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
	99="Overall"
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

data plt;
	merge   tamof.daily(keep=patientid treatmentday PelodTotalScore platelets rename=(treatmentday=day) in=A)
			tamof.survival(where=(plasmaexchange=1) keep=patientid plasmaexchange censor in=B); by patientid;
			pelod0=PelodTotalScore;
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
			tamof.survival(where=(PlasmaExchange=1) keep=patientid censor PlasmaExchange in=B)	
			; by patientid;
	if day in(2,3,4,5) then day=4;
	if day in(7,8,9) then day=8;
	if day in(21,25,28) then day=28;
run;

data mixed; 
	merge pelod lab;
	by patientid day;
	rename PelodTotalScore=pelod patientid=id platelets=plt;
	site=floor((patientid-100000)/1000);
run;

proc means data=mixed(where=(day=1));
class site;
var pelod;
run;

proc sort  data=tamof.ecmo_survival nodupkey out=wbh; by patientid;run;

proc means data=mixed;
class censor day;
var pelod plt adamts13  vwf_ag  vwf_rca;
run;

proc sort data=mixed(where=(censor^=.)) nodupkey out=mixed_id; by id; run;

proc means data=mixed_id;
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("nd",compress(n));
	if censor=1 then call symput("ns",compress(n));
run;

*adamts13  vwf_ag  vwf_rca;
proc sort data=mixed(where=(adamts13^=.)) nodupkey out=mixed_id; by id; run;
proc means data=mixed_id;
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("noa",compress(n));
	if censor=1 then call symput("nya",compress(n));
run; 
%put &noa;

*adamts13  vwf_ag  vwf_rca;
proc sort data=mixed(where=(vwf_ag^=.)) nodupkey out=mixed_id; by id; run;
proc means data=mixed_id(where=(vwf_ag^=.));
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("nov",compress(n));
	if censor=1 then call symput("nyv",compress(n));
run; 

proc sort data=mixed(where=(vwf_rca^=.)) nodupkey out=mixed_id; by id; run;
proc means data=mixed_id(where=(vwf_rca^=.));
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("nor",compress(n));
	if censor=1 then call symput("nyr",compress(n));
run; 


%macro getn(data);
%do j = 0 %to 28;
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


