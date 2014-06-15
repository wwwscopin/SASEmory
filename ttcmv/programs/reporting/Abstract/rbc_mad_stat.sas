
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


create table rbctx as
select a.* , b.LBWIDOB as DateOfBirth 
from rbctx as a left join
cmv.LBWI_Demo as  b
on a.id= b.id;




quit;

data rbctx ; set rbctx;

vol_wt = rbcvolumeTransfused / (BodyWeight/1000);
age_of_blood = (DateTransfusion - DateDonated );
time_to_tx= (DateTransfusion - DateOfBirth );

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


/* *** snap score * *****/

proc sql;
create table snap as
select a.id, b.SnapTotalScore
from (select distinct(id) as id from rbcTx )  as a left join
cmv.snap as b
on a.id=b.id;



quit;
data snap; set snap;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
studygroup=input(substr(id2, 1, 1),1.);
run;

data snap; 
set snap; 
 
output; 
center = 0; studygroup=0;
output; 
run;



/* *** END snap score * *****/


/* *** birth weight gest age  * *****/

proc sql;
create table birth as
select a.id, b.birthweight,b.gestage
from (select distinct(id) as id from rbcTx )  as a left join
cmv.LBWI_Demo as b
on a.id=b.id;



quit;
data birth; set birth;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
studygroup=input(substr(id2, 1, 1),1.);
visitlist=1;
run;

data birth; 
set birth; 
 
output; 
center = 0; studygroup=0;
output; 
run;



/* *** END birth weight gest age score * *****/

data time_tx; set rbctx; where dfseq=101;run;

proc sql;
create table storage as
select max(age_of_blood) as age_of_blood_max , donorunitid,center
from rbctx
group by donorunitid, center; 

create table time_tx as
select min(time_to_tx) as time_to_tx_min , id,center
from rbctx
group by id, center; 

create table lowest_hb as
select  b.id,b.center,a.hb
from  rbctx as a right join time_tx as b
on a.id=b.id and a.time_to_tx=b.time_to_tx_min and a.center=b.center
; 

create table rbc_donors as
select distinct(DonorUnitId),center  from rbctx;

quit;

/*************************************************************/
/*********univariate_stat macro definition *****************/
%macro univariate_stat (data= ,var = , label = , group=,stattype=, format=,subheader=); 

%if &subheader=0 %then %do;
data &data; set &data; if &var=-99 then &var=.;run;


proc sort data=&data;  by center; run;


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

variable = "&label \n \S={font_style=italic }Mean " || put(177,S370FPIB1.)  || " SD\n Median " || put(177,S370FPIB1.)   
|| " MAD \n Min - Max \n N";


disp_point = "\n" || compress(put(mean, &format)) || "" || put(177,S370FPIB1.) || ""  || compress(put(std, &format))  
|| " \n" || compress(put(median, &format))  || "" 
|| put(177,S370FPIB1.) || "" || compress(put(mad, &format)) 
||"  \n" || compress(put(min,4.0)) || " - "   || compress(put(max,4.0))

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

proc sql; drop table &var; quit;
%mend;


/*********univariate_stat macro calls *****************/
%univariate_stat (data=rbctx ,var =center  , label =	Total number of transfusions , group=1,stattype=2, format=6.1,subheader=0);
%univariate_stat (data=rbc_donors ,var =center  , label =	Total Donors , group=2,stattype=2, format=6.1,subheader=0);
%univariate_stat (data=rbctx ,var =center  , label =\n\S={font_weight=bold }Data on all RBC transfusions , group=0,stattype=2, format=6.1,subheader=1);
%univariate_stat (data=rbctx ,var =BodyWeight  , label =	Body Weight at transfusion(gms) , group=3,stattype=1, format=6.0,subheader=0);
%univariate_stat (data=rbctx ,var =rbcvolumeTransfused  , label =	Volume (mL) per tranfusion, group=4,stattype=1, format=6.1,subheader=0);


%univariate_stat (data=rbctx ,var =vol_wt  , label = 	Volume (mL/kg) per tranfusion , group=5,stattype=1, format=6.1,subheader=0); 
%univariate_stat (data=rbctx ,var =age_of_blood  , label =	Average length of storage(days) , group=6,stattype=1, format=6.1,subheader=0); 

%univariate_stat (data=storage ,var =age_of_blood_max  , label =  Longest length of storage(days) , group=7,stattype=1, format=6.1,subheader=0); 


