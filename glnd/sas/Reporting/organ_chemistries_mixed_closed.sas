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
proc print data=glnd_ext.chemistries;

where glucose>600;

run;

%let mu=%sysfunc(byte(181));
%put &mu;

* prepare data;
data chemistries;
	set glnd_ext.chemistries;

	* jitter time for plotting;
	day2=day - .3 + .6*uniform(234);	

	* transformations ;
	ln_sgot_ast = log(sgot_ast);
	ln_sgpt_alt = log(sgpt_alt);
	ln_crp = log(crp); 	

	if glucose>600 then glucose=.;

run;



proc sort data=chemistries;by day id;run;


	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
					colors = (black red) /*ftitle=Arial*/ ftext=cent  /*fby =Arial*/ hby = 3;

	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;
	
	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;


%macro make_plots(idx); 
    data chem;
        set chemistries;
        where treatment=&idx;
    run;
    
    %if &idx=1 %then %do; %let trt=Treatment A; %end;
    %if &idx=2 %then %do; %let trt=Treatment B; %end;

	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
	%let l= 1;

  	%do %while (&l < 9);
 		%if &l = 1 %then %do; 	%let variable =bun; %let description = "BUN (mg/dL)";
							%let scale = /*order = (-180 to -70 by 10) */ minor=(number=3); %let y1 = 8; %let y2= 25; %let pic= 'A)'; %end; 

		%if &l = 2 %then %do; 	%let variable =creatinine; %let description = "Creatinine (mg/dL)"; 
							%let scale = /*order = (-110 to -20 by 10) */ minor=(number=4); %let y1 = .7; %let y2= 1.2; %let pic= 'B)'; %end; 

		%if &l = 3 %then %do; 	%let variable =bilirubin; %let description ="Total Bilirubin (mg/dL)";
							%let scale = /*order = (0 to 5 by 0.5) */ minor=(number=4); %let y1 = .3; %let y2= 1.2; %let pic= 'C)'; %end; 

		%if &l = 4 %then %do; 	%let variable =ln_sgot_ast; %let description = "ln[SGOT/AST (U/L)]";
							%let scale = /*order = (0 to 0.2 by 0.05)*/ minor=(number=4); %let y1 = 2.71; %let y2= 3.71; %let pic= 'D)'; %end; /* %let y1 = 15; %let y2= 41; %let pic= 'D)';*/
 
		%if &l = 5 %then %do; 	%let variable =ln_sgpt_alt; %let description = "ln[SGPT/ALT (U/L)]"; 
							%let scale = /*order = (0 to 17 by 1) */ minor=(number=1); %let y1 = 1;%let y2= 3.81; %let pic= 'E)';%end; /* %let y1 = 0; %let y2= 45; %let pic= 'E)';%end;*/

		%if &l = 6 %then %do; 	%let variable =alk_phos; %let description = "Alkaline Phosphatase (U/L)";
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 32; %let y2= 91; %let pic= 'F)';%end; 

		%if &l = 7 %then %do; 	%let variable =glucose; %let description ="Blood Glucose (mg/dL)";
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 80; %let y2= 130; %let pic= 'G)';	%end; 

		*** normal range is not actually -1, but is -2.68. i have set to -1 to fit it on the graph properly!  ***;
		%if &l = 8 %then %do; 	%let variable = ln_crp; %let description = 'ln[C-Reactive Protein(' f=greek 'm' f=triplex 'g/mL)]';
							%let scale = /*order = (0 to 100 by 10)*/ minor=(number=4) ; %let y1 = 1; %let y2= 2.1; %let pic= 'H)';%end;  /* %let y1 = .068; %let y2= 8.2; %let pic= 'H)';%end; */
							

		* get 'n' at each day;
		proc means data=chem noprint;
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
		title2 h=3.5 f=triplex justify=center &description, &trt;
		title3 h=2.5 f=triplex justify=center 'Longitudinal model (means and 95% CI)';

		axis1 	label=(f=triplex h=3 'Day' ) value=(f=cent h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
		axis2 	label=(f=triplex h=3 a=90 &description  ) 	value=(f=cent h=2) &scale ;

************************************************************************************************************;
************************************************************************************************************;
		proc mixed data = chem empirical covtest;
			class id day ; * &source;
		
			model &variable = day / solution ; * &source	day*&source/ solution;
			repeated day / subject = id type = cs;
			lsmeans day / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = chem out=tmp; by day; run;
		proc sort data = lsmeans_&l; by day; run;

		data chem_mean ;
			merge 	tmp lsmeans_&l;	by day;
		run;
			


		DATA anno_mixed_&l; 
			set lsmeans_&l;
			
			xsys='2'; ysys='2';

				* draw a light gray rectangle from 80 to 130;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;;	
			

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

		proc gplot data=chem_mean gout=glnd_rep.graphs;
			plot estimate*day &variable*day2/ overlay haxis = axis1 vaxis = axis2 annotate=anno_mixed_&l nolegend;

			note h=2 f=cent m=(6pct, 9 pct) "Day:" ;
			note h=2 f=cent m=(6pct, 7 pct) "(n)" ;

			format day time_axis. estimate 4.0; 
		run;	

%let l = %eval(&l + 1);
%end;

%mend make_plots;

	ods pdf file = "/glnd/sas/reporting/chemistries.pdf";
		%make_plots(1); 
		%make_plots(2);run;
	ods pdf close;


	* spit out 4 one-page PDF files so that George's program can handle them ;


filename output 'organ1c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;


	ods ps file = "/glnd/sas/reporting/organ1c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs; * L2R2s;
            list igout;
			treplay 1:gplot  2:gplot1 3:gplot8  4:gplot9;;
		run;
	ods ps close;

filename output 'organ2c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;


	ods ps file = "/glnd/sas/reporting/organ2c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs; 
            list igout;
			treplay 1:gplot2 2:gplot3 3:gplot10 4:gplot11;
		run;
	ods ps close;

filename output 'organ3c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;

	ods ps file = "/glnd/sas/reporting/organ3c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs;
            list igout;
			treplay 1:gplot4 2:gplot5 3:gplot12  4:gplot13;
		run;
	ods ps close;

filename output 'organ4c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;
	

	ods ps file = "/glnd/sas/reporting/organ4c.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template= l2r2s nofs;
            list igout;
			treplay 1:gplot6 2:gplot7 3:gplot14 4:gplot15;
		run;
	ods ps close;
quit;
