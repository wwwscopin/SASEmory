
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
	select distinct(a.date),a.screened_count,b.eligible_count,c.enrolled_count
	from 

	(select count(*) as screened_count, date 
		from screening
		group by date) 

	as  a
	left join
 
	(select distinct(count(*)) as eligible_count, elig_criteria, date
		from screening where elig_criteria = 1
		group by date)

	as b
	on a.date=b.date
	left join

	(select distinct(count(*)) as enrolled_count, enrolled, date
		from screening where LBWIconsentdate is not null
		group by date)

	as c
	on b.date=c.date;
quit;


proc sort data = screened_eligible_enrolled; by date; run;


data screened_eligible_enrolled; set screened_eligible_enrolled;
	by date;
	retain cum_enrolled_count;
	if _N_ = 1 then cum_enrolled_count = enrolled_count;
	else cum_enrolled_count = cum_enrolled_count + enrolled_count;
run;


options nodate orientation = portrait;

ods rtf file = "&output./monthly/&mon_file_recruitment_table.recruitment_table.rtf" style=journal toc_data startpage = yes bodytitle;
	ods noproctitle proclabel "&mon_pre_recruitment_table Patients recruited by month (last 6 months)";

		title1 "&mon_pre_recruitment_table Patients recruited by month (last 6 months)";
		proc print data = screened_eligible_enrolled label noobs split = "*" style(header) = [just=center] contents = "";

				where date > today() - 200;

				var date enrolled_count cum_enrolled_count / style(data) = [just=center];				

				label date = "Month"
						 enrolled_count = "Patients*Recruited*"
						 cum_enrolled_count = "Total*Recruited*" 
				;

				run;

	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