%macro line(data, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
	data tmp;
		set &data;
		%if &var=pelod %then %do; where day<=7; %end;
	run;

	proc sort data=tmp nodupkey out=mixed_day; by censor day id;run;
	proc means data=mixed_day noprint;
    	class censor day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0;   
%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; 
%getn(num_&var);

proc format;
value dd   0 = " "  1="1*(&n1|&m1)"  2 = "2*(&n2|&m2)" 3="3*(&n3|&m3)" 4 = "4*(&n4|&m4)" 
		5="5*(&n5|&m5)" 6 = "6*(&n6|&m6)" 7="7*(&n7|&m7)" 8 = " ";
run;


proc mixed method=ml data=tmp covtest;
	class id censor;
	model &var=censor day censor*day/s;
	random int day/type=un subject=id;
	estimate "Non-Survivor, slope" day 1 censor*day 1 0;
	estimate "Survivor, slope" day 1 censor*day 0 1;
	estimate "Compare slopes" censor*day 1 -1;

	estimate "Survivor, intercept" int 1 censor 0 1/cl;
	estimate "Survivor, Day1"  int 1 censor 0 1 day 1  day*censor 0 1 ;
	estimate "Survivor, Day2"  int 1 censor 0 1 day 2  day*censor 0 2 ;
	estimate "Survivor, Day3"  int 1 censor 0 1 day 3  day*censor 0 3 ;
	estimate "Survivor, Day4"  int 1 censor 0 1 day 4  day*censor 0 4 ;
	estimate "Survivor, Day5"  int 1 censor 0 1 day 5  day*censor 0 5 ;
	estimate "Survivor, Day6"  int 1 censor 0 1 day 6  day*censor 0 6 ;
	estimate "Survivor, Day7"  int 1 censor 0 1 day 7  day*censor 0 7 /e;

	estimate "Non-Survivor, intercept" int 1 censor 1 0/cl;
	estimate "Non-Survivor, Day1"  int 1 censor 1 0 day 1  day*censor 1  0;
	estimate "Non-Survivor, Day2"  int 1 censor 1 0 day 2  day*censor 2  0;
	estimate "Non-Survivor, Day3"  int 1 censor 1 0 day 3  day*censor 3  0;
	estimate "Non-Survivor, Day4"  int 1 censor 1 0 day 4  day*censor 4  0;
	estimate "Non-Survivor, Day5"  int 1 censor 1 0 day 5  day*censor 5  0;
	estimate "Non-Survivor, Day6"  int 1 censor 1 0 day 6  day*censor 6  0;
	estimate "Non-Survivor, Day7"  int 1 censor 1 0 day 7  day*censor 7  0/e;


	ods output Mixed.Estimates=estimate_&var.0;
run;

data _null_;
	set estimate_&var.0(firstobs=1 obs=3);
	if _n_=1 then call symput("d", put(estimate,4.1)||"("||compress(put(stderr,4.1))||")");
	if _n_=2 then call symput("s", put(estimate,4.1)||"("||compress(put(stderr,4.1))||")");
	if _n_=3 then call symput("p", put(Probt,4.2));
run;


data estimate;
	set estimate_&var.0(firstobs=4);
	if find(label,"Non-Survivor") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= substr(compress(scan(label,2,",")),4,2)+0;
	day1=day+0.1;
	keep group day day1 estimate upper lower;
	if 0<day<=7;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
run;


DATA anno0; 
	set estimate;
	where group=0;
	xsys='2'; ysys='2';  color='red ';
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

DATA anno1; 
	set estimate;
	where group=1;
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

data anno_&var;
	set anno0 anno1;
run;

data estimate_&var;
	merge estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=2;
symbol2 i=j ci=red value=dot co=red cv=red h=2 w=2;

axis1 	label=(f=Century h=2.5 "Days on Study" ) split="*"	value=(f=Century h=2)  order= (0 to 8 by 1) minor=none offset=(0 in, 0 in);

%if &var=pelod %then %do;
	axis2 	label=(f=Century h=2.5 a=90 "PELOD Score") value=(f=Century h=2) order= (0 to 80 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title 	height=3 f=Century "PELOD Score Rate of Decline vs Days on Study (Survivors=&ns, Non-Survivors=&nd)";
	legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
	value = (f=Century h=3 "Non-Survivor, Slope(SE)=&d" "Survivor, Slope(SE)=&s") offset=(0.2in, -0.4 in) frame;
%end;
               
proc gplot data= estimate_&var gout=tamof.graphs;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
	note h=2 m=(5pct, 9.5 pct) "Day :" ;
	note h=2 m=(-3pct, 7.0 pct) "(#Survivor|#Non-Survivor)" ;
	format estimate0 estimate1 4.0 day dd.;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend line;


%macro mixed(data, varlist)/minoperator;


%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
		%if &var=pelod0 or &var=pelod or &var=plt %then %do; where 0<day<=7; %end;
	run;

	proc sort data=tmp nodupkey out=mixed_day; by censor day id;run;
	proc means data=mixed_day noprint;
    	class censor day;
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

%getn(num_&var);

proc format;
value dd   0 = " "  1="1*(&n1)*(&m1)"  2 = "2*(&n2)*(&m2)" 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5="5*(&n5)*(&m5)" 6 = "6*(&n6)*(&m6)" 7="7*(&n7)*(&m7)" 8 = " " ;

value tt  -1=" " 0 = "0*(&n0)*(&m0) "  1="1*(&n1)*(&m1)"  2 = " " 3="3*(&n3)*(&m3)" 4 = "4*(&n4)*(&m4)" 
		5=" " 6 = " " 7=" " 8 = "8*(&n8)*(&m8) " 9=" " 
		10 = " " 11=" " 12 = " )" 13=" " 	14 = " " 15="15*(&n15)*(&m15)"  16=" "  17 = " " 
		18=" " 19= " "   20=" " 21 = " "    22=" " 23 = " "  24 = " " 25=" " 
		26 = " " 27=" "  28="28*(&n28)*(&m28)" 40=" ";
run;

proc mixed data =tmp empirical covtest;
	class censor id day ; * &source;	
	model &var= censor day censor*day/ solution ; * &source	day*&source/ solution;
	repeated day / subject = id type = cs;
	lsmeans censor*day censor/pdiff cl ;

	%if &var # pelod pelod0 plt %then %do; 
		estimate "line trend0" day -3 -2 -1 0 1 2 3 censor*day -3 -2 -1 0 1 2 3 0 0 0 0 0 0 0/e;
		estimate "line trend1" day -3 -2 -1 0 1 2 3 censor*day 0 0 0 0 0 0 0 -3 -2 -1 0 1 2 3;
	%end;

	ods output lsmeans = lsmeans;
	ods output Mixed.Tests3=p_&var;
	ods output Mixed.Diffs= diff;
run;

data diff;
    length pv $8;
    set diff;
    where day=_day or effect="censor";
    diff=put(estimate,4.1)||"("||put(lower,4.1)||", "||put(upper,4.1)||")";
    pv=put(probt, 7.4);
    if probt<0.0001 then pv="<0.0001";
	if effect="censor" then day=99;
    keep day diff probt pv;  
run;

proc sort; by day; run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="censor" then effect="Vital Status";
		if effect="day" then effect="Days on Study";
			if effect="censor*day" then effect="Interaction between Vital Status and Days on Study";
run;

data lsmeans_&var;
	set lsmeans;
	*if lower^=. and lower<0 then lower=0;
	/*%if &var=adamts13 %then %do; if A then do; lower=estimate; upper=estimate; end; %end;*/
	day1=day+0.20;
	if day=8 then day1=day+0.5;
	if day>8 then day1=day+1;
	if effect="censor" then day=99;
run;

proc sort; by day;run;

DATA anno0; 
	set lsmeans_&var(where=(censor=0 and day^=99));
	xsys='2'; ysys='2';  color='blue ';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if day<8  then do;
    	X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else if day=8  then do;
    	X=day1-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else do;
    	X=day1-0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+0.5; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;

  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(censor=1 and day^=99));
	xsys='2'; ysys='2';  color='red';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	if day<8  then do;
    	X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	end;
	else if day=8  then do;
    	X=day-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
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
	merge lsmeans_&var(where=(censor=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(censor=1) rename=(estimate=estimate1 lower=lower1 upper=upper1))
	num_&var(where=(censor=0) keep=censor day num_obs rename=(num_obs=n0))
	num_&var(where=(censor=1) keep=censor day num_obs rename=(num_obs=n1))
	diff; by day;
	if day=.  then delete;
	if day=99 then do; n0=&nd; n1=&ns; end;
	%if &var=adamts13 %then %do; if day=99 then do; n0=&noa; n1=&nya; end; %end;
	%if &var=vwf_ag %then %do; if day=99 then do; n0=&nov; n1=&nyv; end; %end;
	%if &var=vwf_rca %then %do; if day=99 then do; n0=&nor; n1=&nyr; end; %end;
	est1=put(estimate1,4.1)||"("||put(lower1,4.1)||", "||put(upper1,4.1)||"), "||compress(n1);
	est0=put(estimate0,4.1)||"("||put(lower0,4.1)||", "||put(upper0,4.1)||"), "||compress(n0);
	if effect=" " then delete;
	%if &var # adamts13 vwf_ag vwf_rca %then %do; if day in(28,99) then do; est0="-"; diff="-"; pv="-"; end; %end;
run;


goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=3 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1 line=2;

axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (0 to 8 by 1) minor=none offset=(0 in, 0 in);
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Survivors" "Non-Survivors") offset=(0.2in, -0.2 in) frame;


%if &var=pelod0 %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score") value=(f=Century h=3) order= (0 to 60 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1  justify=left height=3.5 f=centb  "2A";
	*title2 	height=3.0 f=Century "Mean PELOD Score";
%end;

%if &var=pelod %then %do;
	axis2 	label=(f=Century h=3 a=90 "PELOD Score") value=(f=Century h=3) order= (0 to 60 by 5) offset=(.25 in, .25 in) minor=(number=1); 
	title1  justify=left height=3.5 f=centb  "2B";
	*title2 	height=3.0 f=Century "Mean PELOD Score Using the Maximum PELOD Score of 71 at All Time Points after Death";
%end;

%if &var=plt %then %do;
	axis2 	label=(f=Century h=3 a=90 "Platelet Counts(*1000 cells/uL)") value=(f=Century h=3) order= (0 to 160 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title 	height=3.5 f=Century "Platelet Count vs Days on Study";
%end;

%if &var=adamts13 %then %do;
	axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (-1 0 1 4 8 15 28 40) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=Century h=3 a=90 "ADAMTS-13 Activity (%)") value=(f=Century h=3) order= (0 to 110 by 10) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=cent "ADAMTS-13 Activity vs Days on Study";
	title2 height=3 f=Century "(Survivors=&nya vs. Non-Survivors=&noa)";
%end;

%if &var=vwf_ag %then %do;
	axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (-1 0 1 4 8 15 28 40) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=Century h=3 a=90 "vWF Antigen (%)") value=(f=Century h=3) order= (0 to 260 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "vWF Antigen vs Days on Study";
	title2 	height=3.0 f=Century "(Survivors=&nyv vs. Non-Survivors=&nov)";
%end;

%if &var=vwf_rca %then %do;
	legend across = 1 position=(top center inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
	value = (f=Century h=2.5 "Survivors" "Non-Survivors") offset=(0.2in, -0.2 in) frame;

	axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (-1 0 1 4 8 15 28 40) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=Century h=3 a=90 "vWF Ristocetin Cofactor Activity (%)") value=(f=Century h=3) order= (0 to 280 by 20) offset=(.25 in, .25 in) minor=(number=1); 
	title1 	height=3.5 f=Century "vWF Ristocetin Cofactor Activity vs Days on Study";
	title2 	height=3.0 f=Century "(Survivors=&nyr vs. Non-Survivors=&nor)";
%end;
             
proc gplot data= estimate_&var(where=(day^=99)) gout=tamof.graphs;
	plot estimate1*day estimate0*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;

	note h=3 m=(6pct, 15 pct) "Day :" ;
	note h=3 m=(2pct, 11.5 pct) "(#Survivors)" ;
	note h=3 m=(2pct, 8 pct) "(#Non-Survivors)" ;
	%if &var=pelod0 or &var=pelod or &var=plt  %then %do; 	format estimate0 estimate1 4.0 day dd.; %end;
	%else %do; format estimate0 estimate1 4.0 day tt.; %end;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;

proc greplay igout=tamof.graphs  nofs; delete _ALL_; run;
goptions rotate = portrait;

%let varlist=pelod0 pelod plt adamts13 vwf_ag  vwf_rca;
	%mixed(mixed,&varlist); run;

proc gslide gout=tamof.graphs;
  *title1 height=1.5 f=Century Bold "TAMOF children (Survivors=&ns vs. Non-Survivors=&nd)";
  title1 height=1.5 f=Century Bold "TAMOF children receiving Plasma Exchange (Survivors=&ns vs. Non-Survivors=&nd)";
run;

options orientation=portrait /*papersize=(8.5in 11in)*/;
ods pdf file = "All_PLE_only_censor_mixed.pdf";

goptions reset=all border;
proc greplay nofs /*NOBYLINE*/;
igout tamof.graphs;
list igout;
tc template;
tdef t1 5 /llx=5    ulx=5   lrx=50   urx=50  lly=5    uly=35    lry=5      ury=35
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=35   uly=65    lry=35     ury=65
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=65   uly=95    lry=65     ury=95
		6 /llx=50   ulx=50  lrx=95   urx=95  lly=5    uly=35    lry=5      ury=35
        4 /llx=50   ulx=50  lrx=95   urx=95  lly=35   uly=65    lry=35     ury=65
        2 /llx=50   ulx=50  lrx=95   urx=95  lly=65   uly=95    lry=65     ury=95
		7 /llx=10   ulx=10   lrx=90  urx=90  lly=0  uly=97   lry=0   ury=97					
			;
template t1;
tplay 1:1 2:2 3:3 4:4 5:5 6:6 7:8;
*tplay 1:1 3:3 5:5 ;
*tplay 2:2 4:4 6:6 ;
run; 
/*
proc greplay nofs ;
igout tamof.graphs;
list igout;
tc template;
tdef t1 3 /llx=10    ulx=10   lrx=80   urx=80  lly=5    uly=35    lry=5      ury=35
        2 /llx=10    ulx=10   lrx=80   urx=80  lly=35   uly=65    lry=35     ury=65
        1 /llx=10    ulx=10   lrx=80   urx=80  lly=65   uly=95    lry=65     ury=95
		4 /llx=15    ulx=15   lrx=75   urx=75  lly=0  uly=99   lry=0   ury=99					
			;
template t1;
tplay 1:4 2:5 3:6;
run; quit;
*/
ods pdf close;

options orientation=landscape;
ods ps file="pelod_pe_only1.ps" color=mono;
proc greplay igout = tamof.graphs tc=sashelp.templt template=whole nofs ; * L2R2s;
            list igout;
			treplay 1:1;
run;
ods ps close;

ods ps file="pelod_pe_only2.ps" color=mono;
proc greplay igout = tamof.graphs tc=sashelp.templt template=whole nofs ; * L2R2s;
            list igout;
			treplay 1:2;
run;
ods ps close;


ods rtf file="all_ple_only_censor_mixed.rtf" style=journal bodytitle startpage=no; 
proc print data=estimate_pelod0 noobs label split="*";
title "PELOD Score vs Days on Study by Vital Status";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_pelod0 noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;

proc print data=estimate_pelod noobs label split="*";
title "PELOD Score vs Days on Study by Vital Status: Max PELOD used at all time points after death.";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_pelod noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;

proc print data=estimate_plt noobs label split="*";
title "Platelet Count vs Days on Study by Vital Status";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_plt noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;

proc print data=estimate_adamts13 noobs label split="*";
title "Adamts13 vs Days on Study by Vital Status";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_adamts13 noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;

proc print data=estimate_vwf_ag noobs label split="*";
title "vWF Antigen vs Days on Study by Vital Status";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_vwf_ag noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;

proc print data=estimate_vwf_rca noobs label split="*";
title "vWF-RCA vs Days on Study by Vital Status";
var day est0 est1 diff pv/style=[just=center cellwidth=1.5 in];
label day="Days on Study"
	  est0="Non-Survivors*Mean(95%CI)"
	  est1="Survivors*Mean(95%CI)"
	  diff="Difference*Mean(95%CI)"
	  pv="p value";
run;

proc print data=p_vwf_rca noobs label;
title "P values for Repeated Measurements Analysis";
var  Effect /style=[just=left cellwidth=4 in];
var  probf/style=[just=center cellwidth=1 in];
label Effect="Effect"
	  probf="p value"
	;
run;
ods rtf close;
