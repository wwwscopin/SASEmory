/* line plots */

* turn macros on;
 *proc options option = macro;  
* run;


%include "&include/annual_toc.sas";

*%include "style.sas";

libname cmv_rep "/ttcmv/sas/programs/reporting";


proc format;

value visit
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8='60'
9=''
;

run;



data review; set cmv.med_review;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

proc sql;
create table review as
select a.* ,b.snap2score
from review as a left join
cmv.snap2 as b
on a.id=b.id and a.dfseq=b.dfseq;
run;

data review; set review;
if dfseq=1 then visit=1;
if dfseq=4 then visit=2;
if dfseq=7 then visit =3;
if dfseq=14 then visit =4;
if dfseq=21 then visit=5;
if dfseq = 28 then visit=6;
if dfseq=40 then visit=7;
if dfseq=60 then visit=8;

label Hb="Hb" Weight="Weight"  HeadCircum="Head Circum" HtLength="Height/Length";
run;

**** DUPLICATE THE INCOMING DATA SET FOR OVERALL COLUMN 
**** CALCULATIONS SO NOW TRT HAS VALUES 1 = Control, 2 = Intevention, 
**** AND 3 = OVERALL.; 
data review2; 
set review; 
output; 
center = 0; 
output; 
run; 


proc greplay    igout= cmv_rep.graphs  nofs; 
delete _all_; 
run;


goptions reset = all;
%macro line_plot (data= ,var = , label = , studygroup=, orderlow=, orderhigh=,orderby=,n=); 
%do out=1 %to 1;
proc sql; 
select max(&var) into : max from &data ; 
select min(&var) into : min from &data ; 
run;quit; 
%let max1 = &max; 
%let min1 = %sysevalf(&min -1 , int); 
%let y =&max1-&min1; 
%let y =%sysevalf(&max1 + 1, int); 

%let byvalue1 = %sysevalf(&y) ; 
%let x= 10; 
%let byvalue3 = %sysevalf(&byvalue1/&x); 
%if &out = 1 %then %let study="Overall"; 
%else %if &out = 2 %then %let study="Intervention (LPV/r + RAL)"; 
goptions reset = all; 



goptions gunit=pct  device=jpeg htitle=5 htext=3   ftitle=zapf ftext= zapf;
goptions border;





 axis1 order=(0 to 9 by 1) value=(    "" "1" "4" "7" "14" "21" "28" "40" "60"  "") label=(  j=center  "Day of Life"  ) minor=none offset=(0,0)  major=none split="_";
axis2 order=(&orderlow to &orderhigh by &orderby) minor=none offset=(0,0) label=(  j=center a=90 /* "&label" */  "") major=(height=.7) minor=(number=2 h=0.2);

symbol1 value = dot h=1.0 i=join repeat = 200; 

title1 ls=1.5  "&label over time";
/*
title2 h=8 " ";

title3 a=90 h=1pct "";
title4 a=-90 h=18pct " "; 

footnote h=17pct " ";*/

proc gplot data=&data   gout= cmv_rep.graphs; 

plot &var*visit=id / name ="&n" nolegend noframe haxis=axis1 vaxis=axis2  /* annotate=linetext*/;
format visit visit.;

run;
quit; 
%end;
%mend line_plot;

 
%line_plot(data=review ,var=hb, label=Hb (mg/dL) , studygroup=1, orderlow=5, orderhigh=50,orderby=5, n=Hb); 
%line_plot(data=review ,var=hb, label=Hct (mg/dL) , studygroup=1, orderlow=5, orderhigh=50,orderby=5, n=Hct); 
%line_plot(data=review ,var=Weight, label=Weight (gms) , studygroup=2,orderlow=400, orderhigh=1800,orderby=200, n=wt); 
%line_plot(data=review ,var= HtLength, label= Height Length (cms) , studygroup=3,orderlow=20, orderhigh=50,orderby=10, n=ht); 
%line_plot(data=review ,var= HeadCircum, label= Head Circumference (cms) , studygroup=4,orderlow=20, orderhigh=40,orderby=10, n=hc); 
%line_plot(data=review ,var= snap2score, label= SNAP II score , studygroup=4,orderlow=0, orderhigh=40,orderby=10, n=snap); 


/* box plots */


/* Box plot */
/* PLOT LONGITUDINAL BOXPLOTS FOR each variable */ 
* add jitter ; 
data review; 
set review; 
dfseq2= (dfseq - .02) + .01*uniform(3654); 
run; 


goptions reset = all;
%macro box_plot (data= ,var = , label = , studygroup=, orderlow=, orderhigh=,orderby=,n=); 
%do out=1 %to 1;
proc sql; 
select max(&var) into : max from &data ; 
select min(&var) into : min from &data ; 
run;quit; 
%let max1 = &max; 
%let min1 = %sysevalf(&min -1 , int); 
%let y =&max1-&min1; 
%let y =%sysevalf(&max1 + 1, int); 

