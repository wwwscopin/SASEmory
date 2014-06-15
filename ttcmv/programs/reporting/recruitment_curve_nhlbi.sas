
%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


data recruited_all;	set cmv.plate_001 (rename = (isEligible = enrolled));

	if enrollmentdate ~= .;

	center = floor(id/1000000);
	format center center.;

	format date monyy5.;
	date = mdy(month(enrollmentdate), 1, year(enrollmentdate));

run;


	proc sort data = recruited_all; by date id; run;
	data cmv.recruited_all; set recruited_all; run;

	* compute number recruited each month;
	proc means data= recruited_all noprint;
		class date;
		output out = total_recruit_all n(id) = num_recruit;
	run;

	* compute cum. sum. at each month;
	data total_recruit_all; set total_recruit_all;
		where _type_ = 1;
		retain sum_recruit;
		if _N_ = 1 then sum_recruit = num_recruit;
		else sum_recruit = sum_recruit + num_recruit;

		format sum_recruit 3.0;
	run;

	* capture the total # recruited;
	data total_recruit_all; set total_recruit_all;
		by date;
		if last.date then do;
			call symput('act_sum', compress(put(sum_recruit, 3.0)));
			this_month_flag = 1;
		end;
	run;

	* generate expected recruitment ;
	data expected_recruit_all;
		do month = 1 to 12;
			date = mdy(month, 1, 2010);
		output;
		end;
		do month = 1 to 12;
			date = mdy(month, 1, 2011);
		output;
		end;
		do month = 1 to 12;
			date = mdy(month, 1, 2012);
		output;
		end;
	run;

	data expected_recruit_all; set expected_recruit_all;
		retain expected_recruit;
		if _N_ = 1 then expected_recruit = 2;
		else if _N_ = 2 then expected_recruit = expected_recruit + 4;
		else if _N_ = 3 then expected_recruit = expected_recruit + 6;
		else if _N_ = 4 or _N_ = 5 or _N_ = 6 or _N_ = 7 then expected_recruit = expected_recruit + 8;
		else expected_recruit = expected_recruit + 15;		
	run;

	data expected_recruit_all; set expected_recruit_all;
		seventyfive_percent = expected_recruit * 0.75;
		fifty_percent = expected_recruit * 0.5;
	run;

	proc sort data = total_recruit_all; by date; run;
	proc sort data = expected_recruit_all; by date; run;
	data total_recruit_all; 
		merge total_recruit_all expected_recruit_all; 
		by date; 

		if this_month_flag = 1 then do; 
			call symput('exp_sum', compress(put(expected_recruit, 3.0)));	
			call symput('exp_pct', compress(put((sum_recruit/expected_recruit)*100, 2.0)));
		end;
	run;



* PLOT recruitment ;

		* If you leave out the colors statement here, the symbols statements don't work. Isn't that awesome??? ;
		goptions reset=all rotate=landscape gunit=pct device=png noborder cback=white colors=(black) ftitle=times ftext=times;
	
		symbol1 value = "dot" h=2 w=4 i=join line=21;
		symbol2 value = none h=3 w=3 c="green" i=join;
		symbol3 value = none h=3 w=3 c="orange" i=join;
		symbol4 value = none h=3 w=3 c="red" i=join;

 		axis1 	label= (f=times h=3 'Study Month')
					value= (f=swiss h=1.5) 
					order= (18263 to 19358/*18992*/ by 90)
					major= (h=3 w=2) 
					minor= none
		;

 		axis2 	label= (a=90 f=times h=3 'Patients Recruited') 
					value= (f=times h=2) 
					order= (0 to 400 by 25) 
					major= (h=1.5 w=2) 
					minor= (number=3)
		;

 		legend1 across=1 down=2 position=(top right outside) mode=protect
 			shape=symbol(3,2) label=(f=times h=2 '')
 			value=(h=2 'Actual' 'Target' '75% Target' '50% Target')
			offset= (-35, -2.5)
		;

data _NULL_;
	call symput ("titledate", put(mdy(month(today()),1,year(today())), worddate.));
run;


* PRINT TO PDF  &exp_sum &exp_pct.;
/*
options nodate orientation = landscape;
ods pdf file = "&output./recruitment_curve_nhlbi.pdf";

	title1 f=times h=3 justify=center "TT-CMV Patient Recruitment Summary - All Centers,&titledate"; 
	title2 f=times h=2.5 justify=center "&act_sum patients recruited of &exp_sum expected (&exp_pct.%).";
	proc gplot data = total_recruit_all; 
		plot 	sum_recruit*date 
					expected_recruit*date
					seventyfive_percent*date
					fifty_percent*date
						/ overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* &act_sum patients recruited.";
		footnote2 h=2 justify=left "* Expected recruitment per month: Grady: 4; EUHM: 4; Northside: 7.";
		footnote3 "";
	run;

ods pdf close;
*/
******************************************************************************;
* PRINT TO RTF ;
goptions device=png target=png xmax=10 in  xpixels=5000  ymax=7 in ypixels=3500;
options nonumber nodate orientation = landscape;
ods rtf file = "&output./recruitment_curve_nhlbi.rtf" style=journal;

	title1 f=times h=3 justify=center "TT-CMV Patient Recruitment Summary - All Centers,&titledate"; 
	title2 f=times h=2.5 justify=center "&act_sum patients recruited of &exp_sum expected (&exp_pct.%).";
	proc gplot data = total_recruit_all; 
		plot 	sum_recruit*date 
					expected_recruit*date
					seventyfive_percent*date
					fifty_percent*date
						/ overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* &act_sum patients recruited.";
		footnote2 h=2 justify=left "* Expected recruitment per month: Grady: 4; EUHM: 4; Northside: 7.";
		footnote3 "";
	run;

ods rtf close;



* use this code to get literal value for date;
/***********************/
*data _NULL_;
*	sampdate = '1jan2010'd;
*	put sampdate=;
*run;
/***********************/
