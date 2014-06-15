%include "&include./annual_toc.sas";

*%include "style.sas";

proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


proc sql;

create table enrolled_rbc as
select a.id, a.id2,a.center, a.DateOfBirth , b.*
from enrolled as a ,
cmv.rbctx as b
where a.id=b.id;

create table total_lbwi_count as
select count(id) as Total_Lbwi_Count, center
from enrolled
group by center;


create table rbc_count as
select id, count(*) as rbcTxTotal, center 
from enrolled_rbc
where dfseq <> .
group by  id ,center;



create table rbc_count2 as
select a.* , b.Total_Lbwi_Count
from rbc_count as a, total_lbwi_count as b
where a.center=b.center;




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
from enrolled_rbc_no as a, total_lbwi_count as b
where a.center=b.center;



/* RBC Unit */


create table donorunit as
select count(Distinct(DonorUnitId)) as TotalDonors , id,center
from enrolled_rbc
group by id,center;

quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data rbc_count2; 
set rbc_count2; 
output; 
center = 0; 
output; 
run; 


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled_rbc_no; 
set enrolled_rbc_no; 
output; 
center = 0; 
output; 
run; 

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data donorunit2; 
set donorunit; 
output; 
center = 0; 
output; 
run;

/* ALL PAtients */






proc means data = donorunit2 fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. ;
					class  center ; 

				var TotalDonors;
				output out = donor_out sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data donor_out2; set donor_out;

if center =.  then delete;


run;


data ReportTable_donor_no_rbc( keep=gp groupvariable variable center stat); 
set donor_out2;


length stat $ 50;

gp =1;

groupvariable="All Patients";
variable = "No. of red-cell units per patient-  Median (min,max,sum)";
stat= compress( put(median,5.0))   || " [ " || compress(put(min,5.0))  || " , "  || compress(put(max,5.0)) || ", " ||  compress(put(sum,5.0)) || " ]";


 
run;




proc sql;



/* any tx */


create table rbc_count3 as


select count(id) as lbwi_count, center, Total_Lbwi_Count, "No red-cell transfusion - no of patients (%)" as variable , 0 as gp, "All Patients" as groupvariable
from enrolled_rbc_no
where center > 0 and txId is null
group by center,Total_Lbwi_Count


union

select count(id) as lbwi_count, 0 as center, sum(Total_Lbwi_Count) as Total_Lbwi_Count, "No red-cell transfusion - no of patients (%)" as variable , 0 as gp, "All Patients" as groupvariable
from enrolled_rbc_no 
where center = 0 and txId is null



union

select count(id) as lbwi_count, center, Total_Lbwi_Count, "Any tx - no. of patients (%)" as variable , 4 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where center > 0
group by center,Total_Lbwi_Count


union

select count(id) as lbwi_count, 0 as center, sum(Total_Lbwi_Count) as Total_Lbwi_Count, "Any tx - no. of patients (%)" as variable , 4 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where center = 0


union


select count(id) as lbwi_count, center, Total_Lbwi_Count, "1 tx - no. of patients (%)" as variable , 5 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 1
group by center, Total_Lbwi_Count

union
select count(id) as lbwi_count, center, Total_Lbwi_Count, "2 tx - no. of patients (%)" as variable , 6 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal = 2
group by center, Total_Lbwi_Count


union
select count(id) as lbwi_count, center, Total_Lbwi_Count, ">2 tx - no. of patients (%)" as variable, 7 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
where  rbcTxTotal > 2
group by center, Total_Lbwi_Count

order by gp

;



quit;




data ReportTable_tx( keep=gp groupvariable variable center stat); set rbc_count3;

length stat $ 50;

pct = lbwi_count/Total_Lbwi_Count;

stat= compress( put(lbwi_count,5.0))   || " ( " || compress(put(pct,5.1))  || " ) "  ;


 
run;


proc sql;

create table donor_unit as
select count(Distinct(DonorUnitId)) as donor_count, id,center
from enrolled_rbc
where dfseq <> .
group by  id ,center;


quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data donor_unit2; 
set donor_unit; 
output; 
center = 0; 
output; 
run; 



proc means data = donor_unit2 fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class  center ;

				var donor_count;
				output out = donor_sum_by_center_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data donor_sum_by_center_summary2; set donor_sum_by_center_summary;

if center =.  then delete;


run;


data ReportTable_donor( keep=gp groupvariable variable center stat); 
set donor_sum_by_center_summary2;


length stat $ 50;

gp =8;

groupvariable="Patients undergoing RBC tx";
variable = "No. of red-cell units per transfused patient Median (q1,q3)";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;



/* volume of rbc */

data rbc_volume; 
set enrolled_rbc;

vol_tx_by_wt= (rbcVolumeTransfused /(BodyWeight/1000));

run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data rbc_volume; 
set rbc_volume; 
output; 
center = 0; 
output; 
run; 





proc means data = rbc_volume fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class  center ;

				var vol_tx_by_wt;
				output out = volume_sum_by_center_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data volume_sum_by_center_summary2; set volume_sum_by_center_summary;

if center =.  then delete;


run;


data ReportTable_volume( keep=gp groupvariable variable center stat); 
set volume_sum_by_center_summary2;


length stat $ 50;

gp =9;

groupvariable="Patients undergoing RBC tx";
variable = "Volume of red-cell units per transfused patient  - ml /kg Median (q1,q3)";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;


/* first rbc tx */


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled_rbc2; 
set enrolled_rbc; 
output; 
center = 0; 
output; 
run; 

proc sql;

create table first_tx as
select Min(DateTransfusion) format=MMDDYY9. as MinDateTransfusion, id, center,DateOfBirth
from  enrolled_rbc2
group by id, center,DateOfBirth;


quit;

proc sort data=enrolled_rbc2; by  center id DateTransfusion;run;



data first_tx; set first_tx;


daysdiff = int( MinDateTransfusion - DateOfBirth);
run;



proc means data = first_tx fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class  center ;

				var daysdiff;
				output out = time_tx_from_dob_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data time_tx_from_dob_summary2; set time_tx_from_dob_summary;

if center =.  then delete;


run;


data ReportTable_firstTX( keep=gp groupvariable variable center stat); 
set time_tx_from_dob_summary2;


length stat $ 50;

gp =10;

groupvariable="First red-cell transfusion";
variable = "Time from Birth to first Tx - days Median (q1,q3)";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;


/* HB Level */
data xx;
set enrolled_rbc2 ;
by  center id DateTransfusion;


if first.id then counter=0; counter+1;
if LAST.id then return;


run;


proc means data = xx fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. and counter=1;
					class  center ; 

				var hb;
				output out = hb_out sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data hb_out2; set hb_out;

if center =.  then delete;


run;


data ReportTable_hb( keep=gp groupvariable variable center stat); 
set hb_out2;


length stat $ 50;

gp =11;

groupvariable="First red-cell transfusion";
variable = "Hemoglobin level BEFORE first Tx- g/dl - days Median (q1,q3)";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;



proc means data = xx fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. and counter=2;
					class  center ; 

				var hb;
				output out = hb_out2 sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data hb_out2; set hb_out2;

if center =.  then delete;


run;


data ReportTable_hb2( keep=gp groupvariable variable center stat); 
set hb_out2;


length stat $ 50;

gp =12;

groupvariable="First red-cell transfusion";
variable = "Hemoglobin level AFTER first Tx- g/dl - days Median (q1,q3)";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;


/* All rbc -tx */

proc sql;

create table xx as
select count(*) as TotalTx, center


from enrolled_rbc2
where dfseq <> .
group by center;
quit;


proc means data = xx fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. ;
					class  center ; 

				var TotalTx;
				output out = TotalTx2 sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data TotalTx2; set TotalTx2;

if center =.  then delete;


run;





