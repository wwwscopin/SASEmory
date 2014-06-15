data x;
 set glnd.status;
keep id dt_random;
proc sort; by dt_random id;
ods pdf file='dt_random.pdf';
title GLND Patients by Date Randomized;
proc print label;
run;
ods pdf close;
