%include "&include./annual_toc.sas";

%include "style.sas";

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


%macro alltx(data=,out=,variable=,vargroup=,gp=);




%if &gp=1 %then %do;
proc sql;

create table temp as

select a.* , b.dfseq, "&variable" as TxType, "&vargroup" as vargroup, DonorUnitId
from enrolled as a
left join

cmv.&data as b
on a.id=b.id;
quit;

data &out; set temp;run;

%end;

%if &gp>1 %then %do;
proc sql;

create table temp as

select a.* , b.dfseq, "&variable" as TxType, "&vargroup" as vargroup
from enrolled as a
left join

cmv.&data as b
on a.id=b.id;


create table &out as
select * from &out
union
select * from temp;
quit;


%end;
%mend alltx;

%alltx(data=rbctx,out=tx,variable=rbctx, vargroup=Transfusion , gp=1 );

%alltx(data=Platelettx,out=tx,variable=plttx,vargroup=Transfusion ,gp=2);

%alltx(data=Ffptx,out=tx,variable=ffptx,vargroup=Transfusion ,gp=3);

data tx; set tx;

output; 
center = 0; 
output; 
run; 

proc sql;

create table tx_total as
select count(*) as tx_total, TxType, center,vargroup
from tx
where dfseq<>.
group by txtype, center,vargroup

union

select count(*) as tx_total, "Anytx" as TxType, center,vargroup
from tx
where dfseq<>.
group by   center,vargroup

;







/* put final table together */

create table tx_lbwi as
select count(Distinct(id)) as tx_lbwi, TxType, center,vargroup
from tx
where dfseq<>.
group by txtype, center,vargroup

union

select count(Distinct(id)) as tx_lbwi,"Anytx" as TxType, center,vargroup
from tx
where dfseq <>.
group by  center,vargroup;



/* get donor count */

create table donor_count as
select count(Distinct(DonorUnitid)) as tx_total,  "donor" as TxType, center,"Donor" as vargroup
from tx
where dfseq<>.
group by center,vargroup;


create table donor_count2 as
select Distinct(a.TxType) as TxType, a.center,a.tx_total,b.tx_lbwi,a.vargroup

from donor_count as a, 
 tx_lbwi as b
where  a.center=b.center and b.TxType='Anytx';




create table tx_lbwi2 as
select a.TxType, a.center,a.tx_total,b.tx_lbwi,a.vargroup

from tx_total as a, 
 tx_lbwi as b
where a.TxType=b.TxType and a.center=b.center and a.vargroup=b.vargroup

union

select Distinct(TxType), center,tx_total,tx_lbwi,vargroup

from donor_count2 

;




quit;

data tx_lbwi2; set tx_lbwi2;
length stat $ 20;
length what_stat $ 20;
what_stat="tx_sum_LBWI_n ";
stat= compress( tx_total)   || " [ " || compress(tx_lbwi)  || " ]"  ;

run;


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
'rbctx' = 'RBC Tx'
'plttx' = 'Platelet Tx'
'ffptx' = 'FFP Tx'
'granotx' = 'Granulocyte Tx'
'Anytx' = 'Any Tx'
'donor' = ' Donor count'

;



run;

data enrolled; set enrolled;

output; 
center = 0; 
output; 
run; 

data enrolled;
length centerXX $ 50;
set enrolled;

if center= 0 then centerXX='Overall';

if center= 2 then centerXX='Grady';
if center= 3 then centerXX='Northside';
if center= 1 then centerXX='EUHM';
run;



proc sql;
  create table tofmt as
  select  ( compress( centerXX) || '_ ( N = ' || compress(put(Count(*),2.)) || ' )' ) as total, center,centerXX

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





/* table 2 */


proc sql;


create table tx_sum_by_lbwi as
select id, center, txtype, vargroup, count(id) as tx_sum_by_lbwi
from tx
where dfseq <> .
group by id, center, txtype, vargroup

union

select id, center, "AnyTx" as txtype, vargroup, count(id) as tx_sum_by_lbwi
from tx
where dfseq <> .
group by id, center,  vargroup

order by vargroup,center, txtype

;

/* get donor count by lbwi*/

create table donor_sum_by_lbwi as
select count(Distinct(DonorUnitid)) as donor_sum_by_lbwi,  "donor" as TxType, center,"Donor" as vargroup,id
from tx
where dfseq<>.
group by center,vargroup,id;


create table tx_sum_by_lbwi2 as
select id, center, txtype, vargroup,tx_sum_by_lbwi as variable
from tx_sum_by_lbwi
union
select id, center,txtype, vargroup, donor_sum_by_lbwi as variable
from donor_sum_by_lbwi
;



quit;


proc means data = tx_sum_by_lbwi2 fw=5 maxdec=1 nonobs n mean stddev median min max noprint;
where center <>.;
					class txtype center ;

				var variable;
				output out = tx_sum_by_lbwi_summary sum = sum n = n median = median q1 = q1 q3 = q3
						 mean = mean  stddev = stddev min = min max = max ;
			run;

data tx_sum_by_lbwi_summary2; set tx_sum_by_lbwi_summary;

if center =. or _type_ = 1 then delete;


