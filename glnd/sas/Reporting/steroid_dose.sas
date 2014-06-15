/* steroid_dose.sas ;
 *
 * produce a simple listing of steroid usage and dosage, by patient
 *
 *
 */


proc sort data = glnd.status; by id; run;
proc sort data = glnd.concom_meds; by id med_code dt_meds_str ; run;


data concom_steroid;
	merge 
		glnd.status (keep = id dt_random)
		glnd.concom_meds 
	;
	by id;


	if med_code ~= 4 then DELETE;

	length duration_of_drug $ 15;

	* compute intervals;
	study_day_started = dt_meds_str - dt_random;
	if (dt_meds_stp - dt_meds_str) ~= . then	duration_of_drug = put(dt_meds_stp - dt_meds_str, $3.);
	else duration_of_drug = "(date missing)"; 


	* Capitalize drug names ;
	meds = upcase(substr(meds,1,1)) || substr(meds,2); 

	label 
		id = "GLND ID"
		meds = "Drug name"
		meds_dose = "Dose"
		study_day_started = "Began on study day:"
		duration_of_drug = "Days given"
		;
	

run;

* insert spaces between patients ;
data concom_steroid;
	set concom_steroid;

	by id;


	output;

	if last.id then do;	
		dt_random = .;
		dt_meds_str = .;
		meds = " ";
		meds_dose =.;
		study_day_started =.;
		duration_of_drug = " ";
		output;
	end;
run;
	
	options nodate nonumber;
	ods pdf file = "/glnd/sas/reporting/concom_steroid.pdf" style = journal;

title "Listing of corticosteroids administered";
proc print data = concom_steroid noobs label ;
	by id;
	id id;
	var dt_random dt_meds_str meds meds_dose study_day_started duration_of_drug /style(data) = [just=center];
run; 

	ods pdf close;
