proc sql;

create table enrolled as
select a.id, isEligible,enrollmentdate,LBWIConsentDate  
from 
cmv.Eligibility as a

where (enrollmentdate is not null or IsEligible =1 )and  a.id not in (3003411,3003421);


create table enrolled_enrol as
select a.id, isEligible,enrollmentdate  
from 
cmv.Eligibility as a

where enrollmentdate is not null ;

create table xx as
select a.* ,b.id as id2 from enrolled as a left join
enrolled_enrol as b
on a.id =b.id;





create table xy as
select race, count(*) 
from cmv.plate_005
where ishispanic=0
group by race;
quit;
