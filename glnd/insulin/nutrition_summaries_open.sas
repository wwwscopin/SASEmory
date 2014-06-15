/* nutrition_summaries_open.sas
 *
 * "Nutritional Benchmarks and Summaries" Table
 * provides summary information on PN kcal composition, as well as enteral feeding
 * this is the old "Template Table 24" 
 *
 * for DSMB OPEN SESSION
 *
 */

 * create library for reporting files and graphs;
 libname glnd_rep "/glnd/sas/reporting";



/* Part 1a - days of PN prior to enrollment, EN prior to enrollment */
	* add in day of EN, PN prior. start assembling into the data to be used in the top half of the table ;
	proc sort data= glnd.demo_his; by id; run;

	data en_pn_prior;
		set	glnd.demo_his (keep = id ent_nutr ent_nutr_days parent_nutr parent_nutr_days)	;
		
		* make sure that when they answer no, then days is set to missing, so that the two portions of our table line up  ;
		if (ent_nutr = 0) then ent_nutr_days = .;
		if (parent_nutr = 0) then parent_nutr_days = .;

	run;
	
	proc means data= en_pn_prior	noprint;
		output 	out= en_pn_prior_means
				n(id ent_nutr_days parent_nutr_days  ) = id_n ent_nutr_days_n parent_nutr_days_n
				median(ent_nutr_days parent_nutr_days) = ent_nutr_days_med parent_nutr_days_med
				min(ent_nutr_days parent_nutr_days) = ent_nutr_days_min parent_nutr_days_min
				max(ent_nutr_days parent_nutr_days) = ent_nutr_days_max parent_nutr_days_max
				sum(ent_nutr parent_nutr) = ent_nutr_s parent_nutr_s
			;
	run;
	
	* create table;
	data glnd_rep.en_pn_prior;
		set en_pn_prior_means;

		* design each column;
		* row 1;
			row = "PN administration prior to enrollment               ";
			yes = put(parent_nutr_s, 3.) || "/" || left(put(id_n, 3.));
			pct = (parent_nutr_s / id_n)*100; 
			median = parent_nutr_days_med;
			min = parent_nutr_days_min;
			max = parent_nutr_days_max;
			output;
		* row 2;
			row = "Enteral nutrition administration prior to enrollment";
			yes = put(ent_nutr_s, 3.) || "/" || left(put(id_n, 3.));
			pct = (ent_nutr_s / id_n)*100; 
			median = ent_nutr_days_med;
			min = ent_nutr_days_min;
			max = ent_nutr_days_max;
			output;
		format pct 4.1;
		
		drop _type_ _freq_ id_n ent_nutr_days_n parent_nutr_days_n ent_nutr_days_med parent_nutr_days_med 
			ent_nutr_days_min parent_nutr_days_min ent_nutr_days_max parent_nutr_days_max ent_nutr_s parent_nutr_s
			;
		
		label 	row = '00'x /* blank */
			  	yes = "Yes"
				pct = "Percent"
				median = "Median"	
				min = "Min"
				max = "Max"
			; 
	run;






/* Part 1b - days to enteral feeding */ 
	proc sort data= glnd.followup_all_long; 
		by id day; 
	run;

	* loop through days within a person;
	data days_to_en;
		set glnd.followup_all_long; 
		by id;

		retain first_en_day; * remember if the first enteral day has been found ;
		
		if first.id then first_en_day = .; * initialize the variable for each person;
		
		* compute total enteral kcal;
			* first recode missing to zero not for accuracy but in order to avoid having a '.' for the total if one value is missing;
			if tube_kcal = . then tube_kcal = 0;
			if oral_kcal = . then oral_kcal = 0;

			tot_ent_kcal = tube_kcal + oral_kcal;
		
		* find first day of enteral feeding;
		if (tot_ent_kcal = 0) then DELETE; * this is not the first day of enteral nutrition;
		else if (first_en_day = .) then first_en_day = day; * this is the first day of EN;
		else delete; * delete the days thereafter;
		
		keep id first_en_day;
	run;

	* merge with status to make load all IDs into this dataset (people who never received EN are currently excluded) ;
	proc sort data= days_to_en; by id; run;
	proc sort data= glnd.status; by id; run;
	data days_to_en;
		merge 	days_to_en
				glnd.status (keep = id still_in_hosp)
			;
		by id;

		if (first_en_day = .) & (still_in_hosp = 0) then never_en_hospital = 1;  * was the person ever on EN in hospital? otherwise, discharged or died w/o EN;
		if (first_en_day = .) & (still_in_hosp = 1) then not_yet_en = 1;  * still in hopsital but not yet on EN;
	run;

	proc means data= days_to_en noprint;
		output 	out= days_to_en_means
				n(first_en_day not_yet_en never_en_hospital ) = first_en_day_n not_yet_en_n never_en_hospital_n
				median(first_en_day) = first_en_day_med
				min(first_en_day) = first_en_day_min 
				max(first_en_day) = first_en_day_max 
			;
	run;

	* create table;
	data glnd_rep.days_to_en;
		set days_to_en_means;

		n_ent= first_en_day_n + never_en_hospital_n ; * denominator;
		call symput('n_enteral', put(n_ent, 3.0)); * store this value in a macro variable for use in printing the table;
	
		row = "Days to first enteral nutrition administration";		
		
		n =  put(first_en_day_n, 3.) || "/" || left(put(n_ent, 3.));

		label 	row = '00'x /* blank */
				n = "n"
				first_en_day_med = "Median"	
				first_en_day_min = "Min"
				first_en_day_max = "Max"	
				not_yet_en_n = "# not yet*on EN"
				never_en_hospital_n = "# never received*EN during*hospitalization"
			;

		drop _type_ _freq_ ;
	run;

	
