options nocenter;
libname hw 'p:\bio113\hw';
data hw.ivh;
infile 'g:\shared\bio113\ivh.dat';
input id 6. (hosp sex race) (1.) ga 2. bw 4. (ivh medu single cs pih) (1.) 
      (labor rom) (6.) acs 33 (mage apg1 apg5) (2.) vent 40 los 3. 
       dead 44 (wt1-wt4) (4.) (map1-map4 pco2_1-pco2_4) (2.) 
       (pda1-pda4 dopa1-dopa4) (1.) (fluid1-fluid4 cry1-cry4) (3.)
      (col1-col4) (2.) (ptx1-ptx4) (1.)  t4 5.  t4age 2.;
run;
proc print data=hw.ivh(obs=10);
run;
