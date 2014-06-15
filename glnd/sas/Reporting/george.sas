/* blood_gluc_closed.sas 
 *
 * Eli Rosenberg
 *
 * Create longitundal plots of each patient's nutritional intake. both line plots and boxplots
 * SEPARATED BY TREATMENT FOR THE CLOSED SESSION DSMB REPORT
 *
 */
 
 * turn macros on;
 proc options option = macro;  
 run;
 options mprint mlogic symbolgen;
  
	* initialize the macro variables to store the sample sizes OUTSIDE of macro;
	* in order to set the scope to global ;
		%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0;
		%let n_6= 0; %let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;
		%let n_11= 0; %let n_12= 0; %let n_13= 0; %let n_14= 0; %let n_15= 0;
		%let n_16= 0; %let n_17= 0; %let n_18= 0; %let n_19= 0; %let n_20= 0;
		%let n_21= 0; %let n_22= 0; %let n_23= 0; %let n_24= 0; %let n_25= 0;
		%let n_26= 0; %let n_27= 0; %let n_28= 0; 


 proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

 proc sort data= glnd.followup_all_long;
 	by id day;
 run;
 
  * merge treatment info into a dataset that can be subsetted by treatment and used for plotting;
  proc sort data= glnd.george; by id; run;

 data follow_up_treat;
	merge 	glnd.followup_all_long
			glnd.george (keep = id treatment)
			;
	by id; 
run;

 
 	* capture sample size of total people in each trt group; 
		proc means data= glnd.george;
			where (treatment = 1);
			output out= n_A n(id) = id_n;
		run;
		
		proc means data= glnd.george;
			where (treatment = 2);
			output out= n_B n(id) = id_n;
		run;
				
		data _null_;
			set n_A;
	
			call symput('n_A', compress(put(id_n, 3.0)));
		run;
		
		data _null_;
			set n_B;
	
			call symput('n_B', compress(put(id_n, 3.0)));
		run;


 
 
/** MAKE OVERALL GLUCOSE PLOTS **/
* i = treatment group number. the unix macro engine cannot handle nested loops and thus you must feed it the treatment number in two separate macro calls;
%macro make_nutr_plots (i = ); 
  	
 * ASSIGN THE TREATMENT TO THE VARIABLE GROUP, ACCORDING TO THE FORMAT;
data _null_;
	num = input("&i", 1.);
	call symput('group', put(num, trt.));
	
run;
 
 * subset data based on treatment;
 data plot;
 	set follow_up_treat;
 	where treatment = &i;
 run;
 
 data anno;
	set plot;
		
		where treatment = &i; * counter for outer loop;

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
	set plot;

		where treatment = &i;
		
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
 	%let x= 1;
  	%do %while (&x < 4);
  	
  		%if &x = 1 %then %do; %let variable = gluc_eve ; %let description = "Evening blood glucose (mg/dL)"; %end; 
  		%else %if &x = 2 %then %do; %let variable = gluc_mrn ; %let description = "Morning blood glucose (mg/dL)"; %end; 
  		%else %if &x = 3 %then %do; %let variable = gluc_aft ; %let description = "Afternoon blood glucose (mg/dL)"; %end; 
  	  
		* get 'n' at each day;
		proc means data=plot noprint;
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
  		
		/* PLOT LONGITUDINAL TRACKINGS FOR GLUCOSE */		
		* symbols for up to 10 patients - no longer labeling individuals ;
		symbol1 value = dot h=1.5 i=join repeat = 200;

 		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=1.3) order = (0 to 29) minor= none split="*";
 		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 400 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 		
 		/*legend1 across=1  position=(top right outside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h= 3 position= top justify = center 'Patient ID:')
 			value=(f=zapf h=3);*/

 		title1 f=zapfb h=4 justify=center &description ", treatment " &group;

 		
	
 			proc gplot data= plot gout= glnd_rep.graphs; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno nolegend; * legend=legend1; 
				format day day_glnd.;

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
 			run;
 		

		/* PLOT LONGITUDINAL BOXPLOTS FOR GLUCOSE */	
			* add jitter ;
			data glu_box;
				set plot;
				day2= (day - .2) + .4*uniform(3654);
			run;	

		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=1.3) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
		proc format library= library;
			value day_temp 0 = "  " 29 = " ";
		run;
		symbol1 interpol=boxt0 mode=exclude repeat = 1 value=none co=black cv=black height=.6 bwidth=3 width=2;
		symbol2 ci=blue value=dot h=1;
			proc gplot data= glu_box gout= glnd_rep.graphs;
				plot &variable*day   &variable*day2   /overlay haxis = axis1 vaxis = axis2   annotate=anno_boxplots nolegend;

				format day day2 day_glnd.; 

				note h=1.5 m=(12pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(12pct, 9 pct) " (n)" ;
			run;	

		/* SIMPLE MIXED MODEL FOR GLUCOSE. PLOT RESULTS */
	
		* means mixed model with heterogenous compund symmetry;
		proc mixed data = glu_box empirical covtest;
			class id day;
		
			model &variable = day / solution;
			repeated day / subject = id type = csh;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans;
		run;

		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = glu_box; by day; run;
		proc sort data = lsmeans; by day; run;
		data glu_mixed;
			merge 	glu_box
					lsmeans
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
  data glnd.gluc_mixed_closed_&variable.&group;
   set lsmeans;
   run;

		* draw bars for 95% CIs;
		DATA anno_mixed; 
			set lsmeans;
			
			xsys='2'; ysys='2';
						
			* draw a light gray rectangle from 80 to 130;
			function = 'move'; x = 0; y = 80; output;
			function = 'BAR'; x = 29; y = 130; color = 'ligr'; style = 'solid'; line= 0; output;
		
			* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
			function = 'move'; x = 0; y = 250; output;
			function = 'draw'; x = 29; y = 250; color = 'black';  line= 2; output;

			* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
			function = 'move'; x = 0; y = 50; output;
			function = 'draw'; x = 29; y = 50; color = 'black';  line= 2; output;

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black'; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black'; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;
				
		* plot original data jitterd, estimated means and 95% CIs;

		goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;

		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=1.3) order = (0 to 29) minor= none split="*"; * give one extra day in each direction to allow space for boxplots ; 
		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 400 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 	
		symbol1 value=dot h=1;
		symbol2 ci=blue value=circle h=1;
		symbol3 value = diamond co=black h = 2 i = join ;

		legend1 	across = 1 position=(top right inside) mode = reserve fwidth = .2
				shape = symbol(3,2) label=NONE 
				value = (f=zapf h=3 "lab" "accucheck" "mean");

 		title1 f=zapfb h=4 justify=center &description ", treatment " &group;
		title2 f=zapfb h=3 justify=center "Longitudinal models (means and 95% CI)";


		proc gplot data = glu_mixed gout= glnd_rep.graphs;
			plot 	lab_&variable*day2 
					accucheck_&variable*day2 
					estimate*day	/overlay annotate= anno_mixed haxis = axis1 vaxis = axis2 legend=legend1;

				note h=1.5 m=(10pct, 10.5 pct) "Day:" ;
				note h=1.5 m=(10pct, 9 pct) " (n)" ;

			format estimate &variable 4.1 	day day day2 day_glnd.; 
		run;

		* now make a table of the means and 95% CI for morning, evening, and afternoon blood glucose on days 0, 7, 14;
		data gluc_mixed_&group;
			merge 	glnd.gluc_mixed_closed_gluc_eve&group (keep = estimate upper lower day rename = (estimate = mean_eve upper = upper_eve lower = lower_eve))
					glnd.gluc_mixed_closed_gluc_mrn&group (keep = estimate upper lower day rename = (estimate = mean_mrn upper = upper_mrn lower = lower_mrn))
					glnd.gluc_mixed_closed_gluc_aft&group (keep = estimate upper lower day rename = (estimate = mean_aft upper = upper_aft lower = lower_aft))
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

			keep day eve mrn aft;
			
		run;



   	%let x = &x + 1;
 	%end; * x loop;

