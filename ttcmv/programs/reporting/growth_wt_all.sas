options orientation=landscape nodate;
libname wbh "/ttcmv/sas/programs";	
%let pm=%sysfunc(byte(177)); 

proc format;
		value tx 
		0="No"
		1="Yes"
		;
run;

data hwl;
	merge cmv.plate_015 cmv.plate_008
	cmv.plate_005(keep=id LBWIDOB Gender  IsHispanic  race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	retain bw;
	if DFSEQ=1 then bw=weight;
	if bw<=1250 then gp=1; else gp=2;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth gender bw gp;
	rename DFSEQ=day;
run;


proc sql;
	create table hwl as 
	select a.*
	from hwl as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;
proc sort nodupkey out=tmp; by id;run;
proc freq; tables gp;run;

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
	daytx=WeightDate-dtx;

	format dtx mmddyy.;

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

data  hwl_before_tx;
	set hwl_tx;
	if daytx<0;
run;


data  hwl_after_tx;
	set hwl_tx;
	if daytx>=0;
run;

data hwl_C;
	set hwl_no_tx hwl_before_tx(in=before) hwl_after_tx(in=after);
	if before then tx=1; 
	if after then tx=2; 
	if not before and not after  then tx=0;
	wk=day/7;
run;

proc sort nodupkey output=hwl_id; by tx id day;run;

proc means data=hwl_id ;
    	class tx day;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or day=. then delete;
run;


%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if tx=0 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));

	if tx=1 and day=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if tx=1 and day=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if tx=1 and day=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if tx=1 and day=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if tx=1 and day=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if tx=1 and day=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if tx=1 and day=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if tx=1 and day=60 then call symput( "b60",  compress(put(num_obs, 3.0)));

	if tx=2 and day=1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if tx=2 and day=4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if tx=2 and day=7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if tx=2 and day=14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if tx=2 and day=21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if tx=2 and day=28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if tx=2 and day=40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if tx=2 and day=60 then call symput( "a60",  compress(put(num_obs, 3.0)));
run;

%put &n1;
%put &b1;
%put &a1;

proc format;

value dd -1=" "  
 0=" " 1="1*(&n1)*(&b1)*(&a1)"  2=" " 3=" " 4 = "4*(&n4)*(&b4)*(&a4)" 5=" " 6=" " 7="7*(&n7)*(&b7)*(&a7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)*(&b14)*(&a14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&n21)*(&b21)*(&a21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)*(&b28)*(&a28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&n40)*-*(&a40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&n60)*-*(&a60)" ;

value gp 0="Without pRBC Transfusion (n=&no)" 1="Before 1st pRBC Transfusion (n=&yes)" 2="After 1st pRBC Transfusion (n=&yes)";

run;

