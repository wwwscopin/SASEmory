/*  */

* 	write a macro that edits a variable &days which is the equivalent of a return value representing the days between
	study starting and and an input;


/* Req. Forms:
	1. 6 baseline pages
	2. Plate 8  
	3. demo form
	4. PN Calc
	5. Blood forms
	6. Daily Follow-Up
	
	tie them to day 1 - give days late?

use in to determine whether form exists and then "dfc" to determine lateness

*/

* We are looking at the first plate of forms only;

/* FIRST grab plates that are uniquely assigned to one visit */

proc sort data = glnd.status; by id; run;
proc sort data = glnd.apache_sicu; by id; run;
proc sort data = glnd.plate8; by id; run; * pharmacy conf. ;
proc sort data = glnd.plate9; by id; run; * demo ;
proc sort data = glnd.plate11; by id; run; * pn calc ;
proc sort data = glnd.plate23; by id; run; * day 3 f/u;
proc sort data = glnd.plate27; by id; run; * day 7 f/u ;
proc sort data = glnd.plate42; by id; run; * 30-day post-study drug discontinuation ;
proc sort data = glnd.plate45; by id; run; * day 28 vital status phonecall ;

* plate 14 - AA calc? ;
* plate 18 - concom meds? ; 

data glnd_df.submission;
	merge 
		glnd.apache_sicu (keep = id in = from_apache_sicu) /** create by plate3.sas **/
		glnd.plate8 (keep= id in = from_8 )
		glnd.plate9 (keep= id in = from_9)
		glnd.plate11 (keep= id in = from_11)
		glnd.plate23 (keep= id in = from_23)
		glnd.plate27 (keep= id in = from_27)
		glnd.plate42 (keep= id in = from_42)
		glnd.plate45 (keep= id in = from_45)
		;

	by id;

	* label if have a record of this plate - 1=Yes, 0=No, 2=not expected;
	if from_apache_sicu then apache_sicu = 1;
	if from_8 then pharm_conf = 1;
	if from_9 then demo = 1;
	if from_11 then pn_calc = 1;
	if from_23 then day_3 = 1;
	if from_27 then day_7 = 1;
	if from_42 then post_drug_30 = 1;
	if from_45 then day_28_vital = 1;


run;


/* NEXT, get plates which are used for multiple visit */
	* blood forms, 14,21 visit - by id and visit ;
	
	proc sort data = glnd.plate15; by id dfseq ; run; * blood calc ;
	proc sort data = glnd.plate32; by id dfseq; run; * day 14/21/28 f/u ;

	* get data stacked;	
	data a;
		merge 
			glnd.plate15 (keep = id dfseq in = from_15)
			glnd.plate32 (keep = id dfseq in = from_32)
			;
		by id dfseq;
	
		if from_15 then has_15 = 1;
		if from_32 then has_32 = 1;
	run;

	* now transpose such that each visit and plate is in a column;
		proc transpose data= a out=b_15 ;
			by id;
			id dfseq;
			var has_15;
		run;

		proc transpose data= a out=b_32 ;
			by id;
			id dfseq;
			var has_32;
		run;

		data b;
			merge
				b_32 (drop = _1 _2 _3 rename = (_4 = day_14 _5 = day_21 _6 = day_28))
				b_15 (rename = (_1 = blood_base _2 = blood_3 _3 = blood_7 _4 = blood_14 _5 = blood_21 _6 = blood_28))
				;
	
			by id;

			drop _NAME_;
		run;
		

	* get 2/4/6 month phone call through a similar process;
		proc sort data = glnd.plate43; by id dfseq; run;
		
		data phone;
			set glnd.plate43 (keep = id dfseq in=from_43);
		
			if from_43 then has_43 = 1;
		run;
		
		proc transpose data= phone out= phone_out;
			by id;
			id dfseq;
			var has_43;
		run; 	
		
		data phone_out;
			set phone_out  (drop = _NAME_ rename = (_42 = phone_2mo _43 = phone_4mo _44 = phone_6mo));
		
		run;
		



/* MERGE all plate info, and all study termination variables */
data glnd_df.submission;
	merge 
		glnd_df.submission
		b
		phone_out
		glnd.status (keep = id days_hosp_post_entry days_until_death deceased still_in_hosp dt_random)
	;

	by id; 
run;

