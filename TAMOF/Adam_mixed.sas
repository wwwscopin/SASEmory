options orientation=portrait nodate nonumber nofmterr;
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

value pdd
	2= "Patient improvement / Treatment goal met"
	3= "Death"
	9= "No Answer"
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
run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

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
	 		tamof.survival(keep=patientid ptDiscontDay28Yes PlasmaExchange censor fullcensor in=C rename=(ptDiscontDay28Yes=pdd)); by patientid;
	*if patientid= 111002 and day=3 then day=4;
	if day in(2,3,4,5) then day=4;
	if day in(7,8,9) then day=8;
	if day in(21,25,28) the day=28;
	if pdd=. then pdd=9;
	if patientid=111001 then pdd=3;
	if B and day^=.;
run;

proc sort data=lab out=tmp nodupkey; by patientid;run;

proc means data=tmp n;
class pdd; 
var patientid;
output out=wbh n(patientid)=n;
run;

data _null_;
	set wbh;
	if pdd=2 then call symput("num2", compress(n));
	if pdd=3 then call symput("num3", compress(n));
	if pdd=9 then call symput("num9", compress(n));
run;


data mixed; 
	merge pelod lab; by patientid day;
	rename PelodTotalScore=pelod patientid=id platelets=plt PlasmaExchange=pe;
	if patientid=110002 then censor=1;
	format pdd pdd.;
run;

proc contents data=mixed;run;
/*
ods listing;
proc sort data=mixed(where=(adamts13^=.)) nodupkey out=mixed_id; by id; run;
data temp;
	set mixed(where=(adamts13^=.));
run;

proc print data=temp;
var id pe censor day adamts13;
run;

proc means data=mixed_id; 
class pe;
var id;
run;
*/

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

*adamts13  vwf_ag  vwf_rca;
proc means data=mixed_id(where=(adamts13^=.));
	class pe;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if pe=0 then call symput("noa",compress(n));
	if pe=1 then call symput("nya",compress(n));
run; 
%put &noa;

*adamts13  vwf_ag  vwf_rca;
proc means data=mixed_id(where=(vwf_ag^=.));
	class pe;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if pe=0 then call symput("nov",compress(n));
	if pe=1 then call symput("nyv",compress(n));
run; 

proc means data=mixed_id(where=(vwf_rca^=.));
	class pe;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if pe=0 then call symput("nor",compress(n));
	if pe=1 then call symput("nyr",compress(n));
run; 

