proc sql;

create table df_id as
select distinct(id) as id 
from ptcrf2  ;

create table df_id2 as
select a.id from df_id as a right join
( select id from cmv.endofstudy where reason in (1,2,3,6) ) as b
on a.id=b.id;

create table df_id3 as
select * from df_id2 where id is not null;

quit;

