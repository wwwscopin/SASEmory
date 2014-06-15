options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\psycho.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='1a. What is your marital status?'
	2='1b. Which forms of safe sex do you practice? (choice=Abstinence (1))'
	3='1b. Which forms of safe sex do you practice? (choice=Condoms (2))'
	4='1b. Which forms of safe sex do you practice? (choice=Pull out (3))'
	5='1b. Which forms of safe sex do you practice? (choice=None (4))'
	6='1b. Which forms of safe sex do you practice? (choice=Other (5))'
	7='Which type of condoms? (choice=Male (1))'
	8='Which type of condoms? (choice=Female (2))'
	9='1c. In the last 6 months, how often did you practice safe sex?'
	10='5. Who knows you are living with HIV? (choice=Partner/spouse (1))'
	11='5. Who knows you are living with HIV? (choice=Family member(s)(2))'
	12='5. Who knows you are living with HIV? (choice=Friends (3))'
	13='5. Who knows you are living with HIV? (choice=Employer (4))'
	14='5. Who knows you are living with HIV? (choice=Other (5))'
	
	15='Do they live with you?'
	16='7a. Do you have someone who is a treatment supporter/partner?'
	17='8a. Have you ever been hurt by someone?'
	18='8b. How have you been hurt? (choice=Physical (1))'
	19='8b. How have you been hurt? (choice=Sexual (2))'
	20='8b. How have you been hurt? (choice=Verbal (3))'
	21='8b. How have you been hurt? (choice=Psychological (4))'
	22='8b. How have you been hurt? (choice=Other (5))'
	23='8c. Has anyone ever physically forced your to have sex even when you did not want?'
	24='Whom?'
	25='8d. Has anyone ever forced you to perform any sexual acts you did not want to?'
	26='Whom?'
	27='8e. When was the last time you were hurt sexually?'
	28='9. In the past 4 weeks, did you use street drugs?'
	29='10a. How often do you drink alcohol?'
	30='10b. What type of alcohol? (choice=Mqombothi (1))'
	31='10b. What type of alcohol? (choice=Cider (2))'
	32='10b. What type of alcohol? (choice=Wine (3))'
	33='10b. What type of alcohol? (choice=Spirits (4))'
	34='10b. What type of alcohol? (choice=Beer (5))'
	35='10c. Have you ever felt you should cut down on your drinking?'
	36='10d. Hae people annoyed you by criticizing your drinking?'
	37='10e. Have you ever felt bad or guilty about your drinking?'
	38='10f. Have you ever had a drink first thing in the morning to steady your nerves or get rid of a hangover (eye-opener)?'
	39='11a. Do you smoke?'
	40='11b. What do you smoke? (choice=Cigarettes (1))'
	41='11b. What do you smoke? (choice=Cigars (2))'
	42='11b. What do you smoke? (choice=Pipe (3))'
	43='11b. What do you smoke? (choice=Dagga (4))'
	44='12. How much education do you feel  you have received about HIV?'
	45='13a. How many pre-ARV training sessions did you receive?'
	46='13b. Were these sessions helpful?'
	47='14. In the last 12 months, how many 1-on-1 adherence counseling sessions have you received?'
	48='Were the sessions helpful to you?'
	49='15a. Would you like additional support for your illness (i.e. financial, emotional, spiritual)?'
	50='16. Do you feel you have access to all the services you need?'
	51='17. Which services would you like to access more? (choice=Health Education (1))'
	52='17. Which services would you like to access more? (choice=Counseling (2))'
	53='17. Which services would you like to access more? (choice=Doctors (3))'
	54='17. Which services would you like to access more? (choice=Pharmacy (4))'
	55='17. Which services would you like to access more? (choice=Physiotherapy (5))'
	56='17. Which services would you like to access more? (choice=Social Work (6))'
	57='17. Which services would you like to access more? (choice=Psychiatry/Psychology (7))'
	58='17. Which services would you like to access more? (choice=Prayer/Minister (8))'
	59='17. Which services would you like to access more? (choice=Other (9))'
	60='a. During the past month, about how often did you feel tired out for no good reason?'
	61='b. During the past month, about how often did you feel nervous?'
	62='c. So nervous that nothing could calm you down?'
	63='d. During the past month, about how often did you feel hopeless?'
	64='e. During the past month, about how often did you feel restless or fidgety?'
	65='f. So restless you could not sit still?'
	66='g. During the past month, about how often did you feel sad or depressed?'
	67='h. So depressed that nothing could cheer you up?'
	68='i. During the past month, about how often did you feel that everything was an effort?'
	69='j. During the past month, about how often did you feel worthless?'
	70='30a. Total Score'
	71='Would you like me to share your responses with your adherence counselor?'
	72='Would you like me to share your responses with your doctor?'
	;

	value marital_status 1='Married (1)' 2='Divorced (2)' 	3='Single living with partner (3)' 4='Single not living with partner (4)' 
		5='Single no partner (5)' 6='Widowed (6)' 	7='Separated (7)';
	value ny 0='No' 1='Yes';
	value practice_safe 1='Always (100%)(1)' 2='Often (>50%)(2)' 	3='Sometimes (< 50%)(3)' 4='Rarely (< 25%)(4)' 	5='Never, or none (0%)(5)' 9='Declined to answer (9)';

	value yn 1='Yes' 2='No';
	value abuse 1='Frequently (>=3x/wk)(1)' 2='Sometimes (>=1x/mo)(2)' 3='Rarely (>=1/yr)(3)' 4='Never (4)';
	value abuse_sex 1='Often (1)' 2='Sometimes (2)' 		3='Not at all (3)';
	value abuse_whom 1='Partner (1)' 2='Other (2)';
	value abuse_acts 1='Often (1)' 2='Sometimes (2)' 		3='Not at all (3)';
	value abuse_acts_whom 1='Partner (1)' 2='Other (2)';
	value abuse_sex_time 1='< 1 mo (1)' 2='1-6 mo (2)' 	3='>6-12 mo (3)' 4='>12 mo (4)';

	value alcohol 1='Daily (1)' 2='4-5 times/week (2)' 	3='Weekends (3)' 4='3-4 times/month (4)' 
		5='Once/month (5)' 6='< Once/month (6)' 		7='Never (7)';

	value hiv_educate 1='Much (1)' 2='Some (2)' 		3='Little (3)' 4='None (4)';
	value arv_train 1='0(1)' 2='1-2 (2)' 		3='3-5 (3)' 4='>5 (4)';
	value session_num 0='0' 1='1' 		2='2' 3='3' 		4='4' 5='5' 	6='6' 7='7' 	8='10+';

	value fq 1='None of the time (1)' 2='A little of the time (2)' 	3='Some of the time (3)' 4='Most of the time (4)' 	5='All of the time (5)';
	value idx 0="CONTROL" 1="CASE";
