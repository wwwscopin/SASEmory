proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;

quit;

proc sql

create table lbwi_blood_nat as

select a.*,b.* 
from enrolled as a
left join 
cmv.Lbwi_blood_nat_result as b
on a.id = b.id
quit;

