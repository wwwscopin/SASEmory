*libname cyto "\glnd\Cytokines";


data cyto_plot;
   	merge glnd_ext.cytokines glnd.status(keep=id in=tmp); by id;
   	* jitter time for plotting;
   	visit2= visit - .3 + .6*uniform(613);	*using visit, not actual day on study of blood draw	;   
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	if lowcase(ifnc)='nd' then group_ifn=1; else group_ifn=0;
	if lowcase(tnfc)='nd' then group_tnf=1; else group_tnf=0;
	if tmp;
run;


data tmp;
	set cyto_plot;
	where visit=0;
	keep id il6 il8 ifn tnf;
run;



       goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=cent  /*fby =Arial*/ hby = 3;
         	
	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;
         
         proc sort data=cyto_plot; by day id; run;
        
         %macro make_plots(idx); 
         
     data cytop;
        set cyto_plot;
        where treatment=&idx;
    run; 
    
    %if &idx=1 %then %do; %let trt=Treatment A; %end;
    %if &idx=2 %then %do; %let trt=Treatment B; %end;
 
         
         	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
				%let m_0= 0; %let m_3= 0; %let m_7= 0; %let m_14= 0; %let m_21= 0; %let m_28= 0;
				%let t_0= 0; %let t_3= 0; %let t_7= 0; %let t_14= 0; %let t_21= 0; %let t_28= 0;

         	%let l= 1;
         
           	%do %while (&l <5);
         
     %if &l = 1 %then %do; 	%let variable =log_il6; %let description = f=zapf 'ln[IL-6 Concentration (pg/ml)], ' "&trt";
       			%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0.447; %let y2= 9.96; %let pic= 'A)'; %end;
         
     %if &l = 2 %then %do; 	%let variable =log_il8; %let description = f=zapf 'ln[IL-8 Concentration (pg/ml)], ' "&trt";
       			%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 = 3.23; %let y2= 24.5; %let pic= 'B)'; %end;

		%if &l = 3 %then %do; 	%let variable =log_ifn; %let description = f=zapf 'ln[IFN' f=greek ' d ' f=zapf 'Concentration (pg/ml)], ' "&trt";
       			%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0.25; %let y2= 15.6; %let pic= 'C)'; %end;
         
     	%if &l = 4 %then %do; 	%let variable =log_tnf; %let description = f=zapf 'ln[TNF' f=greek ' a ' f=zapf 'Concentration (pg/ml)], ' "&trt";
     				%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 =0.25; %let y2= 4.71; %let pic= 'D)'; %end;
         
          		* get 'n' at each day;
         		proc means data=cytop noprint;
         			class visit;
         			var &variable; 
         			output out = num n(&variable) = num_obs n(&variable) = num_obs;
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
         		 	value time_axis   -1=" " 0 = "0#(&n_0)" 1=" " 2=" " 3="3#(&n_3)" 4=" " 5=" " 6=" " 7="7#(&n_7)" 8=" " 9=" " 10=" " 
         			                   11=" " 12=" " 13=" " 14="14#(&n_14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
         			                   21 = "21#(&n_21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28#(&n_28)"  29=" " 30=" ";
                
         		run;


         		proc means data=cytop noprint;
         			class visit;
         			var group_ifn; 
         			output out = nd_ifn n(group_ifn) = nd_ifn;
						where group_ifn=1;
         		run;
         
         		* populate 'n' annotation variables ;
         		%do i = 0 %to 28;
         			data _null_;
         				set nd_ifn;
         				where visit = &i;
         				call symput( "m_&i",  compress(put(nd_ifn, 3.0)));
         			run;
         		%end;


         		proc format; 
         		 	value time_axis_B   -1=" " 1=" " 0 = "0#(%sysfunc(cats(&n_0,"|",&m_0)))*"  2=" " 3="3#(%sysfunc(cats(&n_3,"|",&m_3)))" 4=" " 5=" " 6=" " 	7="7#(%sysfunc(cats(&n_7,"|",&m_7)))" 8=" " 9=" " 10=" " 
         			11=" " 12=" " 13=" " 14="14#(%sysfunc(cats(&n_14,"|",&m_14)))" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
						21 = "21#(%sysfunc(cats(&n_21,"|",&m_21)))"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28#(%sysfunc(cats(&n_28,"|",&m_28)))"  29=" " 30=" ";
                
         		run;


         		proc means data=cytop noprint;
         			class visit;
         			var group_tnf; 
         			output out = nd_tnf n(group_tnf) = nd_tnf;
						where group_tnf=1;
         		run;
         
         		* populate 'n' annotation variables ;
         		%do i = 0 %to 28;
         			data _null_;
         				set nd_tnf;
         				where visit = &i;
         				call symput( "t_&i",  compress(put(nd_tnf, 3.0)));
         			run;
         		%end;
         
         		proc format; 
         		 	value time_axis_C   -1=" " 0 = "0#(%sysfunc(cats(&n_0,"|",&t_0)))*" 1=" " 2=" " 3="3#(%sysfunc(cats(&n_3,"|",&t_3)))" 4=" " 5=" " 6=" " 	7="7#(%sysfunc(cats(&n_7,"|",&t_7)))" 8=" " 9=" " 10=" " 
         			11=" " 12=" " 13=" " 14="14#(%sysfunc(cats(&n_14,"|",&t_14)))" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
						21 = "21#(%sysfunc(cats(&n_21,"|",&t_21)))"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28#(%sysfunc(cats(&n_28,"|",&t_28)))"  29=" " 30=" ";
                
         		run;



         
         		title1 h=3 justify=left &pic;
         		title2 h=3.5 justify=center &description;
					title3 h=2.5 f=triplex justify=center 'Longitudinal model (means and 95% CI)';
         
         		axis1 	label=(f=cent h=2 'Day' ) value=(f=cent h=1.55) split="#" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=cent h=2 a=90 &description  ) 	value=(f=cent h=2) &scale ;
         
         
