/* apache_comparison_open.pdf
 *
 * make a listing and a plot that compares the SICU entry APACHE II and study entry one
 *
 *
 */
 

proc sort data = glnd.plate6; by id ; run; * already is subsetting to include just the study-entry visit;
proc sort data = glnd.apache_sicu; by id dfseq; run;
proc sort data = glnd.status; by id; run;


proc format library = work;
	value	sicu_cat 1 = "2" 	
			2 = "3 - 6" 
			3 = "6 - 10"
			4 = "11+"
			;
run;

data apache_comp;
	merge 
		glnd.plate6 (keep = id apache_total)
		glnd.apache_sicu (keep = id apache_total_sicu)
		glnd.status (keep = id days_sicu_prior)
			/* "Days in SICU prior to entry". May be an underestimate in terms of actual days, if a patient left the 
			SICU and then returned prior to their enrollment, however we do not record more detailed
			data, such as SICU dates */
	;
	by id;

	apache_dif = apache_total - apache_total_sicu;
	
	
	* categorize days in SICU for plotting ;
	if days_sicu_prior = 2 then sicu_cat = 1;
	else if days_sicu_prior < 6 then sicu_cat = 2;
	else if days_sicu_prior < 11 then sicu_cat = 3;
	else if days_sicu_prior ~= . then sicu_cat = 4;
	
	format sicu_cat sicu_cat.;
	
	label 
		apache_total = "APACHE II - Study Entry"
		apache_total_sicu = "APACHE II - first day in SICU"
		apache_dif = "Difference"
		days_sicu_prior = "Days in SICU prior to study"
	;
	
run;



ods pdf file = "/glnd/sas/reporting/apache_comparison_open.pdf";
	proc print data = apache_comp label;
		var id apache_total_sicu apache_total apache_dif days_sicu_prior ;
	run;
	
	goptions reset=all rotate=landscape device=jpeg gunit=pct noborder cback=white
  		colors = (black, blue, red, green) ftitle=triplex ftext= triplex;
  	
  	symbol1 value = dot h=1.5;

 	axis1 	label=(f=triplex h=4  ) 	value=(f=titalic h=3)  order= (0 to 50 by 10) major=(h=1.5 w=2) minor=(number=9 h=1);
 	axis2 	label=(f=triplex h=4 a=90 ) 	value=(f=titalic h=3)  order= (0 to 50 by 10) major=(h=1.5 w=2) minor=(number=9 h=1);
 	
 	legend1 across=1  position=(top left inside) mode=reserve fwidth =1
 			shape=symbol(3,2) label=(f=triplex h= 3 position= top justify = center "Days in SICU" justify= center"prior to study")
 			value=(f=titalic h=2 justify = left) ;
 	
 	data anno;
 		set apache_comp;
 	
 		xsys = '2'; ysys = '2';
 		
 		* Draw identity line;
 		function = 'move'; x = 0; y = 0; output;
		function = 'draw'; x = 50; y = 50; color = 'black';  line= 2; output;
 	run;
 	
  	proc gplot data = apache_comp;
  		plot apache_total * apache_total_sicu = sicu_cat /haxis = axis1 vaxis = axis2 vref = 15 lvref = 2 
  				legend = legend1 annotate = anno;
 	run; 	
	
	
ods pdf close;

