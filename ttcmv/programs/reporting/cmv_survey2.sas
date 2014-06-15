***************************
*program:	cmv_survey.sas
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

proc format;
value nat
1="N"
2="LP"
3="P"
4="I"
.="-"
;
value igM
.="IgM-Neg"
2="IgM-Pos"
;

value igg
1="Negative"
2="Positive"
3="Inconclusive"
;


value nat_long
1="Not detected"
2="Low Positive"
3="Positive"
4="Indeterminate"
.="Pending"
99="Pending"
;

value nat_short
1="ND"
2="LowPos"
3="Pos"
4="Indet"
.="Pending"
99="Pending"
;

value nat_longX
1="Not detected"
2="Low Positive"
3="Positive"
4="Indeterminate"
.="Not detected"
99="Pending"
;


value DFSEQ
1='DOB'
21='DOL 21'
40='DOL 40'
60='DOL 60'
63='EOS or DOL 90'
65='Tx 7 days before Dx'
85='Unscheduled'
91-96='Unscheduled'
;
value Bfed
1='Yes'
.='No';

value death
6='Y';

value l_count
1='Singleton'
2='Twin'
3='Triplets'
;

value  outcome
1='Yes'
.='No';

value  lbwi_nat
2='Yes'
3='Yes'
.='No'
4='Indet';

value gender
1='M'
2='F';

value deathcau
1='CMV'
2='IVH'
3='Inf/Sep'
4='Tx'
5='NEC'
6='BPD'
7='PDA'
8='SAE';

value UrineCulture
99='.'
1='Neg'
2='Pos'
3='Inconclusive';
run;

proc sql;



create table enrolled as
select a.id  , LBWIDOB as DateOfBirth,GestAge,BirthWeight,Gender 
from 
/*cmv.valid_ids */ ( select * from  cmv.Eligibility where Enrollmentdate is not null  ) as a
left join

cmv.LBWI_Demo as b
on a.id =b.id
where a.id not in ( 1002811,3001511)

;

quit;

/**** IgM Positive Moms *****************/

data moc_igM_positive (keep = id id2  moc_id IgMTestResult); 
set cmv.Moc_sero;  
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

run;

data moc_igM_positive ; set  moc_igM_positive ; where IgMTestResult=2;run;

data enrolled; set enrolled;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;


proc sql;
create table moc_igM_positive_2 as
select a.id, "moc_IgM_Positive" as cmv_survey_type
from enrolled as a
where moc_id in (Select moc_id from moc_igM_positive);



/* all lbwi with urine or blood nat positive test or moc sero IgM positive*/
create table cmv_id as
select distinct(id) as id ,"urine_nat_positive" as cmv_survey_type
from cmv.Lbwi_urine_NAT_Result
where UrineTestResult in (2,3)
union

select distinct(id) as id ,"blood_nat_positive" as cmv_survey_type
from cmv.Lbwi_Blood_NAT_Result
where NATTestResult in (2,3)
union
select distinct(id) as id ,"moc_IgM_Positive" as cmv_survey_type
from moc_igM_positive_2 as a  

union
select distinct(id) as id ,"moc_Blood_NAT_Positive" as cmv_survey_type
from cmv.moc_nat as a where  NATTestResult in (2,3,4)

union
select distinct(id) as id ,"moc_IgG_Positive" as cmv_survey_type
from cmv.plate_209 as a where  IgGTestResult in (2,3)

union
select distinct(id) as id ,"moc_IgG_Positive" as cmv_survey_type
from cmv.plate_215 as a where  IgGTestResult in (2,3)
;


create table cmv_id as
select a.*,b.ComboTestResult, IgMTestResult
from cmv_id as a left join
cmv.Moc_sero as b
on a.id=b.id;

create table cmv_id as
select a.*,b.IgGTestResult, IgMTestDate
from cmv_id as a left join
( select id,IgGTestResult, IgMTestDate from cmv.plate_209 where IgGTestResult in (2,3) 

 ) as b
on a.id=b.id;


create table cmv_id as
select a.*,b.DateofBirth
from cmv_id as a
left join
enrolled as b
on a.id=b.id;

/**** get lbwi NAT results ******/

create table lbwi_blood_nat as
select distinct a.id,a.DateofBirth, b.DateBloodCollected,b.NATTestResult,b.NATCopyNumber
from cmv_id as a left join
cmv.Lbwi_Blood_NAT_Result as b
on a.id=b.id
order by a.id, DateofBirth,DateBloodCollected;


create table all_igm as

