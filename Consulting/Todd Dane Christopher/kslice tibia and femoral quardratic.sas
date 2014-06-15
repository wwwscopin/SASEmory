
options orientation=portrait;
%let dane=H:\SAS_Emory\Consulting\Todd Dane Christopher\output;
%include "tab_stat.sas";
libname xxx "&dane";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Todd Dane Christopher\Kslice tibia and femoral volume cleaned data.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="'master all$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc print data=temp;run;
proc freq;
	tables knee gender;
run;
*/
proc format;
	value knee 1="Left" 2="Right";
	value gender 0="Female" 1="Male";
run;

data tf0;
	set temp(rename=(knee=knee0 gender=gender0));
	if knee0='L' then knee=1; else if knee0='R' then knee=2;
	if gender0='f' then gender=0; else if gender0='m' then gender=1;
	format knee knee. gender gender.;
	drop gender0 knee0;
	if gender=. then delete;
run;
proc sort; by gender;run;

proc means data=tf0 n mean std Q1 median Q3 noprint;
	var age;
	output out=age Q1(age)=Q1_age median(age)=median_age Q3(age)=Q3_age;
run;
data _null_;
	set age;
	call symput ("Q1_age", put(Q1_age, 4.1));
	call symput ("median_age", put(median_age, 4.1));
	call symput ("Q3_age", put(Q3_age, 4.1));
run;

proc format;
	value age_group 1="Age<=&Q1_age(Q1)"  2="Age=&Q1_age(Q1)~&median_age(Median)"  3="Age=&median_age(median)~&Q3_age(Q3)"  4="Age>&Q3_age(Q3)";
	value age .="Overall";
run;

data tf;
	set tf0;
	if age<=&Q1_age then age_group=1;
	else if &q1_age<age<=&median_age then age_group=2;
	else if &median_age<age<=&Q3_age then age_group=3;
	else age_group=4;
	format age_group age_group.;
run;

%macro qfit(data=, gp=, var=, label=)/minoperator;

proc mixed data =&data covtest;

	class &gp; 	
	model &var= &gp age age*&gp age*age/ solution; 
	lsmeans &gp/ pdiff cl ;

	estimate "male, age1" int 1 &gp 0 1 age 1  age*&gp 0 1  age*age 1/cl;
	estimate "male, age2" int 1 &gp 0 1 age 2  age*&gp 0 2  age*age 4;
	estimate "male, age3" int 1 &gp 0 1 age 3  age*&gp 0 3  age*age 9;
	estimate "male, age4" int 1 &gp 0 1 age 4  age*&gp 0 4  age*age 16;
	estimate "male, age5" int 1 &gp 0 1 age 5  age*&gp 0 5  age*age 25;
	estimate "male, age6" int 1 &gp 0 1 age 6  age*&gp 0 6  age*age 36/cl;
	estimate "male, age7" int 1 &gp 0 1 age 7  age*&gp 0 7  age*age 49;
	estimate "male, age8" int 1 &gp 0 1 age 8  age*&gp 0 8  age*age 64;
	estimate "male, age9" int 1 &gp 0 1 age 9  age*&gp 0 9  age*age 81;
	estimate "male, age10" int 1 &gp 0 1 age 10 age*&gp 0 10 age*age 100;
	estimate "male, age11" int 1 &gp 0 1 age 11 age*&gp 0 11 age*age 121;
	estimate "male, age12" int 1 &gp 0 1 age 12 age*&gp 0 12 age*age 144;
	estimate "male, age13" int 1 &gp 0 1 age 13 age*&gp 0 13 age*age 169;
	estimate "male, age14" int 1 &gp 0 1 age 14 age*&gp 0 14 age*age 196;
	estimate "male, age15" int 1 &gp 0 1 age 15 age*&gp 0 15 age*age 225;

	estimate "female, age1" int 1 &gp 1 0 age 1  age*&gp 1  0 age*age 1;
	estimate "female, age2" int 1 &gp 1 0 age 2  age*&gp 2  0 age*age 4;
	estimate "female, age3" int 1 &gp 1 0 age 3  age*&gp 3  0 age*age 9;
	estimate "female, age4" int 1 &gp 1 0 age 4  age*&gp 4  0 age*age 16;
	estimate "female, age5" int 1 &gp 1 0 age 5  age*&gp 5  0 age*age 25;
	estimate "female, age6" int 1 &gp 1 0 age 6  age*&gp 6  0 age*age 36;
	estimate "female, age7" int 1 &gp 1 0 age 7  age*&gp 7  0 age*age 49;
	estimate "female, age8" int 1 &gp 1 0 age 8  age*&gp 8  0 age*age 64;
	estimate "female, age9" int 1 &gp 1 0 age 9  age*&gp 9  0 age*age 81;
	estimate "female, age10" int 1 &gp 1 0 age 10 age*&gp 10 0 age*age 100;
	estimate "female, age11" int 1 &gp 1 0 age 11 age*&gp 11 0 age*age 121;
	estimate "female, age12" int 1 &gp 1 0 age 12 age*&gp 12 0 age*age 144;
	estimate "female, age13" int 1 &gp 1 0 age 13 age*&gp 13 0 age*age 169;
	estimate "female, age14" int 1 &gp 1 0 age 14 age*&gp 14 0 age*age 196;
	estimate "female, age15" int 1 &gp 1 0 age 15 age*&gp 15 0 age*age 225;

	*estimate "line trend0" age -5 -3 3 5 -1 1 	&gp*age -5 -3 3 5 -1 1 0 0 0 0 0 0 0 0 0 0 0 0/e;
	*estimate "line trend1" age -5 -3 3 5 -1 1 	&gp*age 0 0 0 0 0 0 -5 -3 3 5 -1 1 0 0 0 0 0 0/e;

	ods output SolutionF=cfit;
	ods output  Mixed.Estimates = lsmeans;
		ods output   Mixed.Tests3=p_&var;
