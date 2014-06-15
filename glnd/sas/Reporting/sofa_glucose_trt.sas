
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
run;

data hsp;
	merge 	glnd_ext.hsp
			glnd.george (keep = id treatment)
			;
	by id;
run;

data redox;
	merge 	glnd_ext.redox
			glnd.george (keep = id treatment)
			;
	by id;
	where id ~= 32006;
	log_gsh_conc = log(gsh_concentration);
	log_gssg_conc = log(gssg_concentration);

    if Cys_concentration>200 then Cys_concentration=.;
   	rename visit=day;

	keep visit id treatment GSH_GSSG_redox Cys_CySS_redox log_gsh_conc log_gssg_conc Cys_concentration CysSS_concentration;
run;

data cyto;
   	merge glnd_ext.cytokines glnd.george (keep = id treatment); by id;
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	rename visit=day;
run;


data all_glucose;
    set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=gluc_all eve_gluc_src=all_gluc_src))
        glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=gluc_all mrn_gluc_src=all_gluc_src))
        glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=gluc_all aft_gluc_src=all_gluc_src));
run;

proc sort; by id day; run;

data all_glucose;
    merge all_glucose glnd.george (keep = id treatment); by id;
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


/*to get the freq of data points*/

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

proc print;
where id in(12473,12506,51071);
run;

data temp;
    set temp(where=(_name_="Glutamine"));
    num=n(of COL1-COL6);
run;

ods rtf file="glutamine_data.rtf" style=journal;
proc freq data=temp;
tables num;
run;
ods rtf close;


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

	data tmp; 
	   set &data;	
	   if &var=. then delete;
	   
     %if &var # sofa_tot gluc_mrn gluc_all
         %then %do; where day<=28; %end;
           	%else %do; where day<15; %end;

	run;
	
	proc means data=tmp noprint;
    	class &trt day;
    	var &var;
 		output out = m_&var n(&var) = m_obs;
	run;
		
	proc sort data=tmp nodupkey; by id day; run;
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


value dt 0 = " "  1="1*(&m1)*(&n1)"  2 = "2*(&m2)*(&n2) " 3="3*(&m3)*(&n3)" 4 = "4*(&m4)*(&n4) " 5="5*(&m5)*(&n5) " 6 = "6*(&m6)*(&n6) " 7="7*(&m7)*(&n7)" 
        8 = "8*(&m8)*(&n8) " 9="9*(&m9)*(&n9) " 10 = "10*(&m10)*(&n10) " 11="11*(&m11)*(&n11)" 12 = "12*(&m12)*(&n12) " 13="13*(&m13)*(&n13) " 	14 = "14*(&m14)*(&n14)" 
        15=" "  ;

value dd 0 = " "  1="1*(&m1)*(&n1)"  2 = "2*(&m2)*(&n2) " 3="3*(&m3)*(&n3)" 4 = "4*(&m4)*(&n4) " 5="5*(&m5)*(&n5) " 6 = "6*(&m6)*(&n6) " 7="7*(&m7)*(&n7)" 
        8 = "8*(&m8)*(&n8) " 9="9*(&m9)*(&n9) " 10 = "10*(&m10)*(&n10) " 11="11*(&m11)*(&n11)" 12 = "12*(&m12)*(&n12) " 13="13*(&m13)*(&n13) " 	14 = "14*(&m14)*(&n14)" 
        15=" 15*(&m15)*(&n15)"  16="16*(&m16)*(&n16) "  17 = "17*(&m17)*(&n17) " 18="18*(&m18)*(&n18) " 19= "19*(&m19)*(&n19) "   20="20*(&m20)*(&n20) " 
		21 = "21*(&m21)*(&n21)"    22="22*(&m22)*(&n22)" 24 = "24*(&m24)*(&n24) "  23 = "23*(&m23)*(&n23) " 25="25*(&m25)*(&n25) " 26 = "26*(&m26)*(&n26) " 27="27*(&m27)*(&n27)"  28="28*(&m28)*(&n28)" 29=" ";

value dayt 0 = " "  1="1*(&m1)*(&n1)"  2 = " " 3=" " 4 = "4*(&m4)*(&n4) " 5=" " 6 = " " 7="7*(&m7)*(&n7)" 
        8 = " " 9=" " 10 = "10*(&m10)*(&n10) " 11=" " 12 = " " 13="13*(&m13)*(&n13) " 	14 = " " 
        15=" "  16="16*(&m16)*(&n16) "  17 = " " 18=" " 19= "19*(&m19)*(&n19) "   20=" " 
		21 = " "    22="22*(&m22)*(&n22)" 24 = " "  23 = " " 25="25*(&m25)*(&n25) " 26 = " " 27=" "  28="28*(&m28)*(&n28)" 29=" ";
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
	*if lower^=. and lower<0 then lower=0;
	day1=day+0.20;
	%if &var # sofa_tot gluc_mrn 
        %then %do; where day <=28; %end;
        
   	/*%if &var # gluc_all
        %then %do; where day in(1,4,7,10, 13, 16, 19, 22, 25, 28); %end;*/
    %if &var # gluc_all
        %then %do; where day <=28; %end;
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
	m_&var(where=(&trt=1) keep=&trt day m_obs rename=(m_obs=m1))
	m_&var(where=(&trt=2) keep=&trt day m_obs rename=(m_obs=m2))
	diff;
	by day;
	if day=. then delete;
	est1=put(estimate1,4.0)||"("||put(lower1,4.0)||", "||put(upper1,4.0)||"), "||compress(n1);
	est2=put(estimate2,4.0)||"("||put(lower2,4.0)||", "||put(upper2,4.0)||"), "||compress(n2);
run;

