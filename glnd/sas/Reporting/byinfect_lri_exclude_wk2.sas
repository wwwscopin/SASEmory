
options pagesize= 60 linesize = 85 center nodate nonumber orientation=portrait;

%let mu=%sysfunc(byte(181));

proc format;
    value yn 1="Yes" 0="No";
run;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;

data infect;
    set glnd.info (keep = id apache_2 ni_any ni_bsi ni_lri dt_any dt_bsi dt_lri);
    any=ifn(ni_any>0,1,0,0);
        bsi=ifn(ni_bsi>0,1,0,0);
            lri=ifn(ni_lri>0,1,0,0);
    keep id apache_2 any bsi lri dt_any dt_bsi dt_lri;
    format any bsi lri yn.;
run;

data infect;
    merge infect glnd.george; by id;
    mark=dt_lri-dt_random+1;
run;


data hsp;
	merge 	glnd_ext.hsp infect; by id;
	
	if bsi=. then bsi=0;
	if lri=. then lri=0;
	if any=. then any=0;
	if mark^=. then if day<mark;
run;

data redox;
	merge 	glnd_ext.redox infect;	by id;
	where id ~= 32006;
	log_gsh_conc = log(gsh_concentration);
	log_gssg_conc = log(gssg_concentration);

    if Cys_concentration>200 then Cys_concentration=.;
   	rename visit=day;
   	
   	if bsi=. then bsi=0;
	if lri=. then lri=0;
	if any=. then any=0;
    if mark^=. then if visit<mark;
	keep visit id treatment apache_2 any bsi lri
	 GSH_GSSG_redox Cys_CySS_redox log_gsh_conc log_gssg_conc Cys_concentration CysSS_concentration;
run;

data cyto;
   	merge glnd_ext.cytokines(drop=day) infect; by id;
	log_il6=log(il6);
	log_il8=log(il8);
	log_ifn=log(ifn);
	log_tnf=log(tnf); 
	
	if bsi=. then bsi=0;
	if lri=. then lri=0;
	if any=. then any=0;
    if mark^=. then if visit<mark;
	rename visit=day;
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
	   set &data;	
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


%if &var=sofa_tot %then %do; %let scaley=(0 to 10 by 1); %let scalex=(0 to 29 by 1); %let y1 = 0; %let y2= 0; %end;
%if &var=glutamicacid %then %do; %let scaley=(0 to 240 by 20); %let scalex=(-1 to 29 by 1); %let y1 = 10; %let y2= 131; %end;
%if &var=glutamine %then %do; %let scaley=(200 to 800 by 50); %let scalex=(-1 to 29 by 1); %let y1 = 205; %let y2= 756; %end;
%if &var #gluc_all glu_local %then %do; %let scaley=(100 to 170 by 5); %let scalex=(0 to 29 by 1); %let y1 = 80; %let y2= 130; %end;
%if &var #glucose glu_center  %then %do; %let scaley=(100 to 170 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 80; %let y2= 130;%end;

