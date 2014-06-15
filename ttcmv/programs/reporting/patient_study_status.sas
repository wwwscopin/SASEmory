/*libname cmv "/ttcmv/sas/data/freeze2011.03.09";
*/



%include "&include./monthly_toc.sas";

proc sql;


/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id

where (enrollmentdate is not null  )and  a.id not in (3003411,3003421);

*/



create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

quit;


data enrolled; set enrolled;where id <> .;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

*********************;
proc sql;


select compress(put(count (*),3.0)) into :total0  from enrolled ;
select compress(put(count (*),2.0)) into :total1  from enrolled  where center=1;
select compress(put(count (*),2.0)) into :total2  from enrolled  where center=2;
select compress(put(count (*),2.0)) into :total3  from enrolled  where center=3;


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
left join
( select id from cmv.endofstudy where reason In (1,2,3,6) ) as b
on a.id=b.id; 



quit;






proc format ;

 

value DFSEQ
1='Enrollment'
2='DOL 1'
;
value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;


value status
1='Completed Study'
0='On Study'
3='MOC/LBWI withdrawn'
;
run;

proc sql;

create table studystatus as
select a.*, b.StudyLeftDate,b.reason
from enrolled as a 
left join cmv.endofstudy as b
on a.id=b.id 

;

create table withdrawn as
select id , reason from cmv.endofstudy where reason In (4,5);

quit;


data studystatus; set studystatus;

status=99;
if  StudyLeftDate <> . and reason IN (1,2) then status=1;/* completed */
else if StudyLeftDate = . and reason eq . then status=0;/* on study */
else if StudyLeftDate <> . and reason In  (4,5) then status=3;/* withdrawn */
else if  reason In  (6) then status=4;/* death */
else if StudyLeftDate <> . and reason In  (3) then status=5;/* transferred to non-study affiliated hospital */
run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data studystatus; 
set studystatus; 
output; 
center = 0; 
output; 
run; 


data  withdrawn; set  withdrawn;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data withdrawn; 
set withdrawn; 
output; 
center = 0; 
output; 
run; 



/*
data cmv.study_status; 
set studystatus; 
output; 
center = 0; 
output; 
run; 


*/



proc freq data=studystatus; tables center*status/ list out=status_freq; format status status.;run;


proc sql;

create table temp as
select count(*) as total, center
from StudyStatus
group by center;

create table status_freq as
select a.*, b.total
from status_freq as a
left join temp as b
on a.center =b.center;

select compress(put(count (*),3.0)) into :dx0  from studystatus where reason in (1,2,3,6) and center=0;

select compress(put(count (*),3.0)) into :dx1  from studystatus where reason in (1,2,3,6) and center=1;
select compress(put(count (*),3.0)) into :dx2  from studystatus where reason in (1,2,3,6) and center=2;
select compress(put(count (*),3.0)) into :dx3  from studystatus where reason in (1,2,3,6) and center=3;

quit;


data status_freq;
set status_freq;

percent_center= (count/total)*100;


if status  eq 1 or status  eq 0  then do;
stat=   compress(Left(trim(count))) || "/"  || compress(Left(trim(total)))  || "\n( " || compress(Left(trim(put(percent_center,5.0))))|| " %)" ;
end;

else if status  In ( 3,4,5) then do;
stat=   compress(Left(trim(count)))  ;
end;


pipe ='|';
format percent_center PERCENT7.1;
run;



%include "patient_study_status_include.sas";

%include "missing_plates.sas";


/***** for third column ****************/
proc sql;
create table column3_neeta as
select distinct(id) as id from column1_neeta
union
select distinct(id)as id  from column2_neeta;

create table column3_neeta2 as
select a.id 
from column3_neeta as a inner join
( select id from cmv.endofstudy) as b 
on a.id =b.id;

quit;

data column3_neeta2; set column3_neeta2;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

proc sql;

create table column3_neeta2_1 as
select count(distinct(id)) as all_missed,  center  from column3_neeta2  group by center
union
select count(distinct(id)) as all_missed,  0 as center  from column3_neeta2
;



quit;



/**** end third column ****************/
proc sql;
create table status_freq2 as
select a.* , b.stat2
 from status_freq as a left join summary as b
on a.center=b.center ;



update status_freq2
set stat2="."
where status=0;

create table temp1 as
select center, stat as completed_stat , stat2 as crf_stat from status_freq2 where status=1;

create table temp2 as
select center, stat as on_study_stat  from status_freq2 where status=0;



create table temp3 as
select b.*, a.* from temp1 as a right join temp2 as b on a.center=b.center;



create table temp5 as
select center, stat as death_study_stat  from status_freq2 where status=4;

create table temp3 as
select b.*, a.* from temp5 as a right join temp3 as b on a.center=b.center;


create table temp6 as
select center, stat as non_study_hosp_stat  from status_freq2 where status=5;

