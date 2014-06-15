* for the 3/2009 DSMB report, blood_gluc_open became so busy that SAS ran out of memory
	so i have split the file into 2 so that we can print the glucose plots by center;


/** NOW MAKE GLUCOSE PLOTS BY CENTER **/

	data gluc_center;
		set glnd.followup_all_long;
        where id^=31351;		where this_date>mdy(&last_dsmb_date);
	run;
	
	proc sort data= gluc_center;
		by center;
	run;
	data anno_center;
		set gluc_center;

		xsys='2'; ysys='2'; * specifies coordinate system to be the same as that of the data;
		
		* draw a light gray rectangle from 80 to 130;
		function = 'move'; x = 1; y = 80; output;
		function = 'BAR'; x = 28; y = 130; color = 'ligr'; style = 'solid'; line= 0; output;
	
		* draw a dotted line at glucose = 250 to represent hyperglyecmia requiring an AE form;
		function = 'move'; x = 1; y = 250; output;
		function = 'draw'; x = 28; y = 250; color = 'black';  line= 2; output;

		* draw a dotted line at glucose = 50 to represent hypoglyecmia requiring an AE form;
		function = 'move'; x = 1; y = 50; output;
		function = 'draw'; x = 28; y = 50; color = 'black';  line= 2; output;

	run;

	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
	options nobyline;
		
   %macro make_nutr_plots_center; 
  	%let x= 1;
 
 	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
 
  	%do %while (&x < 4);
  	
		%if &x = 1 %then %do; %let variable = gluc_eve ; %let description = "Evening blood glucose (mg/dL)"; %let time = "[22:00 - 24:00]"; %end; 
  		%else %if &x = 2 %then %do; %let variable = gluc_mrn ; %let description = "Morning blood glucose (mg/dL)"; %let time = "[05:00 - 07:00]"; %end; 
  		%else %if &x = 3 %then %do; %let variable = gluc_aft ; %let description = "Afternoon blood glucose (mg/dL)"; %let time =  "[14:00 - 18:00]"; %end; 
    
  	goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf;
  		
		
		* symbols for up to 10 patients - no longer labeling individuals ;
		symbol1 value = dot h=1.5 i=join repeat = 200;

 		axis1 	label=(f=zapf h=4 'Day' ) 	value=(f=zapf h=2) order = (1 to 28) minor= none;
 		axis2 	label=(f=zapf h=4 a=90 &description ) 	value=(f=zapf h=3) 
					order= (0 to 400 by 50) 	major=(h=1.5 w=2) minor=(number=4 h=1);
 		
 		/*legend1 across=1  position=(top right outside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h= 3 position= top justify = center 'Patient ID:')
 			value=(f=zapf h=3);*/


 		title1 f=zapfb h=4 justify=center &description;	
 		title2 f=zapfb h=2.5 justify=center &time;
		
	
 			proc gplot data= gluc_center gout= glnd_rep.graphs;
				where center = 1; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;
 			

			/***************
 			*data --- GEORGE   ---- ; 
 			*dummy data for miriam = 0 patients ;
 			data dummy;
 				gluc_mrn = .;
 				gluc_eve = .;
 				gluc_aft = .;
 				day = .;
 				id = .;
 			run;
 			 proc gplot data= dummy gout= glnd_rep.graphs;
			
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;
			*******************/
 			
 			 proc gplot data= gluc_center gout= glnd_rep.graphs;
				where center = 3; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;
 			
 			
 			 proc gplot data= gluc_center gout= glnd_rep.graphs;
				where center = 4; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;
 			
			 proc gplot data= gluc_center gout= glnd_rep.graphs;
				where center = 5; 
 				plot &variable*day=id / haxis=axis1 vaxis=axis2  annotate=anno_center nolegend; * legend=legend1; 
 			run;
 
 		
   	%let x = &x + 1;
 	%end;
	 	
 	%mend make_nutr_plots_center;
  	%make_nutr_plots_center run;
quit;




