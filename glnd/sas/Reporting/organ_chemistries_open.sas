/* organ_chemistries.sas 
 *
 * create longitudinal boxplots for organ function chemistries
 *
 */

/*
proc compare data = glnd_ext.chemistries compare = glnd.plate46;
run;

title "Ext Chemistries";
proc print data = glnd_ext.chemistries;
run;

title "Plat 46 Chemistries";
proc print data = glnd.plate46;
run;
*/

* prepare data;
data chemistries;
	set glnd_ext.chemistries;

	* jitter time for plotting;
	day2=day - .3 + .6*uniform(234);	

	* transformations ;
	ln_sgot_ast = log(sgot_ast);
	ln_sgpt_alt = log(sgpt_alt);
	ln_crp = log(crp); 	
run;


goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

					/* Set up symbol for Boxplot */
					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=2;

					/* Set up Symbol for Data Points */
					symbol2 ci=blue value=dot h=1;

proc sort data=chemistries;by day id;run;

%macro make_plots; 
	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 

	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let x= 1;

  	%do %while (&x < 9);

 		%if &x = 1 %then %do; 	%let variable =bun; %let description = f=zapf 'BUN (mg/dL)';
							%let scale = /*order = (-180 to -70 by 10) */ minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'A)'; %end; 

		%if &x = 2 %then %do; 	%let variable =creatinine; %let description = f=zapf 'Creatinine (mg/dL)'; 
							%let scale = /*order = (-110 to -20 by 10) */ minor=(number=4); %let y1 = .7; %let y2= 1.2; %let pic= 'B)'; %end; 

		%if &x = 3 %then %do; 	%let variable =bilirubin; %let description = f=zapf 'Total Bilirubin (mg/dL)';
							%let scale = /*order = (0 to 5 by 0.5) */ minor=(number=4); %let y1 = .3; %let y2= 1.2; %let pic= 'C)'; %end; 

		%if &x = 4 %then %do; 	%let variable =ln_sgot_ast; %let description = f=zapf 'ln[SGOT/AST (U/L)]';
							%let scale = /*order = (0 to 0.2 by 0.05)*/ minor=(number=4); %let y1 = 2.71; %let y2= 3.71; %let pic= 'D)'; %end; /* %let y1 = 15; %let y2= 41; %let pic= 'D)';*/
 
		%if &x = 5 %then %do; 	%let variable =ln_sgpt_alt; %let description = f=zapf 'ln[SGPT/ALT (U/L)]'; 
							%let scale = /*order = (0 to 17 by 1) */ minor=(number=1); %let y1 = 1;%let y2= 3.81; %let pic= 'E)';%end; /* %let y1 = 0; %let y2= 45; %let pic= 'E)';%end;*/

		%if &x = 6 %then %do; 	%let variable =alk_phos; %let description = f=zapf 'Alkaline Phosphatase (U/L)';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 32; %let y2= 91; %let pic= 'F)';%end; 

		%if &x = 7 %then %do; 	%let variable =glucose; %let description = f=zapf 'Blood Glucose (mg/dL)';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 80; %let y2= 130; %let pic= 'G)';	%end; 

		*** normal range is not actually -1, but is -2.68. i have set to -1 to fit it on the graph properly!  ***;
		%if &x = 8 %then %do; 	%let variable = ln_crp; %let description = f=zapf 'ln[C-Reactive Protein (' f=greek h = 4 'm' h=3 f=zapf 'g/mL)]';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = -1; %let y2= 2.1; %let pic= 'H)';%end;  /* %let y1 = .068; %let y2= 8.2; %let pic= 'H)';%end; */

		* get 'n' at each day;
		proc means data=chemistries noprint;
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
		 	value time_axis   -1=" " 1=" " 0 = "0*(&n_0)"  2=" " 3="3*(&n_3)" 4=" " 5=" " 6=" " 7="7*(&n_7)" 8=" " 9=" " 10=" " 
			                   11=" " 12=" " 13=" " 14="14*(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
			                   21 = "21*(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&n_28)"  29=" " 30=" ";               
		run;

		title1 h=3 f=triplex justify=left &pic;
		title2 h=3.5 f=triplex justify=center &description;

		axis1 	label=(f=triplex h=3 'Day' ) value=(f=zapf h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=triplex h=3 a=90 &description  ) 	value=(f=zapf h=2) &scale ;


		data anno;
			set chemistries;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
		run;

		proc gplot data=chemistries gout=glnd_rep.graphs;
			plot &variable*day  &variable*day2 / overlay haxis = axis1 vaxis = axis2 annotate=anno nolegend;

			note h=2 f=zapf m=(7pct, 10 pct) "Day:" ;
			note h=2 f=zapf m=(7pct, 7.5 pct) "(n)" ;

			format day time_axis.; 
		run;	

%let x = &x + 1;
%end;

%mend make_plots;

	ods pdf file = "/glnd/sas/reporting/chemistries.pdf";
		%make_plots run;
	ods pdf close;


	* spit out 4 one-page PDF files so that George's program can handle them ;

	goptions rotate = portrait;

	ods ps file = "/glnd/sas/reporting/organ1.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot1;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/organ2.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs; 
            list igout;
			treplay 1:gplot2 2:gplot3;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/organ3.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
            list igout;
			treplay 1:gplot4 2:gplot5;
		run;
	ods ps close;

	ods ps file = "/glnd/sas/reporting/organ4.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= v2s nofs;
            list igout;
			treplay 1:gplot6 2:gplot7;
			*treplay 1:gplot6 ;
		run;
	ods ps close;

quit;

libname t '';
data t.chemistries;
   set chemistries;
proc contents varnum;
run;
