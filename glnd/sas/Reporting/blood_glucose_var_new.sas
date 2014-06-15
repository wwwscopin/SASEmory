
 
 * turn macros on;
 proc options option = macro;  run;
 options spool;
 

proc sort data= glnd.followup_all_long; by id day; run;
 

* initialize the macro variables to store the sample sizes OUTSIDE of macro;
* in order to set the scope to global ;
		%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0;
		%let n_6= 0; %let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;
		%let n_11= 0; %let n_12= 0; %let n_13= 0; %let n_14= 0; %let n_15= 0;
		%let n_16= 0; %let n_17= 0; %let n_18= 0; %let n_19= 0; %let n_20= 0;
		%let n_21= 0; %let n_22= 0; %let n_23= 0; %let n_24= 0; %let n_25= 0;
		%let n_26= 0; %let n_27= 0; %let n_28= 0; 

 
/** MAKE OVERALL GLUCOSE PLOTS **/
   %macro make_nutr_plots(idx=0); 
  	%let x= 1;
 
 	ods pdf file = "/glnd/sas/reporting/blood_gluc.pdf";
 	proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
 
  	%do %while (&x <2);
  	 	
  		%if &x = 1 %then %do; %let variable = gluc_eve ; %let source = eve_gluc_src; 			%let description = "Evening blood glucose (mg/dL)"; %let time = "[22:00 - 24:00]"; %end; 
  		%else %if &x = 2 %then %do; %let variable = gluc_mrn ; %let source = mrn_gluc_src;		%let description = "Morning blood glucose (mg/dL)"; %let time = "[05:00 - 07:00]"; %end; 
  		%else %if &x = 3 %then %do; %let variable = gluc_aft ; %let source = aft_gluc_src;		%let description = "Afternoon blood glucose (mg/dL)"; %let time =  "[14:00 - 18:00]"; %end; 
  	  
		/* SIMPLE MIXED MODEL FOR GLUCOSE. PLOT RESULTS */
		
		* get 'n' at each day - NOEW WE ARE DOING THIS CUMULATIVELY ! ;
		proc means data=glnd.followup_all_long noprint;
			
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
			value day_glnd 0 = " " 29 = " "
				1 = "1*(&n_1)" 7 = "7*(&n_7)" 13 = "13*(&n_13)"  19 = "19*(&n_19)" 24 = "24*(&n_24)" 
				2 = "2*(&n_2)" 8 = "8*(&n_8)" 14 = "14*(&n_14)"  20 = "20*(&n_20)" 25 = "25*(&n_25)" 
				3 = "3*(&n_3)" 9 = "9*(&n_9)" 15 = "15*(&n_15)"  21 = "21*(&n_21)" 26 = "26*(&n_26)" 
				4 = "4*(&n_4)" 10 = "10*(&n_10)" 16 = "16*(&n_16)"  22 = "22*(&n_22)" 27 = "27*(&n_27)" 
				5 = "5*(&n_5)" 11 = "11*(&n_11)" 17 = "17*(&n_17)"  23 = "23*(&n_23)" 28 = "28*(&n_28)" 
				6 = "6*(&n_6)" 12 = "12*(&n_12)" 18 = "18*(&n_18)"  
				;
		run;
		
		data glu_box;
				set glnd.followup_all_long;
				day2= (day - .2) + .4*uniform(3654);
				%if &idx=0 %then %do; %end;
				%if &idx=1 %then %do; where &source=1; %end;
				%if &idx=2 %then %do; where &source=2; %end;
		run;	
		
		data glu;
				set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=glu eve_gluc_src=src) in=C)
				 glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=glu aft_gluc_src=src) in=B)
				 glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=glu mrn_gluc_src=src) in=A);
                
                if A then gt=1; if B then gt=2; if C then gt=3;
						
				%if &idx=0 %then %do; %end;
				
				%if &idx=1 %then %do; if A; %end;
				%if &idx=2 %then %do; if B; %end;
				%if &idx=3 %then %do; if C; %end;
				/*
				%if &idx=4 %then %do; where src=1; %end;
				%if &idx=5 %then %do; where src=2; %end;
				*/
		run;	

        proc sort; by id;run;
		
		data glu;
		  merge glu glnd.info(keep=id apache_2 hospital_death)
		  glnd.george (keep = id treatment); by id;
          center = floor(id/10000);
		run;
		
		/*
		proc sort data=glu out=glu_id nodupkey; by id; run;
		proc means data=glu_id n;
		 class treatment;
		 var id;
		run;
        */
		proc means data=glu n mean min max;
		  class treatment;
		 var glu;
		run;

	   	
	   proc mixed data=glu empirical covtest;
	       class id;
	       model glu=;
	       random intercept/subject=id type=un;
	   run;	       

	   
	   proc mixed data=glu(where=(treatment=1)) empirical covtest;
	       class id;
	       model glu=;
	       random intercept/subject=id type=un;
	   run;	 	   	   	   
	   
		* means mixed model with heterogenous compound symmetry;
		*ods trace on/label listing;
		proc mixed data = glu empirical covtest;
			class id treatment;
			model glu = treatment day treatment*day; 
			repeated / subject = id group=treatment;
			random intercept/type=un subject=id group=treatment g;
			ods output Mixed.CovParms=cov;
		run;

