
options spool;

data x;
	set	glnd.status ;
	center = floor(id/10000);
run;

/*
options nodate nonumber;
ods pdf file = "/glnd/sas/reporting/apache_breakdown.pdf" style = journal;
	title "GLND - Breakdown of Patients by APACHE II Score and Center";
	
	proc freq data = x;
		tables center * apache_2 /nopercent nocol norow;
		format center center. apache_2 apache.;
	run;

ods pdf close;
*/

data glu;
    set glnd.followup_all_long(keep=id day gluc_mrn rename=(gluc_mrn=gluc))
        glnd.followup_all_long(keep=id day gluc_aft rename=(gluc_aft=gluc))
        glnd.followup_all_long(keep=id day gluc_eve rename=(gluc_eve=gluc));
        by id day;
run;

data xx;
    merge glu glnd.status(keep=id treatment apache_2); by id;
run;


%macro getn(data);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;
    if treatment=2 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if treatment=1 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%macro mixed(data, idx);

%if &idx=1 %then %let stra=APACHE <=15;
%if &idx=2 %then %let stra=APACHE >15;

data tmp;
    set &data;
    where apache_2=&idx;
run;


proc sort data=tmp nodupkey out=mixed_day; by treatment day id;run;
proc means data=mixed_day;
    class treatment day;
   	var gluc;
	output out = num n(gluc) = num_obs;
run;

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13= 0; %let m14= 0;   
%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13= 0; %let n14= 0; 

%let m15= 0; %let m16= 0; %let m17= 0; %let m18= 0; %let m19= 0; %let m20=0; %let m21= 0;  
%let m22= 0; %let m23= 0; %let m24= 0; %let m25= 0; %let m26= 0; %let m27= 0; %let m28= 0;   
%let n15= 0; %let n16= 0; %let n17= 0; %let n18= 0; %let n19= 0; %let n20=0; %let n21= 0;  
%let n22= 0; %let n23= 0; %let n24= 0; %let n25= 0; %let n26= 0; %let n27= 0; %let n28= 0; 

%getn(num);

proc format;


value dd  0 = " "  1="1*(&n1)*(&m1)"  2 =" " 3=" " 4 = "4*(&n4)*(&m4)"	5=" " 6 = " " 8=" " 7 = "7*(&n7)*(&m7)" 
          9=" " 10 = " " 11=" " 12 = " " 13=" " 15 =" "  14="14*(&n14)*(&m14)"  16=" "  17 = " " 	18=" " 19= " "   
          20=" " 21 = "21*(&n21)*(&m21)"    22=" " 23 = " "  24 = " " 25=" "  26 = " " 27=" "  28="28*(&n28)*(&m28)" 29=" ";
run;

proc mixed data =tmp empirical covtest;
	class treatment id day ; * &source;	
	model gluc= treatment day treatment*day/ solution ; 
	repeated day / subject = id type = cs;
	lsmeans treatment*day treatment/cl ;
	ods output lsmeans = lsmeans;
			ods output   Mixed.Tests3=pv;
run;

data pv;
	length effect $100;
	set pv;
	if effect="treatment" then effect="Treatment";
		if effect="day" then effect="Treatment Day";
			if effect="treatment*day" then effect="Interaction between Treatment and Treatment Day";
run;

data lsmeans;
	set lsmeans;
	day1=day+0.1;
	if effect="treatment" then day=99;
	where day in(1,4,7,14,21,28);
run;

proc sort; by day;run;


DATA anno1; 
	set lsmeans(where=(treatment=2 and day^=99));
	xsys='2'; ysys='2';  color='blue ';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:

    	X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;

  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno0; 
	set lsmeans(where=(treatment=1 and day^=99));
	xsys='2'; ysys='2';  color='red ';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    	X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno;
	set anno0 anno1;
run;

data estimate&idx;
	merge lsmeans(where=(treatment=1) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans(where=(treatment=2) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=3 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

axis1 	label=(f=Century h=3 "Days on Study" ) split="*"	value=(f=Century h=3)  order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "Treatment A" "Treatment B") offset=(0.2in, -0.2 in) frame;


axis2 	label=(f=Century h=3 a=90 "Blood Glucose") value=(f=Century h=3) order= (90 to 170 by 5) offset=(.25 in, .25 in) minor=(number=1);
title 	height=3.5 f=Century "Apache Stratum &idx (&stra): Treatemtn A and B";


       
proc gplot data= estimate&idx gout=glnd_rep.graphs;

	plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=3 m=(5pct, 14.5 pct) "Day :" ;
	note h=3 m=(5pct, 11.0 pct) "(#A) " ;
	note h=3 m=(5pct, 7.5 pct) "(#B)" ;
	format estimate0 estimate1 4.0 day dd.; 
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions rotate = portrait;

%mixed(xx,1); run;
%mixed(xx,2); run;

data EP0;
	set estimate1;
	col0=put(estimate0,4.1)||"["||put(lower0, 4.1)||"-"||put(upper0, 4.1)||"]";
		col1=put(estimate1,4.1)||"["||put(lower1, 4.1)||"-"||put(upper1, 4.1)||"]";
		keep day col0 col1;
run;

data EP;
	set estimate2;
	col0=put(estimate0,4.1)||"["||put(lower0, 4.1)||"-"||put(upper0, 4.1)||"]";
		col1=put(estimate1,4.1)||"["||put(lower1, 4.1)||"-"||put(upper1, 4.1)||"]";
		keep day col0 col1;
run;


options orientation=portrait papersize=(8.5in 11in);
ods pdf file = "glucose_apache_treatment.pdf";

goptions reset=all border;
proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
list igout;
tplay 1:1 2:3;
run; 
ods pdf close;