run;


data tx_sum_by_lbwi_summary3; set tx_sum_by_lbwi_summary2;

length variable $ 50;

stat= compress( put(median,5.1))   || " [ " || compress(put(min,5.1))  || " , "  || compress(put(max,5.1)) || " ]";

if TxType  ='donor' then variable ='Donor';
else variable ='Transfusion';

 
run;

/* print two tables */



ods rtf file = "&output/annual/&all_tx_summary_file.t1_rbc_tx_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;
ods noproctitle proclabel "&all_tx_summary_title Transfusion and Donor Summary by Sites";





	title  justify = center "&all_tx_summary_title Transfusion and Donor Summary by Sites ";


proc report data=tx_lbwi2 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column   vargroup  txType      center ,  (stat  )  dummy;

define vargroup/ group order=data  style(column) = [just=center cellwidth=1in]   " Characteristic_" ;


define txType/ group order=data    " Tranfusion_" ;



*define what_stat/ group order=data   Left    " Statistics " ;

define center / across order=internal  style(column) = [just=center cellwidth=2in]   ""  format=cvar.;

define stat/center  style(column) = [just=center cellwidth=2in] " count [# LBWI ] "  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


break after  txType/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after vargroup;
     line ' ';
  endcomp;




format center center.;format txType $var.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
*ods rtf close;


/* table 2 */

/*
ods rtf   file = "&output/annual/&all_tx_summary_file.t1_rbc_tx_summary2.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&all_tx_summary_title a. Transfusion and Donor Summary per LBWI";

*/

title  justify = center "&all_tx_summary_title a.Transfusion and Donor Summary per LBWI ";


proc report data=tx_sum_by_lbwi_summary3 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column   variable  txType      center ,  (stat  )  dummy;

define variable/ group order=data    " Characteristic_" ;


define txType/ group order=data    " Tranfusion_" ;



*define what_stat/ group order=data   Left    " Statistics " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] "Median [ Min, Max ] / LBWI"  format=cvar.;

define stat/center   width=20   style(column) = [just=center cellwidth=2in] "  "  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


break after  txType/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after variable;
     line ' ';
  endcomp;




format center center.;format txType $var.;




run;




ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;



/* table 3 */

proc sql;


create table total_lbwi as
select center, count(id) as total_lbwi
from enrolled
group by center;


create table zero_tx_type as
select  Distinct(count(id)) as zeroTx, txtype, center
from tx
where dfseq =.
group by  txtype, center;

create table xx as
select Distinct(a.center) as center, id as total_lbwi,anyTx,idxx
from enrolled as a left join
(
/*select distinct(id) as idxx, max(dfseq) as maxseq   from tx where dfseq <> . */

select id as idxx,center, count(*) as AnyTx
from tx
where dfseq <> .
group by id,center

) as b
on a.id =b.idxx
;

create table zero_anytx as

select count(TOTAL_LBWI) as zeroTx, "AnyTx" as txtype, center
from  xx
where anyTx =.
group by  txtype, center; 



create table tx_type_category as
select txtype, center, vargroup , variable as TxCount, count(id) as num_lbwi
from tx_sum_by_lbwi2

where vargroup='Transfusion'
group by TxCount,txtype, center, vargroup 

union

select txtype, center, "Transfusion" as vargroup, 0 as TxCount, zeroTx as  num_lbwi
from  zero_tx_type

union
select txType,center, "Tranfusion" as vargroup, 0 as TxCount, zeroTx as num_lbwi
from zero_anytx






order by txtype, center,TxCount asc



;




create table tx_type_category as
select a.* ,b.total_lbwi
from tx_type_category as a,

total_lbwi as b
where a.center=b.center
order by txtype, center,TxCount asc;
quit;


data tx_type_category; set tx_type_category;
length stat $ 20;
length what_stat $ 20;
what_stat="tx_sum_LBWI_n ";
percent = (num_lbwi / total_lbwi ) * 100;
stat= compress( num_lbwi)   || " (" || compress(put(percent,5.1))  || " % )"  ;

run;



ods rtf   file = "&output/annual/&all_tx_summary_file.t1_rbc_tx_summary3.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&all_tx_summary_title b.  Number of transfusions (% of LBWI )";



title  justify = center "&all_tx_summary_title b. Number of transfusions  ( % of LBWI) ";


proc report data=tx_type_category nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column     txType  TxCount    center ,  (stat  )  dummy;



define txType/ group order=data    " Tranfusion_" ;



define TxCount/ group  order=internal   center    " # of transfusions " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2in] ""  format=cvar.;

define stat/center   width=20   style(column) = [just=center cellwidth=2in] " number of LBWI (%) "  left ;
*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


break after  txType/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after txType;
     line ' ';
  endcomp;




format center center.;format txType $var.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;


/* donor units */


proc sql;

create table donors as

 

select distinct(DonorUnitid) as donorunitid, ABOGroup, Rhgroup, UnitSerostatus,UnitStorageSolution,Irradiated,Washed,Leukoreduced,Volume_reduced
from cmv.rbctx
 where dfseq<>.

union

