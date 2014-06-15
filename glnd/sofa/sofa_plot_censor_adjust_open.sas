/* sofa_plot_censor_adjust_open.sas
 *
 * For all patients, plot total sofa scores longitudinally and draw boxplots. 
 * Annotate with sample sizes at each day (SOFA scores are recordable when a patient
 * is in the SICU)
 *
 * This version was created (2/5/2010) per the DSMB recommendations to keep people who leave the SICU or die by assigning them a min or max score (0 if leave SICU, 24 if die)
 *
 */

* The first, new thing we need to do is make a dataset with 28 days for each person on study, indicating whether or not they were in the SICU that day;

	* read in SICU in/out log for people in the SICU multiple times ;
	data icu_multi_days;
		set glnd.plate49;
		where (SICU_inter_start_day_1 ~= .) | (SICU_readmit_day_2 ~= .) |(SICU_readmit_day_3 ~= .) |(SICU_readmit_day_4 ~= .)|(SICU_readmit_day_5 ~= .); * include only if they have some readmit data ;
	run;

	proc sort data= icu_multi_days; by id; run;
	proc sort data= glnd.status; by id; run;

	* Add hospital information;
	data icu_status_28;
		merge 	icu_multi_days (in = has_multi)	
				glnd.status (keep = id dt_random dt_leave_sicu mortality_28d days_sicu_prior dt_death deceased)
				;
		by id;

		multi_sicu = has_multi;
		
		died_in_sicu = 0;

		do day = 1 to 28;
			
			this_date = dt_random + day - 1; 	* record date of this person's study day ;

			* figure out on-off SICU days for people with multiple SICU stays;

			if has_multi then do;
				if 	(dt_random <= this_date <= SICU_inter_start_day_1) |
					(SICU_readmit_day_2 <= this_date <= SICU_inter_start_day_2) |	
					(SICU_readmit_day_3 <= this_date <= SICU_inter_start_day_3) |	
					(SICU_readmit_day_4 <= this_date <= SICU_inter_start_day_4) |	
					(SICU_readmit_day_5 <= this_date <= SICU_inter_start_day_5) 
				then in_SICU = 1;
			
				else in_SICU = 0;	
			end;

			** people with just one stay in the SICU;
			else do;
				if (dt_random <= this_date <= dt_leave_sicu) then in_SICU = 1;
				else in_SICU = 0;
			end;
			
			* figure out if people died in the SICU and keep the value for the rest of the records until day 28 ;
			if in_SICU and (dt_death = this_date) then died_in_sicu = 1;

			output;
		end;

		format this_date mmddyy. in_SICU yn.;
	run;

	proc print data = icu_status_28;
		var id day this_date multi_sicu dt_random  dt_leave_SICU  SICU_inter_start_day_1 SICU_readmit_day_2 SICU_inter_start_day_2 in_SICU dt_death died_in_sicu;
	run;


options pagesize= 60 linesize = 85 center nodate nonumber;

proc sort data = icu_status_28; by id day; run;
proc sort data = glnd.followup_all_long; by id day; run;

data sofa;
	merge 
		icu_status_28
		glnd.followup_all_long;
	by id day;

	day2= (day - .2) + .4*uniform(3654);

	* for people that are not in the SICU, assign them min and max SOFA scores! ;

	if died_in_sicu then sofa_tot = 24; * this person died in the SICU and should get a max score this day onward;
	else if ~in_sicu then sofa_tot = 0;	* discharged alive from the sicu;
run;

* check that the n at each day is the same. this may change if SOFA is missing on a day that a person is in the SICU;
	proc means data = sofa n;
		class day;
		var id;
	run;

* LEFT OFF HERE: test that plots have all people for 28 days, and that min and max are appropriately calculated using a PROC PRINT;

proc sort data = sofa; by id day; run;
proc sort data = glnd.status; by id; run;


proc sort data=sofa;by day id; run;
proc print data= sofa; var day day2 id sofa_tot; run;

