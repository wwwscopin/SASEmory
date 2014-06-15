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

run;

proc sql;

/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where (Enrollmentdate is not null ) and a.id not in (3003411,3003421);
*/

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

quit;

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
;



create table summary as
select distinct id as id, FeedStatus
from cmv.plate_020
where feedstatus=1;

quit;

data cmv_id; 
set cmv_id;  
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;

data bm_nat; set cmv.bm_nat;
id2 = left(trim(id));
moc_id = input(substr(id2, 1, 5),5.);
run;

data summary; set summary;
id_x = left(trim(id));
moc_id2 = input(substr(id_x, 1, 5),5.);

run;

proc sql;

create table cmv_id as
select a.* ,StudyLeftDate
from cmv_id as a 
left join
cmv.endofstudy as b
on a.id=b.id ;

create table cmv_id as
select a.* ,b.DateOfBirth
from cmv_id as a 
left join
enrolled as b
on a.id=b.id ;




create table seroneg as
select a.* ,b.IgMTestResult
from cmv_id as a left join
moc_igM_positive as b
on a.moc_id=b.moc_id;

create table seroneg as
select a.* ,b.UrineTestResult,b.UrineCopyNumber
from seroneg as a left join
( select * from cmv.Lbwi_urine_NAT_Result where dfseq =1 ) as b
on a.id =b.id
;


create table seroneg as
select distinct a.* ,b.FeedStatus,moc_id2
from seroneg as a left join
summary as b
on a.moc_id = b.moc_id2;


create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_dob,b.NATCopyNumber as NATCopyNumber_dob
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =1)   as b
on a.id =b.id
;

create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_dol21,b.NATCopyNumber as NATCopyNumber_dol21
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =21)   as b
on a.id =b.id
;


create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_dol40,b.NATCopyNumber as NATCopyNumber_dol40
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =40)   as b
on a.id =b.id
;

create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_dol60,b.NATCopyNumber as NATCopyNumber_dol60
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =60)   as b
on a.id =b.id
;

create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_dol90,b.NATCopyNumber as NATCopyNumber_dol90
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =63)   as b
on a.id =b.id
;

create table seroneg as
select a.* ,b.NATTestResult as NATTestResult_tx,b.NATCopyNumber as NATCopyNumber_tx
from seroneg as a left join
(select id, NATTestResult, NATCopyNumber
from 
cmv.Lbwi_Blood_NAT_Result  where  dfseq =65)   as b
on a.id =b.id
;


create table seroneg as
select a.* , b.rbc_tx ,donor_rbc
from seroneg as a left join 
(
select count(*) as rbc_tx, id ,count(distinct(DonorUnitId)) as donor_rbc
from cmv.rbctx  group by id) as b 

on a.id=b.id
;

create table seroneg as
select a.* , b.plt_tx ,donor_plt
from seroneg as a left join 
(
select count(*) as plt_tx, id ,count(distinct(DonorUnitId)) as donor_plt
from cmv.plate_033  group by id) as b 

on a.id=b.id
;

create table seroneg as
select a.* , b.ffp_tx ,donor_ffp
from seroneg as a left join 
(
select count(*) as ffp_tx, id,count(distinct(DonorUnitId)) as donor_ffp
from cmv.plate_035  group by id) as b 

on a.id=b.id
;


create table seroneg as
select a.* , b.cryo_tx ,donor_cryo
from seroneg as a left join 
(
select count(*) as cryo_tx, id,count(distinct(DonorUnitId)) as donor_cryo
from cmv.plate_037  group by id) as b 

on a.id=b.id
;

create table seroneg as
select a.* , b.*
from seroneg as a left join
bm_nat as b

on a.moc_id=b.moc_id;

 
quit;

data bu; set cmv.Plate_003_bu; 
*id2 = left(trim(id));
*center = input(substr(id2, 1, 1),1.);
center=8; 
visitlist=dfseq; treat=center;
run;


proc sql;

create table donor as
select Distinct(DonorUnitId)  as DonorUnitId ,id , "RBC" as source from cmv.plate_031
union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Plt" as source from cmv.plate_033
union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "FFP" as source from cmv.plate_035
union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Cry" as source from cmv.plate_037
/*union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Gran" as source from cmv.plate_039
*/
order by id,source,DonorUnitId
;
create table donor_2 as
select b.DonorUnitId, source, a.id
from seroneg as a left join
donor as b
on a.id =b.id
order by a.id,source,b.DonorUnitId;

create table donor_3 as
select a.DonorUnitId, a.UnitResult,b.DonorUnitId as UnitId
from bu as a right join
donor_2 as b
on a.DonorUnitId =b.DonorUnitId
where unitid is not null
;
quit;

