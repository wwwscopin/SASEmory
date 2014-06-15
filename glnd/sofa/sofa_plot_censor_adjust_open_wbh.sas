/* sofa_plot_censor_adjust_open.sas
 *
 * For all patients, plot total sofa scores longitudinally and draw boxplots. 
 * Annotate with sample sizes at each day (SOFA scores are recordable when a patient
 * is in the SICU)
 *
 * This version was created (2/5/2010) per the DSMB recommendations to keep people who leave the SICU or die by assigning them a min or max score (0 if leave SICU, 24 if die)
 *
 */

options pagesize= 60 linesize = 85 center nodate nonumber;

data all;
	set glnd.followup_all_long(keep=id);
run;

data dead;
	set glnd_rep.death_details_open(keep=id);
run;

proc sql;
	create table sur as
	select *
      from all
   except
   select *
      from dead;

proc sort data=all nodup;by id;run;
proc sort data=dead nodup;by id;run;
proc sort data=sur nodup;by id;run;
proc sort data = glnd.followup_all_long; by id day; run;

data _null_;
	set all;
	call symput("num_pat", trim(put(_n_, 3.0)));
run;

data _null_;
	set dead;
	call symput("num_dead", trim(put(_n_, 3.0)));
run;

data _null_;
	set sur;
	call symput("num_sur", trim(put(_n_, 3.0)));
run;






data sofa;
		set glnd.followup_all_long;	by id day;
		day2= (day - .2) + .4*uniform(3654);
run;

proc sql;
	create table sofa_dead as 
	select sofa.*
	from sofa, dead
	where sofa.id=dead.id;
;

proc sql;
	create table sofa_sur as 
	select sofa.*
	from sofa, sur
	where sofa.id=sur.id;
run;

%macro anno(data=sofa);
		proc mixed data = &data empirical covtest;
			class id day ; * &source;
		
			model sofa_tot = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_&data;
		run;

		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = &data; by day; run;
		proc sort data = lsmeans_&data; by day; run;

		data lsmeans_&data;
			set lsmeans_&data;
			if estimate<0 then estimate=0;
			if lower<0 then lower=0;
			if upper<0 then upper=0;
		run;

		data &data ;
			merge &data lsmeans_&data;	by day;
   	run;


		DATA anno_mixed_&data; 
			set lsmeans_&data;
			
			xsys='2'; ysys='2';
			
			%if &data=sofa %then %do; %let mycolor='black'; %end;
			%if &data=sofa_sur %then %do; %let mycolor='blue'; %end;
			%if &data=sofa_dead %then %do; %let mycolor='red'; %end;

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor;  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; color=&mycolor; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;

%mend anno;

%anno(data=sofa);
%anno(data=sofa_sur);
%anno(data=sofa_dead);

* check that the n at each day is the same. this may change if SOFA is missing on a day that a person is in the SICU;
	proc means data = sofa n;
		class day;
		var id;
	run;

* LEFT OFF HERE: test that plots have all people for 28 days, and that min and max are appropriately calculated using a PROC PRINT;

proc sort data = glnd.status; by id; run;
proc sort data=sofa;by day id; run;


/* Load sample sizes for each day into macro variables, for plot annotation */
	* initialize the macro variables to store the sample sizes OUTSIDE of macro;
	* in order to set the scope to global ;
		%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0;
		%let n_6= 0; %let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;
		%let n_11= 0; %let n_12= 0; %let n_13= 0; %let n_14= 0; %let n_15= 0;
		%let n_16= 0; %let n_17= 0; %let n_18= 0; %let n_19= 0; %let n_20= 0;
		%let n_21= 0; %let n_22= 0; %let n_23= 0; %let n_24= 0; %let n_25= 0;
		%let n_26= 0; %let n_27= 0; %let n_28= 0; 

		%let s_1= 0; %let s_2= 0; %let s_3= 0; %let s_4= 0; %let s_5= 0;
		%let s_6= 0; %let s_7= 0; %let s_8= 0; %let s_9= 0; %let s_10= 0;
		%let s_11= 0; %let s_12= 0; %let s_13= 0; %let s_14= 0; %let s_15= 0;
		%let s_16= 0; %let s_17= 0; %let s_18= 0; %let s_19= 0; %let s_20= 0;
		%let s_21= 0; %let s_22= 0; %let s_23= 0; %let s_24= 0; %let s_25= 0;
		%let s_26= 0; %let s_27= 0; %let s_28= 0; 

		%let d_1= 0; %let d_2= 0; %let d_3= 0; %let d_4= 0; %let d_5= 0;
		%let d_6= 0; %let d_7= 0; %let d_8= 0; %let d_9= 0; %let d_10= 0;
		%let d_11= 0; %let d_12= 0; %let d_13= 0; %let d_14= 0; %let d_15= 0;
		%let d_16= 0; %let d_17= 0; %let d_18= 0; %let d_19= 0; %let d_20= 0;
		%let d_21= 0; %let d_22= 0; %let d_23= 0; %let d_24= 0; %let d_25= 0;
		%let d_26= 0; %let d_27= 0; %let d_28= 0; 

