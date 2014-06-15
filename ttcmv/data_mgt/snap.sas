/* SNAP.sas
 *
 * SNAP form - TTCMV
 *
 */

proc sort data = cmv.plate_010; by id; run;
proc sort data = cmv.plate_011; by id; run;
proc sort data = cmv.plate_012; by id; run;

data cmv.SNAP;
	merge 
			cmv.plate_010
			cmv.plate_011
			cmv.plate_012
	;
	by id;
run;

proc print;
run;
	
