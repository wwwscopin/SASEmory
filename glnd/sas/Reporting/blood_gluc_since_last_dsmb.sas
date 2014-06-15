/* blood_gluc_monthly_since_last_dsmb.sas
 *
 * modification of the "blooc_gluc_monthly.sas" to include all glucose data for patients who have information after 1/1/2008 - when we last froze the DSMB data. 
 *
 * blood glucose data for inclusion in the GLND monthly reports
 *
 * 1. produce line plots by center for the patients with data in the previous month	
 * 2. proportions of measurements above 250 and below 50 in the previous month
 *
 *
 */

** turn macros on **;
 proc options option = macro;  
 run;


*** Prepare data. add dates of enrollment and dates of each glucose measurement! ***;
	proc sort data = glnd.status; by id; run;
	proc sort data = glnd.followup_alL_long; by id day; run;


	data gluc_center;
		set 	glnd.followup_all_long ;
		
		/** CODE USED TO ADD DATES AND CENTER VARIABLES WAS MOVED TO "followup_all.sas" on 8/30/2009 **/
	run;

%macro gluc_loop;

	%do x = 1 %to 2;
	
	** subset the patients by those with data in the last month ;

		** step 1 - keep observations from gluc_center taken in the last month ;
		data last_month_gluc;
			set gluc_center;
			
			%if ( &x = 2) %then %do;
			    if id^=31351; 
				where this_date>=mdy(&last_dsmb_date);
			%end;
		run;

		proc print data = last_month_gluc;
			where day = 1;
		run;

		** step 2 - reduce this data to just IDs;
		data last_month_gluc_IDs;
			set last_month_gluc;
			by id;

			if ~first.id then delete;		
			keep id day;
		run;
		
		proc print data = last_month_gluc_IDs ; var id day; run;

		** step 2.5 - figure out how many people this is and store in a macro variable ;
			proc means data = last_month_gluc_IDs;
				output out = total_IDs n(id) = total_IDs;
			run;
		


		** step 3 - keep longitudinal data for those people with data during last month ;
		data gluc_center;
			merge 	gluc_center
					last_month_gluc_IDs (in = has_gluc_last_month);
			by id;	

			if ~has_gluc_last_month then delete;

			* categorize normal, hypo and hyper-glycemic values ;

			if (80 <= gluc_eve <= 130) then normal_eve = 1; 	else if gluc_eve ~= . then normal_eve = 0; 
			if (80 <= gluc_mrn <= 130) then normal_mrn = 1; 	else if gluc_mrn ~= . then normal_mrn = 0; 
			if (80 <= gluc_aft <= 130) then normal_aft = 1; 	else if gluc_aft ~= . then normal_aft = 0; 

			if gluc_eve < 40 then hypo_40_eve = 1; 	else if gluc_eve >= 40 then hypo_40_eve = 0; if gluc_eve = . then hypo_40_eve = .; 
			if gluc_mrn < 40 then hypo_40_mrn = 1; 	else if gluc_mrn >= 40 then hypo_40_mrn = 0; if gluc_mrn = . then hypo_40_mrn = .;
			if gluc_aft < 40 then hypo_40_aft = 1; 	else if gluc_aft >= 40 then hypo_40_aft = 0; if gluc_aft = . then hypo_40_aft = .;

			if 40 <= gluc_eve < 50 then hypo_eve = 1; 	else if gluc_eve ~= . then hypo_eve = 0; 
			if 40 <= gluc_mrn < 50 then hypo_mrn = 1; 	else if gluc_mrn ~= . then hypo_mrn = 0; 
			if 40 <= gluc_aft < 50 then hypo_aft = 1; 	else if gluc_aft ~=. then hypo_aft = 0; 
			
			if gluc_eve > 250 then hyper_eve = 1; 	else if gluc_eve <= 250 then hyper_eve = 0; if gluc_eve = . then hyper_eve = .;
			if gluc_mrn > 250 then hyper_mrn = 1; 	else if gluc_mrn <= 250 then hyper_mrn = 0; if gluc_mrn = . then hyper_mrn = .;
			if gluc_aft > 250 then hyper_aft = 1; 	else if gluc_aft <= 250 then hyper_aft = 0; if gluc_aft = . then hyper_aft = .;

			if (50 <= gluc_eve < 80) then below_normal_eve = 1; 	else if gluc_eve ~= . then below_normal_eve = 0; 
			if (50 <= gluc_mrn < 80) then below_normal_mrn = 1; 	else if gluc_mrn ~= . then below_normal_mrn = 0; 
			if (50 <= gluc_aft < 80) then below_normal_aft = 1; 	else if gluc_aft ~= . then below_normal_aft = 0; 

			if (130 < gluc_eve <= 150) then above_normal_eve = 1; 	else if gluc_eve ~= . then above_normal_eve = 0; 
			if (130 < gluc_mrn <= 150) then above_normal_mrn = 1; 	else if gluc_mrn ~= . then above_normal_mrn = 0; 
			if (130 < gluc_aft <= 150) then above_normal_aft = 1; 	else if gluc_aft ~= . then above_normal_aft = 0; 

			if (150 < gluc_eve <= 180) then more_above_normal_eve = 1; 	else if gluc_eve ~= . then more_above_normal_eve = 0; 
			if (150 < gluc_mrn <= 180) then more_above_normal_mrn = 1; 	else if gluc_mrn ~= . then more_above_normal_mrn = 0; 
			if (150 < gluc_aft <= 180) then more_above_normal_aft = 1; 	else if gluc_aft ~= . then more_above_normal_aft = 0; 

			if (180 < gluc_eve <= 250) then very_above_normal_eve = 1; 	else if gluc_eve ~= . then very_above_normal_eve = 0; 
			if (180 < gluc_mrn <= 250) then very_above_normal_mrn = 1; 	else if gluc_mrn ~= . then very_above_normal_mrn = 0; 
			if (180 < gluc_aft <= 250) then very_above_normal_aft = 1; 	else if gluc_aft ~= . then very_above_normal_aft = 0; 


		run;


	** determine the proportion above 250 and below 50 in the last month and make a table; 
		proc means data = gluc_center;
				output out = glnd_rep.since_last_dsmb_gluc_totals 
				n(normal_eve normal_mrn normal_aft hypo_40_eve hypo_40_mrn hypo_40_aft hypo_eve hypo_mrn hypo_aft hyper_eve hyper_mrn hyper_aft below_normal_eve below_normal_mrn below_normal_aft 
					above_normal_eve above_normal_mrn above_normal_aft very_above_normal_eve very_above_normal_mrn very_above_normal_aft
					more_above_normal_eve more_above_normal_mrn more_above_normal_aft) 
						= normal_eve_n normal_mrn_n normal_aft_n hypo_40_eve_n hypo_40_mrn_n hypo_40_aft_n hypo_eve_n hypo_mrn_n hypo_aft_n hyper_eve_n hyper_mrn_n hyper_aft_n below_normal_eve_n below_normal_mrn_n below_normal_aft_n above_normal_eve_n 
						above_normal_mrn_n above_normal_aft_n
							very_above_normal_eve_n very_above_normal_mrn_n very_above_normal_aft_n
							more_above_normal_eve_n more_above_normal_mrn_n more_above_normal_aft_n

				sum(normal_eve normal_mrn normal_aft hypo_40_eve hypo_40_mrn hypo_40_aft hypo_eve hypo_mrn hypo_aft hyper_eve hyper_mrn hyper_aft below_normal_eve below_normal_mrn below_normal_aft 
					above_normal_eve above_normal_mrn above_normal_aft very_above_normal_eve very_above_normal_mrn very_above_normal_aft
					more_above_normal_eve more_above_normal_mrn more_above_normal_aft) 
						= normal_eve_s normal_mrn_s normal_aft_s hypo_40_eve_s hypo_40_mrn_s hypo_40_aft_s hypo_eve_s hypo_mrn_s hypo_aft_s hyper_eve_s hyper_mrn_s hyper_aft_s below_normal_eve_s below_normal_mrn_s below_normal_aft_s above_normal_eve_s 
						above_normal_mrn_s above_normal_aft_s
							very_above_normal_eve_s very_above_normal_mrn_s very_above_normal_aft_s
							more_above_normal_eve_s more_above_normal_mrn_s more_above_normal_aft_s
					;
		run;
		
		%if &x = 1 %then %do;
		
		* LISTINGS OF HYPO AND HYPERGLYCEMIC PATIENTS;
		
		ods pdf file = "/glnd/sas/reporting/hypo_hyper_listing.pdf" style = journal;
		proc print data = gluc_center;
			title "hypoglycemia < 40 ";
			where (hypo_40_mrn | hypo_40_aft | hypo_40_eve);
			var id day hypo_40_eve hypo_40_mrn hypo_40_aft  gluc_eve gluc_mrn gluc_aft;
			format hypo_40_eve hypo_40_mrn hypo_40_aft  yn.;
		run;
	
	
		proc print data = gluc_center;
			title "hypoglycemia < 50 ";
			where (hypo_mrn | hypo_aft | hypo_eve);
			var id day hypo_eve hypo_mrn hypo_aft gluc_eve gluc_mrn gluc_aft;
			format hypo_eve hypo_mrn hypo_aft yn.;
		run;
		
		proc print data = gluc_center;
			title "hyperglycemia, by center";
			where (hyper_mrn | hyper_aft | hyper_eve);
			
			by center;
			
			var id day hyper_eve hyper_mrn hyper_aft gluc_eve gluc_mrn gluc_aft;
			format hyper_eve hyper_mrn hyper_aft  yn.;
		run;
		ods pdf close;
		%end;
		
		data glnd_rep.since_last_dsmb_gluc_totals_&x;
			set glnd_rep.since_last_dsmb_gluc_totals;
		
			* Lay out the table ;
			row = "Evening  ";
			normal_display = compress(put(normal_eve_s, 4.0)) || "/" || compress(put(normal_eve_n, 4.0)) || " (" || compress(put(100* normal_eve_s / normal_eve_n, 4.1)) || "%)"; 
			hypo_40_display = compress(put(hypo_40_eve_s, 4.0)) || "/" || compress(put(hypo_40_eve_n, 4.0)) || " (" || compress(put(100* hypo_40_eve_s / hypo_40_eve_n, 4.1)) || "%)"; 
			hypo_display = compress(put(hypo_eve_s, 4.0)) || "/" || compress(put(hypo_eve_n, 4.0)) || " (" || compress(put(100* hypo_eve_s / hypo_eve_n, 4.1)) || "%)"; 
			hyper_display = compress(put(hyper_eve_s, 4.0)) || "/" || compress(put(hyper_eve_n, 4.0)) || " (" || compress(put( 100*hyper_eve_s / hyper_eve_n, 4.1)) || "%)"; 
			below_normal_display = compress(put(below_normal_eve_s, 4.0)) || "/" || compress(put(below_normal_eve_n, 4.0)) || " (" || compress(put( 100*below_normal_eve_s / below_normal_eve_n, 4.1)) || "%)"; 
			above_normal_display = compress(put(above_normal_eve_s, 4.0)) || "/" || compress(put(above_normal_eve_n, 4.0)) || " (" || compress(put( 100*above_normal_eve_s / above_normal_eve_n, 4.1)) || "%)"; 
			more_above_normal_display = compress(put(more_above_normal_eve_s, 4.0)) || "/" || compress(put(more_above_normal_eve_n, 4.0)) || " (" || compress(put( 100*more_above_normal_eve_s / more_above_normal_eve_n, 4.1)) || "%)"; 
			very_above_normal_display = compress(put(very_above_normal_eve_s, 4.0)) || "/" || compress(put(very_above_normal_eve_n, 4.0)) || " (" || compress(put( 100*very_above_normal_eve_s / very_above_normal_eve_n, 4.1)) || "%)"; 
			output;			

			row = "Morning";
			normal_display = compress(put(normal_mrn_s, 4.0)) || "/" || compress(put(normal_mrn_n, 4.0)) || " (" || compress(put(100*normal_mrn_s / normal_mrn_n, 4.1)) || "%)"; 
			hypo_40_display = compress(put(hypo_40_mrn_s, 4.0)) || "/" || compress(put(hypo_40_mrn_n, 4.0)) || " (" || compress(put(100*hypo_40_mrn_s / hypo_40_mrn_n, 4.1)) || "%)"; 
			hypo_display = compress(put(hypo_mrn_s, 4.0)) || "/" || compress(put(hypo_mrn_n, 4.0)) || " (" || compress(put(100*hypo_mrn_s / hypo_mrn_n, 4.1)) || "%)"; 
			hyper_display = compress(put(hyper_mrn_s, 4.0)) || "/" || compress(put(hyper_mrn_n, 4.0)) || " (" || compress(put(100* hyper_mrn_s / hyper_mrn_n, 4.1)) || "%)"; 
			below_normal_display = compress(put(below_normal_mrn_s, 4.0)) || "/" || compress(put(below_normal_mrn_n, 4.0)) || " (" || compress(put( 100*below_normal_mrn_s / below_normal_mrn_n, 4.1)) || "%)"; 
			above_normal_display = compress(put(above_normal_mrn_s, 4.0)) || "/" || compress(put(above_normal_mrn_n, 4.0)) || " (" || compress(put( 100*above_normal_mrn_s / above_normal_mrn_n, 4.1)) || "%)"; 
			more_above_normal_display = compress(put(more_above_normal_mrn_s, 4.0)) || "/" || compress(put(more_above_normal_mrn_n, 4.0)) || " (" || compress(put( 100*more_above_normal_mrn_s / more_above_normal_mrn_n, 4.1)) || "%)"; 
			very_above_normal_display = compress(put(very_above_normal_mrn_s, 4.0)) || "/" || compress(put(very_above_normal_mrn_n, 4.0)) || " (" || compress(put( 100*very_above_normal_mrn_s / very_above_normal_mrn_n, 4.1)) || "%)"; 
			output;			

			row = "Afternoon";
			normal_display = compress(put(normal_aft_s, 4.0)) || "/" || compress(put(normal_aft_n, 4.0)) || " (" || compress(put(100* normal_aft_s / normal_aft_n, 4.1)) || "%)"; 
			hypo_40_display = compress(put(hypo_40_aft_s, 4.0)) || "/" || compress(put(hypo_40_aft_n, 4.0)) || " (" || compress(put(100* hypo_40_aft_s / hypo_40_aft_n, 4.1)) || "%)"; 
			hypo_display = compress(put(hypo_aft_s, 4.0)) || "/" || compress(put(hypo_aft_n, 4.0)) || " (" || compress(put(100* hypo_aft_s / hypo_aft_n, 4.1)) || "%)"; 
			hyper_display = compress(put(hyper_aft_s, 4.0)) || "/" || compress(put(hyper_aft_n, 4.0)) || " (" || compress(put(100* hyper_aft_s / hyper_aft_n, 4.1)) || "%)"; 
			below_normal_display = compress(put(below_normal_aft_s, 4.0)) || "/" || compress(put(below_normal_aft_n, 4.0)) || " (" || compress(put( 100*below_normal_aft_s / below_normal_aft_n, 4.1)) || "%)"; 
			above_normal_display = compress(put(above_normal_aft_s, 4.0)) || "/" || compress(put(above_normal_aft_n, 4.0)) || " (" || compress(put( 100*above_normal_aft_s / above_normal_aft_n, 4.1)) || "%)"; 
			more_above_normal_display = compress(put(more_above_normal_aft_s, 4.0)) || "/" || compress(put(more_above_normal_aft_n, 4.0)) || " (" || compress(put( 100*more_above_normal_aft_s / more_above_normal_aft_n, 4.1)) || "%)"; 
			very_above_normal_display = compress(put(very_above_normal_aft_s, 4.0)) || "/" || compress(put(very_above_normal_aft_n, 4.0)) || " (" || compress(put( 100*very_above_normal_aft_s / very_above_normal_aft_n, 4.1)) || "%)"; 
			output;			


			label
				row = "Time of Day"
				normal_display = "Target Range*(80 - 130 mg/dL)"
				hypo_40_display = "Hypoglycemic*(< 40mg/dL)"
				hypo_display = "Hypoglycemic*(40 - 50mg/dL)"
				hyper_display = "Hyperglycemic*(> 250mg/dL)"
				below_normal_display = " *(50 - 80 mg/dL)"
				above_normal_display = " *(130 - 150 mg/dL)"	
				more_above_normal_display = " *(150 - 180 mg/dL)"	
				very_above_normal_display = " *(180 - 250 mg/dL)"	
		;

