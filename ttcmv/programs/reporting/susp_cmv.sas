%include "&include./annual_toc.sas";

*%include "style.sas";

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
3="NS_( n=&size3)"
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


proc sql;

/*
create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where (Enrollmentdate is not null ) and a.id not in (3003411,3003421);

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


proc sql;


select compress(put(count (*),3.0)) into :total0  from enrolled ;
select compress(put(count (*),2.0)) into :total1  from enrolled  where center=1;
select compress(put(count (*),2.0)) into :total2  from enrolled  where center=2;
select compress(put(count (*),2.0)) into :total3  from enrolled  where center=3;


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
( select id from cmv.endofstudy where reason In (1,2,3,6) ) as b
on a.id=b.id; 

quit;




data sus_cmv; set cmv.sus_cmv; 
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

treat=center;
visitlist=dfseq; 


sus_cmv=1;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Group A, 2 = Group B, 
**** AND 0 = OVERALL.; 
data a; 
set sus_cmv;
 
output; 
center = 0; treat=0; 
output; 
run;




%macro getstat ( data=, out=, var=,f=, varlabel=,gp=,subheader=);

%if &subheader=0 %then %do;
data x; set &data; if &var=99 or &var=999 then delete; run;

proc freq data=x;where &var not in (99 ,999);
tables visitlist*treat*&var/list  out = outfreq_&var;;

run;

proc freq data=x;
where &var not in (99 ,999);
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

data temp; length variable $ 100; length var_name $ 100; set temp;
variable="&varlabel"; 
class_descript = put(category , &f);
var_name="&var";


run;

%if &gp=1 %then %do;
data AllVarFreq; set temp; group=&gp; subheader=&subheader;class_descript = put(category , &f);var_name="&var";

run;

%end;

%if &gp>1 %then %do;
proc sql;
create table AllVarFreq as
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq , group , subheader ,class_descript ,var_name from AllVarFreq
union
select variable, treat, visitlist, category, category2,groupFreq, PatientFreq ,group, &subheader ,class_descript, var_name  from temp;

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


%getstat ( data=a, out=, var=sus_cmv,f=YN., varlabel=CMV cases  ,gp=1,subheader=0);
%getstat ( data=a, out=, var=sus_cmv,f=YN., varlabel=\n\S={font_weight=bold }Suspected CMV cases  ,gp=0,subheader=1);


