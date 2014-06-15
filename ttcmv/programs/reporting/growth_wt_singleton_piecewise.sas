options orientation=portrait nodate nobyline;
libname wbh "/ttcmv/sas/data";	
%let pm=%sysfunc(byte(177)); 

proc format; value tx 0="No"	1="Yes";run;

data hwl;
	merge cmv.plate_015 cmv.plate_008; by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;

	if not MultipleBirth;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth;
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
run;

proc sort nodupkey; by id dt; run;

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt); by id;
	if trans then tx=1; else tx=0;
	if hwl;

	retain dtx;
	if first.id then dtx=dt;
	daytx0=WeightDate-dtx;

	format dtx mmddyy.;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if -1<=daytx0<=1 then daytx=daytx0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	

	wk=day/7;
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

%put &no;

proc sort data=hwl_no_tx nodupkey out=hwl0_id; by tx id day;run;

proc means data=hwl0_id noprint;
    	class tx day;
    	var weight;
 		output out = num_wt0 n(weight) = num_obs;
run;

data num_wt0;
	set num_wt0;
	if tx=. or day=. then delete;
run;

data  hwl_tx;
	set hwl_tx(drop=day);
	if daytx0<=0 then tx=0; else tx=1;
	rename daytx0=day;
	d1=min(daytx0,0);
	d2=max(daytx0,0);
	wk1=d1/7;
	wk2=d2/7;
run;

proc sort nodupkey out=hwl_id; by tx id daytx;run;

proc means data=hwl_id ;
    	class tx daytx;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or daytx=. then delete;
run;

%let a0= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n0= 0; %let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b0= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if daytx=0  then call symput( "a0",   compress(put(num_obs, 3.0)));
	if daytx=-1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if daytx=-4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if daytx=-7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if daytx=-14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if daytx=-21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if daytx=-28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if daytx=-40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if daytx=-60 then call symput( "a60",  compress(put(num_obs, 3.0)));

	if daytx=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if daytx=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if daytx=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if daytx=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if daytx=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if daytx=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if daytx=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if daytx=60 then call symput( "b60",  compress(put(num_obs, 3.0)));
run;


data _null_;
	set num_wt0;
	*if tx=0 and day=0  then call symput( "n0",   compress(put(num_obs, 3.0)));
	if tx=0 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));
run;

%put &n0;
%put &n1;
%put &n4;

proc format;