create table temp3 as
select b.*, a.* from temp6 as a right join temp3 as b on a.center=b.center;


drop table temp1; 
drop table temp2;drop table  status_freq2;drop table  temp4;


select compress(put(count (*),3.0)) into :total0  from enrolled ;


create table temp3 as
select a.* , b.data_count
 from temp3 as a left join crf_data_problem1 as b
on a.center=b.center ;


create table temp3 as
select a.* , b.all_missed
 from temp3 as a left join column3_neeta2_1 as b
on a.center=b.center ;
quit;
/* QC problems */

data temp3; set temp3;
if center=0 then total_lbwi=&dx0;
if center=1 then total_lbwi=&dx1;
if center=2 then total_lbwi=&dx2;
if center=3 then total_lbwi=&dx3;

if data_count= . then data_count = 0;

qc_resolved= total_lbwi - data_count;
qc_resolved_pct= (qc_resolved/total_lbwi)*100;
data_count_stat = compress(Left(trim(qc_resolved))) || "/"  || compress(Left(trim(total_lbwi)))  || "\n(" || compress(Left(trim(put(qc_resolved_pct,5.0))))|| " %)" ;


all_missed_pct= ((total_lbwi - all_missed)/total_lbwi)*100;
all_missed_stat = compress(Left(trim(total_lbwi- all_missed))) || "/"  || compress(Left(trim(total_lbwi)))  || "\n(" || compress(Left(trim(put(all_missed_pct,5.0))))|| " %)" ;

run;

%let t=%eval(&total0 + 6);

ods escapechar = '\';
options nodate orientation = portrait;
ods rtf file = "&output./monthly/&patient_study_status_file.patient_study_status.rtf"  style=journal

toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&patient_study_status_title:Study Status Overall  and by Site";

	title  justify = center "&patient_study_status_title:Study Status Overall (n=&total0) and by Site ";

footnote1 "*Database was frozen as of April 5,2011. The DCC had received baseline MOC and LBWI CRFs for &total0 mother/infant pairs. ";
*footnote2 "*Four additional MOC/LBWI pairs had been enrolled as of March 31,2011 but baseline data were not available for this report ";
footnote2 "Two additional MOC/LBWI pairs were ineligible ( one LBWI was ineligible due to weight, one MOC DOL0 blood could not be collected ).";
footnote3 "Total LBWI enrolled: &total0 / MOC=";
footnote4 "LBWI who discharged/died/transferred to another hospital:XXX";
footnote5 "Total number of Txs for LBWI discharged/died/transferred to another hospital:XXX Tx/ YYY donors /zzz LBWI";

proc report /*data=status_freq2*/ data=temp3 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column center  on_study_stat  completed_stat /*with_study_stat*/ death_study_stat non_study_hosp_stat crf_stat data_count_stat all_missed_stat dummy ;

define center / group center  order=internal   style(column)=[cellwidth=1in just=center]   " Site ";

define on_study_stat/ center   order=internal   " LBWI_On Study _n/N(%) " style(column)=[cellwidth=0.8in];
define completed_stat/ center   order=internal   "LBWI_Discharged _n/N(%) " style(column)=[cellwidth=1in];
*define with_study_stat/ center   order=internal   "Number of _MOC/LBWI_Withdrawn/_Ineligible*  _n " style(column)=[cellwidth=0.8in];
define death_study_stat/ center   order=internal   "Number of _LBWI_Died  _n " style(column)=[cellwidth=1in];
define non_study_hosp_stat/ center   order=internal   "Number of _LBWI_Transferred to_Non_study_hospital  _n " style(column)=[cellwidth=1in];

define crf_stat/ center   order=internal   " All CRFs Received_n/N(%) " style(column)=[cellwidth=0.8in];
define data_count_stat/ center   order=internal   "All Data_Queries_Resolved_n/N(%) " style(column)=[cellwidth=0.8in];
define all_missed_stat/ center   order=internal   "All Data_Problems_Resolved_n/N(%) " style(column)=[cellwidth=0.8in];


define dummy/ noprint;


format center center.;

format status status.;

run;

ods rtf close;
quit;


%include "patient_study_status_include_bm_rbc_vent_tr.sas";
%include "breast_feed_monthly_neeta.sas";
%include "cmv_susp_monthly.sas";

ods escapechar = '\';
options nodate orientation = portrait;
ods rtf file = "&output./monthly/&patient_bm_etc_file.patient_bm_tr_rbc_status.rtf"  style=journal

toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&patient_bm_etc_title.a: Summary Status Update for Discharged LBWIs";

	title  justify = center "&patient_bm_etc_title.a: Summary Status Update for Discharged LBWIs (n=&dx0) ";
footnote1 "* Unexpected SAE that exclude mortality";
footnote2 "@ >5x10^6 wbc/ml";
proc report  data=status_freq2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
/*where status=1;*/

