proc sql;

create table breastfeedlog_long as
select id,startdate1 as startdate,enddate1 as enddate, fresh_milk1 as fresh_milk,
       frozen_milk1 as frozen_milk, moc_milk1 as moc_milk,donor_milk1 as donor_milk, comments1 as comments ,dfseq, 1 as rownum 
from cmv.breastfeedlog

union
select id,startdate2 as startdate,enddate2 as enddate, fresh_milk2 as fresh_milk,
       frozen_milk2 as frozen_milk, moc_milk2 as moc_milk,donor_milk2 as donor_milk, comments2 as comments ,dfseq, 2 as rownum 
from cmv.breastfeedlog

union
select id,startdate3 as startdate,enddate3 as enddate, fresh_milk3 as fresh_milk,
       frozen_milk3 as frozen_milk, moc_milk3 as moc_milk,donor_milk3 as donor_milk, comments3 as comments ,dfseq, 3 as rownum 
from cmv.breastfeedlog

union
select id,startdate4 as startdate,enddate4 as enddate, fresh_milk4 as fresh_milk,
       frozen_milk4 as frozen_milk, moc_milk4 as moc_milk,donor_milk4 as donor_milk, comments4 as comments ,dfseq, 4 as rownum 
from cmv.breastfeedlog

union
select id,startdate5 as startdate,enddate5 as enddate, fresh_milk5 as fresh_milk,
       frozen_milk5 as frozen_milk, moc_milk5 as moc_milk,donor_milk5 as donor_milk, comments5 as comments ,dfseq, 5 as rownum 
from cmv.breastfeedlog

union
select id,startdate6 as startdate,enddate6 as enddate, fresh_milk6 as fresh_milk,
       frozen_milk6 as frozen_milk, moc_milk6 as moc_milk,donor_milk6 as donor_milk, comments6 as comments ,dfseq, 6 as rownum 
from cmv.breastfeedlog

union
select id,startdate7 as startdate,enddate7 as enddate, fresh_milk7 as fresh_milk,
       frozen_milk7 as frozen_milk, moc_milk7 as moc_milk,donor_milk7 as donor_milk, comments7 as comments ,dfseq, 7 as rownum 
from cmv.breastfeedlog

union
select id,startdate8 as startdate,enddate8 as enddate, fresh_milk8 as fresh_milk,
       frozen_milk8 as frozen_milk, moc_milk8 as moc_milk,donor_milk8 as donor_milk, comments8 as comments ,dfseq, 8 as rownum 
from cmv.breastfeedlog

union
select id,startdate9 as startdate,enddate9 as enddate, fresh_milk9 as fresh_milk,
       frozen_milk9 as frozen_milk, moc_milk9 as moc_milk,donor_milk9 as donor_milk, comments9 as comments ,dfseq, 9 as rownum 
from cmv.breastfeedlog


union
select id,startdate10 as startdate,enddate10 as enddate, fresh_milk10 as fresh_milk,
       frozen_milk10 as frozen_milk, moc_milk10 as moc_milk,donor_milk10 as donor_milk, comments10 as comments ,dfseq, 10 as rownum 
from cmv.breastfeedlog

union
select id,startdate11 as startdate,enddate11 as enddate, fresh_milk11 as fresh_milk,
       frozen_milk11 as frozen_milk, moc_milk11 as moc_milk,donor_milk11 as donor_milk, comments11 as comments ,dfseq, 11 as rownum 
from cmv.breastfeedlog

union
select id,startdate12 as startdate,enddate12 as enddate, fresh_milk12 as fresh_milk,
       frozen_milk12 as frozen_milk, moc_milk12 as moc_milk,donor_milk12 as donor_milk, comments12 as comments ,dfseq, 12 as rownum 
from cmv.breastfeedlog

union
select id,startdate13 as startdate,enddate13 as enddate, fresh_milk13 as fresh_milk,
       frozen_milk13 as frozen_milk, moc_milk13 as moc_milk,donor_milk13 as donor_milk, comments13 as comments ,dfseq, 13 as rownum 
