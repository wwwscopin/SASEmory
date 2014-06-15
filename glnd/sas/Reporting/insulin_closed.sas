options nodate nonumber;
	
data insulin;
	set glnd.followup_all_long(keep=id day gluc_mrn gluc_aft gluc_eve tot_insulin);
	center=floor(id/10000);
	format center center.;
	gluc_mean=mean(gluc_mrn,gluc_aft,gluc_eve);
	where gluc_mrn^=. or gluc_aft^=. or gluc_eve^=. or tot_insulin^=.;
	if id=12207 then delete;
	format gluc_mean 5.1;
run;

proc sort data=insulin;by id;run;

 data insulin_plot;
	merge 	insulin
			glnd.george (keep = id treatment)
			;
	by id;
	run;

 	* capture sample size of total people in each trt group; 
		proc means data= glnd.george;
			where (treatment = 1);
			output out= n_A n(id) = id_n;
		run;
		
		proc means data= glnd.george;
			where (treatment = 2);
			output out= n_B n(id) = id_n;
		run;
				
		data _null_;
			set n_A;
	
			call symput('n_A', compress(put(id_n, 3.0)));
		run;
		
		data _null_;
			set n_B;
	
			call symput('n_B', compress(put(id_n, 3.0)));
		run;


goptions reset=all rotate=portrait device=jpeg gunit=pct noborder cback=white
  		colors = (black) ftitle=zapf ftext= zapf htitle=3 htext=3;


axis1 label=(a=90 h=4 c=Black "Blood glucose (mg/dL)") order=(0 to 300 by 50) minor=none;
axis2 label=( h=4 c=Black "Total insulin administered (units)") order=(0 to 500 by 50) minor=none;



symbol1 value=circle   i=none h=2 w=2 c=blue;  *repeat=130;

title "Blood glucose (mg/dL) vs Total insulin administered (units), treatment A (n=&n_A)";

proc gplot data=insulin_plot gout=cat1;
	where treatment=1;
	plot gluc_mean*tot_insulin/vaxis=axis1 haxis=axis2 nolegend; *noframe;
run;

title "Blood glucose (mg/dL) vs Total insulin administered (units), treatment B (n=&n_B)";
proc gplot data=insulin_plot gout=cat1;
	where treatment=2;
	plot gluc_mean*tot_insulin/vaxis=axis1 haxis=axis2 nolegend; *noframe;
run;

filename output 'insulin_closed.eps';
goptions reset=all rotate = portrait device=pslepsfc gsfname=output gsfmode=replace;

		ods pdf file = "/glnd/sas/reporting/insulin_closed.pdf";
		ods ps file = "/glnd/sas/reporting/insulin_closed.ps";
			proc greplay igout = cat1 tc=sashelp.templt template= v2s nofs;
				treplay 1:gplot 2:gplot1;
			run;
		ods ps close;
		ods pdf close;

