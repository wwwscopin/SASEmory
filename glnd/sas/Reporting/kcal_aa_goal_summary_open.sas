* PRODUCE SUMMARIES OF KCAL AND AA GOALS, ADMINISTERED AMOUNTS, PN COMPOSITION;

* modify dataset ;

	data  indiv_pn_tables;
		set glnd_rep.indiv_pn_tables  ;
		by id;

		if last.id then delete; * remove last observation, which contains the details of a patient's hospital data termination;
	run;
	
	data  indiv_pn_tables;
		merge 
			indiv_pn_tables (in = from_nut)
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

			;

	run;

	title"";

%macro get_medians (var = , class = , where =, first_var =, row = , cat =, item_no =);
	proc means data = indiv_pn_tables fw=5 maxdec=1 nonobs n mean stddev median min max ;
		class &class;
		where &where;
		var &var;
		*ods output summary = &var ;
		output out = &var median(&var) = median n(&var) = n min(&var) = min max(&var) = max q1(&var) = q1 q3(&var) = q3 ;
	run;

	data &var;
		set &var;

		length row $ 40;
		length category $ 40;

		where _TYPE_ = 1;

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

* kcal composition;
%get_medians(var = overall_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- overall", cat = "Kcal per kg", item_no = 10);
%get_medians(var = pn_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given parenterally: Overall", cat = "Kcal per kg", item_no = 11);

%get_medians(var = pn_aa_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from AA", cat = "Kcal per kg", item_no = 12);
%get_medians(var = pn_cho_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from CHO", cat = "Kcal per kg", item_no = 13);
%get_medians(var = pn_lipid_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "--- given parenterally: from lipid", cat = "Kcal per kg", item_no = 14);

%get_medians(var = en_kcal_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given enterally", cat = "Kcal per kg", item_no = 15);

* grams of AA;
%get_medians(var = overall_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- overall", cat = "Grams of AA per kg", item_no = 16);
%get_medians(var = pn_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given parenterally", cat = "Grams of AA per kg", item_no = 17);
%get_medians(var = en_aa_g_per_kg, class = day, where =  day in (1, 7, 14, 21 28), first_var = percent_overall, row = "- given enterally", cat = "Grams of AA per kg", item_no = 18);

* composition by week ;
	*kcal;
	%get_medians(var = overall_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- overall", cat = "Kcal per kg", item_no = 19);
	%get_medians(var = pn_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- given parenterally: Overall", cat = "Kcal per kg", item_no = 20);
	%get_medians(var = en_kcal_per_kg, class = week, where = , first_var = percent_overall, row = "- given enterally", cat = "Kcal per kg", item_no = 21);

	* AA;
	%get_medians(var = overall_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- overall", cat = "Grams of AA per kg", item_no = 22);
	%get_medians(var = pn_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- given parenterally", cat = "Grams of AA per kg", item_no = 23);
	%get_medians(var = en_aa_g_per_kg, class = week, where = , first_var = percent_overall, row = "- given enterally", cat = "Grams of AA per kg", item_no = 24);


* process for printing ;
	data outcome_table;
			set outcome_table;

		by category row notsorted;
		
		length disp_visit $ 8;
		length disp_median $ 25;
		length disp_range $ 20;
		length disp_n $ 3;

		* add line with title at beginning of category;
		if first.category then do;
			old_row = row;
			row = category; * temporarily change the row title to the category name, simulating a title ;
			disp_visit = '00'x;
			disp_median = '00'x;
			disp_n = '00'x;
			disp_range = '00'x;
			output;

			row = old_row;			* reset the row title to what it should be;
		end;

		* set up columns for display ;
			if item_no < 19 then disp_visit = "Day " || compress(put(day, 2.)); * make a text field of visit so that it can be made blank;
			else if item_no >= 19 then disp_visit = "Week " || compress(put(week, 2.));

			disp_median = compress(put(median, 5.1)) || " (" || compress(put(q1, 5.1)) || ", " || compress(put(q3, 5.1)) || ")";
			disp_n = compress(put(n, 4.0));
			disp_range = "[" || compress(put(min, 5.1)) || " - " || compress(put(max, 5.1)) || "]";

		output;

		* add blank line at end of category;
		if last.row then do;
			category = category;
			row = row;
			disp_visit = '00'x;
			disp_median = '00'x;
			disp_n = '00'x;
			disp_range = '00'x;
			output;
			

		end;


		label 	row ='00'x
				category = '00'x
				disp_visit = '00'x
				disp_median = "median (Q1, Q3)"
				disp_n = "n"
				disp_range = "[min - max]"
				;
	run;

* output tables to PDF on separate pages;
options nodate nonumber orientation = portrait;

ods pdf file = "kcal_aa_goal_summary_open.pdf" style = journal;
ods ps file= "kcal1.ps" style=journal;
	title1 "Percent of kcal and protein goals administered"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 1 <= item_no < 7;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;
ods ps close;
ods ps file ="kcal2.ps" style=journal;
	title1 "PN composition"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 7 <= item_no < 10;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;
ods ps file ="kcal3.ps" style=journal;
 	title1 "kcal administered (per kg)"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 10 <= item_no < 16;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;
ods ps file ="kcal4.ps" style=journal;
 	title1 "AA administered (g per kg)"; 
	title2 "at specific days";
	proc print data = outcome_table label noobs;
		where 16 <= item_no < 19;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;

ods ps close;

 options orientation=landscape;


ods ps file ="kcal5.ps" style=journal;
/**** KIRK RULED OUT PRESENTING THE WHOLE WEEK PLOTS AS REDUNDANT
 	title1 "kcal administered (per kg)"; 
	title2 "during whole weeks";
	proc print data = outcome_table label noobs;
		where 19 <= item_no < 22;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;

 	title1 "AA administered (g per kg)"; 
	title2 "during whole weeks";
	proc print data = outcome_table label noobs;
		where 22 <= item_no < 25;
		id row ;
		by row notsorted;
		var disp_visit ;
		var disp_median disp_range disp_n /style(data) = [just=center];;
	run;
 
****/


	* MAKE BOXPLOTS ;

	%macro get_n;
	* get 'n' at each day;
		proc means data=indiv_pn_tables noprint;
			class day;
			var percent_parenteral;
			output out = num n(percent_parenteral) = num_obs;
		run;

		* populate 'n' annotation variables ;
		%do i = 0 %to 28;
			data _null_;
				set num;
				where day = &i;
				call symput( "n_&i",  compress(put(num_obs, 3.0)));
			run;
		%end;

		proc format; 
			value day_glnd 
				1 = "1*(&n_1)" 7 = "7*(&n_7)" 14 = "14*(&n_14)"	 21 = "21*(&n_21)" 28 = "28*(&n_28)" 
				 
				
				0,2,3,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,22,23,24,25,26,27,29 = " "
				;
		run;
	%mend get_n;
	
	%get_n run;


	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
 

        
		goptions reset=all device=jpeg rotate=landscape gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;
  		
 
		* % of protein goal given perenterally;

			* add jitter ;
			data pn_box;
				set indiv_pn_tables;
				where day in (1, 7, 14, 21 28);

				day2= (day - .2) + .4*uniform(3654);
			run;	

			title1 f=zapfb h=4 justify=center "Percent of kcal goal given parenterally";
			title2; 

		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=1.3) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
		axis2 	label=(f=zapf h=4 a=90 "Percent (%)" ) 	value=(f=zapf h=3) 
					order= (0 to 150 by 25) 	major=(h=1.5 w=2) minor=(number=4 h=1);
	
		
		symbol1 interpol=boxt0 mode=exclude repeat = 1 value=none co=black cv=black height=.6 bwidth=3 width=3;
		symbol2 ci=blue value=dot h=1;
			proc gplot data= pn_box gout= glnd_rep.graphs;
				plot percent_parenteral*day   percent_parenteral*day2   /overlay haxis = axis1 vaxis = axis2   nolegend;

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
				format day day2 day_glnd. percent_parenteral 3.;
			run;	
ods ps close;


ods pdf close;

quit;

 		filename output 'kcal5.eps';
        goptions device=pslepsfc gsfname=output gsfmode=replace;
        proc gplot data= pn_box gout= glnd_rep.graphs;
				plot percent_parenteral*day   percent_parenteral*day2   /overlay haxis = axis1 vaxis = axis2   nolegend;

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
				format day day2 day_glnd. percent_parenteral 3.;
		run;
        
        

* produce listing of %kcal given enterally and parenterally ;

ods pdf file = "/glnd/sas/reporting/kcal_print.pdf" style = journal;

	proc sort data = indiv_pn_tables; by center percent_parenteral descending id; run;
	
		proc print data=indiv_pn_tables label noobs ;
			title "% of kcal goal given - Day 1";
			by center;
			where day = 1;
			var id percent_overall percent_parenteral percent_enteral;
		run;
ods pdf close;

** OLD! **;
/*******
* get within person medians ;
	proc means data = indiv_pn_tables maxdec = 1 fw = 5 n median q1 q3;
		class id;
		var  
				percent_parenteral percent_enteral percent_overall 
				percent_iv_aa percent_iv_dextrose percent_iv_lipid
				pn_aa_kcal_per_kg pn_cho_per_kg pn_lipid_per_kg 
				percent_parenteral_prot percent_enteral_prot percent_overall_prot ;

		output out = within_person_stats 
			median(percent_parenteral percent_enteral percent_overall 
				percent_iv_aa percent_iv_dextrose percent_iv_lipid
				pn_aa_kcal_per_kg pn_cho_per_kg pn_lipid_per_kg 
				percent_parenteral_prot percent_enteral_prot percent_overall_prot) = 

				percent_parenteral_med percent_enteral_med percent_overall_med 
				percent_iv_aa_med percent_iv_dextrose_med percent_iv_lipid_med
				pn_aa_kcal_per_kg_med pn_cho_per_kg_med pn_lipid_per_kg_med 
				percent_parenteral_prot_med percent_enteral_prot_med percent_overall_prot_med;
	run;

	data within_person_stats;
		set within_person_stats (rename = (_FREQ_ = total_days));
		where _TYPE_ = 1;
		drop _TYPE_;
	run;




* give table by days of interest ;
	title1 "Proportion of kcal and AA goal met";
	title2 "At key days";
	proc means data = indiv_pn_tables maxdec = 1 fw = 5 n median q1 q3 min max ;
		class day;
		where day in (1, 7, 14, 21 28);
		var  
				percent_overall percent_enteral	percent_parenteral 
				percent_iv_aa percent_iv_dextrose percent_iv_lipid
				percent_overall_prot percent_parenteral_prot percent_enteral_prot  ;
	run;


	* ;
	title1 "Median kcal and grams of AA: total, PN, EN";
	title2 "At key days";
	proc means data = indiv_pn_tables maxdec = 1 fw = 5 n median q1 q3;
		class day;
		where day in (1, 7, 14, 21 28);
		var  
			overall_kcal_per_kg 	pn_kcal_per_kg 		
			pn_aa_kcal_per_kg 	pn_cho_per_kg	pn_lipid_per_kg
			en_kcal_per_kg
			overall_aa_g_per_kg 	pn_aa_g_per_kg 		en_aa_g_per_kg 
			  
;
	run;

	
	title1 "Median kcal and grams of AA: total, PN, EN";
	title2 "For each week";
	proc means data = indiv_pn_tables maxdec = 1 fw = 5 n median q1 q3;
		class week;
		var  
			overall_kcal_per_kg 	pn_kcal_per_kg 		
			pn_aa_kcal_per_kg 	pn_cho_per_kg	pn_lipid_per_kg
			en_kcal_per_kg
			overall_aa_g_per_kg 	pn_aa_g_per_kg 		en_aa_g_per_kg 
			 ;
	run;







*********** FIX MEDIANS TO BE WITHIN PEOPLE FIRST THEN ACROSS PEOPLE!!!! ****************88;

proc means data = indiv_pn_tables maxdec = 1 fw = 5 n median q1 q3 min max ;
		class day;
		where day in (1, 7, 14, 21 28);
		var  
				percent_overall percent_enteral	percent_parenteral 
				percent_iv_aa percent_iv_dextrose percent_iv_lipid
				percent_overall_prot percent_parenteral_prot percent_enteral_prot  ;
	run;


*/


