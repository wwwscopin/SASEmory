proc format ;
  
  value yn   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value gender   99 = "Blank"
                 1 = "Male"
                 2 = "Female"
                 3 = "Ambiguous" ;
  value race   99 = "Blank"
                 1 = "Black"
                 2 = "American Indian or Alaskan Native"
                 3 = "White"
                 4 = "Native Hawaiian or Other Pacific Islander"
                 5 = "Asian"
                 6 = "More than one race"
                 7 = "Other" ;
 
  value result   99 = "Blank"
                 1 = "Not detected"
                 2 = "Low positive ( < 300 copies/ml)"
                 3 = "Positive ( > 300 copies /ml)"
                 4 = "Indterminate" ;
  value ig  99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inconclusive" ;



data p1;
  set cmv.plate_001;
  keep id mocinit enrollmentdate;
  if enrollmentdate ne .;
run;


data p3;
  set cmv.lbwi_urine_collection;
  p3=1;
  if dfseq=1;
  keep id urinesample urinesampledate p3;
run;

data p4;
  set cmv.plate_004;
  p4=1;
   if dfseq=1;
  keep id datenatsample dateserologysample natsample serologysample p4;
run;

data p5;
  set cmv.plate_005;
   if dfseq=1;
  p5=1;
  keep id p5 lbwidob lbwitob gender race;
run;

data p6;
  set cmv.plate_006;
   if dfseq=1;
  p6=1;
  keep id p6;
run;

data p7;
   set cmv.plate_007;
    if dfseq=1;
   p7=1;
   keep id p7;
run;

data p8;
   set cmv.plate_008;
    if dfseq=1;
   p8=1;
   keep id p8;
run;

data p9;
   set cmv.plate_009;
   p9=1;
   keep id p9;
run;

data p10;
   set cmv.plate_010;
    if dfseq=1;
   p10=1;
   keep id p10;
run;

data p11;
   set cmv.plate_011;
    if dfseq=1;
   p11=1;
   keep id p11; 
run;

data p12;
   set cmv.plate_012;
    if dfseq=1;
   p12=1;
   keep id p12;
run;

data p15;
   set cmv.plate_015;
    
   p15=1;
   if dfseq=1;
   keep id p15;
run;

data p16;
   set cmv.plate_016;
   p16=1;
   if dfseq=1;
   keep id p16;
run;

data p17;
   set cmv.lbwi_blood_collection;
   p17=1;
   if dfseq=1;
   keep id p17 natbloodcollect natblooddate;
run;

data p200;
   set cmv.LBWI_Urine_NAT_Result;
   p200=1;
   if dfseq=1;
   keep id p200 urinetestresult;
run;

data p201;
   set cmv.LBWI_blood_NAT_result;
   p201=1;
   if dfseq=1;
   keep id p201 nattestresult;
run;
   
data p203;
   set cmv.moc_nat;
   p203=1;
   if dfseq=1;
   nattestresultmoc=nattestresult;
   keep id p203 nattestresultmoc;
run;

data p204;
   set cmv.moc_sero;
   p204=1;
   if dfseq=1;
   keep id p204 ComboTestResult IgMTestResult;
run;

data init;
   merge p1 p3 p4 p5 p6 p7 p8  p10 p11 p12 p15 p16 p17 p200 p201 p203 p204 ;
   by id;
   array p(16) p3 p4 p5 p6 p7 p8  p10 p11 p12 p15 p16 p17 p200 p201 p203 p204;
   do i=1 to 16;
     if p(i)=. then p(i)=0;
   end;
   drop i;
    format p3 p4 p5 p6 p7 p8 p10 p11 p12 p15 p16  p200 p201 p203 p204
       natsample serologysample urinesample natbloodcollect yn.
           gender gender. race race. urinetestresult nattestresult
           nattestresultmoc result. combotestresult igmtestresult ig.;
   lbwidemo=p5+p6;
   mocdemo=p7+p8;
   snap=p12+p10+p11;
   p15p16=p15+p16;
   
run;
   
*proc print;


data p15;
   set cmv.plate_015;
   p15=1;
   if dfseq ne 1;
   keep id p15 dfseq;
run;
proc sort; by id dfseq;

data p16;
   set cmv.plate_016;
   p16=1;
   if dfseq ne 1;
   keep id p16 dfseq;
run;
proc sort; by id dfseq;

data p18;
   set cmv.snap2;
   p18=1;
   if dfseq ne 1;
   keep id p18 dfseq;
run;
proc sort; by id dfseq;

data f4;
  merge p15 p16 p18;
   by id dfseq;
   if dfseq=4;
   f4=sum(p15,p16,p18);
   keep id  f4;
run;


data p20;
   set cmv.plate_020;
   p20=1;
   if dfseq ne 1;
   keep id p20 dfseq;
run;
proc sort; by id dfseq;
    
 
data p21;
   set cmv.plate_021;
   p21=1;
   if dfseq ne 1;
   keep id p21 dfseq;
run;
proc sort; by id dfseq;

