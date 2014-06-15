options nofmterr /*orientation=landscape*/ orientation=portrait nodate nonumber;
%let path=H:\SAS_Emory\Consulting\Brent1\;
libname brent "&path";

filename edmd "&path.EDMD.xls";
filename pnp "&path.PNP.xls";

proc format;
	value group
		1="Age"
		2="Fever"
		3="Head Injury"
		4="Respiratory";
	value site
		1="Egleston"
		2="Scottish Rite";
	value exit
		1="Home"
		2="Home Orders Pending"
		3="Admission"
		4="Intensive Care"
		5="Operating Room"
		6="Transfer";

	value role
		1="EDMD"
		2="MD"
		3="NOED"
		4="PNP";

	value Acuity
		3="3/Pink-2+resources"
		4="4/Gray";
	value yn
		0="No"
		1="Yes";

	value itemA
		1="Count of number of charges for abdominal x-ray"
		2="Count of number of labs done"
		3="Length of ED stay in minutes";
	value PP
		0="Pre" 1="Post";
	value gs
		0="PNP" 1="EDMD";
run;
proc sort data=brent.edmd; by pid;run;

data tmp_edmd; 
	merge brent.edmd brent.EDMD_Overall(in=A keep=pid); by pid;
	if A;
run;
proc sort data=brent.pnp; by pid;run;
data tmp_pnp; 
	merge brent.pnp brent.pnp_Overall(in=A keep=pid); by pid;
	if A;
run;

data PP;
	set tmp_edmd(in=A) tmp_pnp(in=B);
	if  B then gs=0; else gs=1;
	if  Visit_date>'1Sep2010'd then idx=1; else idx=0;
	mon=intck("month",'1Sep2010'd,visit_date);
	mon0=min(mon,0);
	mon1=max(mon,0);

	if Visit_date>'12Jul2011'd and md_to_exit_minutes>500 then md_to_exit_minutes=.;

	if A;

	format gs gs. idx  pp.;
	rename 	rad_ct_abd=rca rad_ct_head=rch rad_chest=rc rad_kub=rk rad_kub_chest=rkc iv_abx_present=iap iv_fluids_present=ifp iv_zofran_present=izp;
run;

proc sort data=pp nodupkey out=pp_id; by pid; run;

proc means data=pp_id noprint;
class gs;
output out=wbh n(pid)=n;
run;

data site1 site2;
	set pp; 
	rename attending_primary_location=site;
	if attending_primary_location=1 then output site1;
	if attending_primary_location=2 then output site2;
run;


%macro make_plots(data)/minoperator;

%let x= 1;

%do %while (&x <13);
    %if &x = 1  %then %do; %let var =los;       %let varname =md to exit (mins);  	 %let txt=Length of ED stay ;   %end;
    %if &x = 2  %then %do; %let var =return;    %let varname =revisit 72 hours (%);  %let txt=Return rate ; 		%end;
	%if &x = 3  %then %do; %let var =admission; %let varname =admitted to hospital;  %let txt=admitted to hospital; %end;
	%if &x = 4  %then %do; %let var =labs; 		%let varname =labs; 				 %let txt=Count of number of Labs; %end;
	%if &x = 5  %then %do; %let var =rca;  		%let varname =rad ct abd (%);  		 %let txt=Patient receive abd and/or pelvis CT; %end;
	%if &x = 6  %then %do; %let var =rch;  		%let varname =rad ct head;  		 %let txt=Count of number of charges for head CT; %end;
	%if &x = 7  %then %do; %let var =rc;   		%let varname =rad chest;  			 %let txt=Count of number of charges for chest X-ray; %end;
	%if &x = 8  %then %do; %let var =rk;   		%let varname =rad kub;  			 %let txt=Count of number of charges for abdominal x-ray; %end;
	%if &x = 9  %then %do; %let var =rkc;  		%let varname =rad kub chest; 		 %let txt=Count of number of charges for abdominal x-ray and chest x-ray; %end; 	
    %if &x = 10 %then %do; %let var =iap;  		%let varname =iv abx present (%);  	 %let txt=Charges for IV antibiotics exist; %end;
	%if &x = 11 %then %do; %let var =ifp;  		%let varname =iv fluids present (%); %let txt=Charges for IV fluids exist; %end;
	%if &x = 12 %then %do; %let var =izp;  		%let varname =iv zofran present (%); %let txt=Charges for IV zofran (ondansetron) exist.; %end;

data sub;
	set &data;
	%if &var=labs %then %do; where group in (1,2); %end;
	%if &var=rch  %then %do; where group in (3); %end;
	%if &var=rca  %then %do; where group in (1); %end;
	%if &var=rc   %then %do; where group in (4); %end;
	%if &var=rk   %then %do; where group in (1); %end;
	%if &var=rkc  %then %do; where group in (2); %end;
	%if &var=iap  %then %do; where group in (2); %end;
	%if &var=ifp  %then %do; where group in (1); %end;
	%if &var=izp  %then %do; where group in (1); %end;
