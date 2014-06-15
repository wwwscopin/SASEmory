/* organ_chemistries.sas 
 *
 * create longitudinal boxplots for organ function chemistries
 *
 */

* prepare data;
data flag_lps;
	set glnd_ext.flag_lps;

	* jitter time for plotting;
	visit2 = visit - .3 + .6*uniform(234);		

run;


goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) ftitle=swissx ftext=swissx  fby =swissx hby = 3;

	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;
         

proc sort data=flag_lps ; by id visit ; run;

%macro make_plots(idx); 

    data flps;
        set flag_lps;
        where treatment=&idx;
    run; 
    
    %if &idx=1 %then %do; %let trt=Treatment A; %end;
    %if &idx=2 %then %do; %let trt=Treatment B; %end;


	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let l= 1;

  	%do %while (&l < 9);

 		%if &l = 1 %then %do; 	%let variable = flag_new; %let description = f=swissx 'Flagellin (O.D.), '"&trt";
							%let scale =  order = (0 to 1 by .1)   minor=(number=1); %let y1 = 0.35; %let y2= 0; %let pic= 'A)'; %end; 

		%if &l = 2 %then %do; 	%let variable = lps_30_min; %let description = f=swissx 'LPS (O.D.), ' "&trt"; 
							%let scale = /* order = (0 to 1.5 by .1) */ minor=(number=1); %let y1 = 0.1; %let y2= 0; %let pic= 'B)'; %end; 

		%if &l = 3 %then %do; 	%let variable = anti_flag_IgG; %let description = f=greek h = 4 'a' h=3 f=swissx '-Flagellin IgG (O.D.), ' "&trt";
							%let scale = /* order = (0 to 1.5 by .1)  */ minor=(number=1); %let y1 = .07; %let y2= 1; %let pic= 'A)'; %end; 

		%if &l = 4 %then %do; 	%let variable = anti_flag_IgA; %let description = f=greek h = 4 'a' h=3 f=swissx '-Flagellin IgA (O.D.), ' "&trt";
							%let scale =  /* order = (0 to 2 by .25) */ minor=none; %let y1 = .04; %let y2= .9; %let pic= 'B)'; %end;
 
		%if &l = 5 %then %do; 	%let variable = anti_flag_IgM; %let description = f=greek h = 4 'a' h=3 f=swissx '-Flagellin IgM (O.D.), ' "&trt";
							%let scale = /* order = (0 to 2.5 by .25) */ minor=none; %let y1 = .6; %let y2= 1.2; %let pic= 'C)';%end; 

		%if &l = 6 %then %do; 	%let variable = anti_lps_IgG; %let description = f=greek h = 4 'a' h=3 f=swissx '-LPS IgG (O.D.), ' "&trt";
							%let scale = /* order = (0 to 1 by .1) */ minor=(number=1) ; %let y1 = .4; %let y2= .8; %let pic= 'A)';%end; 

		%if &l = 7 %then %do; 	%let variable = anti_lps_IgA; %let description = f=greek h = 4 'a' h=3 f=swissx '-LPS IgA (O.D.), ' "&trt";
							%let scale = /* order = (0 to 2 by .25) */ minor=none ; %let y1 = .4; %let y2= .8; %let pic= 'B)';	%end; 

		%if &l = 8 %then %do; 	%let variable = anti_lps_IgM; %let description = f=greek h = 4 'a' h=3 f=swissx '-LPS IgM (O.D.), ' "&trt";
							%let scale = /* order = (0 to 3.5 by .5) */ minor=(number=4) ; %let y1 = .8; %let y2= 1.4; %let pic= 'C)';%end; 

		* get 'n' at each day;
		proc means data	=	flps noprint;
			class visit;
			var &variable;
			output out = num n(&variable) = num_obs;
		run;

		* populate 'n' annotation variables ;
		%do i = 0 %to 28;
			data _null_;
				set num;
				where visit = &i;
				call symput( "n_&i",  compress(put(num_obs, 3.0)));
			run;
		%end;

		proc format; 
		 	value time_axis   -1=" " 1=" " 0 = "0*(&n_0)"  2=" " 3="3*(&n_3)" 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 justify=left &pic;
		title2 h=3 justify=center &description;
		title3 h=3 f=triplex justify=center 'Longitudinal model (means and 95% CI)';

		axis1 	label=(h=3 'Day' ) value=(h=2.5) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(h=4 a=90 &description  ) 	value=(h=2.5) &scale ;


