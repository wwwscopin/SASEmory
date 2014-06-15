* NAT results  summary ;

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


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
cmv.endofstudy as b
on a.id=b.id;

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data blood; set cmv.LBwi_blood_nat_result; 
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


data moc; set cmv.Moc_nat; 
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
;

quit;

data donor; set donor; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
treat=center; visitlist=1; dfseq =1;
run;




proc sql;
create table donor1 as
select a.*, b.DCCUnitid as DCCUnitid, b.DonorUnitId ,b.UnitResult
from donor as a inner join
bu as b
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





data bu_wbc; set cmv.Plate_002_bu;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
treat=center; visitlist=BloodUnitType; dfseq =BloodUnitType;
run;


proc sql;
create table bu_wbc1 as
select a.*, b.DCCUnitid as DCCUnitid, b.DonorUnitId 
from bu_wbc as a inner join
bu as b
on a.donorunitid =b.donorunitid;

quit;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data bu_wbc1; 
set bu_wbc1; 
output; 
center = 0; treat=0; 
output; 
run; 



proc format;




value DFSEQ
1='DOB'
21='DOL 21'
40='DOL 40'
60='DOL 60'
63='End of study or DOL 90'
65='If Tx 7 days before Dx'
85='Unscheduled'
91-96='Unscheduled'
;

value DFSEQ_MOC
1='DOB'
21='DOL 21'
40='DOL 40'
60='DOL 60'
63='End of study if CMV- at DOL1'
65='If Tx 7 days before Dx'
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
;


value BloodUnitType
0='All types'
1='RBC'
2='FFP'
3='Granulocyte'
4='Platelet'
5='Granulocyte';


value YN
1='Yes'
0='No';
;
run;



%macro NATsample ( data=, out=, var=,f=, varlabel=,gp=);


proc freq data=&data;

tables visitlist*treat/list  out = outpatients;;
run;

proc freq data=&data;
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc sql;
create table temp as

select a.count as PatientFreq, a.visitlist,a.treat,b.count as groupFreq, b.&var as category, "&varlabel" as variable,
put(&var,&f) as category2
from outpatients as a right join
outfreq_&var as b
on a.visitlist=b.visitlist and a.treat=b.treat

order by treat, visitlist,&var ;
quit;

data temp; set temp (rename=(&var=category));

run;

%if &gp=1 %then %do;
data AllVarFreq; set temp;

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq from temp;

drop table temp;  drop table outfreq_&var;

quit;%end;

%mend NATsample;

%NATsample ( data=blood, out=, var=NATTestResult,f=NATTestResult., varlabel=Blood NAT Test Result,gp=1);

*%NATsample ( data=urine, out=, var=UrineTestResult,f=NATTestResult., varlabel=Urine NAT Test Result,gp=2);

*%NATsample ( data=moc, out=, var=NATTestResult,f=NATTestResult., varlabel=MOC NAT Test Result,gp=3);
*%NATsample ( data=donor1, out=, var=UnitResult,f=NATTestResult., varlabel=Unit Test Result,gp=4);
*%NATsample ( data=bu_wbc1, out=, var=wbc_result1,f=YN., varlabel=Unit WBC Result,gp=5);

proc sql;
select id into :blood_pos_id from blood where NATTestResult=2 and center=0;
select id  into :moc_pos_id from moc where NATTestResult is null  and center=0;
select id  into :urine_pos_id from urine where UrineTestResult is null and center=0;
quit;

data AllVarFreq ; set AllVarFreq; 

if category=. then category=99;
percent = round((groupFreq/PatientFreq)*100,.1);
pipe='|';

stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || "(" || compress(Left(trim(percent)))|| ")" ;
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

ods noproctitle proclabel "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results";

title  justify = center "&nat_result_summary_title a: Longitudinal LBWI Serum CMV NAT results ";
footnote "LBWI id with Low positive result : &blood_pos_id";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Blood NAT Test Result';

column  /*variable*/     treat  visitlist category ,(stat) dummy ;

*define variable / group   width=15   style(column)=[just=center cellwidth=1in]  'Variable ';

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
/*
ods noproctitle proclabel "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results ";

title  justify = center "&nat_result_summary_title b: Longitudinal LBWI Urine CMV NAT results";
footnote " LBWI id for missing data: &urine_pos_id";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Urine NAT Test Result';

column  /*variable*/     treat  visitlist category ,(stat) dummy ;



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


ods noproctitle proclabel "&nat_result_summary_title c: MOC Serum CMV NAT results";

title  justify = center "&nat_result_summary_title c: MOC Serum CMV NAT results";

footnote "LBWI id with MOC missing data : &moc_pos_id";

proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='MOC NAT Test Result';

column  /*variable*/     treat  visitlist category ,(stat) dummy ;



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

ods noproctitle proclabel "&nat_result_summary_title d: CMV NAT results for Donor Units ";

title  justify = center "&nat_result_summary_title d: CMV NAT results for Donor Units ";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Unit Test Result';

column  /*variable visitlist */     treat   category ,(stat) dummy ;



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


ods noproctitle proclabel "&nat_result_summary_title e: Residual WBC results for Donor Units ";

title  justify = center "&nat_result_summary_title e: Residual WBC results for Donor Units ";

footnote "";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;

where variable='Unit WBC Result';

column  /*variable visitlist */     treat   category ,(stat) dummy ;



define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1in] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=1.5in]  'Blood Donor Unit Type ';


define category /across   center order=internal width=15   style(column)=[just=center cellwidth=1in] '' ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;


format category YN.;
format visitlist BloodUnitType.;
format treat  treat.;


compute after treat;
     line ' ';
  endcomp;


run;
*/
ods rtf close;
quit;


