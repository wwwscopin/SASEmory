options nofmterr /*orientation=landscape*/ orientation=portrait;
%let path=H:\SAS_Emory\Consulting\Brent1\;
libname brent "&path";


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

data PP;
	set brent.edmd(in=A) brent.pnp(in=B);
	if  B then gs=0; else gs=1;
	if  Visit_date>'1Sep2010'd then idx=1; else idx=0;
	mon=intck("month",'1Sep2010'd,visit_date);
	format gs gs. idx  pp.;
run;

proc means data=pp n mean;
class pid mon;
var los return labs rad_ct_abd rad_ct_head rad_chest rad_kub rad_kub_chest iv_abx_present iv_fluids_present iv_zofran_present;
output out=tmp;
run;
/*
proc univariate data=pp;
var los return labs rad_ct_abd rad_ct_head rad_chest rad_kub rad_kub_chest iv_abx_present iv_fluids_present iv_zofran_present;
	qqplot;
run;
*/
proc freq; tables _freq_;run;

data lr;
	set tmp(where=( _STAT_='MEAN'));
	if pid^=. and mon^=.;
	if  _FREQ_<10  then delete;
	rename  _FREQ_=n;
	mon0=min(mon,0);
	mon1=max(mon,0);
	rr=return*100;
	rca=rad_ct_abd*100;
	iap=iv_abx_present*100;
	ifp=iv_fluids_present*100;
	izp=iv_zofran_present*100;
	rename rad_ct_head=rch rad_chest=rc	 rad_kub=rk	rad_kub_chest=rkc;
	keep pid mon  mon0 mon1 _FREQ_ los return rr labs rca rad_ct_head rad_chest rad_kub rad_kub_chest iap ifp izp;
	format rr 4.2;
run;

proc sort data=lr nodupkey out=lr_id; by pid mon;run;

%macro make_plots(data);

%let x= 1;

%do %while (&x <12);
    %if &x = 1  %then %do; %let var =los;  %let varname =md to exit (mins);  %let txt=Length of ED stay ; %end;
    %if &x = 2  %then %do; %let var =rr;   %let varname =revisit 72 hours (%);  %let txt=Return rate ; %end;
	%if &x = 3  %then %do; %let var =labs; %let varname =labs;  %let txt=Count of number of Labs; %end;
	%if &x = 4  %then %do; %let var =rca;  %let varname =rad ct abd (%);  %let txt=Patient receive abd and/or pelvis CT; %end;
	%if &x = 5  %then %do; %let var =rch;  %let varname =rad ct head;  %let txt=Count of number of charges for head CT; %end;
	%if &x = 6  %then %do; %let var =rc;   %let varname =rad chest;  %let txt=Count of number of charges for chest X-ray; %end;
	%if &x = 7  %then %do; %let var =rk;   %let varname =rad kub;  %let txt=Count of number of charges for abdominal x-ray; %end;
	%if &x = 8  %then %do; %let var =rkc;  %let varname =rad kub chest;  %let txt=Count of number of charges for abdominal x-ray and chest x-ray; %end; 	
    %if &x = 9  %then %do; %let var =iap;  %let varname =iv abx present (%);  %let txt=Charges for IV antibiotics exist; %end;
	%if &x = 10 %then %do; %let var =ifp;  %let varname =iv fluids present (%);  %let txt=Charges for IV fluids exist; %end;
	%if &x = 11 %then %do; %let var =izp;  %let varname =iv zofran present (%);  %let txt=Charges for IV zofran (ondansetron) exist.; %end;

proc mixed method=ml data=&data covtest;
	class pid;
	model &var=mon0 mon1/s;
	random int mon0 mon1/type=un subject=pid;
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

	estimate "Compare slopes between pre and post" mon0 1 mon1 -1;	
	ods output Mixed.Estimates=estimate;
	ods output Mixed.SolutionF=slope;
run;