%mend make_nutr_plots;

%make_nutr_plots(i=1) run; * treatment A;
%make_nutr_plots(i=2) run; * treatment B;


 	/* after complete macro, use greplay to tile 3 graphs per page in a SINGLE pdf, landscape, for a total of 3 pages  */
	goptions rotate = portrait;
	ods pdf file = "/glnd/sas/reporting/blood_gluc_tiled_closed.pdf";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
			list igout;

			* line plots;
			treplay 1:gplot 2:gplot10;
			treplay 1:gplot3 2:gplot13;
			treplay 1:gplot6 2:gplot16;

			* boxplots;
			treplay 1:gplot1 2:gplot11;
			treplay 1:gplot4 2:gplot14;
			treplay 1:gplot7 2:gplot17;

			* MIXED plots; 
			treplay 1:gplot2 2:gplot12;
			treplay 1:gplot5 2:gplot15;
			treplay 1:gplot8 2:gplot18;
			*treat B;

			* treat A;

			/***** OLD ORDER - L2R2s 

			* treat A;
			treplay 1:gplot 2:gplot3 3:gplot6 ; * line plots ;
			treplay 1:gplot1 2:gplot4 3:gplot7 ; * boxplots ; 
			treplay 1:gplot2 2:gplot5 3:gplot8 ; * MIXED plots ; 

			*treat B;
			treplay 1:gplot9 2:gplot12 3:gplot15 ;
			treplay 1:gplot10 2:gplot13 3:gplot16 ;
			treplay 1:gplot11 2:gplot14 3:gplot17 ;	

			******/
			run;


	ods pdf close;
	quit;
	
	
	***** now create 2 ps pages;
	
	/* REVISIT - MAKE 9 PS PAGES*/
	
	goptions rotate = portrait;


		* line plots;
		ods ps file = "/glnd/sas/reporting/blood1closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot 2:gplot10;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood2closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot3 2:gplot13;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood3closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot6 2:gplot16;
			run;
		ods ps close;

		* boxplots;
		ods ps file = "/glnd/sas/reporting/blood4closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot1 2:gplot11;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood5closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot4 2:gplot14;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood6closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot7 2:gplot17;
			run;
		ods ps close;


		* MIXED plots; 
		ods ps file = "/glnd/sas/reporting/blood7closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot2 2:gplot12;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood8closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot5 2:gplot14;
			run;
		ods ps close;

		ods ps file = "/glnd/sas/reporting/blood9closed.ps";
			proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot8 2:gplot18;
			run;
		ods ps close;


		* MIXED Tables;
		options nodate nonumber;
		ods pdf file = "/glnd/sas/reporting/gluc_mixed_tables_closed.pdf" style = journal startpage = no;
			ods escapechar='^' ;
			title "Blood glucose longitudinal model means (mg/dL)";
			 
			ods pdf text = "^S={font_weight=bold font_size=12pt just=center} Treatment group A (n = &n_A)";		
			proc print data =gluc_mixed_A noobs label split= '*';
				var day eve mrn aft;
			run;

			ods pdf text = " ";
			ods pdf text = " ";
			ods pdf text = "^S={font_weight=bold font_size=12pt just=center} Treatment group B (n = &n_B)";		
			proc print data =gluc_mixed_B noobs label split= '*';
				var day eve mrn aft;
			run;
			
		
						
		ods pdf close;


