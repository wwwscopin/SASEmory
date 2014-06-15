/*proc contents data=glnd.ae_patients;
proc contents data=glnd.ae_cases;

proc contents data=glnd.sae_patients;
proc contents data=glnd.sae_cases;
*/;
options ls=80 ps=54;

**** first get total # of patients at for each group;

proc means data=glnd.ae_patients noprint;
where treatment=1;
var ae1-ae17;
output out=aae sum=aae1-aae17;
run;
proc means data=glnd.ae_patients noprint;
where treatment=2;
var ae1-ae17;
output out=bae sum=bae1-bae17;
run;
data pae;
merge aae bae;
format aae1-aae17 bae1-bae17;
array ae(17) ae1-ae17;
array bae(17);
array aae(17);
  do i=1 to 17;
     ae(i)=aae(i)+bae(i);
  end;
  drop i;
 run;
 title;
 **** now do cases;
 
 data caae;
  set glnd.ae_cases;
  if treatment=1;
  array ae(17) ae1-ae17;
  array caae(17) caae1-caae17;
  do i=1 to 17;
      caae(i)=ae(i);
  end;
   drop i ae1-ae17;
  run;
  data cbae;
  set glnd.ae_cases;
  if treatment=2;
  array ae(17) ae1-ae17;
  array cbae(17) cbae1-cbae17;
  do i=1 to 17;
      cbae(i)=ae(i);
  end;
   drop i ae1-ae17;
  run;
  
  
  data cae;
  set glnd.ae_cases;
  if treatment=.;
  array ae(17) ae1-ae17;
  array cae(17) cae1-cae17;
  do i=1 to 17;
      cae(i)=ae(i);
  end;
   drop i ae1-ae17;
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
  
  
  
  data ae;
   merge pae caae cbae cae na nb;
   n=na+nb;
   an='n='||put(n,2.);
     put an;
     call symput('n',an);
     %global n;
     %put &n;
   drop treatment;
   data aeout;
    set ae;
   array ae(17) ae1-ae17;
array bae(17);
array aae(17);
array cae(17) cae1-cae17;
array caae(17) caae1-caae17;
array cbae(17) cbae1-cbae17;
do i=1 to 17;
    pata=aae(i);
    casea=caae(i);
    patb=bae(i);
    caseb=cbae(i);
    pat=ae(i);
    case=cae(i);
    output;
 end;
 keep i pata--case na nb n;
 
    
 data glnd.dsmcaeall;
 set aeout;
  ae=i;
   drop i;
   format ae ae.;
   label ae='Adverse Event';
   pcta=round(pata*100/na,.1);
    pctb=round(patb*100/nb,.1);
     pct=round(pat*100/n,.1);
     
     aae=put(casea,4.)||'('||put(pata,3.)||')'||put(pcta,5.1)||'%';
     bae=put(caseb,4.)||'('||put(patb,3.)||')'||put(pctb,5.1)||'%';
     tae=put(case,4.)||'('||put(pat,3.)||')'||put(pct,5.1)||'%';
     label aae="Treatment A &a ";
     label bae="Treatment B &b ";
     label tae="Total &n ";
     keep aae bae tae ae;
    run;
    
    data glnd.dsmcaeunrel;
     set glnd.dsmcaeall;
     
     if ae in (9,10,15,17) then delete;
    run;
    data glnd.dsmcaerel;
     set glnd.dsmcaeall;
     
     if ae in (9,10,15,17) ;
    run;
     
     ods pdf file='dsmcaeopen.pdf';
     ods ps file='dsmcaeopen.ps';
     
     title Open Session AE Unrelated to Glutamine;
     
   proc print noobs label data=glnd.dsmcaeunrel;
    var ae tae;
     
     run;
     
     
     title Open Session AE Potentially Related to Glutamine;
     
   proc print noobs label data=glnd.dsmcaerel;
    var ae tae;
     
     run;
     ods ps close;
     ods pdf close;
     
     
     
      ods pdf file='dsmcaeclosed.pdf';
     ods ps file='dsmcaeclosed.ps';
     
     title CLOSED Session AE Unrelated to Glutamine;
     
   proc print noobs label data=glnd.dsmcaeunrel;
    var ae aae bae tae;
     
     run;
     
     
     title CLOSED Session AE Potentially Related to Glutamine;
     
   proc print noobs label data=glnd.dsmcaerel;
    var ae aae bae tae;
     
     run;
     ods ps close;
     ods pdf close;
     