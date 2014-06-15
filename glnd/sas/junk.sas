data x;
 set glnd.basedemo;
daysop=dt_random-dt_primary_elig_op;
label daysop='Days from Primary OP to Enrollment';
proc means ;
var daysop;
run;
data glnd.basedemo;
 set x;
