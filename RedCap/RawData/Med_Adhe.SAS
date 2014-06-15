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
infile "&path\CSV\med_adhe.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat doses_miss_wk $500. ;
	informat doses_miss_mo $500. ;
	informat doses_late_wk $500. ;
	informat doses_late_mo $500. ;
	informat remember_meds___1 best32. ;
	informat remember_meds___2 best32. ;
	informat remember_meds___3 best32. ;
	informat remember_meds___4 best32. ;
	informat remember_meds___5 best32. ;
	informat remember_meds___6 best32. ;
	informat remember_meds___7 best32. ;
	informat remember_meds___8 best32. ;
	informat remember_meds___9 best32. ;
	informat remember_oth $500. ;
	informat remember_collect___1 best32. ;
	informat remember_collect___2 best32. ;
	informat remember_collect___3 best32. ;
	informat remember_collect___4 best32. ;
	informat remember_coll_oth $500. ;
	informat arvs_home best32. ;
	informat arvs_busy best32. ;
	informat arvs_forgot best32. ;
	informat arvs_too_many best32. ;
	informat arvs_side_effects best32. ;
	informat arvs_others best32. ;
	informat arvs_change best32. ;
	informat arvs_harm best32. ;
	informat arvs_sleep best32. ;
	informat arvs_sick best32. ;
	informat arvs_depressed best32. ;
	informat arvs_times best32. ;
	informat arvs_obtain best32. ;
	informat arvs_out best32. ;
	informat arvs_money best32. ;
	informat arvs_tired best32. ;
	informat arvs_taking best32. ;
	informat arvs_swallow best32. ;
	informat arvs_feel_good best32. ;
	informat arvs_trad_healer best32. ;
	informat arvs_alcohol best32. ;
	informat arvs_drugs best32. ;
	informat arvs_other best32. ;
	informat arvs_oth_specify $500. ;
	informat medication_adherence_complete best32. ;

	format patient_id $500. ;
	format doses_miss_wk $500. ;
	format doses_miss_mo $500. ;
	format doses_late_wk $500. ;
	format doses_late_mo $500. ;
	format remember_meds___1 best12. ;
	format remember_meds___2 best12. ;
	format remember_meds___3 best12. ;
	format remember_meds___4 best12. ;
	format remember_meds___5 best12. ;
	format remember_meds___6 best12. ;
	format remember_meds___7 best12. ;
	format remember_meds___8 best12. ;
	format remember_meds___9 best12. ;
	format remember_oth $500. ;
	format remember_collect___1 best12. ;
	format remember_collect___2 best12. ;
	format remember_collect___3 best12. ;
	format remember_collect___4 best12. ;
	format remember_coll_oth $500. ;
	format arvs_home best12. ;
	format arvs_busy best12. ;
	format arvs_forgot best12. ;
	format arvs_too_many best12. ;
	format arvs_side_effects best12. ;
	format arvs_others best12. ;
	format arvs_change best12. ;
	format arvs_harm best12. ;
	format arvs_sleep best12. ;
	format arvs_sick best12. ;
	format arvs_depressed best12. ;
	format arvs_times best12. ;
	format arvs_obtain best12. ;
	format arvs_out best12. ;
	format arvs_money best12. ;
	format arvs_tired best12. ;
	format arvs_taking best12. ;
	format arvs_swallow best12. ;
	format arvs_feel_good best12. ;
	format arvs_trad_healer best12. ;
	format arvs_alcohol best12. ;
	format arvs_drugs best12. ;
	format arvs_other best12. ;
	format arvs_oth_specify $500. ;
	format medication_adherence_complete best12. ;

