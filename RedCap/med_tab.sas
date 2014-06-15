options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\med_adhe.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1="How do you remember to take your meds? (choice=Pill box (1))"
	2="How do you remember to take your meds? (choice=Clock/Watch alarm (2))"
	3="How do you remember to take your meds? (choice=Cell phone (3))"
	4="How do you remember to take your meds? (choice=Partner (4))"
	5="How do you remember to take your meds? (choice=Calendar (5))"
	6="How do you remember to take your meds? (choice=Chart (6))"
	7="How do you remember to take your meds? (choice=Media (TV/Radio)(7))"
	8="How do you remember to take your meds? (choice=Daily schedule (8))"
	9="How do you remember to take your meds? (choice=Other (9))"
	10="How do you remember to come for your drug collection appt? (choice=Appointment card (1))"
	11="How do you remember to come for your drug collection appt? (choice=Partner/Friend (2))"
	12="How do you remember to come for your drug collection appt? (choice=Cellphone (3))"
	13="How do you remember to come for your drug collection appt? (choice=Other (4))"
	14="You were away from home"
	15='You were busy with other things'
	16='You forgot to take pills'
	17='You had too many pills to take'
	18='You had wanted to avoid side effects'
	19='You did not want others to see you taking ARVs'
	20='You had a change in what you do every day'
	21='You felt like the drug could hurt/harm you '
	22='You fell asleep through the dose time'
	23='You felt sick or ill'
	24='You felt depressed or stressed'
	25='You had a problem taking pills at certain times (with meals, on empty stomach, etc.)'
	26='You forgot to obtain meds'
	27='You ran out of pills'
	28='You did not have money for ARVs'
	29='You were tired of ARVs'
	30='You dont like taking pills'
	31='You have difficulty swallowing ARVs'
	32='You thought you did not need more ARVs because you felt good'
	33='Receiving treatment from Traditional Healer'
	34='You had too much alcohol'
	35='You were taking street drugs'
	36='Other (i.e. Partner borrows/Someone steals meds)'
	;
	value how_often 0='Never (0)' 1='Rarely (1)' 2='Sometimes (2)' 3='Frequently (3)';
	value yn 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
run;


data med;
	set brent.med_adhe;
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


%let varlist=remember_meds___1 remember_meds___2 remember_meds___3 remember_meds___4 remember_meds___5 remember_meds___6 remember_meds___7 
remember_meds___8 remember_meds___9 remember_collect___1 remember_collect___2 remember_collect___3 remember_collect___4 
arvs_home arvs_busy arvs_forgot arvs_too_many arvs_side_effects arvs_others arvs_change arvs_harm arvs_sleep arvs_sick arvs_depressed 
arvs_times arvs_obtain arvs_out arvs_money arvs_tired arvs_taking arvs_swallow arvs_feel_good arvs_trad_healer arvs_alcohol arvs_drugs 
arvs_other;
%tab(med, idx, tab, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set tab;

	if item<=13 then code0=put(code, yn.);	
	if item>=14 then code0=put(code, how_often.);	

	format item item.;	
run;

ods rtf file="med_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"Case*(n=&n1)";
define nfn/"Control*(n=&n0)";
define pv/"p value" group;
run;
ods rtf close;
