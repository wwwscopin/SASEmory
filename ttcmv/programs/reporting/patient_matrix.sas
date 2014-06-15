
/********************************** */
/*
*program:	patient_matrix.sas
*purpose: create table for expected and received status report for monthly report
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: January 10,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;

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


where (Enrollmentdate is not null ) and a.id not in (3003411,3003421);
*/


create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;


quit;


data a; 
set enrolled; where id <> .;
length formname $ 100;
output; do;DFSEQ =1; Formname="LBWI_Demo"; day=1; grace=1; formid=1;end;

 
output;do;DFSEQ =1; Formname="MOC_Demo"; day=1; grace=0;formid=2;end;

output;do;DFSEQ =1; Formname="MOC_sero_result"; day=0; grace=0;formid=3;end;
output;do;DFSEQ =1; Formname="MOC_blood_collect"; day=0; grace=0;formid=4;end;


output;do;DFSEQ =1; Formname="LBWI_MRev"; day=1;grace=0; formid=5;end;
output;do;DFSEQ =4; Formname="LBWI_MRev"; day=4;grace=2; formid=6;end;

output;do;DFSEQ =7; Formname="LBWI_MRev"; day=7;grace=2;formid=7;end;

output;do;DFSEQ =14; Formname="LBWI_MRev"; day=14;grace=2;formid=8;end;
output;do;DFSEQ =21; Formname="LBWI_MRev"; day=21;grace=2;formid=9;end;
output;do;DFSEQ =28; Formname="LBWI_MRev"; day=28;grace=2;formid=10;end;
output;do;DFSEQ =40; Formname="LBWI_MRev"; day=40;grace=2;formid=11;end;
output;do;DFSEQ =60; Formname="LBWI_MRev"; day=60;grace=2;formid=12;end;

output;do;DFSEQ =1; Formname="SNAP"; day=1; grace=1;formid=13;end;

output;do;DFSEQ =4; Formname="SNAP2"; day=4; grace=0;formid=14;end;
output;do;DFSEQ =7; Formname="SNAP2"; day=7; grace=0;formid=15;end;
output;do;DFSEQ =14; Formname="SNAP2"; day=14; grace=0;formid=16;end;

output;do;DFSEQ =21; Formname="SNAP2"; day=21; grace=0;formid=17;end;
output;do;DFSEQ =28; Formname="SNAP2"; day=28; grace=0;formid=18;end;
output;do;DFSEQ =40; Formname="SNAP2"; day=40; grace=0;formid=19;end;
output;do;DFSEQ =60; Formname="SNAP2"; day=60; grace=0;formid=20;end;

output;do;DFSEQ =1; Formname="LBWI_urine_collect"; day=1; grace=0;formid=21;end;
/*output;do;DFSEQ =63; Formname="LBWI_urine_collect"; day=60; grace=5;formid=22;end;*/
output;do;DFSEQ =1; Formname="LBWI_urine_NAT_result"; day=1; grace=5;formid=23;end;
/*output;do;DFSEQ =63; Formname="LBWI_urine_NAT_result"; day=60; grace=5;formid=24;end;*/


output;do;DFSEQ =1; Formname="LBWI_blood_collect"; day=1; grace=0;formid=25;end;
output;do;DFSEQ =21; Formname="LBWI_blood_collect"; day=21; grace=0;formid=26;end;
output;do;DFSEQ =40; Formname="LBWI_blood_collect"; day=40; grace=0;formid=27;end;
output;do;DFSEQ =60; Formname="LBWI_blood_collect"; day=60; grace=0;formid=28;end;
output;do;DFSEQ =63; Formname="LBWI_blood_collect"; day=90; grace=0;formid=29;end;
/*output;do;DFSEQ =65; Formname="LBWI_blood_collect"; day=90; grace=0;formid=29;end;
*/
output;do;DFSEQ =1; Formname="LBWI_Blood_NAT_result"; day=0; grace=0;formid=30;end;
output;do;DFSEQ =21; Formname="LBWI_Blood_NAT_result"; day=21; grace=0;formid=31;end;
output;do;DFSEQ =40; Formname="LBWI_Blood_NAT_result"; day=40; grace=0;formid=32;end;
output;do;DFSEQ =60; Formname="LBWI_Blood_NAT_result"; day=60; grace=0;formid=33;end;
output;do;DFSEQ =63; Formname="LBWI_Blood_NAT_result"; day=90; grace=0;formid=34;end;

output;do;DFSEQ =165; Formname="ConMeds"; day=90; grace=0;formid=35;end;

output;do;DFSEQ =378; Formname="MechVent"; day=90; grace=0;formid=36;end;

output;do;DFSEQ =375; Formname="BreastFeed"; day=90; grace=0;formid=376;end;

output;do;DFSEQ =63; Formname="MOC_blood_eos_neg"; day=90; grace=0;formid=38;end;
output;do;DFSEQ =63; Formname="MOC_NAT_eos_neg"; day=90; grace=0;formid=39;end;
output;
run;



data a; set a; where DFSEQ <>.;run;

proc sql;

create table righttable (

id num,
DFSEQ num,
formname char(100),
DataObserved num,
formindex num
);
quit;


%macro RightTable (data= ,formname = , output=, table=, group=);
%if &group=1 %then %do; 
proc sql;



insert into righttable
select Distinct(id) as id, DFSEQ ,&formname as formname, 1 as DataObserved, &group as formindex
from &table ;

quit; %end;
%if &group >1   %then %do; 

proc sql;

create table righttable as
select id, DFSEQ , formname, DataObserved,formindex
from righttable 
union

select Distinct(id), DFSEQ ,&formname as formname, 1 as DataObserved,&group as formindex
from &table 

order by id, Formname, DFSEQ;

quit;

%end;




%mend;

