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

value ecmo
	0="no ECMO"
	1="ECMO"
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
	merge tamof.daily TAMOF.pex
	tamof.survival(keep=patientid censor plasmaexchange ecmo  in=tmp); by patientid;
	if tmp;
	pw=PlasmaExchVol/weight;
	keep patientid  PelodTotalScore treatmentday censor platelets hemoglobin wbc paco2 pao2 weight  totalintake
		IsPEXToday PEXDevice PEXDeviceOther PEXNumber PEXTechnique PEXVolumeType PlasmaExchVol pw ecmo_pex
		 totaloutput  UrineOutput plasmaexchange ecmo;
	rename PelodTotalScore=pelod treatmentday=day patientid=id platelets=plt hemoglobin=hb paco2=pco pao2=pao
	platelets=plt hemoglobin=hb;
	if plasmaexchange=1 and ecmo=0;
run;

proc sort; by id plasmaexchange ecmo censor; run;

proc transpose data=mixed out=intake; 
by id plasmaexchange ecmo censor;
var totalintake;
run;

data intake;
	set intake;
	rename col1=day1 col2=day2 col3=day3 col4=day4 col5=day5 col6=day6 col7=day7 
			col8=day8 col9=day9 col10=day10 col11=day11 col12=day12 col13=day13 col14=day14;
	drop _name_;
run;
proc sort; by plasmaexchange ecmo censor id; run;

ods rtf file="ple_noECMO_intake.rtf" style=journal bodytitle;
proc print noobs ;
title "Data listing for Total Daily Intake (mL)";
by plasmaexchange ecmo censor;
id plasmaexchange ecmo censor;
var id day1-day14;
format day1-day14 5.0 plasmaexchange ecmo yn. censor censor.;
run;
ods rtf close;

options orientation=landscape nodate nonumber nofmterr;


proc sort data=mixed nodupkey out=mixed_id; by id;run;

proc means data=mixed_id;
	class censor;
	var id;
	output out=mixed_num n(id)=n;
run;

data _null_;
	set mixed_num;
	if censor=0 then call symput("nd",compress(n));
	if censor=1 then call symput("ns",compress(n));
run;

%let nt=%eval(&nd+&ns);

%macro getn(data);
%do j = 1 %to 14;
data _null_;
    set &data;
    where day = &j;
    if censor=0 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if censor=1 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let mu=%sysfunc(byte(181));
%put &mu;


%macro mixed(data, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );


	proc means data=&data noprint;
    	class censor day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13=0; %let m14= 0;
%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13=0; %let n14= 0;  

%getn(num_&var);

proc format;
value dd   -1=" " 0 = " "  1="1*(&n1)*(&m1)"  2 = "2*(&n2)*(&m2)" 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5="5*(&n5)*(&m5)" 6 = "6*(&n6)*(&m6)" 7="7*(&n7)*(&m7)" 8 = "8*(&n8)*(&m8)" 9="9*(&n9)*(&m9)"  
		10 = "10*(&n10)*(&m10)" 11="11*(&n11)*(&m11)" 12 = "12*(&n12)*(&m12)" 
		13="13*(&n13)*(&m13)" 14 = "14*(&n14)*(&m14)" 15 = " " ;;
run;

/*
proc mixed data =&data(where=(censor=0)) empirical covtest;
	class id day ; * &source;	
	model &var= censor day / solution ; * &source	day*&source/ solution;
	repeated day / subject = id type = cs;
	lsmeans day / cl ;
	ods output lsmeans = lsmeans0;
run;

proc mixed data = &data(where=(censor=1)) empirical covtest;
	class id day ; * &source;	
	model &var = censor day / solution ; * &source	day*&source/ solution;
	repeated day / subject = id type = cs;
	lsmeans day / cl ;
	ods output lsmeans = lsmeans1;
run;

data lsmeans_&var;
	set lsmeans0(in=A) lsmeans1(in=B);
	if A then censor=0; 
	if B then censor=1;
	if lower<0 then lower=0;
	day1=day+0.1;
run;

proc sort; by day;run;

DATA anno0; 
	set lsmeans_&var(where=(censor=0));
	xsys='2'; ysys='2';  color='blue';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(censor=1));
	xsys='2'; ysys='2';  color='red';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno0 anno1;
run;

data estimate_&var;
	merge lsmeans_&var(where=(censor=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(censor=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;
*/

proc means data=&data noprint median;
   	class censor day;
   	var &var;
	output out = num_&var median(&var) = med;
run;

data estimate_&var;
	merge num_&var(where=(censor=0) rename=(med=estimate0)) 
	num_&var(where=(censor=1) rename=(med=estimate1)); by day;
	day1=day+0.1;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=zapf  hby = 3;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=3 width=1;
symbol2 i=j ci=red value=dot co=red cv=red h=3 w=1;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=3 "Non-Survivors" "Survivors") offset=(0.2in, -0.4 in) frame;


axis1 	label=(f=zapf h=2.5 "Days of Treatment" ) split="*"	value=(f=zapf h=2)  order= (0 to 15 by 1) minor=none offset=(0 in, 0 in);

%if &var=totalintake %then %do;
axis2  label=(f=zapf h=2.5 a=90 "Total Daily Intake (mL)") value=(f=zapf h=2) order= (0 to 7000 by 500) offset=(.25 in, .25 in) minor=(number=1); 
title1 height=3 f=zapf "Median Total Daily Intake vs Days of Treatment";
title2 height=2.5 f=zapf "for &nt Children with TAMOF treated with Plasma Exchange but did not receive ECMO (Survivors=&ns, Non-Survivors=&nd)";
legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=3 "Non-Survivors" "Survivors") offset=(1in, -0.4 in) frame;
%end;

%if &var=totaloutput %then %do;
axis2  label=(f=zapf h=2.5 a=90 "Total Daily Output (mL)") value=(f=zapf h=2) order= (0 to 7000 by 500) offset=(.25 in, .25 in) minor=(number=1); 
title1 height=3 f=zapf "Median Total Daily Output vs Days of Treatment";
title2 height=2.5 f=zapf "for &nt Children with TAMOF treated with Plasma Exchange but did not receive ECMO (Survivors=&ns, Non-Survivors=&nd)";
%end;

%if &var=UrineOutput %then %do;
axis2  label=(f=zapf h=2.5 a=90 "Daily Urine Output (mL)") value=(f=zapf h=2) order= (0 to 1600 by 200) offset=(.25 in, .25 in) minor=(number=1); 
title1 height=3 f=zapf "Median Daily Urine Output vs Days of Treatment";
title2 height=2.5 f=zapf "for &nt Children with TAMOF treated with Plasma Exchange but did not receive ECMO (Survivors=&ns, Non-Survivors=&nd)";
%end;
               
proc gplot data= estimate_&var gout=tamof.graphs;
	plot estimate0*day estimate1*day1/overlay haxis = axis1 vaxis = axis2 legend=legend;
	note h=2 m=(5pct, 12pct) "Day :" ;
	note h=2 m=(3pct, 9.5 pct) "(#Survivors)" ;
	note h=2 m=(1pct, 7.0 pct) "(#Non-Survivors)" ;
	format estimate0 estimate1 5.0 day dd.;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions rotate = portrait;
%let varlist=totalintake  totaloutput  UrineOutput;
	%mixed(mixed,&varlist); run;

options orientation=portrait;
goptions reset=all;
ods pdf file = "ple_noecmo_intake.pdf" style=journal;
proc greplay igout = tamof.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
	treplay 1:1 2:2;
run;
proc greplay igout = tamof.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
	treplay 1:3;
run;
ods pdf close;
