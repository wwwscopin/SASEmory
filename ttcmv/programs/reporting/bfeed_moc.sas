proc sql;



create table enrolled as
select a.id  , LBWIDOB as DateOfBirth,GestAge,BirthWeight,Gender 
from 
cmv.valid_ids  as a
left join
cmv.LBWI_Demo as b
on a.id =b.id
where a.id not in ( 1002811,3001511)

;


create table bflog_eos as
select a.*,b.*
from cmv.completedstudylist as a inner join
cmv.Breastfeedlog as b
on a.id=b.id;
quit;

data bflog_eos; set bflog_eos;

moc_fed=0;

if moc_milk1 = 1 or moc_milk2 = 1 or moc_milk3 = 1 
or moc_milk4 = 1 or moc_milk5 = 1
or moc_milk6 = 1  or moc_milk7 = 1 or moc_milk8 = 1 
or moc_milk9 = 1 or moc_milk10 = 1 or moc_milk11 = 1 
or moc_milk12 = 1 or moc_milk13 = 1 or moc_milk14 = 1 
or moc_milk15 = 1 
then moc_fed=1;
run;

proc freq data=bflog_eos;tables moc_fed*center;run;
