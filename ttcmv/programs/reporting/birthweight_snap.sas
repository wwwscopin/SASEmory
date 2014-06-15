options nodate nonumber papersize=("7" "8");
libname wbh "/ttcmv/sas/programs/reporting/baohua";

%let n=0;
data _null_;
	set cmv.comp_pat;
	call symput("n", compress(_n_));
run;

proc greplay igout= wbh.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

goptions reset=global gunit=pct border /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

/*
axis1 label=(a=90 h=4 c=black "Frequency") order=(0 to 16 by 2) minor=none;
axis2 label=(a=0 h=4 c=black "Age (days)") order=(0 to 100 by 10) minor=none;

title "Histogram of Age for LBWIs Who Complete Study (n=&n)";

Proc gchart data=cmv.comp_pat gout=wbh.graphs;
	vbar age/ midpoints=(0 to 100 by 10) raxis=axis1 maxis=axis2 space=1 coutline=black;
run;
quit;
*/
         	
/* Set up symbol for Boxplot */
symbol1 interpol=none mode=exclude value=circle co=blue cv=blue height=1 bwidth=4 width=1;
axis1 	label=(f=zapf h=3 'Total SNAP Score' ) value=(/*f=zapf*/ h=3.0) split="*" order= (0 to 25 by 2) minor=none offset=(0 in, 0 in);
axis2 	label=(f=zapf h=3 a=90 "Birthweight(g)") order=(400 to 1500 by 100) value=(/*f=zapf*/ h=3) ;
 

title "Weight (g) vs Total SNAP Score At Birth (n=&n)";

Proc gplot data=cmv.comp_pat gout=wbh.graphs;
	plot birthweight*SNAPTotalScore/ overlay haxis = axis1 vaxis = axis2  nolegend;
run;
quit;


options orientation=portrait;
ods ps file = "bw_snap.ps";
ods pdf file = "bw_snap.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
     treplay 1:1;
run;
ods pdf close;
ods ps close;
