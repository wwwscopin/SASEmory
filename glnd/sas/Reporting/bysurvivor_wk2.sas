
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
   	merge glnd_ext.cytokines(drop=day) glnd.george (keep = id treatment); by id;
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	rename visit=day;
run;

proc format;
    value src 1="Lab" 2="Accucheck";
run;

data all_glucose;
    set glnd.followup_all_long(keep=id day gluc_eve eve_gluc_src rename=(gluc_eve=gluc_all eve_gluc_src=src))
        glnd.followup_all_long(keep=id day gluc_mrn mrn_gluc_src rename=(gluc_mrn=gluc_all mrn_gluc_src=src))
        glnd.followup_all_long(keep=id day gluc_aft aft_gluc_src rename=(gluc_aft=gluc_all aft_gluc_src=src));
run;

proc sort; by id day; run;

data all_glucose;
    merge all_glucose glnd.george (keep = id treatment); by id;
    format src src.;
run;


proc sort data=all_glucose out=all_glucose_id nodupkey; by id; run;

data center_glucose;
    merge glnd_ext.chemistries glnd.george (keep = id treatment); by id;
    if glucose>600 then delete;
    if glucose=. then delete;
run;

proc sort data=center_glucose out=center_glucose_id nodupkey; by id; run;

data glucose_local;
    merge all_glucose(in=loc) center_glucose_id(in=cent keep=id); by id;
    if loc and cent;
    rename gluc_all=glu_local;    
run;

data glucose_center;
    merge all_glucose_id(in=loc keep=id) center_glucose(in=cent); by id;
    if loc and cent;    
    rename glucose=glu_center;
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


data flag_lps;
	merge glnd_ext.flag_lps(drop=day) glnd.george(keep=id treatment); by id;
	rename visit=day;
run;

proc format; 
    value trt 1="AG-PN" 2="STD-PN";
run;

/*
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
*/

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

%if &var=sofa_tot %then %do; %let scaley=(0 to 15 by 1); %let scalex=(0 to 29 by 1); %let y1 = 0; %let y2= 0; %end;
%if &var=glutamicacid %then %do; %let scaley=(0 to 180 by 20); %let scalex=(-1 to 29 by 1); %let y1 = 10; %let y2= 131; %end;
%if &var=glutamine %then %do; %let scaley=(200 to 800 by 50); %let scalex=(-1 to 29 by 1); %let y1 = 205; %let y2= 756; %end;
%if &var #gluc_all glu_local %then %do; %let scaley=(60 to 200 by 10); %let scalex=(0 to 29 by 1); %let y1 = 80; %let y2= 130; %end;
%if &var #glucose glu_center  %then %do; %let scaley=(60 to 200 by 10); %let scalex=(-1 to 29 by 1); %let y1 = 80; %let y2= 130;%end;

