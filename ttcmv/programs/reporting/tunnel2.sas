data tunnel2;
set a.Tunnel2_blowout;

if company ='Linvatec' then visitlist=1;
if company ='Arthrex' then visitlist=2;

if company ='Sm&Neph' then visitlist=3;

trt=1; subjectid = _n_;
run;


data  chemistry_plot; set tunnel2;  treatmentgroup=trt; visit=	visitlist; run;

proc format;
value visitfmt
1='Linvatec'
2= 'Arthrex'
3= 'Sm&Neph'

; 

value group
1='Overall'
;

value visit_overall
0=''
1='Linvatec'
2= 'Arthrex'
3= 'Sm&Neph'
5=''
; 
run;

%macro mixedplots( data=, var=,label=,orderlow=, orderhigh=, orderby=, titletx=, yaxis=, name=,group=);

proc mixed data = chemistry_plot  covtest;
class subjectid  treatmentgroup visit;

				;

				model &var= visit treatmentgroup treatmentgroup*visit / solution;
				repeated visit /  subject = subjectid;
				*lsmeans visit|treatmentgroup / cl ;
				


				lsmeans treatmentgroup visit treatmentgroup*visit/alpha=.05 cl slice=visit pdiff;

				format visit visitfmt. Treatmentgroup group.;
				ods output lsmeans = lsmeans_median;
				ods output tests3=t3_&var;
run;


			proc sql;
			select 	probf format= PVALUE6.3 into:visitp  
				from  t3_&var
			where effect='visit';

			select 	probf format= PVALUE6.3 into:treatp 
				from  t3_&var
			where effect='treatmentgroup';

			select 	probf format= PVALUE6.3 into:interactionp	 
				from  t3_&var
			where effect='treatmentgroup*visit';

			quit;

			* clean up lsmeans output;
			data lsmeans_median;
				set lsmeans_median;

				where Effect ="treatmentgroup*visit";

			run;


			data median_plot (keep=subjectid visitlist visit treatmentgroup &var visit_jitter); 
set  chemistry_plot; 
*visit_jitter= (visit) + .4*uniform(435);
visit_jitter= (visit - .1) + .04*uniform(435);
		run;

			* merge the means and CIs into cd4_plot to obtain plotting dataset;
			proc sort data = median_plot; by treatmentgroup visit; run;
			proc sort data = lsmeans_median; by treatmentgroup visit; run;

			data median_mixed ;
				merge 	median_plot
						lsmeans_median
					;	
				by treatmentgroup visit;

			
				
				if treatmentgroup = 0 then do; median_trt1  = &var;	estimate_trt1 = estimate; end;
				else if treatmentgroup = 1 then do; median_trt2 = &var;	estimate_trt2 = estimate; end;

				if treatmentgroup = 0 then do; visit = visit + .1; visit_jitter = visit_jitter + .1;  end; * offset the two means;
				else do;  visit = visit - .1; visit_jitter = visit_jitter - .1;  end; 

				


					
				
/*

				label median_trt1="&label (Group A)"
						median_trt2="&label (Group B)"
						estimate_trt1="Estimate (Group A)"
						estimate_trt2="Estimate (Group B)";	*/
			run;


			* draw bars for 95% CIs;
			DATA anno_mixed; 
				set median_mixed;
				
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

			

		
* plot original data jittered, estimated means and 95% CIs;
  			goptions reset=all rotate=landscape gunit=pct noborder cback=white	colors = (black) ftitle=triplex ftext= triplex;

			

	axis1 label=(f=triplex h=4 "Company") value=(f=titalic h=3  "" "Arthrex" "Linvatac" "Sm&Neph"  "") order=0 to 4 by 1 minor=none;
  axis2 label=(f=triplex h=4 a=90 "&yaxis") value=(f=titalic h=3   )  order=&orderlow to &orderhigh by &orderby
 major=(h=1.5 w=2) minor=(number=1 h=1);

	 	
			symbol1 value=dot h=1.5 color=black;
			

			symbol2 value = diamond co=black h = 3 i = join ;
			

			
				Title f=triplex h=4 justify=center  "Mean and 95% CI for &titletx  (p=&visitp)";
			
	        legend1     across = 1 /*position=(top left inside)*/ position=(top right outside) mode = reserve fwidth = 1
                shape = symbol(6,2.5)  label=(justify = center position = (top center) h= 3 "Key:")  value = (f=titalic h=2 );


			proc gplot data = median_mixed  ;
				plot 	 median_trt2*visit_jitter 
							estimate_trt2*visit	/overlay  
annotate= anno_mixed haxis = axis1 vaxis = axis2  legend = nolegend name ="&name";

					format visit visit_jitter visit_overall.;

					



						;
			run; quit;

			proc sql;
			DROP TABLE MEDIAN_MIXED; DROP TABLE MEDIAN_PLOT; 
			DROP TABLE ANNO_MIXED; DROP TABLE LSMEANS_MEDIAN; drop table t3_&var;
			quit; 
%mend;
ods listing;
%mixedplots( data=, var=force,label=Force (N),orderlow=0, orderhigh=2000, orderby=200, titletx=Force ( N ) by Company, yaxis=Force ( N ), name=force,group=1);


data tunnel3;
set a.Tunnel2_blowout;

visitlist2=tunnel_mm;
visitlist=tunnel_mm-6;

trt=1; subjectid = _n_;
run;





data  chemistry_plot; set tunnel3;  treatmentgroup=trt; visit=	visitlist; run;

