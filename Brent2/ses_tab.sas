options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\ses_health.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
proc format;
	value yn 1='Yes' 2='No';
	value ny 0='No' 1='Yes';
	value housing 1='House (1)' 2='Flat (2)' 3='Shack (3)' 4='Other (4)';
	value living 1='Own home (1)' 2='Rent (2)' 3='Stay with family (3)' 4='Stay with friends (4)' 	5='Stay with employer (5)';
	value food 1='Never (1)' 2='Rarely (1-2 times/mo)(2)' 3='Often enough to eat (3)';
	value food_eat 1='Enough to eat (1)' 2='Sometimes not enough to eat (2)' 3='Often not enough to eat (3)';
	value no_food 1='Never (1)' 2='Rarely (1-2 times/mo)(2)' 3='Sometimes (3-10 times/mo)(3)' 4='Often (>10 times/mo)(3)';
	value arv_start 1='Sinikithemba (Ridge House)(1)' 2='Siyaphila Inpatient Ward (2)' 	3='Private Provider (3)' 4='DOH Clinic (4)' 5='Other (5)';

	value clinic_feel 1='Pleased (1)' 2='Worried (2)' 	3='Ashamed (3)' 4='Neutral (4)' 	5='Other (5)';
	value freq 0='Never (0)' 1='Rarely (1)' 	2='Sometimes (2)' 3='Frequently (3)';
	value idx 0="Control" 1="Case";

	value item 
		1='Do you have an income?'
		2='Are you (choice=Employed full-time (1))'
		3='Are you (choice=Employed part-time (2))'
	    4='Are you (choice=Self-employed (3))'
		5='Are you (choice=Attending school (4))'
		6='Are you (choice=Disabled (5))'
		7='Are you (choice=Unemployed seeking work (6))'
		8='Are you (choice=Unemployed NOT seeking work (7))'
		9='Are you (choice=Retired (8))'
		10='Other than an job, do you receive money from someone or somewhere?'
		11='Where do you stay?'
		12='Have you ever lived in an informal settlement since starting ARVs?'
		13='What is your current living arrangement?'

	14='Where you are staying now, do you have (please read all options and check all that apply): (choice=Electricity (1))'
	15='Where you are staying now, do you have (please read all options and check all that apply): (choice=Working radio (2))'
	16='Where you are staying now, do you have (please read all options and check all that apply): (choice=Toilet indoors (3))'
	17='Where you are staying now, do you have (please read all options and check all that apply): (choice=Television (4))'
	18='Where you are staying now, do you have (please read all options and check all that apply): (choice=Tap water indoors (5))'
	19='Where you are staying now, do you have (please read all options and check all that apply): (choice=None of these (6))'
	20='Do you have (please read all options and check all that apply): (choice=Car or bakkie (1))'
	21='Do you have (please read all options and check all that apply): (choice=Bicycle (2))'
	22='Do you have (please read all options and check all that apply): (choice=Motorcycle (3))'
	23='Do you have (please read all options and check all that apply): (choice=None of these (4))'
	24='In the past 4 weeks did you worry that you or your family would not have enough food?'
	25='In the past 4 weeks, the amount of food you and your family had to eat was:'
	26='In the past 4 weeks how many times did you or your family go an entire day and night without food because there was not enough food?'
	27='What clinic(s) do you currently attend? (choice=Sinikithemba (1))'
	28='What clinic(s) do you currently attend? (choice=Other (2))'
	29='Where did you first start ARVs?'
	30='Transport to clinic: (choice=Your car (1))'
	31='Transport to clinic: (choice=Friend/relative car (2))'
	32='Transport to clinic: (choice=Meter Taxi (3))'
	33='Transport to clinic: (choice=Mini Bus/Bus (4))'
	34='Transport to clinic: (choice=Walk (5))'
	35='Transport to clinic: (choice=Other (i.e. hired car)(6))'
	36='How do you pay for clinic meds? (choice=Sponsor (1))'
	37='How do you pay for clinic meds? (choice=Grant (2))'
	38='How do you pay for clinic meds? (choice=Employer (3))'
	39='How do you pay for clinic meds? (choice=Self-pay (4))'
	40='How do you pay for clinic meds? (choice=Family Member (5))'
	41='How do you pay for clinic meds? (choice=Spouse (6))'
	42='How do you pay for clinic meds? (choice=Other (7))'
	43='How do you feel about coming to clinic?'
	44='A healthcare worker not wanting to touch someone because they have HIV'
	45='People being treated poorly by hospital/clinic/healthcare workers because of HIV'
	46='People being rejected at hospital/clinic because of HIV'
	47='A healthcare worker talking out loud about a patient with HIV'
	48='Cost of visit'
	49='Cost of transport'
	50='Getting transport'
	51='Time off work'
	52='Fear of being seen by someone you know at clinic'
	53='Fear of others knowing you are living with HIV'
	54='Childcare'
	55='Being ill'
	56='Family circumstances'
	57='Receiving treatment from Traditional Healer'
	58='Other reason'
	;
	
run;


data ses;
	set brent.ses_health;
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

%let varlist=income employ1 employ2 employ3 employ4 employ5 employ6 employ7 employ8 money housing settlement 
	living live1 live2 live3 live4 live5 live6 trans1 trans2 trans3 trans4 food_4wks food_eat_4wks no_food_4wks 
	clinic1 clinic2 arv_start ctran1 ctran2 ctran3 ctran4 ctran5 ctran6 cmed1 cmed2 cmed3 cmed4 cmed5 cmed6 cmed7 clinic_feel 
	hcw_touch treat_poorly rejected talk_loud cost_visit cost_transport get_transport off_work fear_seen fear_know childcare ill 
	family healer other_stop;
%tab(ses, idx, tab, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set /*stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A)*/
		tab
		;
	if item in(1,10,12) then code0=put(code, yn.);	
	if 2<=item<=9 then code0=put(code, ny.);	
	if item=11 then code0=put(code, housing.);	
	if item=13 then code0=put(code, living.);	
	if 14<=item<=23 then code0=put(code, ny.);	
	if item=24 then code0=put(code, food.);	
	if item=25 then code0=put(code, food_eat.);	
	if item=26 then code0=put(code, no_food.);	
	if item in(27,28) then code0=put(code, ny.);	
	if item=29 then code0=put(code, arv_start.);	
	if 30<=item<=42 then code0=put(code, ny.);	
	if item=43 then code0=put(code, clinic_feel.);	
	if item>=44 then code0=put(code, freq.);	

	format item item.;	
run;

ods rtf file="ses_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left cellwidth=4in];
define code0/"." style=[cellwidth=1in];
define nft/"All patients*(n=&n)" style=[cellwidth=1.5in];
define nfy/"Case*(n=&n1)";
define nfn/"Control*(n=&n0)";
define pv/"p value" group;
run;
ods rtf close;
