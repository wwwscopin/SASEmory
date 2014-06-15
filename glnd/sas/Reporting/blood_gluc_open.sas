 * turn macros on;
 proc options option = macro;  
 run;
 
* options papersize=(23.4in 16.5in);
 
%put &last_dsmb_date;


/** BEGIN **/

 proc sort data= glnd.followup_all_long;
 	by id day;
 run;
 

 /*
 proc print; 
 where day=1 and gluc_mrn=.;
 var id day gluc_mrn;
 run;
*/

	* initialize the macro variables to store the sample sizes OUTSIDE of macro;
	* in order to set the scope to global ;
		%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0;
		%let n_6= 0; %let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;
		%let n_11= 0; %let n_12= 0; %let n_13= 0; %let n_14= 0; %let n_15= 0;
		%let n_16= 0; %let n_17= 0; %let n_18= 0; %let n_19= 0; %let n_20= 0;
		%let n_21= 0; %let n_22= 0; %let n_23= 0; %let n_24= 0; %let n_25= 0;
		%let n_26= 0; %let n_27= 0; %let n_28= 0; 


 data anno;
	set glnd.followup_all_long;

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

	data anno_boxplots;
		set glnd.followup_all_long;

		xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;
		
		* draw a light gray rectangle from 80 to 130;
		function = 'move'; x = 0; y = 80; output;
		function = 'BAR'; x = 29; y = 130; color = 'ligr'; style = 'solid'; line= 0; output;
	
		* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
		function = 'move'; x = 0; y = 250; output;
		function = 'draw'; x = 29; y = 250; color = 'black';  line= 2; output;

		* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
		function = 'move'; x = 0; y = 50; output;
		function = 'draw'; x = 29; y = 50; color = 'black';  line= 2; output;

run;
 
