%let pm=%sysfunc(byte(177));

		data  indiv_pn_tables;
		set glnd_rep.indiv_pn_tables  ;
		by id;

		if last.id then delete; * remove last observation, which contains the details of a patient's hospital data termination;
	run;
	
	
	data  indiv_pn_tables;
		merge 
			indiv_pn_tables (in = from_nut)
			glnd.george (keep = id treatment)
			glnd.plate11 (keep = id bod_weight); * sorted already;
		by id;


		* Give week assignment so that we can summarize by week in PROC MEANS;
		if day < 8 then week = 1;
		else if day < 15 then week = 2;
		else if day < 22 then week = 3;
		else if day < 29 then week = 4;

		* kcal per gram body weight ;
		overall_kcal_per_kg = tot_kcal / bod_weight;
		pn_kcal_per_kg = tot_parent_kcal / bod_weight;
		en_kcal_per_kg = tot_ent_kcal / bod_weight;

			* look at PN kcal composition individually - we can't look at overall food composition since we don't have this breakdown for EN ;
			pn_aa_kcal_per_kg = pn_aa_kcal / bod_weight;
			pn_cho_per_kg = pn_cho / bod_weight;
			pn_lipid_per_kg = pn_lipid / bod_weight;

		* grams AA per kilogram body weight ;
  		overall_aa_g_per_kg = tot_aa / bod_weight;
		pn_aa_g_per_kg = pn_aa_g / bod_weight;
		en_aa_g_per_kg = tot_ent_prot / bod_weight;


		label 
			overall_kcal_per_kg = "Overall kcal/kg"
			pn_kcal_per_kg = "PN kcal/kg"
			en_kcal_per_kg = "EN kcal/kg"

			pn_aa_kcal_per_kg = "PN kcal/kg, from AA"
			pn_cho_per_kg = "PN kcal/kg, from CHO"
			pn_lipid_per_kg = "PN kcal/kg, from lipid"

			overall_aa_g_per_kg	= "Overall AA g/kg"
			pn_aa_g_per_kg = "PN AA g/kg"
			en_aa_g_per_kg = "EN AA g/kg"
			treatment="Treatment"

			;

	run;


	title"";

%macro get_medians (var = , class = , where =, first_var =, row = , cat =, item_no =);
	proc means data = indiv_pn_tables fw=5 maxdec=1 nonobs n mean stddev median min max ;
		class treatment &class;
		where &where;
		var &var;
		*ods output summary = &var ;
		output out = &var mean(&var)=avg stddev(&var)=std median(&var) = median n(&var) = n min(&var) = min max(&var) = max q1(&var) = q1 q3(&var) = q3 ;
	run;

	data &var;
		set &var;

		length row $ 40;
		length category $ 40;

		where _TYPE_ = 3;

		* add row headers ;
		row = &row;
		category = &cat;

		item_no = &item_no;
	run;
	
		* stack results;
		data outcome_table;
			%if &var = &first_var %then %do;
				set &var;
			%end;
			%else %do;
				set outcome_table
				&var;
			%end;

		run;
	

%mend get_medians;



