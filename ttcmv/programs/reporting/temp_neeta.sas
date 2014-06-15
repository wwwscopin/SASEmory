proc sql;

create table enrolled as
select a.id  , b.*
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

create table enrolled as
select  a.enrollmentDate,a.consent ,b.*
from 
cmv.Eligibility as a
right join
enrolled as b
on a.id =b.id
;




quit;

data enrolled2; set enrolled;
year_enrol=Year(enrollmentDate);

month_enrol=Month(enrollmentDate);

if id > 1000000 and id < 2000000 then center="EUHM";
if id > 2000000 and id < 3000000 then center="Grady";
if id > 3000000 and id < 4000000 then center="NS";
if year_enrol=2017 then year_enrol=2011;
run;



proc format;
value gen
1="m"
2="f"
;

value race
1="Black"
2="Am Ind"
3="white"
4="Native Hwa or pacific islander"
5="asian"
6="more than one race"
7="other"
;

run;

%include "&include./monthly_toc.sas";

options nodate  orientation = portrait; 

ods rtf file = "&output./monthly/marta.rtf"  style = journal toc_data startpage = yes bodytitle;
proc freq data=enrolled2;
where year_enrol=2011 or ( month_enrol > 7 and year_enrol=2010);
tables year_enrol*center; 
tables gender*center;
tables race*center;
format race race.; format gender gen.;
run;

title "last period consent";
proc freq data=enrolled2;
where year_enrol=2011 or ( month_enrol > 7 and year_enrol=2010);
tables consent;
run;

title "up tp now consent";
proc freq data=cmv.Eligibility;

tables consent;
run;


ods rtf close;
