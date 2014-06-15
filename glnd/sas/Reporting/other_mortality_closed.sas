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
	
		length row $ 40;
		length category $ 40;
		
		%if &var ~= center  %then %do;
			 where _TYPE_ = 1; 	
		%end;
		* add row headers ;
		row = trim(put(&var, &format.));
		category = &cat;

		* if this is the first group (center) so make an overall row;
		
		if _TYPE_ = 0 then do;  row = "---"; category = "Overall"; end;
				
		drop &var;
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

%do x = 1 %to 2;

* classify deaths in-hospital and at 28-day;
data other_mortality;
	set glnd.status ;

	where treatment = &x;

	if deceased & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;

	if deceased & ((dt_death - dt_random) <= 28) then day_28_death = 1; else day_28_death = 0;	  

	center = floor(id/10000);

	* if (id = 32175) then hospital_death = 1; ** correction on 3/06/09 because we do not yet have hospital release date **;

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
	

	age_years = (dt_random - dt_birth) / 365.25;
	
	* approximate quartiles: ;
	if age_years <= 50 then age_cat = 1;
	else if age_years <= 60 then age_cat = 2;
	else if age_years <= 70 then age_cat = 3;
	else age_cat = 4;
	
	if age_years = . then age_cat = .;
	
	
	 
run;

proc format library = library;

	value median_sicu_hosp
		1 = "<= 25 (lower 50%)"
		2 = "> 25 (upper 50%)"
		;

run;

* BUILD TABLE OF MORTALITY x STRATA;
%get_sums(var = center, cat ="Center", format = center.);
%get_sums(var = apache_2, cat = "APACHE II", format = apache_other.);
%get_sums(var = race, cat = "Race", format = race.);
%get_sums(var = hispanic, cat ="Hispanic", format = yn.);
%get_sums(var = gender, cat= "Gender", format = gender.);
%get_sums(var = age_cat, cat= "Age", format = age_cat.);
%get_sums(var = apache_sicu_cat, cat= "APACHE II-SICU", format = median_sicu_hosp.);


proc print data = mort_table;
run;



	* process for printing ;
		data mort_table_&x;
				set mort_table;

			by category row notsorted;
			
			length disp_deceased $ 20;
			length disp_hospital_death $ 20;
			length disp_day_28_death $ 20;
			


			* set up columns for display ;
				disp_deceased = compress(put(deceased_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((deceased_s/denominator)*100, 4.1)) || "%)" ; 
				disp_hospital_death = compress(put(hospital_death_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((hospital_death_s/denominator)*100, 4.1)) || "%)" ; 
				disp_day_28_death = compress(put(day_28_death_s, 3.0)) || "/" || compress(put(denominator, 3.0)) || " (" || compress(put((day_28_death_s/denominator)*100, 4.1)) || "%)" ; 
			
			output;

			** ADDED FOR MARCH 2010 REPORT:	Wisconsin isnt balanced between A and B. This adds an extra line for trt B, so that we dont need a third overall cycle of the loop;
			if (last.category) & (category = "Center") & (compress(row) ~= "Wisconsin") then do;
				category = category;
				row = 'Wisconsin';
				disp_deceased = '00'x;
				disp_hospital_death = '00'x;
				disp_day_28_death = '00'x;
				output;
			end;

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

	data mort_table_&x;
		set mort_table_&x;
		
		order = _N_; * works when number of lines is the same for both tables, which is currently true. otherwise, need to do loop a third time for an overall group;
		vline = "|";
	
		label vline = '00'x;
	run;

	%end;
%mend death_ab;

%death_ab run;


* merge a and b;

	data mort_table_ab;
		merge 
			mort_table_1 (rename = (disp_deceased= disp_deceased_a 	disp_hospital_death  = disp_hospital_death_a 	disp_day_28_death= disp_day_28_death_a))
			mort_table_2 (drop = category row rename = (disp_deceased= disp_deceased_b 	disp_hospital_death  = disp_hospital_death_b 	disp_day_28_death= disp_day_28_death_b))
		;
		by order;
	run;


* output table to PDF;
options nodate nonumber orientation = portrait;
ods ps file = "omclosed.ps" style=journal;
ods rtf file="omclosed.rtf";
	title "GLND Mortality Summary"; 
	proc print data = mort_table_ab label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased_a disp_hospital_death_a disp_day_28_death_a vline disp_deceased_b disp_hospital_death_b disp_day_28_death_b /style(data) = [just=center];;
		
		label
			disp_hospital_death_a = "A*In-hospital"
			disp_hospital_death_b = "B*In-hospital"
			;
	run;
ods rtf close;
ods ps close;

data mort;
   set mort_table_ab;
   if _n_ <= 10;

ods ps file = "omclosed_geo.ps" style=journal;

	title "GLND Mortality Summary"; 
	proc print  label noobs split = "*" style(header) = [just=center];
		
		id  category row;
		by  category notsorted;

		var disp_deceased_a disp_hospital_death_a disp_day_28_death_a vline disp_deceased_b disp_hospital_death_b disp_day_28_death_b /style(data) = [just=center];;
		
		label
			disp_hospital_death_a = "A*In-hospital"
			disp_hospital_death_b = "B*In-hospital"
			;
	run;
ods ps close;
