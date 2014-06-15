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


create table endofstudy_tx as
select a.* ,b.lbwi_rbc_tx,lbwi_rbc_donor
from endofstudy as a left join  rbc_tx  as b on a.id=b.id;

create table endofstudy_tx as
select a.* ,b.lbwi_plt_tx,lbwi_plt_donor
from endofstudy_tx as a left join  plt_tx  as b on a.id=b.id;

create table endofstudy_tx as
select a.* ,b.lbwi_ffp_tx,lbwi_ffp_donor
from endofstudy_tx as a left join  ffp_tx  as b on a.id=b.id;

create table endofstudy_tx as
select a.* ,b.lbwi_cryo_tx,lbwi_cryo_donor
from endofstudy_tx as a left join  cryo_tx  as b on a.id=b.id;
run;



data endofstudy_tx; set endofstudy_tx;
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

prc sql;
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

create table volume as
select id, sum(volume)as total_volume , center, tx_type from all_donors group by id,tx_type, center;


select compress(put(count(*),2.0)) into: center0 from endofstudy ;
select compress(put(count(*),2.0)) into: center1 from endofstudy where center=1;
select compress(put(count(*),2.0)) into: center2 from endofstudy where center=2;
select compress(put(count(*),2.0)) into: center3 from endofstudy where center=3;


select compress(put(tx_total,4.0)) into: tx0  from all_donors_tx where center=0 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx1  from all_donors_tx where center=1 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx2 from all_donors_tx where center=2 and tx_Type='All Tx';
select compress(put(tx_total,4.0)) into: tx3 from all_donors_tx where center=3 and tx_Type='All Tx';

quit;


data all_donors_tx; set all_donors_tx; where center <> .;
variable = tx_type;
stat= compress( put(Tx_total,5.0))  || " (" || compress( put(donor_total,5.0))  || " )";

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

value last
0="."
1="Total:";
run;



/*************************************************************/
/* ******* tx distribution table   */

data endofstudy_tx; 
set endofstudy_tx; 
output; 
center = 0; 
output; 
run;

proc sql;

create table tx_results as
select count(*) as total_lbwi, center,lbwi_rbc_tx,lbwi_ffp_tx,lbwi_plt_tx,lbwi_cryo_tx, 0 as last
from endofstudy_tx
group by center ,lbwi_rbc_tx,lbwi_ffp_tx,lbwi_plt_tx,lbwi_cryo_tx

union

select count(*) as total_lbwi,   center,  b.lbwi_rbc_tx,  b.lbwi_ffp_tx,   b.lbwi_plt_tx ,   b.lbwi_cryo_tx, 1 as last
from endofstudy_tx as a , 
( select sum(lbwi_rbc_tx) as lbwi_rbc_tx, sum(lbwi_ffp_tx)  as lbwi_ffp_tx,  
sum(lbwi_plt_tx) as lbwi_plt_tx ,  sum(lbwi_cryo_tx) as lbwi_cryo_tx 

from endofstudy_tx where center=0 and ( lbwi_rbc_tx > 0  or lbwi_ffp_tx > 0 or  lbwi_plt_tx> 0 or lbwi_cryo_tx > 0  ) ) as b
where a.lbwi_rbc_tx > 0  or a.lbwi_ffp_tx > 0 or  a.lbwi_plt_tx> 0 or a.lbwi_cryo_tx > 0  
group by center 

 ;



quit;



data tx_results; set tx_results;


if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

variable ="pRBC (" || compress( put(lbwi_rbc_tx,5.0)) || ") FFP (" || compress( put(lbwi_ffp_tx,5.0))|| ") Plt (" || compress( put(lbwi_plt_tx,5.0))|| ") Cryo (" || compress( put(lbwi_cryo_tx,5.0))|| ")";

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

tx_total=lbwi_rbc_tx + lbwi_ffp_tx+lbwi_plt_tx  + lbwi_cryo_tx;
run;


proc sql;

create table tx_results as
select * from tx_results
order by tx_total,  center;
quit;


/*************************************************************/
/*********Donor exposure table *****************/

proc sql;

create table xx as

select lbwi_rbc_donor,lbwi_plt_donor,lbwi_ffp_donor,lbwi_cryo_donor
from 
(
select  count(distinct(donorunitid))as lbwi_rbc_donor from all_donors 
 where center=0 and tx_type="pRBC") as a,

(
select  count(distinct(donorunitid))as lbwi_ffp_donor from all_donors 
 where center=0 and tx_type="FFP") as b,


(
select  count(distinct(donorunitid))as lbwi_cryo_donor from all_donors 
 where center=0 and tx_type="Cryo") as c,


(
select  count(distinct(donorunitid))as lbwi_plt_donor from all_donors 
 where center=0 and tx_type="Plt") as d