data donor_3; set donor_3;
if UnitResult = . then UnitResult=9;
run;

proc sql;

create table donor_4 as
select a.*,b.UnitResult
from donor_2 as a left join
donor_3 as b
on a.DonorUnitId=b.UnitId;

create table donor_4_count as
select id, count(*) as donorcount, unitresult
from donor_4
where unitresult is not null
group by id, unitresult ;

quit;

data donor_4_count; set donor_4_count;

if unitresult =9 then 
donor_result_stat=  "M( " || compress(donorcount) || ")";
else if unitresult =1 then 
donor_result_stat=  "N( " || compress(donorcount) || ")";
else if unitresult =2 then 
donor_result_stat=  "LP( " || compress(donorcount) || ")";
else if unitresult =3 then 
donor_result_stat=  "P( " || compress(donorcount) || ")";
else if unitresult =4 then 
donor_result_stat=  "I( " || compress(donorcount) || ")";
run;

proc sql;

create table seroneg_2 as 
select a.*,b.donor_result_stat as donor_result_Miss 
from seroneg as a left join
( select * from donor_4_count where unitresult=9 ) as b
on a.id=b.id
;

create table seroneg_2 as 
select a.*,b.donor_result_stat as donor_result_ND 
from seroneg_2 as a left join
( select * from donor_4_count where unitresult=1 ) as b
on a.id=b.id
;

create table seroneg_2 as 
select a.*,b.donor_result_stat as donor_result_LP 
from seroneg_2 as a left join
( select * from donor_4_count where unitresult=2 ) as b
on a.id=b.id
;

create table seroneg_2 as 
select a.*,b.donor_result_stat as donor_result_P 
from seroneg_2 as a left join
( select * from donor_4_count where unitresult=3 ) as b
on a.id=b.id
;

create table seroneg_2 as 
select a.*,b.donor_result_stat as donor_result_I 
from seroneg_2 as a left join
( select * from donor_4_count where unitresult=4 ) as b
on a.id=b.id
;

quit;

data seroneg_2; set seroneg_2;
 
donor_result_stat_2 = compress(donor_result_Miss) || " " || compress(donor_result_ND)|| " " || compress(donor_result_LP)
|| " " || compress(donor_result_P) || " " || compress(donor_result_I);
run;

/* fix wbc result */

data bu; set cmv.Plate_002_bu; 
*id2 = left(trim(id));
*center = input(substr(id2, 1, 1),1.);
center=8; 
visitlist=dfseq; treat=center;
run;

proc sql;

create table bu_2 as
select a.id, a.Donorunitid, b.wbc_result1,b.wbc_count1,b.wbc_result2,b.wbc_count2
from (select  id, Donorunitid from Donor_4 where Donorunitid  ) as a left join
bu as b
on a.DonorUnitid =b.donorunitid;



quit;

data bu_2; set bu_2;
length donor_wbc_stat $ 50;
if wbc_result2 = 1 then  donor_wbc_stat =  "ND";
else if wbc_result2 = 2 and wbc_count2 <> . then  do; donor_wbc_stat =  "D" ; wbc_count=wbc_count2;end;
else if wbc_result2 = 99 and  wbc_result1 = 1  then  donor_wbc_stat =  "ND" ; 
else if wbc_result2 =99 and  wbc_result1 = 2 and wbc_count1 <> . then  do; donor_wbc_stat =  "D"; wbc_count=wbc_count1;end;
else if wbc_result2 = . and wbc_result1 = . then donor_wbc_stat =  "M";
run;

proc sql;

create table bu_3 as
select id, donor_wbc_stat,count(*) as donor_wbc_count2
from bu_2
group by id ,donor_wbc_stat;



create table seroneg_3 as 
select a.*,b.donor_wbc_stat as donor_wbc_stat_D ,b.donor_wbc_count2 as donor_wbc_count2_D
from seroneg_2 as a left join
( select * from bu_3 where donor_wbc_stat="D" ) as b
on a.id=b.id
;


create table seroneg_3 as 
select a.*,b.donor_wbc_stat as donor_wbc_stat_M ,b.donor_wbc_count2 as donor_wbc_count2_M
from seroneg_3 as a left join
( select * from bu_3 where donor_wbc_stat="M" ) as b
on a.id=b.id
;


create table seroneg_3 as 
select a.*,b.donor_wbc_stat as donor_wbc_stat_ND ,b.donor_wbc_count2 as donor_wbc_count2_ND
from seroneg_3 as a left join
( select * from bu_3 where donor_wbc_stat="ND" ) as b
on a.id=b.id
;


quit;

data seroneg_3; set seroneg_3;
length donor_wbc_stat_2 $ 50;

