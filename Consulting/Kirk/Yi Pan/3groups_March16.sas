libname grac "H:\SAS_Emory\Consulting\Kirk\Yi Pan";


*==========================
Mixed Model for HAQ Score
*==========================;
/*adjusted model;

proc mixed data=grac.outcomes empirical ;
		class id  visit treatment age_60  employed insurance duration adhere;
		model haq_score=treatment visit treatment*visit age_60  employed insurance duration adhere/s;
		repeated visit/ subject=id type = cs; 
		lsmeans treatment visit treatment*visit age_60  employed insurance duration adhere/cl;
		*ods output lsmeans=haq;
		*Estimate "linear, Ig"  visit_num 1 0 -1    tmt_new*visit_num   0 0 0      1 0 -1;
		*Estimate "linear,saline"  visit_num 1 0 -1    tmt_new*visit_num  1 0 -1      0 0 0 ;
title;
run;*/


*ods rtf file=" F:\BCC_Project\Conn\result\plot_Aug\Figure4A_HAQ.rtf";
proc mixed data=grac.outcomes empirical covtest;
		class id  visit treatment;
		*where visit<4 ;
		model haq_score= treatment visit treatment*visit;
		repeated visit/ subject=id type = cs; 
		lsmeans treatment*visit/cl;
		ods output lsmeans=lsmeans_haq;
		*Estimate "linear, Ig"         visit_num 1 0 -1    tmt_new*visit_num   0 0 0      1 0 -1;
		*Estimate "linear,saline"  visit_num 1 0 -1    tmt_new*visit_num  1 0 -1      0 0 0 ;
title;
run;
*ods rtf close;


data lsmeans_haq;
		set lsmeans_haq;
		where effect ='visit*treatment';
		format estimate D4.3;
	run;



options ls=200;
proc sort data = lsmeans_haq; by treatment visit; run;
proc sort data=grac.outcomes;by treatment visit; run;
* merge the original data and the lsmeans data;


data  mixed;
	merge grac.outcomes lsmeans_haq;
	*where visit<4;
	by treatment visit;
	if treatment=0 then do; haq1=haq_score; estimate1=estimate;end;
	else if treatment=1 then do; haq2=haq_score; estimate2=estimate;end;
	else if treatment=2 then do; estimate0=estimate;end;
	visit_new= visit + .15*uniform(3654);

	if treatment = 1 then do; visit= visit + .1; visit_new = visit_new + .15;  end; * offset the two means;
				else if treatment=2 then do;  visit= visit - .1; visit_new = visit_new - .15;  end; 
	format estimate 5.3 estimate_new 5.3 visit_new 5.3;

run;


proc sort data = mixed; by effect treatment visit; run;

proc format;
		value visit_num 0="  "
                        1 = "baseline"
						2 = "6 month"
						3 = "12 month"
						4="18 month   "
						5= "    "
						.5 = " "
						1.5 = " "
						2.5 = " "
				               ;
						
	run;


proc sort data = mixed; by  treatment visit; run;


DATA anno_final; 
		set mixed;
		by treatment;
		
		lc=lower; uc=upper;

		xsys='2'; ysys='2';
		  X=visit;
		  y=estimate;
		FUNCTION='MOVE'; when = 'A'; OUTPUT;
		/*function = 'BAR'; x = 3.5; y = 11.1; color = 'liy'; style = 'solid'; line= 0; output;	*/
		Y=lower;
		FUNCTION='DRAW';when = 'A'; line=1; size=.1; color='black';  OUTPUT;
		LINK TIPS;
		Y=upper;
		FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black';  OUTPUT;
		
		LINK TIPS;
		TIPS: *** dRAW TOP AND BOTTOM OF BARS;
		  X=visit-.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit+.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit;     FUNCTION='MOVE';   when = 'A';                              OUTPUT;
		return;

* draw the normal area:3.6, 11.1;	
	run;



options nodate;
goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white colors=(black)
		 ftitle=zapf ftext= zapf fby = zapf hby = 3;

      legend1 across=1  position=(top right inside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h=3 position=top justify=center justify = center 'Key:')
 			value=(f=zapf h=3) frame;
   symbol1 value=dot h=1.5 c=black; symbol2 value=circle h=1.5 c=black;
   symbol3 value = diamond co=black h = 3 i = join c=red;
   symbol5 value = square co=black h = 3 i = join c=blue;
