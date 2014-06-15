* NAT results  summary ;
/* ****Summary of NAT on MOC, LBWI , Donors and Donor characteristics ************* */

%include "&include./annual_toc.sas";

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


where (Enrollmentdate is not null or iseligible = 1) and a.id not in (3003411,3003421);

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
left join
cmv.endofstudy as b
on a.id=b.id;

create table LBwi_blood_nat_result as
select a.id, b.*
from cmv.valid_ids as a
left join
cmv.LBwi_blood_nat_result as b
on a.id=b.id;

update LBwi_blood_nat_result 
set dfseq =1 where dfseq is null;



create table Moc_nat as
select a.id, b.*
from cmv.valid_ids as a
left join
cmv.Moc_nat as b
on a.id=b.id;

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data Moc_nat; set Moc_nat; 
id2 = left(trim(id));
twin_index= input(substr(id2, 6, 1),1.); 



run;

proc sql;
update Moc_nat
set dfseq =1 
where dfseq is null and twin_index =1;

quit;

data blood; set LBwi_blood_nat_result; 

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;





**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data blood; 
set blood; 
output; 
center = 0; treat=0; 
output; 
run;

data urine; set cmv.LBwi_urine_nat_result; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data urine; 
set urine; 
output; 
center = 0; treat=0; 
output; 
run; 


data moc; set Moc_nat; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data moc; 
set moc; 
output; 
center = 0; treat=0; 
output; 
run; 
 


/* ******   MOC seronegative counting * *****/

proc sql;
create table moc_sero as
select a.*, b.*
from enrolled as a
left join
cmv.Moc_sero as b
on a.id =b.id where b.DFSEQ =1 and b.combotestresult=1;


quit;


data moc_sero; set moc_sero;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

proc sql;
select compress(put(count (*),3.0)) into :m0  from moc_sero ;
select compress(put(count (*),3.0)) into :m1  from moc_sero where center=1;
select compress(put(count (*),3.0)) into :m2  from moc_sero where center=2;
select compress(put(count (*),3.0)) into :m3  from moc_sero where center=3;
quit;

/*    Blood Unit * *****/

data bu; set cmv.Plate_003_bu; 
*id2 = left(trim(id));
*center = input(substr(id2, 1, 1),1.);
center=8; 
visitlist=dfseq; treat=center;
if  DCCUnitid = 80000031 then delete;
run;


proc sql;

create table donor as
select Distinct(DonorUnitId)  as DonorUnitId ,id , "RBC" as source from cmv.plate_031
union all
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Plt" as source from cmv.plate_033
union all
select Distinct(DonorUnitId)  as DonorUnitId ,id , "FFP" as source from cmv.plate_035
union all
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Cry" as source from cmv.plate_037
/*union
select Distinct(DonorUnitId)  as DonorUnitId ,id , "Gran" as source from cmv.plate_039
*/
;

create table tx_patient_ids as
select distinct(a.id) as id , studyleftdate, reason 
from 
donor as a 
right join 
( select id, studyleftdate, reason from cmv.endofstudy where reason in (1,2,3,6)) as b
on a.id=b.id ;

create table tx_patient_ids as
select * from tx_patient_ids where id is not null;


create table donor as
select a.*,b.id as bu_id 
from donor as a right join
tx_patient_ids as b
on a.id=b.id;



run;

quit;

data donor; set donor; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
treat=center; visitlist=1; dfseq =1;
run;




proc sql;
create table donor as
select Distinct(DonorUnitId)  as DonorUnitId,center,treat,visitlist,dfseq
from donor;


create table donor1 as
select a.*, b.DCCUnitid as DCCUnitid, b.DonorUnitId as DonorUnitId_tracking,b.UnitResult
from donor as a left join
( select * from bu  )as b
on a.donorunitid =b.donorunitid;


quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data donor1; 
set donor1; 
output; 
center = 0; treat=0; 
output; 
run; 



data bu; set cmv.Plate_003_bu; 
*id2 = left(trim(id));
*center = input(substr(id2, 1, 1),1.);
center=8; 
visitlist=dfseq; treat=center;
run;




proc sql;
create table bu_wbc1 as
select a.*, b.*
from donor as a left join
( select * from cmv.Plate_002_bu where dccunitid <> 90000031 )as b
on a.donorunitid =b.donorunitid;

quit;

data bu_wbc1; set bu_wbc1;

treat=center; 
/*visitlist=BloodUnitType; 
dfseq =BloodUnitType;
*/
visitlist=0;dfseq=0;

if wbc_result1 = . then wbc_result1=99;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data bu_wbc1; 
set bu_wbc1; 
output; 
center = 0; treat=0; 
output; 
run; 

