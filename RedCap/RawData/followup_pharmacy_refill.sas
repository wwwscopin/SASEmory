%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\followup_pharmacy_refill.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat refill_num_follow best32. ;
	informat dt_refill_1_follow yymmdd10. ;
	informat refill_amt_1_follow $500. ;
	informat dt_refill_2_follow yymmdd10. ;
	informat refill_amt_2_follow $500. ;
	informat dt_refill_3_follow yymmdd10. ;
	informat refill_amt_3_follow $500. ;
	informat dt_refill_4_follow yymmdd10. ;
	informat refill_amt_4_follow $500. ;
	informat dt_refill_5_follow yymmdd10. ;
	informat refill_amt_5_follow $500. ;
	informat dt_refill_6_follow yymmdd10. ;
	informat refill_amt_6_follow $500. ;
	informat dt_refill_7_follow yymmdd10. ;
	informat refill_amt_7_follow $500. ;
	informat dt_refill_8_follow yymmdd10. ;
	informat refill_amt_8_follow $500. ;
	informat dt_refill_9_follow yymmdd10. ;
	informat refill_amt_9_follow $500. ;
	informat dt_refill_10_follow yymmdd10. ;
	informat refill_amt_10_follow $500. ;
	informat follow_up_pharmacy_r_v_0 best32. ;

	format patient_id $500. ;
	format refill_num_follow best12. ;
	format dt_refill_1_follow yymmdd10. ;
	format refill_amt_1_follow $500. ;
	format dt_refill_2_follow yymmdd10. ;
	format refill_amt_2_follow $500. ;
	format dt_refill_3_follow yymmdd10. ;
	format refill_amt_3_follow $500. ;
	format dt_refill_4_follow yymmdd10. ;
	format refill_amt_4_follow $500. ;
	format dt_refill_5_follow yymmdd10. ;
	format refill_amt_5_follow $500. ;
	format dt_refill_6_follow yymmdd10. ;
	format refill_amt_6_follow $500. ;
	format dt_refill_7_follow yymmdd10. ;
	format refill_amt_7_follow $500. ;
	format dt_refill_8_follow yymmdd10. ;
	format refill_amt_8_follow $500. ;
	format dt_refill_9_follow yymmdd10. ;
	format refill_amt_9_follow $500. ;
	format dt_refill_10_follow yymmdd10. ;
	format refill_amt_10_follow $500. ;
	format follow_up_pharmacy_r_v_0 best12. ;

input
		patient_id $
		refill_num_follow
		dt_refill_1_follow
		refill_amt_1_follow $
		dt_refill_2_follow
		refill_amt_2_follow $
		dt_refill_3_follow
		refill_amt_3_follow $
		dt_refill_4_follow
		refill_amt_4_follow $
		dt_refill_5_follow
		refill_amt_5_follow $
		dt_refill_6_follow
		refill_amt_6_follow $
		dt_refill_7_follow
		refill_amt_7_follow $
		dt_refill_8_follow
		refill_amt_8_follow $
		dt_refill_9_follow
		refill_amt_9_follow $
		dt_refill_10_follow
		refill_amt_10_follow $
		follow_up_pharmacy_r_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label refill_num_follow='Number of refills to enter';
	label dt_refill_1_follow='1. Refill date';
	label refill_amt_1_follow='Amount dispensed';
	label dt_refill_2_follow='2. Refill date';
	label refill_amt_2_follow='Amount dispensed';
	label dt_refill_3_follow='3. Refill date';
	label refill_amt_3_follow='Amount dispensed';
	label dt_refill_4_follow='4. Refill date';
	label refill_amt_4_follow='Amount dispensed';
	label dt_refill_5_follow='5. Refill date';
	label refill_amt_5_follow='Amount dispensed';
	label dt_refill_6_follow='6. Refill date';
	label refill_amt_6_follow='Amount dispensed';
	label dt_refill_7_follow='7. Refill date';
	label refill_amt_7_follow='Amount dispensed';
	label dt_refill_8_follow='8. Refill date';
	label refill_amt_8_follow='Amount dispensed';
	label dt_refill_9_follow='9. Refill date';
	label refill_amt_9_follow='Amount dispensed';
	label dt_refill_10_follow='10. Refill date';
	label refill_amt_10_follow='Amount dispensed';
	label follow_up_pharmacy_r_v_0='Complete?';
	run;

proc format;
	value follow_up_pharmacy_r_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format follow_up_pharmacy_r_v_0 follow_up_pharmacy_r_v_0_.;
	run;

data brent.followup_pharmacy_refill;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.followup_pharmacy_refill short varnum; run;