;


create table donor_results as
select count(*) as total_lbwi, center, lbwi_rbc_donor,lbwi_ffp_donor,lbwi_plt_donor,lbwi_cryo_donor, 0 as last
from endofstudy_tx
group by center, lbwi_rbc_donor,lbwi_ffp_donor,lbwi_plt_donor,lbwi_cryo_donor



union

select count(*) as total_lbwi,   center,  b.lbwi_rbc_donor,  b.lbwi_ffp_donor,   b.lbwi_plt_donor ,   b.lbwi_cryo_donor, 1 as last
from endofstudy_tx as a , 
( select * from xx

 ) as b
where a.lbwi_rbc_donor > 0  or a.lbwi_ffp_donor > 0 or  a.lbwi_plt_donor> 0 or a.lbwi_cryo_donor > 0  
group by center 

 ;





*drop table xx;
quit;


data donor_results; set donor_results;

variable ="pRBC (" || compress( put(lbwi_rbc_donor,5.0)) || ") FFP (" || compress( put(lbwi_ffp_donor,5.0))|| 
          ") Plt (" || compress( put(lbwi_plt_donor,5.0))|| ") Cryo (" || compress( put(lbwi_cryo_donor,5.0)) || ")";


if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;


stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

donor_exposure= lbwi_rbc_donor + lbwi_ffp_donor +lbwi_plt_donor ++lbwi_cryo_donor;

run;

/***************RBC donor exposure***************************************/
proc sql;

create table donor_results_rbc as

select lbwi_rbc_donor as donor_exposure, sum(total_lbwi)as total_lbwi, center,last
from donor_results
group by center,lbwi_rbc_donor,last;

quit;

data donor_results_rbc; set donor_results_rbc;

if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

run;


/***************PLT donor exposure***************************************/
proc sql;

create table donor_results_plt as

select lbwi_plt_donor as donor_exposure, sum(total_lbwi)as total_lbwi, center,last
from donor_results
where last=0
group by center,lbwi_plt_donor,last 

union

select  b.lbwi_plt_donor as donor_exposure, count(*) as total_lbwi,  center, 1 as last
from endofstudy_tx as a , 
( select * from xx

 ) as b 
where  a.lbwi_plt_donor > 0   
group by center ;


quit;

data donor_results_plt; set donor_results_plt;

if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

run;


/***************ffp donor exposure***************************************/
proc sql;

create table donor_results_ffp as

select lbwi_ffp_donor as donor_exposure, sum(total_lbwi)as total_lbwi, center,last
from donor_results
where last=0
group by center,lbwi_ffp_donor,last

union

select  b.lbwi_ffp_donor as donor_exposure, count(*) as total_lbwi,  center, 1 as last
from endofstudy_tx as a , 
( select * from xx

 ) as b 
where  a.lbwi_ffp_donor > 0   
group by center ;

quit;

data donor_results_ffp; set donor_results_ffp;

if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

run;

/***************cryo donor exposure***************************************/
proc sql;

create table donor_results_cryo as

select lbwi_cryo_donor as donor_exposure, sum(total_lbwi)as total_lbwi, center,last
from donor_results
where last=0
group by center,lbwi_cryo_donor,last

union

select  b.lbwi_cryo_donor as donor_exposure, count(*) as total_lbwi,  center, 1 as last
from endofstudy_tx as a , 
( select * from xx

 ) as b 
where  a.lbwi_cryo_donor > 0   
group by center ;

quit;

data donor_results_cryo; set donor_results_cryo;

if center=0 then total_center=&center0;
if center=1 then total_center=&center1;
if center=2 then total_center=&center2;
if center=3 then total_center=&center3;

stat = compress( put(total_lbwi,5.0)) || " ( " || compress( put((total_lbwi/total_center)*100,5.0)) || "% )";

run;

/***************volume of product given ***************************************/

proc means data=volume n mean median stddev min max p25 p75 maxdec=1;
class center tx_type;
var total_volume;
ods output summary=summary;
run;

proc univariate data=volume ;
class center tx_type;
var total_volume;
output out=uni mad=mad; run;


data uni; set uni;
if tx_type="Cryo" then tx_type2="Cryo";
if tx_type="FFPo" then tx_type2="FFP";
 
if tx_type="Plto" then tx_type2="Plt";
if tx_type="pRBC" then tx_type2="pRBC";
run;

proc sql;
create table summary as
select a.* , b.mad
from summary as a left join
uni as b
on a.center=b.center and a.tx_type=b.tx_type2;
quit;
run;


