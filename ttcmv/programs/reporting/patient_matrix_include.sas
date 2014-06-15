
***************************
*program:	patient_matrix_include.sas
*purpose: create table monthly report med review section completness report for monthly report
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: July 14,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;




*%include "&include./monthly_toc.sas";

data /*cmv.snap2 */ snap2; set cmv.snap2; 

total_snap2=4;  this_snap2_gt25=0;
this_snap2=0; total_snap2=3;

if MeanBP eq 99 or MeanBP eq 999 then  this_snap2=this_snap2+1;  
if  LowestTemp eq 99 or LowestTemp eq 999 then this_snap2=this_snap2+1;
if  seizures eq 99 or seizures eq 999 then this_snap2=this_snap2+1;
if  UOP eq 99 or UOP eq 999 then this_snap2=this_snap2+1;

if BloodCollect eq 1 and (LowPh eq 99 or LowPh eq 999) then this_snap2=this_snap2+1;
if BloodCollect eq 1 and (PO2Fo2Ratio eq 99 or PO2Fo2Ratio eq 999) then this_snap2=this_snap2+1;


if BloodCollect eq 1 then total_snap2=6;

this_snap2_pct=this_snap2/total_snap2*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap2_nonmiss=compress(this_snap2) || "/" || compress(total_snap2);


if this_snap2_pct >=25 then this_snap2_gt25 =1;


run;

/* snap missing */

data /*cmv.snap*/ snap; set cmv.snap; 

total_snap=39;  this_snap_gt25=0;
this_snap=0; 

if MaxMeanBP eq 99 or MaxMeanBP eq 999 then  this_snap=this_snap+1;  
if MinMeanBP eq 99 or MinMeanBP eq 999 then  this_snap=this_snap+1;
if MaxHeartRate eq 99 or MaxHeartRate eq 999 then  this_snap=this_snap+1;
if MinHeartRate eq 99 or MinHeartRate eq 999 then  this_snap=this_snap+1;
if RespRate eq 99 or RespRate eq 999 then  this_snap=this_snap+1;
if Temp eq 99 or Temp eq 999 then  this_snap=this_snap+1;
if Seizures eq 99 or Seizures eq 999 then  this_snap=this_snap+1;
if Apnea eq 99 or Apnea eq 999 then  this_snap=this_snap+1;
if StoolGuaic eq 99 or StoolGuaic eq 999 then  this_snap=this_snap+1;
if po2missing eq 1  then  this_snap=this_snap+1;
if PCO2 eq 99 or PCO2 eq 999 then  this_snap=this_snap+1;
if fio2missing eq 1  then  this_snap=this_snap+1;
if OxyIndex eq 99 or OxyIndex eq 999 then  this_snap=this_snap+1;
if MaxHct eq 99 or MaxHct eq 999 then  this_snap=this_snap+1;
if MinHct eq 99 or MinHct eq 999 then  this_snap=this_snap+1;
if WBC eq 99 or WBC eq 999 then  this_snap=this_snap+1;
if WBC eq 99 or WBC eq 999 then  this_snap=this_snap+1;

if ProMyoMissing eq 1  then  this_snap=this_snap+1;
if MyelocyteMissing eq 1  then  this_snap=this_snap+1;
if MetamyeMissing eq 1  then  this_snap=this_snap+1;
if BandsMissing eq 1  then  this_snap=this_snap+1;
if TotalNeutroMissing eq 1  then  this_snap=this_snap+1;

if AbsNeutro eq 99 or AbsNeutro eq 999 then  this_snap=this_snap+1;
if Platelets eq 99 or Platelets eq 999 then  this_snap=this_snap+1;
if BUN eq 99 or BUN eq 999 then  this_snap=this_snap+1;
if Creatinine eq 99 or Creatinine eq 999 then  this_snap=this_snap+1;
if UOP eq 99 or UOP eq 999 then  this_snap=this_snap+1;

if IndirectBili eq 99 or IndirectBili eq 999 then  this_snap=this_snap+1;
if DirectBili eq 99 or DirectBili eq 999 then  this_snap=this_snap+1;
if MaxSodium eq 99 or MaxSodium eq 999 then  this_snap=this_snap+1;
if MinSodium eq 99 or MinSodium eq 999 then  this_snap=this_snap+1;
if MaxPotassium eq 99 or MaxPotassium eq 999 then  this_snap=this_snap+1;
if MinPotassium eq 99 or MinPotassium eq 999 then  this_snap=this_snap+1;

if (MaxIonizedCa eq 99 or MaxIonizedCa eq 999) and (MaxTotalCa eq 99 or MaxTotalCa eq 999) then  do; this_snap=this_snap+1;  var33=99; end;
if (MinIonizedCa eq 99 or MinIonizedCa eq 999) and (MinTotalCa eq 99 or MinTotalCa eq 999)  then do; this_snap=this_snap+1;var34=99; end;

*if MaxTotalCa eq 99 or MaxTotalCa eq 999 then  this_snap=this_snap+1;
*if MinTotalCa eq 99 or MinTotalCa eq 999 then  this_snap=this_snap+1;

if MaxGlucose eq 99 or MaxGlucose eq 999 then  this_snap=this_snap+1;
if MinGlucose eq 99 or MinGlucose eq 999 then  this_snap=this_snap+1;