/* make custom slide arrangment  to give overall title  */

	* 2 x 2 horizontal box, with an outer box for displaying a title ;
	proc greplay tc=work.tempcat nofs;

	tdef title2x2 des='Five panel template'

	     1/llx=0   lly=10
	       ulx=0   uly=50
	       urx=50  ury=50
	       lrx=50  lry=10
	       color=white
	     2/llx=0   lly=50
	       ulx=0   uly=90
	       urx=50  ury=90
	       lrx=50  lry=50
	       color=white

	     3/llx=50   lly=50
	       ulx=50   uly=90
	       urx=100 ury=90
	       lrx=100 lry=50
	       color=white

	     4/llx=50   lly=10
	       ulx=50  uly=50
	       urx=100 ury=50
	       lrx=100 lry=10
	       color=white

		/* This one is for displaying the outer box */
	     5/llx=0   lly=0
	        ulx=0   uly=100
	        urx=100 ury=100
	        lrx=100 lry=0
	        color=white;

	   template title2x2;

	   list template;
	run;


        ** step 1 - keep observations from gluc_center taken in the last month ;
                data n;
                        set glnd.followup_all_long;
                        if id^=31351;

			where this_date > mdy(&last_dsmb_date);
			keep id day center;
                run;

                ** step 2 - reduce this data to just IDs;
                data last_dsmb_IDs;
                        set n;
                        by id;

                        if ~first.id then delete;

                run;

                proc print data = last_dsmb_IDs ; var id day; run;

                ** step 2.5 - figure out how many people this is and store in a macro variable ;
                        proc means data = last_dsmb_IDs;
                        	class center;
                                output out = total_IDs n(id) = total_IDs;
                        run;

                        data _NULL_;
                                set total_IDs;
                                
                                if center = 1 then  call symput('num_people_emory', compress(put(total_IDs, 3.0)) );
                              *  if center = 2 then  call symput('num_people_miriam', compress(put(total_IDs, 3.0)) );
                                if center = 3 then  call symput('num_people_vandy', compress(put(total_IDs, 3.0)) );
                                if center = 4 then  call symput('num_people_colorado', compress(put(total_IDs, 3.0)) );
                                if center = 5 then  call symput('num_people_wisconsin', compress(put(total_IDs, 3.0)) );
                        run;



	
	* make slide for each center;
	proc gslide gout=glnd_rep.graphs; * name = gslide ;
  		title1 f=triplex h=4  'Individual blood glucose tracking - Emory';
  		title2 f=triplex h=2.5 "for &num_people_emory patients with data since the last DSMB report";
	run;
	proc gslide gout=glnd_rep.graphs; * name = gslide2 ;
  		title1 f=triplex h=4  'Individual blood glucose tracking - Vanderbilt';
  		title2 f=triplex h=2.5 "for &num_people_vandy patients with data since the last DSMB report";
	run;
	proc gslide gout=glnd_rep.graphs; * name = gslide3 ;
   		title1 f=triplex h=4  'Individual blood glucose tracking - Colorado';
   		title2 f=triplex h=2.5 "for &num_people_colorado patients with data since the last DSMB report";
	run;

	proc gslide gout=glnd_rep.graphs; * name = gslide3 ;
   		title1 f=triplex h=4  'Individual blood glucose tracking - Wisconsin';
   		title2 f=triplex h=2.5 "for &num_people_wisconsin patients with data since the last DSMB report";
	run;


	* play back all sites into a PDF ;
	ods pdf file = "/glnd/sas/reporting/blood_gluc_tiled_by_center.pdf";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
				list igout;
				treplay 1:gplot4 2:gplot 3:gplot8 5: gslide; * Emory ;
				treplay 1:gplot5 2:gplot1 3:gplot9 5: gslide1; * Vandy ;
				treplay 1:gplot6 2:gplot2 3:gplot10 5: gslide2; * Colorado ;
				treplay 1:gplot7 2:gplot3 3:gplot11 5: gslide3; * Wisconsin;

			run;

	ods pdf close;
	quit;

quit;

*ods listing close;
options orientation=landscape;

filename output 'bloodemory.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;


**** again make 4 ps files;
	ods ps file = "/glnd/sas/reporting/bloodemory.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
				list igout;
				treplay 1:gplot3 2:gplot 3:gplot6 5: gslide; * Emory ;
				
				
			run;
	ods ps close;
	quit;
	
filename output 'bloodvandy.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;


	ods ps file = "/glnd/sas/reporting/bloodvandy.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
				list igout;
				treplay 1:gplot4 2:gplot1 3:gplot7 5: gslide1; * Miriam ;
				
				
			run;
	ods ps close;
	quit;
	
filename output 'bloodcolorado.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;

	
	ods ps file = "/glnd/sas/reporting/bloodcolorado.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
				list igout;
				
				treplay 1:gplot5 2:gplot2 3:gplot8 5: gslide2; * Vandy ;
				
			run;
	ods ps close;
	quit;
	
filename output 'bloodwisconsin.eps';
goptions reset=all noborder device=pslepsfc gsfname=output gsfmode=replace;

	
	ods ps file = "/glnd/sas/reporting/bloodwisconsin.ps";
			proc greplay igout = glnd_rep.graphs tc=work.tempcat template= title2x2 nofs;
				list igout;
				
				treplay 1:gplot7 2:gplot3 3:gplot11 5: gslide3; * Colorado ;
			run;
	ods ps close;
	quit;
	



	/* LIST BUILT-IN SAS TEMPLATE CATALOG:
 	proc greplay nofs tc=sashelp.templt;
		list tc;
	run;
	*/
