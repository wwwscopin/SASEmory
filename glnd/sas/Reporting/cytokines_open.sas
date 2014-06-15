*libname cyto "\glnd\Cytokines";


data cyto_plot;
   	set glnd_ext.cytokines;
   	* jitter time for plotting;
   	visit2= visit - .3 + .6*uniform(613);	*using visit, not actual day on study of blood draw	;   
	
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	
	if ifn=0 then group_ifn=1; else group_ifn=0;
	if tnf=0 then group_tnf=1; else group_tnf=0;

run;


/*
data temp;
	set cyto_plot(keep=ifn);
run;

proc sort data=temp; by ifn;run;

proc print;run;

data temp;
	set cyto_plot(keep=tnf);
run;

proc sort data=temp; by tnf;run;
proc print;run;

*/


       goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 ci=blue value=dot h=1;
         
         proc sort data=cyto_plot; by day id; run;
        
         %macro make_plots; 
         	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
         
         	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
				%let m_0= 0; %let m_3= 0; %let m_7= 0; %let m_14= 0; %let m_21= 0; %let m_28= 0;
				%let t_0= 0; %let t_3= 0; %let t_7= 0; %let t_14= 0; %let t_21= 0; %let t_28= 0;

         	%let x= 1;
         
           	%do %while (&x <5);
         
     %if &x = 1 %then %do; 	%let variable =log_il6; %let description = f=zapf 'ln[IL-6 Concentration (pg/ml)]';
       			%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0.447; %let y2= 9.96; %let pic= 'A)'; %end;
         
     %if &x = 2 %then %do; 	%let variable =log_il8; %let description = f=zapf 'ln[IL-8 Concentration (pg/ml)]';
       			%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 = 3.23; %let y2= 24.5; %let pic= 'B)'; %end;

		%if &x = 3 %then %do; 	%let variable =log_ifn; %let description = f=zapf 'ln[IFN' f=greek ' g ' f=zapf 'Concentration (pg/ml)]';
       			%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0.25; %let y2= 15.6; %let pic= 'C)'; %end;
         
     	%if &x = 4 %then %do; 	%let variable =log_tnf; %let description = f=zapf 'ln[TNF' f=greek ' a ' f=zapf 'Concentration (pg/ml)]';
     				%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 =0.25; %let y2= 4.71; %let pic= 'D)'; %end;
         
          		* get 'n' at each day;
         		proc means data=cyto_plot noprint;
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


         		proc means data=cyto_plot noprint;
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


         		proc means data=cyto_plot noprint;
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
         
         		axis1 	label=(f=zapf h=2 'Day' ) value=(f=zapf h=1.55) split="#" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=2 a=90 &description  ) 	value=(f=zapf h=2) &scale ;
         
         
         		data anno;
         			set cyto_plot;
         				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
         	
         				* draw a light gray rectangle ;
          			
						function = 'move'; x = -1; y = log(&y1); output;
         			function = 'BAR'; x = 29; y = log(&y2); color = 'ltgray'; style = 'solid'; line= 0; output;
         									
         		run;
         
         		proc gplot data=cyto_plot gout=glnd_rep.graphs;
         			plot &variable*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2  nolegend annotate=anno;

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;
						%if &variable=log_ifn %then %do; 
										format visit time_axis_B. &variable 4.1; 
										note f='zapf / it' m=(1,1) h=1.5 "* &n_0 = measures | &m_0 = non-detectable";
								%end;
						%if &variable=log_tnf %then %do; 
										format visit time_axis_C. &variable 4.1; 
										note f='zapf / it' m=(1,1) h=1.5 "* &n_0 = measures | &t_0 = non-detectable";
								%end;
						%if &variable=log_il6 or &variable=log_il8 %then %do; format visit time_axis. &variable 4.1;%end;
	         		run;	
         
         %let x = &x + 1;
         %end;
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = landscape;
        	%make_plots run;
        goptions rotate = portrait;
        
        	ods ps file = "/glnd/sas/reporting/cyto_open_p1.ps";
        	ods pdf file = "/glnd/sas/reporting/cyto_open_p1.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot 2:gplot1;
        		run;
        	ods pdf close;
        	ods ps close;

			ods ps file = "/glnd/sas/reporting/cyto_open_p2.ps";
        	ods pdf file = "/glnd/sas/reporting/cyto_open_p2.pdf";
        	*ods pdf file = "cyto_open_p2.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot2 2:gplot3;
	        		run;
        	ods pdf close;
        	ods ps close;
  quit;
