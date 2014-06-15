
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

/*
proc means data =glnd.plate6 Q1 median Q3 maxdec=1;
var apache_total;
output out=wbh Q1(apache_total)=a1 median(apache_total)=a2 Q3(apache_total)=a3;
run;

data _null_;
    set wbh;
    call symput("ap1", compress(a1));
        call symput("ap2", compress(a2));
            call symput("ap3", compress(a3));
run;
*/

proc means data =glnd.plate6b Q1 median Q3 maxdec=1;
var apache_total;
output out=wbh Q1(apache_total)=a1 median(apache_total)=a2 Q3(apache_total)=a3;
run;

data _null_;
    set wbh;
    call symput("ap1", compress(a1));
        call symput("ap2", compress(a2));
            call symput("ap3", compress(a3));
run;


data glu;
	set glnd_ext.glutamine(drop=day);

	keep id GlutamicAcid Glutamine visit;
	rename visit=day;
	where visit=0;
run;

proc means data =glu Q1 median Q3 maxdec=1;
var glutamine;
output out=wbh Q1(glutamine)=a1 median(glutamine)=a2 Q3(glutamine)=a3;
run;

data _null_;
    set wbh;
    call symput("g1", compress(round(a1)));
        call symput("g2", compress(round(a2)));
            call symput("g3", compress(round(a3)));
run;


data apache;
        merge glnd.george (keep = id treatment in=A)
        glnd.plate6(keep=id apache_total rename=(apache_total=ap0))
        glnd.plate6b(keep=id apache_total rename=(apache_total=ap1))
        glnd.basedemo(keep=id age gender)
        glnd.status (keep = id deceased dt_death dt_discharge)
        glu; 
        by id;
        
        if A;
        if deceased & (dt_death <= dt_discharge) then hdeath = 1 ; else hdeath = 0;
        
        if 0<ap0<=11 then apa4=1;
            else if ap0<=16 then apa4=2;
            else if ap0<=20 then apa4=3;
            else apa4=4;   
            
        if 0<ap1<=&ap1 then apachese4=1;
            else if &ap1<ap1<=&ap2 then apachese4=2;
            else if &ap2<ap1<=&ap3 then apachese4=3;
            else apachese4=4; 
            
        if  round(glutamine)<&g1 then glu=1;
            else if &g1<=round(glutamine)<=&g2 then glu=2;
            else if &g2<round(glutamine)<=&g3 then glu=3;
            else if &g3<round(glutamine) then glu=4;
        
        if glutamine=. then glu=.;

   	if glutamine<420 then ga=1; else ga=0;
	if glutamine<400 then gb=1; else gb=0;
	if glutamine>930 then gc=1; else gc=0;
	if glutamine<400 or glutamine>930 then gd=1; else gd=0;
run;

proc freq data=apache; 
    tables glu*hdeath/chisq trend;
    *tables apa4*(hdeath deceased)/chisq trend;
    tables apachese4*(hdeath deceased)/chisq trend;
    tables apachese4*hdeath*treatment/chisq trend cmh;
    exact trend;
run;

proc logistic data=apache;
    class apa4(param=ref ref="1") apachese4(param=ref ref="1") treatment(ref=last)/param=ref ;
    *model hdeath(event="1")=apa4 treatment apa4*treatment/aggregate rsquare;
    model hdeath(event="1")=apachese4 treatment apachese4*treatment/aggregate rsquare;
     
    exact treatment apachese4*treatment/ estimate = both;        
    oddsratio apachese4;
    oddsratio treatment;
run;

proc logistic data=apache;
    model hdeath(event="1")=ap1/aggregate rsquare clodds=wald;
    unit ap1=5;
run;
proc logistic data=apache;
    class treatment(ref=last)/param=ref ;
    model hdeath(event="1")=ap1 treatment /*ap1*treatment*/ /aggregate rsquare clodds=wald;
    *exact ap1 /estimate = both ;
    oddsratio ap1;
    unit ap1=5;
run;


proc logistic data=apache;
    class glu(param=ref ref="1")/param=ref ;
    model hdeath(event="1")=glu/aggregate rsquare;   
run;


proc genmod data =apache descending;
	class id glu; 	
	model hdeath=glu/dist=bin; 
    *repeated subject=id / corr=unstr corrw;
    repeated subject=id / corr=exch;
    estimate 'Beta' glu -1 1 0 0/ exp;
    estimate 'Beta' glu -1 0 1 0/ exp;
    estimate 'Beta' glu -1 0 0 1/ exp;
run;


/*
proc genmod data =apache descending;
	class id glu; 	
	model hdeath=glu/dist=bin; 
    *repeated su
bject=id / corr=unstr corrw;
    repeated subject=id / corr=exch;
    estimate 'Beta' glu -1 1 0 0/ exp;
    estimate 'Beta' glu -1 0 1 0/ exp;
    estimate 'Beta' glu -1 0 0 1/ exp;
run;

proc genmod data =apache descending;
	class id ga; 	
	model hdeath=ga/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' ga -1 1 / exp;
run;

proc genmod data =apache descending;
	class id gb; 	
	model hdeath=gb/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gb -1 1 / exp;
run;

proc genmod data =apache descending;
	class id gc; 	
	model hdeath=gc/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gc -1 1 / exp;
run;
proc genmod data =apache descending;
	class id gd; 	
	model hdeath=gd/dist=bin; 
    repeated subject=id / corr=exch;
    estimate 'Beta' gd -1 1 / exp;
run;

proc genmod data =apache descending;
	class id gd; 	
	model hdeath=age gender ap1 glutamine/dist=bin; 
    repeated subject=id / corr=exch;
run;
*/
