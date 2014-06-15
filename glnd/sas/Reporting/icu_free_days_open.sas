/* icu_free_days_open.sas
 *
 */


	proc sort data = glnd.plate49;	by id;	run;


	data icu_free_days;
		set glnd.plate49;
		where (SICU_inter_start_day_1 ~= .) | (SICU_readmit_day_2 ~= .) |(SICU_readmit_day_3 ~= .) |(SICU_readmit_day_4 ~= .)|(SICU_readmit_day_5 ~= .); * include only if they have some readmit data ;
	run;
	



	proc sort data= icu_free_days; by id; run;
	proc sort data= glnd.status; by id; run;
	
	* Add hospital information;

	data icu_free_days;
		merge 	icu_free_days (in = has_multi)	
				glnd.status (keep = id dt_random dt_leave_sicu mortality_28d days_sicu_prior)
				;
		by id;

		multi_sicu = has_multi;
		
		if has_multi then do;

			* compute individual time intervals;
				days_in_sicu_1 = (SICU_inter_start_day_1 - dt_random) ; 
				days_in_sicu_2 = (SICU_inter_start_day_2 - SICU_readmit_day_2) ; 
				days_in_sicu_3 = (SICU_inter_start_day_3 - SICU_readmit_day_3) ; 
				days_in_sicu_4 = (SICU_inter_start_day_4 - SICU_readmit_day_4) ; 
				days_in_sicu_5 = (SICU_inter_start_day_5 - SICU_readmit_day_5) ; 

			
		end;
	
		** people with just one stay in the SICU;
		else		days_in_sicu_1 = dt_leave_sicu - dt_random;



		* zero out missing times and sum them up - the first run is excluding to force a missing value on those with an incomplete first run;
			if (days_in_sicu_2 = .) then days_in_sicu_2 = 0; 
			if (days_in_sicu_3 = .) then days_in_sicu_3 = 0;
			if (days_in_sicu_4 = .) then days_in_sicu_4 = 0;
			if (days_in_sicu_5 = .) then days_in_sicu_5 = 0;

		* this total excludes penalty of "0" SICU-free days for death ... giving a "raw" days on mechanical ventilation, reporting on what is on the on/off log ;
			days_in_sicu_raw = days_in_sicu_1 + days_in_sicu_2 + days_in_sicu_3 + days_in_sicu_4 + days_in_sicu_5  ;

		* Use the raw days in the SICU to also compute total days in sicu during hospitalization ;
			days_in_sicu_hosp_stay = days_in_sicu_raw + days_sicu_prior;
		
		/*** COMPUTE ICU-free days ***/

				* if a patient is in and out in the same day AFTER STUDY ENROLLMENT, assign it to be a half-day ;

					* default adjusted days in sicu to raw values;
						days_in_sicu_1_adj = days_in_sicu_1 ; 
						days_in_sicu_2_adj = days_in_sicu_2 ;
						days_in_sicu_3_adj = days_in_sicu_3 ;
						days_in_sicu_4_adj = days_in_sicu_4 ;
						days_in_sicu_5_adj = days_in_sicu_5 ;

						if (days_in_sicu_1_adj = 0) then days_in_sicu_1_adj = 0.5; * it will only be 0 for those people in the SICU for under a day. everybody else has missing data for their first SICU stay ;

						if (days_in_sicu_2_adj = 0) & (SICU_inter_start_day_2 - SICU_readmit_day_2 ~= .) then days_in_sicu_2_adj = 0.5; 
						if (days_in_sicu_3_adj = 0) & (SICU_inter_start_day_3 - SICU_readmit_day_3 ~= .) then days_in_sicu_3_adj = 0.5; 
						if (days_in_sicu_4_adj = 0) & (SICU_inter_start_day_4 - SICU_readmit_day_4 ~= .) then days_in_sicu_4_adj = 0.5; 
						if (days_in_sicu_5_adj = 0) & (SICU_inter_start_day_5 - SICU_readmit_day_5 ~= .) then days_in_sicu_5_adj = 0.5; 

				* zero out missing times and sum them up ;
					if (days_on_vent_2_adj = .) then days_on_vent_2_adj = 0;
					if (days_on_vent_3_adj = .) then days_on_vent_3_adj = 0;
					if (days_on_vent_4_adj = .) then days_on_vent_4_adj = 0;
					if (days_on_vent_5_adj = .) then days_on_vent_5_adj = 0;

				days_in_sicu_adj = days_in_sicu_1_adj + days_in_sicu_2_adj + days_in_sicu_3_adj + days_in_sicu_4_adj + days_in_sicu_5_adj  ;


			** now calculate SICU-free days - penalizing for 28-day mortality!! **;

			if (mortality_28d = 1) | (days_in_sicu_adj > 28) then  icu_free_days = 0;
			else if (days_in_sicu_adj ~= .) then icu_free_days = 28 - days_in_sicu_adj;
		
	run;

	proc print; where id=31386;run;

