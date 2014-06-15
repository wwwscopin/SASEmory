/*libname cmv "/ttcmv/sas/data/freeze2011.03.09";

*/
%include "&include./annual_toc.sas";
%include "&include./monthly_toc.sas";


proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth,birthweight 
from 
cmv.valid_ids as a
left join

cmv.LBWI_Demo as b
on a.id =b.id;

create table enrolled as
select a.* ,b.id as eosid
from enrolled as a 
right join
cmv.endofstudy as b
on a.id=b.id where reason in (1,2,3,6);




quit;
data enrolled; set enrolled;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
if birthweight >=1000 and birthweight <=1500 then weight_group="VL";
if birthweight < 1000 then weight_group="LL";

run;


proc sql;

create table enrolled_rbc as
select a.id, a.id2,a.center, a.DateOfBirth ,birthweight,weight_group, b.*
from enrolled as a ,
cmv.plate_031 as b
where a.id=b.id;

create table enrolled_rbc_no as
select a.id, a.id2,a.center, a.DateOfBirth ,birthweight,weight_group,b.id as tx_id
from enrolled as a left join
cmv.plate_031 as b
on a.id=b.id;

quit;

data enrolled_rbc_no; set enrolled_rbc_no; where tx_id =. ;
group_type="No Tx";
run;

proc sql;
create table enrolled_rbc as
select * from enrolled_rbc where datetransfusion is not null;
quit;

data enrolled_rbc; set enrolled_rbc;
age_tx= datetransfusion-DateOfBirth ;group_type=" Tx";
run;


/***** age at first tx *****/
proc sql;
create table tx_stat_vl as 
select id,center ,min(age_tx) as age_first_tx_min ,max(age_tx) as age_first_tx_max,
sum(rbcVolumeTransfused) as vol_tx_total, count(id) as total_tx, "VL" as weight_group
from  enrolled_rbc 
where age_tx <=30 and weight_group="VL"
group by id,center;

create table tx_stat_ll as 
select id,center ,min(age_tx) as age_first_tx_min ,max(age_tx) as age_first_tx_max,
sum(rbcVolumeTransfused) as vol_tx_total, count(id) as total_tx, "LL" as weight_group
from  enrolled_rbc 
where age_tx <=30 and weight_group="LL"
group by id,center;

quit;


data tx_stat_vl; 
set tx_stat_vl; 
 studygroup=center;
output; 
center = 0; studygroup=0;
output; 
run;

data tx_stat_ll; 
set tx_stat_ll; 
 studygroup=center;
output; 
center = 0; studygroup=0;
output; 
run;

/*************************************************************/
/*********univariate_stat macro definition *****************/
%macro univariate_stat (data= ,var = , label = , group=,stattype=, format=,subheader=,group_tx=); 

%if &subheader=0 %then %do;
data &data; set &data; if &var=-99 then &var=.;run;


proc sort data=&data;  by center; run;

data &data; set &data; if &var < 0 then &var=0;run;
proc univariate data=&data ;
by center;
var &var  ;
output out=&var mad=mad  mean=mean std=std median =median n=n min=min max=max; 


run;

data &var; 
set &var; 
length variable $ 200; 
length disp_point $ 50; 

group =&group; 
group_tx=&group_tx;

%if &stattype = 1 %then %do;

variable = "&label \n \S={font_style=italic }Mean " || put(177,S370FPIB1.)  || " SD\n Median " || put(177,S370FPIB1.)   || " MAD \n N";
disp_point = "\n" || compress(put(mean, &format)) || "" || put(177,S370FPIB1.) || ""  || compress(put(std, &format))  
|| " \n" || compress(put(median, &format))  || "" 
|| put(177,S370FPIB1.) || "" || compress(put(mad, &format)) || "  \n" || compress(put(n,4.0))  ; 


%end;


%else %if &stattype = 2 %then %do;

variable = "&label \n  N";
disp_point = " \n" || compress(put(n,4.0))  ; 


%end;

%else %if &stattype = 3 %then %do;