value dd 0=" " 1="1(&n1)"  2=" " 3=" " 4 = "4(&n4)" 5=" " 6=" " 7="7(&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14(&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21(&n21)"  22=" " 
 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28(&n28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" "  
 36=" " 37=" " 38=" " 39=" " 42=" " 41=" " 40="40(&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	
 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60(&n60)" ;

/*
value dd 0=" " 1="1*(&n1)"  2=" " 3=" " 4 = "4*(&n4)" 5=" " 6=" " 7="7*(&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21*(&n21)"  22=" " 
 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" "  
 36=" " 37=" " 38=" " 39=" " 42=" " 41=" " 40="40*(&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	
 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60*(&n60)" ;


value dt   
			-41=" " -40="-40*(&a40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28*(&a28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21*(&a21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14*(&a14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7*(&a7)" -6=" " - 5=" "  -4="-4*(&a4)"  -3=" "   
			-2=" "  -1=" " 0= "0*(&a0)"  1=" "  2=" " 3=" " 4="4*(&b4)" 5=" " 6=" " 7="7*(&b7)" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14*(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21*(&b21)"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&b28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40*(&b40)" ;
*/

value dt   
			-41=" " -40="-40(&a40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28(&a28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21(&a21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14(&a14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7(&a7)" -6=" " - 5=" "  -4="-4(&a4)"  -3=" "   
			-2=" "  -1=" " 0= "0(&a0)"  1=" "  2=" " 3=" " 4="4(&b4)" 5=" " 6=" " 7="7(&b7)" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21(&b21)"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28(&b28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40(&b40)" ;

value idx 0="Without pRBC Transfusion (n=&no)" 1="With pRBC Transfusion (n=&yes)";

value tx 0="No"	1="Yes"	;

run;

proc mixed method=ml data=hwl_no_tx covtest;
	class id;
	model weight=day/s;
	random int day/type=un subject=id;

	estimate "intercept" int 1/cl;
	estimate "Day1"   int 1 day 1;
	estimate "Day4"   int 1 day 4;
	estimate "Day7"   int 1 day 7;
	estimate "Day14"  int 1 day 14;
	estimate "Day21"  int 1 day 21;
	estimate "Day28"  int 1 day 28;
	estimate "Day40"  int 1 day 40;
	estimate "Day60"  int 1 day 60/e;

	ods output Mixed.Estimates=estimate0;
run;

data line_wt0;
	set estimate0;

	if find(label,"intercept") then day=0; 
	else day= compress(label,"Day")+0;

	keep day estimate upper lower;
	if day>0;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
run;


ods trace on/label listing;
proc mixed method=ml data=hwl_no_tx covtest;
	class id;
	model weight=wk/s;
	random int wk/type=un subject=id;

	estimate "Month1"  int 1 wk 4.286;  
	estimate "Month2"  int 1 wk 8.572;  

	ods output  Mixed.SolutionF=slope0;
	ods output Mixed.Estimates=estimate_notx;
run;
ods trace off;

data info_notx;
	length effect $60;
	set slope0(in=A) estimate_notx;

	ms=put(estimate,4.0)||" &pm "||compress(put(stderr,4.0));

	if effect="Intercept"  then effect="Intercept (g, Weight at Birth)";
	if effect="wk" then effect="Slope for LBWIs without pRBC Transfusion (g/week)";

	if find(label, "Month1") then effect="Mean Weight at 1 Month (g)";
	if find(label, "Month2") then effect="Mean Weight at 2 Month (g)";
	if ms=" " then delete;
run;


data _null_;
	set slope0;
	tmp=put(estimate, 5.0)||"("||put(stderr,3.0)||")";
	if _n_=2 then call symput("s0", compress(tmp));
run;


proc mixed method=ml data=hwl_tx covtest;
	*id id day tx;
	class id;
	model weight=d1 d2/s;
	random int d1 d2/type=un subject=id;

	estimate "Before, Day-60"  int 1 d1 -60/cl;	
	estimate "Before, Day-40"  int 1 d1 -40;  
	estimate "Before, Day-28"  int 1 d1 -28;  
	estimate "Before, Day-21"  int 1 d1 -21; 
	estimate "Before, Day-14"  int 1 d1 -14;
	estimate "Before, Day-7"   int 1 d1 -7 ; 
	estimate "Before, Day-4"   int 1 d1 -4 ;   	 
	estimate "Before, Day-1"   int 1 d1 -1 ;  
 	estimate "Before, Day0"    int 1 d1 0;
	estimate "After, Day1"   int 1 d2 1 ;  
	estimate "After, Day4"   int 1 d2 4 ;  
	estimate "After, Day7"   int 1 d2 7 ; 
	estimate "After, Day14"  int 1 d2 14;  
	estimate "After, Day21"  int 1 d2 21;  
	estimate "After, Day28"  int 1 d2 28;  
	estimate "After, Day40"  int 1 d2 40;  
	estimate "After, Day60"  int 1 d2 60;

	ods output Mixed.Estimates=estimate1;
run;

data line_wt1;
	set estimate1;
	day= compress(scan(label,2,","),"Day")+0;
	keep day estimate upper lower;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
	if day not in(-60,60);
run;

proc mixed method=ml data=hwl_tx covtest;
	*id id day tx;
	class id tx;
	model weight=wk1 wk2/s;
	random int wk1 wk2/type=un subject=id;

	estimate "Before Transfusion, Month1"  int 1 wk1 -4.286;  
	estimate "After Transfusion, Month1"  int 1 wk2 4.286; 
	estimate "After Transfusion, Month2"  int 1 wk2 8.572;   

	ods output Mixed.SolutionF=slope1;
	ods output Mixed.Estimates=estimate_tx;
run;

data info_tx;
	length effect $60;

	set slope1(in=A) estimate_tx;

	if effect="Intercept"  then effect="Intercept (g, Weight at 1st pRBC Transfusion)";
	ms=put(estimate,4.0)||" &pm "||compress(put(stderr,4.0));
	if effect="wk1" then effect="Slope Before 1st pRBC Transfusion (g/week)";
	if effect="wk2" then effect="Slope After 1st pRBC Transfusion (g/week)";
	if find(label, "Before") then effect="Mean Weight at 1 Month Before 1st pRBC Transfusion (g)";
	if find(label, "After") and find(label, "Month1") then effect="Mean Weight at 1 Month After 1st pRBC Transfusion (g)";
	if find(label, "After") and find(label, "Month2") then effect="Mean Weight at 2 Month After 1st pRBC Transfusion (g)";
	if ms=" " then delete;
run;

data info;
	set info_notx(in=A) info_tx(in=B);
	if A then idx=0; 
	if B then idx=1;
	format idx idx.;
run;

proc sort; by idx; run;

data info;
	set info; by idx; 
	idx0=put(idx, idx.);
	if not first.idx then idx0=" ";
run;

data _null_;
	set slope1;
	tmp=put(estimate, 5.0)||"("||put(stderr,4.0)||")";
	if _n_=2 then call symput("sb", compress(tmp));
	if _n_=3 then call symput("sa", compress(tmp));
run;


DATA anno0; 
	set line_wt0;
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

data anno0A;
	length function $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set line_wt0;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=0.60; output;
	text=left(put(day,dd.));
	output;
run;

data anno0;
	length color $6 function $8;
	set anno0 anno0A;
run;

DATA anno1; 
	set line_wt1;
	xsys='2'; ysys='2';  color='red';
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

data anno1A;
	length function $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set line_wt1;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=0.60; output;
	text=left(put(day,dt.));
	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white colors = (black red green blue)  ftext=zapf  hby = 3;

proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;

symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=2;

axis1 	label=(f=zapf h=2.5 'Age of LBWIs (days)' ) split="*" value=(f=zapf h=1.0 c=white)  
order= (0 to 61 by 1) minor=none offset=(0 in, 0 in) major=(c=white) origin=(,15)pct;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=2 "Without pRBC Transfusion, Slope(SE)=&s0 g/week" )  offset=(0.2in, -0.4 in) frame;


