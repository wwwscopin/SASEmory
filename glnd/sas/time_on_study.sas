/* time_on_study.sas
 *
 * how long a patient has been enrolled
 *
 */


	data glnd.time_on_study;
		set glnd.status (keep = id dt_random );
	
		days_on_study = (date() - dt_random);
		months_on_study = days_on_study /30 ;

		/* MODIFY ONCE HAVE SIX-MONTH PHONE CALL OR LOST TO FOLLOW-UP FORMS TO TERMINATE DAYS ON STUDY 
			also add death*/

		format months_on_study 4.1;

		label 
			dt_random = "Date Randomized"
			days_on_study = "Days on Study"
			months_on_study = "Months on Study";
	run;


	title 'GLND: Time on Study';
	proc print data = glnd.time_on_study label;


	
