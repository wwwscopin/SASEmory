data x;
   set glnd.plate101; 
    plate101=1;
     keep id plate101 ;
     options ls=85 ps=53;
proc sort; by id;

proc means noprint;
 by id;
 var plate101;
 output out=plate101
 n=n101 max=plate101;
run;

data stat;
  set glnd.status;
keep id dt_random;

data rev;
   set glnd.plate56;
 keep id;
data plate56;
   set rev;
   by id;
   if first.id;
   plate56=1;
   keep id plate56;
run;


data b;
   set glnd.plate52;
 keep id;
data plate52;
   set b;
   by id;
   if first.id;
   plate52=1;
   keep id plate52;
run;


data prev1;
  merge plate101 (in=a) plate52 plate56 stat;
  by id;
  if a;
  drop _freq_ _type_;
  if plate52 eq . and plate56 eq .;
label n101='# of Suspected Infections';
proc sort; by dt_random;
ods rtf file='non_reviewed.rtf' sasdate;
ods pdf file='non_reviewed.pdf';

proc print label;
   var id dt_random n101;
   sum n101;
  title Patients with Suspected Infections That Have Not Been Reviewed;
run;
ods pdf close;
ods rtf close;
