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

run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

proc contents data=TAMOF.ecmo_survival;run;
proc contents data=TAMOF.daily;run;
proc contents data=TAMOF.pex;run;
proc sort data=tamof.pex; by patientid;run;

data mixed;
	merge tamof.daily TAMOF.pex
	tamof.survival(keep=patientid censor plasmaexchange ecmo where=(plasmaexchange=1 and ecmo=0) in=tmp); by patientid;
	if tmp;
	pw=PlasmaExchVol/weight;
	keep patientid  PelodTotalScore treatmentday censor platelets hemoglobin wbc paco2 pao2 weight 
		IsPEXToday PEXDevice PEXDeviceOther PEXNumber PEXTechnique PEXVolumeType PlasmaExchVol pw;
	rename PelodTotalScore=pelod treatmentday=day patientid=id platelets=plt hemoglobin=hb paco2=pco pao2=pao
	platelets=plt hemoglobin=hb;
	*if treatmentday<=7;
run;
proc univariate data=mixed;
class day;
var pw;
histogram pw/normal; 
run;

proc freq data=mixed;
	tables  day*IsPEXToday;
	ods output  Freq.Table1.CrossTabFreqs=pe_today;
run;

proc sort data=pe_today; by day; run;
proc transpose data=pe_today out=pex0; var frequency; by day; run;

data pex;
	set pex0(rename=(col1=n0 col2=n1 col3=n));
	where day^=.;
	f0=n0/n*100;
	f1=n1/n*100;
	nf0=compress(n0||"/"||n||"("||put(f0, 4.0)||"%)");
	nf1=compress(n1||"/"||n||"("||put(f1, 4.0)||"%)");
	keep day nf0 nf1;
run;

proc sort data=mixed; by censor; run;
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
value dd   -1=" " 0 = " "  1="1*(&n1|&m1)"  2 = "2*(&n2|&m2)" 3="3*(&n3|&m3)" 4 = "4*(&n4|&m4)" 
		5="5*(&n5|&m5)" 6 = "6*(&n6|&m6)" 7="7*(&n7|&m7)" 8 = "8*(&n8|&m8)" 9="9*(&n9|&m9)"  
		10 = "10*(&n10|&m10)" 11="11*(&n11|&m11)" 12 = "12*(&n12|&m12)" 
		13="13*(&n13|&m13)" 14 = "14*(&n14|&m14)" 15 = " " ;;
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

legend across = 1 position=(top center inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=3 "Non-Survivors" "Survivors") offset=(0.2in, -0.4 in) frame;


axis1 	label=(f=zapf h=2.5 "Days of Treatment" ) split="*"	value=(f=zapf h=2)  order= (0 to 15 by 1) minor=none offset=(0 in, 0 in);

