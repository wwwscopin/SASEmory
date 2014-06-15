options orientation=landscape nodate nonumber nofmterr byline;
proc format; 

value StudySite
	1 ="CHOA-Egleston"
	2 ="Pittsburgh" 
	3 ="LSU-Shreveport" 
	4 ="Columbus" 
	5 ="CNMC"
	6 ="Cincinnati" 
	7 ="CHOA-Scottish Rite"
	8 ="Cook Children's (Texas)" 
	9 ="Texas Children's" 
	10 ="Minnesota" 
	11 ="Vanderbilt" 
	12 ="Stanford" 
	13 ="Michigan" 
	14 ="Phoenix" 
	15 ="Iowa" 
	16 ="All Sites"
; 

value VisitList
	-1 ="Screening"
	0="Day 0"
	1 ="Day 1"
	2 ="Day 2" 
	3 ="Day 3" 
	4 ="Day 4"
	5 ="Day 5"
	6 ="Day 6"
	7 ="Day 7"
	8 ="Day 8"
	9 ="Day 9"
	10 ="Day 10"
	11 ="Day 11"
	12 ="Day 12"
	13 ="Day 13"
	14 ="Day 14"
	15 ="Day 15"
	16 ="Day 16"
	17 ="Day 17" 
	18 ="Day 18" 
	19 ="Day 19"
	20 ="Day 20"
	21="Day 21"
	22="Day 22"
	23="Day 23"
	24="Day 24"
	25="Day 25"
	26 ="Day 26"
	27 ="Day 27"
	28 ="Day 28"
	99 ="Overall"
; 

value yn
	0= "No"
	1= "Yes"
;

value pe
	0= "Standard Therapy"
	1= "PEx Change"
;

value whyleft
	1= "Withdrawal of consent"
	2= "Patient improvement / Treatment goal met"
	3 = "Death"
	4 = "Complications"
;

value icd_death
	1="Incision of vessels, unspecified"
	2="Endarterectomy, intracranial vessels"
	3="Other malignant lymphomas, unspecified site"
	4="Cardiorespiratory / cardiopulmonary arrest (cardiac arrest)"
	5="Hemorrhage cerebral NOS / Massive pontine hemorrhage - intracerebral hemorrhage"
	6="Acute respiratory failure"
	7="Septic shock"
	8="Sepsis"
;

value deathrate
	0 = "Low predicted death rate by PELOD (< 50%)"
	1 = "High predicted death rate by PELOD (> 50%)"
;   

value group 1="Plasma Exchange" 2="Vital Status";
value censor 0="Non-Survivor" 1="Survivor";

value item 1="PELOD Score" 2="PELOD Score Change(%)" 3="PELOD Score Change" 4="PELOD Score" 5="PELOD Score Change(%)" 6="PELOD Score Change";
value idx  1="Treatment" 2="ECMO" 3="CVVH" 4="Day" 5="Standard Therapy*day" 6="Plasma Exchange*day";
value gp 1="PELOD Score" 2="PELOD Score Change";
run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

data TAMOF.survival; set TAMOF.survival;
      if patientid = 111001 then pelodtotalscore = 21;
      if patientid = 111003 then pelodtotalscore = 30;
      if patientid = 111006 then pelodtotalscore = 22;
      if patientid = 111008 then pelodtotalscore = 22;

      if patientid = 111003 then daysonpex = 3;
      if patientid = 111004 then daysonpex = 3;

      if patientid = 111007 then plasmaexchange = 1;
      if patientid = 111007 then daysonpex = 3; 

      drop pelodpreddeathrate deathrate; *These are not correct anymore and we don't use them anyway ;
run;