/** Part 2 - trackings for percent PN kcal given as dextrose, lipid, enterally ---- formerly part 3 **/

		data long_status;
			merge	glnd.followup_all_long (in = has_followup)
					glnd.status (keep = id still_in_hosp dt_random dt_discharge);
			by id;

			if ~has_followup then delete ; * remove patients that are in status but for whom we have no follow-up data;

			days_study = dt_discharge - dt_random;
		run;	

	proc sort data= glnd.plate11; by id; run;
	data percent_pn;
		merge 	long_status
				glnd.plate11 (keep = id tot_kcal_goal tot_prot_1 rename = (tot_kcal_goal = daily_kcal_goal tot_prot_1 = daily_prot_goal ))
			;
		by id;
		
		* percent of intravenous parenteral nutrition (not just the PN bag) administered as various forms ;
		percent_iv_aa= (pn_aa_kcal / (pn_cho + pn_aa_kcal + pn_lipid + iv_kcal + prop_kcal)) * 100; * not necessarily needed;
		percent_iv_dextrose= (pn_cho / (pn_cho + pn_aa_kcal + pn_lipid + iv_kcal + prop_kcal)) * 100;
		percent_iv_lipid= ((pn_lipid+prop_kcal) / (pn_cho + pn_aa_kcal + pn_lipid + iv_kcal + prop_kcal)) * 100; * propofol is mostly lipid;

		* total given parenterally ;
		tot_parent_kcal = pn_cho + pn_aa_kcal + pn_lipid + iv_kcal + prop_kcal;
		percent_parenteral = (tot_parent_kcal/ daily_kcal_goal) * 100 ; * Emory pharmacists have instructed that this be given with goal, not actual kcal, as the denominator (July 2007) ; 
		
		* total given enterally;
		tot_ent_kcal = tube_kcal + oral_kcal;
		percent_enteral = (tot_ent_kcal / daily_kcal_goal) * 100; * Emory pharmacists have instructed that this be given with goal, not actual kcal, as the denominator (July 2007) ; 

		* total given;
		percent_overall = (tot_kcal / daily_kcal_goal) * 100;
		
		
		* total protein ;
		tot_ent_prot = tube_prot + oral_prot;
		percent_parenteral_prot = (pn_aa_g/daily_prot_goal) * 100;
		percent_enteral_prot = (tot_ent_prot/daily_prot_goal) * 100;
		percent_overall_prot = (tot_aa / daily_prot_goal) * 100;

		*for vars for printing;
		format percent_iv_aa 5.1;
		format percent_iv_dextrose 5.1;
		format percent_iv_lipid 5.1;
		format percent_enteral 5.1;
		format percent_parenteral 5.1;
		format percent_overall 5.1;
		format percent_enteral_prot 5.1;
		format percent_parenteral_prot 5.1;
		format percent_overall_prot 5.1;

		format center center.;
	run;

	proc sort data= percent_pn; by id day; run;
	proc sort data= glnd.status; by id; run;

	/* process the data, removing blank observations and putting in an extra row that indicates the status of the patient and their data */
	data percent_pn;
		merge percent_pn
			glnd.status (keep = id days_hosp_post_entry days_until_death deceased);
		by id;

			row = put(day, 11.); * row label;
		center = floor(id / 10000);

	
		* if we know the patient was released from the hospital or died but we do not have all of the f/u info;
		if (last.id) & (day < days_hosp_post_entry) then do;
			
			output;
			daily_kcal_goal =.;
			iv_kcal =.;
			prop_kcal =.;
			pn_aa_kcal =.;
			pn_cho  =.;
			pn_lipid  =.;
			percent_iv_aa  =.;
			percent_iv_dextrose =.;
			percent_iv_lipid  =.;
			tot_parent_kcal  =.;
			tot_ent_kcal  =.;
			tot_kcal  =.;
			percent_parenteral  =.;
			percent_enteral  =.;
			percent_overall =.;
 
			tot_ent_prot =.;
			percent_parenteral_prot = .;
			percent_enteral_prot = .;
			percent_overall_prot = .;
			pn_aa_g = .;
			daily_prot_goal = .;	
			tot_aa = .;
			tot_insulin=.;

			if day = 28 then row = "End of Data"; * they were still hopsitalized past day 28 but the daily nutrition data ends here ; 
			else row = "Data Incom."; 

			output;
		end;
		
		* still hospitalized;
		else if (last.id) & (days_hosp_post_entry = .) then do ;
			output;
			daily_kcal_goal =.;
			iv_kcal =.;
			prop_kcal =.;
			pn_aa_kcal =.;
			pn_cho  =.;
			pn_lipid  =.;
			percent_iv_aa  =.;
			percent_iv_dextrose =.;
			percent_iv_lipid  =.;
			tot_parent_kcal  =.;
			tot_ent_kcal  =.;
			tot_kcal  =.;
			percent_parenteral  =.;
			percent_enteral  =.;
			percent_overall =.; 

			tot_ent_prot =.;
			percent_parenteral_prot = .;
			percent_enteral_prot = .;
			percent_overall_prot = .;
			pn_aa_g = .;
			daily_prot_goal = .;
			tot_aa = .;
			tot_insulin=.;

			row = "Still hosp.";
			output;
		end;

		* produces most normal rows;
		else if (day < days_hosp_post_entry) | (days_hosp_post_entry = .) then do ;
			* output last day in hopsital;	
			output;
		end;

		else if (day > days_hosp_post_entry) then DELETE; * this is a blank record post-hospital discharge;
		
		else if (day = days_hosp_post_entry) then do; * if last record for a person and they have left the hospital for death or discharge;
			* output last day in hopsital;
			output;
			
			* create lastrow;
			if (deceased) & (days_until_death <= days_hosp_post_entry) then row = "Died";
			else row = "Discharged";
			
			daily_kcal_goal =.;
			iv_kcal =.;
			prop_kcal =.;
			pn_aa_kcal =.;
			pn_cho  =.;
			pn_lipid  =.;
			percent_iv_aa  =.;
			percent_iv_dextrose =.;
			percent_iv_lipid  =.;
			tot_parent_kcal  =.;
			tot_ent_kcal  =.;
			tot_kcal  =.;
			percent_parenteral  =.;
			percent_enteral  =.;
			percent_overall =.; 

			tot_ent_prot =.;
			percent_parenteral_prot = .;
			percent_enteral_prot = .;
			percent_overall_prot = .;
			pn_aa_g = .;
			daily_prot_goal = .;
			tot_aa = .;
			tot_insulin=.;

			output;



		label
			row= "Day"
			pn_aa_kcal="IV AA kcal"
        		tot_kcal="Tot kcal"
        		pn_lipid = "IV lipid kcal"
			pn_cho = "IV CHO kcal"
			
			percent_iv_aa= "% IV kcal AA"
			percent_iv_dextrose= "% IV kcal Dext"
			percent_iv_lipid = "% IV kcal Lipid"
		
			daily_kcal_goal = "Daily kcal goal"
			tot_parent_kcal = "Tot IV kcal "
			tot_ent_kcal = "Tot EN kcal "

			iv_kcal="IV fl. kcal"
       		prop_kcal="Prop. kcal"
			
			percent_parenteral = "% kcal goal admin. IV"
			percent_enteral = "% kcal goal admin. EN"
			percent_overall = "% kcal goal admin."

			percent_parenteral_prot = "% prot. goal admin. IV" 
			percent_enteral_prot = "% prot. goal admin. EN"
		 	percent_overall_prot = "% prot. goal admin."

			daily_prot_goal = "Daily AA /prot goal (g)"
			pn_aa_g = "IV AA (g)"
			tot_ent_prot = "EN AA /prot (g)"
			tot_aa = "Tot AA /Prot (g)"
			tot_insulin ="Tot Insulin admin. (units)"
		;
		end;
