/* whos_on_what_CLOSED.sas 
 *
 * FOR UNBLINDED EYES ONLY! 
 * a reference of which patients are on which treatments
 *
 */

* get DSMB date from autoexec;
data _NULL_;
	call symput ("title_date", put(mdy(&dsmb_date), mmddyy.));
run;

options nodate nonumber;
ods pdf file = "/glnd/sas/reporting/whos_on_what_closed.pdf" style = journal ;
	title h=3 "GLND - Treatment Assignments for Patients Enrolled through &title_date ";
	proc print data= glnd.george label ;
		var id treatment;
		format treatment trt.;
		
		label 	id = "ID"
				treatment = "Treatment";
	run;
ods pdf close;

