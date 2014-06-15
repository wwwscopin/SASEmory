/*libname cmv "/ttcmv/sas/data/freeze2011.03.09";
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


where (Enrollmentdate is not null or iseligible = 1) and a.id not in (3003411,3003421) ;
*/

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
 /*cmv.valid_ids */CMV.COMPLETEDstudylist  as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;


select compress(put(count (*),3.0)) into :lbwi0  from enrolled ;
quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
moc = input(substr(id2, 1, 5),5.);
run;



proc format ;

value DFSEQ
1='Enrollment'
2='DOL 1'
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

value $variable
'ComboTestResult' = 'IgG/IgM Combo Test'
'IgMTestResult'='IgM Test *'
;


run;

proc sql;
create table moc_sero as
select a.*, b.*
from enrolled as a
left join
cmv.Moc_sero  as b
on a.id =b.id where b.DFSEQ =1;


select compress(put(count (*),3.0)) into :moc0  from moc_sero ;

create table moc_igg as
select a.*, b.*
from enrolled as a
right join
(select distinct(id) as id, Max(IgGTestResult) as IgGTestResult  from 
( 
select distinct(id) as id, Max(IgGTestResult) as IgGTestResult from cmv.plate_209 where IgGTestResult In (1,2)
union

select distinct(id) as id, Max(IgGTestResult) as IgGTestResult from cmv.plate_215 where IgGTestResult In (1,2)
)
) as b
on a.id =b.id ;

quit;


data moc_sero; set moc_sero;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data moc_igg; set moc_igg;dfseq=1;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


data bm_nat; set cmv.bm_nat;dfseq=1;
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);
run;

proc sql;
create table moc_nat_x as
select a.* 
from cmv.moc_nat as a 
inner join
enrolled as b
on a.id=b.id;

quit;

data moc_nat; set moc_nat_x;where dfseq=1;
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);
run;

data moc_nat_eos; set moc_nat_x;where dfseq=63;
id2 = left(trim(id));

center = input(substr(id2, 1, 1),1.);
run;




proc sql;
select compress(put(count (*),3.0)) into :mo0  from moc_sero ;
select compress(put(count (*),3.0)) into :mo1  from moc_sero where center=1;
select compress(put(count (*),3.0)) into :mo2  from moc_sero where center=2;
select compress(put(count (*),3.0)) into :mo3  from moc_sero where center=3;

select compress(put(count (*),3.0)) into :lbwi0  from enrolled ;
quit;


proc format;
value center 
0="Overall (MOC=&mo0)"
2="Grady (MOC=&mo2)"
1="EUHM (MOC=&mo1)"
3="Northside (MOC=&mo3)"
4="CHOA Egleston"
5="CHOA Scottish";

run;
proc sql;
create table class_count as

select count(*) as classtotal, dfseq, center,ComboTestResult as classvar format=Igtest., "ComboTestResult" as variable, 1 as group
from  moc_sero
group by dfseq, center,ComboTestResult, variable, group

Union
select count(*) as classtotal, dfseq, 0 as center,ComboTestResult as classvar format=Igtest., "ComboTestResult" as variable, 1 as group
from  moc_sero

group by dfseq, ComboTestResult, variable, group


union

select count(*) as classtotal, dfseq, center,IgMTestResult as classvar format=Igtest., "IgMTestResult" as variable, 2 as group
from  moc_sero
where ComboTestResult=2
group by dfseq, center,IgMTestResult, variable, group


Union
select count(*) as classtotal, dfseq, 0 as center,IgMTestResult as classvar format=Igtest., "IgMTestResult" as variable, 2 as group
from  moc_sero
where ComboTestResult=2
group by dfseq, IgMTestResult, variable, group


union

select count(*) as classtotal, 1 as dfseq, center,IgGTestResult as classvar format=Igtest., "IgGTestResult" as variable, 3 as group
from  moc_igg
where IgGTestResult=2
group by  center,IgGTestResult, variable, group

union

select count(*) as classtotal,1 as  dfseq, 0 as center,IgGTestResult as classvar format=Igtest., "IgGTestResult" as variable, 3 as group
from  moc_igg
where IgGTestResult=2
group by IgGTestResult, variable, group

union

select count(*) as classtotal, 1 as dfseq, center,2 as classvar format=Igtest., "BMNATTestResult" as variable, 4 as group
from  bm_nat
where NATResult_wk1 In (2,3) or NATResult_wk3 In (2,3) or NATResult_wk4 In (2,3) or NATResult_d34 In (2,3)
group by  center, variable, group

union

