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
   groupmeans = 1.2 | 5.2 
   stddev = 3 4 5 6 7 8 9
   npergroup = . 
   power = 0.8; 
 run;
