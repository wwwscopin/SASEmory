proc power; 
  twosamplefreq test=lrchi 
  groupproportions = (.875 .90) 
  /*nullproportiondiff = 0 */
  power = 0.7 .80 0.9
  groupweights =(1 1)
  /*sides=1*/
  ntotal =.;
  *npergroup =.;
run;

proc power; 
  twosamplefreq test=pchi 
  groupproportions = (.88 .90) 
  nullproportiondiff = 0 
  power = .80
  groupweights =(1 1)
  ntotal =.;
  *npergroup =.;
  *sides=1;
run;
