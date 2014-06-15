/* sofa_stats_open.sas 
 * 
 *
 *
 **/
	
*Created a temp file of the longitudinal data to work from;
data LongData;
	*set "/glnd/sas/dsmc/20070820/followup_all_long.sas7bdat";
	set glnd.followup_all_long;
run;
*Output the max for each sofa measure for week 1 for each patient;
proc means data = LongData max n;
	where day lt 8;
	var sofa_resp sofa_coag sofa_liver sofa_cardio sofa_cns sofa_renal day;
	by id;
	output out= sofamax1 max(sofa_resp)= respmax max(sofa_coag)= coagmax 
	max(sofa_liver)= livermax max(sofa_cardio)= cardiomax max(sofa_cns)= cnsmax 
	max(sofa_renal)= renalmax n(sofa_resp) = n1; 
	
run;
*Now that I have the max values in a table I add them up to create the maxSOFA score for week 1;

data sofamax1;
	set sofamax1;
	Sofamax_wk1 = respmax + coagmax + livermax + cardiomax + cnsmax + renalmax;
run;
*I created a small table with the day 1 total SOFA score for each patient so I can merge with the max table
and get the Delta SOFA score;

data sofaday1;
	set Longdata; 
	keep id sofa_tot;

	where day=1;
run;

data sofamax1;

	merge sofamax1 sofaday1;
	by id;
	label sofa_tot = Day1Total;
run;
* Now that the tables are merged I can subtract the day1 sofa score from the MaxSOFA score and get SOFA delta;
data sofamax1;
	set sofamax1;
	SofaDelta_Wk1 = sofamax_wk1 - sofa_tot;

run;

****Now I can do all of that again for week two data***********
****I just need to change the day fields and name the tables differently;





;

 proc means data = LongData max;
	where day le 14 and day ge 8;
	var sofa_resp sofa_coag sofa_liver sofa_cardio sofa_cns sofa_renal ;
	by id;
	output out= sofamax2 max(sofa_resp)= respmax max(sofa_coag)= coagmax 
	max(sofa_liver)= livermax max(sofa_cardio)= cardiomax max(sofa_cns)= cnsmax 
	max(sofa_renal)= renalmax n(sofa_resp) = n2; 
	label n2= Days2;
run;
*Now that I have the max values in a table I add them up to create the maxSOFA score for week 2;

data sofamax2;
	set sofamax2;
	Sofamax_wk2 = respmax + coagmax + livermax + cardiomax + cnsmax + renalmax;
run;
*I created a small table with the day 8 total SOFA score for each patient so I can merge with the max table
and get the Delta SOFA score;

data sofaday8;
	set Longdata; 
	keep id sofa_tot;

	where day=8;
run;

data sofamax2;

	merge sofamax2 sofaday8;
	by id;
	label sofa_tot = Day8Total;
run;
* Now that the tables are merged I can subtract the day1 sofa score from the MaxSOFA score and get SOFA delta;
data sofamax2;
	set sofamax2;
	SofaDelta_Wk2 = sofamax_wk2 - sofa_tot;

run;

*********Now I have two tables, one with week 1 info and another with week 2 information. I can merge these and create
a total table for each patient;


;

data sofa_score_Table;

	merge sofamax1 sofamax2;
	by id;
	keep id sofamax_wk1 sofaDelta_wk1 sofamax_wk2 sofaDelta_wk2 n1 n2;

run; 

/** END SEBASTIAN. BEGIN ELI **/


* ELI 10/1/07 ;
* touch up data ;
data sofa_score_Table;
	set sofa_score_Table( rename = (n1 = days_wk1 n2= days_wk2));

	if days_wk2 = . then days_wk2= 0; * recode missing days to be 0 days in the SICU ;

	* calculate n present in ICU during the given week;
	n1 = (days_wk1 ~= 0);
	n2 = (days_wk2 ~= 0);

run;

* return median (MAD) max and delta SOFA scores for each week ;
proc univariate data= sofa_score_table;
	var sofamax_wk1 sofaDelta_wk1 sofamax_wk2 sofaDelta_wk2 days_wk1 days_wk2 n1 n2;
	output out = glnd.sofa_stats_open 
				median = med_max_7 med_delta_7 med_max_14 med_delta_14 med_days_7 med_days_14
				mad= mad_max_7 mad_delta_7 mad_max_14 mad_delta_14 mad_days_7 mad_days_14
				sum = a b c d e f n_7 n_14
				;
run;

data glnd.sofa_stats_open;
	set glnd.sofa_stats_open;

	* row 1 ;
	study_days = "1 - 7 "; n = n_7; med_sicu_days = med_days_7; mad_sicu_days = mad_days_7; 
	max = compress(put(med_max_7, 3.)) || " " || 'B1'x || " " || compress(put(mad_max_7, 3.) ); 
	delta= compress(put(med_delta_7, 3.)) || " " || 'B1'x || " " ||  compress(put(mad_delta_7, 3.)); 
	output;


	* row 2 ;
	study_days = "8 - 14"; n = n_14; med_sicu_days = med_days_14; mad_sicu_days = mad_days_14; 
	max = compress(put(med_max_14, 3.)) || " " || 'B1'x || " " || compress(put(mad_max_14, 3.) ); 
	delta= compress(put(med_delta_14, 3.)) || " " || 'B1'x || " " ||  compress(put(mad_delta_14, 3.)); 
	output;

	label 
		study_days = "Study Days"
		n = "n"
		med_sicu_days = "Days in SICU*(median)"
		mad_sicu_days = "Days in SICU*MAD"
		max= "Max SOFA*(median " 'B1'x " MAD)"
		delta = "Delta SOFA*(median " 'B1'x " MAD)"
		;

	drop med_max_7 med_delta_7 med_max_14 med_delta_14  mad_max_7 mad_delta_7 mad_max_14 mad_delta_14 
			mad_days_7 mad_days_14 med_days_7 med_days_14 a b c d e f n_7 n_14;

run;

* OUTPUT TABLE TO PDF;
ods pdf file = "/glnd/sas/reporting/sofa_stats_open.pdf" style = journal;
	options nodate nonumber;
	title "Summary of Max and Delta SOFA Score";
	proc print data = glnd.sofa_stats_open label noobs split= "*";
		var study_days;
		var n med_sicu_days max delta /style(data) = [just=center];
	run;
ods pdf close;

/* ADDED BY ELI 9/28/07 - CHECK FOR ERRORS IN THE TOTALLING OF SOFA SCORES 
options pagesize=65 nodate ;
title;
data x;
	set glnd.followup_all_long;

	if sofa_tot = sofa_resp + sofa_coag + sofa_liver + sofa_cardio + sofa_cns + sofa_renal then total_ok= 1;
	else total_ok = 0;

	keep id DAY sofa_resp sofa_coag sofa_liver sofa_cardio sofa_cns sofa_renal sofa_tot total_ok;

run;
proc print data=x;run;quit;

*/