proc format;
value visitfmt
1='7'
2= '8'
3= '9'
4='10'
; 

value group
1='Overall'
;

value visit_overall
0=''
1='7'
2= '8'
3= '9'
4='10'
5=''
; 
run;


%macro mixedplots( data=, var=,label=,orderlow=, orderhigh=, orderby=, titletx=, yaxis=, name=,group=);

proc mixed data = chemistry_plot  covtest;
class subjectid  treatmentgroup visit;

				;

				model &var= visit treatmentgroup treatmentgroup*visit / solution;
				repeated visit /  subject = subjectid;
				*lsmeans visit|treatmentgroup / cl ;
				


				lsmeans treatmentgroup visit treatmentgroup*visit/alpha=.05 cl slice=visit pdiff;

				format visit visitfmt. Treatmentgroup group.;
				ods output lsmeans = lsmeans_median;
				ods output tests3=t3_&var;
run;


			proc sql;
			select 	probf format= PVALUE6.3 into:visitp  
				from  t3_&var
			where effect='visit';

			select 	probf format= PVALUE6.3 into:treatp 
				from  t3_&var
			where effect='treatmentgroup';

			select 	probf format= PVALUE6.3 into:interactionp	 
				from  t3_&var
			where effect='treatmentgroup*visit';

			quit;

			* clean up lsmeans output;
			data lsmeans_median;
				set lsmeans_median;

				where Effect ="treatmentgroup*visit";

			run;


			data median_plot (keep=subjectid visitlist visit treatmentgroup &var visit_jitter); 
set  chemistry_plot; 
*visit_jitter= (visit) + .4*uniform(435);
visit_jitter= (visit - .1) + .04*uniform(435);
		run;

			* merge the means and CIs into cd4_plot to obtain plotting dataset;
			proc sort data = median_plot; by treatmentgroup visit; run;
			proc sort data = lsmeans_median; by treatmentgroup visit; run;

			data median_mixed ;
				merge 	median_plot
						lsmeans_median
					;	
				by treatmentgroup visit;

			
				
				if treatmentgroup = 0 then do; median_trt1  = &var;	estimate_trt1 = estimate; end;
				else if treatmentgroup = 1 then do; median_trt2 = &var;	estimate_trt2 = estimate; end;

				if treatmentgroup = 0 then do; visit = visit + .1; visit_jitter = visit_jitter + .1;  end; * offset the two means;
				else do;  visit = visit - .1; visit_jitter = visit_jitter - .1;  end; 

				


					
				
/*

				label median_trt1="&label (Group A)"
						median_trt2="&label (Group B)"
						estimate_trt1="Estimate (Group A)"
						estimate_trt2="Estimate (Group B)";	*/
			run;


			* draw bars for 95% CIs;
			DATA anno_mixed; 
				set median_mixed;
				
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

			

		
* plot original data jittered, estimated means and 95% CIs;
  			goptions reset=all rotate=landscape gunit=pct noborder cback=white	colors = (black) ftitle=triplex ftext= triplex;

			

	axis1 label=(f=triplex h=4 "Tunnel Diameter (mm)") value=(f=titalic h=3  "" "7" "8" "9"  "10" "") order=0 to 5 by 1 minor=none;
  axis2 label=(f=triplex h=4 a=90 "&yaxis") value=(f=titalic h=3   )  order=&orderlow to &orderhigh by &orderby
 major=(h=1.5 w=2) minor=(number=1 h=1);

	 	
			symbol1 value=dot h=1.5 color=black;
			

			symbol2 value = diamond co=black h = 3 i = join ;
			

			
				Title f=triplex h=4 justify=center  "Mean and 95% CI for &titletx  (p=&visitp)";
			
	        legend1     across = 1 /*position=(top left inside)*/ position=(top right outside) mode = reserve fwidth = 1
                shape = symbol(6,2.5)  label=(justify = center position = (top center) h= 3 "Key:")  value = (f=titalic h=2 );


			proc gplot data = median_mixed  ;
				plot 	 median_trt2*visit_jitter 
							estimate_trt2*visit	/overlay  
annotate= anno_mixed haxis = axis1 vaxis = axis2  legend = nolegend name ="&name";

					format visit visit_jitter visit_overall.;

					



						;
			run; quit;

			proc sql;
			DROP TABLE MEDIAN_MIXED; DROP TABLE MEDIAN_PLOT; 
			DROP TABLE ANNO_MIXED; DROP TABLE LSMEANS_MEDIAN; drop table t3_&var;
			quit; 
%mend;
%mixedplots( data=, var=force,label=Force (N),orderlow=0, orderhigh=2000, orderby=200, titletx=Force ( N ) by Tunnel Daimeter, yaxis=Force ( N ), name=forD,group=2);


ods listing ;

options nodate orientation=landscape;
ods pdf file="c:\tunnel_plot.pdf"; 
STARTPAGE=on; 
goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=8in vsize=8in; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:force; /* 3:sgpt  2:Hb  4:Creat; */
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:forD; /* 3:sgpt  2:Hb  4:Creat; */
run;
ods pdf close; 
ods listing; 
quit;


options nodate orientation=landscape;
ods rtf file="c:\tunnel_plot.rtf"; 
STARTPAGE=on; 
goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=8in vsize=8in; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:force; /* 3:sgpt  2:Hb  4:Creat; */
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:forD; /* 3:sgpt  2:Hb  4:Creat; */
run;
ods rtf close; 
ods listing; 
quit;
