data test;
    set glnd.plate201;
run;

proc freq;
table related_treat;
run;

proc print;
var id related_treat;
where related_treat=2;
run;
