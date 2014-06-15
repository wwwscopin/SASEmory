%include "&include./annual_toc.sas";

*%include "style.sas";

proc sql;

/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id

where (Enrollmentdate is not null ) 
and a.id not in (3003411,3003421);

*/

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

quit;



data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data eos; set cmv.endofstudy;where reason In (1,2,3,6); 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;

data bpd; set cmv.bpd; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;


 
data a; 
set bpd; 
output; 
center = 0; treat=0; 
output; 
run;






proc sql;
create table samplesize as
select compress(put(count (*),3.0)) as total /*into :size0 */ , 0 as center from enrolled 
union

select compress(put(count (*),3.0))as total /* into :size1 */, 1 as center from enrolled where center=1
union

select compress(put(count (*),3.0))as total  /*into :size2 */, 2 as center from enrolled where center=2
union
select compress(put(count (*),3.0)) as total /*into :size3 */, 3 as center from enrolled where center=3;

create table samplesize2 as
select compress(put(count (*),2.0))as bpd   /*into :size0_ivh */, 0 as center from a where center=0
union

select compress(put(count (*),2.0)) as bpd /*into :size1_ivh */, 1 as center from a where center=1
union
select compress(put(count (*),2.0)) as bpd /*into :size2_ivh */, 2 as center from a where center=2
union
select compress(put(count (*),2.0)) as bpd /*into :size3_ivh */, 3 as center from a where center=3;

create table samplesize3 as
select a.total,a.center, b.bpd
from samplesize as a left join samplesize2 as b 
on a.center =b.center;

quit;

data samplesize3; set samplesize3;
percent = round((bpd/total)*100,.1);
stat=   compress(Left(trim(bpd))) || "/"  || compress(Left(trim(total)))  || " (" || compress(Left(trim(percent)))|| " % )" ;
run;

proc sql;

select stat into :size0_bpd  from samplesize3  where center=0;
select stat into :size1_bpd from samplesize3 where center=1;

select stat into :size2_bpd from samplesize3 where center=2;

select stat into :size3_bpd  from samplesize3 where center=3;

select compress(Left(trim(bpd))) into:bpd_overall from  samplesize3  where center=0;


select compress(Left(trim(total))) into :size0  from samplesize3  where center=0;
select compress(Left(trim(total))) into :size1 from samplesize3 where center=1;

select compress(Left(trim(total))) into :size2 from samplesize3 where center=2;

select  compress(Left(trim(total))) into :size3  from samplesize3 where center=3;


select count(*)  into :eos0  from eos  ;
select count(*) into :eos1  from eos  where center=1;
select count(*) into :eos2  from eos  where center=2;
select count(*) into :eos3  from eos  where center=3;
quit;



proc format;

value DFSEQ
1='DOB'
4='4  '
14='14 '
21='21 '
28='28 '
40='40 '
60='60 '
63='90/EOS'
;

value visit
1='DOB'
4='4  '
14='14 '
21='21 '
28='28 '
40='40 '
60='60 '
63='90/EOS'
;

value center 
0="Overall_( n=&size0)"
2="Grady_( n=&size2)"
1="EUHM_( n=&size1)"
3="Northside_( n=&size3)"
4="CHOA Egleston"
5="CHOA Scottish"
8="BU"
;

value treat 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
8='Overall'
;
value YN
1="Yes"
0="No"
-99=Missing;
;

run;
/*
proc freq data=a;

tables visitlist*treat/list  out = outpatients;;
run;
*/


%macro getstat ( data=, out=, var=,f=, varlabel=,gp=,subheader=);

%if &subheader=0 %then %do;
data x; set &data; if &var=99 or &var=999 or &var=-99 then delete; run;

proc freq data=x;where &var not in (99 ,999,-99);
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc freq data=x;
where &var not in (99 ,999,-99);
tables visitlist*treat/list  out = outpatients;;
run;

proc sql;
create table temp as

select a.count as PatientFreq, a.visitlist,a.treat,b.count as groupFreq, b.&var as category, "&varlabel"  as variable2 ,
put(&var,&f) as category2, &gp as group
from outpatients as a right join
outfreq_&var as b
on a.visitlist=b.visitlist and a.treat=b.treat

order by treat, visitlist,&var ;
quit;



run;

data temp; length variable $ 100; set temp;
variable="&varlabel"; 
class_descript = put(category , &f);


run;