data p22;
   set cmv.plate_022;
   p22=1;
   if dfseq ne 1;
   keep id p22 dfseq;
run;
proc sort; by id dfseq;

data p22;
   set cmv.plate_022;
   p22=1;
   if dfseq ne 1;
   keep id p22 dfseq;
run;
proc sort; by id dfseq;

data p19;
   set cmv.bm_collection;
   p19=1;
   if dfseq ne 1;
   keep id p19 dfseq;
run;
proc sort; by id dfseq;

**** need to add plate205;


data f7;
  merge p15 p16 p18 p20 p21 p22 p19;
   by id dfseq;
   if dfseq=7;
   f7=sum(p15,p16,p18,p20,p21,p22);
   f7optional=p19;
   keep id  f7 f7optional;
run;

data f14;
  merge p15 p16 p18 p20 p21 p22 ;
   by id dfseq;
   if dfseq=14;
   f14=sum(p15,p16,p18,p20,p21,p22);
 
   keep id  f14;
run;
data p17;
   set cmv.lbwi_blood_collection;
   p17=1;
   if dfseq ne 1;
   keep id p17 dfseq natbloodcollect natblooddate;
run;
proc sort; by id dfseq;
data p201;
   set cmv.LBWI_blood_NAT_result;
   p201=1;
   if dfseq ne 1;
   keep id p201 dfseq nattestresult;
run;
proc sort; by id dfseq;


   
data p203;
   set cmv.moc_nat;
   p203=1;
   if dfseq ne 1;
   nattestresultmoc=nattestresult;
   keep id p203 nattestresultmoc dfseq;
run;


data p105;
   set cmv.endofstudy;
   p105=1;
   if dfseq ne 1;
   keep id p105 dfseq studyleftdate;
run;
proc sort; by id dfseq;

data p200;
   set cmv.LBWI_Urine_NAT_Result;
   p200=1;
   if dfseq ne 1;
   keep id p200 urinetestresult dfseq;
run;

data f21;
  merge p15 p16 p17 p18 p20 p21 p22 p19 p201;
   by id dfseq;
   if dfseq=21;
   f21=sum(p15,p16,p17,p18,p20,p21,p22);
   length f21optional $ 20;
   f21optional=' ';
     if p19=1 then f21optional='Plate19 ';
     if p201=1 then f21optional=strip(f21optional)||' Plate201';
   
   keep id  f21 f21optional ;
run;

data f25;
  set p9;
  f25=1;
  keep id f25;

data f28;
  merge p15 p16 p18 p20 p21 p22 p19;
   by id dfseq;
   if dfseq=28;
   f28=sum(p15,p16,p18,p20,p21,p22);
   f28optional=p19;
   keep id  f28 f28optional;
run;


data f40;
  merge p15 p16 p17 p18 p20 p21 p22 p19 p201;
   by id dfseq;
   if dfseq=40;
   f40=sum(p15,p16,p17,p18,p20,p21,p22);
   length f40optional $ 20;
   f40optional=' ';
     if p19=1 then f40optional='Plate19 ';
     if p201=1 then f40optional=strip(f40optional)||' Plate201';
   
   keep id  f40 f40optional ;
run;

data f60;
  merge p15 p16 p17 p18 p20 p21 p22  p201;
   by id dfseq;
   if dfseq=60;
   f60=sum(p15,p16,p17,p18,p20,p21,p22);
   length f60optional $ 20;
   f60optional=' ';
   if p201=1 then f60optional='Plate201 ';
   keep id  f60 f60optional ;
run;


* f90 is 105
    optional 3,17, 20-23 200,201,203;

 data f90;
   merge p105 p20 p21 p22 p201 p200 p203 ;
   by id dfseq;
   if dfseq=63;
   f90optional=sum(p20,p21,p22,p201,p200,p203);
   f90=p105;
   keep id f90 f90optional;
run;

data p68;
   set cmv.plate_068;
   p68=1;
   if dfseq =75;
   keep id p68;
run;
data p69;
   set cmv.plate_069;
   p69=1;
   if dfseq =75;
   keep id p69;
run;
data p18a;
   set cmv.snap2;
   p18=1;
   if dfseq =75;
   keep id p18;
run;

data ivh;
  merge p68 p69 p18a;
  by id;
  ivh=sum(p68,p18,p69);
  keep id ivh;  
run;

data bpd;
  set cmv.bpd;
  bpd=1;
  if dfseq=78;
  keep id bpd;
run;

data rop;
  set cmv.rop;
  rop=1;
  if dfseq=80;
  keep id rop;
run;

data pda;
  set cmv.pda;
  pda=1;
  if dfseq=83;
  keep id pda;
run;
   
data ubnat;
  set p200;
  if 85 <=dfseq<=89 ;
  keep id p200;
run;
proc means noprint;
 by id;
 var p200;
 output out=ubnat1 sum=ubnat;
run;

  data uunat;
  set p201;
  if 91 <=dfseq<=95 ;
  keep id p201;
run;
proc means noprint;
 by id;
 var p201;
 output out=uunat1 sum=uunat;
run;

