/*libname cmv "/ttcmv/sas/data/freeze2011.03.09";

*/
%include "&include./monthly_toc.sas";

*%include "style.sas";

proc sql;
/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where (enrollmentdate is not null or IsEligible =1 )and  a.id not in (3003411,3003421);
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
cmv.endofstudy as b
on a.id=b.id where reason in (1,2,3,6);




quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


proc sql;

create table enrolled_rbc as
select a.id, a.id2,a.center, a.DateOfBirth , b.*
from enrolled as a ,
cmv.plate_031 as b
where a.id=b.id;

quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled_rbc; 
set enrolled_rbc; 
output; 
center = 0; 
output; 
run;


data enrolled; 
set enrolled; 
output; 
center = 0; 
output; 
run;



proc sql;
create table total_lbwi_count as
select count(id) as Total_Lbwi_Count, center
from enrolled
group by center;


create table rbc_count as
select id, count(*) as rbcTxTotal, center 
from enrolled_rbc
where dfseq <> .
group by  id ,center;


/* no RBC tx patients */

create table enrolled_rbc_no as
select a.id, a.id2,a.center, a.DateOfBirth , b.txId as txID
from enrolled as a left join
( select distinct(id) as txId 
from cmv.rbctx
) as b
 
on a.id=b.txid
;





create table enrolled_rbc_no as
select a.* , b.Total_Lbwi_Count
from (select count(distinct(id)) as lbwi_count, center
from enrolled_rbc_no
where  txId is null
group by center) as a, 
total_lbwi_count as b
where a.center=b.center;


create table rbc_count as
select id, count(*) as rbcTxTotal, center 
from enrolled_rbc
where dfseq <> .
group by  id ,center;



create table rbc_count2 as
select a.* , b.Total_Lbwi_Count
from rbc_count as a, total_lbwi_count as b
where a.center=b.center;



quit;


/* any tx */

proc sql;
create table rbc_count3 as


select   lbwi_count, center, Total_Lbwi_Count, "No red-cell transfusion - num of LBWI" as variable , 0 as gp, "All Patients" as groupvariable
from enrolled_rbc_no
where center > 0 



union

select  lbwi_count, 0 as center, sum(Total_Lbwi_Count) as Total_Lbwi_Count, "No red-cell transfusion - num of LBWI" as variable , 0 as gp, "All Patients" as groupvariable
from enrolled_rbc_no 
where center = 0 




union

select count(id) as lbwi_count, center, Total_Lbwi_Count, "1 or more Tx - num of LBWI" as variable , 4 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where center > 0
group by center,Total_Lbwi_Count


union

select count(id) as lbwi_count, 0 as center, Total_Lbwi_Count as Total_Lbwi_Count, "1 or more Tx - num of LBWI" as variable , 4 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where center = 0


union


select count(id) as lbwi_count, center, Total_Lbwi_Count, "	1 Tx - num of LBWI" as variable , 5 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 1
group by center, Total_Lbwi_Count

union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	2 Tx - num of LBWI" as variable , 6 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 2
group by center, Total_Lbwi_Count


union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	3 Tx - num of LBWI" as variable, 8 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 3
group by center, Total_Lbwi_Count

union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	4 Tx - num of LBWI" as variable, 9 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 4
group by center, Total_Lbwi_Count

union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	5-6 Tx - num of LBWI" as variable, 10 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 5 or rbcTxTotal = 6
group by center, Total_Lbwi_Count


union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	7-10 Tx - num of LBWI" as variable, 11 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal > 6 and  rbcTxTotal <=10
group by center, Total_Lbwi_Count


union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "	>10 Tx - num of LBWI" as variable, 12 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal >10
group by center, Total_Lbwi_Count

order by gp

;



quit;

data ReportTable_tx( keep=gp groupvariable variable center stat); set rbc_count3;

length stat $ 50;

pct = ( lbwi_count/Total_Lbwi_Count) * 100;



if pct <100 and pct > 0 then
stat= compress( put(lbwi_count,5.0))   || " / " || compress( put(Total_Lbwi_Count,5.0))  || "\n( " || compress(put(pct,5.1))  || "%) "  ;

else if pct = 100 or pct =0 then
stat= compress( put(lbwi_count,5.0))   || " / " || compress( put(Total_Lbwi_Count,5.0))  || "\n( " || compress(put(pct,5.0))  || "% ) "  ;
 
run;

data enrolled;
length centerXX $ 50;
set enrolled;

if center= 0 then centerXX='Overall';

if center= 2 then centerXX='Grady';
if center= 3 then centerXX='Northside';
if center= 1 then centerXX='EUHM';
run;


proc sql;
  create table tofmt as
  select  ( compress( centerXX) || '_( N = ' || compress(put(Count(*),3.)) || ' )' ) as total, center,centerXX

  from enrolled

group by center,centerXX;
quit;


proc sql;
select compress(put(Count(*),3.)) into :center0 from enrolled;
select compress(put(Count(*),3.)) into :center1 from enrolled where center=1;
select compress(put(Count(*),3.)) into :center2 from enrolled where center=2;
select compress(put(Count(*),3.)) into :center3 from enrolled where center=3;
quit;

proc format;
value center
0="Overall (N=&center0)"
1="EUHM (N=&center1)"
2="Grady (N=&center2)"
3="EUHM (N=&center3)";
run;

data fmt_dataset;
  retain fmtname "cvar";
  set tofmt ;
  start = center;
  label = total  ;
run;
proc format cntlin = fmt_dataset  fmtlib;
  select cvar;
  run;



quit;

proc format;
value center
0="Overall (N=&center0)"
1="EUHM (N=&center1)"
2="Grady (N=&center2)"
3="EUHM (N=&center3)";
run;




options nodate orientation=portrait;
ods escapechar='\';
ods rtf   file = "&output./monthly/&rbc_tx_summary_file2.rbc_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&rbc_tx_summary_title2 pRBC Transfusions for LBWI who completed study ";



title  justify = center "&rbc_tx_summary_title2 pRBC Transfusions for LBWI who completed study  ";
footnote "";

proc report data=ReportTable_tx nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column     /*groupvariable */ variable    center ,  (stat  )  dummy;



*define groupvariable/ group order=data    " " ;



define variable/ group  order=data   Left    " Num of pRBC Txs " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  format=cvar.;

define stat/center   width=20   style(column) = [just=center cellwidth=1in] "  "  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


*break after  groupvariable/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



/*compute after groupvariable;
     line ' ';
  endcomp;

*/

format center center.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;