/*
	proc print data = icu_free_days width = minimum;
		*var id multi_sicu days_in_sicu_1 days_in_sicu_2 days_in_sicu_1_adj days_in_sicu_2_adj days_in_sicu_raw days_in_sicu_adj mortality_28d icu_free_days; 
	run;
*/


	proc means data = icu_free_days n sum median ;

		output out = glnd_rep.icu_free_days_open
			n(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_n days_in_sicu_raw_n days_in_sicu_hosp_stay_n
			median(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_m days_in_sicu_raw_m days_in_sicu_hosp_stay_m
			q1(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_q1 days_in_sicu_raw_q1 days_in_sicu_hosp_stay_q1
			q3(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_q3 days_in_sicu_raw_q3 days_in_sicu_hosp_stay_q3
			min(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_min days_in_sicu_raw_min days_in_sicu_hosp_stay_min
			max(icu_free_days days_in_sicu_raw days_in_sicu_hosp_stay) = icu_free_days_max days_in_sicu_raw_max days_in_sicu_hosp_stay_max
		;

	run;

	proc print data = glnd_rep.icu_free_days_open;
	run;
	
	data glnd_rep.icu_free_days_open;
		set glnd_rep.icu_free_days_open;
		
		length row $ 50;
		length display_1 $ 40;
		length display_2 $ 40;
		
			row = "== During entire hospitalization ==";
			display_1 = " ";
			display_2 = " ";
			order = 1;
			output;
					
			row = "Total days in the SICU";
			display_1 = compress(put(days_in_sicu_hosp_stay_m, 4.1)) || " [" || compress(put(days_in_sicu_hosp_stay_q1, 4.1)) || ", " || compress(put(days_in_sicu_hosp_stay_q3, 4.1)) || "], " || compress(put(days_in_sicu_hosp_stay_n, 4.0)) ;
			display_2 = "[" || compress(put(days_in_sicu_hosp_stay_min, 4.1)) || ", " || compress(put(days_in_sicu_hosp_stay_max, 4.1)) || "]" ;
			order = 2;
			output;
			
			row = " ";
			display_1 = " ";
			display_2 = " ";
			order = 3;
			output;
			
			row = "== From study entry ==";
			display_1 = " ";
			display_2 = " ";
			order = 4;
			output;
			
			row = "Total days in the SICU";
			display_1 = compress(put(days_in_sicu_raw_m, 4.1)) || " [" || compress(put(days_in_sicu_raw_q1, 4.1)) || ", " || compress(put(days_in_sicu_raw_q3, 4.1)) || "], " || compress(put(days_in_sicu_raw_n, 4.0)) ;
			display_2 = "[" || compress(put(days_in_sicu_raw_min, 4.1)) || ", " || compress(put(days_in_sicu_raw_max, 4.1)) || "]" ;
			order = 5;
			output;
		
			row = "ICU-free days";
			display_1 = compress(put(icu_free_days_m, 4.1)) || " [" || compress(put(icu_free_days_q1, 4.1)) || ", " || compress(put(icu_free_days_q3, 4.1)) || "], " || compress(put(icu_free_days_n, 4.0)) ;
			display_2 = "[" || compress(put(icu_free_days_min, 4.1)) || ", " || compress(put(icu_free_days_max, 4.1)) || "]" ;
			order = 6;
			output;
	
		label 
			row = "." 
			display_1 = "med.\~[Q1,\~Q3],\~n"
			display_2 = "[min - max]"
		;
	run;

options nodate nonumber;
title "Summary of time in the SICU";

ods pdf file = "/glnd/sas/reporting/icu_free_days_open.pdf" style = journal;
	proc print data = glnd_rep.icu_free_days_open noobs label;
		var row;
		var display_1 display_2 /style(data) = [just=center];
	run;
ods pdf close;	


****/

** post-process table for display ;

* report VFD for patients on vent only and both ;		


data glnd_rep.sicudays;
   set icu_free_days (rename=(days_in_sicu_raw=sicudays));
   keep id sicudays;
proc print ;
*		var id  days_in_sicu_raw ; 
	run;