donor_wbc_stat_2 = compress(donor_wbc_stat_D) || " " || compress(donor_wbc_count2_D)|| " " 
||  compress(donor_wbc_stat_M) || " " || compress(donor_wbc_count2_M) || " "
|| compress(donor_wbc_stat_ND) || " " || compress(donor_wbc_count2_ND) || " ";




run;


proc sql;

select compress(put(count(id),2.0))  into :cmv_id from seroneg_3 ;
select compress(put(count(id),4.0)) into :enrolled_id from enrolled ;
quit;


data seroneg; 
length all_donor_result $ 50;
length donor_wbc_result $ 50;
length hosp_day $ 50;

eos_days=0;

set seroneg_3;
if rbc_tx = . then rbc_tx=0; if donor_rbc= . then donor_rbc=0;
if plt_tx = . then plt_tx=0; if donor_plt= . then donor_plt=0;
if ffp_tx = . then ffp_tx=0; if donor_ffp= . then donor_ffp=0;
if cryo_tx = . then cryo_tx=0; if donor_cryo= . then donor_cryo=0;

all_tx = rbc_tx+ plt_tx + ffp_tx + cryo_tx;
all_donor = donor_rbc + donor_plt + donor_ffp + donor_cryo;

NATTestResult_dob_tx = "-";
NATTestResult_dol21_tx = "-";
NATTestResult_dol40_tx = "-";
NATTestResult_dol60_tx = "-";
NATTestResult_dol90_tx = "-";

if NATTestResult_dob eq 1 then NATTestResult_dob_tx="N";
if NATTestResult_dob eq 2 then NATTestResult_dob_tx="LP";
if NATTestResult_dob eq 3 then NATTestResult_dob_tx="P";
if NATTestResult_dob eq 4 then NATTestResult_dob_tx="I";

if NATTestResult_dol21 eq 1 then NATTestResult_dol21_tx="N";
if NATTestResult_dol21 eq 2 then NATTestResult_dol21_tx="LP";
if NATTestResult_dol21 eq 3 then NATTestResult_dol21_tx="P";
if NATTestResult_dol21 eq 4 then NATTestResult_dol21_tx="I";

if NATTestResult_dol40 eq 1 then NATTestResult_dol40_tx="N";
if NATTestResult_dol40 eq 2 then NATTestResult_dol40_tx="LP";
if NATTestResult_dol40 eq 3 then NATTestResult_dol40_tx="P";
if NATTestResult_dol40 eq 4 then NATTestResult_dol40_tx="I";

if NATTestResult_dol60 eq 1 then NATTestResult_dol60_tx="N";
if NATTestResult_dol60 eq 2 then NATTestResult_dol60_tx="LP";
if NATTestResult_dol60 eq 3 then NATTestResult_dol60_tx="P";
if NATTestResult_dol60 eq 4 then NATTestResult_dol60_tx="I";

if NATTestResult_dol90 eq 1 then NATTestResult_dol90_tx="N";
if NATTestResult_dol90 eq 2 then NATTestResult_dol90_tx="LP";
if NATTestResult_dol90 eq 3 then NATTestResult_dol90_tx="P";
if NATTestResult_dol90 eq 4 then NATTestResult_dol90_tx="I";

if StudyLeftDate <> . then eos_days=  StudyLeftDate -DateOfBirth ;

else if StudyLeftDate = . then eos_days= date()-DateOfBirth ;


if studyLeftDate <> . then hosp_day= compress(put(eos_days,4.0)) || "*";
*if studyLeftDate = . then hosp_day= compress(put(eos_days,4.0)) ;

else if studyLeftDate = . then hosp_day= "On Study" ;

nat = compress(NATTestResult_dob_tx) || " | " || compress(NATTestResult_dol21_tx) || " | " || compress(NATTestResult_dol40_tx)  || " | " || compress(NATTestResult_dol60_tx) || " | " || compress(NATTestResult_dol90_tx);

all_donor_NAT = "N/A";donor_wbc_result ="N/A";
if all_donor = 0 then do; all_donor_NAT="-"; donor_wbc_result="-";end;


D7NatResult_tx = "--";
if D7NatResult eq 1 then D7NatResult_tx="N";
if D7NatResult eq 2 then D7NatResult_tx="LP";
if D7NatResult eq 3 then D7NatResult_tx="P";
if D7NatResult eq 4 then D7NatResult_tx="I";

D21NatResult_tx = "--";
if D21NatResult eq 1 then D21NatResult_tx="N";
if D21NatResult eq 2 then D21NatResult_tx="LP";
if D21NatResult eq 3 then D21NatResult_tx="P";
if D21NatResult eq 4 then D21NatResult_tx="I";

