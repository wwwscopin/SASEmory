/* nosocomial_closed.sas 
 * 
 * Unlike the two OPEN nosocomial programs (by_organism_center, _adjudicated_open), this program does both the organism
 * and episode tables in one program, simp
ly inheriting the revised "adjudicated" dataset from "nosocomial_adjudicated_open.sas"
 */

	* capture sample size of total people in each trt group; 
		proc means data= glnd.george;
			where (treatment = 1);
			output out= n_A n(id) = id_n;
		run;
		
		proc means data= glnd.george;
			where (treatment = 2);
			output out= n_B n(id) = id_n;
		run;
				
		data _null_;
			set n_A;
	
			call symput('n_A', compress(put(id_n, 3.0)));
		run;


			set n_B;
	
			call symput('n_B', compress(put(id_n, 3.0)));
		run;



%let group = "A";

%macro closed;

%do x = 1 %to 2;

proc sort data= glnd.george; by id; run;


* ASSIGN THE TREATMENT TO THE VARIABLE GROUP, ACCORDING TO THE FORMAT;
data _null_;
	num = input("&x", 1.);
	call symput('group', put(num, trt.));
run;

proc sort data = glnd_rep.all_infections_with_adj; by id; run;


 * 1st Table - # infections(patients) by organism type "Table 13" in 2/9/2007 MOO ;

	
	data noso;
		merge 		glnd_rep.all_infections_with_adj     /* this is the key 7/30/2009 update! we are inheriting the adjudicated dataset! */
				glnd.george (keep = id treatment)
			;
	
		by id;