select count(*) as classtotal,1 as  dfseq, 0 as center,2 as classvar format=Igtest., "BMNATTestResult" as variable, 4 as group
from  bm_nat
where NATResult_wk1 In (2,3) or NATResult_wk3 In (2,3) or NATResult_wk4 In (2,3) or NATResult_d34 In (2,3)
group by  variable, group

union

select count(*) as classtotal, 1 as dfseq, center,NATTestResult as classvar format=serotest., "MOCNATTestResult" as variable, 5 as group
from  moc_nat
where NATTestResult in (1,2,3)
group by  center, NATTestResult,variable, group

union

select count(*) as classtotal,1 as dfseq, 0 as center,NATTestResult as classvar format=serotest., "MOCNATTestResult" as variable, 5 as group
from  moc_nat
where NATTestResult in (1,2,3)
group by  NATTestResult, variable, group


/**** ****/
union

select count(*) as classtotal, 1 as dfseq, center,NATTestResult as classvar format=serotest., "MOCNATTestResultEOS" as variable, 6 as group
from  moc_nat_eos
where NATTestResult in (1,2,3)
group by  center, NATTestResult,variable, group

union

select count(*) as classtotal,1 as dfseq, 0 as center,NATTestResult as classvar format=serotest., "MOCNATTestResultEOS" as variable, 6 as group
from  moc_nat_eos
where NATTestResult in (1,2,3)
group by  NATTestResult, variable, group



order by variable


;



quit;


proc sql;
create table overall_count as

select count(*) as Overalltotal, dfseq, center, "ComboTestResult" as variable, 1 as group
from  moc_sero
where ComboTestResult in (1,2,3)
group by dfseq, center, variable, group

union

select count(*) as Overalltotal, dfseq, 0 as center, "ComboTestResult" as variable, 1 as group
from  moc_sero
where ComboTestResult in (1,2,3)


union

select count(*) as Overalltotal, dfseq, center, "IgMTestResult" as variable, 2 as group
from  moc_sero
where IgMTestResult in (1,2,3) and  ComboTestResult=2




union

select count(*) as Overalltotal, dfseq, 0 as center, "IgMTestResult" as variable, 2 as group
from  moc_sero
where IgMTestResult in (1,2,3) and  ComboTestResult=2

union

select count(*) as Overalltotal, dfseq, center, "IgGTestResult" as variable, 3 as group
from  moc_igg
where IgGTestResult in (1,2) 


union

select count(*) as Overalltotal, dfseq, 0 as center, "IgGTestResult" as variable, 3 as group
from  moc_igg
where IgGTestResult in (1,2) 


union

select count(*) as Overalltotal, dfseq, center, "BMNATTestResult" as variable, 4 as group
from  bm_nat
where NATResult_wk1 <99 or NATResult_wk3 <99 or NATResult_wk4 <99 or NATResult_d34 <99


union
select count(*) as Overalltotal, dfseq, 0 as center, "BMNATTestResult" as variable, 4 as group
from  bm_nat
where NATResult_wk1 <99 or NATResult_wk3 <99 or NATResult_wk4 <99 or NATResult_d34 <99

union

select count(*) as Overalltotal, 1 as dfseq, center, "MOCNATTestResult" as variable, 5 as group
from  moc_nat
where NATTestResult in (1,2,3,4) 

union

select count(*) as Overalltotal, 1 as dfseq, 0 as center, "MOCNATTestResult" as variable, 5 as group
from  moc_nat
where NATTestResult in (1,2,3,4)

/**** ****/

union

select count(*) as Overalltotal, 1 as dfseq, center, "MOCNATTestResultEOS" as variable, 6 as group
from  moc_nat_eos
where NATTestResult in (1,2,3,4) 

union

select count(*) as Overalltotal, 1 as dfseq, 0 as center, "MOCNATTestResultEOS" as variable, 6 as group
from  moc_nat_eos
where NATTestResult in (1,2,3,4)

order by variable
;



quit;

proc sql;

create table final_1 as

select a.Overalltotal, a.dfseq, a.center,a.group,
       b.classtotal as cmv_serology_negative,a.variable
from overall_count as a
left join

class_count as b

on a.center=b.center and a.dfseq=b.dfseq and a.variable=b.variable and a.group=b.group

where b.classvar =1;

quit;


proc sql;

create table final_2 as

select a.*,
       b.classtotal as cmv_serology_positive
from final_1 as a
left join

(select * from class_count where classvar>1 )as b

on a.center=b.center and a.dfseq=b.dfseq and a.variable=b.variable and a.group=b.group

;

quit;

data final_2; set final_2;

if cmv_serology_positive=. then cmv_serology_positive=0;
run;

proc sql;

create table final as