%if &var=pw %then %do;
	axis2  label=(f=zapf h=2.5 a=90 "Plasma Volume Replaced(ml/kg)") value=(f=zapf h=2) order= (30 to 80 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1 height=3 f=zapf "Median Plasma Volume Replaced vs Days of Treatment";
	title2 height=3 "for &nt Children with TAMOF treated with Plasma Exchange but did not receive ECMO (Survivors=&ns, Non-Survivors=&nd)";
%end;
               
proc gplot data= estimate_&var gout=tamof.graphs;
	plot estimate0*day estimate1*day1/overlay haxis = axis1 vaxis = axis2 legend=legend;
	note h=2 m=(0pct, 10pct) "Day :" ;
	note h=2 m=(-10pct, 7.5 pct) "(#Survivors|#Non-Survivors)" ;
	format estimate0 estimate1 4.0 day dd.;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions rotate = portrait;
%let varlist=pw;
	%mixed(mixed,&varlist); run;

*ods trace on/label listing;
proc freq data=mixed; 
	by censor;
	tables 	day*(PEXVolumeType PEXTechnique);
	ods output  Freq.ByGroup1.Table1.CrossTabFreqs=type0;
	ods output  Freq.ByGroup1.Table2.CrossTabFreqs=tech0;
	ods output  Freq.ByGroup2.Table1.CrossTabFreqs=type1;
	ods output  Freq.ByGroup2.Table2.CrossTabFreqs=tech1;
run;
*ods trace off;
proc sort data=type0; by day; run;
proc sort data=tech0; by day; run;
proc sort data=type1; by day; run;
proc sort data=tech1; by day; run;

proc transpose data=type0 out=typeA; var frequency;	by day; run;
proc transpose data=tech0 out=techA; var frequency;	by day; run;
proc transpose data=type1 out=typeB; var frequency;	by day; run;
proc transpose data=tech1 out=techB; var frequency;	by day; run;

data ttA;
	merge typeA(in=a rename=(col1=nA1 col2=nA2 col3=nA3 col4=nA)) techA(in=b rename=(col1=mA1 col2=mA2 col3=mA)); by day;
	fa1=na1/nA*100; fa2=na2/nA*100; fa3=na3/nA*100; ga1=ma1/mA*100; ga2=ma2/mA*100; 
	ta1=na1||"/"||compress(nA)||"("||compress(put(fa1,4.0))||"%)";
	ta2=na2||"/"||compress(nA)||"("||compress(put(fa2,4.0))||"%)";
	ta3=na3||"/"||compress(nA)||"("||compress(put(fa3,4.0))||"%)";
	sa1=ma1||"/"||compress(mA)||"("||compress(put(ga1,4.0))||"%)";
	sa2=ma2||"/"||compress(mA)||"("||compress(put(ga2,4.0))||"%)";
	if na=0 and na1=0 then ta1="--";
	if na=0 and na2=0 then ta2="--";
	if na=0 and na3=0 then ta3="--";
	if ma=0 and ma1=0 then sa1="--";
	if ma=0 and ma2=0 then sa2="--";
	keep day nA1-nA3 nA mA1-mA2 mA ta1 ta2 ta3 sa1 sa2;
run;

data ttB;
	merge typeB(in=a rename=(col1=nB1 col2=nB2 col3=nB3 col4=nB4 col5=nB)) techB(in=b rename=(col1=mB1 col2=mB2 col3=mB)); by day;
	fb1=nb1/nb*100; fb2=nb2/nb*100; fb3=nb3/nb*100; fb4=nb4/nb*100; gb1=mb1/mb*100; gb2=mb2/mb*100; 

	tb1=nb1||"/"||compress(nb)||"("||compress(put(fb1,4.0))||"%)";
	tb2=nb2||"/"||compress(nb)||"("||compress(put(fb2,4.0))||"%)";
	tb3=nb3||"/"||compress(nb)||"("||compress(put(fb3,4.0))||"%)";
	tb4=nb4||"/"||compress(nb)||"("||compress(put(fb4,4.0))||"%)";
	sb1=mb1||"/"||compress(mb)||"("||compress(put(gb1,4.0))||"%)";
	sb2=mb2||"/"||compress(mb)||"("||compress(put(gb2,4.0))||"%)";

	if nb=0 and nb1=0 then tb1="--";
	if nb=0 and nb2=0 then tb2="--";
	if nb=0 and nb3=0 then tb3="--";
	if nb=0 and nb4=0 then tb4="--";
	if mb=0 and mb1=0 then sb1="--";
	if mb=0 and mb2=0 then sb2="--";

	keep day nb1-nb4 nb mb1-mb2 mb tb1 tb2 tb3 tb4 sb1 sb2;
run;

data tt; 
	merge ttA(in=A) ttB(in=B); by day;
	if day=. then delete;
run;
options orientation=landscape;
ods pdf file = "ple_noECMO_pw.pdf" style=journal ;
/*
proc print data=pex noobs label split="*";
title "Did the patient receive a plasma exchange today?";
Var day/style(data)=[cellwidth=1.5in just=left] style(header)=[ just=left]; 
var nf0 nf1/style(data)=[cellwidth=1.5in just=center] style(header)=[ just=center]; 
label  day="Treatment Day"
		nf0="No*#Pat/n(%)"
		nf1="Yes*#Pat/n(%)"
	  ;
run;
*/
proc greplay igout = tamof.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;

proc report data=tt nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title1 "Plasma Volume vs Days of Treatment for &nt Children with TAMOF treated with Plasma Exchange but did not receive ECMO";
title2 "(Survivors=&ns, Non-Survivors=&nd)";

column day ("-------------------Non-Survivors---------------" ("----Estimated plasma volume used---" ta1-ta3) 
("---Techniques used---" sa1-sa2))   ("------------------------Survivors----------------------------" 
("----------------Estimated plasma volume used----------------" tb1-tb4)
("--------Techniques used-------" sb1-sb2));

define day/"Day" style(column)=[just=left] style(header)=[just=left];
define ta1/"Single plasma volume" style(column)=[just=left];
define ta2/"1.5 plasma volume" style(column)=[cellwidth=0.75in just=center];
define ta3/"Double plasma volume" style(column)=[cellwidth=0.75in just=center];
define sa1/"Plasma exchange" style(column)=[cellwidth=0.75in just=center];
define sa2/"Plasma filtration" style(column)=[cellwidth=0.75in just=center];

define tb1/"Single plasma volume" style(column)=[cellwidth=1in just=left];
define tb2/"1.5 plasma volume" style(column)=[cellwidth=1in just=center];
define tb3/"Double plasma volume" style(column)=[cellwidth=0.75in just=center];
define tb4/"Unknown" style(column)=[cellwidth=0.75in just=center];
define sb1/"Plasma exchange" style(column)=[cellwidth=1in just=center];
define sb2/"Plasma filtration" style(column)=[cellwidth=1in just=center];

*break after day/ dol dul skip;
run;
ods pdf close;
