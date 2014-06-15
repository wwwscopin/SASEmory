***************************
*program:	target_mwindow.sas
*purpose: create table for expected and received status report for monthly report. This is based off andrea's time_window_check.sas
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: August 12,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;




%include "&include./monthly_toc.sas";
%include "&include./nurses_toc.sas";

proc sql;

create table windowtable (

count_window num,
out_of_window num,

DFSEQ num,
center num,
formname char(100),
formindex num
);
quit;

%macro windowTable (data= ,formname = , dfseq=,output=, table=, group=);

data temp; set &table;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
twin_index = input(substr(id2, 6, 1),1.);

run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intervention, 
**** AND 3 = OVERALL.; 

data temp; 
set temp; 
output; 
center = 0; 
output; 



run;

proc sql;


%if &formname ~=  "MOC_sero_result" %then %do;
insert into windowtable(count_window,  center,formname,formindex)
select count(out_of_window) as count_window,  center ,&formname as formname,  &group as formindex
from temp
where out_of_window In (1,0) and  dfseq <> . and dfseq &dfseq 
group by center
;

%end;


%if &formname =  "MOC_sero_result" %then %do;
insert into windowtable(count_window,  center,formname,formindex)
select count(out_of_window) as count_window,  center ,&formname as formname,  &group as formindex
from temp
where out_of_window In (1,0) and  dfseq <> . and dfseq &dfseq and twin_index=1
group by center
;

%end;



select count(out_of_window) as out_of_window into :c0 from temp where out_of_window In (1) and dfseq <> . and dfseq &dfseq and center=0;
select count(out_of_window) as out_of_window into :c1 from temp where out_of_window In (1) and dfseq <> . and dfseq &dfseq and center=1;
select count(out_of_window) as out_of_window into :c2 from temp where out_of_window In (1) and dfseq <> . and dfseq &dfseq and center=2;
select count(out_of_window) as out_of_window into :c3 from temp where out_of_window In (1) and dfseq <> . and dfseq &dfseq and center=3;

update windowtable
set out_of_window=&c0 where center=0  and formindex=&group;

update windowtable
set out_of_window=&c1 where center=1  and formindex=&group;

update windowtable
set out_of_window=&c2 where center=2 and formindex=&group;

update windowtable
set out_of_window=&c3 where center=3  and formindex=&group;


drop table temp;
quit;
%mend;

*%windowTable(data=windowtable ,formname= "LBWI_Demo",  dfseq==1 ,output=output, table=cmv.LBWI_Demo, group=5);
%windowTable(data=righttable ,formname= "LBWI_MRev",dfseq= < 63 , output=output, table=cmv.Med_review, group=6);  
%windowTable(data=windowtable ,formname= "SNAP",dfseq= =1, output=output, table=cmv.snap, group=9);
%windowTable(data=righttable ,formname= "SNAP2",dfseq= < 63 ,output=output, table=cmv.snap2, group=10);
%windowTable(data=righttable ,formname= "LBWI_urine_collect", dfseq= =1,output=output, table=cmv.LBWI_urine_collection, group=11);
%windowTable(data=righttable ,formname= "LBWI_blood_collect_DOL0",dfseq= =1, output=output, table=cmv.LBWI_blood_collection, group=14);
%windowTable(data=righttable ,formname= "LBWI_blood_collect_DOL21",dfseq= =21, output=output, table=cmv.LBWI_blood_collection, group=16);
%windowTable(data=righttable ,formname= "LBWI_blood_collect_DOL40",dfseq= =40, output=output, table=cmv.LBWI_blood_collection, group=18);
%windowTable(data=righttable ,formname= "LBWI_blood_collect_DOL60",dfseq= =60, output=output, table=cmv.LBWI_blood_collection, group=20);
%windowTable(data=righttable ,formname= "LBWI_blood_collect_DOL63",dfseq= =63, output=output, table=cmv.LBWI_blood_collection, group=22);
*%windowTable(data=righttable ,formname= "LBWI_blood_collect",dfseq=<=63, output=output, table=cmv.LBWI_blood_collection, group=19);
%windowTable(data=righttable ,formname= "MOC_sero_result",dfseq= =1, output=output, table=cmv.Moc_sero, group=2);


data windowtable; set windowtable;
out_of_window_pct=(out_of_window/count_window)*100;
out_of_window_stat=compress(Left(out_of_window)) ||   " / " || compress(left(count_window)) || "( "   || compress(put(out_of_window_pct,5.1)) || ")";
pipe = "|";
run;


proc format ;
value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;
run;

