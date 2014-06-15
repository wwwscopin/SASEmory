options nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));

libname TAMOF "S:\bios\TAMOF\Reporting\data";

proc sort data=tamof.daily; by patientid; run;
proc sort data=tAMOF.demographic; by patientid; run;
proc print;run;
proc contents;run;
proc sort data=tamof.admitting_diagnoses; by patientid; run;
proc contents;run;
proc print;
var patientid admitting_diagnosis;
run;

proc format; 

value ishisp
	0 = "Non-Hispanic"
	1 = "Hispanic"
;   

value idx
	1 = "Age(years)"
	2 = "Weight(kg)"
	3 = "Baseline PELOD Score"
	4 = "Baseline PRISM Score"
	5 = "Baseline OFI Score"
	6 = "Baseline Platelet Count"
	7 = "Baseline ADAMTS-13"
	8 = "Baseline VWF Ag"
	9 = "Baseline Ristocetin Cofactor"
;

value item
	0 =" "
	1 = "Gender"
	2 = "Ethnicity"
	3 = "Race"
	4 = "Admitting Diagnosis"
	5 = "On ECMO"
	6 = "On CVVH"
	7 =" "
	8 = "Age(years)"
	9 = "Weight(kg)"
	10 = "Baseline PELOD Score"
	11 = "Baseline PRISM Score"
	12 = "Baseline OFI Score"
	13 = "Baseline Platelet Count(1000 cell/&mu.L)"
	14 = "Baseline ADAMTS-13 (%)"
	15 = "Baseline vWF Antigen (%)"
	16 = "Baseline Ristocetin Cofactor (%)"
;

value yn 0 ="No" 1 ="Yes" ;

value gender 0 = "Female"  1 = "Male";

value pe 0="No Plasma Exchange" 1="Plasma Exchange" 9="Overall";

value race
	1 ="Black"
	2 ="American Indian or Alaskan Native"
	3 ="White"
	4 ="Native Hawaiian or Other Pacific Islander"
	5 ="Asian"
	6 ="More than one race"
	7 ="Other"
;

	value dg 1="Sepsis (Staph)" 2="Sepsis (Non-staph)" 3="Non-Sepsis";

run;

data tamof tamof_pe tamof_ecmo tamof_noecmo;
	merge 
		TAMOF.demographic(keep=patientid  AgeEnrollmentYear gender race IsHispanic in=A)
		tamof.daily(where=(treatmentday=1) keep=patientid treatmentday weight PelodTotalScore PRISMIII_Score OFI_Score iscvvhon   isecmoon
		platelets )
		tamof.lab(where=(day=0) keep=patientid day adamts13  vwf_ag  vwf_rca)
		TAMOF.survival(keep=patientid plasmaexchange ecmo censor)
		tamof.admitting_diagnoses; by patientid;
	if A;
	if patientid=110002 then censor=1;
	if gender=2 then gender=0;
	rename AgeEnrollmentYear=age PelodTotalScore=pelod PRISMIII_Score=prism OFI_Score=ofi platelets=plt  PlasmaExchange=pe;
	if PlasmaExchange=1 then output tamof_pe;	
	if PlasmaExchange=1 and ecmo=1 then output tamof_ecmo;
	if PlasmaExchange=1 and ecmo=0 then output tamof_noecmo;
	output tamof;
run;
proc contents data=tamof;run;

	proc freq data=tamof;
		tables pe/out=temp;
	run;

	%macro tab(data, group, varlist,out)/minoperator parmbuff;

proc freq data=&data; 
	tables &group/out=temp;
run;

%global n0=0;
%global n1=0;
%global n=0;

data _null_;
	set temp;
	if &group=0 then call symput("n0", put(count,2.0));
	if &group=1 then call symput("n1", put(count,2.0));
run;

