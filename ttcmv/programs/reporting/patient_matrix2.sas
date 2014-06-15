/********************************** */
/*
*program:	patient_matrix.sas
*purpose: create table for expected and received status report for monthly report
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: January 10,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;

*/


%include "&include./monthly_toc.sas";

proc format;
value center
0="Overall"
1="Midtown"
2="Grady"
3="Northside";
run;


proc sql;




create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;


create table results_table (
center num,
crf_id num,
crf_name char(100),
DFSEQ num,
expected_count num,
received_count num,
pct_received num,

data_missing_count num,
data_missing_stat char(50),
out_of_window_count num,
out_of_window_stat char(50),
sample_not_collected_count num,
sample_not_collected_stat char(50)
);
quit;

data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
moc_id = input(substr(id2, 1, 5),5.);
run;




%macro results_table (crf_id=, crf_name=,exp_table=,rec_table=, dfseq=,count_var=,sample=,where_sample=,window=,where_window=);

data temp1; set &rec_table; where dfseq=&dfseq; run;

proc sql;
create table temp as
select a.*
from temp1 as a inner join enrolled as b on a.id=b.id;
quit;

data temp; set temp;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
moc_id = input(substr(id2, 1, 5),5.);
if moc_id =. then delete;
run;

data center0; set temp; where moc_id ~= .; run;
data center1; set temp; where center=1 and moc_id ~= .; run;
data center2; set temp; where center=2 and moc_id ~= .; run;
data center3; set temp; where center=3 and moc_id ~= .; run;
proc sql;


insert into results_table(crf_id,crf_name,center,dfseq) 
values (&crf_id,&crf_name,0,&dfseq);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (&crf_id,&crf_name,1,&dfseq);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (&crf_id,&crf_name,2,&dfseq);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (&crf_id,&crf_name,3,&dfseq);

update  results_table 
set expected_count= (select count(distinct(a.&count_var)) from &exp_table as a)
where crf_name=&crf_name and center=0;

update  results_table 
set received_count= (select count(distinct(a.&count_var)) from temp as a inner join enrolled as b on a.id=b.id)
where crf_name=&crf_name and center=0;

update  results_table 
set expected_count= (select count(distinct(a.&count_var)) from &exp_table as a where center=1 )
where crf_name=&crf_name and center=1;

update  results_table 
set received_count= (select count(distinct(a.&count_var))  from center1 as a where dfseq=&dfseq)
where crf_name=&crf_name and center=1;

update  results_table 
set expected_count= (select count(distinct(a.&count_var)) from &exp_table as a where center=2 )
where crf_name=&crf_name and center=2;

update  results_table 
set received_count= (select count(distinct(a.&count_var))  from center2 as a where dfseq=&dfseq )
where crf_name=&crf_name and center=2;

update  results_table 
set expected_count= (select count(distinct(a.&count_var)) from &exp_table as a where center=3 )
where crf_name=&crf_name and center=3;

update  results_table 
set received_count= (select count(distinct(a.&count_var))  from center3 as a where dfseq=&dfseq )
where  crf_name=&crf_name and center=3;



quit;

/**** this is for sample not collected ****/

%if &sample = 1 %then %do;
proc sql;
update  results_table
set sample_not_collected_count= (select count(distinct(moc_id)) from center0  where &where_sample  )
where crf_name=&crf_name and center=0;


update  results_table
set sample_not_collected_count= (select count(distinct(moc_id)) from center1  where &where_sample  and center=1)
where crf_name=&crf_name and center=1;

update  results_table
set sample_not_collected_count= (select count(distinct(moc_id)) from center2  where &where_sample  and center=2 )
where crf_name=&crf_name and center=2;

update  results_table
set sample_not_collected_count= (select count(distinct(moc_id)) from center3  where &where_sample  and center=3)
where crf_name=&crf_name and center=3;
quit;

%end;


/**** this is for Out of window ****/

%if &window = 1 %then %do;
proc sql;
update  results_table
set out_of_window_count= (select count(distinct(id)) from center0  where &where_window  )
where crf_name=&crf_name and center=0;


update  results_table
set out_of_window_count= (select count(distinct(id)) from center1  where &where_window  and center=1)
where crf_name=&crf_name and center=1;

update  results_table
set out_of_window_count= (select count(distinct(id)) from center2  where &where_window  and center=2 )
where crf_name=&crf_name and center=2;

update  results_table
set out_of_window_count= (select count(distinct(id)) from center3  where &where_window  and center=3)
where crf_name=&crf_name and center=3;
quit;

%end;


proc sql;

drop table temp1; drop table temp;
drop table center1; drop table center2; drop table center3; drop table center0;
quit;
%mend;


/********************MOC Demographics ******************************/

%results_table (crf_id=0, crf_name='MOC Demographics',exp_table=enrolled ,rec_table=cmv.Plate_007, dfseq=1, count_var=moc_id,
sample=0,where_sample=,window=0,where_window=);


data results_table; set results_table;
if crf_name='MOC Demographics' then do; data_missing_stat='-'; out_of_window_stat='-'; sample_not_collected_stat='-'; end;
run;


/********************MOC Blood Collection DOL 0 ******************************/

