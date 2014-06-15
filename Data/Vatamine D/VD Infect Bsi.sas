
PROC IMPORT OUT= WORK.vd10 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND VitD 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'vitD data$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data vd1;
	retain id day ohd rlu lot;
	set vd10(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;

PROC IMPORT OUT= WORK.vd20 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND vitD 032912-1.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'GLND vitD 032912-1 $'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data vd2;
	retain id day ohd rlu lot;
	set vd20(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;

PROC IMPORT OUT= WORK.vd30 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\GLND 25OHD data part-3 032912.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$B5:G63"; 
     GETNAMES=No;
     MIXED=No;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data vd3;
	retain id day ohd rlu lot;
	set vd30(keep=F2-F6 rename=(F3=OHD F5=RLU F6=Lot));
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	if id=. then delete;
	keep id day ohd rlu lot;
run;


data vd;
	set vd1 vd2 vd3;
	if id<10000 then delete;
run;
proc sort; by id day;run;
/*
proc sort nodupkey; by id;run;
proc print;run;
proc sort data=id; by id day;run;
proc means data=vd n;
	class day;
	var id ohd;
run;
*/

PROC IMPORT OUT= WORK.ll0 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\ELISA LL37 VitD VDBP 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'LL-37 Sum$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data ll;
	set ll0(keep=F2 F8);
	if _n_>8;
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	LL=F8+0;
	drop F2 F8;
	if id=. then delete;
run;
proc sort; by id day;run;

PROC IMPORT OUT= vdbp0 
            DATAFILE= "H:\SAS_Emory\Data\Vatamine D\ELISA LL37 VitD VDBP 032812.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'VDBP Sum$'"; 
     GETNAMES=NO;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data vdbp;
	set vdbp0(keep=F2 F9);
	if _n_>7;
	id=scan(F2, 1, "-")+0;
	day=scan(F2, 2, "-")+0;
	vdbp=F9+0;
	drop F2 F9;
	if id=. then delete;
run;
proc sort ; by id day;run;

data vd;
	merge vd ll vdbp; by id day;
run;

proc univariate data=vd plots;
var ohd ll vdbp;
run;

proc print;
where ll>200;
var id day ohd ll vdbp;
run;

option nofmterr nodate nonumber orientation=portrait;
libname wbh "H:\SAS_Emory\Data\Vatamine D";
%let mu=%sysfunc(byte(181));
%put &mu;


/*proc contents data=wbh.info;run;*/
proc format; 
	value yn    0="No" 1="Yes";
	value gender   99 = "Blank"
                 1 = "Male"
 				 2 = "Female" ;
   value treatment   99 = "Blank"
                 1 = "AG-PN"
                 2 = "STD-PN" ; 
	value death 0="Survivor" 1="Non-Survivor";
run;

data infect;
    set wbh.info (keep = id apache_2 ni_any ni_bsi ni_lri dt_any dt_bsi dt_lri);
    any=ifn(ni_any>0,1,0,0);
        bsi=ifn(ni_bsi>0,1,0,0);
            lri=ifn(ni_lri>0,1,0,0);
    keep id apache_2 any bsi lri dt_any dt_bsi dt_lri;
    format any bsi lri yn.;
run;


data sofa;
	set wbh.followup_all_long;
	where day=1;
	keep id sofa_tot;
run;


data glnd_VD;
	merge vd(in=A) wbh.info(keep=id age gender apache_2 hospital_death treatment days_hosp_post_entry days_sicu_post_entry days_on_vent_adj in=comp) 
		  infect sofa;	by id; 
	format treatment treatment. hospital_death death.;
	if A and comp;
	label ohd="25(OH)D" ll="LL37" vdbp="VDBP" hospital_death="In-Hospital Mortality";
run;


%macro getn(data,trt);
%do j = 0 %to 28 %by 14;
data _null_;
    set &data;
    where day = &j;
    if &trt=1 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if &trt=0 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let p1=0;
%let p2=0;
%let p3=0;

%macro mixed(data, var, trt, ylab, title)/minoperator;

	data tmp; 
	   set &data;	
	   if &var=. then delete;
	run;
	proc sort nodupkey; by id day; run;
	proc sort data=tmp nodupkey out=nday; by &trt day id;run;
	proc means data=nday noprint;
    	class &trt day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;
	

%let m0= 0; %let m14= 0; %let m28= 0;  
%let n0= 0; %let n14= 0; %let n28= 0;  

%getn(num_&var, &trt);

proc format;
	value dd -1=" " 0="0*(&m0)*(&n0)"  14 = "14*(&m14)*(&n14)" 28="28*(&m28)*(&n28)" 42=" ";
run;

*ods trace on/label listing;
	proc mixed data =tmp empirical covtest;
	class &trt id day ; 	
	model &var=&trt day &trt*day/ solution ; 
	repeated day / subject = id type = cs;
	lsmeans &trt*day/pdiff cl;
	
	ods output lsmeans = lsmean0;
	ods output Mixed.Diffs= diff;
	ods output Mixed.Tests3=p_&var;
run;

*ods trace off;

data diff;
    length pv $8;
    set diff;
    where day=_day;
    diff=put(estimate,4.1)||"["||put(lower,4.1)||" - "||put(upper,4.1)||"]";
    pv=put(probt, 7.4);
    if probt<0.0001 then pv="<0.0001";
    keep day diff probt pv;  
run;


data _null_;
    length pv $8;
    set p_&var;
    pv=put(probf,7.4);
    if probf<0.0001 then pv="<0.0001";
    if _n_=1 then call symput("p1", pv);
        if _n_=2 then call symput("p2", pv);
            if _n_=3 then call symput("p3", pv);
run;

data lsmean;
	set lsmean0;
	*if lower^=. and lower<0 then lower=0;
	day1=day+0.20;
	where day in(0,14,28); 
run;

proc sort; by &trt day;run;

DATA anno0; 
	set lsmean(where=(&trt=1));
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
	set lsmean(where=(&trt=0));
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
	merge lsmean(where=(&trt=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	lsmean(where=(&trt=0) rename=(estimate=estimate2 lower=lower2 upper=upper2)) 
	num_&var(where=(&trt=1) keep=&trt day num_obs rename=(num_obs=n1))
	num_&var(where=(&trt=0) keep=&trt day num_obs rename=(num_obs=n2))
	diff;
	by day;
	if day=. then delete;
	est1=put(estimate1,4.1)||"["||put(lower1,4.1)||" - "||put(upper1,4.1)||"], "||compress(n1);
	est2=put(estimate2,4.1)||"["||put(lower2,4.1)||" - "||put(upper2,4.1)||"], "||compress(n2);
run;

data test_&var;
    set estimate;
	where day in(0,14,28);
	keep day est1 est2 diff pv;
run;

data est_&var;
    retain day n1 estimate1 lower1 upper1 error1 n2 estimate2 lower2 upper2 error2;
    set estimate;
	where day in(0,14,28);
	error1=estimate1-lower1;
	error2=estimate2-lower2;
	
	format estimate1-estimate2 error1-error2 7.2;
	keep day n1 n2 estimate1-estimate2 error1-error2;
	*label n1="n*(AG-PN)" n2="n*(STD-PN)" estimate1="Mean*(AG-PN)" estimate2="Mean*(STD-PN)" 
	   error1="Error*(AG-PN)" error2="Error*(STD-PN)";
run;

goptions reset=all device=pslepsfc gunit=pct noborder cback=white colors = (black red) hby = 3 htitle=1 htext=1;

symbol1 i=j ci=red  value=square co=red cv=red h=1.75 ;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=1.75;

legend across = 1 position=(top right inside) mode = share shape = symbol(5,2) label=NONE 
value = (h=2.5 "BSI=Yes" "BSI=No") offset=(-0.2in, -0.2 in) frame;

%if &var=ohd %then %do; %let scaley=(10 to 25 by 1); %let scalex=( 0 to 42 by 14); %end;
%if &var=ll %then %do; %let scaley=(20 to 150 by 10); %let scalex=( 0 to 42 by 14); %end;
%if &var=vdbp %then %do; %let scaley=(15 to 25 by 1); %let scalex=(0 to 42 by 14); %end;


axis1 	label=(h=3 "Days on Study" ) split="*"	value=(h=2.5)  order=&scalex minor=none offset=(0.5 in, 0 in);
axis2 	label=(h=3 a=90 &ylab) value=(h=2.5) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 
title1 	height=5 "Model-Based Means and 95%CI by BSI and Days on Study";
title2  h=5 "for &title";
title3 	h=4 "p(BSI)=&p1, p(Days)=&p2, p(BSI*Days)=&p3";
          
proc gplot data= estimate gout=wbh.graphs;
	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=2.5 m=(10pct, 12 pct) "Day :" ;
	note h=2.5 m=(10pct, 9 pct) "(#BSI=Yes)" ;
	note h=2.5 m=(10pct, 6 pct) "(#BSI=No)" ;
	
	format day dd.  estimate1-estimate2 4.0;
run;
%mend mixed;

proc greplay igout= wbh.graphs nofs; delete _ALL_; run;
 
%let ylab="25(OH)D (ng/mL)";
%let title=Vitamin D by BSI;
%mixed(glnd_vd,ohd,bsi,&ylab, &title); run; 

%let ylab="LL-37 Total (ng/mL)";
%let title=LL-37 Total by BSI;
%mixed(glnd_vd,ll,bsi,&ylab, &title); run; 

%let ylab="VDBP (mg/dL)";
%let title=VDBP by BSI;
%mixed(glnd_vd,vdbp,bsi,&ylab, &title); run; 


	ods pdf file = "glnd_vd_bsi.pdf";
 		proc greplay igout = wbh.graphs tc=sashelp.templt template=v3  nofs ; * L2R2s;
            list igout;
			treplay 1:1  2:3  3:5;
		run;
	ods pdf close;



	ods  rtf  file="GLND VD bsi.rtf" style=journal bodytitle startpage=never;
	
	proc report data=test_ohd nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for 25(OH)D (ng/mL) by BSI and Days on Study";
    	column day est1 est2 diff ;
    	define day/"Day" order;
    	define est1/"BSI=Yes*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"BSI=No*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_ll nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for LL-37 (ng/mL) by BSI and Days on Study";
     	column day est1 est2 diff ;
    	define day/"Day" order;
    	define est1/"BSI=Yes*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"BSI=No*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;

	proc report data=test_vdbp nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for VDBP (mg/dL) by BSI and Days on Study";
    	column day est1 est2 diff;
    	define day/"Day" order;
    	define est1/"BSI=Yes*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"BSI=No*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;

	ods rtf close;
