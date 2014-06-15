/* recruitment_by_center.sas 
 *
 * Eli Rosenberg
 * 
 * generates curves of expected versus actual recruitment for GLND
 *
 * actual recruitment determined from the number of patient enrollment forms received (plate 8)
 */
 

/* UPDATED 4/5/2007 to have Emory only start on 11/06. This is reference month 1 */




%macro recruitment_by_center; 
	%let i= 1;
	%let center_name = "Emory";

	proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run; 
  	%do %while (&i < 6);

		/* COMMENTED OUT
		%if &x = 1 %then %do; %let variable = il6;  %end; 
		%if &x = 2 %then %do; %let variable = il8;%let name = f=zapf 'B)'  ; %let description = f=zapf 'IL-8 (pg/ml)' ; %let scale = order = (0 to 50 by 5) minor=none; %let y1 = 3.23; %let y2= 24.5; %end; 
		%if &x = 3 %then %do; %let variable = ln_il6;  %let name = f=zapf 'A)' ;%let description = f=zapf 'log10(IL-6) [log10(pg/ml)]' ; %let scale = order = (-1 to 2) minor = (number=9); %let y1 = -.35; %let y2=1; %end; 
		%if &x = 4 %then %do; %let variable = ln_il8;%let name = f=zapf 'B)'  ; %let description = f=zapf 'log10(IL-8) [log10(pg/ml)]' ; %let scale = order = (-1 to 3 ) minor = (number=9); %let y1 = .51; %let y2= 1.39; %end; 
		*/

 	data temp8;
 		set glnd.plate8;

		center = floor(id/10000);
 		call symput( "center_name", compress(put(%eval(&i), center.))); * assign center names according to the formats ;

 		/* indicate study month as a number. 
 		* recruitment officially started on December 1st 2006. Although Emory recruited in November and these patients
		* will be included in the first month */

		if (month(dt_random) = 11) & (year(dt_random) = 2006) then study_month = 1; * the first month (Emory Only);
		else if (month(dt_random) = 12) & (year(dt_random) = 2006) then study_month = 2; * the second month (Emory Only);
		else study_month = ((year(dt_random) - 2007) * 12)  + month(dt_random) + 2; * for all other months;
 	run;
	
	* get totals patients per month;
	proc sort data= temp8;	by study_month;	run;

	proc means data= temp8 n noprint;
		where center = %eval(&i); /*** Subset the data by center ***/

		by study_month;
 		var id;
 		output out= recruit_n n= n_patients;
 	run;
	

	* create recruitment dataset by making one entry for each study month and merging with the per month totals from PROC MEANS;
	data glnd.recruitment;	
		do study_month = 1 to ( ((year(today()) - 2007) * 12)  + month(today())   /* <== '-1'Added by Eli temporarily 7/9/07, 8/6/07. THIS ALLOWS YOU TO GO BACK A MONTH*/ + 2); * 1 to the current month;
			output;
			put study_month;
		end;
		call symput('stop_month', study_month - 1); * assign last month to a macro variable. after above loop ends, month is +1 of where it should be so subtract 1;
		put study_month;
	run;

	data glnd.recruitment;
		merge glnd.recruitment recruit_n;	
		by study_month;
	
		if n_patients = . then n_patients = 0; * if a month has no patients;

		drop _type_ _freq_;
	run;

  * run a macro to calculate the cumulative sum at each month;
  proc options option = macro;  
  run;

	%macro sum_patients;
		
		* for now sums will have just the first record;
		data sums;
			set glnd.recruitment;
			where study_month = 1 ;

			sum_patients = n_patients;
			keep study_month n_patients sum_patients;
		run;

  		%do x = 2 %to &stop_month; * second number is study to month to finish at ;
  			
			* capture recruitment sum <= this month;
			proc means data= glnd.recruitment n sum  noprint;
				where study_month <= &x;
				var n_patients;
		 		output out= temp_sums sum= sum_patients;
			run;

			* add in the month ;
			data temp_sums;
				set temp_sums;
				study_month = &x;
			run;

			* add to growing total;
			data sums;
				set sums temp_sums;
				drop _TYPE_ _FREQ_;
				
			run;
			
		%end;
	%mend sum_patients;
	%sum_patients run;
	
	data sums;
		set sums;
		drop n_patients;	
	run;

	* merge the cumulative sum data with the original patient counts at each month;
	data glnd.recruitment;
		merge glnd.recruitment sums;
		by study_month;
	
	* create projections for all future months;
	data temp;
		do study_month = 1 to 51; * 39 months gives us ~150 patients - project recruitment needed is 150 patients;
			
			* change the expectations depending on center;
			%if &i = 1 %then %do;
				expected_patients = study_month; * emory started at month 1;
			%end;

			%if &i = 2 %then %do;
				if study_month in (1,2) then expected_patients = 0; 
				else if study_month < 34 then expected_patients =  study_month - 2; 
				else expected_patients = 31; * As of August 2009, Miriam is no longer expected to be enrolling patients. thus they stop at 31; 

			%end;

			%if &i = 3 %then %do;
				if study_month in (1,2) then expected_patients = 0; 
				else expected_patients =  study_month - 2; 
			%end;

			%if &i = 4 %then %do;
				if study_month in (1,2,3) then expected_patients = 0; 
				else expected_patients =  study_month - 3; 
			%end;
		

			* Wisconsin starts November 2009 ;
			%if &i = 5 %then %do;
				if study_month < 37 then expected_patients = 0; 
				else expected_patients =   study_month - 36; 
			%end;
		

			actual_month = 17122 + (30*(study_month-1)); * adds 30 days to 11/17/06 for each month. yes, this is not perfect but it should work for our date range.;
	
			output;
		end;
		
		format actual_month MONYY5. ; * give formatting (for graph labels);
	run;



	* merge projections with actual recruitment information;
	data glnd.recruitment;
		merge glnd.recruitment temp;
		by study_month;
	run;

	* capture some variables from the current month for display on the graph;
	* we want the number expected/actually recruited as well as the current month and year;
	data;
		set glnd.recruitment;
		where sum_patients ~= .;
		by study_month;


		if last.study_month then do;
			
			call symput('act_sum', compress(put(sum_patients, 3.0))); * store the last sum of patients recruited for later display;
			call symput('cur_month',  compress(put(actual_month, monname9. )));
			call symput('cur_year', compress(put(actual_month, year4.)));
			call symput('cur_exp', compress(put(expected_patients, 3.0))); * capture expected patients for this month;
			
			per_rec = (sum_patients/expected_patients)*100;
			call symput('percent_recruit', compress(put(per_rec, 5.1)));
		end;
	run;
	* plot both estimated and actual recruitment;
	goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;
  		
		
	 	symbol1 value = "dot" h=2 i=join;
 		symbol2 value =  none h=3 i=join line=21 ;
 		
 		axis1 	label=(f=zapf h=3 'Study Month' ) value=(f=zapf h=1.5) 
					order= (17122 to 18627 by 91)	major=(h=3 w=2) minor=(number=2 h=1) ; * 17113 to 18253;
 		axis2 	label=(f=zapf h=3 a=90 'Patients Recruited' ) 	value=(f=zapf h=3) 
					order= (0 to 60 by 10) 	major=(h=1.5 w=2) minor=(number=9 h=1) ;
 		
 		legend1 across=1 down=2 position=(top right outside) mode=protect
 			shape=symbol(3,2) label=(f=zapf h= 2.5 '')
 			value=(f=zapf h=2.5 'Actual' 'Expected')
			offset= (-13, -2.5 );
 		
		title1 f=zapf h=3 justify=center underlin = 2 "&center_name";
 		title2 f=zapf h=3 justify=center "GLND Patient Recruitment Summary - through &cur_month &cur_year";
 		title3 f=zapf h=3 justify=center "&act_sum patients recruited of &cur_exp expected (&percent_recruit%)";

			proc gplot data= glnd.recruitment gout= glnd_rep.graphs; 
 				plot sum_patients*actual_month expected_patients*actual_month / overlay haxis=axis1 vaxis=axis2 legend=legend1; 
 			run;
			proc print data= glnd.recruitment; 
 				var sum_patients expected_patients actual_month ; 
 			run;

	%let i = &i + 1;
%end;

%mend recruitment_by_center;


	%recruitment_by_center run;

	* tile into one happy picture;
        *ods ps file = "/glnd/sas/reporting/recruitment_by_center.ps";
	ods pdf file = "/glnd/sas/reporting/recruitment_by_center.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs; 
            list igout;
			treplay 	1:gplot  2:gplot2
					3:gplot1 4:gplot3;
		run;
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= whole nofs; 
            list igout;
				treplay 	1:gplot4;
		run;
	ods pdf close;
        *ods ps close;

* use greplay to tile;



