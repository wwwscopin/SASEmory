
 proc power; 
   twosamplemeans test=diff 
   meandiff = 1 to 2 by 0.5 
   stddev = 2 to 5 by 1
   alpha=0.05
   power = 0.8 
   npergroup = . ;
 run;


