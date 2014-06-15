*libname cyto "\glnd\Cytokines";
   
data cyto_plot;
   	set glnd_ext.cytokines;
   	* jitter time for plotting;
   	visit2= visit - .3 + .6*uniform(613);	*using visit, not actual day on study of blood draw	;   
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf);      
run;
         
			 goptions rotate = landscape reset=global gsfmode=replace gunit=pct border
			 ctext=black ftitle=swissb ftext=swiss htitle=3 htext=3;

			 symbol1 value=circle  i=none h=4 w=1 c=blue; 
			 symbol2 value=none  i=j h=4 w=2 c=red;  
         
         proc sort data=cyto_plot; by day id; run;
        
         %macro make_plots; 
         	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
         
         	%let n_0= 0; %let n_3= 0; %let n_7= 0; %let n_14= 0; %let n_21= 0; %let n_28= 0;
         	%let x= 1;
         
           %do %while (&x <5);
         
          	%if &x = 1 %then %do; 	%let variable =log_il6; %let description = f=zapf 'ln[IL-6 Concentration (pg/ml)]';
         		%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 =0.447; %let y2=9.96; %let pic= 'A)'; %end;
         
         	%if &x = 2 %then %do; 	%let variable =log_il8; %let description = f=zapf 'ln[IL-8 Concentration (pg/ml)]';
         		%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 =3.23; %let y2=24.5; %let pic= 'B)'; %end;

				%if &x = 3 %then %do; 	%let variable =log_ifn; %let description = f=zapf 'ln[IFN' f=greek ' d ' f=zapf 'Concentration (pg/ml)]';
         		%let scale = /*order = (0 to 50 by 5) minor=(number=3)*/; %let y1 =0.25; %let y2= 15.6; %let pic= 'C)'; %end;
         
         		%if &x = 4 %then %do; 	%let variable =log_tnf; %let description = f=zapf 'ln[TNF' f=greek ' a ' f=zapf 'Concentration (pg/ml)]';
         		%let scale = /*order = (0 to 25 by 1) minor=(number=3) */ ; %let y1 =0.25; %let y2= 4.71; %let pic= 'D)'; %end;
         
          		* get 'n' at each day;
         		proc means data=cyto_plot noprint;
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
         			set cyto_plot;
         				xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;		
         	
         				* draw a light gray rectangle ;
          			
						function = 'move'; x = -0.5; y = log(&y1); output;
         			function = 'BAR'; x = 28.5; y = log(&y2); color = 'ltgray'; style = 'solid'; line= 0; output;
         									
         		run;


		proc mixed data = cyto_plot empirical covtest;
			class id visit; * &source;
		
			model &variable = visit / solution ; * &source	day*&source/ solution;
			repeated visit / subject = id type = cs;
			lsmeans visit / cl ;
			ods output lsmeans =lsmeans_&variable;
		run;

		proc sort data = cyto_plot; by visit; run;
		proc sort data = lsmeans_&variable; by visit; run;

		
		data cyto_plot_&variable ;
			merge 	cyto_plot
					lsmeans_&variable
				;	
			by visit;
		run;

         
         		proc gplot data=cyto_plot_&variable gout=glnd_rep.graphs;
         			plot &variable*visit2 estimate*visit/overlay haxis = axis1 vaxis = axis2  nolegend annotate=anno;
  

         			note h=2 m=(7pct, 10 pct) "Day:" ;
         			note h=2 m=(7pct, 7.5 pct) "(n)" ;

         			format visit2 visit time_axis. &variable estimate 4.1;
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

        

        	ods ps file = "/glnd/sas/reporting/log_cyto1.ps";
        	ods pdf file = "/glnd/sas/reporting/log_cyto1.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot 2:gplot1;
        		run;
        	ods pdf close;
        	ods ps close;

			ods ps file = "/glnd/sas/reporting/log_cyto2.ps";
        	ods pdf file = "/glnd/sas/reporting/log_cyto2.pdf";
	 	    proc greplay igout = glnd_rep.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
        			treplay 1:gplot2 2:gplot3;
        		run;
        	ods pdf close;
        	ods ps close;


  quit;
