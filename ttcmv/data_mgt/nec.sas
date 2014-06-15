/* nec.sas
 *
 * NEC form - TTCMV
 *
 */

proc sort data = cmv.nec_p1; by id; run;
proc sort data = cmv.nec_p2; by id; run;
proc sort data = cmv.nec_p3; by id; run;


data cmv.nec;
	merge 
			cmv.nec_p1
			cmv.nec_p2
			cmv.nec_p3
			
	;
	by id;
run;

proc print;
run;
	
