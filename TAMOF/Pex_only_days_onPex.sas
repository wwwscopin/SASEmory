options orientation=landscape nodate nonumber nofmterr;
ods listing;

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
	15 ="End of Study"
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

value item
	1="Estmated plasma volume used"
	2="Technique used";

value type
	1="Single Plasma volume"
	2="1.5 plasma volume"
	3="Double plasma volume"
	4="Unknown";

value tech
	1="Plasma exchange"
	2="Plasma filtration";

value group
	0="Non-Survivors"
	1="Censor"
	;

value censor
	0="Non-Survivors"
	1="Survivors"
	;
run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

proc contents data=TAMOF.ecmo_survival;run;
proc contents data=TAMOF.daily;run;
proc contents data=TAMOF.pex;run;
proc sort data=tamof.pex; by patientid;run;


data mixed;
	merge tamof.daily TAMOF.pex(drop=treatmentday)
	tamof.survival(keep=patientid censor plasmaexchange ecmo in=tmp); by patientid;
	if tmp;
	pw=PlasmaExchVol/weight;
	keep patientid  PelodTotalScore treatmentday censor platelets hemoglobin wbc paco2 pao2 weight 
		IsPEXToday PEXDevice PEXDeviceOther PEXNumber PEXTechnique PEXVolumeType PlasmaExchVol pw plasmaexchange ecmo;
	rename PelodTotalScore=pelod treatmentday=day patientid=id platelets=plt hemoglobin=hb paco2=pco pao2=pao
	platelets=plt hemoglobin=hb PlasmaExchVol=pexv plasmaexchange=pe;
	*if treatmentday<=7;
run;

proc print data=mixed;
var id day pelod;
run;

proc print data=tamof.daily;
var patientid treatmentday pelodtotalscore;
run;


proc sort data=mixed out=mixed_pe; by id pe censor; run;

proc transpose data=mixed_pe(where=(pe=1)) out=ple; 
by id pe censor;
var pexv;
run;

data ple;
	set ple;
	rename col1=day1 col2=day2 col3=day3 col4=day4 col5=day5 col6=day6 col7=day7 
			col8=day8 col9=day9 col10=day10 col11=day11 col12=day12 col13=day13 col14=day14;
	drop _name_;

	nday=n(of col1-col14);
run;

proc sort data=ple; by pe censor id; run;

ods rtf file="pex_vol.rtf" style=journal bodytitle;
proc print noobs ;
title "Data listing for Plasma Exchange Volume";
by pe censor;
id pe censor;
var id day1-day14 nday;
format day1-day14 5.0 pe yn. censor censor.;
run;
ods rtf close;

proc sort data=ple; by id;run;

data mixed;
	merge mixed ple(keep=id nday); by id;
	if nday=. then nday=0;
	/*
	if pw=. then pw=0;
	if pexv=. then pexv=0;
	*/
run;
/*
proc freq data=mixed(where=(pelod^=.));
	tables (pe censor)*day;
run;

data tamof.wbh2;
	set mixed;
run;
proc sort data=tamof.wbh1; by id day;run;
proc sort data=tamof.wbh2; by id day;run;

data test;
	merge tamof.wbh1(keep=id day pe censor pelod0 rename=(pe=pe0 censor=censor0) in=A) tamof.wbh2(keep=id day pe censor pelod in=B); by id day; 
	if not (A and B);
run;


proc print;
var id day pe0 censor0 pelod0 pe censor pelod;
run;
*/

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
		where 1<=day<=7 and pe=1;
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

proc mixed data =tmp empirical covtest; 
	class &cvar id day ; 	
	model &var=&cvar day &cvar*day nday /*pw pexv*/ / solution ; 
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
	%end;
	%if &cvar=censor %then %do;
	if effect="censor" then do; effect="Vital Status"; call symput("pv", put(probf,7.3)); end;
		if effect="day" then effect="Treatment Day";
			if effect="censor*day" then effect="Interaction between Vital Status and Treatment Day";
	%end;
run;

data lsmeans_&var;
	set lsmeans_&i;

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

axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (0 to 8 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(f=Century h=3 a=90 "PELOD Score") value=(f=Century h=3) order= (0 to 36 by 2) offset=(.25 in, .25 in) minor=(number=1); 
title1 	height=3.5 f=Century "PELOD Score vs Days on Study";

%if &cvar=pe %then %do;
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Plasma Exchange" "Standard Therapy") offset=(-0.2in, -0.2 in) frame;
%end;

%if &cvar=censor %then %do;
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Survivors" "Non-Survivors") offset=(-0.2in, -0.2 in) frame;
%end;
     
proc gplot data= estimate_&var(where=(day^=99)) gout=tamof.graphs;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend vref=0 lvref=4;
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

%let varlist=pelod;
/*%mixed(mixed,pe,&varlist); run;*/
%mixed(mixed,censor,&varlist); run;

options orientation=portrait nodate nonumber nofmterr;

/*
goptions hsize=0in vsize=0in;
proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean PELOD scores and 95% confidence intervals by treatment group";
  title2 h=5pt "(Plasma Exchange=&ny vs. Standard Therapy=&no)";
run;
*/
goptions hsize=0in vsize=0in;
proc gslide gout=tamof.graphs;
  title1 height=7pt f=Century "Estimates of mean PELOD scores and 95% confidence intervals by vital status";
  title2 h=5pt "(Survivors=&ns vs. Non-Survivors=&nd)";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

goptions reset=all border;
ods listing close;
ods pdf file = "pelod_adjust_by_days_on_pex.pdf" style=journal;
proc greplay igout=tamof.graphs tc=sashelp.templt template=v2s nofs;
list igout;
treplay 1:1 ; 
run; quit;
ods pdf close;
