/* sus CMV.sas
 *
 * sus CMV form - TTCMV
 *
 */

proc sort data = cmv.sus_cmv_p1; by id; run;
proc sort data = cmv.sus_cmv_p2; by id; run;
proc sort data = cmv.sus_cmv_p3; by id; run;
proc sort data = cmv.sus_cmv_p4; by id; run;
proc sort data = cmv.sus_cmv_p5; by id; run;

data cmv.sus_cmv;
	merge 
			cmv.sus_cmv_p1
			cmv.sus_cmv_p2
			cmv.sus_cmv_p3
			cmv.sus_cmv_p4
			cmv.sus_cmv_p5
	;
	by id;
run;

proc print;
run;
	