run;

data _null_;
	set cfit;
	if _n_=1 then call symput("int", put(estimate,7.4));
	if _n_=2 then call symput("female",  put(estimate,7.4));
	if _n_=4 then call symput("age", put(estimate,7.4));
	if _n_=5 then call symput("fage", put(estimate,7.4));
	if _n_=7 then call symput("age2", put(estimate,7.4));

	*call symput('eqn',"&var="||"&int"||" + "||"&age.*Age"||" + "||"&age2.*Age*Age"||" + "||"&female.*Female"||" + "||"&female.*Sex");
run;

data _null;
	call symput('eqn',"&var="||"&int"||" + "||"&age.*Age"||" + "||"&age2.*Age*Age"||" + "||"&female.*Female"||" + "||"&fage.*Female*Age");
run;

%put &eqn;

data lsmeans;
	set lsmeans;
	age=compress(scan(label,2),"age")+0;
	if scan(label,1)="male" then &gp=1; else &gp=0;
run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="&gp" then effect="&gp";
		if effect="age" then effect="Age";
		if effect="age*age" then effect="Age*Age";
		if effect="&gp*age" then effect="Interaction between &gp and Age";
run;

data _null_;
	set p_&var;
	if _n_=1 then do; if probf<0.0001 then call symput ("p1", "<0.0001"); else call symput ("p1", put(probf,7.4)); end;
	if _n_=2 then do; if probf<0.0001 then call symput ("p2", "<0.0001"); else call symput ("p2", put(probf,7.4)); end;
	if _n_=3 then do; if probf<0.0001 then call symput ("p3", "<0.0001"); else call symput ("p3", put(probf,7.4)); end;
	if _n_=4 then do; if probf<0.0001 then call symput ("p4", "<0.0001"); else call symput ("p4", put(probf,7.4)); end;
run;


data lsmeans_&var;
	set lsmeans;
	if lower^=. and lower<0 then lower=0;
	if upper^=. and upper<0 then upper=0;
	if estimate^=. and estimate<0 then estimate=0;
	age1=age+0.10;
	if 0<age<=15;
run;

proc sort; by &gp age;run;

DATA anno0; 
	set lsmeans_&var(where=(&gp=0));
	xsys='2'; ysys='2';  color='blue';
	X=age1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	   	X=age1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=age1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  		X=age1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmeans_&var(where=(&gp=1));
	xsys='2'; ysys='2';  color='red';
	X=age; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    	X=age-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=age+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	  	X=age;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	length color $10;
	set anno0 anno1;
run;

