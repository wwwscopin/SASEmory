option nofmterr nodate nonumber orientation=landscape;
libname wbh "H:\SAS_Emory\Data\complete";
%let mu=%sysfunc(byte(181));
%put &mu;

/*proc contents data=wbh.info;run;*/
proc format; 
	value cit   1="<11 &mu.mol/L" 2="11-20 &mu.mol/L" 3=">20 &mu.mol/L";
	value citru 1="<11 &mu.mol/L" 2=">=11 &mu.mol/L";
	value yn    0="No" 1="Yes";
	value apache   99 = "Blank"
                 1 = "APACHE <=15"
                 2 = "APACHE >15" ;
	value surg_index 0="Non-GI" 1="GI";
run;

PROC IMPORT OUT= citrulline0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="citrulline$A1:G661"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data citrulline;
	set citrulline0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	citrulline=round(result);
	if id=32006 then delete;
	keep id day citrulline;
	label citrulline="Citrulline (&mu.mol/L)";
run;
proc sort; by id day; run;
proc means data=citrulline(where=(day=0)) noprint n Q1 median Q3 maxdec=1;
	var citrulline;
	output out=wbh q1(citrulline)=Qc1 median(citrulline)=Qc2  q3(citrulline)=Qc3 /autoname;
run;

data _null_;
	set wbh;
	call symput("qc1", qc1);
	call symput("qc2", qc2);
	call symput("qc3", qc3);
run;

proc sql;
	create table wbh.citrulline as 
	select a.*, count(citrulline) as n
	from citrulline as a
	group by id
	;

PROC IMPORT OUT= glutamine0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="glutamine$A1:G658"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data glutamine;
	set glutamine0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	rename result=glutamine;
	if id=32006 then delete;
	keep id day result;
	label result="Glutamine (&mu.M)";
run;
proc sort; by id day; run;

proc sql;
	create table wbh.glutamine as 
	select a.*, count(glutamine) as n
	from glutamine as a
	group by id
	;
quit;
proc format;
	value qcit 1="Citrulline<~&qc1.&mu.m" 2="Citrulline=&qc1.~&qc2.&mu.m" 3="Citrulline=&qc2.~&qc3.&mu.m" 4="Citrulline>=&qc3&mu.m";
	value sofa 1="<=6" 2=">6";
run;

/*proc contents data=wbh.info;run;
proc means data=wbh.followup_all_long(where=(day=1)) median;
	var sofa_tot;
run;
*/

data glnd;
	merge citrulline(where=(day=0)) glutamine(where=(day=0)) wbh.followup_all_long(keep=id day sofa_tot where=(day=1))
	wbh.info(keep=id surg ap1 apache_2 dt_discharge dt_death dt_random hospital_death deceased day_28_death followup_days ni_bsi ni_any ni_lri); 
	by id; 
	if 0<=citrulline<11 then cit=1;
		else if 11<=citrulline<=20 then cit=2;
		else if 20<citrulline then cit=3;
	
	if cit=1 then citru=1; else if cit in(2,3) then citru=2;

	if  0<=citrulline<&Qc1 then qcit=1;
	else if &Qc1<=citrulline<&Qc2 then qcit=2;
	else if &Qc2<=citrulline<&Qc3 then qcit=3;
	else if &Qc3<=citrulline then qcit=4;
	
	if 0<ap1<=15 then apache_icu=1; else if ap1>15 then apache_icu=2;
	if glutamine>2000 then glutamine=.;
	if sofa_tot>6 then sofa=2; else sofa=1;
	if ni_bsi>0 then bsi=1; else bsi=0;
	if ni_lri>0 then lri=1; else lri=0;
	if ni_any>0 then any=1; else any=0;
	if surg="Upper GI resection" then surg_index=1; else surg_index=0;

	dday=dt_death-dt_random;
	if dday=. then dday=dt_discharge-dt_random;
	drop day;
	label cit="Citrulline" citru="Citrulline";
	format cit cit. citru citru. qcit qcit. apache_2 apache_icu apache. sofa sofa. bsi lri any yn. surg_index surg_index.;