run;

* make a permanent copy of the above dataset ;
	data glnd_rep.indiv_pn_tables;
		set percent_pn;
	run;

/* Part 3 - total patients receiving median kcals enterally through each day ---- formerly part 2 */ 

	* this is being done for days 0-7,7-14,14-21,21-28, overall separately. i tried using a macro, but this is easier!;
			
		data temp_nut;
			set percent_pn; 
			by id;

			if last.id then delete; 	* remove the last row which is a descriptor that indicates the patient's study status  ;

				* first determine if they have any recorded EN;
				if (tube_kcal ~= .) and (oral_kcal ~= .) then has_en = 1; else has_en = 0;

				* now recode missing to zero not for accuracy but in order to avoid having a '.' for the total if one value is missing;
				if tube_kcal = . then tube_kcal = 0;
				if oral_kcal = . then oral_kcal = 0;
	
				* compute total enteral kcal;
				tot_ent_kcal = tube_kcal + oral_kcal;
	
				percent_enteral = (tot_ent_kcal / tot_kcal) * 100;
	
	
			
		run;

proc print data = temp_nut;
	var id day tube_kcal oral_kcal has_en;
run;

		
		* process the first week - get median EN per patient;
			proc means data= temp_nut n median;
				where (day < 8 ) ;
				class id;
				var percent_enteral;
				output 	out = en_0_7 
						median(percent_enteral) = median_en 		sum(has_en) = sum_has_en; * also get the total days with EN day for the week;
			run;
			data en_0_7;
				set en_0_7;
					day = 7;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;
			
				drop _type_ _freq_;			* drop extra vars;
			run;
		
		* process the second week - get medians;
			proc means data= temp_nut n median;
				where ((day > 7 ) & (day < 15)) & ((still_in_hosp & (date() - dt_random > 7)) | (days_study > 7) ); * get all data for first 15 days of people hospitalized more than a week;

				class id;
				var percent_enteral;
				output 	out = en_7_14 
						median(percent_enteral) = median_en 		sum(has_en) = sum_has_en; * also get the total days with EN day for the week;
			run;
			data en_7_14;
				set en_7_14;
					day = 14;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process the third week - get medians;
			proc means data= temp_nut n median;
				where ((day > 14 ) & (day < 22)) & ((still_in_hosp & (date() - dt_random > 14)) | (days_study > 14) ); * get all data for first 15 days of people hospitalized more than a week;
				class id;
				var percent_enteral;
				output 	out = en_14_21 
						median(percent_enteral) = median_en		sum(has_en) = sum_has_en; * also get the total days with EN day for the week;
			run;
			data en_14_21;
				set en_14_21;
					day = 21;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process the fourth week - get medians;
			proc means data= temp_nut n median;
				where ((day > 21 ) & (day < 29)) & ((still_in_hosp & (date() - dt_random > 21)) | (days_study > 21) );  * get all data for first 15 days of people hospitalized more than a week;
				class id;
				var percent_enteral;
				output 	out = en_21_28 
						median(percent_enteral) = median_en		sum(has_en) = sum_has_en; * also get the total days with EN day for the week;
			run;
			data en_21_28;
				set en_21_28;
					day = 28;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process all time overall - get medians;
			proc means data= temp_nut n median;
				class id;
				var percent_enteral;
				output 	out = en_overall 
						median(percent_enteral) = median_en		sum(has_en) = sum_has_en; * also get the total days with EN day for the week;
			run;
			data en_overall;
				set en_overall;
					day = 99;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;
		
		data en_combined;
			set 	en_0_7
				en_7_14
				en_14_21
				en_21_28
				en_overall
			;
		run;

