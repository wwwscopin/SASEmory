/* immune_function_open.sas 
 *
 * create longitudinal boxplots for immune function measurements
 *
 */



* prepare data;
data immune;
	merge glnd.plate47 glnd.status(keep=id treatment); by id; 

	if (dfseq = 1) then day = 0;
	else if (dfseq = 2) then day = 3;
	else if (dfseq = 3) then day = 7;
	else if (dfseq = 4) then day = 14;
	else if (dfseq = 5) then day = 21;
	else if (dfseq = 6) then day = 28;

	* jitter time for plotting;
	day2=day - .3 + .6*uniform(234);	

	* calculated variables ;
	ros_dif = ros_prod_stim - ros_prod_cont;
	phago_dif = phago_stim - phago_cont;

run;

proc sort data=immune;by id day;run;

proc print data = immune;
	var id day ros_prod_stim ros_prod_cont ros_dif phago_stim phago_cont phago_dif;

run;

goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) /*ftitle=Arial*/ ftext=cent  /*fby =Arial*/ hby = 3;

	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;

proc sort data=immune;by day id;run;

         %macro make_plots(idx); 
         
     data immune_plot;
        set immune;
        where treatment=&idx;
    run; 
    
    %if &idx=1 %then %do; %let trt=Treatment A; %end;
    %if &idx=2 %then %do; %let trt=Treatment B; %end;

	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let l= 1;

  	%do %while (&l < 5);

 		%if &l = 1 %then %do; 	%let variable =ros_prod_stim; %let description = f=cent 'Neutrophil ROS production [stimulated] (%), ' "&trt";
							%let scale = order = (0 to 100 by 10)  minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'A)'; %end; 

 		%if &l = 2 %then %do; 	%let variable =ros_dif; %let description = f=cent 'Neutrophil ROS production [stimulated - control] (%), ' "&trt";
							%let scale = order = (0 to 100 by 10)  minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'B)'; %end; 

		%if &l = 3 %then %do; 	%let variable =phago_stim; %let description = f=cent 'Neutrophil phagocytosis [stimulated] (%), ' "&trt"; 
							%let scale = order = (40 to 100 by 10) minor=(number=3); %let y1 = .7; %let y2= 1.2; %let pic= 'C)'; %end; 

		%if &l = 4 %then %do; 	%let variable =phago_dif; %let description = f=cent 'Neutrophil phagocytosis [stimulated - control] (%), ' "&trt"; 
							%let scale = order = (40 to 100 by 10) minor=(number=3); %let y1 = .7; %let y2= 1.2; %let pic= 'D)'; %end; 


		* get 'n' at each day;
		proc means data=immune_plot noprint;
			class day;
			var &variable;
			output out = num n(&variable) = num_obs;
		run;

		* populate 'n' annotation variables ;
		%do i = 0 %to 28;
			data _null_;
				set num;
				where day = &i;
				call symput( "n_&i",  compress(put(num_obs, 3.0)));
			run;
		%end;

		proc format; 
		 	value time_axis   -1=" " 1=" " 0 = "0*(&n_0)"  2=" " 3=" " 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 f=triplex justify=left &pic;
		title2 h=3.5 f=triplex justify=center &description;
		title3 h=2.5 f=triplex justify=center 'Longitudinal model (means and 95% CI)';

		axis1 	label=(f=triplex h=3 'Day' ) value=(f=cent h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=triplex h=3 a=90 &description  ) 	value=(f=cent h=2) &scale ;


************************************************************************************************************;
************************************************************************************************************;
		proc mixed data = immune_plot empirical covtest;
			class id day ; * &source;
		
			model &variable = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = immune_plot out=tmp; by day; run;
		proc sort data = lsmeans_&l; by day; run;

		data immune1 ;
			merge 	tmp lsmeans_&l;	by day;
		run;
			


		DATA anno_mixed_&l; 
			set lsmeans_&l;
			
			xsys='2'; ysys='2';

/*
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
*/

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red';  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=3; color='red'; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
		run;

************************************************************************************************************;


		proc gplot data=immune1 gout=glnd_rep.graphs;
			plot estimate*day  &variable*day2 / overlay haxis = axis1 vaxis = axis2 nolegend annotate=anno_mixed_&l ;

			note h=2 f=cent m=(7pct, 4 pct) "Day:" ;
			note h=2 f=cent m=(7pct, 1 pct) "(n)" ;

			format day time_axis. estimate 4.0; 
		run;	

%let l = %eval(&l + 1);
%end;

%mend make_plots;


		%make_plots(1); run;
		%make_plots(2); run;


	* spit out 2 one-page PS files so that George's program can handle them ;

filename output 'immune1c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/immune1c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot1 3:gplot5 4:gplot6;
		run;
	ods ps close;

filename output 'immune2c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/immune2c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot2 2:gplot3 3:gplot7 4:gplot8;;
		run;
	ods ps close;

quit;
