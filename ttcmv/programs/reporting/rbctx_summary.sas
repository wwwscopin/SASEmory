%include "&include./annual_toc.sas";


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


proc sql;







create table rbc as

select a.* , b.*
from enrolled as a
left join

cmv.Rbctx as b
on a.id=b.id;
quit;



data rbc; 
set rbc; 
output; 
center = 0; 
output; 
run; 


data enrolled; 
set enrolled; 
output; 
center = 0; 
output; 
run; 


proc sql;





create table tx_count as

select count(*) as tx_count,id,center
from rbc as a

group by id,center;




create table tx as

select a.*, b.*
from enrolled as a,

tx_count as b
where a.id =b.id and a.center=b.center;



create table lowhb as
select id, Min(hb) as low_hb
from cmv.med_review
group by id;


create table enrolled as
select a.* , b.low_hb
from enrolled as a
left join
lowhb as b
on a.id=b.id;





quit;









%macro tx_macro(in=, outdata=, sql=, var=, varlabel=);
proc sql;


create table tx_count as

select &sql as &varlabel,id,center
from rbc as a

group by id,center;




create table &outdata as

select a.*, b.*
from &in as a,

tx_count as b
where a.id =b.id and a.center=b.center;


quit;
%mend;

%tx_macro(in=enrolled, outdata=tx2, sql=count(*), var=, varlabel=tx_count);

%tx_macro(in=tx2, outdata=tx2, sql=count(Distinct(DonorUnitId)), var=, varlabel=donor_count);

%tx_macro(in=tx2, outdata=tx2, sql=sum(rbcVolumeTransfused), var=, varlabel=rbc_volume);









%macro get_stat(indata=, outdata=, var=, varlabel= , gp=, stattype=,frmt=);



proc sort data=&indata; by center; run;
proc means data=&indata maxdec=2;
class center; by center;

var &var;

output out=tx_sum_&var sum=sum
mean=mean median=median min=min max=max n=n std=std;

run;



data temp ( keep= variable what_stat stat center);
length variable $ 50;
length what_stat $ 50;

set tx_sum_&var;
variable="&varlabel";


%if &stattype =1 %then %do;
what_stat="[Med, Min, Max] n";
stat= compress(trim( "[" || put(median, &frmt)   || ", " || put(min, &frmt)|| "," ||  put(max, &frmt) || "]" || " " || n ));
%end;



%if &stattype =2 %then %do;
what_stat="[mean,sd] ";
stat= compress(trim( "[" || put(mean, &frmt)   || ", " || put(std, &frmt)  || "]"  ));
%end;



*where center <> .;
run;

%if &gp=1 %then %do;

data first ; set temp; run;
%end;

%if &gp >1 %then %do; 

proc sql;

create table first as
select * from first 
Union
select * from temp;


quit;



%end;

%mend;

%get_stat(indata=tx2, outdata=, var=tx_count,varlabel=tx_count,gp=1 , stattype=1 ,frmt=4.0);


%get_stat(indata=tx2, outdata=, var=donor_count,varlabel=donor_count,gp=2 ,stattype=1,frmt=4.0);

%get_stat(indata=rbc, outdata=, var=hct,varlabel=hct,gp=3 ,stattype=2,frmt=4.1);


%get_stat(indata=rbc, outdata=, var=hb,varlabel=hb,gp=4 ,stattype=2,frmt=4.1);

%get_stat(indata=tx2, outdata=, var=rbc_volume,varlabel=rbc_volume,gp=5 ,stattype=2,frmt=4.1);

%get_stat(indata=enrolled, outdata=, var=low_hb,varlabel=low_hb,gp=6 ,stattype=2,frmt=4.1);

%get_stat(indata=rbc, outdata=, var=bodyweight,varlabel=bodyweight,gp=7 ,stattype=2,frmt=4.1);

%get_stat(indata=rbc, outdata=, var=unitage,varlabel=unitage,gp=8 ,stattype=2,frmt=4.1);




proc format;

value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
;

value $abo
1='A'
2='AB'
3='B'
4='O'
;

value $rh
2='Negative'
1='Positive'
;



value $var 
'hct' = 'LBWI Hematocrit (%) at transfusion'
'hb' = 'LBWI Hemoglobin (g/dl) at transfusion'
'donor_count' = 'No of Donors for a LBWI'
'rbc_volume' = 'RBC volume transfused (ml) to LBWI'
'tx_count' = 'Number of transfusions per LBWI'
'low_hb' = 'Lowest Hb level (g/dl) for a LBWI'
'bodyweight' ='LBWI Body weight prior to Tx' 
'unitage' = ' Blood unit age (days)'
'total_tx'= 'Total number of Tx'
'NumberTx'= ' Number of LBWI with tx = '
'ABOGroup'= 'Donor unit blood group'
;



run;



proc sql;






create table first as
select variable, center, what_stat, stat from first
union
select "total_tx" as variable, center, "Sum" as what_stat , put(count(*),3.0) as stat
from rbc
group by center, variable,what_stat
union



select  b.variable, a.center, b.what_stat,   compress( put(b.stat,5.0)  || " (" || put(((b.stat/a.total_infant)*100),2.1) || "%)"  ) as stat  

from (

select count(Distinct(id)) as Total_infant, center

from tx2
group by center) as a,

(

select "NumberTx" as variable , center, put(tx_count,2.0)  as what_stat, count(*) as stat 
from tx2 

group by center,what_stat


) as b
where a.center=b.center



union

select  b.variable, a.center, put(b.what_stat,1.0) as what_stat format=$abo.,   compress( put(b.stat,5.0)  || " (" || put(((b.stat/a.total_donor)*100),2.1) || "%)"  ) as stat  

from (

select count(Distinct(DonorUnitId))  as Total_donor, center

from rbc
group by center) as a,

(

select ABOgroup as what_stat , count(Distinct(DonorUnitId))  as stat, center, "ABOGroup" as variable

from rbc 
group by ABOgroup,center


) as b
where a.center=b.center
order by center, what_stat;





;




quit;


data enrolled;
length centerXX $ 50;
set enrolled;

if center= 0 then centerXX='Overll';

if center= 2 then centerXX='Grady';
run;




/*
proc sql;
create table sfmt as
select 'trtX' as fmtname , centerXX as start ,
trim(center) || '\(N=' || ')'
as
label length=20
from enrolled group by center ,centerXX ;
*/

proc sql;
  create table tofmt as
  select  compress( centerXX || '_( N =' || put(Count(*),2.) || ')' ) as total, center,centerXX

  from enrolled

group by center,centerXX;
quit;



data fmt_dataset;
  retain fmtname "cvar";
  set tofmt ;
  start = center;
  label = total  ;
run;
proc format cntlin = fmt_dataset  fmtlib;
  select cvar;
  run;



quit;



data first; set first;

pipe ='|';


run;






ods rtf file = "&output./annual/&rbc_tx_summary_file.rbc_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&rbc_tx_summary_title RBC transfusion Summary";





	title  justify = center "RBC Transfusion Summary ";


proc report data=first nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;




column    variable   what_stat    center ,  (stat pipe )  dummy;

define variable/ group order=data  Left width=30 " Characteristic " ;



define what_stat/ group order=data   Left width=30   " Statistics " ;

define center / across order=internal  Left width=30 "------Center------_" format=cvar.;

define stat/center   width=20 "  " ;
define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


break after  variable/ol skip ;

rbreak after / skip ;


compute after variable;
     line ' ';
  endcomp;




format center center.;
format variable $var.;




run;





ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;