data line_&var;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	if lower<0 then lower=0;
		if upper<0 then upper=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
	if mon=. then delete;
	keep Mon estimate upper lower label;
run;

data _null_;
	set estimate;
	if find(label,"slopes") then call symput("pslope", compress(put(probt,7.4)));
run;

data _null_;
	set slope;
	tmp=compress(put(estimate, 7.3)||"("||put(stderr,7.3)||")");
	if _n_=2 then call symput("pre", tmp);
	if _n_=3 then call symput("post", tmp);
run;


DATA anno_&var; 
	set line_&var;
    %let color='blue';

	xsys='2'; ysys='2'; color=&color;  
	X=mon; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=mon-.1; FUNCTION='DRAW';  when = 'A'; line=1; size=1; OUTPUT;
	X=mon+.1; FUNCTION='DRAW';  when = 'A'; line=1; size=1; OUTPUT;
  	X=mon;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

axis1 	label=(h=2.5 'Months Before and After Intervention' ) split="*"	value=( h=1.75)  order= (-15 to 11 by 1) minor=none offset=(0 in, 0 in);
%if &var=los %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (60 to 140 by 5) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=rr %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 3 by 0.5) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=labs %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.6 by 0.05) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=rca %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 1 by 0.05) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rch  %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.04 by 0.01) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rk %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.08 by 0.02) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rkc or &var=rc %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 0.3 by 0.05) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=iap  %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 8 by 2) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=ifp or &var=izp %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 20 by 2) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=izp %then %do;
axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0 to 5 by 0.5) offset=(.25 in, .25 in) minor=none;
%end;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=1 width=1;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2 shape = symbol(3,2) label=NONE 
value = (h=2 "Pre Intervention, Slope(SE)=&pre Post Intervention, Slope(SE)=&post p value=&pslope" )  offset=(0.2in, -0.4 in) frame;

title 	height=3 "&txt";
proc gplot data=line_&var gout=brent.graphs;
	plot estimate*mon/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
	%if &var=los or &var=iap  or &var=ifp  %then format estimate 5.0;
	%else %if &var=rr or &var=izp  %then format estimate 4.1;
	%else format estimate 4.2;
run;

%let x = &x + 1;
%end;

%mend make_plots;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftitle="Times" ftext="Times"  hby = 3;
proc greplay igout=brent.graphs  nofs; delete _ALL_; run;

%make_plots(lr); run;

goptions reset=all noborder;
ods pdf file = "trend.pdf";
proc greplay igout =brent.graphs  tc=sashelp.templt template= v3s nofs; * L2R2s;
	treplay 1:1 2:2 3:3;
run;

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
tplay 1:4 2:5 3:6 4:7 5:8 6:9 7:10 8:11;
run; quit;
ods pdf close;

************ To get data from Top Quartile ******************************;

filename edmd "&path.EDMD.xls";
filename pnp "&path.PNP.xls";

PROC IMPORT OUT= top10 
            DATAFILE=edmd 
            DBMS=EXCEL REPLACE;
     sheet="overall"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data top1;
	set top10;
	if rank<23;
	keep pid;
run;

PROC IMPORT OUT= top20 
            DATAFILE=pnp 
            DBMS=EXCEL REPLACE;
     sheet="overall"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data top2;
	set top20;
	if rank<5;
	keep pid;
run;

data top;
	set top1 top2;
run;

proc sort; by pid; run;

proc print;run;

data top_lr;
	merge lr top(in=A); by pid;
	if A;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftext=Times  hby = 3;
proc greplay igout=brent.graphs  nofs; delete _ALL_; run;

%make_plots(top_lr); run;

goptions reset=all border;
ods pdf file = "top.pdf";
proc greplay igout =brent.graphs  tc=sashelp.templt template= v3s nofs; * L2R2s;
	treplay 1:1 2:2 3:3;
run;

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
tplay 1:4 2:5 3:6 4:7 5:8 6:9 7:10 8:11;
run; quit;
ods pdf close;