run;

proc logistic data=glnd descending plots=roc;
	model hospital_death=citrulline/OUTROC=wbh;
	roc ;
	output out=pred p=phat lower=lcl upper=ucl  predprobs=(individual crossvalidate);
run;
/*
proc print data=wbh;run;
*/
proc sort data=pred nodupkey; by citrulline;run;
proc print data=pred;
var citrulline phat lcl ucl;
where citrulline^=.;
run;

proc sgplot data=pred;  
   scatter x=citrulline y=phat;
   band x=citrulline lower=lcl upper=ucl / transparency=0.8;
run;


proc freq data=glnd;
	tables citru/binomial(ac wilson exact);
run;

proc freq data=glnd;
   tables qcit*hospital_death/ nopercent norow cmh chisq fisher trend ;
run;


/*
proc freq data=glnd;
   tables qcit*deceased/ nopercent norow cmh chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model deceased=qcit;
run;

proc freq data=glnd;
   tables qcit*apache_icu/ nopercent norow cmh chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model apache_icu=qcit;
run;

proc freq data=glnd;
   tables qcit*apache_2/ nopercent norow cmh chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model apache_2=qcit;
run;

proc freq data=glnd;
   tables qcit*sofa/ nopercent norow cmh chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model sofa=qcit;
run;

proc freq data=glnd;
   tables qcit*bsi/ nopercent norow cmh chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model bsi=qcit;
run;

proc freq data=glnd;
   tables qcit*lri/ nopercent norow chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model lri=qcit;
run;

proc freq data=glnd;
   tables qcit*any/ nopercent norow chisq fisher trend ;
run;

proc logistic data=glnd descending;
	class qcit;
	model any=qcit;
run;
*/

proc means data=glnd(keep=id surg citrulline) mean std Q1 median Q3 maxdec=1;
	class surg; 
	var citrulline;
run;

proc npar1way data=glnd(keep=id surg citrulline) wilcoxon;
	class surg; 
	var citrulline;
run;

/*
proc means data=glnd(keep=id surg_index citrulline) mean std Q1 median Q3 maxdec=1;
	class surg_index; 
	var citrulline;
run;

proc npar1way data=glnd(keep=id surg_index citrulline) wilcoxon;
	class surg_index; 
	var citrulline;
run;
*/


data _null_;
	set glnd(where=(hospital_death=1 and citru^=.));
	call symput("num_death", compress(_n_));
run;

*ods trace on/label listing;
proc corr data=glnd /*spearman*/ ;
	var citrulline;
	with glutamine;
	ods output  Corr.PearsonCorr=cor;
run;
*ods trace off;

proc print;run;

data _null_;
	set cor;
	call symput("cor", put(citrulline, 5.2));
	call symput("pcor", put(Pcitrulline, 5.2));
run;

proc reg data=glnd outest=regdata noprint;
   model glutamine=citrulline / clm;
run;
quit;

/* Place the regression equation in a macro variable. */
data _null_;
   set regdata;
   call symput('eqn',"Glutamine="||Intercept||" + "||citrulline||"*Citrulline");
run;

ods listing close;
ods html file='regressionplot.html' path='.' style=styles.statistical;
ods graphics / reset width=600px height=400px imagename='Regression' imagefmt=gif;

title 'PROC SGPLOT with Regression Equation';

proc sgplot data=glnd;
   TITLE "Linear Regression for Glutamine on Baseline Citrulline";
   reg x=citrulline y=glutamine / clm CURVELABELLOC=inside;
   *reg x=glutamine  y=citrulline / clm CURVELABELLOC=inside;
   inset "r=&cor(p=&pcor)"/position=topright;

   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
   /* inset "&eqn" / position=bottomleft;  */

   *footnote1 j=l "Regression Equation";
   *footnote2 j=l "&eqn";
run;

