 proc power; 
   twosamplemeans test=diff 
   groupmeans = 0 | 1 
   stddev = 3
   groupns = (24 24)
   power = .; 
 run;


proc power; 
  twosamplefreq test=pchi 
  groupproportions = (0.023 0.058) 
  nullproportiondiff = 0 
  groupweights =(1 9)
  power = .80
  ntotal =.;
run;

proc power; 
  twosamplefreq test=pchi 
  groupproportions = (0.023 0.058) 
  nullproportiondiff = 0 
  groupweights =(1 9)
  power = .
  ntotal =1376;
run;
