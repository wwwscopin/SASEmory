goptions reset = all ;

%macro ttcmvPlot3(indata=,yvar=, giflabel=, Varlabel=,title=, orderlow=,orderhigh=,orderby=,name=,center=,centertxt=,xaxislabel=,yaxislabel=,xlow=,xhigh=,xby=);
		


		data &yvar._plot (keep=id dfseq  visit &yvar dfseq_jitter); set  &indata; 
				visit_jitter= (visit - .2) + .4*uniform(435); where center=&center;
			run;
		
		proc mixed data = &indata   empirical covtest  /* ;  noprint Noprint option some times gives problem */;
				class visit;
			
				where center=&center;

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
			where center =&center
			group by center,visit
			order by center,visit;

			
			run; quit;


data tablanno; set xx;
length text $20.;
length color function $8.;
xsys='2'; ysys='2'; hsys='3'; position='5'; style='swissb'; color='black'  ;
function='move'; x=visit; y=0; output;
ysys='3'; 
function='label';
text=trim(left(put(number,comma4.0))); 
if center In( 0,1,2,3) then y=11; 
/*else if center eq 2 then y=11; 
else if center eq 3 then y=7; */
output;
run;


data tabllabl;
length text $20.;
length color function $8.;
xsys='3'; ysys='3'; hsys='3'; position='6'; style='swissb'; color='black';
x=5; 
y=11; text=' n ='; output;
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

data tablanno; set tablanno tabllabl /*grayline*/ ;
run;


			data anno_mixed; 
*set anno anno_mixed; 
set anno_mixed  tablanno;
run;


* plot original data jittered, estimated means and 95% CIs;
  			goptions reset=all device=jpeg gunit=pct noborder htitle=5 htext=3 cback=white	colors = (black)  ftitle=swissb ftext= swissb;
			goptions border;


				axis1 
label=( f=swiss h=4.0 j=center  "&xaxislabel"  ) minor=none   offset=(0,0) order=(&xlow to &xhigh by &xby)   
value=(f=swiss h=3)
 major=(height=2 ) split="_";


 axis2 label=(f=swissb h=4.0  j=center a=90 "&yaxislabel"  ) order=(&orderlow TO &orderhigh BY &orderby)  value=(f=swiss h=3)
 major=(height=2 )  ;

			

			symbol value = diamond co=black h = 3 i = join ;	
		
	 		title1   "&title ( &centertxt)";


footnote h=7pct " "; 

	       
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


