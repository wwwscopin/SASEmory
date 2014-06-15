
options pagesize= 60 linesize = 85 orientation=portrait;
 	*clear out the graphs catalog;

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;

proc format;
  value deficient
   1='Above'
   0='Not Above'
   ;

data glutamine_full;
	set glnd_ext.glutamine;

glutamine=round(glutamine);	
	
if visit=0;
if glutamine eq . then delete;
if glutamine>600 then ga=1; else ga=0;
	if glutamine>750 then gb=1; else gb=0;
	if glutamine>930 then gc=1; else gc=0;
	if glutamine>1000 then gd=1; else gd=0;
  
  label ga='>600'
        gb='>750'
        gc='>930'
        gd='>1000'
;


format ga gb gc gd deficient.;
keep id GlutamicAcid Glutamine ga gb gc gd;

run;

proc sort data=glutamine_full; by id; run;
proc sort data= glnd.status; by id; run;

data final;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
	        glnd.status (keep = id hospital_death mortality_6mo)
	        
			;
	by id;
if has_glutamine;
run;
title Mortality vs. Baseline Glutamine ;
ods pdf file='deficient1.pdf';
proc freq;
    tables (ga gb gc gd )*(hospital_death mortality_6mo) / chisq; 
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
class gd/desc;
   model hospital_death(event='1')= gc/ risklimits;
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
class gd / desc;
   model mortality_6mo(event='1')= gc/ risklimits;
run;

ods pdf close;



