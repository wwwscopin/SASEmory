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
/*
PROC STANDARD DATA=can
       MEAN=0 STD=1 OUT=ZSCORES;
       VAR time;
       RUN;
       PROC PRINT DATA=ZSCORES;
RUN;
*/

PROC MEANS NOPRINT DATA=can;VAR time attempt;OUTPUT OUT=can_mean
       MEAN(time)=t_mean mean(attempt)=a_mean STD(time)=t_sd STD(attempt)=a_sd;
RUN;
DATA can_diff;SET can;
       IF _N_=1 THEN SET can_mean;
       t_DIFF=time-t_mean; a_DIFF=attempt-a_mean;
       t_Z=t_DIFF/t_sd;  a_Z=a_DIFF/a_sd; * CREATES STANDARDIZED SCORE (Z-SCORE);
	   keep time t_diff t_z attempt a_diff a_z;
RUN;

PROC PRINT DATA= can_diff;VAR time t_diff t_z attempt a_diff a_z;
RUN;

ods rtf file="corr.rtf" style=journal;
PROC CORR data=can;
    VAR time attempt;
	TITLE 'Correlation Between Time And Attempt';
run;
ods rtf close;
	

proc gplot data=can;
	symbol1 v=dot c=red i=rlcli95;
	plot time*attempt;
	plot log_t*log_a;
run;
proc univariate data=can plot;
var time attempt;
run;


TITLE 'Agreement between the Two Observers';
PROC CORR data=two_atp;
    VAR attempt1 attempt2;
	TITLE 'Correlation Between Attempt1 and Attempt2';
run;
proc ttest  data=two_atp;
	paired attempt1*attempt2;
run;

data two_atp;
	set two_atp;
	diff=attempt1-attempt2;
	avg=0.1538462; d1=avg+1.96* 3.4118947; d2=avg-1.96* 3.4118947;
run;

proc print;run;
proc univariate data=two_atp plot;
	var diff;
run;

proc means data=two_atp;
	var diff;
run;

proc gplot data=two_atp;
	symbol1 v=dot c=red i=rlcli95;
	plot attempt1*attempt2;
run;

axis1 order=(-8 to 8 by 1);
proc gplot data=two_atp;
	symbol1 v=dot c=red i=none;
	plot diff*attempt/vaxis=axis1 vref=0.1538462 6.84116 -6.53347 lv=3 c=black;
run;