%results_table (crf_id=1, crf_name='MOC Blood Collection DOL 0',exp_table=enrolled ,rec_table=cmv.plate_004, dfseq=1, count_var=moc_id,
sample=0,where_sample=,window=0,where_window=);

data results_table; set results_table;
if crf_name='MOC Blood Collection DOL 0' then do; data_missing_stat='-'; out_of_window_stat='-'; sample_not_collected_stat='-'; end;
run;


/********************MOC Sero Status ******************************/

%results_table (crf_id=2, crf_name='MOC Sero Status',exp_table=enrolled ,rec_table=cmv.Moc_sero, dfseq=1, count_var=moc_id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);

data results_table; set results_table;
if crf_name='MOC Sero Status' then do; data_missing_stat='-'; out_of_window_stat='-'; sample_not_collected_stat='-'; end;
run;


/********************MOC Blood Collection EOS Seroneg ******************************/

data seroneg; set cmv.Moc_sero; where combotestresult=1;run;

proc sql;

create table seroneg2 as
select a.id,a.combotestresult,b.DateOfBirth,b.center,b.moc_id,63 as dfseq
from seroneg as a inner join enrolled as b 
on a.id=b.id;

create table seroneg3 as
select a.*,b.StudyLeftDate
from seroneg2 as a right join 
cmv.Endofstudy as b 
on a.id=b.id;

create table seroneg4 as
select a.* from seroneg3 as a where StudyLeftDate is not null and combotestresult=1;

create table Plate_023 as
select a.*
from cmv.Plate_023 as a right join seroneg4 as b on a.id=b.id;
quit; 

%results_table (crf_id=3, crf_name='MOC Blood Collection EOS Seroneg',exp_table=seroneg4 ,rec_table=Plate_023, dfseq=63, count_var=moc_id, 
sample=1,where_sample=IsNatblood eq 0 ,window=0,where_window=);



proc sql; drop table seroneg; drop table seroneg2; drop table seroneg3; drop table seroneg4;  drop table Plate_023; quit;

/********************MOC NAT Result EOS Seroneg ******************************/

data seroneg; set cmv.Moc_sero; where combotestresult=1;run;

proc sql;

create table seroneg2 as
select a.id,a.combotestresult,b.DateOfBirth,b.center,b.moc_id,63 as dfseq
from seroneg as a inner join enrolled as b 
on a.id=b.id;

create table seroneg3 as
select a.*,b.StudyLeftDate
from seroneg2 as a right join 
cmv.Endofstudy as b 
on a.id=b.id;

create table seroneg4 as
select a.* from seroneg3 as a where StudyLeftDate is not null and combotestresult=1;

create table seroneg5 as
select a.* ,b.IsNatblood
from seroneg4 as a left join
cmv.Plate_023 as b
on a.id=b.id ;

create table seroneg5 as
select * from seroneg5 where IsNatblood=1;
quit;

%results_table (crf_id=4, crf_name='MOC NAT Result EOS Seroneg',exp_table=seroneg5 ,rec_table=cmv.MOC_nat, dfseq=63, count_var=moc_id, 
sample=0,where_sample= ,window=0,where_window=);
proc sql; drop table seroneg; drop table seroneg2; drop table seroneg3; drop table seroneg4;  drop table seroneg5; quit;

/********************LBWI Demographics ******************************/

%results_table (crf_id=5, crf_name='LBWI Demographics',exp_table=enrolled ,rec_table=cmv.LBWI_Demo, dfseq=1, count_var=id,
sample=0,where_sample=,window=0,where_window=);


/********************LBWI Lab Review DOL 1 ******************************/

%results_table (crf_id=6, crf_name='LBWI Lab Review DOL 1',exp_table=enrolled ,rec_table=cmv.Med_review, dfseq=1, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);


/********************LBWI Lab Review DOL 4 ******************************/


proc sql;
create table Med_review as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table Med_review2 as
select a.* from Med_review  as a where StudyLeftDate is not null;

quit;

data Med_review3; set Med_review2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=4;
quit;



%results_table (crf_id=7, crf_name='LBWI Lab Review DOL 4',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=4, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);

/********************LBWI Lab Review DOL 7 ******************************/

proc sql; drop table Med_review4;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=7;

quit;

%results_table (crf_id=8, crf_name='LBWI Lab Review DOL 7',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=7, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq  1);


/********************LBWI Lab Review DOL 14 ******************************/

proc sql;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=14;

quit;

%results_table (crf_id=9, crf_name='LBWI Lab Review DOL 14',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=14, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);


/********************LBWI Lab Review DOL 21 ******************************/

proc sql;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=21;

quit;

%results_table (crf_id=10, crf_name='LBWI Lab Review DOL 21',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=21, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);


/********************LBWI Lab Review DOL 28 ******************************/

proc sql;drop table Med_review4;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=28;

quit;

%results_table (crf_id=11, crf_name='LBWI Lab Review DOL 28',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=28, count_var=id,
sample=0,where_sample=out_of_window eq 1,window=1,where_window=out_of_window eq 1);


/********************LBWI Lab Review DOL 40 ******************************/