%RightTable(data=righttable ,formname= "LBWI_Demo", output=output, table=cmv.LBWI_Demo, group=1); 
%RightTable(data=righttable ,formname= "MOC_Demo", output=output, table=cmv.Plate_007, group=2); 
%RightTable(data=righttable ,formname= "MOC_sero_result", output=output, table=cmv.Moc_sero, group=3);
%RightTable(data=righttable ,formname= "MOC_blood_collect", output=output, table=cmv.plate_004, group=4);
%RightTable(data=righttable ,formname= "LBWI_MRev", output=output, table=cmv.Med_review, group=5); 
%RightTable(data=righttable ,formname= "SNAP", output=output, table=cmv.snap, group=6);
%RightTable(data=righttable ,formname= "SNAP2", output=output, table=cmv.snap2, group=7);
%RightTable(data=righttable ,formname= "LBWI_urine_collect", output=output, table=cmv.LBWI_urine_collection, group=8);
%RightTable(data=righttable ,formname= "LBWI_urine_NAT_result", output=output, table=cmv.LBWI_urine_nat_result, group=9);

%RightTable(data=righttable ,formname= "LBWI_blood_collect", output=output, table=cmv.LBWI_blood_collection, group=10);

/* this was changed to table blood collection so that , result form is picked up only where blood was collected;*/
%RightTable(data=righttable ,formname= "LBWI_Blood_NAT_result", output=output, table=cmv.LBWI_blood_nat_result, group=11);


%RightTable(data=righttable ,formname= "ConMeds", output=output, table=cmv.Con_meds, group=12);
%RightTable(data=righttable ,formname= "MechVent", output=output, table=cmv.Mechvent, group=13);

%RightTable(data=righttable ,formname= "BreastFeed", output=output, table=cmv.Breastfeedlog, group=14);

%RightTable(data=righttable ,formname= "MOC_blood_eos_neg", output=output, table=cmv.Plate_023, group=15);
%RightTable(data=righttable ,formname= "MOC_NAT_eos_neg", output=output, table=cmv.MOC_nat, group=16);


data righttable;  set righttable; 
UniqueForm=formname;
if DFSEQ = 1 then DFSEQ =0;
formname= Trim(Left(formname)) || "_DOL" || Trim(Left(DFSEQ));   

if UniqueForm eq  "LBWI_blood_collect" or UniqueForm eq "LBWI_Blood_NAT_result" then UniqueForm=formname;

run;

/* set dataobserved =1 if urine NAT result obtained but Blood NAT result not received*/
proc sql;


create table dol90urine as
select a.id as id, a.dfseq , b.id as eos_id,b.NATBloodCollect
from cmv.Endofstudy as a  left join cmv.LBWI_blood_collection as b
on a.id=b.id and a.dfseq=b.dfseq where b.dfseq=63 and a.dfseq=63;


create table dol90urine as
select a.* ,b.id as urinenat_id,UrineTestResult
from dol90urine as a
left join cmv.LBWI_urine_nat_result as b
on a.id=b.id and a.dfseq=b.dfseq ;



insert into righttable (id ,DFSEQ ,formname ,DataObserved ,formindex)
select id, 63 ,  "LBWI_Blood_NAT_result_DOL63",1,11
from dol90urine
where NATBloodCollect=0 and UrineTestResult is not null;

quit;
 
data a; set a; 
UniqueForm=formname;
if DFSEQ = 1 then DFSEQ =0;
formname= Trim(Left(formname)) || "_DOL" || Trim(Left(DFSEQ));  

if UniqueForm eq  "LBWI_blood_collect" or UniqueForm eq "LBWI_Blood_NAT_result" then UniqueForm=formname;
run;


/* now merge */

proc sql;
create table all as
select a.*, b.DataObserved,b.formindex
from a 
left join righttable as b
on a.id=b.id and a.DFSEQ=b.DFSEQ and a.formname=b.formname
order by id, Formname, DFSEQ;


/* end of study */

create table all as
select a.*, b.StudyLeftDate
from all as a 
left join cmv.endofstudy as b
on a.id=b.id 
order by id, Formname, DFSEQ;


quit;

data all; set all; 
ExpectedDate=DateOfBirth;
today=today();
Expected14Date=DateOfBirth;
DataExpected=0;
format ExpectedDate date9.;
format Expected14Date date9.;
format StudyLeftDate date9.;
format today date9.;
seroneg='N';

run;




proc sql;
update all
set ExpectedDate=DateOfBirth + day + grace,
Expected14Date=DateOfBirth + day + grace+7;




quit;


proc sql;


update all
set DataExpected =1
where uniqueform =  "MechVent" and StudyLeftDate is not null and  id in (select Distinct(id) as id from cmv.Summary where VentStatus=1)
;

update all
set DataExpected =1
where uniqueform =  "BreastFeed" and StudyLeftDate is not null and  id in (select Distinct(id) as id from cmv.Summary where FeedStatus=1)
;


update all
set DataExpected =1, seroneg='Y'
where ( uniqueform =  "MOC_blood_eos_neg"  or uniqueform =  "MOC_NAT_eos_neg" ) and StudyLeftDate is not null and  
id in 
(select Distinct(id) as id from cmv.MOC_sero where ComboTestResult=1 and dfseq=1)
and dfseq=63;


quit;


data all; set all;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
twin_index=0;


if DataObserved =1 then do; DataExpected =1; DataStatus="Y";end;
else if DataObserved =. and Expected14Date >= today and ( uniqueform <>  "MOC_blood_eos_neg"  and uniqueform <>  "MOC_NAT_eos_neg" ) then do; DataExpected=99; DataStatus="-";end;

