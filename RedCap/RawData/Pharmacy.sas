%let path=H:\SAS_Emory\RedCap;
libname brent "&path.\data";

%macro removeOldFile(bye);
%if %sysfunc(exist(&bye.)) %then %do;
proc delete data=&bye.;
run;
%end;
%mend removeOldFile;
%removeOldFile(work.redcap);

data REDCAP;
%let _EFIERR_ = 0;
infile "&path.\csv\pharmacy.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat refill_num best32. ;
	informat dt_refill_1 yymmdd10. ;
	informat refill_amt_1 $500. ;
	informat dt_refill_2 yymmdd10. ;
	informat refill_amt_2 $500. ;
	informat dt_refill_3 yymmdd10. ;
	informat refill_amt_3 $500. ;
	informat dt_refill_4 yymmdd10. ;
	informat refill_amt_4 $500. ;
	informat dt_refill_5 yymmdd10. ;
	informat refill_amt_5 $500. ;
	informat dt_refill_6 yymmdd10. ;
	informat refill_amt_6 $500. ;
	informat dt_refill_7 yymmdd10. ;
	informat refill_amt_7 $500. ;
	informat dt_refill_8 yymmdd10. ;
	informat refill_amt_8 $500. ;
	informat dt_refill_9 yymmdd10. ;
	informat refill_amt_9 $500. ;
	informat dt_refill_10 yymmdd10. ;
	informat refill_amt_10 $500. ;
	informat pharmacy_refills_complete best32. ;

	format patient_id $500. ;
	format refill_num best12. ;
	format dt_refill_1 yymmdd10. ;
	format refill_amt_1 $500. ;
	format dt_refill_2 yymmdd10. ;
	format refill_amt_2 $500. ;
	format dt_refill_3 yymmdd10. ;
	format refill_amt_3 $500. ;
	format dt_refill_4 yymmdd10. ;
	format refill_amt_4 $500. ;
	format dt_refill_5 yymmdd10. ;
	format refill_amt_5 $500. ;
	format dt_refill_6 yymmdd10. ;
	format refill_amt_6 $500. ;
	format dt_refill_7 yymmdd10. ;
	format refill_amt_7 $500. ;
	format dt_refill_8 yymmdd10. ;
	format refill_amt_8 $500. ;
	format dt_refill_9 yymmdd10. ;
	format refill_amt_9 $500. ;
	format dt_refill_10 yymmdd10. ;
	format refill_amt_10 $500. ;
	format pharmacy_refills_complete best12. ;

input
		patient_id $
		refill_num
		dt_refill_1
		refill_amt_1 $
		dt_refill_2
		refill_amt_2 $
		dt_refill_3
		refill_amt_3 $
		dt_refill_4
		refill_amt_4 $
		dt_refill_5
		refill_amt_5 $
		dt_refill_6
		refill_amt_6 $
		dt_refill_7
		refill_amt_7 $
		dt_refill_8
		refill_amt_8 $
		dt_refill_9
		refill_amt_9 $
		dt_refill_10
		refill_amt_10 $
		pharmacy_refills_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label refill_num='Number of refills to enter';
	label dt_refill_1='1. Refill date';
	label refill_amt_1='Amount dispensed';
	label dt_refill_2='2. Refill date';
	label refill_amt_2='Amount dispensed';
	label dt_refill_3='3. Refill date';
	label refill_amt_3='Amount dispensed';
	label dt_refill_4='4. Refill date';
	label refill_amt_4='Amount dispensed';
	label dt_refill_5='5. Refill date';
	label refill_amt_5='Amount dispensed';
	label dt_refill_6='6. Refill date';
	label refill_amt_6='Amount dispensed';
	label dt_refill_7='7. Refill date';
	label refill_amt_7='Amount dispensed';
	label dt_refill_8='8. Refill date';
	label refill_amt_8='Amount dispensed';
	label dt_refill_9='9. Refill date';
	label refill_amt_9='Amount dispensed';
	label dt_refill_10='10. Refill date';
	label refill_amt_10='Amount dispensed';
	label pharmacy_refills_complete='Complete?';
	run;

proc format;
	value pharmacy_refills_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format pharmacy_refills_complete pharmacy_refills_complete_.;
	run;

proc contents data=redcap;


data brent.refill;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

proc print data=brent.refill(obs=50);run;