/* This only work for before the cult_org_code_1 correction was made */
/*********************************************************************/
if org_spec_1="Cytomegalovirus" then cult_org_code_1=23;



			* nosocomial_adjudicated_open.sas prepares the data for an episode table, but not an organism one
			  the code below is used by both open and closed programs to prepare for an organism table;
		

			* Set up text field to contain organism format. need to have text rather than numeric so can adjust the "other people";
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);

			** ADDED 7/30/2008 **;
			if org_spec_1 = "" then org_spec_1 = "(not specified)";
			if org_spec_2 = "" then org_spec_2 = "(not specified)";
			if org_spec_3 = "" then org_spec_3 = "(not specified)";
			if org_spec_4 = "" then org_spec_4 = "(not specified)";
			if org_spec_5 = "" then org_spec_5 = "(not specified)";

			* Adjust "other" categories to include the name of the organism;
			if (cult_org_code_1 in (9, 20, 21,22,23)) then organism_1= trim(put(organism_1, $30.)) || " - " || trim(put(org_spec_1, $35.)) ;
			if (cult_org_code_2 in (9, 20, 21,22,23)) then organism_2= trim(put(organism_2, $30.)) || " - " || trim(put(org_spec_2, $35.)) ;
			if (cult_org_code_3 in (9, 20, 21,22,23)) then organism_3= trim(put(organism_3, $30.)) || " - " || trim(put(org_spec_3, $35.)) ;
			if (cult_org_code_4 in (9, 20, 21,22,23)) then organism_4= trim(put(organism_4, $30.)) || " - " || trim(put(org_spec_4, $35.)) ;
			if (cult_org_code_5 in (9, 20, 21,22,23)) then organism_5= trim(put(organism_5, $30.)) || " - " || trim(put(org_spec_5, $35.)) ;


			* remove repeat organisms from the same infection report, comparing the text labels, working backwards from the 5th organism ;
			if (organism_5 = organism_4) then do; organism_5 = .; cult_org_code_5 = .; org_spec_5 = .; end;
			if (organism_4 = organism_3) then do; organism_4 = .; cult_org_code_4 = .; org_spec_4 = .; end;
			if (organism_3 = organism_2) then do; organism_3 = .; cult_org_code_3 = .; org_spec_3 = .; end;
			if (organism_2 = organism_1) then do; organism_2 = .; cult_org_code_2 = .; org_spec_2 = .; end;
 
			
		
		label
			incident = "Incident"
			days_post_entry = "Days post study entry"
			cult_positive="Culture positive?"
			cult_obtain="Culture obtained?"
	        	site_code="Site code"
	        	type_code="Type code"
			infect_confirm="Infection confirmed?"
			center = "Center"

			organism_1 ="1st cult. org."
			organism_2 ="2nd cult. org."
			organism_3 ="3rd cult. org."
			organism_4 ="4th cult. org."
			organism_5 ="5th cult. org."
			;
	run;


	* SUBSET DATA BY TRT;		
	data noso;
		set noso;
		where (treatment = &x);

		drop treatment;
	run;



	* capture sample size of number of suspected infections;
		proc means data= noso;
			output out= noso_n n(id) = id_n;
		run;
		data _null_;
			set noso_n;
	
			call symput('n_susp_infec', put(id_n, 3.0));
		run;

	* capture sample size of total people on study; 
		proc means data= glnd.george;
			where (treatment = &x);
			output out= study_n n(id) = id_n;
		run;
		data _null_;
			set study_n;
	
			call symput('n_study', put(id_n, 3.0));
			if &x = 1 then call symput('n_A', put(id_n, 3.0));
			if &x = 2 then call symput('n_B', put(id_n, 3.0));
		run;



			* nodate contents;

	/*****
	 PRODUCE BY CENTER LISTNG 
	* to do: use a macro to go by center, get rid of by-line, make a custom one with sample size for each center ;
	

	*ods pdf file = "/glnd/sas/reporting/nosocomial_listings_open.pdf" style = journal startpage=no ;
	ods pdf file = "nosocomial_listings_open.pdf" style = journal startpage=no ;
		title "GLND - Summary of Suspected Nosocomial Infections  (total = &n_susp_infec, n = &n_study)";
		
		proc print data= noso noobs label width=minimum style(table)= [font_width = compressed ];
			id center;
			by center;
			var id infect_confirm incident days_post_entry  cult_obtain cult_positive organism_1 organism_2 organism_3 organism_4 organism_5 
				site_code type_code;
			format center center.;
		run;
	ods pdf close;



	/* PRODUCE BY ORGANISM TABLE */

	* go through data, currently arranged on a per-episode basis, and stack by organism ;
	data by_organism;
		set noso;

		where (infect_confirm in (1,2)) & (cult_positive=1); * only look at positive infections with positive cultures ; 

		* work backwards from oganism_5,  ... ;
		if cult_org_code_5 ~= . then do; organism = organism_5; cult_org_code = cult_org_code_5; org_spec = org_spec_5; output; end;
		if cult_org_code_4 ~= . then do; organism = organism_4; cult_org_code = cult_org_code_4; org_spec = org_spec_4; output; end;
		if cult_org_code_3 ~= . then do; organism = organism_3; cult_org_code = cult_org_code_3; org_spec = org_spec_3; output; end;
		if cult_org_code_2 ~= . then do; organism = organism_2; cult_org_code = cult_org_code_2; org_spec = org_spec_2; output; end;
		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; 
			* every record has at least the first organism;
		
		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;	
	


		* handle non "other" types of infections first, using numeric codes ;

			* get counts of infections, by organism type;
				proc sort data= by_organism; by incident; run;			
				proc means data = by_organism n  ;
					where (cult_org_code ~= 23); * will process others separately;
					by incident;
					class cult_org_code;
					var id ;

					output out = infects_out n(cult_org_code) = num_infect;
				run;
				* clean up output dataset ;	
				data infects_out;
					set infects_out;
					where cult_org_code ~= .;
					drop _type_ _freq_;
				run;
			
			* get count of people infected, by organism type ;
			* remove repeat IDs within each organism code;
				proc sort data= by_organism; by incident cult_org_code id; run;		* conveniently already sorted by incident ;
				data people_infec;
					set by_organism;
					where (cult_org_code ~= 23); * will process others separately;
					by incident cult_org_code id;

					if ~first.id then delete; * make sure theres one record for each person within this type of infection ;
				run;
				proc sort data= people_infec; by incident; run;		

				proc means data = people_infec n  ;
					by incident;
					class cult_org_code;
					var id ;

					output out = patients_out n(cult_org_code) = num_patients;
				run;
				* clean up output dataset ;	
				data patients_out;
					set patients_out;
					where cult_org_code ~= .;
					drop _type_ _freq_;
				run;

			* merge patient and infection totals, for prevalent and incident, side-by-side ;
				data total_prev;
					set	patients_out (rename = (num_patients = prev_patients)) ;
					by cult_org_code;
					where incident = 0;
				
					
				run;
	
				data total_inc;
					merge 	infects_out  (rename = (num_infect = inc_infect ))
							patients_out (rename = (num_patients = inc_patients ));
					by cult_org_code;
					where incident = 1;
				run;
				
				data total;	
					merge total_inc total_prev;
					by cult_org_code;

					drop incident;
				run;
				

			proc print data= total;
			run;


		* merge these summary numbers back with the blank gram+, gram-, fungus tables;

		/* Create pieces by organism types */
		
		* blank tables first ;
		data all_codes;
			do i = 1 to 23;
				cult_org_code = i;
				output;
			end;	

			drop i;
		run;	
		

		* gram+ bacteria (codes 1-7, 11, 16,21);
		data gram_pos;
			merge all_codes 
				total	
					;
			by cult_org_code;
			where cult_org_code in (1,2,3,4,5,6,7,11,16,21);
			type = "Gram+ Bacteria     ";  * spaces are here so that the variable can hold longer strings later ;
			organism = put(cult_org_code, cult_org_code.);
		run;

		* gram- bacteria (codes: 8-10, 12-15,22);
		* however, we want codes 8 and 9 last, so that we can append the klebsiella other data;
		data gram_neg;	
			merge all_codes 
				total	
					;
			by cult_org_code;
			where cult_org_code in (10,12,13,14,15);
		run;
		data gram_neg_1;
			merge all_codes 
				total	
					;
			by cult_org_code;
		
			where cult_org_code in (8,9) ;
		run;

		data gram_neg_2;
			merge all_codes 
				total	
					;
			by cult_org_code;
		
			where cult_org_code=22 ; 
		run;

		data gram_neg;
			set gram_neg gram_neg_1 gram_neg_2;
		
			type = "Gram- Bacteria";
		organism = put(cult_org_code, cult_org_code.);
		run;
		

		* Fungal species (codes 17-20);
		data fungus;	
			merge all_codes 
				total	
					;
			by cult_org_code;
			where cult_org_code in (17,18,19,20);
			organism = put(cult_org_code, cult_org_code.);
			
			if cult_org_code = 20 then	organism = put(cult_org_code, cult_org_code.) || ":";

			type= "Fungal Species";
		run;


		/* Now that we have all three main groupings, we will now repeat the process above on the 3 other categories, but performing 
			operations on the three text strings, not the organism code

			The code is pasted, overwriting the previous datasets, with little adjustment */

			* get counts of infections, by organism type;
				proc sort data= by_organism; by incident; run;			
				proc means data = by_organism n  ;
					where (cult_org_code in (9,20,21,22,23));
					by incident;
					class organism; * by the text description of the organism, not the number ;
					var id ;

					output out = infects_out n(cult_org_code) = num_infect;
				run;
			
				* clean up output dataset ;	
				data infects_out;
					set infects_out;
					where _TYPE_ = 1;
					*where (organism ~= ".") | (trim(organism) ~= " ");
				
					drop _type_ _freq_;
				run;
			
			* get count of people infected, by organism type ;
			* remove repeat IDs within each organism code;
				
				proc sort data= by_organism; by incident organism id; run;		
				data people_infec;
					set by_organism;
					where (cult_org_code in (9,20,21,22,23));
					by incident organism id;

					if ~first.id  then delete; * make sure theres one record for each person within this type of infection ;

				run;
				proc sort data= people_infec; by incident; run;		

				proc means data = people_infec n  ;
					where (cult_org_code in (9,20,21,22,23));
					by incident;
					class organism;
					var id ;

					output out = patients_out n(cult_org_code) = num_patients;
				run;
				* clean up output dataset ;	
				data patients_out;
					set patients_out;
					where (organism ~= ".") | (trim(organism) ~= " ");
					drop _type_ _freq_;
				run;

			* merge patient and infection totals, for prevalent and incident, side-by-side ;
				data total_prev;
					set	patients_out (rename = (num_patients = prev_patients)) ;
					by organism;
					where incident = 0;
				
					
				run;
	
				data total_inc;
					merge 	infects_out  (rename = (num_infect = inc_infect ))
							patients_out (rename = (num_patients = inc_patients ));
					by organism;
					where incident = 1;
				run;
				
				
				proc sort data= by_organism; by organism; run;










				* these have all the other organisms to add into other parts of the table  ;

				data total_others;	
					merge 	total_inc (in = has_inc_other)
							total_prev (in = has_prev_other)
							by_organism (keep = organism cult_org_code) /* put the culture number back on the dataset */
							;
					by organism;

					if ~(has_inc_other | has_prev_other) then delete; * capture just those with other infections ; 
					if _N_ = 1 then delete ; * the above means procedure's use of the cult_org_code for the n otuput produces a summary first record with a blank description that needs to be removed;
					drop incident;


					if cult_org_code=20 then type = "Fungal Species";
					if cult_org_code=21 then type = "Gram+ Bacteria";
					if cult_org_code in(9, 22) then type = "Gram- Bacteria";
					if cult_org_code=23 then type = "Other";

				run;
				

			proc means data= total;
			run;


