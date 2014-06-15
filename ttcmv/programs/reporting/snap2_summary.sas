%include "&include./annual_toc.sas";

*%include "style.sas";

proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
cmv.endofstudy as b
on a.id=b.id;

quit;


data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data snap2; set cmv.snap2; where dfseq <=63;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;



**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data a; 
set snap2; 
output; 
center = 0; treat=0; 
output; 
run;




proc format;

value MeanBP
19="<20"
9="20-29"
0=">=30"
99="Missing"
999="Missing"
;


value LowestTemp
15="<35"
0=">35.5"
8="35-35.5"
99="Missing"
999="Missing"
;

value uop
18="<0.1"
5="0.1 - 0.9"
0=">=1"
99="Missing"
999="Missing"
;

value lowph
16="<7.1"
7="7.1 - 7.19"
0=">=7.2"
99="Blank"
999="Missing"
;



value seizures
0="No"
19="Yes"
;

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

value center 
0='Overall'
2='Grady'
1='EUHM'
3='Northside'
4='CHOA Egleston'
5='CHOA Scottish'
8='BU'
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


run;

proc freq data=a;

tables visitlist*treat/list  out = outpatients;;
run;



%macro getstat ( data=, out=, var=,f=, varlabel=,gp=);


data a; set a; if &var=99 or &var=999 then &var=999; run;
proc freq data=a;
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc sql;
create table temp as

select a.count as PatientFreq, a.visitlist,a.treat,b.count as groupFreq, b.&var as category, "&varlabel" as variable,
put(&var,&f) as category2, &gp as group
from outpatients as a right join
outfreq_&var as b
on a.visitlist=b.visitlist and a.treat=b.treat

order by treat, visitlist,&var ;
quit;



run;

%if &gp=1 %then %do;
data AllVarFreq; set temp; group=&gp;

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq , group from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq ,group from temp;

drop table temp;  drop table outfreq_&var;

quit;%end;



%mend getstat;

%getstat ( data=, out=, var=MeanBP,f=MeanBP., varlabel=Mean Arterial Pressure (mm Hg),gp=1);
%getstat ( data=, out=, var=LowestTemp,f=LowestTemp., varlabel=Lowest Temp (C),gp=2);
%getstat ( data=, out=, var=Seizures,f=seizures., varlabel=Multiple Seizures ,gp=3);
%getstat ( data=, out=, var=uop,f=uop., varlabel=Urine Output (ml/kg/hr) ,gp=4);
%getstat ( data=, out=, var=Lowph,f=lowph., varlabel=Lowest pH  ,gp=5);

data AllVarFreq ; set AllVarFreq; 

if category=. then category=99;
percent = round((groupFreq/PatientFreq)*100,.1);
pipe='|';

stat=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || "(" || compress(Left(trim(percent)))|| ")" ;
stat2=   compress(Left(trim(groupFreq))) || "/"  || compress(Left(trim(PatientFreq)))  || " " || compress(Left(trim(percent)))|| "%" ;


run;


proc sql;
create table AllVarFreq as
select * from AllVarFreq
order by  variable , treat, visitlist, category asc;
quit;

%macro CreateReport(titleindex=, title=, categorytitle= ,group=,format=);

ods noproctitle proclabel "&snap2_summary_title &titleindex: SNAP2 component - &title";

title  justify = center "&snap2_summary_title &titleindex: SNAP2 component - &title ";


proc report data=AllVarFreq nofs   style(header) = [just=left] split="_" missing headline headskip contents = "" ;
where group=&group;
column  /*variable*/     treat  visitlist  category ,(stat) dummy ;

*define variable / group   width=15   style(column)=[just=center cellwidth=1in]  'Variable ';

define treat / group order=data center      style(column)=[just=left ] 'Site' ;
define visitlist /  group order=data left   width=15   style(column)=[just=left cellwidth=0.8in]  'DOL ';


define category /across   center order=internal width=15   style(column)=[just=center cellwidth=1.2in] "&categorytitle" format=&format ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;

define dummy/ noprint;


compute before treat;
line ' ';
endcomp;

format category NATTestResult.;
format visitlist dfseq.;
format treat  treat.;




run;
%mend CreateReport;


options nodate orientation=portrait;
ods rtf   file = "&output./annual/&snap2_summary_file.snap2_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;


%CreateReport(titleindex=a, title=Longitudinal Mean Aerterial BP (mm Hg) for LBWI by site, categorytitle=Mean Arterial BP (mm Hg) , group=1,format=MeanBP.);

%CreateReport(titleindex=b, title=Longitudinal Lowest Temp (C) for LBWI by site, categorytitle=Lowest Temperature (C) , group=2,format=LowestTemp.);

%CreateReport(titleindex=c, title=Occurrence of Multiple Seizures for LBWI by site, categorytitle=Multiple Seizures, group=3,format=seizures.);
%CreateReport(titleindex=d, title=Longitudinal Urine Output(mL/kg/hr) for LBWI by site, categorytitle=Urine Output(mL/kg/hr), group=4,format=uop.);
%CreateReport(titleindex=e, title=Longitudinal Lowest Serum pH for LBWI by site, categorytitle=Lowest Serum pH, group=5,format=lowph.);


ods rtf close;
quit;





