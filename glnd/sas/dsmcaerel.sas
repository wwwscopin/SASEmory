data x;
 set glnd.status;
 if dt_random ge mdy(4,1,2008);
trta=0;
if treatment=1 then trta=1;
trtb=0;
if treatment=2 then trtb=1; 
 
proc means noprint;
 var trta trtb;
 output out=sum sum=na nb;

data sum1;
 set sum;
 n=na+nb;
call symput('na',na);
call symput('nb',nb);
call symput('n',n);

 %put &na;
 %put &nb;
 %put &n;


data x;
 set glnd.dsmcaerel;
if _n_=5 then do;
casea=input(aae,4.);
pata=substr(aae,6,3)+0;
caseb=input(bae,4.);
patb=substr(bae,6,3)+0;
case=input(tae,4.);
pat=substr(tae,6,3)+0;

pcta=round(pata*100/&na,.1);
    pctb=round(patb*100/&nb,.1);
     pct=round(pat*100/&n,.1);
     
     temp=compress("("||put(pata,2.)||"/&na)");
     aae="  "||compress(put(casea,3.)||temp)||put(pcta,5.1)||'%';
     temp=compress("("||put(patb,2.)||"/&nb)");
     bae="  "||compress(put(caseb,3.)||temp)||put(pctb,5.1)||'%';
     temp=compress("("||put(pat,2.)||"/&n)");
     tae="  "||compress(put(case,3.)||temp)||put(pct,5.1)||'%';
    
end;
 drop temp casea--pat pcta pctb pct ;
proc print noobs;
 
run;
data glnd.dsmcaerel;
 set x;
 run;
title "wbh";
proc print;run;
