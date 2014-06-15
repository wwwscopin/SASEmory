/*** **************************************************************************************** /
/****** this file generates a list of missing donor tracking form for rbc tx for LBWI who completed study  ****/


/******************************************************************/

%include "&include./monthly_toc.sas";
%include "&include./annual_toc.sas";

proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
( select * from cmv.endofstudy where reason in (1,2,3,6) )as b
on a.id=b.id;


create table endofstudy as
select a.id, b.*
from cmv.valid_ids as a right join
cmv.endofstudy as b
on a.id=b.id;
run;

data endofstudy; set endofstudy;

where reason in (1,2,3,6);
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

proc sql;

create table all_tx as
select id, dfseq ,donorunitid, "rbc" as tx_type ,DateTransfusion from cmv.plate_031
union
select id, dfseq ,donorunitid, "plt" as tx_type,DateTransfusion from cmv.plate_033
union
select id, dfseq ,donorunitid, "ffp" as tx_type ,DateTransfusion from cmv.plate_035
union
select id, dfseq ,donorunitid, "cryo" as tx_type,DateTransfusion from cmv.plate_037;


create table all_tx2 as
select * 
from all_tx as a inner join
endofstudy as b
on a.id=b.id;

create table tx_lbwi as
select distinct (id) from all_tx2;

create table distinct_donors as
select distinct donorunitid from all_tx2;


create table distinct_donors_rbc as
select distinct donorunitid from all_tx2 /*where tx_type="rbc"*/;

create table rbc_tx as
select count(*) from all_tx2 where tx_type="rbc";

create table donor_bu as
select distinct (donorunitid) as bu_donor from cmv.plate_001_bu;


create table distinct_rbc_donors_bu as
select donorunitid, bu_donor 
from distinct_donors_rbc as a left join
donor_bu as b
on a.donorunitid=b.bu_donor;

create table distinct_rbc_donors_bu_lbwi as
select a.*,b.id,b.donor_lbwi,b.tx_type
from distinct_rbc_donors_bu as a
left join
( select distinct (donorunitid) as donor_lbwi, id ,tx_type from all_tx2 /*where tx_type="rbc"*/) as b
on a.donorunitid = b.donor_lbwi
order by b.id;


create table donor_bu_missing as
select * 
from distinct_rbc_donors_bu_lbwi 
where bu_donor is null;


create table donor_bu_missing_2 as
select a.*,b.dfseq ,DateTransfusion,b.tx_type
from donor_bu_missing as a
left join
all_tx as b
on a.donorunitid=b.donorunitid and a.id=b.id
order by id,DateTransfusion ;

create table donor_bu_missing_2_count as
select donorunitid, id , max(DateTransfusion) as last_tx_date, count(*) as tx_count,tx_type
from donor_bu_missing_2
 
group by donorunitid, id ,tx_type
order by id,last_tx_date
;


quit;

data donor_bu_missing_2_count;
set donor_bu_missing_2_count;
if id >1000000 and id < 2000000 then center="Emory";
else if id >2000000 and id < 3000000 then center="Grady";
else if id >3000000 and id < 4000000 then center="NS";

run;

/***** wbc missing *******/
proc sql;
create table donor_wbc as
select distinct (donorunitid) as bu_donor from cmv.plate_002_bu;


create table distinct_rbc_donors_wbc as
select donorunitid, bu_donor 
from distinct_donors_rbc as a left join
donor_wbc as b
on a.donorunitid=b.bu_donor;

create table distinct_rbc_donors_wbc_lbwi as
select a.*,b.id,b.donor_lbwi,b.tx_type
from distinct_rbc_donors_wbc as a
left join
( select distinct (donorunitid) as donor_lbwi, id ,tx_type from all_tx2 /*where tx_type="rbc"*/) as b
on a.donorunitid = b.donor_lbwi
order by b.id;


create table donor_wbc_missing as
select * 
from distinct_rbc_donors_wbc_lbwi 
where bu_donor is null;


create table donor_bu_missing_2 as
select a.*,b.dfseq ,DateTransfusion,b.tx_type
from donor_wbc_missing as a
left join
all_tx as b
on a.donorunitid=b.donorunitid and a.id=b.id
order by id,DateTransfusion ;

create table donor_wbc_missing_2_count as
select donorunitid, id , max(DateTransfusion) as last_tx_date, count(*) as tx_count,tx_type
from donor_bu_missing_2
 
group by donorunitid, id ,tx_type
order by id,last_tx_date
;

quit;


