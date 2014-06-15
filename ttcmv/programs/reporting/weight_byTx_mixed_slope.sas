libname wbh "/ttcmv/sas/data";	

proc format;
		value tx 
		0="No"
		1="Yes"
		;
run;

data hwl;
	set cmv.plate_015;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate;
	rename DFSEQ=day;
run;

proc sql;
	create table hwl as 
	select a.*
	from hwl as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0; 
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	/*if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */
	if A;

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
		;
run;

proc sort nodupkey; by id dt; run;

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	daytx0=WeightDate-dt;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if  -1<=daytx0<=1 then daytx=0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	

	if tx then output hwl_tx;
	if not tx then output hwl_no_tx;
	output hwl;
run;

data hwl_id;
	set hwl; 
	keep id tx;
run;

proc sort nodupkey; by id;run;
	
proc freq data=hwl_id;
	tables tx;
	ods output onewayfreqs=tab;
run;

data _null_;
	set tab;
	if tx=0 then call symput("no", compress(frequency));
	if tx=1 then call symput("yes",compress(frequency));
run;
%let total=%eval(&yes+&no);

data  hwl_before_tx;
	set hwl_tx;
	if daytx<=0;
run;


data  hwl_after_tx;
	set hwl_tx(drop=day);
	if daytx>=0;
	rename daytx=day;
run;

data hwl_A;
	set hwl_no_tx hwl_before_tx(in=before);
	if before then tx=1; else tx=0;
run;
proc sort nodupkey; by day id;run;

data hwl_B;
	set hwl_after_tx hwl_before_tx(in=before);
	if before then tx=1; else tx=0;
run;
proc sort nodupkey; by day id;run;

data hwl_C;
	set hwl_after_tx hwl_before_tx(in=before);
	if before then tx=1; else tx=0;
run;
proc sort nodupkey; by day id;run;

%macro getn(data);
data _null_;
	set &data;
	if tx=0 and day=1  then call symput( "m1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "m4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "m7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "m14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "m21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "m28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "m40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "m60",  compress(put(num_obs, 3.0)));

	if tx=1 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=1 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=1 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=1 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=1 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=1 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=1 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=1 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));
run;
%mend;

%macro tx(data, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );


	proc means data=&data noprint;
    	class tx day;
    	var &var;
 		output out = num_&var n(&var) = num_obs;
	run;

%let m1= 0; %let m4= 0; %let m7= 0; %let m14= 0; %let m21= 0; %let m28=0; %let m40= 0;  %let m60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;

%getn(num_&var);

proc format;
value tt -1=" "  
 0=" " 1="1*(&m1|&n1)"  2=" " 3=" " 4 = "4*(&m4|&n4)" 5=" " 6=" " 7="7*(&m7|&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&m14|&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&m21|&n21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&m28|&n28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&m40|&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&m60|&n60)" ;

value dd -1=" "  
 0=" " 1="1*(&m1)*(&n1)"  2=" " 3=" " 4 = "4*(&m4)*(&n4)" 5=" " 6=" " 7="7*(&m7)*(&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&m14)*(&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&m21)*(&n21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&m28)*(&n28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&m40)*(&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&m60)*(&n60)" ;

run;


