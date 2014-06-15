

proc sql;

create table results as
select a.* ,b.*
from sampleresults as a,
group as b
where a.patientid =b.id;

quit;

data a;
set results;

if smearpositive = 1 then afb_new =11;
if smearpositive= 2 then afb_new =12;
if smearpositive= 3 then afb_new =13;
if smearpositive= 4 then afb_new =14;

if smearnegative= 1 then afb_new =1;
if smearnegative= 2 then afb_new =2;


if culturepositive = 1 then culturepositive_new =11;
if culturepositive= 2 then culturepositive_new =12;
if culturepositive= 3 then culturepositive_new =13;
if culturepositive= 4 then culturepositive_new =14;
if culturepositive= 5 then culturepositive_new =15;
if LJ = 2 and culturepositive not in (1,2,3,4,5) then culturepositive_new=19;
if LJ = .  then lj=-9;

run;



**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 3 = OVERALL.; 
data a; 
set a; 
output; 
treat = "Overall"; 
output; 
run; 




proc format;

value afb_new
1='0_/F'
2='1-2_/300F'
11='1-9_/100F'
12='1-9_/10F'
13='1-9_/1F'
14='>9 _/1F'
19='|'
-9='Missing'
;
value $treat
'Overall'='Overall ( n/N (%) )'
'Placebo'='Group A ( n/N (%) )'
'Vitamin D'='Group B ( n/N (%) )'
;

value visit 
1='Base' 
2='Wk 2'
3='Wk 4'
4='Wk 6'
5='Wk 8'
6='Wk 12'
7='Wk 16'
;

value culturepositive
1='< 50'
2='50-100'
3='100-200'
4='200-500'
5='> 500'
-9 ='Missing';

value culturepositive_new

-9 ='Missing'
1='Neg'
2='Pos'
3='Cont'
11='< 50_colonies'
12='50-100_colonies'
13='100-200_colonies'
14='200-500_colonies'
15='> 500_colonies'
19 ='Unknown'
51='|';

value lj
1='Neg'
2='Pos'
3='Cont'
-9 ='Missing';

;
value print_group
1='by treatment'
2='Overall'
;

run;



proc freq data=a;

tables visitlist*treat/list  out = outpatients;;
run;


proc print data=a ; var afb_new visitlist ;where afb_new =.;run;




%macro TBsample ( data=, out=, var=,f=, varlabel=,gp=);


proc freq data=a;
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc sql;
create table temp as

select a.count as PatientFreq, a.visitlist,a.treat,b.count as groupFreq, b.&var as category, "&varlabel" as variable,
put(&var,&f) as category2
from outpatients as a right join
outfreq_&var as b
on a.visitlist=b.visitlist and a.treat=b.treat

order by treat, visitlist,&var ;
quit;

data temp; set temp (rename=(&var=category));

run;

%if &gp=1 %then %do;
data AllVarFreq; set temp;

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq from temp;

drop table temp;  drop table outfreq_&var;

quit;%end;

%mend TBsampele;

%TBsample ( data=, out=, var=afb_new,f=afb_new., varlabel=AFB smear test,gp=1);
%TBsample ( data=, out=, var=lj,f=lj., varlabel=AFB culture test,gp=2);
%TBsample ( data=, out=, var=culturepositive_new,f=culturepositive_new., varlabel=Positive culture test,gp=3);


data AllVarFreq ; set AllVarFreq; 
percent = round((groupFreq/PatientFreq)*100,.1);
pipe='|';

stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || "(" || compress(Left(trim(percent)))|| "%)" ;
stat2=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || " " || compress(Left(trim(percent)))|| "%" ;


if category=. then category =-9;


if treat='Overall' then print_group =2;

if treat='Placebo' then print_group =1;
if treat='Vitamin D' then print_group =1;

label print_group='Group';

format treat $treat.;
run;

proc sql;
create table AllVarFreq2 as
select * from AllVarFreq
order by   print_group, variable , treat, visitlist, category asc;
quit;



%macro AddPipe();
%do i= 1 %to 7;
proc sql;

insert into allvarfreq2 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Placebo',%eval(&i),'AFB smear test',19,'19','|','|',1);

insert into allvarfreq2 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Vitamin D',%eval(&i),'AFB smear test',19,'19','|','|',1);

insert into allvarfreq2 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Overall',%eval(&i),'AFB smear test',19,'19','|','|',2);
quit;

