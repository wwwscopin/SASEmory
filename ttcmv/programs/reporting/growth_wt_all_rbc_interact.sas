options orientation=portrait nodate nobyline nonumber;
libname wbh "/ttcmv/sas/programs";	
%let pm=%sysfunc(byte(177)); 
%let ds=%sysfunc(byte(167)); 
%let one=%sysfunc(byte(185)); 
%let two=%sysfunc(byte(178)); 

proc means data=cmv.plate_012 median;
var SNAPTotalScore;
output out=tmp median(SNAPTotalScore)=median;
run;

data _null_;
    set tmp;
    call symput("median",compress(median));
run;


proc format; value tx 0="No"	1="Yes";
       
value item 0="--"
           1="Gender"
           2="Race(only for Black and White)"
           3="Center"
           /*4="Anemia(Hemoglobin<=9 g/dL) before 1st pRBC transfusion"
             5="Anemia(Hemoglobin<=8 g/dL) before 1st pRBC transfusion"
           */
           4="SNAP at Birth"
           5="Any breast milk fed before 1st pRBC transfusion"
           6="Caffeine used before 1st pRBC transfusion"
           ;
value Anemic 0="Not Anemic" 1="Anemic";
value snapg  0="SNAP Score <=Median(&median)" 1="SNAP Score >Median";

run;

data hwl0;
	merge cmv.plate_008(keep=id MultipleBirth) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(rename=(dfseq=dday))
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	center=floor(id/1000000);
	if SNAPTotalScore>&median then snapg=1;else snapg=0;
	day=weightdate-lbwidob;
	keep id dday day Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth SNAPTotalScore
			LBWIDOB Gender  IsHispanic  Race RaceOther Hb HbDate Center snapg;
	rename SNAPTotalScore=snap LBWIDOB=dob;
run;

proc sql;
	create table hwl as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id dday;run;

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

proc sort data=tx nodupkey; by id dt; run;

data tx;
    set tx; by id;
    if first.id;
run;

data feed;
    merge cmv.bm_collection(keep=id DFSEQ BreastMilkObtained) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    retain age;
    if first.id then age=dt-dob;
    if dfseq<age or (dfseq=7 and age^=.) then feed=BreastMilkObtained;
    if feed=1;
run;
proc sort nodupkey; by id;run;


