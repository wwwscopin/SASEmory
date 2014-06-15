/*data MissedCRF; set MissedCRF;
where missingflag=1;
run;
*/
proc sql;

create table missing_page_ids as
select a.* , b.reason ,b.id 
from MissedCRF as a 
left join cmv.endofstudy as b

on a.id=b.id;

quit;

data missing_page_ids;set missing_page_ids;

time_from_Dx = ( date()-studyleftdate  )+1;
if  missingflag=0 then delete;
run;
/*

data _NULL_;
  		
  command = "/usr/local/apps/datafax/reports/DF_QCupdate 20 ";	
  
  call symput('command1', command);
  
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /ttcmv/DataFax/work/*";
   x "chgrp -f studies *";
run;
*/
data _NULL_;
  filename = "pt_crfs_current.txt"; 		
  command = "/usr/local/apps/datafax/reports/DF_PTcrfs  20 -p - > /ttcmv/sas/data/pt_crfs_current.txt";	
  call symput('filename', filename);	
  call symput('command1', command);
  put filename;
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /ttcmv/DataFax/work/*";
   x "chgrp -f studies *";
run;


* read first half of the columns (the first table);
data ptcrfproblem;
 infile "/ttcmv/sas/data/pt_crfs_current.txt"  missover firstobs=8  ; * when importing a file from the cumulative QC report: firstobs= 12 obs=18 ;
		input id   visit  date problem $  ;
 if id =. then delete;
run;	




proc sql;
create table  column2_neeta as
select distinct(id) from ptcrfproblem where problem is not null  and ( problem Like  '%r%'  or problem Like  '%-%' or problem Like  '%+%') ;

create table ptcrfproblem2 as
select a.id, a.reason , b.id as Missingid,b.visit,b.problem,a.studyleftdate
from (select id, reason , studyleftdate from cmv.Endofstudy where reason not in  (4,5) ) as a left join
ptcrfproblem as b
on a.id=b.id  ;

create table ptcrfproblem3 as
select * from ptcrfproblem2 where problem is not null and ( problem Like  '%r%' /*or problem Like '%*%' */ or problem Like  '%-%'  or problem Like  '%+%') ;


create table pt_missing_id3 as
select * from  ptcrfproblem2  where problem is not null and ( problem Like  '%-%' ) ;

create table ptcrfproblem4 as
select distinct(id) as id from ptcrfproblem3 ;

quit;




data ptcrfproblem3;set ptcrfproblem3;

time_from_Dx = ( date()-studyleftdate  )+1;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

if time_from_Dx <30 then delete ;
run;


data pt_missing_id3;set pt_missing_id3;

time_from_Dx = ( date()-studyleftdate  )+1;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

if time_from_Dx <30 then delete ;
run;


proc sql;
create table crf_data_problem1 as
select count(distinct(id)) as data_count,  center  from ptcrfproblem3  group by center
union
select count(distinct(id)) as data_count,  0 as center  from ptcrfproblem3
;


quit;


/* *********************************************** */

proc format;

value $problem
"65-" = "NEC PN Log Page 1"
"18-"="SNAP II"
"17-"="LBWI Blood Collection"
"201-"="LBWI NAT Result"
"16-"="LBWI Lab Review"
"22-"="LBWI Summary"
"5-"="LBWI Demographic"
"69-"="IVH Page 2"
"23-"="MOC d/c blood collection"

;

value myvisit
1="DOL 1"
7="DOL 7"
21="DOL 21"
28="DOL 28"
40="DOL 40"
60="DOL 60/dx"
75="-"
63="DOL 63"
161="-"
162="-"
163="-"
;

quit;

options nodate orientation = portrait;
ods rtf file = "&output./nurses/missing_CRFs.rtf"  style=journal

toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&patient_study_status_title :  List of LBWI with missing pages";

	title  justify = center "&patient_study_status_title :  List of LBWI with missing pages";


footnote "";

proc report  data=pt_missing_id3 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

column  id  time_from_Dx  visit  problem  dummy ;
*define center / group center  order=internal   style(column)=[cellwidth=1in just=center]   " Site ";

define id / group center  order=internal   style(column)=[cellwidth=1in just=center]   " Id ";

define time_from_Dx / center   order=internal  width=15 " Time from Dx_(days)" style(column)=[cellwidth=0.5in];
define visit/ center   order=internal  width=15 "DOL  " style(column)=[cellwidth=0.5in] ;
define problem/ center   order=internal  width=15 "CRF " style(column)=[cellwidth=1.5in] format=$problem.;

define dummy/ noprint;

format visit myvisit.;


run;

ods rtf close;