/** MAKE OVERALL GLUCOSE PLOTS **/
   %macro make_nutr_plots; 
  	%let x= 1;
 
 	ods pdf file = "/glnd/sas/reporting/blood_gluc.pdf";
 	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
 
  	%do %while (&x < 4);
  	
  		%if &x = 1 %then %do; %let variable = gluc_eve ; %let source = eve_gluc_src; 			%let description = "Evening blood glucose (mg/dL)"; %let time = "[22:00 - 24:00]"; %end; 
  		%else %if &x = 2 %then %do; %let variable = gluc_mrn ; %let source = mrn_gluc_src;		%let description = "Morning blood glucose (mg/dL)"; %let time = "[05:00 - 07:00]"; %end; 
  		%else %if &x = 3 %then %do; %let variable = gluc_aft ; %let source = aft_gluc_src;		%let description = "Afternoon blood glucose (mg/dL)"; %let time =  "[14:00 - 18:00]"; %end; 
  	  

		* get 'n' at each day - SINCE LAST DSMB. TRACKINGS AND BOXPLOTS ARE SINCE LAST DSMB. MIXED IS CUMULATIVE! ;
		proc means data=glnd.followup_all_long(where=(id^=31351)) noprint;
		
			where this_date >= mdy(&last_dsmb_date);
			
			class day;
			var &variable;
			output out = num n(&variable) = num_obs;
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
			value day_glnd 0 = " " 29 = " "
				1 = "1*(&n_1)" 7 = "7*(&n_7)" 13 = "13*(&n_13)"  19 = "19*(&n_19)" 24 = "24*(&n_24)" 
				2 = "2*(&n_2)" 8 = "8*(&n_8)" 14 = "14*(&n_14)"  20 = "20*(&n_20)" 25 = "25*(&n_25)" 
				3 = "3*(&n_3)" 9 = "9*(&n_9)" 15 = "15*(&n_15)"  21 = "21*(&n_21)" 26 = "26*(&n_26)" 
				4 = "4*(&n_4)" 10 = "10*(&n_10)" 16 = "16*(&n_16)"  22 = "22*(&n_22)" 27 = "27*(&n_27)" 
				5 = "5*(&n_5)" 11 = "11*(&n_11)" 17 = "17*(&n_17)"  23 = "23*(&n_23)" 28 = "28*(&n_28)" 
				6 = "6*(&n_6)" 12 = "12*(&n_12)" 18 = "18*(&n_18)"  
				;
		run;


  	goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;
  		
		/* PLOT LONGITUDINAL TRACKINGS FOR GLUCOSE - SINCE PREVIOUS DSMB REPORT (as of 8/30/2009) */		
		* symbols for up to 10 patients - no longer labeling individuals ;
		symbol1 value = dot h=1.5 i=join repeat = 20;

 		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=centb h=1.25) order = (1 to 28) minor= none split="*";
 		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 450 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 		
 		/*legend1 across=1  position=(top right outside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h= 3 position= top justify = center 'Patient ID:')
 			value=(f=zapf h=3);*/

	
 		title1 f=zapfb h=4 justify=center &description;
 		title2 f=zapfb h=2.5 justify=center &time;

		*proc gplot data= glnd.followup_all_long gout= glnd_rep.graphs; 
    	proc gplot data= glnd.followup_all_long(where=(id^=31351)) gout= glnd_rep.graphs; 
			
					where this_date >= mdy(&last_dsmb_date);
			
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno nolegend; * legend=legend1; 

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
				format day day_glnd.;
 			run;
 		


		/* PLOT LONGITUDINAL BOXPLOTS FOR GLUCOSE - SINCE PREVIOUS DSMB REPORT (as of 8/30/2009) */	
			* add jitter ;
			data glu_box;
				set glnd.followup_all_long;
				day2= (day - .2) + .4*uniform(3654);
			run;	

		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=centb h=1.25) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
		proc format library= library;
			value day_temp 0 = "  " 29 = " ";   
		run;
		symbol1 interpol=boxt0 mode=exclude repeat = 1 value=none co=black cv=black height=.6 bwidth=3 width=2;
		symbol2 ci=blue value=dot h=1;

			proc gplot data= glu_box(where=(id^=31351)) gout= glnd_rep.graphs;
			
				where this_date >= mdy(&last_dsmb_date);
			
				plot &variable*day   &variable*day2   /overlay haxis = axis1 vaxis = axis2   annotate=anno_boxplots nolegend;

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
				format day day2 day_glnd.;
			run;	



		/* SIMPLE MIXED MODEL FOR GLUCOSE. PLOT RESULTS */
		
		* get 'n' at each day - NOEW WE ARE DOING THIS CUMULATIVELY ! ;
		proc means data=glnd.followup_all_long noprint;
			
			class day;
			var &variable;
			output out = num n(&variable) = num_obs;
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
			value day_glnd 0 = " " 29 = " "
				1 = "1*(&n_1)" 7 = "7*(&n_7)" 13 = "13*(&n_13)"  19 = "19*(&n_19)" 24 = "24*(&n_24)" 
				2 = "2*(&n_2)" 8 = "8*(&n_8)" 14 = "14*(&n_14)"  20 = "20*(&n_20)" 25 = "25*(&n_25)" 
				3 = "3*(&n_3)" 9 = "9*(&n_9)" 15 = "15*(&n_15)"  21 = "21*(&n_21)" 26 = "26*(&n_26)" 
				4 = "4*(&n_4)" 10 = "10*(&n_10)" 16 = "16*(&n_16)"  22 = "22*(&n_22)" 27 = "27*(&n_27)" 
				5 = "5*(&n_5)" 11 = "11*(&n_11)" 17 = "17*(&n_17)"  23 = "23*(&n_23)" 28 = "28*(&n_28)" 
				6 = "6*(&n_6)" 12 = "12*(&n_12)" 18 = "18*(&n_18)"  
				;
		run;
		
		* means mixed model with heterogenous compound symmetry;
		proc mixed data = glu_box empirical covtest;
			class id day ; * &source;
		
			model &variable = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_&variable;
		run;

		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = glu_box; by day; run;
		proc sort data = lsmeans_&variable; by day; run;

		data glu_mixed ;
			merge 	glu_box
					lsmeans_&variable
				;	
			by day;
			
			* 	value gluc_src   99 = "Blank"  	1 = "lab"	2 = "accucheck" ;
			* split accucheck and raw lab values into 2 different columns;
		
				if eve_gluc_src = 1 then lab_gluc_eve = gluc_eve;
				else if eve_gluc_src = 2 then accucheck_gluc_eve = gluc_eve;
			
				if mrn_gluc_src = 1 then lab_gluc_mrn = gluc_mrn;
				else if mrn_gluc_src = 2 then accucheck_gluc_mrn = gluc_mrn;

				if aft_gluc_src = 1 then lab_gluc_aft = gluc_aft;
				else if aft_gluc_src = 2 then accucheck_gluc_aft = gluc_aft;
	
		run;

	
		* draw bars for 95% CIs;
		DATA anno_mixed; 
			set lsmeans_&variable;
			
			xsys='2'; ysys='2';
						
			* draw a light gray rectangle from 80 to 130;
			function = 'move'; x = 0; y = 80; output;
			function = 'BAR'; x = 29; y = 130; color = 'ligr '; style = 'solid'; line= 0; output;
		
			* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
			function = 'move'; x = 0; y = 250; output;
			function = 'draw'; x = 29; y = 250; color = 'black';  line= 2; output;

			* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
			function = 'move'; x = 0; y = 50; output;
			function = 'draw'; x = 29; y = 50; color = 'black';  line= 2; output;

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black'; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black'; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;
				
		* plot original data jitterd, estimated means and 95% CIs;

		goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;

		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=centb h=1.25) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 450 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 	
		symbol1 value=dot h=1 ci=red;
		symbol2 ci=blue value=circle h=1;
		symbol3 value = diamond co=black h = 2 i = join w = 2.5;

		legend1 	across = 1 position=(top right inside) mode = reserve fwidth = .2
				shape = symbol(3,2) label=NONE 
				value = (f=zapf h=3 "lab" "accucheck" "mean");

 		title1 f=zapfb h=4 justify=center &description;
		title2 f=zapfb h=3 justify=center "Longitudinal models (means and 95% CI)";


		proc gplot data = glu_mixed  gout= glnd_rep.graphs;
			plot 	lab_&variable*day2 
					accucheck_&variable*day2 
					estimate*day	/overlay annotate= anno_mixed haxis = axis1 vaxis = axis2 legend=legend1;

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
			format estimate &variable 4.1 	day day2 day_glnd.; 
		run;
		
		* also model this with source of measurement;
		proc mixed data = glu_box empirical covtest;
			class id day  &source;
		
			model &variable = day  &source	day*&source/ solution;
			repeated day / subject = id type = cs r;
			lsmeans day &source day*&source / cl ;
			ods output lsmeans = lsmeans_&variable._&source;
		run;

			data lsmeans_&variable._&source;
				set lsmeans_&variable._&source (rename = (&source = source));
				where compress(effect) = "day*&source";
			run;

