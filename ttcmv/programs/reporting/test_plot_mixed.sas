%include "&include./annual_toc.sas";

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
center = 0; 
output; 
run;


proc mixed data = chemistry_plot empirical covtest;
				class subjectid  treatmentgroup visit;

				where treatmentgroup in (1,2,3);

				model snap2score= visit  treatmentgroup treatmentgroup*visit/solution ;
				repeated visit / subject = subjectid type = un;
				
				lsmeans  visit treatmentgroup treatmentgroup*visit/alpha=.05 cl slice=visit ;

				*format visit visitfmt. Treatmentgroup group.;
				ods output lsmeans = lsmeans_median;
				*ods output tests3=t3_snap2;
			run; 

quit;

			data lsmeans_median;
				set lsmeans_median;

				where Effect = 'treatmentgroup*visit';

if lower < 0 then lower=0;

			run;

data median_plot (keep=subjectid visitlist visit treatmentgroup snap2score visit_jitter); 
set  chemistry_plot; 

visit_jitter= (visit - .1) + .04*uniform(435);
		run;

			
			proc sort data = median_plot; by treatmentgroup visit; run;
			proc sort data = lsmeans_median; by treatmentgroup visit; run;


data median_mixed ;
				merge 	median_plot
						lsmeans_median
					;	
				by treatmentgroup visit;

			
				
				if treatmentgroup = 1 then do; median_trt1  = snap2score;	estimate_trt1 = estimate; end;
				else if treatmentgroup = 2 then do; median_trt2 = snap2score;	estimate_trt2 = estimate; end;
				else  if treatmentgroup = 3 then do; median_trt3 = snap2score;	estimate_trt3 = estimate; end;
		else  if treatmentgroup = 0 then do; median_trt4 = snap2score;	estimate_trt4 = estimate; end;

				if treatmentgroup = 1 then do; visit = visit + .1; visit_jitter = visit_jitter + .1;  end; 
				else if treatmentgroup = 2 then do;  visit = visit - .1; visit_jitter = visit_jitter - .1;  end; 
         else  if treatmentgroup = 2 then do;  visit = visit - .2; visit_jitter = visit_jitter - .2;  end; 

			else  if treatmentgroup = 0 then do;  visit = visit - .25; visit_jitter = visit_jitter - .25;  end;


label median_trt1="EUHM"
						median_trt2="Grady" median_trt3="Northside"
						estimate_trt1="Estimate (EUHM)"
						estimate_trt2="Estimate (Grady)" estimate_trt3="Estimate (NH)"
estimate_trt4="Estimate (Overall)";
			
			run;


 DATA anno_mixed; 
				set median_mixed;
				
				xsys="2"; ysys="2";
							
				
				X=visit; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
				Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; 


			if treatmentgroup = 1 then  color='black'; 
else if treatmentgroup = 2 then  color='Red';
else if treatmentgroup = 3 then  color='Blue'; 
		
 OUTPUT; * draw down;
			
				LINK TIPS; * make bar;

				Y=upper;	FUNCTION='DRAW'; when = "A"; line=1; size=1; 


if treatmentgroup = 1 then  color='black'; 
else if treatmentgroup = 2 then  color='Red';
else if treatmentgroup = 3 then  color='Blue'; 

OUTPUT; * draw up; 
			
				LINK TIPS; * make bar;
			
				* draw top and bottoms of bars;
				TIPS:
				  X=visit-.1; FUNCTION='DRAW'; when = "A"; line=1; size=1; 

if treatmentgroup = 1 then  color='black'; 
else if treatmentgroup = 2 then  color='Red';
else if treatmentgroup = 3 then  color='Blue'; 


OUTPUT;
				  X=visit+.1; FUNCTION='DRAW'; when = "A"; line=1; size=1; 
if treatmentgroup = 1 then  color='black'; 
else if treatmentgroup = 2 then  color='Red';
else if treatmentgroup = 3 then  color='Blue';  


OUTPUT;
				  X=visit;     FUNCTION='MOVE'; when = "A";                                OUTPUT;
				return;

			run;


options nodate orientation=landscape;
ods rtf file = "&output./annual/&snap2_plots_whole_file.snap_mixed_plot.rtf"  style=journal
toc_data startpage =yes bodytitle ;

goptions reset=all rotate=landscape gunit=pct noborder cback=white	colors = (black) ftitle=swissb ftext= swissb;
goptions device=png target=png  xmax=10 in  xpixels=2500 /*can not get this to be right xmax=10 in  xpixels=2500  ymax=20 in  ypixels=2000*/;

ods noproctitle proclabel "snap2_plots_whole_title Longitudinal SNAP II Score Plot ";

			
	axis1 label=(f=swissb h=4 "Day of Life") 
   value=(f=swissb h=2.5  ""  "D4" "D7" "D14"  "D21" "D28" "D40" "D60" "") 
   order=0 to 8 by 1 minor=none;
  axis2 label=(f=swissb h=4 a=90 "SNAP II Score") value=(f=swissb h=2.5)  order=0 to 40 by 10
 major=(h=2 w=2) minor=(number=1 h=1);

	 	 
			symbol1 value=dot h=1.5 color=black;
symbol2 value=star h=1.5 color=red;
symbol3 value=circle h=1.5 color=blue;

			

			symbol4 value = diamond color=black h = 3 i = join ;
			
symbol5 value = star color=red h = 3 i = join ;

symbol6 value = circle color=blue h = 3 i = join ;

			
				Title f=swissb h=4 justify=center  "SNAP II Score : Mean and 95% CI ";

 legend1     across = 1 /*position=(top left inside)*/ position=(top right outside) mode = reserve fwidth = 1
                shape = symbol(6,2.5)  label=(justify = center position = (top center) h= 1.5 "Key :")  value = (f=swissb h=1.5 );
			
	       

			proc gplot data = median_mixed  ;
				plot 	 median_trt1*visit_jitter
							median_trt2*visit_jitter 
						median_trt3*visit_jitter

							estimate_trt1*visit estimate_trt2*visit 	
                 estimate_trt3*visit
/overlay  
							annotate= anno_mixed haxis = axis1 vaxis = axis2 legend = legend1 name="snap" ;

					format visit visit_jitter visit_overall.;

					



						;
run; 

ods rtf close; 
quit;

options nodate orientation=landscape;
ods rtf   file = "&output./annual/&plots_file.snap_mixed.rtf" 
style=journal

toc_data startpage = yes bodytitle ;

ods noproctitle proclabel "&plots_title c. Snap ";
 
goptions device=gif gsfname=grafout gsfmode=replace FTitle=arial hsize=8in vsize=8in; 
proc greplay igout=work.gseg tc=sashelp.templt 	template=whole
nofs;
list igout;


treplay 1:snap ; 
run;
ods rtf close; 
quit;