select a.*,
        ((cmv_serology_positive/OverallTotal)*100)   as percent_positive FORMAT=PERCENT7.2
from final_2 as a

;

quit;



/* ***** do for igg and BM******* ****/
proc sql;

insert into  final ( variable, center, dfseq, group ,cmv_serology_positive)
select Variable, center, dfseq, group,classtotal 
from class_count where  variable ='IgGTestResult';

insert into  final ( variable, center, dfseq, group ,cmv_serology_positive)
select Variable, center, dfseq, group,classtotal 
from class_count where  variable ='BMNATTestResult';

update final
set overalltotal=&mo0
where variable In ('IgGTestResult', 'BMNATTestResult','MOCNATTestResult' ) and center=0;


update final
set overalltotal=&mo1
where variable In ('IgGTestResult', 'BMNATTestResult','MOCNATTestResult' ) and center=1;

update final
set overalltotal=&mo2
where variable In ('IgGTestResult', 'BMNATTestResult' ,'MOCNATTestResult') and center=2;

update final
set overalltotal=&mo3
where variable In ('IgGTestResult', 'BMNATTestResult' ,'MOCNATTestResult') and center=3;



quit;

/* end *********************/






data final; set final;




length percent_positive_text $ 25;

if center = 0 then total_moc=&mo0;
if center = 1 then total_moc=&mo1;
if center = 2 then total_moc=&mo2;
if center = 3 then total_moc=&mo3;

if group in ( 2,3,4) then percent_positive = (cmv_serology_positive/total_moc)*100;



percent_positive_text=compress( put(percent_positive,5.1) || " % "  );

percent_positive_text =compress(trim(percent_positive_text));

pipe ="|";
label variable='Test';

run;



proc sql;

/* this is place holder for other centers 
insert into final ( center, dfseq, group )
values (1, 1,1);
*/
insert into final ( center, dfseq, group)
values (3, 1,1);

create table serology_report as
select distinct center from final ;

create table serology_report2 as
select a.*, b.combo_positive,
            b.combo_negative,
					b.combo_pct,
					c.igM_positive,
            c.igM_negative,
					c.igM_pct,
					d.igG_positive,
					d.igG_pct,
					e.bm_nat_positive,
					e.bm_nat_pct,
					f.moc_nat_positive,
					f.moc_nat_negative,
					f.moc_nat_pct,
					g.moc_nat_positive_eos
					
from serology_report as a left join
     ( select center, b.cmv_serology_positive as combo_positive,
            b.cmv_serology_negative as combo_negative,
					b.percent_positive_text as combo_pct 
			from final as b where b.variable='ComboTestResult')as  b
on a.center=b.center 
left join
			( select center, b.cmv_serology_positive as igM_positive,
            b.cmv_serology_negative as igM_negative,
					b.percent_positive_text as igM_pct 
from final as b where b.variable='IgMTestResult')as  c
on a.center=c.center 
left join
			( select center, b.cmv_serology_positive as igG_positive,
            
					b.percent_positive_text as igG_pct 
from final as b where b.variable='IgGTestResult')as  d
on a.center=d.center

left join
			( select center, b.cmv_serology_positive as bm_nat_positive,
            
					b.percent_positive_text as bm_nat_pct 
from final as b where b.variable='BMNATTestResult')as e
on a.center=e.center

left join
			( select center, b.cmv_serology_positive as moc_nat_positive,
            b.cmv_serology_negative as moc_nat_negative,
					b.percent_positive_text as moc_nat_pct 
from final as b where b.variable='MOCNATTestResult')as f
on a.center=f.center


left join
			( select center, b.cmv_serology_positive as moc_nat_positive_eos
            
from final as b where b.variable='MOCNATTestResultEOS')as g
on a.center=f.center




;
create table serology_report3 as
select distinct center,  combo_positive, combo_negative, combo_pct , IgM_positive, IgM_negative ,IgM_pct ,
 IgG_positive , IgG_pct  ,
moc_nat_positive ,moc_nat_negative, moc_nat_pct ,bm_nat_positive  ,
moc_nat_positive_eos

from serology_report2;

quit;

data serology_report3; set serology_report3; pipe="|";run;

proc sort data=final; by variable;run;


ods escapechar = '~';
options nodate orientation = portrait;
ods rtf file = "&output./monthly/&moc_sero_status_file.moc_sero_status2_completed.rtf"  style=journal

toc_data startpage = yes bodytitle;


ods noproctitle proclabel "&moc_sero_status_title :MOC CMV Serology Status Overall and by Site";



	title  justify = center "&moc_sero_status_title :MOC CMV Serology Status Overall (MOC =&moc0 for LBWI=&lbwi0) and by Site";

