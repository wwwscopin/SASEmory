PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Chris\ATC study Stats.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:F55"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc format;
value gender 0="Male" 1="Female";
run;

data atc0;
	set tmp;
	if _n_=1 then delete;
	rename Perceived_Time_w_physician=pt Actual_Time_w_physician=at Satisfaction_of_education=satify;
	format sex gender.;
run;

proc means data=atc0 median mean stderr stddev;
	var age;
	output out=wbh median(age)=median;
run;

data _null_;
	set wbh;
	call symput ("mage", compress(median));
run;

data atc;
	set atc0;
	if age>&mage then gage=1; else gage=0;
	dt=pt-at;
	if dt>0 then x=1; else x=0;
	if dt=. then x=.;
run;

proc freq;
	table sex satify;
run;

proc univariate ;
  var dt;
run;

proc freq;
	table x*(gage sex)/chisq;
run;

proc freq data=atc;
	table satify*(gage sex)/chisq;
run;

proc freq data=atc;
	table gage*sex/chisq;
run;

/*
proc freq;
	table x*(gage sex)/chisq;
run;
*/

proc npar1way wilcoxon; 
	class x;
	var at age;
run;

proc means data=atc maxdec=1; 
	class x;
	var age;
run;

proc npar1way wilcoxon; 
	class gage;
	var pt at ;
run;

proc npar1way wilcoxon; 
	class sex;
	var pt at age;
run;
