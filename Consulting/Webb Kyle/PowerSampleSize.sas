/*
proc power; 
  twosamplefreq test=pchi 
  groupproportions = (0.096 0.162) 
  nullproportiondiff = 0 
  power = 0.7 0.8 0.9
  npergroup =.;
run;
*/

proc power; 
  twosamplefreq test=lrchi 
  groupproportions = (0.096 0.162) 
  power = 0.7 0.8 0.9
  npergroup =.;
run;

proc power; 
  twosamplefreq test=lrchi 
  groupproportions = (0.096 0.162) 
  power =. 
  npergroup =248;
run;
/*
proc power; 
  twosamplefreq test=fisher 
  groupproportions = (0.096 0.162) 
  power = 0.7 0.8 0.9
  npergroup =.;
run;
*/

 proc power; 
   twosamplemeans test=diff 
   groupmeans = 4.28 | 2.02
   stddev = 0.89
   npergroup = . 
   power = 0.7 0.8 0.9; 
 run;

  proc power; 
   twosamplemeans test=diff 
   groupmeans = 2779 | 1886
   stddev = 549
   npergroup = . 
   power = 0.7 0.8 0.9; 
 run;
