
proc contents data=cmv.plate_005; run;
proc print data=cmv.plate_005; run;

date tmp;
	set cmv.plate_005;
	rename LBWIDOB=dob;
	keep id race raceother Gender LBWIDOB;
run;