/* *******************Blood donor characteristics *******   */

proc sql;
create table bu_track as
select a.*, b.*
from donor as a left join
( select * from cmv.Plate_001_bu where dccunitid not in (  20000032 ) ) as b
on a.donorunitid =b.donorunitid;



quit;



data bu_track; set bu_track;

treat=center; 
/*visitlist=BloodUnitType; 
dfseq =BloodUnitType;
*/
visitlist=0;dfseq=0;

if ABOGroup = . then ABOGroup=99;
if RHGroup = . then RHGroup=99;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data bu_track; 
set bu_track; 
output; 
center = 0; treat=0; 
output; 
run; 



/* *******************Formats *******   */
proc format;

value rh
1='Negative'
2='Positive'
;


value abo
1='A'
2='B'
3='AB'
4='O'
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

value DFSEQ_MOC
1='DOB'
21='DOL 21'
40='DOL 40'
60='DOL 60'
63='EOS if CMV- at Enrollment'
65='Tx 7 days before Dx'
85='Unscheduled'
91-96='Unscheduled'
;

value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
8='BU'
;

value treat 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
8='Overall'
;


value NATTestResult 
99='Missing'
1='Not detected'
2='Low positive_( < 300 copies /ml)'
3='Positive_( >= 300 copies /ml)'
4='Indeterminate'
.='Pending'
;


value BloodUnitType
0='All types'
1='RBC'
2='FFP'
3='Granulocyte'
4='Platelet'
5='Granulocyte';


value wbc
1='Not detected (< 0.2 wbc)'
2='Detected (>=0.2 wbc)'
99='Missing'
;
run;

%macro getstat ( data=, out=, var=,f=, varlabel=,gp=,subheader=);

%if &subheader=0 %then %do;
data x; set &data; if &var=99 or &var=999 then delete; run;

proc freq data=x;where &var not in (99 ,999);
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc freq data=x;
where &var not in (99 ,999);
tables visitlist*treat/list  out = outpatients;;
run;

proc sql;
create table temp as

select a.count as PatientFreq, a.visitlist,a.treat,b.count as groupFreq, b.&var as category, "&varlabel"  as variable2 ,
put(&var,&f) as category2, &gp as group
from outpatients as a right join
outfreq_&var as b
on a.visitlist=b.visitlist and a.treat=b.treat

order by treat, visitlist,&var ;
quit;



run;

data temp; length variable $ 100; length var_name $ 100; set temp;
variable="&varlabel"; 
class_descript = put(category , &f);
var_name="&var";


run;

%if &gp=1 %then %do;
data AllVarFreq; set temp; group=&gp; subheader=&subheader;class_descript = put(category , &f);var_name="&var";

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq , group , subheader ,class_descript ,var_name from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq ,group, &subheader ,class_descript, var_name  from temp;

drop table temp;  drop table outfreq_&var; drop table x; drop table outpatients;

quit;%end;

%end; * endi of top if ;
%if &subheader eq 1 %then %do;
proc sql;
insert into AllVarFreq(variable, group,category,subheader)
values ("&varlabel",&gp,0, 1);

quit;

%end;


%mend getstat;
%getstat ( data=blood, out=, var=NATTestResult,f=NATTestResult., varlabel=Blood NAT Test Result,gp=1,subheader=0);

%getstat( data=urine, out=, var=UrineTestResult,f=NATTestResult., varlabel=Urine NAT Test Result,gp=2,subheader=0);

%getstat ( data=moc, out=, var=NATTestResult,f=NATTestResult., varlabel=MOC NAT Test Result,gp=3,subheader=0);
%getstat ( data=donor1, out=, var=UnitResult,f=NATTestResult., varlabel=Parent Unit NAT Result,gp=4,subheader=0);
%getstat( data=bu_wbc1, out=, var=wbc_result1,f=wbc., varlabel=Parent Unit WBC Result,gp=5,subheader=0);

%getstat ( data=bu_track, out=, var=ABOGroup,f=abo., varlabel=Blood Group,gp=6,subheader=0);
%getstat ( data=bu_track, out=, var=RHGroup,f=rh., varlabel=RH Group,gp=7,subheader=0);


proc sql;
select id into :blood_pos_id from blood where NATTestResult=2 and center=0;
select id  into :moc_pos_id from moc where NATTestResult is null  and center=0;
select id  into :urine_pos_id from urine where UrineTestResult is null and center=0;

select compress(put(count(distinct(DonorUnitId)),3.0 )) into :donor_count from donor1 where  center=0;

select compress(put(count (*),3.0)) into :total0  from cmv.valid_ids ;
quit;

