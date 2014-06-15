%include "&include./annual_toc.sas";


libname cmv_rep "/ttcmv/sas/programs/reporting";

%include "z_score_longitudinal.sas";

data Med_review; set anthro_olsen; run;

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

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth ,BirthWeight as weight,Length,HeadCircum,gender,dfseq,olsen_weight_z,olsen_length_z,olsen_hc_z
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

create table medreview as
select a.id  , b.gender ,Weight as weight,HtLength as length,HeadCircum,dfseq,olsen_weight_z,olsen_length_z,olsen_hc_z
from 
cmv.valid_ids as a
left join

Med_review as b
on a.id =b.id;



create table patients as
select id, gender,weight,length,HeadCircum,dfseq ,olsen_weight_z,olsen_length_z,olsen_hc_z from enrolled
union
select id, gender, weight,length,HeadCircum,dfseq ,olsen_weight_z,olsen_length_z,olsen_hc_z from medreview where dfseq >1;


quit;



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


value visit_overall
0='0'
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8='60'
9='90'
; 

value visitfmt
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

value group
0='A'
1='B'
2='Overall'
;

value trt
0='A'
1='B'
2='Overall'
;

value visitfmt
1='1'
2='4'
3 ='7'
4='14'
5='21'
6='28'
7='40'
8='60'
9='90'
; 

run;


data chemistry_plot; set patients;
where gender in (1,2); 

if gender=1 then treatmentgroup=0;
if gender=2 then treatmentgroup=1;

if dfseq =0 then visit=0;
if dfseq =1 then visit=1;
if dfseq =4 then visit=2;
if dfseq =7 then visit=3;
if dfseq =14 then visit=4;
if dfseq =21 then visit=5;
if dfseq =28 then visit=6;
if dfseq =40 then visit=7;
if dfseq =60 then visit=8;
if dfseq =63 then visit=9;

visitlist=visit;
subjectid = id;

run;

%macro mixedtwogpplots( data=, var=,label=,orderlow=, orderhigh=, orderby=, titletx=, yaxis=, name=);
proc mixed data = chemistry_plot empirical covtest;
				class subjectid  treatmentgroup visit;

				
			
				where treatmentgroup In (0,1);

				model &var= visit treatmentgroup treatmentgroup*visit / solution;
				repeated visit / subject = subjectid type = cs;
				
				lsmeans treatmentgroup visit treatmentgroup*visit/alpha=.05 cl slice=visit pdiff;

				/*format visit visitfmt. Treatmentgroup group.;*/
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

			run;
				data median_mixed ; set median_mixed;
				if treatmentgroup = 0 then do; median_trt1  = &var;	estimate_trt1 = estimate; end;
				if treatmentgroup = 1 then do; median_trt2 = &var;	estimate_trt2 = estimate; end;
            
				if treatmentgroup = 0 then do; visit = visit + .1; visit_jitter = visit_jitter + .1;  end; 
				if treatmentgroup = 1 then do;  visit = visit - .1; visit_jitter = visit_jitter - .1;  end; 
                           

				label median_trt1="&label (Males) " 
                median_trt2="&label (Females)"
						estimate_trt1="Estimate (Males)"
						estimate_trt2="Estimate (Females)" ;
       
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
  goptions reset=all rotate=portrait gunit=pct noborder device=jpeg gsfname=grafout gsfmode=replace  
 vcback=white	colors = (black)  ftext= zapf ;

			*goptions    hsize=8in vsize=9in ; 

	axis1 label=(f=zapf h=4 'Day of Life') value=(f=zapf h=3   ) order=0 to 9 by 1 minor=none;
  axis2 label=(f=zapf h=4 a=90 "&yaxis") value=(f=zapf h=3   )  order=&orderlow to &orderhigh by &orderby
 major=(h=1.5 w=2) minor=(number=1 h=1);

	 	
			symbol1 value=dot h=1.5 color=black;
			symbol2 value=circle h=1.5 color=red;

			symbol3 value = diamond co=black h = 3 i = join ;
			symbol4 value = square co=red h = 3 i = join ;

	 	symbol1 value=dot h=1.5 color=black;
			symbol2 value=circle h=1.5 color=red;

			symbol3 value = diamond co=black h = 3 i = join ;
			symbol4 value = square co=red h = 3 i = join ;

legend1     across = 1  position=(top right outside) mode = reserve fwidth = 1
          shape = symbol(6,2.5)  label=( f=zapf h=2  justify = center position = (top center)  "Key:")  value = (f=zapf h=2  );

			
			Title  h=14pt justify=center  "&titletx by Gender";
			Title2 h=12pt justify=center  "Mean and 95% Confidence Intervals ";

		proc gplot data = median_mixed  gout= cmv_rep.graphs;
				plot 	median_trt1*visit_jitter median_trt2*visit_jitter 
						estimate_trt1*visit	estimate_trt2*visit	/overlay  
annotate= anno_mixed haxis = axis1 vaxis = axis2  legend = legend1 name ="&name";

					format visit visit_jitter visit_overall.;

					



						;
			run; quit;	
		
							


			
%mend;

proc greplay    igout= cmv_rep.graphs  nofs; 
delete _all_; 
run;

%mixedtwogpplots( data=, var=weight,label=Weight,orderlow=400, orderhigh=3200, orderby=200, titletx=Figure 10: Weight, yaxis= Weight (gms), name=wei);
%mixedtwogpplots( data=, var=length,label=Length,orderlow=30, orderhigh=50, orderby=5, titletx=Figure 11: Length , yaxis=Length (cms), name=len);
%mixedtwogpplots( data=, var=headcircum,label=Circumference,orderlow=20, orderhigh=40, orderby=5, titletx=Figure 12: Head Circumference , yaxis=Head Circumference (cms), name=cir);



/*
%mixedtwogpplots( data=, var=olsen_weight_z,label=Weight (Z-score),orderlow=-5, orderhigh=10, orderby=1, titletx=Weight (Z score) , yaxis=Weight (Z-score), name=wei_o);

%mixedtwogpplots( data=, var=olsen_length_z,label=Length (Z-score),orderlow=-5, orderhigh=5, orderby=1, titletx=Length (Z score) , yaxis=Length (Z-score), name=len_o);

%mixedtwogpplots( data=, var=olsen_hc_z,label=Length (Z-score),orderlow=-5, orderhigh=8, orderby=1, titletx=Head Circumference (Z score) , yaxis=Head Circumference(Z-score), name=cir_o);
*/

%include "box_plot_macro.sas";


