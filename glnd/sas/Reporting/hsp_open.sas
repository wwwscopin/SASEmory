
libname glnd_rep "/glnd/sas";

          /* hsp_open.sas
           *
           * create longitudinal boxplots for the heat shock proteins
           * as of now, we just have data on 1 of 3 HSP (
           *
           */
          
          data hsp_plot;
	          	set glnd_ext.hsp;
         
   	         	* jitter time for plotting;
	         	visit2= visit - .3 + .6*uniform(613);	*using visit, not actual day on study of blood draw	;         
         run;
         
         goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white 
         					colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;
         	
         					/* Set up symbol for Boxplot */
         					symbol1 interpol=boxjt10 mode=exclude value=none co=black cv=black height=.6 bwidth=4 width=0.8;
         
         					/* Set up Symbol for Data Points */
         					symbol2 ci=blue value=dot h=1;
         
         proc sort data=hsp_plot; by day id; run;
        
         %macro make_plots; 
         	*proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
         
         	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
         	%let x= 1;
         
           	%do %while (&x < 3);
         
          		%if &x = 1 %then %do; 	%let variable =hsp70_ng; %let description = f=zapf 'Heat-shock Protein 70 (ng/mL)';
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0; %let y2= 2; %let pic= 'A)'; %end;
         
         		%if &x = 2 %then %do; 	%let variable =hsp27_ng; %let description = f=zapf 'Heat-shock Protein 27 (ng/mL)';
         							%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 = 0; %let y2= 2; %let pic= 'B)'; %end;
         
         		* get 'n' at each day;
         		proc means data=hsp_plot noprint;
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
         		title2 h=3.5 justify=center &description;
         
         		axis1 	label=(f=zapf h=3 'Day' ) value=(f=zapf h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=zapf h=3 a=90 &description  ) 	value=(f=zapf h=2) &scale ;
         
         
         		data anno;
         			set hsp_plot;
         				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
         	
         				* draw a light gray rectangle ;
         			/*	function = 'move'; x = -1; y = &y1; output;
         				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;
         			*/
         		run;
         
         		proc gplot data=hsp_plot gout=glnd_rep.graphs;
         			plot &variable*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2  nolegend; *annotate=anno;
         
         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;
         		
         			format visit time_axis. &variable 4.1;
         ; 
         		run;	
         
         %let x = &x + 1;
         %end;
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = landscape;
        	%make_plots run;
        goptions rotate = portrait;
        
        	ods ps file = "/glnd/sas/reporting/hsp_open.ps";
        	ods pdf file = "/glnd/sas/reporting/hsp_open.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot 2:gplot1;
        		run;
        	ods pdf close;
        	ods ps close;
        
        quit;