%univariate_stat (data=rbctx ,var =center  , label =\n\S={font_weight=bold }Data on first RBC transfusion for LBWI, group=8,stattype=2, format=6.1,subheader=1);

%univariate_stat (data=time_tx ,var =time_to_tx_min  , label =  Days to first RBC Tx(days) , group=9,stattype=3, format=6.1,subheader=0); 

%univariate_stat (data=lowest_hb ,var =Hb  , label =  Hb level within 24hrs before first Tx(g/dl) , group=10,stattype=1, format=6.1,subheader=0); 
%univariate_stat (data=snap ,var =snaptotalscore  , label = SNAP score at Birth , group=11,stattype=3, format=6.1,subheader=0); 
%univariate_stat (data=birth ,var =birthweight , label = Weight at Birth (gms) , group=12,stattype=3, format=6.0,subheader=0); 
%univariate_stat (data=birth ,var =gestage , label = Gestational age at Birth (weeks), group=13,stattype=3, format=6.1,subheader=0); 



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
ods rtf   file = "&output./annual/&combo_tx_summary_file.rbc_tx_mad_summary.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&rbc_mad_summary_title .a: Data on all red-cell transfusions for LBWI who completed study";

title  justify = center "&rbc_mad_summary_title .a: Data on all red-cell transfusions for LBWI who completed study ";
footnote "MAD = median of the absolute values of the deviation from the median.";

proc report data=univ_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
where group < 8;

column      variable    center ,  (disp_point  )  dummy;


define variable/ group  order=data   Left  style(column) = [just=left cellwidth=2.5in]   "  " ;

define center / across order=internal  left   style(column) = [just=center cellwidth=2.3in] ""  ;

define disp_point/center      style(column) = [just=center cellwidth=1in] " "  left ;
*define pipe/center    "  " ;

define dummy/NOPRINT ;


rbreak after / skip ;

format center center.;


run;

ods noproctitle proclabel "&rbc_mad_summary_title .b: Data on first RBC transfusion for LBWI who completed study";

title  justify = center "&rbc_mad_summary_title .b: Data on first RBC transfusion for LBWI who completed study";
footnote "MAD = median of the absolute values of the deviation from the median.";

proc report data=univ_table nofs   style(header) = [just=center] split="_" missing headline headskip contents = "" ;
where group >7;

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

/**** plot of day at first Tx verses birth snap score ***********/

proc sql;
create table plot_table as
select a.id, a.center, a.snaptotalscore, b.time_to_tx_min
from snap as a left join
time_tx as b
on a.id=b.id and a.center=b.center;


create table plot_table_birth as
select a.id, a.center, a.birthweight, a.gestage,b.time_to_tx_min
from birth as a left join
time_tx as b
on a.id=b.id and a.center=b.center;

/*
create table plot_table2 as
select a.id, a.center, a.snaptotalscore,a.time_to_tx_min  as time0,time1,time2,time3
from plot_table as a left join
(select id, center,time_to_tx_min as time1 from plot_table where center=1) as b
on a.id=b.id
left join
(select id, center,time_to_tx_min as time2 from plot_table where center=2) as c
on a.id=c.id 
left join
(select id, center,time_to_tx_min as time3 from plot_table where center=3) as d
on a.id=d.id; */
quit;

libname cmv_rep "/ttcmv/sas/programs/reporting";

proc greplay igout= cmv_rep.graphs  nofs; delete _ALL_; run;

goptions reset=all device=jpeg  gunit=pct htitle=5 htext=3 cback=white	colors = (black)  ftitle=swiss ftext= swissb;
			goptions border;

				axis1  label=(f=swiss h=4.0 j=center  "SNAP Score at Birth"  ) minor=none  
major=(height=2 ) offset=(0,0)  order=(0 to 20 by 2) value=(f=swiss h=3)  split="_";

 axis2 label=(f=swiss h=4.0  j=center a=90 "Days to First RBC Tx after Birth "  )  major=(height=2 )  order=(0 to 40 by 4) value=(f=swiss h=3);


		symbol value=dot h=3 ;

	 		title1   "Days to First RBC Tx and Birth SNAP Score (All Hospitals) ";


*footnote h=10pct " "; 

			proc gplot data = plot_table    gout= cmv_rep.graphs;
		where center > 0; 
			
				plot 	time_to_tx_min*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="rbc_0"    ;

				;
			run; 

	title1 ls=1.5  "Days to First RBC Tx and Birth SNAP Score (EUHM) ";

