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
quit;

data cmv_id; set cmv_id;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;


proc sql;
create table BFeed as
select distinct id , input(substr(put(id,7.), 1, 5),5.) as moc_id, FeedStatus from cmv.plate_020 where FeedStatus=1;


create table tx as
select distinct id , 1 as tx_source , input(substr(put(id,7.), 1, 5),5.) as moc_id from cmv.plate_031  ;

create table lbwi_count as
select  count(*) as lbwi_count , input(substr(put(id,7.), 1, 5),5.) as moc_id from  enrolled group by moc_id;

create table lbwi_nat as
select  max(NATTestResult) as lbwi_nat ,input(substr(put(id,7.), 1, 5),5.) as moc_id
from cmv.Lbwi_Blood_NAT_Result where NATTestResult in (2,3)
group by moc_id;

create table UrineTestResult as
select  max(urineTestResult) as UrineTestResult ,input(substr(put(id,7.), 1, 5),5.) as moc_id
from cmv.Lbwi_Urine_NAT_Result where UrineTestResult in (2,3)
group by moc_id;
quit;


/**** get moc table ****/

proc sql;
create table moc_table as
select distinct a.id, a.moc_id, ComboTestResult,IgMTestResult,b.FeedStatus,tx_source,lbwi_count,
lbwi_nat,UrineTestResult,1 as seq
from 
(select distinct id, moc_id, ComboTestResult,IgMTestResult 
from cmv_id 
where ComboTestResult is not null) as a
left join 
BFeed as b on a.moc_id=b.moc_id

left join
tx as c on  a.moc_id=c.moc_id
left join
lbwi_count as d on  a.moc_id=d.moc_id
left join
lbwi_nat as e on  a.moc_id=e.moc_id

left join
UrineTestResult as f on  a.moc_id=f.moc_id
;

drop table BFeed; drop table tx; drop table lbwi_count;
drop table lbwi_nat; drop table UrineTestResult;

quit;

/**** now replicate moc_table to append *****/


data moc_table_output; set moc_table;



output; seq=2; output;seq=3;output; seq=4; output;seq=5; output;seq=6; output;seq=7;output; seq=8;output;

run;


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

data bm_culture; set bm_culture;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


/********************** MOC 30043 BM culture data for wk 7 positive , Wk 12 Negative *************************/
/***************** DCC does not have this data because test was ordered as standard of care ******************/

data bm_culture;

set bm_culture;

if moc_id = 30043 then 

milk_culture_stat = "d14(Neg)\nWk7(Pos)\nWk12(Neg)";
run;

proc sql;
create table moc_table_output as
select a.*, b.milk_culture_stat
from moc_table_output as a left join
bm_culture as b 
on a.moc_id=b.moc_id and a.seq=b.seq;

drop table bm_culture;
quit;

/***** BM NAT *****/

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

quit;


data bm_nat_long; set bm_nat_long;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

dol_bm_nat=sampledate - DateOfBirth;
if BM_nat_result In (2,3) then 
bm_NAT_stat= "d" || compress(dol_bm_nat) ||  " (" || compress(put(BM_nat_result ,nat_short.)) || " :" || compress(nat_copy) || "c/ml)";
else if BM_nat_result In (1,4) then 
bm_NAT_stat= "d" || compress(dol_bm_nat) ||  " (" || compress(put(BM_nat_result ,nat_short.)) || ")";

run;


proc sort data=bm_nat_long; by id dol_bm_nat;run;
data bm_nat_long; set bm_nat_long;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table moc_table_output as
select a.*, b.bm_NAT_stat
from moc_table_output as a left join
bm_nat_long as b 
on a.moc_id=b.moc_id and a.seq=b.seq;

drop table bm_nat_long;
quit;


/**** moc _nat ****************/

proc sql;

create table moc_nat as
select a.*,b.DateOfBirth
from cmv.moc_nat as a left join 
enrolled as b
on a.id=b.id;

quit;

data moc_nat; set moc_nat;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);

