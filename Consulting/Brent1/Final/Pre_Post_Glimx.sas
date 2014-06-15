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
	value idx
		1="Length of ED stay" 
    	2="72-hour return rate (%)"
		3="Rate of admission to hospital (%)"
		4="Lab tests performed (per 100 patients)" 			 
		5="Abdominal/pelvic CT scans performed (%)"
		6="Head CT scans performed (per 100 patients)"
		7="Chest x-rays performed (per 100 patients)"
		8="Abdominal x-rays performed (per 100 patients)"
		9="Chest and abdominal x-rays performed (per 100 patients)"
    	10="Intravenous antibiotics administered (%)"
		11="Intravenous fluid administered (%)"
		12="Intravenous ondansetron administered (%)";
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
/*
proc means data=edmd mean var;
	var labs;
run;

proc sgplot data = edmd;
	histogram labs / scale = count;
run;

proc univariate data=edmd plot;
	var labs;
run;

*/;


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


%macro make_plots(data, out)/minoperator;

data &out;	if 1=1 then delete; run;

%let x= 1;

%do %while (&x <13);
    %if &x = 1  %then %do; %let var =los;       %let varname =Length of stay (min);  	%let txt=Length of ED stay ;   %end;
    %if &x = 2  %then %do; %let var =return;    %let varname =72-hour return rate (%);  %let txt=Return rate ; 		   %end;
	%if &x = 3  %then %do; %let var =admission; %let varname =Rate of admission to hospital (%);  		 		 %let txt=admitted to hospital; %end;
	%if &x = 4  %then %do; %let var =labs; 		%let varname =Lab tests performed (per 100 patients); 			 %let txt=Count of number of Labs; %end;
	%if &x = 5  %then %do; %let var =rca;  		%let varname =Abdominal/pelvic CT scans performed (%);  		 %let txt=Patient receive abd and/or pelvis CT; %end;
	%if &x = 6  %then %do; %let var =rch;  		%let varname =Head CT scans performed (per 100 patients);  		 %let txt=Count of number of charges for head CT; %end;
	%if &x = 7  %then %do; %let var =rc;   		%let varname =Chest x-rays performed (per 100 patients);  		 %let txt=Count of number of charges for chest X-ray; %end;
	%if &x = 8  %then %do; %let var =rk;   		%let varname =Abdominal x-rays performed (per 100 patients);  	 %let txt=Count of number of charges for abdominal x-ray; %end;
	%if &x = 9  %then %do; %let var =rkc;  		%let varname =Chest and abdominal x-rays performed (per 100 patients); 		 %let txt=Count of number of charges for abdominal x-ray and chest x-ray; %end; 	
    %if &x = 10 %then %do; %let var =iap;  		%let varname =Intravenous antibiotics administered (%);  	%let txt=Charges for IV antibiotics exist; %end;
	%if &x = 11 %then %do; %let var =ifp;  		%let varname =Intravenous fluid administered (%);		 	%let txt=Charges for IV fluids exist; %end;
	%if &x = 12 %then %do; %let var =izp;  		%let varname =Intravenous ondansetron administered (%); 	%let txt=Charges for IV zofran (ondansetron) exist.; %end;

data sub;
	set &data;
	%if &var=labs %then %do; where group in (1,2); %end;
	%if &var=rch %then %do; where group in (3); %end;
	%if &var=rca %then %do; where group in (1); %end;
	%if &var=rc %then %do; where group in (4); %end;
	%if &var=rk %then %do; where group in (1); %end;
	%if &var=rkc %then %do; where group in (2); %end;
	%if &var=iap %then %do; where group in (2); %end;
	%if &var=ifp %then %do; where group in (1); %end;
	%if &var=izp %then %do; where group in (1); %end;
run;

proc means data=sub mean maxdec=4;
		class pid mon;
		var &var;
		ods output summary=avg;
run;

data avg;
	set avg(keep=pid mon &var._mean);
	%if &x # 1 %then %do; y0=&var._mean; %end;
	%else %do; y0=&var._mean*100; %end;
