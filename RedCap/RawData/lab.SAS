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
infile "&path.\csv\lab.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat hiv_rna1 $500. ;
	informat dt_rna1 yymmdd10. ;
	informat hiv_rna2 $500. ;
	informat dt_rna2 yymmdd10. ;
	informat hiv_rna3 $500. ;
	informat dt_rna3 yymmdd10. ;
	informat hiv_rna4 $500. ;
	informat dt_rna4 yymmdd10. ;
	informat hiv_rna5 $500. ;
	informat dt_rna5 yymmdd10. ;
	informat hiv_rna6 $500. ;
	informat dt_rna6 yymmdd10. ;
	informat hiv_rna7 $500. ;
	informat dt_rna7 yymmdd10. ;
	informat cd4_1 $500. ;
	informat dt_cd4_1 yymmdd10. ;
	informat cd4_2 $500. ;
	informat dt_cd4_2 yymmdd10. ;
	informat cd4_3 $500. ;
	informat dt_cd4_3 yymmdd10. ;
	informat cd4_4 $500. ;
	informat dt_cd4_4 yymmdd10. ;
	informat cd4_5 $500. ;
	informat dt_cd4_5 yymmdd10. ;
	informat cd4_6 $500. ;
	informat dt_cd4_6 yymmdd10. ;
	informat cd4_7 $500. ;
	informat dt_cd4_7 yymmdd10. ;
	informat hiv_rna_enroll $500. ;
	informat dt_hiv_rna_enroll yymmdd10. ;
	informat cd4_enroll $500. ;
	informat dt_cd4_enroll yymmdd10. ;
	informat laboratory_results_complete best32. ;

	format patient_id $500. ;
	format hiv_rna1 $500. ;
	format dt_rna1 yymmdd10. ;
	format hiv_rna2 $500. ;
	format dt_rna2 yymmdd10. ;
	format hiv_rna3 $500. ;
	format dt_rna3 yymmdd10. ;
	format hiv_rna4 $500. ;
	format dt_rna4 yymmdd10. ;
	format hiv_rna5 $500. ;
	format dt_rna5 yymmdd10. ;
	format hiv_rna6 $500. ;
	format dt_rna6 yymmdd10. ;
	format hiv_rna7 $500. ;
	format dt_rna7 yymmdd10. ;
	format cd4_1 $500. ;
	format dt_cd4_1 yymmdd10. ;
	format cd4_2 $500. ;
	format dt_cd4_2 yymmdd10. ;
	format cd4_3 $500. ;
	format dt_cd4_3 yymmdd10. ;
	format cd4_4 $500. ;
	format dt_cd4_4 yymmdd10. ;
	format cd4_5 $500. ;
	format dt_cd4_5 yymmdd10. ;
	format cd4_6 $500. ;
	format dt_cd4_6 yymmdd10. ;
	format cd4_7 $500. ;
	format dt_cd4_7 yymmdd10. ;
	format hiv_rna_enroll $500. ;
	format dt_hiv_rna_enroll yymmdd10. ;
	format cd4_enroll $500. ;
	format dt_cd4_enroll yymmdd10. ;
	format laboratory_results_complete best12. ;

input
		patient_id $
		hiv_rna1 $
		dt_rna1
		hiv_rna2 $
		dt_rna2
		hiv_rna3 $
		dt_rna3
		hiv_rna4 $
		dt_rna4
		hiv_rna5 $
		dt_rna5
		hiv_rna6 $
		dt_rna6
		hiv_rna7 $
		dt_rna7
		cd4_1 $
		dt_cd4_1
		cd4_2 $
		dt_cd4_2
		cd4_3 $
		dt_cd4_3
		cd4_4 $
		dt_cd4_4
		cd4_5 $
		dt_cd4_5
		cd4_6 $
		dt_cd4_6
		cd4_7 $
		dt_cd4_7
		hiv_rna_enroll $
		dt_hiv_rna_enroll
		cd4_enroll $
		dt_cd4_enroll
		laboratory_results_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label hiv_rna1='1. HIV-1 RNA Viral Load';
	label dt_rna1='Date of test';
	label hiv_rna2='2. HIV-1 RNA Viral Load';
	label dt_rna2='Date of test';
	label hiv_rna3='3. HIV-1 RNA Viral Load';
	label dt_rna3='Date of test';
	label hiv_rna4='4. HIV-1 RNA Viral Load';
	label dt_rna4='Date of test';
	label hiv_rna5='5. HIV-1 RNA Viral Load';
	label dt_rna5='Date of test';
	label hiv_rna6='6. HIV-1 RNA Viral Load';
	label dt_rna6='Date of test';
	label hiv_rna7='7. HIV-1 RNA Viral Load';
	label dt_rna7='Date of test';
	label cd4_1='1. Absolute CD4 Count';
	label dt_cd4_1='Date of test';
	label cd4_2='2. Absolute CD4 Count';
	label dt_cd4_2='Date of test';
	label cd4_3='3. Absolute CD4 Count';
	label dt_cd4_3='Date of test';
	label cd4_4='4. Absolute CD4 Count';
	label dt_cd4_4='Date of test';
	label cd4_5='5. Absolute CD4 Count';
	label dt_cd4_5='Date of test';
	label cd4_6='6. Absolute CD4 Count';
	label dt_cd4_6='Date of test';
	label cd4_7='7. Absolute CD4 Count';
	label dt_cd4_7='Date of test';
	label hiv_rna_enroll='HIV-1 RNA Viral Load';
	label dt_hiv_rna_enroll='Date of test';
	label cd4_enroll='Absolute CD4 Count';
	label dt_cd4_enroll='Date of test';
	label laboratory_results_complete='Complete?';
	run;

proc format;
	value laboratory_results_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format laboratory_results_complete laboratory_results_complete_.;
	run;

data brent.lab;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

proc contents data=brent.lab; run;
proc contents data=brent.lab short varnum; run;
