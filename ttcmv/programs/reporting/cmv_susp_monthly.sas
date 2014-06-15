/**** help file for cmv susp for month ly table 8  ****************/

data eos;

set cmv.endofstudy;
where reason IN (1,2,3,6);

run;

proc sql;
create table eos as
select b.*
from cmv.valid_ids as a, eos as b
on a.id =b.id;
quit;

data eos; set eos;where id <> .;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

data death; set cmv.plate_100;
where deathcause =1;run;

data death; set death;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

proc sql;
create table susp_cmv as
select a.* ,b.*
from cmv.sus_cmv as a inner join
eos  as b on a.id=b.id
;
create table susp_cmv as
select a.* ,b.deathcause
from susp_cmv as a left join
death  as b on a.id=b.id
;

quit;


data susp_cmv; set susp_cmv;where id <> .;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

data susp_cmv; set susp_cmv;
clin_symptom=0;  NAT_result=0; lab_finding=0; image_finding=0;proc_finding=0;

if fever eq 1 or rash eq 1 or jaundice eq 1  or petechiae eq 1 or seizure eq 1 or hepatomegaly eq 1 or 
splenomegaly eq 1  or microcephaly eq 1  then

clin_symptom=1;

if AbBrainParenchyma eq 1 or BrainCalc eq 1 or Hydrocephalus eq 1   or pneumonitis eq 1  then

image_finding=1;

if HighAST eq 1 or HighALT eq 1 or HighGGT eq 1   or HighTBili eq 1 
or HighDBili eq 1  or AbLipase eq 1 or AbCh eq 1
or AbWBC eq 1 or AbPlatelet eq 1 or AbHCT eq 1 or AbHb eq 1 or AbNeutro eq 1 or AbLympho eq 1 then

lab_finding=1;


if confirmColitis eq 1 or confirmRetinitis eq 1 or confirmPneumonitis eq 1   or confirmDermatitis eq 1 or confirmEncephal=1 then

proc_finding=1;

if BloodNatResult in (2,3) or UrineNatResult in (2,3) then NAT_result=1;

if deathcause=. then deathcause_cmv=0;
run;

proc sql;
create table dis_conf as
select center, count(*) as dis_conf
from susp_cmv 
where CMVDisConf=1 group by center
union

select 0 as center, count(*) as dis_conf
from susp_cmv 
where CMVDisConf=1 ;

create table dis_rule_out as
select center, count(*) as dis_rule_out
from susp_cmv 
where CMVDisNo=1 group by center
union

select 0 as center, count(*) as dis_rule_out
from susp_cmv 
where CMVDisNo=1 ;


create table cmv_clin_sym_no as
select center, count(*) as cmv_clin_sym_no
from susp_cmv 
where clin_symptom=0 group by center
union
select 0 as center, count(*) as cmv_clin_sym_no
from susp_cmv 
where clin_symptom=0 ;

create table cmv_nat as
select center, count(*) as cmv_nat_neg
from susp_cmv 
where NAT_result=0 group by center
union
select 0 as center, count(*) as cmv_nat_neg
from susp_cmv 
where NAT_result=0 ;


create table cmv_serology as
select center, count(*) as cmv_serology_neg
from susp_cmv 
where SerologyResult ~=2 group by center
union
select 0 as center, count(*) as cmv_serology_neg
from susp_cmv 
where SerologyResult ~= 2 ;

create table cmv_culture as
select center, count(*) as cmv_culture_neg
from susp_cmv 
where UrineCultureResult~=2 group by center
union
select 0 as center, count(*) as cmv_culture_neg
from susp_cmv 
where UrineCultureResult~=2 ;

create table center as
select center, count(*) as total
from eos group by center
union
select 0 as center , count(*) as total from eos;
create table cmv_cases as
select center, count(*) as cmv_cases
from susp_cmv group by center
union
select 0 as center , count(*) as total from susp_cmv;


create table cmv_death as
select center, count(*) as cmv_death_no
from susp_cmv 
where deathcause_cmv =0 group by center
union
select 0 as center, count(*) as cmv_death_no
from susp_cmv 
where deathcause_cmv=0 ;


create table cmv_labtest as
select center, count(*) as cmv_labtest
from susp_cmv 
where labtest =1 group by center
union
select 0 as center, count(*) as cmv_labtest
from susp_cmv 
where labtest=1 ;


create table cmv_labfinding as
select center, count(*) as cmv_lab_finding_no
from susp_cmv 
where lab_finding  =0 group by center
union
select 0 as center, count(*) as cmv_lab_finding_no
from susp_cmv 
where lab_finding  =0 ;


create table cmv_imagefinding as
select center, count(*) as cmv_image_finding_no
from susp_cmv 
where image_finding  =0 group by center
union
select 0 as center, count(*) as cmv_image_finding_no
from susp_cmv 
where image_finding  =0 ;

create table cmv_procfinding as
select center, count(*) as cmv_proc_finding_no
from susp_cmv 
where proc_finding  =0 group by center
union
select 0 as center, count(*) as cmv_proc_finding_no
from susp_cmv 
where proc_finding  =0 ;


quit;