/*  ADD THE OTHERS WITHIN EACH TYPE. AS WELL AS GENERAL OTHER group below. 
	then create the various summary numbers for display, format their display (found in nutrition_summaries.sas) */

		data organism_summary;
			length organism $80;
			set 
				gram_pos	
				total_others (where=(cult_org_code = 21))	
				gram_neg     (where=(cult_org_code ^=22))
				total_others (where=(cult_org_code = 9))
				gram_neg     (where=(cult_org_code = 22))
				total_others (where=(cult_org_code = 22))
				fungus
				total_others (where=(cult_org_code = 20))
				total_others (where=(cult_org_code = 23))
				;

			* add "types" into the 'other' rows for proper display ;
			if cult_org_code = 21 then do;
				if organism^=scan(organism,1,"-") then do;
				organism = "--" || substrn(organism, 23); * chop of the "Other - " portion of the string ; 
			end;	end;

			* add "types" into the 'other' rows for proper display ;
			if cult_org_code = 9 then do;
				if organism^=scan(organism,1,"-") then do;
				organism = "--" || substrn(organism, 27); * chop of the "Other - " portion of the string ; 
			end;	end;

			* add "types" into the 'other' rows for proper display ;
			if cult_org_code = 22 then do;
				if organism^=substr(organism,1,20) then do;
				organism = "--" || substrn(organism, 23); * chop of the "Other - " portion of the string ; 
			end;	end;

			* add "types" into the 'other' rows for proper display ;
			if cult_org_code = 20 then do;
				if organism^=scan(organism,1,"-") then do;
				organism = "--" || substrn(organism, 23); * chop of the "Other - " portion of the string ; 
			end;	end;

			if (cult_org_code = 23) & type="Other" then do;
				organism = substrn(organism, 9); * chop of the "Other - " portion of the string ; 
			end;

			* set missing data to 0's ;
			if prev_patients = . then prev_patients= 0;
			if inc_infect = . then inc_infect = 0;	
			if inc_patients = . then inc_patients= 0;

			format cult_org_code cult_org_code.;
		run;

		* now create "All organism" type of summaries for this table ;
		data organism_summary;
			set organism_summary;
			by type notsorted;
		
			if (last.type) & (type ~= "Other")  then do; * this doesnt make too much sense for the other group ; 
				output;
				organism = "== Any " || trim(type) || " =="; 	
				summary = 1; * INDICATES THAT THIS IS A SUMMARY RECORD, USEFUL FOR SORTING LATER!; 
			end;
			output;
		run;

		* remember the order of the observations of this dataset for later! ;
		data organism_summary;
			set organism_summary;
			order = _n_ ;
		run;


		* capture infection totals - for all 4 types (includes OTHERS);
			proc means data = organism_summary;
				class type ;
				where ~((substrn(organism, 0, 3) = "==") | (substrn(organism, 0, 3) = "--")) ; 
						* exclude any rows that show summaries or specific other types of organisms  ;
	
				var inc_infect;
				output out = org_total_infect sum(inc_infect) = inc_infect;
			run;
			/*data org_total_infect;
				set org_total_infect;
				
				temp_type = type;
				drop type;
			run;*/
			data org_total_infect;
				set org_total_infect;

				if _type_ = 0 then type = "== Any Infection ==       ";
				else type = "== " || type || " =="; * this will allow us to merge back into the table later;

				drop _type_ _freq_;
			run;

		* capture patient totals WITHIN each type;
			* go back to data, label type;
			
			data by_type;
				set by_organism;
				where cult_org_code ~= 23; * treat each OTHER infection separately;

				if cult_org_code in (1,2,3,4,5,6,7,11,16,21) then type = "== Any Gram+ Bacteria =="; 
				if cult_org_code in (8,9,10,12,13,14,15,22) then type = "== Any Gram- Bacteria ==";
				if cult_org_code in (17,18,19,20) then type = "== Any Fungal Species =="; 
				
 			run;
			proc sort data= by_type; 
				by incident type id; 
			run;

				* - VERY IMPORTANT STEP! - remove replicate IDs within each class of organism within each class of incidence  ;
				data by_type;
					set by_type;
					by incident type id ;
					if ~first.id  then delete; * make sure theres one record for each person within this type of infection ;
				run;

				proc sort data= by_type; by incident; run;		
				proc print data= by_type; var id incident organism; run;
				
				proc means data =  by_type n  ;
					by incident;
					class type;
					var id ;

					output out = patients_out n(cult_org_code) = num_patients;
				run;


				* clean up output dataset - this dataset now has the totals for gram+, gram-, fungal species ;	
				data patients_out;
					set patients_out;
					
					if _type_ = 0 then delete; * delete overall total row. this is not accurate;
					drop _type_ _freq_;
				run;
					data a;
						set patients_out;
						where incident = 0;
					run;
					data b;
						set patients_out;
						where incident = 1;
					run;
					data patients_out;
						merge a (rename =(num_patients = prev_patients))
							 b (rename =(num_patients = inc_patients));
						by type;
						drop incident;

					run;

					* add in the overall sum of infections for these three groups ;
					proc sort data= org_total_infect; by type; run; 

					* strip out the overall and other record, leaving just the 3 in middle ;
					data temp_org_total;
						set org_total_infect;
						if _n_ in (1,5) then delete;
					run;
							
					* merge the two side-by-side, to put the infection totals next to the patient totals 
						(this is not the most stable with no by statement, but it is easiest here due to problems with the type variable ;
					data patients_out;
						merge patients_out 
							temp_org_total (drop = type)
							;
						format type $52.;
						rename type = organism; * this really should have been called organism all along;
					run;
					* merge into organism_summary;
					* sort organism_summary by organism, but we have the order stored in there; 
					proc sort data= organism_summary; by organism; run;
					proc sort data= patients_out; by organism; run;
				
					data organism_summary;	
						merge   organism_summary
								patients_out (in = is_summary rename = (prev_patients = a inc_patients = b inc_infect = c))
								;
						by organism;
						
						* take summary numbers and overwrite 0s in table;
						if is_summary then do;
							prev_patients = a; inc_patients = b; inc_infect = c;
						end;
						drop a b c;
					run;
					proc sort data= organism_summary; by order; run; * reorder ;



				* 1. still need sum of patients overall ;
				* 2. merge in infection totals from org_total_infect; 
				* 3. then merge that info back into the main organism_summary table ; 


				* get sum of patients overall ;
				proc sort data= by_organism; 
					by incident  id; 
				run;
				data by_overall;
					set by_organism;
					by incident id ;
		
					if ~first.id then delete;
				run;
				proc means data =  by_overall n  ;
					class incident;
					var id ;

					output out = overall_out n(cult_org_code) = num_patients;
				run;
					data overall_out;
						set overall_out;
						
						if _type_ = 0 then delete; * delete overall total row. this is not accurate;
						drop _type_ _freq_;
					run;
					data a;
						set overall_out;
						where incident = 0;
					run;
					data b;
						set overall_out;
						where incident = 1;
					run;
					data overall_out;
						merge a (rename =(num_patients = prev_patients))
							 b (rename =(num_patients = inc_patients));
							
						* format for the final table ;
						type = "== Any Infection ==";
						organism = " ";
						summary = 1; * WILL HELP SORTING LATER;
						drop incident;
					run;

					* add in the overall sum of infections ;
					data overall_out;
						merge overall_out ( in = overall_record)
							org_total_infect
							;
						if ~overall_record then delete ; * take just the overall record from these totals ;
					run;
					

					* add any infection to bottom of table;
					data organism_summary;
						set organism_summary
							overall_out;	
					run;

		* now perform calculations and format the results;
		data organism_summary_&x;
			set organism_summary;

			if summary ~= 1 then summary = 0;

			* convert all genus names to upper-case for most appropriate presentation. ie: capitalize first letter ;
			organism = upcase(substrn(trim(organism), 1, 1)) || substrn(organism, 2);

			* perform calculations ;
			if prev_patients = . then prev_patients= 0;
			if inc_patients = . then inc_patients= 0;
			prev_percent = (prev_patients / &n_study) * 100; * percent of patients with this  organism ;
			inc_percent = (inc_patients / &n_study) * 100; 	* percent of patients with this organism ;	
			if inc_percent = . then inc_percent = 0; 

			* format all information in one convenient line for each infection type;
			prevalent_&group = compress(put(prev_patients, 3.) || "/" || put(&n_study, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
			incident_&group =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(&n_study, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;
		run;
	
		/* FOR DIAGNOSTIC PURPOSES - SAVE A COPY OF THE DATA FOR CHECKING
		data glnd_rep.organism_summary_&x; 
			set organism_summary_&x;
		run;
		*/



/**  PRODUCE BY SITE AND TYPE TABLE, with organism listing **/

	* first, we need the data arranged two way - by number of unique infection episodes and by cultured organisms;

	* number of unique episodes is straight-forward - simply take noso, filter out non-confirmed infections ;
	data by_episode;
		set noso; 

		where (infect_confirm in (1,2)); * only look at positive infections with positive cultures ; 


		site_code_label = trim(put(site_code, site_code.));
		type_code_label = trim(put(type_code, type_code.));

		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;

	* now list by organism ... ; 
	* unlike the previous by_organism, this dataset has records for those infections w/o a listed organism ;
	data by_organism_all_infec;
		set noso;

		where (infect_confirm in (1,2)); * only look at positive infections with positive cultures ; 

		/*organism= " 													";
		* work backwards from oganism_5,  ... ;
		if cult_org_code_5 ~= . then do; organism = trim(organism) || ", " || organism_5; end;
		if cult_org_code_4 ~= . then do; organism = trim(organism) || ", " || organism_4; end;
		if cult_org_code_3 ~= . then do; organism = trim(organism) || ", " || organism_3; end;
		if cult_org_code_2 ~= . then do; organism = trim(organism) || ", " || organism_2; end;

		if cult_org_code_1 ~= . then do; organism = trim(organism) || ", " || organism_1; end;
		*/
		if cult_org_code_5 ~= . then do; organism = organism_5; cult_org_code = cult_org_code_5; org_spec = org_spec_5; output; end;
		if cult_org_code_4 ~= . then do; organism = organism_4; cult_org_code = cult_org_code_4; org_spec = org_spec_4; output; end;
		if cult_org_code_3 ~= . then do; organism = organism_3; cult_org_code = cult_org_code_3; org_spec = org_spec_3; output; end;
		if cult_org_code_2 ~= . then do; organism = organism_2; cult_org_code = cult_org_code_2; org_spec = org_spec_2; output; end;

		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; 
				* every record has at least the first organism;
		else output;
		
		
		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;		

	* add labels to those infections w/o a confirmed organism;
	data by_organism_all_infec;
		set  by_organism_all_infec;

		if  (organism = "") & ~cult_obtain then organism = "(no culture obtained)";
		else if (organism = "") & (cult_obtain) & (~cult_positive) then organism = "(negative culture)";

		* also add indicator for whether this is a prevalent or incident culture ;
		if incident then organism = trim(organism) || " - [inc.]";
		if ~incident then organism = trim(organism) || " - [prev.]";

	run;



	* NOW ANALYZE by site and type code - first gather total number of infections;
		proc means data = by_episode n;
			class site_code type_code;
			where incident = 1;
			var dt_infect ;

			output out = episode_infect n(dt_infect) = inc_infect;
		run;

		* post-process. remove all observations that are summarizing across a class ;
		data episode_infect;
			set episode_infect;
			where (site_code ~= "") & (type_code ~= "") ;
			drop _type_ _freq_;
		run;


	* then gather unique people within each infection and type+site code  ;
		proc sort data= by_episode; 
			by incident type_code site_code id;
		run;
		
		* reduce to one id per combination of incident, type, site ;
		data episode_people;
			set by_episode;
			by incident type_code site_code id;
			if ~first.id then delete;
		run;

		* now gather totals by incidence ;
		proc means data = episode_people n;
			class incident site_code type_code;
			var dt_infect ;

			output out = episode_people_out n(dt_infect) = num_patients;
		run;

		* post-process. remove all observations that are summarizing across a class ;
		data episode_people_out;
			set episode_people_out;
			where (site_code ~= "") & (type_code ~= "") & (incident ~= .) ;
			drop _type_ _freq_;
		run;
			data a;
				set episode_people_out;
				where incident = 0;
			run;
			data b;
				set episode_people_out;
				where incident = 1;
			run;

			proc sort data= a; 	by site_code type_code ; run;
			proc sort data= b; 	by site_code type_code; run;
			proc sort data= episode_infect; 	by site_code type_code; run;

		* now put incident and prevalent patient totals together with incident infection totals ;
		data episode_people_out;
			merge a (rename =(num_patients = prev_patients))
				 b (rename =(num_patients = inc_patients))
				 episode_infect;
			by site_code type_code;

			* recode missing to 0;
			if prev_patients = . then prev_patients = 0;
			if inc_patients = . then inc_patients = 0;
			if inc_infect = . then inc_infect = 0;

		drop incident;
		run;





		* now merge in the specific organism findings by site and type code;
		proc sort data=  by_organism_all_infec; 	by site_code type_code; run;
		data episode_people_out;
			merge  episode_people_out
					by_organism_all_infec (keep = site_code type_code organism incident)
					;
			by site_code type_code;
		run;


		proc sort data= episode_people_out; 	by site_code type_code incident organism ; run;

		* touch up table, generate summary stats. white out repeats within all three levels. 
			so only add labels on the first of site_code type_code ;

		data episode_summary;
			set episode_people_out (drop = incident); * drop incident as i will re-create it below to serve another purpose;
			by site_code type_code;
			
			organism = trim(organism);
			
			if first.type_code then do;
				* perform calculations ;
				prev_percent = (prev_patients / &n_study) * 100; * percent of patients with this  organism ;
				inc_percent = (inc_patients / &n_study) * 100; 	* percent of patients with this organism ;	
				if inc_percent = . then inc_percent = 0; 

				* format all information in one convenient line for each infection type;
				prevalent = compress(put(prev_patients, 3.) || "/" || put(&n_study, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
				incident =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(&n_study, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;
			end;	
		run;


		/* NOW COMPUTE OVERALL TOTALS, THEN PASTE BY CENTER AND OVERALL INTO SUMMARY TABLE! */
		
			proc means data = by_episode n;
				where incident = 1;
				var dt_infect ;

				output out = overall_infect n(dt_infect) = inc_infect;
			run;

			* post-process. remove all observations that are summarizing across a class ;
			data overall_infect;
				set overall_infect;
				drop _type_ _freq_;
			run;


		* then gather unique people within each infection  code  ;
			proc sort data= by_episode; 
				by incident id;
			run;
			
			* reduce to one id per combination of incident ;
			data episode_people;
				set by_episode;
				by incident id;
				if ~first.id then delete;
			run;

			* now gather totals by incidence ;
			proc means data = episode_people n;
				class incident ;
				var dt_infect ;

				output out = overall_people_out n(dt_infect) = num_patients;
			run;

			* post-process. remove all observations that are summarizing across a class ;
			data overall_people_out;
				set overall_people_out;
				where (incident ~= .) ;
				drop _type_ _freq_;
			run;
				data a;
					set overall_people_out;
					where incident = 0;
				run;
				data b;
					set overall_people_out;
					where incident = 1;
				run;

			* now put incident and prevalent patient totals together with incident infection totals ;
			data overall_people_out;
				merge a (rename =(num_patients = prev_patients))
					 b (rename =(num_patients = inc_patients))
					 overall_infect;

					 * by nothing, since all datasets have one observation ;



				* recode missing to 0;
				if prev_patients = . then prev_patients = 0;
				if inc_patients = . then inc_patients = 0;
				if inc_infect = . then inc_infect = 0;

				* add row title ;
				site_code = "Overall total:";

			drop incident;
			run;	


		/** now add by overall totals into summary table, and process **/
		data summary_temp;
			set 		
				overall_people_out;
			
						
				* perform calculations ;
				prev_percent = (prev_patients / &n_study) * 100; * percent of patients with this  organism ;
				inc_percent = (inc_patients / &n_study) * 100; 	* percent of patients with this organism ;	
				if inc_percent = . then inc_percent = 0; 

				* format all information in one convenient line for each infection type;
				prevalent = compress(put(prev_patients, 3.) || "/" || put(&n_study, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
				incident =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(&n_study, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;

				sort = 1; **** DETERMINE SORT ORDER IN TABLE;
		run;

		data episode_summary;
			set episode_summary
				summary_temp;

	
		run;

	  
		/**	Now compute the numbers by center, then add to the table	**/
			proc means data = by_episode n;
				class center;
				where incident = 1;
				var dt_infect ;

				output out = center_infect n(dt_infect) = inc_infect;
			run;

			* post-process. remove all observations that are summarizing across a class ;
			data center_infect;
				set center_infect;
				where (center ~= .) ;
				drop _type_ _freq_;
			run;


		* then gather unique people within each infection and center code  ;
			proc sort data= by_episode; 
				by incident center id;
			run;
			
			* reduce to one id per combination of incident, centere ;
			data episode_people;
				set by_episode;
				by incident center id;
				if ~first.id then delete;
			run;

			* now gather totals by incidence ;
			proc means data = episode_people n;
				class incident center;
				var dt_infect ;

				output out = center_people_out n(dt_infect) = num_patients;
			run;

			* post-process. remove all observations that are summarizing across a class ;
			data center_people_out;
				set center_people_out;
				where (center~=.) & (incident ~= .) ;
				drop _type_ _freq_;
			run;
				data a;
					set center_people_out;
					where incident = 0;
				run;
				data b;
					set center_people_out;
					where incident = 1;
				run;

				proc sort data= a; 	by center ; run;
				proc sort data= b; 	by  center ; run;
				proc sort data= center_infect; 	by center; run;

			* now put incident and prevalent patient totals together with incident infection totals ;
			data center_people_out;
				merge a (rename =(num_patients = prev_patients))
					 b (rename =(num_patients = inc_patients))
					 center_infect;
				by center;

			drop incident;
			run;
			

			* now capture denominators by center for computing center percentages. cannot use macro variable for overall n ;
				data status_temp;
					set glnd.george; * CAPTURE TREATMENT INFO! ;
					WHERE TREATMENT = &x;

					center = floor(id/10000);
				run;
				proc means data= status_temp;
					
					class center;
					output out= center_n n(id) = center_n;
				run;
				* post-process to remove overall total and other columns;
				data center_n;
					set center_n;
					where _type_ ~= 0;
					drop _type_ _freq_;
				run;
		
		proc sort data= center_people_out; by center; run;
		proc sort data= center_n; by center; run;


		/** now add in center N, center totals into summary table, and process **/
		data summary_temp;
			merge	center_people_out
					center_n
					;
			by center;


				* recode missing to 0;
				if prev_patients = . then prev_patients = 0;
				if inc_patients = . then inc_patients = 0;
				if inc_infect = . then inc_infect = 0;

				* add row title code;
				if center = 1 then site_code = "Emor";
				if center = 2 then site_code = "Miri";
				if center = 3 then site_code = "Vand";
				if center = 4 then site_code = "Colo";
				if center = 5 then site_code = "Wisc";
	
				* perform calculations ;
				prev_percent = (prev_patients / center_n) * 100; * percent of patients with this  organism ;
				inc_percent = (inc_patients / center_n) * 100; 	* percent of patients with this organism ;	
				if inc_percent = . then inc_percent = 0; 

				* format all information in one convenient line for each infection type;
				prevalent = compress(put(prev_patients, 3.) || "/" || put(center_n, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
				incident =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(center_n, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;

				sort = 4;
	
		run;

		data glnd_rep.summary_temp; set summary_temp; run;

		* add a blank line on top of centers ;
		data center_headers;
		
			site_code = "    "; sort = 2; output;
			site_code = "Site"; sort = 3; output;

			
		run;

		* change ;
		data episode_summary_&x;
			set episode_summary
				center_headers
				summary_temp;

				if sort = . then sort = 0; * all regular rows;

		*			if prevalent = "" then prevalent ;
		
			rename prevalent = prevalent_&group incident = incident_&group;

			drop organism; * we are not going to have this on the merged listing;
		run;


%end;

%mend closed;
%closed run;


/**** Merge and Polish up organism table ****/
	* add record indicator for sorting both A and B tables after merge;
		data organism_summary_1;
			set organism_summary_1;
			by type notsorted;
			num = _N_; * assign a number within this treatment group;
			/* For sorting*/
			if organism="-- Klebsiella not specified" then num=38;
		run;
		proc sort data= organism_summary_1 nodupkey; by type organism; run;
	

		data organism_summary_2;
			set organism_summary_2;
			by type notsorted;
			num = _N_; * assign a number within this treatment group;
		run;
		proc sort data= organism_summary_2 nodupkey; by type organism; run;
	
	
		data glnd_rep.organism_summary_closed;
			merge 	organism_summary_1 
					organism_summary_2 
					;
			
			* blanks were created in one group where an OTHER organism was seen in one group but not the other, as a result of the merge. fix this ;
			if prevalent_a = "" then prevalent_a = "0 (0/&n_A, 0.0%)";
			if prevalent_b = "" then prevalent_b = "0 (0/&n_B, 0.0%)";		
			if incident_a = "" then incident_a = "0 (0/&n_A, 0.0%)";		
			if incident_b = "" then incident_b = "0 (0/&n_B, 0.0%)";		
	

			* control the sorting of each TYPE for printing;

				if trim(type) = "Gram+ Bacteria" then type_sort = 0;
				if trim(type) = "Gram- Bacteria" then type_sort = 1;
				if trim(type) = "Fungal Species" then type_sort = 2; 
				if trim(type) = "Other" then type_sort = 3; 
				
				* truncate label on last row;
				if type = "== Any Infection ==" then do; type ="Any Infection"; type_sort = 4; end;

	
			by type organism;
		run;


		proc sort data= glnd_rep.organism_summary_closed; by type_sort summary num; run; * sort by type, whether it is a summary record, 
																			then by num for the non-summary records (this does not necessarily 
																			produce reliable sorting within the non-summary records);


		* insert spaces after each grouping, as row titles are now getting tossed onto 2 lines ;
		data glnd_rep.organism_summary_closed; 
			set glnd_rep.organism_summary_closed(rename=(organism=temp)); 
			by type notsorted;


			* convert all genus names to upper-case for most appropriate presentation. ie: capitalize first letter ;
			if substr(temp,1,2)^="--" then organism = Upcase(substrn(strip(temp), 1, 1)) || substrn(strip(temp), 2);
			else organism ="-- "||Upcase(substrn(strip(temp), 4, 1)) || substrn(strip(temp), 5);
				*organism=propcase(temp);

			drop temp;



	label 	type = "Class" 
					organism = "Organism"
					prevalent_a = "Treatment A"
					incident_a = "Treatment A"
					prevalent_b = "Treatment B"
					incident_b = "Treatment B"
					
			if last.type then do; 
				output; 
				 organism = ""; prevalent_a = ""; prevalent_b = ""; incident_a = ""; incident_b = ""; * type is still output, so can properly print;
				output;
			end;
			else output;
		run;

* Merge and Polish up site and type table */

	* add record indicator for sorting both A and B tables after merge;
		data episode_summary_1;
			set episode_summary_1;
			by site_code type_code  notsorted; 			

			* delete empty rows created by removal of causative organisms ;
			if ~first.type_code then delete;
		run;

		data episode_summary_1;
			set episode_summary_1;
			num = _N_;
		run;
		
		/* data glnd_rep.episode_summary_1; set episode_summary_1; run; * FOR TESTING ONLY ; */ 
		
		proc sort data= episode_summary_1; by site_code type_code; run;
	
		data episode_summary_2;
			set episode_summary_2;
			by site_code type_code  notsorted; 	

			* delete empty rows created by removal of causative organisms ;
			if ~first.type_code then delete;
		run;

		data episode_summary_2;
			set episode_summary_2;
			num = _N_;
		run;

		/* data glnd_rep.episode_summary_2; set episode_summary_2; run;  * FOR TESTING ONLY; */
  
		proc sort data= episode_summary_2; by site_code type_code; run;
	
	
		data glnd_rep.episode_summary_closed;
			merge 	episode_summary_1 
					episode_summary_2 
					;
                by site_code type_code;
*               added by george for splus;


length  tc $ 50;
  tc='  ';

 if type_code="SUTI" then tc= "Symptomatic urinary tract infection";
                                if type_code="ASB" then tc=     "Asymptomatic bacteriuria" ;
                                if type_code="OUTI" then tc=    "Other infections of the urinary tract";
                                if type_code="SKNC" then tc= "Superficial incisional infection at chest incision site, after CBGB";
                                if type_code="SKNL" then tc= "Superficial incisional infection at vein donor site, after CBGB.";
                                if type_code="STC" then tc=   "After CBGB, report STC for deep incisional surgical site infection at chest inc
ision site.";
                                if type_code="STL" then tc=      "After CBGB, report STL for deep incisional surgical site infection at vein d
onor site.";
                                if type_code="PNU1" then tc= "PNU1 - Clinically defined pneumonia";
                                if type_code="PNU2" then tc= "PNU2 - Pneumonia with specific lab findings";
                                if type_code="PNU3" then tc= "PNU3 - Pneumonia in immunocompromised patients";
                                if type_code="LCBI" then tc=  "Laboratory-confirmed bloodstream infection";
                                if type_code="CSEP" then tc=    "Clinical sepsis";
                                if type_code="BONE" then tc=    "Osteomyelitis";
                                if type_code="JNT" then tc=     "Joint or bursa";
                                if type_code="IC" then tc=      "Intracranial infection";
                                if type_code="MEN" then tc=     "Menitigitis or ventriculitis";
                                if type_code="SA" then tc=      "Spinal abscess without meningitis";
                                if type_code="VASC" then tc=    "Arterial or venous infection";
                                if type_code="ENDO" then tc=    "Endocarditis";
                                if type_code="CARD" then tc=    "Myocarditis or pericarditis";
                                if type_code="MED" then tc=     "Mediastinitis";
                                if type_code="EYE" then tc=     "Eye other than conjunctivitis";
                                if type_code="ORAL" then tc=    "Oral Cavity (mouth, tongue, or gums)";
                                if type_code="SINU" then tc=    "Sinusitis";
                                if type_code="UR" then tc=      "Upper respiratory tract, pharyngitis, laryngitis, epiglottitis";
                                if type_code="GE" then tc=      "Gastroenteritis";
                                if type_code="GIT" then tc=     "Gastrointestinal (GI) tract";
                                if type_code="HEP" then tc=     "Hepatitis";
                                if type_code="IAB" then tc=     "Intra-abdominal, not specified elsewhere";
                                if type_code="BRON" then tc=    "Bronchitis, tracheobronchitis, tracheitis, without evidence of pneumonia";
                                if type_code="LUNG" then tc=    "Other infections of the lower respiratory tract";
                                if type_code="DECU" then tc=    "Decubitus ulcer";


			* blanks were created in one group where an OTHER organism was seen in one group but not the other, as a result of the merge. fix this ;
			if site_code ~= "" then do;
				if prevalent_a = "" then prevalent_a = "0/0 (0.0%)";
				if prevalent_b = "" then prevalent_b = "0/0 (0.0%)";		
				if incident_a = "" then incident_a = "0 (0/0, 0.0%)";		
				if incident_b = "" then incident_b = "0 (0/0, 0.0%)";		
			end;
			
			
			***** fixe site code same way;
length sc $ 30;
sc='     ';

if site_code= "UTI" then sc=	"Urinary Tract Infection"
if site_code= "SSI" then sc=	"Surgical Site Infection"
if site_code= "PNEU" then sc= "Pneumonia "
if site_code= "BSI" then sc=	"Bloodstream Infection";
if site_code= "BJ" then sc="Bone and Joint Infection";
if site_code= "CNS" then sc=	"Central Nervous System Infection"
if site_code= "CVS" then sc=	"Cardiovascular System Infection"
if site_code= "EENT" then sc=	"Eye, Ear, Nose, Throat, or Mouth Infection"
if site_code= "GI" then sc="Gastrointestinal System Infection"
if site_code= "LRI" then sc=	"Lower Respiratory Tract Infection, Other Than Pneumonia"
if site_code= "SST" then sc=	"Skin and Soft Tissue Infection"
if site_code= "Over" then sc= "Overall total:";
if site_code= "Site" then sc= "Totals by site:";
if site_code= "Emor" then sc= "Emory";
if site_code= "Miri" then sc= "Miriam";
if site_code= "Vand" then sc= "Vanderbilt";
if site_code= "Colo" then sc= "Colorado";
if site_code="Site" then do;
 prevalent_a='  ';
 prevalent_b='  ';
 incident_a= '  ';
 incident_b='  ';
end;
 
			label tc="Type Code"	
					prevalent_a = "Treatment A"
					incident_a = "Treatment A"
					prevalent_b = "Treatment B"
					incident_b = "Treatment B"
					site_code="Site Code"
					sc="Site Code"
					type_code="Type Code";
		run;

	proc contents;

		proc sort data= glnd_rep.episode_summary_closed nodup; by sort center num; run;
		proc print data =glnd_rep.episode_summary_closed;run;


	/*Proc SQL noprint;
		create table unique as select distinct (organism) from glnd_rep.organism_summary_closed;
	quit;*/
		
   

/* PRINT TABLES */

	options ls=125 nodate  	/*papersize= ("15", "8.5")*/    orientation=portrait center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*";
			 * nodate contents;
	*ods ps file = "/glnd/sas/reporting/nosocomialclosed.ps"  style=journal startpage=no ;
	*ods pdf file = "/glnd/sas/reporting/nosocomial_organism_table_closed.pdf" style = journal startpage=no ;
	ods ps file = "nosocomialclosed.ps"  style=journal startpage=no ;
	ods pdf file = "nosocomial_organism_table_closed.pdf" style = journal startpage=no ;

		title1 "GLND - Summary of Nosocomial Infections" ;
		title2 "By Cultured Organism";

		proc print data= glnd_rep.organism_summary_closed noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;

			id type;
			by type notsorted; 
			var organism;
			
			var prevalent_a /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var incident_a /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var prevalent_b /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var incident_b /style(data) = [just=center]; * separate var statement for separate atrributes ;
			
			label 	type = "Class" 
					organism = "Organism"
					prevalent_a = "A*Prevalent Infec.:*# patients (% prev.)"
					incident_a = "A*Incident Infec.:* # infec. (#patients, % incid.)"
					prevalent_b = "B*Prevalent Infec.:*# patients (% prev.)"
					incident_b = "B*Incident Infec.:* # infec. (#patients, % incid.)"
			
				;
		run;	


	ods ps close;
	ods pdf close;

		options ls=250; *nodate  	/*papersize= ("15", "8.5")*/  orientation=portrait center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*"; 	
				* nodate contents;
		*ods ps file = "/glnd/sas/reporting/nosocomialepisodeclosed.ps" style = journal startpage=no ;
		*ods pdf file = "/glnd/sas/reporting/nosocomial_episode_table_closed.pdf" style = journal startpage=no ;
		ods ps file = "nosocomialepisodeclosed.ps" style = journal startpage=no ;
		ods pdf file = "nosocomial_episode_table_closed.pdf" style = journal startpage=no ;
			title1 "GLND - Summary of Nosocomial Infections";
			title2 "By Clinical Site and Type";


			proc print data= glnd_rep.episode_summary_closed noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;
	
				id site_code type_code  ;
				by site_code type_code notsorted ;
	
				var prevalent_a /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var incident_a /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var prevalent_b /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var incident_b /style(data) = [just=center]; * separate var statement for separate atrributes ;
		

				label 	
						prevalent_a = "A*Prevalent Infec.:*# patients (% prev.)"
						incident_a = "A*Incident Infec.:* # infec. (#patients, % incid.)"
						prevalent_b = "B*Prevalent Infec.:*# patients (% prev.)"
						incident_b = "B*Incident Infec.:* # infec. (#patients, % incid.)"
					;
			
					
				format site_code $site_code.;
			run;


		ods ps close;
		ods pdf close;

	quit;
	options ls=120;
proc print  data= glnd_rep.episode_summary_closed;
 var site_code sc;
 data glnd_rep.episodesummaryclosed;
  set glnd_rep.episode_summary_closed;
  keep sc tc prevalent_a prevalent_b incident_a incident_b;
proc contents data= glnd_rep.episodesummaryclosed;

data glnd_rep.organism_summary_closed1;
   set glnd_rep.organism_summary_closed; 
  if _n_ < 45;
  
data glnd_rep.organism_summary_closed2;
   set glnd_rep.organism_summary_closed; 
  if _n_ >=45;