options orientation=portrait nodate nonumber nofmterr byline;
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

value item 1="ADAMTS-13 Activity (%)" 2="ADAMTS-13 Activity (%) Change (%)" 3="ADAMTS-13 Activity (%) Change" 4="ADAMTS-13 Activity (%)" 5="ADAMTS-13 Activity (%) Change(%)" 6="ADAMTS-13 Activity (%) Change";
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
      if patientid = 111003 & visitlist = 1 then pelodtotalscore = 30;
      if patientid = 111006 & visitlist = 1 then pelodtotalscore = 22;
      if patientid = 111008 & visitlist = 1 then pelodtotalscore = 22;

      * delete all longitudinal PELOD values for Vanderbilt patients ; 
      if floor((patientid-100000)/1000) = 11 & visitlist ~= 1 then pelodtotalscore = .;
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
	merge   tamof.lab(keep=patientid day adamts13  vwf_ag  vwf_rca in=A rename=(adamts13=adam))
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	if patientid= 111002 and day=3 then day=4;
	if B and day^=.;
	if day in(2,3,4,5) then day=4;
	if day in(7,8,9) then day=8;
	if day in(21,25,28) then day=28;
run;

data mixed; 
	merge pelod lab; by patientid day;
	rename PelodTotalScore=pelod patientid=id platelets=plt PlasmaExchange=pe;
	if patientid=110002 then censor=1;
	retain bp;
	if day=0 then bp=adam;
	dbp=adam-bp;
	chg=dbp/bp*100;
	*if chg>400 then chg=.;
run;

data mixed;
	merge mixed tamof.survival(keep=patientid ecmo cvvh rename=(patientid=id)); by id; 
	*if id=111003 then cvvh=1;
run;


data sub;
	set mixed;
	where chg>400 and 1<=day<=7;
	keep id pe censor day bp pelod0 dbp chg; 
	format chg 5.0;
run;

data mixed7;
	merge mixed(where=(day=1) keep=id day pe censor adam dbp chg rename=(adam=adam1 dbp=dbp1 chg=chg1))
		  mixed(where=(day^=1) keep=id day pe censor adam dbp chg rename=(adam=adam0 dbp=dbp0 chg=chg0))
		  ;
		by id;
run;


ods listing;

proc means data=mixed7;
class censor; 
var adam1 adam0;
run;

proc sort data=mixed(where=(adam^=.)) nodupkey out=mixed_id; by id;run;

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

%macro mixed(data, cvar, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
	run;

	proc sort nodupkey; by id day &var; run;

	proc sort data=tmp nodupkey out=mixed_day; by &cvar day id;run;
	proc means data=mixed_day ;
    	class &cvar day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13= 0; %let m14= 0;   
%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13= 0; %let n14= 0; 

%let m15= 0; %let m16= 0; %let m17= 0; %let m18= 0; %let m19= 0; %let m20=0; %let m21= 0;  
%let m22= 0; %let m23= 0; %let m24= 0; %let m25= 0; %let m26= 0; %let m27= 0; %let m28= 0;   
%let n15= 0; %let n16= 0; %let n17= 0; %let n18= 0; %let n19= 0; %let n20=0; %let n21= 0;  
%let n22= 0; %let n23= 0; %let n24= 0; %let n25= 0; %let n26= 0; %let n27= 0; %let n28= 0; 

%getn(num_&var,&cvar);

proc format;
value dd  -1=" " 0 = "0*(&n0)*(&m0) "  1="1*(&n1)*(&m1)"  2 = " " 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5=" " 6 = " " 7=" " 8 = "8*(&n8)*(&m8) " 9=" " 
		10 = " " 11=" " 12 = " )" 13=" " 	14 = " " 15="15*(&n15)*(&m15)"  16=" "  17 = " " 
		18=" " 19= " "   20=" " 21 = " "    22=" " 23 = " "  24 = " " 25=" " 
		26 = " " 27=" "  28="28*(&n28)*(&m28)" 40=" ";

proc mixed data =tmp empirical covtest; 
	class &cvar id day ecmo cvvh; 	
	model &var=&cvar day &cvar*day cvvh ecmo/ solution ; 
	repeated day / subject = id type =cs;
	lsmeans &cvar &cvar*day/pdiff cl ;
	ods output lsmeans = lsmeans_&i;
		ods output   Mixed.Tests3=p_&var;
run;

data p_&cvar._&var;
	length effect $100;
	set p_&var;
	%if &cvar=pe %then %do;
	if effect="pe" then do; effect="Plasma Exchange"; call symput("pv", put(probf,7.3)); end;
		if effect="day" then effect="Treatment Day";
			if effect="pe*day" then effect="Interaction between Plasma Exchange and Treatment Day";
				if effect="cvvh" then effect="Ever on CVVH";
					if effect="ecmo" then effect="Ever on ECMO";
	%end;
	%if &cvar=censor %then %do;
	if effect="censor" then do; effect="Vital Status"; call symput("pv", put(probf,7.3)); end;
		if effect="day" then effect="Treatment Day";
			if effect="censor*day" then effect="Interaction between Vital Status and Treatment Day";
	%end;
run;

data lsmeans_&var;
	set lsmeans_&i;
	%if &var^=adam %then %do;
		if day=0 then do; estimate=0; upper=0; lower=0; end;
	%end;
	day1=day+0.20;
	if day=8 then day1=day+0.5;
	if day>8 then day1=day+1;
	if effect='pe' or effect='censor' then day=99;
run;

proc sort; by &cvar day;run;

DATA anno0; 
	set lsmeans_&var(where=(&cvar=0 and day^=99));
	xsys='2'; ysys='2';  color='blue';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if day<15  then do;
    	X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else do;
    	X=day1-0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;

  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(&cvar=1 and day^=99));
	xsys='2'; ysys='2';  color='red';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if day<15  then do;
    	X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else do;
    	X=day-0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno0 anno1;
