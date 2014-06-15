%include "&include./monthly_toc.sas";

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

proc contents data=enrolled; run;

proc format ;

 *value DFSTATV;
*1=1;
*2=2;

value DFSEQ
1='Enrollment'
2='DOL 1'
21='DOL 21'
40='DOL 40'
60='DOL 60'
63='DOL 90/End of Study'
;
value center 
2='Grady'
1='EUHM'
;
value serotest
1='Not detected'
2='Low positive'
3='Positive'
4='Indeterminate'
;


value Igtest
1='Negative'
2='Positive'
3='Inconclusive'

;

run;


proc sql;
create table lbwi_urine_nat_result as
select a.*, b.*
from enrolled as a
left join
cmv.lbwi_urine_nat_result as b
on a.id =b.id;

quit;


proc sql;
create table lbwi_blood_nat_result as
select a.*, b.*
from enrolled as a
left join
cmv.lbwi_blood_nat_result as b
on a.id =b.id;

quit;



proc sql;
create table yy as
select count(*) as total, dfseq, center,UrineTestResult as classvar format=serotest., "UrineTestResult" as variable, 1 as group
from  lbwi_urine_nat_result
group by dfseq, center,UrineTestResult, variable, group
union
select count(*) as total, dfseq, center,NATTestResult as classvar format=Igtest., "NATTestResult" as variable, 2 as group
from  lbwi_blood_nat_result
group by dfseq, center,NATTestResult, variable, group

;

quit;


proc contents data=yy;run;

%macro allstat(data=, var=,f=,group=);

proc sort data=&data; by center dfseq;run;

%if &group = 1 %then %do;
proc freq data=&data;
by center dfseq;

tables DFSEQ*&var/out=x&group ;
run;
data xx; set x1; variable="&var"; classvar = &var;
format classvar &f;
run;

%end;

%if &group >1 %then %do; 
proc freq data=&data;
by center dfseq;

tables DFSEQ*&var/out=x&group ;
run;
data x&group; set x&group; variable="&var";classvar = &var;
format classvar &f;
run;
proc sql;
create table xx as
select a.*
from xx as a
Union
select b.*
from x&group as b;

quit;

%end;

%mend allstat;



%allstat(data=lbwi_urine_nat_result, var=UrineTestResult , f=Igtest. ,group=1);

%allstat(data=lbwi_blood_nat_result, var=NATTestResult , f=serotest.,  group=2);





data xx; set xx;
length stat $ 25;
length stat2 $ 25;
stat=compress( count || " (" || percent || "%)" );

stat2 =compress(trim(stat));
if DFSEQ = . then delete;
run;


proc sql;
create table xx2 as
select a.* , b.total
from xx as a,
yy as b
where  a.dfseq = b.dfseq and a.variable=b.variable and a.classvar=b.classvar;

quit;


data xx2; set xx2;

length stat3 $ 25;
stat3=compress( count || " / " || total || " (" || percent || "%)" );

stat3 =compress(trim(stat3));


run;

* Types of the Define Statement;

*proc sql ;

*create table xx2 as
*select * from xx2
*order by DFSEQ asc,center;
*quit;


proc format;

value $variable
'UrineTestResult' = ' Urine test'
'NATTestResult' = 'NAT test'
;

run;
*options nodate nonumber orientation = landscape; 


*ods rtf file = "107_lbwi_cmv.rtf" style = journal toc_data startpage = yes bodytitle;
*ods noproctitle proclabel "Table x : LBWI CMV Result";


ods rtf file = "&output./monthly/&lbwi_cmv_status_file.lbwi_cmv_status.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&lbwi_cmv_status_title LBWI CMV Status";


	title justify = center "&lbwi_cmv_status_title LBWI CMV Result ";

* Types of the Define Statement;
proc report data=xx2 nofs  style(header) = [just=center] split="*" headline headskip contents = "";
column center DFSEQ  variable classvar stat3 ;
define center / group center  width=15 " Center ";
define DFSEQ/order  center order=internal   width=15 " Day on * Study ";
define variable / center  width=10 " Test ";
define classvar/ center  width=15 " Result ";
define stat3/ center width=30 " n/N (%) ";


break after center /skip;
break after DFSEQ /skip;

*compute statistics;
*statistics=compress( count.sum || " (" || percent.sum || "%)" );
*endcomp;
format center center.;
format DFSEQ DFSEQ.;
format variable $variable.;


run;


ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;