%if &var=hsp70_ng %then %do; %let scaley=(0 to 100 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 0; %let y2= 2; %end;
%if &var=hsp27_ng %then %do; %let scaley=(0 to 2 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = 0; %let y2= 2; %end;

%if &var=GSH_GSSG_redox %then %do; %let scaley=(-160 to -60 by 5); %let scalex=(-1 to 29 by 1); %let y1 = -155; %let y2= -121; %end;
%if &var=Cys_CySS_redox %then %do; %let scaley=(-100 to -60 by 5); %let scalex=(-1 to 29 by 1); %let y1 = -98; %let y2= -62; %end;
%if &var=log_gsh_conc %then %do; %let scaley=(0 to 3 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = 0.9; %let y2= 2.9; %end;
%if &var=log_gssg_conc %then %do; %let scaley=(0 to 1.2 by 0.1); %let scalex=(-1 to 29 by 1); %let y1 = 0.01; %let y2= 0.1; %end;
%if &var=Cys_concentration %then %do; %let scaley=(0 to 40 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 4; %let y2= 16; %end;
%if &var=CysSS_concentration %then %do; %let scaley=(30 to 130 by 10); %let scalex=(-1 to 29 by 1); %let y1 =30; %let y2= 85; %end;

%if &var=log_il6 %then %do; %let scaley=(0 to 250 by 10); %let scalex=(-1 to 29 by 1); %let y1 = 0.447; %let y2= 9.96;  %end;
%if &var=log_il8 %then %do; %let scaley=(0 to 80 by 5); %let scalex=(-1 to 29 by 1); %let y1 = 3.23; %let y2= 24.5;  %end;
%if &var=log_ifn %then %do; %let scaley=(0 to 80 by 5); %let scalex=(-1 to 29 by 1);  %let y1 = 0.25; %let y2= 15.6;  %end;
%if &var=log_tnf %then %do; %let scaley=(0 to 12 by 1); %let scalex=(-1 to 29 by 1); %let y1 =0.25; %let y2= 4.71;  %end;

%if &var=anti_flag_IgG %then %do; %let scaley=(0 to 1.2 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = .07; %let y2= 1; %end;
%if &var=anti_flag_IgA %then %do; %let scaley=(0 to 3 by 0.2); %let scalex=(-1 to 29 by 1); %let y1 = .04; %let y2= .9; %end;

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

/*
    xsys='2'; ysys='2';
	  	    %if &var # sofa_tot gluc_all glu_local %then %do;
				function = 'move'; x = 0; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0;  output;
			%end;

			%else %do;
				function = 'move'; x = -1; y = &y1; output;
				function = 'BAR'; x = 29; y = &y2; color = 'ltgray'; style = 'solid'; line= 0; output;
		    %end;
*/

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
	
	label n1="n*(No)" n2="n*(Yes)" estimate1="Mean*(No)" estimate2="Mean*(Yes)" 
	   error1="Error*(No)" error2="Error*(Yes)" lower1="Lower*(No)" lower2="Lower*(Yes)"
	   upper1="Upper*(No)" upper2="Upper*(Yes)";
run;



goptions reset=all device=pslepsfc gunit=pct noborder cback=white colors = (black red) htitle=4 htext=2;

symbol1 i=j  value=dot ci=red co=red cv=red h=1.75 ;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=1.75;

legend across = 1 position=(top right inside) mode = share fwidth =.2	shape = symbol(5,2) label=NONE 
value = (h=1.25 "LRI=No" "LRI=Yes") offset=(-0.2in, -0.2 in) frame;

axis1 	label=(h=2.5 "Days on Study" ) split="*"	value=(h=1.5)  order=&scalex minor=none offset=(0 in, 0 in);
axis2 	label=(h=2.5 a=90 &ylab) value=(h=1.75) order=&scaley offset=(.25 in, .25 in) minor=(number=1); 
title1 	h=4 Means and 95%CI by Infection and Days on Study;
%if &var # log_gsh_conc log_gssg_conc log_il6 log_il8 log_ifn log_tnf
	 %then %do;
        title1 	h=4 Geometric Means and 95%CI by LRI and Days on Study;
     %end;
title2 h=4 for &title;
title3 	height=4 "p(LRI)=&p1, p(Days)=&p2, p(LRI*Days)=&p3";

             
proc gplot data= estimate gout=glnd_rep.graphs;
    %if &var # sofa_tot gluc_all glu_local glucose glu_center %then %do;
    	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
    %end;
    %else %do;
    	plot estimate1*day estimate2*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend vref=&y1 &y2;
    %end;
	note h=1.75 m=(2pct, 9 pct) "Day :" ;

	note h=1.75 m=(1pct, 7 pct) "(#LRI=No)" ;
	note h=1.75 m=(1pct, 5 pct) "(#LRI=Yes)" ;
	
	%if &var # sofa_tot gluc_all glu_local  %then %do; format day dd.; %end;
		  %else %do; format day dt.; %end;
    format estimate1-estimate2 4.0;
	%if &var # hsp27_ng log_gsh_conc anti_flag_IgG anti_flag_IgA 
	%then %do; format estimate1 estimate2 4.1; %end;
	%if &var # log_gssg_conc 
	%then %do; format estimate1 estimate2 5.2; %end;	
run;
%mend mixed;

proc greplay igout= glnd_rep.graphs nofs; delete _ALL_; run;
 
%let ylab="Heat-shock Protein 70 (ng/mL)";
%let title=Heat-shock Protein 70;
%mixed(hsp,hsp70_ng,lri,&ylab, &title); run; 

** For redox;
%let ylab="GSH/GSSG Redox (mV)";
%let title=GSH/GSSG Redox;
%mixed(redox,GSH_GSSG_redox,lri,&ylab, &title); run; 

%let ylab="GSSG Concentration (" f=greek 'm' f=fixed "M)";
%let title=GSSG Concentration;
%mixed(redox,log_gssg_conc,lri,&ylab, &title); run; 

* Cytokines;

%let ylab="IL-6 Concentration (pg/ml)";
%let title=IL-6 Concentration (pg/ml) ;
%mixed(cyto,log_il6,lri,&ylab, &title); run; 


	ods pdf file = "glnd_infec_lri_exclude_wk2.pdf";
 		proc greplay igout = glnd_rep.graphs tc=sashelp.templt template=v2s  nofs ; * L2R2s;
            list igout;
			treplay 1:1  2:3;
			treplay 1:5  2:7;
			treplay 1:9  2:11;
			treplay 1:13 2:15;
			treplay 1:17 2:19;
		run;
	ods pdf close;
	

ods tagsets.excelxp file="glnd_infect_lri_exclude_wk2.xls";

ods tagsets.excelxp
options(sheet_name="HSP70");
proc print data=est_hsp70_ng noobs label split="*";Run;

ods tagsets.excelxp
options(sheet_name="GSH/GSSG redox");
proc print data=est_GSH_GSSG_redox noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="GSSG concentration");
proc print data=est_log_gssg_conc noobs label split="*";run;

ods tagsets.excelxp
options(sheet_name="Cytokines IL-6");
proc print data=est_log_il6 noobs label split="*";run;
ods tagsets.excelxp close;



	ods  rtf  file="GLND_lri_exclude_wk2.rtf" style=journal bodytitle startpage=never;

	proc report data=test_hsp70_ng  nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for HSP-70(ng/dL) by LRI and Days on Study";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"No*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Yes*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	

	proc report data=test_GSH_GSSG_redox   nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for GSH/GSSG Redox (mV) by LRI and Days on Study";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"No*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Yes*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	proc report data=test_log_gssg_conc  nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for GSSG Concentration (&mu.M) by LRI and Days on Study";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"No*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Yes-PN*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
	
	proc report data=test_log_il6 nowindows split="*" style(column)=[just=center];
	    title "Model-based Means and 95% CIs for Cytokines IL-6 (pg/mL) by LRI and Days on Study";
    	column day est1 est2 diff pv;
    	define day/"Day";
    	define est1/"No*Mean[95%CI], N" style(column)=[width=2in];
    	define est2/"Yes*Mean[95%CI], N" style(column)=[width=2in];
       	define diff/"Difference*Mean[95%CI]" style(column)=[width=2in];
    	define pv/"p value";
	run;
	
ods rtf close;

	
	