/* post-process table - enter reasons for non-submission. looks for days until discharge or days in hospital so far (if still in hopsital) */
data glnd_df.submission;
	set glnd_df.submission;


	fu_window = 7; * allows one week for daily follow-up and blood forms to be sent in. set to zero to see what is currently owed! ;
	phone_window = 14; * allows one week for phonecall forms to be sent in. set to zero to see what is currently owed!;
	
	* unconditionally needed forms - no time windows for now. immediately expected ;
	if (pharm_conf ~= 1) then pharm_conf = 0;
	if (pn_calc ~= 1) then pn_calc = 0;
	if (demo ~= 1) then demo = 0;
	if (apache_sicu ~= 1) then apache_sicu = 0;
	
	* daily f/u - need to be in-hospital and alive;

	if (day_3 ~= 1) then day_3 = 0; * must have first f/u form in; 
	if (day_7 ~= 1) then do; if ((date() - dt_random) >= (7 + fu_window)) & ((days_hosp_post_entry > 3) | (still_in_hosp )) then day_7 = 0; else day_7 = 2; end;
	if (day_14 ~= 1) then do; if ((date() - dt_random) >= (14 + fu_window)) & ((days_hosp_post_entry > 7) | (still_in_hosp))  then day_14 = 0; else day_14 = 2; end;
	if (day_21 ~= 1) then do; if ((date() - dt_random) >= (21 + fu_window)) & ((days_hosp_post_entry > 14) | (still_in_hosp)) then day_21 = 0; else day_21 = 2; end;
	if (day_28 ~= 1) then do; if ((date() - dt_random) >= (28 + fu_window)) & ((days_hosp_post_entry > 21) | (still_in_hosp)) then day_28 = 0; else day_28 = 2; end;

	* everything else - just need to be alive ;

	if (blood_base ~= 1) then blood_base = 0;
	if (blood_3 ~= 1) then blood_3 = 0;
	if (blood_7 ~= 1) then do; if ((date() - dt_random) < (7 + fu_window)) | ((deceased) & (days_until_death < 7)) then blood_7 = 2; else blood_7 = 0; end;
	if (blood_14 ~= 1) then do; if ((date() - dt_random) < (14 + fu_window)) | ((deceased) & (days_until_death < 14)) then blood_14 = 2; else blood_14 = 0; end;
	if (blood_21 ~= 1) then do; if ((date() - dt_random) < (21 + fu_window)) | ((deceased) & (days_until_death < 21)) then blood_21 = 2; else blood_21 = 0; end;
	if (blood_28 ~= 1) then do; if ((date() - dt_random) < (28 + fu_window)) | ((deceased) & (days_until_death < 28)) then blood_28 = 2; else blood_28 = 0; end;

	* for 28 day/2/4/6 month f/u calls, make sure that they are alive and the specified time has elapsed;
	if (day_28_vital ~= 1) then do; if ((date() - dt_random) < (28 + fu_window) ) | ((deceased) & (days_until_death < 28)) then day_28_vital = 2; else day_28_vital = 0; end;
	if (phone_2mo ~= 1) then do; if ((date() - dt_random) < (90 + phone_window)) | ((deceased) & (days_until_death < 60.9)) then phone_2mo = 2; else phone_2mo = 0; end; * 30 extra days given for getting this form in;
	if (phone_4mo ~= 1) then do; if ((date() - dt_random) < (150 + phone_window)) | ((deceased) & (days_until_death < 121.8)) then phone_4mo = 2; else phone_4mo = 0; end; * 30 extra days given for getting this form in;
	if (phone_6mo ~= 1) then do; if ((date() - dt_random) < (210 + phone_window)) | ((deceased) & (days_until_death < 182.6)) then phone_6mo = 2; else phone_6mo = 0; end; * 30 extra days given for getting this form in;
	
	* for 30-day post-study drug, we also do not expect the form if the patient has been enrolled for <= 30 days;
	if (post_drug_30 ~= 1) then do; if ((date() - dt_random) < (30 + fu_window))| ((deceased) & (days_until_death < 30)) | (days_hosp_post_entry >= 30) then post_drug_30 = 2; else post_drug_30 = 0; end;
	
	* add center;
	center = floor(id /10000);
	
	if id=41091 then do; post_drug_30=2; day_28_vital=2; blood_14=2; blood_21=2; blood_28=2; phone_2mo=2; phone_4mo=2; phone_6mo=2; end;
	if id=41141 then do; post_drug_30=2; phone_6mo=2; end;
	if id in(32229,32262,41143) then do; post_drug_30=1; end;
	if id in(31075,32064,32349,41090,41144,41145,41156,42133) then do; day_28_vital=2; end;


	label
		pharm_conf = "Pharmacy Conf."
		demo = "Demo."
		pn_calc = "PN Calc."
		apache_sicu = "APACHE II SICU entry"
		day_3 = "Day 3 F/U"
		day_7 = "Day 7 F/U"
		day_14 = "Day 14 F/U"
		day_21 = "Day 21 F/U"
		day_28 = "Day 28 F/U"
		blood_base = "Baseline Blood Coll."
		blood_3 = "Day 3 Blood Coll."
		blood_7 = "Day 7 Blood Coll."
		blood_14 = "Day 14 Blood Coll."
		blood_21 = "Day 21 Blood Coll."
		blood_28 = "Day 28 Blood Coll."

		post_drug_30 = "30-Day Post-drug F/U"
		day_28_vital = "Day 28 Vital Assess."
		phone_2mo = "2-Month F/U Call"
		phone_4mo = "4-Month F/U Call"
		phone_6mo = "6-Month F/U Call"
		;
	

	drop days_hosp_post_entry days_until_death deceased still_in_hosp dt_random;
