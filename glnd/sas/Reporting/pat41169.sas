/* blood_gluc_monthly_since_last_dsmb.sas
 *
 * modification of the "blooc_gluc_monthly.sas" to include all glucose data for patients who have information after 1/1/2008 - when we last froze the DSMB data. 
 *
 * blood glucose data for inclusion in the GLND monthly reports
 *
 * 1. produce line plots by center for the patients with data in the previous month	
 * 2. proportions of measurements above 250 and below 50 in the previous month
 *
 *
 */

** turn macros on **;
 proc options option = macro;  
 run;


*** Prepare data. add dates of enrollment and dates of each glucose measurement! ***;
	proc sort data = glnd.status; by id; run;
	proc sort data = glnd.followup_alL_long; by id day; run;


	data gluc_center;
		set 	glnd.followup_all_long ;
		
		/** CODE USED TO ADD DATES AND CENTER VARIABLES WAS MOVED TO "followup_all.sas" on 8/30/2009 **/
		where id=41169;
	run;

ODS PDF FILE ="41169.pdf";  
proc sgplot data=gluc_center;

series x=day y=gluc_mrn;
series x=day y=gluc_aft;
series x=day y=gluc_eve;
xaxis integer values=(0 to 15 by 1);
run;
ods pdf close;
