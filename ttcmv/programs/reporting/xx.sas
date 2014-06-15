
%include "&include./monthly_toc.sas";
%include "&include./annual_toc.sas";


proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;


create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
( select * from cmv.endofstudy where reason in (1,2,3,6) )as b
on a.id=b.id;


create table endofstudy as
select a.id, b.*
from cmv.valid_ids as a right join
cmv.endofstudy as b
on a.id=b.id;

quit;

data endofstudy; set endofstudy;

where reason in (1,2,3,6);
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
run;



proc sql;

create table rbctx as
select a.id, b.*
from endofstudy as a left join
cmv.rbctx as b
on a.id=b.id;

create table rbctx as
select * from rbctx where donorunitid is not null;
 

create table rbctx as
select a.* ,b.DateDonated
from rbctx as a left join
 (  select distinct donorunitid, DateDonated
from cmv.plate_001_bu  ) as b 
on a.donorunitid=b.donorunitid;

quit;

data rbctx ; set rbctx;

vol_wt = rbcvolumeTransfused / BodyWeight;
age_of_blood = (DateTransfusion - DateDonated )+1;

run;

data rbctx; set rbctx;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
studygroup=input(substr(id2, 1, 1),1.);
run;

data rbctx; 
set rbctx; 
 
output; 
center = 0; studygroup=0;
output; 
run;

proc sql;
create table storage as
select max(age_of_blood) as age_of_blood_max , donorunitid,center
from rbctx
group by donorunitid, center; quit;

/*************************************************************/
/*********univariate_stat macro definition *****************/
%macro univariate_stat (data= ,var = , label = , group=,stattype=, format=,subheader=); 

%if &subheader=0 %then %do;
data &data; set &data; if &var=-99 then &var=.;run;


proc sort data=&data;  by center; run;


proc univariate data=&data ;
by center;
var &var  ;
output out=&var mad=mad  median =median n=n; 


run;

data &var; 
set &var; 
length variable $ 200; 
length disp_point $ 50; 

group =&group; 


%if &stattype = 1 %then %do;

variable = "&label \n Median [MAD]  N";
disp_point = compress(put(median, &format)) || " [" || compress(put(mad, &format)) || "] , " || compress(put(n,4.0))  ; 


%end;


%else %if &stattype = 2 %then %do;

variable = "&label \n  N";
disp_point =  compress(put(n,4.0))  ; 


%end;

run;

* stack results; 
data univ_table; length variable $ 100;  subheader=&subheader;
%if &group=1 %then %do; 
		set &var;  


%end; 
%else %do; 
		set univ_table 
					&var; 
		%end;
run; 

%end; * endi of top if ;

%if &subheader eq 1 %then %do;
		proc sql;
				insert into univ_table(variable, group,center)
				values ("&label",&group,0);

		quit;

%end;

proc sql; drop table &var; quit;
%mend;


/*********univariate_stat macro calls *****************/
%univariate_stat (data=rbctx ,var =center  , label =	Total number of transfusions , group=1,stattype=2, format=6.1,subheader=0);
%univariate_stat (data=rbctx ,var =center  , label =\n\S={font_weight=bold }Data on RBC transfusions , group=0,stattype=2, format=6.1,subheader=1);
%univariate_stat (data=rbctx ,var =vol_wt  , label = 	Volume (mL/kg) per tranfusion , group=2,stattype=1, format=6.3,subheader=0); 
%univariate_stat (data=rbctx ,var =age_of_blood  , label =	Average length of storage(days) , group=3,stattype=1, format=6.1,subheader=0); 

%univariate_stat (data=storage ,var =age_of_blood_max  , label =  Longest length of storage(days) , group=4,stattype=1, format=6.1,subheader=0); 

proc sql;
select compress(put(count(*),2.0)) into: center0 from endofstudy ;
select compress(put(count(*),2.0)) into: center1 from endofstudy where center=1;
select compress(put(count(*),2.0)) into: center2 from endofstudy where center=2;
select compress(put(count(*),2.0)) into: center3 from endofstudy where center=3;


create table univ_table as
select * from univ_table
order by group,center;


quit;

proc format ;

value center 
0="Overall_N=&center0 "
2="Grady_N=&center2 "
1="EUHM_N=&center1 "
3="Northside_N=&center3 "
4="CHOA Egleston"
5="CHOA Scottish"
;

value last
0="."
1="Total:";
run;

/*************************************************************/
/*********Need this in annual *****************/

ods escapechar='\';
options nodate orientation=portrait;
ods rtf   file = "&output./annual/&combo_tx_summary_file.a_rbc_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&rbc_mad_summary_title : Data on red-cell transfusions for LBWI who completed study";

title  justify = center "&rbc_mad_summary_title : Data on red-cell transfusions for LBWI who completed study ";
footnote "";

proc report data=univ_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;


column      variable    center ,  (disp_point  )  dummy;


define variable/ group  order=data   Left  style(column) = [just=center cellwidth=2in]   "  " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=1.5in] ""  ;

define disp_point/center      style(column) = [just=center ] " "  left ;
*define pipe/center    "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

format center center.;


run;
ods rtf close;
