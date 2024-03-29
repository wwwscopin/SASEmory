/* sofa_plot_open_wbh.sas
 *
 * For all patients, plot total sofa scores longitudinally and draw boxplots. 
 * Annotate with sample sizes at each day (SOFA scores are recordable when a patient
 * is in the SICU)
 *
 */

options pagesize= 60 linesize = 85 center nodate nonumber;

data sofa;
	set glnd.followup_all_long;
	day2= (day - .2) + .4*uniform(3654);
	xsys='2'; ysys='2';
run;


/*
data sofa_id;
	set sofa(keep=id);
run;

proc sort data=sofa_id nodup;by id;run;
proc print;run;
*/

proc sort data = sofa; by id day; run;
proc sort data = glnd.status; by id; run;

data sofa; 
	merge glnd.status (keep = id deceased mortality_28d)
		 sofa;
	by id;
run;



		proc mixed data = sofa empirical covtest;
			class id day ; * &source;
		
			model sofa_tot = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_sofa;
		run;

		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = sofa; by day; run;
		proc sort data = lsmeans_sofa; by day; run;

		data sofa ;
			merge sofa lsmeans_sofa;	by day;
   	run;


		DATA anno_mixed; 
			set lsmeans_sofa;
			
			xsys='2'; ysys='2';
						

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
			output out = sizes n(sofa_tot) = num_obs max(day) = last_day;
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
	symbol1 interpol=none mode=exclude value=circle co=red cv=blue height=1 bwidth=3 width=2;
	/* Set up Symbol for Data Points */
	symbol2 i=j ci=red value=square h=2 w=4;

	axis1 	label=(f=zapf h=2.5 "Day in SICU" ) split="*"	value=(f=zapf h= 1.25)  order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Total SOFA Score" ) 	value=(f=zapf h=2) order= (0 to 24 by 2) offset=(.25 in, .25 in)
	                minor=(number=1); 

	legend1 across = 1 position=(top right inside) mode = reserve fwidth = .2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=3 "sofa" "mean") offset=(0, -0.4 in) frame;


	title 	height=3 f=zapf 'Total SOFA Score';


	* plot! ;
  *ods pdf file = "/glnd/sas/reporting/sofa_plot_open.pdf";
	ods pdf file = "sofa_plot_open.pdf";
   ods ps file="sofa.ps";

		** Box plots;
			proc gplot data= sofa;
				plot sofa_tot*day2 estimate*day/overlay annotate= anno_mixed haxis = axis1 vaxis = axis2 legend=legend1;

				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd.; 
			run;	
	
	ods ps close;



	** Line plots;
	* random 25 people who are alive and 28 who died in the SICU ;

		symbol1 ci=blue value=circle h=1 w=2 i = join repeat = 2000;
		axis1 	label=(f=zapf h=2.5 "Day in SICU" ) split="*"	value=(f=zapf h= 1.5)  order= (0 to 15 by 1) minor=none offset=(0 in, 0 in);

			proc gplot data= sofa;
				plot  sofa_tot*day2 = id  / overlay haxis = axis1 vaxis = axis2 nolegend;
				
				where (year(dt_random) <= 2007) & day < 15;
				
				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd.; 
			run;	
		
			ods pdf close;
********************************************************************************************************************;
		ods pdf file="sofa_mixed_mean.pdf" style=journal;

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data glnd_rep.sofa_mixed_open;
				merge lsmeans_sofa(keep = estimate upper lower day) 
						 lsmeans_sofa_survivor(keep = estimate upper lower day rename=(estimate=estimate_s upper=upper_s lower=lower_s)) ;
						 lsmeans_sofa_dead(keep = estimate upper lower day rename=(estimate=estimate_d upper=upper_d lower=lower_d)) ;		
			by day;
			
			where day in (1, 7, 14);
 		
			sofa_t = strip(put(estimate, 5.1)) || " (" || strip(put(lower, 5.1)) || ", " || strip(put(upper, 5.1))|| ")";
			sofa_s = strip(put(estimate_s, 5.1)) || " (" || strip(put(lower_s, 5.1)) || ", " || strip(put(upper_s, 5.1))|| ")";
			sofa_d = strip(put(estimate_d, 5.1)) || " (" || strip(put(lower_d, 5.1)) || ", " || strip(put(upper_d, 5.1))|| ")";
			
			label
				day = "Day"
				sofa_t = "Total Sofa Score*mean (95% CI)";
				sofa_s = "Total Sofa Score for Survior*mean (95% CI)";
				sofa_d = "Total Sofa Score for Non_survior*mean (95% CI)";
		
		   format day;

		  	keep day sofa_t sofa_s sofa_d;
		run;


			proc print data = glnd_rep.sofa_mixed_open noobs label style(data) = [just=center];
				var day sofa_t sofa_s spfa_d ;
			run;
	
		ods pdf close;