D28NatResult_tx = "--";
if D28NatResult eq 1 then D28NatResult_tx="N";
if D28NatResult eq 2 then D28NatResult_tx="LP";
if D28NatResult eq 3 then D28NatResult_tx="P";
if D28NatResult eq 4 then D28NatResult_tx="I";


D40NatResult_tx = "--";
if D40NatResult eq 1 then D40NatResult_tx="N";
if D40NatResult eq 2 then D40NatResult_tx="LP";
if D40NatResult eq 3 then D40NatResult_tx="P";
if D40NatResult eq 4 then D40NatResult_tx="I";


if D7NatCopy <> . or D21NatCopy <>. or D28NatCopy <> . or D40NatCopy <> . then do;
bm_result = compress(D7NatResult_tx) || " ( " || compress(put(D7NatCopy,4.0)) || " )_ " 
|| compress(D21NatResult_tx) || " (" || compress(put(D21NatCopy,4.0)) || " )_ "  
|| compress(D28NatResult_tx) || " (" || compress(put(D28NatCopy,4.0)) || ")_" 
|| compress(D40NatResult_tx) || " (" || compress(put(D40NatCopy,4.0)) || ")";
end;

if BreastFeed = 1 and   bm_result=" " then bm_result="Data Missing";


run;


proc sql;

create table seroneg_style2 as
select a.moc_id  ,a.IgMTestResult ,a.id ,a.hosp_day ,a.DateOfBirth, a.StudyLeftDate, a.hosp_day , all_tx , all_donor,Feedstatus, b.NATTestResult ,b.NATCopyNumber ,b.dfseq
from seroneg as a left join
cmv.Lbwi_Blood_NAT_Result     as b
on a.id =b.id
order by moc_id,id, dfseq
;

create table seroneg_style2 as
select a.* ,b.UrineTestResult ,b.UrineCopyNumber ,b.dfseq as dfseq2
from seroneg_style2 as a left join
cmv.Lbwi_Urine_NAT_Result     as b
on a.id =b.id and a.dfseq=b.dfseq
order by moc_id,id, a.dfseq
;

create table seroneg_style2 as
select a.*,b.DateBloodCollected
from seroneg_style2 as a left join
cmv.Lbwi_Blood_NAT_Result as b
on a.id =b.id and a.dfseq=b.dfseq;


create table seroneg_style2 as
select a.*,b.reason
from seroneg_style2 as a left join
( select id, reason from cmv.endofstudy where reason = 6)  as b
on a.id =b.id ;


quit;


proc sql;


quit;

data seroneg_style2; set seroneg_style2;
if NATTestResult eq 3 then  nat_result ="Positive" || "(" || compress(NATCopyNumber);
else if NATTestResult eq 1 then  nat_result ="Not detected" ;
else if NATTestResult eq 2 then  nat_result ="Low positive" ;
else if NATTestResult eq 4 then  nat_result ="Indeterminate" ;
else if NATTestResult eq 99 then  nat_result ="Pending" ;

if UrineTestResult eq 3 then  Urine_result ="Positive" || "(" || compress(UrineCopyNumber);
else if UrineTestResult eq 1 then  Urine_result ="Not detected" ;
else if UrineTestResult eq 2 then  Urine_result ="Low positive" ;
else if UrineTestResult eq 4 then  Urine_result ="Indeterminate" ;
else if  UrineTestResult eq 99 then  Urine_result ="Pending" ;

time_to_blood=DateBloodCollected - DateOfBirth;

if all_donor = 0 then all_donor =.;
run;




proc sql;

create table donor_report as
select a.id, b.*
from seroneg_style2 as a left join
donor as b
on a.id=b.id;

create table donor_report as
select distinct a.*, b.*
from donor_report as a left join
cmv.Plate_003_bu as b
on a.DonorUnitId=b.DonorUnitId;


create table donor_report as
select distinct a.moc_id  ,a.IgMTestResult ,a.hosp_day ,a.DateOfBirth, a.StudyLeftDate, a.hosp_day , a.all_tx , a.all_donor ,b.*
from donor_report as b left join
seroneg_style2 as a
on a.id=b.id;


create table donor_report_2 as
select distinct b.*, wbc_result1,wbc_result2,wbc_count1,wbc_count2,a.donorunitid as unitid2
from donor_report as b left join
cmv.Plate_002_bu as a
on a.donorunitid=b.donorunitid
order by Moc_id, Id;




quit;


data donor_report_2; set donor_report_2;
length donor_unit_result $ 50;
length donor_wbc_result $ 50;

if  all_tx eq 0 then do; donor_unit_result ="_";donorunitid="_";end;
else if all_tx > 0 and donorunitid eq . and  UnitResult eq . then donor_unit_result ="Pending";
else if UnitResult eq 1 then  donor_unit_result ="Not detected" ;
else if UnitResult eq 2 then  donor_unit_result ="Low positive" ;
else if UnitResult eq 3 then  donor_unit_result ="Positive" || "(" || compress(NATCopyNumber)|| ")";
else if UnitResult eq 4 then  donor_unit_result ="Indeterminate" ;


