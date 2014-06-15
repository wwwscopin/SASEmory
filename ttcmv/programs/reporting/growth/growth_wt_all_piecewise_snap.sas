options orientation=landscape nodate nobyline nonumber;
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
           4="Anemia(Hemoglobin<=9 g/dL) before 1st pRBC transfusion"
           5="SNAP at Birth"
           6="Any breast milk fed before 1st pRBC transfusion"
           7="Caffine used in 1st week"
           ;
value Anemic 0="Not Anemic" 1="Anemic";
value snapg  0="SNAP Score <=Median(&median)" 1="SNAP Score >Median";

run;

data hwl0;
	merge cmv.plate_008(keep=id MultipleBirth) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(rename=(dfseq=day))
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	center=floor(id/1000000);
	if SNAPTotalScore>&median then snapg=1;else snapg=0;
	keep id day Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth SNAPTotalScore
			LBWIDOB Gender  IsHispanic  Race RaceOther Hb HbDate Center snapg;
	rename SNAPTotalScore=snap LBWIDOB=dob;
run;

proc sql;
	create table hwl as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id hb DateTransfusion rename=(DateTransfusion=date_rbc))
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
data tx;
    set tx; by id dt;
    if first.id;
    rename hb=hb0;
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

		keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
run;
%mend;

%conmed(cmv.con_meds);quit;


data cafe;
    merge tmp(where=(medcode=5) keep=id medcode enddate) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob)); by id;
    if enddate-dob<=7;
run;
proc sort nodupkey; by id;run;

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt) feed(keep=id in=breast) cafe(keep=id in=cafe); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	if breast then feed=1; else feed=0;
	if cafe then caffine=1;else caffine=0;
	
	daytx0=WeightDate-dt;
	
	age=dt-dob;

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

proc means data=hwl_tx(where=(day>7));
class snapg;
var weight;
ods output means.summary=avg;
run;


data _null_;
    set avg;
    if snapg=0 then call symput("avg0", put(Weight_Mean,5.0));
        if snapg=1 then call symput("avg1", put(Weight_Mean,5.0));
run;


data hwl_id;
	set hwl_tx; 
	keep id snapg;
run;

proc sort nodupkey; by id;run;
	
proc freq data=hwl_id;
	tables snapg;
	ods output onewayfreqs=tab;
run;

data _null_;
	set tab;
	if snapg=0 then call symput("no", compress(frequency));
	if snapg=1 then call symput("yes",compress(frequency));
run;
%let total=%eval(&yes+&no);

data  hwl_tx;
	set hwl_tx(drop=day);
	if daytx0<=0 then tx=0; else tx=1;
	rename daytx0=day;
	d1=min(daytx0,0);
	d2=max(daytx0,0);
run;

proc sort nodupkey out=hwl_id; by tx id daytx;run;

proc means data=hwl_id median;
    	var age;
 		output out =median_age median(age)=med_age;
run;

data _null_;
    set median_age;
    call symput("medage", compress(med_age));
run;

proc means data=hwl_id ;
    	class snapg daytx;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if snapg=. or daytx=. then delete;
run;

%let a0= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let b0= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;
%let c0= 0; %let c1= 0; %let c4= 0; %let c7= 0; %let c14= 0; %let c21= 0; %let c28=0; %let c40= 0;  %let c60=0;
%let d0= 0; %let d1= 0; %let d4= 0; %let d7= 0; %let d14= 0; %let d21= 0; %let d28=0; %let d40= 0;  %let d60=0;

data _null_;
	set num_wt;
	if snapg=0 then do;
	if daytx=0   then call symput( "a0",   compress(put(num_obs, 3.0)));
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
	end;
	
	if snapg=1 then do;
	if daytx=0   then call symput( "c0",   compress(put(num_obs, 3.0)));
	if daytx=-1  then call symput( "c1",   compress(put(num_obs, 3.0)));
	if daytx=-4  then call symput( "c4",   compress(put(num_obs, 3.0)));
	if daytx=-7  then call symput( "c7",   compress(put(num_obs, 3.0)));
	if daytx=-14 then call symput( "c14",  compress(put(num_obs, 3.0)));
	if daytx=-21 then call symput( "c21",  compress(put(num_obs, 3.0)));
	if daytx=-28 then call symput( "c28",  compress(put(num_obs, 3.0)));
	if daytx=-40 then call symput( "c40",  compress(put(num_obs, 3.0)));
	if daytx=-60 then call symput( "c60",  compress(put(num_obs, 3.0)));

	if daytx=1  then call symput( "d1",   compress(put(num_obs, 3.0)));
	if daytx=4  then call symput( "d4",   compress(put(num_obs, 3.0)));
	if daytx=7  then call symput( "d7",   compress(put(num_obs, 3.0)));
	if daytx=14 then call symput( "d14",  compress(put(num_obs, 3.0)));
	if daytx=21 then call symput( "d21",  compress(put(num_obs, 3.0)));
	if daytx=28 then call symput( "d28",  compress(put(num_obs, 3.0)));
	if daytx=40 then call symput( "d40",  compress(put(num_obs, 3.0)));
	if daytx=60 then call symput( "d60",  compress(put(num_obs, 3.0)));
	end;