*footnote h=10pct " "; 

    
			proc gplot data = plot_table    gout= cmv_rep.graphs;
		where center =1; 
			
				plot 	time_to_tx_min*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="rbc_1"    ;

				;
			run; 

	title1 ls=1.5 f=3.5 "Days to First RBC Tx and Birth SNAP Score (Grady) ";


*footnote h=10pct " "; 

    
			proc gplot data = plot_table    gout= cmv_rep.graphs;
		where center =2; 
			
				plot 	time_to_tx_min*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="rbc_2"    ;

				;
			run; 

	title1 ls=1.5  "Days to First RBC Tx and Birth SNAP Score (Northside) ";


*footnote h=10pct " "; 

    
			proc gplot data = plot_table    gout= cmv_rep.graphs;
		where center =3; 
			
				plot 	time_to_tx_min*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="rbc_3"    ;

				;
			run; 



	axis1  label=(f=swiss h=4.0 j=center  " Weight at Birth (gms)"  ) minor=none  
major=(height=2 ) offset=(0,0)  order=(300 to 1500 by 100) value=(f=swiss h=3)  split="_";

 axis2 label=(f=swiss h=4.0  j=center a=90 "Days to First RBC Tx after Birth "  )  major=(height=2 )  order=(0 to 40 by 4) value=(f=swiss h=3);


		symbol value=dot h=3 ;

	 		title1   "Days to First RBC Tx and Birth Weight (All Hospitals) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center > 0; 
			
				plot 	time_to_tx_min*birthweight /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="wt_0"    ;

				;
			run; 



	 		title1   "Days to First RBC Tx and Birth Weight (EUHM) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =1; 
			
				plot 	time_to_tx_min*birthweight /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="wt_1"    ;

				;
			run;


	 		title1   "Days to First RBC Tx and Birth Weight  (Grady) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =2; 
			
				plot 	time_to_tx_min*birthweight /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="wt_2"    ;

				;
			run;

title1   "Days to First RBC Tx and Birth Weight (Northside) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =3; 
			
				plot 	time_to_tx_min*birthweight /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="wt_3"    ;

				;
			run;

/* gest age */

axis1  label=(f=swiss h=4.0 j=center  " Gestational age at Birth (weeks)"  ) minor=none  
major=(height=2 ) offset=(0,0)  order=(20 to 36 by 2 ) value=(f=swiss h=3)  split="_";

 axis2 label=(f=swiss h=4.0  j=center a=90 "Days to First RBC Tx after Birth "  )  major=(height=2 )  order=(0 to 40 by 4) value=(f=swiss h=3);


		symbol value=dot h=3 ;

	 		title1   "Days to First RBC Tx and Gestational age (All Hospitals) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center > 0; 
			
				plot 	time_to_tx_min*gestage /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="age_0"    ;

				;
			run; 



	 		title1   "Days to First RBC Tx and Gestational age  (EUHM) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =1; 
			
				plot 	time_to_tx_min*gestage /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="age_1"    ;

				;
			run;


	 		title1   "Days to First RBC Tx and Gestational age  (Grady) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =2; 
			
				plot 	time_to_tx_min*gestage /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="age_2"    ;

				;
			run;

title1   "Days to First RBC Tx and Gestational age  (Northside) ";

			proc gplot data = plot_table_birth    gout= cmv_rep.graphs;
		where center =3; 
			
				plot 	time_to_tx_min*gestage /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="age_3"    ;

				;
			run;


       


options nodate orientation=portrait;

goptions device=gif gsfname=grafout gsfmode=replace  hsize=7in vsize=9in; 


ods rtf file = "&output./annual/&combo_tx_summary_file.rbc_snap_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;


ods noproctitle proclabel "Days to First Tx against Birth SNAP score ";

proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=l2r2s
nofs;
treplay 1:rbc_0  3:rbc_1 2:rbc_2  4:rbc_3; 
treplay 1:wt_0  3:wt_1 2:wt_2  4:wt_3; 
treplay 1:age_0  3:age_1 2:age_2  4:age_3; 
run; 
ods rtf close; 
ods listing; 
quit;

*%include "beeram_table2.sas";

%include "rbc_tx_by_weight.sas";

%include "rbc_tx_by_weight_bpd.sas";