run;

data estimate_&var;
	merge lsmeans_&var(where=(&cvar=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(&cvar=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;

data estimate_&cvar._&var;
	set estimate_&var;
	est0=put(estimate0,5.1)||"["||put(lower0, 5.1)||", "||put(upper0,5.1)||"]";
	est1=put(estimate1,5.1)||"["||put(lower1, 5.1)||", "||put(upper1,5.1)||"]";
	keep day est0 est1;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
	value = (f=Century h=2.5 "Plasma Exchange" "Standard Therapy") offset=(0.2in, -0.2 in) frame;


axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (-1 0 1 4 8 15 28 40) minor=none offset=(0 in, 0 in);

%if &cvar=pe %then %do;
	

%if &var=adam %then %do;
	axis2 	label=(f=Century h=3 a=90 "ADAMTS-13 Activity (%)") value=(f=Century h=3) order= (30 to 110 by 10) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "ADAMTS-13 Activity vs Days on Study";
	*title2 height=3 f=Century "(Survivors=&nya vs. Non-Survivors=&noa)";
	title2 height=3 f=Century "(Plasma Exchange=&ny  vs Standard Therapy=&no)";
%end;


%if &var=dbp %then %do;
	axis2 	label=(f=Century h=3 a=90 "ADAMTS-13 Activity Change from Baseline") value=(f=Century h=3) order= (-30 to 60 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "ADAMTS-13 Activity Change from Baseline vs Days on Study";
	title2 height=3 f=Century "(Plasma Exchange=&ny  vs Standard Therapy=&no)";

%end;

%if &var=chg %then %do;
	axis2 	label=(f=Century h=3 a=90 "ADAMTS-13 Activity Change from Baseline (%)") value=(f=Century h=3) order= (-100 to 360 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PADAMTS-13 Activity from Baseline vs Days on Study";
%end;


%end;

       
proc gplot data= estimate_&var(where=(day^=99)) gout=tamof.graphs;
%if &var^=adam %then %do;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend vref=0 lvref=4;
%end;
%else %do;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
%end;
%if &cvar=pe %then %do;
	note h=3 m=(2pct, 15 pct) "Day :" ;
	note h=3 m=(2pct, 11.5 pct) "(#Plasma Exchange)" ;
	note h=3 m=(2pct, 8 pct) "(#Standard Therapy)" ;
	format estimate0 estimate1 4.0 day dd.; 
%end;

%if &cvar=censor %then %do;
	note h=3 m=(2pct, 15 pct) "Day :" ;
	note h=3 m=(2pct, 11.5 pct) "(#Survivors)" ;
	note h=3 m=(2pct, 8 pct) "(#Non-Survivors)" ;
	format estimate0 estimate1 4.0 day dd.; 
%end;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions rotate = landscape noborder;

%let varlist=adam chg dbp;
%mixed(mixed,pe,&varlist); run;

data est_pe_adam;
	set estimate_pe_adam(in=A) estimate_pe_chg(in=B)  estimate_pe_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if (B or C) and day=0 then do; est0="-"; est1="-"; end;
	format item item. ;

	if A or C;
	where day in(0,1,4,8,15,28,99);
run;
proc sort; by item; run;


data p_adam;
	set p_pe_adam(in=A) p_pe_chg(in=B) p_pe_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if A or B or C then gp=1;

	if A or C;

	format item item. gp group.;
run;
proc sort; by item; run;


goptions hsize=0in vsize=0in;
proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean ADAMTS-13 Activity (%) and 95% confidence intervals by treatment group";
  title2 h=5pt "(Plasma Exchange=&ny vs. Standard Therapy=&no)";
run;
goptions hsize=0in vsize=0in;
proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean ADAMTS-13 Activity (%) and 95% confidence intervals by vital status";
  title2 h=5pt "(Survivors=&ns vs. Non-Survivors=&nd)";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

goptions reset=all border;
ods listing close;
ods pdf file = "adam_ple_cvvh_ecmo.pdf" style=journal ;
proc greplay nofs /*NOBYLINE*/;
igout tamof.graphs;
list igout;
tc template;
tdef t1 3 /llx=10    ulx=10   lrx=80   urx=80  lly=5    uly=35    lry=5      ury=35
        2 /llx=10    ulx=10   lrx=80   urx=80  lly=35   uly=65    lry=35     ury=65
        1 /llx=10    ulx=10   lrx=80   urx=80  lly=65   uly=95    lry=65     ury=95
		4 /llx=15    ulx=15   lrx=75   urx=75  lly=0  uly=99   lry=0   ury=99					
			;
template t1;
tplay 1:1 3:3 /*4:5*/;
run; quit;


proc report data=est_pe_adam nowindows split="*";
title "Estimation of PELOD Score and 95%CI by Treatment from Multivariate Analysis";
column item day est0 est1;
define item/order style=[just=left cellwidth=2.25in] "Item";
define day/style=[just=left cellwidth=0.75in] "Day";
define est0/style=[just=center cellwidth=1.75in] "Standard Therapy* Mean[Lower, Upper]";
define est1/style=[just=center cellwidth=1.75in] "Plasma Exchange*Mean[Lower, Upper]";
run;

ods pdf startpage=no ;


proc report data=p_adam nowindows split="*";
title "P Values from Multivariate Analysis";
column item effect probF;
*define gp/order "";
define item/order style=[just=left cellwidth=2.25in] "Item";
define effect/style=[just=left cellwidth=3.5in] "Effect";
define probF/style=[just=center cellwidth=0.75in] "p value";
run;

ods pdf close;
