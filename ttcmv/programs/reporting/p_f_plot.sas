/* ***********  SNAP fio2 PAO2 and ratio ************/

%include "&include./annual_toc.sas";


libname cmv_rep "/ttcmv/sas/programs/reporting";


proc format;

value visit
0='0'
1='1'
1.1='1'
.9='1'
1.2='1'
2='4'
2.1='4'
1.9='4'
2.2='4'
3 ='7'
3.1 ='7'
2.9 ='7'
3.2 ='7'
4='14'
4.1='14'
3.9='14'
4.2='14'
5='21'
5.1='21'
5.2='21'
4.9='21'
6='28'
6.1='28'
6.2='28'
5.9='28'
7='40'
7.1='40'
6.9='40'
7.2='40'
8='60'
8.1='60'
8.2='60'
7.9='60'
9='90'
9.1='90'
9.2='90'
8.9='90'
10=''
;

proc sql;
create table all_snap as
select id  , dfseq , pO2value ,fio2 from cmv.Plate_010
union
select id  , dfseq , pO2value ,fio2 from cmv.snap2
;

create table all_snap2 as
select a.id  ,b.*
from 
cmv.valid_ids as a
left join
all_snap as b
on a.id =b.id;

quit;



data chemistry_plot; set  all_snap2;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

data chemistry_plot; set  chemistry_plot; if dfseq > 63 then delete;
P_F_ratio = pO2value/(fio2/100);
if center=1 then treatmentgroup=1;
if center=2 then treatmentgroup=2;
if center=3 then treatmentgroup=3;


subjectid = id;

if DFSEQ=1 then visit=1;
if DFSEQ=4 then visit=2;
if DFSEQ=7 then visit=3;
if DFSEQ=14 then visit=4;
if DFSEQ=21 then visit=5;
if DFSEQ=28 then visit=6;
if DFSEQ=40 then visit=7;
if DFSEQ=60 then visit=8;
if DFSEQ=63 then visit=9;
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 

data chemistry_plot; 
set chemistry_plot; 
output; 
center = 0; treatmentgroup=0;
output; 
run;

proc greplay    igout= cmv_rep.graphs  nofs; 
delete _all_; 
run;


proc format; 
			
value visit_overall
0=""
1="DOL1"
2="DOL4"
3="DOL7"
4="DOL14"
5="DOL21"
6="DOL28"
7="DOL40"
8="DOL60"
9="DOL90"
10=""
; 

value visitfmt
0=""
1="D1"
2="D4"
3="D7"
4="D14"
5="D21"
6="D28"
7="D40"
8="D60"
9="D90"
10=""
; 

value group 
1="Grady"
2="EUHM"
3="Northside"
4="CHOA Egleston"
5="CHOA Scottish"
8="BU"
;

value visitfmt
0=""
1="DOL1"
2="DOL4"
3="DOL7"
4="DOL14"
5="DOL21"
6="DOL28"
7="DOL40"
8="DOL60"
9="DOL90"
10=""
;

run;


goptions reset = all ;

%macro ttcmvPlot3(indata=,yvar=, giflabel=, Varlabel=,ylabel=,title=, orderlow=,orderhigh=,orderby=,name=);
		


		data &yvar._plot (keep=id dfseq  visit &yvar dfseq_jitter); set  &indata;  where center=0;
				visit_jitter= (visit - .1) + .1*uniform(435);
 
			run;
		
		proc mixed data = &indata   empirical covtest  /* ;  noprint Noprint option some times gives problem */;
				
			
				where center=0 ; class visit ;

				model &yvar = visit / solution;
				repeated visit / subject = id type = cs;
				lsmeans visit / cl ;
				ods output lsmeans = lsmeans_&yvar ;
			run; 

			


			* clean up lsmeans output;
			data lsmeans_&yvar;
				set lsmeans_&yvar;

				where effect = "visit";

			run;


			* merge the means and CIs into cd4_plot to obtain plotting dataset;
			proc sort data = &yvar._plot; by visit; run;
			proc sort data = lsmeans_&yvar; by visit; run;

			data &yvar._mixed ;
				merge 	&yvar._plot
						lsmeans_&yvar
					;	
				by  visit;
					
				
			run;


			* draw bars for 95% CIs;
			DATA anno_mixed; 
				set &yvar._mixed;


xsys='2'; ysys='2';
							
				* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
				X=visit; 	y=estimate;  FUNCTION='MOVE'; when = 'A';  OUTPUT;  *start at mean ;
				Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
			
				 LINK TIPS;  * make bar;

				Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw up; 
			
				LINK TIPS; * make bar;
			
				* draw top and bottoms of bars;
				TIPS:
				  X=visit-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black'; OUTPUT;
				  X=visit+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black'; OUTPUT;
				  X=visit;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
				return;


			run;


				/* add table annonation */