symbol4 value = triangle co=black h = 3 i = join c=green;


    axis1 	label=(f=zapf h=4 a=90 'HAQ Score') value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none order = (0 to 3.2 by 0.2)  ;
	axis2 	label=(f=zapf h=4 'Study Time' ) 	value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none ;*order = (1 to 3 by .5)  ;
	

	*ods pdf file =  "F:\BCC_Project\Conn\result\plot_Aug\class\with_control\Figure5A_HAQ.pdf";


libname g "C:\Documents and Settings\root\My Documents\My Dropbox\BCC\Conn\result\March_2011";
		
		proc gplot data= mixed gout=g.graphs;
			plot haq1*visit_new=1 haq2*visit_new=2
						estimate1*visit=3 estimate2*visit=4 estimate0*visit=5/overlay annotate = anno_final  vaxis = axis1 haxis = axis2 legend = legend1;
			label  
						haq1 = ">=4"
						haq2 = "<4"
						estimate1 = ">=4"
						estimate2 = "<4"
						estimate0="Usual Care";
						format visit visit_num. visit_new visit_num.;
						*title "Figure 5 A. Means model for HAQ Score by Number of Classes Attended, with Usual Care Group";
						note font=swiss h=3 m=(15, 96 pct) '3D HAQ';
		run;	

*ods pdf close;





proc datasets kill library=work; run;
*=================
Total T
*================;
/* adjusted model;

proc genmod data=grac.outcomes;
	class id  visit treatment age_60  employed insurance duration adhere;
	model total_t=treatment visit treatment*visit employed insurance duration age_60 adhere/link=log dist=poisson type3;
	repeated subject=id/type=cs;
	lsmeans treatment visit treatment*visit age_60  employed insurance duration adhere/cl;
run;*/

*ods rtf  style=journal file=" C:\Users\fchen\Documents\My Dropbox\BCC\Conn\result\Aug9\tender.rtf";
proc genmod data=grac.outcomes;
	class id treatment visit;
	where id~=75;
	model total_t=treatment visit treatment*visit /link=log dist=poisson type3;
	repeated subject=id/type=cs;
	lsmeans treatment*visit/diff cl;
	ods output lsmeans=lsmeans_t;
run;
*ods rtf close;


data lsmeans_t (rename=(mean=estimate ));
		set lsmeans_t;
		where effect ='treatment*visit';
		format mean D4.3;
		format visit_new 8.;
		if visit="Baseline" then visit_new=1;
		 else if visit="6-month" then visit_new=2;
		 	else if  visit="12-month" then visit_new=3;
				else if visit="18-month" then visit_new=4;
		if treatment="1" then treatment_new=1;
		else if treatment="0" then treatment_new=0;
		else treatment_new=2;
		lower=exp(lowercl);
		upper=exp(uppercl);
		drop visit treatment;
	run;

data lsmeans_t_new;set lsmeans_t(rename=(visit_new=visit treatment_new=treatment));run;

proc print data=lsmeans_t_new;run;


options ls=200;
proc sort data = lsmeans_t_new; by treatment visit; run;
proc sort data=grac.outcomes;by treatment visit; run;
* merge the original data and the lsmeans data;


data  mixed;
	merge grac.outcomes lsmeans_t_new;
	by treatment visit;
	if treatment=0 then do;total_1=total_t; estimate1=estimate;end;
	else if treatment=1 then do; total_2=total_t; estimate2=estimate;end;
	else if treatment=2 then do; estimate0=estimate;end;
	visit_new= visit + .15*uniform(3654);

	if treatment = 1 then do; visit= visit + .1; visit_new = visit_new + .15;  end; * offset the two means;
				else if treatment=2 then do;  visit= visit - .1; visit_new = visit_new - .15;  end; 
	format estimate 5.3  visit_new 5.3;

run;


proc sort data = mixed; by treatment visit; run;



proc format;
		value visit_num 0="  "
                        1 = "baseline"
						2 = "6 month"
						3 = "12 month"
						4="18 month   "
						5="    "
						.5 = " "
						1.5 = " "
						2.5 = " "
				               ;
						
	run;


proc sort data = mixed; by  treatment visit; run;


DATA anno_final; 
		set mixed;
		by treatment;
		
		lc=lower; uc=upper;

		xsys='2'; ysys='2';
		  X=visit;
		  y=estimate;
		FUNCTION='MOVE'; when = 'A'; OUTPUT;
		/*function = 'BAR'; x = 3.5; y = 11.1; color = 'liy'; style = 'solid'; line= 0; output;	*/
		Y=lower;
		FUNCTION='DRAW';when = 'A'; line=1; size=.1; color='black';  OUTPUT;
		LINK TIPS;
		Y=upper;
		FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black';  OUTPUT;
		
		LINK TIPS;
		TIPS: *** dRAW TOP AND BOTTOM OF BARS;
		  X=visit-.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit+.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit;     FUNCTION='MOVE';   when = 'A';                              OUTPUT;
		return;