else if DataObserved =. and StudyLeftDate <> . and Expected14Date >= StudyLeftDate  and 
( uniqueform <>  "MOC_blood_eos_neg"  and uniqueform <>  "MOC_NAT_eos_neg" ) then 
do;DataExpected=99;DataStatus="-";end;
else if DataObserved =. and StudyLeftDate = . and Expected14Date < today then do;DataExpected=2;DataStatus="N";end;
run;

data all; set all;
/* if twin then , second baby MOC sero , MOC demo is not required */

if  uniqueform eq  "MOC_sero_result" or uniqueform eq "MOC_Demo" or uniqueform eq "MOC_blood_collect"   or uniqueform eq "MOC_blood_eos_neg" 
or  uniqueform eq "MOC_NAT_eos_neg" then do;   
twin_index = substr(id2, 6, 1);
end;


if  (uniqueform eq  "MOC_sero_result" or uniqueform eq "MOC_Demo" or uniqueform eq "MOC_blood_collect"   or uniqueform eq "MOC_blood_eos_neg" 
or  uniqueform eq "MOC_NAT_eos_neg" )
and id = 1002811 then do;   
twin_index = 2;
end;

if  (uniqueform eq  "MOC_sero_result" or uniqueform eq "MOC_Demo" or uniqueform eq "MOC_blood_collect"   or uniqueform eq "MOC_blood_eos_neg" 
or  uniqueform eq "MOC_NAT_eos_neg")
and id = 1002821 then do;   
twin_index = 1;
end;



if  (uniqueform eq  "MOC_sero_result"  or uniqueform eq "MOC_Demo" or uniqueform eq "MOC_blood_collect"  or uniqueform eq "MOC_blood_eos_neg"
or  uniqueform eq "MOC_NAT_eos_neg"
) and twin_index > 1  then do;  DataExpected=99; DataStatus="*" ;end;

/* con meds form is required at study completion */

if  (uniqueform eq  "ConMeds"   and StudyLeftDate <> .  )  then do;  DataExpected=1; end;
if  (uniqueform eq  "ConMeds"   and StudyLeftDate = . )  then do;  DataExpected=99; DataStatus="-" ;end;

/* these two forms are required at study completion  only if they were on it */
if  (uniqueform eq  "MechVent"   and StudyLeftDate <> . and DataExpected =1)  then do;  DataExpected=1; end;
if  (uniqueform eq  "MechVent"   and StudyLeftDate = . )  then do;  DataExpected=99; DataStatus="-"; end;


if  (uniqueform eq  "BreastFeed"   and StudyLeftDate <> . and  DataExpected =1)  then do;  DataExpected=1; end;
if  (uniqueform eq  "BreastFeed"   and StudyLeftDate = . )  then do;  DataExpected=99; DataStatus="-"; end;


if  (uniqueform eq  "MOC_blood_eos_neg"   and StudyLeftDate <> . and  seroneg eq 'Y')  then do;  DataExpected=1; end;
if  (uniqueform eq  "MOC_blood_eos_neg"   and StudyLeftDate <> . and  seroneg eq 'N')  then do;  DataExpected=99; DataStatus="-"; end;

if  (uniqueform eq  "MOC_NAT_eos_neg"   and StudyLeftDate <> . and  seroneg eq 'Y')  then do;  DataExpected=1; end;
if  (uniqueform eq  "MOC_NAT_eos_neg"   and StudyLeftDate <> . and  seroneg eq 'N')  then do;  DataExpected=99; DataStatus="-"; end;

/*if  (uniqueform eq  "MOC_blood_eos_neg"   and StudyLeftDate = . )  then do;  DataExpected=99; DataStatus="-"; end;
*/
run;





/* if DOB is missing and DataStatus=N then set it to - */


data all; set all;

if  DataStatus="N" and  DateOfBirth = . then DataStatus="-";
run;





proc sql;

create table forms as 
select Distinct(formname), DFSEQ  , formid from all order by formid ;

quit;



data forms; set forms; 
alias=Left(trim(formname)  )  ;
alias2=Left(trim(formname)) ;
alias3= Left(trim(alias)) || "=" || Left(trim(alias2));
run;


proc sql;

create table forms as
select * from forms
order by formid;
quit;

data _null_;

set work.Forms end=no_more;

call symput("form" || left(_n_), (trim(formname)));
call symput("visit" || left(_n_), (trim(DFSEQ)));
call symput("alias" || left(_n_), (trim(formname)));

if no_more then call symput ("count",_n_);

run;

%macro flattable;

%local i;
%do i=1 %to &count;
	%put TEACH&i is &&form&i;
	%put VISIT&i is &&visit&i;


%if &i = 1 %then %do;
proc sql;

create table f2 as
select a.*, b.DataStatus as &&form&i label ="&&alias&i"

from Enrolled as a,
all as b
where a.id = b.id 
 and b.formname="&&form&i" and  b.DFSEQ=&&visit&i;
quit;

%end;



%if &i >1 %then %do; 
proc sql;

create table f2 as
select a.*, b.DataStatus as &&form&i label ="&&alias&i"

from f2 as a,
all as b
where a.id = b.id 
 and b.formname="&&form&i" and  b.DFSEQ=&&visit&i;
quit;

%end;


%end;


%mend flattable;



%flattable;




data f2 ( drop=formname DFSEQ Day grace); set f2;

run;





* Below code is for count table ;
* find count;

data all; set all;
/*
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);*/

run;


proc sql;

create table Received as

select Distinct(Uniqueform) , TotalAll,Total as ReceivedCt ,pct as ReceivedPct,center

from (

select  a.TotalAll,b.Total, b.Uniqueform,  (b.total/a.totalall)*100 as pct,a.center
from
(
select count(*) as TotalAll, Uniqueform ,center
from all
where DataStatus = "Y"
group by center, Uniqueform) as a,
(

select count(*) as Total, Uniqueform,center 
from all
where DataStatus = "Y"
group by center,Uniqueform) as b

where a.Uniqueform=b.Uniqueform  and a.center=b.center
)
 order by Uniqueform;