data AllVarFreq ; set AllVarFreq; 

if category=. then category=99;

if variable eq 'MOC NAT Test Result' and treat =0 and visitlist=63 then PatientFreq=&m0;
if variable eq 'MOC NAT Test Result' and treat =1 and visitlist=63  then PatientFreq=&m1;
if variable eq 'MOC NAT Test Result' and treat =2 and visitlist=63  then PatientFreq=&m2;
if variable eq 'MOC NAT Test Result' and treat =3 and visitlist=63  then PatientFreq=&m3;

percent = round((groupFreq/PatientFreq)*100,.1);
pipe='|';

stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || "(" || compress(Left(trim(percent)))|| "%)" ;
stat2=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || " " || compress(Left(trim(percent)))|| "%" ;


run;


proc sql;
create table AllVarFreq as
select * from AllVarFreq
order by  variable , treat, visitlist, category asc;
quit;


options nodate orientation=portrait;
ods rtf   file = "&output./annual/&nat_result_summary_file.nat_result_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&nat_result_summary_title a: LBWI NAT Result ( (n=&total0))";

title  justify = center "&nat_result_summary_title a: LBWI NAT Result  ( (n=&total0)) ";

footnote "LBWI id with Low positive result : &blood_pos_id";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Blood NAT Test Result' 'Urine NAT Test Result'  )and treat=0 and category < 99;


column  variable  visitlist      category2  stat dummy ;


define variable / group order=data center   width=15   style(column)=[just=left cellwidth=1.5in] '' ;
define visitlist /  group order=data left      style(column)=[just=left cellwidth=1.5in]  'DOL ';

define category2 /group   center order=internal    style(column)=[just=center cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;


format visitlist dfseq.;

compute after variable;
     line ' ';
  endcomp;


run;

/*


ods noproctitle proclabel "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results";

title  justify = center "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results (n=&total0)";
footnote "LBWI id with Low positive result : &blood_pos_id";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Blood NAT Test Result' and treat=0 and category < 99;

column     treat  visitlist category ,(stat) dummy ;



define treat / group order=data center      style(column)=[just=left cellwidth=.7in] 'Site' ;
define visitlist /  group order=data left      style(column)=[just=left cellwidth=1.5in]  'DOL ';


define category /across   center order=internal    style(column)=[just=left cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;

ods noproctitle proclabel "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results ";

title  justify = center "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Urine NAT Test Result' and treat=0 and category < 99;

column       treat  visitlist category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1.5in]  'DOL ';


define category /across   center order=internal width=15   style(column)=[just=left cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;
*/

ods noproctitle proclabel "&nat_result_summary_title c: MOC Serum CMV NAT results";

title  justify = center "&nat_result_summary_title c: MOC Serum CMV NAT results";

*footnote "LBWI id with MOC missing data : &moc_pos_id";
footnote "";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='MOC NAT Test Result' and treat=0 and category < 99;

column    treat  visitlist category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1.5in]  'DOL ';


define category /across   center order=internal width=15   style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq_MOC.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;
/*
ods noproctitle proclabel "&nat_result_summary_title d: CMV NAT results for Donor Units for LBWI who completed study ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title d: CMV NAT results for Donor Units for LBWI who completed study ( Donors=&donor_count)";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Unit Test Result' and treat=0 ;

column      treat   category ,(stat) dummy ;

define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;



define category /across   center order=internal width=15   style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;

ods noproctitle proclabel "&nat_result_summary_title e: Residual WBC results for Donor Units ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title e: Residual WBC results for Donor Units ( Donors=&donor_count)";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Unit WBC Result' )and treat=0 ;

column       treat  visitlist category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1in]  'Blood Donor Unit Type ';


define category /across   center order=internal    style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1in]  'n/N (%) ' ;;
define dummy/ noprint;


format category wbc.;
format visitlist BloodUnitType.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;
*/

ods noproctitle proclabel "&nat_result_summary_title c: Donor Unit Characteristics ( Donors=&donor_count)";

title  justify = center "&nat_result_summary_title c: Donor Unit Characteristics ( Donors=&donor_count) ";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable IN ('Parent Unit Test Result' 'Parent Unit WBC Result','Blood Group' , 'RH Group' )and treat=0 ;

column  variable        category2  stat dummy ;


define variable / group order=data center   width=15   style(column)=[just=left cellwidth=1.5in] 'Site' ;



define category2 /group   center order=internal    style(column)=[just=center cellwidth=1.5in] '' ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;



*format visitlist BloodUnitType.;
*format treat  treat.;


compute after variable;
     line ' ';
  endcomp;


run;


ods rtf close;
quit;

