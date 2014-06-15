
%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


data recruited_all;	set cmv.plate_001 (rename = (isEligible = enrolled));

	if enrolled = 1;

	center = floor(id/1000000);
	format center center.;

	format date monyy5.;
	date = mdy(month(enrollmentdate), 1, year(enrollmentdate));

run;


	proc sort data = recruited_all; by date id; run;

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
	run;

	data expected_recruit_all; set expected_recruit_all;
		retain expected_recruit;
		if _N_ = 1 then expected_recruit = 4;
		else if _N_ = 2 then expected_recruit = expected_recruit + 7;
		else if _N_ = 3 then expected_recruit = expected_recruit + 8;
		else if _N_ = 4 then expected_recruit = expected_recruit + 14;
		else if _N_ = 5 then expected_recruit = expected_recruit + 3;
		else expected_recruit = expected_recruit + 28;		
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


/**********************************************************************************************/

data recruited_midtown; set recruited_all; if center = 1; run;

	proc sort data = recruited_midtown; by date id; run;

	* compute number recruited each month;
	proc means data= recruited_midtown noprint;
		class date;
		output out = total_recruit_midtown n(id) = num_recruit;
	run;

	* compute cum. sum. at each month;
	data total_recruit_midtown; set total_recruit_midtown;
		where _type_ = 1;
		retain sum_recruit;
		if _N_ = 1 then sum_recruit = num_recruit;
		else sum_recruit = sum_recruit + num_recruit;

		format sum_recruit 3.0;
	run;

	* capture the total # recruited;
	data total_recruit_midtown; set total_recruit_midtown;
		by date;
		if last.date then call symput('act_sum_midtown', compress(put(sum_recruit, 3.0)));
	run;

	* generate expected recruitment ;
	data expected_recruit_midtown;
		do month = 1 to 12;
			date = mdy(month, 1, 2010);
		output;
		end;
	run;

	data expected_recruit_midtown; set expected_recruit_midtown;
		retain expected_recruit;
		if _N_ = 1 or _N_ = 2 then expected_recruit = 0;
		else if _N_ = 3 then expected_recruit = 2;
		else expected_recruit = expected_recruit + 7;		
	run;

	proc sort data = total_recruit_midtown; by date; run;
	proc sort data = expected_recruit_midtown; by date; run;
	data total_recruit_midtown; merge total_recruit_midtown expected_recruit_midtown; by date; run;

/**********************************************************************************************/

data recruited_grady; set recruited_all; if center = 2; run;

	proc sort data = recruited_grady; by date id; run;

	* compute number recruited each month;
	proc means data= recruited_grady noprint;
		class date;
		output out = total_recruit_grady n(id) = num_recruit;
	run;

	* compute cum. sum. at each month;
	data total_recruit_grady; set total_recruit_grady;
		where _type_ = 1;
		retain sum_recruit;
		if _N_ = 1 then sum_recruit = num_recruit;
		else sum_recruit = sum_recruit + num_recruit;

		format sum_recruit 3.0;
	run;

	* capture the total # recruited;
	data total_recruit_grady; set total_recruit_grady;
		by date;
		if last.date then call symput('act_sum_grady', compress(put(sum_recruit, 3.0)));
	run;

	* generate expected recruitment ;
	data expected_recruit_grady;
		do month = 1 to 12;
			date = mdy(month, 1, 2010);
		output;
		end;
	run;

	data expected_recruit_grady; set expected_recruit_grady;
		retain expected_recruit;
		if _N_ = 1 then expected_recruit = 4;
		else expected_recruit = expected_recruit + 7;		
	run;

	proc sort data = total_recruit_grady; by date; run;
	proc sort data = expected_recruit_grady; by date; run;
	data total_recruit_grady; merge total_recruit_grady expected_recruit_grady; by date; run;

/**********************************************************************************************/

data recruited_northside; set recruited_all; if center = 3; run;

	proc sort data = recruited_northside; by date id; run;

	* compute number recruited each month;
	proc means data= recruited_northside noprint;
		class date;
		output out = total_recruit_northside n(id) = num_recruit;
	run;

	* compute cum. sum. at each month;
	data total_recruit_northside; set total_recruit_northside;
		where _type_ = 1;
		retain sum_recruit;
		if _N_ = 1 then sum_recruit = num_recruit;
		else sum_recruit = sum_recruit + num_recruit;

		format sum_recruit 3.0;
	run;

	* capture the total # recruited;
	data total_recruit_northside; set total_recruit_northside;
		by date;
		if last.date then call symput('act_sum_northside', compress(put(sum_recruit, 3.0)));
	run;

	* generate expected recruitment ;
	data expected_recruit_northside;
		do month = 1 to 12;
			date = mdy(month, 1, 2010);
		output;
		end;
	run;

	data expected_recruit_northside; set expected_recruit_northside;
		retain expected_recruit;
		if _N_ = 1 or _N_ = 2 or _N_ = 3 or _N_ = 4 then expected_recruit = 0;
		else if _N_ = 5 then expected_recruit = 4;
		else expected_recruit = expected_recruit + 14;		
	run;

	proc sort data = total_recruit_northside; by date; run;
	proc sort data = expected_recruit_northside; by date; run;
	data total_recruit_northside; merge total_recruit_northside expected_recruit_northside; by date; run;

/**********************************************************************************************/

