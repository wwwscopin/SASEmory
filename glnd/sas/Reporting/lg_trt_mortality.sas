
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

data glutamine_full;
	set glnd_ext.glutamine(drop=day);

	keep id GlutamicAcid Glutamine visit;
	rename visit=day;
run;

proc means data =glutamine_full(where=(day=0)) Q1 median Q3;
var glutamine;
output out=wbh Q1(glutamine)=a1 median(glutamine)=a2 Q3(glutamine)=a3;
run;

data _null_;
    set wbh;
    call symput("g1", compress(round(a1)));
        call symput("g2", compress(round(a2)));
            call symput("g3", compress(round(a3)));
run;

%put &g1;
%put &g2;
%put &g3;

data glutamine_group;
    set glutamine_full(where=(day=0));
    if  round(glutamine)<&g1 then glu=1;
        else if &g1<=round(glutamine)<=&g2 then glu=2;
        else if &g2<round(glutamine)<=&g3 then glu=3;
        else if &g3<round(glutamine) then glu=4;
        if glutamine=. then delete;
        keep id glu glutamine;
run;

proc sort data=glutamine_group;by id; run;
proc sort data=glutamine_full; by id; run;
proc sort data= glnd.george; by id; run;

data glutamine_full;
	merge 	glutamine_full (in = has_glutamine)
        	glutamine_group
			glnd.george (keep = id treatment)
	        glnd.status (keep = id deceased dt_death dt_discharge)
	        glnd.plate6b(keep=id apache_total)
	        glnd.basedemo(keep=id age gender)
			;
	by id;

	if ~has_glutamine then delete;
	
	if deceased & (dt_death <= dt_discharge) then hdeath = 1 ; else hdeath = 0;

	if glutamine<420 then ga=1; else ga=0;
	if glutamine<400 then gb=1; else gb=0;
	if glutamine>930 then gc=1; else gc=0;
	if glutamine<400 or glutamine>930 then gd=1; else gd=0;
run;

proc freq data=glutamine_full(where=(day=0)); 
    tables glu*hdeath/trend;
run;


proc genmod data =glutamine_full descending;
	class id glu; 	
	model hdeath=glu/dist=bin; 
    *repeated subject=id / corr=unstr corrw;
    repeated subject=id / corr=exch;
    estimate 'Beta' glu -1 1 0 0/ exp;
    estimate 'Beta' glu -1 0 1 0/ exp;
    estimate 'Beta' glu -1 0 0 1/ exp;
run;

proc genmod data =glutamine_full descending;
	class id ga; 	
	model hdeath=ga/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' ga -1 1 / exp;
run;

proc genmod data =glutamine_full descending;
	class id gb; 	
	model hdeath=gb/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gb -1 1 / exp;
run;

proc genmod data =glutamine_full descending;
	class id gc; 	
	model hdeath=gc/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gc -1 1 / exp;
run;
proc genmod data =glutamine_full descending;
	class id gd; 	
	model hdeath=gd/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gd -1 1 / exp;
run;

proc genmod data =glutamine_full descending;
	class id gd; 	
	model hdeath=age gender apache_total glutamine/dist=bin; 
    repeated subject=id / corr=exch;
run;
