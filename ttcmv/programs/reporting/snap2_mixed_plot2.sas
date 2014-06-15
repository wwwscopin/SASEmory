%include "&include./annual_toc.sas";


libname cmv_rep "/ttcmv/sas/programs/reporting";


proc format;
/*
value visit
0='0'
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8='60'
9='';*/

value visit
0=''
1='4'
2='7'
3='14'
4='21'
5='28'
6='40'
7='60'
8='90'
9=''
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


where (enrollmentdate is not null or IsEligible =1 )and  a.id not in (3003411,3003421);
*/

create table chemistry_plot as
select a.id  ,b.*
from 
cmv.valid_ids as a
left join

cmv.snap2 as b
on a.id =b.id;




quit;


data chemistry_plot;
set cmv.snap2; where dfseq <=63; run;

data chemistry_plot; set chemistry_plot;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;


data chemistry_plot; set  chemistry_plot;

if center=1 then treatmentgroup=1;
if center=2 then treatmentgroup=2;
if center=3 then treatmentgroup=3;


subjectid = id;


if dfseq=4 then visit=1;
if dfseq=7 then visit=2;
if dfseq=14 then visit=3;
if dfseq=21 then visit=4;
if dfseq=28 then visit=5;
if dfseq=40 then visit=6;
if dfseq=60 then visit=7;



run;

proc format; 
			
value visit_overall
0=""
1="DOL4"
2="DOL7"
3="DOL14"
4="DOL21"
5="DOL28"
6="DOL40"
7="DOL60"
8=""
; 

value visitfmt
0=""
1="D4"
2="D7"
3="D14"
4="D21"
5="D28"
6="D40"
7="D60"
8=""
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
1="DOL4"
2="DOL7"
3="DOL14"
4="DOL21"
5="DOL28"
6="DOL40"
7="DOL60"
8=""
;

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




goptions reset = all ;

%macro ttcmvPlot3(indata=,yvar=, giflabel=, Varlabel=,title=, orderlow=,orderhigh=,orderby=,name=);
		


		data &yvar._plot (keep=id dfseq  visit &yvar dfseq_jitter); set  &indata; 
				visit_jitter= (visit - .2) + .4*uniform(435); where center=0;
			run;
		
		proc mixed data = &indata   empirical covtest  /* ;  noprint Noprint option some times gives problem */;
				class visit;
			
				where center=0;

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
				by visit;
					
				
			run;


			* draw bars for 95% CIs;
			DATA anno_mixed; 
				set &yvar._mixed;


				
				xsys='2'; ysys='2';
							
				* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
				X=visit; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
				Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; color='black';  OUTPUT; * draw down;
			
				LINK TIPS; * make bar;

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
data tablanno; set tablanno tabllabl /*grayline */;
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
  			

goptions reset=all device=jpeg gunit=pct noborder htitle=5 htext=3 cback=white	colors = (black)  ftitle=swissb ftext= swissb;
			goptions border;





				axis1 order=(0 to 9 by 1) 
label=(  j=center  "Day of Life"  ) minor=none  /*minor=(number=1)*/ offset=(0,0)  major=none split="_";


 axis2 label=(f=swissb h=2.5  j=center a=90 " "  ) order=(&orderlow TO &orderhigh BY &orderby) 
  major=(height=2 w=2) minor=(number=1 h=1) ;


		symbol1 value=dot h=1 ;
			

			symbol2 value = dot co=black h = 3 i = join ;	
		
	 		title1 ls=1.5  "&title";


title1 h=4 "&varlabel : Model-based means and 95% CI ";


footnote h=10pct " "; 

	        


			proc gplot data = &yvar._mixed   anno= anno_mixed  gout= cmv_rep.graphs; 
			format visit visit.; format estimate 4.0;
				plot 	&yvar*visit
						estimate*visit	/overlay  anno=tablanno haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="&name"    ;
 
  ; 
                        

				;
			run; quit;

			 proc sql;
 			drop table anno_mixed; drop table &yvar._plot; drop table lsmeans_&yvar;
drop table &yvar._mixed;

 			drop table xx; drop table anno1; drop table anno; drop table anno2;
			run;quit; 

			 


%mend ttcmvPlot3;

%ttcmvPlot3(indata=chemistry_plot,yvar=snap2score, giflabel=snap2, varlabel=SNAP II score, title=snap score over time,orderlow=0, 
orderhigh=40,orderby=5,name=snap );


goptions /*device=gif gsfname=grafout gsfmode=replace  FTitle=arial  */ hsize=9in vsize=6in ; 

ods rtf file = "&output./annual/&snap2_plots_whole_file.snap2_mixed_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;


ods noproctitle proclabel "&growth_plots_whole_title . LBWI growth plots ";



proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;
treplay 1:snap  ; 

ods rtf close; 
ods listing; 
quit;


