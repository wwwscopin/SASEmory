%include "&include./annual_toc.sas";

/* line plots */
proc format;


value visit
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8=''
;

run;



data review; set cmv.Med_review;
id2 = left(trim(id));
center = input(substr(id2, 1, 1),1.);

run;

proc means data=review n  mean std min max clm; class dfseq; var headcircum;run;

proc mixed data=review;
class dfseq;
model hb=dfseq/solution;
repeated dfseq / subject = id type = cs;
				lsmeans dfseq / cl ;
ods output lsmeans = lsmeans_hb;
run;


data review; set review;
if dfseq=1 then visit=1;
if dfseq=4 then visit=2;
if dfseq=7 then visit =3;
if dfseq=14 then visit =4;
if dfseq=21 then visit=5;
if dfseq = 28 then visit=6;
if dfseq=40 then visit=7;

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

goptions reset = all;
%macro line_plot (data= ,var = , label = , studygroup=, by=,n=); 
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
/*Filename gout1 "c:\&var&out..gif";*/ 
goptions reset=all hsize = 8in /*vsize =8in device=GIF gsfmode=replace gsfname=gout1*/; 
footnote1 ;  font=arial;


axis1   order=(0 to 8 by 1) value=( f=titalic h=1.5  "" "1" "4" "7" "14" "21" "28" "40"  "") 
label=(f=triplex h=3 "Day of Life" ) minor = none; 

axis2 order=(&min1 to &y by &by) label= (f=triplex h=3 angle = 90 "&label" ) value=( f=titalic h=1.5 ) 
 major=(h=2 w=2) minor=(number=2 h=1);

symbol1 value = dot h=1.0 i=join repeat = 200; 

proc gplot data=&data gout=gseg ; 

plot &var*visit=id / name ="&n&out" nolegend frame haxis=axis1 vaxis=axis2  /* annotate=linetext*/;

title1 f=triplex h=3 justify=center "&label over time";
run;
quit; 
%end;
%mend;
proc greplay nofs igout=Work.Gseg; 
delete _all_; 
run; 
quit; 
%line_plot(data=review ,var=hb, label=Hb (mg/dL) , studygroup=1, by=1,n=Hb); 
%line_plot(data=review ,var=Weight, label=Weight (gms) , studygroup=2,by=100, n=wt); 
%line_plot(data=review ,var= HtLength, label= Height Length (cms) , studygroup=3,by=1, n=ht); 
%line_plot(data=review ,var= HeadCircum, label= Head Circumference (cms) , studygroup=4,by=1, n=hc); 



proc means data = review fw=5 maxdec=1 nonobs n mean stddev median min max q1 q3 clm; 
class visit; 
var hb; 
ods output summary = hb; 
run;


proc contents data=review;run;


proc mixed data=review;
class visit;
model hb=visit/solution;
repeated visit / subject = id type = cs;
				lsmeans visit / cl ;
ods output lsmeans = lsmeans_hb;
run;


%macro ttcmvPlot(indata=,yvar=, giflabel=, Varlabel=,title=, orderlow=,orderhigh=,orderby=,name=);

		data &yvar._plot (keep=id dfseq  visit &yvar dfseq_jitter); set  &indata; 
				visit_jitter= (visit - .2) + .4*uniform(435); where center>0;
			run;
		
		proc mixed data = &indata   empirical covtest  /* ;  noprint Noprint option some times gives problem */;
				class visit;
			
				where center>0;

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


			* for sample size ;

			proc sql;
			create table xx as
			select center,visit, count(&yvar)  as number
			from &indata
			
			group by center,visit
			order by center,visit;

			

			run; quit;


			data anno1;
set xx;
/*by treatmentgroup; */
length text $40 function $ 6;
retain function 'label' position '5' size 1.5;
xsys='2';
ysys='3';
if visit=0 then do;
text="n="||left(put(number,3.));
end;
else do;
text=left(put(number,3.));
end;
x=visit;
y=3;
if center=0 then y=3;
else if center=2 then y=1.0; 
/*else if center=3 then y=1.0; */
run;

