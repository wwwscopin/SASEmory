
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait /*mlogic mprint symbolgen*/;

%let mu=%sysfunc(byte(181));

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;



data flag_lps;
	merge glnd_ext.flag_lps(drop=day) glnd.george(keep=id treatment); by id;
	
	if .<anti_flag_IgG<0 then anti_flag_IgG=0; 
    if .<anti_flag_IgA<0 then anti_flag_IgA=0;
    if .<anti_flag_IgM<0 then anti_flag_IgM=0; 
    
    if .<anti_lps_IgG<0 then anti_lps_IgG=0;
    if .<anti_lps_IgA<0 then anti_lps_IgA=0;
    if .<anti_lps_IgM<0 then anti_lps_IgM=0;
    rename visit=day;
run;

proc transpose data=flag_lps out=igm1(keep=id col1-col7); 
    by id;
    var anti_lps_IgM;
run;
data igm;
set igm1;
Igm_sum=sum(of col1-col7);
if igm_sum=0;
keep id;
run;
proc print;run;


/*
proc univariate data=flag_lps plots;
    var anti_flag_IgG anti_flag_IgA anti_flag_IgM anti_lps_IgG anti_lps_IgA anti_lps_IgM;
    *qqplot;
    HISTOGRAM / NORMAL exponential (COLOR=RED W=5) NROWS=3;
run;
*/

proc format; 
    value trt 1="Survivor" 2="Non-Survivor";
run;


%macro getn(data,trt);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;
    if &trt=0 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if &trt=1 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let p1=0;
%let p2=0;
%let p3=0;

%macro mixed(data, var, trt, ylab, title)/minoperator;

	data tmp; 
	   merge &data glnd.info(keep=id hospital_death); by id;		
	   if &var=. then delete;
	   if day<=14;
	run;
	%if &var # gluc_all glu_local %then %do;
	   proc sort; by id day; run;
	%end;
	%else %do;
    	proc sort nodupkey; by id day; run;
	%end;
	
	proc sort data=tmp nodupkey out=nday; by &trt day id;run;
	proc means data=nday noprint;
    	class &trt day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;
	

%let m1= 0; %let m2= 0; %let m3= 0; %let m4= 0; %let m5= 0; %let m6=0; %let m7= 0;  %let m0=0;
%let m8= 0; %let m9= 0; %let m10= 0; %let m11= 0; %let m12= 0; %let m13= 0; %let m14= 0;   
%let m15= 0; %let m16= 0; %let m17= 0; %let m18= 0; %let m19= 0; %let m20=0; %let m21= 0;  
%let m22= 0; %let m23= 0; %let m24= 0; %let m25= 0; %let m26= 0; %let m27= 0; %let m28= 0;   

%let n1= 0; %let n2= 0; %let n3= 0; %let n4= 0; %let n5= 0; %let n6=0; %let n7= 0;  %let n0=0;
%let n8= 0; %let n9= 0; %let n10= 0; %let n11= 0; %let n12= 0; %let n13= 0; %let n14= 0; 
%let n15= 0; %let n16= 0; %let n17= 0; %let n18= 0; %let n19= 0; %let n20=0; %let n21= 0;  
%let n22= 0; %let n23= 0; %let n24= 0; %let n25= 0; %let n26= 0; %let n27= 0; %let n28= 0; 

%getn(num_&var, &trt);

proc format;


value dd -1=" " 0 = " "  1="1*(&m1)*(&n1)"  2 = " " 3=" " 4 = "4*(&m4)*(&n4)" 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";
		
value dt -1=" " 0 = "0*(&m0)*(&n0)"  1=" "  2 = " " 3="3*(&m3)*(&n3)" 4 = " " 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";

run;

