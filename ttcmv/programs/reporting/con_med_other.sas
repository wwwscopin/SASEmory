optiont nodate;

data all_pat;
	set cmv.comp_pat(keep=id);
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;

%let  n=0;
data _null_;
	set all_pat;
	call symput("n", compress(_n_));
run;


%macro conmed(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 9;
		center=floor(id/1000000);
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

		keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
		format  StartDate EndDate mmddyy8. center center. MedCode MedCode. Indication Indication. unit unit.;
run;
%mend;

%conmed(cmv.con_meds);quit;

proc freq data=tmp(where=(medcode in(21,22))) noprint;
	table indication*medcode*medname/out=medname;
run;

proc contents; run;
proc sort; by descending count;run;

ods rtf file="medname.rtf" style=journal;
proc print; 
	title "Concomitant Medication Summary";
	where indication^=. and medname^=" ";
	var indication ;
	var medcode/style(data)=[cellwidth=1.0in];
	var medname count percent; 
	format percent 4.1;
run;
ods rtf close;


proc sql;
	create table tmp as
	select tmp.*
	from tmp, all_pat
	where tmp.id=all_pat.id
;


data tmp;
	set tmp;
	if id=1002011 and medname="PENICILLIN" then dose=65000.00;
  	if Unit=4 then do; Unit=1; dose=dose/1000; end;
	*if unit=99 then delete;
run;

proc sort; by indication medcode unit;run;



*************************************************************************;

data other;
	set tmp;
	where medcode=21;
run;
proc sort; by indication medname unit;run;

proc means data=other n median noprint;
	class indication medname unit;
	var day dose;
	output out = cm_other median(day) = median_day n(day)=n_day median(dose) = median_dose n(dose) = n_dose;
run;

data cm_other;
	set cm_other;
	if indication=. or medname=" " or unit=. then delete;
	drop _type_  _freq_;
run;

data cm_other;
	set cm_other;
	group=_n_;
run;

proc sort; by indication medname unit;run;

data other;
	merge other cm_other(keep=indication medname unit group); by indication medname unit;
run;

proc sort nodupkey; by indication medname unit id; run;

proc freq data=other noprint;
table group/out=other_pct;
run;

data cm_other;
	merge cm_other other_pct(keep=group count);by group;
	pct=count/&n*100;
	if indication=. or medname=" " or unit=. then delete;
	if median_dose=. then n_dose=count;
	tmp_day=put(median_day,3.0)||"("||strip(put(n_day,3.0))||")";
	tmp_dose=put(median_dose,5.2)||"("||strip(put(n_dose,3.0))||")";
	
	medcode=21;

	medname=lowcase(medname);
	substr(medname,1,1)=upcase(substr(medname,1,1));
	medcode0="Other--"||medname;
	format pct 5.1;
run;

proc sort; by indication medcode medcode0 unit;run;

*************************************************************************;
proc means data=tmp n median noprint;
	class Indication medcode unit;
	*class medname;
	var day dose;
	output out = conmed median(day) = median_day n(day)=n_day median(dose) = median_dose n(dose) = n_dose;
run;

data conmed;
	set conmed;
	if indication=. or medcode=. or unit=. then delete;
	drop _type_  _freq_;
run;

data conmed;
	set conmed;
	group=_n_;
run;

proc sort; by indication medcode unit;run;

data tmp;
	merge tmp conmed(keep=indication medcode unit group); by indication medcode unit;
run;

proc sort nodupkey; by indication medcode unit id; run;

proc freq data=tmp noprint;
table group/out=conmed_pct;
run;

data conmed;
	merge conmed conmed_pct(keep=group count);by group;
	pct=count/&n*100;
	if indication=. or medcode=. or unit=. then delete;
	if median_dose=. then n_dose=count;
	tmp_day=put(median_day,3.0)||"("||strip(put(n_day,3.0))||")";
	tmp_dose=put(median_dose,5.2)||"("||strip(put(n_dose,3.0))||")";
	if medcode^=21 then medcode0=put(medcode, medcode.);
	format pct 5.1;
run;

proc sort; by indication medcode medcode0 unit;run;

data conmed;
	merge conmed cm_other; by indication medcode medcode0 unit; 
	if medcode0=" " then delete;
run;

data conmed;
	set conmed(where=(indication^=8)) conmed(where=(indication=8));
	 label 	count='Ever Used'
			pct="Percent(%)"
			medcode0="MedCode"
			percent='Percent(%)'
			tmp_day='Median Days*(count)'
			tmp_dose='Median Dose*(count)'
	;
run;

ods rtf file="conmed_other.rtf" style=journal startpage=no bodytitle;
title "Summary for Concomitant Medication (n=&n)";
proc print data=conmed noobs label split='*' style(data)=[just=left];
	where medcode in(21, 22);
	var indication/style(data)=[cellwidth=1.5in]; 
	var medcode0/style(data)=[cellwidth=2.5in]; 
	var unit count;
   var pct tmp_day tmp_dose/style(data)=[just=center];
run;

odf rtf close;


