
data test;
    set glnd.plate43;
    if nursing_home=1;
    keep id nursing_home;
run;

proc sort nodupkey; by id;run; 
proc print;run;

data test_death;
    merge test(in=A) glnd.plate205 (keep = id dt_death in = in_death); by id;
    if in_death then death=1; else death=0;
    if A;
run;

proc print;run;
