

%let mu=%sysfunc(byte(181));

/*
proc means data =glnd.plate6 Q1 median Q3;
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

proc means data =glnd.plate6b Q1 median Q3;
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

proc means data =glu Q1 median Q3;
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
            else if &g1<=round(glutamine)<&g2 then glu=2;
            else if &g2<=round(glutamine)<&g3 then glu=3;
            else if &g3<=round(glutamine) then glu=4;

   	if glutamine<420 then ga=1; else ga=0;
	if glutamine<400 then gb=1; else gb=0;
	if glutamine>930 then gc=1; else gc=0;
	if glutamine<400 or glutamine>930 then gd=1; else gd=0;
ap15=ap1/5;
ap110=ap1/10;
 apmedian=0;
if apachese4 > 2 then apmedian=1;
run;
proc sort; by apachese4;
ods ps file='ap.ps';
ods pdf file='ap.pdf';
proc logistic;
  class treatment (ref=last);
  model hdeath(event="1")= treatment ;
 by apachese4;
run;

proc logistic;
  class treatment (ref=last);
  model hdeath(event="1")= treatment ;
 by apmedian;
run;
ods pdf close;
ods ps close;

endsas;
proc sort; by treatment;
proc freq data=apache; 
   by treatment;
    
    tables apachese4*(hdeath )/chisq trend;
   
    exact trend;
run;

proc logistic data=apache;
    class apa4(param=ref ref="1") apachese4(param=ref ref="1") treatment(ref=last);
  
   model hdeath(event="1")=apachese4 treatment apachese4*treatment;
       oddsratio apachese4;
run;


proc logistic data=apache;
    class apa4(param=ref ref="1") apachese4(param=ref ref="1") treatment(ref=last);
  
 
model hdeath(event="1")=apachese4 treatment  ;
    oddsratio apachese4;
run;

proc logistic data=apache;
    class apa4(param=ref ref="1") apachese4(param=ref ref="1") treatment(ref=last);
  
 
model hdeath(event="1")=apachese4 ;
    oddsratio apachese4;
run;

proc logistic data=apache;
  class treatment(ref=last);
  
 
model hdeath(event="1")=ap1 treatment ap1*treatment ;
   
run;

proc logistic data=apache;
 class  treatment(ref=last);
  
 
model hdeath(event="1")=ap1 treatment  ;
   
run;

proc logistic data=apache;
 class  treatment(ref=last);
  
 
model hdeath(event="1")=ap15 treatment;
   
run;



proc logistic data=apache;
 class  treatment(ref=last);
  
 
model hdeath(event="1")=ap110 treatment;
   
run;
