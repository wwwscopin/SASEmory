/* QC_report.sas
 *
 * finalized 7/7/08
 *
 * new version of the monthly QC report. now gives median and range days to resolution as well as a quotient of QCs / page submitted.
 * 
 * to do this, the program now directly rads the QC database from Datafax, rather than using the built-in datafax QC report (though this report
 * is still called in order to obtain the "pages submitted" numbers)
 *
 */

	*	Unlike the previous qc_status_data, we do not need to save and store each month in a separate file, since I will not be
		reporting the number of QCs originally resolved in the first month of issue. this report will display the current
		state of QCs issued in the last 6 months, with median (min, max) time to resolution  ;


options mprint mlogic;

**** export the QC notes from the dedicated datafax plate (511) for QCs to a text file ;

	data _NULL_;
		command = "$DATAFAX_DIR/bin/DFexport.rpc -s all 12 511 /glnd/sas/reporting/df_reporting/current_qcnotes.dat";	
		
		call symput('command1', command);
	run;
	
	data _NULL_;
		x "&command1";
	run;


**** read in QC data - adapted from a program by George ****;

	data glnd_df.qcs;
	  	infile '/glnd/sas/reporting/df_reporting/current_qcnotes.dat' dlm='|' dsd lrecl=2000 missover;
	  	length f3 $ 12;
	 	length f13 $ 150;
		length f14 $ 150;
	 	length f17 $ 500 f18 $ 500 f19 $ 50 f20 $ 50 f21 $ 50;
	
		  input
		    f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
		    f13 f14 f15 f16 f17 f18 f19 f20 f21 f22;
	
		* f1 = status
		* f5 = plate #
		* f6 = reader code + 4000
		* f7 = id
		* f8 = field #+3
		* f13 = field name
		* f15 = problem code
		;
		  status = f1;
		  plate = f5;
		  dfseq = f6;
		  id = f7;
		  field = f8+3;	
		  name = f13;
		  problem_code = f15;
	
		center = f9;
		report_num = f10;
	
		creation_string = f19;
		last_modify_string = f20;
		resolution_string = f21;
		usage_code = f22;



	run;
	
	proc print;
	where center=1 and plate=47 and dfseq=1;
	run;
	



**** post-process data ****;
	
	data glnd_df.qcs;
		set glnd_df.qcs (keep = 	status plate field plate dfseq center report_num problem_code creation_string last_modify_string
						resolution_string usage_code) ;
	
		** parse creation, last modified, and resolved dates ;

		creation_string = substr(creation_string, find(creation_string, " ") + 1, 8);
		creation_date = mdy(substr(creation_string, 4, 2) , substr(creation_string, 7, 2) , substr(creation_string, 1 , 2)); 

		last_modify_string = substr(last_modify_string, find(last_modify_string, " ") + 1, 8);
		last_modify_date = mdy(substr(last_modify_string, 4, 2) , substr(last_modify_string, 7, 2) , substr(last_modify_string, 1 , 2)); 

		resolution_string = substr(resolution_string, find(resolution_string, " ") + 1, 8);
		resolution_date = mdy(substr(resolution_string, 4, 2) , substr(resolution_string, 7, 2) , substr(resolution_string, 1 , 2)); 


		** make new variables ;
		days_to_resolution = resolution_date - creation_date; 

		month = month(creation_date);
		year = year(creation_date);

		format creation_date last_modify_date resolution_date date. center center. ;
		
		drop creation_string last_modify_string resolution_string;
	run;	
	
	



	** restrict to external QCs, that are non-missing page but field-specific QCs, within the desired time range **;
		
		* store month range in macro variables ;
		data _NULL_;

				*cur_month = month(today());
				*cur_year = year(today());
				
				cur_month = 12;
				cur_year = 2011;

				call symput('cur_month', cur_month);
				call symput('cur_year', cur_year);


				* if July onwards, then all months within the current year;
				if cur_month > 6 then do;
					call symput('stop_month', cur_month - 6);
					call symput('stop_year', cur_year);
				end;
			
				* otherwise the stop month is last year;
				else do;
					call symput('stop_month', cur_month + 6);
					call symput('stop_year', cur_year - 1);
				end;
				
			
		run;
		%put &stop_month;
		%put &cur_month;


		data glnd_df.qcs;
			set glnd_df.qcs ;
	
			where 	(usage_code = 1) & (problem_code < 21 ) &
					(creation_date > mdy(&stop_month, 01, &stop_year) ) & (creation_date < mdy(&cur_month, 01, &cur_year) );	
		run;
		