run;

proc format;

value dt   
			-41=" " -40="-40*&a40*&c40" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28*&a28*&c28" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21*&a21*&c21" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14*&a14*&c14" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7*&a7*&c7*" -6=" " - 5=" "  -4="-4*&a4*&c4"  -3=" "   
			-2=" "  -1=" " 0= "0*&a0*&c0"  1=" "  2=" " 3=" " 4="4*&b4*&d4" 5=" " 6=" " 7="7*&b7*&d7" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14*&b14*&d14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21*&b21*&d21"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*&b28*&d28"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40*&b40*&d40" ;
			
value dd   
			-41=" " -40="-40" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7" -6=" " - 5=" "  -4="-4"  -3=" "   
			-2=" "  -1=" " 0= "0"  1=" "  2=" " 3=" " 4="4" 5=" " 6=" " 7="7" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40" ;

value idx 0="Without pRBC Transfusion (n=&no)" 1="With pRBC Transfusion (n=&yes)";

value tx 0="No"	1="Yes"	;

run;

proc mixed /*method=ml*/ data=hwl_tx covtest;
	class id snapg;
	model weight=d1 d2 snapg snapg*d2/s;
	random int d1 d2/type=un subject=id;
	
	estimate "No, Day-40"  int 1 d1 -40 snapg 1 0 ;  
	estimate "No, Day-28"  int 1 d1 -28 snapg 1 0 ;  
	estimate "No, Day-21"  int 1 d1 -21 snapg 1 0 ; 
	estimate "No, Day-14"  int 1 d1 -14 snapg 1 0 ;
	estimate "No, Day-7"   int 1 d1 -7  snapg 1 0 ; 
	estimate "No, Day-4"   int 1 d1 -4  snapg 1 0 ;   	 
	estimate "No, Day-1"   int 1 d1 -1  snapg 1 0 ;  
 	estimate "No, Day0"    int 1 d1 0   snapg 1 0 ;

	estimate "No, Day1"   int 1 d2 1     snapg 1 0 snapg*d2    1 0;  
	estimate "No, Day4"   int 1 d2 4     snapg 1 0 snapg*d2    4 0;  
	estimate "No, Day7"   int 1 d2 7     snapg 1 0 snapg*d2    7 0; 
	estimate "No, Day14"  int 1 d2 14    snapg 1 0 snapg*d2   14 0;  
	estimate "No, Day21"  int 1 d2 21    snapg 1 0 snapg*d2   21 0;  
	estimate "No, Day28"  int 1 d2 28    snapg 1 0 snapg*d2   28 0;  
	estimate "No, Day40"  int 1 d2 40    snapg 1 0 snapg*d2   40 0;  	
 	 	 	
 	estimate "Yes, Day-40"  int 1 d1 -40 snapg 0 1 ;  
	estimate "Yes, Day-28"  int 1 d1 -28 snapg 0 1 ;  
	estimate "Yes, Day-21"  int 1 d1 -21 snapg 0 1 ; 
	estimate "Yes, Day-14"  int 1 d1 -14 snapg 0 1 ;
	estimate "Yes, Day-7"   int 1 d1 -7  snapg 0 1 ; 
	estimate "Yes, Day-4"   int 1 d1 -4  snapg 0 1 ;   	 
	estimate "Yes, Day-1"   int 1 d1 -1  snapg 0 1 ;  
 	estimate "Yes, Day0"    int 1 d1 0   snapg 0 1 ;
 	
	estimate "Yes, Day1"   int 1 d2 1     snapg 0 1 snapg*d2   0 1;  
	estimate "Yes, Day4"   int 1 d2 4     snapg 0 1 snapg*d2   0 4;  
	estimate "Yes, Day7"   int 1 d2 7     snapg 0 1 snapg*d2   0 7; 
	estimate "Yes, Day14"  int 1 d2 14    snapg 0 1 snapg*d2   0 14;  
	estimate "Yes, Day21"  int 1 d2 21    snapg 0 1 snapg*d2   0 21;  
	estimate "Yes, Day28"  int 1 d2 28    snapg 0 1 snapg*d2   0 28;  
	estimate "Yes, Day40"  int 1 d2 40    snapg 0 1 snapg*d2   0 40/cl;  
	
	estimate "post1" d2 1 snapg*d2 1 0;
	estimate "post2" d2 1 snapg*d2 0 1;
			estimate "pv" snapg*d2 1 -1;

	ods output Mixed.Estimates=estimate1;
