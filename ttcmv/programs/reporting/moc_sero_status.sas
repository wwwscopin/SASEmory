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
;
value center 
2='Grady'
3='EUHM'
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
create table moc_sero as
select a.*, b.*
from enrolled as a
left join
cmv.Moc_sero as b
on a.id =b.id where b.DFSEQ =1;

quit;


proc sql;
create table moc_nat as
select a.*, b.*
from enrolled as a
left join
cmv.Moc_nat as b
on a.id =b.id  where b.DFSEQ =1;

quit;



proc sort data=moc_sero; by center dfseq;run;
proc sort data=moc_nat; by center dfseq;run;


proc freq data=moc_sero;
by center dfseq;

tables DFSEQ*IgMTestResult/out=xx ;


run;

proc means data=moc_sero n ;
by center dfseq;
var IgMTestResult;
output out=yy sum=;
run;



proc sql;
create table yy as
select count(*) as total, dfseq, center,IgMTestResult as classvar format=serotest., "IgMTestResult" as variable, 1 as group
from  moc_sero
group by dfseq, center,IgMTestResult, variable, group
union
select count(*) as total, dfseq, center,ComboTestResult as classvar format=Igtest., "ComboTestResult" as variable, 2 as group
from  moc_sero
group by dfseq, center,ComboTestResult, variable, group

union
select count(*) as total, dfseq, center,NATTestResult as classvar format=serotest., "NATTestResult" as variable, 3 as group
from  moc_nat
group by dfseq, center,NATTestResult, variable, group;

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





%allstat(data=moc_sero, var=IgMTestResult , f=serotest.,  group=1);
%allstat(data=moc_sero, var=ComboTestResult , f=Igtest. ,group=2);
%allstat(data=moc_nat, var=NATTestResult , f=serotest. ,group=3);
/* data xx; set xx; where class <> .;run;
*/
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
where  a.dfseq = b.dfseq and a.variable=b.variable  and a.classvar=b.classvar;

* ;

quit;

proc contents data=xx2;run;
data xx2; set xx2;

length stat3 $ 25;
stat3=compress( count || " / " || total || " (" || percent || "%)" );

stat3 =compress(trim(stat3));


run;

* Types of the Define Statement;



*options nodate nonumber orientation = landscape; 


ods rtf file = "&output/monthly/&moc_sero_status_file.moc_sero_status.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&moc_sero_status_title  MOC cohort assignment";



	title f= zapf h=3 justify = center "MOC Cohort assignment ";

* Types of the Define Statement;
proc report data=xx2 nofs  style(header) = [just=center] split="*" headline headskip contents = "";
column center  DFSEQ   variable classvar stat3 ;
define center / order width=6 " Center ";
define DFSEQ / order order=internal  width=15 " Day on * Study ";
define variable /order   order=internal  width=10 " Test Name ";
define classvar/order  order=internal  width=15 " Result ";
define stat3/  width=30 " Statistics * n/N (%) ";


break after center /skip;

*compute statistics;
*statistics=compress( count.sum || " (" || percent.sum || "%)" );
*endcomp;
format center center.;
format DFSEQ DFSEQ.;



run;


ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;