footnote1 '~S={ just=left  }'
'~{super *} IgM done if combo test is positive' ;
footnote2 '~S={ just=left  }'
'~{super *} IgG test for reactivation is done if IgM positive or MOC/LBWI NAT positive/low positive/indeterminate or BM NAT positive' ;

footnote3 '~S={ just=left  }'
'~{super *} **Only seronegative MOCs at enrollment are NAT tested at EOS' ;

footnote4 '~S={ just=left  }'
'~{super *} Of the XX MOCs that were Combo test NEG, YY were tested at EOS, a blood sample was not obtained for Z MOC, and Y are pending' ;

proc report data=serology_report3 nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;



column center  combo_positive combo_negative combo_pct  IgM_positive IgM_negative IgM_pct  IgG_positive  /*IgG_pct */ 
moc_nat_positive moc_nat_negative moc_nat_pct moc_nat_positive_eos bm_nat_positive /* bm_nat_pct */
dummy ;

define center / center group   order=internal     style(column)=[cellwidth=0.8in just=center]  "Site" format=center.;


define combo_positive/ center   order=internal   " Combo Test_Pos " style(column)=[cellwidth=0.6in];
define combo_negative/ center   order=internal   " Combo Test_Neg " style(column)=[cellwidth=0.5in];
define combo_pct/ center  " Combo Test _(% Pos) " style(column)=[cellwidth=0.8in];

define IgM_positive/ center   order=internal  " IgM_Pos " style(column)=[cellwidth=0.5in];
define IgM_negative/ center   order=internal  " IgM_Neg " style(column)=[cellwidth=0.5in];
define IgM_pct/ center  " IgM _(% Pos) " style(column)=[cellwidth=0.5in];

define IgG_positive/ center   order=internal   " IgG_Pos " style(column)=[cellwidth=0.5in];
define IgG_pct/ center   " IgG _(% Pos) " style(column)=[cellwidth=0.5in];

define bm_nat_positive/ center   order=internal   " Breast_Milk_NAT_Pos " style(column)=[cellwidth=0.5in];
*define bm_nat_pct/ center   " Breast_Milk_NAT _(% Pos) " style(column)=[cellwidth=0.5in];

define moc_nat_positive/ center   order=internal   " MOC_NAT_Pos_DOL0" style(column)=[cellwidth=0.5in];
define moc_nat_negative/ center   order=internal   " MOC_NAT_Neg_DOL0" style(column)=[cellwidth=0.5in];
define moc_nat_pct/ center   " MOC_NAT _(% Pos)_DOL0" style(column)=[cellwidth=0.5in];

define moc_nat_positive_eos/ center   order=internal   " MOC_NAT_Pos_EOS**" style(column)=[cellwidth=0.5in];


define pipe/ center   " " ;
define dummy/ noprint;
format center center.;

format variable $variable.;


run;




ods rtf close;
quit;





/* second sty;e */

/*

proc report data=final nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

*by variable ;
where overalltotal ~= .;

column center variable   cmv_serology_positive cmv_serology_negative percent_positive_text     ;

define center / group Left  order=internal    " Center " style(column)=[cellwidth=1in] format=center.;

define variable / group Left  order=internal    "Test" ;


define cmv_serology_positive/ center   order=internal  width=20 " Positive " style(column)=[cellwidth=1in];
define cmv_serology_negative/center   order=internal  width=20 " Negative " style(column)=[cellwidth=1in];
define percent_positive_text/ center  width=30 " %_Positive " ;

*define pipe/ center  width=30 " | " ;

*define dummy/ noprint;




format center center.;

format variable $variable.;


run;


ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;

proc report data=final nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;

by variable ;
where overalltotal ~= .;

column center variable , ( cmv_serology_positive cmv_serology_negative percent_positive_text  )  dummy ;

define center / group Left  order=internal    " Center " style(column)=[cellwidth=1in];

define variable / across Left  order=internal    "" ;


define cmv_serology_positive/ center   order=internal  width=20 " Positive " style(column)=[cellwidth=1in];
define cmv_serology_negative/center   order=internal  width=20 " Negative " style(column)=[cellwidth=1in];
define percent_positive_text/ center  width=30 " %_Positive " ;

*define pipe/ center  width=30 " | " ;

define dummy/ noprint;






compute after center; 
blankline='   '; 
num=0; 
if center=0 then do; num=8; mytext='Hospital';  ; end; 

else do; num=0;
mytext='        ';
end;
line @1 blankline $varying. num;
line @19 mytext $varying. num;

line @1 blankline $varying. num;
endcomp;



format center center.;

format variable $variable.;


run;
*/