proc sort data=windowtable; by center formindex;run;

/*

options nodate nonumber orientation = portrait; 

ods rtf file = "&output./monthly/&window_file.target_window.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&window_title Target window (CRFs) by Site and Overall";
	

	
	
	title  justify = center "&window_title Target window (CRFs) by Site and Overall";
footnote1 "";
footnote2 "";
   
   proc print data = windowtable noobs label  split = "_" style(header) = [just=center] contents = ""; 

	by center;
		var formname count_window out_of_window  out_of_window_stat;


    label Form='CRF Name' count_window='With-in window' out_of_window='Out-of window' out_of_window_stat='Percent';
	*format form $form.; format center center.;
run; 


ods rtf close;
*/

/* Missing assessment */




proc sql;

create table Missedtable (
formname char(100),
formindex num,
center num
);
quit;






proc sql;

insert into Missedtable values("LBWI_blood_collect_DOL0",14,0);
insert into Missedtable values("LBWI_blood_collect_DOL0",14,1);
insert into Missedtable values("LBWI_blood_collect_DOL0",14,2);
insert into Missedtable values("LBWI_blood_collect_DOL0",14,3);

insert into Missedtable values("LBWI_blood_collect_DOL21",16,0);
insert into Missedtable values("LBWI_blood_collect_DOL21",16,1);
insert into Missedtable values("LBWI_blood_collect_DOL21",16,2);
insert into Missedtable values("LBWI_blood_collect_DOL21",16,3);

insert into Missedtable values("LBWI_blood_collect_DOL40",18,0);
insert into Missedtable values("LBWI_blood_collect_DOL40",18,1);
insert into Missedtable values("LBWI_blood_collect_DOL40",18,2);
insert into Missedtable values("LBWI_blood_collect_DOL40",18,3);

insert into Missedtable values("LBWI_blood_collect_DOL60",20,0);
insert into Missedtable values("LBWI_blood_collect_DOL60",20,1);
insert into Missedtable values("LBWI_blood_collect_DOL60",20,2);
insert into Missedtable values("LBWI_blood_collect_DOL60",20,3);

insert into Missedtable values("LBWI_blood_collect_DOL90",22,0);
insert into Missedtable values("LBWI_blood_collect_DOL90",22,1);
insert into Missedtable values("LBWI_blood_collect_DOL90",22,2);
insert into Missedtable values("LBWI_blood_collect_DOL90",22,3);


insert into Missedtable values("LBWI_urine_collect",11,0);
insert into Missedtable values("LBWI_urine_collect",11,1);
insert into Missedtable values("LBWI_urine_collect",11,2);
insert into Missedtable values("LBWI_urine_collect",11,3);


insert into Missedtable values("MOC_blood_collect",1,0);
insert into Missedtable values("MOC_blood_collect",1,1);
insert into Missedtable values("MOC_blood_collect",1,2);
insert into Missedtable values("MOC_blood_collect",1,3);

insert into Missedtable values("MOC_blood_eos_neg",3,0);
insert into Missedtable values("MOC_blood_eos_neg",3,1);
insert into Missedtable values("MOC_blood_eos_neg",3,2);
insert into Missedtable values("MOC_blood_eos_neg",3,3);

create table dol90sample as
select a.id, a.dfseq,a.NATBloodCollect,b.UrineSample
from cmv.LBWI_blood_collection as a left join cmv.LBWI_urine_collection as b
on a.id=b.id and a.dfseq=b.dfseq
where a.dfseq=63 and b.dfseq=63;


create table mocseroneg as
select a.id as id, a.ComboTestResult,b.id as nat_id, b.IsNatBlood,b.dfseq as dfseq
from cmv.Moc_sero as a left join cmv.Plate_023 as b
on a.id=b.id 
where b.dfseq=63  and ComboTestResult=1;


create table missed_ass as

select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "LBWI_blood_collect_DOL0" as formname , 14 as group 
from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq = 1  
group by center

union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "LBWI_blood_collect_DOL21" as formname , 16 as group 
from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq = 21
group by center

union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "LBWI_blood_collect_DOL40" as formname , 18 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq = 40 group by center

union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "LBWI_blood_collect_DOL60" as formname , 20 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq = 60 group by center

union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "LBWI_blood_collect_DOL90" as formname , 22 as group 
from /*cmv.LBWI_blood_collection*/dol90sample 
where NATBloodCollect= 0 and UrineSample = 0 and dfseq = 63 group by center


union


select count(*) as TotalMissed ,0 as center , "LBWI_blood_collect_DOL0" as formname , 14 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq =1 

