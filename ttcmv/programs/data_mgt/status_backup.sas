******************
create status dataset

for now
id
date of enrollment (plate1)
date left study

add death date
mech vent

;

cmv.endofstudydata enroll;
   set cmv.plate_001;
   keep id enrollmentdate;
   if enrollmentdate > .;
run;

data eos;
   set cmv.endofstudy;
   leftstudy=1;
   keep id StudyLeftDate leftstudy Reason;
run;



data status;
  merge enroll eos;
  by id;
  
  *  for now if no eos then set date to be today;
  if StudyLeftDate eq . then StudyLeftDate=today();
  fdays=StudyLeftDate-enrollmentdate;
run;

data x;
  merge cmv.mechvent (in=a) status;
  by id;
  if a;
  array startd(10) startdate1-startdate10;
  array endd(10) enddate1-enddate10;
  
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

data cmv.status;
  merge status x milk vaso2;
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
   
       drop studyleftdate7;
run;
options orientation=landscape;
ods pdf file='status.pdf' ;
ods ps file='status.ps';
proc print  label;
 var id enrollmentdate studyleftdate reason leftstudy 
     fdays vdays vfreedays milk milkdays nvaso mvent;
title TTCMV Status;
run;
title;
ods pdf close;
ods ps close;
ods pdf file='mechvent.pdf';
proc freq;
     tables mvent;
title Overall ;
run;
proc means n median q1 q3;
   var fdays;
run;
proc means n median q1 q3;
 var vdays vfreedays;
 title Patients Ever on Ventilator;
 run;
 ods pdf close;
  proc print label ;
   var id mvent vdays fdays vfreedays;
   title;
run;
ods pdf file='milk.pdf';
proc print;
   title Breast Milk Feeding ;
   var id milk milkdays;
proc freq;
 tables milk;
 proc means;
  var milkdays;
run;
ods pdf close;

ods pdf file='vaso.pdf';
proc print label ;
 var id nvaso leftstudy reason;
 title Vasopressor Log;
run;
proc freq;
 tables nvaso;
 run;
 ods pdf close;