if  all_tx eq 0 then do; donor_wbc_result ="_";donorunitid="_";end;
else if all_tx > 0 and donorunitid eq . and wbc_result1 = .  then donor_wbc_result ="Pending";
else if  wbc_result1 = 1 then donor_wbc_result ="<0.2 ";
else if   wbc_result1 = 2 then donor_wbc_result = compress(wbc_count1);
run;

proc sql;

create table tx_hx as
select DonorUnitId  as DonorUnitId ,id , "RBC" as source , DateTransfusion from cmv.plate_031
union
select DonorUnitId  as DonorUnitId ,id , "Plt" as source , DateTransfusion from cmv.plate_033
union
select DonorUnitId  as DonorUnitId ,id , "FFP" as source , DateTransfusion from cmv.plate_035
union
select DonorUnitId  as DonorUnitId ,id , "Cry" as source , DateTransfusion from cmv.plate_037
/*union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Gran" as source , DateTransfusion from cmv.plate_039
*/
order by id,source,DonorUnitId,DateTransfusion
;

create table tx_hx_2 as
select a.*, b.DateTransfusion format=date7.
from donor_report_2 as a left join
tx_hx as b
on a.id=b.id and a.DonorUnitId=b.DonorUnitId and a.source=b.source;

create table tx_hx_3 as
select a.*, b.DateDonated format=date7.
from tx_hx_2 as a left join
cmv.plate_001_bu as b
on  a.DonorUnitId=b.DonorUnitId;

create table tx_hx_4 as

select a.* ,c.NAT
from tx_hx_3 as a left join
(
select id2 as id2 ,  max(NAT) as NAT from (
select id as id2 , max(NATTestResult) as NAT from cmv.Lbwi_Blood_NAT_Result where  NATTestResult In (1,2,3)  group by id
union
select id as id2 , max(urineTestResult) as NAT from cmv.Lbwi_urine_NAT_Result where  urineTestResult In (1,2,3) group by id
) as b  group by id2) as c 
on a.id = c.id2 
order by id, DateTransfusion desc;


create table tx_hx_4 as
select a.*,b.reason
from tx_hx_4 as a left join
( select id, reason from cmv.endofstudy where reason = 6)  as b
on a.id =b.id 
order by id, DateTransfusion asc;

quit;


data tx_hx_4; set tx_hx_4; 
age_blood =  DateTransfusion - DateDonated ; 
days_to_tx=DateTransfusion - DateOfBirth;

run;

proc sql;

create table breastFeed_report as
select a.moc_id  ,a.IgMTestResult ,a.id ,a.hosp_day ,a.DateOfBirth, a.StudyLeftDate, a.hosp_day ,a.FeedStatus, b.* 
from seroneg as a left join
bm_nat     as b
on a.moc_id =b.moc_id
order by moc_id,id, dfseq
;


create table breastFeed_report as
select a.*,b.reason
from breastFeed_report as a left join
( select id, reason from cmv.endofstudy where reason = 6)  as b
on a.id =b.id ;


create table IgG_report as
select a.moc_id  ,a.IgMTestResult ,a.id ,a.hosp_day ,a.DateOfBirth, a.StudyLeftDate, a.hosp_day ,a.FeedStatus, b.* 
from seroneg as a right join
cmv.plate_209     as b
on a.id =b.id
order by moc_id,id, dfseq
;




quit;

data IgG_report; set IgG_report;

days_to_igG= DateBloodCollected - DateOfBirth;
run;

data breastFeed_report; 



length NATResult_wk1_txt $ 50;
length NATResult_wk3_txt $ 50;
length NATResult_wk4_txt $ 50;
length NATResult_d34_txt $ 50;

set breastFeed_report;



days_to_milk_wk1=milk_date_wk1 - DateOfBirth;
days_to_milk_wk3=milk_date_wk3 - DateOfBirth;
days_to_milk_wk4=milk_date_wk4 - DateOfBirth;
days_to_milk_d34=milk_date_d34 - DateOfBirth;


if FeedStatus = 1 and NATResult_wk1 =.  then  NATResult_wk1_txt="Not Tested";
else if NATResult_wk1 = 1 then NATResult_wk1_txt="Not detected" ;
else if NATResult_wk1 = 2 then NATResult_wk1_txt="Low Positive" || "(<300 copies/ml)" ;
else if NATResult_wk1 = 3 then NATResult_wk1_txt="Positive" || "(" || compress(NATCopy_wk1) || ")";
else if NATResult_wk1 = 4 then NATResult_wk1_txt="Indeterminate" ;

