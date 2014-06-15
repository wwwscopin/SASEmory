/*
This file is included to generate Bm, transfer, vent, rbc , any TX

*/

data studystatus;

set studystatus;
where reason IN (1,2,3,6);

rbc_tx_yes=0;
any_tx_yes=0;
vent_yes=0;
transfer_yes=0;
BreastFed_yes=0;
AdvReactionStatus_yes=0;
UnexpectAE_yes=0;
LBWI_Blood_NAT_yes=0;
Unit_NAT_yes=0;
Unit_WBC_yes=0;
run;


proc sql;
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


/**** get wbc donors ****/
proc sql;
create table wbc_donor as
select center, count(distinct(donorunitid)) as donor_count
from
(
select a.id,b.donorunitid,a.center from
cmv.completedstudylist as a inner join
(
select  donorunitid ,id from cmv.plate_031 
union
select donorunitid ,id from cmv.plate_033
) as b 
on a.id=b.id
)as c
group by center


;
;
quit;
proc sql;

update studystatus
set rbc_tx_yes=1 
where id in ( 
select distinct(id) from cmv.plate_031 
);


update studystatus
set any_tx_yes=1 
where id in ( 
select distinct(id) from cmv.plate_031 
union
select distinct(id) from cmv.plate_033 
union
select distinct(id) from cmv.plate_035 
union
select distinct(id) from cmv.plate_037 
);


update studystatus
set vent_yes=1 
where id in ( 
select distinct(id) from cmv.Mechvent /* plate_020 where ventstatus=1 */
);

update studystatus
set BreastFed_yes=1 
where id in ( 
select distinct(id) from bflog_eos where moc_fed=1
);

update studystatus
set transfer_yes=1 
where id in ( 
select distinct(id) from cmv.Plate_110  
);

update studystatus
set AdvReactionStatus_yes=1 
where id in ( 
select distinct(id) from cmv.Plate_020 where AdvReactionStatus=1
);

update studystatus
set UnexpectAE_yes=1 
where id in ( 
select distinct(id) from cmv.Plate_101 where deathcause in( 99,0) 
);


quit;




proc sql;

create table temp as
select count(*) as rbc_tx_yes_total, center,status
from StudyStatus 
where rbc_tx_yes=1 
group by center,status;

create table status_freq as
select a.*, b.rbc_tx_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;


create table temp as
select count(*) as any_tx_yes_total, center,status
from StudyStatus 
where any_tx_yes=1 
group by center,status;

create table status_freq as
select a.*, b.any_tx_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;

create table temp as
select count(*) as vent_yes_total, center,status
from StudyStatus 
where vent_yes=1 
group by center,status;

create table status_freq as
select a.*, b.vent_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;


create table temp as
select count(*) as BreastFed_yes_total, center,status
from StudyStatus 
where BreastFed_yes=1 
group by center,status;

create table status_freq as
select a.*, b.BreastFed_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;

create table temp as
select count(*) as transfer_yes_total, center,status
from StudyStatus 
where transfer_yes=1 
group by center,status;

create table status_freq as
select a.*, b.transfer_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;

create table temp as
select count(*) as AdvReactionStatus_yes_total, center,status
from StudyStatus 
where AdvReactionStatus_yes=1 
group by center,status;

create table status_freq as
select a.*, b.AdvReactionStatus_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;

create table temp as
select count(*) as UnexpectAE_yes_total, center,status
from StudyStatus 
where UnexpectAE_yes=1 
group by center,status;

create table status_freq as
select a.*, b.UnexpectAE_yes_total
from status_freq as a
left join temp as b
on a.center =b.center and a.status=b.status;



update status_freq
set count=(select count(*) from studystatus where center=0 and reason in (1,2,3,6))
where center=0 and status in (1,4,5);

update status_freq
set count=(select count(*) from studystatus where center=1 and reason in (1,2,3,6))
where center=1 and status in (1,4,5);


update status_freq
set count=(select count(*) from studystatus where center=2 and reason in (1,2,3,6))
where center=2 and status in (1,4,5);


update status_freq
set count=(select count(*) from studystatus where center=3 and reason in (1,2,3,6))
where center=3 and status in (1,4,5);



