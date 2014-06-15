/* nosocomial_open.sas 
 *
 * MODIFIED ON 3/9/09 TO INHERIT THE NOSOCOMIAL DATASET MODIFIED BY ADJUDICATION, RATHER THAN THE ORIGINAL SITE-REPORTED DATA
 *
 * Produces tables regarding nosocomial infections for the DSMB OPEN SESSION report
 * 
 * Makes a listing of all nosocomial infections, by center 
 * Makes three tables: 1. # infections (patients) by  organism type (cultured), and  
							2. # infections(patients) by clinical presentation ( NO LONGER TRUE. THIS IS CALCULATED, BUT NOT PRINTED. THAT IS DONE IN NOSOCOMIAL_ADJUDICATED_OPEN.SAS )
 *							3. by center totals
 */

 * 1st Table - # infections(patients) by organism type "Table 13" in 2/9/2007 MOO ;


 	proc sort data= glnd_rep.all_infections_with_adj; by id ; run;
 	proc sort data= glnd.status; by id ; run;


/*** MODIFIED ON 3/9/09 TO INHERIT THE NOSOCOMIAL DATASET MODIFIED BY ADJUDICATION, RATHER THAN THE ORIGINAL SITE-REPORTED DATA
 
	proc sort data= glnd.plate102; by id dfseq; run;
	proc sort data= glnd.plate103; by id dfseq; run;
	
	* gather dates and infection data from forms;
	* looking at just infections for now;
	data noso;
		merge	glnd.plate101 (keep = id dfseq dt_infect cult_obtain cult_positive cult_org_code_1 org_spec_1 )
				glnd.plate102 (keep = id dfseq cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5 org_spec_2 org_spec_3 org_spec_4 org_spec_5)
				glnd.plate103 (keep = id dfseq infect_confirm site_code type_code);
		by id dfseq;
	run;
*****************************/	
*options linesize=100;

	data noso;
		set 	glnd_rep.all_infections_with_adj;
			;
	
		by id;