data umnat;
  set p203;
  if 96 <=dfseq<=100 ;
  keep id p203;
run;
proc means noprint;
 by id;
 var p203;
 output out=umnat1 sum=umnat;
run;

data un;
  merge ubnat1 uunat1 umnat1;
  by id;
  drop _freq_ _type_; 
  un=sum(ubnat, uunat, umnat);
run;

data rbc;
  set cmv.plate_031;
  p31=1;
  if 101<=dfseq<=130 ;
  keep id p31;
run;
proc means noprint;
  by id;
  var p31;
  output out=rbc1 sum=rbc;
run;
data rbc2;
   set rbc1;
   keep id rbc;
run;

*** From status.sas;
 
data eos;
   set cmv.endofstudy;
   leftstudy=1;
   keep id StudyLeftDate leftstudy Reason;
run;

data status;
  merge p1 eos;
  by id;
  *  for now if no eos then set date to be today;
  if StudyLeftDate eq . then StudyLeftDate=today();
  fdays=StudyLeftDate-enrollmentdate;
run;

data mech;
  merge cmv.mechvent (in=a) status;
  by id;
  if a;
  array startd(10) startdate1-startdate10;
  array endd(10) enddate1-enddate10;
  
  if startd(1) ne . then do;
  do i=1 to 10;
      if startd(i) ne . then last=i;
  end;
  
  vdays=0;
  do i=1 to last;
     if endd(i) eq . then endd(i)=StudyLeftDate;
     vdays=vdays+(endd(i)-startd(i));
  end;
  
  if vdays > fdays then vdays=fdays;
  vfreedays=fdays-vdays;
  end;
  else do;
*  if mechvent form empty assume never on vent;
   vdays=0;
   vfeeedays=0;
  end;

 keep vdays vfreedays vdays id last;
run;
 
 
**** breast milk;
data milk;
   set cmv.breastfeedlog;
   array startd(15) startdate1-startdate15;
   array endd(15) enddate1-enddate15;
   array mtype(15) milktype1-milktype15;
   milk=1;
   milkdays=0;
   fresh=0;
   frozen=0;
   freshdays=0;
   frozendays=0;
   
   do i=1 to 15;
       if startd(i) ne . then do;
            days=endd(i)-startd(i);
            if days=. then days=1;
            *** at least one day;
            milkdays=milkdays+days;
            if mtype(i)=1 then do;
                  fresh=1;
                  freshdays=freshdays+days;
            end;
            if mtype(i)=2 then do;
                  frozen=1;
                  frozendays=frozendays+days;
            end;
       end;
   end;
  
   keep id milk milkdays;
   *****
   there is a problem on the form for type
   many may have said both types and we only allow one
   
   For now do not say whether fresh or frozen;

**** vasopressor;
data vaso;
   set cmv.vasopressor;
  
  array td(20) treatmentdate1-treatmentdate20;
  array dos(20) dose1-dose20;
  array ti(20) time_hr1-time_hr20;
  do i=1 to 20;
      if td(i) >. or dos(i) >. or ti(i) > . then nvaso=i;
  end;
  keep id nvaso;
   label nvaso='No. of Vasopressor Treatments';
  proc sort; by id;
  proc means noprint;
 by id;
 var nvaso;
 output out=vaso1 sum=nvaso;
data vaso2;
  set vaso1;
  keep id nvaso;
data status1;
  merge status mech milk vaso2;
  by id;
  length mvent $ 3;
  if last eq . then mvent='No' ;
     else mvent='Yes';
  drop last;
   label vdays='Days on Ventilator'
         fdays='Days Followed'
         vfreedays='Ventilator Free Days'
         mvent='Ever on Ventilator'
         milk='Ever Breast Fed'
         milkdays='Days Breast Fed'
         leftstudy='Left Study';
   format milk leftstudy yn.;
   if milk=. then milk=0;
   if leftstudy=. then leftstudy=0;
    StudyLeftDate7=StudyLeftDate+7;
   if nvaso=. and today() > StudyLeftDate7 then nvaso=0; 
   status=1;
       drop studyleftdate7 enrollmentdate mocinit;
run;
 

   
data trans;
  set cmv.pdeviation;
  trans=1;
  TransferDate=max(TransferDate1,TransferDate2,TransferDate3,
      TransferDate4, TransferDate5, TransferDate6);
  format TransferDate mmddyy.;
  label TransferDate='Last Transfer Date';
 keep id trans transferdate;
 
data followup;
   merge f4 f7 f14 f21 f25 f28 f40 f60 ivh bpd rop pda f90 rbc2 status1  un trans;
    
    by id;
 
run;

data cmv.status;
    merge init followup;
    by id;
 
    if status=1;
    label p3='LBWI: Urine Collection'
          p4='MOC Blood Collection'
          f4='# Day 4 Forms'
          f7='# Day 7 Forms'
          f14='# Day 14 Forms'
          f21='# Day 21 Forms'
          f28='# Day 28 Forms'
          f40='# Day 40 Forms'
          f60='# Day 60 Forms'
          f90='# Day 90 Forms' 
;          
run;
