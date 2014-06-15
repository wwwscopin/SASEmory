options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\non_aids.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='Serious non-AIDS condition (choice=Rash)'
	2='Serious non-AIDS condition (choice=Anemia)'
	3='Serious non-AIDS condition (choice=Pancreatitis)'
	4='Serious non-AIDS condition (choice=Hepatitis)'
	5='Serious non-AIDS condition (choice=Lipodystrophy)'
	6='Serious non-AIDS condition (choice=Peripheral Neuropathy)'
	7='Serious non-AIDS condition (choice=Diarrhea)'
	8='Serious non-AIDS condition (choice=Lactic Acidosis)'
	9='Serious non-AIDS condition (choice=Hyperlipidemia)'
	10='Serious non-AIDS condition (choice=Neuropsychological)'
	11='Serious non-AIDS condition (choice=Cardiovascular)'
	12='Serious non-AIDS condition (choice=Pulmonary)'
	13='Serious non-AIDS condition (choice=Hematological)'
	14='Serious non-AIDS condition (choice=Malignancy)'
	15='Serious non-AIDS condition (choice=Endocrine)'
	16='Serious non-AIDS condition (choice=Renal)'
	17='Serious non-AIDS condition (choice=Hepatobiliary)'
	18='Serious non-AIDS condition (choice=Gastrointestinal)'
	19='Serious non-AIDS condition (choice=Dermatological)'
	20='Serious non-AIDS condition (choice=Infectious Disease)'
	21='Serious non-AIDS condition (choice=Rheumatological)'
	22='Serious non-AIDS condition (choice=OB/GYN)'
	23='Serious non-AIDS condition (choice=Other Adverse Event)'
	24='Serious non-AIDS condition (choice=Other)'

	25='Rash number of episodes'
	26='Anemia number of episodes'
	27='Pancreatitis number of episodes'
	28='Hepatitis number of episodes'
	29='Lipodystrophy number of episodes'
	30='Peripheral Neuropathy number of episodes'
	31='Diarrhea number of episodes'
	32='Lactic Acidosis number of episodes'
	33='Hyperlipidemia number of episodes'
	34='Other Adverse Event number of episodes'
	35='Neuropsychological number of episodes'
	36='Cardiovascular number of episodes'
	37='Pulmonary number of episodes'
	38='Hematological number of episodes'
	39='Malignancy number of episodes'
	40='Endocrine number of episodes'
	41='Renal number of episodes'
	42='Hepatobiliary number of episodes'
	43='Gastrointestinal number of episodes'
	44='Dermatological number of episodes'
	45='Infectious Disease number of episodes'
	46='Rheumatological number of episodes'
	47='OB/GYN number of episodes'
	48='Other number of episodes'
	49='Other number of episodes'
	50='Other number of episodes'
	51='Other number of episodes'
	52='Other number of episodes'
	;

	value yn 1='Yes' 2='No';
	value ny 0="No" 1='Yes';
	
	value idx 0="CONTROL" 1="CASE";
run;


data nonaids;
	set brent.nonaids;
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


%let varlist=non_aids_condition___1 non_aids_condition___2 non_aids_condition___3 non_aids_condition___4 non_aids_condition___5 
	non_aids_condition___6 non_aids_condition___7 non_aids_condition___8 non_aids_condition___9 non_aids_condition___10 non_aids_condition___11 
	non_aids_condition___12 non_aids_condition___13 non_aids_condition___14 non_aids_condition___15 non_aids_condition___16 non_aids_condition___17
	non_aids_condition___18 non_aids_condition___19 non_aids_condition___20 non_aids_condition___21 non_aids_condition___22 non_aids_condition___98 
	non_aids_condition___99;
%tab(nonaids, idx, tab, &varlist);
/*
%let varlist=rash_num anemia_num pancreatitis_num hepatitis_num lipo_num neuropathy_num diarrhea_num acidosis_num lipidemia_num ae_other_num neuro_num
cardio_num pulmonary_num hema_num malig_num endocrine_num renal_num hepato_num gastro_num derm_num id_num rheum_num obgyn_num other_non_aids_num1 
other_non_aids_num2 other_non_aids_num3 other_non_aids_num4 other_non_aids_num5;
%tab(aids, idx, &varlist);
*/
data tab;
	*length nfn nfy nft code0 $40 pv $8;
	set tab /*stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A);
	if A then item=item+29;*/
	;
	if item<=24  then code0=put(code, ny.);

	format item item.;	
run;

ods rtf file="non-aids_table.rtf" style=journal bodytitle startpage=never ;
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
