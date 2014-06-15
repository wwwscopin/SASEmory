/**** global tx and donor units****/

%include "&include./monthly_toc.sas";
%include "&include./annual_toc.sas";

proc sql;


create table endofstudy as
select a.id, b.studyleftdate,b.reason
from cmv.valid_ids as a right join
cmv.endofstudy as b
on a.id=b.id;

create table tx as
select id, donorunitid, dfseq, "pRBC" as tx_type
from cmv.plate_031 

union
select id, donorunitid, dfseq, "Plt" as tx_type
from cmv.plate_033

union
select id, donorunitid, dfseq, "FFP" as tx_type
from cmv.plate_035

union
select id, donorunitid, dfseq, "Cryo" as tx_type
from cmv.plate_037;

create table tx_eos as
select a.*
from tx as a inner join endofstudy as b
on a.id=b.id;




create table tx_eos_tracking as
select a.*,b.*
from (select distinct donorunitid , tx_type from tx_eos ) as a left join
cmv.plate_001_bu as b
on a.donorunitid=b.donorunitid;


create table tx_eos_donor_count as
select count(distinct(donorunitid)), tx_type
from tx_eos_tracking 
group by tx_type

union
select count(distinct(donorunitid)),"ALL tx" as tx_type
from tx_eos_tracking 
;

create table tx_eos_wbc as
select a.*,b.*
from (select distinct donorunitid , tx_type from tx_eos ) as a left join
cmv.plate_002_bu as b
on a.donorunitid=b.donorunitid;

create table tx_eos_nat as
select a.*,b.*
from (select distinct donorunitid , tx_type from tx_eos ) as a left join
cmv.plate_003_bu as b
on a.donorunitid=b.donorunitid;


quit;

data tx_eos_wbc; set tx_eos_wbc;
wbc_count1_cat=1;
if wbc_result1 eq 1 and wbc_count1 ~=. and wbc_count1 <= 5 then wbc_count1_cat=0;run;

proc format;
value sero
1="Negative"
2="Unknown"
99="Pending"
999="Not applicable( Blood product is FFP,Cryo,Gran) "
;
value wbc
1="Not detected( <0.2wbc/ul)"
2="Detected( >= 0.2wbc/ul)"
99="Pending"
999="Not applicable( Blood product is FFP,Cryo,Gran) "
;

value wbc_c
0="(wbc <= 5*10^6/L)"
1="(wbc > 5*10^6/L)"
99="Pending"
999="Not applicable( Blood product is FFP,Cryo,Gran) "
;

value nat
1="Not detected"
2="Low positive"
3="Positive"
4="Indeterminate"
.="Pending"
;


run;

/*** this only to see if there are any duplicates *******/
proc sql;

create table tx_eos_nat_duplicate as
select donorunitid,count(*) 
from tx_eos_nat
group by donorunitid
having count(*) >1;

create table tx_eos_wbc_duplicate as
select donorunitid,count(*) 
from tx_eos_wbc
group by donorunitid
having count(*) >1;

create table tx_eos_tracking_duplicate as
select donorunitid,count(*) 
from tx_eos_tracking
group by donorunitid
having count(*) >1;

quit;

proc sort data=tx_eos_tracking; by donorunitid; run;
data tx_eos_tracking;set tx_eos_tracking; by   donorunitid; if first.donorunitid; run;

proc sort data=tx_eos_wbc; by donorunitid; run;
data tx_eos_wbc;set tx_eos_wbc; by   donorunitid; if first.donorunitid; run;

proc sort data=tx_eos_nat; by donorunitid; run;
data tx_eos_nat;set tx_eos_nat; by donorunitid; if first.donorunitid; run;