run;


data psycho;
	set brent.psycho;
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


%let varlist=marital_status safe_sex___1 safe_sex___2 safe_sex___3 safe_sex___4 safe_sex___5 safe_condom___1 safe_condom___2 
	practice_safe knows_hiv___1 knows_hiv___2 knows_hiv___3 knows_hiv___4 knows_hiv___5 support_live treat_support abuse 
	abuse_type___1 abuse_type___2 abuse_type___3 abuse_type___4 abuse_type___5 abuse_sex abuse_whom abuse_acts abuse_acts_whom 
	abuse_sex_time drugs alcohol alcohol_type___1 alcohol_type___2 alcohol_type___3 alcohol_type___4 alcohol_type___5 
	drinking_stop drinking_crit drinking_guilt drinking_morning smoke smoke_type___1 smoke_type___2 smoke_type___3 smoke_type___4 
	hiv_educate arv_train train_help session_num session_help support services services_spec___1 services_spec___2 services_spec___3 
	services_spec___4 services_spec___5 services_spec___6 services_spec___7 services_spec___8 services_spec___9 tired nervous nervous_rate 
	hopeless restless restless_sit depressed depressed_cheer effort worthless share_counselor share_doctor ;
%tab(psycho, idx, tab, &varlist);
%let varlist=total_score;
%stat(psycho, idx, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set tab(where=(item<=69))
	stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A)
	tab(where=(item>=70) in=B);

	if A then item=70;
	if B then item=item+1;
	if item in(15,16,28,35,36,37,38,39,46,48,49,50) then code0=put(code, yn.);	
	if item=1 then code0=put(code, marital_status.);	
	if item in(2,3,4,5,6,7,8,10,11,12,13,14,18,19,20,21,22,30,31,32,33,34,40,41,42,43,51,52,53,54,55,56,57,58,59) then code0=put(code, ny.);	
	if item=9 then code0=put(code, practice_safe.);	
	if item=17 then code0=put(code, abuse.)	;
	if item=23 then code0=put(code, abuse_sex.)	;
	if item=24 then code0=put(code, abuse_whom.)	;
	if item=25 then code0=put(code, abuse_acts.)	;
	if item=26 then code0=put(code, abuse_acts_whom.)	;
	if item=27 then code0=put(code, abuse_sex_time.)	;
	if item=29 then code0=put(code, alcohol.)	;

	if item=44 then code0=put(code, hiv_educate.);	
	if item=45 then code0=put(code, arv_train.);	
	if item=47 then code0=put(code, session_num.);	
	if 60<=item<=69 or item in(71,72)  then code0=put(code, fq.);
	
	format item item.;	
run;

ods rtf file="psycho_table.rtf" style=journal bodytitle startpage=never ;
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