select distinct(DonorUnitid) as donorunitid, ABOGroup, Rhgroup, UnitSerostatus
from cmv.ffptx
where dfseq<>.
union

select distinct(DonorUnitid) as donorunitid, ABOGroup, Rhgroup, UnitSerostatus,Irradiated,Washed,Leukoreduced,Volume_reduced
from cmv.platelettx
where dfseq<>.
;

create table donors2 as 
select distinct(DonorUnitid) as donorunitid, ABOGroup, Rhgroup, UnitSerostatus,UnitStorageSolution,Irradiated,Washed,Leukoreduced,Volume_reduced,center
from donors as a
inner join (

select Distinct(donorunitid) as unit, center
from tx where donorunitid is not null)

as b
on a.donorunitid=b.unit; 


create table donors2 as 
select a.* ,b.leuko_failure, b.UnitResult
from donors2 as a left join

(
select Distinct(DonorUnitid) as DonorUnitId,leuko_failure, UnitResult
from cmv.Unit_status ) as b
on a.DonorUnitId =b.DonorUnitId;





quit;






%macro donorStat ( data=, out=, var=,f=, varlabel=,gp=,gpname=);


proc freq data=donors2;
tables center*&var/list  out = outfreq_&var;;

run;

proc sql;
create table temp as

select a.tx_total as DonorFreq, a.center,b.count as groupFreq, b.&var as category, "&varlabel" as variable,
put(&var,&f) as category2
from donor_count as a right join
outfreq_&var as b
on a.center=b.center 

order by center,&var ;
quit;

data temp; 

set temp (rename=(&var=category));

run;

data temp; 

length gpid $ 5;length gpname $ 5;
set temp;
gpid = "&gp"; gpname="&gpname";

run;

%if &gp=1 %then %do;
data AllVarFreq; set temp;


run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, center, category, category2,groupFreq, donorFreq ,gpid ,gpname from AllVarFreq
union
select variable, center, category, category2,groupFreq, DonorFreq ,gpid ,gpname from temp;

drop table temp;  drop table outfreq_&var;

quit;%end;

%mend donorStat;

%donorStat ( data=, out=, var=ABOGroup,f=abo_group., varlabel= ABO Group ,gp=1, gpname=ABO Group);
%donorStat ( data=, out=, var=RHGroup,f=rh_group., varlabel= Rh Group ,gp=2, gpname=RH Group);

%donorStat ( data=, out=, var=UnitSeroStatus,f=unit_cmv., varlabel= Unit Sero Status ,gp=3 , gpname=Sero Status);
%donorStat ( data=, out=, var=UnitResult,f=unit_CMV_NAT., varlabel= Unit NAT Status ,gp=4 , gpname=Unit Result);

%donorStat ( data=, out=, var=UnitStorageSolution,f=UnitStorageSolution., varlabel= Unit Storage ( RBC only) ,gp=5 , gpname=Unit Storage);
%donorStat ( data=, out=, var=Irradiated,f=yn., varlabel= Processing ( Irradiated) ,gp=6 , gpname=Unit Processing);
%donorStat ( data=, out=, var=Washed,f=yn., varlabel= Processing ( Washed) ,gp=7 , gpname=Unit Processing);

%donorStat ( data=, out=, var=Leukoreduced,f=yn., varlabel= Processing ( Leukoreduced) ,gp=8, gpname=Unit Processing);
%donorStat ( data=, out=, var=Volume_reduced,f=yn., varlabel= Processing ( reduced) ,gp=9, gpname=Unit Processing);






data AllVarFreq ; set AllVarFreq; 
percent = round((groupFreq/DonorFreq)*100,.1);
pipe='|';

stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(DonorFreq)))  || "(" || compress(Left(trim(percent)))|| "%)" ;
stat2=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || " " || compress(Left(trim(percent)))|| "%" ;

if category = . then category2 = 'Missing';

run;


proc sql;
create table allvarfreq as
select * from ALlVarFreq 
order by gpid;
quit;


options nodate  orientation = landscape; 

ods rtf  style=ttcmvtables file = "&output/annual/&all_tx_summary_file.t1_rbc_tx_summary4.rtf"  style=journal

toc_data startpage = yes bodytitle ;


ods noproctitle proclabel "&all_tx_summary_title c. Donor Unit Summary ";

title  justify = center "&all_tx_summary_title c. Donor Unit Summary  ";

proc report data=allvarfreq nowindows missing
headline  headskip pspace=1 split='_'


 ;
;


column  variable  category2 center  , ( stat  )  dummy ;

define variable / group order=data   width=15   style(column)=[font_size=8pt just=left]  'Characteristic ';

define category2 / group  center order=data width=15   style(column)=[font_size=8pt ] ' Class ' ;

define center / across order=internal  style(column) = [just=center cellwidth=2in]   ""  ;


*define pipe /  left  '' style(column)=[font_size=6pt];



define stat/  center   style(column)={font_size=8pt   just=center cellwidth=2in}  ' ' ;;
define dummy/ noprint;





format center center.;


compute before  variable;
line ' ';
endcomp;
/*
compute after visitlist;
line '';
endcomp; */

run;





run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;




%include "inc_tx.sas";
