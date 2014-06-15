/* nosocomial_patient_details.sas
 *
 * for each patient, print out a listing that includes relevant demographic information, as well as a listing of all prevalent or incident infections 
 
 */


* GET DEMO INFO ;

options nodate ls = 100 orientation = landscape center; * switch to landscape?? ;
title;

proc sort data= glnd.status; by id; run;
proc sort data= glnd.demo_his; by id; run;
proc sort data= glnd.plate1; by id; run;
proc sort data= glnd.plate6; by id; run;



%macro make_details(current_id = ) ;
	ods pdf startpage = yes;  * start new page for new person;
	ods escapechar='^' ;

	data noso_patient;
		merge 	glnd.status (in = randomized keep = id dt_random dt_drug_str apache_2 days_sicu_post_entry days_hosp_post_entry dt_discharge deceased days_until_death dt_death dt_admission order_randomized)
				glnd.demo_his (keep = id dt_admission ptint dt_birth dt_primary_elig_op gender race hispanic days_sicu_prior pre_op_kg 
				pre_op_cm  primary_diag wbc_count ards mech_vent nosc_infect ent_nutr ent_nutr_days parent_nutr parent_nutr_days  dt_primary_elig_op)

				glnd.plate1( keep = id in_sicu_choice)
				glnd.plate6( keep = id apache_total)
			;
	
		if ~randomized then DELETE; 

		where id = &current_id;
	


		* assign the quantities that we are interested in outputting to macro variables ;
		call symput('order_randomized',  put(order_randomized, 3.0));
		call symput('id',  put(id, 5.0));
		call symput('ptint', put(ptint, $3.));
		call symput('gender', put(gender, gender.));
		call symput('race', put(race, race.));
		call symput('age_at_random', compress(put(yrdif(dt_birth, dt_random, 'ACT/ACT'), 4.1)));		
		call symput('dt_random', put(dt_random, mmddyy.));
		call symput('dt_admission', put(dt_admission, mmddyy.));
		call symput('dt_discharge', put(dt_discharge, mmddyy.));
		call symput('dt_primary_elig_op', put(dt_primary_elig_op, mmddyy.));
		call symput('days_sicu_prior', compress(put(days_sicu_prior, 3.0)));
		call symput('bmi', compress(put( pre_op_kg / ((.01*pre_op_cm)**2), 4.1)));
		call symput('primary_diag', put(primary_diag, demo_diag.));
		call symput('in_sicu_choice', put(in_sicu_choice, op.));
		call symput('wbc_count', compress(put(wbc_count, 4.1)));
		call symput('ards', put(ards, yn.));
		call symput('mech_vent', put(mech_vent, yn.));
		call symput('nosc_infect', put(nosc_infect, yn.));
		call symput('center', put( floor(id / 10000), center.));
		call symput('apache_total', compress(put( apache_total, 2.)));
		call symput('days_sicu_prior', trim(put(days_sicu_prior, 3.0) || " days"));

	
		if deceased = 0 then call symput('deceased', put( deceased, yn.));
		else call symput('deceased', trim(put(deceased, yn.) || " (" || compress(put(days_until_death, 3.0)) || " days on study)"  ));

		if deceased & (dt_death <= dt_discharge) then call symput('hospital_death', put(1, yn.));
		else call symput('hospital_death', put(0, yn.));

		if deceased then call symput('days_study', "n/a");
		else if (today() - dt_random) > (365/2) then call symput('days_study', "> 6 months");
		else call symput('days_study', trim(put(today() - dt_random, 4.0) || " days" ));

		if ent_nutr = 1 then call symput('ent_nutr', trim(put(ent_nutr, yn.) || " (" || compress(put(ent_nutr_days, 3.0)) || " days)"  ));
		else call symput('ent_nutr', put(ent_nutr, yn.)) ;
	
		if parent_nutr = 1 then call symput('parent_nutr', trim(put(parent_nutr, yn.) || " (" || compress(put(parent_nutr_days, 3.0)) || " days)"  ));
		else call symput('parent_nutr', put(parent_nutr, yn.)) ;
	
	run;	



	* spit out this information in the desired format, using PDF commands - THIS MUST FOLLOW THE DATA STEP. SYMPUTs are processed at the end of the data step! ;
	ods pdf text = "^S={font_weight=bold font_size=14pt just=center} Nosocomial Infection Summary - Infection Adjudication ID: &order_randomized ^S={font_weight=bold font_size=11pt} (order randomized)";		
	ods pdf text = " ";
	ods pdf text = "[^S={font_size=11pt font_weight=bold just=left} Study site: ^S={} &center   ^S={font_weight=bold font_size=11pt}       Patient ID: ^S={} &id ] <---^S={font_weight=bold font_size=11pt font_style=slant} redact before adjudication";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Admitted: ^S={} &dt_admission  ^S={font_weight=bold font_size=11pt}          Eligibility Op: ^S={} &dt_primary_elig_op" ;	
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Randomized: ^S={} &dt_random  ^S={font_weight=bold font_size=11pt}     Discharged: ^S={} &dt_discharge" ;
	ods pdf text = " ";
	ods pdf text = "^S={font_size=11pt font_style= slant just=left} Vital status";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Deceased: ^S={} &deceased                                       ^S={font_size=11pt font_weight=bold just=left} Died in-hospital: ^S={} &hospital_death";
	ods pdf text = " ";
	ods pdf text = "^S={font_size=11pt font_style= slant just=left} Demographics";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Initials: ^S={} &ptint                                         ^S={font_size=11pt font_weight=bold just=left} Gender: ^S={} &gender";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Age at randomization: ^S={} &age_at_random years    ^S={font_size=11pt font_weight=bold just=left} Race: ^S={} &race";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Apache II: ^S={} &apache_total		                                     ^S={font_size=11pt font_weight=bold just=left} BMI: ^S={} &bmi";
	ods pdf text = " ";
	ods pdf text = "^S={font_size=11pt font_style= slant just=left} Baseline Medical Summary";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Eligiblity operation: ^S={} &in_sicu_choice		              ^S={font_weight=bold font_size=11pt} Primary diagnosis: ^S={} &primary_diag ";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Days in the SICU prior to entry: ^S={} &days_sicu_prior		         ^S={font_size=11pt font_weight=bold just=left} WBC count: ^S={} &wbc_count ";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Post-op nosocomial infection: ^S={} &nosc_infect ^S={font_size=11pt font_weight=bold just=left} 		      		         ARDS: ^S={} &ards";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} On Mechanical Vent.: ^S={} &mech_vent";
	ods pdf text = "^S={font_size=11pt font_weight=bold just=left} Receiving PN within 30 days: ^S={}&parent_nutr                        ^S={font_size=11pt font_weight=bold just=left} Receiving EN within 30 days: ^S={} &ent_nutr";

	/* DEAD CODE:     ^S={font_weight=bold font_size=11pt}Time on study: ^S={}&days_study";*/
	ods pdf startpage = no;		


