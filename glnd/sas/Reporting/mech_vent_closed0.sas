/* mech_vent_open.sas
 *
 * started 7/17/08. supercedes previous versions of the mechanical ventilation report. no longer counts times on and off.
 * now reports time on vent as well as vent-free days
 *
 * ADDS TREATMENT INFO BY CREATING A MACRO AND SUBSETTING THE DATA. THE RESULTANT 2 TABLES ARE MERGED AND LABELLED ACCORDING TO THE TREATMENTS LOADED INTO THE TREATMENT FORMAT  
 *
 */


%macro closed;

%do x = 1 %to 2;


* ASSIGN THE TREATMENT TO THE VARIABLE 'GROUP', ACCORDING TO THE FORMAT;
data _null_;
	num = input("&x", 1.);
	call symput('group', put(num, trt.));
run;


proc sort data = glnd.plate17;	by id;	run;


	data mech_vent;
		set glnd.plate17;
		where (dt_mech_vent_start_1 ~= .) | (dt_mech_vent_start_2 ~= .) |(dt_mech_vent_start_3 ~= .) |(dt_mech_vent_start_4 ~= .)|(dt_mech_vent_start_5 ~= .); * include only if they were ever on mechanical ventilation. some people have blank mech vent forms ;
	run;

	proc sort data= mech_vent; by id; run;
	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.george; by id; run;


	* Add hospital information to mech_vent. if they have only one run on mechanical ventilation and no stop date for that 
		run, then set the stop date equal to their discharge date or the date of the data freeze (8/20/07 for DSMB report #1) ;

	data mech_vent;
		merge 	mech_vent (in = has_mech_vent)	
				glnd.status (keep = id dt_random mortality_28d dt_discharge)
				glnd.george (keep = id treatment)
				;
		by id;

		if (treatment ~= &x) then delete;

		ever_on_vent = has_mech_vent;

		* number of runs for that person ;
		if ~(ever_on_vent) then num_runs = 0;
		else 	num_runs = 1 + (dt_mech_vent_start_2 ~= .) + (dt_mech_vent_start_3 ~= .) + (dt_mech_vent_start_4 ~= .) + (dt_mech_vent_start_5 ~= .);

		if (dt_mech_vent_stop_1 = mdy(1,1,1999) ) then dt_mech_vent_stop_1 = dt_discharge;
		if (dt_mech_vent_stop_2 = mdy(1,1,1999) ) then dt_mech_vent_stop_2 = dt_discharge;
		if (dt_mech_vent_stop_3 = mdy(1,1,1999) ) then dt_mech_vent_stop_3 = dt_discharge;
		if (dt_mech_vent_stop_4 = mdy(1,1,1999) ) then dt_mech_vent_stop_4 = dt_discharge;
		if (dt_mech_vent_stop_5 = mdy(1,1,1999) ) then dt_mech_vent_stop_5 = dt_discharge;
		

		/****
			* fix stop dates of first run;
			if (dt_mech_vent_stop_1 = .) & (dt_mech_vent_start_2 = .) then do;
			if still_in_hosp then dt_mech_vent_stop_1 = datejul(2007232);
				else dt_mech_vent_stop_1 = dt_discharge; 
			end;

			* duration of first mech vent run ;
			run_1_duration = dt_mech_vent_stop_1 - dt_mech_vent_start_1 ;
		****/


		* compute individual time intervals;
			days_on_vent_1 = (dt_mech_vent_stop_1 - dt_mech_vent_start_1) ; 
			days_on_vent_2 = (dt_mech_vent_stop_2 - dt_mech_vent_start_2) ; 
			days_on_vent_3 = (dt_mech_vent_stop_3 - dt_mech_vent_start_3) ; 
			days_on_vent_4 = (dt_mech_vent_stop_4 - dt_mech_vent_start_4) ; 
			days_on_vent_5 = (dt_mech_vent_stop_5 - dt_mech_vent_start_5) ; 
	
		* zero out missing times and sum them up ;
			if (days_on_vent_1 = .) then days_on_vent_1 = 0;
			if (days_on_vent_2 = .) then days_on_vent_2 = 0;
			if (days_on_vent_3 = .) then days_on_vent_3 = 0;
			if (days_on_vent_4 = .) then days_on_vent_4 = 0;
			if (days_on_vent_5 = .) then days_on_vent_5 = 0;

		* this total excludes the 48-hour wait-period, giving a "raw" days on mechanical ventilation, reporting on what is on the on/off log ;
			days_on_vent_raw = days_on_vent_1 + days_on_vent_2 + days_on_vent_3 + days_on_vent_4 + days_on_vent_5  ;

	
		/*** Ventilator-free days - calculated using the rules of Schoenfeld and Bernard, Critical Care Medicine 2002 ***/

			**** now give the adjusted 48-hour (really 2 days for us, because we do not record hours) total days on vent;
	
				** VFD are just concerned with the day of enrollment onward. censor data to BEGIN at enrollment; 
				if (dt_mech_vent_start_1 < dt_random) then dt_mech_vent_start_1_adj = dt_random; 	else dt_mech_vent_start_1_adj = dt_mech_vent_start_1;
				if (dt_mech_vent_start_2 < dt_random) then dt_mech_vent_start_2_adj = dt_random; 	else dt_mech_vent_start_2_adj = dt_mech_vent_start_2;
				if (dt_mech_vent_start_3 < dt_random) then dt_mech_vent_start_3_adj = dt_random; 	else dt_mech_vent_start_3_adj = dt_mech_vent_start_3;
				if (dt_mech_vent_start_4 < dt_random) then dt_mech_vent_start_4_adj = dt_random; 	else dt_mech_vent_start_4_adj = dt_mech_vent_start_4;
				if (dt_mech_vent_start_5 < dt_random) then dt_mech_vent_start_5_adj = dt_random; 	else dt_mech_vent_start_5_adj = dt_mech_vent_start_5;

				if (dt_mech_vent_stop_1 < dt_random) & (dt_mech_vent_stop_1 ~=. ) then dt_mech_vent_stop_1_adj = dt_random; 	else dt_mech_vent_stop_1_adj = dt_mech_vent_stop_1;
				if (dt_mech_vent_stop_2 < dt_random) & (dt_mech_vent_stop_2 ~=. ) then dt_mech_vent_stop_2_adj = dt_random; 	else dt_mech_vent_stop_2_adj = dt_mech_vent_stop_2;
				if (dt_mech_vent_stop_3 < dt_random) & (dt_mech_vent_stop_3 ~=. ) then dt_mech_vent_stop_3_adj = dt_random; 	else dt_mech_vent_stop_3_adj = dt_mech_vent_stop_3;	
				if (dt_mech_vent_stop_4 < dt_random) & (dt_mech_vent_stop_4 ~=. ) then dt_mech_vent_stop_4_adj = dt_random; 	else dt_mech_vent_stop_4_adj = dt_mech_vent_stop_4;
				if (dt_mech_vent_stop_5 < dt_random) & (dt_mech_vent_stop_5 ~=. ) then dt_mech_vent_stop_5_adj = dt_random; 	else dt_mech_vent_stop_5_adj = dt_mech_vent_stop_5;
		
		
				* if there are less than 2 days separating mech vent episodes, then we count the time in between as being on ventilator!;	
				if ((dt_mech_vent_start_2_adj - dt_mech_vent_stop_1_adj) in (0, 1) ) then dt_mech_vent_start_2_adj = dt_mech_vent_stop_1_adj ; * i use in (0, 1) rather than < 2 to exclude ".";		
				if ((dt_mech_vent_start_3_adj - dt_mech_vent_stop_2_adj) in (0, 1) ) then dt_mech_vent_start_3_adj = dt_mech_vent_stop_2_adj ;
				if ((dt_mech_vent_start_4_adj - dt_mech_vent_stop_3_adj) in (0, 1) ) then dt_mech_vent_start_4_adj = dt_mech_vent_stop_3_adj ;
				if ((dt_mech_vent_start_5_adj - dt_mech_vent_stop_4_adj) in (0, 1) ) then dt_mech_vent_start_5_adj = dt_mech_vent_stop_4_adj ;
	

				* compute individual time intervals;
					days_on_vent_1_adj = (dt_mech_vent_stop_1_adj - dt_mech_vent_start_1_adj) ; 
						if ~ever_on_vent then days_on_vent_1_adj = 0;

					days_on_vent_2_adj = (dt_mech_vent_stop_2_adj - dt_mech_vent_start_2_adj) ; 
					days_on_vent_3_adj = (dt_mech_vent_stop_3_adj - dt_mech_vent_start_3_adj) ; 
					days_on_vent_4_adj = (dt_mech_vent_stop_4_adj - dt_mech_vent_start_4_adj) ; 
					days_on_vent_5_adj = (dt_mech_vent_stop_5_adj - dt_mech_vent_start_5_adj) ; 
	
				* if a patient is on and off in the same day AFTER STUDY ENROLLMENT, assign it to be a half-day ;
					if (days_on_vent_1_adj = 0) & (dt_mech_vent_start_1 >= dt_random) & (dt_mech_vent_stop_1 - dt_mech_vent_start_1 ~= .) then days_on_vent_1_adj = 0.5; *   (dt_mech_vent_stop_1 - dt_mech_vent_start_1) = 0 ;
					if (days_on_vent_2_adj = 0) & (dt_mech_vent_start_2 >= dt_random) & (dt_mech_vent_stop_2 - dt_mech_vent_start_2 ~= .) then days_on_vent_2_adj = 0.5;
					if (days_on_vent_3_adj = 0) & (dt_mech_vent_start_3 >= dt_random) & (dt_mech_vent_stop_3 - dt_mech_vent_start_3 ~= .) then days_on_vent_3_adj = 0.5;
					if (days_on_vent_4_adj = 0) & (dt_mech_vent_start_4 >= dt_random) & (dt_mech_vent_stop_4 - dt_mech_vent_start_4 ~= .) then days_on_vent_4_adj = 0.5;
					if (days_on_vent_5_adj = 0) & (dt_mech_vent_start_5 >= dt_random) & (dt_mech_vent_stop_5 - dt_mech_vent_start_5 ~= .) then days_on_vent_5_adj = 0.5;

				* zero out missing times and sum them up ;
					if (days_on_vent_2_adj = .) then days_on_vent_2_adj = 0;
					if (days_on_vent_3_adj = .) then days_on_vent_3_adj = 0;
					if (days_on_vent_4_adj = .) then days_on_vent_4_adj = 0;
					if (days_on_vent_5_adj = .) then days_on_vent_5_adj = 0;

			days_on_vent_adj =sum(days_on_vent_1_adj, days_on_vent_2_adj, days_on_vent_3_adj, days_on_vent_4_adj , days_on_vent_5_adj)  ;


			** now calculate ventilator-free days **;

			if (mortality_28d = 1) | (days_on_vent_adj > 28) then  vent_free_days = 0;
			else if (days_on_vent_adj ~= .) then vent_free_days = 28 - days_on_vent_adj;

		
	run;

	proc print data = mech_vent width = minimum;
		where id = 41036;
		var id days_on_vent_1 days_on_vent_2 dt_mech_vent_stop_1 dt_mech_vent_stop_1 dt_mech_vent_stop_1 dt_mech_vent_stop_1;
	run;

	proc print data = mech_vent width = minimum;
		var id dt_mech_vent_start_1 dt_mech_vent_stop_1 dt_random days_on_vent_1 days_on_vent_2 days_on_vent_3 days_on_vent_raw days_on_vent_1_adj days_on_vent_2_adj days_on_vent_3_adj days_on_vent_adj mortality_28d vent_free_days ever_on_vent;
	run;


** show n-s for ever on vent, total vent days, VFD days;	

	proc means data = mech_vent n sum median ;
		class ever_on_vent;
		var ever_on_vent days_on_vent_adj vent_free_days;	
		output out = mech_vent_closed_&x
			n(ever_on_vent days_on_vent_adj vent_free_days) = ever_on_vent_n days_on_vent_adj_n vent_free_days_n
			sum(ever_on_vent) = ever_on_vent_s
			median(ever_on_vent days_on_vent_adj vent_free_days) = ever_on_vent_m days_on_vent_adj_m vent_free_days_m
			q1(ever_on_vent days_on_vent_adj vent_free_days) = ever_on_vent_q1 days_on_vent_adj_q1 vent_free_days_q1
			q3(ever_on_vent days_on_vent_adj vent_free_days) = ever_on_vent_q3 days_on_vent_adj_q3 vent_free_days_q3;
	run;

	proc print data = mech_vent_closed_&x;
	run;
	
	data mech_vent_closed_&x;
		set mech_vent_closed_&x;
		
		length row $ 60;
		length display_&group $ 35;

		if (_type_ = 0) then do;

			row = "== Overall ==";
			display_&group = "n (%)";
			order = 1;
			output;

			row = "-  Patients ever on mechanical ventilation";
			display_&group = compress(put(ever_on_vent_s, 4.0)) || "/"|| compress(put(ever_on_vent_n, 4.0)) || " (" || compress(put((ever_on_vent_s/ever_on_vent_n)*100,4.1)) || "%)" ; 
			order = 2;
			output;

			row = " ";
			display_&group = " ";
			order = 3;
			output;

			row = " ";
			display_&group = "med. [Q1, Q3], n";
			order = 4;
			output;

			row = "-  Ventilator-free days";
			display_&group = compress(put(vent_free_days_m, 4.1)) || " [" || compress(put(vent_free_days_q1, 4.1)) || ", " || compress(put(vent_free_days_q3, 4.1)) || "], " || compress(put(vent_free_days_n, 4.0)) ;
			order = 5;
			output;
		end;

		if (_type_ = 1) & (ever_on_vent = 1) then do;

			row = " ";
			display_&group = " ";
			order = 6;
			output;

			row = "== Patients on Mechanical Ventilation only == ";
			display_&group = " ";
			order = 7;
			output;
			
			row = "- Adjusted number of days on ventilator";
			display_&group = compress(put(days_on_vent_adj_m, 4.1)) || " [" || compress(put(days_on_vent_adj_q1, 4.1)) || ", " || compress(put(days_on_vent_adj_q3, 4.1)) || "], " || compress(put(days_on_vent_adj_n, 4.0)) ;
			order = 8;
			output;

			row = "- Ventilator-free days";
			display_&group = compress(put(vent_free_days_m, 4.1)) || " [" || compress(put(vent_free_days_q1, 4.1)) || ", " || compress(put(vent_free_days_q3, 4.1)) || "], " || compress(put(vent_free_days_n, 4.0)) ;
			order = 9;
			output;


		end;

		label 
			row = '00'x 
			display_&group = "&group"
		;
	run;

%end;

%mend closed;
%closed run;

proc sort data = mech_vent_closed_1; by order; run;
proc sort data = mech_vent_closed_2; by order; run;

data glnd_rep.mech_vent_closed;
	merge 
		mech_vent_closed_1
		mech_vent_closed_2
		;
	by order;
run;


options nodate nonumber;
title "Mechanical Ventilation Summary";

ods ps file = "/glnd/sas/reporting/mech_vent_closed.ps" style = journal;
	proc print data = glnd_rep.mech_vent_closed noobs label style(header) = [just = center];
		var row;
		var display_a display_b /style(data) = [just=center];
	run;
ods ps close;	