run;
proc sort; by mon pid;run;

proc glimmix data=sub;
	class pid;
		%if &x=1 %then %do;
		model &var=mon0 mon1/s;
		random int mon0 mon1/type=un subject=pid;
		%end;
		%else %if %eval(&x in 2 3 5 10 11 12) %then %do;
		model  &var(event='Yes')=mon0 mon1/s dist=binary;
		random int /subject=pid type=un;
		%end;
		%else %if %eval(&x in 4 6 7 9) %then %do;
		model  &var=mon0 mon1/link=log s dist=POISSON;
		random int/subject=pid type=un;
		%end;	
		%else %if %eval(&x in 8) %then %do;
		model  &var=mon0 mon1/link=log s dist=POISSON;
		random int/subject=pid type=cs;
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
	estimate "Post, Mon13"   int 1 mon1  13/cl;	
	estimate "Post, Mon14"   int 1 mon1  14/cl;
	estimate "Post, Mon15"   int 1 mon1  15/cl;
	estimate "Post, Mon16"   int 1 mon1  16/cl;
	estimate "Post, Mon17"   int 1 mon1  17/cl;	
	estimate "Post, Mon18"   int 1 mon1  18/cl;
	estimate "Post, Mon19"   int 1 mon1  19/cl;	
	estimate "Post, Mon20"   int 1 mon1  20/cl;
	estimate "Post, Mon21"   int 1 mon1  21/cl;
	estimate "Post, Mon22"   int 1 mon1  22/cl;
	estimate "Post, Mon23"   int 1 mon1  23/cl;	
	estimate "Post, Mon24"   int 1 mon1  24/cl;
	estimate "Post, Mon25"   int 1 mon1  25/cl;
	estimate "Post, Mon26"   int 1 mon1  26/cl;
	estimate "Post, Mon27"   int 1 mon1  27/cl;	

	estimate "Compare slopes between pre and post" mon0 1 mon1 -1;	
    ods output Glimmix.Estimates=estimate;
	ods output Glimmix.ParameterEstimates=slope;
run;

%if %eval(&x in 1) %then %do; 
data line_&var;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	if lower<0 then lower=0;
		if upper<0 then upper=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
	if mon=. then delete;
	x=&x;
	keep x Mon estimate upper lower label;
	rename estimate=y upper=y1 lower=y2;
run;
%end;

%if %eval(&x in 2 3 5 10 11 12) %then %do; 
data line_&var;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	y=1/(1+exp(-estimate))*100;
		y1=1/(1+exp(-upper))*100;
			y2=1/(1+exp(-lower))*100;
	if mon=. then delete;
	x=&x;
	keep x Mon y y1 y2 estimate upper lower label;
run;
%end;

%if %eval(&x in 4 6 7 8 9) %then %do; 
data line_&var;
	set estimate;
	mon= compress(scan(label,2,","),"Mon")+0;
	y=exp(estimate)*100;
		y1=exp(upper)*100;
			y2=exp(lower)*100;
	if mon=. then delete;
	x=&x;
	keep x Mon y y1 y2 estimate upper lower label;
run;
%end;

data _null_;
	set line_&var;
	if mon=-14 then call symput("ya", compress(put(y,5.1)));
	if mon=0 then call symput("y0", compress(put(y,5.1)));
	if mon=21 then call symput("yb", compress(put(y,5.1)));
run;


data _null_;
	set estimate;
	if find(label,"slopes") then if probt>=0.0001 then call symput("pslope", compress(put(probt,7.4))); 
	else if probt<0.0001 then call symput("pslope", '<0.0001');
run;

data _null_;
	set slope;
	%if &var^=los %then %do; 
		tmp=compress(put(estimate, 7.4)||"("||put(stderr,7.4)||")");
	%end;
	%else  %do;
		tmp=compress(put(estimate, 5.1)||"("||put(stderr,5.1)||")");
	%end;
	if _n_=2 then call symput("pre", tmp);
	if _n_=3 then call symput("post", tmp);
run;

