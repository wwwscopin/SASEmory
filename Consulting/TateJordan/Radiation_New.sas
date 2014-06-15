PROC IMPORT OUT= WORK.TEMP1 
            DATAFILE= "H:\SAS_Emory\Consulting\TateJordan\STUDY 1 NEW VS OLD.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:B275"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

proc format; 
	value type 1="cervical" 2="lumbar" 3="hip";
	value norm 1=">=25" 0="<25";
	value new 0="Old" 1="New";
	value obese 0="BMI<25" 1="25=<BMI<30" 2="BMI>=30";
	value bmi_idx 1="<20" 2="20-25" 3="25-30" 4="30-35" 5="35-40" 6=">40";
run;

%let square=%sysfunc(byte(178));
%put &square;

data new;
	set temp1;
	if NEW_OLD="N" then new=1; else new=0;
	rename GY__RAD_EXPOSURE_=gy;
	keep New_OLD new GY__RAD_EXPOSURE_;
	format new new.;
run;

proc means data=new n mean std median clm maxdec=6;
	class new;
	var gy;
run;

data new_gy;
	merge new(where=(new=0) keep=new gy rename=(gy=gy0)) 
		  new(where=(new=1) keep=new gy rename=(gy=gy1));
	drop new;
	diff=gy1-gy0;
run;

proc univariate data=new_gy plot cibasic;
	var diff;
	qqplot;
run;

Proc corr data=new_gy spearman;
	var gy1 gy0;
run;


/*
proc sgscatter data=new_gy;
  title "Scatter Plot of GY by New vs Old";
  compare y=(gy1)
		  x=(gy0);
run;
*/


PROC IMPORT OUT= WORK.TEMP2 
            DATAFILE= "H:\SAS_Emory\Consulting\TateJordan\STUDY 2.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:D325"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

data rad;
	set temp2;
	id=_n_;
	if BMI>=25 then bmi_norm=1; else if 0<BMI<25 then bmi_norm=0;
	if 25=<BMI<30 then obese=1; else if BMI>=30 then obese=2; else obese=0;
	rename PATIENT__NEW_=pn RAD_Time__sec_=rad GY__RADIATION_EXPOSURE_=gy;
	log_gy=log(GY__RADIATION_EXPOSURE_); log_bmi=log(bmi); log_rad=log(RAD_Time__sec_);
	gy_rad=GY__RADIATION_EXPOSURE_/RAD_Time__sec_;

	if BMI<20 then bmi_idx=1;
	else if 20<=BMI<25 then bmi_idx=2;
	else if 25<=BMI<30 then bmi_idx=3;
	else if 30<=BMI<35 then bmi_idx=4;
	else if 35<=BMI<=40 then bmi_idx=5;
	else if 40<BMI then bmi_idx=6;

	keep  id PATIENT__NEW_ RAD_Time__sec_ GY__RADIATION_EXPOSURE_ BMI bmi_norm log_gy log_bmi log_rad gy_rad obese bmi_idx;
	format bmi_norm norm. obese obese. bmi_idx bmi_idx.;
	label RAD_Time__sec_="RAD Time (sec)"
		  GY__RADIATION_EXPOSURE_="GY (RADIATION EXPOSURE)"
		  gy_rad="GY/RAD"
		  bmi_idx="BMI(kg/m&square)";
run;
/*
proc freq data=rad;
	tables bmi_idx;
run;
*/
proc npar1way data=rad(where=(bmi_idx in (1,2))) wilcoxon;
	class bmi_idx;
	var rad gy gy_rad;
run;
proc npar1way data=rad(where=(bmi_idx in (2,3))) wilcoxon;
	class bmi_idx;
	var rad gy gy_rad;
run;
proc npar1way data=rad(where=(bmi_idx in (3,4))) wilcoxon;
	class bmi_idx;
	var rad gy gy_rad;
run;
proc npar1way data=rad(where=(bmi_idx in (4,5))) wilcoxon;
	class bmi_idx;
	var rad gy gy_rad;
run;
proc npar1way data=rad(where=(bmi_idx in (5,6))) wilcoxon;
	class bmi_idx;
	var rad gy gy_rad;
run;

proc sgplot data=rad;
vbox rad / category=bmi_idx;
label rad="Radiation Time(Sec)";
run;

proc sgplot data=rad;
vbox gy / category=bmi_idx;
label gy="Radiation Exposure";
run;

proc sgplot data=rad;
vbox gy_rad / category=bmi_idx;
label gy_rad="Radiation Exposure/Time";
run;

*ods trace on/label listing;
%macro regline(data,var);
proc reg data=&data outest=regdata ;
   model &var=BMI / clm;
   ods output  ParameterEstimates=param;
run;
*ods trace off;

data _null_;
	set param; 
	call symput("probt", put(probt, 7.4));
run;
/* Place the regression equation in a macro variable. */
data _null_;
   set regdata;
   %if &var=rad %then %do;
   		call symput('eqn',"Radiation Time="||put(Intercept,7.4)||" + "||put(bmi,7.4)||"*BMI");
   %end;
   %if &var=gy %then %do;
   		call symput('eqn',"Radiation Exposure="||put(Intercept,7.4)||" + "||put(bmi,7.4)||"*BMI");
   %end;
   %if &var=gy_rad %then %do;
   		call symput('eqn',"Radiation Exposure/Time="||put(Intercept,7.4)||" + "||put(bmi,7.4)||"*BMI");
   %end;
run;

proc sgplot data=&data;
   title " ";
   reg x=BMI y=&var / clm;

   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
/* inset "&eqn" / position=bottomleft;  */

   xaxis values=(10 to 50 by 5);
   %if &var=rad %then %do;
	   label &var="Radiation Time(Sec)";
   %end;
   %if &var=gy %then %do;
	   label &var="Radiation Exposure";
   %end;
   %if &var=gy_rad %then %do;
	   label &var="Radiation Exposure/Time";
   %end;
   label BMI="BMI(kg/m&square)";
   footnote1 j=l "Regression Equation(p=&probt)";
   footnote2 j=l "&eqn";
run;
%mend;
%regline(rad, rad);
%regline(rad, gy);
%regline(rad, gy_rad);


/*
proc means data=rad n mean std median clm maxdec=6;
	class bmi_norm;
	var gy gy_rad;
run;

proc npar1way data=rad wilcoxon;
	class bmi_norm;
	var gy gy_rad;
run;

proc means data=rad n mean std median clm maxdec=6;
	class obese;
	var rad gy gy_rad;
run;

proc npar1way data=rad wilcoxon;
	class obese;
	var rad gy gy_rad;
run;

proc sgscatter data=rad;
  title "Scatter Plot of GY vs BMI/RAD";
  compare y=(log_gy)
		  x=(log_bmi log_rad);
run;

proc sgplot data=rad;
   title " ";
   reg x=log_rad y=log_gy / clm;
run;

proc sgscatter data=rad;
  title "Scatter Plot of GY vs BMI/RAD";
  compare y=(gy)
		  x=(bmi rad);
run;

Proc corr data=rad spearman;
	var bmi_norm gy;
run;

Proc corr data=rad spearman;
	var bmi rad gy;
run;
proc sort data=rad; by obese;run;

ods graphics on;
title 'Scatter plot by BMI Range';
proc corr data=rad spearman nomiss plots=matrix(histogram) plots=scatter(nvar=2 alpha=.20 .30);
   by obese;
   var BMI rad gy gy_rad;
 run;
ods graphics off;
*/