variable = "&label \n \S={font_style=italic }Mean " || put(177,S370FPIB1.)  || " SD\n N";


disp_point = "\n" || compress(put(mean, &format)) || "" || put(177,S370FPIB1.) || ""  || compress(put(std, &format))  

|| "  \n" || compress(put(n,4.0))  ; 


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


proc sql; 
drop table &var; quit;
%mend;


/*********univariate_stat macro calls *****************/
%univariate_stat (data=tx_stat_vl ,var =age_first_tx_min, label=Age at first transfusion(d) , group=1,stattype=1, format=6.1,subheader=0,group_tx=1);
%univariate_stat (data=tx_stat_vl ,var =total_tx, label=Total number of Tx per infant by day 30 , group=2,stattype=1, format=6.1,subheader=0,group_tx=1);
%univariate_stat (data=tx_stat_vl ,var =vol_tx_total, label=Total blood volume transfused by day 30(mL) , group=3,stattype=1, format=6.1,subheader=0,group_tx=1);

%univariate_stat (data=tx_stat_ll ,var =age_first_tx_min, label=Age at first transfusion(d) , group=11,stattype=1, format=6.1,subheader=0,group_tx=1);
%univariate_stat (data=tx_stat_ll ,var =total_tx, label=Total number of Tx per infant by day 30 , group=12,stattype=1, format=6.1,subheader=0,group_tx=1);
%univariate_stat (data=tx_stat_ll ,var =vol_tx_total, label=Total blood volume transfused by day 30(mL) , group=13,stattype=1, format=6.1,subheader=0,group_tx=1);



/***** table outcomes ******/

proc sql;
create table id_weight as
select id, id2,center,group_type ,birthweight,weight_group
from enrolled_rbc
union

select id, id2,center,group_type,birthweight,weight_group
from enrolled_rbc_no;

create table pda_weight as
select a.* , b.id, b.id2,b.center,b.group_type,weight_group
from cmv.pda as a left join
id_weight as b
on a.id=b.id;




create table ivh_weight as
select a.* , b.id, b.id2,b.center,b.group_type,weight_group
from cmv.ivh as a inner join
id_weight as b
on a.id=b.id;

create table rop_weight as
select a.* , b.id, b.id2,b.center,b.group_type,weight_group
from cmv.rop as a inner join
id_weight as b
on a.id=b.id;

create table bpd_weight as
select a.* , b.id, b.id2,b.center,b.group_type,weight_group
from cmv.bpd as a inner join
id_weight as b
on a.id=b.id;
quit;



/****** format ********************/
proc format ;

value center 
0="Overall"
2="Grady"
1="EUHM"
3="Northside"
4="CHOA Egleston"
5="CHOA Scottish"
;


run;

/*********output *****************/

ods escapechar='\';
options nodate orientation=portrait;
ods rtf   file = "&output./monthly/001.vlbw_summary_neeta.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "Table 2a: PRBC transfusion in very low birth weight(1000-1500gms)LBWI who completed study";

title  justify = center "Table 2a: PRBC transfusion in very low birth weight(1000-1500gms)LBWI who completed study";
footnote "";

proc report data=univ_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
where group < 10;
column      variable    center ,  (disp_point  )  dummy;


define variable/ group  order=data   Left  style(column) = [just=left cellwidth=2.5in]   "  " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2.3in] ""  ;

define disp_point/center      style(column) = [just=center cellwidth=1in] " "  left ;
*define pipe/center    "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

format center center.;


run;

title  justify = center "Table 2b: PRBC transfusion in low birth weight(< 1000gms)LBWI who completed study";
footnote "";

proc report data=univ_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
where group > 10;
column      variable    center ,  (disp_point  )  dummy;


define variable/ group  order=data   Left  style(column) = [just=left cellwidth=2.5in]   "  " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2.3in] ""  ;

define disp_point/center      style(column) = [just=center cellwidth=1in] " "  left ;
*define pipe/center    "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

format center center.;


run;

ods rtf close;
