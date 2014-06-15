/* patient_status_for_monitors.sas
 *
 *
 * ID, initials, enrollment date, date drug started,  days since enrollment, apache_2, days_sicu since entry, days_hosp since entry, deceased
 *
 *
 */

options orientation=landscape;
* before we print, we need to grab the initials from the screening forms (or really any form), as well as calculate the numbers of days since
  enrollment; 

proc sort data= glnd.status; by id; run;
proc sort data= glnd.demo_his; by id; run;
proc sort data= glnd.plate1; by id; run;

proc format library = work;
	value new_apache   99 = "Blank"
                 1 = "<= 15"
                 2 = "> 15" ;
run;

data status_monitors;
	merge 	glnd.status (in = randomized keep = id dt_random dt_drug_str apache_2 days_sicu_post_entry days_hosp_post_entry dt_discharge deceased followup_days order_randomized)
			glnd.plate1 (keep = id ptint)
			glnd.demo_his (keep = id gender)
			;

	by id;

	if ~randomized then DELETE;

	days_since_random = today() - dt_random;

	* fix some labels ;
	label 	dt_random = "Date Randomized"
			dt_drug_str = "Date Drug Started"
			apache_2 = "Apache II"
			days_since_random = "Days Since Randomization"
			deceased = "Deceased"
			dt_discharge = "Date Discharged"
			gender = "Gender"
			days_sicu_post_entry = "Days in SICU post rand."
			days_hosp_post_entry = "Days in hospital post rand."
			;

	format deceased yn. apache_2 new_apache.;
run;


***** on 7/24/08, I comment out "days_SICU_post_entry" because it is no longer accurate, after we allow for patients to go in and out of the SICU *******;


/*** AS OF 5/8/09, NANA WILL RECEIVE THE VERSION ORIGINALLY SENT TO JUST GAUTAM, WHICH IS SORTED BY RANDOMIZATION TIME
	* make this file for monitors ;
	ods pdf file = "/glnd/sas/patient_status_for_monitors.pdf" style = journal;

		title "GLN-D Patient Status" ;
		proc print data= status_monitors label  ;
			var id ptint apache_2 gender  dt_random  dt_drug_str dt_discharge days_since_random days_hosp_post_entry deceased followup_days
				/style(data) = [just=center];;
		run;
	ods pdf close;
***/


* now sort by date of enrollment for Gautam ;
	proc sort data = status_monitors; by order_randomized; run;
	ods pdf file = "/glnd/sas/patient_status.pdf" style = journal;
	
		title "GLN-D Patient Status" ;
		proc print data= status_monitors label noobs ;
			var order_randomized id ptint apache_2 gender  dt_random  dt_drug_str dt_discharge days_since_random /*days_sicu_post_entry*/ days_hosp_post_entry deceased followup_days
				/style(data) = [just=center];;
		run;
	ods pdf close;
	
* send this form to Gautam on Sunday and Thursday nights (ie: for Monday and Friday mornings) ;
	data _NULL_;
		if ( weekday(today()) in (1, 5))  then do;
			*call system('sendmessage -s "GLND Patient Status Update" -r ghebbar@emory.edu -a patient_status.pdf');
                        * turn off sending email;
			put 'email sent to Gautam today';
		end;
		
	run;
	
* send this form to Kirk on the Friday before steering committee calls (Friday before 2nd tuesday of the month) ;
	data _NULL_;
	
		first_day_month = weekday(mdy(month(today()),1,year(today()))) ; * first day of month;
		
		if first_day_month < 4 then sc_day = 11 - first_day_month;
		else sc_day = 18 - first_day_month;
	
		kirk_email_day = sc_day - 4; 
	
			* send to Kirk the night before the FRIDAY before SC call ;
			if day(today()) = (kirk_email_day - 1)  then do;
				*call system('sendmessage -s "GLND Patient Status Update" -r keasle2@sph.emory.edu -a patient_status.pdf');
                                 * turn off sending email;
				put 'email sent to Kirk today';
			end;
	run;