select id, dfseq, DateBloodCollected format=date7. as BloodDate, IgMTestResult from cmv.plate_209 where IgMTestResult in (2,3) 
union
select id, dfseq,DateBloodReceived format=date7. as BloodDate,IgMTestResult from cmv.moc_sero where IgMTestResult in (2,3) 

;


 

quit;

data cmv_id; set cmv_id;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;

/*********** transpose BM NAT PCR plate 206,207*************/
proc sql;

create table bm_nat_long as
select id, milk_date_wk1 as sampledate,NATResult_wk1 as BM_nat_result,NATCopy_wk1 as nat_copy,"week1" as sample_time
from cmv.bm_nat where NATResult_wk1 In (1,2,3,4)
union
select id, milk_date_wk3 as sampledate,NATResult_wk3 as BM_nat_result,NATCopy_wk3 as nat_copy,"week3" as sample_time
from cmv.bm_nat where NATResult_wk3 In (1,2,3,4)
union

select id, milk_date_wk4 as sampledate,NATResult_wk4 as BM_nat_result,NATCopy_wk4 as nat_copy,"week4" as sample_time
from cmv.bm_nat where NATResult_wk4 In (1,2,3,4)

union

select id, milk_date_d34 as sampledate,NATResult_d34 as BM_nat_result,NATCopy_d34 as nat_copy,"Day 34" as sample_time
from cmv.bm_nat where NATResult_d34 In (1,2,3,4);

create table bm_nat_long as
select a.*,b.DateOfBirth
from bm_nat_long as a left join 
enrolled as b
on a.id=b.id;


create table moc_igg as
select id, DateBloodReceived, iggtestresult from cmv.plate_215 where iggtestresult in (2,3)
union
select id, DateBloodReceived, iggtestresult from cmv.plate_209 where iggtestresult in (2,3)
;

create table moc_igg as
select a.*,b.DateOfBirth
from moc_igg as a left join 
enrolled as b
on a.id=b.id;

create table moc_nat as
select a.*,b.DateOfBirth
from cmv.moc_nat as a left join 
enrolled as b
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


proc transpose data=lbwi_blood_nat out=lbwi_blood_nat_wide prefix=dol_lbwi_nat;
by id;id dol_lbwi_nat; var lbwi_blood_NAT_stat;
run;


 
data bm_nat_long; set bm_nat_long;
dol_bm_nat=sampledate - DateOfBirth;
if BM_nat_result In (2,3) then 
bm_NAT_stat= "d" || compress(dol_bm_nat) ||  " (" || compress(put(BM_nat_result ,nat_short.)) || " :" || compress(nat_copy) || "c/ml)";
else if BM_nat_result In (1,4) then 
bm_NAT_stat= "d" || compress(dol_bm_nat) ||  " (" || compress(put(BM_nat_result ,nat_short.)) || ")";

run;


data moc_igg; set moc_igg;

igg_dol=DateBloodReceived - DateOfBirth;
if iggtestresult In (2,3) then 
moc_igg_stat= "d" || compress(igg_dol) ||  " (" || compress(put(iggtestresult ,UrineCulture.)) || ")";
else if iggtestresult In (1,4) then 
moc_igg_stat= "d" || compress(igg_dol) ||  " (" || compress(put(iggtestresult ,UrineCulture.)) || ")";

run;

proc transpose data=moc_igg out=moc_igg_wide prefix=igg_dol;
by id;id igg_dol; var moc_igg_stat;
run;

data moc_nat; set moc_nat;
moc_nat_dol=DateBloodReceived - DateOfBirth;
if nattestresult In (2,3) then 
moc_nat_stat= "d" || compress(moc_nat_dol) ||  " (" || compress(put(nattestresult ,nat_short.)) || ")";
else if nattestresult In (1,4) then 
moc_nat_stat= "d" || compress(moc_nat_dol) ||  " (" || compress(put(nattestresult ,nat_short.)) || ")";

run;

proc sort data=bm_nat_long; by id dol_bm_nat;run;
data bm_nat_long; set bm_nat_long;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;

data moc_igg; set moc_igg;by id;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sort data=moc_nat; by id moc_nat_dol;run;
data moc_nat; set moc_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sort data=lbwi_blood_nat; by id dol_lbwi_nat;run;
data lbwi_blood_nat; set lbwi_blood_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;

create table bm_nat_long2 as
select * from bm_nat_long   order by id, dol_bm_nat;

create table cmv_id2 as
select a.*,b.bm_NAT_stat ,b.dol_bm_nat ,b.seq from 
cmv_id as a left join
 bm_nat_long2   as b
on a.id=b.id;
quit;
data cmv_id2; set cmv_id2; if seq=. then seq=1;run;
proc sql;

