%let path=H:\SAS_Emory\Consulting\Chenlu\;
filename ercp "&path.raw ERCP data-12.16.10.xls";

PROC IMPORT OUT= can 
            DATAFILE= ercp 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data can two_atp;
	set can;
	if _n_>1;
	i=f1+0; time=f2+0; attempt1=f3+0; attempt2=f4+0;
	if attempt2=. then attempt=attempt1; else attempt=(attempt1+attempt2)/2;
	log_t=log(time); log_a=log(attempt); log_t0=log(time*60);
	drop F1-F4;
	if attempt2^=. or i= 48 then output two_atp; 
	output can;
run;

proc print data=can;run;

data can_single;
	set can;
	if attempt2=.;
run;

proc means data=can_single;
	var attempt1;
run;
/*
PROC STANDARD DATA=can
       MEAN=0 STD=1 OUT=ZSCORES;
       VAR time;
       RUN;
       PROC PRINT DATA=ZSCORES;
RUN;
*/

PROC MEANS DATA=can;VAR time attempt attempt1;OUTPUT OUT=can_mean
       MEAN(time)=t_mean mean(attempt)=a_mean STD(time)=t_sd STD(attempt)=a_sd;
RUN;

PROC CORR data=can;
    VAR time attempt;
	TITLE 'Correlation Between Time And Attempt';
run;

DATA can_diff;SET can;
       IF _N_=1 THEN SET can_mean;
       t_DIFF=time-t_mean; a_DIFF=attempt-a_mean;
       t_Z=t_DIFF/t_sd;  a_Z=a_DIFF/a_sd; * CREATES STANDARDIZED SCORE (Z-SCORE);
	   zdiff=t_z-a_z; z_avg=(t_z+a_z)/2;
	   keep time t_diff t_z attempt a_diff a_z zdiff z_avg;
RUN;

proc means data=can_diff;
var zdiff;
run;

TITLE 'Agreement between the time and attempt';
data can_diff;
	set can_diff;
	avg=0; d1=avg+1.96*0.7445473; d2=avg-1.96*0.7445473;
run;
proc print;run;

proc univariate data=can_diff plot;
	var zdiff;
run;

axis1 order=(-4 to 4 by 0.5);
proc gplot data=can_diff;
	symbol1 v=dot c=red i=none;
	plot zdiff*z_avg/vaxis=axis1 vref=0 1.4593 -1.4593 lv=3 c=black;
run;



