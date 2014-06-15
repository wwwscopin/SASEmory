/* sofa_plot_open.sas
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
run;


proc sort data = sofa; by id day; run;
proc sort data = glnd.status; by id; run;

data sofa; 
	merge glnd.status (keep = id deceased mortality_28d)
		 sofa;
	by id;
run;

proc sort data=sofa;by day id; run;
/*proc print data= sofa; var day day2 id sofa_tot; run;*/

data glnd.sofa;
    retain id day sofa_tot;
    set sofa;
    keep id day sofa_tot;
    rename sofa_tot=sofa;
run;
proc sort nodupkey; by id day; run;

proc print;run;

data sofa1;
   set sofa;
   keep id day sofa_tot;
if day ne .;
run;

proc sort; by id day;
data glnd_rep.sofa;
  array sofa(28);
  do i=1 to 28;
   set sofa1;
   by id;
   sofa(day)=sofa_tot;
   if last.id then return;
 end;
keep id sofa1-sofa28;
proc print;
proc means;
run;
   


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
	symbol1 interpol=boxt0 mode=exclude value=none co=black cv=black height=.6 bwidth=3 width=2;
	/* Set up Symbol for Data Points */
	symbol2 ci=blue value=circle h=1 w=2;

	axis1 	label=(f=zapf h=2.5 "Day in SICU" ) split="*"	value=(f=zapf h= 1.25)  order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Total SOFA Score" ) 	value=(f=zapf h=2) order= (0 to 24 by 2) offset=(.25 in, .25 in)
	                minor=(number=1); 
	title	height=3 f=zapf 'Total SOFA Score';


	* plot! ;
	ods pdf file = "/glnd/sas/reporting/sofa_plot_open.pdf";
   ods ps file="sofa.ps";

		** Box plots;
			proc gplot data= sofa;
				plot sofa_tot*day  sofa_tot*day2
	                   / overlay haxis = axis1 vaxis = axis2;

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
				plot  sofa_tot*day2 = id  / overlay haxis = axis1 vaxis = axis2;
				
				where (year(dt_random) <= 2007) & day < 15;
				
				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd.; 
			run;	
		
	ods pdf close;