/* This only work for before the cult_org_code_1 correction was made */
/*********************************************************************/
*f org_spec_1="Cytomegalovirus" then cult_org_code_1=23;



		* add center;
		center = floor(id / 10000);

		format incident yn.;
		

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
			if (cult_org_code_1 in (9, 20, 21,22,23)) then organism_1= trim(put(organism_1, $50.)) || " - " || trim(put(org_spec_1, $80.)) ;
			if (cult_org_code_2 in (9, 20, 21,22,23)) then organism_2= trim(put(organism_2, $50.)) || " - " || trim(put(org_spec_2, $80.)) ;
			if (cult_org_code_3 in (9, 20, 21,22,23)) then organism_3= trim(put(organism_3, $50.)) || " - " || trim(put(org_spec_3, $80.)) ;
			if (cult_org_code_4 in (9, 20, 21,22,23)) then organism_4= trim(put(organism_4, $50.)) || " - " || trim(put(org_spec_4, $80.)) ;
			if (cult_org_code_5 in (9, 20, 21,22,23)) then organism_5= trim(put(organism_5, $50.)) || " - " || trim(put(org_spec_5, $80.)) ;


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


	* capture sample size of number of suspected infections;
		proc means data= noso;
			output out= noso_n n(id) = id_n;
		run;
		data _null_;
			set noso_n;
	
			call symput('n_susp_infec', put(id_n, 3.0));
		run;

	* capture sample size of total people on study; 
		proc means data= glnd.status;
			output out= study_n n(id) = id_n;
		run;
		data _null_;
			set study_n;
	
			call symput('n_study', put(id_n, 3.0));
		run;



	/* PRODUCE BY CENTER LISTNG */
	* to do: use a macro to go by center, get rid of by-line, make a custom one with sample size for each center ;
	
	options ls=120 nodate  	/*papersize= ("15", "8.5")*/  orientation = landscape center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*"; * nodate contents;
	*ods pdf file = "/glnd/sas/reporting/nosocomial_listings_open.pdf" style = journal startpage=no ;
	ods pdf file = "nosocomial_listings_open.pdf" style = journal startpage=no ;
		title "GLND - Summary of Suspected Nosocomial Infections  (total = &n_susp_infec, n = &n_study)";
		proc sort data= noso; by id  days_post_entry infect_confirm   ; run;
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
		length	organism $80;
		length org_spec $80;

		where (infect_confirm in (1,2)) & (cult_positive=1); * only look at positive infections with positive cultures ; 

		* work backwards from oganism_5,  ... ;
		if cult_org_code_5 ~= . then do; organism = organism_5; cult_org_code = cult_org_code_5; org_spec = org_spec_5; output; end;
		if cult_org_code_4 ~= . then do; organism = organism_4; cult_org_code = cult_org_code_4; org_spec = org_spec_4; output; end;
		if cult_org_code_3 ~= . then do; organism = organism_3; cult_org_code = cult_org_code_3; org_spec = org_spec_3; output; end;
		if cult_org_code_2 ~= . then do; organism = organism_2; cult_org_code = cult_org_code_2; org_spec = org_spec_2; output; end;
		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; * every record has at least the first organism;
		
		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;	


		* handle non "other" types of infections first, using numeric codes ;

			* get counts of infections, by organism type;
				proc sort data= by_organism; by incident; run;			
				proc means data = by_organism n  ;
					where (cult_org_code ^=23); * will process others separately;
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
					where (cult_org_code ^=23); * will process others separately;
					by incident cult_org_code id;

					if ~first.id then delete; * make sure there's one record for each person within this type of infection ;
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


		/* Now that we have all three main groupings, we will now repeat the process above on the 3 "other" categories, but performing 
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
					where (organism ~= ".") | (trim(organism) ~= " ");
				
					drop _type_ _freq_;
				run;
			
			* get count of people infected, by organism type ;
			* remove repeat IDs within each organism code;
				
				proc sort data= by_organism; by incident organism id; run;		
				data people_infec;
					set by_organism;
					where (cult_org_code in (9,20,21,22,23));
					by incident organism id;

					if ~first.id  then delete; * make sure there's one record for each person within this type of infection ;

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

					if cult_org_code=9  then type = "Gram- Bacteria";
					if cult_org_code=20 then type = "Fungal Species";
					if cult_org_code=21 then type = "Gram+ Bacteria";
					if cult_org_code=22 then type = "Gram- Bacteria";
					if cult_org_code=23 then type = "Other";

				run;
				

			proc means data= total;
			run;


/*  ADD THE OTHERS WITHIN EACH TYPE. AS WELL AS GENERAL "OTHER" group below. 
	then create the various summary numbers for display, format their display (found in nutrition_summaries.sas) */

		/* stack all pieces in the desired order and prepare summary table */
		data organism_summary;
			length organism $80;
			set gram_pos	
				total_others (where=(cult_org_code = 21))	
				gram_neg     (where=(cult_org_code ~= 22))
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

		* remove repeat "other" organisms! ** ADDED 7/30/2008 DUE TO REPEAT "OTHER FUNGAL SPECIES" **; ;
		data organism_summary;
			set organism_summary;
			by organism NOTSORTED;

			if ~first.organism then delete;
		run;


		* now create "All organism" type of summaries for this table ;
		data organism_summary;
			set organism_summary;
			by type notsorted;
		
			if (last.type) & (type ~= "Other")  then do; * this doesn't make too much sense for the 'other' group ; 
				output;
				organism = "== Any " || trim(type) || " =="; 	
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
				where ~((substrn(organism, 0, 3) = "==") | (substrn(organism, 0, 3) = "--")) ; * exclude any rows that show summaries or specific 'other' types of organisms  ;
	
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
				where cult_org_code ~= 23; * treat each 'OTHER' infection separately;

				if cult_org_code in (1,2,3,4,5,6,7,11,16,21) then type = "== Any Gram+ Bacteria ==";
				if cult_org_code in (8,9,10,12,13,14,15,22) then type = "== Any Gram- Bacteria ==";
				if cult_org_code in (17,18,19,20) then type = "== Any Fungal Species ==";
				*if cult_org_code =23 then type = "== Any Other ==";				
 			run;
			proc sort data= by_type; 
				by incident type id; 
			run;

				* - VERY IMPORTANT STEP! - remove replicate IDs within each class of organism within each class of incidence  ;
				data by_type;
					set by_type;
					by incident type id ;
					if ~first.id  then delete; * make sure there's one record for each person within this type of infection ;
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

					* strip out the overall and 'other' record, leaving just the 3 in middle ;
					data temp_org_total;
						set org_total_infect;
						if _n_ in (1,5) then delete;
					run;
							
					* merge the two side-by-side, to put the infection totals next to the patient totals (this is not the most stable with no 'by' statement, but it is easiest here due to problems with the 'type' variable ;
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
						
						* take summary numbers and overwrite 0's in table;
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
		data organism_summary;
			set organism_summary(rename=(organism=temp));

			* convert all genus names to upper-case for most appropriate presentation. ie: capitalize first letter ;
			if substr(temp,1,2)^="--" then organism = Upcase(substrn(strip(temp), 1, 1)) || substrn(strip(temp), 2);
			else organism ="-- "||Upcase(substrn(strip(temp), 4, 1)) || substrn(strip(temp), 5);
				*organism=propcase(temp);

			* perform calculations ;
			prev_percent = (prev_patients / &n_study) * 100; * percent of patients with this  organism ;
			inc_percent = (inc_patients / &n_study) * 100; 	* percent of patients with this organism ;	
			if inc_percent = . then inc_percent = 0; 

			* format all information in one convenient line for each infection type;
			prevalent = compress(put(prev_patients, 3.) || "/" || put(&n_study, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
			incident =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(&n_study, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;

			drop temp;
		run;

	options ls=120 nodate  	/*papersize= ("15", "8.5")*/  orientation =  portrait center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*"; * nodate contents;
	*ods ps file = "/glnd/sas/reporting/nosocomialopen.ps" style = journal startpage=no ;
	*ods pdf file = "/glnd/sas/reporting/nosocomial_organism_table_open.pdf" style = journal startpage=no ;
	ods ps file = "nosocomialopen.ps" style = journal startpage=no ;
	ods pdf file = "nosocomial_organism_table_open.pdf" style = journal startpage=no ;
		title1 "Nosocomial Infections - Cultured Organisms" ;
		title2 "With adjudications applied (n = &n_study)";

		proc print data= organism_summary noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;
			id type;
			by type notsorted;
			var organism;
			var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;

			label 	type = "Class" 
					organism = "Organism"
					prevalent = "Prevalent Infec.:*# patients (% prev.)"
					incident = "Incident Infec.:* # infec. (#patients, % incid.)"
				;
		run;	
	ods ps close;
	ods pdf close;

data x;
   set organism_summary;
   type0=lag(type);
   if type ne type0 then new+1;

ods ps file = "/glnd/sas/reporting/nosocomialopena.ps" style = journal startpage=no ;
	   title1 "Nosocomial Infections - Cultured Organisms" ;
		title2 "With adjudications applied (n = &n_study)";

		proc print data= x noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;
			id type;
			by type notsorted;
			var organism;
			var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;

			label 	type = "Class" 
					organism = "Organism"
					prevalent = "Prevalent Infec.:*# patients (% prev.)"
					incident = "Incident Infec.:* # infec. (#patients, % incid.)"
				;
      where new<4; 
		run;	
	ods ps close;
	


ods ps file = "/glnd/sas/reporting/nosocomialopenb.ps" style = journal startpage=no ;
	   title1 "Nosocomial Infections - Cultured Organisms" ;
		title2 "With adjudications applied (n = &n_study)";

		proc print data= x noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;
			id type;
			by type notsorted;
			var organism;
			var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
			var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;

			label 	type = "Class" 
					organism = "Organism"
					prevalent = "Prevalent Infec.:*# patients (% prev.)"
					incident = "Incident Infec.:* # infec. (#patients, % incid.)"
				;
      where new>3; 
		run;	
	ods ps close;
	



/**  PRODUCE BY SITE AND TYPE TABLE, with organism listing - USED NOW ONLY FOR BY CENTER TOTALS. THESE DATA ARE NOT PRINTED **/

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

		if cult_org_code_1 ~= . then do; organism = organism_1; cult_org_code = cult_org_code_1; org_spec = org_spec_1; output; end; * every record has at least the first organism;
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
				site_code = "Over";

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

		run;
		data episode_summary;
			set episode_summary
				summary_temp;
		run;

	  
		/**	Now compute the numbers by center	**/
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

				* recode missing to 0;
				if prev_patients = . then prev_patients = 0;
				if inc_patients = . then inc_patients = 0;
				if inc_infect = . then inc_infect = 0;

				* add row title code;
				if center = 1 then site_code = "Emor";
				if center = 2 then site_code = "Miri";
				if center = 3 then site_code = "Vand";
				if center = 4 then site_code = "Colo";
				

			drop incident;
			run;
			
		

			* now capture denominators by center for computing center percentages. cannot use macro variable for overall n ;
				data status_temp;
					set glnd.status;
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

				* fix missing values for sites with no infections;
				if prev_patients = . then prev_patients = 0; if prev_percent = . then prev_percent = 0;
				if inc_patients = . then inc_patients = 0; if inc_infect = . then inc_infect = 0;

						
				* perform calculations ;
				prev_percent = (prev_patients / center_n) * 100; * percent of patients with this  organism ;
				inc_percent = (inc_patients / center_n) * 100; 	* percent of patients with this organism ;	
				if inc_percent = . then inc_percent = 0; 

				* format all information in one convenient line for each infection type;
				prevalent = compress(put(prev_patients, 3.) || "/" || put(center_n, 3.), ' ')  || " (" || compress((put(prev_percent, 5.1)) || "%)", ' ')  ;
				incident =  put(inc_infect, 3.) || " (" || compress(put(inc_patients, 3.) || "/" || put(center_n, 3.), ' ') || ", " || compress(put(inc_percent, 5.1) || "%)", ' ')  ;
				
				if center = 5 then site_code = "Wisc";	* wisconsin had 0 infection for the march 2010 report, so i need to add a label for them down here, rather than above;
			label site_code = "Site:";

		run;

		proc print data = summary_temp;
		run;

		/* REMOVED WHEN DECIDED TO PUT BY SITE TOTALS IN A SEPARATE TABLE 
		* add a blank line on top of centers ;
		data center_headers;
			site_code = "     "; output;
			site_code = "Site"; output;
		run;

		data episode_summary;
			set episode_summary
				center_headers
				summary_temp;
		run;
		*/


		* add extra formats for the summaries at the bottom to a different site_code format, stored in work, not library (where the rest of the glnd formats are);

		proc format library=work;
				value $site_code
					/* custom row labels*/
					"Over" = "Overall total:"
					"Site" = "Totals by site:"
					"Emor" = "Emory"
					"Miri" = "Miriam"
					"Vand" = "Vanderbilt"
					"Colo" = "Colorado"	
					"Wisc" = "Wisconsin"

					/* actual site codes */
					"UTI"=	"Urinary Tract Infection"
					"SSI"=	"Surgical Site Infection"
					"PNEU"= "Pneumonia "
					"BSI" =	"Bloodstream Infection"
					"BJ"	=	"Bone and Joint Infection"
					"CNS" =	"Central Nervous System Infection"
					"CVS" =	"Cardiovascular System Infection"
					"EENT"=	"Eye, Ear, Nose, Throat, or Mouth Infection"
					"GI"	=	"Gastrointestinal System Infection"
					"LRI"=	"Lower Respiratory Tract Infection, Other Than Pneumonia"
					"SST"=	"Skin and Soft Tissue Infection"
						;
			run;


		options ls=250 nodate  	/*papersize= ("15", "8.5")*/  orientation =  portrait center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*"; * nodate contents;
		*ods ps file = "/glnd/sas/reporting/nosocomial_center_table_open.ps" style = journal startpage=no ;
		*ods pdf file = "/glnd/sas/reporting/nosocomial_center_table_open.pdf" style = journal startpage=no;
		ods ps file = "nosocomial_center_table_open.ps" style = journal startpage=no ;
		ods pdf file = "nosocomial_center_table_open.pdf" style = journal startpage=no;
		ods escapechar='^' ;

/**************

	BY SITE AND TYPE PRINTING CODE REMOVED! NOW IT IS EXECUTED BY "NOSOCOMIAL_ADJUDICATED_OPEN.SAS" AND THE SOURCE IS IN "NOSOCOMIAL_EPISODE_TABLE.SAS.
 
 **************/






/*** Temporarily here to because I want to put the by center table on the next page. It is not working and not needed now. 10/15/07 ***/
			
			* print STUDY CENTER totals ;
		
			ods pdf startpage = yes; ods ps startpage = yes;
		
			proc print data= summary_temp noobs label width=minimum split = '*' style(table)= [font_width = compressed just = center] ;
				title2 "Totals by Study Center";
				var site_code;
				var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;
					

				label 	
						prevalent = "Prevalent Infec.:*# patients (% prev.)"
						incident = "Incident Infec.:* # infec. (#patients, % incid.)"
					;

				format site_code $site_code.;
			run;	

		ods ps close;
		ods pdf close;

	quit;