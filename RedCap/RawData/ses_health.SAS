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
infile "&path\CSV\ses_health.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat income best32. ;
	informat income_supp $500. ;
	informat employ___1 best32. ;
	informat employ___2 best32. ;
	informat employ___3 best32. ;
	informat employ___4 best32. ;
	informat employ___5 best32. ;
	informat employ___6 best32. ;
	informat employ___7 best32. ;
	informat employ___8 best32. ;
	informat employ_type $500. ;
	informat money best32. ;
	informat money_source $500. ;
	informat housing best32. ;
	informat housing_oth $500. ;
	informat settlement best32. ;
	informat dt_start_settle yymmdd10. ;
	informat dt_stop_settle yymmdd10. ;
	informat living best32. ;
	informat live_num $500. ;
	informat live_options___1 best32. ;
	informat live_options___2 best32. ;
	informat live_options___3 best32. ;
	informat live_options___4 best32. ;
	informat live_options___5 best32. ;
	informat live_options___6 best32. ;
	informat walls $500. ;
	informat floor $500. ;
	informat transport___1 best32. ;
	informat transport___2 best32. ;
	informat transport___3 best32. ;
	informat transport___4 best32. ;
	informat food_4wks best32. ;
	informat food_eat_4wks best32. ;
	informat no_food_4wks best32. ;
	informat clinic___1 best32. ;
	informat clinic___2 best32. ;
	informat clinic_other $500. ;
	informat arv_start best32. ;
	informat arv_other $500. ;
	informat clinic_arrive best32. ;
	informat clinic_transport___1 best32. ;
	informat clinic_transport___2 best32. ;
	informat clinic_transport___3 best32. ;
	informat clinic_transport___4 best32. ;
	informat clinic_transport___5 best32. ;
	informat clinic_transport___6 best32. ;
	informat other_transport $500. ;
	informat clinic_meds___1 best32. ;
	informat clinic_meds___2 best32. ;
	informat clinic_meds___3 best32. ;
	informat clinic_meds___4 best32. ;
	informat clinic_meds___5 best32. ;
	informat clinic_meds___6 best32. ;
	informat clinic_meds___7 best32. ;
	informat meds_other_pay $500. ;
	informat clinic_feel best32. ;
	informat other_feel $500. ;
	informat worried_why $500. ;
	informat hcw_touch best32. ;
	informat treat_poorly best32. ;
	informat rejected best32. ;
	informat talk_loud best32. ;
	informat cost_visit best32. ;
	informat cost_transport best32. ;
	informat get_transport best32. ;
	informat off_work best32. ;
	informat fear_seen best32. ;
	informat fear_know best32. ;
	informat childcare best32. ;
	informat ill best32. ;
	informat family best32. ;
	informat healer best32. ;
	informat other_stop best32. ;
	informat other_stop_spec $500. ;
	informat sesaccess_healthcare_complete best32. ;

	format patient_id $500. ;
	format income best12. ;
	format income_supp $500. ;
	format employ___1 best12. ;
	format employ___2 best12. ;
	format employ___3 best12. ;
	format employ___4 best12. ;
	format employ___5 best12. ;
	format employ___6 best12. ;
	format employ___7 best12. ;
	format employ___8 best12. ;
	format employ_type $500. ;
	format money best12. ;
	format money_source $500. ;
	format housing best12. ;
	format housing_oth $500. ;
	format settlement best12. ;
	format dt_start_settle yymmdd10. ;
	format dt_stop_settle yymmdd10. ;
	format living best12. ;
	format live_num $500. ;
	format live_options___1 best12. ;
	format live_options___2 best12. ;
	format live_options___3 best12. ;
	format live_options___4 best12. ;
	format live_options___5 best12. ;
	format live_options___6 best12. ;
	format walls $500. ;
	format floor $500. ;
	format transport___1 best12. ;
	format transport___2 best12. ;
	format transport___3 best12. ;
	format transport___4 best12. ;
	format food_4wks best12. ;
	format food_eat_4wks best12. ;
	format no_food_4wks best12. ;
	format clinic___1 best12. ;
	format clinic___2 best12. ;
	format clinic_other $500. ;
	format arv_start best12. ;
	format arv_other $500. ;
	format clinic_arrive best12. ;
	format clinic_transport___1 best12. ;
	format clinic_transport___2 best12. ;
	format clinic_transport___3 best12. ;
	format clinic_transport___4 best12. ;
	format clinic_transport___5 best12. ;
	format clinic_transport___6 best12. ;
	format other_transport $500. ;
	format clinic_meds___1 best12. ;
	format clinic_meds___2 best12. ;
	format clinic_meds___3 best12. ;
	format clinic_meds___4 best12. ;
	format clinic_meds___5 best12. ;
	format clinic_meds___6 best12. ;
	format clinic_meds___7 best12. ;
	format meds_other_pay $500. ;
	format clinic_feel best12. ;
	format other_feel $500. ;
	format worried_why $500. ;
	format hcw_touch best12. ;
	format treat_poorly best12. ;
	format rejected best12. ;
	format talk_loud best12. ;
	format cost_visit best12. ;
	format cost_transport best12. ;
	format get_transport best12. ;
	format off_work best12. ;
	format fear_seen best12. ;
	format fear_know best12. ;
	format childcare best12. ;
	format ill best12. ;
	format family best12. ;
	format healer best12. ;
	format other_stop best12. ;
	format other_stop_spec $500. ;
	format sesaccess_healthcare_complete best12. ;