run;

proc print;
where center in(3,4); 
where post_drug_30=0 or day_28_vital=0;
var id post_drug_30 day_28_vital;
run;

proc format library= work;
	value yndash 	1 = "Y"
				0 = "N"
				2 = "-"
	;

run;

/* compute summaries by center */

	proc freq data= glnd_df.submission ; 
	
		tables pharm_conf * center /out= pharm_conf sparse;
		tables pn_calc * center /out= pn_calc sparse;
		tables demo * center /out= demo sparse;
		tables day_3 * center /out= day_3 sparse;
		tables day_7 * center /out= day_7 sparse;
		tables day_14* center /out= day_14 sparse;  
		tables day_21* center /out= day_21 sparse; 
		tables day_28 * center /out= day_28 sparse; 
		tables blood_base * center /out= blood_base sparse;  
		tables blood_3 * center /out= blood_3 sparse;
		tables blood_7 * center /out= blood_7 sparse;
		tables blood_14 * center /out= blood_14 sparse;
		tables blood_21 * center /out= blood_21 sparse;
		tables blood_28 * center /out= blood_28 sparse;
		tables day_28_vital * center /out= day_28_vital sparse;
		tables phone_2mo * center /out= phone_2mo sparse;
		tables phone_4mo * center /out= phone_4mo sparse;
		tables phone_6mo * center /out= phone_6mo sparse;
		tables post_drug_30 * center  /out= post_drug_30 sparse;
		tables apache_sicu * center /out= apache_sicu sparse;

	run;
	proc print data= day_7; run;

/* this macro arranges the expected and received information into one dataset */
	%macro make_exp_recvd;
		
		%let x= 1;
	
	  	%do %while (&x < 21);
  															       
  			%if &x = 1 %then %do; %let variable = pharm_conf ; %let description = "Pharmacy Conf.      "; %end; 
  			%else %if &x = 2 %then %do; %let variable = pn_calc ; %let description = "PN Calc."; %end; 
  			%else %if &x = 3 %then %do; %let variable = demo ; %let description = "Demo."; %end; 
			%else %if &x = 4 %then %do; %let variable = apache_sicu ; %let description = "APACHE II SICU entry"; %end; 
  			%else %if &x = 5 %then %do; %let variable = day_3 ; %let description = "Day 3 F/U"; %end; 
	  		%else %if &x = 6 %then %do; %let variable = day_7 ; %let description = "Day 7 F/U"; %end; 
  			%else %if &x = 7 %then %do; %let variable = day_14 ; %let description = "Day 14 F/U"; %end; 
  			%else %if &x = 8 %then %do; %let variable = day_21 ; %let description = "Day 21 F/U"; %end; 
  			%else %if &x = 9 %then %do; %let variable = day_28 ; %let description = "Day 28 F/U"; %end; 
  			%else %if &x = 10 %then %do; %let variable = blood_base; %let description = "Baseline Blood Coll."; %end; 
  			%else %if &x = 11 %then %do; %let variable = blood_3 ; %let description = "Day 3 Blood Coll."; %end; 
  			%else %if &x = 12 %then %do; %let variable = blood_7 ; %let description = "Day 7 Blood Coll."; %end; 
  			%else %if &x = 13 %then %do; %let variable = blood_14 ; %let description = "Day 14 Blood Coll." ; %end; 
  			%else %if &x = 14 %then %do; %let variable = blood_21 ; %let description = "Day 21 Blood Coll."; %end; 
  			%else %if &x = 15 %then %do; %let variable = blood_28 ; %let description = "Day 28 Blood Coll."; %end; 
  			%else %if &x = 16 %then %do; %let variable = day_28_vital ; %let description = "Day 28 Vital Assess."; %end; 
  			%else %if &x = 17 %then %do; %let variable = phone_2mo ; %let description = "2-Month F/U Call" ; %end; 
  			%else %if &x = 18 %then %do; %let variable = phone_4mo ; %let description = "4-Month F/U Call"; %end; 
  			%else %if &x = 19 %then %do; %let variable = phone_6mo ; %let description = "6-Month F/U Call"; %end; 
  			%else %if &x = 20 %then %do; %let variable = post_drug_30 ; %let description = "30-Day Post-drug F/U"; %end; 
 	
			proc sort data= &variable; by center &variable; run;
		
			* process the data for the current form;
			data c;
				set &variable;
				retain old_val old_count;

				by center;
				
				length form $23;

				* not received;
				if &variable = 0 then do; 
					old_val= &variable; 
					old_count= count; 
					DELETE; * remove this record;
				end;
	
				* received;
				else if &variable = 1 then do; 
					if old_count = . then old_count = 0; * in case of 100% submission, make the number of non-submitted = 0 ;
					expected = count + old_count; 
					received = count;
					pct_received = (received / expected) * 100;
					form = &description;
					order = &x; * the order of the variables for later sorting and printing; 
				end;
	
				else if &variable = 2 then DELETE; * remove this record - not expected ;	
	
				*keep center form received expected pct_received order;
			run;
			
			* concatenate all variables into one file;
			%if &x = 1 %then %do;
				data glnd_df.submission_summary; 
					set c;
			%end;

			%else %do;
				data glnd_df.submission_summary; 
					set glnd_df.submission_summary
						c;
					
					label
						center = "Center"
						form = "Form"
						expected = "Expected"
						received = "Received"
						pct_received = "Percent Received" 
					;
					format pct_received 5.1;
				run;
			%end;

		%let x= &x + 1;
		%end;