create table moc_igg2 as
select * from moc_igg  order by id, igg_dol;

create table cmv_id2 as
select a.*,b.moc_igg_stat ,b.igg_dol from 
cmv_id2 as a left join
 moc_igg2 as b
on a.id=b.id and a.seq=b.seq;


create table moc_nat2 as
select distinct moc_nat_dol, moc_nat_stat ,id, seq from moc_nat   order by id, seq;

create table cmv_id3 as
select a.*,b.moc_nat_stat ,b.moc_nat_dol from 
cmv_id2 as a left join
 moc_nat2 as b
on a.id=b.id and a.seq=b.seq;



create table cmv_id_final as
select distinct id , ComboTestResult ,  IgMTestResult ,  moc_igg_stat ,
         bm_NAT_stat, moc_nat_stat, moc_id,seq
 from cmv_id3 order by id, seq 
;
create table lbwi_count as
select moc_id, count(distinct(id)) as lbwi_count  from cmv_id_final group by moc_id;

create table cmv_id_final as
select a.* ,b.lbwi_count
 from cmv_id_final  as a left join
lbwi_count as  b 
on a.moc_id=b.moc_id
order by a.id, a.seq 
;
create table cmv_id_final as
select a.* ,b.lbwi_nat
 from cmv_id_final  as a left join
(select distinct id,moc_id, max(NATTestresult)as lbwi_nat   from lbwi_blood_nat where NATTestresult in (2,3) ) as b
on a.moc_id=b.moc_id
order by a.id, a.seq ;

quit;



/*** Breast milk culture ***/
proc sql;
create table bm_culture as
select a.*,b.DateOfBirth
from cmv.Plate_216_long as a left join 
enrolled as b
on a.id=b.id;

quit;




data bm_culture; set bm_culture;
length milk_culture_stat $ 80;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

dol_milk_culture=milk_date - DateOfBirth;
if conv_test In (2) or rapid_test In (2) then 
milk_culture_stat= "d" || compress(dol_milk_culture) ||  " (Pos)";
else if conv_test In (1) or rapid_test In (1) then
milk_culture_stat= "d" || compress(dol_milk_culture) ||  " (Neg)";

run;

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

data lbwi_urine_nat; set lbwi_urine_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;

proc sql;
create table cmv_id_final as
select a.* ,b.milk_culture_stat
 from cmv_id_final  as a left join
bm_culture as b
on a.moc_id=b.moc_id
order by a.id, a.seq ;

update cmv_id_final
set milk_culture_stat = "N/A"
where milk_culture_stat is null;


create table cmv_id_final as
select a.* ,b.FeedStatus
from cmv_id_final as a left join
(select distinct id , FeedStatus from cmv.plate_020 where FeedStatus=1) as b
on a.id=b.id ;

create table cmv_id_final as
select a.* ,b.tx_source
from cmv_id_final as a left join
( select distinct id , 1 as tx_source from cmv.plate_031 )  as b 
on a.id=b.id;


create table cmv_id_final as
select a.* ,b.UrineTestResult
from cmv_id_final as a left join
( select moc_id, min(UrineTestResult) as UrineTestResult from cmv.plate_211_long where UrineTestResult In (3,4))  as b 
on a.moc_id=b.moc_id;



quit;



data cmv_id_final; set cmv_id_final;by id ;
if FIRST.id then lbwi_seq=0; lbwi_seq+1;
if Last.id then return;
run;




proc sql;

create table lbwi_blood_nat2 as
select distinct dol_lbwi_nat, lbwi_blood_NAT_stat ,id, seq from lbwi_blood_nat   order by id, seq;


create table cmv_id_final2 as
select a.*,b.lbwi_blood_NAT_stat , b.dol_lbwi_nat from 
cmv_id_final as a  left join
 lbwi_blood_nat2 as b
on a.id=b.id ;

create table cmv_id_final3 as
select lbwi_seq , id , ComboTestResult ,  IgMTestResult ,  moc_igg_stat ,
         bm_NAT_stat, moc_nat_stat, moc_id,seq,lbwi_blood_NAT_stat
 from cmv_id_final2 where lbwi_seq  =1  order by id, seq ;





quit;

/***** tx record *******/

proc sql;



create table lbwi_tx_1 as
select a.id,b.lbwi_blood_NAT_stat,b.dol_lbwi_nat
from 
(select distinct id , moc_id from cmv_id_final ) as a left join
lbwi_blood_nat as b 
on a.id=b.id;

create table lbwi_tx_2 as
select a.* ,b.tx_source
from lbwi_tx_1 as a left join
( select distinct id , 1 as tx_source from cmv.plate_031 )  as b 
on a.id=b.id;

