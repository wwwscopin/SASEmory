/* other_mortality_closed.sas 
 *
 * produce a table reporting mortality in-hosp
 *
 */

proc means data= glnd.status n;
	var id;
	output out= n_patients n(id)= n_patients;
run;
data n_patients;
	set n_patients;
	keep n_patients;
run;





%macro get_sums (var = , cat =, format = );
	proc means data = other_mortality fw=5 maxdec=1 nonobs n sum noprint;
		class &var;
		var deceased hospital_death day_28_death;
		output out = &var sum(deceased hospital_death day_28_death) = 
			deceased_s hospital_death_s day_28_death_s n(deceased) = denominator;

	run;
	
	data &var;
		set &var;


		length category $ 40;
		












		* add row headers ;
		row = trim(put(&var, &format.));
		category = &cat;


		
		if _TYPE_ = 0 then do;  row = "---"; category = "Overall"; end;
				


	run;
	
	
		* stack results;
		data mort_table;
			%if &var = center %then %do;
				set &var;
			%end;
			%else %do;
				set mort_table
				&var;
			%end;

		run;

%mend get_sums;




%macro death_ab;

%do x = 1 %to 3; * done three times since last is overall to ensure that all lines are full;

* classify deaths in-hospital and at 28-day;
data other_mortality;
	set glnd.status ;

	where treatment = &x;

	if deceased & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;

	if deceased & ((dt_death - dt_random) <= 28) then day_28_death = 1; else day_28_death = 0;	  

	center = floor(id/10000);

	if (id = 32175) then hospital_death = 1; ** correction on 3/06/09 because we do not yet have hospital release date **;

	format center center.;
run;

proc sort data = glnd.demo_his; by id; run;

* add in factors to stratify upon ;
data other_mortality;
	merge 	other_mortality
		glnd.demo_his	(keep = id race hispanic gender dt_birth);
	by id;
	
	age_years = (dt_random - dt_birth) / 365.25;
	
	 
run;



* BUILD TABLE OF MORTALITY x STRATA;
%get_sums(var = center, cat ="Center", format = center.);
%get_sums(var = apache_2, cat = "APACHE II", format = apache_other.);
%get_sums(var = race, cat = "Race", format = race.);
%get_sums(var = hispanic, cat ="Hispanic", format = yn.);
%get_sums(var = gender, cat= "Gender", format = gender.);


proc print data = mort_table;
run;



	* process for printing ;
		data mort_table_&x;
				set mort_table;

			by category row notsorted;
			
			length disp_deceased $ 20;
			length disp_hospital_death $ 20;
			length disp_day_28_death $ 20;
			
			/*
			* add line with title at beginning of category;
			if first.category then do;
				old_row = row;
				row = category; * temporarily change the row title to the category name, simulating a title ;
				disp_deceased = '00'x;
				disp_hospital_death = '00'x;
				disp_day_28_death = '00'x;
				output;

				row = old_row;			* reset the row title to what it should be;
			end;
			*/

			* set up columns for display ;
				disp_deceased = compress(put(deceased_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((deceased_s/denominator)*100, 4.1)) || "%)" ; 
				disp_hospital_death = compress(put(hospital_death_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((hospital_death_s/denominator)*100, 4.1)) || "%)" ; 
				disp_day_28_death = compress(put(day_28_death_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((day_28_death_s/denominator)*100, 4.1)) || "%)" ; 
			
			output;

			* add blank line at end of category;
			if (last.category) & (category ~= "Gender") then do;
				category = category;
				row = '00'x;
				disp_deceased = '00'x;
				disp_hospital_death = '00'x;
				disp_day_28_death = '00'x;
				output;
				

			end;


			label 	row ='00'x
					category = '00'x
					disp_deceased = '6-month'
					disp_hospital_death = 'In-hospital'
					disp_day_28_death = '28-Day'
					;
			run;

%mend death_ab;

%death_ab run;



* add vertical line ;

data mort_table;
	set mort_table;
	
	vline = "|";
	
	label vline = '00'x;
run;


* output table to PDF;
options nodate nonumber orientation = portrait;
ods pdf file = "/glnd/sas/reporting/other_mortality_open.pdf" style=journal;
	title "GLND Mortality Summary"; 
	proc print data = mort_table_1 label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased vline disp_hospital_death vline disp_day_28_death /style(data) = [just=center];;
	run;
	
	proc print data = mort_table_2 label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased vline disp_hospital_death vline disp_day_28_death /style(data) = [just=center];;
	run;
	
	proc print data = mort_table_3 label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased vline disp_hospital_death vline disp_day_28_death /style(data) = [just=center];;
	run;
ods pdf close;