*** annotation for footenote --- part 2;
data anno2;
length text $40.;
retain function 'label' xsys '3' ysys '3' position '6'
size 1.5;
position='6';
x=2; y=5.0; text="# of LBWI"; output;
x=2; y=3.0; text="Overall (n=)"; output;
x=2; y=1.0; text="Grady (n=)"; output;
run;
data anno;
set anno1 anno2;
run;

data anno_mixed; set anno anno_mixed; run;


* plot original data jittered, estimated means and 95% CIs;
  			goptions reset=all /*rotate=landscape gunit=pct */noborder cback=white	colors = (black) ftitle=triplex ftext= triplex;


				axis1   label=(f=triplex h=3  j=right  "Day of Life"  )
           order=(0 to 8 by 1) value=( f=titalic h=3  "" "1" "4"  "7" "14" "21" "28" "40"  "")  minor= none split="*" ;  

axis2 	label=(f=triplex h=3 a=90 "&varlabel" ) 	value=(f=titalic h=3)  order = &orderlow TO &orderhigh BY &orderby
							major=(h=2 w=2) minor=(number=2 h=1);


							
	 	
			symbol1 value=dot h=1 ;
			/*symbol2 value=circle h=1;	*/

			symbol2 value = diamond co=black h = 3 i = join ;
			/*symbol4 value = square co=black h = 3 i = join ; */

			
		
	 		title1 f=triplex h=3 justify=center "&title";
			
			title2 f=triplex h=2 justify=center "Model-based means and 95% CI";

	        legend1     across = 1 /*position=(top left inside)*/ position=(top left inside) mode = reserve fwidth = 1
                shape = symbol(6,2.5)  label=(justify = center position = (top center) h=3 "Key:")  value = (f=titalic h=2 );


			proc gplot data = &yvar._mixed  gout= Gseg;
				plot 	&yvar*visit
						estimate*visit	/overlay  annotate= anno_mixed haxis = axis1 vaxis = axis2 /*vref=&vrefLow vref=&vrefHigh vref=&vhrefgrade3*/ 
                         legend = legend1 name ="&name";

					format visit visit.;

					


					/*label  
						&yvar._trt1 = "HAART data"
						&yvar._trt2 = "LPV/r + RAL data"
						estimate_trt1 = "HAART mean"
						estimate_trt2 = "LPV/r + RAL mean"  */
						;
			run; quit;

			 proc sql;
 			drop table anno_mixed; drop table &yvar._plot;

 			drop table xx; drop table anno1; drop table anno; drop table anno2;
			run;quit; 


%mend ttcmvPlot;
%ttcmvPlot(indata=review2,yvar=hb, giflabel=hb_m, varlabel=Hb (mg/dl), title=Hb (mg/dl) ,orderlow=6, orderhigh=18,orderby=2,name=hbm);
%ttcmvPlot(indata=review2,yvar=Weight, giflabel=Weight_m, varlabel=Weight (gms), title=Weight (gms) ,orderlow=200, orderhigh=1800,orderby=200,name=wtm);
%ttcmvPlot(indata=review2,yvar=HtLength, giflabel=HtLength_m, varlabel=HtLength (cms), title=Height Length (cms) ,orderlow=20, orderhigh=50,orderby=10,name=htm);
%ttcmvPlot(indata=review2,yvar=HeadCircum, giflabel=HeadCircum_m, varlabel=Head Circumference (cms), title=Head Circumference (cms) ,orderlow=20, orderhigh=30,orderby=5,name=hcm);




	/* plots */

options nodate orientation=landscape;

ods rtf  style=ttcmvtables file = "&output./annual/&plots_file.plot.rtf"  style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&plots_title c. Plots ";

*ods rtf file="c:\ttcmv.rtf"; 
*STARTPAGE=on; 
goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=10in vsize=7in; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Hb1 ; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Wt1 ; 

proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Ht1;

proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Hc1 ;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay  1:hbm; 


proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Wtm; 


proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Htm;



proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:Hcm;
run;
ods rtf close; 
ods listing; 
quit; 


proc contents data=review2;run;
