* platelet tx summary for completed;

%include "&include./monthly_toc.sas";
%include "&include./annual_toc.sas";



proc sql;

/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where (Enrollmentdate is not null ) and a.id not in (3003411,3003421); ;
*/

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
from cmv.valid_ids as a left join
cmv.endofstudy as b
on a.id=b.id;


create table rbctx as
select a.id, b.*
from endofstudy as a left join
cmv.rbctx as b
on a.id=b.id;

create table rbctx as
select * from rbctx where donorunitid is not null;


create table Platelettx as
select a.id, b.*
from endofstudy as a left join
cmv.Platelettx as b
on a.id=b.id;

create table Platelettx as
select * from Platelettx where donorunitid is not null;



create table ffptx as
select a.id, b.*
from endofstudy as a left join
cmv.plate_035 as b
on a.id=b.id;


create table ffptx  as
select * from ffptx  where donorunitid is not null;

create table cryotx as
select a.id, b.*
from endofstudy as a left join
cmv.plate_037 as b
on a.id=b.id;

create table cryotx  as
select * from cryotx  where donorunitid is not null;



quit;




data rbctx (keep=id donorunitid tx_type center rbcVolumeTransfused); /*set cmv.rbctx;*/set rbctx; id2 = left(trim(id)); center = input(substr(id2, 1, 1),1.); tx_type="pRBC";
rename volume=rbcVolumeTransfused; run;

data Platelettx(keep=id donorunitid tx_type center plt_VolumeTransfused); /*set cmv.Platelettx; */ set Platelettx; id2 = left(trim(id)); center = input(substr(id2, 1, 1),1.);;tx_type="Plt";  rename volume=plt_VolumeTransfused;  run;

data ffptx(keep=id donorunitid tx_type center ffp_VolumeTransfused); /*set cmv.plate_035;*/ set ffptx; id2 = left(trim(id)); center = input(substr(id2, 1, 1),1.);tx_type="FFP";
rename volume=ffp_VolumeTransfused;
run;

data cryotx(keep=id donorunitid tx_type center  cryo_VolumeTransfused); 
/*set cmv.plate_037;*/set cryotx;  id2 = left(trim(id)); center = input(substr(id2, 1, 1),1.);tx_type="Cryo";

rename volume=cryo_VolumeTransfused;
run;


/*


proc sql;

create table rbc_tx as
select distinct(id) as id, count(*)as lbwi_rbc_tx
from rbctx
group by id;

create table plt_tx as
select distinct(id) as id, count(*)as lbwi_plt_tx
from Platelettx
group by id;

create table ffp_tx as
select distinct(id) as id, count(*)as lbwi_ffp_tx
from ffptx
group by id;

create table cryo_tx as
select distinct(id) as id, count(*)as lbwi_cryo_tx
from cryotx
group by id;


create table enrolled as
select a.* ,b.lbwi_rbc_tx
from enrolled as a left join  rbc_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_plt_tx
from enrolled as a left join  plt_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_ffp_tx
from enrolled as a left join  ffp_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_cryo_tx
from enrolled as a left join  cryo_tx  as b on a.id=b.id;


create table rbc_tx_donor as
select id as id, count(distinct(DonorUnitId))as lbwi_rbc_donor
from rbctx
group by id;

create table plt_tx_donor as
select id as id, count(distinct(DonorUnitId))as lbwi_plt_donor
from Platelettx
group by id;


create table ffp_tx_donor as
select id as id, count(distinct(DonorUnitId))as lbwi_ffp_donor
from ffptx
group by id;

create table cryo_tx_donor as
select id as id, count(distinct(DonorUnitId))as lbwi_cryo_donor
from cryotx
group by id;


create table enrolled as
select a.* ,b.lbwi_rbc_donor
from enrolled as a left join  rbc_tx_donor as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_ffp_donor
from enrolled as a left join  ffp_tx_donor as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_plt_donor
from enrolled as a left join  plt_tx_donor as b on a.id=b.id;


create table enrolled as
select a.* ,b.lbwi_cryo_donor
from enrolled as a left join  cryo_tx_donor as b on a.id=b.id;




quit;

*/

