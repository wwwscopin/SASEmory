data x;
  set glnd.plate201;
  if .<glucose<40 ;
keep id glucose;
proc sort; by id;
data y;
 set glnd.status;
 keep id treatment;

data xy;
 merge x(in=a) y;
 by id;
if a;
proc print;
