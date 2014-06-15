* nosocomial_rates_closed.sas ;


*** PLUG IN CODE *** : execute nosocomial_adjudicated_open to refresh nosocomial infection datasets ;



%macro closed;

%do x = 1 %to 2;


	* ASSIGN THE TREATMENT TO THE VARIABLE 'GROUP', ACCORDING TO THE FORMAT;
		data _null_;
			num = input("&x", 1.);
			call symput('group', put(num, trt.));
		run;

	* capture sample size of total people on study, that are no longer in the hospital because we need to know hospital ; 
		proc means data= glnd.status noprint;
			where (still_in_hosp = 0) & (treatment = &x); 
			output out= study_n n(id) = id_n;
		run;
		data _null_;
			set study_n;
	
			call symput('n_study_1', put(id_n, 3.0));
		run;

	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.george; by id; run;


** Sort pre and post-adjudication datasets, create a hybrid infection dataset that contains the adjudicated records for those adjudicated
	and the non-adjudicated records for those IDs not yet adjudicated ;

	proc sort data =  glnd_rep.suspected_noso_before_adj; by id site_code type_code dt_infect ; run;
	proc sort data =  glnd_rep.suspected_noso_after_adj; by id site_code type_code dt_infect ; run;

	data non_adj_folks;
		merge 	glnd_rep.suspected_noso_before_adj
				glnd_rep.suspected_noso_after_adj (in = adjudicated keep = id)
		;

		by id;	
		
		if adjudicated then delete;

	run;

	* this is the patient infections, with the adjudicated infection data for those people adjudicated ;
	data all_infections_with_adj;
		set
			non_adj_folks
			glnd_rep.suspected_noso_after_adj
			;
	run;
	

	proc sort data = all_infections_with_adj; by id; run;

	data all_infections_for_calc;
		length new_site_code $ 4;
		
		merge 	
			all_infections_with_adj (in = has_infect)
			glnd.status (keep = id days_hosp_post_entry still_in_hosp) 
			glnd.george (keep = id treatment)
			;
		by id;

		if (treatment ~= &x) then delete;
		
		if ~has_infect then delete;


		* remove patients still thought to actively be in the hospital - they cannot contribute to "hospital days" denominator ;
		if still_in_hosp then delete;
	
		* create a new classification variable for infections, to be used in our table;
		new_site_code = site_code;

		if site_code = "PNEU" then new_site_code = "LRI";
		
	run;