**** collect descriptive statistics on QCs, by center ****;

	proc means data = glnd_df.qcs n mean median min max fw = 5 maxdec = 0;


		class year month center;
		var days_to_resolution;

		* n for days_to_resolution is a surrogate for the number of QCs resolved, since the dates are therefore non-missing ;

		output out = qc_stats n(days_to_resolution) = days_n median(days_to_resolution) = days_med min(days_to_resolution) = days_min max(days_to_resolution) = days_max;
	
	run;

	** post-process means output ;
	data qc_stats;
		set qc_stats (rename = (_freq_ = qcs_created));

		where _TYPE_ in (6, 7); * keep the month and center within month total only ;
		
		month_display = put(mdy(month , 1 , year), monname.) || " " || put(year, 4.0) ; 

		resolved_display = compress(put(days_n, 4.0)) || " (" || compress(put((days_n/qcs_created)*100 ,4.0)) || "%)";
		
	*	if (tot_qcs = 0) then resolved_display = "--"; 
			

		if _type_ = 6 then do;
			center = 999; * This assigns the row to become a "TOTAL:";
			output;

			* insert a blank spacer row;

		end;
		
		output;
		drop _type_ ;
	
	run;

*** Now loop through the last 6 months and call the old, built-in DataFax QC query to obtain the number of pages submitted in each month ***;

	%macro get_total_records (month = , year = , first_record= );

		data _NULL_;
		
			month = input(&month, 2.0); 
			year = input(&year, 2.0);
		
			if month ~= 1 then do;
				last_month = month - 1; 
				last_year = year; * same year for both months;
			end;
		
			else do;
				last_month = 12;
				last_year = year -1 ;
			end;
		
			* assign todays month and year to macro vars ;
		
			if month > 9 then month_t = compress(put(month, 2.0));
				else month_t = "0" || compress(put(month, 2.0));
		
			if last_month > 9 then last_month_t = compress(put(last_month, 2.0));
				else last_month_t = "0" || compress(put(last_month, 2.0));
		
			**** make 2-digit year ;
			if year < 10 then year_t = "0" || compress(put(year, 2.0)); else year_t = compress(put(year, 2.0)); * 2010 or beyond;
			if last_year < 10 then last_year_t = "0" || compress(put(last_year, 2.0)); else	last_year_t = compress(put(last_year, 2.0)); 
			

			filename = "qc_status_current.txt"; 				* || compress(month_t) || "_20" || compress(year_t) || ".txt" );	
			command = "/usr/local/apps/datafax/reports/DF_CTqcs 12 -t " || compress(last_year_t) || "/" || compress(last_month_t) || "/01-" || compress(year_t) || "/" || compress(month_t) || "/01 > /glnd/sas/reporting/df_reporting/" || compress(filename);	
			command2= "cp qc_status_current.txt qc_" || month_t || ".txt";
			call symput('last_month_t', last_month);
			call symput('last_year_t', last_year);

			call symput('filename', filename);	
			call symput('command1', command);
			call symput('command2', command2);

		run;
		
		data _NULL_;
			x "&command1";
			x "&command2";
		run;
		 
		* read first half of the columns (the first table);
		data DF_qc_report;
			infile "&filename"  missover firstobs=9 obs=13 ; * when importing a file from the cumulative QC report: firstobs= 12 obs=18 ;
			input center tot_records tot_qcs rate_100_rec num_resolved pct_resolved correct na irrel days;
		run;	
		
		** post-process. add month and year stamps **;
		data DF_qc_report;
			set DF_qc_report;
			retain last_center;
			
			* if there were not 4 or 5 centers submitting data last month, then this total record may have entered in.
				delete this ;
			if (center = 100) then DELETE ;
	
			month = input(compress("&last_month_t"), 2.); 
			year = input(compress("&last_year_t"), 2.) + 2000;
				

			month_display = put(mdy(month , 1 , year), monname.) || " " || put(year, 4.0) ; 

			** This snippet of code handles the situation where a site has not submitted data for a given
				month. This causes the DF qc output to be missing a line for that center. I recreate 
				the line here. This happened when Miriam submitted no forms in October 2008;
				
				if _N_ = 1 then last_center = 1;
				else if (center ~= last_center + 1) then do;
						center = last_center + 1;
						old_total = tot_records;
						tot_records = 0;
						output;	
						
						center = center + 1;
						tot_records = old_total;
						last_center = last_center + 2;
				end;

				else last_center = last_center + 1;
				
				if month=11 and center=5 then tot_records=0;

				output;
			
			
						
			format center center.;		

			*keep center tot_records month year month_display;
		run;
		
		
		** stack! ;
		data DF_qc_report_stacked;
	
			%if &first_record = "Yes!" %then %do; 
				set DF_qc_report;
			%end;
			%else %do; 
				set	DF_qc_report_stacked
					DF_qc_report;
			%end;

		run;

		proc print data = DF_qc_report_stacked;
		run;


	%mend get_total_records;

	data _NULL_;
		*cur_month = month(today());
		*cur_year = year(today()) - 2000;
		cur_month = 12;
		cur_year = 2011 - 2000;
		
		call symput("month_1", compress(put(cur_month, 2.)) );
		call symput("year_1", compress(put(cur_year, 2.)) );

		if cur_month - 1 > 0 then do;	
			call symput("month_2", compress(put(cur_month - 1, 2.)) );
			call symput("year_2", compress(put(cur_year, 2.)) );
		end;
		else do;	
			call symput("month_2", compress(put(11 + cur_month, 2.)) );
			call symput("year_2", compress(put(cur_year - 1, 2.)) );
		end;

		if cur_month - 2 > 0 then do;	
			call symput("month_3", compress(put(cur_month - 2, 2.)) );
			call symput("year_3", compress(put(cur_year, 2.)) );
		end;
		else do;	
			call symput("month_3", compress(put(10 + cur_month, 2.)) );
			call symput("year_3", compress(put(cur_year - 1, 2.)) );
		end;

		if cur_month - 3 > 0 then do;	
			call symput("month_4", compress(put(cur_month - 3, 2.)) );
			call symput("year_4", compress(put(cur_year, 2.)) );
		end;
		else do;	
			call symput("month_4", compress(put(9 + cur_month, 2.)) );
			call symput("year_4", compress(put(cur_year - 1, 2.)) );
		end;

		if cur_month - 4 > 0 then do;	
			call symput("month_5", compress(put(cur_month - 4, 2.)) );
			call symput("year_5", compress(put(cur_year, 2.)) );
		end;
		else do;	
			call symput("month_5", compress(put(8 + cur_month, 2.)) );
			call symput("year_5", compress(put(cur_year - 1, 2.)) );
		end;

		if cur_month - 5 > 0 then do;	
			call symput("month_6", compress(put(cur_month - 5, 2.)) );
			call symput("year_6", compress(put(cur_year, 2.)) );
		end;
		else do;	
			call symput("month_6", compress(put(7 + cur_month, $2.)) );
			call symput("year_6", compress(put(cur_year - 1, $2.)) );
		end;

	run;

	data _NULL_
		%get_total_records(month = "&month_1", year = "&year_1", first_record = "Yes!");
		%get_total_records(month = "&month_2", year = "&year_2", first_record = "No!");
		%get_total_records(month = "&month_3", year = "&year_3", first_record = "No!");
		%get_total_records(month = "&month_4", year = "&year_4", first_record = "No!");
		%get_total_records(month = "&month_5", year = "&year_5", first_record = "No!");
		%get_total_records(month = "&month_6", year = "&year_6", first_record = "No!");
	run;


	** remove bogus centers that appear from DFctQC report, when not every center submits forms in a given month;
	data DF_qc_report_stacked;
		set DF_qc_report_stacked;
		if ~(center in (1,2,3,4,5,999)) then DELETE ;
	run;
	
	** get totals for each month ;
	data DF_qc_report_stacked;
		set DF_qc_report_stacked;
		by year month NOTSORTED;
		retain sum;
		
		if ~(center in (1,2,3,4,5,999)) then DELETE ;

		
		if first.month then sum = tot_records;
		else sum = sum + tot_records;

		output;

		if last.month then do;
			
			center = 999 ; * total;
			tot_records = sum;
			output;
		end;


		drop sum;
	run;