/*
union


select "LBWI_blood_collect_DOL0" as Uniqueform , TotalAll,Total as ReceivedCt ,pct as ReceivedPct,center

from (

select  a.TotalAll,b.Total, b.Uniqueform,  (b.total/a.totalall)*100 as pct,a.center
from
(
select count(*) as TotalAll, Uniqueform ,center
from all
where DataStatus = "Y" and formname='LBWI_blood_collect_DOL0'
group by center, Uniqueform) as a,
(

select count(*) as Total, Uniqueform,center 
from all
where DataStatus = "Y" and formname='LBWI_blood_collect_DOL0'
group by center,Uniqueform) as b

where a.Uniqueform=b.Uniqueform  and a.center=b.center
)
order by Uniqueform;*/



quit;


proc sql;

create table Expected as

select Distinct(Uniqueform) , TotalAll,Total as ExpectedCt ,pct as ExpectedPct,center

from (


select  a.TotalAll,b.Total, b.Uniqueform,  (b.total/a.totalall)*100 as pct,a.center 
from
(
select count(*) as TotalAll, Uniqueform ,center
from all
where DataExpected In (1,2)
group by center,Uniqueform) as a,
(

select count(*) as Total, Uniqueform ,center
from all
where DataExpected In (1,2)
group by center,Uniqueform) as b

where a.Uniqueform=b.Uniqueform and a.center=b.center)

order by Uniqueform;

/*
Union

select "LBWI_blood_collect_DOL0" as Uniqueform, TotalAll,Total as ExpectedCt ,pct as ExpectedPct,center

from (


select  a.TotalAll,b.Total, b.Uniqueform,  (b.total/a.totalall)*100 as pct,a.center 
from
(
select count(*) as TotalAll, Uniqueform ,center
from all
where DataExpected In (1,2) and  formname='LBWI_blood_collect_DOL0'
group by center,Uniqueform) as a,
(

select count(*) as Total, Uniqueform ,center
from all
where DataExpected In (1,2) and formname='LBWI_blood_collect_DOL0'
group by center,Uniqueform) as b

where a.Uniqueform=b.Uniqueform and a.center=b.center  )

order by Uniqueform;

*/

quit;



proc sql;

create table FormCount as

select  e.Uniqueform, e.ExpectedCt,e.ExpectedPct,r.ReceivedCt,r.ReceivedPct, (r.ReceivedCt/e.ExpectedCt)*100 as Percent_Received,e.center

from expected as e
left join
received as r
on e.Uniqueform = r.Uniqueform and e.center=r.center;



quit;

data formcount; set formcount;



run;

data formcount (keep=Uniqueform expected received Percent_Received center); set formcount;
Expected = ExpectedCt;
 * Expected = Trim(Left(ExpectedCt)) ||   "(" || Trim(left(ExpectedPct)) || ")%";
 Received = ReceivedCt  ;
*Trim(Left(ReceivedCt)) ||   "(" || trim(left(Pct)) || ")%";

percent_received= compress(put(percent_received, 5.0));
*format Percent_Received percent5.0.;

run;



proc sql;

create table formcount as

select a.Uniqueform as Form, b.expected , b.received ,b.Percent_Received,a.center
from 
(
select Distinct(Uniqueform),center
from all  group by center ) as a 
left join
formcount as b
on a.Uniqueform=b.Uniqueform and a.center=b.center

;


quit;








proc sort data=formcount;by center;run;

proc sql;

create table formcount_overall as
select form , Sum(Expected) as expected, sum(Received) as received,  0 as center
from formcount
group by form;
quit;

data formcount_overall ; set formcount_overall;

percent_received= (received/expected)*100;
percent_received= compress(put(percent_received, 5.0));
*format Percent_Received percent5.0.;
label center="Center";
run;

proc sql;

create table formcount as
select center, form, expected,received, percent_received from formcount
union

select center, form, expected,received, percent_received from formcount_overall;
quit;





data formcount; set formcount;

stat=Trim(Left(Received)) ||   " / " || Trim(left(Expected)) || "( " || Trim(left(percent_received)) || " %)";
pipe = "|";
run;







%include "patient_matrix_include.sas";

proc sql;
create table formcount as
select center, form, expected,received, percent_received ,stat, pipe  from formcount
union
select center, form, .,.,., stat, pipe  from summary;
quit;





/* set order */

data formcount; set formcount;


if form eq  "MOC_Demo" then formindex= -1;
if form eq  "MOC_blood_collect" then formindex= 1;
if form eq  "MOC_sero_result" then formindex= 2;


if form eq  "MOC_blood_eos_neg" then formindex= 3;
if form eq  "MOC_NAT_eos_neg" then formindex= 4;

if form eq  "LBWI_Demo" then formindex= 5;
if form eq  "LBWI_MRev" then formindex= 6;
if form eq  "Anthropometric section" then do; formindex= 7;stat2=stat;end;
if form eq  "Lab section" then do; formindex= 8;;stat2=stat;end;

if form eq  "SNAP" then formindex= 9;
if form eq  "SNAP2" then formindex= 10;

if form eq  "LBWI_urine_collect" then formindex=11;
if form eq  "LBWI_urine_NAT_result" then formindex= 12;

if form eq  "LBWI_blood_collect" then formindex= 13;

if form eq  "LBWI_blood_collect_DOL0" then formindex= 14;
if form eq  "LBWI_Blood_NAT_result_DOL0" then formindex= 15;
if form eq  "LBWI_blood_collect_DOL21" then formindex= 16;
if form eq  "LBWI_Blood_NAT_result_DOL21" then formindex= 17;
if form eq  "LBWI_blood_collect_DOL40" then formindex= 18;
if form eq  "LBWI_Blood_NAT_result_DOL40" then formindex= 19;
if form eq  "LBWI_blood_collect_DOL60" then formindex= 20;
if form eq  "LBWI_Blood_NAT_result_DOL60" then formindex= 21;
if form eq  "LBWI_blood_collect_DOL63" then formindex= 22;
if form eq  "LBWI_Blood_NAT_result_DOL63" then formindex= 23;