************************************************************************************************************;
************************************************************************************************************;

		proc mixed data = cytop empirical covtest;
			class id visit ; * &source;
		
			model &variable = visit / solution ; * &source	day*&source/ solution;
			repeated visit / subject = id type = cs;
			lsmeans visit / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = cytop out=tmp; by visit; run;
		proc sort data = lsmeans_&l; by visit; run;

		data cyto_mean ;
			merge tmp lsmeans_&l;	by visit;
		run;		


		DATA anno_mixed_&l; 
			set lsmeans_&l;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
        				* draw a light gray rectangle ;
          			
						function = 'move'; x = -1; y = log(&y1); output;
         			function = 'BAR'; x = 29; y = log(&y2); color = 'ltgray'; style = 'solid'; line= 0; output;
			

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

         
         		proc gplot data=cyto_mean gout=glnd_rep.graphs;
         			plot estimate*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2  nolegend annotate=anno_mixed_&l;

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;
						%if &variable=log_ifn %then %do; 
										format visit time_axis_B. &variable estimate 4.1; 
										note f='cent / it' m=(1,1) h=1.5 "* &n_0 = measures | &m_0 = non-detectable";
								%end;
						%if &variable=log_tnf %then %do; 
										format visit time_axis_C. estimate &variable 4.1; 
										note f='cent / it' m=(1,1) h=1.5 "* &n_0 = measures | &t_0 = non-detectable";
								%end;
						%if &variable=log_il6 or &variable=log_il8 %then %do; format visit time_axis. estimate &variable 4.1;%end;
	         		run;	
         
         %let l = %eval(&l + 1);
         %end;
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run;
        

        	%make_plots(1); 
        	%make_plots(2);    
        	
 	     	
        	     	     	     	

        	options orientation=landscape;
        	
filename output 'cyto1c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;
        
            ods pdf file = "/glnd/sas/reporting/cyto1c.pdf";
          	ods ps file = "/glnd/sas/reporting/cyto1c.ps";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= l2r2s nofs; * L2R2s;
        			treplay 1:gplot 2:gplot1 3:gplot4 4:gplot5;
        		run;
        	ods ps close;
        	ods pdf close;
        	        	

filename output 'cyto2c.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;

            ods pdf file = "/glnd/sas/reporting/cyto2c.pdf";
			ods ps file = "/glnd/sas/reporting/cyto2c.ps";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= l2r2s nofs; * L2R2s;
        			treplay 1:gplot2 2:gplot3 3:gplot6 4:gplot7;
	        		run;
          	ods ps close;
         	ods pdf close;         	

  quit;