proc sql;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=40;

quit;

%results_table (crf_id=12, crf_name='LBWI Lab Review DOL 40',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=40, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);


/********************LBWI Lab Review DOL 60 ******************************/

proc sql;drop table Med_review4;
create table Med_review4 as
select * from Med_review3 where days_to_eos >=60;

quit;

%results_table (crf_id=13, crf_name='LBWI Lab Review DOL 60',exp_table=Med_review4 ,rec_table=cmv.Med_review, dfseq=60, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);

/******** LBWI Lab Review (Longitudinal) *******************/
data results_table ;set results_table; 

if received_count >expected_count and crf_id in (6,7,8,9,10,11,12,13)
then
expected_count=received_count;
run;

data results_table2 ;set results_table; run;

proc sql;
insert into results_table(crf_id,crf_name,center,dfseq) 
values (14,'LBWI Lab Review (Longitudinal)',0,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (14,'LBWI Lab Review (Longitudinal)',1,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (14,'LBWI Lab Review (Longitudinal)',2,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (14,'LBWI Lab Review (Longitudinal)',3,63);

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where crf_id in (6,7,8,9,10,11,12,13) and center=0),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=0),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=0)
where crf_name='LBWI Lab Review (Longitudinal)' and center=0;

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=1),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=1),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=1)
where crf_name='LBWI Lab Review (Longitudinal)' and center=1;


update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=2),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=2),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=2)
where crf_name='LBWI Lab Review (Longitudinal)' and center=2;

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=3),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=3),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (6,7,8,9,10,11,12,13) and center=3)
where crf_name='LBWI Lab Review (Longitudinal)' and center=3;

drop table results_table2;
quit;


/********************Anthro 15 .see Gt 25% data part in the end ******************************/
proc sql;

insert into results_table(crf_id,crf_name,center,dfseq) 
values (15,'--Anthropometric section',0,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (15,'--Anthropometric section',1,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (15,'--Anthropometric section',2,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (15,'--Anthropometric section',3,63);


quit;


/********************LAB Section 16 ******************************/

proc sql;

insert into results_table(crf_id,crf_name,center,dfseq) 
values (16,'--Lab section',0,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (16,'--Lab section',1,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (16,'--Lab section',2,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (16,'--Lab section',3,63);


quit;


/********************SNAP ******************************/


%results_table (crf_id=16.5, crf_name='LBWI SNAP DOL 0',exp_table=enrolled ,rec_table=cmv.snap, dfseq=1, count_var=id,
sample=0,where_sample=,window=1,where_window=out_of_window eq 1);

/********************SNAP II DOL 4******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=4;
quit;

%results_table (crf_id=17, crf_name='LBWI SNAP II DOL 4',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=4, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 7******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=7;
quit;

%results_table (crf_id=18, crf_name='LBWI SNAP II DOL 7',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=7, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 14******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=14;
quit;

%results_table (crf_id=19, crf_name='LBWI SNAP II DOL 14',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=14, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 21******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=21;
quit;

%results_table (crf_id=20, crf_name='LBWI SNAP II DOL 21',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=21, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 28******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=28;
quit;

%results_table (crf_id=21, crf_name='LBWI SNAP II DOL 28',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=28, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 40******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=40;
quit;

%results_table (crf_id=22, crf_name='LBWI SNAP II DOL 40',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=40, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/********************SNAP II DOL 60******************************/
proc sql;
create table snap2_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table snap2_2 as
select a.* from snap2_1  as a where StudyLeftDate is not null;

quit;

data snap2_3; set snap2_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table snap2_4 as
select * from snap2_3 where days_to_eos >=60;
quit;

%results_table (crf_id=23, crf_name='LBWI SNAP II DOL 60',exp_table=snap2_4 ,rec_table=cmv.snap2, dfseq=60, count_var=id,
sample=1,where_sample=BloodCollect eq 99 or BloodCollect eq 0,window=1,where_window=out_of_window eq 1);


/******** LBWI SNAP II (Longitudinal) *******************/


data results_table ;set results_table; 

if received_count >expected_count and crf_id in (17,18,19,20,21,22,23)
then
expected_count=received_count;
run;

data results_table2 ;set results_table; run;

proc sql;
insert into results_table(crf_id,crf_name,center,dfseq) 
values (24,'LBWI SNAP II (Longitudinal)',0,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (24,'LBWI SNAP II (Longitudinal)',1,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (24,'LBWI SNAP II (Longitudinal)',2,63);

insert into results_table(crf_id,crf_name,center,dfseq) 
values (24,'LBWI SNAP II (Longitudinal)',3,63);

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where crf_id in (17,18,19,20,21,22,23) and center=0),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=0),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=0),
sample_not_collected_count=(select sum(sample_not_collected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=0)
where crf_name='LBWI SNAP II (Longitudinal)' and center=0;

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=1),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=1),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=1),
sample_not_collected_count=(select sum(sample_not_collected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=1)
where crf_name='LBWI SNAP II (Longitudinal)' and center=1;


update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=2),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=2),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=2),
sample_not_collected_count=(select sum(sample_not_collected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=2)
where crf_name='LBWI SNAP II (Longitudinal)' and center=2;

update  results_table 
set expected_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=3),
	received_count= (select sum(expected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=3),
out_of_window_count=(select sum(out_of_window_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=3),
sample_not_collected_count=(select sum(sample_not_collected_count)  from results_table2 where  crf_id in (17,18,19,20,21,22,23) and center=3)
where crf_name='LBWI SNAP II (Longitudinal)' and center=3;

drop table results_table2;
quit;


/********************LBWI Urine Collection DOL 0 ******************************/

%results_table (crf_id=25, crf_name='LBWI Urine Collection DOL 0',exp_table=enrolled ,rec_table=cmv.LBWI_urine_collection, dfseq=1, count_var=id,
sample=1,where_sample=urineSample eq 0,window=1,where_window=out_of_window eq 1);

/********************LBWI Urine NAT Result DOL 0 ******************************/

%results_table (crf_id=26, crf_name='LBWI Urine NAT Result DOL 0',exp_table=enrolled ,rec_table=cmv.LBWI_urine_nat_result, dfseq=1, count_var=id,
sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (25) and center=0)
	where crf_name='LBWI Urine NAT Result DOL 0' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (25) and center=1)
	where crf_name='LBWI Urine NAT Result DOL 0' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (25) and center=2)
	where crf_name='LBWI Urine NAT Result DOL 0' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (25) and center=3)
	where crf_name='LBWI Urine NAT Result DOL 0' and center=3;


