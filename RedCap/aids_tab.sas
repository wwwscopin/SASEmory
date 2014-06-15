options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\aids.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='AIDS Condition (choice=Bacterial infection)'
	2='AIDS Condition (choice=Candida Esophagitis)'
	3='AIDS Condition (choice=Candida Other)'
	4='AIDS Condition (choice=Cervical Cancer)'
	5='AIDS Condition (choice=Coccidioidomycosis)'
	6='AIDS Condition (choice=Cryptococcus)'
	7='AIDS Condition (choice=Cryptosporidiosis)'
	8='AIDS Condition (choice=CMV retinitis)'
	9='AIDS Condition (choice=CMV Other)'
	10='AIDS Condition (choice=HIV Dementia)'
	11='AIDS Condition (choice=HSV Other)'
	12='AIDS Condition (choice=Histoplasmosis)'
	13='AIDS Condition (choice=Isosporiasis)'
	14='AIDS Condition (choice=KS)'
	15='AIDS Condition (choice=LIP)'
	16='AIDS Condition (choice=Burkitts)'
	17='AIDS Condition (choice=Immunoblastic Lymphoma)'
	18='AIDS Condition (choice=CNS Lymphoma)'
	19='AIDS Condition (choice=MAC/M. kansasii)'
	20='AIDS Condition (choice=MTB (Pulmonary))'
	21='AIDS Condition (choice=EPTB)'
	22='AIDS Condition (choice=NTM)'
	23='AIDS Condition (choice=PCP)'
	24='AIDS Condition (choice=Recurrent Pneumonia)'
	25='AIDS Condition (choice=PML)'
	26='AIDS Condition (choice=Salmonella)'
	27='AIDS Condition (choice=Toxoplasmosis)'
	28='AIDS Condition (choice=Wasting Syndrome)'
	29='AIDS Condition (choice=Other)'

	30='Bacterial infection number of episodes'
	31='Candida Esophagitis number of episodes'
	32='Candida Other number of episodes'
	33='Cervical Cancer number of episodes'
	34='Coccidioidomycosis number of episodes'
	35='Cryptococcus number of episodes'
	36='Cryptosporidiosis number of episodes'
	37='CMV Retinitis number of episodes'
	38='CMV Other number of episodes'
	39='HIV Dementia number of episodes'
	40='HSV Other number of episodes'
	41='Histoplasmosis number of episodes'
	42='Isosporiasis number of episodes'
	43='KS number of episodes'
	44='LIP number of episodes'
	45='Burkitts number of episodes'
	46='Immunoblastic Lymphoma number of episodes'
	47='CNS Lymphoma number of episodes'
	48='MAC/M. kansasii number of episodes'
	49='MTB (Pulmonary) number of episodes'
	50='EPTB number of episodes'
	51='NTM number of episodes'
	52='PCP number of episodes'
	53='Recurrent Pneumonia number of episodes'
	54='PML number of episodes'
	55='Salmonella number of episodes'
	56='Toxoplasmosis number of episodes'
	57='Wasting Syndrome number of episodes'
	58='Other number of episodes'
	59='Other number of episodes'
	60='Other number of episodes'
	61='Other number of episodes'
	62='Other number of episodes'
	;

	value yn 1='Yes' 2='No';
	value ny 0="No" 1='Yes';
	
	value idx 0="CONTROL" 1="CASE";
run;


data aids;
	set brent.aids;
	format idx idx.;
run;

proc print;
 var infect_num cand_eso_num cand_oth_num cancer_num coccid_num crypto_num cryptospor_num cmv_ret_num cmv_oth_num dementia_num
	hsv_oth_num histo_num isospor_num ks_num lip_num burkitts_num lymphoma_num cns_num mac_num mtb_num eptb_num ntm_num pcp_num pneumonia_num pml_num
	salmonella_num toxo_num wasting_num other_aids_num1 other_aids_num2 other_aids_num3 other_aids_num4 other_aids_num5;
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


%let varlist=aids_condition___1 aids_condition___2 aids_condition___3 aids_condition___4 aids_condition___5 aids_condition___6 aids_condition___7 
	aids_condition___8 aids_condition___9 aids_condition___10 aids_condition___11 aids_condition___12 aids_condition___13 aids_condition___14 
	aids_condition___15 aids_condition___16 aids_condition___17 aids_condition___18 aids_condition___19 aids_condition___20 aids_condition___21 
	aids_condition___22 aids_condition___23 aids_condition___24 aids_condition___25 aids_condition___26 aids_condition___27 aids_condition___28 
	aids_condition___99;
%tab(aids, idx, tab, &varlist);
/*
%let varlist=infect_num cand_eso_num cand_oth_num cancer_num coccid_num crypto_num cryptospor_num cmv_ret_num cmv_oth_num dementia_num
	hsv_oth_num histo_num isospor_num ks_num lip_num burkitts_num lymphoma_num cns_num mac_num mtb_num eptb_num ntm_num pcp_num pneumonia_num pml_num
	salmonella_num toxo_num wasting_num other_aids_num1 other_aids_num2 other_aids_num3 other_aids_num4 other_aids_num5;
%tab(aids, idx, &varlist);
*/
data tab;
	*length nfn nfy nft code0 $40 pv $8;
	set tab /*stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A);
	if A then item=item+29;*/
	;
	if item<=29  then code0=put(code, ny.);

	format item item.;	
run;

ods rtf file="aids_table.rtf" style=journal bodytitle startpage=never ;
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
