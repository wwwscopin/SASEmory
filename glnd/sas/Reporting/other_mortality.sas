/* other_mortality.sas 
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

proc sort data = glnd.apache_sicu; by id; run;


* classify deaths in-hospital and at 28-day;
data other_mortality;
	set glnd.status ;

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
		glnd.demo_his	(keep = id race hispanic gender dt_birth)
		 glnd.apache_sicu (keep = id apache_total_sicu);
	by id;
	
	if apache_total_sicu <= 25 then apache_sicu_cat = 1; 
	else if apache_total_sicu > 25 then apache_sicu_cat = 2;
	if apache_total_sicu = . then apache_sicu_cat = .;

	age_years = (dt_random - dt_birth) / 365.25;
	
	* approximate quartiles: ;
	if age_years <= 50 then age_cat = 1;
	else if age_years <= 60 then age_cat = 2;
	else if age_years <= 70 then age_cat = 3;
	else age_cat = 4;
	
	if age_years = . then age_cat = .;
	
	
	 
run;

proc print data = other_mortality;
	var age_years;
run;

proc means data = other_mortality n mean median q1 q3;
	var age_years apache_total_sicu;	
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
	
		length row $ 40;
		length category $ 40;
		
		%if &var ~= center  %then %do;
			 where _TYPE_ = 1; 	
		%end;
		
		
		/*
		%if (&first = 1)  %then %do;
			
		%end;*/
		
		
		
		* add row headers ;
		row = trim(put(&var, &format.));
		category = &cat;

		* if this is the first group (center) so make an overall row;
		
		if _TYPE_ = 0 then do;  row = "---"; category = "Overall"; end;
				
		drop &var;
		 /********* LEFT OFF HERE ON 9/4/09! NEED TO STILL WORK IN REST OF ACR_SUMMARY MACRO AND FILE **********/
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

proc format library = library;

	value median_sicu_hosp
		/*1 = "<= 25 (lower 50%)"
		2 = "> 25 (upper 50%)"*/
		1 = "<= 25 "
		2 = "> 25 "
		;

run;

* BUILD TABLE OF MORTALITY x STRATA;
%get_sums(var = center, cat ="Center", format = center.);
%get_sums(var = apache_2, cat = "APACHE II", format = apache_other.);
%get_sums(var = race, cat = "Race", format = race.);
%get_sums(var = hispanic, cat ="Hispanic", format = yn.);
%get_sums(var = gender, cat= "Gender", format = gender.);
%get_sums(var = age_cat, cat= "Age", format = age_cat.);
%get_sums(var = apache_sicu_cat, cat= "APACHE II - SICU entry", format = median_sicu_hosp.);





	* process for printing ;
		data mort_table;
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
			if (last.category) & (category ~= "APACHE II - SICU entry") then do;
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



* add vertical line ;

data mort_table;
	set mort_table;
	
	vline = "|";
	
	label vline = '00'x;
run;



* output table to PDF;
options nodate nonumber orientation = portrait;
ods ps file = "/glnd/sas/reporting/mortopen.ps" style=journal;
	title "GLND Mortality Summary"; 
	proc print data = mort_table label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased vline disp_hospital_death vline disp_day_28_death /style(data) = [just=center];;
		
	run;
ods ps close;