proc mixed method=ml data=hwl_C covtest;
	class id tx;
	model weight=tx day tx*day/s;
	random int day/type=un subject=id;

	estimate "No-Tx, slope" day 1 tx*day 1 0 0;
	estimate "Before, slope" day 1 tx*day 0 1 0;
	estimate "After, slope" day 1 tx*day 0 0 1;

	estimate "Compare slopes between No-Tx and Before" tx*day 1 -1 0;
	estimate "Compare slopes between No-Tx and After" tx*day 1  0 -1;
	estimate "Compare slopes between Before and After" tx*day 0 1 -1;

	estimate "No-Tx, intercept" int 1 tx 1 0 0/cl;
	estimate "No-Tx, Day1"   int 1 tx 1 0 0 day 1   day*tx 1  0 0;
	estimate "No-Tx, Day4"   int 1 tx 1 0 0 day 4   day*tx 4  0 0;
	estimate "No-Tx, Day7"   int 1 tx 1 0 0 day 7   day*tx 7  0 0;
	estimate "No-Tx, Day14"  int 1 tx 1 0 0 day 14  day*tx 14 0 0;
	estimate "No-Tx, Day21"  int 1 tx 1 0 0 day 21  day*tx 21 0 0;
	estimate "No-Tx, Day28"  int 1 tx 1 0 0 day 28  day*tx 28 0 0;
	estimate "No-Tx, Day40"  int 1 tx 1 0 0 day 40  day*tx 40 0 0;
	estimate "No-Tx, Day60"  int 1 tx 1 0 0 day 60  day*tx 60 0 0/e;

	estimate "Before, intercept" int 1 tx 0 1 0/cl;
	estimate "Before, Day1"   int 1 tx 0 1 0 day 1   day*tx 0 1  0;
	estimate "Before, Day4"   int 1 tx 0 1 0 day 4   day*tx 0 4  0;
	estimate "Before, Day7"   int 1 tx 0 1 0 day 7   day*tx 0 7  0;
	estimate "Before, Day14"  int 1 tx 0 1 0 day 14  day*tx 0 14 0;
	estimate "Before, Day21"  int 1 tx 0 1 0 day 21  day*tx 0 21 0;
	estimate "Before, Day28"  int 1 tx 0 1 0 day 28  day*tx 0 28 0;
	estimate "Before, Day40"  int 1 tx 0 1 0 day 40  day*tx 0 40 0;
	estimate "Before, Day60"  int 1 tx 0 1 0 day 60  day*tx 0 60 0/e;

	estimate "After, intercept" int 1 tx 0 0 1 /cl;
	estimate "After, Day1"   int 1 tx 0 0 1 day 1   day*tx 0 0 1  ;
	estimate "After, Day4"   int 1 tx 0 0 1 day 4   day*tx 0 0 4  ;
	estimate "After, Day7"   int 1 tx 0 0 1 day 7   day*tx 0 0 7  ;
	estimate "After, Day14"  int 1 tx 0 0 1 day 14  day*tx 0 0 14 ;
	estimate "After, Day21"  int 1 tx 0 0 1 day 21  day*tx 0 0 21 ;
	estimate "After, Day28"  int 1 tx 0 0 1 day 28  day*tx 0 0 28 ;
	estimate "After, Day40"  int 1 tx 0 0 1 day 40  day*tx 0 0 40 ;
	estimate "After, Day60"  int 1 tx 0 0 1 day 60  day*tx 0 0 60 /e;

	ods output Mixed.Estimates=estimate_wt;
run;

proc mixed method=ml data=hwl_C covtest;
	class id tx;
	model weight=tx wk tx*wk/s noint;
	random int wk/type=un subject=id;

	estimate "No Tx, intercept"     tx 1 0 0;
	estimate "No Tx, slope"      wk 1 tx*wk 1 0 0;
	estimate "No Tx, Month1"      tx 1 0 0 wk 4.286 tx*wk 4.286 0 0; 
	estimate "No Tx, Month2"      tx 1 0 0 wk 8.572 tx*wk 8.572 0 0;  

	estimate "Before 1st pRBC Tx, intercept" tx 0 1 0;
	estimate "Before 1st pRBC Tx, slope"  wk 1 tx*wk 0 1 0;
	estimate "Before 1st pRBC Tx, Month1"  tx 0 1 0 wk 4.286 tx*wk 0 4.286 0;  

	estimate "After 1st pRBC Tx, intercept"  tx 0 0 1;
	estimate "After 1st pRBC Tx, slope"   wk 1 tx*wk 0 0 1;
	estimate "After 1st pRBC Tx, Month1"   tx 0 0 1 wk 4.286 tx*wk 0 0 4.286;  
	estimate "After 1st pRBC Tx, Month2"   tx 0 0 1 wk 8.572 tx*wk 0 0 8.572;  

/*
	estimate "Compare slopes between No-Tx and Before 1st pRBC Tx" tx*wk 1 -1  0;
	estimate "Compare slopes between No-Tx and After 1st pRBC Tx"  tx*wk 1  0 -1;
	estimate "Compare slopes between Before 1st pRBC Tx and After 1st pRBC Tx" tx*wk 0  1 -1;
*/
	ods output Mixed.Estimates=estimate_wk;
run;

data info;

	length effect $40;

	set estimate_wk;
	ms=put(estimate,4.0)||" &pm "||compress(put(stderr,4.0));

	if find(label, "No") then group=0;
	if find(label, "Before") then group=1;
	if find(label, "After") then group=2;

	if find(label, "intercept") then effect="Intercept (g)";
	if find(label, "slope") then effect="Slope (g/week)";
	if find(label, "Month1") then effect="Mean Weight at 1 Month (g)";
	if find(label, "Month2") then effect="Mean Weight at 2 Month (g)";

	format group gp.;