/*
			proc sql noprint;
create table lineanno as
select * from &yvar._plot
having visit=max(visit);
quit; run;

data lineanno; set lineanno;
length text $20.;
xsys='2'; ysys='2'; hsys='3'; position='6'; style='"arial/bold"'; color='black'; 
x=visit; y=&yvar; function='label'; text='  '||trim(left(center));
run;
*/

proc sql;
			create table xx as
			select center,visit, count(&yvar)  as number
			from &indata
			where center =0
			group by center,visit
			order by center,visit;

			

			run; quit;

data tablanno; set xx;
length text $20.;
length color function $8.;
xsys='2'; ysys='2'; hsys='3'; position='5'; style='"triplex"'; color='black'  ;
function='move'; x=visit; y=0; output;
ysys='3'; 
function='label';
text=trim(left(put(number,comma4.0))); 
if center eq 0 then y=7; 
/*else if center eq 2 then y=11; 
else if center eq 3 then y=7; */
output;
run;


data tabllabl;
length text $20.;
length color function $8.;
xsys='3'; ysys='3'; hsys='3'; position='6'; style='"triplex"'; color='black';
x=2; 
y=7; text='Overall (n =)'; output;
/*y=11; text='Grady (n =)'; output;
y=7; text='EUHM (n =)'; output;*/


run;
/*
data grayline;
xsys='1'; ysys='3'; color='gray';
function='move'; x=0; y=17; output;
function='draw'; x=100; y=17; output;
run;
*/
data tablanno; set tablanno   tabllabl  /* grayline */;
run;


			data anno_mixed; 
*set anno anno_mixed; 
set anno_mixed  tablanno;
run;

data &yvar._mixed ; set &yvar._mixed ;
if id > 1000000 and id < 2000000 then visit= visit +.1;
if id > 2000000 and id < 3000000 then visit= visit -.1;
if id > 3000000 and id < 4000000 then visit= visit +.2;


run;

* plot original data jittered, estimated means and 95% CIs;
  			

goptions reset=all device=jpeg gunit=pct noborder htitle=4 htext=3 cback=white	colors = (black)  ftitle=swissb ftext= swissb;
			goptions border;


				axis1  label=(  j=center  "Day of Life"  )  value=("" "1" "4" "7" "14" "28" "40" "60" "90" "" )  order=(0 to 10 by 1)
 minor=none   offset=(0,0)  major=none split="_";


 axis2 label=(  j=center a=90 "&ylabel"  ) order=(&orderlow TO &orderhigh BY &orderby) 
  major=(height=2 w=2) minor=(number=1 h=1) ;


		
			symbol1 value=circle  ;

			symbol2  co=black h = 3 i = join ;	
		
	 		title1 /*ls=1.5 */ "&varlabel";


title2 h=4 " Model based means and 95% CI ";


footnote h=10pct " "; 

	        


			proc gplot data = &yvar._mixed  anno=anno_mixed   gout= cmv_rep.graphs; 
			
				plot &yvar*visit	
						estimate*visit	  / ovcerlay anno=tablanno haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="&name"    ;
 
  ; 
                format visit visit.; 
   format estimate 4.0;        

				;
			run; quit;

			 proc sql;
 			drop table anno_mixed; drop table &yvar._plot; drop table lsmeans_&yvar;
*drop table &yvar._mixed;

 			drop table xx; drop table anno1; drop table anno; drop table anno2;
			run;quit; 

			 


%mend ttcmvPlot3;



%ttcmvPlot3(indata=chemistry_plot,yvar=pO2value, giflabel=pao2, varlabel=Figure 19 : PaO2(mm Hg) ,ylabel=PaO2(mm Hg), title= PaO2 over time,orderlow=0, 
orderhigh=160,orderby=20,name=pao );

%ttcmvPlot3(indata=chemistry_plot,yvar=fio2, giflabel=fio2, varlabel=Figure 20 :  FiO2 (%), ylabel=FiO2 (%), title=Figure 20: FiO2 (%) over time,orderlow=0, 
orderhigh=100,orderby=20,name=Fio );

%ttcmvPlot3(indata=chemistry_plot,yvar=P_F_ratio, giflabel=P_F_ratio, varlabel=Figure 21 : PaO2/FiO2 Ratio,ylabel=PaO2/FiO2 Ratio, title=Figure 21: FiO2 (%) over time,orderlow=0, 
orderhigh=800,orderby=100,name=p_f );

options nodate;
goptions /*device=gif gsfname=grafout gsfmode=replace  FTitle=arial  */ hsize=8in vsize=9in ; 

ods rtf file = "&output./annual/&p_f_plot_file.p_by_f_mixed_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;


ods noproctitle proclabel "&p_f_plot_title . LBWI PaO2 By FiO2 ";



proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;
treplay 1:pao  ;
treplay 1:Fio;treplay 1:p_f;

ods rtf close; 
ods listing; 
quit;