axis2 	label=(f=zapf h=2.5 a=90 "Weight(g)") value=(f=zapf h=2) order= (0 to 2600 by 200) offset=(.25 in, .25 in) minor=(number=1);
 
title 	height=3 f=zapf "Weight vs Days for Singleton LBWIs without pRBC Transfusion (n=&no)";
proc gplot data=line_wt0 gout=wbh.graphs;
	plot estimate*day/overlay annotate= anno0 haxis = axis1 vaxis = axis2 legend=legend;
	note h=1.5 m=(5pct, 10 pct) "Day(n):" ;
	format estimate 4.0;
run;


symbol1 interpol=j mode=exclude value=circle co=red cv=red height=2 bwidth=3 width=2;

axis1 	label=(f=zapf h=2.5 'Days Before and After 1st pRBC Transfusion' ) split="*"	
value=(f=zapf h=1.0 c=white) order= (-41 to 41 by 1) minor=none major=(c=white) offset=(0in, 0in) origin=(,15)pct;


legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=2 "Before  1st pRBC Transfusion, Slope(SE)=&sb g/week; After 1st pRBC Transfusion, Slope(SE)=&sa g/week" )  offset=(0in, -0.4 in) frame;

title 	height=3 f=zapf "Weight vs Days for Singleton LBWIs with pRBC Transfusion (n=&yes)";
proc gplot data=line_wt1 gout=wbh.graphs;
	plot estimate*day/overlay annotate= anno1 haxis = axis1 vaxis = axis2 legend=legend;
	note h=1.5 m=(4pct, 10 pct) "Day(n):" ;
	format estimate 4.0;
run;

ods pdf file = "growth_singleton_joint.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= v2s nofs; * L2R2s;
	treplay 1:1 2:2;
run;

ods pdf style=journal startpage=no;
proc print data=info noobs label ;
title "Singleton LBWIs Growth Rate (n=&total)";

var idx0;
var effect/style(data)=[just=left cellwidth=3.5in] style(header)=[just=left];
var ms probt/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label
		idx0="." 
		effect="Effect"
		ms="Estimate &pm SE"
		probt="p value"
		;
run;
ods pdf close;