run;

data line_wt;
	set estimate1;
	day= compress(scan(label,2,","),"Day")+0;
	if scan(label, 1,",")="No" then group=0; 
	if scan(label, 1,",")="Yes" then group=1;
	
	*if scan(label, 1,",")="post1" then call symput("s1", compress(put(estimate/&avg0*1000,7.1)||"&pm"||put(stderr/&avg0*1000,5.1)));
	*if scan(label, 1,",")="post2" then call symput("s2", compress(put(estimate/&avg1*1000,7.1)||"&pm"||put(stderr/&avg1*1000,5.1)));
	
	if scan(label, 1,",")="post1" then call symput("s1", compress(put(estimate,7.1)||"&pm"||put(stderr,5.1)));
	if scan(label, 1,",")="post2" then call symput("s2", compress(put(estimate,7.1)||"&pm"||put(stderr,5.1)));

    length pv $8;
	if scan(label, 1,",")="pv" then do; if probt<=0.001 then pv="<0.001"; else pv=put(probt, 7.3);  call symput("pv", compress(pv)); end;
	
	day1=day+0.25;

	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
	keep day day1 estimate upper lower group;
run;

proc sort; by group day;run;

DATA anno0; 
	set line_wt;
	where group=0;
	xsys='2'; ysys='2';  color='blue';
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

data anno0A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt;
		where group=0;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

/*
data anno0;
	length color $6 function $8;
	set anno0 anno0A;
run;
*/

DATA anno1; 
	set line_wt;
	where group=1;
	xsys='2'; ysys='2';  color='red';
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

data anno1A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt;
		where group=1;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;
/*
data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;
*/
data anno;
	set anno0 anno1;
run;

data wt;
	merge line_wt(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
			line_wt(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
    ;
	by day;
run;


goptions reset=all  rotate=landscape device=jpeg  gunit=pct noborder cback=white
colors = (black red green blue)  ftext="Times"  hby = 3;

symbol1 interpol=spline mode=exclude value=circle co=blue cv=blue height=2 width=1;
symbol2 i=spline ci=red value=dot co=red cv=red h=2 w=1;


axis1 	label=(h=2.5 "Pre and Post 1st pRBC Transfusion (days)" ) split="*"	value=(h=1.25)  order= (-41 to 41 by 1) minor=none offset=(0 in, 0 in);

axis2 	label=(h=2.5 a=90 "Weight(g)") value=(h=2) order= (400 to 2400 by 100) offset=(.25 in, .25 in) minor=(number=1);
 
title1 	height=3 "All LBWIs Weight vs Pre and Post 1st pRBC Transfusion";
title2 	height=2.5 "n(SNAP>Median(&median))=&yes, n(SNAP<=Median(&median))=&no";
title3 	height=2.5 "Test of equal slopes for post 1st pRBC transfusion, p=&pv";

%put &yes;

legend across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 c=black "SNAP<=Median(&median), Slope(SE)=&s1 g/day" "SNAP>Median(&median), Slope(SE)=&s2 g/day") offset=(-0.2in, -0.4 in) frame;


proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;

proc gplot data= wt gout=wbh.graphs;
	plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
	
	*		note h=3 m=(30pct, 5 pct) "Pre and Post 1st pRBC Transfusion (days)" ;
			
	note h=1.25 m=(0pct, 10.5 pct) "Day :" ;
	note h=1.25 m=(0pct, 9 pct) "(#SNAP>Median)" ;
	note h=1.25 m=(0pct, 7.5 pct) "(#SNAP<=Median)" ;

	format estimate0 estimate1 4.0 day dt.;
run;

goptions reset=all;
ods pdf file = "growth_snap.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:1;
run;
ods pdf close;
