
options orientation=portrait minoperator center nodate nonumber;

%let mu=%sysfunc(byte(181));

proc sort data= glnd.george; by id; run;
proc sort data= glnd.followup_all_long; by id; run;

data sofa;
	merge 	glnd.followup_all_long
			glnd.george (keep = id treatment)
			;
	by id;
run;


data glutamine_full;
	set glnd_ext.glutamine;

	keep id GlutamicAcid Glutamine visit total_glutamine visit2 diff;
	rename visit=day;
run;


proc sort data=glutamine_full; by id; run;
proc sort data= glnd.george; by id; run;

 data glutamine_full;
	merge 	glutamine_full (in = has_glutamine)
			glnd.george (keep = id treatment)
			;
	by id;

	if ~has_glutamine then delete; 
run;


data cyto;
   	merge glnd_ext.cytokines(drop=day) glnd.george (keep = id treatment); by id;
 	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 

	if ifn=0 then group_ifn=1; else group_ifn=0;
	if tnf=0 then group_tnf=1; else group_tnf=0;
	rename visit=day;
run;

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


%macro mixed(data, var, trt, ylab, title)/mindelimiter=',';

	data tmp; set &data;	run;
	proc sort nodupkey; by id day; run;
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

%getn(num_&var);

proc format;


value dd -1=" " 0 = " "  1="1*(&m1)*(&n1)"  2 = " " 3=" " 4 = "4*(&m4)*(&n4)" 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";
		
value dt -1=" " 0 = "0*(&m0)*(&n0)"  1=" "  2 = " " 3="3*(&m3)*(&n3)" 4 = " " 5=" " 6 = " " 7="7*(&m7)*(&n7)" 8 = " " 9=" " 
		10 = " " 11=" " 12 = " " 13=" " 	14 = "14*(&m14)*(&n14)" 15=" "  16=" "  17 = " " 18=" " 19= " "   20=" " 
		21 = "21*(&m21)*(&n21)"    22=" " 23 = " "  24 = " " 25=" " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";

run;


	proc mixed data =tmp empirical covtest;
	class &trt id day ; 	
	model &var=&trt day &trt*day/ solution ; 
	repeated day / subject = id type = cs;
	lsmeans &trt*day/cl;
	
	ods output lsmeans = lsmean0;
	ods output Mixed.Tests3=p_&var;
run;


data lsmean;
	set lsmean0;
	if lower^=. and lower<0 then lower=0;
	day1=day+0.20;
	%if &var in sofa_tot, gluc_mrn %then %do; where day in(1,4,7,14,21,28); %end;
	%else %do; where day in(0,3,7,14,21,28); %end;
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
	lsmean(where=(&trt=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) ; by day;
run;

goptions reset=all gunit=pct noborder cback=white colors = (black red)  ftext=zapf  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "AG-PN" "STD-PN") offset=(-0.2in, -0.2 in) frame;

%if &var=sofa_tot %then %do; %let scaley=(0 to 10 by 1); %let scalex=(0 to 29 by 1); %end;
%if &var=total_glutamine %then %do; %let scaley=(200 to 800 by 50); %let scalex=(-1 to 29 by 1); %end;
%if &var=glutamine %then %do; %let scaley=(200 to 600 by 50); %let scalex=(-1 to 29 by 1); %end;
%if &var=gluc_mrn %then %do; %let scaley=(100 to 160 by 5); %let scalex=(0 to 29 by 1); %end;

%if &var=log_il6 %then %do; %let scaley=(3 to 6 by 0.5); %let scalex=(-1 to 29 by 1); %end;
%if &var=log_il8 %then %do; %let scaley=(3 to 6 by 0.5); %let scalex=(-1 to 29 by 1); %end;
%if &var=log_ifn %then %do; %let scaley=(0 to 5 by 0.5); %let scalex=(-1 to 29 by 1); %end;
%if &var=log_tnf %then %do; %let scaley=(0 to 5 by 0.5); %let scalex=(-1 to 29 by 1); %end;


axis1 	label=(h=3 "Days on Study" ) split="*"	value=(h=2.5)  order=&scalex minor=none offset=(0 in, 0 in);
axis2 	label=(h=3 a=90 &ylab) value=(h=2.5) order=&scaley offset=(0in, 0 in) minor=(number=1); 
title 	height=3.5 &title;


             
proc gplot data= estimate gout=glnd_rep.graphs;
	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=2.5 m=(2pct, 15 pct) "Day :" ;
	note h=2.5 m=(1pct, 12 pct) "(# AG-PN)" ;
	note h=2.5 m=(1pct, 9 pct) "(#STD-PN)" ;
	%if &var in sofa_tot, gluc_mrn %then %do; format day dd. estimate1 3.0; %end;
	%else %if &var in log_il6, log_il8, log_ifn, log_tnf %then %do; format day dt. estimate1 4.1; %end;
	%else %do; format day dt. estimate1 4.0; %end;
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
 
/*
%let ylab="SOFA Total Score";
%let title=SOFA Total Score by Treatment;
%mixed(sofa,sofa_tot,treatment,&ylab, &title); run;


%let ylab="Glutamic Acid (" f=greek 'm' f=centb "M)";
%let title=Glutamic Acid by Treatment;
%mixed(glutamine_full,GlutamicAcid,treatment,&ylab, &title); run;


%let ylab="Glutamine (" f=greek "m" f=centb "M)";
%let title=Glutamine by Treatment;
%mixed(glutamine_full,glutamine,treatment,&ylab, &title); run;

%let ylab="Morning Blood Glucose (mg/dL)";
%let title=Morning Blood Glucose by Treatment;
%mixed(sofa,gluc_mrn,treatment,&ylab, &title); run;


filename output 'sofa_glu_ppt.eps';
goptions reset=all NOBORDER rotate=portrait device=pslepsfc gsfname=output gsfmode=replace ;

	ods ps file = "sofa_paper.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v3s  nofs ; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot2 3:gplot4;
		run;
	ods ps close;
*/


proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;

%let ylab="Ln[IL-6 Concentration(pg/mL)]";
%let title=Ln[IL-6 Concentration] by Treatment;
%mixed(cyto,log_il6,treatment,&ylab, &title); run;

%let ylab="Ln[IL-8 Concentration(pg/mL)]";
%let title=Ln[IL-8 Concentration] by Treatment;
%mixed(cyto,log_il8,treatment,&ylab, &title); run;


%let ylab=%str(f=zapf 'Ln[IFN' f=greek ' g ' f=zapf 'Concentration(pg/mL)]');
%let title=%str(f=zapf 'Ln[IFN' f=greek ' g ' f=zapf 'Concentration] by Treatment');
%mixed(cyto,log_ifn,treatment,&ylab, &title); run;

%let ylab=%str(f=zapf 'Ln[TNF' f=greek ' a ' f=zapf 'Concentration(pg/mL)]');
%let title=%str(f=zapf 'Ln[TNF' f=greek ' a ' f=zapf 'Concentration] by Treatment');
%mixed(cyto,log_tnf,treatment,&ylab, &title); run;


filename output 'cyto_trt.eps';
goptions reset=all NOBORDER rotate=landscape device=pslepsfc gsfname=output gsfmode=replace ;

	ods ps file = "cyto_trt.ps";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=l2r2s  nofs ; * L2R2s;
            list igout;
			treplay 1:gplot 2:gplot2 3:gplot4 4:gplot6;
		run;
	ods ps close;
