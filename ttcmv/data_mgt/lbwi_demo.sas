/* lbwi_demo.sas
 *
 * LBWI Demograhpic form - TTCMV
 *
 */

proc sort data = cmv.plate_005; by id; run;
proc sort data = cmv.plate_006; by id; run;

data cmv.lbwi_demo;
	merge 
			cmv.plate_005
			cmv.plate_006
	;
	by id ;
	if dfstatus = 0 then delete;
run;

proc print;
run;
	
