options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\symptom.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='1. Fatigue or loss of energy?'
	2='2. Fevers, chills, or sweats?'
	3='3. Feeling dizzy or lightheaded?'
	4='4. Pain, numbness or tingling in the hands or feet?'
	5='5. Trouble remembering?'
	6='6. Nausea or vomiting?'
	7='7. Diarrhea or loose bowel movements?'
	8='8. Felt sad, down or depressed?'
	9='9. Felt nervous or anxious?'
	10='10. Difficulty falling or staying asleep?'
	11='11. Skin problems, such as rash, dryness or itching?'
	12='12. Cough or trouble catching your breath?'
	13='13. Headache?'
	14='14. Loss of appetite or a change in the taste of food?'
	15='15. Bloating, pain or gas in your stomach?'
	16='16. Muscle aches or joint pain?'
	17='17. Problems with having sex, such as loss of interest or lack of satisfaction?'
	18='18. Changes in the way your obdy looks, such as fat deposits or weight gain?'
	19='19. Problems with weight loss or wasting?'
	20='20. Hair loss or changes in the way your hair looks?'
	21='21. Other symptom'
	22='22. Do you think any of the above symptoms are caused by the ARVs?'
	23='23. Do any of the above symptoms make it hard for you to take ARVs? '
	;

	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 	4='It bothers patient terribly';

	value sympt 1='Yes' 2='No' 	9='N/A';
	value idx 0="CONTROL" 1="CASE";
run;


data symptom;
	set brent.symptom;
	format idx idx.;
run;

proc freq; 
tables idx;
ods output onewayfreqs=tmp;
run;
*ods trace off;
data _null_;
	set tmp;
	if idx=0 then call symput("n0", compress(Frequency));
	if idx=1 then call symput("n1", compress(Frequency));
run;
%let n=%eval(&n0+&n1);


%let varlist=symptom_fatigue symptom_fever symptom_dizzy symptom_pain symptom_rememb symptom_vomit symptom_diarr symptom_sad 
	symptom_nervous symptom_sleep symptom_skin symptom_cough symptom_head symptom_app symptom_gi symptom_aches symptom_sex 
	symptom_body symptom_waste symptom_hair symptom_other sympt_caused symptoms_take;
%tab(symptom, idx, tab, &varlist);

data tab;
	set tab;

	if 1<=item<=21  then code0=put(code, symptom.);
	if item in(22,23)  then code0=put(code, sympt.);
	
	format item item.;	
run;

ods rtf file="symptom_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left width=4in];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"Case*(n=&n1)";
define nfn/"Control*(n=&n0)";
define pv/"p value" group;
run;
ods rtf close;