************************************************************************************************************;
************************************************************************************************************;

		proc mixed data = flps empirical covtest;
			class id visit ; * &source;
		
			model &variable = visit / solution ; * &source	day*&source/ solution;
			repeated visit / subject = id type = cs;
			lsmeans visit / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = flps out=tmp; by visit; run;
		proc sort data = lsmeans_&l; by visit; run;

		data flps_mean ;
			merge tmp lsmeans_&l;	by visit;
		run;		


		DATA anno_mixed_&l; 
			set lsmeans_&l;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
			%if &l < 3 %then %do;
				* draw a dotted line at the detection threshold;
				function = 'move'; x = -1; y = &y1; output;
				function = 'draw'; x = 29; y = &y1; color = 'black';  line= 2; size = 3; output;
			%end;

			%else %do;
				* draw a light gray rectangle, indicating normal ranges;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;
			%end;
			

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=visit; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=visit-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=visit+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=visit;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;


		proc gplot data=flps_mean gout=glnd_rep.graphs;
			plot estimate*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2 annotate=anno_mixed_&l nolegend;

			note h=2.5 m=(7pct, 15 pct) "Day:" ;
			note h=2.5 m=(7pct, 12 pct) "(n)" ;

			format visit time_axis. estimate 4.1; 

			%if (&l = 1) | (&l = 2) %then %do; 
				footnote justify=left  h=2.5 "Dotted line at OD =" &y1 "indicates threshold of detectable true presence in serum";
			%end;
			%else %do;
				footnote " " ;
			%end;

		run;	

%let l = %eval(&l + 1);
%end;

%mend make_plots;

goptions rotate = landscape;

* clear graph catalog ;

	proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run; 

		%make_plots(1); run;
		%make_plots(2); run;
	
	
	goptions reset=all rotate = portrait;

	ods pdf file = "/glnd/sas/reporting/flag_lps_tiled.pdf";		
		ods ps file = "/glnd/sas/reporting/flag_lps_tiled_1.ps";
		proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
			treplay 1:gplot  2:gplot1;
		run;
		ods ps close;

	goptions rotate = landscape;

		proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= l2r2s nofs; * L2R2s;
			treplay 1:gplot2 3:gplot3 2:gplot4;
			treplay 1:gplot5 3:gplot6 2:gplot7;
		run;
	ods pdf close;


filename output 'flps1.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/flps1.ps";
		proc greplay nofs; igout = glnd_rep.graphs ;
            list igout;
            tc template;
                tdef t1 3 /llx=0    ulx=0   lrx=50   urx=50   lly=5    uly=35    lry=5      ury=35
                        2 /llx=0    ulx=0   lrx=50   urx=50   lly=35   uly=65    lry=35     ury=65
                        1 /llx=0    ulx=0   lrx=50   urx=50   lly=65   uly=95    lry=65     ury=95
                		6 /llx=50   ulx=50  lrx=100  urx=100  lly=5    uly=35    lry=5      ury=35
                        5 /llx=50   ulx=50  lrx=100  urx=100  lly=35   uly=65    lry=35     ury=65
                        4 /llx=50   ulx=50  lrx=100  urx=100  lly=65   uly=95    lry=65     ury=95
			;
           template t1;
           tplay 1:3 2:4 3:5 4:12 5:13 6:14;
		run;
	ods ps close;

filename output 'flps2.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

	
	ods ps file = "/glnd/sas/reporting/flps2.ps";
		proc greplay nofs; igout = glnd_rep.graphs ;
            list igout;
            tc template;
                  tdef t1 
                        3 /llx=0    ulx=0   lrx=50   urx=50   lly=5    uly=35    lry=5      ury=35
                        2 /llx=0    ulx=0   lrx=50   urx=50   lly=35   uly=65    lry=35     ury=65
                        1 /llx=0    ulx=0   lrx=50   urx=50   lly=65   uly=95    lry=65     ury=95
                		6 /llx=50   ulx=50  lrx=100  urx=100  lly=5    uly=35    lry=5      ury=35
                        5 /llx=50   ulx=50  lrx=100  urx=100  lly=35   uly=65    lry=35     ury=65
                        4 /llx=50   ulx=50  lrx=100  urx=100  lly=65   uly=95    lry=65     ury=95
			;
           template t1;
           tplay 1:6 2:7 3:8 4:15 5:16 6:17;
		run;
	ods ps close;
	
quit;