%if &var=hsp70_ng %then %do; %let scaley=(0 to 120 by 10); %let scalex=(-1 to 29 by 1); %let y1 = 0; %let y2= 2; %end;
%if &var=hsp27_ng %then %do; %let scaley=(0 to 2 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = 0; %let y2= 2; %end;

%if &var=GSH_GSSG_redox %then %do; %let scaley=(-160 to -80 by 5); %let scalex=(-1 to 29 by 1); %let y1 = -155; %let y2= -121; %end;
%if &var=Cys_CySS_redox %then %do; %let scaley=(-100 to -50 by 5); %let scalex=(-1 to 29 by 1); %let y1 = -98; %let y2= -62; %end;
%if &var=log_gsh_conc %then %do; %let scaley=(0 to 3 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = 0.9; %let y2= 2.9; %end;
%if &var=log_gssg_conc %then %do; %let scaley=(0 to 0.6 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = 0.01; %let y2= 0.1; %end;
%if &var=Cys_concentration %then %do; %let scaley=(0 to 50 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 4; %let y2= 16; %end;
%if &var=CysSS_concentration %then %do; %let scaley=(20 to 150 by 10); %let scalex=(-1 to 29 by 1); %let y1 =30; %let y2= 85; %end;

%if &var=log_il6 %then %do; %let scaley=(0 to 300 by 20); %let scalex=(-1 to 29 by 1); %let y1 = 0.447; %let y2= 9.96;  %end;
%if &var=log_il8 %then %do; %let scaley=(0 to 100 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 3.23; %let y2= 24.5;  %end;
%if &var=log_ifn %then %do; %let scaley=(0 to 180 by 10); %let scalex=(-1 to 29 by 1);  %let y1 = 0.25; %let y2= 15.6;  %end;
%if &var=log_tnf %then %do; %let scaley=(0 to 20 by 2); %let scalex=(-1 to 29 by 1); %let y1 =0.25; %let y2= 4.71;  %end;

%if &var=anti_flag_IgG %then %do; %let scaley=(0 to 1.5 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = .07; %let y2= 1; %end;
%if &var=anti_flag_IgA %then %do; %let scaley=(0 to 3.2 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = .04; %let y2= .9; %end;

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
    
    %if &var # sofa_tot hsp27_ng log_gsh_conc log_gssg_conc anti_flag_IgG anti_flag_IgA %then %do;
        diff=compress(put(estimate,7.2))||"["||compress(put(lower,7.2))||" - "||compress(put(upper,7.2))||"]";	
    %end;
	%else %do;
         diff=compress(put(estimate,5.0))||"["||compress(put(lower,5.0))||" - "||compress(put(upper,5.0))||"]";	
    %end;
    
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
	day1=day+0.20;
	
	%if &var # log_gsh_conc log_gssg_conc log_il6 log_il8 log_ifn log_tnf
	   %then %do;
	       estimate=exp(estimate);
	       lower=exp(lower);
	       upper=exp(upper);
	   %end;
	%if &var # sofa_tot gluc_all glu_local
        %then %do; where day in(1,4,7,14,21,28); %end;
        	%else %do; where day in(0,3,7,14,21,28); %end;
    %if &var # sofa_tot Cys_concentration glutamicacid %then %do;  if lower<0 then lower=0; %end;
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
	%if &var # sofa_tot hsp27_ng log_gsh_conc log_gssg_conc anti_flag_IgG anti_flag_IgA log_tnf %then %do;
    	est1=put(estimate1,7.2)||"["||compress(put(lower1,7.2))||" - "||compress(put(upper1,7.2))||"], "||compress(n1);
	    est2=put(estimate2,7.2)||"["||compress(put(lower2,7.2))||" - "||compress(put(upper2,7.2))||"], "||compress(n2);
	%end;
	%else %do;
        est1=put(estimate1,5.0)||"["||compress(put(lower1,5.0))||" - "||compress(put(upper1,5.0))||"], "||compress(n1);
	    est2=put(estimate2,5.0)||"["||compress(put(lower2,5.0))||" - "||compress(put(upper2,5.0))||"], "||compress(n2);	
	%end;
run;

data test_&var;
    set estimate;
    %if &var # sofa_tot gluc_all glu_local
        %then %do; where day in(1,4,7,14,21,28); %end;
        	%else %do; where day in(0,3,7,14,21,28); %end;
    keep day est1 est2 diff pv;
run;

data est_&var;
    retain day n1 estimate1 lower1 upper1 error1 n2 estimate2 lower2 upper2 error2;
    set estimate;
    %if &var # sofa_tot gluc_all glu_local
        %then %do; where day in(1,4,7,14,21,28); %end;
        	%else %do; where day in(0,3,7,14,21,28); %end;
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



goptions reset=all device=pslepsfc gunit=pct noborder cback=white colors = (black red) hby = 3 htitle=1 htext=1;

symbol1 i=j  value=dot ci=red co=red cv=red h=1.75 ;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=1.75;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(5,2) label=NONE 
value = (h=1.25 "Survivor" "Non-Survivor") offset=(-0.2in, -0.2 in) frame;

%if &data=std_glucose or &data=ag_glucose %then %do; 
legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(5,2) label=NONE 
value = (h=2 "Lab" "Accucheck") offset=(-0.2in, -0.2 in) frame;
%end;

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
	
	%if &var # sofa_tot gluc_all glu_local  %then %do; format day dd.; %end;
		  %else %do; format day dt.; %end;
    format estimate1-estimate2 4.0;
	%if &var # log_gssg_conc hsp27_ng log_gsh_conc anti_flag_IgG anti_flag_IgA 
	%then %do; format estimate1 estimate2 4.1; %end;
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
 
%let ylab="Heat-shock Protein 70 (ng/mL)";
%let title=Heat-shock Protein 70;
%mixed(hsp,hsp70_ng,hospital_death,&ylab, &title); run; 

%let ylab="Heat-shock Protein 27 (ng/mL)";
%let title=Heat-shock Protein 27 ;
%mixed(hsp,hsp27_ng,hospital_death,&ylab, &title); run; 


** For redox;
%let ylab="GSH/GSSG Redox (mV)";
%let title=GSH/GSSG Redox;
%mixed(redox,GSH_GSSG_redox,hospital_death,&ylab, &title); run; 

%let ylab="Cys/CySS Redox (mV)";
%let title=Cys/CySS Redox ;
%mixed(redox,Cys_CySS_redox,hospital_death,&ylab, &title); run; 

%let ylab="GSH Concentration(" f=greek 'm' f=fixed "M)";
%let title=GSH Concentration;
%mixed(redox,log_gsh_conc,hospital_death,&ylab, &title); run; 

%let ylab="GSSG Concentration (" f=greek 'm' f=fixed "M)";
%let title=GSSG Concentration;
%mixed(redox,log_gssg_conc,hospital_death,&ylab, &title); run; 

%let ylab="Cys Concentration (" f=greek 'm' f=fixed "M)";
%let title=Cys Concentration ;
%mixed(redox,Cys_concentration,hospital_death,&ylab, &title); run; 

%let ylab="CysSS Concentration (" f=greek 'm' f=fixed "M)";
%let title=CysSS Concentration ;
%mixed(redox,CysSS_concentration,hospital_death,&ylab, &title); run; 

* Cytokines;

%let ylab="IL-6 Concentration (pg/ml)";
%let title=IL-6 Concentration (pg/ml) ;
%mixed(cyto,log_il6,hospital_death,&ylab, &title); run; 

%let ylab="IL-8 Concentration (pg/ml)";
%let title=IL-8 Concentration (pg/ml) ;
%mixed(cyto,log_il8,hospital_death,&ylab, &title); run; 

%let ylab="IFN-g Concentration (pg/ml)";
%let title=IFN-g Concentration;
%mixed(cyto,log_ifn,hospital_death,&ylab, &title); run; 

%let ylab="IFN-a Concentration (pg/ml)";
%let title=TNF-a Concentration;
%mixed(cyto,log_tnf,hospital_death,&ylab, &title); run; 


%let ylab="a-Flagellin IgG (O.D.)";
%let title=a-Flagellin IgG (O.D.) ;
%mixed(flag_lps,anti_flag_IgG,hospital_death,&ylab, &title); run; 

%let ylab= "a-Flagellin IgA (O.D.)";
%let title="a-Flagellin IgA (O.D.)" ;
%mixed(flag_lps,anti_flag_IgA,hospital_death,&ylab, &title); run; 


%let ylab="SOFA Total Score";
%let title=SOFA Total Score ;
%mixed(sofa,sofa_tot,hospital_death,&ylab, &title); run;


%let ylab="Glutamic Acid (" f=greek 'm' f=fixed "M)";
%let title=Glutamic Acid ;
%mixed(glutamine_full,glutamicacid,hospital_death,&ylab, &title); run;


%let ylab="Glutamine (" f=greek "m" f=fixed "M)";
%let title=Glutamine ;
%mixed(glutamine_full,glutamine,hospital_death,&ylab, &title); run;


%let ylab="Blood Glucose (mg/dL)";
%let title=Blood Glucose(Local Lab. 7592 obs) ;
%mixed(all_glucose,gluc_all,hospital_death,&ylab, &title); run;

%let ylab="Blood Glucose (mg/dL)";
%let title=Blood Glucose(Central Lab, 419 obs) ;
%mixed(center_glucose,glucose,hospital_death,&ylab, &title); run;

%let ylab="Blood Glucose (mg/dL)";
%let title=Blood Glucose(Local Lab for Matched Only, 4822 obs) ;
%mixed(glucose_local,glu_local,hospital_death,&ylab, &title); run;

%let ylab="Blood Glucose (mg/dL)";
%let title=Blood Glucose(Central Lab for Matched Only, 419 obs) ;
%mixed(glucose_center,glu_center,hospital_death,&ylab, &title); run;




	ods pdf file = "glnd_survivor_wk2.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1  2:3;
			treplay 1:5  2:7;
			treplay 1:9  2:11;
			treplay 1:13 2:15;
			treplay 1:17 2:19;
			treplay 1:21 2:23;
			treplay 1:25 2:27;
			treplay 1:29 2:31;			
			treplay 1:31 2:33;
			treplay 1:35 2:37;
			treplay 1:39 2:41;
		run;
	ods pdf close;

ods tagsets.excelxp file="glnd_graph_survivor_wk2.xls";
ods tagsets.excelxp
options(sheet_name="SOFA");
proc print data=est_sofa_tot noobs label split="*";Run;

ods tagsets.excelxp
options(sheet_name="Glutamic Acid");
proc print data=est_glutamicacid noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Glutamine");
proc print data=est_glutamine noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="Blood Glucose(Local Lab)");
proc print data=est_gluc_all noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Blood Glucose(Central Lab)");
proc print data=est_glucose noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="Blood Glucose(Local Lab for Matched Only)");
proc print data=est_glu_local noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Blood Glucose(Central Lab for Matched Only)");
proc print data=est_glu_center noobs label split="*";run;


ods tagsets.excelxp
options(sheet_name="HSP70");
proc print data=est_hsp70_ng noobs label split="*";Run;
ods tagsets.excelxp
options(sheet_name="HSP27");
proc print data=est_hsp27_ng noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="GSH/GSSG redox");
proc print data=est_GSH_GSSG_redox noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Cys/CySS redox");
proc print data=est_Cys_CySS_redox noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="GSH concentration");
proc print data=est_log_gsh_conc noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="GSSG concentration");
proc print data=est_log_gssg_conc noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Cys concentration");
proc print data=est_Cys_concentration noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="CysSS concentration");
proc print data=est_CysSS_concentration noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="Cytokines IL-6");
proc print data=est_log_il6 noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Cytokines IL-8");
proc print data=est_log_il8 noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Cytokines IFN");
proc print data=est_log_ifn noobs label split="*";run;
ods tagsets.excelxp
options(sheet_name="Cytokines TNF");
proc print data=est_log_tnf noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_flag_IgG");
proc print data=est_anti_flag_IgG noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="anti_flag_IgA");
proc print data=est_anti_flag_IgA noobs label split="*";run;