** calculate total number of infections ;

	*** for certain individual infection types;
		title "Incident infection totals - treatment &x";
		proc means data = all_infections_for_calc 	n sum;
			where 	(compress(new_site_code) in ("BSI", "LRI", "GI", "CVS", "SSI") ) |
				 	((compress(new_site_code) = "UTI") & (compress(type_code) = "SUTI")   );
	
			class new_site_code;
	
			var incident;
			output out = indiv_infect sum(incident) = incident_cases_sum;
		run;


		* now get the total number of individuals and merge back in;
			proc sort data = all_infections_for_calc; by incident new_site_code id; run;

			data indiv_infect_id;
				set all_infections_for_calc;
	
				where 	(compress(new_site_code) in ("BSI", "LRI", "GI", "CVS", "SSI") ) |
				 	((compress(new_site_code) = "UTI") & (compress(type_code) = "SUTI")   );

				by incident new_site_code id;

				if ~(incident = 1) then delete;
				if ~first.id then delete;
			run;

			proc means data = indiv_infect_id n sum;
				class new_site_code;
		
				var incident; * this now counts incident PEOPLE, not infections ;
				output out = indiv_infect_people sum(incident) = incident_people_sum;
			run;				
	
			data indiv_infect;
				merge 
					indiv_infect
					indiv_infect_people;

					by _TYPE_ new_site_code;
			run;

		* remove overall sum;
		data indiv_infect;
			set indiv_infect;
			where _type_ = 1;
		run;

		proc print data = indiv_infect;
		run;
	

	*** for non-BSIs that are not asymptomatic UTI;
		proc means data = all_infections_for_calc 	n sum;
			where 	(compress(new_site_code) ~= "BSI") & ~((compress(new_site_code) = "UTI") & (compress(type_code) = "ASB")  );
	
			var incident;
			output out = non_bsi_infect sum(incident) = incident_cases_sum;
		run;

		* now get the total number of individuals and merge back in;
			proc sort data = all_infections_for_calc; by incident id; run;

			data non_bsi_infect_id;
				set all_infections_for_calc;
	
				where (incident = 1) &	(compress(new_site_code) ~= "BSI") & ~((compress(new_site_code) = "UTI") & (compress(type_code) = "ASB")  );
				by incident id;

				if ~first.id then delete;
			run;

			proc means data = non_bsi_infect_id n sum;
						
				var incident; * this now counts incident PEOPLE, not infections ;
				output out = non_bsi_infect_people sum(incident) = incident_people_sum;
			run;				
	
			data non_bsi_infect;
				merge 
					non_bsi_infect
					non_bsi_infect_people;
			run;

		proc print data = non_bsi_infect;
		run;
	


	*** for all infections that are not asymptomatic UTI;
		proc means data = all_infections_for_calc 	n sum;
			where ~((compress(new_site_code) = "UTI") & (compress(type_code) = "ASB")  );
	
			var incident ;
			output out = total_infect sum(incident) = incident_cases_sum;
		run;

		* now get the total number of individuals and merge back in;
			proc sort data = all_infections_for_calc; by incident id; run;

			data total_infect_id;
				set all_infections_for_calc;
	
				where (incident = 1) & ~((compress(new_site_code) = "UTI") & (compress(type_code) = "ASB")  );
				by incident id;

				if ~first.id then delete;
			run;

			proc means data = total_infect_id n sum;
						
				var incident; * this now counts incident PEOPLE, not infections ;
				output out = total_infect_people sum(incident) = incident_people_sum;
			run;				
	
			data total_infect;
				merge 
					total_infect
					total_infect_people;
			run;

		proc print data = total_infect;
		run;


	* calculate total patient days in hospital for the study ;
		proc means data = glnd.status 	n sum median;
			where (still_in_hosp = 0) & (treatment = &x);
	 
			var days_hosp_post_entry;
			output out = total_hosp_days  sum(days_hosp_post_entry) = total_hosp_days ;
		run;

		data _null_;
			set total_hosp_days;
	
			call symput('total_hosp_days', put(total_hosp_days, 12.));
			

		run;

	data header_1;
		row = "== Specific Infections ==";
	run;

	data header_2;
		row = "===================";
	run;

** combine these totals and calculate Poisson 95% CI ;

	** stack!;
		data rate_table_&x;
			length row $ 46 ;
	
			set 
				header_1			(in = from_header_1)
				indiv_infect		(in = from_indiv_infect)
				header_2			(in = from_header_2)
				non_bsi_infect 	(in = from_non_bsi)
				total_infect		(in = from_total)
			;
	
			if from_indiv_infect then row = put(new_site_code, site_code.);
			if from_non_bsi then row = "Any non-BSI infection";
			if from_total then row = "Any infection";

			if new_site_code = "LRI" then row = "Pneumonia or Lower Respiratory Tract Infection";

			if (~from_header_1) & (~from_header_2) then do;	
				** compute rates and CIs ;	
				rate_1000d = (incident_cases_sum / &total_hosp_days) * 1000;
				denominator = input(&total_hosp_days, 12.);
	
				conf_level = .95;
				
				upper_p = 1 - (1 - conf_level)/2;
				lower_p = 1 - upper_p;  
	
				* upper and lower CI bounds for the Poisson counts of incident infections ;
				upper_mu = .5 * cinv(upper_p, 2 * (incident_cases_sum + 1));
				lower_mu = .5 * cinv(lower_p, 2 * (incident_cases_sum));
	

				* transform these into CI for the RATES;
				upper_rate = (upper_mu/denominator) * 1000;
				lower_rate = (lower_mu/denominator) * 1000;
	
	
				* make columns for display ;
				display_count_people_&group = compress(put(incident_cases_sum, 4.0)) || " (" || compress(put(incident_people_sum, 4.0)) || "/" || compress(&n_study_1) || ")";
				display_rate_&group = compress(put(rate_1000d, 5.1)) ;
				display_ci_&group = "[" || compress(put(lower_rate, 5.1)) || ", " || compress(put(upper_rate, 5.1)) || "]";
			end;
				
			order = _N_;			* for merging both treatment groups ;
			
			label
				row = "."
				display_count_people_&group = "&group+# infec. (# pat.)+ "
				display_rate_&group = "&group+infec. /+ 1000 hosp.+days"
				display_ci_&group = "&group+95% CI *" 				
			;
		run;

		* make a copy of this treatment groups data so that i can access it after the macro terminates;
			data all_infections_for_calc_&x ;
				set all_infections_for_calc;
			run;

