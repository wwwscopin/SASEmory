/*
proc power;
twosamplemeans 
	nfractional
	meandiff=10
	stddev=15
	groupweights=(1 1) 
	power=0.8
	alpha=0.05
	ntotal=.;
title "Sample Size Calculation for Comparing Two Groups"; 
run;


 proc power; 
   twosamplemeans test=diff 
   groupmeans = 0|1.0 
   stddev = 1.0 1.5 2
   npergroup = . 
   power = 0.8 0.9; 
 run;


  proc power; 
   twosamplemeans test=diff 
   groupmeans = 0|1 
   stddev = 1.0 1.5
   npergroup =15 
   power = .; 
 run;

 proc power; 
  onesamplemeans test=t 
  nullmean = 0 
  mean  = 1
  stddev = 1.0 1.5 2
  power = .8
  ntotal = . ; 
run;
*/

/*
proc power; 
  pairedmeans test=diff 
  meandiff = 15.6
  std = 23.6 
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 12.6
  std = 29.8
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 7.8
  std = 17.8
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;
*/

proc power; 
  pairedmeans test=diff 
  meandiff = 31.1
  std = 26.0
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 19.0
  std = 29.7
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 14.2
  std = 18.4
  corr = .5
  npairs = . 
  power = 0.6 to .9 by .1; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 20 to 50 by 10
  std = 20 to 40 by 10
  corr = .5 to 0.7 by 0.1
  npairs = . 
  power = 0.8 0.9; 
run;

proc power; 
  pairedmeans test=diff 
  meandiff = 20 to 50 by 10
  std = 20 to 40 by 10
  corr = .5 to 0.7 by 0.1
  npairs = 60 
  power =. ; 
run;
