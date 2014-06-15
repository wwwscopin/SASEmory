/* ivh.sas
 *
 * IVH form - TTCMV
 *
 */

proc sort data = cmv.plate_068; by id; run;
proc sort data = cmv.plate_069; by id; run;

data cmv.ivh;
	merge 
			cmv.plate_068
			cmv.plate_069
	;
	by id dfseq;
run;

proc print;
run;
	
