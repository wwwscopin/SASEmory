proc power; 
  twosamplefreq test=fisher 
  groupproportions = (.77  .94) 
  power =0.7 .8 0.9
  npergroup = . ;
run;


 proc power; 
   twosamplemeans test=diff 
   groupmeans = 9.1273 | 6.6381 
   stddev = 5.1559
   npergroup = . 
   alpha = .05
   power =0.7 0.8 0.9; 
 run;