data est_&var;
    retain day n1 m1 estimate1 error1 n2 m2 estimate2 error2;
    set estimate;

	error1=estimate1-lower1;
	error2=estimate2-lower2;
	
	format estimate1-estimate2 error1-error2 7.2;
	keep day n1 n2 m1 m2 estimate1-estimate2 error1-error2;
	label n1="n*(AG-PN)" n2="n*(STD-PN)" estimate1="Mean*(AG-PN)" estimate2="Mean*(STD-PN)" 
	   error1="Error*(AG-PN)" error2="Error*(STD-PN)" m1="nobs*(AG-PN)" m2="nobs*(STD-PN)";
	*where day in(1,4,7,10, 13, 16, 19, 22, 25, 28);
run;

goptions reset=all gunit=pct noborder cback=white colors = (black red)  ftext=triplex hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2.5 "AG-PN" "STD-PN") offset=(-0.2in, -0.2 in) frame;

%if &var=sofa_tot %then %do; %let scaley=(0 to 10 by 1); %let scalex=(0 to 29 by 1); %end;
%if &var=gluc_mrn %then %do; %let scaley=(100 to 160 by 5); %let scalex=(0 to 29 by 1); %end;
%if &var=gluc_all %then %do; %let scaley=(60 to 180 by 10); %let scalex=(0 1 to 28 by 3 29); %end;
%if &var # overall_kcal_per_kg pn_kcal_per_kg en_kcal_per_kg %then %do; %let scaley=(0 to 35 by 5); %let scalex=(0 to 15 by 1); %end;
%if &var # overall_aa_g_per_kg pn_aa_g_per_kg en_aa_g_per_kg %then %do; %let scaley=(0 to 2 by 0.2); %let scalex=(0 to 15 by 1); %end;

axis1 	label=(h=3 "Days on Study" ) split="*"	value=(h=2)  order=&scalex minor=none offset=(0 in, 0 in);
axis2 	label=(h=3 a=90 &ylab) value=(h=2.5) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 

title1 	height=3.5 &title;
title2 	height=2.5 "p(Treatment)=&p1, p(Days)=&p2, p(Treatment*Days)=&p3";

             
proc gplot data= estimate gout=glnd_rep.graphs;
	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;

	note h=2 m=(2pct, 12 pct) "Day :" ;
	note h=2 m=(1pct, 10 pct) "(# AG-PN)" ;
	note h=2 m=(1pct, 8 pct) "(#STD-PN)" ;
	%if &var # sofa_tot gluc_mrn gluc_all  %then %do; format day dayt.; %end;
		  %else %do; format day dt.; %end;
    format estimate1-estimate2 4.0;
	%if &var # overall_aa_g_per_kg pn_aa_g_per_kg en_aa_g_per_kg %then %do; format estimate1 estimate2 4.1; %end;
	
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
 
/*
%let ylab="SOFA Total Score";
%let title=SOFA Total Score by Treatment;
%mixed(sofa,sofa_tot,treatment,&ylab, &title); run;
*/

%let ylab="Blood Glucose (mg/dL)";
%let title=Blood Glucose by Treatment;
%mixed(all_glucose,gluc_all,treatment,&ylab, &title); run;

/*
%let ylab="Total Energy (kcal/kg/day)";
%let title=Total Energy by Treatment;
%mixed(glnd.kcal_pn,overall_kcal_per_kg,treatment,&ylab, &title); run;

%let ylab="Parenteral Energy (kcal/kg/day)";
%let title=Parenteral Energy by Treatment;
%mixed(glnd.kcal_pn,pn_kcal_per_kg,treatment,&ylab, &title); run;

%let ylab="Enteral Energy (kcal/kg/day)";
%let title=Enteral Energy by Treatment;
%mixed(glnd.kcal_pn,en_kcal_per_kg,treatment,&ylab, &title); run;

%let ylab="Total Protein/AA (g/kg/day)";
%let title=Total Protein/AA by Treatment;
%mixed(glnd.kcal_pn,overall_aa_g_per_kg,treatment,&ylab, &title); run;

%let ylab="Parenteral Protein/AA (g/kg/day)";
%let title=Parenteral Protein/AA by Treatment;
%mixed(glnd.kcal_pn,pn_aa_g_per_kg,treatment,&ylab, &title); run;

%let ylab="Enteral Protein/AA (g/kg/day)";
%let title=Enteral Protein/AA by Treatment;
%mixed(glnd.kcal_pn,en_aa_g_per_kg,treatment,&ylab, &title); run;
*/

options orientation=landscape;
	ods pdf file = "blood_glucose.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=whole  nofs ; * L2R2s;
            list igout;
			treplay 1:1;
		run;
	ods pdf close;
	
/*
	ods pdf file = "sofa_glucose_pn.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1   2:3;
			treplay 1:5   2:7;
			treplay 1:9   2:11;
			treplay 1:13  2:15;
		run;
	ods pdf close;
*/	
ods tagsets.excelxp file="glnd_blood_glucose.xls";
ods tagsets.excelxp
options(sheet_name="Blood Glucose");
proc print data=est_gluc_all noobs label split="*";Run;
/*
ods tagsets.excelxp
options(sheet_name="Total Kcal");
proc print data=est_overall_kcal_per_kg noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Parenteral Kcal");
proc print data=est_pn_kcal_per_kg noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Enteral Kcal");
proc print data=est_en_kcal_per_kg noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="Total Protein/AA");
proc print data=est_overall_aa_g_per_kg noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Parenteral Protein/AA");
proc print data=est_pn_aa_g_per_kg noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Enteral Protein/AA");
proc print data=est_en_aa_g_per_kg noobs label split="*";run;
*/
ods tagsets.excelxp close;