%let n=%eval(&n0+&n1);

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	proc freq data=&data;
		table &var*&group/nocol nopercent chisq;
		ods output crosstabfreqs = tab;
		output out = p&i chisq exact;
	run;

	data tab;
		set tab;
		if &group=. then &group=9;
	run;
	proc sort; by &group &var;run;

	data tab&i;
		merge tab(where=(&var^=.)) tab(where=(&var=.) rename=(frequency=n)); by &group &var;
		retain m;
		if first.&group then m=n;
		if n=. then n=m;
		if &var=. then delete;
		f=frequency/n*100;
		col=compress(frequency||"/"||n||"("||put(f,4.1)||"%)");
		keep &group &var frequency n col;
	run;
	
	proc sort; by &var; run;
	proc transpose data=tab&i out=tab&i; var col; by &var;run;

	data tab&i; set tab&i; item=&i;run;

	data p&i;
		XP2_FISH=.;
		set p&i;
		item=&i;
		pvalue=XP2_FISH+0;
		if pvalue=. then pvalue= P_PCHI+0;
		if pvalue^=. and pvalue<0.01 then pv='<0.01'; else pv=put(pvalue,4.2);
		keep item pvalue pv;
		if _n_=1;
	run;

	data tab&i;
		merge tab&i p&i; by item ;
		rename &var=code;
	run;

	data &out;
		length code0 $100;
		set &out tab&i;

		if item=1 then  do; code0=put(code, gender.); end;
		if item=2 then  do; code0=put(code, ishisp.); end;
		if item=3 then  do; code0=put(code, race.); end;
		if item=4 then  do; code0=put(code, dg.); end;
		if item=5 then  do; code0=put(code, yn.); end;
		if item=6 then  do; code0=put(code, yn.); end;
		format item item. code;
		drop _name_;
	run; 
   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%macro col(data, group, varlist, out);

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

proc means data=&data n mean std;
	class &group;
	var &var;
	output out=tmp n= mean= std= /autoname;
run;

data tab&i;
	set tmp;
	col=compress(put(&var._mean,5.1)||"("||put(&var._stddev,4.1)||"),"||&var._n);
	idx=&i;
	if &group=. then &group=9; 
	if &var._n=0 then col=" ";
	keep &group idx col;
run;

proc npar1way data =&data wilcoxon;
	class &group;
	var &var;
	ods output WilcoxonTest=wp&i;
run;

data wp&i;
	length pv $5;
	set wp&i;
	if _n_=10;
	idx=&i;
	pvalue=cvalue1+0;
	pv=put(pvalue, 4.2);
	if pvalue<0.01 then pv='<0.01';
	keep idx pvalue pv;
run;

data tab&i;
	merge tab&i(where=(&group=9)) tab&i(where=(&group=0)rename=(col=col0)) tab&i(where=(&group=1)rename=(col=col1)) wp&i; 
	by idx;
	drop &group;
	format idx idx.;
run;

data &out;
	set &out tab&i;
run;
%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend col;

%let varlist1=gender IsHispanic race admitting_diagnosis isecmoon iscvvhon;
%let varlist2=age weight Pelod PRISM OFI plt adamts13  vwf_ag  vwf_rca;

%tab(tamof, pe, &varlist1, char); run;
%col(tamof, pe, &varlist2, base); run;

data blank;
	item=0;  col0="Num/Total (%)"; pv="p value"; output;
	item=7;  col0="Mean(SD),N"; pv="p value"; output;
run;

data demo_base;
	length pv $8;
	set char(rename=(col3=col col1=col0 col2=col1)) base(rename=(idx=item) in=B) blank;

	if B then item=item+7;
	format item item.;
run;

proc sort; by item;run;

data demo_base;
	set demo_base; by item;
	if not first.item then pv=" " ;
run;