%macro size(data);
	* obtain n's for each day;
		proc means data= &data noprint;
			class day;
			var sofa_tot;
			output out = sizes_&data n(sofa_tot) = num_obs max(day) = last_day;	* if alive and in SICU but missing the SOFA info, that will affect the total sample size;
		run;
	* trim initial record and get last day ;
		data sizes_&data; 
			set sizes_&data;

			if (day = .) then do;
				call symput("last_day", trim(put(last_day, 3.0))); * save the last day for which we have observations;
				delete;
			end;
		run;
	
	* loop through the n's from proc means, for all days that we have observations;
   	%macro get_sizes;
			%do i = 1 %to &last_day;
				data _null_;
					set sizes_&data;
					where day = &i;
					call symput( "n_&i", compress(put(num_obs, 3.0)));
					%if &data=sofa_sur  %then %do; 
						call symput( "s_&i", compress(put(num_obs, 3.0)));
					%end;
					%if &data=sofa_dead  %then %do; 
						call symput( "d_&i", compress(put(num_obs, 3.0)));
					%end;
				run;
			%end;
		%mend get_sizes;
	%get_sizes run;

	

	* change day 0 to blank ;
	proc format library= library;
		value day_glnd_&data 0 = " "
			1 = "1*(&n_1)" 7 = "7*(&n_7)" 13 = "13*(&n_13)"  19 = "19*(&n_19)" 24 = "24*(&n_24)" 
			2 = "2*(&n_2)" 8 = "8*(&n_8)" 14 = "14*(&n_14)"  20 = "20*(&n_20)" 25 = "25*(&n_25)" 
			3 = "3*(&n_3)" 9 = "9*(&n_9)" 15 = "15*(&n_15)"  21 = "21*(&n_21)" 26 = "26*(&n_26)" 
			4 = "4*(&n_4)" 10 = "10*(&n_10)" 16 = "16*(&n_16)"  22 = "22*(&n_22)" 27 = "27*(&n_27)" 
			5 = "5*(&n_5)" 11 = "11*(&n_11)" 17 = "17*(&n_17)"  23 = "23*(&n_23)" 28 = "28*(&n_28)" 
			6 = "6*(&n_6)" 12 = "12*(&n_12)" 18 = "18*(&n_18)"  29 = " "
			;


		value day_glnd_sofa_all 0 = " "
			1 = "1#*(&s_1)*(&d_1)" 7 = "7*(&s_7))*(&d_7)" 13 = "13*(&s_13)*(&d_13)"  19 = "19*(&s_19)*(&d_19)" 24 = "24*(&s_24)*(&d_24)" 
			2 = "2*(&s_2)*(&d_2)" 8 = "8*(&s_8)*(&d_8)" 14 = "14*(&s_14)*(&d_14)"  20 = "20*(&s_20)*(&d_20)" 25 = "25*(&s_24)*(&d_25)" 
			3 = "3*(&s_3)*(&d_3))" 9 = "9*(&s_9)*(&d_9)" 15 = "15*(&s_15)*(&d_15)"  21 = "21*(&s_21)*(&d_21)" 26 = "26*(&s_26)*(&d_26)" 
			4 = "4*(&s_4)*(&d_4)" 10 = "10*(&s_10)*(&d_10)" 16 = "16*(&s_16)*(&d_16)"  22 = "22*(&s_22)*(&d_22)" 27 = "27*(&s_27)*(&d_27)" 
			5 = "5*(&s_5)*(&d_5)" 11 = "11*(&s_11)*(&d_11)" 17 = "17*(&s_17)*(&d_17)"  23 = "23*(&s_23)*(&d_23)" 28 = "28*(&s_28)*(&d_28)" 
			6 = "6*(&s_6)*(&d_6)" 12 = "12*(&s_12)*(&d_12)" 18 = "18*(&s_18)*(&d_18)"  29 = " "
			;

