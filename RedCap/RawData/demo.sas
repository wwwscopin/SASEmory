
%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); 
	%if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; 
%mend removeOldFile; 
%removeOldFile(work.redcap); 

data REDCAP; %let _EFIERR_ = 0;
infile "&path\CSV\demo.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat dt_visit yymmdd10. ;
	informat dob yymmdd10. ;
	informat gender best32. ;
	informat race best32. ;
	informat black_ethnicity best32. ;
	informat black_other $500. ;
	informat address $500. ;
	informat education $500. ;
	informat read___1 best32. ;
	informat read___2 best32. ;
	informat read___3 best32. ;
	informat read___4 best32. ;
	informat read_other $500. ;
	informat understand___1 best32. ;
	informat understand___2 best32. ;
	informat understand___3 best32. ;
	informat understand_other $500. ;
	informat speak___1 best32. ;
	informat speak___2 best32. ;
	informat speak___3 best32. ;
	informat speak_other $500. ;
	informat problems___1 best32. ;
	informat problems___2 best32. ;
	informat problems___3 best32. ;
	informat problems___4 best32. ;
	informat demographics_complete best32. ;

	format patient_id $500. ;
	format dt_visit yymmdd10. ;
	format dob yymmdd10. ;
	format gender best12. ;
	format race best12. ;
	format black_ethnicity best12. ;
	format black_other $500. ;
	format address $500. ;
	format education $500. ;
	format read___1 best12. ;
	format read___2 best12. ;
	format read___3 best12. ;
	format read___4 best12. ;
	format read_other $500. ;
	format understand___1 best12. ;
	format understand___2 best12. ;
	format understand___3 best12. ;
	format understand_other $500. ;
	format speak___1 best12. ;
	format speak___2 best12. ;
	format speak___3 best12. ;
	format speak_other $500. ;
	format problems___1 best12. ;
	format problems___2 best12. ;
	format problems___3 best12. ;
	format problems___4 best12. ;
	format demographics_complete best12. ;

input
		patient_id $
		dt_visit
		dob
		gender
		race
		black_ethnicity
		black_other $
		address $
		education $
		read___1
		read___2
		read___3
		read___4
		read_other $
		understand___1
		understand___2
		understand___3
		understand_other $
		speak___1
		speak___2
		speak___3
		speak_other $
		problems___1
		problems___2
		problems___3
		problems___4
		demographics_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label dt_visit='Study visit date';
	label dob='1. Date of birth';
	label gender='2. Gender';
	label race='3. How do you describe your race/ethnicity?';
	label black_ethnicity='4. If black, what is your ethnic group and/or nationality?';
	label black_other='Other black ethnic group or nationality';
	label address='5. Address';
	label education='6. What is your last grade of school/education?';
	label read___1='Which languages can you read? (choice=Zulu (1))';
	label read___2='Which languages can you read? (choice=English (2))';
	label read___3='Which languages can you read? (choice=Other (3))';
	label read___4='Which languages can you read? (choice=Cannot read (4))';
	label read_other='Other language';
	label understand___1='Which spoken languages do you understand? (choice=Zulu (1))';
	label understand___2='Which spoken languages do you understand? (choice=English (2))';
	label understand___3='Which spoken languages do you understand? (choice=Other (3))';
	label understand_other='Other language';
	label speak___1='Which languages do you speak? (choice=Zulu (1))';
	label speak___2='Which languages do you speak? (choice=English (2))';
	label speak___3='Which languages do you speak? (choice=Other (3))';
	label speak_other='Other language';
	label problems___1='7. Do you have any problems with the following? (choice=Hearing (1))';
	label problems___2='7. Do you have any problems with the following? (choice=Seeing (2))';
	label problems___3='7. Do you have any problems with the following? (choice=Voice (3))';
	label problems___4='7. Do you have any problems with the following? (choice=None (4))';
	label demographics_complete='Complete?';
	run;

proc format;
	value gender_ 0='Male' 1='Female';
	value race_ 1='Black (1)' 2='Colored (2)' 
		3='White (3)' 4='Indian (4)';
	value black_ethnicity_ 1='Zulu (1)' 2='Xhosa (2)' 
		3='Malawian (3)' 4='Other (4)';
	value read___1_ 0='Unchecked' 1='Checked';
	value read___2_ 0='Unchecked' 1='Checked';
	value read___3_ 0='Unchecked' 1='Checked';
	value read___4_ 0='Unchecked' 1='Checked';
	value understand___1_ 0='Unchecked' 1='Checked';
	value understand___2_ 0='Unchecked' 1='Checked';
	value understand___3_ 0='Unchecked' 1='Checked';
	value speak___1_ 0='Unchecked' 1='Checked';
	value speak___2_ 0='Unchecked' 1='Checked';
	value speak___3_ 0='Unchecked' 1='Checked';
	value problems___1_ 0='Unchecked' 1='Checked';
	value problems___2_ 0='Unchecked' 1='Checked';
	value problems___3_ 0='Unchecked' 1='Checked';
	value problems___4_ 0='Unchecked' 1='Checked';
	value demographics_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format gender gender_.;
	format race race_.;
	format black_ethnicity black_ethnicity_.;
	format read___1 read___1_.;
	format read___2 read___2_.;
	format read___3 read___3_.;
	format read___4 read___4_.;
	format understand___1 understand___1_.;
	format understand___2 understand___2_.;
	format understand___3 understand___3_.;
	format speak___1 speak___1_.;
	format speak___2 speak___2_.;
	format speak___3 speak___3_.;
	format problems___1 problems___1_.;
	format problems___2 problems___2_.;
	format problems___3 problems___3_.;
	format problems___4 problems___4_.;
	format demographics_complete demographics_complete_.;
	run;

proc contents data=redcap;
data brent.demo;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	age=(dt_visit-dob)/365.25;

	rename read___1=read1 read___2=read2 read___3=read3 read___4=read4 understand___1=understand1 understand___2=understand2 
	understand___3=understand3 speak___1=speak1 speak___2=speak2 speak___3=speak3 
	problems___1=problem1 problems___2=problem2 problems___3=problem3 problems___4=problem4;
	if idx=1 and id=63 then dt_visit=mdy(6,2,2011);
run;

proc contents data=brent.demo short varnum; run;