from cmv.breastfeedlog


union
select id,startdate14 as startdate,enddate14 as enddate, fresh_milk14 as fresh_milk,
       frozen_milk14 as frozen_milk, moc_milk14 as moc_milk,donor_milk14 as donor_milk, comments14 as comments ,dfseq, 14 as rownum 
from cmv.breastfeedlog

union
select id,startdate15 as startdate,enddate15 as enddate, fresh_milk15 as fresh_milk,
       frozen_milk15 as frozen_milk, moc_milk15 as moc_milk,donor_milk15 as donor_milk, comments15 as comments ,dfseq, 15 as rownum 
from cmv.breastfeedlog;


create table breastfeedlog_long as
select a.*,b.LBWIDOB
from breastfeedlog_long as a left join cmv.lbwi_demo as b
on a.id=b.id;
quit;

/* if check boxes for moc_milk and donor_milk are zero and site is grady or midtown, then it is moc milk */
data breastfeedlog_long; set breastfeedlog_long;
if startdate ~=. and moc_milk eq 0 and donor_milk= 0  and id < 3000000 then moc_milk=1;

run;

proc sql;
create table fed_comp as
selct id from cmv.completedstudylist;

quit;

data fed_comp; set fed_comp;
moc_fed_only=0; moc_donor_fed=0; donor_only=0; not_fed=0;
run;

proc sql;

create table moc_only as
select distinct(id) as id , max(moc_milk) as moc_milk_max, max(donor_milk) as donor_milk_max 
from  breastfeedlog_long;


update fed_comp
set moc_donor_fed=1
where id in (select id from moc_only where moc_milk_max=1 and donor_milk_max=1);
quit;

data fed_comp; set fed_comp;
if moc_fed_only=0 and moc_donor_fed=0 and donor_only=0 then not_fed=1;
run;

/**** get sample size *****/

proc sql;
create table feed_sample as
select count(*) as total , 0 as center from cmv.completedstudylist
union
select count(*) as total , 1 as center from cmv.completedstudylist where id < 2000000
union
select count(*) as total , 2 as center from cmv.completedstudylist where id > 2000000 and id < 3000000
union
select count(*) as total , 3 as center from cmv.completedstudylist where id > 3000000 ;

create table feed_sample_moc_only as
select count(*) as moc_donor_fed_total , 0 as center from fed_comp where moc_donor_fed=1 
union
select count(*) as moc_donor_fed_total , 1 as center from fed_comp where id < 2000000 and moc_donor_fed=1 
union
select count(*) as moc_donor_fed_total , 2 as center from fed_comp where id > 2000000 and id < 3000000 and moc_donor_fed=1 
union
select count(*) as moc_donor_fed_total , 3 as center from fed_comp where id > 3000000 and moc_donor_fed=1 ;

create table feed_sample_not_fed as
select count(*) as not_fed_total , 0 as center from fed_comp where not_fed=1 
union
select count(*) as not_fed_total , 1 as center from fed_comp where id < 2000000 and not_fed=1 
union
select count(*) as not_fed_total , 2 as center from fed_comp where id > 2000000 and id < 3000000 and not_fed=1 
union
select count(*) as not_fed_total , 3 as center from fed_comp where id > 3000000 and not_fed=1 ;

create table feed_sample as
select a.*,moc_donor_fed_total,not_fed_total
from feed_sample as a left join feed_sample_moc_only as b on a.center=b.center
left join feed_sample_not_fed as c on b.center=c.center;


quit;

data feed_sample; set feed_sample;

moc_donor_fed_total_stat= compress(Left(trim(moc_donor_fed_total))) || "/"  || compress(Left(trim(total)))  || "( " 
|| compress( left(trim(put( moc_donor_fed_total/total*100,3.0)))  )   ||
"%)" ;


not_fed_total_stat= compress(Left(trim(not_fed_total))) || "/"  || compress(Left(trim(total)))  || "( " 
|| compress( left(trim(put( not_fed_total/total*100,3.0)))  )   ||
"%)" ;
run;

