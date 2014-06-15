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

data ivh; set cmv.ivh; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.); 
visitlist=dfseq; treat=center;
run;


**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data a; 
set ivh; 
output; 
center = 0; treat=0; 
output; 
run;



proc sql;
select compress(put(count (*),2.0)) into :size0 from enrolled ;
select compress(put(count (*),2.0)) into :size1 from enrolled where center=1;
select compress(put(count (*),2.0)) into :size2 from enrolled where center=2;
select compress(put(count (*),2.0)) into :size3 from enrolled where center=3;
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

value center 
0="Overall ( n=&size0)"
2="Grady( n=&size2)"
1="EUHM ( n=&size1)"
3="NS( n=&size3)"
4="CHOA Egleston"
5="CHOA Scottish"
8="BU"
;

value treat 
0='Overall'
2='Grady'
1='EUHM'
3='NS'
4='CHOA Egleston'
5='CHOA Scottish'
8='Overall'
;
value YN
1="Yes"
0="No"
999="Missing";

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

%getstat ( data=, out=, var=Apnea,f=YN., varlabel=Signs of Apnea,gp=1);
%getstat ( data=, out=, var=Bradycardia,f=YN., varlabel=Signs of Bradycardia,gp=2);
%getstat ( data=, out=, var=Cyanosis,f=YN., varlabel=Signs of Cyanosis,gp=3);
%getstat ( data=, out=, var=Weaksuck,f=YN., varlabel=Signs of Weak Suck,gp=4);
%getstat ( data=, out=, var=Highcry,f=YN., varlabel=High Pitched Cry,gp=5);
%getstat ( data=, out=, var=Seizures,f=YN., varlabel=Seizures,gp=6);
%getstat ( data=, out=, var=Anemia,f=YN., varlabel=Anemia,gp=7);
%getstat ( data=, out=, var=Swelling,f=YN., varlabel=Swelling of fontanelles,gp=8);
%getstat ( data=, out=, var=RadiographFind,f=YN., varlabel=Radiograph,gp=9);
%getstat ( data=, out=, var=Indomethacin,f=YN., varlabel=Indomethacin given,gp=10);
%getstat ( data=, out=, var=AntiConvulsant,f=YN., varlabel=AntiConvulsant given ,gp=11);

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
order by  group , treat, visitlist, category asc;
quit;


options nodate orientation=portrait;
ods rtf   file = "&output./annual/&ivh_summary_file.IVH_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&ivh_summary_title : IVH summary";

title  justify = center "&ivh_summary_title : IVH summary ";

title2  justify = center "Overall (n=&size0) EUHM (n=&size1) Grady (n=&size2) NS (n=&size3) ";
proc report data=AllVarFreq nofs   style(header) = [just=Left] split="_" missing headline headskip contents = "" ;


column  variable     treat   category ,(stat) dummy ;

define variable / group  order=data    style(column)=[just=left cellwidth=1.0in]  'Outcome ';

define treat / group order=data center      style(column)=[just=left cellwidth=0.7in] 'Site' ;
*define visitlist /  group order=data left     style(column)=[just=left cellwidth=2.5in]  'DOL ';


define category /across   center order=internal    style(column)=[just=left cellwidth=1.5in] '' format=YN. ;

define stat/  center   style(column)=[just=left cellwidth=2in]  'n/N (%) ' ;;
define dummy/ noprint;



format visitlist dfseq.;
format treat  treat.;


compute after variable;
     line ' ';
  endcomp;


run;

ods rtf close;
quit;


