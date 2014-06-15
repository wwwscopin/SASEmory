

%include "&include./monthly_toc.sas";
%include "&include./annual_toc.sas";


proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth ,Birthweight,gestage
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

create table all_tx as
select id, donorunitid ,"RBC" as tx_type  from cmv.plate_031 
union all
select id, donorunitid ,"Plt" as tx_type  from cmv.plate_033
union all
select id, donorunitid ,"FFP" as tx_type  from cmv.plate_035
union all
select id, donorunitid ,"Cryo" as tx_type  from cmv.plate_037
;


create table tx_count as
select id, count(*) as tx from all_tx
group by id;

create table tx_count as
select a.*,b.tx 
from enrolled as a left join
tx_count as b 
on a.id = b.id;


create table tx_count as
select a.*, b.SnapTotalScore
from tx_count  as a left join
cmv.snap as b
on a.id=b.id;
quit;


data tx_count; set tx_count;

id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);
studygroup=input(substr(id2, 1, 1),1.);

if tx = . then tx=0;
if birthweight < 1000 then wtcat =1;
if birthweight >=1000 and birthweight < 1500 then wtcat=2;
if birthweight >=1500  then wtcat=3;

if snaptotalscore < 9 then snapcat =1;
if snaptotalscore >= 9  then snapcat=2;


run;


data tx_count; 
set tx_count; 
 
output; 
center = 0; studygroup=0;
output; 
run;

proc format;

value visit
0=''
1='< 1000 '
2='1000- 1500'
3 =''
4=''
;

run;


%include "proc_mixed_plot.sas";

libname cmv_rep "/ttcmv/sas/programs/reporting";

proc greplay igout= cmv_rep.graphs  nofs; delete _ALL_; run;

proc format;

value visit
0=''
1='< 1000 '
2='1000- 1500'
3 =''
4=''
;

run;

data tx_count; set tx_count; visit=wtcat; where tx >0; run;

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=wt_0, varlabel=Number of Tx, title=Number of Tx and Birth Weight,orderlow=0, orderhigh=30,orderby=2,name=wt_0 ,center=0,centertxt=Allsites,xaxislabel=Birth Weight (gms),yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=wt_1, varlabel=Number of Tx, title=Number of Tx and Birth Weight,orderlow=0, orderhigh=30,orderby=2,name=wt_1 ,center=1,centertxt=EUHM,xaxislabel=Birth Weight (gms),yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=wt_2, varlabel=Number of Tx, title=Number of Tx and Birth Weight,orderlow=0, orderhigh=30,orderby=2,name=wt_2 ,center=1,centertxt=Grady,xaxislabel=Birth Weight (gms),yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=wt_3, varlabel=Number of Tx, title=Number of Tx and Birth Weight,orderlow=0, orderhigh=30,orderby=2,name=wt_3 ,center=3,centertxt=Northside,xaxislabel=Birth Weight (gms),yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);



proc format;

value visit
0=''
1='< 9 '
2='>=9'
3 =''
4=''
;

run;

data tx_count; set tx_count;  visit=snapcat;run;

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=snap_0, varlabel=Number of Tx, title=Number of Tx and Birth SNAP Score,orderlow=-10, orderhigh=50,orderby=5,name=snap_0 ,center=0,centertxt=Allsites,xaxislabel=Birth SNAP Score,yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=snap_1, varlabel=Number of Tx, title=Number of Tx and Birth SNAP Score,orderlow=-10, orderhigh=50,orderby=5,name=snap_1 ,center=1,centertxt=EUHM,xaxislabel=Birth SNAP Score,yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);

%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=snap_2, varlabel=Number of Tx, title=Number of Tx and Birth SNAP Score,orderlow=-10, orderhigh=50,orderby=5,name=snap_2 ,center=2,centertxt=Grady,xaxislabel=Birth SNAP Score,yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);


%ttcmvPlot3(indata=tx_count,yvar=tx, giflabel=snap_3, varlabel=Number of Tx, title=Number of Tx and Birth SNAP Score,orderlow=-10, orderhigh=50,orderby=5,name=snap_3 ,center=3,centertxt=Northside,xaxislabel=Birth SNAP Score,yaxislabel=Number of Tx, xlow=0,xhigh=3,xby=1);



goptions reset=all device=jpeg  gunit=pct htitle=5 htext=3 cback=white	colors = (black)  ftitle=swiss ftext= swissb;
			goptions border;

				axis1  label=(f=swiss h=4.0 j=center  "SNAP Score at Birth"  ) minor=none  
major=(height=2 ) offset=(0,0)  order=(0 to 20 by 2) value=(f=swiss h=3)  split="_";

 axis2 label=(f=swiss h=4.0  j=center a=90 "Number of  Tx  "  )  major=(height=2 )  order=(0 to 40 by 4) value=(f=swiss h=3);


		symbol value=dot h=3 ;

	 		title1   "Number of  Tx and Birth SNAP Score (All Hospitals) ";
*footnote h=10pct " "; 

			proc gplot data = tx_count    gout= cmv_rep.graphs;
		where center > 0; 
			
				plot 	tx*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="s_0"    ;

				;
			run; 

title1   "Number of  Tx and Birth SNAP Score (EUHM) ";
*footnote h=10pct " "; 

			proc gplot data = tx_count    gout= cmv_rep.graphs;
		where center =1; 
			
				plot 	tx*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="s_1"    ;

				;
			run; 

title1   "Number of  Tx and Birth SNAP Score (Grady) ";
*footnote h=10pct " "; 

			proc gplot data = tx_count    gout= cmv_rep.graphs;
		where center =2; 
			
				plot 	tx*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="s_2"    ;

				;
			run; 

title1   "Number of  Tx and Birth SNAP Score (Northside) ";
*footnote h=10pct " "; 

			proc gplot data = tx_count    gout= cmv_rep.graphs;
		where center =3; 
			
				plot 	tx*snaptotalscore /   haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="s_3"    ;

				;
			run; 



options nodate orientation=portrait;

goptions device=gif gsfname=grafout gsfmode=replace  hsize=7in vsize=9in; 


ods rtf file = "&output./annual/&tx_num_summary_file.tx_num_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;


ods noproctitle proclabel "Number of Tx against Birth SNAP score ";

proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=l2r2s
nofs;
treplay 1:s_0 2:s_2 3:s_1 4:s_3 ;
treplay 1:wt_0 2:wt_2 3:wt_1 4:wt_3 ;
treplay 1:snap_0 2:snap_2 3:snap_1 4:snap_3 ;

run; 
ods rtf close; 
ods listing; 
quit;

