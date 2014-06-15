/* followup_all.sas
 *
 * This program creates two datasets from all follow-up forms:
 *  1. glnd.followup_7 = a cross-sectional summary of all forms
 *  2. glnd.followup_7_long = a longitudinal view of all follow-up days, where day is a variable and all other variables are the same
 */
 


* 1. not yet implemented

* 2. makes a longitudinal dataset containing all follow-up form data ;

data glnd.followup_all_long;
	set glnd.followup_3_long
		glnd.followup_7_long
		glnd.followup_14_long
		glnd.followup_21_long
		glnd.followup_28_long;
		
	if gluc_aft = 979 then gluc_aft = .;  * fix an erroneous value for the 2/2008 DSMB report; 
run;


 
*** Prepare data. add dates of enrollment and dates of each glucose measurement! ***;
	proc sort data = glnd.status; by id; run;
	proc sort data = glnd.followup_alL_long; by id day; run;


	data glnd.followup_all_long;
		merge 	glnd.followup_all_long 
				glnd.status (keep = id dt_random);

		by id;

		this_date = dt_random + (day - 1); * calculate the date of measurement. used to later restrict by date in reporting (ie: with blood glucose reports) ; 

		center = floor(id/10000);

		format this_date mmddyy. center center.;	
	run;
	


proc sort data = glnd.followup_all_long;
	by id day;
run;



proc print;
run;


