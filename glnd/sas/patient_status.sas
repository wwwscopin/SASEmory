
***********
program to create sitevisit report
for now only looking at forms received
NO KEY fields yet
use print12 to print 
**************************;
data id;
 infile 'sitevisit.dat';
 input id;
 
 **** get data from status;
 data status;
  set glnd.status;
  run;
  proc sort; by id;
%inc'forms.sas';

data demo;
 set glnd.demo_his;
 keep id ptint dt_birth ptint center dt_primary_elig_op;
 run;
  


%inc'aepat.sas';
 %inc'saepat.sas';
 %inc'nospat.sas';
 %inc'medspat.sas';
 %inc'ventpat.sas';
 
data p48;
   set glnd.plate48;
   plate48=1;
   keep id plate48;
run;

data combo;
 merge id(in=a) status forms demo ae1 sae1 nos1 meds1 vent1 p48;
  by id;
  if a;
  
      file 'patient_status.out';
    tod=today();
    y=round((tod-dt_random)/30.125,.01);
    format tod mmddyy8.;
    put;
    put;
    put @5 'Center = ' center ;
    put @5 'Today = ' tod;
    put;
    put @5 'ID = ' id @30 'Initials = ' ptint;
    put;
    put @5 'Date of Birth ' @30 dt_birth;
    put @5 'Admission Date' @30 dt_admission;
    put @5 'Date of Study Surgery' @30 dt_primary_elig_op; 
    put @5 'Date Randomized ' @30 dt_random;
    put @5 'Time Randomized ' @30 time_random;
    put @5 'APACHE II Score ' @30 apache_2;
    put @5 'Date PN Started ' @30 dt_drug_str;
    put @5 'Time PN Started ' @30 time_drug_str;
    put;
    put @5 'Date PN Stopped ' @30 dt_study_pn_stopped;
    put @5 'Date Discharged ' @30 dt_discharge;
	if meds=1 then put @5 'Concomitant Medication Form';
	if vent=1 then put @5 'Mechanical Ventilation Form';
    put;
    if plate48=1 then put 
        @5 'Study PN Interruption';
    /*
    
    value form
        1='Pharmacy Conf'
        2='PN Calc'
        3='Demo.'
        4='Day 3 F/U'
        5='Day 7 F/U'
        6='Day 14 F/U'
        7='Day 21 F/U'
        8='Day 28 F/U'
        9='Baseline Blood Coll.'
        10='Day 3 Blood Coll.'
        11='Day 7 Blood Coll.'
        12='Day 14 Blood Coll.'
        13='Day 21 Blood Coll.'
        14='Day 28 Blood Coll.'
        15='Day 28 Vital Assess.'
        16='2-Month F/U Call'
        17='4-Month F/U Call'
        18='6-Month F/U Call'
        19='30-Day Post-Drug F/U';
*/;

  **** now put form received, if date is missing then perhaps missed visit;
  *                    1    2    3      4     5  ;
       array d8s (19) dfc8 dfc11 dfc9 dfc23 dfc27 
                  day_14d day_21d day_28d blood_based blood_3d
                  blood_7d blood_14d blood_21d blood_28d dfc45
                  phone_2mod phone_4mod phone_6mod dfc42;
       array d8sm (19) $ 8 dfc8m dfc11m dfc9m  dfc23m dfc27m 
                  day_14dm day_21dm day_28dm blood_basedm blood_3dm
                  blood_7dm blood_14dm blood_21dm blood_28dm dfc45m
                  phone_2modm phone_4modm phone_6modm dfc42m;
       array forms(19) pharm_conf  pn_calc demo  day_3 day_7 
        
                  day_14 day_21 day_28 blood_base blood_3
                  blood_7 blood_14 blood_21 blood_28day_28_vital
                  phone_2mo phone_4mo phone_6mo post_drug_30;

                  
       do i=1 to 19;
           if d8s(i) ne . then d8sm(i)=put(d8s(i),mmddyy8.);
           if d8s(i) eq . then d8sm(i)='Missed?';
       end;
    put;
    put @5 'Date:' @20 'Form Received';
    put @5 '____________________________________';
    put;
      do i=1 to 19;
      format i form.;
      if forms(i) eq 1 then put @5 d8sm(i) @20 i;
      end;
      
      *** now do aes;
      if nae >0 then do;
      put;
       put @5 '____________________________________';
       put @5 ' ADVERSE EVENTS' ;
       put @3 ' Sequence' @14 'Date' @25 'Reason';
        put @5 '____________________________________';
        
       
      array dtae(20) ;
           array seqae(20);
           array aetype(20);
           do i=1 to nae;
              put @5 seqae(i) @14 dtae(i) @25 aetype(i);
           end;
     end;  
     
     


      
      *** now do saes;
      if nsae >0 then do;
      put;
       put @5 '____________________________________';
       put @5 ' SERIOUS ADVERSE EVENTS' ;
       put @3 ' Sequence' @14 'Date' @25 'Reason';
        put @5 '____________________________________';
        
       
      array dtsae(20) ;
           array seqsae(20);
           array saetype(20);
           do i=1 to nsae;
              put @5 seqsae(i) @14 dtsae(i) @25 saetype(i);
           end;
     end;  
     



      
      *** now do nos infection;
      if nnos >0 then do;
      put;
       put @5 '____________________________________';
       put @5 ' Suspected Nosocomial Infection' ;
       put @3 ' Sequence' @14 'Date' @25 'Infection Number from Log';
        put @5 '____________________________________';
        
       
      array dtnos(20) ;
           array seqnos(20);
           array nosnum(20);
           do i=1 to nnos;
              put @5 seqnos(i) @14 dtnos(i) @25 nosnum(i);
           end;
     end;  

run;