proc sgplot data=glnd;
   TITLE "Linear Regression for Citrulline on Baseline Glutamine";
   reg x=glutamine  y=citrulline / clm CURVELABELLOC=inside;
   inset "r=&cor(p=&pcor)"/position=topright;
run;

ods html close;
ods listing;

proc freq data=glnd;
tables citru;
ods output onewayfreqs=tmp;
run;

data _null_;
    set tmp;
    if citru=1 then call symput("n", compress(frequency));
    if citru=2 then call symput("m", compress(frequency));
run;

%put &n;
%put &m;
/*
proc lifetest nocensplot data=glnd;
	ods output productlimitestimates=plt;
	time dday*hospital_death(0);
    strata citru;
run;
*/

proc lifetest nocensplot data=glnd timelist=0 7 14 21 28 30 35 42 49 56 63 70 77 84 91 outsurv=pl1;
	ods output productlimitestimates=plt;
	time dday*hospital_death(0);
    strata citru;
run;

data _null_;
	set plt;
	if citru=1 then do;
       if Timelist=0  then call symput( "n0",   compress(put(left, 3.0))); 
	   if Timelist=7  then call symput( "n7",   compress(put(left, 3.0))); 
       if Timelist=14 then call symput( "n14",  compress(put(left, 3.0))); 
	   if Timelist=21 then call symput( "n21",  compress(put(left, 3.0))); 
	   if Timelist=28 then call symput( "n28",  compress(put(left, 3.0))); 
       if Timelist=35 then call symput( "n35",  compress(put(left, 3.0))); 
       if Timelist=42 then call symput( "n42",  compress(put(left, 3.0))); 
	   if Timelist=49 then call symput( "n49",  compress(put(left, 3.0))); 
       if Timelist=56 then call symput( "n56",  compress(put(left, 3.0))); 
	   if Timelist=63 then call symput( "n63",  compress(put(left, 3.0))); 
	   if Timelist=70 then call symput( "n70",  compress(put(left, 3.0))); 
       if Timelist=77 then call symput( "n77",  compress(put(left, 3.0))); 
       if Timelist=84 then call symput( "n84",  compress(put(left, 3.0))); 
	   if Timelist=91 then call symput( "n91",  compress(put(left, 3.0))); 
	end;
	if citru=2 then do;
       if Timelist=0   then call symput( "m0",   compress(put(left, 3.0))); 
	   if Timelist=7   then call symput( "m7",   compress(put(left, 3.0))); 
       if Timelist=14  then call symput( "m14",  compress(put(left, 3.0))); 
	   if Timelist=21  then call symput( "m21",  compress(put(left, 3.0))); 
	   if Timelist=28  then call symput( "m28",  compress(put(left, 3.0))); 
       if Timelist=35  then call symput( "m35",  compress(put(left, 3.0))); 
       if Timelist=42  then call symput( "m42",  compress(put(left, 3.0))); 
	   if Timelist=49  then call symput( "m49",  compress(put(left, 3.0))); 
       if Timelist=56  then call symput( "m56",  compress(put(left, 3.0))); 
	   if Timelist=63  then call symput( "m63",  compress(put(left, 3.0))); 
	   if Timelist=70  then call symput( "m70",  compress(put(left, 3.0))); 
       if Timelist=77  then call symput( "m77",  compress(put(left, 3.0))); 
       if Timelist=84  then call symput( "m84",  compress(put(left, 3.0))); 
	   if Timelist=91  then call symput( "m91",  compress(put(left, 3.0))); 
	end;
run;

proc format;
		value dd -1="Day*(#<11 &mu.mol/L)*(#>=11 &mu.mol/L)" 0="0*(&n0)*(&m0)" 7="7*(&n7)*(&m7)" 14="14*(&n14)*(&m14)" 
			 21="21*(&n21)*(&m21)" 28="28*(&n28)*(&m28)" 35="35*(&n35)*(&m35)" 42="42*(&n42)*(&m42)"
			 49="49*(&n49)*(&m49)" 56="56*(&n56)*(&m56)" 63="63*(&n63)*(&m63)" 70="70*(&n70)*(&m70)" 77="77*(&n77)*(&m77)" 
			 84="84*(&n84)*(&m84)" 91="91*(&n91)*(&m91)";
