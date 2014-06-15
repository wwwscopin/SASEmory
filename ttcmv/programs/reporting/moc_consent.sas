

proc sql;

create table enrolled as
select a.* ,moc_dob
from 
cmv.Eligibility as a
left join
cmv.plate_007 as b
on a.id=b.id
where (Enrollmentdate is not null ) ;



quit;

data enrolled; 
length twin_status $ 15;
set enrolled;
id2 = left(trim(id));
mocId=input(substr(id2, 1, 5),5.);
twin=input(substr(id2, 6, 1),5.);
center = input(substr(id2, 1, 1),1.);

moc_age_enrol =  (EnrollmentDate - moc_dob)/365 ; 


run;

proc sql;

create table twin_status as
select max(twin)as ismultiple, mocid from enrolled group by mocid;

create table enrolled as
select a.*, b.ismultiple
from enrolled as a left join
twin_status as b
on a.mocid=b.mocid
order by center,  EnrollmentDate asc,id;

/*
create table enrolled as
select * from enrolled
order by center,  EnrollmentDate asc,id;

*/
quit;
data enrolled; set enrolled;

if ismultiple eq 1 then twin_status="singleton";
else if ismultiple eq 2 then twin_status="twin";
else if ismultiple eq 3 then twin_status="triplet";
run;

proc freq;
tables twin_status;
run;