create table sus_cmv as 
select a.id,a.moc_id, CMVDisConf ,CMVDisNo
from
(select distinct id , moc_id from cmv_id_final ) as a left join
(select id, CMVDisConf ,CMVDisNo ,UrineCultureResult from cmv.sus_cmv) as b
on a.id=b.id
;


quit;

 data sus_cmv; length cmv_disease $ 20; set sus_cmv;
if CMVDisConf = 0 then cmv_disease="No";
else if CMVDisConf = 1 then cmv_disease="Yes" || "\n " || compress(put(UrineCultureResult,UrineCulture.));
else if CMVDisConf = . then cmv_disease="-";
run;

proc sql;
create table lbwi_tx_3 as
select a.* ,b.cmv_disease
from lbwi_tx_2 as a left join
sus_cmv as b 
on a.id=b.id;

create table lbwi_tx_4 as
select a.* ,b.BPD,IsOxygenDOL28
from lbwi_tx_3 as a left join
( select id, 1 as BPD,IsOxygenDOL28 from cmv.bpd) as b 
on a.id=b.id;

create table lbwi_tx_5 as
select a.* ,b.ROP
from lbwi_tx_4 as a left join
( select id, 1 as ROP from cmv.ROP) as b 
on a.id=b.id;

create table lbwi_tx_6 as
select a.* ,b.PDA,b.PDADiagDate
from lbwi_tx_5 as a left join
( select id, 1 as PDA,PDADiagDate from cmv.PDA) as b 
on a.id=b.id;

create table lbwi_tx_7 as
select a.* ,b.NEC
from lbwi_tx_6 as a left join
( select id, 1 as NEC from cmv.NEC) as b 
on a.id=b.id
order by id , dol_lbwi_nat
;


create table lbwi_tx_7 as
select a.* ,b.IVH,IVhDiagDate
from lbwi_tx_7 as a left join
( select id, 1 as IVH, IVhDiagDate from cmv.IVH) as b 
on a.id=b.id
order by id , dol_lbwi_nat
;

create table lbwi_tx_7 as
select a.* ,b.FeedStatus
from lbwi_tx_7 as a left join
(select distinct id , FeedStatus from cmv.plate_020 where FeedStatus=1) as b
on a.id=b.id 
order by id , dol_lbwi_nat;


create table lbwi_tx_7 as
select a.* ,DateofBirth,GestAge,BirthWeight,Gender
from lbwi_tx_7 as a left join
enrolled as b
on a.id=b.id 
order by id , dol_lbwi_nat;

create table death_all as
select id, deathdate , deathcause from cmv.plate_100
union
select id, deathdate ,8 as deathcause from cmv.plate_101 where deathdate is not null;

create table lbwi_tx_7 as
select a.* ,deathdate ,deathcause
from lbwi_tx_7 as a left join
death_all as b
on a.id=b.id 
order by id , dol_lbwi_nat;
quit;

data lbwi_tx_7; set lbwi_tx_7;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table lbwi_tx_7 as
select a.* ,lbwi_urine_nat_stat
from lbwi_tx_7 as a left join
lbwi_urine_nat as b
on a.id=b.id and a.seq=b.seq
order by id , dol_lbwi_nat;

quit;

data lbwi_tx_7; length pda_stat $ 20;length death_stat $ 20;length ivh_stat $ 20;
set lbwi_tx_7;
death_day= deathdate - DateOfBirth;

if death_day = . then
death_stat="No";

else if death_day ~=. then 
do;    
death_stat="Yes\n d" || compress(death_day) || "\n" || compress(put(deathcause,deathcau.));
end;

pda_stat =compress(put(pda,outcome.));

if pda eq 1 then do;
PDA_days=PDADiagDate - DateOfBirth;
pda_stat =compress(pda_stat) || "\n d" || compress(PDA_days);
end;


ivh_stat =compress(put(ivh,outcome.));

if ivh eq 1 then do;
ivh_days=ivhDiagDate - DateOfBirth;
ivh_stat =compress(ivh_stat) || "\n d" || compress(ivh_days);
end;


age_wt_gender_stat= compress(put(gender,gender.)) || "\n" ||   compress(Birthweight)|| "g\n" ||   compress(gestage) || "wk";
run;


/**** get tx and donor ******************/
proc sql;

