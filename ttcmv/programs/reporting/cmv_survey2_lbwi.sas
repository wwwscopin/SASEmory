***************************
*program:	cmv_survey2_lbwi.sas
*purpose: create table for cmv survey for moc IgM positive babies
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: January 10,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;

*libname cmv "/ttcmv/sas/data";


%include "&include./annual_toc.sas";


/***** inherit cmv_id dataset from cmv_survey2_moc.sas file ****/

proc sql;

create table lbwi_table as
select distinct id, id2, moc_id,DateOfBirth
from  cmv_id;


create table lbwi_table as
select a.* ,GestAge,BirthWeight,Gender
from lbwi_table as a left join
enrolled as b
on a.id=b.id ;

create table PDA as
select a.id ,b.PDA,b.PDADiagDate
from lbwi_table as a left join
( select id, 1 as PDA,PDADiagDate from cmv.PDA) as b 
on a.id=b.id;



create table ivh as
select a.id ,b.IVH,IVhDiagDate
from lbwi_table as a left join
( select id, 1 as IVH, IVhDiagDate from cmv.IVH) as b 
on a.id=b.id

;


create table lbwi_table as
select a.* ,b.NEC
from lbwi_table as a left join
( select id, 1 as NEC from cmv.NEC) as b 
on a.id=b.id
order by id ;


create table lbwi_table as
select a.* ,b.BPD,IsOxygenDOL28
from lbwi_table as a left join
( select id, 1 as BPD,IsOxygenDOL28 from cmv.bpd) as b 
on a.id=b.id;

create table lbwi_table as
select a.* ,b.ROP
from lbwi_table as a left join
( select id, 1 as ROP from cmv.ROP) as b 
on a.id=b.id;


create table sus_cmv as 
select a.id,a.moc_id, CMVDisConf ,CMVDisNo
from  lbwi_table as a left join

(select id, CMVDisConf ,CMVDisNo ,UrineCultureResult from cmv.sus_cmv) as b
on a.id=b.id
;


create table death_all as
select id, deathdate , deathcause from cmv.plate_100
union
select id, deathdate ,8 as deathcause from cmv.plate_101 where deathdate is not null;


create table lbwi_table as
select a.* ,deathdate ,deathcause
from lbwi_table as a left join
death_all as b
on a.id=b.id ;

drop table death_all;
quit;

/*** sus_cmv table ****/
data sus_cmv; length cmv_disease $ 20; set sus_cmv;
if CMVDisConf = 0 then cmv_disease="No";
else if CMVDisConf = 1 then cmv_disease="Yes" || "\n " || compress(put(UrineCultureResult,UrineCulture.));
else if CMVDisConf = . then cmv_disease="-";
run;


proc sql;
create table lbwi_table as
select a.* ,b.cmv_disease
from lbwi_table as a left join
sus_cmv as b 
on a.id=b.id;
drop table sus_cmv;

quit;

/*** pDA table ****/
data pda;set pda;

pda_stat =compress(put(pda,outcome.));

if pda eq 1 then do;
PDA_days=PDADiagDate - DateOfBirth;
pda_stat =compress(pda_stat) || "\n d" || compress(PDA_days);
end;

run;

proc sql;
create table lbwi_table as
select a.* ,b.pda_stat
from lbwi_table as a left join
pda as b 
on a.id=b.id;
drop table pda;

quit;


/*** IVH table ****/
data ivh; set ivh;
ivh_stat =compress(put(ivh,outcome.));

if ivh eq 1 then do;
ivh_days=ivhDiagDate - DateOfBirth;
ivh_stat =compress(ivh_stat) || "\n d" || compress(ivh_days);
end;

run;


proc sql;
create table lbwi_table as
select a.* ,b.ivh_stat
from lbwi_table as a left join
ivh as b 
on a.id=b.id;
drop table ivh;

quit;


/****** tx *******/


proc sql;
create table tx as
select  dfseq, DonorUnitId ,id , DateTransfusion, "RBC" as source from cmv.plate_031
union
select  dfseq, DonorUnitId ,id , DateTransfusion,"Plt" as source from cmv.plate_033
union
select dfseq, DonorUnitId ,id ,DateTransfusion, "FFP" as source from cmv.plate_035
union
select dfseq, DonorUnitId ,id ,DateTransfusion, "Cry" as source from cmv.plate_037;

create table tx_count as 
select id, count(*) as total_tx from tx where DateTransfusion is not null group by id; 

create table lbwi_table as
select a.* ,b.total_tx
from lbwi_table as a left join
tx_count as b 
on a.id=b.id;

drop table tx; drop table tx_count;

quit;