ods pdf file = "/glnd/sas/reporting/en.pdf" style = journal;
		proc print data= en_combined;
		run;
ods pdf close;

		* now convert each person's median EN intake for each week into a category;
		data en_combined;
			set en_combined;

				if (median_en >= 0) & (median_en < 25) then recv_0_25 = 1; else recv_0_25 = 0;		
				if (median_en >= 25) & (median_en < 50) then recv_25_50 = 1; else recv_25_50 = 0;
				if (median_en >= 50) & (median_en < 75) then recv_50_75 = 1; else recv_50_75 = 0;
				if (median_en >= 75) then recv_75_100 = 1; else recv_75_100 = 0;

				if sum_has_en > 0 then had_en = 1; else had_en = 0; 	* did each patient have EN over a given week? ;
		run;	

		* now sum, by week (labeled 'day'), the total people in each category;
		proc sort data= en_combined; by day; run;
		
		proc means data= en_combined n sum mean ;
			by day;
			var recv_0_25 recv_25_50 recv_50_75 recv_75_100;

			* collect results for table;
			output 	out = tot_recv
					n(recv_25_50) =  patients
					sum(recv_0_25 recv_25_50 recv_50_75 recv_75_100 had_en) = recv_0_25_s recv_25_50_s recv_50_75_s recv_75_100_s had_en_s
				;
		run;




	* calculate percentages for final table;
	data glnd_rep.percent_enteral;
		set tot_recv;
	
		recv_0_25_percent= (recv_0_25_s / had_en_s) * 100;
		recv_25_50_percent= (recv_25_50_s / had_en_s) * 100;
		recv_50_75_percent= (recv_50_75_s / had_en_s) * 100;
		recv_75_100_percent= (recv_75_100_s / had_en_s) * 100;

		* format vars;
		format recv_0_25_percent 4.1;
		format recv_25_50_percent 4.1;
		format recv_50_75_percent 4.1;
		format recv_75_100_percent 4.1;

		
		* set up columns for display ;
		col_0_25= put(recv_0_25_s, 3.) || " (" || left(put(recv_0_25_percent, 4.1)) || "%)"  ;
		col_25_50= put(recv_25_50_s, 3.) || " (" || left(put(recv_25_50_percent, 4.1)) || "%)"  ;
		col_50_75= put(recv_50_75_s, 3.) || " (" || left(put(recv_50_75_percent, 4.1)) || "%)"  ;
		col_75_100= put(recv_75_100_s, 3.) || " (" || left(put(recv_75_100_percent, 4.1)) || "%)"  ;


		* create labels ;
		label 	day = '00'x  /* blank */
				patients = "Patients with nutrition data" 
				had_en_s = "Patients with any enteral nutrition data"
				col_0_25 = "Receiving 0 - 25% kcals enterally"
				col_25_50 = "Receiving 25 - 50% kcals enterally"
				col_50_75 = "Receiving 50 - 75% kcals enterally"
				col_75_100 = "Receiving 75 - 100% kcals enterally"
		;
	
		drop _type_ _freq_;
	run;

	* set format for day;
	proc format library = library;
		value day_nut 
			7 = "through day 7"
			14 = "through day 14"
			21 = "through day 21"
			28 = "through day 28"
			99 = "overall"
		;
	run;
		





