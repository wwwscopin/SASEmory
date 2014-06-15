data x;
   set glnd.plate101;
     keep id  cult_obtain  cult_positive;
     options ls=85 ps=53;
proc means noprint;
 var id;
 output out=tot n=totalforms;
run;

data p;
  set x;
   by id;
   if first.id;
proc means nprint;
  var id;
  output out=npat n=npat;

proc print;

data x1;
   set x;
    if cult_obtain=1;
 *proc freq;
 *     tables cult_positive;
proc means noprint;
 var id;
 output out=cult n=totalcult;
run;

proc means noprint data=x1;
 by id;
 var cult_positive;
 output out=cp max=cultpos;
 
/*proc print;
 format cultpos;
 proc means sum;
  var _freq_;
*/;
data cultneg;
   set cp;
   if cultpos=0;
proc means noprint;
   var id;
   output out=negpat n=negpat;

data x2;
   set x1;
     if cult_positive=0;
    
proc means noprint;
 var id;
 output out=neg n=totalneg;
run;  

proc sort data=x; by id;
data xsingle;
   set x;
   by id;
   if first.id;
   plate101=1;
   keep id plate101;
data pat;
    set glnd.status;
    keep id;
 proc sort; by id;
data xuniq;
  merge xsingle pat;
   by id;
   if plate101=. then plate101=0;
  proc means noprint;
    var plate101;
  output out=pat1 mean=iform;
 data final;
  merge tot cult neg pat1 negpat npat;
  
  
  drop _type_ _freq_;
  
   pernever=round((1-iform)*100,.1);
   file 'neg_cult.txt';
   put;
   put '     Total # of Infection Forms ' totalforms;
   put '     From a total of            ' npat ' persons';
   put '     Total # with Culture Obtained ' totalcult;
   put '     # of Negative Results         ' totalneg;
   perneg=round(totalneg*100/totalcult,.1);
   put '     % Cultures Obtained that are neg ' perneg;
   put '     # Patients with only Neg Cult    ' negpat;
   put;
   put '     % of Subjects Without any forms ' pernever;
  proc print; 
  