proc mixed method=ml data=&data covtest;
	class id tx;
	model &var=tx day tx*day/s;
	random int day/type=un subject=id;

	estimate "Tx, slope" day 1 tx*day 1 0;
	estimate "Non-tx, slope" day 1 tx*day 0 1;
	estimate "Compare slopes" tx*day 1 -1;

	estimate "No-tx, intercept" int 1 tx 0 1/cl;
	estimate "No-tx, Day1"   int 1 tx 0 1 day 1   day*tx 0 1   ;
	estimate "No-tx, Day4"   int 1 tx 0 1 day 4   day*tx 0 4   ;
	estimate "No-tx, Day7"   int 1 tx 0 1 day 7   day*tx 0 7   ;
	estimate "No-tx, Day14"  int 1 tx 0 1 day 14  day*tx 0 14  ;
	estimate "No-tx, Day21"  int 1 tx 0 1 day 21  day*tx 0 21  ;
	estimate "No-tx, Day28"  int 1 tx 0 1 day 28  day*tx 0 28  ;
	estimate "No-tx, Day40"  int 1 tx 0 1 day 40  day*tx 0 40  ;
	estimate "No-tx, Day60"  int 1 tx 0 1 day 60  day*tx 0 60  /e;

	estimate "tx, intercept" int 1 tx 1 0/cl;
	estimate "tx, Day1"   int 1 tx 1 0 day 1   day*tx 1  0;
	estimate "tx, Day4"   int 1 tx 1 0 day 4   day*tx 4  0;
	estimate "tx, Day7"   int 1 tx 1 0 day 7   day*tx 7  0;
	estimate "tx, Day14"  int 1 tx 1 0 day 14  day*tx 14 0;
	estimate "tx, Day21"  int 1 tx 1 0 day 21  day*tx 21 0;
	estimate "tx, Day28"  int 1 tx 1 0 day 28  day*tx 28 0;
	estimate "tx, Day40"  int 1 tx 1 0 day 40  day*tx 40 0;
	estimate "tx, Day60"  int 1 tx 1 0 day 60  day*tx 60 0/e;
	ods output Mixed.Estimates=estimate_&var;
run;

data _null_;
	set estimate_&var(firstobs=3 obs=3);
	if probt<0.01 then pv='<0.01';
	else pv=put(probt,4.2);
	call symput("p", pv);
run;


data estimate_&var;
	set estimate_&var(firstobs=4);
	if find(label,"No-tx") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= substr(compress(scan(label,2,",")),4,2)+0;
	day1=day+0.25;
	keep group day day1 estimate upper lower;
	if day>0;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
run;

proc sort; by day;run;

proc print;run;

DATA anno0; 
	set estimate_&var;
	where group=0;
	xsys='2'; ysys='2';  color='blue';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set estimate_&var;
	where group=1;
	xsys='2'; ysys='2';  color='red';
	X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno0 anno1;
run;

data &data._&var;
	merge estimate_&var(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	estimate_&var(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;


goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=zapf  hby = 3;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=2;
symbol2 i=j ci=red value=dot co=red cv=red h=2 w=2;

%if &data=hwl_A %then %do;
axis1 	label=(f=zapf h=2.5 "Days Before RBC Transfusion" ) split="*"	value=(f=zapf h=1)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);%end;

%if &data=hwl_B %then %do;
axis1 	label=(f=zapf h=2.5 "Days After RBC Transfusion" ) split="*"	value=(f=zapf h=1)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in); %end;

axis2 	label=(f=zapf h=2.5 a=90 "Weight(g)") value=(f=zapf h=2) order= (0 to 2800 by 200) offset=(.25 in, .25 in) minor=(number=1); 
title1 	height=3 f=zapf "Weight vs Days (Transfusion=&yes, No Transfusion=&no)";
title2 	height=3 f=zapf "Test of equal slopes, p=&p";

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=3 "No Transfustion" "Transfution") offset=(0.2in, -0.4 in) frame;


proc gplot data= &data._&var gout=wbh.graphs;
	plot estimate0*day estimate1*day1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;
	note h=1 m=(8pct, 10 pct) "Day :" ;
	note h=1 m=(8pct, 8.5 pct) "(#no tx)" ;
	note h=1 m=(8pct, 7.0 pct) "(#tx)" ;

	format estimate0 estimate1 4.0 day dd.;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend tx;

proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;
goptions rotate = portrait;
%let varlist=weight;
	%tx(hwl_A,&varlist);quit; 
	%tx(hwl_B,&varlist);quit; 

ods pdf file = "w_slope.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
	treplay 1:1;
run;
proc greplay igout = wbh.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
	treplay 1:2;
run;
ods pdf close;