create table tx_donor as
select distinct(a.id),DateOfBirth, b.DonorUnitId,source,dfseq,DateTransfusion,source
from lbwi_tx_7 as a left join
(
select  dfseq, DonorUnitId ,id , DateTransfusion, "RBC" as source from cmv.plate_031
union
select  dfseq, DonorUnitId ,id , DateTransfusion,"Plt" as source from cmv.plate_033
union
select dfseq, DonorUnitId ,id ,DateTransfusion, "FFP" as source from cmv.plate_035
union
select dfseq, DonorUnitId ,id ,DateTransfusion, "Cry" as source from cmv.plate_037
) as b
on a.id=b.id
order by id, source, DonorUnitId;
;


create table tx_donor_count as
select distinct a.id,rbc_tx,plt_tx,ffp_tx,cry_tx

from lbwi_tx_7 as a left join
(select id, count(*) as rbc_tx from tx_donor  where source='RBC' group by id) as b 
on a.id=b.id
left join
(select id, count(*) as plt_tx from tx_donor  where source='Plt' group by id) as c 
on a.id=c.id
left join
(select id, count(*) as ffp_tx from tx_donor  where source='FFP' group by id) as d 

on a.id=d.id
left join
(select id, count(*) as cry_tx from tx_donor  where source='Cry' group by id) as e 
on a.id=e.id;

quit;

data tx_donor_count;set tx_donor_count;
if rbc_tx =. then rbc_tx=0; 
if plt_tx =. then plt_tx=0; 
if ffp_tx =. then ffp_tx=0; 
if cry_tx =. then cry_tx=0; 

total_tx= rbc_tx +plt_tx +ffp_tx +cry_tx;



run;

proc sql;
create table lbwi_tx_7 as
select a.*,b.total_tx
from lbwi_tx_7 as a left join
tx_donor_count as b
on a.id=b.id order by id , dol_lbwi_nat;


quit;

data lbwi_tx_7; length tx_stat $ 30;
set lbwi_tx_7;

if tx_source = 1 then tx_stat ="Yes \n" || compress(total_tx);
else if tx_source =. then tx_stat ="No" ;
run;


/**** Overall summary ****/

data completedstudylist; set cmv.completedstudylist;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;


proc sql;
create table overall as
select count(distinct(id)) as count ,"LBWI NAT Positive" as variable, 1 as group
from  cmv.Lbwi_Blood_NAT_Result where NATTestResult in (2,3)
union
select count(distinct(id)) as count ,"MOC IgG Positive" as variable , 2 as group
from  moc_igg where iggTestResult in (2)

union
select count(distinct(id)) as count ,"MOC IgM Positive" as variable , 3 as group
from moc_igM_positive where IgMTestResult in (2)

union
select count(distinct(id)) as count ,"Breast Milk NAT Positive/Indeterminate" as variable , 4 as group
from bm_nat_long where BM_nat_result in (2,3,4)

union
select count(distinct(id)) as count ,"MOC NAT Positive/Indeterminate" as variable , 5 as group
from moc_nat where nattestresult in (2,3,4)

union
select count(distinct(id)) as count ,"LBWI Breast Fed" as variable , 6 as group
from cmv.plate_020 where FeedStatus in (1) 
union
(select count(distinct(a.id)) as count ,"LBWI Transfused" as variable , 7 as group
from cmv.plate_031 as a inner join enrolled /*cmv.valid_ids*/ as b on a.id=b.id)

union
(

select count(distinct(a.id)) as count ,"LBWI Urine NAT Positive" as variable , 8 as group
from cmv.plate_211_long as a inner join enrolled /*cmv.valid_ids*/ as b on a.id=b.id where a.UrineTestResult  in (2,3))

union
select count(distinct(DonorUnitId)) as count ,"WBC Filter Failure Donor Units" as variable , 9 as group
from cmv.plate_002_bu where wbc_count1 > 5 or wbc_count2 > 5
;

/*********completed overall ****************/
create table overall_completed as
select count(distinct(a.id)) as count ,"LBWI NAT Positive/Indeterminate" as variable, 1 as group
from  cmv.Lbwi_Blood_NAT_Result as a inner join completedstudylist as b on a.id=b.id where NATTestResult in (2,3)
union
select count(distinct(a.id)) as count ,"MOC IgG Positive" as variable , 2 as group
from  moc_igg as a inner join completedstudylist as b on a.id=b.id where iggTestResult in (2)

union
select count(distinct(a.id)) as count ,"MOC IgM Positive" as variable , 3 as group
from moc_igM_positive as a inner join completedstudylist as b on a.id=b.id where IgMTestResult in (2)

union
select count(distinct(a.id)) as count ,"Breast Milk NAT Positive/Indeterminate" as variable , 4 as group
from bm_nat_long as a inner join completedstudylist as b on a.id=b.id where BM_nat_result in (2,3,4)