** Percents of goal met and PN composition, on specific study days: ** ;
%get_medians(var = percent_overall, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal administered", cat = "Kcal goal", item_no = 1);
%get_medians(var = percent_parenteral, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal given parenterally", cat = "Kcal goal", item_no = 2);
%get_medians(var = percent_enteral, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal given enterally", cat = "Kcal goal", item_no = 3);

%get_medians(var = percent_overall_prot, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal administered", cat = "Protein goal", item_no = 4);
%get_medians(var = percent_parenteral_prot, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal given parenterally", cat = "Protein goal", item_no = 5);
%get_medians(var = percent_enteral_prot, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % of goal given enterally", cat = "Protein goal", item_no = 6);

%get_medians(var = percent_iv_aa, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % AA", cat = "PN composition", item_no = 7);
%get_medians(var = percent_iv_dextrose, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % Dextrose", cat = "PN composition", item_no = 8);
%get_medians(var = percent_iv_lipid, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % Lipid", cat = "PN composition", item_no = 9);
%get_medians(var = percent_enteral, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- % Enteral Kcal", cat = "PN composition", item_no = 10);

* kcal composition;
%get_medians(var = overall_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- overall", cat = "Kcal per kg", item_no = 11);
%get_medians(var = pn_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given parenterally: Overall", cat = "Kcal per kg", item_no = 12);

%get_medians(var = pn_aa_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from AA", cat = "Kcal per kg", item_no = 13);
%get_medians(var = pn_cho_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from CHO", cat = "Kcal per kg", item_no = 14);
%get_medians(var = pn_lipid_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from lipid", cat = "Kcal per kg", item_no = 15);

%get_medians(var = en_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given enterally", cat = "Kcal per kg", item_no = 16);

* grams of AA;
%get_medians(var = overall_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- overall", cat = "Grams of AA per kg", item_no = 17);
%get_medians(var = pn_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given parenterally", cat = "Grams of AA per kg", item_no = 18);
%get_medians(var = en_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given enterally", cat = "Grams of AA per kg", item_no = 19);

* composition by week ;
	*kcal;
	%get_medians(var = overall_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- overall", cat = "Kcal per kg", item_no = 20);
	%get_medians(var = pn_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- given parenterally: Overall", cat = "Kcal per kg", item_no = 21);
	%get_medians(var = en_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- given enterally", cat = "Kcal per kg", item_no = 22);

	* AA;
	%get_medians(var = overall_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- overall", cat = "Grams of AA per kg", item_no = 23);
	%get_medians(var = pn_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- given parenterally", cat = "Grams of AA per kg", item_no = 24);
	%get_medians(var = en_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- given enterally", cat = "Grams of AA per kg", item_no = 25);

proc sort; by item_no day treatment;run;


* process for printing ;
	data outcome_table;
			set outcome_table;

		by category row notsorted;
		
		length disp_visit $ 8;
		length disp_median $ 25;
		length disp_mean $ 25;
		length disp_range $ 20;
		length disp_n $ 3;

		* add line with title at beginning of category;
		if first.category then do;
			old_row = row;
			row = category; * temporarily change the row title to the category name, simulating a title ;
			disp_visit = '00'x;
			treatment=.;
			disp_median = '00'x;
			disp_mean = '00'x;
			disp_n = '00'x;
			disp_range = '00'x;
			output;
			if first.row then treatment=1;
        	row = old_row;			* reset the row title to what it should be;
		end;

		* set up columns for display ;
			if item_no < 20 then disp_visit = "Day " || compress(put(day, 2.)); * make a text field of visit so that it can be made blank;
			else if item_no >= 20 then disp_visit = "Week " || compress(put(week, 2.));

			disp_median = compress(put(median, 5.1)) || " (" || compress(put(q1, 5.1)) || ", " || compress(put(q3, 5.1)) || ")";
			disp_mean = compress(put(avg, 5.1)) || "&pm" || compress(put(std, 5.1)) ;
			disp_n = compress(put(n, 4.0));
			disp_range = "[" || compress(put(min, 5.1)) || " - " || compress(put(max, 5.1)) || "]";

		output;

		* add blank line at end of category;
		
        
		if last.row then do;
			category = category;
			row = row;
			disp_visit = '00'x;
			treatment=.;			
			disp_median = '00'x;
			disp_mean = '00'x;
			disp_n = '00'x;
			disp_range = '00'x;
			output;
			

		end;


		label 	row ='00'x
				category = '00'x
				disp_visit = '00'x
				disp_median = "median (Q1, Q3)"
				disp_mean = "mean &pm std"
				disp_n = "n"
				disp_range = "[min - max]"
				;
	run;
	
* output tables to PDF on separate pages;
options nodate nonumber orientation = portrait;

ods rtf file="kcal_aa_goal_summary_trt.rtf" style=journal bodytitle;
ods pdf file = "kcal_aa_goal_summary_trt.pdf" style = journal;
ods ps file= "kcal1.ps" style=journal;
	title1 "Percent of kcal and protein goals administered"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 1 <= item_no < 7;
		id row ;
		by row notsorted;
		var disp_visit treatment ;
		var disp_mean disp_median disp_range disp_n /style(data) = [just=center];;
	run;
ods ps close;
ods ps file ="kcal2.ps" style=journal;
	title1 "PN composition"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 7 <= item_no <= 10;
		id row ;
		by row notsorted ;
		var disp_visit treatment;
		var disp_mean disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;
ods ps file ="kcal3.ps" style=journal;
 	title1 "kcal administered (per kg)"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 10 < item_no < 17;
		id row ;
		by row notsorted;
		var disp_visit treatment;
		var disp_mean disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;
ods ps file ="kcal4.ps" style=journal;
 	title1 "AA administered (g per kg)"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 17 <= item_no < 20;
		id row ;
		by row notsorted;
		var disp_visit treatment;
		var disp_mean disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;
ods pdf close;
ods rtf close;
