/* create missing data */
data cmv.snap2; set cmv.snap2; 

total_snap2=4;  this_snap2_gt25=0;
this_snap2=0; total_snap2=3;

if MeanBP eq 99 or MeanBP eq 999 then  this_snap2=this_snap2+1;  
if  LowestTemp eq 99 or LowestTemp eq 999 then this_snap2=this_snap2+1;
if  seizures eq 99 or seizures eq 999 then this_snap2=this_snap2+1;
if  UOP eq 99 or UOP eq 999 then this_snap2=this_snap2+1;

if BloodCollect eq 1 and (LowPh eq 99 or LowPh eq 999) then this_snap2=this_snap2+1;
if BloodCollect eq 1 and (PO2Fo2Ratio eq 99 or PO2Fo2Ratio eq 999) then this_snap2=this_snap2+1;


if BloodCollect eq 1 then total_snap2=5;

this_snap2_pct=this_snap2/total_snap2*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap2_nonmiss=compress(this_snap2) || "/" || compress(total_snap2);


if this_snap2_pct >=25 then this_snap2_gt25 =1;


run;