if form eq  "ConMeds" then formindex= 25;
if form eq  "MechVent" then formindex= 26;


if form eq  "BreastFeed" then formindex= 27;

run;


/* these also have missed assessment code */
%include "time_window_check.sas";
%include "target_window.sas";

proc sql;
create table formcount as
select a.*,b.out_of_window
  from formcount as a left join
windowtable as b 
on a.center=b.center and a.formindex=b.formindex;

create table formcount as
select a.*,b.TotalMissed
  from formcount as a left join
missedtable2 as b 
on a.center=b.center and a.formindex=b.formindex;


quit;
/*** count snap2 missed blood collection ***/

proc sql;

select count(*)   into:snap2_0 from snap2 where  bLoodCollect=0;
select count(*)   into:snap2_1 from snap2 where center=1 and bLoodCollect=0;
select count(*)   into:snap2_2 from snap2 where center=2 and bLoodCollect=0;
select count(*)   into:snap2_3 from snap2 where center=3 and bLoodCollect=0;

update  formcount
set TotalMissed=&snap2_0
where center=0 and form = "SNAP2";

update  formcount
set TotalMissed=&snap2_1
where center=1 and form = "SNAP2";

update  formcount
set TotalMissed=&snap2_2
where center=2 and form = "SNAP2";

update  formcount
set TotalMissed=&snap2_3
where center=3 and form = "SNAP2";


quit;

data formcount; set formcount;
if out_of_window >=0 then do;
out_of_window_pct=(out_of_window/received)*100;

out_of_window_stat= compress(Left(out_of_window)) || "(" || compress(put(out_of_window_pct,5.0)) || ")";

if out_of_window_pct = 0 or out_of_window_pct=100 then 
out_of_window_stat= compress(Left(out_of_window)) || "(" || compress(put(out_of_window_pct,5.0)) || ")";


end;

if TotalMissed >=0 and received <> . then do;
TotalMissed_pct= (totalmissed/received)*100;
TotalMissed_stat= compress(Left(totalmissed)) || "(" || compress(put(totalmissed_pct,5.0)) || ")";

if TotalMissed_pct = 0 or TotalMissed_pct =100 then 
TotalMissed_stat= compress(Left(totalmissed)) || "(" || compress(put(totalmissed_pct,5.0)) || ")";
end;
run;


proc sort data=formcount; by center formindex;run;

data formcount; set formcount;
new_expected=100;
run;

proc sql;

select  (expected-TOTALMISSED) as  total into :total_expected0_0 from formcount where form='LBWI_blood_collect_DOL0' and center=0;
select  (expected-TOTALMISSED) as  total into :total_expected0_1 from formcount where form='LBWI_blood_collect_DOL0' and center=1;
select  (expected-TOTALMISSED) as  total into :total_expected0_2 from formcount where form='LBWI_blood_collect_DOL0' and center=2;
select  (expected-TOTALMISSED) as  total into :total_expected0_3 from formcount where form='LBWI_blood_collect_DOL0' and center=3;

select  (expected-TOTALMISSED) as  total into :total_expected21_0 from formcount where form='LBWI_blood_collect_DOL21' and center=0;
select  (expected-TOTALMISSED) as  total into :total_expected21_1 from formcount where form='LBWI_blood_collect_DOL21' and center=1;
select  (expected-TOTALMISSED) as  total into :total_expected21_2 from formcount where form='LBWI_blood_collect_DOL21' and center=2;
select  (expected-TOTALMISSED) as  total into :total_expected21_3 from formcount where form='LBWI_blood_collect_DOL21' and center=3;



select  (expected-TOTALMISSED) as  total into :total_expected40_0 from formcount where form='LBWI_blood_collect_DOL40'  and center=0;
select  (expected-TOTALMISSED) as  total into :total_expected40_1 from formcount where form='LBWI_blood_collect_DOL40'  and center=1;
select  (expected-TOTALMISSED) as  total into :total_expected40_2 from formcount where form='LBWI_blood_collect_DOL40'  and center=2;
select  (expected-TOTALMISSED) as  total into :total_expected40_3 from formcount where form='LBWI_blood_collect_DOL40'  and center=3;




select  (expected-TOTALMISSED) as  total into :total_expected60_0 from formcount where form='LBWI_blood_collect_DOL60' and center=0;
select  (expected-TOTALMISSED) as  total into :total_expected60_1 from formcount where form='LBWI_blood_collect_DOL60' and center=1;
select  (expected-TOTALMISSED) as  total into :total_expected60_2 from formcount where form='LBWI_blood_collect_DOL60' and center=2;
select  (expected-TOTALMISSED) as  total into :total_expected60_3 from formcount where form='LBWI_blood_collect_DOL60' and center=3;




select  (expected-TOTALMISSED) as  total into :total_expected63_0 from formcount where form='LBWI_blood_collect_DOL63' and center=0;
select  (expected-TOTALMISSED) as  total into :total_expected63_1 from formcount where form='LBWI_blood_collect_DOL63' and center=1;
select  (expected-TOTALMISSED) as  total into :total_expected63_2 from formcount where form='LBWI_blood_collect_DOL63' and center=2;
select  (expected-TOTALMISSED) as  total into :total_expected63_3 from formcount where form='LBWI_blood_collect_DOL63' and center=3;