data TAMOF.daily; set TAMOF.daily;
      if patientid = 111001 & visitlist = 1 then pelodtotalscore = 21;
      if patientid = 111002 & visitlist = 1 then pelodtotalscore = 21;
      if patientid = 111003 & visitlist = 1 then pelodtotalscore = 30;
      if patientid = 111004 & visitlist = 1 then pelodtotalscore = 50;
      if patientid = 111005 & visitlist = 1 then pelodtotalscore = 21;
	  if patientid = 111006 & visitlist = 1 then pelodtotalscore = 22;
      if patientid = 111007 & visitlist = 1 then pelodtotalscore = 13;
      if patientid = 111008 & visitlist = 1 then pelodtotalscore = 22;
      if patientid = 111009 & visitlist = 1 then pelodtotalscore = 32;
	  if patientid = 111010 & visitlist = 1 then pelodtotalscore = 22;

      * delete all longitudinal PELOD values for Vanderbilt patients ; 
      if floor((patientid-100000)/1000) = 11 & visitlist ~= 1 then pelodtotalscore = .;
run;


data ttt;
	set tamof.lab(keep=patientid day adamts13  vwf_ag  vwf_rca);
	*where  day=5;
run;

/*
proc contents data=TAMOF.ecmo_survival;run;
proc print data=TAMOF.ecmo_survival;var patientid censor time pelodtotalscore; run;
proc print data=TAMOF.daily;var patientid treatmentday PelodTotalScore platelets; run;
proc print data=TAMOF.lab;var patientid day adamts13  vwf_ag  vwf_rca; run;
proc contents data=TAMOF.daily;run;
proc contents data=TAMOF.pex;run;
proc contents data=TAMOF.lab;run;
*/
proc sort data=tamof.pex; by patientid;run;
proc sort data=tamof.lab; by patientid;run;
proc sort data=tamof.demographic; by patientid;run;

data plt;
	merge   tamof.daily(keep=patientid treatmentday PelodTotalScore platelets rename=(treatmentday=day) in=A)
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	pelod0=PelodTotalScore;
	if B;
run;

%let pm=%sysfunc(byte(177)); 
%put &pm;

data dead0;
	set plt(where=(censor=0)); by patientid day;
	if last.patientid and day<7 then 
		do i=day+1 to 7;
			day=i; PelodTotalScore=71;
			output;
		end;
	drop i platelets;
run;

data pelod;
	set dead0 plt;
	by patientid day;
	if PelodTotalScore=71 then pelod0=.;
run;

data lab;
	merge   tamof.lab(keep=patientid day adamts13  vwf_ag  vwf_rca in=A)
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	if patientid= 111002 and day=3 then day=4;
	if B and day^=.;
run;

data mixed; 
	merge pelod lab; by patientid day;
	rename PelodTotalScore=pelod patientid=id platelets=plt PlasmaExchange=pe;
	if patientid=110002 then censor=1;
	retain bp;
	if day=1 then bp=pelod0;
	dbp=pelod0-bp;
	chg=dbp/bp*100;
	*if chg>400 then chg=.;
run;

data mixed;
	merge mixed tamof.survival(keep=patientid ecmo cvvh rename=(patientid=id)); by id; 
	*if id=111003 then cvvh=1;
run;

	data tmp;
		set mixed;
		where 1<=day<=7 and pelod0^=.;
	run;

	proc sort nodupkey; by id day pelod0; run;

data sub;
	set mixed;
	where chg>400 and 1<=day<=7;
	keep id pe censor day bp pelod0 dbp chg; 
	format chg 5.0;
run;

data mixed7;
	merge mixed(where=(day=1) keep=id day pe censor pelod0 dbp chg rename=(pelod0=pelod1 dbp=dbp1 chg=chg1))
		  mixed(where=(day in(2,3,4,5,6,7)) keep=id day pe censor pelod0 dbp chg rename=(pelod0=pelod7 dbp=dbp7 chg=chg7))
		  ;
		by id;
run;


ods listing;

proc means data=mixed7;
class censor; 
var pelod1 pelod7;
run;

proc means data=mixed;
class pe day;
var pelod plt adamts13  vwf_ag  vwf_rca;
run;