data donor_wbc_missing_2_count;
set donor_wbc_missing_2_count;
if id >1000000 and id < 2000000 then center="Emory";
else if id >2000000 and id < 3000000 then center="Grady";
else if id >3000000 and id < 4000000 then center="NS";

run;
/***** donor NAT ********/

proc sql;
create table donor_nat as
select distinct (donorunitid) as bu_donor from cmv.plate_003_bu;


create table distinct_rbc_donors_nat as
select donorunitid, bu_donor 
from distinct_donors_rbc as a left join
donor_nat as b
on a.donorunitid=b.bu_donor;

create table distinct_rbc_donors_nat_lbwi as
select a.*,b.id,b.donor_lbwi,b.tx_type
from distinct_rbc_donors_nat as a
left join
( select distinct (donorunitid) as donor_lbwi, id ,tx_type from all_tx2 /*where tx_type="rbc"*/) as b
on a.donorunitid = b.donor_lbwi
order by b.id;


create table donor_nat_missing as
select * 
from distinct_rbc_donors_nat_lbwi 
where bu_donor is null;


create table donor_bu_missing_2 as
select a.*,b.dfseq ,DateTransfusion,b.tx_type
from donor_nat_missing as a
left join
all_tx as b
on a.donorunitid=b.donorunitid and a.id=b.id
order by id,DateTransfusion ;

create table donor_nat_missing_2_count as
select donorunitid, id , max(DateTransfusion) as last_tx_date, count(*) as tx_count,tx_type
from donor_bu_missing_2
 
group by donorunitid, id ,tx_type
order by id,last_tx_date
;

quit;


data donor_nat_missing_2_count;
set donor_nat_missing_2_count;
if id >1000000 and id < 2000000 then center="Emory";
else if id >2000000 and id < 3000000 then center="Grady";
else if id >3000000 and id < 4000000 then center="NS";

run;


/************** summarise missing information by hospital ****************/
proc sql;
create table all_tx2_hospital as
select count(distinct donorunitid) as donor_total , "Overall" as hospital, 0 as center
from all_tx2 
union
select count(distinct donorunitid) as donor_total , "EUH" as hospital, 1 as center
from all_tx2 where id >1000000 and id < 2000000 
union
select count(distinct donorunitid) as donor_total, "Grady" as hospital, 2 as center
from all_tx2 where id >2000000 and id < 3000000
union
select count(distinct donorunitid) as donor_total, "NS" as hospital, 3 as center
from all_tx2 where id >3000000 and id < 4000000;


create table donor_tracking as
select count(distinct donorunitid) as track_donor_total , "Overall" as hospital, 0 as center
from donor_bu_missing_2_count 
union
select count(distinct donorunitid) as track_donor_total , "EUH" as hospital, 1 as center
from donor_bu_missing_2_count where id >1000000 and id < 2000000 
union
select count(distinct donorunitid) as track_donor_total, "Grady" as hospital, 2 as center
from donor_bu_missing_2_count where id >2000000 and id < 3000000
union
select count(distinct donorunitid) as track_donor_total, "NS" as hospital, 3 as center
from donor_bu_missing_2_count where id >3000000 and id < 4000000;


create table donor_wbc as
select count(distinct donorunitid) as wbc_donor_total , "Overall" as hospital, 0 as center
from donor_wbc_missing_2_count 
union
select count(distinct donorunitid) as wbc_donor_total , "EUH" as hospital, 1 as center
from donor_wbc_missing_2_count where id >1000000 and id < 2000000 
union
select count(distinct donorunitid) as wbc_donor_total, "Grady" as hospital, 2 as center
from donor_wbc_missing_2_count where id >2000000 and id < 3000000
union
select count(distinct donorunitid) as wbc_donor_total, "NS" as hospital, 3 as center
from donor_wbc_missing_2_count where id >3000000 and id < 4000000;


create table donor_nat as
select count(distinct donorunitid) as nat_donor_total , "Overall" as hospital, 0 as center
from donor_nat_missing_2_count 
union
select count(distinct donorunitid) as nat_donor_total , "EUH" as hospital, 1 as center
from donor_nat_missing_2_count where id >1000000 and id < 2000000 
union
select count(distinct donorunitid) as nat_donor_total, "Grady" as hospital, 2 as center
from donor_nat_missing_2_count where id >2000000 and id < 3000000
union
select count(distinct donorunitid) as nat_donor_total, "NS" as hospital, 3 as center
from donor_nat_missing_2_count where id >3000000 and id < 4000000;

create table donor_summary as
 select a.*,track_donor_total, wbc_donor_total, nat_donor_total