if FeedStatus = 1 and NATResult_wk3 =.  then  NATResult_wk3_txt="Not Tested";
else if NATResult_wk3 = 1 then NATResult_wk3_txt="Not detected" ;
else if NATResult_wk3 = 2 then NATResult_wk3_txt="Low Positive" || "(<300 copies/ml)" ;
else if NATResult_wk3 = 3 then NATResult_wk3_txt="Positive" || "(" || compress(NATCopy_wk3) || ")";
else if NATResult_wk3 = 4 then NATResult_wk3_txt="Indeterminate" ;

if FeedStatus = 1 and NATResult_wk4 =.  then  NATResult_wk4_txt="Not Tested";
else if NATResult_wk4 = 1 then NATResult_wk4_txt="Not detected" ;
else if NATResult_wk4 = 2 then NATResult_wk4_txt="Low Positive" || "(<300 copies/ml)" ;
else if NATResult_wk4 = 3 then NATResult_wk4_txt="Positive" || "(" || compress(NATCopy_wk4) || ")";
else if NATResult_wk4 = 4 then NATResult_wk4_txt="Indeterminate" ;

if FeedStatus = 1 and NATResult_d34 then  NATResult_d34_txt="Not Tested";
else if NATResult_d34 = 1 then NATResult_d34_txt="Not detected" ;
else if NATResult_d34 = 2 then NATResult_d34_txt="Low Positive" || "(<300 copies/ml)" ;
else if NATResult_d34 = 3 then NATResult_d34_txt="Positive" || "(" || compress(NATCopy_d34) || ")";
else if NATResult_d34 = 4 then NATResult_d34_txt="Indeterminate" ;
run;




options nodate orientation=landscape;

ods rtf file = "&output./annual/&cmv_survey_summary_file.cmv_survey.rtf"  style = journal toc_data startpage = yes bodytitle;

/*
ods noproctitle proclabel "&cmv_survey_summary_title : CMV - surveillance summary";


title  justify = center "&cmv_survey_summary_title : CMV - surveillance summary for LBWI ( NAT positive or MOC IgM-Positive ) &cmv_id/&enrolled_id";
footnote1 " NAT Result ( N: Not detected P: Positive L: Low positive I: Indeterminate ) ";
footnote2 "Residual WBC Result ( D: Detected >=0.2wbc ND : Not detected M: Missing)";
footnote3 " * LBWI Left Study";
proc report data=seroneg nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    moc_id   IgMTestResult id  DateOfBirth hosp_day UrineTestResult nat  FeedStatus bm_result all_tx  all_donor   
donor_result_stat_2  donor_wbc_stat_2 dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left    " MOC_IgM " format=igM.;
define id/   order=data   Left    " LBWI_Id " ;
define DateOfBirth/   order=data   Left    " DOB " ;

define hosp_day/   order=data   Left    " Hosp_days " ;

define UrineTestResult/   order=data   Left    " Urine_NAT On_DOB " format=nat.;

define nat /   left   style(column) = [just=center cellwidth=1in] "Blood NAT_On_D0|21|40|60|90"  ;
define Feedstatus /   left   style(column) = [just=center cellwidth=0.5in] "Breast_Fed?"  format=bfed.;
define bm_result /   left   style(column) = [just=center cellwidth=2in] "Breast Milk_NAT Result(Copy Num)_On_D7|21|28|40"  ;

define all_tx /   left   style(column) = [just=center cellwidth=0.5in] "# Tx "  ;
define all_donor /   left   style(column) = [just=center cellwidth=0.8in] "# Donor"  ;
define donor_result_stat_2 /   left   style(column) = [just=center cellwidth=1in] "Donor Unit_NAT_"  ;
define donor_wbc_stat_2 /   left   style(column) = [just=center cellwidth=1in] "Residual_WBC_"  ;

define dummy/NOPRINT ;


rbreak after / skip ;






run;
*/
*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
*ods rtf close;
*quit;





ods noproctitle proclabel "&cmv_survey_summary_title a: CMV surveillance summary for MOC (IgM Positive) or for LBWI(NAT positive) ";

title  justify = center "&cmv_survey_summary_title a: CMV surveillance summary for MOC (IgM Positive) or for LBWI(NAT positive) " /*(&cmv_id/&enrolled_id) */;
footnote1 "* LBWI discharged   ";
footnote2 "MOC id 30043 was tested for CMV reactivation. On day of enrollment and day 16 after enrollment, MOC blood was IgG Positive." ;
proc report data=seroneg_style2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    moc_id   IgMTestResult id   DateOfBirth StudyLeftDate hosp_day reason all_tx  all_donor  Feedstatus time_to_blood /*dfseq*/ nat_result  urine_result/*NATTestResult NATCopyNumber*/ dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left    " MOC_IgG/IgM " format=igM.;
define id/   group order=data   Left    " LBWI_Id " ;
define DateOfBirth/ group  order=data   Left    " DOB " ;
define StudyLeftDate/ group   order=data   Left    " EOS " ;
define hosp_day/  group order=data   center    " Hosp_days " ;