union
select count(distinct(a.id)) as count ,"MOC NAT Positive/Indeterminate" as variable , 5 as group
from moc_nat as a inner join completedstudylist as b on a.id=b.id where nattestresult in (2,3,4)

union
select count(distinct(a.id)) as count ,"LBWI Breast Fed" as variable , 6 as group
from cmv.plate_020 as a inner join completedstudylist as b on a.id=b.id where FeedStatus in (1) 
union
(select count(distinct(a.id)) as count ,"LBWI Transfused" as variable , 7 as group
from cmv.plate_031 as a inner join completedstudylist as b on a.id=b.id)

union
(

select count(distinct(a.id)) as count ,"LBWI Urine NAT Positive/Indeterminate" as variable , 8 as group
from cmv.plate_211_long as a inner join cmv.completedstudylist as b on a.id=b.id where a.UrineTestResult  in (2,3,4))

union
select count(distinct(DonorUnitId)) as count ,"WBC Filter Failure Donor Units" as variable , 9 as group
from cmv.plate_002_bu where wbc_count1 > 5 or wbc_count2 > 5
;


select count(distinct(moc_id)) format=3.0 into :moc_all from enrolled /*cmv.valid_ids*/;
select count(distinct(id)) format=3.0 into :lbwi_all from enrolled /*cmv.valid_ids*/;
select count(distinct(DonorUnitId)) format=3.0 into :filter_failed from cmv.plate_002_bu;

select count(distinct(moc_id)) format=3.0 into :moc_comp from completedstudylist;
select count(distinct(id)) format=3.0 into :lbwi_comp from completedstudylist;

quit;

data overall; set overall;
if group =. then do; variable="WBC Filter Failure Donor Units";  group =9; total=&filter_failed; end;
if group In(1,6,7,8) then do; total=&lbwi_all; end;
if group In(2,3,4,5)  then do; total=&moc_all; end;

stat = compress(count) || "/"  ||compress(total) || "(" || compress(put ((count/total)*100,3.0)) || "%)";
run;

data overall_completed; set overall_completed;
if group =. then do; variable="WBC Filter Failure Donor Units";  group =9; total=&filter_failed; end;
if group In(1,6,7,8) then do; total=&lbwi_comp; end;
if group In(2,3,4,5)  then do; total=&moc_comp; end;

comp_stat = compress(count) || "/"  ||compress(total) || "(" || compress(put ((count/total)*100,3.0)) || "%)";
run;

proc sql;

create table overall as
select * from overall order by group;

create table overall_all_comp as
select a.group,a.variable, comp_stat,stat 
from overall  as a inner join
overall_completed as b
on a.group=b.group

order by a.group;
quit;

/***** get sample size *****/

proc sql;
select count(distinct(moc_id)) format=2.0 into :moc from cmv_id_final;
select count(distinct(id)) format=3.0 into :lbwi from cmv_id_final;
quit;


/********************** MOC 30043 BM culture data for wk 7 positive , Wk 12 Negative *************************/
/***************** DCC does not have this data because test was ordered as standard of care ******************/

data cmv_id_final;

set cmv_id_final;

if moc_id = 30043 then 

milk_culture_stat = "d14(Neg)\nWk7(Pos)\nWk12(Neg)";
run;



/******************** Infection data ***************************/
proc sql;
create table infection as
select a.id,b.*
from (select distinct id from lbwi_tx_7) as a left join
cmv.infection_all as b
on a.id=b.id;
quit;


proc format;
value siteblood
1="Blood"
0="."
.=".";

value sitecns
1="CNS"
0="."
.=".";

value siteUT
1="UT"
0="."
.=".";

value siteCardio
1="Cardio"
0="."
.=".";

value siteResp
1="Lower Resp"
0="."
.=".";

value siteGI
1="GI"
0="."
.=".";

value siteSurgical
1="Surgical"
0="."
.=".";

value cultureSite
1="Blood"
2="Urine"
3="Wound"
4="Sputum/Trachael aspirate"
5="BAL"
6="CSF"
7="Stool"
8="Cathetar tip"
9="Other"
.=""
;

value cultureOrg
1="Stap epidermidis"
2="MSSA"
3="MRSA"
4="Vancomycin-susceptible Enterococcus faecalis"
5="Vancomycin-resistant Enterococcus faecalis"
6="Vancomycin-susceptible Enterococcus faecium"
7="Vancomycin-resistant Enterococcus faecium"
8="Kleb pneumoniae"
9="P aeruginosa"
10="Strep pneumoniae"
11="Strep viridans"
12="Strep agalactiae"
13="E coli"
14="Acinobacter baumannii"
15="Enterbacter cloace"
16="Enterbacter aerogenes"
17="Clostridium difficile"
18="Candida albicans"
19="Candida glabrata"
20="Candida tropicalis"
21="Influenza"
22="Henoch Schonlein purpura"
23="Respiratory Syntial virus"
24="Epstein Bar virus"
25="Enterovirus"
26="Adenovirus"
;

