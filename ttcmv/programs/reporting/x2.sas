
%include "&include./annual_toc.sas";

/******* beeram table 2 *************/


proc sql;

create table birth2 as
select a.*
from birth as a right join
(select  distinct(id) as id from rbctx) as b
on a.id =b.id;
quit;
data birth2; set birth2; where studygroup > 0;
birthweight_cat=0;
if birthweight > 400 and birthweight <=750 then birthweight_cat=1;
if birthweight > 750 and birthweight <=1000 then birthweight_cat=2;
if birthweight > 1000 and birthweight <=1250 then birthweight_cat=3;

visitlist=1;
studygroup=birthweight_cat;
run;

data a; set birth2 ; run;

proc format;
value visit
1='1'
;
run;

/* macro */
%macro cont_vars (data= ,var = , label = , group=,stattype=, format=,subheader=); 

%if &subheader=0 %then %do;
data &data; set &data; if &var=-99 then &var=.;run;
proc means data = &data fw=5 maxdec=1 nonobs n mean stddev median min max q1 q3;
 
class studygroup visitlist; 
var &var; 
ods output summary = &var; 
run; 
data &var; 
set &var; 
length variable $ 200; 
length disp_visit $ 50; 
length disp $ 60; 
* fix variable names; 
n = &var._n; 
mean = &var._mean; 
std_dev = &var._stddev; 
median = &var._median; 
min = &var._min; 
max = &var._max; 
q1 = &var._q1; 
q3 = &var._q3; 
group =&group; 
* format for display ; 
disp_n = compress(put(n, 4.0)); 

%if &stattype = 1 %then %do;
disp_5point = compress(put(median, &format)) || " (" || compress(put(q1, &format)) || ", " || compress(put(q3, &format)) || ")" ; 
%end;


%else %if &stattype = 2 %then %do;
disp_5point =  compress(put(mean, &format)) || "(" || compress(put(std_dev, &format)) || ") [" || compress(put(min, &format)) || " , " || compress(put(max, &format)) || "] " ; 
%end;


%else %if &stattype = 3 %then %do;
disp_5point = compress(put(median, &format)) || " (" || compress(put(q1, &format)) || ", " || compress(put(q3, &format)) || ")" 
|| "[" || compress(put(min, &format)) || " , " || compress(put(max, &format)) || "] (" || compress(put(mean, &format)) || "," || compress(put(std_dev, &format)) || ")"; 

%end;

%else %if &stattype = 4 %then %do;
disp_5point =   compress(put(mean, &format)) || "(" || compress(put(std_dev, &format)) || ")"; 

%end;

%else %if &stattype = 5 %then %do; 
disp_5point =   compress(put(mean, &format)) || "(" || compress(put( (mean/52)*100, &format)) || "%)"; ; 

%end;

if (median <> .) then disp = trim(disp_5point) || " " || disp_n; 

else disp = "(no data)";

disp_visit = put(visitlist, visit.); 
* add row headers ; 



%if &stattype = 1 %then %do;

variable = "&label Median (q1,q3) N"; 
%end;


%else %if &stattype = 2 %then %do;

variable = "&label  Mean(std) (min,max) N"; 
%end;


%else %if &stattype = 3 %then %do;

variable = "&label  Median(q1,q3) [ Mean(std)] (min,max) N"; 
%end;

%else %if &stattype = 4 %then %do;

variable = "&label   Mean(std)  N"; 
%end;

%else %if &stattype = 5 %then %do;

variable = "&label   N"; 
%end;


drop &var._n &var._mean &var._stddev &var._median &var._min &var._max &var._q1 &var._q3; 
run;
data gp1 (keep = variable disp_visit visitlist site1 ); 
set &var; where StudyGroup=1; 
site1 = disp; 
run; 
data gp2 (keep = variable disp_visit visitlist site2);; 
set &var; where StudyGroup=2; 
site2 = disp; 
run; 
data gp3 (keep = variable disp_visit visitlist site3);; 
set &var; where StudyGroup=3; 
site3 = disp; 
run; 
/*
data gp0 (keep = variable disp_visit visitlist site0);; 
set &var; where StudyGroup=0; 
site0 = disp; 
run; 
*/