data one;
	xsys='2'; ysys='2';
	function='label'; x=0; y=&ya; color="black"; size=2; text="Pre Intervention, Slope(SE)=&pre"; output;
	function='label'; x=0; y=&yb; color="black"; size=2; text="Post Intervention, Slope(SE)=&post"; output;
	function='label'; x=0; y=&y0; color="black"; size=2; text="Test of Equal Slopes: p value=&pslope"; output;
run;

axis1 	label=(h=2.5 'Months Before and After Intervention' ) split="*"	value=( h=1.75)  order= (-14 to 28 by 2) minor=none offset=(0.2 in, 0 in);
%if &var=los %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (120 to 140 by 2) offset=(.25 in, .25 in) minor=(number=1);
%end;


%if &var=return %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (1.6 to 2.8 by 0.1) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=admission %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (6 to 12 by 0.5) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=labs %then %do;
	axis2 	label=(h=2.5 a=90 "&varname") value=(h=2) order= (40 to 70 by 2) offset=(.25 in, .25 in) minor=(number=1);
%end;

%if &var=rca %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (0.4 to 3.0 by 0.2) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rch  %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (12 to 32 by 2) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rc %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (25 to 35 by 1) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rk %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (12 to 20 by 0.5) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=rkc %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (24 to 36 by 1) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=iap  %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (6 to 14 by 1) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=ifp %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (28 to 42 by 1) offset=(.25 in, .25 in) minor=none;
%end;

%if &var=izp %then %do;
	axis2 label=(h=2.5 a=90 "&varname") value=(h=2) order= (3 to 12 by 1) offset=(.25 in, .25 in) minor=none;
%end;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=1 width=1 ;
symbol2 interpol=j mode=exclude value=none co=green cv=green height=2 bwidth=1 width=1 l=4;
symbol3 interpol=j mode=exclude value=none co=green cv=green height=2 bwidth=1 width=1 l=4;
symbol4 interpol=none mode=exclude value=dot co=black cv=black h=0.5 bwidth=1 w=1 ;

%let note1=m=(10,30) h=2 "Pre Intervention, Slope(SE) =&pre ";
%let note2=m=(10,27) h=2 "Post Intervention, Slope(SE) =&post";
%let note3=m=(10,24) h=2 "Test of Equal Slopes: p value =&pslope";

/*
data line_&var;
	merge line_&var avg; by mon;
run;
*/

proc gplot data=line_&var gout=brent.graphs;
	title 	height=3 " ";
	*plot y*mon y0*mon/overlay haxis = axis1 vaxis = axis2 legend=nolegend href=0 CHREF=red lhref=2;
	plot y*mon/overlay haxis = axis1 vaxis = axis2 legend=nolegend href=0 CHREF=red lhref=2;

	format y y1 y2 4.2;
	%if &var # los ifp iap izp labs rc rch rkc %then %do; format y y1 y2 5.0; %end;
	%if &var # return admission rk rca %then %do; format y y1 y2 4.1; %end;
	note &note1;
	note &note2;
	note &note3;
run;

data &out;
	set &out line_&var;
run;

%let x = &x + 1;
%end;

%mend make_plots;


goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftitle="Times" ftext="Times"  hby = 3;
proc greplay igout=brent.graphs  nofs; delete _ALL_; run;
%make_plots(edmd,line); run;


ods pdf file = "trend_EDMD.pdf";
proc greplay igout = brent.graphs tc=sashelp.templt template=v2s nofs; * L2R2s;
     treplay 1:1 2:2;
		       treplay 1:3 2:4;
					     treplay 1:5 2:6;
							       treplay 1:7  2:8;
										     treplay 1:9 2:10;
												       treplay 1:11 2:12;
run;
ods pdf close;


ods rtf file = "trend_edmd_data.rtf" style=journal toc_data startpage = yes bodytitle;
proc print data=line noobs label;
	by x; 
	id x;
	var mon y y1 y2;
	label x="Item"
		  mon="Month"
		  y="Estimate"
		  y1="Upper"
		  y2="Lower";
	format x idx.;
run;
ods rtf close;