%macro conmed(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 9;
		center=floor(id/1000000);
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

		keep id center dose dosenumber EndDate Startdate Indication MedCode MedName Unit prn i ; 
run;
%mend;

%conmed(cmv.con_meds);quit;

data anemia;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if hbdate<=dt and 0<hb<=9;
   	keep id;
run;

data anemia8;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if hbdate<=dt and 0<hb<=8;
   	keep id;
run;

proc sort nodupkey; by id; run;

data cafe;
    merge tmp(where=(medcode=5) keep=id medcode enddate) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    if /*enddate-dob<=7 and*/ enddate<dt;
run;
proc sort nodupkey; by id;run;

data hwl hwl_base;
	merge hwl(in=hwl) tx(in=trans keep=id dt) feed(keep=id in=breast) cafe(keep=id in=cafe) anemia(in=A) anemia8(in=B); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	
	if breast then feed=1; else feed=0;
	if cafe then caffine=1;else caffine=0;
	if A then anemic=1; else anemic=0;
	if B then anemic8=1; else anemic8=0;
	
	daytx=WeightDate-dt;
	
    gtx=tx;

        if dday=1  then t=1;
        if dday=4  then t=2;
        if dday=7  then t=3;
        if dday=14 then t=4;
        if dday=21 then t=5;
        if dday=28 then t=6;
        if dday=40 then t=7;
        if dday=60 then t=8;
        
        st1=min(day,7);
        st2=max(0,day-7);
        
    	if dday=1 then output hwl_base;
    	output hwl;
run;

data hwl;
    set hwl(where=(tx=0) in=A) hwl(where=(daytx<0 and daytx^=.) in=B) hwl(where=(daytx>=0) in=C);
    if A then tx=0;
    if B then tx=1; 
    if C then tx=2;
run;

data _null_;
	set hwl_base;
	call symput("n", compress(_n_));
run;
%put &n;

proc freq data=hwl_base;
table tx;
ods ouput onewayfreqs=tmp;
run;

data _null_;
	set tmp;
    if tx=0 then call symput("t0", compress(frequency));
        if tx=1 then call symput("t1", compress(frequency));
run;

proc sort data=hwl nodupkey; by id dday weight;run;

proc means data=hwl ;
    	class tx dday;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or dday=. then delete;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if tx=0 and dday=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and dday=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and dday=60 then call symput( "n60",  compress(put(num_obs, 3.0)));

	if tx=1 and dday=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if tx=1 and dday=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if tx=1 and dday=60 then call symput( "b60",  compress(put(num_obs, 3.0)));

	if tx=2 and dday=1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if tx=2 and dday=14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if tx=2 and dday=60 then call symput( "a60",  compress(put(num_obs, 3.0)));
run;

%put &n1;
%put &b1;
%put &a1;

proc format;

value dt -1=" "  
 0=" " 1="1*(&n1)*(&b1)*(&a1)"  2=" " 3=" " 4 = "4*(&n4)*(&b4)*(&a4)" 5=" " 6=" " 7="7*(&n7)*(&b7)*(&a7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)*(&b14)*(&a14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&n21)*(&b21)*(&a21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)*(&b28)*(&a28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&n40)*-*(&a40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&n60)*-*(&a60)" ;
 
 value dd  0=" " 1="1"  2=" " 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60" ;

run;

proc sort data=hwl; by id tx t;run;
*****************************************************;
proc mixed data=hwl /*method=ml*/ ORDER=internal;
        class id tx;
        model weight=tx st1 st2 st1*tx st2*tx/s chisq;
       	random int st1 st2/type=un subject=id;

    
    estimate "No-Tx, intercept" int 1 tx 1 0 0/cl;
	estimate "No-Tx, Day1"   int 1 tx 1 0 0 st1 1   st1*tx 1  0 0;
	estimate "No-Tx, Day4"   int 1 tx 1 0 0 st1 4   st1*tx 4  0 0;
	estimate "No-Tx, Day7"   int 1 tx 1 0 0 st1 7   st1*tx 7  0 0;
	estimate "No-Tx, Day14"  int 1 tx 1 0 0 st2 7   st2*tx 7  0 0;
	estimate "No-Tx, Day21"  int 1 tx 1 0 0 st2 14  st2*tx 14 0 0;
	estimate "No-Tx, Day28"  int 1 tx 1 0 0 st2 21  st2*tx 21 0 0;
	estimate "No-Tx, Day40"  int 1 tx 1 0 0 st2 33  st2*tx 33 0 0;
	estimate "No-Tx, Day60"  int 1 tx 1 0 0 st2 53  st2*tx 53 0 0/e;

	estimate "Before, intercept" int 1 tx 0 1 0/cl;
	estimate "Before, Day1"   int 1 tx 0 1 0 st1 1   st1*tx 0 1  0;
	estimate "Before, Day4"   int 1 tx 0 1 0 st1 4   st1*tx 0 4  0;
	estimate "Before, Day7"   int 1 tx 0 1 0 st1 7   st1*tx 0 7  0;
	estimate "Before, Day14"  int 1 tx 0 1 0 st2 7   st2*tx 0 7 0;
	estimate "Before, Day21"  int 1 tx 0 1 0 st2 14  st2*tx 0 14 0;
	estimate "Before, Day28"  int 1 tx 0 1 0 st2 21  st2*tx 0 21 0;
	estimate "Before, Day40"  int 1 tx 0 1 0 st2 33  st2*tx 0 33 0;
	estimate "Before, Day60"  int 1 tx 0 1 0 st2 53  st2*tx 0 53 0/e;

	estimate "After, intercept" int 1 tx 0 0 1 /cl;
	estimate "After, Day1"   int 1 tx 0 0 1 st1 1   st1*tx 0 0 1  ;
	estimate "After, Day4"   int 1 tx 0 0 1 st1 4   st1*tx 0 0 4  ;
	estimate "After, Day7"   int 1 tx 0 0 1 st1 7   st1*tx 0 0 7  ;
	estimate "After, Day14"  int 1 tx 0 0 1 st2 7   st2*tx 0 0 7 ;
	estimate "After, Day21"  int 1 tx 0 0 1 st2 14  st2*tx 0 0 14 ;
	estimate "After, Day28"  int 1 tx 0 0 1 st2 21  st2*tx 0 0 21 ;
	estimate "After, Day40"  int 1 tx 0 0 1 st2 33  st2*tx 0 0 33 ;
	estimate "After, Day60"  int 1 tx 0 0 1 st2 53  st2*tx 0 0 53 /e;

	estimate "slope"  st2 1  st2*tx 1 0 0;
	estimate "slope"  st2 1  st2*tx 0 1 0;
	estimate "slope"  st2 1  st2*tx 0 0 1;
	estimate "Equale  slope" st2*tx 1 0 -1;
        *ods output Mixed.SolutionF=slope;
		ods output Mixed.Estimates=estimate_wt;
run;

data _null_;
    set estimate_wt;
   	if _n_=28 then call symputx("s0", put(estimate,4.1)||"("||compress(put(stderr,3.1))||")");
	if _n_=29 then call symputx("s1", put(estimate,4.1)||"("||compress(put(stderr,3.1))||")");
	if _n_=30 then call symputx("s2", put(estimate,4.1)||"("||compress(put(stderr,3.1))||")");

	if _n_=31 then do;
	    pv="p="||compress(put(probt, 7.3));
	    if probt<0.001 then pv="p<0.001";
        call symputx("pv", pv);
    end;
	
run;


data line_wt;
	set estimate_wt(firstobs=1);
	if _n_<=27;
	if find(label,"No-Tx", 't') then tx=0; 
		else if find(label,"Before")  then tx=1; else tx=2;
	if find(label,"intercept") then day=0; 
   	else dday= compress(scanq(label,2),'Day', ",")+0;
	dday1=dday+0.05;
	dday2=dday+0.25;
	
    *if dday>0;
	if lower<0 then lower=0;
	
	keep tx dday dday1 dday2 estimate upper lower;
run;

DATA anno0; 
	set line_wt;
	where tx=0;
	xsys='2'; ysys='2';  color='green';
	X=dday; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno1; 
	set line_wt;
	where tx=1;
	xsys='2'; ysys='2';  color='blue';
	X=dday1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

DATA anno2; 
	set line_wt;
	where tx=2;
	xsys='2'; ysys='2';  color='red';
	X=dday2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=dday2-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	X=dday2+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
  	X=dday2;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

proc contents;run;

data anno;
	set anno0 anno1(in=B) anno2;
	if B and dday>28 then delete;
run;

data wt;
	merge line_wt(where=(tx=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
			line_wt(where=(tx=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
			line_wt(where=(tx=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)); 
	by dday;
	if  dday>28 then do; estimate1=.; lower1=.; upper1=.; end;
run;


goptions reset=all  rotate=landscape device=jpeg  gunit=pct noborder cback=white
colors = (black red green blue)  ftext="Times" ftitle="Times"  hby = 3;

symbol1 interpol=spline mode=exclude value=circle co=green cv=green height=2 width=1;
symbol2 i=spline ci=blue value=dot co=blue cv=blue h=2 w=1;
symbol3 i=spline ci=red value=triangle co=red cv=red h=2 w=1;


axis1 	label=(h=2.5 "Age of LBWIs (days)" ) split="*"	value=(h=1.25)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
axis2 	label=(h=2.5 a=90 "Weight(g)") value=(h=2) order= (600 to 3000 by 100) offset=(.25 in, .25 in) minor=(number=1);
 
title1 	height=3 "All LBWIs Weight vs Age";
title2 	height=2.5  "(With pRBC Transfusion=&t1, Without pRBC Transfusion=&t0)";
title3 	height=2.5 "Test of equal slopes between 'No Tx' and 'After Tx', &pv";

%put &yes;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 "Without pRBC Transfusion, Slope(SE)=&s0 g/day" "Before 1st pRBC Transfusion, Slope(SE)=&s1 g/day" 
"After 1st pRBC Transfusion, Slope(SE)=&s2 g/day") offset=(0.2in, -0.4 in) frame;


proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;

proc gplot data= wt gout=wbh.graphs;
	plot estimate0*dday estimate1*dday1 estimate2*dday2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
	note h=1.25 m=(5pct, 11.25 pct) "Day :" ;
	note h=1.25 m=(5pct, 9.75 pct) "(#No tx)" ;
	note h=1.25 m=(5pct, 8.5 pct) "(#Before tx)" ;
	note h=1.25 m=(5pct, 7.25 pct) "(#After tx)" ;

	format estimate0 estimate1 estimate2 4.0 dday dt.;
run;

options orientation=landscape;
ods pdf file = "growth_rbc.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;
ods pdf close;

options orientation=portrait;

/*
%let t0n1= 0; %let t0n2= 0; %let t0n3= 0; %let t1n1= 0; %let t1n2= 0; %let t1n3=0; 
%let t0w1= 0; %let t0w2= 0; %let t0w3= 0; %let t1w1= 0; %let t1w2= 0; %let t1w3=0; 
*/

%macro test(data,out, varlist);

data &out;
    if 1=1 then delete;
run;

proc mixed data=&data covtest;
	class id tx;
	model weight=tx st1 st2 st1*tx st2*tx/s;
	random int st1 st2/type=un subject=id;
	estimate "int"  int 1 tx 1 0 0;
	estimate "int"  int 1 tx 0 1 0;
	estimate "int"  int 1 tx 0 0 1;
	estimate "slope" st2 1 st2*tx 1 0 0;
	estimate "slope" st2 1 st2*tx 0 1 0;
	estimate "slope" st2 1 st2*tx 0 0 1;
	estimate "Equal slope" st2*tx 1 0 -1;
	ods output Mixed.Estimates=slope0;
	ods output Mixed.Tests3=interaction;
run;

data _null_;
    set interaction(firstobs=5);
    call symput("pv",compress(put(probf,7.5)));
run;

data &out;
    length effect $100;
    set slope0;
    item=0;
    if _n_=1  then effect="Intercept--No Tx"; 
        if _n_=2  then effect="Intercept--Before 1st pRBC Tx"; 
            if _n_=3  then effect="Intercept--After 1st pRBC Tx"; 
    if _n_=4  then  do; effect="No pRBC Transfusion Slope (g/day)"; probt=&pv; end; else if _n_^=7 then do; probt=.; end;
    if _n_=5  then  effect="Before 1st pRBC Transfusion Slope (g/day)";
    if _n_=6  then  effect="After 1st pRBC Transfusion Slope (g/day)";
    if _n_=7  then  do; effect="Test equal slope between No pRBC Transfusion and After 1st pRBC Transfusion"; probt=probt; end;
run;


%let i=1;
%let var=%scan(&varlist, &i);

%do %while(&var NE );

data tmp;
    set &data;
    %if &var=race %then %do; where race in(1,3); %end;
run;

proc sort data=&data out=wbh nodupkey; by id &var;

proc means data=wbh;
class gtx &var; 
var id; 
ods output means.summary=tt1;
run;

proc means data=tmp(where=(day>7));
class gtx &var; 
var weight; 
ods output means.summary=tt2;
run;


data _null_;
    set tt1;
    %if &var=gender %then %do;
    if gtx=0 and gender=1 then call symput("t0n1", compress(nobs));
    if gtx=0 and gender=2 then call symput("t0n2", compress(nobs));
    if gtx=1 and gender=1 then call symput("t1n1", compress(nobs));
    if gtx=1 and gender=2 then call symput("t1n2", compress(nobs));
    %end;
   
    %if &var=race %then %do; 
    if gtx=0 and race=1 then call symput("t0n1", compress(nobs));
    if gtx=0 and race=3 then call symput("t0n2", compress(nobs));
    if gtx=1 and race=1 then call symput("t1n1", compress(nobs));
    if gtx=1 and race=3 then call symput("t1n2", compress(nobs));
    %end;
    
    %if &var=snapg %then %do; 
    if gtx=0 and snapg=0 then call symput("t0n1", compress(nobs));
    if gtx=0 and snapg=1 then call symput("t0n2", compress(nobs));
    if gtx=1 and snapg=0 then call symput("t1n1", compress(nobs));
    if gtx=1 and snapg=1 then call symput("t1n2", compress(nobs));
    %end;
 
    %if &var=center %then %do; 
    if gtx=0 and center=1 then call symput("t0n1", compress(nobs));
    if gtx=0 and center=2 then call symput("t0n2", compress(nobs));
    if gtx=0 and center=3 then call symput("t0n3", compress(nobs));
    if gtx=1 and center=1 then call symput("t1n1", compress(nobs));
    if gtx=1 and center=2 then call symput("t1n2", compress(nobs));
    if gtx=1 and center=3 then call symput("t1n3", compress(nobs));
    %end;

run;


%put &t0n1;

data _null_;
    set tt2;
    %if &var=gender %then %do; 
    if gtx=0 and gender=1 then call symput("t0w1", put(weight_mean,7.2));
    if gtx=0 and gender=2 then call symput("t0w2", put(weight_mean,7.2));
    if gtx=1 and gender=1 then call symput("t1w1", put(weight_mean,7.2));
    if gtx=1 and gender=2 then call symput("t1w2", put(weight_mean,7.2));
    %end;
    
    %if &var=race %then %do; 
    if gtx=0 and race=1 then call symput("t0w1", put(weight_mean,7.2));
    if gtx=0 and race=3 then call symput("t0w2", put(weight_mean,7.2));
    if gtx=1 and race=1 then call symput("t1w1", put(weight_mean,7.2));
    if gtx=1 and race=3 then call symput("t1w2", put(weight_mean,7.2));
    %end;
    
    %if &var=snapg %then %do; 
    if gtx=0 and snapg=0 then call symput("t0w1", put(weight_mean,7.2));
    if gtx=0 and snapg=1 then call symput("t0w2", put(weight_mean,7.2));
    if gtx=1 and snapg=0 then call symput("t1w1", put(weight_mean,7.2));
    if gtx=1 and snapg=1 then call symput("t1w2", put(weight_mean,7.2));
    %end;
 
    %if &var=center %then %do; 
    if gtx=0 and center=1 then call symput("t0w1", put(weight_mean,7.2));
    if gtx=0 and center=2 then call symput("t0w2", put(weight_mean,7.2));
    if gtx=0 and center=3 then call symput("t0w3", put(weight_mean,7.2));
    if gtx=1 and center=1 then call symput("t1w1", put(weight_mean,7.2));
    if gtx=1 and center=2 then call symput("t1w2", put(weight_mean,7.2));
    if gtx=1 and center=3 then call symput("t1w3", put(weight_mean,7.2));
    %end;
run;

*ods trace on/label listing;
proc mixed /*method=ml*/ data=tmp covtest;
	class id tx &var;
	model weight=tx &var tx*&var st1 st2 st2*tx st2*&var st2*tx*&var /s chisq;
	random int st1 st2/type=un subject=id;

    %if &var^=center %then %do; 
	
	estimate "int0" int 1 tx 1 0 0 &var 1 0 tx*&var 1 0 0 0 0 0; 
	estimate "int0" int 1 tx 1 0 0 &var 0 1 tx*&var 0 1 0 0 0 0; 
	estimate "int1" int 1 tx 0 1 0 &var 1 0 tx*&var 0 0 1 0 0 0;
	estimate "int1" int 1 tx 0 1 0 &var 0 1 tx*&var 0 0 0 1 0 0;
	estimate "int2" int 1 tx 0 0 1 &var 1 0 tx*&var 0 0 0 0 1 0;
	estimate "int2" int 1 tx 0 0 1 &var 0 1 tx*&var 0 0 0 0 0 1;
	estimate "slope" st2 1 st2*tx 1 0 0 st2*&var 1 0 st2*tx*&var 1 0 0 0 0 0;
	estimate "slope" st2 1 st2*tx 1 0 0 st2*&var 0 1 st2*tx*&var 0 1 0 0 0 0;
	estimate "slope" st2 1 st2*tx 0 1 0 st2*&var 1 0 st2*tx*&var 0 0 1 0 0 0;
	estimate "slope" st2 1 st2*tx 0 1 0 st2*&var 0 1 st2*tx*&var 0 0 0 1 0 0;
	estimate "slope" st2 1 st2*tx 0 0 1 st2*&var 1 0 st2*tx*&var 0 0 0 0 1 0;
	estimate "slope" st2 1 st2*tx 0 0 1 st2*&var 0 1 st2*tx*&var 0 0 0 0 0 1;
	%end;
	
	
	%else %do;
	estimate "int0" int 1 tx 1 0 0 &var 1 0 0 tx*&var 1 0 0 0 0 0 0 0 0 ;  
	estimate "int0" int 1 tx 1 0 0 &var 0 1 0 tx*&var 0 1 0 0 0 0 0 0 0 ; 
	estimate "int0" int 1 tx 1 0 0 &var 0 0 1 tx*&var 0 0 1 0 0 0 0 0 0 ; 
	estimate "int1" int 1 tx 0 1 0 &var 1 0 0 tx*&var 0 0 0 1 0 0 0 0 0 ; 
	estimate "int1" int 1 tx 0 1 0 &var 0 1 0 tx*&var 0 0 0 0 1 0 0 0 0 ; 
	estimate "int1" int 1 tx 0 1 0 &var 0 0 1 tx*&var 0 0 0 0 0 1 0 0 0 ;  
	estimate "int2" int 1 tx 0 0 1 &var 1 0 0 tx*&var 0 0 0 0 0 0 1 0 0 ; 
	estimate "int2" int 1 tx 0 0 1 &var 0 1 0 tx*&var 0 0 0 0 0 0 0 1 0 ; 
	estimate "int2" int 1 tx 0 0 1 &var 0 0 1 tx*&var 0 0 0 0 0 0 0 0 1 ; 

	estimate "slope" st2 1 st2*tx 1 0 0 &var*st2 1 0 0 st2*tx*&var 1 0 0 0 0 0 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 1 0 0 &var*st2 0 1 0 st2*tx*&var 0 1 0 0 0 0 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 1 0 0 &var*st2 0 0 1 st2*tx*&var 0 0 1 0 0 0 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 0 1 0 &var*st2 1 0 0 st2*tx*&var 0 0 0 1 0 0 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 0 1 0 &var*st2 0 1 0 st2*tx*&var 0 0 0 0 1 0 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 0 1 0 &var*st2 0 0 1 st2*tx*&var 0 0 0 0 0 1 0 0 0 ; 
	estimate "slope" st2 1 st2*tx 0 0 1 &var*st2 1 0 0 st2*tx*&var 0 0 0 0 0 0 1 0 0 ; 
	estimate "slope" st2 1 st2*tx 0 0 1 &var*st2 0 1 0 st2*tx*&var 0 0 0 0 0 0 0 1 0 ; 
	estimate "slope" st2 1 st2*tx 0 0 1 &var*st2 0 0 1 st2*tx*&var 0 0 0 0 0 0 0 0 1 ; 
	%end;

	ods output Mixed.Estimates=slope;
	ods output Mixed.Tests3=interaction;
run;
*ods trace off;

data _null_;
    set interaction;
    if _n_=8;
    call symput("pv",compress(put(probf,7.5)));
run;

%put &pv;

data est;
    length effect $60;
    set slope;
    
    %if &var=gender %then %do;
    %let var1=Male;
    %let var2=Female;
    %end;
    
    %if  &var=race %then %do;
    %let var1=Black;
    %let var2=White;
    %end;
  
    %if  &var=center %then %do;
    %let var1=Midtown;
    %let var2=Grady;
    %let var3=Northside;
    %end;        
    
    %if  &var=anemic or &var=anemic8 %then %do;
    %let var1=Not Anemic;
    %let var2=Anemic;
    %end;
    
    %if  &var=snapg %then %do;
    %let var1=SNAP score <=Median(&median);
    %let var2=SNAP score >Median(&median);
    %end;
    
    item=&i;  
    
    %if &var^=center %then %do; 
    if _n_=1  then   effect="Intercept --No Tx + &var1 (n=&t0n1)"; 
    if _n_=2  then   effect="Intercept --No Tx + &var2 (n=&t0n2)"; 
    if _n_=3  then   effect="Intercept --Before Tx + &var1 (n=&t1n1)"; 
    if _n_=4  then   effect="Intercept --Before Tx + &var2 (n=&t1n2)"; 
    if _n_=5  then   effect="Intercept --After Tx + &var1 (n=&t1n1)"; 
    if _n_=6  then   effect="Intercept --After Tx + &var2 (n=&t1n2)"; 
    if _n_=7  then do;  effect="slope --No Tx + &var1";  probt=&pv; end; else do; probt=.; end;
    if _n_=8  then   effect="slope --No Tx + &var2";     
    if _n_=9  then   effect="slope --Before Tx + &var1"; 
    if _n_=10  then   effect="slope --Before Tx + &var2";  
    if _n_=11  then   effect="slope --After Tx + &var1"; 
    if _n_=12  then   effect="slope --After Tx + &var2";  
    %end;

    %else %do; 
    if _n_=1  then   effect="Intercept --No Tx + &var1 (n=&t0n1)"; 
    if _n_=2  then   effect="Intercept --No Tx + &var2 (n=&t0n2)"; 
    if _n_=3  then   effect="Intercept --No Tx + &var3 (n=&t0n3)"; 
    if _n_=4  then   effect="Intercept --Before Tx + &var1 (n=&t1n1)"; 
    if _n_=5  then   effect="Intercept --Before Tx + &var2 (n=&t1n2)"; 
    if _n_=6  then   effect="Intercept --Before Tx + &var3 (n=&t1n3)"; 
    if _n_=7  then   effect="Intercept --After Tx + &var1 (n=&t1n1)"; 
    if _n_=8  then   effect="Intercept --After Tx + &var2 (n=&t1n2)"; 
    if _n_=9  then   effect="Intercept --After Tx + &var3 (n=&t1n3)"; 
    if _n_=10  then do;  effect="slope --No Tx + &var1";  probt=&pv; end; else do; probt=.; end;
    if _n_=11  then   effect="slope --No Tx + &var2";     
    if _n_=12  then   effect="slope --No Tx + &var3";     
    if _n_=13  then   effect="slope --Before Tx + &var1"; 
    if _n_=14  then   effect="slope --Before Tx + &var2";  
    if _n_=15  then   effect="slope --Before Tx + &var3"; 
    if _n_=16  then   effect="slope --After Tx + &var1"; 
    if _n_=17  then   effect="slope --After Tx + &var2";  
    if _n_=18  then   effect="slope --After Tx + &var3";  
    %end;
   
run;

data &out;

    set &out est;
    
    estd=compress(put(estimate,7.1)||"&pm"||put(stderr,5.1));
    if label='int1' or label='int2' or label='int0' or label='int' then do;
        estd=compress(put(estimate,7.0)||"&pm"||put(stderr,5.0));
        probt=.;
    end;
    

    if stderr=. then delete;
         
    keep effect label code Estimate StdErr estd Probt item;
run;


%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;
%mend;

%let varlist=gender race  center anemic anemic8 snapg;
%let varlist=gender race  center snapg;
*%let varlist=gender;
*ods trace on/label listing;
%test(hwl, tab, &varlist);
*ods trace off;


data tab;
    length pv $6;
    set tab; by item; 

    if first.item then  item0=put(item, item.); else item0=" ";
    if probt^=. then do; if probt<0.001 then pv="<0.001"; else pv=put(probt,7.4); end;
    else pv=" ";
run;

data tab;
    set tab; by item; output;
    retain tmp;
    if last.item then do; Call missing( of _all_ ); output; end;
run;

ods rtf file="Interaction_rbc_var.rtf" style=journal bodytitle;
proc print data=tab noobs label;
title "Growth Rate Analysis after 7 days (no Tx=&t0, Tx=&t1)";
id item0/style(data)=[just=left width=1.5in] style(header)=[just=left];
var effect/style(data)=[just=left width=3.5in] style(header)=[just=left];
var estd/style(data)=[just=center width=1in] style(header)=[just=center];
var pv/style(data)=[just=center width=0.6in] style(header)=[just=center];
label 
    item0="Item"
    effect="Effect"
    Par="Parameter"
    estd="Estimate &pm SE"
    pv="p value";
run;
/*
ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=10pt}
* Median age at 1^{super st} pRBC transfusion: &medage days.
^n 1. Weight at time of 1^{super st} pRBC transfusion.
^n 2. Growth velocity after 1^{super st} pRBC transfusion is greater if anemic before 1^{super st} pRBC transfusion compared to LBWIs who are not anemic before 1^{super st} pRBC transfusion.";
*/
ods rtf close;