select  (expected-TOTALMISSED) as  total into :total_nat_expected0_0 from formcount where form='LBWI_urine_collect' and center=0;
select  (expected-TOTALMISSED) as  total into :total_nat_expected0_1 from formcount where form='LBWI_urine_collect' and center=1;
select  (expected-TOTALMISSED) as  total into :total_nat_expected0_2 from formcount where form='LBWI_urine_collect' and center=2;
select  (expected-TOTALMISSED) as  total into :total_nat_expected0_3 from formcount where form='LBWI_urine_collect' and center=3;


select  (expected-TOTALMISSED) as  total into :MOC_blood_eos_neg0 from formcount where form='MOC_blood_eos_neg' and center=0;
select  (expected-TOTALMISSED) as  total into :MOC_blood_eos_neg1 from formcount where form='MOC_blood_eos_neg' and center=1;
select  (expected-TOTALMISSED) as  total into :MOC_blood_eos_neg2 from formcount where form='MOC_blood_eos_neg' and center=2;
select  (expected-TOTALMISSED) as  total into :MOC_blood_eos_neg3 from formcount where form='MOC_blood_eos_neg' and center=3;

*select  (expected-TOTALMISSED) as  total into :total_expected_moc_neg from formcount where form='MOC_blood_eos_neg';



update  formcount
set new_expected= &total_nat_expected0_0,expected = &total_nat_expected0_0
where form='LBWI_urine_NAT_result' and center=0;

update  formcount
set new_expected= &total_nat_expected0_1,expected = &total_nat_expected0_1
where form='LBWI_urine_NAT_result' and center=1;

update  formcount
set new_expected= &total_nat_expected0_2,expected = &total_nat_expected0_2
where form='LBWI_urine_NAT_result' and center=2;

update  formcount
set new_expected= &total_nat_expected0_3,expected = &total_nat_expected0_3
where form='LBWI_urine_NAT_result' and center=3;


update  formcount
set new_expected= &total_expected0_0,expected = &total_expected0_0
where form='LBWI_Blood_NAT_result_DOL0' and center=0;


update  formcount
set new_expected= &total_expected0_1,expected = &total_expected0_1
where form='LBWI_Blood_NAT_result_DOL0' and center=1;

update  formcount
set new_expected= &total_expected0_2,expected = &total_expected0_2
where form='LBWI_Blood_NAT_result_DOL0' and center=2;

update  formcount
set new_expected= &total_expected0_3,expected = &total_expected0_3
where form='LBWI_Blood_NAT_result_DOL0' and center=3;


update  formcount
set new_expected= &total_expected21_0,expected = &total_expected21_0
where form='LBWI_Blood_NAT_result_DOL21' and center=0;

update  formcount
set new_expected= &total_expected21_1,expected = &total_expected21_1
where form='LBWI_Blood_NAT_result_DOL21' and center=1;

update  formcount
set new_expected= &total_expected21_2,expected = &total_expected21_2
where form='LBWI_Blood_NAT_result_DOL21' and center=2;

update  formcount
set new_expected= &total_expected21_3,expected = &total_expected21_3
where form='LBWI_Blood_NAT_result_DOL21' and center=3;


update  formcount
set new_expected= &total_expected40_0,expected = &total_expected40_0
where form='LBWI_Blood_NAT_result_DOL40' and center=0;

update  formcount
set new_expected= &total_expected40_1,expected = &total_expected40_1
where form='LBWI_Blood_NAT_result_DOL40' and center=1;


update  formcount
set new_expected= &total_expected40_2,expected = &total_expected40_2
where form='LBWI_Blood_NAT_result_DOL40' and center=2;


update  formcount
set new_expected= &total_expected40_3,expected = &total_expected40_3
where form='LBWI_Blood_NAT_result_DOL40' and center=3;




update  formcount
set new_expected= &total_expected60_0,expected = &total_expected60_0
where form='LBWI_Blood_NAT_result_DOL60' and center=0;


update  formcount
set new_expected= &total_expected60_1,expected = &total_expected60_1
where form='LBWI_Blood_NAT_result_DOL60' and center=1;

update  formcount
set new_expected= &total_expected60_2,expected = &total_expected60_2
where form='LBWI_Blood_NAT_result_DOL60' and center=2;

update  formcount
set new_expected= &total_expected60_3,expected = &total_expected60_3
where form='LBWI_Blood_NAT_result_DOL60' and center=3;



update  formcount
set new_expected= &total_expected63_0,expected = &total_expected63_0
where form='LBWI_Blood_NAT_result_DOL63' and center=0;

update  formcount
set new_expected= &total_expected63_1,expected = &total_expected63_1
where form='LBWI_Blood_NAT_result_DOL63' and center=1;

update  formcount
set new_expected= &total_expected63_2,expected = &total_expected63_2
where form='LBWI_Blood_NAT_result_DOL63' and center=2;

update  formcount
set new_expected= &total_expected63_3,expected = &total_expected63_3
where form='LBWI_Blood_NAT_result_DOL63' and center=3;



update  formcount
set new_expected= &MOC_blood_eos_neg0,expected = &MOC_blood_eos_neg0
where form='MOC_NAT_eos_neg' and center=0;

update  formcount
set new_expected= &MOC_blood_eos_neg1,expected = &MOC_blood_eos_neg1
where form='MOC_NAT_eos_neg' and center=1;

update  formcount
set new_expected= &MOC_blood_eos_neg2,expected = &MOC_blood_eos_neg2
where form='MOC_NAT_eos_neg' and center=2;

update  formcount
set new_expected= &MOC_blood_eos_neg3,expected = &MOC_blood_eos_neg3
where form='MOC_NAT_eos_neg' and center=3;


select  stat2 as  total into :snap2_stat20 from snap2_missing where center=0 and form="SNAP2";
select  stat2 as  total into :snap2_stat21 from snap2_missing where center=1 and form="SNAP2";
select  stat2 as  total into :snap2_stat22 from snap2_missing where center=2 and form="SNAP2";
select  stat2 as  total into :snap2_stat23 from snap2_missing where center=3 and form="SNAP2";