drop table results_table2;
quit;


/********************LBWI Blood Collection DOL 0 ******************************/

%results_table (crf_id=27, crf_name='LBWI Blood Collection DOL 0',exp_table=enrolled ,rec_table=cmv.LBWI_blood_collection, dfseq=1, count_var=id,
sample=1,where_sample=NATBloodCollect eq 0,window=1,where_window=out_of_window eq 1);

/********************LBWI Blood NAT Result DOL 0 ******************************/

%results_table (crf_id=28, crf_name='LBWI Blood NAT Result DOL 0',exp_table=enrolled ,rec_table=cmv.LBWI_blood_nat_result, dfseq=1, count_var=id,
sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (27) and center=0)
	where crf_name='LBWI Blood NAT Result DOL 0' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (27) and center=1)
	where crf_name='LBWI Blood NAT Result DOL 0' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (27) and center=2)
	where crf_name='LBWI Blood NAT Result DOL 0' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (27) and center=3)
	where crf_name='LBWI Blood NAT Result DOL 0' and center=3;

drop table results_table2;
quit;


/********************LBWI Blood Collection DOL 21 ******************************/

proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null;

quit;

data LBWI_blood_collection_3; set LBWI_blood_collection_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table LBWI_blood_collection_4 as
select * from LBWI_blood_collection_3 where days_to_eos >=21;
quit;

%results_table (crf_id=29, crf_name='LBWI Blood Collection DOL 21',exp_table=LBWI_blood_collection_4 ,rec_table=cmv.LBWI_blood_collection, dfseq=21, count_var=id,
sample=1,where_sample=NATBloodCollect eq 0,window=1,where_window=out_of_window eq 1);

proc sql;
drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 
drop table LBWI_blood_collection_3; 
drop table LBWI_blood_collection_4; 
quit;

data results_table; set results_table;
if crf_id = 29 and received_count > expected_count then expected_count=received_count;
run;

/********************LBWI Blood NAT Result DOL 21 ******************************/

%results_table (crf_id=30, crf_name='LBWI Blood NAT Result DOL 21',exp_table=enrolled ,rec_table=cmv.LBWI_blood_nat_result, dfseq=21, count_var=id,
sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (29) and center=0)
	where crf_name='LBWI Blood NAT Result DOL 21' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (29) and center=1)
	where crf_name='LBWI Blood NAT Result DOL 21' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (29) and center=2)
	where crf_name='LBWI Blood NAT Result DOL 21' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (29) and center=3)
	where crf_name='LBWI Blood NAT Result DOL 21' and center=3;


drop table results_table2;
quit;



/********************LBWI Blood Collection DOL 40******************************/
proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null;

quit;

data LBWI_blood_collection_3; set LBWI_blood_collection_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table LBWI_blood_collection_4 as
select * from LBWI_blood_collection_3 where days_to_eos >=40;
quit;

%results_table (crf_id=31, crf_name='LBWI Blood Collection DOL 40',exp_table=LBWI_blood_collection_4 ,rec_table=cmv.LBWI_blood_collection, dfseq=40, count_var=id,
sample=1,where_sample=NATBloodCollect eq 0,window=1,where_window=out_of_window eq 1);

proc sql;
drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 
drop table LBWI_blood_collection_3; 
drop table LBWI_blood_collection_4; 
quit;

data results_table; set results_table;
if crf_id = 31 and received_count > expected_count then expected_count=received_count;
run;



/********************LBWI Blood NAT Result DOL 40 ******************************/

