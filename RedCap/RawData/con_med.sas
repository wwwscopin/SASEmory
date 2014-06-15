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
infile "&path.\csv\concom_med.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat med1 $500. ;
	informat dt_start1 $500. ;
	informat med2 $500. ;
	informat dt_start2 $500. ;
	informat med3 $500. ;
	informat dt_start3 $500. ;
	informat med4 $500. ;
	informat dt_start4 $500. ;
	informat med5 $500. ;
	informat dt_start5 $500. ;
	informat med6 $500. ;
	informat dt_start6 $500. ;
	informat med7 $500. ;
	informat dt_start7 $500. ;
	informat med8 $500. ;
	informat dt_start8 $500. ;
	informat med9 $500. ;
	informat dt_start9 $500. ;
	informat med10 $500. ;
	informat dt_start10 $500. ;
	informat med11 $500. ;
	informat dt_start11 $500. ;
	informat med12 $500. ;
	informat dt_start12 $500. ;
	informat med13 $500. ;
	informat dt_start13 $500. ;
	informat med14 $500. ;
	informat dt_start14 $500. ;
	informat med15 $500. ;
	informat dt_start15 $500. ;
	informat med16 $500. ;
	informat dt_start16 $500. ;
	informat med17 $500. ;
	informat dt_start17 $500. ;
	informat med18 $500. ;
	informat dt_start18 $500. ;
	informat med19 $500. ;
	informat dt_start19 $500. ;
	informat med20 $500. ;
	informat dt_start20 $500. ;
	informat med21 $500. ;
	informat dt_start21 $500. ;
	informat med22 $500. ;
	informat dt_start22 $500. ;
	informat med23 $500. ;
	informat dt_start23 $500. ;
	informat concomitant_medicati_v_0 best32. ;

	format patient_id $500. ;
	format med1 $500. ;
	format dt_start1 $500. ;
	format med2 $500. ;
	format dt_start2 $500. ;
	format med3 $500. ;
	format dt_start3 $500. ;
	format med4 $500. ;
	format dt_start4 $500. ;
	format med5 $500. ;
	format dt_start5 $500. ;
	format med6 $500. ;
	format dt_start6 $500. ;
	format med7 $500. ;
	format dt_start7 $500. ;
	format med8 $500. ;
	format dt_start8 $500. ;
	format med9 $500. ;
	format dt_start9 $500. ;
	format med10 $500. ;
	format dt_start10 $500. ;
	format med11 $500. ;
	format dt_start11 $500. ;
	format med12 $500. ;
	format dt_start12 $500. ;
	format med13 $500. ;
	format dt_start13 $500. ;
	format med14 $500. ;
	format dt_start14 $500. ;
	format med15 $500. ;
	format dt_start15 $500. ;
	format med16 $500. ;
	format dt_start16 $500. ;
	format med17 $500. ;
	format dt_start17 $500. ;
	format med18 $500. ;
	format dt_start18 $500. ;
	format med19 $500. ;
	format dt_start19 $500. ;
	format med20 $500. ;
	format dt_start20 $500. ;
	format med21 $500. ;
	format dt_start21 $500. ;
	format med22 $500. ;
	format dt_start22 $500. ;
	format med23 $500. ;
	format dt_start23 $500. ;
	format concomitant_medicati_v_0 best12. ;

input
		patient_id $
		med1 $
		dt_start1 $
		med2 $
		dt_start2 $
		med3 $
		dt_start3 $
		med4 $
		dt_start4 $
		med5 $
		dt_start5 $
		med6 $
		dt_start6 $
		med7 $
		dt_start7 $
		med8 $
		dt_start8 $
		med9 $
		dt_start9 $
		med10 $
		dt_start10 $
		med11 $
		dt_start11 $
		med12 $
		dt_start12 $
		med13 $
		dt_start13 $
		med14 $
		dt_start14 $
		med15 $
		dt_start15 $
		med16 $
		dt_start16 $
		med17 $
		dt_start17 $
		med18 $
		dt_start18 $
		med19 $
		dt_start19 $
		med20 $
		dt_start20 $
		med21 $
		dt_start21 $
		med22 $
		dt_start22 $
		med23 $
		dt_start23 $
		concomitant_medicati_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label med1='1. Name';
	label dt_start1='Start date';
	label med2='2. Name';
	label dt_start2='Start date';
	label med3='3. Name';
	label dt_start3='Start date';
	label med4='4. Name';
	label dt_start4='Start date';
	label med5='5. Name';
	label dt_start5='Start date';
	label med6='6. Name';
	label dt_start6='Start date';
	label med7='7. Name';
	label dt_start7='Start date';
	label med8='8. Name';
	label dt_start8='Start date';
	label med9='9. Name';
	label dt_start9='Start date';
	label med10='10. Name';
	label dt_start10='Start date';
	label med11='11. Name';
	label dt_start11='Start date';
	label med12='12. Name';
	label dt_start12='Start date';
	label med13='13. Name';
	label dt_start13='Start date';
	label med14='14. Name';
	label dt_start14='Start date';
	label med15='15. Name';
	label dt_start15='Start date';
	label med16='16. Name';
	label dt_start16='Start date';
	label med17='17. Name';
	label dt_start17='Start date';
	label med18='18. Name';
	label dt_start18='Start date';
	label med19='19. Name';
	label dt_start19='Start date';
	label med20='20. Name';
	label dt_start20='Start date';
	label med21='21. Name';
	label dt_start21='Start date';
	label med22='22. Name';
	label dt_start22='Start date';
	label med23='23. Name';
	label dt_start23='Start date';
	label concomitant_medicati_v_0='Complete?';
	run;

proc format;
	value concomitant_medicati_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;
	format concomitant_medicati_v_0 concomitant_medicati_v_0_.;
run;

data brent.con_med;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;
/*
proc contents data=brent.concom_med short varnum; run;
*/
