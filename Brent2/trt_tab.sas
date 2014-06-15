options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\alt_spirit.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='1. Do you have a religious faith?'
	2='Which one(s)? (choice=Christian)'
	3='Which one(s)? (choice=Traditional African)'
	4='Which one(s)? (choice=Hindu)'
	5='Which one(s)? (choice=Muslim)'
	6='Which one(s)? (choice=Other)'
	
	7='2. How active are you in practicing your religion?'
	8='3. Have you ever stopped your ARVs because of your religious beliefs or teachings?'
	9='4. Did you EVER take any Traditional Medications or herbs (African/muthi, Chinese, Indian)?'
	10='How long ago?'

	11='Drug1-Did the remedy come in the form of a plant?'
	12='Raw material'
	13='Partially processed'
	14='Did the remedy come in the form of a packaged medicine?'
	15='Form of package'
	16='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))'
	17='How did you take it (route)? (choice=Mouth/Oral)'
	18='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))'
	19='How did you take it (route)? (choice=Inhaled (incense, vapor bath))'
	20='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))'
	21='Where did you get this remedy? (choice=Traditional healer/Isangoma)'
	22='Where did you get this remedy? (choice=Herbalist/Inyanga)'
	23='Where did you get this remedy? (choice=Chemist/Pharmacist)'
	24='Where did you get this remedy? (choice=Fortune Teller)'
	25='Where did you get this remedy? (choice=Diviner)'
	26='Where did you get this remedy? (choice=Faith Healer)'
	27='Where did you get this remedy? (choice=Herbal Shop)'
	28='Where did you get this remedy? (choice=Street Vendor)'
	29='Where did you get this remedy? (choice=Chinese Practioner)'
	30='Where did you get this remedy? (choice=Other)'
	31='How did you feel with this remedy?'

	32='Drug2-Did the remedy come in the form of a plant?'
	33='Raw material'
	34='Partially processed'
	35='Did the remedy come in the form of a packaged medicine?'
	36='Form of package'
	37='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))'
	38='How did you take it (route)? (choice=Mouth/Oral)'
	39='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))'
	40='How did you take it (route)? (choice=Inhaled (incense, vapor bath))'
	41='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))'
	42='Where did you get this remedy? (choice=Traditional healer/Isangoma)'
	43='Where did you get this remedy? (choice=Herbalist/Inyanga)'
	44='Where did you get this remedy? (choice=Chemist/Pharmacist)'
	45='Where did you get this remedy? (choice=Fortune Teller)'
	46='Where did you get this remedy? (choice=Diviner)'
	47='Where did you get this remedy? (choice=Faith Healer)'
	48='Where did you get this remedy? (choice=Herbal Shop)'
	49='Where did you get this remedy? (choice=Street Vendor)'
	50='Where did you get this remedy? (choice=Chinese Practioner)'
	51='Where did you get this remedy? (choice=Other)'
	52='How did you feel with this remedy?'

	53='Drug3-Did the remedy come in the form of a plant?'
	54='Raw material'
	55='Partially processed'
	56='Did the remedy come in the form of a packaged medicine?'
	57='Form of package'
	58='How did you take it (route)? (choice=Skin/Topical (i.e. poultice, lotion, ointment, scarification))'
	59='How did you take it (route)? (choice=Mouth/Oral)'
	60='How did you take it (route)? (choice=Rectal/Anal (i.e. enema, sitz bath))'
	61='How did you take it (route)? (choice=Inhaled (incense, vapor bath))'
	62='How did you take it (route)? (choice=Multiple ways (infusions/decoctions))'
	63='Where did you get this remedy? (choice=Traditional healer/Isangoma)'
	64='Where did you get this remedy? (choice=Herbalist/Inyanga)'
	65='Where did you get this remedy? (choice=Chemist/Pharmacist)'
	66='Where did you get this remedy? (choice=Fortune Teller)'
	67='Where did you get this remedy? (choice=Diviner)'
	68='Where did you get this remedy? (choice=Faith Healer)'
	69='Where did you get this remedy? (choice=Herbal Shop)'
	70='Where did you get this remedy? (choice=Street Vendor)'
	71='Where did you get this remedy? (choice=Chinese Practioner)'
	72='Where did you get this remedy? (choice=Other)'
	73='How did you feel with this remedy?'


	74='5b. Do you take these medicines with your ARVs or instead of your ARVs?'
	75='5c. Have you had any side effects/adverse events to any of these remedies?'
	76='6a. In the last 6 mos, did you take meds or supplements from a chemist/pharmacist not prescribed by a doctor, herbalist, or healer?'
	77='6c. How did you feel with this medication?'
	78='7a. In the last 6 mos, did you use any other alternative treatment (for example but not limited to faith healing/prophet, Reikki, massage, sound/music, thermal, reflexology, chiropractic, acupuncture)?'
	79='7c. How did you feel with this treatment?'
	80='8. Who first recommended you to go to an HIV clinic? (choice=Provider (doctor or nurse)(1))'
	81='8. Who first recommended you to go to an HIV clinic? (choice=Traditional Healer (Isangoma)(2))'
	82='8. Who first recommended you to go to an HIV clinic? (choice=Herbalist (Inyanga)(3))'
	83='8. Who first recommended you to go to an HIV clinic? (choice=Friend (4))'
	84='8. Who first recommended you to go to an HIV clinic? (choice=Family (5))'
	85='8. Who first recommended you to go to an HIV clinic? (choice=Member of religious faith (6))'
	86='8. Who first recommended you to go to an HIV clinic? (choice=Other (7))'
	;

	value faith_active 1='Very active (1)' 2='Somewhat active (2)' 3='Not active (3)';
	value how_often 0='Never (0)' 1='Rarely (1)' 2='Sometimes (2)' 3='Frequently (3)';
	value traditional_time 1='< 1 week (1)' 2='1 wk-1month (2)' 3='> 1 month-6 months (3)' 4='> 6 mos (4)';
	value trad1_raw 1='Root' 2='Bark' 	3='Bulb' 4='Whole plant' 5='Leaves/stems' 6='Tubers' 7='Mixture';
	value trad1_process 1='Chopped' 2='Ground';
	value trad1_form 1='Powder' 2='Liquid' 	3='Tablet' 9='Other';
	value feel 1='Same' 2='Better' 	3='Worse';
	value meds_arvs 1='with ARVs (1)' 2='Instead of ARVs (2)';

	value yn 1='Yes' 2='No';
	value ny 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
