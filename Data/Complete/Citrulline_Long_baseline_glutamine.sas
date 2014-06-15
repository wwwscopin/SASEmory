option nofmterr nodate nonumber orientation=landscape;
libname wbh "H:\SAS_Emory\Data\complete";
%let mu=%sysfunc(byte(181));
%put &mu;

/*proc contents data=wbh.info;run;*/
proc format; 
	value cit   1="<=10 &mu.mol/L" 2="10-20 &mu.mol/L" 3=">20 &mu.mol/L";
	value citru 1="<=10 &mu.mol/L" 2=">10 &mu.mol/L";
	value yn    0="No" 1="Yes";
	value apache   99 = "Blank"
                 1 = "APACHE <=15"
                 2 = "APACHE >15" ;
	value surg_index 0="Non-GI" 1="GI";
	value death 1="Survivor" 2="Non-Survivor";
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

proc format;
	value qcit 1="Citrulline<~&qc1.&mu.m" 2="Citrulline=&qc1.~&qc2.&mu.m" 3="Citrulline=&qc2.~&qc3.&mu.m" 4="Citrulline>=&qc3&mu.m";
	value sofa 1="<=6" 2=">6";
run;


data glnd;
	merge citrulline glutamine;
	by id day; 

	if day=0 then do;
		if  0<=citrulline<&Qc1 then qcit=1;
		else if &Qc1<=citrulline<&Qc2 then qcit=2;
		else if &Qc2<=citrulline<&Qc3 then qcit=3;
		else if &Qc3<=citrulline then qcit=4;
	end;
	
	retain base_glu;
	if day=0 then base_glu=glutamine;

	label qcit="Citrulline";
	format qcit qcit.;
run;

data sofa;
	set wbh.followup_all_long(keep=id day sofa_tot where=(day=1));
	drop day;
run;

data glnd;
	merge glnd sofa	wbh.info(keep=id treatment deceased apache_2); by id;
	if sofa_tot>6 then sofa=2; else sofa=1;
	death_6month=deceased+1;
	format apache_2 apache. sofa sofa. death_6month death.;
run;

%macro getn(data);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;

   	if &gvar=1 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if &gvar=2 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let p1=0;
%let p2=0;
%let p3=0;

%macro mixed(data, gvar, var, ylab, title);

	data tmp; 
	   set &data;	
	   if &var=. then delete;
	run;
	proc sort nodupkey; by id day; run;
	proc sort data=tmp nodupkey out=nday; by &gvar day id;run;
	proc means data=nday noprint;
    	class &gvar day;
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

%getn(num_&var);

proc format;
	
value dd -1=" " 0 = "0*(&m0)*(&n0)"  1=" "  2 = " " 3="3*(&m3)*(&n3)" 4 = " " 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";

run;

*ods trace on/label listing;
	proc mixed data =tmp empirical covtest;
	class &gvar id day ; 	
	model &var=base_glu &gvar day &gvar*day/ solution ; 
	repeated day / subject = id type = cs;
	lsmeans &gvar*day/pdiff cl;
	
	ods output lsmeans = lsmean0;
	ods output Mixed.Diffs= diff;
	ods output Mixed.Tests3=p_&var;
run;

*ods trace off;

data diff;
    length pv $8;
    set diff;
    where day=_day;
    diff=put(estimate,4.0)||"("||put(lower,4.0)||", "||put(upper,4.0)||")";
    pv=put(probt, 7.4);
    if probt<0.0001 then pv="<0.0001";
    keep day diff probt pv;  
run;


data _null_;
    length pv $8;
    set p_&var(firstobs=2);
    pv=put(probf,7.4);
    if probf<0.0001 then pv="<0.0001";
    if _n_=1 then call symput("p1", pv);
        if _n_=2 then call symput("p2", pv);
            if _n_=3 then call symput("p3", pv);
run;

data lsmean;
	set lsmean0;
	if lower^=. and lower<0 then lower=0;
	day1=day+0.20;
run;

proc sort; by &gvar day;run;