from all_tx2_hospital as a left join
donor_tracking as b 
on a.center=b.center
left join
donor_wbc as c
on a.center=c.center

left join
donor_nat as d
on a.center=d.center;
quit;

data donor_summary; set donor_summary;

track_stat=compress(donor_total-track_donor_total) || "/" || compress(donor_total) || "(" || compress(put(((donor_total-track_donor_total)/donor_total)*100,3.0)) || "%)";
wbc_stat=compress(donor_total-wbc_donor_total) || "/" || compress(donor_total) || "(" || compress(put(( (donor_total-wbc_donor_total)/donor_total)*100,3.0)) || "%)";
nat_stat=compress(donor_total-nat_donor_total) || "/" || compress(donor_total) || "(" || compress(put(( (donor_total-nat_donor_total)/donor_total)*100,3.0)) || "%)";

run;

/************************ summary output for monthly***********************/

ods escapechar='\';
options nodate orientation=portrait;
ods rtf   file = "&output./monthly/&patient_study_status_file.1_donor_tx_track_missing.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&patient_study_status_title .1:Donor database status for LBWI completed study";

title  justify = center "&patient_study_status_title .1:Donor database status for LBWI completed study";
footnote "";

proc report data=donor_summary nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  Hospital donor_total  track_stat wbc_stat nat_stat  dummy;

define  Hospital/ group  order=data   Left    " Hospital " ;

define donor_total/ group  order=data   Left    " Donor Total" ;
define track_stat/ group  order=data   Left    " Donor Tracking Forms Received" ;
define wbc_stat/ group  order=data   Left    " Donor WBC Results Received" ;
define nat_stat/ group  order=data   Left    " Donor NAT Results Received" ;

define dummy/NOPRINT ;


rbreak after / skip ;



run;

ods rtf close;



/***********************************************************/

/*********Need this in annual *****************/

ods escapechar='\';
options nodate orientation=portrait;
ods rtf   file = "&output./annual/rbc_tx_track_missing.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "Transfusion occurred but Donor Tracking Form Missing for LBWI completed study";

title  justify = center "Transfusion occurred but Donor Tracking Form Missing for LBWI completed study";
footnote "";

proc report data=donor_bu_missing_2_count nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  center    donorunitid id    last_tx_date tx_type tx_count dummy;

define center/ group  order=data   Left    " Hospital " ;
define donorunitid/group order=data center      style(column) = [just=center cellwidth=1.5in] " Donor Id"  left ;
define id/ group  order=data   Left    " LBWI id " ;

define last_tx_date/ group order=internal  "Last Tx date_from this donor"    style(column) = [just=center cellwidth=1.5in] format=date7.  ;
define tx_count/ group  order=data   Left    " Total Tx from this donor " ;
define tx_type/ group  order=data   Left    " tx_type " ;



define dummy/NOPRINT ;


rbreak after / skip ;

compute after center;
line '';
endcomp;

run;


title  justify = center "Transfusion occurred but Donor WBC Form Missing for LBWI completed study";
footnote "";

proc report data=donor_wbc_missing_2_count nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  center    donorunitid id    last_tx_date tx_type tx_count dummy;

define center/ group  order=data   Left    " Hospital " ;
define donorunitid/group order=data center      style(column) = [just=center cellwidth=1.5in] " Donor Id"  left ;
define id/ group  order=data   Left    " LBWI id " ;

define last_tx_date/ group order=internal  "Last Tx date_from this donor"    style(column) = [just=center cellwidth=1.5in] format=date7.  ;
define tx_count/ group  order=data   Left    " Total Tx from this donor " ;
define tx_type/ group  order=data   Left    " tx_type " ;



define dummy/NOPRINT ;


rbreak after / skip ;

compute after center;
line '';
endcomp;

run;


title  justify = center "Transfusion occurred but Donor NAT Results Form Missing for LBWI completed study";
footnote "";

proc report data=donor_nat_missing_2_count nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  center    donorunitid id    last_tx_date tx_type tx_count dummy;

define center/ group  order=data   Left    " Hospital " ;
define donorunitid/group order=data center      style(column) = [just=center cellwidth=1.5in] " Donor Id"  left ;
define id/ group  order=data   Left    " LBWI id " ;

define last_tx_date/ group order=internal  "Last Tx date_from this donor"    style(column) = [just=center cellwidth=1.5in] format=date7.  ;
define tx_count/ group  order=data   Left    " Total Tx from this donor " ;
define tx_type/ group  order=data   Left    " tx_type " ;



define dummy/NOPRINT ;


rbreak after / skip ;

compute after center;
line '';
endcomp;

run;
ods rtf close;