proc sort data=glu output=glu1;by treatment id;run;				
proc nested data=glu1;
  class id ;
  by treatment;
  var glu;
run;
		
		/* The model below is same as the above one since the variance only have two components, intercept and slope;
		   so random and repeated statement have same effects here!;
		proc mixed data = glu empirical covtest;
			class id hospital_death day;
			model glu = hospital_death day hospital_death*day; 
			repeated day/ subject = id type = cs r;
			ods output Mixed.CovParms=cov;
		run;
		*/
        *ods trace off;

       
        data cov&idx;
            merge cov (keep=CovParm estimate StdErr where=(CovParm="CS") rename=(estimate=est1 StdErr=stderr1))
                  cov (keep=CovParm estimate StdErr where=(CovParm="Residual") rename=(estimate=est2 StdErr=stderr2));
            pcent=est1/(est1+est2)*100;
            sd1=est1**0.5;
            sd2=est2**0.5;
            drop covparm;
            format est1 stderr1 sd1 est2 stderr1 sd2 pcent 5.0;
            idx=&idx;
        run;
        
	*****************************************/
   	%let x = &x + 1;
	
	ods pdf close;
	%end;
%mend make_nutr_plots;

%make_nutr_plots(idx=0) run;
*%make_nutr_plots(idx=1) run;
*%make_nutr_plots(idx=2) run;
*%make_nutr_plots(idx=3) run;
/*
%make_nutr_plots(idx=4) run;
%make_nutr_plots(idx=5) run;


proc format;
	value idx 0="Overall" 1="Morning" 2="Afternoon" 3="Evening" 4="Lab" 5="Accucheck";
run;
	
        data cov;
            set cov0 cov1 cov2 cov3 cov4 cov5; 
            format idx idx.;
        run;
      
   
    options orientation=landscape;         
    ods  rtf  file="Cov.rtf" style=journal bodytitle startpage=never;
	proc report data=cov nowindows split="*" style(column)=[width=1.25in just=center];
	    title "Covariance Estimates for Blood Glucose";
    	column idx est1 stderr1 sd1 est2 stderr2 sd2 pcent;
    	define idx/ order order=internal "Item" format=idx.;
    	define est1/"Between" format=5.0;
    	define stderr1/"StdErr of Between" format=5.0;
    	define sd1/"SD of Between" format=5.0;
    	define est2/"Within" format=5.0;
    	define stderr2/"StdErr of Within" format=5.0;
    	define sd2/"SD of Within" format=5.0;
    	define pcent/"Between/Total (%)" format=5.1;
	run;
	ods rtf close;
*/        
        