/**	Part 4 - summary of % PN kcal given as lipid AND DEXTROSE **/

* this is being done for days 0-7,7-14,14-21,21-28, overall separately.;
		
		data percent_lipid;
			set percent_pn;
			by id;

			if last.id then delete; 	* remove the last row which is a descriptor that indicates the patient's study status  ;

		run;
	
		* process the first week - get median EN per patient;
			proc means data= percent_lipid n median;
				where (day < 8 ) ;
				class id;
				var percent_iv_lipid;
				output 	out = lipid_0_7 
						median(percent_iv_lipid percent_iv_dextrose) = median_lipid median_dextrose	 sum(pn_aa_kcal) = sum_pn_aa_kcal; * PN AA kcal is a good surrogate indicator of whether a person was on PN ;
			run;

			data lipid_0_7;
				set lipid_0_7;
					day = 7;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;
			
				drop _type_ _freq_;			* drop extra vars;
			run;
		
		* process the second week - get medians;
			proc means data= percent_lipid n median;
				where ((day > 7 ) & (day < 15)) & ((still_in_hosp & (date() - dt_random > 7)) | (days_study > 7) ); * get all data for first 15 days of people hospitalized more than a week;

				class id;
				var percent_iv_lipid;
				output 	out = lipid_7_14 
						median(percent_iv_lipid percent_iv_dextrose) = median_lipid median_dextrose	sum(pn_aa_kcal) = sum_pn_aa_kcal; * PN AA kcal is a good surrogate indicator of whether a person was on PN ;
			run;

			data lipid_7_14;
				set lipid_7_14;
					day = 14;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process the third week - get medians;
			proc means data= percent_lipid n median;
				where ((day > 14 ) & (day < 22)) & ((still_in_hosp & (date() - dt_random > 14)) | (days_study > 14) ); * get all data for first 15 days of people hospitalized more than a week;
				class id;
				var percent_iv_lipid;
				output 	out = lipid_14_21 
						median(percent_iv_lipid percent_iv_dextrose) = median_lipid median_dextrose	sum(pn_aa_kcal) = sum_pn_aa_kcal; * PN AA kcal is a good surrogate indicator of whether a person was on PN ;;
			run;

			data lipid_14_21;
				set lipid_14_21;
					day = 21;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process the fourth week - get medians;
			proc means data= percent_lipid n median;
				where ((day > 21 ) & (day < 29)) & ((still_in_hosp & (date() - dt_random > 21)) | (days_study > 21) );  * get all data for first 15 days of people hospitalized more than a week;
				class id;
				var percent_iv_lipid;
				output 	out = lipid_21_28 
						median(percent_iv_lipid percent_iv_dextrose) = median_lipid median_dextrose	 sum(pn_aa_kcal) = sum_pn_aa_kcal; * PN AA kcal is a good surrogate indicator of whether a person was on PN ;
			run;

			data lipid_21_28;
				set lipid_21_28;
					day = 28;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;

		* process all time overall - get medians;
			proc means data= percent_lipid n median;
				class id;
				var percent_iv_lipid;
				output 	out = lipid_overall 
						median(percent_iv_lipid percent_iv_dextrose) = median_lipid median_dextrose	 sum(pn_aa_kcal) = sum_pn_aa_kcal; * PN AA kcal is a good surrogate indicator of whether a person was on PN ;
			run;

			data lipid_overall;
				set lipid_overall;
					day = 99;					* add day stamp for later processing;
					if id = . then delete;		* get rid of cumulative info;

				drop _type_ _freq_;			* drop extra vars;
			run;
		

		data lipid_combined;
			set 	lipid_0_7
				lipid_7_14
				lipid_14_21
				lipid_21_28
				lipid_overall
			;
		run;

		proc print data= lipid_combined;
		

		* make LIPID table ;
		* now convert each person's median lipid intake for each week into a category;
		data lipid_combined;
			set lipid_combined;

				if (median_lipid = 0) then recv_0 = 1; else recv_0 = 0;
				if (median_lipid > 0) & (median_lipid <=15 ) then recv_0_15 = 1; else recv_0_15 = 0;		
				if (median_lipid > 15) & (median_lipid <=30 ) then recv_15_30 = 1; else recv_15_30 = 0;		
				if (median_lipid > 30) then recv_30_100 = 1; else recv_30_100 = 0;

				if (sum_pn_aa_kcal > 0) then had_pn = 1; else if (sum_pn_aa_kcal ~= .) then had_pn = 0; 	* did each patient have PN over a given week? ;
		run;	

		* now sum, by week (labeled 'day'), the total people in each category;
		proc sort data= lipid_combined; by day; run;
	
		proc means data= lipid_combined n sum mean ;
			by day;
			var recv_0 recv_0_15 recv_15_30 recv_30_100;

			where had_pn ; * do this only for those who had PN ;

			* collect results for table;
			output 	out = tot_recv_lipid
					n(recv_15_30) =  patients
					sum(recv_0 recv_0_15 recv_15_30 recv_30_100 had_pn) = recv_0_s recv_0_15_s recv_15_30_s recv_30_100_s had_pn_s
				;
		run;

		* get total N for each week ;
		proc means data= lipid_combined n sum mean ;
			by day;
			output 	out = tot_recv_lipid_n
					n(recv_15_30) =  patients;
		run;
		
		* merge back in total n...;
		data tot_recv_lipid;
			merge 	tot_recv_lipid
					tot_recv_lipid_n (keep = day patients);
			by day;
		run;


	* calculate percentages for final table;
	data glnd_rep.percent_iv_lipid;
		set tot_recv_lipid;
	
		recv_0_percent= (recv_0_s / had_pn_s) * 100;
		recv_0_15_percent= (recv_0_15_s / had_pn_s) * 100;
		recv_15_30_percent= (recv_15_30_s / had_pn_s) * 100;
		recv_30_100_percent= (recv_30_100_s / had_pn_s) * 100;

		* format vars;
		format recv_0_percent 4.1;
		format recv_0_15_percent 4.1;
		format recv_15_30_percent 4.1;
		format recv_30_100_percent 4.1;

		
		* set up columns for display ;
		col_0 = put(recv_0_s, 3.) || " (" || left(put(recv_0_percent, 4.1)) || "%)"  ;
		col_0_15= put(recv_0_15_s, 3.) || " (" || left(put(recv_0_15_percent, 4.1)) || "%)"  ;
		col_15_30= put(recv_15_30_s, 3.) || " (" || left(put(recv_15_30_percent, 4.1)) || "%)"  ;
		col_30_100= put(recv_30_100_s, 3.) || " (" || left(put(recv_30_100_percent, 4.1)) || "%)"  ;