ods tagsets.excelxp close;




	ods  rtf  file="GLND Data by Survivor_wk2.rtf" style=journal bodytitle startpage=never;
	
	proc report data=test_sofa_tot nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of SOFA by Vital Status and Days on Study";
    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_glutamine nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Glutamine (&mu.M) by Treatment and Days on Study";
     	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;

	proc report data=test_glutamicacid nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Glutamic Acid (&mu.M) by Vital Status and Days on Study";
    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_gluc_all nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Blood Glucose (mg/dL) (Local Lab) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_glucose  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Blood Glucose (mg/dL)(Central Lab) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_glu_local nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Blood Glucose (mg/dL)(Local Lab for Matched Only) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
      	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_glu_center  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Blood Glucose(mg/dL)(Central Lab for Matched Only) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
      	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_hsp70_ng  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of HSP-70(ng/dL) by Vital Status and Days on Study";
       	column day est1 est2 diff pv;
       	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_hsp27_ng  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of HSP-27(ng/dL) by Vital Status and Days on Study";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	

	proc report data=test_GSH_GSSG_redox   nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of GSH/GSSG Redox (mV) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_Cys_CySS_redox  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cys/CySS Redox (mV) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_gsh_conc  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of GSH Concentration (&mu.M) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_gssg_conc  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of GSSG concentration (&mu.M) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_Cys_concentration   nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cys Concentration (&mu.M) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_CysSS_concentration  nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of CysSS Concentration (&mu.M)  by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_il6 nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cytokines IL-6 (pg/mL) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_il8 nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cytokines IL-8 (pg/mL) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_ifn nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cytokines IFN (pg/mL) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_tnf nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of Cytokines TNF (pg/mL) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_anti_flag_IgG nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of alpha-Flagellin IgG (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_anti_flag_IgA nowindows split="*" style(column)=[just=center];
	    title "Model Based Estimate of alpha-Flagellin IgA (O.D.) by Vital Status and Days on Study";
    	    	*column day est1 est2 diff pv;
    	column day est1 est2;
    	define day/"Day";
    	define est1/"Survivor*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Non-Survivor*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
				
	ods rtf close;

	
	