/***** BF status *******/
proc sql;
create table BFeed as
select distinct id ,  FeedStatus from cmv.plate_020 where FeedStatus=1;

create table lbwi_table as
select a.* ,b.FeedStatus
from lbwi_table as a left join
BFeed as b 
on a.id=b.id;

drop table Bfeed;
quit;

data lbwi_table; length pda_stat $ 20;length death_stat $ 20;length ivh_stat $ 20;length tx_stat $ 20;
set lbwi_table; seq =1;
death_day= deathdate - DateOfBirth;

if death_day = . then
death_stat="No";

else if death_day ~=. then 
do;    
death_stat="Yes\n d" || compress(death_day) || "\n" || compress(put(deathcause,deathcau.));
end;

age_wt_gender_stat= compress(put(gender,gender.)) || "\n" ||   compress(Birthweight)|| "g\n" ||   compress(gestage) || "wk";

if total_tx ~=. then tx_stat ="Yes \n" || compress(total_tx);
else if total_tx =. then tx_stat ="No" ;
run;


/***** *****/

proc sql;
create table lbwi_table as
select distinct id, seq,death_stat,age_wt_gender_stat,DateOfBirth,nec, pda_stat,ivh_stat,nec,bpd,rop,cmv_disease,tx_stat,FeedStatus
from lbwi_table;

quit;



/**** now replicate moc_table to append *****/


data lbwi_table_output; set lbwi_table;



output; seq=2; output;seq=3;output; seq=4; output;seq=5; output;seq=6; output;seq=7;output; seq=8;output;

run;


/***** urine NAT *****/

proc sql;
create table lbwi_urine_nat as
select a.*,b.DateofBirth
from cmv.plate_211_long as a left join
enrolled as b
on a.id=b.id;
quit;


data lbwi_urine_nat; length lbwi_urine_nat_stat $ 30;set lbwi_urine_nat;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

dol_urine_nat=UrineDate - DateOfBirth;
if UrineTestResult In (2) then 
lbwi_urine_nat_stat= "d" || compress(dol_urine_nat) ||  " (LowPos)";
else if UrineTestResult In (1) then 
lbwi_urine_nat_stat= "d" || compress(dol_urine_nat) ||  " (Neg)";
else if UrineTestResult In (3) then
lbwi_urine_nat_stat= "d" || compress(dol_urine_nat) ||  compress(put(UrineTestResult ,nat_short.)) || " :" || compress(UrineCopyNumber) || "c/ml)";
else if UrineTestResult In (4) then 
lbwi_urine_nat_stat= "d" || compress(dol_urine_nat) ||  " (Inder)";
run;

proc sort data=lbwi_urine_nat; by id dol_urine_nat;run;
data lbwi_urine_nat; set lbwi_urine_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table lbwi_table_output as
select a.*, b.lbwi_urine_nat_stat
from lbwi_table_output as a left join
lbwi_urine_nat as b 
on a.id=b.id and a.seq=b.seq;

drop table lbwi_urine_nat;
quit;

/**** LBWI BLOOD NAT *****/
proc sql;
create table lbwi_blood_nat as
select distinct a.id,DateOfBirth, DateBloodCollected,NATTestResult,NATCopyNumber
from cmv.Lbwi_Blood_NAT_Result as a left join enrolled as b
on a.id=b.id;

quit;
data lbwi_blood_nat; set lbwi_blood_nat;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

dol_lbwi_nat=DateBloodCollected - DateOfBirth;
if NATTestresult In (1,2) then 
lbwi_blood_NAT_stat= "d" || compress(dol_lbwi_nat) ||  " (" || compress(put(NATTestresult ,nat_short.)) || ")";
else if NATTestresult In (3,4) then 
lbwi_blood_NAT_stat= "d" || compress(dol_lbwi_nat) ||  " (" || compress(put(NATTestresult ,nat_short.)) || " :" || compress(NATCopyNumber) || "c/ml)";

run;

proc sort data=lbwi_blood_nat; by id dol_lbwi_nat;run;



proc sort data=lbwi_blood_nat; by id dol_lbwi_nat;run;
data lbwi_blood_nat; set lbwi_blood_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table lbwi_table_output as
select a.*, b.lbwi_blood_NAT_stat
from lbwi_table_output as a left join
lbwi_blood_nat as b 
on a.id=b.id and a.seq=b.seq;

drop table lbwi_blood_nat;
quit;


/**** now remove unwanted rows *****/

proc sql;
create table lbwi_table_output as
select *
from lbwi_table_output
where lbwi_blood_NAT_stat is not null or lbwi_urine_NAT_stat is not null ;

quit;
