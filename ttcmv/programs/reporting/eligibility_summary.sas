/* eligible_summary.sas
 *
 * cover reasons LBWI are eligible or ineligible
 *
 */


/** CAN'T COMPLETE THIS PROGRAM UNTIL WE HAVE SOME INELIGIBLE PEOPLE! **/
proc means data = cmv.eligibility;
	where ~isEligible;
	var 

run;

data reasons;
	set cmv.eligibility;

	

run;
