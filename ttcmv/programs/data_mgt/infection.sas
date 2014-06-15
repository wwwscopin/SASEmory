/* infection.sas
 *
 * Infection form - TTCMV
 *
 */

proc sort data = cmv.infection_p1; by id; run;
proc sort data = cmv.infection_p1;; by id; run;

data cmv.infection_all;
	merge 
			cmv.infection_p1
			cmv.infection_p2
	;
	by id;
run;

proc print;
run;
	