* draw the normal area:3.6, 11.1;	
	run;



options nodate;
goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white colors=(black)
		 ftitle=zapf ftext= zapf fby = zapf hby = 3;

      legend1 across=1  position=(top right inside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h=3 position=top justify=center justify = center 'Key:')
 			value=(f=zapf h=3) frame;
   symbol1 value=dot h=1.5 c=black; symbol2 value=circle h=1.5 c=black;
   symbol3 value = diamond co=black h = 3 i = join c=red;
   symbol5 value = square co=black h = 3 i = join c=blue;
	symbol4 value = triangle co=black h = 3 i = join c=green;

    axis1 	label=(f=zapf h=4 a=90 'Total Tender Joints') value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none order = (0 to 35 by 5)  ;
	axis2 	label=(f=zapf h=4 'Study Time' ) 	value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none ;*order = (1 to 3 by .5)  ;
	

	*ods pdf file =  "F:\BCC_Project\Conn\result\plot_Aug\class\with_control\Figure5B_Tender.pdf";

		proc gplot data= mixed gout=g.graphs ;
			plot total_1*visit_new=1 total_2*visit_new=2
						estimate1*visit=3 estimate2*visit=4 estimate0*visit=5/overlay annotate = anno_final  vaxis = axis1 haxis = axis2 legend = legend1;
			label  
						total_1 = ">=4"
						total_2 = "<4"
						estimate1 = ">=4"
						estimate2 = "<4"
						estimate0="Usual Care";
						format visit visit_num. visit_new visit_num.;
						note font=swiss h=3 m=(15, 96 pct) '3A Total Tender Joints';
						*title "Figure 5 B. Means model for Total Tender Joints by Number of Classes Attended, with Usual Care Group";
		run;	

*ods pdf close;





*Genmode: Total S;



proc datasets kill library=work; run;
*=================
Total S
*================;
*adjusted;

proc genmod data=grac.outcomes;
	class id  visit treatment age_60  employed insurance duration adhere;
	model total_s=treatment visit treatment*visit employed insurance duration age_60 adhere/link=log dist=poisson type3;
	repeated subject=id/type=cs;
	lsmeans treatment visit treatment*visit age_60  employed insurance duration adhere/cl;
run;

*ods rtf  style=journal file=" C:\Users\fchen\Documents\My Dropbox\BCC\Conn\result\Aug9\tender.rtf";
proc genmod data=grac.outcomes;
	class id treatment visit;
	where id~=75;
	model total_s=treatment visit treatment*visit /link=log dist=poisson type3;
	repeated subject=id/type=cs;
	lsmeans treatment*visit/diff cl;
	ods output lsmeans=lsmeans_s;
run;
*ods rtf close;


data lsmeans_s (rename=(mean=estimate ));
		set lsmeans_s;
		where effect ='treatment*visit';
		format mean D4.3;
		format visit_new 8.;
		if visit="Baseline" then visit_new=1;
		 else if visit="6-month" then visit_new=2;
		 	else if  visit="12-month" then visit_new=3;
				else if visit="18-month" then visit_new=4;
		if treatment="1" then treatment_new=1;
		else if treatment="0" then treatment_new=0;
		else treatment_new=2;
		lower=exp(lowercl);
		upper=exp(uppercl);
		drop visit treatment;
	run;

data lsmeans_s_new;set lsmeans_s(rename=(visit_new=visit treatment_new=treatment));run;




options ls=200;
proc sort data = lsmeans_s_new; by treatment visit; run;
proc sort data=grac.outcomes;by treatment visit; run;
* merge the original data and the lsmeans data;


data  mixed;
	merge grac.outcomes lsmeans_s_new;
	by treatment visit;
	if treatment=0 then do;total_1=total_s; estimate1=estimate;end;
	else if treatment=1 then do; total_2=total_s; estimate2=estimate;end;
	else if treatment=2 then do; estimate0=estimate;end;
	visit_new= visit + .15*uniform(3654);

	if treatment = 1 then do; visit= visit + .1; visit_new = visit_new + .15;  end; * offset the two means;
				else if treatment=2 then do;  visit= visit - .1; visit_new = visit_new - .15;  end; 
	format estimate 5.3  visit_new 5.3;

run;


proc sort data = mixed; by treatment visit; run;