proc sql;
create table t1 as
select unitserostatus format=sero., count(*) as freq,"Parent Unit CMV SeroStatus" as variable
from tx_eos_tracking
where tx_type in ("pRBC", "Plt") and unitserostatus in (1,2)
group by unitserostatus 
union
select 999 as unitserostatus format=sero., count(*) as freq,"Parent Unit CMV SeroStatus" as variable
from tx_eos_tracking  where tx_type not in ("pRBC", "Plt")
union
select 99 as unitserostatus format=sero., (cmv_donor_count-cmv_donor_count_valid  )   as freq,"Parent Unit CMV SeroStatus" as variable
from 
( select count(distinct(donorunitid)) as cmv_donor_count from tx_eos_tracking  where tx_type  in ("pRBC", "Plt") ),
( select count(distinct(donorunitid)) as cmv_donor_count_valid from tx_eos_tracking  where tx_type  in ("pRBC", "Plt") and unitserostatus in (1,2))
;


create table t1_1 as
select a.*,b.total_donor
from t1 as a ,
( select sum(freq) as total_donor from t1 where unitserostatus <> 999) as b
;


create table t2 as
select wbc_result1 format=wbc., count(*) as freq,"Parent Unit WBC Result\n( Only for RBC,PLT)" as variable
from tx_eos_wbc
where tx_type in ("pRBC", "Plt") and wbc_result1 in (1,2)
group by wbc_result1 
union
select 999 as wbc_result1 format=wbc., count(*) as freq,"Parent Unit WBC Result\n( Only for RBC,PLT)" as variable
from tx_eos_wbc  where tx_type not in ("pRBC", "Plt")
union
select 99 as wbc_result1 format=wbc., (cmv_donor_count-cmv_donor_count_valid  )    as freq,"Parent Unit WBC Result\n( Only for RBC,PLT)" as variable
from ( select count(distinct(donorunitid)) as cmv_donor_count from tx_eos_wbc  where tx_type  in ("pRBC", "Plt") ),
( select count(distinct(donorunitid)) as cmv_donor_count_valid from tx_eos_wbc  where tx_type  in ("pRBC", "Plt") and wbc_result1 in (1,2))

;


create table t2_1 as
select a.*,b.total_donor
from t2 as a ,
( select sum(freq) as total_donor from t2 where wbc_result1 <> 999) as b
;



create table t3 as
select wbc_count1_cat format=wbc_c., count(*) as freq,"Parent Unit WBC Result Filter Failure" as variable
from tx_eos_wbc
where tx_type in ("pRBC", "Plt") and wbc_count1_cat in (1,0)
group by wbc_count1_cat 
union
select 999 as wbc_count1_cat format=wbc_c., count(*) as freq,"Parent Unit WBC Result Filter Failure" as variable
from tx_eos_wbc  where tx_type not in ("pRBC", "Plt")

;


create table t3_1 as
select a.*,b.total_donor
from t3 as a ,
( select sum(freq) as total_donor from t3 where wbc_count1_cat  <> 999) as b
;

create table t4 as
select unitresult format=nat., count(*) as freq,"Parent Unit NAT Result" as variable
from tx_eos_nat
group by unitresult 
;


create table t4_1 as
select a.*,b.total_donor
from t4 as a ,
( select sum(freq) as total_donor from t4 ) as b
;



quit;


proc sql;

create table t_all as
select variable, total_donor,unitserostatus  as  category, freq, 1 as index
from t1_1
union
select variable, total_donor,wbc_result1  as  category, freq , 2 as index
from t2_1

union
select variable, total_donor,wbc_count1_cat  as  category, freq , 3 as index
from t3_1

union
select variable, total_donor,unitresult  as  category, freq , 4 as index
from t4_1

order by index, variable, category
;

quit;

data t_all; set t_all;
length category_txt $ 90;

if index eq 1 and category eq 1 then do; category_txt="Negative"; class_order=1; end;
if index eq 1 and category eq 2 then do;category_txt="Unknown";class_order=2; end;
if index eq 1 and category eq 99 then do;category_txt="Pending"; class_order=3; end;
if index eq 1 and category eq 999 then do;category_txt="Not applicable( Blood product is FFP,Cryo,Gran NOT Tested) "; class_order=4; end;