proc sql;

create table &var as
select variable, disp_visit, visitlist,  site1 as disp, 1 as center from gp1
union
select variable, disp_visit, visitlist,  site2 as disp, 2 as center from gp2
union
select variable, disp_visit, visitlist,  site3 as disp, 3 as center from gp3
/*union
select variable, disp_visit, visitlist,  site0 as disp, 0 as center from gp0;
*/
quit;

data &var; length variable $ 100; set &var; group =&group; 

*variable="&label"; 
%if &stattype = 1 %then %do;

variable = "&label - Median (q1,q3) N"; 
%end;


%else %if &stattype = 2 %then %do;

variable = "&label  - Mean(std) (min,max) N"; 
%end;


%else %if &stattype = 3 %then %do;

variable = "&label  -Median(q1,q3) [ Mean(std)] (min,max) N"; 
%end;

%else %if &stattype = 4 %then %do;

variable = "&label\n Mean(std) N"; 
%end;

%else %if &stattype = 5 %then %do;

variable = "&label\n  N (%)"; 
%end;

run;
* stack results; 
data cont_table; length variable $ 100;  subheader=&subheader;
%if &group=1 %then %do; 
set &var;  




%end; 
%else %do; 
set cont_table 
&var; 
%end;
run; 

%end; * endi of top if ;
%if &subheader eq 1 %then %do;
proc sql;
insert into cont_table(variable, group)
values ("&label",&group);

quit;

%end;

proc sql; drop table &var; 
drop table gp1; drop table gp2; drop table gp3;drop table gp0; run;quit ;
%mend cont_vars; 



%cont_vars(data=a ,var=BodyWeight, label =Body Weight(gms), group=1, stattype= 4 ,format=4.1,subheader=0);

%cont_vars(data=a ,var= gestage, label =Gestational age (weeks), group=2, stattype=4 ,format=4.1,subheader=0);


proc sql;
create table rbctx2 as 
select a.*,b.birthweight_cat 
from 
rbctx as a left join
birth2 as b
on a.id=b.id;


quit;

data rbctx2; set rbctx2; 


visitlist=1;
studygroup=birthweight_cat;
run;

proc sql;
create table rbctx3 as
select id, birthweight_cat, count(*) as total_tx
from rbctx2 
group by id, birthweight_cat;

quit;

data rbctx3; set rbctx3; 


visitlist=1;
studygroup=birthweight_cat;
run;

proc sql;
create table rbctx4 as
select  birthweight_cat, count(distinct(id)) as lbwi_transfused
from rbctx2 
group by  birthweight_cat;

quit;

data rbctx4; set rbctx4; 


visitlist=1;
studygroup=birthweight_cat; center=birthweight_cat;
run;

%cont_vars(data=rbctx2 ,var=vol_wt , label =Volume (mL/kg) per Tx, group=3, stattype=4 ,format=4.1,subheader=0);
%cont_vars(data=rbctx3 ,var=total_tx , label =RBC Tx per LBWI, group=4, stattype=4 ,format=4.0,subheader=0);
%cont_vars(data=rbctx4 ,var=lbwi_transfused , label =Num of LBWI Tx, group=5, stattype=5 ,format=4.0,subheader=0);

proc format;
value center
1='400- 750'
2='751-1000'
3='1001-1250'
;

run;


ods escapechar='\';

options nodate orientation=portrait;
ods rtf   file = "&output./annual/&combo_tx_summary_file.beeram_summary.rtf" style=journal   

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "RBC tx for LBWI who completed the study";

title1  justify = center "RBC tx for LBWI who completed the study";
title2 "";

footnote " ";
proc report data=cont_table nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;
where group > 1;

column   center variable ,(disp) dummy ;



define center / group order=data center      style(column)=[just=left cellwidth=1in] 'Birth weight group' format=center. ;

define variable / across  order=data    style(column)=[just=left cellwidth=1.5in]  '';
define disp/  center   style(column)=[just=left cellwidth=1in]  ' ' ;;
define dummy/ noprint;

compute after center;
     line ' ';
  endcomp;




run;
run;
ods rtf close;