proc format;
		value visit_num 0="  "
                        1 = "baseline"
						2 = "6 month"
						3 = "12 month"
						4="18 month   "
						5="    "
						.5 = " "
						1.5 = " "
						2.5 = " "
				               ;
						
	run;


proc sort data = mixed; by  treatment visit; run;


DATA anno_final; 
		set mixed;
		by treatment;
		
		lc=lower; uc=upper;

		xsys='2'; ysys='2';
		  X=visit;
		  y=estimate;
		FUNCTION='MOVE'; when = 'A'; OUTPUT;
		/*function = 'BAR'; x = 3.5; y = 11.1; color = 'liy'; style = 'solid'; line= 0; output;	*/
		Y=lower;
		FUNCTION='DRAW';when = 'A'; line=1; size=.1; color='black';  OUTPUT;
		LINK TIPS;
		Y=upper;
		FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black';  OUTPUT;
		
		LINK TIPS;
		TIPS: *** dRAW TOP AND BOTTOM OF BARS;
		  X=visit-.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit+.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit;     FUNCTION='MOVE';   when = 'A';                              OUTPUT;
		return;

* draw the normal area:3.6, 11.1;	
	run;



options nodate;
goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white colors=(black)
		 ftitle=zapf ftext= zapf fby = zapf hby = 3;

      legend1 across=1  position=(top right inside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h=3 position=top justify=center justify = center 'Key:')
 			value=(f=zapf h=3) frame;
   symbol1 value=dot h=1.5 c=black; symbol2 value=circle h=1.5 c=black;
   symbol3 value = diamond co=black h = 3 i = join c=red;
   symbol5 value = square co=black h = 3 i = join c=blue;
	symbol4 value = triangle co=black h = 3 i = join c=green;

    axis1 	label=(f=zapf h=4 a=90 'Total Swollen Joints') value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none order = (0 to 35 by 5)  ;
	axis2 	label=(f=zapf h=4 'Study Time' ) 	value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none ;*order = (1 to 3 by .5)  ;
	

	*ods pdf file =  "F:\BCC_Project\Conn\result\plot_Aug\class\with_control\Figure5c_Swollen.pdf";

		proc gplot data= mixed gout=g.graphs;
			plot total_1*visit_new=1 total_2*visit_new=2
						estimate1*visit=3 estimate2*visit=4 estimate0*visit=5/overlay annotate = anno_final  vaxis = axis1 haxis = axis2 legend = legend1;
			label  
						total_1 = ">=4"
						total_2 = "<4"
						estimate1 = ">=4"
						estimate2 = "<4"
						estimate0="Usual Care";
						format visit visit_num. visit_new visit_num.; 
						note font=swiss h=3 m=(15, 96 pct) '3B Total Swollen Joints';
						*title "Figure 5 C. Means model for Total Swollen Joints by Number of Classes Attended, with Usual Care Group";
		run;	

*ods pdf close;




*ACR20;


*ACR20;
proc datasets library=work kill;run;
*ACR20, only has 6 month, 12 month and 18 month;
data acr20;
	set grac.outcomes;
	if acr_20=99 then acr_20=.;
	if visit=1 then delete;
run;

proc print data=acr20; var id visit adhere;run;

proc means data=acr20; var acr_20; class treatment visit;run;

proc genmod data=acr20 descending;
	class id treatment visit;
	model acr_20=treatment visit treatment*visit/link=logit dist=binomial type3;
	repeated subject=id/type=cs;
	lsmeans treatment*visit/diff cl;
	ods output lsmeans=lsmeans_acr;
run;

*add command to plot!;

/*
*adjusted model;

proc genmod data=acr20 descending;
	class id treatment visit age_60  employed insurance duration adhere;
	model acr_20=treatment visit treatment*visit employed insurance duration age_60 adhere/link=logit dist=binomial type3;
	repeated subject=id/type=cs;
	lsmeans treatment visit treatment*visit age_60  employed insurance /cl ;* duration adhere/cl;
run;

*/


data lsmeans_acr ;
		set lsmeans_acr;
		where effect ='treatment*visit';
		format mean D4.3;

		lower=exp(lowercl)/(1+exp(lowercl))*100;
		upper=exp(uppercl)/(1+exp(uppercl))*100;
		estimate_new=mean*100;
		if visit="6-month" then visit_new=2;
		if visit="12-month" then visit_new=3;
		if visit="18-month" then visit_new=4;
		treatment_new=treatment+0;
		drop treatment visit;
	run;


   data lsmeans_acr_new ; set lsmeans_acr;  run;
options ls=200;