/*
		value day_glnd_sofa_all 0 = " "
			1 = "1*(%sysfunc(cats(&s_1,"|",&d_1)))" 7 = "7*(%sysfunc(cats(&s_7,"|",&d_7)))" 13 = "13*(%sysfunc(cats(&s_13,"|",&d_13)))"  19 = "19*(%sysfunc(cats(&s_19,"|",&d_19)))" 24 = "24*(%sysfunc(cats(&s_24,"|",&d_24)))" 
			2 = "2*(%sysfunc(cats(&s_2,"|",&d_2)))" 8 = "8*(%sysfunc(cats(&s_8,"|",&d_8)))" 14 = "14*(%sysfunc(cats(&s_14,"|",&d_14)))"  20 = "20*(%sysfunc(cats(&s_20,"|",&d_20)))" 25 = "25*(%sysfunc(cats(&s_25,"|",&d_25)))" 
			3 = "3*(%sysfunc(cats(&s_3,"|",&d_3)))" 9 = "9*(%sysfunc(cats(&s_9,"|",&d_9)))" 15 = "15*(%sysfunc(cats(&s_15,"|",&d_15)))"  21 = "21*(%sysfunc(cats(&s_21,"|",&d_21)))" 26 = "26*(%sysfunc(cats(&s_26,"|",&d_26)))" 
			4 = "4*(%sysfunc(cats(&s_4,"|",&d_4)))" 10 = "10*(%sysfunc(cats(&s_10,"|",&d_10)))" 16 = "16*(%sysfunc(cats(&s_16,"|",&d_16)))"  22 = "22*(%sysfunc(cats(&s_22,"|",&d_22)))" 27 = "27*(%sysfunc(cats(&s_27,"|",&d_27)))" 
			5 = "5*(%sysfunc(cats(&s_5,"|",&d_5)))" 11 = "11*(%sysfunc(cats(&s_11,"|",&d_11)))" 17 = "17*(%sysfunc(cats(&s_17,"|",&d_17)))"  23 = "23*(%sysfunc(cats(&s_23,"|",&d_23)))" 28 = "28*(%sysfunc(cats(&s_28,"|",&d_28)))" 
			6 = "6*(%sysfunc(cats(&s_6,"|",&d_6)))" 12 = "12*(%sysfunc(cats(&s_12,"|",&d_12)))" 18 = "18*(%sysfunc(cats(&s_18,"|",&d_18)))"  29 = " "
			;
*/
	run;


%mend size;

%size(sofa);
%size(sofa_sur);
%size(sofa_dead);

data sofa_all;
	merge sofa_sur(keep=day estimate rename=(estimate=estimate_sur)) sofa_dead(keep=day estimate rename=(estimate=estimate_dead));
	by day;
 	if day=. then delete;
run;