DATA anno0; 
	set lsmean(where=(&gvar=1));
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
	set lsmean(where=(&gvar=2));
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

		merge lsmean(where=(&gvar=1) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
		lsmean(where=(&gvar=2) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
		num_&var(where=(&gvar=1) keep=&gvar day num_obs rename=(num_obs=n0))
		num_&var(where=(&gvar=2) keep=&gvar day num_obs rename=(num_obs=n1))
		diff;

	by day;
	if day=. then delete;
	est0=put(estimate0,4.0)||"("||put(lower0,4.0)||", "||put(upper0,4.0)||"), "||compress(n0);
	est1=put(estimate1,4.0)||"("||put(lower1,4.0)||", "||put(upper1,4.0)||"), "||compress(n1);
run;


data est_&var;
    set estimate;
run;

goptions reset=all gunit=pct noborder cback=white colors = (black red)  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

%if &gvar=death_6month %then %do;
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "Survivor" "Non-Survivor") offset=(0.2in, -0.2 in) frame;
%end;

%if &gvar=treatment %then %do;
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "AG-PN" "STD-PN") offset=(0.2in, -0.2 in) frame;
%end;

%if &gvar=apache_2 %then %do;
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "Apache II<=15" "Apache II>15") offset=(0.2in, -0.2 in) frame;
%end;

%if &gvar=sofa %then %do;
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "SOFA<=6" "SOFA>6") offset=(0.2in, -0.2 in) frame;
%end;

%if &var=citrulline %then %do; %let scaley=(0 to 30 by 2); %let scalex=(-1 to 29 by 1); %end;


axis1 	label=( h=3 "Days on Study" ) split="*"	value=(h=2.5)  order=&scalex minor=none offset=(0.4in, 0 in);
axis2 	label=( h=3 a=90 &ylab) value=( h=2.5) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 
title1 	height=3.5  "&title";
title2 	height=2.5  "p(Group)=&p1, p(Days)=&p2, p(Group*Days)=&p3";

             
proc gplot data= estimate gout=wbh.graphs;
	plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=2.5 m=(2pct, 12.5 pct) "Day :" ;

	%if &gvar=death_6month %then %do;
		note h=2.5 m=(1pct, 9.5 pct) "(#Survivor)" ;
		note h=2.5 m=(1pct, 7 pct) "(#Non-Survivor)" ;
	%end;

	%if &gvar=treatment %then %do;
		note h=2.5 m=(1pct, 9.5 pct) "(#AG-PN)" ;
		note h=2.5 m=(1pct, 7 pct) "(#STD-PN)" ;
	%end;

	%if &gvar=apache_2 %then %do;
		note h=2.5 m=(1pct, 9.5 pct) "(#ApacheII <=15)" ;
		note h=2.5 m=(1pct, 7 pct) "(#ApacheII >15)" ;
	%end;

	%if &gvar=sofa %then %do;
		note h=2.5 m=(1pct, 9.5 pct) "(#SOFA <=6)" ;
		note h=2.5 m=(1pct, 7 pct) "(#SOFA >6)" ;
	%end;
	
	format day dd. estimate0 2.0; 
run;
%mend mixed;

proc greplay igout= wbh.graphs nofs; delete _ALL_; run;

%let ylab="(Citrulline &mu.M)";
%let title=Citrulline by 6-Month Mortality;
%mixed(glnd,death_6month,citrulline,&ylab, &title); run;
 
%let title=Citrulline by Treatment;
%mixed(glnd,treatment,citrulline,&ylab, &title); run;

%let title=Citrulline by Apache II Score at Randomization;
%mixed(glnd,apache_2,citrulline,&ylab, &title); run;


%let title=Citrulline by SOFA Score at Randomization;
%mixed(glnd,sofa,citrulline,&ylab, &title); run;

/*
filename output 'citrulline.eps';
*/
goptions reset=all NOBORDER rotate=portrait device=pslepsfc /*gsfname=output*/ gsfmode=replace ;

	ods pdf file = "citrulline_baseline_glutamine.pdf";
 		proc greplay igout = wbh.graphs tc=sashelp.templt template=v2 nofs ; * L2R2s;
            list igout;
			treplay 1:1 2:3;
			treplay 1:5 2:7;
		run;
	ods pdf close;