%if &gp=1 %then %do;
data AllVarFreq; set temp; group=&gp; subheader=&subheader;class_descript = put(category , &f);

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq , group , subheader ,class_descript from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq ,group, &subheader ,class_descript from temp;

drop table temp;  drop table outfreq_&var; drop table x; drop table outpatients;

quit;%end;

%end; * endi of top if ;
%if &subheader eq 1 %then %do;
proc sql;
insert into AllVarFreq(variable, group,category,subheader)
values ("&varlabel",&gp,0, 1);

quit;

%end;


%mend getstat;



%getstat ( data=a, out=, var=isOxygenDol28,f=YN., varlabel=Ventilation for >=28 days with Oxygen >= 21%  ,gp=1,subheader=0);
%getstat ( data=a, out=, var=isOxygenDol28,f=YN., varlabel=\S={font_weight=bold }BPD Definition  ,gp=0,subheader=1);

%getstat ( data=a, out=, var=isOxygenDol28,f=YN., varlabel=\n\S={font_weight=bold}If LBWI has BPD (n= &bpd_overall),gp=2,subheader=1);
%getstat ( data=a, out=, var=oxygen_at_36,f=YN., varlabel=Currently at 36 weeks/56 days require Oxygen? ,gp=3,subheader=0);
%getstat ( data=a, out=, var=require_ppv,f=YN., varlabel=Currently at 36 weeks/56 days require PPV/NCPAP? ,gp=4,subheader=0);

%getstat ( data=a, out=, var=isOxygenDol28,f=YN., varlabel=\n\S={font_weight=bold }Hx Resp Complications,gp=6,subheader=1);


%getstat ( data=a, out=, var=resp_distress,f=YN., varlabel=Clinical symptoms of Resp Distress within first 24 hrs of life ,gp=7,subheader=0);
%getstat ( data=a, out=, var=require_ppv,f=YN., varlabel=Require PPV/NCPAP ,gp=8,subheader=0);
%getstat ( data=a, out=, var=req_ppv,f=YN., varlabel=Req O2 or PPV for > 5 hrs within first  24 hrs of life ,gp=9,subheader=0);
%getstat ( data=a, out=, var=surfactant,f=YN., varlabel=Receive Surfactant ,gp=10,subheader=0);
%getstat ( data=a, out=, var=pneumothoax,f=YN., varlabel=Signs of Pneumothoax ,gp=11,subheader=0);
%getstat ( data=a, out=, var=pulhemmorhage,f=YN., varlabel=Signs of Pul Hemmorhage ,gp=12,subheader=0);

%getstat ( data=a, out=, var=isOxygenDol28,f=YN., varlabel=\n\S={font_weight=bold }Treatment,gp=13,subheader=1);

%getstat ( data=a, out=, var=medsreceived,f=YN., varlabel=Medical Treatment received ,gp=14,subheader=0);

data AllVarFreq ; set AllVarFreq; 

if category=. then category=-99;
if group =1 and treat =0 then PatientFreq=&eos0;
else if group =1 and treat =1 then PatientFreq=&eos1;
else if group =1 and treat =2 then PatientFreq=&eos2;
else if group =1 and treat =3 then PatientFreq=&eos3;

percent = round((groupFreq/PatientFreq)*100,.1);
pipe='|';



stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || "(" || compress(Left(trim(percent)))|| ")" ;
stat2=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || " " || compress(Left(trim(percent)))|| "%" ;

if subheader eq 1 then do;stat=.; stat2=.; end;

/* keep only overall */
*if group GT 1  and subheader = 0 and treat GT 0 then delete;
run;


proc sql;
create table AllVarFreq as
select * from AllVarFreq
order by  group , treat, visitlist, category desc;
quit;


/* now get cont */
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

%if &stattype eq 1 %then %do;
disp_5point = compress(put(median, &format)) || " (" || compress(put(q1, &format)) || ", " || compress(put(q3, &format)) || ")" ; 
%end;


%else %if &stattype eq 2 %then %do;
disp_5point =  compress(put(mean, 4.1)) || "(" || compress(put(std_dev, 4.1)) || ") [" || compress(put(min, 4.1)) || " , " || compress(put(max, 4.1)) || "] " ; 
%end;


%else %if &stattype eq 3 %then %do;
disp_5point = compress(put(median, &format)) || " (" || compress(put(q1, &format)) || ", " || compress(put(q3, &format)) || ")" 
|| "[" || compress(put(min, 4.1)) || " , " || compress(put(max, 4.1)) || "] (" || compress(put(mean, 4.1)) || "," || compress(put(std_dev, 4.1)) || ")"; 