format day day_nut.;

		* create labels ;
		label 	day = 'Period' /*'00'x  /* blank */
				patients = "Total Patients"
				had_pn_s = "Patients receiving any TPN" 
				col_0 = "Receiving 0% of IV kcals via lipid"
				col_0_15 = "Receiving 1 - 15% of IV kcals via lipid"
				col_15_30 = "Receiving 15 - 30% of IV kcals via lipid"
				col_30_100 = "Receiving 30 - 100% of IV kcals via lipid"
		;
			keep day patients had_pn_s col_0 col_0_15 col_15_30 col_30_100;	
*		drop _type_ _freq_;
	run;




* make DEXTROSE TABLE ;

				
		* now convert each person's median dextrose intake for each week into a category;
		data dextrose_combined;
			set lipid_combined;
				if (median_dextrose = 0) then recv_0 = 1; else recv_0 = 0;
				if (median_dextrose > 0) & (median_dextrose <= 30) then recv_0_30 = 1; else recv_0_30 = 0;
				if (median_dextrose > 30) & (median_dextrose <= 60) then recv_30_60 = 1; else recv_30_60 = 0;		
				if (median_dextrose > 60) then recv_60_100 = 1; else recv_60_100 = 0;
		run;	

		* now sum, by week (labeled 'day'), the total people in each category;
		proc sort data= dextrose_combined; by day; run;
		
		proc means data= dextrose_combined n sum mean ;
			by day;
			var recv_0 recv_0_30 recv_30_60 recv_60_100;

			where had_pn ; * do this only for those who had PN ;


			* collect results for table;
			output 	out = tot_recv_dextrose
					sum(recv_0 recv_0_30 recv_30_60 recv_60_100 had_pn) = recv_0_s recv_0_30_s recv_30_60_s recv_60_100_s had_pn_s
				;
		run;

		* merge back in total n...;
		data tot_recv_dextrose;
			merge 	tot_recv_dextrose
					tot_recv_lipid_n (keep = day patients); * the n is the same as in this dataset ;
			by day;
		run;

	* calculate percentages for final table;
	data glnd_rep.percent_iv_dextrose;
		set tot_recv_dextrose;
	
		recv_0_percent= (recv_0_s / had_pn_s) * 100;
		recv_0_30_percent= (recv_0_30_s / had_pn_s) * 100;
		recv_30_60_percent= (recv_30_60_s / had_pn_s) * 100;
		recv_60_100_percent= (recv_60_100_s / had_pn_s) * 100;

		* format vars;
		format recv_0_percent 4.1;
		format recv_0_30_percent 4.1;
		format recv_30_60_percent 4.1;
		format recv_60_100_percent 4.1;
                    format day day_nut.;
		
		* set up columns for display ;
		col_0= put(recv_0_s, 3.) || " (" || left(put(recv_0_percent, 4.1)) || "%)"  ;
		col_0_30= put(recv_0_30_s, 3.) || " (" || left(put(recv_0_30_percent, 4.1)) || "%)"  ;
		col_30_60= put(recv_30_60_s, 3.) || " (" || left(put(recv_30_60_percent, 4.1)) || "%)"  ;
		col_60_100= put(recv_60_100_s, 3.) || " (" || left(put(recv_60_100_percent, 4.1)) || "%)"  ;


		* create labels ;
			label 	day = 'Period' /*' 00'x  /* blank */
				patients = "Total Patients"
				had_pn_s = "Patients receiving any TPN" 
				col_0 = "Receiving 0% of IV kcals via dextrose"
				col_0_30 = "Receiving 0 - 30% of IV kcals via dextrose"
				col_30_60 = "Receiving 30 - 60% of IV kcals via dextrose"
				col_60_100 = "Receiving 60 - 100% of IV kcals via dextrose"
		;
		keep day patients had_pn_s col_0 col_0_30 col_30_60 col_60_100;
		*drop _type_ _freq_;
	run;





