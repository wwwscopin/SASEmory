* Below code is for count table ;
* find count;


proc sql;

create table Received as

select Distinct(Uniqueform) , TotalAll,Total as ReceivedCt , DataStatus,pct as ReceivedPct

from (

select  a.TotalAll,b.Total, b.Uniqueform, b.DataStatus, (b.total/a.totalall)*100 as pct
from
(
select count(*) as TotalAll, Uniqueform 
from all
where DataStatus = "Y"
group by Uniqueform) as a,
(

select count(*) as Total, Uniqueform , DataStatus
from all
where DataStatus = "Y"
group by Uniqueform, DataStatus) as b

where a.Uniqueform=b.Uniqueform 
)
order by Uniqueform;



quit;


proc sql;

create table Expected as

select Distinct(Uniqueform) , TotalAll,Total as ExpectedCt,DataExpected ,pct as ExpectedPct

from (


select  a.TotalAll,b.Total, b.Uniqueform, b.DataExpected, (b.total/a.totalall)*100 as pct 
from
(
select count(*) as TotalAll, Uniqueform 
from all
where DataExpected In (1,2)
group by Uniqueform) as a,
(

select count(*) as Total, Uniqueform , DataExpected
from all
where DataExpected In (1,2)
group by Uniqueform, DataExpected) as b

where a.Uniqueform=b.Uniqueform )

order by Uniqueform;

quit;



proc sql;

create table FormCount as

select  e.Uniqueform, e.ExpectedCt,e.ExpectedPct,r.ReceivedCt,r.ReceivedPct

from expected as e
left join
received as r
on e.Uniqueform = r.Uniqueform;



quit;

data formcount (keep=Uniqueform expected received); set formcount;

Expected = Trim(Left(ExpectedCt)) ||   " ( " || Trim(left(ExpectedPct)) || " ) %";
Received = Trim(Left(ReceivedCt)) ||   " ( " || trim(left(ReceivedPct)) || " ) %";


run;



proc sql;

create table formcount as

select a.Uniqueform as Form, b.expected , b.received 
from 
(
select Distinct(Uniqueform)
from all  ) as a 
left join
formcount as b
on a.Uniqueform=b.Uniqueform

;


quit;




options nodate nonumber orientation = landscape; 


ods rtf file = "form_submission_count.rtf" style = journal ;
	/* Print patient details */

	
	title2 f= zapf h=3 justify = center "TTCMV  form count - &date ";

   
   proc print data = formcount noobs label style(header) = [just=center] split = "_"; 
    
	
run; 
ods rtf close;