run;


data _null_;
	set estimate_wk;

	if _n_=2 then call symputx("n", put(estimate,3.0)||"("||compress(put(stderr,3.0))||")");
	if _n_=6 then call symputx("b", put(estimate,3.0)||"("||compress(put(stderr,3.0))||")");
	if _n_=9 then call symputx("a", put(estimate,3.0)||"("||compress(put(stderr,3.0))||")");

/*
	if probt<0.01 then pv='<0.01';
	else pv=put(probt,4.2);
	if _n_=4 then call symput("p01", pv);
	if _n_=5 then call symput("p02", pv);
	if _n_=6 then call symput("p12", pv);
*/
run;


data line_wt;
	set estimate_wt(firstobs=7);
	if find(label,"No-Tx") then group=0; 
		else if find(label,"Before")  then group=1; else group=2;
	if find(label,"intercept") then day=0; 
	else day= substr(compress(scan(label,2,",")),4,2)+0;
	day1=day+0.05;
	day2=day+0.25;
	keep group day day1 day2 estimate upper lower;
	if day>0;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
run;

DATA anno0; 
	set line_wt;
	where group=0;
	xsys='2'; ysys='2';  color='green';
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
	set line_wt;
	where group=1;
	xsys='2'; ysys='2';  color='blue';
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

DATA anno2; 
	set line_wt;
	where group=2;
	xsys='2'; ysys='2';  color='red';
	X=day2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
   X=day2-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day2+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno;
	set anno0 anno1(in=B) anno2;
	if B and day>28 then delete;
run;

data wt;
	merge line_wt(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
			line_wt(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
			line_wt(where=(group=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)); 
	by day;
	if  day>28 then do; estimate1=.; lower1=.; upper1=.; end;
run;


goptions reset=all  rotate=landscape device=jpeg  gunit=pct noborder cback=white
colors = (black red green blue)  ftext=zapf  hby = 3;

symbol1 interpol=spline mode=exclude value=circle co=green cv=green height=2 width=1;
symbol2 i=spline ci=blue value=dot co=blue cv=blue h=2 w=1;
symbol3 i=spline ci=red value=triangle co=red cv=red h=2 w=1;


axis1 	label=(f=zapf h=2.5 "Age of LBWIs (days)" ) split="*"	value=(f=zapf h=1)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(f=zapf h=2.5 a=90 "Weight(g)") value=(f=zapf h=2) order= (0 to 2800 by 200) offset=(.25 in, .25 in) minor=(number=1);
 
title1 	height=3 f=zapf "All LBWIs Weight vs Age";
title2 	height=2.5 f=zapf "(With pRBC Transfusion=&yes, Without pRBC Transfusion=&no)";
*title2 	height=3 f=zapf "Test of equal slopes, p=&p";

%put &yes;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=zapf h=2 "Without pRBC Transfusion, Slope(SE)=&n g/week" "Before 1st pRBC Transfusion, Slope(SE)=&b g/week" 
"After 1st pRBC Transfusion, Slope(SE)=&a g/week") offset=(0.2in, -0.4 in) frame;


proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;

proc gplot data= wt gout=wbh.graphs;
	plot estimate0*day estimate1*day1 estimate2*day2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
	note h=1 m=(7pct, 11.0 pct) "Day :" ;
	note h=1 m=(7pct, 9.75 pct) "(#No tx)" ;
	note h=1 m=(7pct, 8.50 pct) "(#Before tx)" ;
	note h=1 m=(7pct, 7.25 pct) "(#After tx)" ;

	format estimate0 estimate1 estimate2 4.0 day dd.;
run;


ods pdf file = "growth_all.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;

options orientation=portrait;
ods pdf style=journal;
proc print data=info  noobs label;
title "All LBWIs Growth Rate (n=&total)";
by group; id group/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];

var effect/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
var ms /style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label
		group="."
		effect="Effect"
		ms="Estimate &pm SE"
		/*probt="p value"*/
		;
run;

ods pdf close;