%mend make_exp_recvd;


%make_exp_recvd run;


**** Add missed blood draws to the table - 5/12/08 ****;

	data blood;
		set glnd.plate15;
	
	
		* add center;
		center = floor(id /10000);
	run;
	
	proc print;
	title "Baseline Blood Missing" ;
	where dfseq=1 and missed_blood_drw;
	run;
	
	proc means data = blood n sum;
		class center dfseq;
		var missed_blood_drw;
		output out = missed_blood sum(missed_blood_drw) = total_missed_draws;
	run;
	
	
	proc print data = missed_blood;
	run;
	
	* clean up FREQ output;  
	data missed_blood;
		set missed_blood;

		where _TYPE_ = 3;

		attended_visit_total = _FREQ_ - total_missed_draws;

		attended_visit_disp = compress(put(attended_visit_total, 4.0)) || " (" || compress(put(attended_visit_total / _FREQ_ * 100, 4.1 )) || "%)";
		
		order = 9 + dfseq; * so we can merge this into the main table;
	run;

	* add blood draw attendance into main table;
	proc sort data = glnd_df.submission_summary; by center order; run;

	data glnd_df.submission_summary;
		merge glnd_df.submission_summary
				missed_blood (keep = center order attended_visit_disp);

		by center order;

		label attended_visit_disp = "Blood obtained? Total (%)";
	run;
	

********;


options orientation = landscape leftmargin= .1 rightmargin = .1 nodate nonumber;
ods pdf file = "form_submission_by_center.pdf" style = journal;
	title1 "GLN-D Scheduled Forms Received and Expected";


	/* Print summary info */
	
	proc sort data =	glnd_df.submission_summary; 
		by center order;
	run;
	footnote1; footnote2; footnote3; * reset;
 	title2 f= zapf h=3 justify = center "Center Summary";

	proc print data =	glnd_df.submission_summary label noobs split = "*";
		by center;
		pageby center;
		label center = '00'X;

		var form expected received pct_received attended_visit_disp; 

		format center center.;
	run;
ods pdf close;


	proc print data =	glnd_df.submission_summary label noobs split = "*";


		var center order form expected received pct_received attended_visit_disp; 

		format center center.;
	run;


ods pdf file = "form_submission_detail.pdf" style = journal ;
	/* Print patient details */

	footnote1 f= zapfb justify = left h = 3 "Y = form received" ;
	footnote2 f= zapfb justify = left h = 3 "N = form expected and not received" ;
	footnote3 f= zapfb justify = left h = 3 "- = form not expected yet or ever due to patient mortality or hospital release";
	title2 f= zapf h=3 justify = center "patient detail";

	proc print data= glnd_df.submission label noobs width = minimum;
		var id pharm_conf pn_calc demo apache_sicu day_3 day_7 day_14 day_21 day_28 blood_base blood_3 blood_7 blood_14 blood_21 blood_28 day_28_vital phone_2mo phone_4mo phone_6mo post_drug_30;
	
		format pharm_conf pn_calc demo apache_sicu day_3 day_7 day_14 day_21 day_28
			blood_base blood_3 blood_7 blood_14 blood_21 blood_28 day_28_vital
			phone_2mo phone_4mo phone_6mo post_drug_30  yndash.;
	run;



ods pdf close;