proc sql;

create table rbc_tx as
select id , count(*)as lbwi_rbc_tx, count(distinct(DonorUnitId))as lbwi_rbc_donor
from rbctx
group by id;

create table plt_tx as
select distinct(id) as id, count(*)as lbwi_plt_tx,count(distinct(DonorUnitId))as lbwi_plt_donor
from Platelettx
group by id;

create table ffp_tx as
select id, count(*)as lbwi_ffp_tx,count(distinct(DonorUnitId))as lbwi_ffp_donor
from ffptx
group by id;

create table cryo_tx as
select  id, count(*)as lbwi_cryo_tx,count(distinct(DonorUnitId))as lbwi_cryo_donor
from cryotx
group by id;


create table enrolled as
select a.* ,b.lbwi_rbc_tx,lbwi_rbc_donor
from endofstudy as a left join  rbc_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_plt_tx,lbwi_plt_donor
from enrolled as a left join  plt_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_ffp_tx,lbwi_ffp_donor
from enrolled as a left join  ffp_tx  as b on a.id=b.id;

create table enrolled as
select a.* ,b.lbwi_cryo_tx,lbwi_cryo_donor
from enrolled as a left join  cryo_tx  as b on a.id=b.id;

create table xx as
select a.id, b.id as id2 ,a.lbwi_rbc_tx as lbwi_rbc_tx_en ,b.lbwi_rbc_tx as  lbwi_rbc_tx_rbc
from enrolled as a left join  rbc_tx  as b on a.id=b.id;

quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 


data rbctx; 
set rbctx; 
output; 
center = 0; 
output; 
run;

data Platelettx; 
set Platelettx; 
output; 
center = 0; 
output; 
run;

data ffptx; 
set ffptx; 
output; 
center = 0; 
output; 
run;


data cryotx; 
set cryotx; 
output; 
center = 0; 
output; 
run;

proc sql;

/* all donors */
create table all_donors as
select id, donorunitid ,tx_type ,center ,rbcVolumeTransfused as volume from rbctx 
union all
select id, donorunitid ,tx_type ,center ,plt_VolumeTransfused as volume from Platelettx
union all
select id, donorunitid ,tx_type ,center ,ffp_VolumeTransfused as volume from ffptx 
union all
select id, donorunitid ,tx_type ,center ,cryo_VolumeTransfused as volume from cryotx 

;

create table volume as
select id, sum(volume)as total_volume , center, tx_type from all_donors group by id,tx_type, center;

/* create table all_donors as 
select * from all_donors where id is not null;
*/ 

create table all_donors_tx as
select Tx_total,donor_total, a.center,a.tx_type
from (
select count(*) as Tx_total, center, tx_type from all_donors group by center, tx_type) as a right join

(select count(distinct(donorunitid)) as donor_total, center, tx_type from all_donors group by center, tx_type) as b
on a.center=b.center and a.tx_type=b.tx_type;


create table all_donors_tx as
select Tx_total,donor_total, center,tx_type from all_donors_tx
union
select count(*) as Tx_total,count(distinct(donorunitid)) as donor_total,center ,"All Tx" as tx_type 
from all_donors 
group by center
order by center
;

/* donor exposure table */
create table donor_count as

select donor_count, center, count(id) as total_lbwi 
from
(

select id, center, count(distinct(DonorUnitId)) as donor_count
from all_donors
group by id, center) as a 

group by center, donor_count;


/* donor exposure by tx_type table */
create table donor_count_tx_type as

select donor_count, tx_type, center, count(id) as total_lbwi 
from
(

select id, tx_type, center, count(distinct(DonorUnitId)) as donor_count
from all_donors
group by id, tx_type,center) as a 

group by center,tx_type, donor_count;

quit;

data all_donors_tx; set all_donors_tx; where center <> .;
variable = tx_type;
stat= compress( put(Tx_total,5.0))  || " (" || compress( put(donor_total,5.0))  || " )";

run;