input
		patient_id $
		income
		income_supp $
		employ___1
		employ___2
		employ___3
		employ___4
		employ___5
		employ___6
		employ___7
		employ___8
		employ_type $
		money
		money_source $
		housing
		housing_oth $
		settlement
		dt_start_settle
		dt_stop_settle
		living
		live_num $
		live_options___1
		live_options___2
		live_options___3
		live_options___4
		live_options___5
		live_options___6
		walls $
		floor $
		transport___1
		transport___2
		transport___3
		transport___4
		food_4wks
		food_eat_4wks
		no_food_4wks
		clinic___1
		clinic___2
		clinic_other $
		arv_start
		arv_other $
		clinic_arrive
		clinic_transport___1
		clinic_transport___2
		clinic_transport___3
		clinic_transport___4
		clinic_transport___5
		clinic_transport___6
		other_transport $
		clinic_meds___1
		clinic_meds___2
		clinic_meds___3
		clinic_meds___4
		clinic_meds___5
		clinic_meds___6
		clinic_meds___7
		meds_other_pay $
		clinic_feel
		other_feel $
		worried_why $
		hcw_touch
		treat_poorly
		rejected
		talk_loud
		cost_visit
		cost_transport
		get_transport
		off_work
		fear_seen
		fear_know
		childcare
		ill
		family
		healer
		other_stop
		other_stop_spec $
		sesaccess_healthcare_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label income='1. Do you have an income?';
	label income_supp='How many people (other than yourself) do you support?';
	label employ___1='2. Are you (choice=Employed full-time (1))';
	label employ___2='2. Are you (choice=Employed part-time (2))';
	label employ___3='2. Are you (choice=Self-employed (3))';
	label employ___4='2. Are you (choice=Attending school (4))';
	label employ___5='2. Are you (choice=Disabled (5))';
	label employ___6='2. Are you (choice=Unemployed seeking work (6))';
	label employ___7='2. Are you (choice=Unemployed NOT seeking work (7))';
	label employ___8='2. Are you (choice=Retired (8))';
	label employ_type='What type of work do you do?';
	label money='3a. Other than an job, do you receive money from someone or somewhere?';
	label money_source='3b. What sources?';
	label housing='4a. Where do you stay?';
	label housing_oth='Other Housing';
	label settlement='4b. Have you ever lived in an informal settlement since starting ARVs?';
	label dt_start_settle='4c. Start date';
	label dt_stop_settle='Stop date';
	label living='5. What is your current living arrangement?';
	label live_num='6. How many people live with you?';
	label live_options___1='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=Electricity (1))';
	label live_options___2='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=Working radio (2))';
	label live_options___3='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=Toilet indoors (3))';
	label live_options___4='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=Television (4))';
	label live_options___5='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=Tap water indoors (5))';
	label live_options___6='7. Where you are staying now, do you have (please read all options and check all that apply): (choice=None of these (6))';
	label walls='What are the walls made of?';
	label floor='What are the floors made of?';
	label transport___1='8. Do you have (please read all options and check all that apply): (choice=Car or bakkie (1))';
	label transport___2='8. Do you have (please read all options and check all that apply): (choice=Bicycle (2))';
	label transport___3='8. Do you have (please read all options and check all that apply): (choice=Motorcycle (3))';
	label transport___4='8. Do you have (please read all options and check all that apply): (choice=None of these (4))';
	label food_4wks='9a. In the past 4 weeks did you worry that you or your family would not have enough food?';
	label food_eat_4wks='9b. In the past 4 weeks, the amount of food you and your family had to eat was:';
	label no_food_4wks='9c. In the past 4 weeks how many times did you or your family go an entire day and night without food because there was not enough food?';
	label clinic___1='10. What clinic(s) do you currently attend? (choice=Sinikithemba (1))';
	label clinic___2='10. What clinic(s) do you currently attend? (choice=Other (2))';
	label clinic_other='Other clinic name';
	label arv_start='11. Where did you first start ARVs?';
	label arv_other='Other clinic name';
	label clinic_arrive='12. How long does it take to get to clinic?';
	label clinic_transport___1='13. Transport to clinic: (choice=Your car (1))';
	label clinic_transport___2='13. Transport to clinic: (choice=Friend/relative car (2))';
	label clinic_transport___3='13. Transport to clinic: (choice=Meter Taxi (3))';
	label clinic_transport___4='13. Transport to clinic: (choice=Mini Bus/Bus (4))';
	label clinic_transport___5='13. Transport to clinic: (choice=Walk (5))';
	label clinic_transport___6='13. Transport to clinic: (choice=Other (i.e. hired car)(6))';
	label other_transport='Other transport';
	label clinic_meds___1='14. How do you pay for clinic meds? (choice=Sponsor (1))';
	label clinic_meds___2='14. How do you pay for clinic meds? (choice=Grant (2))';
	label clinic_meds___3='14. How do you pay for clinic meds? (choice=Employer (3))';
	label clinic_meds___4='14. How do you pay for clinic meds? (choice=Self-pay (4))';
	label clinic_meds___5='14. How do you pay for clinic meds? (choice=Family Member (5))';
	label clinic_meds___6='14. How do you pay for clinic meds? (choice=Spouse (6))';
	label clinic_meds___7='14. How do you pay for clinic meds? (choice=Other (7))';
	label meds_other_pay='Other payment method';
	label clinic_feel='15a. How do you feel about coming to clinic?';
	label other_feel='Other feelings';
	label worried_why='15b. Why?';
	label hcw_touch='A healthcare worker not wanting to touch someone because they have HIV';
	label treat_poorly='People being treated poorly by hospital/clinic/healthcare workers because of HIV';
	label rejected='People being rejected at hospital/clinic because of HIV';
	label talk_loud='A healthcare worker talking out loud about a patient with HIV';
	label cost_visit='Cost of visit';
	label cost_transport='Cost of transport';
	label get_transport='Getting transport';
	label off_work='Time off work';
	label fear_seen='Fear of being seen by someone you know at clinic';
	label fear_know='Fear of others knowing you are living with HIV';
	label childcare='Childcare';
	label ill='Being ill';
	label family='Family circumstances';
	label healer='Receiving treatment from Traditional Healer';
	label other_stop='Other reason';
	label other_stop_spec='Other specifically ';
	label sesaccess_healthcare_complete='Complete?';
	run;