/*
			label
				row = "Time of Day"
				normal_display = "Target Range(80 - 130 mg/dL)"
				hypo_40_display = "Hypoglycemic(< 40mg/dL)"
				hypo_display = "Hypoglycemic(40 - 50mg/dL)"
				hyper_display = "Hyperglycemic(> 250mg/dL)"
				below_normal_display = "(50 - 80 mg/dL)"
				above_normal_display = "(130 - 150 mg/dL)"	
				more_above_normal_display = "(150 - 180 mg/dL)"	
				very_above_normal_display = "(180 - 250 mg/dL)"	
		;
*/			
		run;
	%end;
%mend gluc_loop;

%gluc_loop run;

* grab n from second iteration of loop into macro variable ;

	data _NULL_;
		set total_IDs;
		call symput('num_people', compress(put(total_IDs, 3.0)) );	
	run;


 proc format;

 value data  0="The &num_people GLND patients since the last DSMB report"
					1="All GLND patients";
run;


data table_open;
	set glnd_rep.since_last_dsmb_gluc_totals_2(in=A)
	  glnd_rep.since_last_dsmb_gluc_totals_1(in=B);
	 if A then data=0;
    if B then data=1;
	 format data data.;
run;


* Print since last dsmb and overall tables;

options orientation = landscape nodate nonumber;
title ;

	* play back all sites into a PDF ;
	
	ods ps file = "/glnd/sas/reporting/bg.ps" style = journal ;
	ods pdf file = "/glnd/sas/reporting/blood_gluc_since_last_dsmb_table.pdf" style = journal ;
		ods escapechar = '^';
		ods pdf startpage = no;
		
		title "Blood glucose measurement ranges";

		proc print data = table_open noobs label split = "*";
			by data notsorted;
			var row ;
			var hypo_40_display /style(data) = [just=center];
			var hypo_display /style(data) = [just=center];
			var below_normal_display /style(data) = [just=center];
			var normal_display /style(data) = [just=center];
			var above_normal_display /style(data) = [just=center];
			var more_above_normal_display /style(data) = [just=center];
			var very_above_normal_display /style(data) = [just=center];
			var hyper_display /style(data) = [just=center];
		run;	
		
	ods pdf close;
	ods ps close;
	quit;



