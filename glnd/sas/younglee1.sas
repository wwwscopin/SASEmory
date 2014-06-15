
data x1;
   set glnd.basedemo;
  keep id age gender pre_op_kg pre_op_cm
    in_sicu_choice apachese dt_random;
proc sort; by id;
data x2;
   set glnd_rep.time_on_pn;
proc sort; by id;
data x3;
  set glnd_rep.sicudays;
proc sort; by id;
data x4;
  set glnd.status;
  keep id dt_discharge dt_death;
proc sort; by id;
data x5;
  set glnd_rep.sofa;
proc sort; by id;

data glnd.younglee1;
   merge x1 x2 x3 x4 x5;
   by id;
 if id in ( 
 11002,
11004,
11009,
11012,
11041,
11044,
11141,
11291,
12026,
12029,
12038,
12046,
12064,
12275,
21017,
21020,
22042,
31032,
32145,
32160,
32175,
32214,
32224,
41068
 );

proc contents;
run;
proc print;
run;
ods csv file='younglee1.csv';
proc print;
  var id age gender pre_op_kg
  pre_op_cm in_sicu_choice apachese dt_random days_on_pn sicudays dt_discharge
  dt_death sofa1-sofa28;
run;
ods csv close;