%results_table (crf_id=32, crf_name='LBWI Blood NAT Result DOL 40',exp_table=enrolled ,rec_table=cmv.LBWI_blood_nat_result, dfseq=40, count_var=id,
sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (31) and center=0)
	where crf_name='LBWI Blood NAT Result DOL 40' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (31) and center=1)
	where crf_name='LBWI Blood NAT Result DOL 40' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (31) and center=2)
	where crf_name='LBWI Blood NAT Result DOL 40' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (31) and center=3)
	where crf_name='LBWI Blood NAT Result DOL 40' and center=3;


drop table results_table2;
quit;

/********************LBWI Blood Collection DOL 60******************************/
proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate
from enrolled as a left join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null;

quit;

data LBWI_blood_collection_3; set LBWI_blood_collection_2; days_to_eos=(StudyLeftDate -DateofBirth);

run;

proc sql;
create table LBWI_blood_collection_4 as
select * from LBWI_blood_collection_3 where days_to_eos >=60;
quit;

%results_table (crf_id=33, crf_name='LBWI Blood Collection DOL 60',exp_table=LBWI_blood_collection_4 ,rec_table=cmv.LBWI_blood_collection, dfseq=60, count_var=id,
sample=1,where_sample=NATBloodCollect eq 0,window=1,where_window=out_of_window eq 1);

proc sql;
drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 
drop table LBWI_blood_collection_3; 
drop table LBWI_blood_collection_4; 
quit;

data results_table; set results_table;
if crf_id = 33 and received_count > expected_count then expected_count=received_count;
run;



/********************LBWI Blood NAT Result DOL 60 ******************************/

%results_table (crf_id=34, crf_name='LBWI Blood NAT Result DOL 60',exp_table=enrolled ,rec_table=cmv.LBWI_blood_nat_result, dfseq=60, count_var=id,
sample=0,where_sample=,window=0,where_window=);

/* some time DOL 60 NAT is > 100% so fix sampl_not collected for dol60 blood collection ****/
data results_table2; set results_table;run;

proc sql;
select received_count into:x0 from results_table where crf_id=34 and center=0;
select received_count into:x1 from results_table where crf_id=34 and center=1;
select received_count into:x2 from results_table where crf_id=34 and center=2;
select received_count into:x3 from results_table where crf_id=34 and center=3;
/*
update  results_table 
set sample_not_collected_count=(select (received_count - &x0)  from results_table2 where crf_id=33 and center=0) 
	where crf_name='LBWI Blood Collection DOL 60' and center=0;

update  results_table 
set sample_not_collected_count=(select (received_count - &x1)  from results_table2 where crf_id=33 and center=1) 
	where crf_name='LBWI Blood Collection DOL 60' and center=1;

update  results_table 
set sample_not_collected_count=(select (received_count - &x2)  from results_table2 where crf_id=33 and center=2) 
	where crf_name='LBWI Blood Collection DOL 60' and center=2;

update  results_table 
set sample_not_collected_count=(select (received_count - &x3)  from results_table2 where crf_id=33 and center=3) 
	where crf_name='LBWI Blood Collection DOL 60' and center=3;
*/
quit;



proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id=33 and center=0)
	where crf_name='LBWI Blood NAT Result DOL 60' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id=33 and center=1)
	where crf_name='LBWI Blood NAT Result DOL 60' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id=33 and center=2)
	where crf_name='LBWI Blood NAT Result DOL 60' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id=33 and center=3)
	where crf_name='LBWI Blood NAT Result DOL 60' and center=3;


drop table results_table2;
quit;

data results_table; set results_table;
if crf_id = 34 and received_count > expected_count then expected_count=received_count;
run;



/********************LBWI Blood Collection DOL90/EOS******************************/
proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null and reason In (1,2);

quit;


%results_table (crf_id=35, crf_name='LBWI Blood Collection DOL 90/EOS',exp_table=LBWI_blood_collection_2 ,rec_table=cmv.LBWI_blood_collection, dfseq=63, count_var=id,
sample=1,where_sample=NATBloodCollect eq 0,window=1,where_window=out_of_window eq 1);

proc sql;
drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 

quit;

data results_table; set results_table;
if crf_id = 35 and received_count > expected_count then expected_count=received_count;
run;


/********************LBWI Blood NAT Result DOL 90/EOS ******************************/
proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null and reason In (1,2);

quit;

%results_table (crf_id=36, crf_name='LBWI Blood NAT Result DOL 90/EOS',exp_table=LBWI_blood_collection_2 ,rec_table=cmv.LBWI_blood_nat_result, dfseq=63, count_var=id,
sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (35) and center=0)
	where crf_name='LBWI Blood NAT Result DOL 90/EOS' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (35) and center=1)
	where crf_name='LBWI Blood NAT Result DOL 90/EOS' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (35) and center=2)
	where crf_name='LBWI Blood NAT Result DOL 90/EOS' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (35) and center=3)
	where crf_name='LBWI Blood NAT Result DOL 90/EOS' and center=3;


drop table results_table2; 

drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 
quit;


proc sql;
drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 

quit;

/********************LBWI Urine Collection DOL 90/EOS ******************************/

proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null and reason In (1,2);

quit;