data mixed; 
	set lsmeans_acr_new;
	if treatment_new=1 then do;
	if visit_new=2 then visit=1;
	if visit_new=3 then  visit=2;
	if visit_new=4 then visit=3;
	end;

if treatment_new=0 then do;
	if visit_new=2 then visit=1.1;
	if visit_new=3 then  visit=2.1;
	if visit_new=4 then visit=3.1;
	end;
	if treatment_new=2 then do;
	if visit_new=2 then visit=1.2;
	if visit_new=3 then visit=2.2;
	if visit_new=4 then visit=3.2;
	end;

run;

proc print data=mixed;run;


proc format;
		value visit_num 0="  "
                
						1 = "6 month"
						2 = "12 month"
						3="18 month   "
						4="    "
						1.1 = " "
						2.1=" "
						3.1=" "
						1.2=" "
						2.2 = " "
						3.2 = " "
						1.5=" "
						2.5=" "
						3.5=" ";
						
	run;

	proc format;
	value treat 0=">=4" 2="Usual Care"
	1="<4";

run;

proc sort data = mixed; by  treatment_new visit; run;


DATA anno_final; 
		set mixed;
		by treatment_new;
		
		lc=lower; uc=upper;

		xsys='2'; ysys='2';
		  X=visit;
		  y=estimate_new;
		FUNCTION='MOVE'; when = 'A'; OUTPUT;
		/*function = 'BAR'; x = 3.5; y = 11.1; color = 'liy'; style = 'solid'; line= 0; output;	*/
		Y=lower;
		FUNCTION='DRAW';when = 'A'; line=1; size=.1; color='black';  OUTPUT;
		LINK TIPS;
		Y=upper;
		FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black';  OUTPUT;
		
		LINK TIPS;
		TIPS: *** dRAW TOP AND BOTTOM OF BARS;
		  X=visit-.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit+.05; FUNCTION='DRAW'; when = 'A';line=1; size=.1; color='black'; OUTPUT;
		  X=visit;     FUNCTION='MOVE';   when = 'A';                              OUTPUT;
		return;

* draw the normal area:3.6, 11.1;	
	run;

options nodate;
goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white colors=(black)
		 ftitle=zapf ftext= zapf fby = zapf hby = 3;

      legend1 across=1  position=(top right inside) mode=reserve  fwidth = .2 
 			shape=symbol(3,2) label=(f=zapf h=3 position=top justify=center justify = center 'Key:')
 			value=(f=zapf h=3) frame;
   

   	symbol1 value = dot co=black h = 3 i = join c=red;
  symbol2 value = triangle co=black h = 3 i = join c=green;
   symbol3 value = circle co=black h = 3 i = join c=blue;

    axis1 	label=(f=zapf h=4 a=90 'Patients %') value=(f=zapf h=3) offset=(0.5in,0.5in) minor = none order = (0 to 70 by 10);
	axis2 	label=(f=zapf h=4 'Study Time' ) 	value=(f=zapf h=3) offset=(1.0in,0.5in) minor = none order = (1.0 to 3.5 by .5);
	
		
		proc gplot data= mixed gout=g.graphs;
			plot 
						estimate_new*visit=treatment_new/annotate = anno_final  vaxis = axis1 haxis = axis2 legend = legend1;
		
						format visit visit_num. treatment_new treat.;
						note font=swiss h=3 m=(15, 96 pct) '3C ACR20';						
		run;	


ods pdf file="C:\Documents and Settings\root\My Documents\My Dropbox\BCC\Conn\result\March_2011\figure3_landscape.pdf";


proc greplay igout=g.graphs
             tc=sashelp.templt
             nofs NOBYLINE;
	
   template L2R2S;
   treplay 1:gplot1
           2:gplot3
		   3:gplot2
           4:gplot;

quit; 


ods pdf close;

/*proc greplay igout=g.graphs
             tc=tempcat
             nofs;

   tdef newfour des="Six seperate graphs"

       1/llx=0  lly=0  ulx=0  uly=50
          lrx=50  lry=0  urx=50  ury=50   color=black

		2/llx=50   lly=0  ulx=50  uly=50
          lrx=100  lry=0  urx=100  ury=50   color=black 

		3/llx=0   lly=50  ulx=0  uly=100
          lrx=50  lry=50  urx=50  ury=100  color=black



		4/llx=50   lly=50  ulx=50  uly=100
          lrx=100  lry=50  urx=100  ury=100   color=black;

   template newfour;

   treplay 1:gplot2
           2:gplot3
		   3:gplot
           4:gplot1;

quit;
ods pdf close; */










