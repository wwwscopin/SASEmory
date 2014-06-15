
options ls=80 ps=54;
/*
proc print data=glnd.sae_cases;

proc print data=glnd.sae_patients;

*/;

**** first get total # of patients at for each group;

proc means data=glnd.sae_patients noprint;
where treatment=1;
var sae1-sae8;
output out=asae sum=asae1-asae8;
run;
proc means data=glnd.sae_patients noprint;
where treatment=2;
var sae1-sae8;
output out=bsae sum=bsae1-bsae8;
run;
data psae;
merge asae bsae;
format asae1-asae8 bsae1-bsae8;
array sae(8) sae1-sae8;
array bsae(8);
array asae(8);
  do i=1 to 8;
     sae(i)=asae(i)+bsae(i);
  end;
  drop i;
 run;
 title;
 **** now do cases;
 
 data casae;
  set glnd.sae_cases;
  if treatment=1;
  array sae(8) sae1-sae8;
  array casae(8) casae1-casae8;
  do i=1 to 8;
      casae(i)=sae(i);
  end;
   drop i sae1-sae8;
  run;
  data cbsae;
  set glnd.sae_cases;
  if treatment=2;
  array sae(8) sae1-sae8;
  array cbsae(8) cbsae1-cbsae8;
  do i=1 to 8;
      cbsae(i)=sae(i);
  end;
   drop i sae1-sae8;
  run;
  
  
  data csae;
  set glnd.sae_cases;
  if treatment=.;
  array sae(8) sae1-sae8;
  array csae(8) csae1-csae8;
  do i=1 to 8;
      csae(i)=sae(i);
  end;
   drop i sae1-sae8;
  run;
  data t;
  set glnd.status;
   keep id treatment;
 proc sort; by treatment;
 proc means noprint;
  by treatment;
   var id;
   output out=tr n=n;
   data na;
    set tr;
    if treatment=1;
    na=n;
    keep na;
    a='n='||put(na,2.);
     put a;
     call symput('a',a);
     %global a;
     %put &a;
    run;
    data nb;
    set tr;
    if treatment=2;
    nb=n;
    keep nb;
    b='n='||put(nb,2.);
     put b;
     call symput('b',b);
     %global b;
     %put &b;
    run;
  
  
  
  data sae;
   merge psae casae cbsae csae na nb;
   n=na+nb;
   an='n='||put(n,2.);
     put an;
     call symput('n',an);
     %global n;
     %put &n;
   drop treatment;
   data saeout;
    set sae;
   array sae(8) sae1-sae8;
array bsae(8);
array asae(8);
array csae(8) csae1-csae8;
array casae(8) casae1-casae8;
array cbsae(8) cbsae1-cbsae8;
do i=1 to 8;
    pata=asae(i);
    casea=casae(i);
    patb=bsae(i);
    caseb=cbsae(i);
    pat=sae(i);
    case=csae(i);
    output;
 end;
 keep i pata--case na nb n;
 
    
 data glnd.dsmcsaeall;
 set saeout;
  sae=i;
   drop i;
   format sae sae_type.;
   label sae='Adverse Event';
   if pata=. then pata=0;
   if patb=. then patb=0;
   if pat=. then pat=0;
   if casea=. then casea=0;
   if caseb=. then caseb=0;
   if case=. then case=0;
   pcta=round(pata*100/na,.1);
    pctb=round(patb*100/nb,.1);
     pct=round(pat*100/n,.1);
     
     asae=put(casea,4.)||'('||put(pata,3.)||')'||put(pcta,5.1)||'%';
     bsae=put(caseb,4.)||'('||put(patb,3.)||')'||put(pctb,5.1)||'%';
     tsae=put(case,4.)||'('||put(pat,3.)||')'||put(pct,5.1)||'%';
     label asae="Treatment A &a ";
     label bsae="Treatment B &b ";
     label tsae="Total &n ";
     keep sae asae bsae tsae;
    run;
    
     ods pdf file='dsmcsaeopen.pdf';
     ods ps file='dsmcsaeopen.ps';
     
     title Open Session SAE;
     
   proc print noobs label data=glnd.dsmcsaeall;
    var sae tsae;
     
     run;
     
     ods ps close;
     ods pdf close;
     
     
     
      ods pdf file='dsmcsaeclosed.pdf';
     ods ps file='dsmcsaeclosed.ps';
     
     title CLOSED Session SAE ;
     
   proc print noobs label data=glnd.dsmcsaeall;
    var sae asae bsae tsae;
     
     run;
     
     
     ods ps close;
     ods pdf close;
     