moc_nat_dol=DateBloodReceived - DateOfBirth;
if nattestresult In (2,3) then 
moc_nat_stat= "d" || compress(moc_nat_dol) ||  " (" || compress(put(nattestresult ,nat_short.)) || ")";
else if nattestresult In (1,4) then 
moc_nat_stat= "d" || compress(moc_nat_dol) ||  " (" || compress(put(nattestresult ,nat_short.)) || ")";

run;
proc sort data=moc_nat; by id moc_nat_dol;run;
data moc_nat; set moc_nat;by id ;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table moc_table_output as
select a.*, b.moc_nat_stat
from moc_table_output as a left join
moc_nat as b 
on a.moc_id=b.moc_id and a.seq=b.seq;

drop table moc_nat;
quit;


/**** moc_ igg table ****/

proc sql;
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
quit;

data moc_igg; set moc_igg;

id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
igg_dol=DateBloodReceived - DateOfBirth;
if iggtestresult In (2,3) then 
moc_igg_stat= "d" || compress(igg_dol) ||  " (" || compress(put(iggtestresult ,UrineCulture.)) || ")";
else if iggtestresult In (1,4) then 
moc_igg_stat= "d" || compress(igg_dol) ||  " (" || compress(put(iggtestresult ,UrineCulture.)) || ")";

run;

proc transpose data=moc_igg out=moc_igg_wide prefix=igg_dol;
by id;id igg_dol; var moc_igg_stat;
run;

data moc_igg; set moc_igg;by id;
if FIRST.id then seq=0; seq+1;
if Last.id then return;
run;


proc sql;
create table moc_table_output as
select a.*, b.moc_igg_stat
from moc_table_output as a left join
moc_igg as b 
on a.moc_id=b.moc_id and a.seq=b.seq;

drop table moc_igg;
quit;


/**** now remove unwanted rows *****/

proc sql;
create table moc_table_output as
select *
from moc_table_output
where moc_igg_stat is not null or moc_nat_stat is not null or bm_NAT_stat is not null or milk_culture_stat is not null;

quit;

data moc_table_output; set moc_table_output;

if seq > 1 then do; ComboTestResult=.; IgMTestResult=.;lbwi_count=.;

end;
if seq = 1 and milk_culture_stat = "" then milk_culture_stat="N/A";
run;

/************************* moc table Output *************/

options nodate orientation=portrait;
ods escapechar="\";

ods rtf file = "&output./annual/&cmv_survey_summary_file.cmv_survey2_new.rtf"  style = journal toc_data startpage = yes bodytitle;

ods noproctitle proclabel "&cmv_survey_summary_title : CMV - surveillance summary";

/**** this table comes from this file  ****/

title1  justify = center "&cmv_survey_summary_title : CMV - surveillance if MOC/LBWI NAT positive or IgG Positive or MOC IgM Positive ( MOC=&moc LBWI=&lbwi) ";

proc report data=moc_table_output nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;



column  moc_id   ComboTestResult IgMTestResult moc_igg_stat bm_NAT_stat moc_nat_stat milk_culture_stat 
lbwi_count  lbwi_nat UrineTestResult FeedStatus tx_source dummy;

define moc_id /  group    Left    " MOC id " ;
define ComboTestResult/      Left    " IgG/IgM_Combo " format=igg.;
define IgMTestResult/      Left    " IgM" format=igg.;
define lbwi_count /      Left    "LBWI " format=l_count.;
define moc_igg_stat /      Left    " MOC_IgG " ;
define bm_NAT_stat /    Left    " B Milk_NAT " ;
define moc_nat_stat /      Left    " MOC_Blood_NAT " ;
define milk_culture_stat /    left    " Milk_Culture";
define lbwi_nat/  group    center    " LBWI_Blood_NAT_Positive? " format=lbwi_nat.;
define UrineTestResult/ group    center    " LBWI_Urine_NAT_Positive? " format=lbwi_nat.;
define FeedStatus/ group    center    " LBWI_Breast_Fed? " format=outcome.;
define tx_source /  group      style(column) = [just=center cellwidth=0.5in] " LBWI Tx? " format=outcome.;
define dummy/NOPRINT ;

rbreak after / skip ;
compute after moc_id;
line '';
endcomp;

run;

ods rtf close;
quit;