update  formcount
set stat2= "&snap2_stat20" 
where form='SNAP2' and center=0;

update  formcount
set stat2= "&snap2_stat21"
where form='SNAP2' and center=1;

update  formcount
set stat2= "&snap2_stat22"
where form='SNAP2' and center=2;

update  formcount
set stat2= "&snap2_stat23"
where form='SNAP2' and center=3;


select  stat2 as  total into :snap_stat20 from snap2_missing where center=0 and form="SNAP";
select  stat2 as  total into :snap_stat21 from snap2_missing where center=1 and form="SNAP";
select  stat2 as  total into :snap_stat22 from snap2_missing where center=2 and form="SNAP";
select  stat2 as  total into :snap_stat23 from snap2_missing where center=3 and form="SNAP";

select  received as  total into :med_review_received20 from formcount where center=0 and form="LBWI_MRev";
select  received as  total into :med_review_received21 from formcount where center=1 and form="LBWI_MRev";
select  received as  total into :med_review_received22 from formcount where center=2 and form="LBWI_MRev";
select  received as  total into :med_review_received23 from formcount where center=3 and form="LBWI_MRev";

update  formcount
set stat2= "&snap_stat20" 
where form='SNAP' and center=0;

update  formcount
set stat2= "&snap_stat21"
where form='SNAP' and center=1;

update  formcount
set stat2= "&snap_stat22"
where form='SNAP' and center=2;

update  formcount
set stat2= "&snap_stat23"
where form='SNAP' and center=3;


update  formcount
set received= &med_review_received20 
where form IN ('Anthropometric section','Lab section') and center=0;

update  formcount
set received= &med_review_received21
where form IN ('Anthropometric section','Lab section') and center=1;

update  formcount
set received= &med_review_received22
where form IN ('Anthropometric section','Lab section') and center=2;

update  formcount
set received= &med_review_received23
where form IN ('Anthropometric section','Lab section') and center=3;

quit;

/* now reset stat */
data formcount; set formcount; 

if  (form eq 'LBWI_Blood_NAT_result_DOL0'  or form eq 'LBWI_Blood_NAT_result_DOL21'  
or form eq 'LBWI_Blood_NAT_result_DOL40' or form eq 'LBWI_Blood_NAT_result_DOL60' or 
form eq 'LBWI_Blood_NAT_result_DOL63') and  received > expected then do;

received=expected; 

percent_received= (received/expected)*100;
percent_received= compress(put(percent_received, 5.0));
stat=Trim(Left(Received)) ||   " / " || Trim(left(Expected)) || "( " || Trim(left(percent_received)) || " %)";

end;

if form eq 'MOC_NAT_eos_neg' and received eq "" and expected >=0 then received =0;

if  form eq 'MOC_NAT_eos_neg' then do;
percent_received= (received/expected)*100;
percent_received= compress(put(percent_received, 5.0));
stat=Trim(Left(Received)) ||   " / " || Trim(left(Expected)) || "( " || Trim(left(percent_received)) || " %)";

end;


if  form eq 'LBWI_urine_NAT_result' then do;
percent_received= (received/expected)*100;
percent_received= compress(put(percent_received, 5.0));
stat=Trim(Left(Received)) ||   " / " || Trim(left(Expected)) || "( " || Trim(left(percent_received)) || " %)";

end;


if form in ('SNAP', 'SNAP2','Anthropometric section','Lab section') then do;
total_missed2= (stat2*received)/100;
missed_25_stat2= compress(put(total_missed2, 5.0)) || "(" ||  compress(put(stat2, 5.0)) || ")";

end;

if form in ('Anthropometric section','Lab section') then received=.;

run;


proc format;

value $Form
'LBWI_MRev' = 'LBWI Medical Review and Lab Results ( Longitudinal)'
'LBWI_Demo' = 'LBWI Demographics '
'SNAP' = 'LBWI SNAP on DOL 0'
'SNAP2' = 'LBWI SNAP II ( Longitudinal )'
'MOC_Demo' = 'MOC Demographics '
'LBWI_urine_collect' = 'LBWI Urine Collection DOL 0'
'LBWI_urine_NAT_result'='LBWI Urine NAT result DOL 0'
'LBWI_blood_collect' = 'LBWI Blood Collection ( Longitudinal )'
'LBWI_Blood_NAT_result'='LBWI Blood NAT result ( Longitudinal )'
'LBWI_Blood_NAT_result_DOL0'='LBWI Blood NAT result DOL 0'
'LBWI_Blood_NAT_result_DOL21'='LBWI Blood NAT result DOL 21'
'LBWI_Blood_NAT_result_DOL40'='LBWI Blood NAT result DOL 40'
'LBWI_Blood_NAT_result_DOL60'='LBWI Blood NAT result DOL 60'
'LBWI_Blood_NAT_result_DOL63'='LBWI Blood/Urine NAT result DOL 90/EOS'
'MOC_sero_result' ='MOC Sero Status'
'MOC_blood_collect' ='MOC Blood Collection DOL 0'
'ConMeds' ='Concomittant Meds Log*'
'MechVent'='Mechanical Vent Log**'
'BreastFeed'='Breast Feed Log *'
'Anthropometric section'='--- Anthropometric section'
'Lab section'='--- Lab section'
'MOC_blood_eos_neg'='MOC Blood Collection (end of study, seroneg)'
'MOC_NAT_eos_neg'='MOC NAT result (end of study, seroneg)'
'LBWI_blood_collect_DOL0'='LBWI Blood Collection DOL 0'
'LBWI_blood_collect_DOL21'='LBWI Blood Collection DOL 21'
'LBWI_blood_collect_DOL40'='LBWI Blood Collection DOL 40'
'LBWI_blood_collect_DOL60'='LBWI Blood Collection DOL 60'
'LBWI_blood_collect_DOL63'='LBWI Blood/Urine Collection DOL 90/EOS'
;


