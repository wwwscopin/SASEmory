/* glutamine_closed.sas
 *
 * provide plots and summaries of glutamine. glutamine data is inherently unblinded. additionally,treatment info is included 
 *
 */

* data is currently set for the Feb 2008 DSMB (data last obtained Nov. 2007). the files come from the 'external data' folder;

data glutamine_full;
	set glnd_ext.glutamine;

		* jitter time;
		visit2 = visit - .2 + .4*uniform(234);

	keep id GlutamicAcid Glutamine visit total_glutamine visit2;
run;

* add in treatment info;
proc sort data=glutamine_full; by id; run;
proc sort data= glnd.george; by id; run;

 data glutamine_full;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
			;
	by id;

	if ~has_glutamine then delete; 
run;
	goptions reset=all rotate=landscape gunit=pct device=jpeg ftext=zapf hby = 3;


/*** CREATE AND TILE 3 SCATTERPLOTS W/ BOXPLOTS FOR GLUTAMINE, GLUTAMIC ACID, AND TOTAL GLUTAMINE ***/

	/* Set up symbol for Boxplot */
	symbol1 interpol=boxjt mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=0.8;
	/* Set up Symbol for Data Points */
	symbol2 ci=blue value=dot h=1;


%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;


proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 

* i = treatment group number. the unix macro engine cannot handle nested loops and thus you must feed it the treatment number in two separate macro calls;
%macro make_glutamine_plots (i =); 

	/* Set up symbol for Boxplot */
	symbol1 interpol=boxjt mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=0.8;
	/* Set up Symbol for Data Points */
	symbol2 ci=blue value=dot h=1;
	
	* subset the data based on treatment;
	data glutamine;
		set glutamine_full;	
		where treatment = &i ;
	run;
	
	* get group name;
	data _null_;
		num = input("&i", 1.);
		call symput('group', put(num, trt.));
	run;
		

	%let x= 1;
	%do %while (&x < 4);

		%if &x = 1 %then %do; 
				%let variable = GlutamicAcid; %let name = f=zapf "1 &group)" ;
				%let description = f=zapf h=3 "Glutamic Acid" ; 
				%let scale = order = (0 to 1500 by 100) ; %let y1 = 10; %let y2= 131;  /* order used to be 0 to 250 by 20 before outliers */
			%end; 
		%if &x = 2 %then %do; 
				%let variable = glutamine; %let name = f=zapf "2 &group)" ;
				%let description = f=zapf h=3 "Glutamine";
				%let scale = order = (0 to 1500 by 100) ; %let y1 = 205; %let y2= 756; /* order used to be 0 to 1200 by 200 before outliers */
			%end; 
		%if &x = 3 %then %do; 
				%let variable = total_glutamine; %let name = f=zapf "3 &group)" ;
				%let description = f=zapf h=3 "Total Glutamine";
				%let scale = order = (0 to 3000 by 200) ; %let y1 = 215; %let y2= 887; /* order used to be 0 to 1400 by 200 before outliers */
			%end; 

		proc sort data=glutamine; by visit id; run;
	
		proc means data= glutamine n min max;
			class visit;
			var &variable;
			output out = s_&variable n(&variable) = num_obs;
		run;

		* populate macro variables with sample sizes at each day;
		%do i = 0 %to 28;
				data _null_;
					set s_&variable;
					where visit = &i;
					call symput( "n_&i",  compress(put(num_obs, 3.0)));
				run;
		%end;

		proc format; 
		 	value day_glnd  -1=" " 0="0*(&n_0)" 1 = " "  2=" " 3="3*(&n_3)" 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 justify=left &name;
		title2 h=3 justify=center &description ", treatment" &group ;

		axis1 	label=(f=zapf h=2 'Day' ) split="*" value=(f=zapf h=2)  order= (-1 to 29 by 1) minor=none ;*origin = (15, 15);*offset=(0 in, 0in);
		axis2 	label=(f=zapf h=2 a=90 &description " (" f=greek h = 4 "m" h=3 f=zapf "M)") 	value=(f=zapf h=2) &scale minor=(number=3);


		data anno;
			set glutamine;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;
				
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'LTGRAY'; style = 'solid'; line= 0; output;;			
		run;

		proc gplot data= glutamine gout=glnd_rep.graphs;
			plot &variable*visit &variable*visit2 / overlay haxis = axis1 vaxis = axis2 annotate=anno nolegend;

			note h=2 m=(9.5 pct, 9 pct) "Day:" ;
			note h=2 m=(9.5 pct, 6.5 pct) " (n)" ;

			format visit day_glnd. &variable 5.0;
		run;	

	%let x = &x + 1;

%end;

%mend make_glutamine_plots;


* run macro;
	ods pdf file = "/glnd/sas/reporting/glutamine_closed.pdf";
		%make_glutamine_plots(i=1) run; * treatment A ;
		%make_glutamine_plots(i=2) run; * treatment B ;
	ods pdf close;

* tile the 2 sets of 3 graphs, side by side for each treatment ;

goptions rotate = portrait;
	ods pdf file = "/glnd/sas/reporting/glutamine_tiled_closed.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
			list igout;
			treplay 1:gplot 2:gplot4 ;
			treplay 1:gplot1 2:gplot5 ;
			treplay 1:gplot2 2:gplot6 ;

		run;
	ods pdf close;
quit;

* make PS files for the closed report ;

	ods ps file = "/glnd/sas/reporting/glutamine_closed_1.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
			treplay 1:gplot 2:gplot4 ;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/glutamine_closed_2.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
			treplay 1:gplot1 2:gplot5 ;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/glutamine_closed_3.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
			treplay 1:gplot2 2:gplot6 ;
		run;
	ods ps close;
