%include "&include./annual_toc.sas";



proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id



where (Enrollmentdate is not null ) and a.id not in (3003411,3003421);

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data enrolled; 
set enrolled; 
output; 
center = 0; 
output; 
run; 


data infection_all; set cmv.infection_all;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data infection_all; 
set infection_all; 
output; 
center = 0; 
output; 
run; 

proc sql;

create table inf_site as
select count(siteblood) as count, "Blood" as site, center  from  infection_all where siteblood = 1 group by site, center
union

select count(SiteCNS) as count, "CNS" as site, center  from  infection_all where SiteCNS = 1 group by site, center

union

select count(SiteUT) as count, "UT" as site, center  from  infection_all where SiteUT = 1 group by site, center
union

select count(SiteCardio) as count, "cardio" as site, center  from  infection_all where SiteCardio = 1 group by site, center

union

select count(SiteLowerResp) as count, "Resp" as site, center  from  infection_all where SiteLowerResp = 1 group by site, center

union

select count(SiteGI) as count, "GI" as site, center  from  infection_all where SiteGI = 1 group by site, center

union

select count(SiteSurgical) as count, "Surgical" as site, center  from  infection_all where SiteSurgical = 1 group by site, center

union

select count(SiteOther) as count, "Other" as site, center  from  infection_all where SiteOther = 1 group by site, center

union

select count(*) as count, "Any" as site, center  from  infection_all where ( siteblood = 1 or SiteCNS =1 or  SiteUT = 1 or SiteCardio = 1 or SiteLowerResp = 1 or SiteGI = 1 or  SiteSurgical = 1  or  SiteOther = 1 ) group by site, center
;


create table inf_patients as
select Count(distinct(id)) as TotalPatients, "Blood" as site, center  from  infection_all where siteblood = 1 group by site, center
union

select Count(distinct(id)) as TotalPatients, "CNS" as site, center  from  infection_all where SiteCNS = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "UT" as site, center  from  infection_all where SiteUT = 1 group by site, center
union

select Count(distinct(id)) as TotalPatients, "cardio" as site, center  from  infection_all where SiteCardio = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "Resp" as site, center  from  infection_all where SiteLowerResp = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "GI" as site, center  from  infection_all where SiteGI = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "Surgical" as site, center  from  infection_all where SiteSurgical = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "Other" as site, center  from  infection_all where SiteOther = 1 group by site, center

union

select Count(distinct(id)) as TotalPatients, "Any" as site, center  from  infection_all where ( siteblood = 1 or SiteCNS =1 or  SiteUT = 1 or SiteCardio = 1 or SiteLowerResp = 1 or SiteGI = 1 or  SiteSurgical = 1  or  SiteOther = 1 ) group by site, center
;




create table report_table as
select a.count,a.site,a.center,b.TotalPatients
from inf_site as a , inf_patients as b
where  a.site=b.site and a.center=b.center
order by a.center, a.site;



select count(*) format=3.0 into :overall  from enrolled where center=0;


select count(*) format=3.0 into :grady  from enrolled where center=2;


select count(*) format=3.0 into :midtown  from enrolled where center=1;

select count(*) format=3.0 into :northside  from enrolled where center=3;

quit;

proc format;
value $site
'Any'='Any Site'
'Blood' = 'Blood Stream (BSI)'
'UT'='Urinary Tract'
'CNS'='Central nervous system'
'Resp'='Lower respiratory tract'
'Surgical'='Surgical site'
'GI'='Gastro intenstinal'
'cardio'='Cardiovascular'
;

value center
1='EUHM ( N ='&midtown ')'
2='Grady ( N ='&grady ')'
0='Overall ( N ='&overall ')'
3='Northside ( N ='&northside ')'
;

value culturesite
1='Blood'
2='Urine'
3='Wound'
4='Sputum/Trachael Aspirate'
5='BAL'
6='CSF'
7='Stool'
8='Catheter tip'
9='Other'
;

