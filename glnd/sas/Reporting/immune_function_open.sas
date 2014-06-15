/* immune_function_open.sas 
 *
 * create longitudinal boxplots for immune function measurements
 *
 */



* prepare data;
data immune;
	set glnd.plate47;

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
					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

					/* Set up symbol for Boxplot */
					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=2;

					/* Set up Symbol for Data Points */
					symbol2 ci=blue value=dot h=1;

proc sort data=immune;by day id;run;

%macro make_plots; 
	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 

	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let x= 1;

  	%do %while (&x < 5);

 		%if &x = 1 %then %do; 	%let variable =ros_prod_stim; %let description = f=zapf 'Neutrophil ROS production [stimulated] (%)';
							%let scale = order = (0 to 100 by 10)  minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'A)'; %end; 

 		%if &x = 2 %then %do; 	%let variable =ros_dif; %let description = f=zapf 'Neutrophil ROS production [stimulated - control] (%)';
							%let scale = order = (0 to 100 by 10)  minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'B)'; %end; 

		%if &x = 3 %then %do; 	%let variable =phago_stim; %let description = f=zapf 'Neutrophil phagocytosis [stimulated] (%)'; 
							%let scale = order = (40 to 100 by 10) minor=(number=3); %let y1 = .7; %let y2= 1.2; %let pic= 'C)'; %end; 

		%if &x = 4 %then %do; 	%let variable =phago_dif; %let description = f=zapf 'Neutrophil phagocytosis [stimulated - control] (%)'; 
							%let scale = order = (40 to 100 by 10) minor=(number=3); %let y1 = .7; %let y2= 1.2; %let pic= 'D)'; %end; 


		* get 'n' at each day;
		proc means data=immune noprint;
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

		axis1 	label=(f=triplex h=3 'Day' ) value=(f=zapf h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=triplex h=3 a=90 &description  ) 	value=(f=zapf h=2) &scale ;


		data anno;
			set immune;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
		run;

		proc gplot data=immune gout=glnd_rep.graphs;
			plot &variable*day  &variable*day2 / overlay haxis = axis1 vaxis = axis2 nolegend; * annotate=anno ;

			note h=2 f=zapf m=(7pct, 10 pct) "Day:" ;
			note h=2 f=zapf m=(7pct, 7.5 pct) "(n)" ;

			format day time_axis.; 
		run;	

%let x = &x + 1;
%end;

%mend make_plots;

	ods pdf file = "/glnd/sas/reporting/immune_function_open.pdf";
		%make_plots run;
	ods pdf close;


	* spit out 2 one-page PS files so that George's program can handle them ;

	goptions rotate = portrait;

	ods ps file = "/glnd/sas/reporting/immune_function_open_1.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot1;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/immune_function_open_2.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; 
            list igout;
			treplay 1:gplot2 2:gplot3;
		run;
	ods ps close;


quit;
