proc power;
title "Sample Size Calculation for Comparing between Baseline and Follow-up"; 
  pairedmeans test=diff 
  meandiff = 3 to 7 by 1
  std = 15 
  corr =0.5 to 0.7 by 0.1
  npairs = . 
  power = 0.8 to .9 by 0.1; 
run;