create table status_freq_complete as
select distinct center, "completed" as status ,count,sum(any_tx_yes_total) as any_tx_yes_total, sum(rbc_tx_yes_total) as rbc_tx_yes_total,
sum(UnexpectAE_yes_total) as UnexpectAE_yes_total, sum(AdvReactionStatus_yes_total) as AdvReactionStatus_yes_total,
sum(vent_yes_total) as vent_yes_total, sum(BreastFed_yes_total) as BreastFed_yes_total,
sum(transfer_yes_total) as transfer_yes_total
from status_freq
where status in (1,4,5)
group by center;
quit;


/* ********* include this for LBWI NAT, DONOR NAT, DONOR WBC result ********/


%include "nat_donor_summary_include.sas";
proc sql;
select compress(put(count(distinct(id)),3.0)) into :lbwi_nat0  from blood where treat=0 and NATTestResult In (2,3);
select compress(put(count(distinct(id)),3.0)) into :lbwi_nat1  from blood where treat=1 and NATTestResult In (2,3);
select compress(put(count(distinct(id)),3.0)) into :lbwi_nat2  from blood where treat=2 and NATTestResult In (2,3);
select compress(put(count(distinct(id)),3.0)) into :lbwi_nat3  from blood where treat=3 and NATTestResult In (2,3);


select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_nat0  from donor1 where treat=0 and UnitResult In (2,3);
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_nat1  from donor1 where treat=1 and UnitResult In (2,3);
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_nat2  from donor1 where treat=2 and UnitResult In (2,3);
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_nat3  from donor1 where treat=3 and UnitResult In (2,3);

select compress(put(count(distinct(Donorunitid)),4.0)) into :unit0  from donor1 where treat=0;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit1  from donor1 where treat=1;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit2  from donor1 where treat=2;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit3  from donor1 where treat=3;


select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_wbc0  from bu_wbc1 where treat=0 and wbc_result1_neeta >5;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_wbc1  from bu_wbc1 where treat=1 and wbc_result1_neeta >5;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_wbc2  from bu_wbc1 where treat=2 and wbc_result1_neeta >5;
select compress(put(count(distinct(Donorunitid)),4.0)) into :unit_wbc3  from bu_wbc1 where treat=3 and wbc_result1_neeta >5;

/*
select compress(put(count(distinct(Donorunitid)),3.0)) into :parentunit_wbc0  from bu_wbc1 where treat=0 ;
select compress(put(count(distinct(Donorunitid)),3.0)) into :parentunit_wbc1  from bu_wbc1 where treat=1 ;
select compress(put(count(distinct(Donorunitid)),3.0)) into :parentunit_wbc2  from bu_wbc1 where treat=2 ;
select compress(put(count(distinct(Donorunitid)),3.0)) into :parentunit_wbc3  from bu_wbc1 where treat=3 ;
*/

select compress(put(sum(Donor_COUNT),4.0)) into :parentunit_wbc0  from wbc_donor;
select compress(put(donor_count,4.0)) into :parentunit_wbc1  from wbc_donor where center=1 ;
select compress(put(donor_count,4.0)) into :parentunit_wbc2  from wbc_donor where center=2 ;
select compress(put(donor_count,4.0)) into :parentunit_wbc3  from wbc_donor where center=3 ;

quit;

data status_freq_complete;
set status_freq_complete;
if center=0 then do; LBWI_Blood_NAT_yes =&lbwi_nat0 ; Unit_NAT_yes =&unit_nat0 ; Unit_WBC_yes=&unit_wbc0 ;All_units=&unit0; 
all_wbc_units=&parentunit_wbc0;
end;
if center=1 then do; LBWI_Blood_NAT_yes =&lbwi_nat1 ;  Unit_NAT_yes =&unit_nat1 ; Unit_WBC_yes=&unit_wbc1 ;All_units=&unit1; 
all_wbc_units=&parentunit_wbc1;
end;
if center=2 then do; LBWI_Blood_NAT_yes =&lbwi_nat2 ; Unit_NAT_yes =&unit_nat2 ; Unit_WBC_yes=&unit_wbc2 ;All_units=&unit2; 
all_wbc_units=&parentunit_wbc2;
end;
if center=3 then do; LBWI_Blood_NAT_yes =&lbwi_nat3 ; Unit_NAT_yes =&unit_nat3 ; Unit_WBC_yes=&unit_wbc3 ;All_units=&unit3; 
all_wbc_units=&parentunit_wbc3;
end;

