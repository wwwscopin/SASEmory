
options ls=120 orientation=portrait fmtsearch=(library) nofmterr;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path.\data";
filename test "&path.\csv\Normative Scores for NC Test.xls" lrecl=1000;
 
proc format; 
value gender 0="Male" 1="Female";
value test 1="DSF" 2="DSB" 3="TMTA" 4="TMTB";
value group 1="18-29" 2="30-50" 3=">50";
value type 1="MND/ANI" 2="HAD" 3="NA";
run;

PROC IMPORT OUT= nc0 
            DATAFILE= test  
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:f17"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 TEXTSIZE=1024;
RUN;

data nc;
	set nc0(rename=(gender=gender0 Test=test0));
	rename 	 Normal__median_=normal_median  _SD=sd1  _SD0=sd2;
	if gender0='Male' then gender=0; else gender=1;
	if test0="DSF" then test=1;	else if test0="DSB" then test=2;



else if test0="TMTA" then test=3;else 	if test0="TMTB" then test=4;
	if age_group="18-29" then group=1;	else if age_group="30-50" then group=2; 
	format gender gender. test test. group group.;
	drop gender0 test0;
run;

proc sort; by group gender; run;

data demo;
	set brent.demo;
	*if demographics_complete;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	age=(dt_visit-dob)/365.25;

	if 18<=age<=29 then group=1; if 30<=age<=50 then group=2; else group=3;

	keep patient_id id idx dt_visit dob age gender group;
	format age 4.1;
run;
proc sort; by idx id; run;

proc contents data=brent.function;run;

data func;
	set brent.func;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	ta=trail_a+0;
	tb=trail_b+0;
	forward=tot_forward+0;
	backward=tot_back+0;
	score=karn_score +0;

	format dt_digit_span mmddyy.;
	keep patient_id id idx ta tb forward backward score dt_digit_span;
run;
proc sort; by idx id; run;
proc print;run;

data temp;	
	merge demo func; by idx id;
run;

proc sort; by group gender;run;


data test;
	merge temp nc(where=(test=1) rename=(normal_median=norm1 sd1=sd1A sd2=sd2A))
		nc(where=(test=2) rename=(normal_median=norm2 sd1=sd1B sd2=sd2B))
		nc(where=(test=3) rename=(normal_median=norm3 sd1=sd1C sd2=sd2C))
		nc(where=(test=4) rename=(normal_median=norm4 sd1=sd1D sd2=sd2D)); by group gender;
	if sd2A<forward<=sd1A then x1=1;  else x1=0; if forward<=sd2A then y1=1;  else y1=0;
	if sd2B<backward<=sd1B then x2=1;  else x2=0; if backward<=sd2B then y2=1;  else y2=0;
	if sd1C<=TA<sd2C then x3=1;  else x3=0; if TA>=sd2C then y3=1;  else y3=0;
	if sd1D<=TB<sd2D then x4=1;  else x4=0; if TB>=sd2D then y4=1;  else y4=0;

	x=sum(x1, x2, x3, x4);y=sum(y1, y2, y3, y4);
	if y>=2 then type=2; 
	else if (x>=2 and y<2) or (x=1 and y=1) then type=1;
	else type=3;
	if id=. then delete;
	format age 4.0 group group. type type.;
run;

data neurocogntive;
	set test;
	keep patient_id idx id age group gender forward backward ta tb score x y type;
	format gender gender. dt_span date9. group group. type type.;
	label /*patient_id="Patient ID"*/
		  Age="Age"
		  group="Age Group"
		  gender="Gender"
		  forward="Total Forward Score"
		  backward="Total Backward Score"
		  ta="Number of seconds for Trail A test"
		  tb="Number of seconds for Trail B test"
		  score="Karnofsky Score (%)"
		  x="X-Inter-Mediate Var"
		  y="Y-Inter-Mediate Var"
		  type="Type"; 
run;

proc sort; by patient_id;run;

data brent.neurocogntive;
	set neurocogntive;
run;

proc print;run;

proc export data=neurocogntive outfile="&path.\Neurocognitive.csv" label dbms=csv replace;  run;
proc export data=neurocogntive outfile="&path.\Neurocognitive.xls"  label dbms=xls replace;  run;

proc print data=test;
var patient_id dt_digit_span age group gender forward backward ta tb x y type; 
run;
*ods trace on/label listing;
proc freq data=test; 
tables idx*type/chisq fisher;
ods output crosstabfreqs=wbh;
ods output Freq.Table1.ChiSq=chq;
run;

proc print data=wbh;run;

data _null_;
	set wbh;
	if idx=0 and type=. then call symput("n0", compress(frequency));
		if idx=1 and type=. then call symput("n1", compress(frequency));
			if idx=. and type=. then call symput("n", compress(frequency));
run;

data _null_;
	length pv $6;
	set chq;
	pv=put(prob, 5.2); if prob<0.001 then pv="<0.001";
	if _n_=1 then call symput("pv", pv);
run;

proc sort data=wbh; by idx;run;

data tab;
	merge wbh(where=(idx=0 and type^=.) rename=(frequency=n0)) 
		wbh(where=(idx=1 and type^=.) rename=(frequency=n1)); by type;
	
	f0=n0/&n0*100; f1=n1/&n1*100;
	col0=n0||"/&n0("||put(f0,5.1)||"%)";
	col1=n1||"/&n1("||put(f1,5.1)||"%)";
	pv=&pv;
	if _n_^=1 then pv=" ";
	keep idx n0 n1 f0 f1 col0 col1 pv type;
run;

options orientation=portrait;
ods rtf file="neurocognitive.rtf" style=journal bodytitle;
proc print data=tab noobs label;
title "Test Outcome";
id type /style=[just=center cellwidth=1.25in];
var col0 col1 pv/style=[just=center cellwidth=1.25in];
label type="Group"
	  col0="Control"
	  col1="Case"
	  pv="p value"
	  ;
run;
ods rtf close;
