options nofmterr /*orientation=landscape*/ orientation=portrait nodate nonumber;
%let path=H:\SAS_Emory\Consulting\Brent1\Final\;
libname brent "&path";

filename edmd "&path.EDMD.xls";

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


data EDMD;
	set tmp_edmd;
	if  Visit_date>'1Sep2010'd then idx=1; else idx=0;
	mon=intck("month",'1Sep2010'd,visit_date);
	mon0=min(mon,0);
	mon1=max(mon,0);

	if Visit_date>'12Jul2011'd and md_to_exit_minutes>500 then md_to_exit_minutes=.;

	format idx  pp.;
	rename 	rad_ct_abd=rca rad_ct_head=rch rad_chest=rc rad_kub=rk rad_kub_chest=rkc iv_abx_present=iap iv_fluids_present=ifp iv_zofran_present=izp;
run;

proc means data=EDMD n min max;
var mon0 mon1;
run;

**************************************************************************************;

%macro count(data,var);
proc freq data=&data; 
	tables pid*&var;
	ods output crosstabfreqs =tmp0;
run;

data tmp1;
	set tmp0;
	keep pid &var frequency _type_;
	if _type_=11 and frequency>0;
run;

proc freq data=tmp1;
	tables pid;
	ods output onewayfreqs=tmp2;
run;

data tmp_id;
	set tmp2;
	where frequency<=8;
	keep pid frequency;
run;

proc freq data=tmp2;
	tables frequency;
	ods output onewayfreqs=tmp3;
run;

data tmp;
	set tmp3;
	if frequency<=8;
	keep frequency cumfrequency cumpercent frequency2 percent;
	rename frequency2=n frequency=mons;
run;

%mend count;
%count(edmd,mon0);
proc print;run;

%count(edmd,mon1);
proc print;run;


%macro make_plots(data, var)/minoperator;

%let x= 1;

data sub;
	set &data;
	where group in (3); 
run;

proc glimmix data=sub;
	class pid;
		model  &var=mon0 mon1/link=log s dist=POISSON;
		random int /subject=pid type=un;

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
	estimate "Post, Mon13"   int 1 mon1  13/cl;	
	estimate "Post, Mon14"   int 1 mon1  14/cl;
	estimate "Post, Mon15"   int 1 mon1  15/cl;
	estimate "Post, Mon16"   int 1 mon1  16/cl;
	estimate "Post, Mon17"   int 1 mon1  17/cl;	
	estimate "Post, Mon18"   int 1 mon1  18/cl;
	estimate "Post, Mon19"   int 1 mon1  19/cl;	
	estimate "Post, Mon20"   int 1 mon1  20/cl;
	estimate "Post, Mon21"   int 1 mon1  21/cl;


	estimate "Compare slopes between pre and post" mon0 1 mon1 -1;	
	ods output Glimmix.Estimates=estimate;
	ods output Glimmix.ParameterEstimates=slope;
run;

data line;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	y=exp(estimate)*100;
		y1=exp(upper)*100;
			y2=exp(lower)*100;
	if mon=. then delete;
	keep Mon y y1 y2 estimate upper lower label;
run;

axis1 	label=(h=2.5 'Months Before and After Intervention' ) split="*"	value=( h=1.75)  order= (-15 to 22 by 1) minor=none offset=(0 in, 0 in);
axis2 label=(h=2.5 a=90 "&var") value=(h=2) offset=(.25 in, .25 in) minor=none;


symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=1 width=1 ;
symbol2 interpol=j mode=exclude value=none co=green cv=green height=2 bwidth=1 width=1 l=4;
symbol3 interpol=j mode=exclude value=none co=green cv=green height=2 bwidth=1 width=1 l=4;

%let note1=m=(10,30) h=2 "Pre Intervention, Slope(SE) =&pre ";
%let note2=m=(10,27) h=2 "Post Intervention, Slope(SE) =&post";
%let note3=m=(10,24) h=2 "Test of Equal Slopes: p value =&pslope";

title 	height=3 " ";
proc gplot data=line gout=brent.graphs;

	*plot y*mon y1*mon y2*mon/overlay haxis = axis1 vaxis = axis2 nolegend href=0 CHREF=red lhref=2;
	plot y*mon/overlay haxis = axis1 vaxis = axis2 nolegend href=0 CHREF=red lhref=2;

	format y y1 y2 4.1;
	note &note1;
	note &note2;
	note &note3;
run;


%mend make_plots;


goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftitle="Times" ftext="Times"  hby = 3;
proc greplay igout=brent.graphs  nofs; delete _ALL_; run;
%make_plots(edmd,rch); run;


ods pdf file = "trend_test.pdf";
proc greplay nofs tc=sashelp.templt template=v2s nofs;
list igout;
treplay 1:1 ; 
run; quit;
ods pdf close;