if index eq 2 and category eq 1 then do;category_txt="Not detected( <0.2wbc/ul)";class_order=1; end;
if index eq 2 and category eq 2 then  do; category_txt="Detected( >= 0.2wbc/ul)";class_order=2; end;
if index eq 2 and category eq 99 then do; category_txt="Pending";class_order=3; end;
if index eq 2 and category eq 999 then do; category_txt="Not applicable( Blood product is FFP,Cryo,Gran NOT Tested) ";class_order=4; end;


if index eq 3 and category eq 0 then do; category_txt="(wbc <= 5*10^6/L)"; class_order=1; end;
if index eq 3 and category eq 1 then do; category_txt="(wbc > 5*10^6/L)";class_order=2; end;
if index eq 3 and category eq 99 then do; category_txt="Pending";class_order=3; end;
if index eq 3 and category eq 999 then do; category_txt="Not applicable( Blood product is FFP,Cryo,Gran NOT Tested) ";class_order=4; end;

if index eq 4 and category eq 1 then do; category_txt="Not detected"; class_order=1; end;
if index eq 4 and category eq 2 then do; category_txt="Low positive"; class_order=2; end;
if index eq 4 and category eq 3 then do; category_txt="Positive";class_order=3; end;
if index eq 4 and category eq 4 then do; category_txt="Indeterminate"; class_order=4; end;
if index eq 4 and category eq . then do; category_txt="Pending"; class_order=5; end;
;

if  category in (1,2) and index in (1,2) then do;
pct = (freq/total_donor)*100;
stat = compress(Left(trim(freq))) || "/"  || compress(Left(trim(total_donor)))  || "(" || compress(Left(trim(put(pct,5.0))))|| " %)" ;
end;


if  category in (0,1) and index in (3) then do;
pct = (freq/total_donor)*100;
stat = compress(Left(trim(freq))) || "/"  || compress(Left(trim(total_donor)))  || "(" || compress(Left(trim(put(pct,5.0))))|| " %)" ;
end;

if  category in (99,999) and index in (1,2,3) then do;
stat = compress(Left(trim(freq)))  ;
end;

if  category in (1,2,3,4) and index in (4) then do;
pct = (freq/total_donor)*100;
stat = compress(Left(trim(freq))) || "/"  || compress(Left(trim(total_donor)))  || "(" || compress(Left(trim(put(pct,5.0))))|| " %)" ;
end;

if  category  eq . and index in (4) then do; category=9;
stat = compress(Left(trim(freq)))  ;
end;

run;

proc sql;
create table t_all_2 as
select * from t_all
order by index, class_order asc;
quit;

/***** get macro variable *****/

proc sql;

select compress(put(count (*),3.0)) into :tx_count_macro  from tx_eos ;
select compress(put(count (*),3.0)) into :tx_rbc_macro  from tx_eos where tx_type="pRBC";
select compress(put(count (*),3.0)) into :tx_plt_macro  from tx_eos where tx_type="Plt";
select compress(put(count (*),3.0)) into :tx_ffp_macro  from tx_eos where tx_type="FFP";
select compress(put(count (*),3.0)) into :tx_cryo_macro  from tx_eos where tx_type="Cryo";

select compress(put(count (distinct(id)),3.0)) into :tx_lbwi_macro  from tx_eos ;
select compress(put(count (distinct(donorunitid)),3.0)) into :tx_donor_macro  from tx_eos ;

select compress(put(count (distinct(id)),3.0)) into :eos_lbwi_macro  from endofstudy ;

quit;

data temp; lbwi =&tx_lbwi_macro;
eos_lbwi= &eos_lbwi_macro;

pct = (lbwi/eos_lbwi)*100;
run;

proc sql;
select compress(put(pct,2.0)) into :tx_pct_macro  from temp ;
drop table temp;
quit;

