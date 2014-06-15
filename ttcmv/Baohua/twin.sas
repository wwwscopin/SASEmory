
data enrolled; 
length twin_status $ 15;
set cmv.completedstudylist;
id2 = compress(id);
mocId=input(substr(id2, 1, 5),5.);
twin=input(substr(id2, 6, 1),5.);
center = input(substr(id2, 1, 1),1.);
run;



proc sql;

create table twin_status as
select max(twin)as ismultiple, mocid from enrolled group by mocid;

create table enrolled as
select a.*, b.ismultiple
from enrolled as a left join
twin_status as b
on a.mocid=b.mocid
order by center,id;
quit;
data enrolled; set enrolled;

if ismultiple eq 1 then twin_status="singleton";
else if ismultiple eq 2 then twin_status="twin";
else if ismultiple eq 3 then twin_status="triplet";
run;



proc sort; by id;run;

data twin; 
    merge enrolled cmv.completedstudylist(in=comp); by id;
    if comp;
run;

proc print;
var id id2 mocid twin ismultiple twin_status;
run;

proc freq;
tables twin_status;
run;