define reason/  group order=data   center    " Death " format=death.;

define all_tx / group  left   style(column) = [just=center cellwidth=0.5in] "# Tx "  ;
define all_donor / group  left   style(column) = [just=center cellwidth=0.5in] "# Donor"  ;
define FeedStatus / group  left   style(column) = [just=center cellwidth=1in] "Breast Fed?"  format=bfed.;
define time_to_blood/  group order=data   Left    " DOL " format=dfseq.;

define nat_result /   left   style(column) = [just=center cellwidth=1in] "Blood NAT_(copy num_/mL)" ;
define urine_result /   left   style(column) = [just=center cellwidth=1in] "Urine NAT_(copy num_/mL)" ;
define dummy/NOPRINT ;


rbreak after / skip ;
compute after moc_id;
line '';
endcomp;

run;

ods noproctitle proclabel "&cmv_survey_summary_title b: CMV surveillance summary for LBWI (Breast Milk NAT result)";

title  justify = center "&cmv_survey_summary_title b: CMV surveillance summary for LBWI (Breast Milk NAT result)" ; /*(&cmv_id/&enrolled_id)*/;
footnote1 " * LBWI discharged ";
footnote2 "MOC id 30043 was tested for CMV reactivation. On day of enrollment and day 16 after enrollment, MOC blood was IgG Positive." ;
proc report data=breastfeed_report nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    moc_id   IgMTestResult id   DateOfBirth StudyLeftDate hosp_day  reason Feedstatus 
 days_to_milk_wk1 NATResult_wk1_txt 
 days_to_milk_wk3 NATResult_wk3_txt   
days_to_milk_wk4 NATResult_wk4_txt 
days_to_milk_d34 NATResult_d34_txt dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left    " MOC_IgG/IgM " format=igM.;
define id/   order=data   Left    " LBWI_Id " ;
define DateOfBirth/   order=data   Left    " DOB " ;
define StudyLeftDate/   order=data   Left    " EOS " ;
define hosp_day/   order=data   center    " Hosp_days " ;
define reason/  group order=data   center    " Death " format=death.;

define days_to_milk_wk1/left   style(column) = [just=center cellwidth=0.5in] "BM 1_Day"  ;
define NATResult_wk1_txt/left   style(column) = [just=center cellwidth=1in] "BM 1_NAT Result_(copy num /mL)  "  ;

define days_to_milk_wk3/left   style(column) = [just=center cellwidth=0.5in] "BM 2_Day"  ;
define NATResult_wk3_txt /   left   style(column) = [just=center cellwidth=1in] "BM 2_NAT Result_(copy num /mL)  "  ;

define days_to_milk_wk4/left   style(column) = [just=center cellwidth=0.5in] "BM 3_Day"  ;
define NATResult_wk4_txt /   left   style(column) = [just=center cellwidth=1in] "BM 3_NAT Result_(copy num /mL)  "  ;

define days_to_milk_d34/left   style(column) = [just=center cellwidth=0.5in] "BM 4_Day"  ;
define NATResult_d34_txt/left   style(column) = [just=center cellwidth=1in] "BM 4_NAT Result_(copy num /mL)  "  ;
define all_donor /   left   style(column) = [just=center cellwidth=0.5in] "# Donor"  ;
define Feedstatus /   left   style(column) = [just=center cellwidth=0.5in] "Breast_Fed?"  format=bfed.;
*define donor_wbc_stat_2 /   left   style(column) = [just=center cellwidth=1in] "Residual_WBC_"  ;

define dummy/NOPRINT ;


rbreak after / skip ;

compute after moc_id;
line '';
endcomp;

run;

