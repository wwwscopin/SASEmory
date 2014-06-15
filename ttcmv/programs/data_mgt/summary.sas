
proc sort data = cmv.plate_020; by id; run;
proc sort data = cmv.plate_021; by id; run;
proc sort data = cmv.plate_022; by id; run;


data cmv.summary;
	merge 
			cmv.plate_020
			cmv.plate_021
			cmv.plate_022
	;
	by id ;
run;

proc print;
run;
