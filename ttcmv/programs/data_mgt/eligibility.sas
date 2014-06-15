/* eligibility.sas
 *
 * Eligibility form - TTCMV
 *
 */

proc sort data = cmv.plate_001; by id; run;
proc sort data = cmv.plate_002; by id; run;

data cmv.eligibility;
	merge 
			cmv.plate_001
			cmv.plate_002
	;
	by id;
run;

proc print;
run;
	
