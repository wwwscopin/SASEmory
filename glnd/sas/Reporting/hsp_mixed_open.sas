
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
         					colors = (black red) /*ftitle=Arial*/ ftext=cent  /*fby =Arial*/ hby = 3;
         	
	/* Set up symbol for Boxplot */
	symbol2 interpol=none mode=exclude value=circle cv=blue height=1 width=1;
	/* Set up Symbol for Data Points */
	symbol1 i=j ci=red value=dot h=2 w=2;
         
         proc sort data=hsp_plot; by day id; run;
        
         %macro make_plots; 
         	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
         
         	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
         	%let l= 1;
         
           	%do %while (&l < 3);
         
          		%if &l = 1 %then %do; 	%let variable =hsp70_ng; %let description ='Heat-shock Protein 70 (ng/mL)';
         							%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 = 0; %let y2= 2; %let pic= 'A)'; %end;
         
         		%if &l = 2 %then %do; 	%let variable =hsp27_ng; %let description = 'Heat-shock Protein 27 (ng/mL)';
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
					title3 h=2.5 f=triplex justify=center 'Longitudinal model (means and 95% CI)';
         
         		axis1 	label=(f=triplex h=3 'Day' ) value=(f=cent h=2) split="*" order= (-1 to 29 by 1) minor=none offset=(0 in, 0 in);
         		axis2 	label=(f=triplex h=3 a=90 &description  ) 	value=(f=cent h=2) &scale ;
         
************************************************************************************************************;
************************************************************************************************************;

		proc mixed data = hsp_plot empirical covtest;
			class id visit ; * &source;
		
			model &variable = visit / solution ; * &source	day*&source/ solution;
			repeated visit / subject = id type = cs;
			lsmeans visit / cl ;
			ods output lsmeans = lsmeans_&l;
		run;


		* merge the means and CIs into gluc_box to obtain plotting dataset;
		proc sort data = hsp_plot out=tmp; by visit; run;
		proc sort data = lsmeans_&l; by visit; run;

		data hsp_plot1 ;
			merge tmp lsmeans_&l;	by visit;
		run;		


		DATA anno_mixed_&l; 
			set lsmeans_&l;
				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
	
         				* draw a light gray rectangle ;
         			/*	function = 'move'; x = -1; y = &y1; output;
         				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;
         			*/	
			

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

         
         		proc gplot data=hsp_plot1 gout=glnd_rep.graphs;
         			plot estimate*visit  &variable*visit2 / overlay haxis = axis1 vaxis = axis2  nolegend annotate=anno_mixed_&l;
         
         			note h=2 m=(7pct, 9 pct) "Day:" ;
         			note h=2 m=(7pct, 7 pct) "(n)" ;
         		
         			format visit time_axis. estimate 4.1;
         ; 
         		run;	
         
         %let l = %eval(&l + 1);
         %end;
         
         %mend make_plots;
         
         * clear graph catalog ;
         proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run;
        
        goptions rotate = landscape;
        	%make_plots run;
 
        
filename output 'hsp_open.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;
        
        	ods ps file = "/glnd/sas/reporting/hsp_open.ps";
        	ods pdf file = "/glnd/sas/reporting/hsp_open.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot 2:gplot1;
        		run;
        	ods pdf close;
        	ods ps close;
        
        quit;
