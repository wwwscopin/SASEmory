 
proc freq data=cmv.rbctxn_summary; 
	tables numrbctxns /nocum out = cmv.numrbctxns; run;

data cmv.numrbctxns; set cmv.numrbctxns;
	by numrbctxns; if last.numrbctxns then call symput("max", numrbctxns); run;


	goptions reset=all rotate=landscape gunit=pct device=png noborder cback=white colors=(black) ftitle=swissb ftext=swissb;
	
	symbol1 value = "dot" h=2 i=join line=1;

	axis1 	label= (f=swissb h=2.5 'RBC Units per Patient')
				value= (f=swissb h=2) 
				order= (1 to &max by 1)
				major= (h=3 w=2) 
				minor= none
	;

	axis2 	label= (a=90 f=swissb h=2.5 'Percentage of Patients') 
				value= (f=swissb h=2) 
				order= (0 to 100 by 10) 
				major= (h=1.5 w=2) 
				minor= (number=3)
	;


	goptions device=png target=png xmax=10 in  xpixels=2500  ymax=7 in ypixels=1750;
	options nodate orientation = landscape;
	ods rtf file = "&output./age_of_blood/txn_per_pt.rtf" style=journal;

		title1 f=swissb h=2.5 justify=center "Distribution of Number of RBC Transfusions Received";
		title2 f=swissb h=2 justify=center "N = &pts patients";

		proc gplot data=cmv.numrbctxns; 
			plot percent*numrbctxns / haxis=axis1 vaxis=axis2; 
		run;
	ods rtf close;