%results_table (crf_id=37, crf_name='LBWI Urine Collection DOL 90/EOS',exp_table=LBWI_blood_collection_2 ,rec_table=cmv.LBWI_urine_collection, dfseq=63, count_var=id,
sample=1,where_sample=urineSample eq 0,window=1,where_window=out_of_window eq 1);


data results_table; set results_table;

if crf_id = 37 and expected_count < received_count then expected_count=received_count;
run;
proc sql;


drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 

quit;




/********************LBWI Urine NAT Result DOL 90/EOS ******************************/

proc sql;
create table LBWI_blood_collection_1 as
select a.*,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table LBWI_blood_collection_2 as
select a.* from LBWI_blood_collection_1  as a where StudyLeftDate is not null and reason In (1,2);

quit;


%results_table (crf_id=38, crf_name='LBWI Urine NAT Result DOL 90/EOS',exp_table=LBWI_blood_collection_1 ,rec_table=cmv.LBWI_urine_nat_result, dfseq=63, count_var=id,sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (37) and center=0)
	where crf_name='LBWI Urine NAT Result DOL 90/EOS' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (37) and center=1)
	where crf_name='LBWI Urine NAT Result DOL 90/EOS' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (37) and center=2)
	where crf_name='LBWI Urine NAT Result DOL 90/EOS' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (37) and center=3)
	where crf_name='LBWI Urine NAT Result DOL 90/EOS' and center=3;


drop table results_table2; 

drop table LBWI_blood_collection_1; 
drop table LBWI_blood_collection_2; 
quit;

data results_table; set results_table;

if crf_id = 38 and expected_count < received_count then expected_count=received_count;
run; 

/********************LBWI Blood/Urine Collection DOL 90/EOS  ******************************/
proc sql;
create table eos_dol90_1 as
select a.id,a.center,a.moc_id,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table eos_dol90_2 as
select a.* from eos_dol90_1  as a where StudyLeftDate is not null and reason In (1,2);


create table eos_dol90_3 as
select a.* ,b.NATBloodCollect,urineSample,blood_out_of_window,urine_out_of_window
from eos_dol90_2 as a left join
( select id, NATBloodCollect, out_of_window as blood_out_of_window from cmv.LBWI_blood_collection  where dfseq=63) as b
on a.id=b.id
left join
( select id, urineSample,out_of_window as urine_out_of_window from cmv.LBWI_urine_collection  where dfseq=63) as c

on a.id=c.id;
quit;

data eos_dol90_4 ; set eos_dol90_3;
dfseq=63;

out_of_window=0;

if  NATBloodCollect =. and urineSample=. then sample_not_collected=1;
else if  NATBloodCollect =0 and urineSample=0 then  sample_not_collected=1;
else if  NATBloodCollect =. and urineSample=0 then  sample_not_collected=1;

else if  NATBloodCollect =. and urineSample=1 then  sample_not_collected=0;
else if  NATBloodCollect =1 and urineSample=. then  sample_not_collected=0;
else if  NATBloodCollect =1 and urineSample=0 then  sample_not_collected=0;
else if  NATBloodCollect =0 and urineSample=1 then  sample_not_collected=0;
else if  NATBloodCollect =1 and urineSample=1 then  sample_not_collected=0;
run;
/*
data eos_dol90_4; set eos_dol90_4;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
moc_id = input(substr(id2, 1, 5),5.);
run;
*/

data obs_table;set eos_dol90_4; where  sample_not_collected=0;run;






%results_table (crf_id=39, crf_name='LBWI Blood/Urine Collection DOL 90/EOS',exp_table=eos_dol90_4 ,rec_table=obs_table, dfseq=63, count_var=id,
sample=1,where_sample=sample_not_collected eq 1,window=1,where_window=out_of_window eq 1);



data results_table2; set results_table;run;
proc sql;
 
select count(*) into :s0 from eos_dol90_4 where sample_not_collected=1;
select count(*) into :s1 from eos_dol90_4 where sample_not_collected=1 and id >1000000 and id < 2000000;
select count(*) into :s2 from eos_dol90_4 where sample_not_collected=1 and id >2000000 and id < 3000000;
select count(*) into :s3 from eos_dol90_4 where sample_not_collected=1 and id >3000000 and id < 4000000;


update  results_table 
set sample_not_collected_count= &s0
	where crf_name='LBWI Blood/Urine Collection DOL 90/EOS' and center=0;

update  results_table 
set sample_not_collected_count= &s1
	where crf_name='LBWI Blood/Urine Collection DOL 90/EOS' and center=1;

update  results_table 
set sample_not_collected_count= &s2
	where crf_name='LBWI Blood/Urine Collection DOL 90/EOS' and center=2;

update  results_table 
set sample_not_collected_count= &s3
	where crf_name='LBWI Blood/Urine Collection DOL 90/EOS' and center=3;


drop table results_table2; 
quit;

proc sql;
drop table eos_dol90_1; 
drop table eos_dol90_2; 

drop table eos_dol90_3; 
drop table eos_dol90_4;
drop table obs_table;

quit;


/********************LBWI Blood/Urine NAT Result DOL 90/EOS ******************************/

proc sql;
create table nat_dol90_1 as
select a.id,a.center,a.moc_id,b.StudyLeftDate,b.reason
from enrolled as a inner join cmv.Endofstudy as b
on a.id=b.id;

