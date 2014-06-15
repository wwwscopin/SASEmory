options orientation=landscape nodate nonumber nofmterr;
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

value item 1="PELOD Score" 2="PELOD Score Change(%)" 3="PELOD Score Change" 4="PELOD Score" 5="PELOD Score Change(%)" 6="PELOD Score Change";
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

      *drop pelodpreddeathrate deathrate; *These are not correct anymore and we don't use them anyway ;
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

%macro mixed(data, cvar, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
		where 1<=day<=7 /*and pe=1*/;
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
value dd   0 = " "  1="1*(&n1)*(&m1)"  2 = "2*(&n2)*(&m2)" 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5="5*(&n5)*(&m5)" 6 = "6*(&n6)*(&m6)" 7="7*(&n7)*(&m7)" 8 = " " ;

		*ods trace on/lable listing;
proc mixed data =tmp empirical covtest; 
	class &cvar id day; 	
	model &var=&cvar day &cvar*day/ solution ; 
	repeated day / subject = id type =cs;
	lsmeans &cvar &cvar*day/pdiff cl ;
	ods output lsmeans = lsmeans_&i;
	ods output  Mixed.Diffs=diff;
		ods output   Mixed.Tests3=p_&var;
run;
*ods trace off;

data p_&cvar._&var;
	length effect $100;
	set p_&var;
	%if &cvar=pe %then %do;
	if effect="pe" then do; effect="Treatment"; call symput("pv", put(probf,7.3)); end;
		if effect="day" then effect="Days on Study";
			if effect="pe*day" then effect="Interaction between Treatment and Days on Study";
				if effect="cvvh" then effect="Ever on CVVH";
					if effect="ecmo" then effect="Ever on ECMO";
	%end;
	%if &cvar=censor %then %do;
	if effect="censor" then do; effect="Vital Status"; call symput("pv", put(probf,7.3)); end;
		if effect="day" then effect="Days on Study";
			if effect="censor*day" then effect="Interaction between Vital Status and Days on Study";
	%end;
run;

data lsmeans_&var;
	set lsmeans_&i;
	%if &var^=pelod0 %then %do;
		if day=1 then do; estimate=0; upper=0; lower=0; end;
	%end;
	day1=day+0.20;
	if day=8 then day1=day+0.5;
	if day>8 then day1=day+1;
	if effect='pe' or effect='censor' then day=99;
run;

proc sort; by &cvar day;run;

data diff;
    length pv $8;
    set diff;
    where day=_day;
    diff=put(estimate,4.1)||"("||put(lower,4.1)||", "||put(upper,4.1)||")";
	/*
	pv=put(probt, 7.4);
    if probt<0.0001 then pv="<0.0001";
	if day<1 then delete;
	*/
	if day in (2,3,7) then pv=put(probt, 4.2);
	if day in (4) then pv=put(probt, 5.3);
	if day in (5) then pv=put(probt, 7.4);
    if probt<0.0001 then pv="<0.0001";

    keep day diff probt pv;  
run;

proc sort; by day; run;


DATA anno0; 
	set lsmeans_&var(where=(&cvar=0 and day^=99));
	xsys='2'; ysys='2';  color='blue';
	X=day1; 	y=estimate; FUNCTION='MOVE '; when = 'A';  OUTPUT; * start at mean ;
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
	merge lsmeans_&var(where=(&cvar=1 and day^=99)) diff(keep=day pv); by day;
	xsys='2'; ysys='2';  color='red';
	if day>1 then do;
		x=day;	Y=-14; 	FUNCTION='Label'; size=1.25; text="p="||compress(pv);OUTPUT; * draw down;
	end;
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
	if day=1 then text=" ";
run;


data estimate_&var;
	merge lsmeans_&var(where=(&cvar=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(&cvar=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	num_&var(where=(&cvar=0) keep=&cvar day num_obs rename=(num_obs=n0))
	num_&var(where=(&cvar=1) keep=&cvar day num_obs rename=(num_obs=n1))
	diff; by day;
	if day=. or day=99 then delete;
	est1=put(estimate1,4.1)||"("||put(lower1,4.1)||", "||put(upper1,4.1)||"), "||compress(n1);
	est0=put(estimate0,4.1)||"("||put(lower0,4.1)||", "||put(upper0,4.1)||"), "||compress(n0);
	*keep day day1 est0 est1 diff probt pv;
run;


goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;


symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1 line=2;

axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (0 to 8 by 1) minor=none offset=(0 in, 0 in);

%if &cvar=pe %then %do;

legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
	value = (f=Century h=2.5 "Plasma Exchange" "Standard Therapy") offset=(0.2in, -0.2 in) frame;

%if &var=pelod0 %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score") value=(f=Century h=3) order= (0 to 40 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PELOD Score by Treatment and Days on Study";
%end;

%if &var=dbp %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score Change from Baseline") value=(f=Century h=3) order= (-15 to 10 by 2) offset=(.25 in, .25 in) minor=(number=1); 
	title1  h=3.5 justify=left f=centb "3";
	*title2 	height=3 f=Century "Delta Changes in PELOD Score by Treatment Groups";
%end;

%if &var=chg %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score Change from Baseline (%)") value=(f=Century h=3) order= (-100 to 360 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PELOD Score Change(%) from Baseline by Treatment and Days on Study";
%end;
%end;


%if &cvar=censor %then %do;
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
	value = (f=Century h=2.5 "Survivors" "Non-Survivors") offset=(0.2in, -0.2 in) frame;

%if &var=pelod0 %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score") value=(f=Century h=3) order= (0 to 40 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PELOD Score by Vital Status and Days on Study";
%end;

%if &var=dbp %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score Change from Baseline") value=(f=Century h=3) order= (-20 to 10 by 2) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PELOD Score Change from Baseline by Vital Status and Days on Study";
%end;

%if &var=chg %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score Change from Baseline (%)") value=(f=Century h=3) order= (-100 to 360 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "PELOD Score Change(%) from Baseline by Vital Status and Days on Study";
%end;
%end;

*title2 	height=3 f=Century "p value=&pv";
       
proc gplot data= estimate_&var(where=(day^=99)) gout=tamof.graphs;
%if &var^=pelod0 %then %do;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend vref=0 lvref=4;
%end;
%else %do;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
%end;
%if &cvar=pe %then %do;
	note h=3 m=(2pct, 15 pct) "Day :" ;
	note h=3 m=(-2pct, 11.5 pct) "(#Plasma Exchange)" ;
	note h=3 m=(-2pct, 8 pct) "(#Standard Therapy)" ;
	format estimate0 estimate1 4.0 day dd.; 
%end;

%if &cvar=censor %then %do;
	note h=3 m=(2pct, 15 pct) "Day :" ;
	note h=3 m=(-2pct, 11.5 pct) "(#Survivors)" ;
	note h=3 m=(-2pct, 8 pct) "(#Non-Survivors)" ;
	format estimate0 estimate1 4.0 day dd.; 
%end;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions rotate =portrait;

%let varlist=pelod0 chg dbp;
%mixed(mixed,pe,&varlist); run;

data est_pe_pelod;
	set estimate_pelod0(in=A) estimate_chg(in=B)  estimate_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if (B or C) and day=1 then do; est0="-"; est1="-"; pv="-"; diff="-"; end;
	format item item. ;

	if C;
run;
proc sort; by item; run;

proc print data=estimate_dbp;run;
/*
data est_censor_pelod;
	set estimate_censor_pelod0(in=A) estimate_censor_chg(in=B)  estimate_censor_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if (B or C) and day=1 then do; est0="-"; est1="-"; pv="-"; end;
	format item item. ;
	if item^=2;
run;
proc sort; by item; run;
*/

data p_pelod;
	set p_pe_pelod0(in=A) p_pe_chg(in=B) p_pe_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if A or B or C then gp=1;

	if C;

	format item item. gp group.;
run;
proc sort; by item; run;

/*
data p_pelod;
	set p_censor_pelod0(in=A) p_censor_chg(in=B) p_censor_dbp(in=C);
	if A then item=1;
	if B then item=2;
	if C then item=3;

	if A or B or C then gp=1;

	if C;

	format item item. gp group.;
	if item^=2;
run;
proc sort; by item; run;
*/
/*
proc mixed data=mixed7 empirical covtest; 
	class pe id day; 	
	model pelod7=pelod1 pe day/ solution ; 
	repeated / subject = id type = cs;
	lsmeans pe/diff=all cl;
		ods output lsmeans = lsmeans_pe;
		ods output diffs =   diff_pe;
run;

data trt1;
	length trt $20 effect $10;
	merge lsmeans_pe(keep=effect pe estimate stderr) diff_pe(keep=effect estimate lower upper probt rename=(estimate=diff)); by effect;
	col1=compress(put(estimate,4.1)||"&pm"||put(stderr,4.1));
	col2=compress(put(diff,4.1)||"("||put(lower,4.1)||"-"||put(upper, 4.1)||")");
	pv=put(probt,7.3); if probt<0.001 then pv="<0.001";
	effect="PELOD";
	if pe=1 then do; n=&ny; m=335; trt="PEx"; end; 
	if pe=0 then do; n=&no; m=129; trt="Standard"; col2=" ";  pv=" "; 	effect=" "; end;
run;
proc sort; by descending pe; run;

data trt;
	set trt1;
run;
*/


proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean PELOD scores and 95% confidence intervals by treatment group";
  title2 h=5pt "(Plasma Exchange=&ny vs. Standard Therapy=&no)";
run;

proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean PELOD scores and 95% confidence intervals by vital status";
  title2 h=5pt "(Survivors=&ns vs. Non-Survivors=&nd)";
run;

goptions reset=all ;

*ods listing close;
ods pdf file = "pelod_ple_cvvh_ecmo_peonly.pdf";
proc greplay nofs /*NOBYLINE*/;
igout tamof.graphs;
list igout;
tc template;
tdef t1 /*3 /llx=10    ulx=10   lrx=80   urx=80  lly=5    uly=35    lry=5      ury=35*/
        2 /llx=10    ulx=10   lrx=80   urx=80  lly=35   uly=65    lry=35     ury=65
        1 /llx=10    ulx=10   lrx=80   urx=80  lly=65   uly=95    lry=65     ury=95
		4 /llx=15    ulx=15   lrx=75   urx=75  lly=0  uly=99   lry=0   ury=99					
			;
template t1;
tplay 1:1 2:3 4:10;
run; quit;

options orientation=landscape ;

ods ps file="delta_pelod_all.ps" color=mono;
proc greplay igout = tamof.graphs tc=sashelp.templt template=whole nofs ; * L2R2s;
            list igout;
			treplay 1:3;
run;quit;
ods ps close;


ods rtf file="delta_pelod.rtf" style=journal bodytitle startpage=never;
proc report data=est_pe_pelod nowindows split="*";
title "Estimation of PELOD Score and 95%CI by Treatment and Days on Study";
where 1<=day<=7;
column day est0 est1 diff pv;
define item/order style=[just=left cellwidth=1.75in] "Item";
define day/style=[just=center cellwidth=1in] "Days on Study";
define est0/style=[just=center cellwidth=1.75in] "Standard Therapy* Mean(95%CI)";
define est1/style=[just=center cellwidth=1.75in] "Plasma Exchange*Mean(95%CI)";
define diff/style=[just=center cellwidth=1.75in] "Difference*Mean(95%CI)";
define pv/style=[just=center cellwidth=1in] "p value";
run;


/*
proc report data=est_pe_pelod nowindows split="*";
title "Estimation of PELOD Score and 95%CI by Vital Status and Days on Study";
where 1<=day<=7;
column item day est0 est1 diff pv;
define item/order style=[just=left cellwidth=1.75in] "Item";
define day/style=[just=left cellwidth=0.75in] "Day";
define est0/style=[just=center cellwidth=1.75in] "Non-Survivors* Mean[95%CI]";
define est1/style=[just=center cellwidth=1.75in] "Survivors*Mean[95%CI]";
define pv/style=[just=center cellwidth=1in] "p value";
run;
*/
ods rtf startpage=no ;


proc report data=p_pelod nowindows split="*";
title "P Values from Repeated Measurements Analysis";
column effect probF;
*define gp/order "";
define item/order style=[just=left cellwidth=1.75in] "Item";
define effect/style=[just=left cellwidth=3.5in] "Effect";
define probF/style=[just=center cellwidth=0.75in] "p value";
run;

ods rtf close;