/***************************** (see KITE cd4_cd8.sas for method of annotating with 2 groups. its very easy
			**  MAKE MIXED PLOTS FOR SOURCE OF MEASUREMENT;
				* merge the means and CIs into gluc_box to obtain plotting dataset;
				proc sort data = glu_box; by day source; run;
				proc sort data = lsmeans_&variable; by day source; run;

				data glu_mixed ;
					merge 	glu_box
							lsmeans_&variable._&source
						;	
					by day source;
					
					* 	value gluc_src   99 = "Blank"  	1 = "lab"	2 = "accucheck" ;
					* split accucheck and raw lab values into 2 different columns;
				
					* split raw data;
						if eve_gluc_src = 1 then lab_gluc_eve = gluc_eve;
						else if eve_gluc_src = 2 then accucheck_gluc_eve = gluc_eve;
					
						if mrn_gluc_src = 1 then lab_gluc_mrn = gluc_mrn;
						else if mrn_gluc_src = 2 then accucheck_gluc_mrn = gluc_mrn;

						if aft_gluc_src = 1 then lab_gluc_aft = gluc_aft;
						else if aft_gluc_src = 2 then accucheck_gluc_aft = gluc_aft;

					* split LSMEANS estimates;
						if eve_gluc_src = 1 then lab_gluc_eve = gluc_eve;
						else if eve_gluc_src = 2 then accucheck_gluc_eve = gluc_eve;
					
						if mrn_gluc_src = 1 then lab_gluc_mrn = gluc_mrn;
						else if mrn_gluc_src = 2 then accucheck_gluc_mrn = gluc_mrn;

						if aft_gluc_src = 1 then lab_gluc_aft = gluc_aft;
						else if aft_gluc_src = 2 then accucheck_gluc_aft = gluc_aft;
				run;

			
				* draw bars for 95% CIs;
				DATA anno_mixed; 
					set glu_mixed;
					
					xsys='2'; ysys='2';
								
					* draw a light gray rectangle from 80 to 130;
					function = 'move'; x = 0; y = 80; output;
					function = 'BAR'; x = 29; y = 130; color = 'ligr '; style = 'solid'; line= 0; output;
				
					* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
					function = 'move'; x = 0; y = 250; output;
					function = 'draw'; x = 29; y = 250; color = 'black';  line= 2; output;

					* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
					function = 'move'; x = 0; y = 50; output;
					function = 'draw'; x = 29; y = 50; color = 'black';  line= 2; output;

					* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
					X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A'; color='black'; OUTPUT; * start at mean ;
							Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black';  OUTPUT; * draw down;
				
					LINK TIPS; * make bar;

					Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black';  OUTPUT; * draw up; 
				
					LINK TIPS; * make bar;
				
					* draw top and bottoms of bars;
					TIPS:
					  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color='black'; OUTPUT;
					  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=46; color='black'; OUTPUT;
					  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
					return;
				run;
						
				* plot original data jitterd, estimated means and 95% CIs;

				goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
		  		colors = (black) ftitle=zapf ftext= zapf;

				axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=centb h=1.25) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
				axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
							order= (0 to 450 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
		 	
				symbol1 value=dot h=1 ci=red;
				symbol2 ci=blue value=circle h=1;
				symbol3 value = diamond ci=black h = 2 i = join w = 4;

				legend1 	across = 1 position=(top right inside) mode = reserve fwidth = .2
						shape = symbol(3,2) label=NONE 
						value = (f=zapf h=3 "lab" "accucheck" "mean");

		 		title1 f=zapfb h=4 justify=center &description;
				title2 f=zapfb h=3 justify=center "Longitudinal models (means and 95% CI)";


				proc gplot data = glu_mixed  gout= glnd_rep.graphs;
					plot 	lab_&variable*day2 
							accucheck_&variable*day2 
							estimate*day	/overlay annotate= anno_mixed haxis = axis1 vaxis = axis2 legend=legend1;

						note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
						note h=1.5 m=(12pct, 9 pct) " (n)" ;
					format estimate &variable 4.1 	day day2 day_glnd.; 
				run;
*****************************************/
   	%let x = &x + 1;
	
	ods pdf close;
	%end;
	
		* now make a table of the means and 95% CI for morning, evening, and afternoon blood glucose on days 0, 7, 14;
		data glnd_rep.glucose_mixed_open;
			merge 	lsmeans_gluc_eve (keep = estimate upper lower day rename = (estimate = mean_eve upper = upper_eve lower = lower_eve))
					lsmeans_gluc_mrn (keep = estimate upper lower day rename = (estimate = mean_mrn upper = upper_mrn lower = lower_mrn))
					lsmeans_gluc_aft (keep = estimate upper lower day rename = (estimate = mean_aft upper = upper_aft lower = lower_aft))
				;
			by day;
			
			where day in (1, 7, 14);
 		
			eve = compress(put(mean_eve, 5.1)) || " (" || compress(put(lower_eve, 5.1)) || ", " || compress(put(upper_eve, 5.1)) || ")";
			mrn = compress(put(mean_mrn, 5.1)) || " (" || compress(put(lower_mrn, 5.1)) || ", " || compress(put(upper_mrn, 5.1)) || ")";
			aft = compress(put(mean_aft, 5.1)) || " (" || compress(put(lower_aft, 5.1)) || ", " || compress(put(upper_aft, 5.1)) || ")";
			
			label
				day = "Day"
				eve = "Evening Glucose*mean (95% CI)"
				mrn = "Morning Glucose*mean (95% CI)"
				aft = "Afternoon Glucose*mean (95% CI)"
				
			;
   format day;

			keep day eve mrn aft;
			
		run;

		* DO THE SAME THING BUT WITH SOURCE OF MEASUREMENT
		* make a table of the means and 95% CI for morning, evening, and afternoon blood glucose on days 0, 7, 14;

		proc sort data = lsmeans_gluc_eve_eve_gluc_src; by day source; run;
		proc sort data = lsmeans_gluc_mrn_mrn_gluc_src; by day source; run;
		proc sort data = lsmeans_gluc_aft_aft_gluc_src; by day source; run;

		data glnd_rep.glucose_source_mixed_open;
			merge 	lsmeans_gluc_eve_eve_gluc_src (keep = estimate upper lower day source rename = (estimate = mean_eve upper = upper_eve lower = lower_eve ))
					lsmeans_gluc_mrn_mrn_gluc_src (keep = estimate upper lower day source rename = (estimate = mean_mrn upper = upper_mrn lower = lower_mrn ))
					lsmeans_gluc_aft_aft_gluc_src (keep = estimate upper lower day source rename = (estimate = mean_aft upper = upper_aft lower = lower_aft ))
				;
			by day source;

			where day in (1, 7, 14);
 		
			eve = compress(put(mean_eve, 5.1)) || " (" || compress(put(lower_eve, 5.1)) || ", " || compress(put(upper_eve, 5.1)) || ")";
			mrn = compress(put(mean_mrn, 5.1)) || " (" || compress(put(lower_mrn, 5.1)) || ", " || compress(put(upper_mrn, 5.1)) || ")";
			aft = compress(put(mean_aft, 5.1)) || " (" || compress(put(lower_aft, 5.1)) || ", " || compress(put(upper_aft, 5.1)) || ")";
			
			label
				source=  "Source of measurement"
				day = "Day"
				eve = "Evening Glucose mean (95% CI)"
				mrn = "Morning Glucose mean (95% CI)"
				aft = "Afternoon Glucose mean (95% CI)"
				
			;
    			format day;
		*	keep source day eve mrn aft;
			
		run;

		ods pdf file = "/glnd/sas/reporting/blood_gluc_mixed_open.pdf" style = journal;
			title1; title2;

			proc print data = glnd_rep.glucose_mixed_open noobs label split= '*';
				var day eve mrn aft;
			run;
	
			proc print data = glnd_rep.glucose_source_mixed_open noobs label split= '*';
				var day source eve mrn aft;
			run;

			/*** Make longitudinal plot of lab and accucheck means:
				symbol1 value = dot i = join;
				symbol2 value = circle i = join;

				axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=1.5) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
				axis2 	label=(f=zapf h=4 a=90 "Morning Glucose" ) 	value=(f=zapf h=3) 
								order= (0 to 450 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);

				proc gplot data = glnd_rep.glucose_source_mixed_open;
					plot mean_mrn * day = source /haxis = axis1 vaxis = axis2;
				run;
			***/
		ods pdf close;