data estimate_&var;
	merge lsmeans_&var(where=(&gp=0 ) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(&gp=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by age;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol2 i=j ci=blue value=circle co=blue cv=blue h=2 w=1;
symbol1 i=j ci=red value=dot co=red cv=red h=2 w=1;

axis1 	label=(f=Century h=3 "Age" ) split="*"	value=(f=Century h=3)  order= (0 to 16 by 1) minor=none offset=(0 in, 0 in);

legend1 across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5  "Male" "Female") offset=(-0.2in, -0.2 in) frame;

%if &var # Fem_Ph_V Tib_Ph_V %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 6 by 0.5) offset=(.25 in, .25 in); 
%end;

%else %if &var # L_F_Ep_V M_F_EP_V Tib_Ep_V %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 40 by 5) offset=(.25 in, .25 in); 
%end;

%else %if &var # F_CEWd_R T_CEWd_R %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 2.4 by 0.2) offset=(.25 in, .25 in); 
%end;

%else %if &var # F_ML_Rat T_ML_Rat %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0.6 to 1.2 by 0.05) offset=(.25 in, .25 in); 
%end;

%else %if &var # F_PE_Rat T_PE_Rat T_ML_Rat F_CEWd_R T_CEWd_R %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 1 by 0.1) offset=(.25 in, .25 in); 
%end;

%else %if &var # Fem_Ep_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W %then %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 100 by 10) offset=(.25 in, .25 in); 
%end;

%else %do; 
	axis2 	label=(f=Century h=3 a=90 &label) value=(f=Century h=3) order= (0 to 20 by 2) offset=(.25 in, .25 in); 
%end;

title1 h=5 &label vs Age by Quardratic Fitting;
title2 h=3 "p(&gp)=&p1; p(Age)=&p2; p(Age*&gp)=&p3; p(Age*Age)=&p4";

proc gplot data= estimate_&var gout=xxx.graphs;
	plot estimate1*age estimate0*age1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend1;

	%if &var # F_PE_Rat T_PE_Rat Fem_Ph_V F_CEWd_R T_CEWd_R Tib_Ph_V %then %do; format estimate0 estimate1 4.1; %end;
	%else %if &var # F_ML_Rat T_ML_Rat %then %do; format estimate0 estimate1 4.2; %end;
	%else %do; format estimate0 estimate1 4.0; %end;

   footnote1 j=l h=2 "Regression Equation:";
   footnote2 j=l h=2 "&eqn";
run;

%mend qfit;

proc greplay igout= xxx.graphs nofs; delete _ALL_; run;
%qfit(data=tf,gp=Gender, var=Fem_Ph_V, label="Femoral Physis Volume");
%qfit(data=tf,gp=Gender, var=Fem_Ep_V, label="Femoral Epiphysis Volume");
%qfit(data=tf,gp=Gender, var=L_F_Ep_V, label="Lateral Femoral Epiphysis Volume");
%qfit(data=tf,gp=Gender, var=M_F_EP_V, label="Medial Femoral Epiphysis Volume");
%qfit(data=tf,gp=Gender, var=F_PE_Rat, label="Femur Physis to Epiphysis Ratio");
%qfit(data=tf,gp=Gender, var=F_ML_Rat, label="Femur Medial to Lateral Epiphysis Ratio");
%qfit(data=tf,gp=Gender, var=Tib_Ph_V, label="Tibia physis volume");
%qfit(data=tf,gp=Gender, var=Tib_Ep_V, label="Tibia Epiphysis Volume");
%qfit(data=tf,gp=Gender, var=L_T_Ep_V, label="Lateral tibia epiphyseal volume");
%qfit(data=tf,gp=Gender, var=M_T_Ep_V, label="Medial tibial epiphyseal volume");
%qfit(data=tf,gp=Gender, var=T_PE_Rat, label="Tibial physis to epiphysis ratio");
%qfit(data=tf,gp=Gender, var=T_ML_Rat, label="Tibial Medial to Lateral Epiphysis Ratio");
%qfit(data=tf,gp=Gender, var=F_Cart_V, label="Femur Cartilage Cap Volume");
%qfit(data=tf,gp=Gender, var=T_Cart_V, label="Tibial Cartilage Cap Volume");
%qfit(data=tf,gp=Gender, var=F_Epi_Wd, label="Width of Femur Epiphysis");
%qfit(data=tf,gp=Gender, var=T_Epi_Wd, label="Width of Tibial Epiphysis");
%qfit(data=tf,gp=Gender, var=F_Cart_W, label="Femur Cartilage Cap Width");
%qfit(data=tf,gp=Gender, var=T_Cart_W, label="Tibia Cartilage Cap Width");
%qfit(data=tf,gp=Gender, var=F_CEWd_R, label="Femur Cartilage Cap width to Epiphysis width Ratio");
%qfit(data=tf,gp=Gender, var=T_CEWd_R, label="Tibia Cartilage Cap width to Epiphysis width Ratio");
quit;

	ods pdf file = "byGenderAge.pdf";
 		proc greplay igout = xxx.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1  2:2;
			treplay 1:3  2:4;
			treplay 1:5  2:6;
			treplay 1:7  2:8;
			treplay 1:9  2:10;
			treplay 1:11  2:12;
			treplay 1:13  2:14;
			treplay 1:15  2:16;
			treplay 1:17  2:18;
			treplay 1:19  2:20;
		run;
	ods pdf close;
