
options pagesize= 60 linesize = 85 orientation=portrait;
 	*clear out the graphs catalog;

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;

proc format;
  value deficient
   1='Deficient'
   0='Not Deficient'
   ;
   value quart
   1='A. <335'
   2='B. 335-404'
   3='C. 405-491'
   4='D. >491';
data x;
  set  glnd_ext.glutamine;
  if visit=0 ;
data missing;
   merge x glnd.status(keep=id deceased);
   by id;
   if glutamine=.;
run;
proc print;
run;
data glutamine_full;
	set glnd_ext.glutamine;

glutamine=round(glutamine);	
	
if visit=0;
if glutamine eq . then delete;
if glutamine<420 then ga=1; else ga=0;
	if glutamine<400 then gb=1; else gb=0;
	if glutamine<350 then gc=1; else gc=0;
   if glutamine <335 then quart=1;
      else if glutamine <=405 then quart=2;
          else if glutamine <=491 then quart=3;
                else quart=4;
 label ga='Deficient < 420'
       gb='Deficient < 400'
       gc='Deficient < 350'
       quart='Glutamine Quartiles';


format ga gb gc deficient. quart quart.;
keep id GlutamicAcid Glutamine ga gb gc quart;

run;

proc univariate freq;
  var glutamine;
run;



proc sort data=glutamine_full; by id; run;
proc sort data= glnd.status; by id; run;

libname t '';
data t.deficient;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
	        glnd.status (keep = id hospital_death mortality_6mo)
	        
			;
	by id;
if has_glutamine;
run;
title Mortality vs. Baseline Glutamine Deficiency;
ods pdf file='deficient.pdf';
proc freq;
    tables (ga gb gc )*(hospital_death mortality_6mo) / chisq;
    tables quart*(hospital_death mortality_6mo) / chisq trend;
run;
proc logistic;
   class ga /desc;
   model hospital_death(event='1')= ga/ risklimits;
run;

proc logistic;
class gb / desc;
   model hospital_death(event='1')= gb/ risklimits;
run;

proc logistic;
class gc /desc;
   model hospital_death(event='1')= gc/ risklimits;
run;

proc logistic;
class quart / desc;
   model hospital_death(event='1')= quart/ risklimits;
run;


proc logistic;
class ga /desc;
   model mortality_6mo(event='1')= ga/ risklimits;
run;

proc logistic;
  class gb /desc;
   model mortality_6mo(event='1')= gb/ risklimits;
run;

proc logistic;
class gc / desc;
   model mortality_6mo(event='1')= gc/ risklimits;
run;

proc logistic;
class quart / desc ;
   model mortality_6mo(event='1')= quart/ risklimits;
run;
ods pdf close;