if MaxBicarbonate eq 99 or MaxBicarbonate eq 999 then  this_snap=this_snap+1;
if MinBicarbonate eq 99 or MinBicarbonate eq 999 then  this_snap=this_snap+1;

if SerumPH eq 99 or SerumPH eq 999 then  this_snap=this_snap+1;


this_snap_pct=this_snap/total_snap*100;

pipe="|";
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);

snap_nonmiss=compress(this_snap) || "/" || compress(total_snap);


if this_snap_pct >=25 then this_snap_gt25 =1;


run;

proc sql;
create table summary1 as
select count(*) as count, "Anthropometric section" as form , center  from cmv.Med_review where this_anthro_gt25=1 group by center
union
select count(*) as count, "Lab section" as form ,center  from cmv.Med_review where this_chem_gt25=1 group by center
union

select count(*) as count, "Anthropometric section" as form , 0 as center  from cmv.Med_review where this_anthro_gt25=1 
union

select count(*) as count, "Lab section" as form ,0 as  center   from cmv.Med_review where this_chem_gt25=1 


;



create table summary2 as
select count(*) as total, "Anthropometric section" as form , center  from cmv.Med_review where this_anthro_gt25 In (1,0) group by center
union
select count(*) as total, "Lab section" as form ,center  from cmv.Med_review where this_chem_gt25 In (1,0) group by center
union

select count(*) as total, "Anthropometric section" as form , 0 as center  from cmv.Med_review where this_anthro_gt25 In (1,0) 
union

select count(*) as total, "Lab section" as form ,0 as  center   from cmv.Med_review where this_chem_gt25 In (1,0)

; 



create table snap2_missing (

form char(100),
center num
);
insert into snap2_missing (form, center)
values ("SNAP2", 0 );
insert into snap2_missing (form, center)
values ("SNAP2", 1 );
insert into snap2_missing (form, center)
values ("SNAP2", 2 );
insert into snap2_missing (form, center)
values ("SNAP2", 3 );
insert into snap2_missing (form, center)
values ("SNAP", 0 );
insert into snap2_missing (form, center)
values ("SNAP", 1 );
insert into snap2_missing (form, center)
values ("SNAP", 2 );
insert into snap2_missing (form, center)
values ("SNAP", 3 );


create table snap2_missing_count as
select count(*) as count, "SNAP2" as form ,0 as  center   from snap2 where this_snap2_gt25=1 
union
select count(*) as count, "SNAP2" as form ,center  from snap2 where this_snap2_gt25=1 group by center
union
select count(*) as count, "SNAP" as form ,0 as  center   from snap where this_snap_gt25=1 
union
select count(*) as count, "SNAP" as form ,center  from snap where this_snap_gt25=1 group by center

;

create table snap2_missing as
select a.form, a.center, b.count 
from  snap2_missing as a left join snap2_missing_count as b on a.center=b.center and a.form=b.form;

create table snap2_missing_total as

select count(*) as total, "SNAP2" as form ,0 as center  from snap2 where this_snap2_gt25 In (1,0) 
union
select count(*) as total, "SNAP2" as form , center  from snap2 where this_snap2_gt25 In (1,0) group by center
union
select count(*) as total, "SNAP" as form ,0 as center  from snap where this_snap_gt25 In (1,0) 
union
select count(*) as total, "SNAP" as form , center  from snap where this_snap_gt25 In (1,0) group by center

;

create table snap2_missing as
select a.form, a.center,a.count, b.total 
from  snap2_missing as a left join snap2_missing_total as b on a.center=b.center and a.form=b.form
order by form,center;

create table summary as
select a.*,b.*
from summary1 as a , summary2 as b
where a.center=b.center and a.form=b.form;

drop table summary1; drop table summary2;
drop table snap2_missing_count; drop table snap2_missing_total;
quit;


data summary (keep =center form stat  pipe) ; set summary;
*stat = Trim(Left(count)) || "/" || Trim(Left(total)) || " ( " || Trim(Left(put((count/total)*100,10.))) || " )";
stat =  Trim(Left(put(((total-count)/total)*100,10.))) ;
pipe="|";
run;


data snap2_missing (keep =center form stat2  pipe) ; set snap2_missing;
if count =. then count=0;
 
*stat = Trim(Left(count)) || "/" || Trim(Left(total)) || " ( " || Trim(Left(put((count/total)*100,10.))) || " )";
stat2 = Trim(Left(put(((count)/total)*100,10.))) ;
pipe="|";
run; 


/*
proc means data = cmv.Med_review fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class  center ;

				var this_anthro;
				output out = this_anthro_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data this_anthro_summary2; set this_anthro_summary;

if center =. then center=0;


run;


proc means data = cmv.Med_review fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class  center ;

				var this_chem;
				output out = this_chem_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data this_chem_summary2; set this_chem_summary;

if center =. then center=0;
run;

proc sql;

create table summary as
select * ,"18" as total, "Lab section" as form from this_chem_summary2

union
select * , "3" as total, "Anthropometric section" as form from this_anthro_summary2;

drop table this_anthro_summary2; drop table this_chem_summary2;

drop table this_anthro_summary; drop table this_chem_summary;
quit;
*/

