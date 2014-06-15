


proc sql;

create table enrolled as
select id  , EnrollmentDate 
from 
cmv.Eligibility where IsEligible=1;

quit;


data a; 
set enrolled; 
length formname $ 100;
output; do;DFSEQ =1; Formname="LBWIDemo"; day=1; grace=0;end;

 
output;do;DFSEQ =1; Formname="MOCDemo"; day=1; grace=0;end;
/*
output;do;Visitlist =2; Formname="Chemistry"; day=1;grace=0;end;
output;do;Visitlist =3; Formname="Chemistry"; day=14;grace=5;end;
output;do;Visitlist =4; Formname="Chemistry"; day=28;grace=5;end;
output;do;Visitlist =5; Formname="Chemistry"; day=56; grace=5;end;
output;do;Visitlist =6; Formname="Chemistry"; day=112; grace=5;end;
output;do;Visitlist =7; Formname="Chemistry"; day=168; grace=5;end;
output;do;Visitlist =8; Formname="Chemistry"; day=252;grace=5;end;
output;do;Visitlist =9; Formname="Chemistry"; day=336;grace=5;end;
*/
output;
run;



data a; set a; where DFSEQ <>.;run;


%macro RightTable (data= ,formname = , output=, table=, group=);
%if &group=1 %then %do; 
proc sql;

create table righttable as
select Distinct(id) as id, DFSEQ ,&formname as formname, 1 as DataObserved
from &table;

quit; %end;
%if &group >1 %then %do; 

proc sql;

create table righttable as
select id, DFSEQ , formname, DataObserved
from righttable
union

select Distinct(id), DFSEQ ,&formname as formname, 1 as DataObserved
from &table

order by id, Formname, DFSEQ;

quit;
%end;
%mend;

%RightTable(data=righttable ,formname= "LBWIDemo", output=output, table=cmv.LBWI_Demo, group=1); 
%RightTable(data=righttable ,formname= "MOCDemo", output=output, table=cmv.Moc_Demo, group=2); 


/* now merge */

proc sql;
create table all as
select a.*, b.DataObserved
from a 
left join righttable as b
on a.id=b.id and a.DFSEQ=b.DFSEQ and a.formname=b.formname
order by id, Formname, DFSEQ;
quit;

data all; set all; 
ExpectedDate=EnrollmentDate;
today=today();
Expected14Date=EnrollmentDate;
DataExpected=0;
format ExpectedDate date9.;
format Expected14Date date9.;
format today date9.;run;
proc sql;
update all
set ExpectedDate=EnrollmentDate + day + grace,
Expected14Date=EnrollmentDate + day + grace+14;
quit;



data all; set all;

if DataObserved =1 then do; DataExpected =1; DataStatus="Received";end;
else if DataObserved =. and Expected14Date >= today then do; DataExpected=99; DataStatus="NotDue";end;
else if DataObserved =. and Expected14Date < today then do;DataExpected=2;DataStatus="Overdue";end;
run;

proc sql;

create table forms as
select Distinct(formname), DFSEQ from all;

quit;



data forms2; set forms; 
alias=Left(trim(formname))||Left(trim(DFSEQ));
alias2=Left(trim(formname))|| "*" || Left(trim(DFSEQ));
alias3= Left(trim(alias)) || "=" || Left(trim(alias2));
run;



*------------------------------------------*;
%MACRO flattable(group=,form=,visit=);
%if &group=1 %then %do; 
proc sql;

create table f2 as
select a.*, b.DataStatus as &form&visit

from enrolled as a,
all as b
where a.id = b.id 
 and b.formname="&form" and  b.DFSEQ=&visit;
quit;
%end;

%if &group >1 %then %do; 
proc sql;

create table f2 as
select a.*, b.DataStatus as &form&visit

from f2 as a,
all as b
where a.id = b.id 
 and b.formname="&form" and b.DFSEQ=&visit;
quit;
%end;


%mend;


*------------------------------------------*;
* CREATE OUTPUT FILE CONTAINING MACRO CALL *;
*------------------------------------------*;
FILENAME TMP_FIL TEMP;
DATA _NULL_;
SET forms;
FILE TMP_FIL;
PUT "%flattable(group= "_N_" , form= " formname " , visit= " DFSEQ ");" ;
RUN;
*------------------------------------------*;
* INCLUDE FILE CONTAINING MACRO CALL *;
*---------------------;
%INCLUDE TMP_FIL;




FILENAME TMP_FIL2 TEMP;
DATA _NULL_;
SET forms2;
FILE TMP_FIL2;

PUT "Label " alias3 ";"
RUN;
*------------------------------------------*;
* INCLUDE FILE CONTAINING MACRO CALL *;
*---------------------;
* %INCLUDE TMP_FIL2;

FILENAME TMP_FIL3 TEMP;
DATA _NULL_;
SET forms2;
FILE TMP_FIL3;
PUT "var id "  ";"
PUT "var " alias  ";"
RUN;
*------------------------------------------*;
* INCLUDE FILE CONTAINING MACRO CALL *;
*---------------------;
*%INCLUDE TMP_FIL3;


%let date = today(); 

%let date = 2_10_2009; 



%let date = 2_10_2009; 
options nodate nonumber orientation = landscape; 
ods rtf file = "datamatrix.rtf" style=journal; 
   title "KITE Study Chemistry Summary - &date "; 
   proc print data = f2 noobs label style(header) = [just=center] split = "*"; 
    
/* var subjectid Demo1 Chemistry1 Chemistry2 /style(data) = [just=center] ; 

   */
%INCLUDE TMP_FIL3;

  
  %INCLUDE TMP_FIL2;

 
run; 
ods rtf close;