/* added fotnote 
ods noproctitle proclabel "&cmv_survey_summary_title c: CMV - surveillance summary for LBWI - MOC IgG Result ( Test for reactivation )";

title  justify = center "&cmv_survey_summary_title c: CMV - surveillance summary for LBWI - MOC IgG Result ( Test for reactivation )";
footnote1 "  ";

proc report data=igg_report nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    moc_id   IgMTestResult   days_to_igG IgGTestResult  
  dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left  style(column) = [just=center cellwidth=1in]  " MOC_IgG/IgM " format=igM.;
*define id/   order=data   Left    " LBWI_Id " ;
define DateOfBirth/   order=data   Left style(column) = [just=center cellwidth=1in]   " LBWI _DOB " ;
define StudyLeftDate/   order=data   Left  style(column) = [just=center cellwidth=1in]    " EOS " ;
define hosp_day/   order=data   Left  style(column) = [just=center cellwidth=1in]   " Hosp_days " ;
define days_to_igG/   order=data   Left   style(column) = [just=center cellwidth=1in]  " MOC _IgG Sample Day " ;
define IgGTestResult /   order=data   Left  style(column) = [just=center cellwidth=1in]   "MOC IgG Result " format=igg.;



define dummy/NOPRINT ;


rbreak after / skip ;

compute after moc_id;
line '';
endcomp;

run;

*/
/*  do not show this
ods noproctitle proclabel "&cmv_survey_summary_title d: CMV surveillance summary for LBWI (Donor Unit NAT and wbc result)";

title  justify = center "&cmv_survey_summary_title d: CMV surveillance summary for LBWI (Donor Unit NAT and wbc result) (&cmv_id/&enrolled_id)";
footnote1 " * LBWI Left Study ";

proc report data=donor_report_2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    moc_id   IgMTestResult id   DateOfBirth StudyLeftDate hosp_day all_tx  all_donor DonorUnitID donor_unit_result donor_wbc_result  dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left    " MOC_IgM " format=igM.;
define id/   group order=data   Left    " LBWI_Id " ;
define DateOfBirth/ group  order=data   Left    " DOB " ;
define StudyLeftDate/ group   order=data   Left    " EOS " ;
define hosp_day/  group order=data   Left    " Hosp_days " ;

define reason/  group order=data   center    " Death " format=death.;

define all_tx /  group left   style(column) = [just=center cellwidth=0.5in] "# Tx "  ;
define all_donor / group  left   style(column) = [just=center cellwidth=0.5in] "# Donor"  ;
define DonorUnitID/  group order=data   Left    " Donor Unit ID" ;

define donor_unit_result /   left   style(column) = [just=center cellwidth=2in] "Donor NAT Result (copy num /mL)" ;
define donor_wbc_result /   left   style(column) = [just=center cellwidth=2in] "Donor residual WBC (#wbc/microL) "  ;


define dummy/NOPRINT ;


rbreak after / skip ;

compute after moc_id;
line '';
endcomp;

run;

*/
ods noproctitle proclabel "&cmv_survey_summary_title c: CMV surveillance summary for LBWI (Donor results and Tx History) ";

title  justify = center "&cmv_survey_summary_title c: CMV surveillance summary for LBWI (Donor results and Tx History) ";
footnote1 " * LBWI discharged";
footnote2 "MOC id 30043 was tested for CMV reactivation. On day of enrollment and day 16 after enrollment, MOC blood was IgG Positive." ;
proc report data=tx_hx_4 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
*where NAT in (2,3);

column    moc_id   IgMTestResult id   DateOfBirth StudyLeftDate hosp_day  reason NAT all_tx  all_donor DonorUnitID donor_unit_result donor_wbc_result 
Source /* DateTransfusion */days_to_tx Age_blood  dummy;

define moc_id/ group  order=data   Left    " MOC id " ;

define IgMTestResult/   group order=data   Left    " MOC_IgG/IgM " format=igM.;
define id/   group order=data   Left    " LBWI_Id " ;
define DateOfBirth/ group  order=data   Left    " DOB " ;
define StudyLeftDate/ group   order=data   Left    " EOS " ;
define hosp_day/  group order=data   center    " Hosp_days " ;
define reason/  group order=data   center    " Death " format=death.;

define NAT/  group order=data   Left    " LBWI_NAT " format=nat_longX.;
define all_tx /  group left   style(column) = [just=center cellwidth=0.5in] "# Tx "  ;
define all_donor / group  left   style(column) = [just=center cellwidth=0.5in] "# Donor"  ;
define DonorUnitID/  group order=data   Left    " Donor Unit ID" ;
define donor_unit_result / group  left   style(column) = [just=center cellwidth=0.8in] "Donor NAT Result (copy num /mL)" ;
define donor_wbc_result / group  left   style(column) = [just=center cellwidth=0.8in] "Donor residual WBC (#wbc/microL) "  ;

define Source/   left   style(column) = [just=center cellwidth=0.5in] "Tx Type "  ;
*define DateTransfusion /   left   style(column) = [just=center cellwidth=1in] "Tx Date" ;
define days_to_tx /   left   style(column) = [just=center cellwidth=1in] "DOL_at_Tx_(days)" ;
define Age_blood/   left   style(column) = [just=center cellwidth=0.5in] "Age of _Blood_(days) "  ;


define dummy/NOPRINT ;


rbreak after / skip ;

compute after moc_id;
line '';
endcomp;

run;


ods rtf close;
quit;

