options nodate nonumber orientation = portrait;
%include "/ttcmv/sas/programs/include/monthly_internal_toc.sas"; 
%let path=/ttcmv/sas/output/monthly_internal/;

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

proc format;

  value nat      99 = "-"
                 1 = "Not detected"
                 2 = "Low positive"
                 4 = "Indeterminate"
                 3 = "Positive" ;

  value outcome  99 = "-"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inconclusive" ;
                
run;

data cmv;
    set tmp;
    where indication=01;
    *if nmiss(medcode, dose)>=1 then delete;
run;

proc sort; by id; run;

data cmv;
    merge cmv(in=A keep=id Indication MedCode MedName) cmv.sus_cmv_p4(keep=id BloodNATResult UrineNATResult SerologyResult UrineCultureResult); by id;
    if A;
    format BloodNATResult UrineNATResult nat. SerologyResult UrineCultureResult outcome.;
run;

options orientation=landscape;
ods rtf file="cmv.rtf" style=journal;
proc print;run;
ods rtf close;

options orientation=portrait;
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

proc freq data=other;
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

proc freq data=tmp;
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
	format pct 5.1 Indication Indication.;
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
	if indication^=8 and indication^=0 and medcode^=21;
run;

proc format;
     value MedCode  1 = "Aminoglycoside"
                 2 = "Ampicilline/Penicillin"
                 3 = "Analgesics/Anesthetic/Anamnestic"
                 4 = "Bicarbonate"
                 5 = "Caffeine/Theophylline"
                 6 = "Electrolyte"
                 7 = "Cephalosporin"
                 8 = "Cardiac"
                 9 = "Anti-convulsant"
                 10 = "Diuretic"
                 11 = "Flagyl(Metronidazole)"
                 12 = "Ganciclovir"
                 13 = "Ibuprofin"
                 14 = "Indomethicin/Indocin"
                 15 = "Insulin"
                 16 = "Immunoglobin"
                 17 = "Steroid"
                 18 = "Surfactant"
                 19 = "Vancomycin"
                 20 = "Valganciclovir" 
				 21 = "Other"
				 22 = "Other antibiotic"
				 23 = "Vitamin"
                 24 = "Vaccine"
                 25 = "Inhaled medication"
                 26 = "Suppository"
                 27 = "Gastroespohageal reflux"
                 28 = "Volume expansion meds"
                 29 = "Electrolyte replacement"
                 ;
					
run;

************************************************************************;

options nodate;

ods rtf file="&path.&file_con_med.conmed.rtf" style=journal startpage=no bodytitle;
*title "Summary for Concomitant Medication (n=&n)";
title "&title_con_med (n=&n)";
proc report data=conmed nowindows split='*' style=[just=left];
    column indication medcode unit count pct tmp_day tmp_dose;
    define indication/"Indication" group order style=[cellwidth=1.5in just=left]; 
	define medcode/"Med Code" format=medcode. style=[cellwidth=2.5in just=left]; 
	define unit/"Unit";
	define count/"Ever Used";
	define pct/"Percent";
	define tmp_day/"Median Days";
	define tmp_dose/"Median Dose" style=[just=center];
run;
ods rtf close;




