options orientation=portrait;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.fpo0 
            DATAFILE= "H:\SAS_Emory\Consulting\Owings F Patterson\Scoliosis.FPO.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="'AS and EG#Revised Combined$'"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc contents;run;
proc format;
	value comp 0="Complication=No" 1="Complication=Yes";
run;

data fpo;
	set fpo0;
	if cmiss(location) then delete;
	keep sex Age_at_Time_of_Surgery Length_of_Stay Surgery_Time ASA EBL __of_levels_fused Complication_type tos first_name last_name;
	rename __of_levels_fused=fused Age_at_Time_of_Surgery=age Length_of_Stay=los;
	if Complication_type>0 then comp=1; else comp=0;
	tos=intck('min',0, surgery_time)/60;
	format comp comp.;
run;

proc sort; by last_name first_name;run;

PROC IMPORT OUT= WORK.name(keep=last_name first_name where=(last_name^=" ")) 
            DATAFILE= "H:\SAS_Emory\Consulting\Owings F Patterson\Scoliosis.FPO.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="'ASR and EG#Revised Comps$'"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sort; by last_name first_name;run;


data fpo;
	merge fpo name(in=B); by last_name first_name;
	if B then comp=1; else comp=0;
	format comp comp.;
run;

proc freq data=fpo;
	tables comp*fused/trend measures cl nopercent norow
          plots=freqplot(twoway=stacked);
   ods output CrossTabFreqs=new;
   test smdrc;
   *exact trend / maxtime=60;;
run;
data pct;
	set new;
	where comp=1 and fused^=.;
	keep fused colpercent;
	rename colpercent=pct;
run;


proc reg data=pct outest=regdata noprint;
	model pct=fused/clm;
run;

proc reg data=pct outest=regdata ;
	model pct=fused/clm;
run;



/* Place the regression equation in a macro variable. */
data _null_;
   set regdata;
   call symput('eqn',"Complication Rate="||Intercept||" + "||Fused||"*Fused");
run;

ods listing close;
ods html file='regressionplot.html' path='.' style=styles.statistical;
ods graphics / reset width=600px height=400px imagename='Regression' imagefmt=gif;

title 'Complication Rates(%) vs # Levels Fused';

proc sgplot data=pct;
   reg x=fused y=pct /clm;

   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
/* inset "&eqn" / position=bottomleft;  */
   XAXIS LABEL = '# Levels Fused' VALUES = (4 TO 15 BY 1);
   label pct="Complication Rate(%)";
   footnote1 j=l "Regression Equation";
   footnote2 j=l "&eqn";
run;

ods html close;
ods listing;


/*
proc logistic data=fpo;
	class asa sex/ param=ref ref=first order=internal;
	model comp=age los tos asa ebl fused sex/expb selection=backward lackfit clodds=pl;
	unit age=5 fused=1;
run;

proc logistic data=fpo plots=roc desc;
	model comp=fused/expb lackfit clodds=pl;
	unit fused=1;
	output out=pred p=phat lower=lcl upper=ucl predprob=(individual crossvalidate);
run;

proc print data=pred;
   title 'Predicted Probabilities and 95% Confidence Limits';
run;

pros sgscatter data=pred;
	plot phat*fused;
run;
*/
	

%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=age,type=con, first_var=1, title="Table Summary");
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=los,type=con, decmax=1);
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=tos,type=con, decmax=1, label="Time of Sugery");
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=asa,type=cat);
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=ebl,type=con, decmax=1);
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=fused,type=con,decmax=1);
%table(data_in=fpo,data_out=fpo_tab,gvar=comp,var=sex,type=cat, last_var=1);quit;
