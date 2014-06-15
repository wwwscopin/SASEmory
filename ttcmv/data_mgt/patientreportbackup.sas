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
   
data status;
   set cmv.status;
   status=1;
   keep id nvaso milk leftstudy mvent status studyleftdate;
   
 
data followup;
   merge f4 f7 f14 f21 f25 f28 f40 f60 ivh bpd rop pda f90 rbc2 status  un ;
    
    by id;
 
run;

data all;
    merge init followup;
    by id;
    if status=1;
run;

data pat;
   infile 'patientreport.dat';
    input id;
run;

data single;
   merge all pat(in=a);
    by id;
    if a;
     
file 'patientreport.out';
   put;
   put @5 "ID = " id @20 "MOC Initials = " mocinit;
   put;
   put @5 "Date Enrolled" @20 Enrollmentdate;
   put @5 "Date of Birth" @20 lbwidob;
   put @5 "Time of Birth" @20 lbwitob;
   put @5 "Gender " @20 gender;
   put @5 "Race " @20 race;
   put;
   put @5 "Enrollment Blood and Urine";
   put @5 "--------------------------";
   put @5 "LBWI: Urine Collection Form  " p3;
   if p3=1 then do;
     put @10 "Was Urine Collected  " urinesample;
     if urinesample=1 then put @20 "Date  " urinesampledate;
   end;
   put @5 "MOC Blood Collection Form  " p4;
   if p4=1 then do;
     put @10 "Was Blood Collected for CMV NAT  " natsample;
     if natsample=1 then put @20 "Date  " datenatsample;
     put @10 "Was Blood Collected for CMV Serology  " serologysample;
     if serologysample=1 then put @20 "Date  " dateserologysample;
   end;   
   put;
   put @5 "Enrollment Forms";
   put @5 "------------------------------------------";
   put @10 "LBWI Demographic:" @40 lbwidemo " forms received";
   put @10 "MOC Demographic:" @40 mocdemo " forms received";
  
   put @10 "SNAP" @40 snap " forms received";
   put @10 "LBWI Medical Record Review" @40 p15p16 " forms received";
   put @10 "LBWI Blood Collection" @40 p17 " form received";
   if p17=1 then do;
       put @15 "Was Blood collected form CMV NAT  " natbloodcollect;
       if natbloodcollect=1 then put @40 "Date:  " natblooddate;
   end;
   put @10 "LBWI: CMV NAT Urine Test Result Form  " p200;
   if p200=1 then put @20 "Results:  " urinetestresult;
    put @10 "LBWI: CMV NAT Blood Test Result Form  " p201;
   if p201=1 then put @20 "Results:  " nattestresult;
    put @10 "MOC: CMV NAT Blood Test Result Form  " p203;
   if p203=1 then put @20 "Results:  " nattestresultmoc;
    put @10 "MOC: CMV Serology Test Result Form  " p204;
   if p204=1 then do;
        put @20 " IgG/IgM Results:  " ComboTestResult;
        put @20 " IgM Results:  " igmTestResult;
   end;
   put;
   put @5 "Follow-up Forms";
   put @5 "------------------------------------------";
   if f4>=1 then put @10 'Day 4 ' @30 f4 " forms received";
   if f7>=1 then do;
                   put @10 'Day 7 ' @30 f7 " forms received";
                   put @20 f7optional " optional forms received";
            end;
   if f14>=1 then put @10 'Day 14 ' @30 f14 " forms received";   
   if f21>=1 then do;
                   put @10 'Day 21 ' @30 f21 " forms received";
                   put @20 f21optional " optional forms received";
            end;
   if f25=1 then put @10 "MOC: Placental Infection and Pathology form received";
   if f28>=1 then do;
                   put @10 'Day 28 ' @30 f28 " forms received";
                   put @20 f28optional " optional forms received";
            end;
   if f40>=1 then do;
                   put @10 'Day 40 ' @30 f40 " forms received";
                   put @20 f40optional " optional forms received";
           end;
   if f60>=1 then do;
                   put @10 'Day 60 ' @30 f60 " forms received";
                   put @20 f60optional " optional forms received";
            end;   
    if ivh>=1 then put @10 'IVH' @30 ivh " forms received";
    if bpd>=1 then put @10 'BPD' @30 "form received";
    if rop>=1 then put @10 'ROP' @30 "form received";
    if pda>=1 then put @10 'PDA' @30 "form received";
    if f90>=1 then do;
                   put @10 'End of Study' @30 f90 " form received";
                   put @20 f90optional " optional forms received";
            end;          
 put;                  
 if un>=1 then do; put @10 "Unscheduled NAT forms";
     if ubnat>=1 then put @30 ubnat  " LBWI Blood NAT forms received";
     if uunat>=1 then put @30 uunat  " LBWI Urine NAT  forms received";
     if umnat>=1 then put @30 umnat  " MOC NAT forms received";
 end;
 put;
 if rbc>=1 then put @10 "Red Blood Cell Transfusion " rbc " forms received";
 put;            
 if nvaso>=1 then put @10 "Vasopressor Log forms received";
 if milk>=1 then put @10 "Ever Breast Fed";
 if mvent='Yes' then put @10 "Ever on Ventilator";
 if leftstudy>=1 then put @10 "Left Study";
*proc print;
run;
proc contents varnum;
run;