data enrolled; set enrolled;
if lbwi_rbc_tx= . then lbwi_rbc_tx=0;
if lbwi_ffp_tx= . then lbwi_ffp_tx=0;
if lbwi_plt_tx= . then lbwi_plt_tx=0;
if lbwi_cryo_tx= . then lbwi_cryo_tx=0;

if lbwi_rbc_donor= . then lbwi_rbc_donor=0;
if lbwi_ffp_donor= . then lbwi_ffp_donor=0;
if lbwi_plt_donor= . then lbwi_plt_donor=0;
if lbwi_cryo_donor= . then lbwi_cryo_donor=0;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled; 
set enrolled; 
output; 
center = 0; 
output; 
run;

proc sql;

create table tx_results as
select count(*) as total_lbwi, center,lbwi_rbc_tx,lbwi_ffp_tx,lbwi_plt_tx,lbwi_cryo_tx
from enrolled
group by center ,lbwi_rbc_tx,lbwi_ffp_tx,lbwi_plt_tx,lbwi_cryo_tx;


create table donor_results as
select count(*) as total_lbwi, center, lbwi_rbc_donor,lbwi_ffp_donor,lbwi_plt_donor,lbwi_cryo_donor
from enrolled
group by center, lbwi_rbc_donor,lbwi_ffp_donor,lbwi_plt_donor,lbwi_cryo_donor;


select compress(put(count(*),2.0)) into: center0 from endofstudy where center=0;
select compress(put(count(*),2.0)) into: center1 from endofstudy where center=1;
select compress(put(count(*),2.0)) into: center2 from endofstudy where center=2;
select compress(put(count(*),2.0)) into: center3 from endofstudy where center=3;


select compress(put(tx_total,4.0)) into: tx0  from all_donors_tx where center=0 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx1  from all_donors_tx where center=1 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx2 from all_donors_tx where center=2 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx3 from all_donors_tx where center=3 and tx_Type='All Tx';





quit;

data donor_count; set donor_count;


if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;



stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || " )";


run;

data tx_results; set tx_results;


if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

variable ="pRBC (" || compress( put(lbwi_rbc_tx,5.0)) || ") FFP (" || compress( put(lbwi_ffp_tx,5.0))|| ") Plt (" || compress( put(lbwi_plt_tx,5.0))|| ") Cryo (" || compress( put(lbwi_cryo_tx,5.0))|| ")";

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

tx_total=lbwi_rbc_tx + lbwi_ffp_tx+lbwi_plt_tx  + lbwi_cryo_tx;
run;


data donor_results; set donor_results;

variable ="pRBC (" || compress( put(lbwi_rbc_donor,5.0)) || ") FFP (" || compress( put(lbwi_ffp_donor,5.0))|| 
          ") Plt (" || compress( put(lbwi_plt_donor,5.0))|| ") Cryo (" || compress( put(lbwi_cryo_donor,5.0)) || "% )";


if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;


stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

donor_exposure= lbwi_rbc_donor + lbwi_ffp_donor +lbwi_plt_donor ++lbwi_cryo_donor;

run;




proc format ;

value center 
0="Overall_N=&center0 _Tx total=&tx0"
2="Grady_N=&center2 _Tx total=&tx2"
1="EUHM_N=&center1 _Tx total=&tx1"
3="Northside_N=&center3 _Tx total=&tx3"
4="CHOA Egleston"
5="CHOA Scottish"
;
run;


proc means data=volume n mean median stddev min max p25 p75 maxdec=1;
class center tx_type;
var total_volume;
ods output summary=summary;
run;

data summary; set summary;
stat = compress( put(total_volume_mean,5.0)) || "(" || compress( put(total_volume_stddev,5.0))  || ")[" || compress( put(total_volume_Min,5.0)) || "," || compress( put(total_volume_Max,5.0)) 
 || "] {"  || compress( put(total_volume_Median,5.0)) || "," || compress( put(total_volume_p25,5.0)) || "," || compress( put(total_volume_p75,5.0)) || "},"
||  compress( put(total_volume_N,5.0));
  