proc format;
	value income_ 1='Yes' 2='No';
	value employ___1_ 0='Unchecked' 1='Checked';
	value employ___2_ 0='Unchecked' 1='Checked';
	value employ___3_ 0='Unchecked' 1='Checked';
	value employ___4_ 0='Unchecked' 1='Checked';
	value employ___5_ 0='Unchecked' 1='Checked';
	value employ___6_ 0='Unchecked' 1='Checked';
	value employ___7_ 0='Unchecked' 1='Checked';
	value employ___8_ 0='Unchecked' 1='Checked';
	value money_ 1='Yes' 2='No';
	value housing_ 1='House (1)' 2='Flat (2)' 
		3='Shack (3)' 4='Other (4)';
	value settlement_ 1='Yes' 2='No';
	value living_ 1='Own home (1)' 2='Rent (2)' 
		3='Stay with family (3)' 4='Stay with friends (4)' 
		5='Stay with employer (5)';
	value live_options___1_ 0='Unchecked' 1='Checked';
	value live_options___2_ 0='Unchecked' 1='Checked';
	value live_options___3_ 0='Unchecked' 1='Checked';
	value live_options___4_ 0='Unchecked' 1='Checked';
	value live_options___5_ 0='Unchecked' 1='Checked';
	value live_options___6_ 0='Unchecked' 1='Checked';
	value transport___1_ 0='Unchecked' 1='Checked';
	value transport___2_ 0='Unchecked' 1='Checked';
	value transport___3_ 0='Unchecked' 1='Checked';
	value transport___4_ 0='Unchecked' 1='Checked';
	value food_4wks_ 1='Never (1)' 2='Rarely (1-2 times/mo)(2)' 
		3='Often enough to eat (3)';
	value food_eat_4wks_ 1='Enough to eat (1)' 2='Sometimes not enough to eat (2)' 
		3='Often not enough to eat (3)';
	value no_food_4wks_ 1='Never (1)' 2='Rarely (1-2 times/mo)(2)' 
		3='Sometimes (3-10 times/mo)(3)' 4='Often (>10 times/mo)(3)';
	value clinic___1_ 0='Unchecked' 1='Checked';
	value clinic___2_ 0='Unchecked' 1='Checked';
	value arv_start_ 1='Sinikithemba (Ridge House)(1)' 2='Siyaphila Inpatient Ward (2)' 
		3='Private Provider (3)' 4='DOH Clinic (4)' 
		5='Other (5)';
	value clinic_arrive_ 1='< 30 min' 2='30-60 min' 
		3='More than 60 min';
	value clinic_transport___1_ 0='Unchecked' 1='Checked';
	value clinic_transport___2_ 0='Unchecked' 1='Checked';
	value clinic_transport___3_ 0='Unchecked' 1='Checked';
	value clinic_transport___4_ 0='Unchecked' 1='Checked';
	value clinic_transport___5_ 0='Unchecked' 1='Checked';
	value clinic_transport___6_ 0='Unchecked' 1='Checked';
	value clinic_meds___1_ 0='Unchecked' 1='Checked';
	value clinic_meds___2_ 0='Unchecked' 1='Checked';
	value clinic_meds___3_ 0='Unchecked' 1='Checked';
	value clinic_meds___4_ 0='Unchecked' 1='Checked';
	value clinic_meds___5_ 0='Unchecked' 1='Checked';
	value clinic_meds___6_ 0='Unchecked' 1='Checked';
	value clinic_meds___7_ 0='Unchecked' 1='Checked';
	value clinic_feel_ 1='Pleased (1)' 2='Worried (2)' 
		3='Ashamed (3)' 4='Neutral (4)' 
		5='Other (5)';
	value hcw_touch_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value treat_poorly_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value rejected_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value talk_loud_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value cost_visit_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value cost_transport_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value get_transport_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value off_work_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value fear_seen_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value fear_know_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value childcare_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value ill_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value family_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value healer_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value other_stop_ 0='Never (0)' 1='Rarely (1)' 
		2='Sometimes (2)' 3='Frequently (3)';
	value sesaccess_healthcare_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format income income_.;
	format employ___1 employ___1_.;
	format employ___2 employ___2_.;
	format employ___3 employ___3_.;
	format employ___4 employ___4_.;
	format employ___5 employ___5_.;
	format employ___6 employ___6_.;
	format employ___7 employ___7_.;
	format employ___8 employ___8_.;
	format money money_.;
	format housing housing_.;
	format settlement settlement_.;
	format living living_.;
	format live_options___1 live_options___1_.;
	format live_options___2 live_options___2_.;
	format live_options___3 live_options___3_.;
	format live_options___4 live_options___4_.;
	format live_options___5 live_options___5_.;
	format live_options___6 live_options___6_.;
	format transport___1 transport___1_.;
	format transport___2 transport___2_.;
	format transport___3 transport___3_.;
	format transport___4 transport___4_.;
	format food_4wks food_4wks_.;
	format food_eat_4wks food_eat_4wks_.;
	format no_food_4wks no_food_4wks_.;
	format clinic___1 clinic___1_.;
	format clinic___2 clinic___2_.;
	format arv_start arv_start_.;
	format clinic_arrive clinic_arrive_.;
	format clinic_transport___1 clinic_transport___1_.;
	format clinic_transport___2 clinic_transport___2_.;
	format clinic_transport___3 clinic_transport___3_.;
	format clinic_transport___4 clinic_transport___4_.;
	format clinic_transport___5 clinic_transport___5_.;
	format clinic_transport___6 clinic_transport___6_.;
	format clinic_meds___1 clinic_meds___1_.;
	format clinic_meds___2 clinic_meds___2_.;
	format clinic_meds___3 clinic_meds___3_.;
	format clinic_meds___4 clinic_meds___4_.;
	format clinic_meds___5 clinic_meds___5_.;
	format clinic_meds___6 clinic_meds___6_.;
	format clinic_meds___7 clinic_meds___7_.;
	format clinic_feel clinic_feel_.;
	format hcw_touch hcw_touch_.;
	format treat_poorly treat_poorly_.;
	format rejected rejected_.;
	format talk_loud talk_loud_.;
	format cost_visit cost_visit_.;
	format cost_transport cost_transport_.;
	format get_transport get_transport_.;
	format off_work off_work_.;
	format fear_seen fear_seen_.;
	format fear_know fear_know_.;
	format childcare childcare_.;
	format ill ill_.;
	format family family_.;
	format healer healer_.;
	format other_stop other_stop_.;
	format sesaccess_healthcare_complete sesaccess_healthcare_complete_.;
	run;

proc contents data=redcap;

data brent.ses_health;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	rename employ___1=employ1 employ___2=employ2 employ___3=employ3 employ___4=employ4 employ___5=employ5 employ___6=employ6 
	employ___7=employ7 employ___8=employ8 live_options___1=live1 live_options___2=live2 live_options___3=live3 live_options___4=live4
	live_options___5=live5 live_options___6=live6 transport___1=trans1 transport___2=trans2 transport___3=trans3 transport___4=trans4
	clinic___1=clinic1 clinic___2=clinic2 clinic_transport___1=ctran1 clinic_transport___2=ctran2 clinic_transport___3=ctran3 
	clinic_transport___4=ctran4 clinic_transport___5=ctran5 clinic_transport___6=ctran6 clinic_meds___1=cmed1 clinic_meds___2=cmed2 
	clinic_meds___3=cmed3 clinic_meds___4=cmed4 clinic_meds___5=cmed5 clinic_meds___6=cmed6 clinic_meds___7=cmed7;
run;

proc contents ;run;

proc freq data=brent.ses_health;
	tables (cmed1-cmed7)*idx;
run;