%let byvalue1 = %sysevalf(&y) ; 
%let x= 10; 
%let byvalue3 = %sysevalf(&byvalue1/&x); 
%if &out = 1 %then %let study="Overall"; 
%else %if &out = 2 %then %let study="Intervention (LPV/r + RAL)"; 
goptions reset = all; 





goptions gunit=pct  device=jpeg htitle=5 htext=3   ftitle=zapf ftext= zapf;
goptions border;





 axis1 order=(0 to 9 by 1) value=(    "" "1" "4" "7" "14" "21" "28" "40"  "60" "") label=(  j=center  "Day of Life"  ) minor=none offset=(0,0)  major=none split="_";
axis2 order=(&orderlow to &orderhigh by &orderby) minor=none offset=(0,0) label=(  j=center a=90  /*"&label" */ "" ) major=(height=.7) minor=(number=2 h=.2);





*symbol1 ci=blue value=dot h=1 ; 
symbol1 interpol=boxt10  value=none co=black cv=black height=.6 bwidth=4 width=2; 


symbol2 value=dot h=1 ;

title1 ls=1.5  "&label over time";
/*
title2 h=8 " ";

title3 a=90 h=1pct "";
title4 a=-90 h=18pct " ";

footnote h=17pct " ";*/

proc gplot data=&data   gout= cmv_rep.graphs; 
*&var*dfseq2;
plot  &var*visit &var*visit/ overlay name ="&n" nolegend  haxis=axis1 vaxis=axis2   /* annotate=linetext*/;
format visit visit.;

run;
quit; 
%end;
%mend box_plot;



%box_plot(data=review ,var=hb, label=Hb (mg/dL) , studygroup=1, orderlow=5, orderhigh=50,orderby=5, n=Hb_b); 
%box_plot(data=review ,var=hb, label=Hct (mg/dL) , studygroup=1, orderlow=5, orderhigh=50,orderby=5, n=Hct_b); 
%box_plot(data=review ,var=Weight, label=Weight (gms) , studygroup=2,orderlow=400, orderhigh=1800,orderby=200, n=wt_b); 
%box_plot(data=review ,var= HtLength, label= Height Length (cms) , studygroup=3,orderlow=20, orderhigh=50,orderby=10, n=ht_b); 
%box_plot(data=review ,var= HeadCircum, label= Head Circumference (cms) , studygroup=4,orderlow=20, orderhigh=40,orderby=10, n=hc_b); 
%box_plot(data=review ,var= snap2score, label= SNAP2 , studygroup=4,orderlow=0, orderhigh=40,orderby=10, n=snap_b); 





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
					
				/* estimate_trt1 = estimate; visit = visit + .25; visit_jitter = visit_jitter + .25;
				
				if treatmentgroup = 1 then do; &yvar._trt1  = &yvar;	estimate_trt1 = estimate; end;
				else if treatmentgroup = 2 then do; &yvar._trt2 = &yvar;	estimate_trt2 = estimate; end;

				if treatmentgroup = 1 then do; week = week + .25; week_jitter = week_jitter + .25;  end; * offset the two means;
				else do;  week = week - .25; week_jitter = week_jitter - .25;  end;  */
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
if center eq 0 then y=11; 
/*else if center eq 2 then y=11; 
else if center eq 3 then y=7; */
output;
run;


data tabllabl;
length text $20.;
length color function $8.;
xsys='3'; ysys='3'; hsys='3'; position='6'; style='"triplex"'; color='black';
x=2; 
y=11; text='Overall (n =)'; output;
/*y=11; text='Grady (n =)'; output;
y=7; text='EUHM (n =)'; output;*/

/*
function='move'; x=16.5; y=14.6; output; function='draw'; x=18; color='red'; size=.7; output;
function='move'; x=16.5; y=10.6; output; function='draw'; x=18; color='cx76EE00'; size=.7; output;
function='move'; x=16.5; y=6.6; output; function='draw'; x=18; color='cx1C86EE'; size=.7; output;
*/
run;

data grayline;
xsys='1'; ysys='3'; color='gray';
function='move'; x=0; y=17; output;
function='draw'; x=100; y=17; output;
run;

data tablanno; set tablanno tabllabl grayline ;
run;


			data anno_mixed; 
*set anno anno_mixed; 
set anno_mixed  tablanno;
run;


* plot original data jittered, estimated means and 95% CIs;
  			goptions reset=all device=jpeg gunit=pct noborder htitle=5 htext=3 cback=white	colors = (black)  ftitle=zapf ftext= zapf;
			goptions border;

				axis1 order=(0 to 9 by 1) 
label=(  j=center  "Day of Life"  ) minor=none  /*minor=(number=1)*/ offset=(0,0)  major=none split="_";

