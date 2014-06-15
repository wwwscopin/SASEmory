/** SIS plots
**/

data a; set sis2; studygroup=trt; visitlist=visit;run;
data chemistry_plot;
set a;


run;

proc format; 
			

			value visit_overall
0=''
1='B'
2= 'M1'
3= 'M2'
4= 'M3'
5=''
; 

value visitfmt2
0=''
1='B'
2= 'M1'
3= 'M2'
4= 'M3'
5=''
; 

value group
0='A'
1='B'
2='Overall'
;

value trt
1='A'
2='B'
3='Overall'
;

value visitfmt
1='Baseline'
2= 'Month 1'
3= 'Month 2'
4= 'Month 3'
; 

		run;

		data chemistry_plot; set chemistry_plot; 




if trt=1 then treatmentgroup=0;
if trt=2 then treatmentgroup=1;
if trt=3 then treatmentgroup=2;

subjectid = patientid;

run;

proc contents data=t3_sisstgs_m;run;
proc sql;
select 	probf  format= PVALUE6.3 into:visitp
from  t3_sisstgs_m
where effect='visit';



			quit;


			quit;
/* SIS plots */
%macro sisplots( data=, var=,label=,orderlow=, orderhigh=, orderby=, titletx=, yaxis=, name=);
proc mixed data = chemistry_plot empirical covtest;
				class subjectid  treatmentgroup visit;

				
			
				where treatmentgroup In (0,1);

				model &var= visit treatmentgroup treatmentgroup*visit / solution;
				repeated visit / subject = subjectid type = un;
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

				label median_trt1="&label (Group A)"
						median_trt2="&label (Group B)"
						estimate_trt1="Estimate (Group A)"
						estimate_trt2="Estimate (Group B)";
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

			

	axis1 label=(f=triplex h=4 "Time on Study (months)") value=(f=titalic h=3  "" "B" "M1" "M2" "M3" "") order=0 to 5 by 1 minor=none;
  axis2 label=(f=triplex h=4 a=90 "&yaxis") value=(f=titalic h=3   )  order=&orderlow to &orderhigh by &orderby
 major=(h=1.5 w=2) minor=(number=1 h=1);

	 	
			symbol1 value=dot h=1.5 color=black;
			symbol2 value=circle h=1.5 color=red;

			symbol3 value = diamond co=black h = 3 i = join ;
			symbol4 value = square co=red h = 3 i = join ;

			
			Title f=triplex h=4 justify=center  "&titletx by treatment group";
			Title2 f=triplex h=3 justify=center  "Mean and 95% Confidence Intervals ";
			Title3 f=triplex h=3 justify=center  "Visit effect (p=&visitp)  Treatment effect (p=&treatp) Interaction effect (p=&interactionp)" ;
	 	
	        legend1     across = 1 /*position=(top left inside)*/ position=(top right outside) mode = reserve fwidth = 1
                shape = symbol(6,2.5)  label=(justify = center position = (top center) h= 3 "Key:")  value = (f=titalic h=2 );


			proc gplot data = median_mixed  ;
				plot 	median_trt1*visit_jitter median_trt2*visit_jitter 
						estimate_trt1*visit	estimate_trt2*visit	/overlay  
annotate= anno_mixed haxis = axis1 vaxis = axis2  legend = legend1 name ="&name";

					format visit visit_jitter visit_overall.;

					



						;
			run; quit;

			proc sql;
			DROP TABLE MEDIAN_MIXED; DROP TABLE MEDIAN_PLOT; 
			DROP TABLE ANNO_MIXED; DROP TABLE LSMEANS_MEDIAN; drop table t3_&var;
			quit;
%mend;
%sisplots( data=, var=SISstgs_m,label=Strength,orderlow=0, orderhigh=100, orderby=20, titletx=A.SIS Strength Domain, yaxis=Strength Domain, name=str);
%sisplots( data=, var=SISmems_m,label=Memory,orderlow=20, orderhigh=100, orderby=20, titletx=B.SIS Memory Domain, yaxis=Memory Domain, name=mem);
%sisplots( data=, var=SISEmos_m,label=Emotion,orderlow=20, orderhigh=100, orderby=20, titletx=C.SIS Emotion Domain, yaxis=Emotion Domain, name=emo);
%sisplots( data=, var=SIScoms_m,label=Communication,orderlow=20, orderhigh=100, orderby=20, titletx=D.SIS Communication Domain, yaxis=Communication Domain, name=com);
%sisplots( data=, var=SISadls_m,label=Daily Living,orderlow=20, orderhigh=100, orderby=20, titletx=E.SIS Daily Living Domain, yaxis=Daily Living Domain, name=adl);
%sisplots( data=, var=SISmobs_m,label=Mobility,orderlow=20, orderhigh=100, orderby=20, titletx=F.SIS Mobility Domain, yaxis=Mobility Domain, name=mob);
%sisplots( data=, var=SISHans_m,label=Hand Function,orderlow=0, orderhigh=100, orderby=20, titletx=G.SIS Hand Function Domain, yaxis=Hand Function Domain, name=han);
%sisplots( data=, var=sisphysd_m,label=Physical,orderlow=20, orderhigh=100, orderby=20, titletx=H.SIS Physical Domain, yaxis=Physical Domain, name=phy);
%sisplots( data=, var=SISHDCs_m,label=Handicap,orderlow=0, orderhigh=100, orderby=20, titletx=I.SIS Handicap Domain, yaxis=Handicap Domain, name=hdc);
%sisplots( data=, var=StrokeRecovery,label=Stroke Recovery,orderlow=0, orderhigh=100, orderby=20, titletx=J.SIS Stroke Recovery ( Hand Function) , yaxis=Stroke Recovery  Hand Function, name=rec);
%sisplots( data=, var=StrokeRecoveryGeneral,label=Stroke Recovery General,orderlow=0, orderhigh=100, orderby=20, titletx=K.SIS Stroke Recovery General , yaxis=Stroke Recovery General, name=recg);


options orientation=portait;
ods pdf file="c:\sis_model_plot.pdf"; 
STARTPAGE=on; 
goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=8in vsize=8in; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:str; /* 3:sgpt  2:Hb  4:Creat; */
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:mem 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:emo 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:com 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:adl 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:mob 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:han 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:phy 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:hdc 	;

proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:rec 	;
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
treplay 1:recg	;
run;
ods pdf close; 
ods listing; 
quit;