union

select count(*) as TotalMissed ,0 as center , "LBWI_blood_collect_DOL21" as formname , 16 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq =21 

union

select count(*) as TotalMissed ,0 as center , "LBWI_blood_collect_DOL40" as formname , 18 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq =40

union

select count(*) as TotalMissed ,0 as center , "LBWI_blood_collect_DOL60" as formname , 20 as group from cmv.LBWI_blood_collection 
where NATBloodCollect= 0 and dfseq =60 

union

select count(*) as TotalMissed ,0 as center , "LBWI_blood_collect_DOL90" as formname , 22 as group 
from /*cmv.LBWI_blood_collection*/dol90sample  
where NATBloodCollect= 0 and  UrineSample = 0 and  dfseq =63

union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center, "LBWI_urine_collect" as formname , 11 as group from cmv.LBWI_urine_collection where UrineSample= 0 and dfseq=1 group by center

union
select count(*) as TotalMissed ,0 as center, "LBWI_urine_collect" as formname , 11 as group from cmv.LBWI_urine_collection where UrineSample= 0 and dfseq=1 


union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "MOC_blood_collect" as formname , 3 as group 
from (select * from cmv.Plate_004 where 
(NATSample= 0 or SerologySample = 0)and dfseq=1 ) as a inner join enrolled as b on a.id=b.id
group by center

union
select count(*) as TotalMissed ,0 as center , "MOC_blood_collect" as formname , 1 as group 
from  (select * from cmv.Plate_004 where 
(NATSample= 0 or SerologySample = 0)and dfseq=1 ) as a inner join enrolled as b on a.id=b.id



union
select count(*) as TotalMissed ,input(substr(put(id,7.), 1, 1),1.) as center , "MOC_blood_eos_neg" as formname , 
3 as group from /*cmv.Plate_023*/ mocseroneg where (IsNATBlood= 0 )and dfseq=63 group by center

union
select count(*) as TotalMissed ,0 as center , "MOC_blood_eos_neg" as formname , 3 as group from /*cmv.Plate_023*/ mocseroneg where (IsNATBlood= 0 )and dfseq=63 


;


create table Missedtable2 as
select a.*, b.TotalMissed,b.group,b.center  from Missedtable as a left join missed_ass as b on a.formname=b.formname and a.center=b.center;

drop table missed_ass;

create table missed_blood_collection as

select a.id, a.dfseq, a.NATBloodCollect from cmv.LBWI_blood_collection as a
right join 
(
select Distinct(id) as missedid from cmv.LBWI_blood_collection 
where
NATBloodCollect= 0 and dfseq <=63) as b
on a.id =b.missedid
where a.dfseq <=63;

create table missed_blood_collection as
select a.*,b.UrineSample,"Y" as missed_collection 
from missed_blood_collection as a  left join 
cmv.LBWI_urine_collection  as b
on a.id=b.id and a.dfseq=b.dfseq; 



create table missed_blood_collection_neeta as
select a.id, a.dfseq, a.NATBloodCollect ,b.UrineSample, 0 as missed_collection
from cmv.LBWI_blood_collection as a left join
cmv.LBWI_urine_collection  as b
on a.id=b.id and a.dfseq=b.dfseq;




quit;

proc sql;
create table missed_blood_collection_neeta as
select a.* ,b.NATTestResult
from missed_blood_collection_neeta as a left join
cmv.LBWI_blood_NAT_result as b
on a.id=b.id and a.dfseq=b.dfseq;


create table missed_blood_collection_neeta as
select a.* ,b.UrineTestResult
from missed_blood_collection_neeta as a left join
cmv.LBWI_Urine_NAT_result as b
on a.id=b.id and a.dfseq=b.dfseq;


quit;



data Missedtable2; set Missedtable2;

if Totalmissed =. then totalmissed=0;
group = formindex;

run;



data missed_blood_collection; set missed_blood_collection;

if dfseq = 1 or dfseq =63 then missed_stat=compress(trim(left(NATBloodCollect))) || "/" || compress(trim(left(UrineSample)));
else missed_stat=left(trim(NATBloodCollect)) ;



run;






proc format;

Value sigb 
-99.0='Red'
;

Value sigbz 
0='Red'
;

value NATBloodCollect
1='Y'
0='N'
; 

