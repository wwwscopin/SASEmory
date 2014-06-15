/* nutrition_tables.sas 
 *
 * Eli Rosenberg
 *
 * Print listing of by patient id and day of all nutrition. calculate median for two measures and print.
 * 
 */

* calculate sums;

	proc sort data =glnd.followup_all_long;
		by id day;
	run;
	
	/* WE ARE NO LONGER INCLUDING MEDIANS AT THE BOTTOM OF EACH TABLE
	* calculate median total protein and total kcal for each patient;
	proc means data =glnd.followup_all_long n median noprint;
		class id;
		var tot_aa tot_kcal;
		output out = medians median = med_tot_aa med_tot_kcal;
	run;
	
	* post-process to remove first record (overall median) and unecessary columns;
	data medians;
		set medians	;
		if id = . then delete;
		drop _type_ _freq_;
	
	* create a new "Median" record. delete all blank records after discharge;
	proc sort data= glnd.plate22; by id; run; * needed for kcal, aa projections;
	
	data sum_temp;
		merge glnd.followup_all_long
			glnd.status (keep = id days_hosp_post_entry ) 
			glnd.plate22 (keep = id entry_kcal_goal entry_aa_goal rename = (entry_kcal_goal = daily_kcal_goal entry_aa_goal = daily_aa_goal ))
			medians ;
		
			by id ;

		row = put(day, 6.); * row label;
		
		* median record;
		if (day = days_hosp_post_entry) | ((days_hosp_post_entry = .) & (last.id)) then do; * if last record for a person;
			* output last day in hopsital;
			output;
			
			* create a new "median" record; 
			row = "Median: ";

			tot_aa = med_tot_aa;
			tot_kcal = med_tot_kcal;

			daily_kcal_goal = .;
			daily_aa_goal = .;
			tot_pn = .;
		  	pn_aa_g = .;
		 	pn_aa_kcal = .;
			tube_prot = .;
			tube_kcal  = .;
			oral_prot = .;
			oral_kcal = .;
			iv_kcal = .;
			prop_kcal = .;
			tot_insulin = . ;

			output;
		end;

		else if (day < days_hosp_post_entry) | (days_hosp_post_entry = .) then output;

		else if (day > days_hosp_post_entry) then DELETE; * this is a blank record post-hospital discharge;
		
		* reformat labels to drop question numbers;
		label 
       		tot_pn="Total infused PN"
       		oral_kcal="Oral food kcal"
       		pn_aa_g="PN amino acid"
       		iv_kcal="IV fluids kcal"
       		pn_aa_kcal="PN kcal"
        		prop_kcal="Propofol kcal"
        		tube_prot= "Tube feeding prot."
        		tot_aa= "Total protein/AA"
        		tube_kcal="Tube feeding kcal"
        		tot_kcal="Total kcal"
        		oral_prot="Oral food protein"
        		tot_insulin="Total insulin"
		
			row = "Day"
			daily_kcal_goal = "Daily kcal goal"
			daily_aa_goal = "Daily protein/AA goal";
	

		drop 	 med_tot_aa med_tot_kcal; * don't need these anymore;

	*/
	
	
	
	* create nutritional tracking dataset. delete all blank records after discharge;
		proc sort data= glnd.plate11; by id; run; * needed for kcal, aa projections;
	
	data nut_temp;
		merge glnd.followup_all_long
			glnd.status (keep = id days_hosp_post_entry days_until_death deceased) /* we need the day that the person was discharged */
			glnd.plate11 (keep = id tot_kcal_goal tot_prot_1 rename = (tot_kcal_goal = daily_kcal_goal  tot_prot_1 = daily_aa_goal ))
			 ;
		
			by id ;

		row = put(day, 24.); * row label;

		* feeding totals; 
			tot_ent_aa = tube_prot + oral_prot;
			tot_ent_kcal = tube_kcal + oral_kcal;
		
			tot_iv_kcal = pn_aa_kcal + pn_lipid + pn_cho + iv_kcal + prop_kcal ;		

		* if we know the patient was released from the hospital or died but we do not have all of the f/u info;
		if (last.id) & (day < days_hosp_post_entry) then do;
			
			output;
			tot_aa = .;
			tot_kcal = .;
			daily_kcal_goal = .;
			daily_aa_goal = .;
			tot_pn = .;
		  	pn_aa_g = .;
		 	pn_aa_kcal = .;
			tube_prot = .;
			tube_kcal  = .;
			oral_prot = .;
			oral_kcal = .;
			iv_kcal = .;
			prop_kcal = .;
			tot_insulin = . ;
			tot_ent_aa = .;
			tot_ent_kcal = .;
			tot_iv_kcal = .;
			pn_lipid = .;
			pn_cho = .;
			row = "Missing daily f/u data!";
			output;
		end;
		
		* still hospitalized;
		else if (last.id) & (days_hosp_post_entry = .) then do ;
			output;
			tot_aa = .;
			tot_kcal = .;
			daily_kcal_goal = .;
			daily_aa_goal = .;
			tot_pn = .;
		  	pn_aa_g = .;
		 	pn_aa_kcal = .;
			tube_prot = .;
			tube_kcal  = .;
			oral_prot = .;
			oral_kcal = .;
			iv_kcal = .;
			prop_kcal = .;
			tot_insulin = . ;
			tot_ent_aa = .;
			tot_ent_kcal = .;
			tot_iv_kcal = .;
			pn_lipid = .;
			pn_cho = .;
			row = "Still hospitalized";
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
			if (deceased) & (days_until_death <= days_hosp_post_entry) then row = "Died in hospital";
			else row = "Discharged from hospital";
			
			tot_aa = .;
			tot_kcal = .;
			daily_kcal_goal = .;
			daily_aa_goal = .;
			tot_pn = .;
		  	pn_aa_g = .;
		 	pn_aa_kcal = .;
			tube_prot = .;
			tube_kcal  = .;
			oral_prot = .;
			oral_kcal = .;
			iv_kcal = .;
			prop_kcal = .;
			tot_insulin = . ;
			tot_ent_aa = .;
			tot_ent_kcal = .;
			tot_iv_kcal = .;
			pn_lipid = .;
			pn_cho = .;
			output;
		end;

		* reformat labels to drop question numbers;
		label 
       		tot_pn="Total infused PN"
       		oral_kcal="Oral food kcal"
       		pn_aa_g="PN AA (g)"
       		iv_kcal="IV fluids kcal"
       		pn_aa_kcal="PN AA kcal"
        		prop_kcal="Propofol kcal"
        		tube_prot= "Tube feeding prot. (g)"
        		tot_aa= "Total prot. (g)"
        		tube_kcal="Tube feeding kcal"
        		tot_kcal="Total kcal"
        		oral_prot="Oral food prot. (g)"
        		tot_insulin="Total insulin"
			pn_lipid = "PN lipid kcal"
			pn_cho = "PN CHO kcal"
		
			row = "Day"
			daily_kcal_goal = "Daily kcal goal"
			daily_aa_goal = "Daily prot. goal (g)"
			tot_ent_aa = "Total enteral prot. (g)"
			tot_ent_kcal = "Total enteral kcal "
			tot_iv_kcal = "Total IV kcal";

		drop 	 med_tot_aa med_tot_kcal; * don't need these anymore;



	/* PRINT nutrition tables to a pdf file*/

	options ls = 120 orientation = landscape;
	ods pdf file = "/glnd/sas/reporting/nutrition_tables.pdf";
	proc print data= nut_temp noobs label width=min;
		by id;
		title 'GLND Patient Nutrition Summary';
		var   row pn_aa_g pn_aa_kcal pn_lipid pn_cho iv_kcal prop_kcal tot_iv_kcal tube_prot tube_kcal oral_prot oral_kcal tot_ent_aa
				tot_ent_kcal tot_aa tot_kcal daily_aa_goal daily_kcal_goal ;
	run;
	ods pdf close;
/*
data glnd.nutritiontables;
 set sum_temp;
 run;
 */
 
options mprint symbolgen;
 %macro pr(id);
 ods pdf file="/glnd/sas/reporting/nut&id..pdf";
 proc print data= nut_temp noobs label width=min;
		by id;
		where id=&id;
		title "GLND Patient Nutrition Summary ID = &id";
		var   row pn_aa_g pn_aa_kcal pn_lipid pn_cho iv_kcal prop_kcal tot_iv_kcal tube_prot tube_kcal oral_prot oral_kcal tot_ent_aa
				tot_ent_kcal tot_aa tot_kcal daily_aa_goal daily_kcal_goal ;
	run; 
  ods pdf close;	
  %mend pr;
  %pr(11002);
  %pr(11004);
  %pr(11009);
  %pr(11012);
  %pr(12013);
	
 
run;
	