ods rtf file="demo_base.rtf" style=journal startpage=no bodytitle;
title "Demographic and Baseline Medical Information by Treatment";
proc print data=demo_base noobs label split='*' style(column)=[just=right] style(header)=[just=center];
by item ;
id item;
var code0/style(column)=[just=center cellwidth=1.25in];
var col col0 col1 pv;
label item="."
	  code0="."
	  col="Overall*(n=&n)"
	  col0="No Plasma Exchange*(n=&n0)"
	  col1="Plasma Exchange*(n=&n1)"
	  pv="."
	  ;
run;
ods rtf close;

%tab(tamof_pe, censor, &varlist1, char_pe);	run;
%col(tamof_pe, censor, &varlist2, base_pe); run;

proc print data=char_pe;run;

data demo_base_pe;
	length pv $8;
	set char_pe(rename=(col3=col col1=col0 col2=col1)) base_pe(rename=(idx=item) in=B) blank;
	if B then item=item+7;
	format item item.;
run;


proc sort; by item;run;

data demo_base_pe;
	set demo_base_pe; by item;
	if not first.item then pv=" " ;
run;

ods rtf file="demo_base_pe.rtf" style=journal startpage=no bodytitle;
title "Demographic and Baseline Medical Information for Children Receiving Plasma Exchange";
proc print data=demo_base_pe noobs label split='*' style(column)=[just=right] style(header)=[just=center];
by item ;
id item;
var code0/style(column)=[just=center cellwidth=1.25in];
var col col0 col1 pv;
label item="."
	  code0="."
	  col="Overall*(n=&n)"
	  col0="Non Survivors*(n=&n0)"
	  col1="Survivors*(n=&n1)"
	  pv="."
	  ;
run;
ods rtf close;


%tab(tamof_ecmo, censor, &varlist1, char_ecmo);	run;
%col(tamof_ecmo, censor, &varlist2, base_ecmo); run;


data demo_base_ecmo;
	length pv $8;
	set char_ecmo(rename=(col3=col col1=col0 col2=col1)) base_ecmo(rename=(idx=item) in=B) blank;
	if B then item=item+7;
	format item item.;
run;

proc sort; by item;run;

data demo_base_ecmo;
	set demo_base_ecmo; by item;
	if not first.item then pv=" " ;
run;

ods rtf file="demo_base_ecmo.rtf" style=journal startpage=no bodytitle;
title "Demographic and Baseline Medical Information for Children Receiving Plasma Exchange (ECMO)";
proc print data=demo_base_ecmo noobs label split='*' style(column)=[just=right] style(header)=[just=center];
by item ;
id item;
var code0/style(column)=[just=center cellwidth=1.25in];
var col col0 col1 pv;
label item="."
	  code0="."
	  col="Overall*(n=&n)"
	  col0="Non Survivors*(n=&n0)"
	  col1="Survivors*(n=&n1)"
	  pv="."
	  ;
run;
ods rtf close;

%tab(tamof_noecmo, censor, &varlist1, char_noecmo);	run;
%col(tamof_noecmo, censor, &varlist2, base_noecmo); run;

data demo_base_noecmo;
	length pv $8;
	set char_noecmo(rename=(col3=col col1=col0 col2=col1)) base_noecmo(rename=(idx=item) in=B) blank;
	if B then item=item+7;
	format item item.;
run;

proc sort; by item;run;

data demo_base_noecmo;
	set demo_base_noecmo; by item;
	if not first.item then pv=" " ;
run;

ods rtf file="demo_base_noecmo.rtf" style=journal startpage=no bodytitle;
title "Demographic and Baseline Medical Information for Children Receiving Plasma Exchange (no ECMO)";
proc print data=demo_base_noecmo noobs label split='*' style(column)=[just=right] style(header)=[just=center];
by item ;
id item;
var code0/style(column)=[just=center cellwidth=1.25in];
var col col0 col1 pv;
label item="."
	  code0="."
	  col="Overall*(n=&n)"
	  col0="Non Survivors*(n=&n0)"
	  col1="Survivors*(n=&n1)"
	  pv="."
	  ;
run;
ods rtf close;
