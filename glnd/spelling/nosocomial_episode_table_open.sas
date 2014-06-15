/** nosocomial_episode_table_open.sas	
 *
 * Based on code from nosocomial_open.sas, as last used for the February 2008 DSMB report
 *
 * This allows the code for the open report version of the nosocomial infection episode table to be re-used, for example by the 
 * infection adjudication reporting programs.
 *
 **/

%macro nosocomial_episode_table_open (datasource = , filename = , n_study = , custom_title = ) ; * n_study is "number of patients" in denominators ;

	** THE NEXT SECTION USED TO ARE IN THE FIRST PART OF THE BODY OF NOSOCOMIAL_OPEN.SAS **;
	data &datasource;
		length organism_1 $ 100;
		length organism_2 $ 100;
		length organism_3 $ 100;
		length organism_4 $ 100;
		length organism_5 $ 100;

		set &datasource;

		*** CLEAN UP DISPLAY IN DATASETS, REMOVE REPEAT ORGANISMS ***;
		* Set up text field to contain organism format. need to have text rather than numeric so can adjust the "other people";
			/**/
			organism_1 = put(cult_org_code_1, cult_org_code.);
			organism_2 = put(cult_org_code_2, cult_org_code.);
			organism_3 = put(cult_org_code_3, cult_org_code.);
			organism_4 = put(cult_org_code_4, cult_org_code.);
			organism_5 = put(cult_org_code_5, cult_org_code.);
			/**/

		* Adjust "other" categories to include the name of the organism;
			if (cult_org_code_1 in (9, 20, 21,22,23)) then organism_1= trim(put(organism_1, $30.)) || " - " || trim(put(org_spec_1, $50.)) ;
			if (cult_org_code_2 in (9, 20, 21,22,23)) then organism_2= trim(put(organism_2, $30.)) || " - " || trim(put(org_spec_2, $50.)) ;
			if (cult_org_code_3 in (9, 20, 21,22,23)) then organism_3= trim(put(organism_3, $30.)) || " - " || trim(put(org_spec_3, $50.)) ;
			if (cult_org_code_4 in (9, 20, 21,22,23)) then organism_4= trim(put(organism_4, $30.)) || " - " || trim(put(org_spec_4, $50.)) ;
			if (cult_org_code_5 in (9, 20, 21,22,23)) then organism_5= trim(put(organism_5, $30.)) || " - " || trim(put(org_spec_5, $50.)) ;


		* remove repeat organisms from the same infection report, comparing the text labels, working backwards from the 5th organism ;
			if (organism_5 = organism_4) then do; organism_5 = .; cult_org_code_5 = .; org_spec_5 = .; end;
			if (organism_4 = organism_3) then do; organism_4 = .; cult_org_code_4 = .; org_spec_4 = .; end;
			if (organism_3 = organism_2) then do; organism_3 = .; cult_org_code_3 = .; org_spec_3 = .; end;
			if (organism_2 = organism_1) then do; organism_2 = .; cult_org_code_2 = .; org_spec_2 = .; end;
			
		label	
			organism_1 ="1st cult. org."
			organism_2 ="2nd cult. org."
			organism_3 ="3rd cult. org."
			organism_4 ="4th cult. org."
			organism_5 ="5th cult. org."
		;		
	
	run;


/**  PRODUCE BY SITE AND TYPE TABLE, with organism listing **/

	* first, we need the data arranged two way - by number of unique infection episodes and by cultured organisms;

	* number of unique episodes is straight-forward - simply take noso, filter out non-confirmed infections ;
	data by_episode;
		set &datasource; 

		where (infect_confirm in (1,2)); * only look at positive infections with positive cultures ; 


		site_code_label = trim(put(site_code, site_code.));
		type_code_label = trim(put(type_code, type_code.));

		drop organism_1 organism_2 organism_3 organism_4 organism_5 cult_org_code_1 cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5
			org_spec_1 org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;

	* now list by organism ... ; 
	* unlike the previous by_organism, this dataset has records for those infections w/o a listed organism ;
	data by_organism_all_infec;
		set &datasource;

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

					/* actual site codes */
	 
                                "UTI"=  "Urinary Tract Infection"
                                "SSI"=  "Surgical Site Infection"
                                "PNEU"= "Pneumonia "
                                "BSI" = "Bloodstream Infection"
                                "BJ"    =       "Bone and Joint Infection"
                                "CNS" = "Central Nervous System Infection"
                                "CVS" = "Cardiovascular System Infection"
                                "EENT"= "Eye, Ear, Nose, Throat, or Mouth Infection"
                                "GI"    =       "Gastrointestinal System Infection"
                                "LRI"=  "Lower Respiratory Tract Infection, Other Than Pneumonia"
                                "REPR" = "Reproductive Tract Infection"
                                "SST"=  "Skin and Soft Tissue Infection"
                                "SYS" = "Systemic Infection"
                                ;

			run;

		options ls=250 nodate  	/*papersize= ("15", "8.5")*/  orientation =  portrait center nonumber formdlim='-' formchar = "|----|+|---+=|-/\<>*"; * nodate contents;
		*ods ps file = "/glnd/sas/reporting/&filename..ps" style = journal startpage=no ;
		*ods pdf file = "/glnd/sas/reporting/&filename..pdf" style = journal startpage=no;
		ods ps file = "&filename..ps" style = journal startpage=no ;
		ods pdf file = "&filename..pdf" style = journal startpage=no;
		ods escapechar='^' ;


			* BEFORE WE DISPLAY THE FINAL TABLE, REMOVE REPEATED CAUSITIVE ORGANISMS WITHIN EACH INFECTION TYPE AND PREV/INC.  (cannot use by-statement since the table is not being displayed in a sorted fashion) ;
			data episode_summary;
				set episode_summary;
				retain old_site old_type old_organism;
	
				if _N_ = 1 then do;
					old_site = site_code;
					old_type = type_code;
					old_organism = organism;
				end;

				else do;
					if (old_site = site_code) & (old_type = type_code) & (old_organism = organism) then delete;	 
					else do;
						old_site = site_code;
						old_type = type_code;
						old_organism = organism;
					end;	
				end;		
			run;

			title1 &custom_title;
			title2 "By clinical site and type";


			* print by site and type, with overall total at bottom ;
			proc print data= episode_summary noobs label width=minimum split = '*' style(table)= [font_width = compressed] ;
				id site_code type_code  ;
				by site_code type_code notsorted ;
				var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;
				var organism;

				label 	
						organism = "Causative Organisms"
						prevalent = "Prevalent Infec.:*# patients (% prev.)"
						incident = "Incident Infec.:* # infec. (#patients, % incid.)"
					;

				format site_code $site_code.;
			run;	

			* save a copy of this table for use by other programs (like nosocomial_rates_open.sas) ;
			data glnd_rep.&filename;
				set episode_summary;

				* add sample size ;
				n = put(&n_study, 3.0);
			run;

	ods pdf close;
	ods ps close;

%mend nosocomial_episode_table_open;