run;


data trt;
	set brent.trt;
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


%let varlist=faith faith_specify___1 faith_specify___2 faith_specify___3 faith_specify___4 faith_specify___5
	faith_active faith_arvs_stop traditional_ever traditional_time trad1_plant trad1_raw trad1_process trad1_package trad1_form 
	trad1_route___1 trad1_route___2 trad1_route___3 trad1_route___4 trad1_route___5 trad1_where___1 trad1_where___2 trad1_where___3 
	trad1_where___4 trad1_where___5 trad1_where___6 trad1_where___7 trad1_where___8 trad1_where___9 trad1_where___10 trad1_feel 
	trad2_plant trad2_raw trad2_process trad2_package trad2_form 
	trad2_route___1 trad2_route___2 trad2_route___3 trad2_route___4 trad2_route___5 trad2_where___1 trad2_where___2 trad2_where___3 
	trad2_where___4 trad2_where___5 trad2_where___6 trad2_where___7 trad2_where___8 trad2_where___9 trad2_where___10 trad2_feel 
	trad3_plant trad3_raw trad3_process trad3_package trad3_form trad3_route___1 trad3_route___2 trad3_route___3 trad3_route___4 
	trad3_route___5 trad3_where___1 trad3_where___2 trad3_where___3 trad3_where___4 trad3_where___5 trad3_where___6 trad3_where___7 
	trad3_where___8 trad3_where___9 trad3_where___10 trad3_feel meds_arvs trad_side_effect chemist chemist_feel alt_treat alt_treat_feel 
	clinic_rec___1 clinic_rec___2 clinic_rec___3 clinic_rec___4 clinic_rec___5 clinic_rec___6 clinic_rec___7;
%tab(trt, idx, tab, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set tab;

	if item in(1,8,9,11,14,32,35,53,56,75,76,78) then code0=put(code, yn.);	
	if item in(2,3,4,5,6) then code0=put(code, ny.);	
	if item=7 then code0=put(code, faith_active.);	
	if item=10 then code0=put(code, traditional_time.);	
	if item in(12,33,54) then code0=put(code, trad1_raw.);	
	if item in(13,34,55) then code0=put(code, trad1_process.);	
	if item in(15,36,57) then code0=put(code, trad1_form.);	
	if 16<=item<=30 or 37<=item<=51  or 58<=item<=72 then code0=put(code, ny.);
	if item in(31,52,73,77,79) then code0=put(code, feel.);
	if item=74 then code0=put(code, meds_arvs.)	;
	if 80<=item<=86 then code0=put(code, ny.)	;

	format item item.;	
run;

ods rtf file="trt_table.rtf" style=journal bodytitle startpage=never ;
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