input
		patient_id $
		doses_miss_wk $
		doses_miss_mo $
		doses_late_wk $
		doses_late_mo $
		remember_meds___1
		remember_meds___2
		remember_meds___3
		remember_meds___4
		remember_meds___5
		remember_meds___6
		remember_meds___7
		remember_meds___8
		remember_meds___9
		remember_oth $
		remember_collect___1
		remember_collect___2
		remember_collect___3
		remember_collect___4
		remember_coll_oth $
		arvs_home
		arvs_busy
		arvs_forgot
		arvs_too_many
		arvs_side_effects
		arvs_others
		arvs_change
		arvs_harm
		arvs_sleep
		arvs_sick
		arvs_depressed
		arvs_times
		arvs_obtain
		arvs_out
		arvs_money
		arvs_tired
		arvs_taking
		arvs_swallow
		arvs_feel_good
		arvs_trad_healer
		arvs_alcohol
		arvs_drugs
		arvs_other
		arvs_oth_specify $
		medication_adherence_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label doses_miss_wk='1. How many doses have you missed in the last week?';
	label doses_miss_mo='Last month?';
	label doses_late_wk='2. How many doses did you take more than 1 hour late in the last week?';
	label doses_late_mo='Last month?';
	label remember_meds___1='3. How do you remember to take your meds? (choice=Pill box (1))';
	label remember_meds___2='3. How do you remember to take your meds? (choice=Clock/Watch alarm (2))';
	label remember_meds___3='3. How do you remember to take your meds? (choice=Cell phone (3))';
	label remember_meds___4='3. How do you remember to take your meds? (choice=Partner (4))';
	label remember_meds___5='3. How do you remember to take your meds? (choice=Calendar (5))';
	label remember_meds___6='3. How do you remember to take your meds? (choice=Chart (6))';
	label remember_meds___7='3. How do you remember to take your meds? (choice=Media (TV/Radio)(7))';
	label remember_meds___8='3. How do you remember to take your meds? (choice=Daily schedule (8))';
	label remember_meds___9='3. How do you remember to take your meds? (choice=Other (9))';
	label remember_oth='Other way to remember';
	label remember_collect___1='4. How do you remember to come for your drug collection appt? (choice=Appointment card (1))';
	label remember_collect___2='4. How do you remember to come for your drug collection appt? (choice=Partner/Friend (2))';
	label remember_collect___3='4. How do you remember to come for your drug collection appt? (choice=Cellphone (3))';
	label remember_collect___4='4. How do you remember to come for your drug collection appt? (choice=Other (4))';
	label remember_coll_oth='Other way to remember';
	label arvs_home='You were away from home';
	label arvs_busy='You were busy with other things';
	label arvs_forgot='You forgot to take pills';
	label arvs_too_many='You had too many pills to take';
	label arvs_side_effects='You had wanted to avoid side effects';
	label arvs_others='You did not want others to see you taking ARVs';
	label arvs_change='You had a change in what you do every day';
	label arvs_harm='You felt like the drug could hurt/harm you ';
	label arvs_sleep='You fell asleep through the dose time';
	label arvs_sick='You felt sick or ill';
	label arvs_depressed='You felt depressed or stressed';
	label arvs_times='You had a problem taking pills at certain times (with meals, on empty stomach, etc.)';
	label arvs_obtain='You forgot to obtain meds';
	label arvs_out='You ran out of pills';
	label arvs_money='You did not have money for ARVs';
	label arvs_tired='You were tired of ARVs';
	label arvs_taking='You dont like taking pills';
	label arvs_swallow='You have difficulty swallowing ARVs';
	label arvs_feel_good='You thought you did not need more ARVs because you felt good';
	label arvs_trad_healer='Receiving treatment from Traditional Healer';
	label arvs_alcohol='You had too much alcohol';
	label arvs_drugs='You were taking street drugs';
	label arvs_other='Other (i.e. Partner borrows/Someone steals meds)';
	label arvs_oth_specify='Other reason';
	label medication_adherence_complete='Complete?';
	run;

proc format;
	value remember_meds___1_ 0='Unchecked' 1='Checked';
	value remember_meds___2_ 0='Unchecked' 1='Checked';
	value remember_meds___3_ 0='Unchecked' 1='Checked';
	value remember_meds___4_ 0='Unchecked' 1='Checked';
	value remember_meds___5_ 0='Unchecked' 1='Checked';
	value remember_meds___6_ 0='Unchecked' 1='Checked';
	value remember_meds___7_ 0='Unchecked' 1='Checked';
	value remember_meds___8_ 0='Unchecked' 1='Checked';
	value remember_meds___9_ 0='Unchecked' 1='Checked';
	value remember_collect___1_ 0='Unchecked' 1='Checked';
	value remember_collect___2_ 0='Unchecked' 1='Checked';
	value remember_collect___3_ 0='Unchecked' 1='Checked';
	value remember_collect___4_ 0='Unchecked' 1='Checked';
	value arvs_home_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_busy_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_forgot_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_too_many_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_side_effects_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_others_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_change_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_harm_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_sleep_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_sick_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_depressed_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_times_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_obtain_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_out_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_money_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_tired_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_taking_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_swallow_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_feel_good_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_trad_healer_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_alcohol_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_drugs_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value arvs_other_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value medication_adherence_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format remember_meds___1 remember_meds___1_.;
	format remember_meds___2 remember_meds___2_.;
	format remember_meds___3 remember_meds___3_.;
	format remember_meds___4 remember_meds___4_.;
	format remember_meds___5 remember_meds___5_.;
	format remember_meds___6 remember_meds___6_.;
	format remember_meds___7 remember_meds___7_.;
	format remember_meds___8 remember_meds___8_.;
	format remember_meds___9 remember_meds___9_.;
	format remember_collect___1 remember_collect___1_.;
	format remember_collect___2 remember_collect___2_.;
	format remember_collect___3 remember_collect___3_.;
	format remember_collect___4 remember_collect___4_.;
	format arvs_home arvs_home_.;
	format arvs_busy arvs_busy_.;
	format arvs_forgot arvs_forgot_.;
	format arvs_too_many arvs_too_many_.;
	format arvs_side_effects arvs_side_effects_.;
	format arvs_others arvs_others_.;
	format arvs_change arvs_change_.;
	format arvs_harm arvs_harm_.;
	format arvs_sleep arvs_sleep_.;
	format arvs_sick arvs_sick_.;
	format arvs_depressed arvs_depressed_.;
	format arvs_times arvs_times_.;
	format arvs_obtain arvs_obtain_.;
	format arvs_out arvs_out_.;
	format arvs_money arvs_money_.;
	format arvs_tired arvs_tired_.;
	format arvs_taking arvs_taking_.;
	format arvs_swallow arvs_swallow_.;
	format arvs_feel_good arvs_feel_good_.;
	format arvs_trad_healer arvs_trad_healer_.;
	format arvs_alcohol arvs_alcohol_.;
	format arvs_drugs arvs_drugs_.;
	format arvs_other arvs_other_.;
	format medication_adherence_complete medication_adherence_complete_.;
	run;

proc contents data=redcap;

data brent.med_adhe;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

proc contents data=brent.med_adhe short varnum; run;
