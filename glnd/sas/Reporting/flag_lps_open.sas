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

proc means min max;
var anti_flag_IgG anti_flag_IgA anti_flag_IgM anti_lps_IgG anti_lps_IgA anti_lps_IgM;
run;


data temp;
    set flag_lps;
    if .<anti_flag_IgG<=0 then anti_flag_IgG_missing=1; else anti_flag_IgG_missing=0;
    if .<anti_flag_IgA<=0 then anti_flag_IgA_missing=1; else anti_flag_IgA_missing=0;
    if .<anti_flag_IgM<=0 then anti_flag_IgM_missing=1; else anti_flag_IgM_missing=0;
    
    if .<anti_lps_IgG<=0 then anti_lps_IgG_missing=1; else anti_lps_IgG_missing=0;
    if .<anti_lps_IgA<=0 then anti_lps_IgA_missing=1; else anti_lps_IgA_missing=0;
    if .<anti_lps_IgM<=0 then anti_lps_IgM_missing=1; else anti_lps_IgM_missing=0;
run;
proc freq data=temp;
table treatment*anti_flag_IgG_missing*visit/nopercent norow;
table treatment*anti_flag_IgA_missing*visit/nopercent norow;
table treatment*anti_flag_IgM_missing*visit/nopercent norow;
table treatment*anti_lps_IgG_missing*visit/nopercent norow;
table treatment*anti_lps_IgA_missing*visit/nopercent norow;
table treatment*anti_lps_IgM_missing*visit/nopercent norow;
run;


goptions reset=all  device=pslepsfc rotate=landscape gunit=pct noborder cback=white 
					colors = (black red)  ftext=triplex   hby = 3;

					/* Set up symbol for Boxplot */
					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=0.8;

					/* Set up Symbol for Data Points */
					symbol2 ci=red value=dot h=1;
					symbol3 ci=blue value=dot h=1;

proc sort data=flag_lps ; by id visit ; run;

%macro make_plots; 
	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let x= 1;

  	%do %while (&x < 9);

 		%if &x = 1 %then %do; 	%let variable = flag_new; %let description ='Flagellin (O.D.)';
							%let scale =  order = (0 to 0.4 by .05)   minor=(number=1); %let y1 = 0.35; %let y2= 0; %let pic= 'A)'; %end; 

		%if &x = 2 %then %do; 	%let variable = lps_30_min; %let description = 'LPS (O.D.)'; 
							%let scale = /* order = (0 to 1.5 by .1) */ minor=(number=1); %let y1 = 0.1; %let y2= 0; %let pic= 'B)'; %end; 

		%if &x = 3 %then %do; 	%let variable = anti_flag_IgG; %let description = f=greek h = 4 'a' h=3 f=triplex '-Flagellin IgG (O.D.)';
							%let scale = /* order = (0 to 1.5 by .1)  */ minor=(number=1); %let y1 = .07; %let y2= 1; %let pic= 'C)'; %end; 

		%if &x = 4 %then %do; 	%let variable = anti_flag_IgA; %let description = f=greek h = 4 'a' h=3 f=triplex '-Flagellin IgA (O.D.)';
							%let scale =  /* order = (0 to 2 by .25) */ minor=none; %let y1 = .04; %let y2= .9; %let pic= 'D)'; %end;
 
		%if &x = 5 %then %do; 	%let variable = anti_flag_IgM; %let description = f=greek h = 4 'a' h=3 f=triplex '-Flagellin IgM (O.D.)';
							%let scale = /* order = (0 to 2.5 by .25) */ minor=none; %let y1 = .6; %let y2= 1.2; %let pic= 'E)';%end; 

		%if &x = 6 %then %do; 	%let variable = anti_lps_IgG; %let description = f=greek h = 4 'a' h=3 f=triplex '-LPS IgG (O.D.)';
							%let scale = /* order = (0 to 1 by .1) */ minor=(number=1) ; %let y1 = .4; %let y2= .8; %let pic= 'F)';%end; 

		%if &x = 7 %then %do; 	%let variable = anti_lps_IgA; %let description = f=greek h = 4 'a' h=3 f=triplex '-LPS IgA (O.D.)';
							%let scale = /* order = (0 to 2 by .25) */ minor=none ; %let y1 = .4; %let y2= .8; %let pic= 'G)';	%end; 

		%if &x = 8 %then %do; 	%let variable = anti_lps_IgM; %let description = f=greek h = 4 'a' h=3 f=triplex '-LPS IgM (O.D.)';
							%let scale = /* order = (0 to 3.5 by .5) */ minor=(number=4) ; %let y1 = .8; %let y2= 1.4; %let pic= 'H)';%end; 


        data flag_lps;
            set flag_lps;
            if treatment=1 then &variable.1=&variable;
            if treatment=2 then &variable.2=&variable;
        run;


		* get 'n' at each day;
		proc means data	=	flag_lps noprint;
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

		axis1 	label=(h=3 'Day' ) value=( h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(h=3 a=90 &description  ) 	value=(h=2) &scale ;


		data anno;
			set flag_lps;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
			%if &x < 3 %then %do;
				* draw a dotted line at the detection threshold;
				function = 'move'; x = -1; y = &y1; output;
				function = 'draw'; x = 29; y = &y1; color = 'black';  line= 2; size = 4; output;
			%end;

			%else %do;
				* draw a light gray rectangle, indicating normal ranges;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;
			%end;
		run;

		proc gplot data=flag_lps gout=glnd_rep.graphs;
			plot &variable*visit  &variable.1*visit2 &variable.2*visit2/ overlay haxis = axis1 vaxis = axis2 annotate=anno nolegend;

			format visit time_axis. &variable 4.1; 
            %if (&x = 1) %then %do; 
			format visit time_axis. &variable 4.2; 
			%end;

			%if (&x = 1) | (&x = 2) %then %do; 
    			note h=2 m=(7pct, 12 pct) "Day:" ;
	       		note h=2 m=(7pct, 9.75 pct) "(n)" ;
				footnote justify=left  h=2.5 "Dotted line at OD =" &y1 "indicates threshold of detectable true presence in serum";
			%end;
			%else %do;
    			note h=2 m=(7pct, 10.5 pct) "Day:" ;
	       		note h=2 m=(7pct, 8.25 pct) "(n)" ;
				footnote " " ;
			%end;

		run;	

%let x = &x + 1;
%end;

%mend make_plots;

/*
	goptions rotate = landscape;
	ods pdf file = "/glnd/sas/reporting/flag_lps.pdf";
		%make_plots run;
	ods pdf close;
*/
	* make tiled plots ;
* clear graph catalog ;

	proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run; 

    
	%make_plots run;
	goptions rotate = portrait;
	ods pdf file = "/glnd/sas/reporting/flag_lps.pdf";		
		ods ps file = "/glnd/sas/reporting/flag_lps_box.ps";
		proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
			treplay 1:1  2:2;
			treplay 1:3  2:4;
			treplay 1:5  2:6;
			treplay 1:7  2:8;
		run;
		ods ps close;
quit;