value organism
1='S.epidermidis'
2='MSSA'
3='MRSA'
4='Vancomycin susp E.faecalis'
5='Vancomycin resis E.faecalis'
6='Vancomycin susp E.faecium'
7='Vancomycin resis E.faecium'
8='K.pneumoniae'
9='P.aeruginosa'
10='S.pneumoniae'
11='S.viridans'
12='S.agalactiae'
13='E. coli'
14='Acinobacter'
15='E. cloace'
16='E. aerogenes'
17='C. dificila'
18='C. albicans'
19='C. gibrate'
20='C. tropicalis'
21='Influenza'
22='H purpura'
23='Resp Synticytial virus'
24='Epstein  virus'
25='Enterovirus'
26='Adenovirus'
27='Other'
;


value $org_txt
"1"="S.epidermidis"
"2"="MSSA"
"3"="MRSA"
"4"="Vancomycin susp E.faecalis"
"5"="Vancomycin resis E.faecalis"
"6"="Vancomycin susp E.faecium"
"7"="Vancomycin resis E.faecium"
"8"="K.pneumoniae"
"9"="P.aeruginosa"
"10"="S.pneumoniae"
"11"="S.viridans"
"12"="S.agalactiae"
"13"="E. coli"
"14"="Acinobacter"
"15"="E. cloace"
"16"="E. aerogenes"
"17"="C. dificila"
"18"="C. albicans"
"19"="C. gibrate"
"20"="C. tropicalis"
"21"="Influenza"
"22"="H purpura"
"23"="Resp Synticytial virus"
"24"="Epstein  virus"
"25"="Enterovirus"
"26"="Adenovirus"
"27"="Other"
;


value $organismother


value $organismother
'13'='E coli'
'26'='Adenovirus'
'27'='Other'
'99'='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';

value yesno
1-2='Y'
0='-';

value inf
481='#1'
482='#2'
483='#3'
484='#4';

run;

data report_table; set report_table;

if center = 0 then samplesize=&overall;
if center = 1 then samplesize=&midtown;
if center = 2 then samplesize=&grady;
if center = 3 then samplesize=&northside;

pct = (TotalPatients /samplesize )*100;



stat = compress(count) || " /" || compress(TotalPatients) || " ( " || compress(put(pct,5.1 )) || ")";

run;


options orientation=landscape;
ods rtf   file = "&output./annual/&infection_summary_file1.infection.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&infection_summary_title1 Infection/Sepsis by Site  ";



title  justify = center "&infection_summary_title1  Infection/Sepsis by Site   ";


proc report data=report_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column    Center Site  /*count   TotalPatients*/ stat  dummy;



define Center/ group order=data    "Site " ;



define Site/ group  order=data   Left    " Infection site " ;

*define count /  order=internal  left   style(column) = [just=center cellwidth=2in] " Total infections" ;
*define TotalPatients /  order=internal  left   style(column) = [just=center cellwidth=2in] " # LBWI" ;
define stat /  order=internal  left   style(column) = [just=center cellwidth=2in] " Total infections /# LBWI (% )" ;

*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;


*break after  groupvariable/ol skip ;

rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after center;
     line ' ';
  endcomp;



format center center.; format site $site.;




run;

*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;
quit;



proc sql;


create table infection_long as
select id, dfseq,  siteblood, SiteCNS, SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture1date format =date9. as culturedate,culture1site as culturesite ,Culture1Org as organism ,Culture1OrgOther  as OrgOther ,InfecConfirm,DateFormCompl format=date9. as DateFormCompl,dfseq
from cmv.infection_all
union
select id, dfseq,  siteblood,SiteCNS, SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture2date as culturedate,culture2site as culturesite,Culture2Org as organism  ,Culture2OrgOther as OrgOther ,InfecConfirm ,DateFormCompl format=date9. as DateFormCompl,dfseq from cmv.infection_all

union
select id, dfseq,  siteblood,SiteCNS, SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture3date as culturedate,culture3site as culturesite,Culture3Org as organism  ,Culture3OrgOther as OrgOther ,InfecConfirm ,DateFormCompl format=date9. as DateFormCompl ,dfseq from cmv.infection_all
union