data summary; set summary;
/*stat = compress( put(total_volume_mean,5.0)) || "(" || compress( put(total_volume_stddev,5.0))  || ")[" || compress( put(total_volume_Min,5.0)) || "," || compress( put(total_volume_Max,5.0)) 
 || "] {"  || compress( put(total_volume_Median,5.0)) || "," || compress( put(total_volume_p25,5.0)) || "," || compress( put(total_volume_p75,5.0)) || "},"
||  compress( put(total_volume_N,5.0));

*/
stat =  compress( put(total_volume_Median,5.0)) || "["  || compress( put(mad,5.1)) || "] "
||  compress( put(total_volume_N,5.0));
  
run;

/*************************************************************/
/*********Need this in monthly *****************/


options nodate orientation=portrait;
ods rtf   file = "&output./monthly/&txn_donor_file.combo_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&txn_donor_title  Transfusion and donor summary for LBWI who completed study ";

title  justify = center "&txn_donor_title  Transfusion and donor summary for LBWI who completed study ";
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
ods rtf close;



/*************************************************************/
/*********Need this in annual *****************/

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




ods noproctitle proclabel "&combo_tx_summary_title b: Transfusion types and number of transfusions for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title b: Transfusion types and number of transfusions for LBWI who completed study  ";
footnote "";

proc report data=tx_results nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    last    tx_total  /* variable */ lbwi_rbc_tx lbwi_plt_tx  lbwi_ffp_tx lbwi_cryo_tx    center ,  (stat  )  dummy;



define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;

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

proc sql;

create table donor_results as
select * from donor_results
order by donor_exposure,  center;
quit;
ods noproctitle proclabel "&combo_tx_summary_title c: Transfusion types and donor exposure for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title c: Transfusion types and donor exposure for LBWI who completed study ";
footnote "";

proc report data=donor_results nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  last  donor_exposure  /*variable */ lbwi_rbc_donor lbwi_plt_donor  lbwi_ffp_donor lbwi_cryo_donor    center ,  (stat  )  dummy;

define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;
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


format center center.;




run;

ods noproctitle proclabel "&combo_tx_summary_title d: Total transfusion volume(ml)infused for LBWI who completed study ";

title  justify = center "&combo_tx_summary_title d: Total transfusion volume(ml)infused for LBWI who completed study";
footnote "";

proc report data=summary nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column     tx_type   center,     (stat)    dummy;


define tx_type/ group  order=data   Left    " Tx Type " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=1.5in] ""  ;
define stat/center   width=20   style(column) = [just=center cellwidth=1.5in] " Median [MAD] N"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;


format center center.;




run;

ods rtf close;

/*************************************************************/
/*********Need this in monthly individual tx type donor exposure*****************/


options nodate orientation=portrait;
ods rtf   file = "&output./monthly/&donor_summary_file.donor_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;


ods noproctitle proclabel "&donor_summary_title a: Donor exposure from RBC Tx for LBWI who completed study ";

title  justify = center "&donor_summary_title a: Donor exposure from RBC Tx for LBWI who completed study ";
footnote "";

proc report data=donor_results_rbc nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  last  donor_exposure      center ,  (stat )  dummy;

define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;
define donor_exposure/ group  order=data   Left    " Total Donor exposures " ;



define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;


format center center.;




run;

ods noproctitle proclabel "&donor_summary_title b: Donor exposure from Plt Tx for LBWI who completed study ";

title  justify = center "&donor_summary_title b: Donor exposure from Plt Tx for LBWI who completed study ";
footnote "";

proc report data=donor_results_Plt nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  last  donor_exposure      center ,  (stat )  dummy;

define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;
define donor_exposure/ group  order=data   Left    " Total Donor exposures " ;



define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;
format center center.;

run;

ods noproctitle proclabel "&donor_summary_title c: Donor exposure from FFP Tx for LBWI who completed study ";

title  justify = center "&donor_summary_title c: Donor exposure from FFP Tx for LBWI who completed study ";
footnote "";

proc report data=donor_results_FFP nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  last  donor_exposure      center ,  (stat )  dummy;

define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;
define donor_exposure/ group  order=data   Left    " Total Donor exposures " ;



define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;
format center center.;

run;

ods noproctitle proclabel "&donor_summary_summary_title d: Donor exposure from Cryoprecipitate Tx for LBWI who completed study ";

title  justify = center "&donor_summary_title d: Donor exposure from Cryoprecipitate Tx for LBWI who completed study ";
footnote "";

proc report data=donor_results_cryo nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  last  donor_exposure      center ,  (stat )  dummy;

define last/ group  order=data    Left  style(column) = [just=center cellwidth=0.5in]   "  " format=last. ;
define donor_exposure/ group  order=data   Left    " Total Donor exposures " ;



define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  ;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] " n (%)"  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;
format center center.;

run;

ods rtf close;



