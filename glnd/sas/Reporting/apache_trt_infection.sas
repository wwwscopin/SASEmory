
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

data infect;
		set	glnd_rep.all_infections_with_adj; by id;
	
		if compress(site_code)="UTI" and compress(type_code) = "ASB" then delete;
		if compress(site_code)="BSI"  then bsi=1;  
		if compress(site_code)="CVS"  then cvs=1; 
		if compress(site_code)="GI"   then gi=1;  
		if compress(site_code)="PNEU" then lri=1; 
		if compress(site_code)="SSI"  then ssi=1; 
		if compress(site_code)="UTI"  then uti=1; 

		
		if not bsi then nbsi=1;
        any=1;
run;

proc sort nodupkey; by id; run;


data apache;
        merge glnd.george (keep = id treatment in=A)
        glnd.plate6(keep=id apache_total rename=(apache_total=ap0))
        glnd.plate6b(keep=id apache_total rename=(apache_total=ap1))
        glnd.basedemo(keep=id age gender)
        glnd.status (keep = id deceased dt_death dt_discharge)
        infect(keep=id any rename=(any=infect))
        glu; 
        by id;
        
        if infect=. then infect=0;
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
            
        if apachese4 in (1,2)  then apa2=1; else apa2=2;
            
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
    tables apachese4*infect*treatment/chisq trend cmh;
    exact trend;
run;

proc logistic data=apache;
    model infect(event="1")=ap1/aggregate rsquare clodds=wald;
    unit ap1=5;
run;

proc logistic data=apache;
    class apachese4(param=ref ref="1") treatment(ref=last)/param=ref ;
    model infect(event="1")=apachese4 treatment apachese4*treatment/aggregate rsquare;
     
    exact treatment apachese4*treatment/ estimate = both;        
    oddsratio apachese4;
    oddsratio treatment;
run;

proc logistic data=apache;
    class apa2(param=ref ref="1") treatment(ref=last)/param=ref ;
    model infect(event="1")=apa2 treatment apa2*treatment/aggregate rsquare;
     
    exact treatment apa2*treatment/ estimate = both;        
    oddsratio apa2;
    oddsratio treatment;
run;