percent_LBWI_Blood_NAT= (LBWI_Blood_NAT_yes/count)*100;
if LBWI_Blood_NAT_yes eq . then LBWI_Blood_NAT_yes =0;
if percent_LBWI_Blood_NAT eq . then percent_LBWI_Blood_NAT =0;
LBWI_Blood_NAT_stat=   compress(Left(trim(LBWI_Blood_NAT_yes))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_LBWI_Blood_NAT,5.0))))|| "% )" ;


percent_Unit_NAT= (Unit_NAT_yes/All_units)*100;
if Unit_NAT_yes eq . then Unit_NAT_yes =0;
if percent_Unit_NAT eq . then percent_Unit_NAT =0;
Unit_NAT_stat=   compress(Left(trim(Unit_NAT_yes))) || "/"  || compress(Left(trim(All_units)))  || "\n( " || compress(Left(trim(put(percent_Unit_NAT,5.0))))|| "% )" ;

percent_Unit_WBC= (Unit_WBC_yes/all_wbc_units)*100;
if Unit_WBC_yes eq . then Unit_WBC_yes =0;
if percent_Unit_WBC eq . then percent_Unit_WBC =0;
Unit_WBC_stat=   compress(Left(trim(Unit_WBC_yes))) || "/"  || compress(Left(trim(all_wbc_units)))  || "\n( " || compress(Left(trim(put(percent_Unit_WBC,5.0))))|| "% )" ;

run;


/* ********* END ****************************/

data status_freq2;
set status_freq_complete;

percent_rbc= (rbc_tx_yes_total/count)*100;
if rbc_tx_yes_total eq . then rbc_tx_yes_total =0;
if percent_rbc eq . then percent_rbc =0;
rbc_stat=   compress(Left(trim(rbc_tx_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_rbc,5.0))))|| "% )" ;


percent_any_tx= (any_tx_yes_total/count)*100;
if any_tx_yes_total eq . then any_tx_yes_total =0;
if percent_any_tx eq . then percent_any_tx =0;
any_tx_stat=   compress(Left(trim(any_tx_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_any_tx,5.0))))|| "% )" ;



if vent_yes_total= . then vent_yes_total=0;
percent_vent= (vent_yes_total/count)*100;
vent_stat=   compress(Left(trim(vent_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_vent,5.0))))|| "% )" ;


if BreastFed_yes_total= . then BreastFed_yes_total=0;
percent_BreastFed= (BreastFed_yes_total/count)*100;
BreastFed_stat=   compress(Left(trim(BreastFed_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_BreastFed,5.0))))|| "% )" ;


if transfer_yes_total= . then transfer_yes_total=0;
percent_transfer= (transfer_yes_total/count)*100;
transfer_stat=   compress(Left(trim(transfer_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_transfer,5.0))))|| " %)" ;



if AdvReactionStatus_yes_total= . then AdvReactionStatus_yes_total=0;
percent_AdvReactionStatus= (AdvReactionStatus_yes_total/any_tx_yes_total)*100;

if percent_AdvReactionStatus =. then percent_AdvReactionStatus=0;

AdvReactionStatus_stat=   compress(Left(trim(AdvReactionStatus_yes_total))) || "/"  || compress(Left(trim(any_tx_yes_total)))  || "( " || compress(Left(trim(put(percent_AdvReactionStatus,5.0))))|| "% )" ;


if UnexpectAE_yes_total= . then UnexpectAE_yes_total=0;
percent_UnexpectAE= (UnexpectAE_yes_total/count)*100;
UnexpectAE_stat=   compress(Left(trim(UnexpectAE_yes_total))) || "/"  || compress(Left(trim(count)))  || "\n( " || compress(Left(trim(put(percent_UnexpectAE,5.0))))|| "% )" ;




run;