proc options group=listcontrol;run;
	options ls=100 nodate 	orientation = landscape center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*";
	ods pdf file = '/glnd/sas/reporting/nutrition_summaries_open.pdf' style = journal startpage=no /* contents */;
	ods escapechar='^' ;
		title1; 

		* Table 1a;
		data _null_; file print; put / / / /  @25 "Summary of Parenteral and Enteral Nutrition at Baseline" ;	run;
		*title1 "Summary of Parenteral and Enteral Nutrition at Baseline";
		proc print data= glnd_rep.en_pn_prior label noobs; 
		run;

		* Table 1b ;
		data _null_; file print; put / / / /  @25 "Summary of Time to Enteral Nutrition (n = &n_enteral)" ;	run;
		*title1 "Summary of Time to Enteral Nutrition (n = &n_enteral)";
		proc print data= glnd_rep.days_to_en noobs label split= '*'; 
			*var row  first_en_day_n first_en_day_med first_en_day_min first_en_day_max not_yet_en_n never_en_hospital_n; 
			var row n first_en_day_med first_en_day_min first_en_day_max ; 
		run;

		* Table 2;
		ods pdf startpage=yes; * create new pages for new procedures (next proc print);
		*options number pageno=min; * start numbering these tables and from page 1;

		options orientation = landscape;
		proc sort  data = percent_pn; by center id; run;

		* for now just print individual listings. may eventually make line plots or summary tables as originally planned ;	
		proc print data= percent_pn noobs label ;
			by center id;
			pageby center;
			
			title1 h=3 'Daily Nutritional kcal Summaries';
			*title2 h=3 '#byval1';

			label center = '00'x 'site' ;
			label id = '00'x 'id';

			var row /style(data) = [just=center];
			var daily_kcal_goal daily_prot_goal iv_kcal prop_kcal pn_aa_kcal pn_cho pn_lipid percent_iv_aa percent_iv_dextrose
				 percent_iv_lipid tot_parent_kcal tot_ent_kcal tot_kcal tot_insulin percent_parenteral percent_enteral percent_overall  

				pn_aa_g tot_ent_prot tot_aa	 percent_parenteral_prot percent_enteral_prot 	percent_overall_prot;

		;
	

		* Table 3;
		data _null_; file print; put / / / /  @25 "Median proportion of Nutrition Received Enterally, Over Time" ;	run;


		*title1 "Proportion of Nutrition Received Enterally, Over Time";
		proc print data= glnd_rep.percent_enteral label noobs;
			var day patients had_en_s col_0_25 col_25_50 col_50_75 col_75_100;
			format day day_nut.;
		run;		
		data _null_; file print; put / / / /  @25 "note: information on enteral nutrition is often unavailable" ;	run;


		* Table 4;
		data _null_; file print; put / / / /  @25 "Median proportion of IV kcal composed of lipid, Over Time" ;	run;
		ods pdf startpage = no;
		proc print data= glnd_rep.percent_iv_lipid label noobs;
			var day patients had_pn_s col_0 col_0_15 col_15_30 col_30_100;
			format day day_nut.;
		run;		
		data _null_; file print; put / / / /  @25 "note: patients with daily information not yet submitted appear as not having IV kcal on those days" ;	run;

	

		data _null_; file print; put / / / /  @25 "Median proportion of IV kcal composed of dextrose, Over Time" ;	run;
		ods pdf startpage = no;
		proc print data= glnd_rep.percent_iv_dextrose label noobs;
			var day patients had_pn_s col_0 col_0_30 col_30_60 col_60_100;
			format day day_nut.;
		run;	

		run;
	ods pdf close;

