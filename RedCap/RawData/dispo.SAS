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
infile "&path\CSV\dispo.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat disposition___1 best32. ;
	informat disposition___2 best32. ;
	informat disposition___3 best32. ;
	informat dt_last_visit_provider yymmdd10. ;
	informat new_provider $500. ;
	informat provider_locate $500. ;
	informat reason_left $500. ;
	informat dt_last_visit_lost $500. ;
	informat dt_death $500. ;
	informat cause_death $500. ;
	informat disposition_complete best32. ;

	format patient_id $500. ;
	format disposition___1 best12. ;
	format disposition___2 best12. ;
	format disposition___3 best12. ;
	format dt_last_visit_provider yymmdd10. ;
	format new_provider $500. ;
	format provider_locate $500. ;
	format reason_left $500. ;
	format dt_last_visit_lost $500. ;
	format dt_death $500. ;
	format cause_death $500. ;
	format disposition_complete best12. ;

input
		patient_id $
		disposition___1
		disposition___2
		disposition___3
		dt_last_visit_provider
		new_provider $
		provider_locate $
		reason_left $
		dt_last_visit_lost $
		dt_death $
		cause_death $
		disposition_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label disposition___1='Disposition (choice=Changed service provider)';
	label disposition___2='Disposition (choice=Lost to follow-up)';
	label disposition___3='Disposition (choice=Died)';
	label dt_last_visit_provider='Date of last clinic visit';
	label new_provider='Name of new provider';
	label provider_locate='Location of new provider';
	label reason_left='Reason for leaving';
	label dt_last_visit_lost='Date of last clinic visit';
	label dt_death='Date of death';
	label cause_death='Cause of death, if known';
	label disposition_complete='Complete?';
	run;

proc format;
	value disposition___1_ 0='Unchecked' 1='Checked';
	value disposition___2_ 0='Unchecked' 1='Checked';
	value disposition___3_ 0='Unchecked' 1='Checked';
	value disposition_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format disposition___1 disposition___1_.;
	format disposition___2 disposition___2_.;
	format disposition___3 disposition___3_.;
	format disposition_complete disposition_complete_.;
	run;

data brent.dispo;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;
