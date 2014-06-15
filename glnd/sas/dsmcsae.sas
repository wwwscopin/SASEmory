
options ls=80 ps=54;
libname glnd '';
data saec;
 set glnd.sae_cases_by_center;
if  center <>. and treatment=.;
 drop treatment;
proc means data=saec noprint;

var sae1-sae8;
output out=ab sum=sae1-sae8;
run;
data sae;
set saec ab;
if center=. then center=100;

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
  merge sae n;
   by center;
   drop _freq_ _type_;
   array sae(8);
   do i=1 to 8;
   if sae(i)=. then sae(i)=0;
   end;
   drop i;
proc print;
run;
data pat;
set glnd.sae_patients;
run;
proc means data=pat noprint;
 by center;
var sae1-sae8;
output out=ab sum=p1-p8;
run;
proc means data=pat noprint;

var sae1-sae8;
output out=ab1 sum=p1-p8;
run;

data newpat;
 set ab ab1;
 if center=. then center=100;
 drop _freq_ _type_;
 format p1-p8;
 
 proc print;
 run;
data all;
 merge cas newpat;
  by center;
  proc print;
  run;
  
  data sae;
   set all;

   array sae(8) sae1-sae8;
   array p(8) p1-p8;
do i=1 to 8;
    pat=p(i);
    case=sae(i);
    output;
 end;
 keep i pat case n center;
 proc print;
 run;

    
 data glnd.dsmcsaeall;
 set sae;
  sae=i;
   drop i;
   format sae sae_type.;
   label sae='Adverse Event';
   
   pct=round(pat*100/n,.1);
   x=compress(put(pat,3.)||'/'||put(n,3.))||')'||put(pct,5.1);
  
    tsae=trim(put(case,4.)||'('||x)||'%';
     
     label tsae="Total*  "
       center='Clinical Center'
       n='No. of Patients';
     keep sae center tsae n;
    run;
	proc print label;
	var center  sae tsae;
	run;