run;

*ods trace on/label listing;
proc lifetest data=glnd confband=all outsurv=pl1 nocensplot;
	time dday*hospital_death(0);
    strata citru;
    ods output HomTests=tmp;
run;
*ods trace off;

data _null_;
    length pv $8;
    set tmp;
    if _n_=1;
    if probchisq<0.0001 then pv="<0.0001";
    else pv=compress(put(probchisq, 5.2));
    call symput("pv", pv);    
run;

data pl;
    set pl1 end=last;
    prob=1-SURVIVAL;
	lower=1-SDF_UCL;
	upper=1-SDF_LCL;

	if lower=. then delete;
    keep citru dday prob upper lower;  
run;

data pl_citru1;
    set pl(where=(citru=1) keep=citru dday prob upper lower rename=(prob=prob0 upper=upper0 lower=lower0)) end=last;
    
    retain p1 p2 p3;
	if lower0^=. then do; p1=prob0; p2=lower0; p3=upper0;  end;
    output;	
    if last then do; if dday<91 then dday=91;  prob0=p1; lower0=p1; upper0=p2; output; end;
run;

data pl_citru2;
    set pl(where=(citru=2) keep=citru dday prob lower upper rename=(prob=prob1 upper=upper1 lower=lower1 dday=dday1)) end=last;
    retain p1 p2 p3;
	if lower1^=. then do; p1=prob1; p2=lower1; p3=upper1;  end;
    output;
    if last then do; if dday1<91 then dday1=91;  prob1=p1; lower1=p1; upper1=p2; output;end;
run;

data pl;
    merge pl_citru1 pl_citru2;
    drop citru;
run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct device=pslepsfc colors=(orange green red) hby = 3;

symbol1 i=steplj mode=exclude value=circle co=blue cv=blue height=1 bwidth=4 width=1.5 l=1;
symbol2 i=steplj mode=exclude value=dot co=red cv=red height=1 bwidth=4 width=1.5 l=1;

legend1 across = 1 position=(top left inside) mode = share shape = symbol(3,2) label=NONE 
value = ( h=2 c=black "Citrulline <11&mu.mol/L" "Citrulline >=11&mu.mol/L") offset=(0.2in, -0.4 in) frame cframe=white cborder=black;

title1 h=3 justify=center "In-Hospital Mortality by Baseline Plasma Citrulline Levels (Number of Death=&num_death)";
title2 h=2.5 justify=center "Log-Rank Test: p=&pv";
         
axis1 	label=(h=2.5 'In-Hospital Days after Randomization' ) split="*" value=(h=2) order= (0 to 91 by 7) minor=none offset=(0.2in, 0);
axis2 	label=(h=2.5 a=90 "In-Hospital Mortality") order=(0 to 1 by 0.1) value=(h=2) ;
     
           
proc gplot data=pl gout=wbh.graphs;
	plot  prob0*dday prob1*dday1/overlay haxis = axis1 vaxis = axis2  legend=legend1;
    format dday dd. prob0 prob1 5.1;
	note h=2 m=(2pct, 10.25 pct) "Day:" ;
	note h=2 m=(-2.25pct, 8 pct) "(#<11&mu.mol/L)" ;
	note h=2 m=(-2.25pct, 5.75 pct) "(# >=11&mu.mol/L)" ;
run;	


filename output 'citrulline_mortality.eps';
goptions reset=all BORDER device=pslepsfc gsfname=output gsfmode=replace ;

ods pdf file = "citrulline_km.pdf";
proc greplay igout =wbh.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;

ods pdf style=journal;
proc print data=plt noobs label;
where  Timelist=30;
var citru timelist failure stderr left;
label timelist="Days on Study" Failure="Motality(%)";
format timelist 4.0;
run;
ods pdf close;
