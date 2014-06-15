%include "stat_macro.sas";
%let pm=%sysfunc(byte(177));

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Johnson\Arthroplasty Sheet for analysis.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:N75"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data tmp;
	set tmp;
	if _n_=1 then delete;
run;

%macro como(data, out, varlist);
data &out;
	if 1=1 then delete;
run;

%do j=1 %to 73;
	data _null_;
		set &data(firstobs=&j obs=&j);
		call symput("char",&varlist);
	run;

	data temp;
		set &data(firstobs=&j obs=&j);
	
		%let i = 1;
		%let cm=%scan(%bquote(&char), &i);
		%do %while(&cm NE );
			if &cm=1  then HTN=1;     *else HTN=0;
			if &cm=2  then DMII=1;    *else DMII=0;
			if &cm=3  then Gerd=1;    *else gerd=0;
			if &cm=4  then psych=1;   *else psych=0;
			if &cm=5  then cancer=1;  *else cancer=0;
			if &cm=6  then Hema=1;    *else Hema=0;
			if &cm=7  then anemia=1;  *else anemia=0;
			if &cm=8  then asthma=1;  *else asthma=0;
			if &cm=9  then Cir=1;     *else Cir=0;
			if &cm=10 then dys=1;     *else dys=0;
			if &cm=11 then cad=1;     *else cad=0;
			if &cm=12 then hypo=1;    *else hypo=0;
			if &cm=13 then ra=1;      *else ra=0;
			if &cm=14 then obesity=1; *else obesity=0;
			if &cm=15 then morbid=1;  *else morbid=0;
			if &cm=16 then chf=1;     *else chf=0;
			if &cm=17 then Ost=1;     *else Ost=0;
			if &cm=18 then abuse=1;   *else abuse=0;
			if &cm=19 then ptsd=1;    *else ptsd=0;
			if &cm=20 then ckd=1;     *else ckd=0;
			if &cm=21 then hcv=1;     *else hcv=0;
			if &cm=22 then cat=1;     *else cat=0;
			if &cm=23 then dysp=1;    *else dysp=0;
			if &cm=24 then mig=1;     *else mig=0;
			if &cm=25 then afib=1;    *else afib=0;
			if &cm=26 then hx=1;      *else hx=0;
			if &cm=27 then cytosis=1; *else cytosis=0;
			*como&i=&cm;
   			%let i= %eval(&i+1);
   			%let cm= %scan(%bquote(&char),&i);
		%end;
	run;

	data &out;
		set &out temp;
	run;
%end;
%mend como;
%como(tmp, tab0, Co_morbidities);

proc freq data=tmp; 
tables Co_morbidities;
run;

proc format;
	value gender 0="Female" 1="Male";
	value yn 0="No" 1="Yes";
	value Op 1="TKA" 2="THA" 3="Revision TKA" 4="Revision THA";
	value cm 1="HTN" 2="DMII" 3="GERD" 4="Psych" 5="Cancer" 6="Hemachromatosis" 7="Anemia" 8="Asthma" 9="Cirrhosis" 10="Dyslipidemia"
			 11="CAD" 12="Hypothyroidism" 13="RA" 14="Obesity" 15="Morbid Obesity" 16="CHF" 17="Osteoporosis" 18="Substance abuse" 19="PTSD" 20="CKD"
			 21="HCV" 22="Cataracts" 23="Dysphonia" 24="Migraines" 25="Afib" 26="Hx of DVT/PE" 27="Macrocytosis";
	value insu 1="None" 2="Medicaire" 3="Medicaid/SSI" 4="Evercare" 5="Conifer" 6="First Southern";
	value Smoker 1="No" 2="Quit for surgery";
	value ind 1="OA" 2="AVN" 3="RA" 4="DJD" 5="Post-traumatic" 6="Revision" 7="Osteosarc" 8="Fibrous dysplasia 2/2 hardware" 9="DDH";
	value comp 1="None" 2="HO" 3="Pain" 4="Wound Drainage" 5="Ulcer" 6="Numb area" 7="Hematoma" 8="Trochanteric Bursitis" 9="Leg length discrepency";

	value item 1="Age*Mean &pm SD[Q1-Q3]" 2="Follow-up days*Mean &pm SD[Q1-Q3]" 3="OPeration" 4="Insurance" 5="Smoker" 6="HIV" 7="Nasal Swab" 8="Further Operations" 9="Complications"
		       10="HTN" 11="DMII" 12="GERD" 13="Psych"  14="Cancer"  15="Hemachromatosis" 16="Anemia" 17="Cirrhosis" 18="Dyslipidemia"
			   19="CAD" 20="Hypothyroidism" 21="RA" 22="Obesity" 23="CHF" 24="Osteoporosis" 25="Substance abuse" 26="PTSD" 27="CKD"
			   28="HCV" 29="Cataracts" 30="Migraines" 31="Hx of DVT/PE";
run;

data tab;
	set tab0(rename=(HIV=HIV0 gender=gender0));
	if gender0="F" then gender=0; else if gender0="M" then gender=1;
	if Nasal_Swab="No" then ns=0; else ns=1;
	if Further_Operations="Yes" then fo=1; else fo=0;
	if HIV0="Yes" then hiv=1; else hiv=0;

	if htn=. then htn=0;
	if dmii=. then dmii=0;
	if gerd=. then gerd=0;
	if psych=. then psych=0;
	if cancer=. then cancer=0;
	if hema=. then hema=0;
	if anemia=. then anemia=0;
	if cir=. then cir=0;
	if dys=. then dys=0;
	if cad=. then cad=0;
	if hypo=. then hypo=0;
	if ra=. then ra=0;
	if obesity=. then obesity=0;
	if chf=. then chf=0;
	if ost=. then ost=0; 
	if abuse=. then abuse=0;
	if ptsd=. then ptsd=0;
	if ckd=. then ckd=0;
	if hcv=. then hcv=0;
	if cat=. then cat=0;
	if mig=. then mig=0;
	if hx=. then hx=0;

	rename Follow_up__days_=day inidication=indication;
	drop gender0 hiv0 Nasal_Swab Further_Operations ;
	format gender gender. ns  fo hiv yn. operation op. insurance insu. smoker smoker. inidication ind. complications comp.;
run;

proc contents;run;
/*proc print data=tab;run;*/

%let varlist=age day;
%stat(tab, gender, &varlist);


%let varlist=operation insurance smoker hiv ns fo complications htn dmii gerd psych cancer hema anemia cir dys cad hypo ra obesity chf ost abuse ptsd ckd hcv cat mig hx;
%tab(tab, gender, table, &varlist);


data table;
	length nfn nfy nft code0 $40 pv $6;
	set stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
	    table (in=A) 
		;
	if A then do; item=item+2; end;
	if item=3 then code0=put(code, op.);
		if item=4 then code0=put(code, insu.);
			if item=5 then code0=put(code, smoker.);
				if item in(6,7,8) then code0=put(code, yn.);
					if item=9 then code0=put(code, comp.);
					if item>9 and code=0 then delete;
run;

data table;
	set table; by item;
	if not first.item then do; pvalue=.; or=.; range=.; pv=" "; end;
	format item item.;
run;

ods rtf file="table.rtf" style=journal bodytitle ;
proc report data=table nowindows style(column)=[just=center] split="*";
title "Demographic Table";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=61)";
define nfy/"Male*(n=29)";
define nfn/"Female*(n=32)";
define pv/"p value";
run;
ods rtf close;