column center any_tx_stat /*breastfed_stat*/ LBWI_Blood_NAT_stat /* rbc_stat vent_stat AdvReactionStatus_stat */  transfer_stat   UnexpectAE_stat 
Unit_NAT_stat Unit_WBC_stat
dummy ;

define center / center  order=internal   style(column)=[cellwidth=0.7in just=center]   " Site ";

*define rbc_stat/ center   order=internal   " LBWI_ pRBC Tx _n/N(%) " style(column)=[cellwidth=0.9in];
define any_tx_stat/ center   order=internal   " LBWI_Any Tx _n/N(%) " style(column)=[cellwidth=0.9in];

*define breastfed_stat/ center   order=internal   " LBWI_MOC_Milk_Fed _n/N(%) " style(column)=[cellwidth=0.9in];
define  LBWI_Blood_NAT_stat/ center   order=internal   " LBWI_Blood NAT_Pos _n/N(%) " style(column)=[cellwidth=0.9in];
*define vent_stat/ center   order=internal   " LBWI_Ever on_ Mech Vent _n/N(%) " style(column)=[cellwidth=0.9in];
define transfer_stat/ center   order=internal   " LBWI_Transferred To _CHOA _n/N(%) " style(column)=[cellwidth=0.9in];

*define AdvReactionStatus_stat/ center   order=internal   " LBWI_with Tx Reaction_n/N(%) " style(column)=[cellwidth=0.9in];
define UnexpectAE_stat/ center   order=internal   " LBWI_with Unexpected SAEs _n/N(%)* " style(column)=[cellwidth=0.9in];
define Unit_NAT_stat/ center   order=internal   " Blood Product_CMV_NAT Positive _n/N(%) " style(column)=[cellwidth=0.8in];
define Unit_WBC_stat/ center   order=internal   " Blood Product_WBC Filter_Failed @ _n/N(%) " style(column)=[cellwidth=1in];

define dummy/ noprint;


format center center.;

run;

ods noproctitle proclabel "&patient_bm_etc_title.b: Feeding information for LBWI who completed study";

	title  justify = center "&patient_bm_etc_title.b: Feeding information for LBWI who completed study";
footnote1 " ";
footnote2 " ";
proc report  data=feed_sample nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column center  moc_donor_fed_total_stat not_fed_total_stat dummy ;

define center / center  order=internal   style(column)=[cellwidth=1in just=center]   " Site ";
define moc_donor_fed_total_stat/ center  order=internal   style(column)=[cellwidth=1in just=center]   "MOC and Donor Milk Fed";
define not_fed_total_stat/ center  order=internal   style(column)=[cellwidth=1in just=center]   "MOC or Donor Milk NOT fed";
define dummy/ noprint;
format center center.;
run;
ods noproctitle proclabel "&patient_bm_etc_title.c: Investigation of Suspected CMV disease in LBWI who completed study";

	title  justify = center "&patient_bm_etc_title.c: Investigation of Suspected CMV disease in LBWI who completed study";
footnote1 "*Clinical symptoms include:fever,rash,jaundice,petechiae,seizure,hepatomegaly,splenomegaly,microcephaly";
footnote2 "@Procedures include: CMV colitis, CMV retinitis, CMV pneumonitis, CMV dermatitis, CMV encephalopathy";
proc report  data=cmv_data nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column center_stat  cmv_cases dis_conf_stat dis_rule_out_stat cmv_clin_sym_stat 
cmv_lab_finding_stat cmv_image_finding_stat  cmv_proc_finding_stat cmv_nat_pos_stat 
 cmv_serology_pos_stat cmv_culture_pos_stat cmv_death_yes_stat
dummy ;
define center_stat / center  order=internal   style(column)=[cellwidth=0.5in just=center]   " Site ";

define cmv_cases / center  order=internal   style(column)=[cellwidth=0.5in just=center]   "LBWI with_CMV_Susp";
define dis_conf_stat / center  order=internal   style(column)=[cellwidth=0.6in just=center]   "LBWI CMV_Dis_Confirm";
define dis_rule_out_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI CMV_Dis_Ruled_out ";
define cmv_clin_sym_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI_with_CMV_Susp_due to_clinical_symptoms*";


define cmv_lab_finding_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI_with_CMV_Susp_due to_Lab Result";
define cmv_image_finding_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI_with_CMV_Susp_due to_Image Result";
define cmv_proc_finding_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI_with_Confirmed_Proc_Result@";


define cmv_nat_pos_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI CMV_NAT_Pos";
define cmv_serology_pos_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI CMV_Sero_Pos";
define cmv_culture_pos_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI CMV_Urine_Culture_Pos";
define cmv_death_yes_stat / center  order=internal   style(column)=[cellwidth=0.7in just=center]   "LBWI Deaths_Due to _CMV disease ";



define dummy/ noprint;

run;
ods rtf close;
quit;