%end;
%mend AddPipe();
%AddPipe();

proc sql;
create table AllVarFreq2 as
select * from AllVarFreq2
order by  print_group,variable , treat, visitlist, category asc;
quit;


options nodate  orientation = landscape; 

ods rtf file = "c:\tb_afb2.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "Table 3: AFB smear test results ";

Title /*'~S={leftmargin = 2.25in font = ("arial",11pt, bold) just = left}'*/
'Table 3: AFB smear test results by groups ';
*footnote '~S={leftmargin = 2.25in font = ("arial",9pt) just = left}'
*'~{super *}Poisson';

proc report data=allvarfreq2 nowindows missing
headline  headskip pspace=1 split='_'

/*style(report) = { cellpadding =1pt
cellspacing = 0pt outputwidth=9.25in  pretext="\fs22 \b
&Title. \b0 {\line} "
frame = hsides 
rules = groups } */
style(header) = {font = ("arial",9pt)
background = white }
style(column) = {font = ("arial",9pt)just=left } ;
;

where variable='AFB smear test';
by print_group;
column  variable  visitlist   treat   , (category , (stat)  )  dummy ;

define variable / group   width=15   style(column)=[font_size=7pt just=left]  'Variable ';

define visitlist / group order=data left   width=15   style(column)=[font_size=7pt just=left]  'Visit ';

define treat / across center   width=15   style(column)=[font_size=7pt ] '' ;
*define pipe /  left  '' style(column)=[font_size=6pt];

define category / across center order=internal width=15   style(column)=[font_size=7pt ] '' ;

define stat/  center   style(column)={font_size=7pt   just=center }  ' ' ;;
define dummy/ noprint;




format category afb_new.;
format visitlist visit.;
format treat  $treat.;
format print_group  print_group.;
/*
compute before variable;
line ' ';
endcomp;

compute after visitlist;
line '';
endcomp; */

run;


*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;

/* culture table */

data allvarfreq3; set allvarfreq2;

if variable = 'Positive culture test' and category =-9 then delete;

run;

data allvarfreq3; set allvarfreq3;
if variable = 'Positive culture test' then variable ='AFB culture test'; run;


%macro AddPipe();
%do i= 1 %to 7;
proc sql;

insert into allvarfreq3 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Placebo',%eval(&i),'AFB culture test',51,'|','|','|',1);

insert into allvarfreq2 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Vitamin D',%eval(&i),'AFB culture test',51,'|','|','|',1);

insert into allvarfreq2 ( treat, visitlist,variable, category, category2, stat,stat2,print_group)
values ('Overall',%eval(&i),'AFB culture test',51,'|','|','|',2);
quit;

%end;
%mend AddPipe();
%AddPipe();

proc sql;
create table AllVarFreq3 as
select * from AllVarFreq3
order by  print_group, variable , treat, visitlist, category asc;
quit;


data AllVarFreq3_2; set AllVarFreq3; 
if category=51 then delete;
run;

proc sql;
create table AllVarFreq3_2 as
select * from AllVarFreq3_2
order by  print_group, visitlist,treat,variable ,   category asc;
quit;


ods escapechar = '~';

options nodate  orientation = landscape; 

ods rtf file = "c:\tb_afb4.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "Table 4: AFB culture test results by groups ";

Title 'Table 4: AFB culture test results by groups ';

proc report data=allvarfreq3_2 nofs 
style(header) =[just=left]  split='_'    headline  headskip contents=""

/**/;
;
where variable='AFB culture test' ;
by print_group;
column  variable  visitlist   treat   , (category , (stat2  )  )  dummy ;

define variable / group        'Variable ' style(column)=[font_size=7pt ];

define visitlist / group order=data    style(column)=[font_size=7pt ]   'Visit ';

define treat / across center      '' style(column)=[font_size=7pt ];
*define pipe /  left  '' style(column)=[font_size=6pt];

define category / across center order=data       style(column)=[font_size=7pt ] '' ;

define stat2/  center     style(column)=[font_size=7pt ]' ' ;
define dummy/ noprint;


*format category afb_new.;
format visitlist visit.;
format treat  $treat.;
format print_group  print_group.;
format category  culturepositive_new.;


compute before variable;
line ' ';
endcomp;

compute after visitlist;
line ' ';
endcomp;

run;
*ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