proc sort data=mixed nodupkey out=mixed_id; by id;run;

proc means data=mixed_id;
	class pe;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if pe=0 then call symput("no",compress(n));
	if pe=1 then call symput("ny",compress(n));
run; 
%put &no;

proc sort data=mixed nodupkey out=mixed_id1; by id;run;

proc means data=mixed_id1;
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("nd",compress(n));
	if censor=1 then call symput("ns",compress(n));
run;

%macro getn(data,var);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;
    if &var=0 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if &var=1 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let mu=%sysfunc(byte(181));
%put &mu;

%macro tab(data, cvar, out, varlist);

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
		where 1<=day<=7;
	run;

	proc sort nodupkey; by id day &var; run;


proc mixed data =tmp empirical covtest; 
	class &cvar id day ecmo cvvh; 	
	model &var=&cvar day &cvar*day cvvh ecmo/ solution ; 
	repeated day / subject = id type =cs;
	lsmeans &cvar &cvar*day ecmo cvvh day/cl ;
	ods output lsmeans = lsmeans_&i;
		ods output   Mixed.Tests3=p_&var;
run;

data lsmeans_&var;
	length code0 $20;
	set lsmeans_&i;
	if effect="&cvar"  then do; idx=1; code=&cvar; code0=put(code,pe.);end;
	if effect='ecmo' then do; idx=2; code=ecmo; code0=put(code,yn.);end;
	if effect='cvvh' then do; idx=3; code=cvvh; code0=put(code,yn.);end;
	if effect='day'  then do; idx=4; code=day; code0=put(code, visitlist.);end;
	if effect="&cvar*day" then do; 
		if &cvar=0 then do; idx=5; code=day; code0=put(code, visitlist.);end; 
		if &cvar=1 then do; idx=6; code=day; code0=put(code, visitlist.);end;
	end;
run;

proc sort; by idx;run;

data p_&var;
	length pv $7;
	set p_&var;
	pv=put(probf,7.4);
	if probf<0.0001 then pv="<0.0001";
	if effect="&cvar"  then  idx=1;
	if effect='ecmo'   then  idx=2;
	if effect='cvvh'   then  idx=3;
	if effect='day'    then  idx=4;
	if effect="&cvar*day"  then  idx=5; output;
	if effect="&cvar*day"  then  idx=6; output;
run;
proc sort nodupkey; by idx;run;

proc print data=p_pelod0;run;

data tab&i;
	length effect $12;
	merge lsmeans_&var p_&var; by idx;
	keep gp idx effect day code code0 estimate stderr upper lower probf pv mean0 ci;
	mean0=put(estimate,4.1)||" &pm "||compress(put(stderr, 4.1));
	ci="("||put(lower,4.1)||", "||compress(put(upper,4.1))||")";
	gp=&i;
run;

data &out;
	set &out tab&i;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend tab;


*%let varlist=pelod0 chg dbp;
%let varlist=pelod0 dbp;
%tab(mixed,pe,tab,&varlist); run;
proc sort data=tab; by gp idx;run;
proc print data=tab;run;


ods listing close;
ods rtf file = "pelod_ple_cvvh_ecmo_tab.rtf" style=journal bodytitle ;

proc report data=tab nowindows split="*";
title "Multivariate Analysis of PELOD Score/PELOD Score Change by PEx, ECMO, CVVH and Days on Study.";
column gp idx code0 mean0 ci pv;
define gp/group order format=gp. style=[just=left cellwidth=1.75in] " ";
define idx/group order=internal format=idx. style=[just=left cellwidth=1in] "Variable";
define code0/style=[just=left cellwidth=1.75in] "Category";
define mean0/style=[just=center cellwidth=1.25in] "Mean &pm SEM";
define ci/style=[just=center cellwidth=1.25in] "%95 CI";
define pv/group style=[just=center cellwidth=1in] "p value";
run;
ods rtf close;
