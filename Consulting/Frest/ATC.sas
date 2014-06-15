%let path=H:\SAS_Emory\Consulting\Frest\;
filename atc "&path.Copy of Research Project Data.xls";

PROC IMPORT OUT= atc 
            DATAFILE= atc 
            DBMS=EXCEL REPLACE;
     sheet="ATC"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data atc;
	set atc;
	if 2<=_n_<=66;
	Study=F1+0; ATC=F2+0; MA=F3+0; Res=F4+0; RN=F5+0; PA=F6+0; MD=F7+0;	
	Q1=F8+0; Q2=F9+0; Q3=F10+0; Q4=F11+0; Q5=F12+0; Q6=F13+0; Q7=F14+0; Q8=F15+0;
	group=0;
	drop F1-F16;
run;

PROC IMPORT OUT= Res 
            DATAFILE= atc 
            DBMS=EXCEL REPLACE;
     sheet="Resident"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data res;
	set res;
	if 2<=_n_<=56;
	Study=F1+0; ATC=F2+0; MA=F3+0; Res=F4+0; RN=F5+0; PA=F6+0; MD=F7+0;	
	Q1=F8+0; Q2=F9+0; Q3=F10+0; Q4=F11+0; Q5=F12+0; Q6=F13+0; Q7=F14+0; Q8=F15+0;
	group=1;
	drop F1-F16;
run;
proc format;
	value group 0="ATC" 1="Resident";
run;


data atc_res;
	set atc res;
	meanscore=mean(of Q1-Q8);
	format group group.;
run;

proc print;run;

proc freq;
	tables (ATC MA Res RN PA MD)*group/norow nocol nopercent;
run;

proc ttest data=atc_res; 
	class group;
	var Q1-Q8 meanscore; 
run;