value $missed_stat
"1/1"="Y/Y"
"1/1_1/1"="Y/Y_Y/Y"
"1/0"="Y/N"
"1_1"="Y/Y"
"0_."="N/."
"0/1"="N/Y"
"0_1"="N/Y"
"0/0"="N/N"
"0/."="N/."
"1/."="Y/."
"./1"="./Y"
"0/1_1/."="N/Y_Y/."
"0/._./1"="N/._./Y"
"0/1_./1"="N/Y_./Y"
"1_."="Y/."
"0/0_1/."="N/N_Y/."
"0/0_./."="N/N_./."
"0/1_1/1"="N/Y_Y/Y"
"1/0/."="Y/N/."
"./1/."="./Y/."
"1"="Y"
"0"="N"
"99/1_./"="./Y_./"
"1/._1/1"="Y/._Y/Y"
"./0/."="N/N/."
"0/0/."="N/N/."
"1/1/." = "Y/Y/."
; 

value dfseq
1="DOB_Blood/Urine Sample_Blood/Urine_NAT "
21="21_Blood_NAT"
40="40_Blood_NAT"
60="60_Blood_NAT"
63="90_Blood/Urine Sample_Blood/Urine_NAT "
65="Blood Sample_If Tx 7days_before d/c_ NAT Result_Exp/Coll/NAT"
/*99="Tx Count_All.RBC.Plt.FFP.Cry"*/
99="Tx Count_All"
92="Plt"
93="Cryo"
94="Ffp"
;

run;

data missed_blood_collection; set missed_blood_collection;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);


run;

data missed_blood_collection_neeta; 
length tx_count $ 50;
set missed_blood_collection_neeta;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);


run;

/* fix tx 7 days before Dx cmv.Platelettx; cmv.plate_035 :Fffp cmv.plate_037= cryo */

data missed_blood_collection_neeta; set missed_blood_collection_neeta;
length tx_count $ 100;
tx_count='x';
run;

proc sql;

create table all_tx as
select id, max(Datetx) format=date9. as datetx from (

select id, max(DateTransfusion) format=date9. as datetx , "rbc" as type from cmv.rbctx group by id
union
select id, max(DateTransfusion) format=date9. as datetx , "Plt" as type from cmv.Platelettx group by id
union
select id, max(DateTransfusion) format=date9. as datetx , "Cryo" as type from cmv.plate_037 group by id
union 
select id, max(DateTransfusion) format=date9. as datetx , "ffp" as type from cmv.plate_035 group by id
 )as a  group by id;






create table missed_blood_collection_neeta as
select a.* ,b.datetx format=date9.
from missed_blood_collection_neeta as a left join all_tx as b
on a.id =b.id;

create table missed_blood_collection_neeta as
select a.* ,b.StudyLeftDate format=date9.

from missed_blood_collection_neeta as a left join cmv.endofstudy as b
on a.id =b.id;


create table rbc_tx_count as

select id, count(*) as tx_count ,  91 as dfseq   from cmv.rbctx where DateTransfusion is not null group by id
;

create table plt_tx_count as
select id, count(*) as tx_count  ,  92 as dfseq from cmv.Platelettx where DateTransfusion is not null group by id
;


create table cryo_tx_count as
select id, count(*) as tx_count  ,  93 as dfseq from cmv.plate_037 where DateTransfusion is not null group by id
;


create table ffp_tx_count as
select id, count(*) as tx_count  ,  94 as dfseq from cmv.plate_035 where DateTransfusion is not null group by id
;

create table tx_count as
select distinct(a.id) ,99 as dfseq, b.tx_count as rbc 
from missed_blood_collection_neeta as a left join
(select id, tx_count from rbc_tx_count) as b
on a.id=b.id
;

create table tx_count as
select a.*, b.tx_count as plt 
from tx_count as a left join
(select id, tx_count from plt_tx_count) as b
on a.id =b.id;

create table tx_count as
select a.*, b.tx_count as ffp 
from tx_count as a left join
(select id, tx_count from ffp_tx_count) as b
on a.id =b.id;


create table tx_count as
select a.*, b.tx_count as cryo 
from tx_count as a left join
(select id, tx_count from cryo_tx_count) as b
on a.id =b.id;

quit;

data tx_count; 
length tx_count2 $ 50;
set tx_count; 
if rbc=. then rbc=0;
if plt=. then plt=0;
if ffp=. then ffp=0;
if cryo=. then cryo=0;

total = rbc+plt+ffp+cryo;
/*tx_count2 =  compress(trim(left(total))) || "." || compress(trim(left(rbc))) || "." || compress(trim(left(plt)))  || "." || compress(trim(left(ffp))) || "." || compress(trim(left(cryo)))  ;
*/

