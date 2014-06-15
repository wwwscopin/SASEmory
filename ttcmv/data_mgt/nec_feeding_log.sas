/* lbwi_demo.sas
 *
 * LBWI Demograhpic form - TTCMV
 *
 */

proc sort data = cmv.plate_065; by id; run;
proc sort data = cmv.plate_066; by id; run;

data cmv.nec_feeding_log;
	merge 
			cmv.plate_065
			cmv.plate_066
	;
	by id ;
	if dfstatus = 0 then delete;
run;

proc print;
run;
	