create table nat_dol90_2 as
select a.* from nat_dol90_1  as a where StudyLeftDate is not null and reason In (1,2);


create table nat_dol90_3 as
select a.* ,b.NATtestresult,urinetestresult
from nat_dol90_2 as a left join
( select id, NATtestresult from cmv.LBWI_blood_nat_result  where dfseq=63) as b
on a.id=b.id
left join
( select id, urinetestresult from cmv.LBWI_urine_nat_result  where dfseq=63) as c

on a.id=c.id;
quit;

data nat_dol90_4 ; set nat_dol90_3;
dfseq=63;

out_of_window=0;

if  NATtestresult =99 and urinetestresult=99 then sample_not_collected=1;
else if  NATtestresult =99 and urinetestresult=. then  sample_not_collected=1;
else if  NATtestresult =. and urinetestresult=99 then  sample_not_collected=1;

else if  NATtestresult not in (1,2,3,4) and urinetestresult in (1,2,3,4) then  sample_not_collected=0;
else if  NATtestresult in (1,2,3,4) and urinetestresult not in (1,2,3,4) then  sample_not_collected=0;
else if  NATtestresult in (1,2,3,4) and urinetestresult  in (1,2,3,4) then  sample_not_collected=0;
/*else if  NATtestresult =1 and urinetestresult=0 then  sample_not_collected=0;
else if  NATtestresult =0 and urinetestresult=1 then  sample_not_collected=0;
else if  NATtestresult =1 and urinetestresult=1 then  sample_not_collected=0;*/
run;

data obs_table;set nat_dol90_4; where  sample_not_collected=0;run;


%results_table (crf_id=40, crf_name='LBWI Blood/Urine NAT Result DOL 90/EOS',exp_table=nat_dol90_4 ,rec_table=obs_table, dfseq=63, count_var=id,sample=0,where_sample=,window=0,where_window=);


data results_table2; set results_table;run;
proc sql;


update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (39) and center=0)
	where crf_name='LBWI Blood/Urine NAT Result DOL 90/EOS' and center=0;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (39) and center=1)
	where crf_name='LBWI Blood/Urine NAT Result DOL 90/EOS' and center=1;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (39) and center=2)
	where crf_name='LBWI Blood/Urine NAT Result DOL 90/EOS' and center=2;

update  results_table 
set expected_count= (select (expected_count - sample_not_collected_count)  from results_table2 where crf_id in (39) and center=3)
	where crf_name='LBWI Blood/Urine NAT Result DOL 90/EOS' and center=3;


drop table results_table2; 

quit;

data results_table; set results_table;

if crf_id = 40 and expected_count < received_count then expected_count=received_count;
run;


/*********gt 25% data  missing *****************/

%include "patient_matrix_include.sas";

/**** set snap2 > 25% ****/
proc sql;
update  results_table 
set data_missing_count= (select count(*) from snap2 where this_snap2_gt25=1  )
	where crf_id=24 and center=0;

update  results_table 
set data_missing_count= (select count(*) from snap2 where this_snap2_gt25=1 and id >1000000 and id < 2000000 )
	where crf_id=24 and center=1;

update  results_table 
set data_missing_count= (select count(*) from snap2 where this_snap2_gt25=1 and id >2000000 and id < 3000000 )
	where crf_id=24 and center=2;

update  results_table 
set data_missing_count= (select count(*) from snap2 where this_snap2_gt25=1 and id >3000000 and id < 4000000 )
	where crf_id=24 and center=3;



quit; 


/**** set snap > 25% ****/
proc sql;
update  results_table 
set data_missing_count= (select count(*) from snap where this_snap_gt25=1  )
	where crf_name='LBWI SNAP DOL 0' and center=0;

update  results_table 
set data_missing_count= (select count(*) from snap where this_snap_gt25=1 and id >1000000 and id < 2000000 )
	where crf_name='LBWI SNAP DOL 0' and center=1;

update  results_table 
set data_missing_count= (select count(*) from snap where this_snap_gt25=1 and id >2000000 and id < 3000000 )
	where crf_name='LBWI SNAP DOL 0' and center=2;

update  results_table 
set data_missing_count= (select count(*) from snap where this_snap_gt25=1 and id >3000000 and id < 4000000 )
	where crf_name='LBWI SNAP DOL 0' and center=3;

quit;

/**** set anthro > 25% ****/

data results_table2; set results_table;run;

proc sql;
update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_anthro_gt25=0  ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=0 )
	where crf_id=15 and center=0;

update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_anthro_gt25=0 and id >1000000 and id < 2000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=1 )
	where crf_id=15 and center=1;

update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_anthro_gt25=0 and id >2000000 and id < 3000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=2 )
	where crf_id=15 and center=2;

update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_anthro_gt25=0 and id >3000000 and id < 4000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=3 )
	where crf_id=15 and center=3;

 quit;

/**** set lab > 25% ****/

proc sql;
update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_chem_gt25=0  ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=0 ) 
	where crf_id=16 and center=0;


update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_chem_gt25=0 and id >1000000 and id < 2000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=1 )
	where crf_id=16 and center=1;

