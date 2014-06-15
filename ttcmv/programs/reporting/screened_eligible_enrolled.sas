
%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


data screening;	set cmv.plate_001 (rename = (isEligible = enrolled));

	center = floor(id/1000000);
	format center center.;

	if (InWeight & InLife & ~ExLifeExpect & ~ExAbnor & ~ExTX & ~ExMOCPrevEnrolled) then	elig_criteria = 1;
	else elig_criteria = 0;

	format date monname.;
	date = mdy(month(LBWIconsentdate), 1, year(LBWIconsentdate));
		
	drop DFSTATUS  DFVALID  DFRASTER  DFSTUDY  DFPLATE  DFSEQ DFSCREEN  DFCREATE  DFMODIFY;

run;

*** By Center ;
*		simple count is # screened 
		check eligibility criteria for # eligible 
		# enrolled is where enrollment date is given ;
proc sql; 
create table screened_eligible_enrolled as 
	select distinct(a.center) as center,a.screened_count,b.eligible_count,c.enrolled_count
	from 

	(select count(*) as screened_count, center 
		from screening
		group by center) 

	as  a
	left join
 
	(select distinct(count(*)) as eligible_count, elig_criteria, center
		from screening where elig_criteria = 1
		group by center)

	as b
	on a.center=b.center
	left join

	(select distinct(count(*)) as enrolled_count, enrolled, center
		from screening where LBWIconsentdate is not null
		group by center)

	as c
	on b.center=c.center;
quit;

*** Overall ;
proc sql; 
create table screened_eligible_enrolled2 as 
	select distinct(a.screened_count),b.eligible_count,c.enrolled_count
	from
	(select count(*) as screened_count from screening) as a,
 	(select distinct(count(*)) as eligible_count, elig_criteria	from screening where elig_criteria = 1) as b,
	(select distinct(count(*)) as enrolled_count, enrolled	from screening where LBWIconsentdate is not null) as c;
quit;


*** Merge ;
data screened_eligible_enrolled2; set screened_eligible_enrolled2; center = 8; run;
data screened_eligible_enrolled; set screened_eligible_enrolled screened_eligible_enrolled2; run;



data screened_eligible_enrolled; set screened_eligible_enrolled;
	eligible_percent = (eligible_count / screened_count) * 100;
	enrolled_percent = (enrolled_count / eligible_count) * 100;
run;

data screened_eligible_enrolled; set screened_eligible_enrolled;
	eligible = compress(put(eligible_count, 3.0)) || "/" || compress(put(screened_count, 3.0)) || " (" ||  compress(put(eligible_percent, 4.1)) || "%)";
	enrolled = compress(put(enrolled_count, 3.0)) || "/" || compress(put(eligible_count, 3.0)) || " (" ||  compress(put(enrolled_percent, 4.1)) || "%)";
run;


/*
data screenlog_ids; set cmv.screen_log; keep id; run;
data eligibility_ids; set screening; keep id; run;
data merge_check1; merge screenlog_ids (in = a) eligibility_ids (in = b); by id; if ~a; run;
data merge_check2; merge screenlog_ids (in = a) eligibility_ids (in = b); by id; if ~b; run;

ods rtf file = "&output./screening_merge_check.rtf" style=journal bodytitle startpage=off;
	title1 "IDs not on the screen log";
	proc print data = merge_check1; run;
	title1 "IDs with no eligibility forms";
	proc print data = merge_check2; run;
ods rtf close;
*/

proc sort data = screening out = cmv.enrolled; by id; run;
data cmv.enrolled; set cmv.enrolled; if LBWIconsentdate ~= .; run;

proc sort data = screened_eligible_enrolled; by center; run;

options nodate orientation = portrait;

ods rtf file = "&output./monthly/&mon_file_screen_enroll.screened_eligible_enrolled.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "&mon_pre_screen_enroll Cumulative Patient Screening and Enrollment";

		title1 "&mon_pre_screen_enroll Cumulative Patient Screening and Enrollment";
		footnote1 "*Study start dates: Grady, Jan 2010; Midtown, March 2010; Northside, July 2010.";
		proc print data = screened_eligible_enrolled label noobs split = "@" style(header) = [just=center] contents = "";

				var center screened_count eligible enrolled / style(data) = [just=center];				

				*by date;
				*label date = "Month";

				label center = "Hospital*"
						 screened_count = "No. Screened@"
						 eligible = "No. Eligible@(% of screened)"
						 enrolled = "No. Enrolled@(% of eligible)"
				;

				run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