** Sort and merge descriptive stats and total records **;

	proc sort data = DF_qc_report_stacked; by year month center; run;
	proc sort data = qc_stats; by year month center; run;

	data QC_display_table;
		merge
			DF_qc_report_stacked
			qc_stats;

		by year month center;
		
		qc_quotient = qcs_created / tot_records;
		format qc_quotient 5.3;

		resolved_stats = compress(put(days_med, 4.0)) || " [" || compress(put(days_min, 4.0)) || "-" || compress(put(days_max, 4.0)) || "]";

		if (center ~= 1) then month_display = "";

		** if there are no QCs, make things still look nice ;
		if (qcs_created = .) then do;
			qcs_created = 0;
			qc_quotient = 0;
			resolved_display = "--";
			resolved_stats = "--";
		end;


		*** format rows, making blanks, etc ;
	*	if last.year & last.month then delete; * don't need this last repeat total row;

		else if last.month then do; * make blank lines ;
			month_display = "";
			center = .;
			tot_records = .;
			qcs_created = .;
			qc_quotient = .;
			resolved_display = "";
			resolved_stats = "";
			
		end;


		label
			month_display = '00'x
			center = "Center"
			tot_records = "Pages submitted"
			qcs_created = "QCs issued"
			qc_quotient = "QCs / page*"
			resolved_display = "QCs resolved*n (%)"
			resolved_stats = "Days to resolution*med. [range]"

		;

	run;


	proc print data = DF_qc_report_stacked; run;
	proc print data = qc_stats;  run;

	*MERGE AND LAY OUT TABLE! 

 * by year month center;


ods ps file = "/glnd/sas/reporting/df_reporting/qc_report.ps" style = journal;
ods pdf file = "/glnd/sas/reporting/df_reporting/qc_report.pdf" style = journal;
	options nodate nonumber;

	title1 "Data Query Report:";
	title2 "Quality Control (QC) Notes Issued Over the Last 6 Months";
 
	proc print data = QC_display_table label noobs split ="*";  


		* This table prints zeroes for Wisconsin in the months before it came onboard (nov 09). it will also print zeroes for 
			Miriam, though it has been inactive since summer 2009 (will turn off after october 09. suppress these zeroes until we 6 months
			out from Nov. 2009  ;
		where ~(( (year = 2009) & (month < 11) & (center = 5))			/* Wisconsin */ 
			| ( (year = 2009) & (month >= 11) & (center = 2) ) | ((year > 2009) & (center = 2)) )	;	/* Miriam */



		var month_display center tot_records qcs_created qc_quotient ;
		var resolved_display /style(data) = [just=center];
		var resolved_stats /style(data) = [just=center];
	run;

ods pdf close;
ods ps close;
