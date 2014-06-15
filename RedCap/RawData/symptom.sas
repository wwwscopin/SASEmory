%let path=H:\SAS_Emory\RedCap;
libname brent "&path.\data";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\symptom.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat symptom_fatigue best32. ;
	informat symptom_fever best32. ;
	informat symptom_dizzy best32. ;
	informat symptom_pain best32. ;
	informat symptom_rememb best32. ;
	informat symptom_vomit best32. ;
	informat symptom_diarr best32. ;
	informat symptom_sad best32. ;
	informat symptom_nervous best32. ;
	informat symptom_sleep best32. ;
	informat symptom_skin best32. ;
	informat symptom_cough best32. ;
	informat symptom_head best32. ;
	informat symptom_app best32. ;
	informat symptom_gi best32. ;
	informat symptom_aches best32. ;
	informat symptom_sex best32. ;
	informat symptom_body best32. ;
	informat symptom_waste best32. ;
	informat symptom_hair best32. ;
	informat symptom_other best32. ;
	informat symptom_oth_spec $500. ;
	informat sympt_caused best32. ;
	informat caused_spec $500. ;
	informat symptoms_take best32. ;
	informat take_specify $500. ;
	informat symptoms_complete best32. ;

	format patient_id $500. ;
	format symptom_fatigue best12. ;
	format symptom_fever best12. ;
	format symptom_dizzy best12. ;
	format symptom_pain best12. ;
	format symptom_rememb best12. ;
	format symptom_vomit best12. ;
	format symptom_diarr best12. ;
	format symptom_sad best12. ;
	format symptom_nervous best12. ;
	format symptom_sleep best12. ;
	format symptom_skin best12. ;
	format symptom_cough best12. ;
	format symptom_head best12. ;
	format symptom_app best12. ;
	format symptom_gi best12. ;
	format symptom_aches best12. ;
	format symptom_sex best12. ;
	format symptom_body best12. ;
	format symptom_waste best12. ;
	format symptom_hair best12. ;
	format symptom_other best12. ;
	format symptom_oth_spec $500. ;
	format sympt_caused best12. ;
	format caused_spec $500. ;
	format symptoms_take best12. ;
	format take_specify $500. ;
	format symptoms_complete best12. ;

input
		patient_id $
		symptom_fatigue
		symptom_fever
		symptom_dizzy
		symptom_pain
		symptom_rememb
		symptom_vomit
		symptom_diarr
		symptom_sad
		symptom_nervous
		symptom_sleep
		symptom_skin
		symptom_cough
		symptom_head
		symptom_app
		symptom_gi
		symptom_aches
		symptom_sex
		symptom_body
		symptom_waste
		symptom_hair
		symptom_other
		symptom_oth_spec $
		sympt_caused
		caused_spec $
		symptoms_take
		take_specify $
		symptoms_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label symptom_fatigue='1. Fatigue or loss of energy?';
	label symptom_fever='2. Fevers, chills, or sweats?';
	label symptom_dizzy='3. Feeling dizzy or lightheaded?';
	label symptom_pain='4. Pain, numbness or tingling in the hands or feet?';
	label symptom_rememb='5. Trouble remembering?';
	label symptom_vomit='6. Nausea or vomiting?';
	label symptom_diarr='7. Diarrhea or loose bowel movements?';
	label symptom_sad='8. Felt sad, down or depressed?';
	label symptom_nervous='9. Felt nervous or anxious?';
	label symptom_sleep='10. Difficulty falling or staying asleep?';
	label symptom_skin='11. Skin problems, such as rash, dryness or itching?';
	label symptom_cough='12. Cough or trouble catching your breath?';
	label symptom_head='13. Headache?';
	label symptom_app='14. Loss of appetite or a change in the taste of food?';
	label symptom_gi='15. Bloating, pain or gas in your stomach?';
	label symptom_aches='16. Muscle aches or joint pain?';
	label symptom_sex='17. Problems with having sex, such as loss of interest or lack of satisfaction?';
	label symptom_body='18. Changes in the way your obdy looks, such as fat deposits or weight gain?';
	label symptom_waste='19. Problems with weight loss or wasting?';
	label symptom_hair='20. Hair loss or changes in the way your hair looks?';
	label symptom_other='21. Other symptom';
	label symptom_oth_spec='Other symptom';
	label sympt_caused='22. Do you think any of the above symptoms are caused by the ARVs?';
	label caused_spec='Specify';
	label symptoms_take='23. Do any of the above symptoms make it hard for you to take ARVs? ';
	label take_specify='Specify';
	label symptoms_complete='Complete?';
	run;

proc format;
	value symptom_fatigue_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_fever_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_dizzy_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_pain_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_rememb_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_vomit_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_diarr_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_sad_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_nervous_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_sleep_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_skin_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_cough_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_head_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_app_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_gi_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_aches_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_sex_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_body_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_waste_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_hair_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value symptom_other_ 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value sympt_caused_ 1='Yes' 2='No' 
		9='N/A';
	value symptoms_take_ 1='Yes' 2='No' 
		9='N/A';
	value symptoms_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format symptom_fatigue symptom_fatigue_.;
	format symptom_fever symptom_fever_.;
	format symptom_dizzy symptom_dizzy_.;
	format symptom_pain symptom_pain_.;
	format symptom_rememb symptom_rememb_.;
	format symptom_vomit symptom_vomit_.;
	format symptom_diarr symptom_diarr_.;
	format symptom_sad symptom_sad_.;
	format symptom_nervous symptom_nervous_.;
	format symptom_sleep symptom_sleep_.;
	format symptom_skin symptom_skin_.;
	format symptom_cough symptom_cough_.;
	format symptom_head symptom_head_.;
	format symptom_app symptom_app_.;
	format symptom_gi symptom_gi_.;
	format symptom_aches symptom_aches_.;
	format symptom_sex symptom_sex_.;
	format symptom_body symptom_body_.;
	format symptom_waste symptom_waste_.;
	format symptom_hair symptom_hair_.;
	format symptom_other symptom_other_.;
	format sympt_caused sympt_caused_.;
	format symptoms_take symptoms_take_.;
	format symptoms_complete symptoms_complete_.;
	run;

proc contents data=redcap;
data brent.symptom;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

proc contents data=brent.symptom short varnum; run;
