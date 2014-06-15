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
infile "&path\CSV\followup_lab.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat hiv_rna1_follow $500. ;
	informat dt_rna1_follow yymmdd10. ;
	informat hiv_rna2_follow $500. ;
	informat dt_rna2_follow yymmdd10. ;
	informat hiv_rna3_follow $500. ;
	informat dt_rna3_follow yymmdd10. ;
	informat hiv_rna4_follow $500. ;
	informat dt_rna4_follow yymmdd10. ;
	informat hiv_rna5_follow $500. ;
	informat dt_rna5_follow yymmdd10. ;
	informat hiv_rna6_follow $500. ;
	informat dt_rna6_follow yymmdd10. ;
	informat hiv_rna7_follow $500. ;
	informat dt_rna7_follow yymmdd10. ;
	informat cd4_1_follow $500. ;
	informat dt_cd4_1_follow yymmdd10. ;
	informat cd4_2_follow $500. ;
	informat dt_cd4_2_follow yymmdd10. ;
	informat cd4_3_follow $500. ;
	informat dt_cd4_3_follow yymmdd10. ;
	informat cd4_4_follow $500. ;
	informat dt_cd4_4_follow yymmdd10. ;
	informat cd4_5_follow $500. ;
	informat dt_cd4_5_follow yymmdd10. ;
	informat cd4_6_follow $500. ;
	informat dt_cd4_6_follow yymmdd10. ;
	informat cd4_7_follow $500. ;
	informat dt_cd4_7_follow yymmdd10. ;
	informat hiv_rna_enroll_follow $500. ;
	informat dt_hiv_rna_enroll_follow yymmdd10. ;
	informat cd4_enroll_follow $500. ;
	informat dt_cd4_enroll_follow yymmdd10. ;
	informat follow_up_laboratory_v_0 best32. ;

	format patient_id $500. ;
	format hiv_rna1_follow $500. ;
	format dt_rna1_follow yymmdd10. ;
	format hiv_rna2_follow $500. ;
	format dt_rna2_follow yymmdd10. ;
	format hiv_rna3_follow $500. ;
	format dt_rna3_follow yymmdd10. ;
	format hiv_rna4_follow $500. ;
	format dt_rna4_follow yymmdd10. ;
	format hiv_rna5_follow $500. ;
	format dt_rna5_follow yymmdd10. ;
	format hiv_rna6_follow $500. ;
	format dt_rna6_follow yymmdd10. ;
	format hiv_rna7_follow $500. ;
	format dt_rna7_follow yymmdd10. ;
	format cd4_1_follow $500. ;
	format dt_cd4_1_follow yymmdd10. ;
	format cd4_2_follow $500. ;
	format dt_cd4_2_follow yymmdd10. ;
	format cd4_3_follow $500. ;
	format dt_cd4_3_follow yymmdd10. ;
	format cd4_4_follow $500. ;
	format dt_cd4_4_follow yymmdd10. ;
	format cd4_5_follow $500. ;
	format dt_cd4_5_follow yymmdd10. ;
	format cd4_6_follow $500. ;
	format dt_cd4_6_follow yymmdd10. ;
	format cd4_7_follow $500. ;
	format dt_cd4_7_follow yymmdd10. ;
	format hiv_rna_enroll_follow $500. ;
	format dt_hiv_rna_enroll_follow yymmdd10. ;
	format cd4_enroll_follow $500. ;
	format dt_cd4_enroll_follow yymmdd10. ;
	format follow_up_laboratory_v_0 best12. ;

input
		patient_id $
		hiv_rna1_follow $
		dt_rna1_follow
		hiv_rna2_follow $
		dt_rna2_follow
		hiv_rna3_follow $
		dt_rna3_follow
		hiv_rna4_follow $
		dt_rna4_follow
		hiv_rna5_follow $
		dt_rna5_follow
		hiv_rna6_follow $
		dt_rna6_follow
		hiv_rna7_follow $
		dt_rna7_follow
		cd4_1_follow $
		dt_cd4_1_follow
		cd4_2_follow $
		dt_cd4_2_follow
		cd4_3_follow $
		dt_cd4_3_follow
		cd4_4_follow $
		dt_cd4_4_follow
		cd4_5_follow $
		dt_cd4_5_follow
		cd4_6_follow $
		dt_cd4_6_follow
		cd4_7_follow $
		dt_cd4_7_follow
		hiv_rna_enroll_follow $
		dt_hiv_rna_enroll_follow
		cd4_enroll_follow $
		dt_cd4_enroll_follow
		follow_up_laboratory_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label hiv_rna1_follow='1. HIV-1 RNA Viral Load';
	label dt_rna1_follow='Date of test';
	label hiv_rna2_follow='2. HIV-1 RNA Viral Load';
	label dt_rna2_follow='Date of test';
	label hiv_rna3_follow='3. HIV-1 RNA Viral Load';
	label dt_rna3_follow='Date of test';
	label hiv_rna4_follow='4. HIV-1 RNA Viral Load';
	label dt_rna4_follow='Date of test';
	label hiv_rna5_follow='5. HIV-1 RNA Viral Load';
	label dt_rna5_follow='Date of test';
	label hiv_rna6_follow='6. HIV-1 RNA Viral Load';
	label dt_rna6_follow='Date of test';
	label hiv_rna7_follow='7. HIV-1 RNA Viral Load';
	label dt_rna7_follow='Date of test';
	label cd4_1_follow='1. Absolute CD4 Count';
	label dt_cd4_1_follow='Date of test';
	label cd4_2_follow='2. Absolute CD4 Count';
	label dt_cd4_2_follow='Date of test';
	label cd4_3_follow='3. Absolute CD4 Count';
	label dt_cd4_3_follow='Date of test';
	label cd4_4_follow='4. Absolute CD4 Count';
	label dt_cd4_4_follow='Date of test';
	label cd4_5_follow='5. Absolute CD4 Count';
	label dt_cd4_5_follow='Date of test';
	label cd4_6_follow='6. Absolute CD4 Count';
	label dt_cd4_6_follow='Date of test';
	label cd4_7_follow='7. Absolute CD4 Count';
	label dt_cd4_7_follow='Date of test';
	label hiv_rna_enroll_follow='HIV-1 RNA Viral Load';
	label dt_hiv_rna_enroll_follow='Date of test';
	label cd4_enroll_follow='Absolute CD4 Count';
	label dt_cd4_enroll_follow='Date of test';
	label follow_up_laboratory_v_0='Complete?';
	run;

proc format;
	value follow_up_laboratory_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format follow_up_laboratory_v_0 follow_up_laboratory_v_0_.;
	run;

data brent.followup_lab;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;
