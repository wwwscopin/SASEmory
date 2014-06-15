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
 
    
 data dall;
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
    
    *** get aedays;
    %inc'aedays.sas';
    data glnd.dsmcaeall;
     merge dall aedays;
     by ae;
     maedaysa='    ';
     if maedays1 ne . then maedaysa=put(maedays1,5.0);
     maedaysb='    ';
      if maedays2 ne . then maedaysb=put(maedays2,5.0);
     maedayst='    ';
      if maedays ne . then maedayst=put(maedays,5.0);
      label maedaysa='Days From Enrollment A (median)'
                maedaysb='Days From Enrollment B (median)'
                maedayst='Days From Enrollment  (median)'; 
    drop maedays1 maedays2 maedays;
    
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
    var ae tae maedayst;
     
     run;
     
     
     title Open Session AE Potentially Related to Glutamine;
     
   proc print noobs label data=glnd.dsmcaerel;
    var ae tae maedayst;
     
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
     
     
     run;
     
     **** now sae;
     
     
options ls=80 ps=54;

*proc print data=glnd.sae_cases;

*proc print data=glnd.sae_patients;



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
 
    
 data saeall;
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
    
    **** get saedays;
    
    %inc'saedays.sas';
    
     data glnd.dsmcsaeall;
     merge saeall saedays;
     by sae;
     msaedaysa='    ';
     if msaedays1 ne . then msaedaysa=put(msaedays1,5.0);
     msaedaysb='    ';
      if msaedays2 ne . then msaedaysb=put(msaedays2,5.0);
     msaedayst='    ';
      if msaedays ne . then msaedayst=put(msaedays,5.0);
      label msaedaysa='Days From Enrollment A (median)'
                msaedaysb='Days From Enrollment B (median)'
                msaedayst='Days From Enrollment B (median)'; 
    drop msaedays1 msaedays2 msaedays;
    
    
    
    
     ods pdf file='dsmcsaeopen.pdf';
     ods ps file='dsmcsaeopen.ps';
     
     title Open Session SAE;
     
   proc print noobs label data=glnd.dsmcsaeall;
    var sae tsae msaedayst;
     
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
     