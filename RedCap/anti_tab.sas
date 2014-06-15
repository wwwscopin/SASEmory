options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\anti.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='Antiretrovirals from CURRENT REGIMEN (choice=Abacavir (ABC))'
	2='Antiretrovirals from CURRENT REGIMEN (choice=Combivir (3TC/ZDV))'
	3='Antiretrovirals from CURRENT REGIMEN (choice=Didanosine (DDI))'
	4='Antiretrovirals from CURRENT REGIMEN (choice=Efavirenz (EFV))'
	5='Antiretrovirals from CURRENT REGIMEN (choice=Emtricitabine (FTC))'
	6='Antiretrovirals from CURRENT REGIMEN (choice=Epzicom (3TC/ABC))'
	7='Antiretrovirals from CURRENT REGIMEN (choice=Indinavir (IDV))'
	8='Antiretrovirals from CURRENT REGIMEN (choice=Lamivudine (3TC))'
	9='Antiretrovirals from CURRENT REGIMEN (choice=Lopinavir/ritonavir or Kaletra (LPV/r))'
	10='Antiretrovirals from CURRENT REGIMEN (choice=Nevirapine (NPV))'
	11='Antiretrovirals from CURRENT REGIMEN (choice=Ritonavir (RTV))'
	12='Antiretrovirals from CURRENT REGIMEN (choice=Saquinavir (SQV))'
	13='Antiretrovirals from CURRENT REGIMEN (choice=Stavudine (D4T))'
	14='Antiretrovirals from CURRENT REGIMEN (choice=Tenofovir (TDF))'
	15='Antiretrovirals from CURRENT REGIMEN (choice=Truvada (FTC/TDF))'
	16='Antiretrovirals from CURRENT REGIMEN (choice=Zidovudine (ZDV))'
	17='Antiretrovirals from CURRENT REGIMEN (choice=Other)'
	18='PREVIOUS Antiretrovirals (choice=Abacavir (ABC))'
	19='PREVIOUS Antiretrovirals (choice=Combivir (3TC/ZDV))'
	20='PREVIOUS Antiretrovirals (choice=Didanosine (DDI))'
	21='PREVIOUS Antiretrovirals (choice=Efavirenz (EFV))'
	22='PREVIOUS Antiretrovirals (choice=Emtricitabine (FTC))'
	23='PREVIOUS Antiretrovirals (choice=Epzicom (3TC/ABC))'
	24='PREVIOUS Antiretrovirals (choice=Indinavir (IDV))'
	25='PREVIOUS Antiretrovirals (choice=Lamivudine (3TC))'
	26='PREVIOUS Antiretrovirals (choice=Lopinavir/ritonavir or Kaletra (LPV/r))'
	27='PREVIOUS Antiretrovirals (choice=Nevirapine (NPV))'
	28='PREVIOUS Antiretrovirals (choice=Ritonavir (RTV))'
	29='PREVIOUS Antiretrovirals (choice=Saquinavir (SQV))'
	30='PREVIOUS Antiretrovirals (choice=Stavudine (D4T))'
	31='PREVIOUS Antiretrovirals (choice=Tenofovir (TDF))'
	32='PREVIOUS Antiretrovirals (choice=Truvada (FTC/TDF))'
	33='PREVIOUS Antiretrovirals (choice=Zidovudine (ZDV))'
	34='PREVIOUS Antiretrovirals (choice=Other)'
	;

	value ny 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
run;


data anti;
	set brent.anti;
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


%let varlist=current_regimen___1 current_regimen___2 current_regimen___3 current_regimen___4 current_regimen___5 current_regimen___6 
	current_regimen___7 current_regimen___8 current_regimen___9 current_regimen___10 current_regimen___11 current_regimen___12 
	current_regimen___13 current_regimen___14 current_regimen___15 current_regimen___16 current_regimen___99 previous_regimen___1 
	previous_regimen___2 previous_regimen___3 previous_regimen___4 previous_regimen___5 previous_regimen___6 previous_regimen___7 
	previous_regimen___8 previous_regimen___9 previous_regimen___10 previous_regimen___11 previous_regimen___12 previous_regimen___13 
	previous_regimen___14 previous_regimen___15 previous_regimen___16 previous_regimen___99 ;
%tab(anti, idx, tab, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set tab;

	code0=put(code, ny.);	
	format item item.;	
run;

ods rtf file="anti_table.rtf" style=journal bodytitle startpage=never ;
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
