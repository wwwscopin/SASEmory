
proc format library= work;

	value center
		1='Emory'
		2='Miriam'
		3='Vanderbilt'
		4='Colorado'
       5='Wisconsin'
	;
	
	value visit
	        1 = "Baseline"
                2 = "Day 3"
                3 = "Day 7"
                4 = "Day 14"
                5 = "Day 21"
                6 = "Day 28"
                7 = " "
	;
	
run;

proc sort data = glnd.status; by id; run; 

**** Add missed blood draws to the table - 5/12/08 ****;

	data blood;
		merge 
			glnd.plate15 (in = from_blood)
			glnd.status (in = from_status keep = id dt_random);
			
		by id;
		
		if ~from_blood then delete;
		
		* assign DSMB reporting period to each person!;
		
		if dt_random <= mdy(3,6,2007) then do; dsmb_freeze = 1; freeze_date = "11/1/2006 - 3/6/2007 "; end;
		else if dt_random <= mdy(8,20,2007) then do; dsmb_freeze = 2; freeze_date = "3/7/2007 - 8/20/2007"; end;
		else if dt_random <= mdy(1,03,2008) then do; dsmb_freeze = 3; freeze_date = "8/21/2007 - 1/3/2008"; end;
		else if dt_random <= mdy(7,24,2008) then do; dsmb_freeze = 4; freeze_date = "1/4/2008 - 7/24/2008"; end;
		else if dt_random <= mdy(3,06,2009) then do; dsmb_freeze = 5; freeze_date = "7/25/2008 - 3/6/2009"; end;
		else if dt_random <= mdy(8,31,2009) then do; dsmb_freeze = 6; freeze_date = "3/7/2009 - 8/31/2009"; end; 
     	else if dt_random <= mdy(3,01,2010) then do; dsmb_freeze = 7; freeze_date = "8/31/2009 - 3/1/2010"; end; 
 		else if dt_random <= mdy(10,11,2010) then do; dsmb_freeze = 8; freeze_date = "3/1/2010 - 10/11/2010"; end; 
 		else if dt_random <= mdy(4,4,2011) then do; dsmb_freeze = 9; freeze_date = "10/11/2010 - 4/4/2011"; end; 
 		else if dt_random <= mdy(4,5,2012) then do; dsmb_freeze = 10; freeze_date = "4/4/2011 - 4/5/2012"; end; 
	
		* add center;
		center = floor(id /10000);
		
		format center center. dfseq visit.;
	run;
	
	proc means data = blood n sum;
		id freeze_date;
		class dsmb_freeze center dfseq;
		var missed_blood_drw;
		output out = missed_blood sum(missed_blood_drw) = total_missed_draws;
	run;

	
	* clean up FREQ output;  
	data missed_blood;
		set missed_blood;

		where _TYPE_ = 7; * full rows of freeze, center, dfseq;

		attended_visit_total = _FREQ_ - total_missed_draws;

		attended_visit_disp = compress(put(attended_visit_total, 4.0)) || "/" || compress(put(_FREQ_, 4.0)) || " (" || compress(put(attended_visit_total / _FREQ_ * 100, 4.1 )) || "%)";
		
		order = 9 + dfseq; * so we can merge this into the main table;

	run;


	proc print data = missed_blood;
		by dsmb_freeze;
		id dsmb_freeze;
		var center dfseq attended_visit_disp;
	
	run;
	
	proc sort data = missed_blood; by dsmb_freeze dfseq center;	run;
	
	* currently, center data is stacked, but let's make each center a column! ;
	proc transpose data = missed_blood out = missed_blood_t;
		by dsmb_freeze dfseq;
		id center;
		var attended_visit_disp;
	run;

	proc print data = missed_blood_t;
	run;

	* add back the date of freeze to each line;
	
	data missed_blood_t;
		merge 
			missed_blood_t (in = from_transposed)
			missed_blood (in = from_original keep = dsmb_freeze freeze_date);
			
		by dsmb_freeze;
		
	run;
	
	data missed_blood_t;
		set missed_blood_t;
		by dsmb_freeze dfseq;
		

		if ~first.dfseq then delete; * for some reason we get repeat lines, even if i try to control this with in= statements ;
		
		* add place-holder in blank cells that indicate no patients;
		if Emory = "" then Emory = "--";
		if Miriam = "" then Miriam = "--";
		if Vanderbilt = "" then Vanderbilt = "--";
		if Colorado = "" then Colorado = "--";
     		if Wisconsin = "" then Wisconsin = "--";

		blank_col = ":                   ";
		
		output;
		
		* add blank line after each freeze;		
		if (dfseq = 6) & (dsmb_freeze ~= 1) then do;
			dfseq = 7;
			blank_col ="";
			Emory = "";
			Miriam ="";
			Vanderbilt ="";
			Colorado = "";
           		Wisconsin = "";
			output;
		end;
		

	run;	
		

run;

proc sort data = missed_blood_t; by descending dsmb_freeze; run;

options ls=80 nodate nonumber; 

ods pdf file = "/glnd/sas/reporting/df_reporting/form_submission_blood_a.pdf" style = journal;
ods ps file = "/glnd/sas/reporting/df_reporting/form_submission_blood_a.ps" style = journal;
	title1 "Succesful blood collection at scheduled visits";
	title2 "for new patients enrolled during each DSMB reporting period";
	proc print data = missed_blood_t noobs label style(header) = [just=center] width = full split="*";
		by freeze_date NOTSORTED;
		id freeze_date;
		

		var dfseq /style(data) = [just=left];
		var blank_col;
		*var Emory Miriam Vanderbilt Colorado Wisconsin /style(data) = [just=center]; 
		var Emory Vanderbilt Colorado Wisconsin /style(data) = [just=center]; 
		
*format Emory $40.;
		
		label 
			freeze_date = "Period"
			dfseq = "Visit"
			blank_col = '00'x
		
		;
		where dsmb_freeze>5;
	run;
ods ps close;
ods pdf close;


ods pdf file = "/glnd/sas/reporting/df_reporting/form_submission_blood_b.pdf" style = journal;
ods ps file = "/glnd/sas/reporting/df_reporting/form_submission_blood_b.ps" style = journal;
	title1 "Succesful blood collection at scheduled visits";
	title2 "for new patients enrolled during each DSMB reporting period";


	proc print data = missed_blood_t noobs label style(header) = [just=center] width = full split="*";
		by freeze_date NOTSORTED;
		id freeze_date;
		where dsmb_freeze<4;
		var dfseq /style(data) = [just=left];
		var blank_col;
		*var Emory Miriam Vanderbilt Colorado Wisconsin /style(data) = [just=center]; 
		var Emory Vanderbilt Colorado Wisconsin /style(data) = [just=center]; 
		
*format Emory $40.;
		
		label 
			freeze_date = "Period"
			dfseq = "Visit"
			blank_col = '00'x
		
		;
		where 1<dsmb_freeze<6;
	run;

ods ps close;
ods pdf close;