/*axis2 label=(f=swissb h=2.5  j=center a=90 "&varlabel"  ) order=(&orderlow TO &orderhigh BY &orderby) 
  major=(height=2 w=2) minor=(number=1 h=1) format=3.1;
*/
 axis2 label=(f=swissb h=2.5  j=center a=90 " "  ) order=(&orderlow TO &orderhigh BY &orderby) 
  major=(height=2 w=2) minor=(number=1 h=1) ;


		*symbol1 value=dot h=1 ;
			

			symbol1 value = diamond co=black h = 3 i = join ;	
		
	 		title1 ls=1.5  "&title";


title2 h=4 "Model-based means and 95% CI ";

/*
title5 a=-90 h=18pct " ";*/
footnote h=10pct " "; 

	        


			proc gplot data = &yvar._mixed   anno= anno_mixed  gout= cmv_rep.graphs; 
			format visit visit.; format estimate 4.0;
				plot 	/*&yvar*visit*/
						estimate*visit	/ anno=tablanno haxis= axis1 vaxis = axis2  
                         nolegend noframe name ="&name"   /*overlay*/ ;
 
  ; 
                        

				;
			run; quit;

			 proc sql;
 			drop table anno_mixed; drop table &yvar._plot; drop table lsmeans_&yvar;
drop table &yvar._mixed;

 			drop table xx; drop table anno1; drop table anno; drop table anno2;
			run;quit; 

			 


%mend ttcmvPlot3;
%ttcmvPlot3(indata=review2,yvar=hb, giflabel=hb_m, varlabel=Hb (mg/dl), title=Hb (mg/dl) over time,orderlow=5, orderhigh=20,orderby=5,name=hb_m );
%ttcmvPlot3(indata=review2,yvar=hct, giflabel=hb_m, varlabel=Hct (mg/dl), title=Hct (mg/dl) over time,orderlow=25, orderhigh=50,orderby=5,name=hct_m );
%ttcmvPlot3(indata=review2,yvar=Weight, giflabel=Weight_m, varlabel=Weight (gms), title=Weight (gms) ,orderlow=600, orderhigh=1800,orderby=200,name=wt_m);
%ttcmvPlot3(indata=review2,yvar=HtLength, giflabel=HtLength_m, varlabel=HtLength (cms), title=Height Length (cms) ,orderlow=25, orderhigh=45,orderby=10,name=ht_m);
%ttcmvPlot3(indata=review2,yvar=HeadCircum, giflabel=HeadCircum_m, varlabel=Head Circumference (cms), title=Head Circumference (cms) ,orderlow=20, orderhigh=35,orderby=5,name=hc_m);

%ttcmvPlot3(indata=review2,yvar=snap2score, giflabel=snap2, varlabel=snap score, title=snap score over time,orderlow=0, orderhigh=15,orderby=5,name=snap_m );


options nodate orientation=landscape;

goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=9in vsize=6in; 



ods rtf  style=ttcmvtables file = "&output./annual/
&growth_plots_panel_file.LBWI_growth_panel_plots.rtf"  
style=journal

toc_data startpage =no bodytitle ;


ods noproctitle proclabel "&growth_plots_panel_title c. LBWI growth plots ";



proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=l2r2s
nofs;
treplay 1:hb_m 3:hct_m 2:wt_m 4:ht_m ; 
treplay 1:hc_m  3:snap_m; 

treplay 1:hb  3:hct 2:wt  4:ht; 

treplay 1:hc 3:snap; 


treplay 1:hb_b 3:hct_b 2:wt_b 4:ht_b ;
treplay  1:hc_b 3:snap_b;
run;

ods rtf close; 
ods listing; 
quit;


goptions /*device=gif gsfname=grafout gsfmode=replace  FTitle=arial  */ hsize=9in vsize=6in ; 

ods rtf  style=ttcmvtables file = "&output./annual/
&growth_plots_whole_file.LBWI_growth_whole_plots.rtf"  
style=journal

toc_data startpage = no bodytitle ;


ods noproctitle proclabel "&growth_plots_whole_title . LBWI growth plots ";



proc greplay igout= cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;
treplay 1:hb_m  ; 

treplay   1:hct_m ; 


treplay   1:wt_m ; 


treplay   1:ht_m ; 


treplay   1:hc_m ; 
treplay   1:snap_m ; 

treplay 1:hb  ; 

treplay 1:hct  ; 

treplay  1:wt ; 

treplay  1:ht ; 

treplay  1:hc; 
treplay  1:snap; 
run;

/* box */

proc greplay igout=cmv_rep.graphs tc=sashelp.templt 	template=whole
nofs;
treplay 1:hb_b  ; 

treplay 1:hct_b  ; 

treplay  1:wt_b ; 

treplay  1:ht_b ; 

treplay  1:hc_b; 

treplay 1:snap_b;
run;

ods rtf close; 
ods listing; 
quit;


