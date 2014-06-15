proc power; 
  twosamplefreq test=pchi 
  groupproportions = (0.0075 0.0088) 
  power =0.7 0.8  0.9
  npergroup = . 
  sides = 1;
run;

proc power; 
  twosamplefreq test=pchi 
  groupproportions = (0.0075 0.0088) 
  power = .
  npergroup = 500 
  sides = 1;
run;

proc power; 
  twosamplefreq test=fisher 
  groupproportions = (0.0075 0.0088) 
  power =0.7 0.8  0.9
  npergroup = . 
  sides = 1;
run;

proc power; 
  twosamplefreq test=fisher 
  groupproportions = (0.0075 0.0088) 
  power = .
  npergroup = 500 
  sides = 1;
run;