run;







options nodate orientation=portrait;
ods rtf   file = "&output./annual/&combo_tx_summary_file.combo_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&combo_tx_summary_title a: Transfusion and donor summary for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title a: Transfusion and donor summary for LBWI who completed study ";
footnote "";

proc report data=all_donors_tx nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column      variable    center ,  (stat  )  dummy;


define variable/ group  order=data   Left    " Tx Type " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=1.5in] ""  ;

define stat/center      style(column) = [just=center cellwidth=1.5in] " Total Tx (Total donors)"  left ;
*define pipe/center    "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

format center center.;




run;

proc sql;

create table tx_results as
select * from tx_results
order by tx_total,  center;
quit;

ods noproctitle proclabel "&combo_tx_summary_title b: Transfusion types and number of transfusions for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title b: Transfusion types and number of transfusions for LBWI who completed study  ";
footnote "";

proc report data=tx_results nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column        tx_total  /* variable */ lbwi_rbc_tx lbwi_plt_tx  lbwi_ffp_tx lbwi_cryo_tx    center ,  (stat  )  dummy;


define tx_total/ group  order=data    Left  style(column) = [just=center cellwidth=1in]   " Total Tx " ;
*define variable/ group  order=data   Left    " Tx combination _Type(Tx num) " ;

define lbwi_rbc_tx/ group  order=data   Left    " # RBC_Tx " ;
define lbwi_plt_tx/ group  order=data   Left    " # Plt_Tx " ;
define lbwi_cryo_tx/ group  order=data   Left    " # Cryo_Tx " ;
define lbwi_ffp_tx/ group  order=data   Left    " # FFP_Tx " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=1.5in] ""  ;

define stat/center      style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after /  summarize skip dol;

compute tx_total;
if _break_ = '_RBREAK_' then
		tx_total = 'Total';
endcomp;

format center center.;




run;

/*

ods noproctitle proclabel "&combo_tx_summary_title c: Donor exposure for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title c: Donor exposure for LBWI who completed study ";
footnote "";

proc report data=donor_count nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column      donor_count    center ,  (stat  )  dummy;


define donor_count/ group  order=data   Left    " Total Donor exposures " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;


define dummy/NOPRINT ;




rbreak after / skip ;


format center center.;




run;
*/

proc sql;

create table donor_results as
select * from donor_results
order by donor_exposure,  center;
quit;
ods noproctitle proclabel "&combo_tx_summary_title c: Transfusion types and donor exposure for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title c: Transfusion types and donor exposure for LBWI who completed study ";
footnote "";

proc report data=donor_results nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    donor_exposure  /*variable */ lbwi_rbc_donor lbwi_plt_donor  lbwi_ffp_donor lbwi_cryo_donor    center ,  (stat  )  dummy;

define donor_exposure/ group  order=data   Left    " Total Donor exposures " ;

define variable/ group  order=data   Left    " Tx combination _Type(Donor num) " ;

define lbwi_rbc_donor/ group  order=data   Left    " # RBC_Donors " ;
define lbwi_plt_donor/ group  order=data   Left    " #  Plt_Donors" ;
define lbwi_cryo_donor/ group  order=data   Left    " #  Cryo_Donors " ;
define lbwi_ffp_donor/ group  order=data   Left    " #  FFP_Donors " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

/*compute before;
     line ' ';
  endcomp;

*/
format center center.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
*ods rtf close;
*quit;





ods noproctitle proclabel "&combo_tx_summary_title d: Summary of total transfusion volume(ml)infused for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title d: Summary of total transfusion volume(ml)infused for LBWI who completed study";
footnote "";

proc report data=summary nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column     tx_type   center,     (stat)    dummy;


define tx_type/ group  order=data   Left    " Tx Type " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=1.5in] ""  ;
define stat/center   width=20   style(column) = [just=center cellwidth=1.5in] " Mean(std)[Min,Max]_{Median,Q1,Q3},N"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

/*compute before;
     line ' ';
  endcomp;

*/
format center center.;




run;

ods rtf close;
quit;