Value $sigbz 
'N'='Red'
;


value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;

run;

data formcount; set formcount;
*if stat2 = . then stat2='-';
if out_of_window_stat ="" then out_of_window_stat='-';
if totalmissed_stat = "" then totalmissed_stat='-';
if missed_25_stat2 = "" then missed_25_stat2='-';
run;
/* exclude breast feed log, con meds, mech vent in this table*/
data formcount; set formcount; where formindex < 25; run;

options nodate  orientation = portrait; 

ods rtf file = "&output./monthly/&exp_count_file.form_submission_count_style1.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&exp_count_title a: Expected and Received Case Report Forms (CRFs): All Hospitals";
	

	
	title  justify = center "&exp_count_title a: Expected and Received forms (CRFs): Overall";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = formcount noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =0 ;
		var form expected received percent_received/style(column) = [just=left];

var missed_25_stat2 /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var totalmissed_stat /style(column) = [just=center];
    label Form='CRF Name' expected='Expected_CRF' received='Received_CRF' percent_received= 'Percent_Received_CRF' missed_25_stat2='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' totalmissed_stat='Sample not_Collected n(%)';
	format form $form.; format center center.;
run; 


ods noproctitle proclabel "&exp_count_title b: Expected and Received Case Report Forms (CRFs)for EUHM Hospital";
	
	
	title  justify = center "&exp_count_title b: Expected and Received forms (CRFs) for EUHM Hospital";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = formcount noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =1 ;
		var form expected received percent_received/style(column) = [just=left];
var missed_25_stat2 /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var totalmissed_stat /style(column) = [just=center];
    label Form='CRF Name' expected='Expected_CRF' received='Received_CRF' percent_received= 'Percent_Received_CRF' missed_25_stat2='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' totalmissed_stat='Sample not_Collected n(%)';
	format form $form.; format center center.;
run; 


ods noproctitle proclabel "&exp_count_title c: Expected and Received Case Report Forms (CRFs)for Grady Hospital";
	
	
	title  justify = center "&exp_count_title c: Expected and Received forms (CRFs) for Grady Hospital";
*footnote1 "*: Only for LBWI who completed study";
*footnote2 "**: Only for LBWI who completed study and indicated use of ventilator on summary form.";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = formcount noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =2 ;
		var form expected received percent_received/style(column) = [just=left];
var missed_25_stat2 /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var totalmissed_stat /style(column) = [just=center];
    label Form='CRF Name' expected='Expected_CRF' received='Received_CRF' percent_received= 'Percent_Received_CRF' missed_25_stat2='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' totalmissed_stat='Sample not_Collected n(%)';
	format form $form.; format center center.;
run; 

ods noproctitle proclabel "&exp_count_title d: Expected and Received Case Report Forms (CRFs)for Northside Hospital";
	

	
	title  justify = center "&exp_count_title d: Expected and Received forms (CRFs) for Northside Hospital";
*footnote1 "*: Only for LBWI who completed study";
footnote1 "Outside target window definitions: blood collection( >+/- 4days); SNAP-DOB ( > 5days); SNAP2 (>+/- 2days); Lab review (>+/- 2days);MOC sero(>+/- 5 days) Urine Collection (>+/- 4 days)";
   
   proc print data = formcount noobs label  split = "_" style(header) = [just=left] contents = ""; 

	
where center =3 ;
		var form expected received percent_received/style(column) = [just=left];
var missed_25_stat2 /style(column) = [just=center];
var out_of_window_stat /style(column) = [just=center];
var totalmissed_stat /style(column) = [just=center];
    label Form='CRF Name' expected='Expected_CRF' received='Received_CRF' percent_received= 'Percent_Received_CRF' missed_25_stat2='>25% Data_Missing_n(%)'
out_of_window_stat='Out-of-window_n(%)' totalmissed_stat='Sample not_Collected n(%)';
	format form $form.; format center center.;
run; 


ods rtf close;




options nodate  orientation = landscape; 


ods rtf file = "&output./monthly/&form_submission_detail_file.form_submission_detail.rtf" style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&form_submission_detail_title TTCMV CRF Submission Summary";
	/* Print patient details */

	footnote1 f= zapfb justify = left h = 3 "Y = form received" ;
	footnote2 f= zapfb justify = left h = 3 "N = form expected and not received" ;
  footnote3 f= zapfb justify = left h = 3 "* = form not expected for twin baby ";
	*footnote3 f= zapfb justify = left h = 3 "- = form not expected yet or ever due to patient mortality or discharge ";
	title  h=3 justify = center "patient detail - &today_date";

title  justify = center "&form_submission_detail_title TTCMV CRF Submission Summary";

* ods rtf file = "datamatrix2.rtf" style=journal; 
   
   proc print data = f2 noobs label  style(header) = [just=center] 
 split = "_" contents = ""
; 
/*
    var id DateOfBirth LBWI_Demo_DOL0	MOC_Demo_DOL0	
			LBWI_MRev_DOL0	LBWI_MRev_DOL4	LBWI_MRev_DOL7	LBWI_MRev_DOL14	LBWI_MRev_DOL21	LBWI_MRev_DOL28	LBWI_MRev_DOL40	LBWI_MRev_DOL60	
SNAP_DOL0	SNAP2_DOL4	SNAP2_DOL7	SNAP2_DOL14	SNAP2_DOL21	SNAP2_DOL28	SNAP2_DOL40	SNAP2_DOL60;

*/

	*var LBWI_Mrev_DOL40 / style={background=$sigbz.};
run; 

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;