%end;

if (median ~= .) then disp = trim(disp_5point) || ", " || disp_n; 
else disp = "(no data)";
disp_visit = put(visitlist, visit.); 
* add row headers ; 

*variable = "&label";

%if &stattype = 1 %then %do;

variable = "&label Median (q1,q3) N"; 
%end;


%else %if &stattype = 2 %then %do;

variable = "&label  Mean(std) (min,max) N"; 
%end;


%else %if &stattype = 3 %then %do;

variable = "&label  Median(q1,q3) [ Mean(std)] (min,max) N"; 
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

data gp0 (keep = variable disp_visit visitlist site0);; 
set &var; where StudyGroup=0; 
site0 = disp; 
run; 


proc sql;

create table &var as
select variable, disp_visit, visitlist,  site1 as disp, 1 as center from gp1
union
select variable, disp_visit, visitlist,  site2 as disp, 2 as center from gp2
union
select variable, disp_visit, visitlist,  site3 as disp, 3 as center from gp3
union
select variable, disp_visit, visitlist,  site0 as disp, 0 as center from gp0;

quit;
/*
proc sort data = gp1; by variable visitlist; run; 
proc sort data =gp2; by variable visitlist; run; 
proc sort data =gp3; by variable visitlist; run; 
proc sort data =gp0; by variable visitlist; run; 
data &var; 
merge 
gp1 
gp2 
gp3 
gp0
; by variable visitList; 
run; */
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


run;
* stack results; 
data cont_table; length variable $ 100;  subheader=&subheader;
%if &group=1 %then %do; 
set &var;  
*variable="&label";



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
drop table gp1; drop table gp2; drop table gp3;run;quit 
%mend cont_vars; 



data a; set a;
studygroup=treat; run;

%cont_vars(data=a ,var= percentOxygen, label =  Percent oxygen needed , group=1, stattype=1 ,format=4.1,subheader=0);


data cont_table; set cont_table;
if group = 1 then group =5;

run;

proc sql;

create table AllVarFreq2 as
select variable, visitlist, treat, group, subheader, category, stat, stat2 , "cat" as stattype from AllVarFreq
union
select variable, ., center as treat, group, subheader, ., disp, disp , "con" as stattype from cont_table /*where center=0*/
order by  group , treat, visitlist, category desc;
quit;

data AllVarFreq2; set AllVarFreq2;
if subheader=1 then do; category=.;treat=0;end;
*if group >1 then treat=.; 
run;

/* end cont */

ods escapechar='\';

options nodate orientation=portrait;
ods rtf   file = "&output./annual/&bpd_summary_file.BPD_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&bpd_summary_title: Summary of Bronchopulmonary Dysplasia (BPD).";



title1  justify = center "&bpd_summary_title: Summary of Bronchopulmonary Dysplasia (BPD).";
title2 "";
/*title3  justify = left  "   LBWI with BPD - n/N (%) ";
title4 justify = left " --      Overall : &size0_bpd  ";
title5 justify = left " --      EUHM : &size1_bpd  ";
title6 justify = left " --     Grady : &size2_bpd  ";
title7 justify = left " --      NS   : &size3_bpd ";

*/

/*
proc report data=AllVarFreq2 nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;


column  variable     treat   category  stat dummy ;

define variable / group  order=data    style(column)=[just=left cellwidth=3in]  'Variable ';

define treat / group order=data center   width=15   style(column)=[just=left cellwidth=1.2in] 'Site' ;


define category /  group center order=data    style(column)=[just=left cellwidth=1in] '' format=YN. ;

define stat/  center   style(column)=[just=left cellwidth=1.5in]  'n/N (%) ' ;;
define dummy/ noprint;



format visitlist dfseq.;
format treat  center.;



run;
*/

proc report data=AllVarFreq2 nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;


column  variable        category  treat,(stat) dummy ;

define variable / group  order=data    style(column)=[just=left cellwidth=2in]  'Variable ';

define treat / across order=data center   width=15   style(column)=[just=left cellwidth=0.9in] 'Site' ;



define category /  group center order=data    style(column)=[just=left cellwidth=0.7in] '' format=YN. ;


define stat/  center   style(column)=[just=left cellwidth=1.3in]  'n/N (%) ' ;;
define dummy/ noprint;



format visitlist dfseq.;
format treat  center.;

/*
compute after subheader;
     line ' ';
  endcomp;
*/

run;




ods rtf close;
quit;


