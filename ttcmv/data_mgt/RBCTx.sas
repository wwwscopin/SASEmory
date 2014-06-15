/* RBCTX.sas
 *
 * RBC TX form - TTCMV
 *
 */

proc sort data = cmv.plate_031; by id; run;


data cmv.RBCTx;
	merge 
			cmv.plate_031
			
	;
	by id;
run;

proc print;
run;
	