update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_chem_gt25=0 and id >2000000 and id < 3000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=2 )
	where crf_id=16 and center=2;

update  results_table 
set data_missing_count= (select count(*) from cmv.Med_review where this_chem_gt25=0 and id >3000000 and id < 4000000 ),
received_count=(select received_count from results_table2 where crf_Id= 14 and center=3 )
	where crf_id=16 and center=3;
quit;


/*************** set stat *************/
data results_table; set results_table;

pct_received=(received_count/expected_count)*100;

sample_not_collected_stat=  compress(sample_not_collected_count) || "(" || compress(put( (sample_not_collected_count/received_count)*100,2.0)) || ")";

out_of_window_stat=  compress(out_of_window_count) || "(" || compress(put( (out_of_window_count/received_count)*100,2.0)) || ")";

if crf_id  in (0,4,15,16,26,28,30,32,34,36,38,40) then do;
out_of_window_stat = "-";sample_not_collected_stat = "-";
end;

if crf_id  in (1,3,4,5,6) then do;
out_of_window_stat = "-";
end;

if crf_id  in (1,2,5,14,16.5, 17) then do;
sample_not_collected_stat = "-";
end;


if crf_id In (15,16,16.5,24) then do;

data_missing_count_stat=  compress(data_missing_count) || "(" || compress(put( (data_missing_count/received_count)*100,2.0)) || ")";
end;



if crf_id  not  In (15,16,16.5,24) then do;
data_missing_count_stat="-";
end;

if crf_id In (15,16) then do;
received_count=.; end;

run;


proc sql;drop table results_table2;  quit;


/****************** output overall *********************/
options nodate  orientation = portrait; 

ods rtf file = "&output./monthly/&exp_count_file.Exp_Obs.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&exp_count_title a: Expected and Received Case Report Forms (CRFs): All Hospitals";
	

	
	title  justify = center "&exp_count_title a: Expected and Received forms (CRFs): Overall";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = results_table noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =0 and crf_id in ( 0,1,2,3,4,5,14,15,16,16.5,24, 25,26,27,28,29,30,31,32,33,34,39,40);
		var  crf_name expected_count received_count pct_received/style(column) = [just=left];

var data_missing_count_stat /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var sample_not_collected_stat /style(column) = [just=center];
    label  crf_name='CRF Name' expected_count='Expected_CRF' received_count='Received_CRF' 
pct_received= 'Percent_Received_CRF' data_missing_count_stat='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' sample_not_collected_stat='Sample not_Collected n(%)';
	 format center center.; format pct_received 3.0;
run; 



ods noproctitle proclabel "&exp_count_title b: Expected and Received Case Report Forms (CRFs): EUHM Hospital";
title  justify = center "&exp_count_title b: Expected and Received forms (CRFs): EUHM Hospital";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = results_table noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =1 and crf_id in ( 0,1,2,3,4,5,14,15,16,16.5,24, 25,26,27,28,29,30,31,32,33,34,39,40);
		var  crf_name expected_count received_count pct_received/style(column) = [just=left];

var data_missing_count_stat /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var sample_not_collected_stat /style(column) = [just=center];
    label  crf_name='CRF Name' expected_count='Expected_CRF' received_count='Received_CRF' 
pct_received= 'Percent_Received_CRF' data_missing_count_stat='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' sample_not_collected_stat='Sample not_Collected n(%)';
	 format center center.; format pct_received 3.0;
run; 

ods noproctitle proclabel "&exp_count_title c: Expected and Received Case Report Forms (CRFs): Grady Hospital";
title  justify = center "&exp_count_title a: Expected and Received forms (CRFs): Grady Hospital";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = results_table noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =2 and crf_id in ( 0,1,2,3,4,5,14,15,16,16.5,24, 25,26,27,28,29,30,31,32,33,34,39,40);
		var  crf_name expected_count received_count pct_received/style(column) = [just=left];

var data_missing_count_stat /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var sample_not_collected_stat /style(column) = [just=center];
    label  crf_name='CRF Name' expected_count='Expected_CRF' received_count='Received_CRF' 
pct_received= 'Percent_Received_CRF' data_missing_count_stat='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' sample_not_collected_stat='Sample not_Collected n(%)';
	 format center center.; format pct_received 3.0;
run; 

ods noproctitle proclabel "&exp_count_title d: Expected and Received Case Report Forms (CRFs): Northside Hospital";
title  justify = center "&exp_count_title a: Expected and Received forms (CRFs): Northside Hospital";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = results_table noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =3 and crf_id in ( 0,1,2,3,4,5,14,15,16,16.5,24, 25,26,27,28,29,30,31,32,33,34,39,40);
		var  crf_name expected_count received_count pct_received/style(column) = [just=left];

var data_missing_count_stat /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var sample_not_collected_stat /style(column) = [just=center];
    label  crf_name='CRF Name' expected_count='Expected_CRF' received_count='Received_CRF' 
pct_received= 'Percent_Received_CRF' data_missing_count_stat='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' sample_not_collected_stat='Sample not_Collected n(%)';
	 format center center.; format pct_received 3.0;
run;

ods rtf close;
