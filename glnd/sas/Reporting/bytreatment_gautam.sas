
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;


data sofa;
	merge 	glnd.followup_all_long
			glnd.george (keep = id treatment)
			;
	by id;
	glu_mrn=gluc_mrn*0.0555;
run;

data glutamine_full;
	set glnd_ext.glutamine(drop=day);

	keep id GlutamicAcid Glutamine visit;
	rename visit=day;
run;


proc sort data=glutamine_full; by id; run;
proc sort data= glnd.george; by id; run;

data glutamine_full;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
	        glnd.status (keep = id deceased dt_death dt_discharge)
	        glnd.plate6b(keep=id apache_total)
	        glnd.basedemo(keep=id age gender)
			;
	by id;

	if ~has_glutamine then delete;
run;

data all_glucose;
    set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=gluc_all eve_gluc_src=all_gluc_src))
        glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=gluc_all mrn_gluc_src=all_gluc_src))
        glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=gluc_all aft_gluc_src=all_gluc_src));
    glu_all=gluc_all*0.0555;
run;

proc sort; by id day; run;

data all_glucose;
    merge all_glucose glnd.george (keep = id treatment); by id;
run;

/*to get the freq of data points*/
/* 
data glutamine;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
			;
	by id;
run;

proc sort; by id day;run;



proc format; 
    value trt 1="AG-PN" 2="STD-PN";
run;

proc transpose data=glutamine out=temp; by id;
var day glutamine;
run;

data temp;
    set temp(where=(_name_="Glutamine"));
    num=n(of COL1-COL6);
run;
proc freq data=temp;
tables num;
run;
*/

%macro getn(data);
%do j = 0 %to 28;
data _null_;
    set &data;
    where day = &j;
    if treatment=1 then call symput( "m&j",  compress(put(num_obs, 3.0)));
	if treatment=2 then call symput( "n&j",  compress(put(num_obs, 3.0)));
run;
%end;
%mend;

%let p1=0;
%let p2=0;
%let p3=0;

%macro mixed(data, var, trt, ylab, title)/minoperator;

	data tmp; set &data;	run;
	proc sort nodupkey; by id day; run;
	proc sort data=tmp nodupkey out=nday; by &trt day id;run;
	proc means data=nday ;
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

%getn(num_&var);

proc format;


value dd -1=" " 0 = " "  1="1*(&m1)*(&n1)"  2 = " " 3=" " 4 = "4*(&m4)*(&n4)" 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";
		
value dt -1=" " 0 = "0*(&m0)*(&n0)"  1=" "  2 = " " 3="3*(&m3)*(&n3)" 4 = " " 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";

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
    diff=put(estimate,4.0)||"("||put(lower,4.0)||", "||put(upper,4.0)||")";
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
	if lower^=. and lower<0 then lower=0;
	day1=day+0.20;
	%if &var=glutamicacid or &var=glutamine %then %do; where day in(0,3,7,14,21,28); %end;
	%else %do; where day in(1,4,7,14,21,28); %end;
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
	set lsmean(where=(&trt=2));
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
	lsmean(where=(&trt=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) 
	num_&var(where=(&trt=1) keep=&trt day num_obs rename=(num_obs=n1))
	num_&var(where=(&trt=2) keep=&trt day num_obs rename=(num_obs=n2))
	diff
	; by day;
	if day=. then delete;
	est1=put(estimate1,4.0)||"("||put(lower1,4.0)||", "||put(upper1,4.0)||"), "||compress(n1);
	est2=put(estimate2,4.0)||"("||put(lower2,4.0)||", "||put(upper2,4.0)||"), "||compress(n2);
run;

data est_&var;
    set estimate;
run;

goptions reset=all gunit=pct noborder cback=white colors = (black red)  ftext=triplex  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "AG-PN" "STD-PN") offset=(-0.2in, -0.2 in) frame;

%if &var=sofa_tot %then %do; %let scaley=(0 to 10 by 1); %let scalex=(0 to 29 by 1); %end;
%if &var=glutamicacid %then %do; %let scaley=(0 to 240 by 20); %let scalex=(-1 to 29 by 1); %end;
%if &var=glutamine %then %do; %let scaley=(300 to 700 by 50); %let scalex=(-1 to 29 by 1); %end;
/*%if &var=gluc_mrn %then %do; %let scaley=(100 to 160 by 5); %let scalex=(0 to 29 by 1); %end;*/
%if &var # glu_mrn glu_all %then %do; %let scaley=(5 to 9 by 0.2); %let scalex=(0 to 29 by 1); %end;


axis1 	label=(h=3 "Days on Study" ) split="*"	value=(h=2.5)  order=&scalex minor=none offset=(0 in, 0 in);
axis2 	label=(h=3 a=90 &ylab) value=(h=2.5) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 
title1 	height=3.5 "&title";
title2 	height=2.5 "p(Treatment)=&p1, p(Days)=&p2, p(Treatment*Days)=&p3";


             
proc gplot data= estimate gout=glnd_rep.graphs;
	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=2.5 m=(2pct, 13 pct) "Day :" ;
	note h=2.5 m=(1pct, 10.5 pct) "(# AG-PN)" ;
	note h=2.5 m=(1pct, 8 pct) "(#STD-PN)" ;
	%if &var=glutamicacid or &var=glutamine %then %do; format day dt. estimate1 4.0; %end;
	%else %do; format day dd. estimate1 3.1; %end;
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
 
%let ylab="Morning Blood Glucose (mmol/L)";
%let title=Morning Blood Glucose by Treatment;
%mixed(sofa,glu_mrn,treatment,&ylab, &title); run;


%let ylab="Blood Glucose (mmol/L)";
%let title=Blood Glucose by Treatment;
%mixed(all_glucose,glu_all,treatment,&ylab, &title); run;


filename output 'blood_glucose_unit.eps';
goptions reset=all NOBORDER rotate=portrait device=pslepsfc gsfname=output gsfmode=replace ;

	ods pdf file = "blood_glucose_unit.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1 2:3;
		run;
	ods pdf close;
	
	/*
	ods  rtf  file="Glutamine.rtf" style=journal bodytitle startpage=never;
	proc report data=est_glutamine nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Glutamine by Treatment and Days";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"AG-PN*Mean(95%CI), N" style(column)=[width=1.5in];
    	define est2/"STD-PN*Mean(95%CI), N" style(column)=[width=1.5in];
    	define diff/"Difference*Mean(95%CI)" style(column)=[width=1.5in];
    	define pv/"p value";
	run;

	
	proc report data=est_glutamicacid nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Glutamic Acid by Treatment and Days";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"AG-PN*Mean(95%CI), N" style(column)=[width=1.5in];
    	define est2/"STD-PN*Mean(95%CI), N" style(column)=[width=1.5in];
       	define diff/"Difference*Mean(95%CI)" style(column)=[width=1.5in];
    	define pv/"p value";
	run;
	
	ods rtf close;
	*/
	
	
