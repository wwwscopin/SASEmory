proc freq data = cmv.km;
	tables gestage / nocum	out = cmv.test1;
run;

proc freq data = cmv.km;
	tables hb / nocum	out = cmv.test2;
run;