* this section is adapted from nosocomial_open.sas, retrieved on 10/16/07;

 	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.plate101; by id dfseq; run;
	proc sort data= glnd.plate102; by id dfseq; run;
	proc sort data= glnd.plate103; by id dfseq; run;

	* gather dates and infection data from forms;
	* looking at just infections for now;
	data noso_plates;
		merge	glnd.plate101 (keep = id dfseq dt_infect cult_obtain cult_positive cult_org_code_1 org_spec_1 cult_site_code_1)
				glnd.plate102 (keep = id dfseq cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5 org_spec_2 org_spec_3 org_spec_4 org_spec_5
										cult_site_code_2 cult_site_code_3 cult_site_code_4 cult_site_code_5)
				glnd.plate103 (keep = id dfseq infect_confirm site_code type_code);
		by id dfseq;
	run;

	data noso;
		merge	noso_plates (in = has_infection)
				glnd.status	(keep = id dt_random dt_drug_str)
			;
		by id;

		where id = &current_id;

		* delete people brought in from status that do not have an infection;
		if ~has_infection then DELETE;

		* determine if prevalent or incident. 
			* incident if yes to nosocomial (pg 3) and more than 2 calendar days after randomization (though technically 48 hours after time of study drug starting) ;
			* prevalent if yes to nosocomial (pg 3) and less than 2 calendar days after randomization (though technically 48 hours after time of study drug starting) ;
	
		* determine infection onset ;	 
		days_post_entry = dt_infect - dt_random;
		if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry > 2) then incident = 1;
		else if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry <= 2) then incident = 0;

		* suspected, not confirmed. - added 12/3/07 ;
		if infect_confirm in (3,4)  then suspected_only = 1; else suspected_only = 0;
		


		* recode vars for non-infections;
		if (infect_confirm > 2) then incident = .;  
		if site_code ="0000" then site_code = " ";
		if type_code ="0000" then type_code = " ";
	
		format incident yn.;
		

			* Set up text field to contain organism format. need to have text rather than numeric so can adjust the "other people";
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);

			* Adjust "other" categories to include the name of the organism;
			if (cult_org_code_1 in (9, 20, 21)) then organism_1= trim(put(organism_1, $30.)) || " - " || trim(put(org_spec_1, $35.)) ;
			if (cult_org_code_2 in (9, 20, 21)) then organism_2= trim(put(organism_2, $30.)) || " - " || trim(put(org_spec_2, $35.)) ;
			if (cult_org_code_3 in (9, 20, 21)) then organism_3= trim(put(organism_3, $30.)) || " - " || trim(put(org_spec_3, $35.)) ;
			if (cult_org_code_4 in (9, 20, 21)) then organism_4= trim(put(organism_4, $30.)) || " - " || trim(put(org_spec_4, $35.)) ;
			if (cult_org_code_5 in (9, 20, 21)) then organism_5= trim(put(organism_5, $30.)) || " - " || trim(put(org_spec_5, $35.)) ;


			* remove repeat organisms from the same infection report, comparing the text labels, working backwards from the 5th organism ;
			if (organism_5 = organism_4) then do; organism_5 = .; cult_org_code_5 = .; org_spec_5 = .; end;
			if (organism_4 = organism_3) then do; organism_4 = .; cult_org_code_4 = .; org_spec_4 = .; end;
			if (organism_3 = organism_2) then do; organism_3 = .; cult_org_code_3 = .; org_spec_3 = .; end;
			if (organism_2 = organism_1) then do; organism_2 = .; cult_org_code_2 = .; org_spec_2 = .; end;
 
			
		
		label
			dt_infect = "Date Suspect. Onset"
			incident = "Incident"
			days_post_entry = "Days post study entry"
			cult_positive="Culture positive?"
			cult_obtain="Culture obtained?"
	        	site_code="Site code"
	        	type_code="Type code"
			infect_confirm="Infection confirmed?"

			organism_1 ="1st cult. org."
			organism_2 ="2nd cult. org."
			organism_3 ="3rd cult. org."
			organism_4 ="4th cult. org."
			organism_5 ="5th cult. org."

			cult_site_code_1 ="1st cult. site."
			cult_site_code_2 ="2nd cult. site."
			cult_site_code_3 ="3rd cult. site."
			cult_site_code_4 ="4th cult. site."
			cult_site_code_5 ="5th cult. site."
			;

	run;

	/* add in ventilator info for pneumonias */
	proc sort data = noso; by id dt_infect site_code type_code; run;
	proc sort data = glnd_rep.pneu; by id dt_infect site_code type_code; run;

	data noso;
		merge noso
		glnd_rep.pneu (keep = id dt_infect vent_infect site_code type_code)
		;

		by id dt_infect site_code type_code;

	run;

	proc sort data= noso; by id  days_post_entry infect_confirm   ; run;


	* PREVALENT INFECTIONS ;
		data prev;
			set noso;
			where incident = 0;
		run;
	
		ods pdf text = " ";
		
		* check if there are any prevalent infections ;
		%if (%sysfunc(attrn(%sysfunc(open(prev, IS)), any)) ~= 1) %then %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Prevalent Infections: ^S={font_size=11pt font_weight=bold just=left} none	";
		%end;
		%else %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Prevalent Infections:";
		%end;
		ods pdf style = journal;
			proc print data= prev noobs label split = '*' width=minimum style(table)= [font_width = compressed ] ;
				var dt_infect days_post_entry infect_confirm cult_obtain cult_positive cult_site_code_1 organism_1 cult_site_code_2 organism_2 cult_site_code_3 organism_3 
					site_code type_code vent_infect;
			run;
	
	
	
	* INCIDENT INFECTIONS ;
		data inc;
			set noso;
			where incident = 1;
		run;
	
		ods pdf style = printer;
		ods pdf text = " ";

		* check if there are any incident infections ;
		%if (%sysfunc(attrn(%sysfunc(open(inc, IS)), any)) ~= 1) %then %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Incident Infections: ^S={font_size=11pt font_weight=bold just=left} none	";
		%end;
		%else %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Incident Infections:";
		%end;
		ods pdf style = journal;
			proc print data= inc noobs label split = '*' width=minimum style(table)= [font_width = compressed ];
				var dt_infect days_post_entry infect_confirm cult_obtain cult_positive cult_site_code_1 organism_1 cult_site_code_2 organism_2 cult_site_code_3 organism_3
					site_code type_code vent_infect;
			run;
	
	
	
	* SUSPECTED, NOT CONFIRMED;
		data susp;
			set noso;
			where suspected_only = 1;
		run;
	
		ods pdf style = printer;
		ods pdf text = " ";

		* check if there are any prevalent infections ;
		%if (%sysfunc(attrn(%sysfunc(open(susp, IS)), any)) ~= 1) %then %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Suspected Infections, Not Confirmed: ^S={font_size=11pt font_weight=bold just=left} none	";
		%end;
		%else %do;
			ods pdf text = "^S={font_size=11pt font_style= slant just=left} Suspected Infections, Not Confirmed:";
		%end;
	
		ods pdf style = journal;
	
			proc print data= susp noobs label split = '*' width=minimum style(table)= [font_width = compressed ];
				
				var dt_infect days_post_entry infect_confirm cult_obtain cult_positive cult_site_code_1 organism_1 cult_site_code_2 organism_2 cult_site_code_3 organism_3
					site_code type_code vent_infect;
			run;


	* ON A SECOND PAGE, GIVE A LISTING OF ALL CONCOMITANT MEDICATIONS, DOSES AND DATES ; 
	*	ods pdf startpage = yes;


		ods pdf text = " ";
		ods pdf style = printer;
		ods pdf text = "^S={font_size=11pt font_style=slant just=left} Summary of Concomitant Medications";

		ods pdf style = journal;
		proc sort data = glnd.concom_meds; by id dt_meds_str med_code; run;
		proc print data = glnd.concom_meds label noobs;
			where id = &current_id;
			var dt_meds_str dt_meds_stp meds med_code meds_dose;
		run;
	
%mend make_details;
	


proc sort data = glnd.status; by dt_random; run;
proc print data= glnd.status;
	var id dt_random;
run;


*** MUST DO ONE ID AT A TIME. DOESN'T WORK IF REPEATEDLY RUN MACRO ON DIFFERENT IDS!;


data _null_;
   infile 'review.txt';
   input this_id;
call symput('this_id',  put(this_id, 5.0));
  
run;

data _null_;
   infile 'review.email';
   length email $ 50;
   input email $ ;
call symput('email',  email);
  
run;
*options symbolgen mprint mlogin;

				ods pdf file = "/glnd/sas/reporting/patient_pdfs/nosocomial_review_cover_&this_id..pdf" 	;
						%make_details(current_id= &this_id) run;
						quit;
				ods pdf close;

data _null_;
 file 'reviewemail';
   put "/usr/local/bin/sendmessage -r &email -a /glnd/sas/reporting/patient_pdfs/nosocomial_review_cover_&this_id..pdf";
   put "chmod -f 777 /glnd/sas/reporting/patient_pdfs/nosocomial_review_cover_&this_id..pdf";
  
proc sort data = glnd.status; by id; run;
quit;




