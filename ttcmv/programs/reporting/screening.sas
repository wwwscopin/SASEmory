/* screening.sas
 *
 * produce tables summarizing LBWI screening 
 *
 */

%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";

 data screening;
	set cmv.plate_001 (rename = (isEligible = enrolled));

	* initialize reasons not eligible;
	length reasons_not_elig $ 100 ;
	reasons_not_elig = ""; 

	* Calculate how many LBWI meet criteria and are thus eligible. this is different than neetas isEligible variable, 
		which accounts for consent and willingness. That corresponds to whether they were enrolled or not ;


	if (InWeight & InLife & ~ExLifeExpect & ~ExAbnor & ~ExTX & ~ExMOCPrevEnrolled) then	elig_criteria = 1;
	else do;
		elig_criteria = 0;
		if ~InWeight then reasons_not_elig = trim(reasons_not_elig) || ", 1250g < Birthweight < 1500g";
		if ~InLife then reasons_not_elig = trim(reasons_not_elig) || ", LBWI not within first 5 days of life"; 
		if ExLifeExpect  then reasons_not_elig = trim(reasons_not_elig) || ", LBWI not expected to live past 7 days of life";
		if ExAbnor  then reasons_not_elig = trim(reasons_not_elig) || ", LBWI has severe congenital abnormality";
		if ExTX  then reasons_not_elig = trim(reasons_not_elig) || ", LBWI received tx from outside institution";
		if ExMOCPrevEnrolled  then reasons_not_elig = trim(reasons_not_elig) || "MOC previously enrolled in study";

		* remove leading comma and space in first position;
		reasons_not_elig = substr(reasons_not_elig, 3);
	end;
	
	center = floor(id/1000000);


	format center center.;
	drop DFSTATUS  DFVALID  DFRASTER  DFSTUDY  DFPLATE  DFSEQ DFSCREEN  DFCREATE  DFMODIFY;
 run;


* CREATE screened_eligible_enrolled VARIABLE;
data screening; set screening;

	format screened_eligible_enrolled	screen_elig_enroll.;

	*Screened - Not eligible;
		if elig_criteria = 0 then screened_eligible_enrolled = 1;
	*Eligible - Did not consent; 
		if elig_criteria = 1 & enrolled = 9 then screened_eligible_enrolled = 2;
	*Enrolled;
		if enrolled = 1 then screened_eligible_enrolled = 3;
 
run;

data cmv.screening; set screening; run;

options nodate nonumber orientation = portrait;


* make table to show eligibility and enrollment, by center;
	%descriptive_stat(data_in= screening, where= , data_out= total_eligible, var= screened_eligible_enrolled, type= cat, first_var= 1, custom_label= "Total:");

	%descriptive_stat(data_in= screening, where= center=1, data_out= total_eligible, var= screened_eligible_enrolled, type= cat, custom_label= "EUHM:");

	%descriptive_stat(data_in= screening, where= center=2, data_out= total_eligible, var= screened_eligible_enrolled, type= cat, custom_label= "Grady:");

	%descriptive_stat(data_in= screening, where= center=3, data_out= total_eligible, var= screened_eligible_enrolled, type= cat, last_var= 1, custom_label= "Northside:", spaces= 1);


	%descriptive_stat(print_rtf = 1, data_out= total_eligible, file= "&output./monthly/&screen_elig_enroll_mon_file.screened_eligible_enrolled.rtf", title = "Screening, Eligibility and Enrollment Summary");



* print reasons for LBWI, by center - FIX LABELS;
* can also change to a command-line type of mode, were you just issue commands to the macro. but then you will have to reset the table, and cannot add to it later;


* Make TWO TABLES: "Reasons not eligible - Failure to Include" and "Reasons not eligible - Excluded" ;

* Summarized in "Failure to Include" table should be the number of patients for whom inclusion = 0;
	data screening; set screening;

		format InWeight_no InLife_no yn.;

		If InWeight = 0 then InWeight_no = 1;
		If InWeight = 1 then InWeight_no = 0;
		If InLife = 0 then InLife_no = 1;
		If InLife = 1 then InLife_no = 0;

	/* Here I re-assign the new variables to the old ones so I don't have to create new labels... Sorry. */

		InWeight = InWeight_no;
		InLife = InLife_no;

	run;

	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_inc, var= InWeight, type= bin, first_var= 1);
	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_inc, var= InLife, type=bin, last_var= 1, spaces= 0);


	* print table ;
	%descriptive_stat(print_rtf = 1, data_out= reasons_not_elig_inc, file= "&output./monthly/&reasons_not_elig_inc_mon_file.reasons_not_elig_inc_table.rtf", title = "&reasons_not_elig_inc_mon_pre Reasons not eligible - Failed to Include");


	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_exc, var= ExLifeExpect, type= bin, first_var= 1);
	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_exc, var= ExAbnor, type= bin);
	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_exc, var= ExTX, type= bin);
	%descriptive_stat(data_in= screening, where= ~elig_criteria, data_out= reasons_not_elig_exc, var= ExMOCPrevEnrolled, type= bin, last_var= 1, spaces= 0);

	* print table ;
	%descriptive_stat(print_rtf = 1, data_out= reasons_not_elig_exc, file= "&output./monthly/&reasons_not_elig_exc_mon_file.reasons_not_elig_exc_table.rtf", title = "&reasons_not_elig_exc_mon_pre Reasons not eligible - Excluded");

* compute summarized success meeting the inclusion and exclusion criteria;

* within those eligible but not enrolled, summarize reasons why not enrolled;
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= MOCNotAvailable, type= bin, first_var= 1);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= ParticipationFear, type= bin);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= BloodDraws, type= bin);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= TooManyTrials, type= bin);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= DangerToChild, type= bin);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= ReasonUnk, type= bin);
	%descriptive_stat(data_in= screening, where= elig_criteria & (enrolled=9), data_out= reasons_not_enroll, var= RefuseOther, type= bin, last_var= 1);

	%descriptive_stat(print_rtf = 1, data_out= reasons_not_enroll, file= "&output./monthly/&reasons_not_enroll_mon_file.reasons_not_enroll_table.rtf", title = "&reasons_not_enroll_mon_pre Reasons refused consent");



/*
* make recruitment curve in this program?;
proc print data = screening; run;
*/

