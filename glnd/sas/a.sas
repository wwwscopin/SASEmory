data x;
  set glnd.status;
  x=today()-dt_random;
proc sort; by x;
run;
proc print;
 var id x;