quit;
data glnd_rep.en_pn_prior1;
 set glnd_rep.en_pn_prior;
  label row="Summary";
  
  
data glnd_rep.days_to_en1;
 set glnd_rep.days_to_en;
  label row="Days";
  
  
data glnd_rep.percent_enteral1;
 set glnd_rep.percent_enteral;
  label day="Days";
  format day day_nut.;
  options orientation=landscape;
  
   options mprint symbolgen;
  
  %macro x(id);
  ods pdf file = "/glnd/sas/reporting/nut&id..pdf" style = journal startpage=no /* contents */;
  
  
		proc print data= percent_pn noobs label ;
			by center id;
			pageby center;
                   where id=&id;			
			title1 h=3 'Daily Nutritional kcal Summaries';
			*title2 h=3 '#byval1';

			label center = '00'x 'site' ;
			label id = '00'x 'id';

			var row /style(data) = [just=center];
			var daily_kcal_goal daily_prot_goal iv_kcal prop_kcal pn_aa_kcal pn_cho pn_lipid percent_iv_aa percent_iv_dextrose
				 percent_iv_lipid tot_parent_kcal tot_ent_kcal tot_kcal tot_insulin percent_parenteral percent_enteral percent_overall  

				pn_aa_g tot_ent_prot tot_aa	 percent_parenteral_prot percent_enteral_prot percent_overall_prot;

	
		run;
		ods pdf close;
   %mend;

proc contents data=percent_pn;run;

* INDIVIDUAL LISTINGS for 7/2008 DSMB REPORT: ;

   %x(11348);
   %x(11369);
   %x(12358);
   %x(12370);
   %x(12383);

   %x(31292);
   %x(32294);
   %x(32305);
   %x(32318);
   
   %x(41141);
   %x(41143);
   %x(41144);
   %x(41145);
   %x(41156);
   %x(41157);
   %x(42160);

   %x(51052);
   %x(52029);
   %x(52049);


 %x(11076);
 %x(32262);
 %x(32270);
 %x(41068);
 %x(42115);
 %x(42119);