%end;

%mend closed;
%closed run;


	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.george; by id; run;

** GET N's for titles - needs to happen outside of macro since the variables' scopes are otherwise within the macros ** ;

	* capture sample size of total people on study, that are no longer in the hospital because we need to know hospital ; 
		data n;
			merge	glnd.status (keep = id still_in_hosp)
				glnd.george (keep = id treatment)
			;
			by id;
		run;
		
		proc means data= n noprint;
			where (still_in_hosp = 0) & (treatment = 1); 
			output out= study_n n(id) = id_n;
		run;
		data _null_;
			set study_n;
			call symput('n_study_A', put(id_n, 3.0));
		run;

		proc means data= n noprint;
			where (still_in_hosp = 0) & (treatment = 2); 
			output out= study_n n(id) = id_n;
		run;
		data _null_;
			set study_n;
			call symput('n_study_B', put(id_n, 3.0));
		run;


	* calculate total patient days in hospital for the study ;
		proc means data = glnd.status 	n sum median;
			where (still_in_hosp = 0) & (treatment = 1);
	 
			var days_hosp_post_entry;
			output out = total_hosp_days  sum(days_hosp_post_entry) = total_hosp_days ;
		run;

		data _null_;
			set total_hosp_days;
			call symput('total_hosp_days_A', compress(put(total_hosp_days, 12.)));
		run;

		proc means data = glnd.status 	n sum median;
			where (still_in_hosp = 0) & (treatment = 2);
	 
			var days_hosp_post_entry;
			output out = total_hosp_days  sum(days_hosp_post_entry) = total_hosp_days ;
		run;

		data _null_;
			set total_hosp_days;
			call symput('total_hosp_days_B', compress(put(total_hosp_days, 12.)));
		run;	

		** capture asymptomatic or unknown UTI infection counts for note  **;
			proc means data = all_infections_for_calc_1 	n sum noprint;
				where (compress(new_site_code) = "UTI") & (compress(type_code) ~= "SUTI")   ;
		
				var incident;
				output out = non_SUTI sum(incident) = incident_non_SUTI_sum;
			run;

			data _NULL_;
				set non_SUTI;
				 call symput('non_SUTI_A', compress(put(incident_non_SUTI_sum, 4.0)));
			run;

			proc means data = all_infections_for_calc_2 	n sum noprint;
				where (compress(new_site_code) = "UTI") & (compress(type_code) ~= "SUTI")   ;
		
				var incident;
				output out = non_SUTI sum(incident) = incident_non_SUTI_sum;
			run;

			data _NULL_;
				set non_SUTI;
				 call symput('non_SUTI_B', compress(put(incident_non_SUTI_sum, 4.0)));
			run;


** end ** ;









	proc sort data = rate_table_1; by row; run;
	proc sort data = rate_table_2; by row; run;

	* MERGE BOTH TERATMENTS ;
	data rate_table_closed ;
		merge 	rate_table_1
			rate_table_2 (drop = order);
		by row;
	run;

	proc sort data = rate_table_closed; by order; run;

		* need to put titles in here so can access local macro variables ;
		title1 "Incident infection rates: Trt. A = &n_study_A patients, Trt. B = &n_study_B patients";
		title2 "(Patient hospital days observed: Trt. A = &total_hosp_days_A days, Trt. B = &total_hosp_days_B days)";
			* using global macro variables doesn't work. just move the code out here ;

	options nodate nonumber;
	*ods pdf file = "/glnd/sas/reporting/nosocomial_rates_closed.pdf" style = journal;
	ods pdf file = "nosocomial_rates_closed.pdf" style = journal;		
	
		proc print data = rate_table_closed noobs label split = '+' style(table)= [font_width = compressed];

			var row;

			var 	display_count_people_A display_rate_A display_ci_A
				display_count_people_B display_rate_B display_ci_B /style(data) = [just=center];;

		run;


		ods escapechar='^' ;
		ods pdf text = " ";
		ods pdf text = "^S={font_size=11pt font_style= slant just=left}Note: Asymptomatic UTI (group A n = &non_SUTI_A, group B n = &non_SUTI_B) are excluded from all results";
		ods pdf text = " ";

		ods pdf text = "^S={font_size=11pt font_style= slant just=left}* 95% confidence intervals are calculated using an exact method based on the Poisson distribution.";


	ods pdf close;