%if &var=anti_flag_IgG %then %do; %let scaley=(0 to 1.2 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = .07; %let y2= 1; %end;
%if &var=anti_flag_IgA %then %do; %let scaley=(0 to 3 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = .04; %let y2= .9; %end;
%if &var=anti_flag_IgM %then %do; %let scaley=(0 to 1.6 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = .6; %let y2= 1.2; %end;
%if &var=anti_lps_IgG %then %do; %let scaley=(0 to 1 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = .4; %let y2= .8; %end;
%if &var=anti_lps_IgA %then %do; %let scaley=(0 to 3 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = .4; %let y2= .8; %end;
%if &var=anti_lps_IgM %then %do; %let scaley=(0 to 1.6 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = .8; %let y2= 1.4; %end;


*ods trace on/label listing;

proc genmod data =tmp ;
	class &trt id day ; 	
	model &var=&trt day &trt*day/dist =poisson link = log type3; 
	repeated subject = id /type = cs;
	lsmeans &trt*day/diff cl e;
	ods output lsmeans = lsmean0;
	ods output Diffs= diff;
	ods output Type3=p_&var;
run;

*ods trace off;

data diff;
    length pv $8;
    set diff;
    where day=_day;
    
    %if &var # sofa_tot hsp27_ng log_gsh_conc log_gssg_conc anti_flag_IgG anti_flag_IgA %then %do;
        diff=put(estimate,7.2)||"("||put(lower,7.2)||", "||put(upper,7.2)||")";	
    %end;
	%else %do;
        diff=put(estimate,5.0)||"("||put(lower,5.0)||", "||put(upper,5.0)||")";	
    %end;
    
    diff=put(estimate,7.2)||"("||put(lower,7.2)||", "||put(upper,7.2)||")";
    pv=put(probz, 7.4);
    if probz<0.0001 then pv="<0.0001";
    keep day diff probz pv;  
run;


data _null_;
    length pv $8;
    set p_&var;
    pv=put(probchisq,7.4);
    if probchisq<0.0001 then pv="<0.0001";
    if _n_=1 then call symput("p1", pv);
        if _n_=2 then call symput("p2", pv);
            if _n_=3 then call symput("p3", pv);
run;

data lsmean;
	set lsmean0;
	day1=day+0.20;
	
    estimate=exp(estimate);
    lower=exp(lower);
    upper=exp(upper);

    where day in(0,3,7,14,21,28);
run;

proc sort; by &trt day;run;


DATA anno0; 
	set lsmean(where=(&trt=0));
	xsys='2'; ysys='2';  color='red ';
	

	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    	X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
    	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set lsmean(where=(&trt=1));
	xsys='2'; ysys='2';  color='blue';
	
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    	X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
      	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno;
	set anno0 anno1;
run;

data estimate;
	merge lsmean(where=(&trt=0) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	lsmean(where=(&trt=1) rename=(estimate=estimate2 lower=lower2 upper=upper2)) 
	num_&var(where=(&trt=0) keep=&trt day num_obs rename=(num_obs=n1))
	num_&var(where=(&trt=1) keep=&trt day num_obs rename=(num_obs=n2))
	diff;
	by day;
	if day=. then delete;
    	est1=put(estimate1,7.2)||"["||compress(put(lower1,7.2))||" - "||compress(put(upper1,7.2))||"], "||compress(n1);
	    est2=put(estimate2,7.2)||"["||compress(put(lower2,7.2))||" - "||compress(put(upper2,7.2))||"], "||compress(n2);
run;

data test_&var;
    set estimate;
    where day in(0,3,7,14,21,28); 
    keep day est1 est2 diff pv;
run;

data est_&var;
    retain day n1 estimate1 lower1 upper1 error1 n2 estimate2 lower2 upper2 error2;
    set estimate;
    where day in(0,3,7,14,21,28);
	error1=estimate1-lower1;
	error2=estimate2-lower2;
	%if &var # log_gsh_conc log_gssg_conc log_il6 log_il8 log_ifn log_tnf
	 %then %do;
   	   	   keep day n1 n2 estimate1-estimate2 lower1-lower2 upper1-upper2;
   	   	   format estimate1-estimate2 lower1-lower2 upper1-upper2 7.2;
	 %end;
	 %else %do;
    	 keep day n1 n2 estimate1-estimate2 error1-error2 lower1-lower2 upper1-upper2;
    	 format estimate1-estimate2 error1-error2 lower1-lower2 upper1-upper2 7.2;
	 %end;
	
	label n1="n*(Survivor)" n2="n*(Non-Survivor)" estimate1="Mean*(Survivor)" estimate2="Mean*(Non-Survivor)" 
	   error1="Error*(Survivor)" error2="Error*(Non-Survivor)" lower1="Lower*(Survivor)" lower2="Lower*(Non-Survivor)"
	   upper1="Upper*(Survivor)" upper2="Upper*(Non-Survivor)";
run;



goptions reset=all device=pslepsfc gunit=pct noborder cback=white colors = (black red) htitle=4 htext=2;

symbol1 i=j  value=dot ci=red co=red cv=red h=1.75 ;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=1.75;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(5,2) label=NONE 
value = (h=1.25 "Survivor" "Non-Survivor") offset=(-0.2in, -0.2 in) frame;

axis1 	label=(h=2.5 "Days on Study" ) split="*"	value=(h=1.5)  order=&scalex minor=none offset=(0 in, 0 in);
axis2 	label=(h=2.5 a=90 &ylab) value=(h=1.75) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 
title1 	h=4 Means and 95%CI by Vital Status and Days on Study;
%if &var # log_gsh_conc log_gssg_conc log_il6 log_il8 log_ifn log_tnf
	 %then %do;
        title1 	h=4 Geometric Means and 95%CI by Vital Status and Days on Study;
     %end;
title2 h=4 for &title;
title3 	height=4 "p(Vital Status)=&p1, p(Days)=&p2, p(Vital Status*Days)=&p3";

             
proc gplot data= estimate gout=glnd_rep.graphs;
    %if &var # sofa_tot gluc_all glu_local glucose glu_center %then %do;
    	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
    %end;
    %else %do;
    	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend vref=&y1 &y2;
    %end;
	note h=1.75 m=(2pct, 9 pct) "Day :" ;

	note h=1.75 m=(1pct, 7 pct) "(# Survivor)" ;
	note h=1.75 m=(1pct, 5 pct) "(#Non-Survivor)" ;
	
	format estimate1 estimate2 4.1 day dt.; 
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;

/*
%let ylab="a-Flagellin IgG (O.D.)";
%let title=a-Flagellin IgG (O.D.) ;
%mixed(flag_lps,anti_flag_IgG,hospital_death,&ylab, &title); run; 

%let ylab= "a-Flagellin IgA (O.D.)";
%let title="a-Flagellin IgA (O.D.)" ;
%mixed(flag_lps,anti_flag_IgA,hospital_death,&ylab, &title); run; 
*/

%let ylab="a-Flagellin IgM (O.D.)";
%let title=a-Flagellin IgM (O.D.) ;
%mixed(flag_lps,anti_flag_IgM,hospital_death,&ylab, &title); run; 


%let ylab="a-LPS IgG (O.D.)";
%let title=a-LPS IgG (O.D.) ;
%mixed(flag_lps,anti_lps_IgG,hospital_death,&ylab, &title); run; 


%let ylab= "a-LPS IgA (O.D.)";
%let title="a-LPS IgA (O.D.)" ;
%mixed(flag_lps,anti_lps_IgA,hospital_death,&ylab, &title); run; 


%let ylab="a-LPS IgM (O.D.)";
%let title=a-LPS IgM (O.D.) ;
%mixed(flag_lps,anti_lps_IgM,hospital_death,&ylab, &title); run; 



	ods pdf file = "flag_lps_bydeath_wk2.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1  2:3;
			treplay 1:5  2:7;
		run;
	ods pdf close;
	

ods tagsets.excelxp file="flag_lps_bydeath_wk2.xls";

/*
ods tagsets.excelxp
options(sheet_name="anti_flag_IgG");
proc print data=est_anti_flag_IgG noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_flag_IgA");
proc print data=est_anti_flag_IgA noobs label split="*";run;
*/

ods tagsets.excelxp
options(sheet_name="anti_flag_IgM");
proc print data=est_anti_flag_IgM noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_lps_IgG");
proc print data=est_anti_lps_IgG noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_lps_IgA");
proc print data=est_anti_lps_IgA noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_lps_IgM");
proc print data=est_anti_lps_IgM noobs label split="*";run;

ods tagsets.excelxp close;



	ods  rtf  file="flag_lps_bydeath_wk2.rtf" style=journal bodytitle startpage=never;
	/*
	proc report data=test_anti_flag_IgG nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-Flagellin IgG (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_anti_flag_IgA nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-Flagellin IgA (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	*/
	
	proc report data=test_anti_flag_IgM nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-Flagellin IgM (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;	
    
    
	proc report data=test_anti_lps_IgG nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-LPS IgG (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_anti_lps_IgA nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-LPS IgA (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_anti_lps_IgM nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for alpha-LPS IgM (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;								
	
	ods rtf close;
	

	
	