data ReportTable_TotalTx2( keep=gp groupvariable variable center stat); 
set TotalTx2;


length stat $ 50;

gp =13;

groupvariable="All red-cell transfusion";
variable = "Total no. of transfusions ";
stat= compress( put(sum,5.0))   ;


 
run;



/* Unit Age */


proc means data = enrolled_rbc2 fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. ;
					class  center ; 

				var UnitAge;
				output out = RBCAge sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data RBCAge2; set RBCAge;

if center =.  then delete;


run;


data ReportTable_RBCAge2( keep=gp groupvariable variable center stat); 
set RBCAge2;


length stat $ 50;

gp =14;

groupvariable="All red-cell transfusion";
variable = "Age of RBC Unit - days ";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;



/* Lowest hb level in Hosp */


data Med_review; set cmv.Med_review;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


proc sql;

create table lowHb as
select id, center, hb , DateTransfusion  as eventdate , "tx" as type from enrolled_rbc2
union
select id, center,hb , HbDate as eventdate , "med" as type from Med_review;


create table lowhb2 as
select min(hb) as LowHb , id, center
from lowhb
group by id, center;


quit;



proc means data = lowhb2 fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>. ;
					class  center ; 

				var LowHb;
				output out = LowHb_out sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data LowHb_out2; set LowHb_out;

if center =.  then delete;


run;


data ReportTable_LowHb_out2( keep=gp groupvariable variable center stat); 
set RBCAge2;


length stat $ 50;

gp =3;

groupvariable="All Patients";
variable = "Lowest hemoglobin level in NICU - g/dl Median (q1,q3) ";
stat= compress( put(median,5.1))   || " [ " || compress(put(q1,5.1))  || " , "  || compress(put(q3,5.1)) || " ]";


 
run;



/* final report table*/




proc sql;

create table ReportTable_Final as
select gp , groupvariable, variable, center, stat from  ReportTable_tx

union
select gp , groupvariable, variable, center, stat from  ReportTable_donor_no_rbc

union
select gp , groupvariable, variable, center, stat from  ReportTable_donor

union
select gp , groupvariable, variable, center, stat from  ReportTable_volume

union

select gp , groupvariable, variable, center, stat from ReportTable_firstTX

union

select gp , groupvariable, variable, center, stat from ReportTable_hb

union

select gp , groupvariable, variable, center, stat from ReportTable_hb2

union

select gp , groupvariable, variable, center, stat from ReportTable_TotalTx2
union

select gp , groupvariable, variable, center, stat from ReportTable_RBCAge2

union

select gp , groupvariable, variable, center, stat from   ReportTable_LowHb_out2

order by gp
;

quit;



data enrolled; set enrolled;

output; 
center = 0; 
output; 
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
  select  ( compress( centerXX) || '_ ( N = ' || compress(put(Count(*),2.)) || ' )' ) as total, center,centerXX

  from enrolled

group by center,centerXX;
quit;






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


options orientation=landscape;
ods rtf   file = "&output./annual/&rbc_tx_summary_file2._rbc_tx_summary2.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&rbc_tx_summary_title2 RED-Cell Transfusions  ";



title  justify = center "&rbc_tx_summary_title2  RED-Cell Transfusions   ";


proc report data=ReportTable_Final nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column     groupvariable  variable    center ,  (stat  )  dummy;



define groupvariable/ group order=data    " " ;



define variable/ group  order=data   Left    " Variable " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  format=cvar.;

define stat/center   width=20   style(column) = [just=center cellwidth=2in] "  "  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


*break after  groupvariable/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after groupvariable;
     line ' ';
  endcomp;



format center center.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;



proc sql;

drop table enrolled;


create table rbc_neeta3 as
select count(id) as lbwi_count, center, Total_Lbwi_Count, "Any tx - no. of patients(%)" as variable , 1 as gp, "Patients undergoing RBC tx" as groupvariable
from rbc_count2 
group by center,Total_Lbwi_Count;
quit;


