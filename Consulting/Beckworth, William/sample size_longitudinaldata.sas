proc power; 
  pairedmeans test=diff 
  meandiff = 2.5
  std = 20 30
  corr = .5 0.6 0.7
  npairs = . 
  power = 0.8; 
run;