%macro getn(data);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;
    if pdd=2 then call symput( "n&j",  compress(put(num_obs, 3.0)));
	if pdd=3 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if pdd=9 then call symput( "k&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let mu=%sysfunc(byte(181));
%put &mu;

%macro mixed(data, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
		*where id^=101015;
	run;

	proc sort data=tmp nodupkey out=mixed_day; by pdd day id;run;
	proc means data=mixed_day noprint;
    	class pdd day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13= 0; %let m14= 0;   
%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13= 0; %let n14= 0; 
%let k1= 0; %let k2= 0; %let k3= 0; %let k4= 0; %let k5= 0; %let k6=0; %let k7= 0;  %let k0=0;
%let k8= 0; %let k9= 0; %let k10= 0; %let k11= 0; %let k12= 0; %let k13= 0; %let k14= 0; 



%let m15= 0; %let m16= 0; %let m17= 0; %let m18= 0; %let m19= 0; %let m20=0; %let m21= 0;  
%let m22= 0; %let m23= 0; %let m24= 0; %let m25= 0; %let m26= 0; %let m27= 0; %let m28= 0;   
%let n15= 0; %let n16= 0; %let n17= 0; %let n18= 0; %let n19= 0; %let n20=0; %let n21= 0;  
%let n22= 0; %let n23= 0; %let n24= 0; %let n25= 0; %let n26= 0; %let n27= 0; %let n28= 0; 
%let k15= 0; %let k16= 0; %let k17= 0; %let k18= 0; %let k19= 0; %let k20=0; %let k21= 0;  
%let k22= 0; %let k23= 0; %let k24= 0; %let k25= 0; %let k26= 0; %let k27= 0; %let k28= 0; 

%getn(num_&var);

proc format;
value dd   0 = " "  1="1*(&n1)*(&m1)"  2 = "2*(&n2)*(&m2)" 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5="5*(&n5)*(&m5)" 6 = "6*(&n6)*(&m6)" 7="7*(&n7)*(&m7)" 8 = " " ;

value tt  -1=" " 0 = "0*(&n0)*(&m0)*(&k0)"  1="1*(&n1)*(&m1)*(&k1)"  2 = " " 3="3*(&n3)*(&m3)*(&k3)" 4 = "4*(&n4)*(&m4)*(&k4)" 
		5=" " 6 = " " 7=" " 8 = "8*(&n8)*(&m8)*(&k8)" 9=" " 
		10 = " " 11=" " 12 = " )" 13=" " 	14 = " " 15="15*(&n15)*(&m15)*(&k15)"  16=" "  17 = " " 
		18=" " 19= " "   20=" " 21 = " "    22=" " 23 = " "  24 = " " 25=" " 
		26 = " " 27=" "  28="28*(&n28)*(&m28)*(&k28)" 40=" ";
run;

proc mixed data =tmp empirical covtest;
	class pdd id day ; 	
	model &var= pdd day pdd*day/ solution ; 
	repeated day / subject = id type = cs;
	lsmeans pdd*day pdd/ cl ;

	estimate "line trend0" day -5 -3 3 5 -1 1 	pdd*day -5 -3 3 5 -1 1 0 0 0 0 0 0 0 0 0 0 0 0/e;
	estimate "line trend1" day -5 -3 3 5 -1 1 	pdd*day 0 0 0 0 0 0 -5 -3 3 5 -1 1 0 0 0 0 0 0/e;
	estimate "line trend2" day -5 -3 3 5 -1 1 	pdd*day 0 0 0 0 0 0 0 0 0 0 0 0 -5 -3 3 5 -1 1/e;

	ods output lsmeans = lsmeans_&i;
		ods output   Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="pdd" then effect="PDD";
		if effect="day" then effect="Treatment Day";
			if effect="pdd*day" then effect="Interaction between PDD and Treatment Day";
run;

data lsmeans_&var;
	set lsmeans_&i;
	if lower^=. and lower<0 then lower=0;
	/*%if &var=adamts13 %then %do; if A then do; lower=estimate; upper=estimate; end; %end;*/
	day1=day+0.20;
	if day=8 then day1=day+0.5;
	if day>8 then day1=day+1;

	day2=day-0.20;
	if day=8 then day2=day-0.5;
	if day>8 then day2=day-1;

	if effect='pdd' then day=99;
run;

proc sort; by pdd day;run;

DATA anno3; 
	set lsmeans_&var(where=(pdd=3 and day^=99));
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

DATA anno9; 
	set lsmeans_&var(where=(pdd=9 and day^=99));
	xsys='2'; ysys='2';  color='grey';
	X=day2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if day<15  then do;
    	X=day2-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day2+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else do;
    	X=day2-0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day2+0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;

  	X=day2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno2; 
	set lsmeans_&var(where=(pdd=2 and day^=99));
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
	length color $10;
	set anno2 anno3 anno9;
run;

data estimate_&var;
	merge lsmeans_&var(where=(pdd=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) 
	lsmeans_&var(where=(pdd=3) rename=(estimate=estimate3 lower=lower3 upper=upper3)) 
	lsmeans_&var(where=(pdd=9) rename=(estimate=estimate9 lower=lower9 upper=upper9)) ; by day;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;
symbol3 i=j ci=grey value=square co=grey cv=grey h=4 w=1;

axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (0 to 8 by 1) minor=none offset=(0 in, 0 in);
legend2 across = 1 position=(bottom right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Improvement" "Death" "No Answer") offset=(-0.2in, 0.2 in) frame;

legend1 across = 1 position=(bottom right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Improvement (n=&num2)" "Death (n=&num3)" "No Answer (n=&num9)") offset=(-0.2in, 0.2 in) frame;


%if &var=adamts13 %then %do;
	axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (-1 0 1 4 8 15 28 40) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=Century h=3 a=90 "ADAMTS-13 Activity (%)") value=(f=Century h=3) order= (0 to 120 by 10) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "ADAMTS-13 Activity vs Days on Study";

	%if &data=mixed %then %do; title2  height=2.5 f=century "TAMOF Children (n=56)"; %end;
	%if &data=mixed_nope %then %do; title2  height=2.5 f=century "TAMOF Children without PEx (n=14)"; %end;
	%if &data=mixed_pe %then %do; title2  height=2.5 f=century "TAMOF Children with PEx (n=42)"; %end;
%end;
         
proc gplot data= estimate_&var(where=(day^=99)) gout=tamof.graphs;
	%if &data=mixed %then %do;
	plot estimate2*day estimate3*day1 estimate9*day2/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend1;
	%end;
	%else %do;
	plot estimate2*day estimate3*day1 estimate9*day2/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend2;
	%end;

	note h=3 m=(5pct, 18.5 pct) "Day :" ;
	note h=3 m=(5pct, 15 pct) "(#Improvement)" ;
	note h=3 m=(5pct, 11.5 pct) "(#Death)" ;
	note h=3 m=(5pct, 8 pct) "(#No Answer)" ;
	format estimate2 estimate3 estimate9 4.0 day tt.; 
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions reset=all rotate = portrait;

%let varlist=adamts13;
%mixed(mixed,&varlist); run;
data mixed_nope;set mixed(where=(pe=0)); run;
data mixed_pe;set mixed(where=(pe=1)); run;
%mixed(mixed_nope,&varlist); run;
%mixed(mixed_pe,&varlist); run;


goptions hsize=0in vsize=0in;
proc gslide gout=tamof.graphs;
  title height=8pt f=Century "TAMOF Children (Plasma Exchange=&ny vs. no Plasma Exchange=&no)";
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

goptions reset=all border;
ods listing close;
ods pdf file = "adamt.pdf" style=journal;
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
tplay 1:1 2:3 3:5 ;
run; quit;
ods pdf close;
