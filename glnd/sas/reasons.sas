options ls=80 ps=52;

proc freq data=glnd.not_enrolled;
tables reason /nopercent nocum;