/* Load sample sizes for each day into macro variables, for plot annotation */
	* initialize the macro variables to store the sample sizes OUTSIDE of macro;
	* in order to set the scope to global ;
		%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0;
		%let n_6= 0; %let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;
		%let n_11= 0; %let n_12= 0; %let n_13= 0; %let n_14= 0; %let n_15= 0;
		%let n_16= 0; %let n_17= 0; %let n_18= 0; %let n_19= 0; %let n_20= 0;
		%let n_21= 0; %let n_22= 0; %let n_23= 0; %let n_24= 0; %let n_25= 0;
		%let n_26= 0; %let n_27= 0; %let n_28= 0; 


	* obtain n's for each day;
		proc means data= sofa noprint;
			class day;
			var sofa_tot;
			output out = sizes n(sofa_tot) = num_obs max(day) = last_day;	* if alive and in SICU but missing the SOFA info, that will affect the total sample size;
		run;
	* trim initial record and get last day ;
		data sizes; 
			set sizes;

			if (day = .) then do;
				call symput("last_day", trim(put(last_day, 3.0))); * save the last day for which we have observations;
				delete;
			end;
		run;
	
	* loop through the n's from proc means, for all days that we have observations;
		%macro get_sizes;
			%do i = 1 %to &last_day;
				data _null_;
					set sizes;
					where day = &i;
					call symput( "n_&i", compress(put(num_obs, 3.0)));
				run;
			%end;
		%mend get_sizes;
	%get_sizes run;
	

	* change day 0 to blank ;
	proc format library= library;
		value day_glnd 0 = " "
			1 = "1*(&n_1)" 7 = "7*(&n_7)" 13 = "13*(&n_13)"  19 = "19*(&n_19)" 24 = "24*(&n_24)" 
			2 = "2*(&n_2)" 8 = "8*(&n_8)" 14 = "14*(&n_14)"  20 = "20*(&n_20)" 25 = "25*(&n_25)" 
			3 = "3*(&n_3)" 9 = "9*(&n_9)" 15 = "15*(&n_15)"  21 = "21*(&n_21)" 26 = "26*(&n_26)" 
			4 = "4*(&n_4)" 10 = "10*(&n_10)" 16 = "16*(&n_16)"  22 = "22*(&n_22)" 27 = "27*(&n_27)" 
			5 = "5*(&n_5)" 11 = "11*(&n_11)" 17 = "17*(&n_17)"  23 = "23*(&n_23)" 28 = "28*(&n_28)" 
			6 = "6*(&n_6)" 12 = "12*(&n_12)" 18 = "18*(&n_18)"  29 = " "
			;
	run;

	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

	/* Set up symbol for Boxplot */
	symbol1 interpol=boxt0 mode=exclude value=none co=black cv=black height=.6 bwidth=3 width=2;
	/* Set up Symbol for Data Points */
	symbol2 ci=blue value=circle h=1 w=2;

	axis1 	label=(f=zapf h=2.5 "Day in SICU" ) split="*"	value=(f=zapf h= 1.25)  order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Total SOFA Score" ) 	value=(f=zapf h=2) order= (0 to 24 by 2) offset=(.25 in, .25 in)
	                minor=(number=1); 
	title1	height=3 f=zapf 'Total SOFA Score, adjusted';
	title2	height=2 f=zapf 'Patients discharged alive from the SICU assigned SOFA of 0 (min)';
	title3	height=2 f=zapf 'Patients who died in the SICU assigned SOFA of 24 (max)';



	* plot! ;
	ods pdf file = "/glnd/sas/reporting/sofa_plot_censor_adjust_open.pdf";
			proc gplot data= sofa;
				plot sofa_tot*day  sofa_tot*day2
	                   / overlay haxis = axis1 vaxis = axis2;

				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd.; 
			run;	
	
	
	ods pdf close;
quit;



			proc gplot data= sofa;
				plot sofa_tot*day  sofa_tot*day2
	                   / overlay haxis = axis1 vaxis = axis2;

				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd.; 
			run;	
	ods ps close;
quit;