value yn
1="Yes"
0="No"
;


quit;
data infection; set infection;
length inf_site_stat $ 50;

length culture1_site_stat $ 50;
length culture2_site_stat $ 50;
length culture3_site_stat $ 50;
length culture4_site_stat $ 50;

length xray_conf $ 20;

if siteLowerResp = 1 and InfecConfirm = 1 then xray_conf="(Infiltrate confirmed)";
if siteLowerResp = 1 and InfecConfirm =0  then xray_conf="(Infiltrate NOT confirmed)";
if siteLowerResp = 1 and InfecConfirm not in (1,0)  then xray_conf="";
if siteLowerResp ~= 1   then xray_conf="";

inf_site_stat=put(siteblood,siteblood.) || "" || put(sitecns,sitecns.)
						|| "" || put(siteUT,siteUT.) || "" || put(sitecardio,sitecardio.)
						|| "" || put(siteLowerResp,siteResp.) || "" || xray_conf || put(siteGI,siteGI.)
						|| "" || put(siteSurgical,siteSurgical.);

if culture1Site ~= . then 
culture1_site_stat=put(culture1Site,cultureSite.) || "\n" || put(culture1org,cultureorg.);


if culture2Site ~= . then 
culture2_site_stat=put(culture2Site,cultureSite.) || "\n" || put(culture2org,cultureorg.);


if culture3Site ~= . then 
culture3_site_stat=put(culture3Site,cultureSite.) || "\n" || put(culture3org,cultureorg.);


if culture4Site ~= . then 
culture4_site_stat=put(culture4Site,cultureSite.) || "\n" || put(culture4org,cultureorg.);

run;

%include "tx_all.sas";

/************************* Output *************/

options nodate orientation=portrait;
ods escapechar="\";

ods rtf file = "&output./annual/&cmv_survey_summary_file.cmv_survey2.rtf"  style = journal toc_data startpage = yes bodytitle;


ods noproctitle proclabel "&cmv_survey_summary_title : CMV - surveillance summary";
title1 " Overall cohort statistics "; 

proc report data=overall_all_comp nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  variable stat comp_stat dummy;
define variable /  group order=data   Left    " " ;
define stat/group  order=internal    Left    " Statistics_(LBWI Up to date) " ;
define comp_stat/group  order=internal    Left    " Statistics _(LBWI who Completed)" ;
define dummy/NOPRINT ;
run;


/**** next two tables come from include file tx_all.sas ****/
title1  justify = center "&cmv_survey_summary_title : Parent donor unit statistics (Total donors = &tx_donor_macro / Total Tx &tx_count_macro) ";

title2 justify=center "pRBC TX= &tx_rbc_macro, Plt Tx=&tx_plt_macro, FFP Tx=&tx_ffp_macro, Cryo Tx=&tx_cryo_macro";
title3 justify=center  Number of LBWI transfused =&tx_lbwi_macro/&eos_lbwi_macro completed (&tx_pct_macro %) ;

proc report data=t_all_2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  variable category_txt stat dummy;
define variable /  group order=data   Left    " " ;
define category_txt/group  order=internal   Left    "  " ;
define stat/group  order=internal    Left    " " ;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after variable;
line '';
endcomp;
run;

title1 justify = center "Donor unit Residual WBC count for detectable units";
title2 "";
title3 "";
proc means data=tx_eos_wbc N mean min p25 median p75 max maxdec=1;

var wbc_count1;
run;

/**** this table comes from this file  ****/

title1  justify = center "&cmv_survey_summary_title : CMV - surveillance if MOC/LBWI NAT positive or IgG Positive or MOC IgM Positive ( MOC=&moc LBWI=&lbwi) ";
/*title2  justify = center " ( MOC=&moc LBWI=&lbwi) ";
title3 "MOC 30043 BM Culture (wk7):POSITIVE and BM Culture (wk12):NEGATIVE. DCC does not have this data." ;
*/
proc report data=cmv_id_final nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

where ComboTestResult <> .;

column  moc_id   ComboTestResult IgMTestResult moc_igg_stat bm_NAT_stat moc_nat_stat milk_culture_stat 
lbwi_count  lbwi_nat UrineTestResult FeedStatus tx_source dummy;

