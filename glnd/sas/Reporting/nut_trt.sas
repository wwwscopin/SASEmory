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
			row = "PN administered prior to enrollment               ";
			yes = put(parent_nutr_s, 3.) || "/" || left(put(id_n, 3.));
			pct = (parent_nutr_s / id_n)*100; 
			median = parent_nutr_days_med;
			min = parent_nutr_days_min;
			max = parent_nutr_days_max;
			output;
		* row 2;
			row = "Enteral nutrition administered prior to enrollment";
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
	
		row = "Days to first enteral nutrition administered";		
		
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
			tube_kcal=.; oral_kcal=.;
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
			tube_kcal=.; oral_kcal=.;
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
			oral_kcal=.; tube_kcal=.;
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
			tube_kcal="TF kcal"
			oral_kcal="Oral kcal"
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

data percent_pn;
    merge percent_pn glnd.george (keep = id treatment); by id;
    tot_pn_kcal=tot_kcal-tot_ent_kcal;
    tot_pn_prot=tot_aa-tot_ent_prot;
    label tot_pn_kcal="Tot PN kcal"
    tot_pn_prot="PN AA /Prot (g)";
run;
proc sort; by treatment id day;run;

data  percent_pn;
    set percent_pn; by treatment id day;
    if day<=7 then wk=1;
        else if 7<day<=14 then wk=2;
        else if 14<day<=21 then wk=3;
run;

proc means data=percent_pn n mean std stderr median maxdec=1;
class treatment;
var pn_aa_kcal pn_aa_g tot_ent_kcal tot_pn_kcal tot_ent_prot tot_pn_prot;
run;

proc means data=percent_pn n mean std stderr median maxdec=1;
class treatment wk;
var pn_aa_kcal pn_aa_g tot_ent_kcal tot_pn_kcal tot_ent_prot tot_pn_prot;
run;