select id, dfseq, siteblood, SiteCNS,SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture4date as culturedate,culture4site as culturesite,Culture4Org as organism ,Culture4OrgOther as OrgOther ,InfecConfirm ,DateFormCompl format=date9. as DateFormCompl ,dfseq from cmv.infection_all

union

select id, dfseq,  siteblood,SiteCNS, SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture5date as culturedate,culture5site as culturesite,Culture5Org as organism ,Culture5OrgOther as OrgOther ,InfecConfirm ,DateFormCompl format=date9. as DateFormCompl,dfseq  from cmv.infection_all

union

select id, dfseq,  siteblood,SiteCNS, SiteUT,SiteCardio,SiteLowerResp,SiteOther,SiteGI,SiteSurgical,culture6date as culturedate,culture6site as culturesite,Culture6Org as organism ,Culture6OrgOther as OrgOther ,InfecConfirm ,DateFormCompl format=date9. as DateFormCompl ,dfseq from cmv.infection_all

;
create table infection_long as
select a.*,LBWIDOB as DateOfBirth
from infection_long as a 
left join
cmv.LBWI_Demo as b
on a.id = b.id;


create table infection_long as
select * from infection_long  where culturedate is not null order by id, dfseq,culturedate asc;


quit;

data infection_long; 

set infection_long; 

length OrgOther2 $ 200; 

if organism = 27 then 
OrgOther2=lowcase(OrgOther);
else 

OrgOther2=put(Organism,2.);

time_to_inf_confirm = culturedate - DateOfBirth;

format OrgOther2 $organismother.;
run;


options orientation=landscape;
ods rtf   file = "&output./annual/&infection_summary_file2.infection.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&infection_summary_title2 Infection/Sepsis by patients ";



title  justify = center "&infection_summary_title2  Infection/Sepsis by Patients  ";


proc report data=infection_long nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column  id  /*DateFormCompl*/ dfseq culturedate time_to_inf_confirm  culturesite /*organism*/ OrgOther2 InfecConfirm SiteLowerResp siteblood SiteCNS SiteUT SiteCardio   SiteGI SiteSurgical SiteOther  dummy;



define id/ group order=data    "LBWI ID" ;

*define DateFormCompl/ group  order=data   Left    " Form date "  format=date9.;
define culturedate/ group  order=data   Left    " Culture_confirm date "  format=date7.;
define time_to_inf_confirm/ group  order=data   Left    " Time to_Culture_confirm "  ;
define dfseq/ group  order=data   Left    " Infection " ;
define culturesite/ group  order=data   Left    " Culture site " ;

*define organism /    left   style(column) = [just=center ] " Culture organism" ;
define OrgOther2 /    left   style(column) = [just=center cellwidth=2in] "Organism" display format =$org_txt.;

define InfecConfirm/   left   style(column) = [just=center ] "x-ray confirm_Resp Tract Inf" ;


define siteblood/   left   style(column) = [just=center ] "Inf Site_BSI" ;
define SiteCNS/    left   style(column) = [just=center ] "Inf Site_CNS" ;
define SiteUT/    left   style(column) = [just=center ] "Inf Site_UT" ;
define SiteCardio/    left   style(column) = [just=center ] "Inf Site_Cardio" ;
define SiteLowerResp/    left   style(column) = [just=center ] "Inf Site_Resp Tract" ;
define SiteGI/    left   style(column) = [just=center ] "Inf Site_GI" ;
define SiteSurgical/    left   style(column) = [just=center ] "Inf Site_Surgical" ;
define SiteOther/    left   style(column) = [just=center ] "Inf Site_Other" ;


*define pipe/center   width=20 "  " ;

define dummy/NOPRINT ;




rbreak after / skip ;

compute before;
     line ' ';
  endcomp;



compute after id;
     line ' ';
  endcomp;


format organism organism.; 
format OrgOther2 $org_txt.;
*format OrgOther2 $organismother.;
 format culturesite culturesite.; format dfseq inf.;
format InfecConfirm siteblood SiteCNS SiteUT SiteCardio SiteLowerResp  SiteGI SiteSurgical SiteOther yesno.;




run;


ods rtf close;
quit;