/** NOW MAKE GLUCOSE PLOTS BY CENTER - THIS IS NOW SIMPLY DONE IN BLOOD_GLUC_BY_CENTER.sas

	proc sort data= gluc_center;
		by center;
	run;

	data anno_center;
		set gluc_center;

		xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;
		
		* draw a light gray rectangle from 80 to 130;
		function = 'move'; x = 1; y = 80; output;
		function = 'BAR'; x = 28; y = 130; color = 'ligr'; style = 'solid'; line= 0; output;
	
		* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
		function = 'move'; x = 1; y = 250; output;
		function = 'draw'; x = 28; y = 250; color = 'black';  line= 2; output;

		* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
		function = 'move'; x = 1; y = 50; output;
		function = 'draw'; x = 28; y = 50; color = 'black';  line= 2; output;
	run;

	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
*	options nobyline;
		
   %macro make_nutr_plots_center; 
  	%let x= 1;
 
 	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
 
  	%do %while (&x < 4);
  	
		%if &x = 1 %then %do; %let variable = gluc_eve ; %let description = "Evening blood glucose (mg/dL)"; %let time = "[22:00 - 24:00]"; %end; 
  		%else %if &x = 2 %then %do; %let variable = gluc_mrn ; %let description = "Morning blood glucose (mg/dL)"; %let time = "[05:00 - 07:00]"; %end; 
  		%else %if &x = 3 %then %do; %let variable = gluc_aft ; %let description = "Afternoon blood glucose (mg/dL)"; %let time =  "[14:00 - 18:00]"; %end; 
    
  	goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf 		hby = 4;
  		
		
		* symbols for up to 10 patients - no longer labeling individuals ;
		symbol1 value = dot h=1.5 i=join repeat = 200;

 		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=2) order = (1 to 28) minor= none;
 		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 400 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 		

 		title1 f=zapfb h=4 justify=center &description;	
 		title2 f=zapfb h=2.5 justify=center &time;
		
	
 			proc gplot data= gluc_center gout= glnd_rep.graphs;
				by center; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;

   	%let x = &x + 1;
 	%end;
	 	
 	%mend make_nutr_plots_center;
  	%make_nutr_plots_center run;

	
	* play back all sites into a PDF ;
	ods pdf file = "/glnd/sas/reporting/blood_gluc_since_last_dsmb_tiled_by_center.pdf";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= L2R2s nofs;
				list igout;
				treplay 1:gplot 2:gplot1 3:gplot2 ;
				treplay 1:gplot3 2:gplot4 3:gplot5 ; 
				treplay 1:gplot6 2:gplot17 3:gplot8 ; 
; 

			run;

	ods pdf close;
	quit;

****/