run;

proc glimmix data=sub;
	class pid;

		%if &x=1 %then %do;
		model &var=mon0 mon1/s;
		random int mon0 mon1/type=un subject=pid;
		%end;
		%else %if %eval(&x in 2 3 5 10 11 12) %then %do;
		model  &var(event='Yes')=mon0 mon1/s dist=binary;
		random int/subject=pid;
		%end;
		%else %if &x=4  %then %do;
		model  &var=mon0 mon1/s dist=POISSON;
		%end;
		%else %if %eval(&x in 7 9) %then %do;
		model  &var=mon0 mon1/s dist=POISSON;
		random int/subject=pid;
		%end;

		%if (&x=6 or &x=8) and &data=site1 %then %do;
		model  &var=mon0 mon1/s dist=POISSON;
		%end;

		%if (&x=6 or &x=8) and &data=site2 %then %do;
		model  &var=mon0 mon1/s dist=POISSON;
		random int/subject=pid;
		%end;

	estimate "Pre,  Mon-14"  int 1 mon0 -14/cl;	
	estimate "Pre,  Mon-13"  int 1 mon0 -13/cl;	
	estimate "Pre,  Mon-12"  int 1 mon0 -12/cl;	
	estimate "Pre,  Mon-11"  int 1 mon0 -11/cl;	
	estimate "Pre,  Mon-10"  int 1 mon0 -10/cl;	
	estimate "Pre,  Mon-9"   int 1 mon0  -9/cl;	
	estimate "Pre,  Mon-8"   int 1 mon0  -8/cl;	
	estimate "Pre,  Mon-7"   int 1 mon0  -7/cl;	
	estimate "Pre,  Mon-6"   int 1 mon0  -6/cl;	
	estimate "Pre,  Mon-5"   int 1 mon0  -5/cl;	
	estimate "Pre,  Mon-4"   int 1 mon0  -4/cl;	
	estimate "Pre,  Mon-3"   int 1 mon0  -3/cl;	
	estimate "Pre,  Mon-2"   int 1 mon0  -2/cl;	
	estimate "Pre,  Mon-1"   int 1 mon0  -1/cl;	
	estimate "Post, Mon0"    int 1 mon1   0/cl;	
	estimate "Post, Mon1"    int 1 mon1   1/cl;	
	estimate "Post, Mon2"    int 1 mon1   2/cl;	
	estimate "Post, Mon3"    int 1 mon1   3/cl;	
	estimate "Post, Mon4"    int 1 mon1   4/cl;	
	estimate "Post, Mon5"    int 1 mon1   5/cl;	
	estimate "Post, Mon6"    int 1 mon1   6/cl;	
	estimate "Post, Mon7"    int 1 mon1   7/cl;
	estimate "Post, Mon8"    int 1 mon1   8/cl;	
	estimate "Post, Mon9"    int 1 mon1   9/cl;	
	estimate "Post, Mon10"   int 1 mon1  10/cl;
	estimate "Post, Mon11"   int 1 mon1  11/cl;	
	estimate "Post, Mon12"   int 1 mon1  12/cl;

	estimate "Compare slopes between pre and post" mon0 1 mon1 -1;	
    ods output Glimmix.Estimates=estimate;
	ods output Glimmix.ParameterEstimates=slope;
run;


data line_&var;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	if mon=. then delete;
	%if %eval(&x in 1) %then %do; 
		if lower<0 then lower=0;
		if upper<0 then upper=0;
		if estimate<0 then delete;
		keep Mon estimate upper lower label;
		rename estimate=y upper=y1 lower=y2;
	%end;
	%if %eval(&x in 2 3 5 10 11 12) %then %do; 
		y=1/(1+exp(-estimate))*100;
		y1=1/(1+exp(-upper))*100;
		y2=1/(1+exp(-lower))*100;
		keep Mon y y1 y2 estimate upper lower label;
	%end;
	%if %eval(&x in 4 6 7 8 9) %then %do; 
		y=exp(estimate);
		y1=exp(upper);
		y2=exp(lower);
		keep Mon y y1 y2 estimate upper lower label;
	%end;
run;

data _null_;
	set estimate;
	if find(label,"slopes") then if probt>=0.0001 then call symput("pslope", compress(put(probt,7.4))); 
	else if probt<0.0001 then call symput("pslope", '<0.0001');
run;

data _null_;
	set slope;
	tmp=compress(put(estimate, 7.3)||"("||put(stderr,7.3)||")");
	if _n_=2 then call symput("pre", tmp);
	if _n_=3 then call symput("post", tmp);
run;