%mend make_nutr_plots;

 	%make_nutr_plots run;

		

/* make custom slide arrangment  to give overall title  */

	* 2 x 2 horizontal box, with an outer box for displaying a title ;
	proc greplay tc=work.tempcat nofs;

	tdef title2x2 des='Five panel template'

	     1/llx=0   lly=10
	       ulx=0   uly=50
	       urx=50  ury=50
	       lrx=50  lry=10
	       color=white
	     2/llx=0   lly=50
	       ulx=0   uly=90
	       urx=50  ury=90
	       lrx=50  lry=50
	       color=white

	     3/llx=50   lly=50
	       ulx=50   uly=90
	       urx=100 ury=90
	       lrx=100 lry=50
	       color=white

	     4/llx=50   lly=10
	       ulx=50  uly=50
	       urx=100 ury=50
	       lrx=100 lry=10
	       color=white

		/* This one is for displaying the outer box */
	     5/llx=0   lly=0
	        ulx=0   uly=100
	        urx=100 ury=100
	        lrx=100 lry=0
	        color=white;

	   template title2x2;

	   list template;
	run;

	** step 1 - keep observations from gluc_center taken in the last month ;
		data n;
			set glnd.followup_all_long;
			
					where this_date >= mdy(&last_dsmb_date);
					if id^=31351;

		run;

		** step 2 - reduce this data to just IDs;
		data last_dsmb_IDs;
			set n;
			by id;

			if ~first.id then delete;		
			keep id day;
		run;
		
		proc print data = last_dsmb_IDs ; var id day; run;

		** step 2.5 - figure out how many people this is and store in a macro variable ;
			proc means data = last_dsmb_IDs;
				output out = total_IDs n(id) = total_IDs;
			run;
		
			data _NULL_;
				set total_IDs;
				call symput('num_people', compress(put(total_IDs, 3.0)) );	
			run;

	
	* make slide for each center;
	proc gslide gout=glnd_rep.graphs; * name = gslide ;
  		title1 f=triplex h=4  "Individual blood glucose tracking";
  		title2 f=triplex h=2.5  "for the &num_people GLND patients with data since the last DSMB report";
	run;
	proc gslide gout=glnd_rep.graphs; * name = gslide1 ;
		title1 f=triplex  h=4  "Blood glucose boxplots"; 
		title2 f=triplex h=2.5 "for the &num_people GLND patients with data since the last DSMB report";

		run;
	proc gslide gout=glnd_rep.graphs; * name = gslide2 ;
		title1 f=triplex h=4  "Longitudinal model of blood glucose";
		
		run;
	
	
	***** now create PS pages;
	
*ods listing close;
options orientation=landscape;

filename output 'blood1.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;
	* indiv trackings;
ods ps file = "/glnd/sas/reporting/blood1.ps";
ods printer sas printer="PostScript EPS Color" file = "/glnd/sas/reporting/blood1.eps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
			list igout;
			treplay 1:gplot 2:gplot3 3:gplot6 5:gslide ;
			title1 f=zapfb h=4 justify=center &descriptio;
			run;
	ods printer close;
	ods ps close;
	quit;

	* boxplots; 

filename output 'blood2.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;ods ps file = "/glnd/sas/reporting/blood2.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
			list igout;
			
			treplay 1:gplot1 2:gplot4 3:gplot7 5:gslide1;
			run;
	ods ps close;
	quit;

	* mixed plots;
	
filename output 'blood3.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;
ods ps file = "/glnd/sas/reporting/blood3.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
			list igout;
			
			treplay 1:gplot2 2:gplot5 3:gplot8 5:gslide2;
			run;
	ods ps close;
	quit;

filename output 'blood4.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;

ods ps file = "/glnd/sas/reporting/blood4.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= whole nofs;
				list igout;
				treplay 1:gplot5; * Emory ;
			run;
	ods ps close;

	quit;



 	
