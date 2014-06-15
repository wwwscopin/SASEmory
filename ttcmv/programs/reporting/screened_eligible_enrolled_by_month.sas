
%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


data screening;	set cmv.plate_001 (rename = (isEligible = enrolled));

	center = floor(id/1000000);
	format center center.;

	if (InWeight & InLife & ~ExLifeExpect & ~ExAbnor & ~ExTX & ~ExMOCPrevEnrolled) then	elig_criteria = 1;
	else elig_criteria = 0;

	format date monname.;
	date = mdy(month(screeningdate), 1, year(screeningdate));
		
	drop DFSTATUS  DFVALID  DFRASTER  DFSTUDY  DFPLATE  DFSEQ DFSCREEN  DFCREATE  DFMODIFY;

run;


proc sql; 
create table screened_eligible_enrolled as 
	select a.center,a.date,a.screened_count,b.eligible_count,c.enrolled_count
	from 

	(select count(*) as screened_count, center, date 
		from screening
		group by center, date) 

	as  a
	left join
 
	(select distinct(count(*)) as eligible_count, elig_criteria, center, date
		from screening where elig_criteria = 1
		group by center, date)

	as b
	on a.center=b.center and a.date=b.date
	left join

	(select distinct(count(*)) as enrolled_count, enrolled, center, date
		from screening where LBWIconsentdate is not null
		group by center, date)

	as c
	on b.center=c.center and b.date=c.date;
quit;

data screened_eligible_enrolled; set screened_eligible_enrolled;
	if screened_count = . then screened_count = 0;
	if eligible_count = . then eligible_count = 0;
	if enrolled_count = . then enrolled_count = 0;
run;

data screened_eligible_enrolled; set screened_eligible_enrolled;
	eligible_percent = (eligible_count / screened_count) * 100;
	enrolled_percent = (enrolled_count / eligible_count) * 100;
run;

data screened_eligible_enrolled; set screened_eligible_enrolled;
	eligible = compress(put(eligible_count, 3.0)) || "/" || compress(put(screened_count, 3.0)) || " (" ||  compress(put(eligible_percent, 4.1)) || "%)";
	enrolled = compress(put(enrolled_count, 3.0)) || "/" || compress(put(eligible_count, 3.0)) || " (" ||  compress(put(enrolled_percent, 4.1)) || "%)";
	if center = 1 | center = 2 then target = compress(put((enrolled_count/4)*100, 4.0)) || "%";
	if center = 3 then target = compress(put((enrolled_count/7)*100, 4.0)) || "%";
run;



proc sort data = screened_eligible_enrolled; by date center; run;


options nodate orientation = portrait;

ods rtf file = "&output./monthly/&mon_file_screen_enroll_by_month.screened_eligible_enrolled_by_month.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "&mon_pre_screen_enroll_by_month Patient screening and enrollment by month (last 6 months)";

		title1 "&mon_pre_screen_enroll_by_month Patient screening and enrollment by month (last 6 months)";
		proc print data = screened_eligible_enrolled label noobs split = "*" style(header) = [just=center] contents = "";

				where date > today() - 200;

				id date;
				by date notsorted;
				var center screened_count eligible enrolled target / style(data) = [just=center];				

				label date = "Month"
						 center = "Hospital"
						 screened_count = "No. Screened*"
						 eligible = "No. Eligible*(% of screened)"
						 enrolled = "No. Enrolled*(% of eligible)"
						 target = "No. Enrolled as*% of monthly target"
				;

				run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