define moc_id /  group order=internal   Left    " MOC id " ;
define ComboTestResult/group  order=internal    Left    " IgG/IgM_Combo " format=igg.;
define IgMTestResult/group   order=internal   Left    " IgM" format=igg.;
define lbwi_count /group   order=internal   Left    "LBWI " format=l_count.;
define moc_igg_stat /  order=internal    Left    " MOC_IgG " ;
define bm_NAT_stat /  order=internal  Left    " B Milk_NAT " ;
define moc_nat_stat /   order=internal   Left    " MOC_Blood_NAT " ;
define milk_culture_stat /   group order =internal left    " Milk_Culture";
*define id / group  order=data   Left    " LBWI_id " ;
define lbwi_nat/ group  order=internal   center    " LBWI_Blood_NAT_Positive? " format=lbwi_nat.;
define UrineTestResult/ group  order=internal   center    " LBWI_Urine_NAT_Positive? " format=lbwi_nat.;
define FeedStatus/ group  order=internal   center    " LBWI_Breast_Fed? " format=outcome.;
define tx_source /group   order=data      style(column) = [just=center cellwidth=0.5in] " LBWI Tx? " format=outcome.;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after moc_id;
line '';
endcomp;

run;

title1  justify = center "&cmv_survey_summary_title : CMV - surveillance resuts if LBWI / MOC CMV NAT positive or IgG Positive or MOC IgM Positive ( MOC=&moc LBWI=&lbwi)";
/*title2  justify = center " ( MOC=&moc LBWI=&lbwi)";
title3 "";*/
proc report data=lbwi_tx_7 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  id age_wt_gender_stat death_stat lbwi_blood_NAT_stat lbwi_urine_nat_stat FeedStatus tx_stat cmv_disease nec pda_stat rop bpd IVH_stat  dummy;

define id / group  order=data  style(column) = [just=center cellwidth=0.9in]    " LBWI_id " ;
define age_wt_gender_stat / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Gender_BirthWeight_Gest Age" ;

define death_stat /  group order=data   style(column) = [just=center cellwidth=0.5in]   "Death" ;


define lbwi_blood_NAT_stat /   order=data   style(column) = [just=center cellwidth=1in font_size=8pt]   " LBWI_Blood_NAT " ;
define lbwi_urine_nat_stat /   order=data   style(column) = [just=center cellwidth=.8in font_size=8pt]   " LBWI_Urine_NAT " ;


define FeedStatus /group   order=data      style(column) = [just=center cellwidth=0.5in font_size=8pt] " LBWI_Breast_Fed?" format=outcome.;
define tx_stat /group   order=data      style(column) = [just=center cellwidth=0.5in font_size=8pt] " LBWI_Tx?_Total " ;
define cmv_disease /group   order=data   style(column) = [just=center cellwidth=0.5in font_size=8pt]    " CMV_dis_confirmed? " ;
define NEC /group          " NEC " style(column) = [just=center cellwidth=0.4in font_size=8pt] format=outcome.;

define PDA_stat /group          " PDA " style(column) = [just=center cellwidth=0.4in font_size=8pt] ;
define ROP /group          " ROP " style(column) = [just=center cellwidth=0.4in font_size=8pt] format=outcome.;
define BPD /group         " BPD " style(column) = [just=center cellwidth=0.4in] format=outcome.;
define IVH_stat /group         " IVH " style(column) = [just=center cellwidth=0.5in] ;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after id;
line '';
endcomp;
run;


/**** infection *****/

title1  justify = center "&cmv_survey_summary_title : LBWI Infections";

proc report data=infection nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

where siteblood=1 or sitecns=1 or siteUT=1 or sitecardio=1 or siteLowerResp=1 or 
siteGI=1 or siteSurgical=1 ;



column  id  inf_site_stat culturePositive culture1_site_stat culture2_site_stat culture3_site_stat culture4_site_stat dummy;

define id / group  order=data  style(column) = [just=center cellwidth=0.9in]    " LBWI_id " ;
define inf_site_stat / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Infection_site" ;
define culturePositive / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Culture_Positive" format=yn.;


define culture1_site_stat / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Culture 1_Site_Org" ;
define culture2_site_stat/ group  order=data  style(column) = [just=center cellwidth=0.8in]    "Culture 2_Site_Org" ;
define culture3_site_stat / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Culture 3_Site_Org" ;
define culture4_site_stat / group  order=data  style(column) = [just=center cellwidth=0.8in]    "Culture 4_Site_Org" ;

define dummy/NOPRINT ;

rbreak after / skip ;
compute after id;
line '';
endcomp;
run;


ods rtf close;
quit;