* PLOT recruitment ;

		* If you leave out the colors statement here, the symbols statements don't work. Isn't that awesome??? ;
		goptions reset=all rotate=landscape gunit=pct device=png noborder cback=white colors=(black) ftitle=swissb ftext=swissb;
	
		symbol1 value = "dot" h=2 i=join line=21;
		symbol2 value = none h=3 i=join;

 		axis1 	label= (f=swissb h=3 'Study Month')
					value= (f=swissb h=2) 
					order= (18263 to 18628 by 31)
					major= (h=3 w=2) 
					minor= none
		;

 		axis2 	label= (a=90 f=swissb h=3 'Patients Recruited') 
					value= (f=swissb h=2) 
					order= (0 to 300 by 20) 
					major= (h=1.5 w=2) 
					minor= (number=3)
		;

 		legend1 across=1 down=2 position=(top right outside) mode=protect
 			shape=symbol(3,2) label=(f=swissb h=2.5 '')
 			value=(h=2.5 'Actual' 'Expected')
			offset= (-13, -2.5)
		;

/**********************************************************************************************/

proc greplay igout=cmv.graphs nofs; delete _all_; run; quit; 

	title1 f=swissb h=3 justify=center "TT-CMV Patient Recruitment Summary - EUHM";
	proc gplot data = total_recruit_midtown gout = cmv.graphs; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* &act_sum_midtown patients recruited at EUHM.";
		footnote2 h=2 justify=left "* Expected recruitment per month at EUHM: 7.";
		footnote3 "";
	run;

	title1 f=swissb h=3 justify=center "TT-CMV Patient Recruitment Summary - Grady";
	proc gplot data = total_recruit_grady gout = cmv.graphs; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* &act_sum_grady patients recruited at Grady.";
		footnote2 h=2 justify=left "* Expected recruitment per month at Grady: 7.";
		footnote3 "";
	run;

	title1 f=swissb h=3 justify=center "TT-CMV Patient Recruitment Summary - Northside";
	proc gplot data = total_recruit_northside gout = cmv.graphs; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* 0 patients recruited at Northside."; /*&act_sum_northside*/
		footnote2 h=2 justify=left "* Expected recruitment per month at Northside: 14.";
		footnote3 "";
	run;


******************************************************************************;
* PRINT TO PS ;
filename fileref1 "&output./monthly/recruitment_curve.ps";
goptions device=ps target=ps gsfname = fileref1;

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve Recruitment Summary through May 10, 2010";
	title2 f=swissb h=2.5 justify=center "&act_sum patients recruited of &exp_sum expected (&exp_pct.%).";

	proc gplot data = total_recruit_all; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ 	overlay haxis=axis1 vaxis=axis2 legend=legend1
							description="&mon_pre_recruit_curve Recruitment Curve - All Sites";
		footnote1 h=2 justify=left "* Expected recruitment per month: Grady: 7; EUHM: 7; Northside: 14.";
		footnote2 "";
	run;
quit;

filename fileref1 "&output./monthly/recruitment_curve2.ps";
goptions gsfname = fileref1;

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve_site Recruitment Summary by Hospital through May 10, 2010";

 	proc greplay igout = cmv.graphs tc=sashelp.templt template= l2r2s nofs; 
					treplay 	1:gplot 2:gplot2 3:gplot1 
									des="&mon_pre_recruit_curve_site Recruitment Curve - By Site";
	run;
quit;


******************************************************************************;
* PRINT TO PDF ;
options nodate orientation = portrait;
ods pdf file = "&output./monthly/recruitment_curve.pdf";

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve Recruitment Summary through May 10, 2010";
	title2 f=swissb h=2.5 justify=center "&act_sum patients recruited of &exp_sum expected (&exp_pct.%).";

	proc gplot data = total_recruit_all; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ 	overlay haxis=axis1 vaxis=axis2 legend=legend1;
		footnote1 h=2 justify=left "* Expected recruitment per month: Grady: 7; EUHM: 7; Northside: 14.";
		footnote2 "";
	run;

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve_site Recruitment Summary by Hospital through May 10, 2010";

 	proc greplay igout = cmv.graphs tc=sashelp.templt template= l2r2s nofs; 
					treplay 	1:gplot 2:gplot2 3:gplot1 
									des="&mon_pre_recruit_curve_site Recruitment Curve - By Site";
	run;
ods pdf close;


******************************************************************************;
* PRINT TO RTF ;
options nodate orientation = portrait;
ods rtf file = "&output./monthly/&mon_file_recruit_curve.recruitment_curve.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "	";

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve Recruitment Summary through May 10, 2010";
	title2 f=swissb h=2.5 justify=center "&act_sum patients recruited of &exp_sum expected (&exp_pct.%).";

	proc gplot data = total_recruit_all; 
		plot 	sum_recruit*date 
					expected_recruit*date
						/ 	overlay haxis=axis1 vaxis=axis2 legend=legend1
							description="&mon_pre_recruit_curve Recruitment Curve - All Sites";
		footnote1 h=2 justify=left "* Expected recruitment per month: Grady: 7; EUHM: 7; Northside: 14.";
		footnote2 "";
	run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


ods rtf file = "&output./monthly/&mon_file_recruit_curve_site.recruitment_curve_site.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "	";

	title1 f=swissb h=3 justify=center "&mon_pre_recruit_curve_site Recruitment Summary by Hospital through May 10, 2010";

 	proc greplay igout = cmv.graphs tc=sashelp.templt template= l2r2s nofs; 
					treplay 	1:gplot 2:gplot2 3:gplot1 
									des="&mon_pre_recruit_curve_site Recruitment Curve - By Site";
	run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;





* use this code to get literal value for date;
/***********************/
*data _NULL_;
*	sampdate = '1jan2010'd;
*	put sampdate=;
*run;
/***********************/