/**** assemble all above ****/

proc sql;

create table cmv_data as
select a.center,a.total,dis_conf,dis_rule_out,cmv_nat_neg,cmv_serology_neg,cmv_culture_neg,
cmv_cases,cmv_clin_sym_no,cmv_death_no,cmv_labtest,cmv_lab_finding_no,cmv_image_finding_no,cmv_proc_finding_no
from center as a left join
dis_conf as b on a.center=b.center
left join dis_rule_out as c on a.center=c.center
left join cmv_nat as d on a.center=d.center
left join cmv_serology as e on a.center=e.center
left join cmv_culture as f on a.center=f.center
left join cmv_cases as g on a.center=g.center
left join cmv_clin_sym_no as h on a.center=h.center
left join cmv_death as i on a.center=i.center
left join cmv_labtest as j on a.center=j.center
left join cmv_labfinding as k on a.center=k.center
left join cmv_imagefinding as l on a.center=l.center
left join cmv_procfinding as m on a.center=m.center
;
;
;

quit;

data cmv_data ; set cmv_data;

if dis_conf=. then dis_conf=0;

if dis_rule_out=. then dis_rule_out=0;

if cmv_nat_neg=. then cmv_nat_neg=0;

if cmv_serology_neg=. then cmv_serology_neg=0;

if cmv_culture_neg=. then cmv_culture_neg=0;

if cmv_clin_sym_no=. then cmv_clin_sym_no=0;

if cmv_lab_finding_no=. then cmv_lab_finding_no=0;
if cmv_image_finding_no=. then cmv_image_finding_no=0;
if cmv_proc_finding_no=. then cmv_proc_finding_no=0;

cmv_nat_pos= cmv_cases-cmv_nat_neg;
cmv_serology_pos= cmv_cases-cmv_serology_neg;
cmv_culture_pos= cmv_cases-cmv_culture_neg;

cmv_death_yes=cmv_cases-cmv_death_no;
cmv_clin_sym_yes=cmv_cases-cmv_clin_sym_no;

cmv_image_finding_yes=cmv_cases-cmv_image_finding_no;
cmv_lab_finding_yes=cmv_cases-cmv_lab_finding_no;
cmv_proc_finding_yes=cmv_cases-cmv_proc_finding_no;
run;

proc format;
value center
0="Overall"
1="EUHM"
2="Grady"
3="NS"

;
run;

/***** get stat *****/

data cmv_data ; set cmv_data;
cmv_nat_pos_pct=(cmv_nat_pos/cmv_cases)*100;
cmv_serology_pos_pct=(cmv_serology_pos/cmv_cases)*100;
cmv_culture_pos_pct=(cmv_culture_pos/cmv_cases)*100;

dis_conf_pct=(dis_conf/cmv_cases)*100;
dis_rule_out_pct=(dis_rule_out/cmv_cases)*100;

cmv_clin_sym_pct=(cmv_clin_sym_yes/cmv_cases)*100;
cmv_death_yes_pct=(cmv_death_yes/cmv_cases)*100;


cmv_labtest_pct=(cmv_labtest/cmv_cases)*100;

cmv_lab_finding_pct=(cmv_lab_finding_yes/cmv_cases)*100;
cmv_image_finding_pct=(cmv_image_finding_yes/cmv_cases)*100;

cmv_proc_finding_pct=(cmv_proc_finding_yes/cmv_cases)*100;

cmv_nat_pos_stat = compress(Left(trim(cmv_nat_pos))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_nat_pos_pct,5.0))))|| " %)" ;

cmv_serology_pos_stat = compress(Left(trim(cmv_serology_pos))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_serology_pos_pct,5.0))))|| " %)" ;

cmv_culture_pos_stat = compress(Left(trim(cmv_culture_pos))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_culture_pos_pct,5.0))))|| " %)" ;

center_stat=compress(Left(trim(put(center,center.))))  ;

dis_conf_stat = compress(Left(trim(dis_conf))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(dis_conf_pct,5.0))))|| " %)" ;

dis_rule_out_stat = compress(Left(trim(dis_rule_out))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(dis_rule_out_pct,5.0))))|| " %)" ;

cmv_clin_sym_stat = compress(Left(trim(cmv_clin_sym_yes))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_clin_sym_pct,5.0))))|| " %)" ;

cmv_death_yes_stat = compress(Left(trim(cmv_death_yes))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_death_yes_pct,5.0))))|| " %)" ;

cmv_labtest_stat = compress(Left(trim(cmv_labtest))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_labtest_pct,5.0))))|| " %)" ;


cmv_lab_finding_stat = compress(Left(trim(cmv_lab_finding_yes))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_lab_finding_pct,5.0))))|| " %)" ;

cmv_image_finding_stat = compress(Left(trim(cmv_image_finding_yes))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_image_finding_pct,5.0))))|| " %)" ;

cmv_proc_finding_stat = compress(Left(trim(cmv_proc_finding_yes))) || "/"  || compress(Left(trim(cmv_cases)))  || "\n(" || compress(Left(trim(put(cmv_proc_finding_pct,5.0))))|| " %)" ;

run;


