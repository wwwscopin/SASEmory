%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye);
%if %sysfunc(exist(&bye.)) %then %do;
proc delete data=&bye.;
run;
%end;
%mend removeOldFile;
%removeOldFile(work.redcap);

data REDCAP;
%let _EFIERR_ = 0;
infile "&path.\csv\function.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat dt_digit_span yymmdd10. ;
	informat trail_a $500. ;
	informat trail_b $500. ;
	informat tot_forward $500. ;
	informat tot_back $500. ;
	informat karn_score $500. ;
	informat functional_scores_complete best32. ;

	format patient_id $500. ;
	format dt_digit_span yymmdd10. ;
	format trail_a $500. ;
	format trail_b $500. ;
	format tot_forward $500. ;
	format tot_back $500. ;
	format karn_score $500. ;
	format functional_scores_complete best12. ;

input
		patient_id $
		dt_digit_span
		trail_a $
		trail_b $
		tot_forward $
		tot_back $
		karn_score $
		functional_scores_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label dt_digit_span='Date';
	label trail_a='Number of seconds for Trail A test';
	label trail_b='Number of seconds for Trail B test';
	label tot_forward='Total Forward Score';
	label tot_back='Total Backwards Score';
	label karn_score='Karnofsky Score (%)';
	label functional_scores_complete='Complete?';
	run;

proc format;
	value functional_scores_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap(rename=(karn_score=karn_score0));

	karn_score=karn_score0+0;
	drop karn_score0;
	format functional_scores_complete functional_scores_complete_.;
	run;

data brent.func;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.func short varnum; run;
