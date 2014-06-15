***********************************************************************
* This is a program that illustrates the use of PROC POWER to         *
* calculate sample size when comparing two hazard functions.          *
***********************************************************************;

proc power;
twosamplesurvival groupweights=(1 1) alpha=0.05 power=0.9 sides=2
   test=logrank curve("Placebo")=(1.01):(0.6) curve("Therapy")=(1.01):(0.8) 
   groupsurvival="Placebo"|"Therapy" accrualtime=0.01 followuptime=1 ntotal=.;
plot min=0.1 max=0.9;
title "Sample Size Calculation for Comparing Two Hazard Functions (1:1 Allocation)"; 
run;

proc power;
twosamplesurvival groupweights=(1 3) alpha=0.05 power=0.9 sides=2
   test=logrank curve("Placebo")=(1.01):(0.6) curve("Therapy")=(1.01):(0.8) 
   groupsurvival="Placebo"|"Therapy" accrualtime=0.01 followuptime=1 ntotal=.;
plot min=0.1 max=0.9;
title "Sample Size Calculation for Comparing Two Hazard Functions (3:1 Allocation)"; 
run;
