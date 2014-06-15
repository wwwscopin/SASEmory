
options ls=80 ps=54;
libname glnd '';
data aec;
 set glnd.ae_cases_by_center;
if  center <>. and treatment=.;
 drop treatment;
proc means data=aec noprint;

var ae1-ae17;
output out=ab sum=ae1-ae17;
run;
data ae;
set aec ab;
if center=. then center=100;

run;

data t;
  set glnd.status;
  center=int(id/10000);
  i=1;
   keep id center i;
   format center center.;
   *proc print;
   run;
 proc sort; by center;
proc means noprint data=t;
 by center;
 var i;
 output out=t1 sum=n;

  proc means noprint data=t;
 
 var i;
 output out=t2 sum=n;

data n;
 set t1 t2;
 if center=. then center=100;
 

 data cas;
  merge ae n;
   by center;
   drop _freq_ _type_;
   array ae(17);
   do i=1 to 17;
   if ae(i)=. then ae(i)=0;
   end;
   drop i;
proc print;
run;
data pat;
set glnd.ae_patients;
run;
proc means data=pat noprint;
 by center;
var ae1-ae17;
output out=ab sum=p1-p17;
run;
proc means data=pat noprint;

var ae1-ae17;
output out=ab1 sum=p1-p17;
run;

data newpat;
 set ab ab1;
 if center=. then center=100;
 drop _freq_ _type_;
 format p1-p17;
 
 proc print;
 run;
data all;
 merge cas newpat;
  by center;
  proc print;
  run;
  
  data ae;
   set all;

   array ae(17) ae1-ae17;
   array p(17) p1-p17;
do i=1 to 17;
    pat=p(i);
    case=ae(i);
    output;
 end;
 keep i pat case n center;
 proc print;
 run;

    
 data glnd.dsmcaeall;
 set ae;
  ae=i;
   drop i;
   format ae ae.;
   label ae='Adverse Event';
   
   pct=round(pat*100/n,.1);
   x=compress(put(pat,3.)||'/'||put(n,3.))||')'||put(pct,5.1);
  
    tae=trim(put(case,4.)||'('||x)||'%';
     
     label tae="Total  "
       center='Clinical Center'
       n='No. of Patients';
     keep ae center tae n;
    run;
	proc print label;
	var center  ae tae;
	*format center;
	run;