proc sort data=sofa_all nodup; by day;run;

	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

	/* Set up symbol for Boxplot */
	symbol1 interpol=none mode=exclude value=circle co=red cv=blue height=1 bwidth=3 width=2;
	/* Set up Symbol for Data Points */
	symbol2 i=j ci=red value=dot h=1 w=2;

	axis1 	label=(f=zapf h=1.5 "Day in SICU" ) split="*"	value=(f=zapf h= 1.25)  order= (0 to 29 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Total SOFA Score") value=(f=zapf h=2) order= (0 to 24 by 2) offset=(.25 in, .25 in) minor=(number=1); 

	legend1 across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=3 "sofa" "mean") offset=(0, -0.4 in) frame;

	legend2 across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=3 "Survivor" "Non-Survivor") offset=(0, -0.4 in) frame;
	                
	title1	height=3 f=zapf "Total SOFA Score (n=&num_pat)";
	title2	height=2 f=zapf 'Longitudinal model (means and 95% CI)';

	* plot! ;
	*ods pdf file = "/glnd/sas/reporting/sofa_plot_censor_adjust_open.pdf";
	ods pdf file = "sofa_plot_censor_adjust_open.pdf";
	ods ps file = "sofa_plot_censor_adjust_open.ps";
			proc gplot data= sofa;
				plot sofa_tot*day2 estimate*day/overlay annotate= anno_mixed_sofa haxis = axis1 vaxis = axis2 legend=legend1;

				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
						
				format day day2 day_glnd_sofa.; 
			run;	
			

	/* Set up symbol for Boxplot */
	symbol1 interpol=j mode=exclude value=dot co=red cv=blue height=2 bwidth=3 width=4;
	/* Set up Symbol for Data Points */
	symbol2 i=j ci=red value=circle h=2 w=4;


	title1	height=3 f=zapf "Total SOFA Score for Survivors (n=%sysfunc(strip(&num_sur))) and Non-Survivors(n=%sysfunc(strip(&num_dead)))";
	title2	height=2 f=zapf 'Longitudinal model (means and 95% CI)';

data anno_mixed_sofa_all;
	set anno_mixed_sofa_sur anno_mixed_sofa_dead; 
	by day;
run;

			proc gplot data= sofa_all;
				plot estimate_sur*day estimate_dead*day/overlay annotate= anno_mixed_sofa_all haxis = axis1 vaxis = axis2 legend=legend2;

				* annotate with sample sizes - more should be added if we have more data on dat 23, 24...;
				note h=1.5 m=(7pct, 8.5 pct) "Day:" ;
				note h=1.5 m=(7pct, 7 pct) " (n)" ;
				note f='zapf / it' m=(10,2) h=1.25 "# &s_1 = Survivors,  &d_1 = Non-Survivors";
						
				format day day_glnd_sofa_all. estimate_sur estimate_dead 2.0; 
			run;	

	
	ods ps close;
	ods pdf close;


		ods pdf file="sofa_mixed_mean.pdf" style=journal;
	title1	height=3 f=zapf 'Total SOFA score longitudinal model means';

		* now make a table of the means and 95% CI for sofa score on days 0, 7, 14;
		data glnd_rep.sofa_mixed_open;
				merge lsmeans_sofa(keep = estimate upper lower day) 
						 sizes_sofa(keep=day num_obs rename=(num_obs=num_all))
						 lsmeans_sofa_sur(keep = estimate upper lower day rename=(estimate=estimate_s upper=upper_s lower=lower_s))
						 sizes_sofa_sur(keep=day num_obs rename=(num_obs=num_sur)) 
						 lsmeans_sofa_dead(keep = estimate upper lower day rename=(estimate=estimate_d upper=upper_d lower=lower_d))
						 sizes_sofa_dead(keep=day num_obs rename=(num_obs=num_dead));		
			by day;
			
			where day in (1, 7, 14);
 			sofa_t = strip(put(estimate, 5.1)) || " (" || strip(put(lower, 5.1)) || ", " || strip(put(upper, 5.1))|| ")";
			sofa_s = strip(put(estimate_s, 5.1)) || " (" || strip(put(lower_s, 5.1)) || ", " || strip(put(upper_s, 5.1))|| ")";
			sofa_d = strip(put(estimate_d, 5.1)) || " (" || strip(put(lower_d, 5.1)) || ", " || strip(put(upper_d, 5.1))|| ")";
			
			label
				day = "Day"
				sofa_t = "Total Sofa Score*mean (95% CI)"
				sofa_s = "Total Sofa Score for Survivor*mean (95% CI)"
				sofa_d = "Total Sofa Score for Non-survivor*mean (95% CI)"
				num_all="Num. of Patients"
				num_sur="Num. of Survivors"
				num_dead="Num. of Non-Survivors"
			;
		
		   format day;

		  	keep day num_all sofa_t num_sur sofa_s num_dead sofa_d;
		run;

			proc print data = glnd_rep.sofa_mixed_open noobs label style(data) = [just=center];
				var day num_all sofa_t num_sur sofa_s num_dead sofa_d ;
			run;
	
		ods pdf close;




