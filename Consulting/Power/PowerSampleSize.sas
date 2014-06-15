proc power; 
  twosamplefreq test=pchi 
  groupproportions = (.3 .15) 
  nullproportiondiff = 0 
  power = .80
  npergroup =.;
run;