tx_count2 =  compress(trim(left(total))) || " ." ;
run;

proc sql;


insert into missed_blood_collection_neeta(id, dfseq, tx_count)
select id, dfseq, tx_count2  from tx_count ;


update missed_blood_collection_neeta
set missed_collection=1 
where id in ((
select Distinct(id) as missedid from cmv.LBWI_blood_collection 
where
NATBloodCollect= 0 and dfseq <=63)
);


quit;

 data missed_blood_collection_neeta;set missed_blood_collection_neeta;



day7_before_dx = INTNX( 'WEEK', StudyLeftDate, -1, 'S' );

format day7_before_dx date9.;



if dfseq eq 65 and StudyLeftDate <> . and datetx <> . and  datetx >= day7_before_dx   then do;
			blood_before_dx = 1;
end;

else if dfseq eq 65 and StudyLeftDate <> . and datetx = .  then do;
			blood_before_dx = 0;
end;



else if dfseq eq 65 and StudyLeftDate = .  then do;
			blood_before_dx = 0;
end;


run;


data missed_blood_collection_neeta; 
length missed_stat $ 50; length missed_all_stat $ 50; length missed_nat_stat $ 50;
set missed_blood_collection_neeta;

if dfseq = 1 or dfseq =63 then missed_stat=compress(trim(left(NATBloodCollect))) || "/" || compress(trim(left(UrineSample)));
else missed_stat=left(trim(NATBloodCollect)) ;


if dfseq = 1 or dfseq =63 then missed_nat_stat=compress(trim(left(NATTestResult))) || "/" || compress(trim(left(UrineTestResult)));
else missed_nat_stat=left(trim(NATTestResult)) ;


missed_all_stat =compress(trim(left(missed_stat))) || "_" || compress(trim(left(missed_nat_stat)));


if dfseq = 65 then missed_all_stat=
compress(trim(left(blood_before_dx))) || "/" || compress(trim(left(missed_stat))) || "/" || compress(trim(left(missed_nat_stat)));



if dfseq > 90 then do; missed_all_stat=compress(trim(left(tx_count)));  
id2 = left(trim(id)); center = input(substr(id2, 1, 1),1.);
end;

run;


proc sort data=missed_blood_collection; by id;run;
proc sort data=missed_blood_collection_neeta; by id;run;


ods escapechar = '~';
options nodate orientation = landscape;
ods rtf file = "&output./nurses/&exp_obs_count_mon_file.missed_samples_coordinator.rtf"  style=journal

toc_data startpage = yes bodytitle;
%macro printreport(center=);
ods noproctitle proclabel "&exp_obs_count_mon_title e. Sample collection profile on LBWI who missed scheduled blood collection (DOB - DOL 90)";


	title  justify = center "&exp_obs_count_mon_title e. Sample collection profile on LBWI who missed scheduled blood collection (DOB - DOL 90)";
footnote "";

proc report data=missed_blood_collection_neeta  nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

by center; where (missed_collection =1) and center=&center ;

column id dfseq , ( missed_all_stat ) /*dfseq , (UrineSample  ) */  dummy ;

define id / center group   order=internal     style(column)=[cellwidth=0.75in just=center]  "LBWI Id";

define dfseq / across Left  order=internal     "DOL" format=dfseq.;


define missed_all_stat/ center   order=internal "  " style(column)=[cellwidth=1.3in  ] format=$missed_stat.;



define dummy/ noprint;
format center center.;
format NATBloodCollect NATBloodCollect.;




run;


ods noproctitle proclabel "&exp_obs_count_mon_title f. Sample collection profile on LBWI who did not miss scheduled  blood collection (DOB - DOL 90)";


	title  justify = center "&exp_obs_count_mon_title f. Sample collection profile on LBWI who did not miss scheduled blood collection (DOB - DOL 90)";
footnote "";

proc report data=missed_blood_collection_neeta  nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

by center; where missed_collection=0 and center=&center ;

column id dfseq , ( missed_stat ) /*dfseq , (UrineSample  ) */dummy ;

define id / center group   order=internal     style(column)=[cellwidth=1in just=center]  "LBWI Id";

define dfseq / across Left  order=internal    "DOL" format=dfseq.;


define missed_stat/ center   order=internal   "  " style(column)=[cellwidth=1in  ] format=$missed_stat.;

define dummy/ noprint;
format center center.;
format NATBloodCollect NATBloodCollect.;




run;


%mend printreport;

%printreport(center=1);
%printreport(center=2);
%printreport(center=3);
ods rtf close;
quit;