axis1 	label=(h=2.5 'Months Before and After Intervention' ) split="*"	value=( h=1.75)  order= (-15 to 13 by 1) minor=none offset=(0 in, 0 in);
%if &var=los %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (80 to 160 by 5) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=return %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 3.0 by 0.2) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=admission %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 10 by 0.5) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=labs %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 1.2 by 0.1) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=rca %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 2.6 by 0.2) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rch  %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.4 by 0.05) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rc %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.36 by 0.02) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rk %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.24 by 0.02) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rkc %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.36 by 0.02) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=iap  %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 20 by 1) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=ifp %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 80 by 5) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=izp %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 15 by 1) offset=(.25 in, .25 in) minor=none;
%end;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=1 width=1 ;
symbol2 interpol=j mode=exclude value=none co=red cv=red height=2 bwidth=1 width=1 l=4;
symbol3 interpol=j mode=exclude value=none co=green cv=green height=2 bwidth=1 width=1 l=4;

%if %eval(&x in 1 6 7 8 9 10 11 12) %then %do;
legend across = 1 position=(bottom left inside) mode = share shape = symbol(3,2) label=NONE 
value = (h=2 "Pre Intervention, Slope(SE)=&pre Post Intervention, Slope(SE)=&post p value=&pslope" "Upper 95%CI" "Lower 95%CI")  offset=(0.2in, 0.4 in) frame;
%end;

%else %if %eval(&x in 2 3) %then %do;
legend across = 1 position=(bottom left inside) mode = share shape = symbol(3,2) label=NONE 
value = (h=2 "Pre Intervention, Slope(SE)=&pre Post Intervention, Slope(SE)=&post p value=&pslope" "Upper 95%CI" "Lower 95%CI")  offset=(0.2in, 0.4 in) frame;
%end;

%else %if %eval(&x in 4 5) %then %do;
legend across = 1 position=(top left inside) mode = share shape = symbol(3,2) label=NONE 
value = (h=2 "Pre Intervention, Slope(SE)=&pre Post Intervention, Slope(SE)=&post p value=&pslope" "Upper 95%CI" "Lower 95%CI")  offset=(0.2in, -0.4 in) frame;
%end;

title 	height=3 "&txt";
proc gplot data=line_&var gout=brent.graphs;

	plot y*mon y1*mon y2*mon/overlay haxis = axis1 vaxis = axis2 legend=legend;

	format y y1 y2 4.2;
	%if &var=los  or &var=ifp or &var=iap  %then %do; format y y1 y2 5.0; %end;
	%if &var=return or &var=izp or &var=admission %then %do; format y y1 y2 4.1; %end;
run;

%let x = &x + 1;
%end;

%mend make_plots;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftitle="Times" ftext="Times"  hby = 3;
proc greplay igout=brent.graphs  nofs; delete _ALL_; run;

%make_plots(site1); run;
%make_plots(site2); run;
/*%make_plots(sub_pp); run;*/

goptions reset=all noborder;
ods pdf file = "trend_eg.pdf";
proc greplay nofs /*NOBYLINE*/;
igout brent.graphs;
list igout;
tc template;
tdef t1 4 /llx=5    ulx=5   lrx=50   urx=50  lly=0    uly=25    lry=0      ury=25
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=25   uly=50    lry=25     ury=50
        2 /llx=5    ulx=5   lrx=50   urx=50  lly=50   uly=75    lry=50     ury=75
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=75   uly=100   lry=75     ury=100
        8 /llx=50   ulx=50  lrx=95   urx=95  lly=0    uly=25    lry=0      ury=25
        7 /llx=50   ulx=50  lrx=95   urx=95  lly=25   uly=50    lry=25     ury=50
        6 /llx=50   ulx=50  lrx=95   urx=95  lly=50   uly=75    lry=50     ury=75
        5 /llx=50   ulx=50  lrx=95   urx=95  lly=75   uly=100   lry=75     ury=100;
template t1;
tplay 1:1 2:2 3:3 4:4 5:5 6:6 7:7 8:8;
tplay 1:9 2:10 3:11 4:12;
run; quit;
ods pdf close;

ods pdf file = "trend_sr.pdf";
proc greplay nofs /*NOBYLINE*/;
igout brent.graphs;
list igout;
tc template;
tdef t1 4 /llx=5    ulx=5   lrx=50   urx=50  lly=0    uly=25    lry=0      ury=25
        3 /llx=5    ulx=5   lrx=50   urx=50  lly=25   uly=50    lry=25     ury=50
        2 /llx=5    ulx=5   lrx=50   urx=50  lly=50   uly=75    lry=50     ury=75
        1 /llx=5    ulx=5   lrx=50   urx=50  lly=75   uly=100   lry=75     ury=100
        8 /llx=50   ulx=50  lrx=95   urx=95  lly=0    uly=25    lry=0      ury=25
        7 /llx=50   ulx=50  lrx=95   urx=95  lly=25   uly=50    lry=25     ury=50
        6 /llx=50   ulx=50  lrx=95   urx=95  lly=50   uly=75    lry=50     ury=75
        5 /llx=50   ulx=50  lrx=95   urx=95  lly=75   uly=100   lry=75     ury=100;
template t1;
tplay 1:14 2:15 3:16 4:17 5:18 6:19 7:20 8:21;
tplay 1:22 2:23 3:24 4:25;
run; quit;
ods pdf close;
