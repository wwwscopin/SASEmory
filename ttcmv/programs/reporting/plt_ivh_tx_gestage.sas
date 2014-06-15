options ORIENTATION="LANDSCAPE" nonumber nodate;
libname wbh "/ttcmv/sas/porgrams";	
%let mu=%sysfunc(byte(181));
%let pm=%sysfunc(byte(177));

proc format;
		value tc 0="Not Thrombocytopenia" 1="Thrombocytopenia";
		value tx 
		0="No"
		1="Yes"
		;


		value dd -1=" " 2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" " 36=" " 37=" " 38=" " 39=" " 41=" "
		42=" " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" "
		61=" " 0="0" 1="1" 7="7" 14="14" 21="21" 28="28" 40="40" 60="60"
		;
run;



data plt0;
	set cmv.plate_015 
		 cmv.plate_033(keep=id PlateletCount DatePlateletCount rename=(DatePlateletCount=pltdate PlateletCount=platelet));
	
	if platelet=. then delete;
	if pltdate=. then pltdate=BloodCollectDate;
	if Platelet>150 then tc=0; else if Platelet^=. then tc=1;
	*rename dfseq=day;
	keep id pltDate platelet tc dfseq ;
	format tc tc.;
run;

proc sort nodupkey; by id pltdate platelet;run;

**********************************************************************************************;
data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;

	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
    keep id ivh imagedate;
run;

data tx;
	set /*cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime in=A)*/
			cmv.plate_033(keep=id DateTransfusion plt_TxStartTime in=B)
			/*cmv.plate_035(keep=id DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DateTransfusion; run;
data tx; 
    merge tx ivh2(in=temp); by id;
    if temp then if DateTransfusion<imagedate;
    keep id;
run;
proc sort nodupkey; by id; run;



***********************************************************************************************;

data ivh;
	merge plt0 ivh2 tx(in=tmp keep=id) cmv.comp_pat(in=comp keep=id gender dob) cmv.plate_006(keep=id gestage); by id;
	if comp;
	day=pltdate-dob;
	
	if tmp then tx=1; else tx=0;
	if pltdate>=imagedate and ivh=1 then platelet=.;
    if platelet=. then delete;
    if ivh=. then if tx=0 then ivh=0; else ivh=2;
 	format gender gender. idate mmddyy8.;
run;

proc means data=ivh mean;
    var gestage;
    output out=test;
run;


data _null_;
    set test;
    if _n_=4;
    call symput("nage", compress(put(gestage, 4.1)));
run;

%put &nage;

proc means data=ivh;
	class ivh;
	var id;
	output out=ivh_obs n(id)=n;
run;

data _null_;
	set ivh_obs;
	if ivh=0 then call symput("m0",compress(n));
	if ivh=1 then call symput("m1",compress(n));
	if ivh=2 then call symput("m2",compress(n));
run;

proc sort data=ivh nodupkey out=ivh_id; by id;run;

proc means data=ivh_id;
	class ivh;
	var id;
	output out=ivh_num n(id)=n;
run;

data _null_;
	set ivh_num;
	if ivh=0 then call symput("n0",compress(n));
	if ivh=1 then call symput("n1",compress(n));
	if ivh=2 then call symput("n2",compress(n));
run;

/*
data ivh_only;
    set ivh(where=(ivh=1));
    onday=idate-dob;
    if leftivhgrade=99 then leftivhgrade=.;
    if rightivhgrade=99 then rightivhgrade=.;
run;

proc sort nodupkey; by id; run;

ods rtf file="ivh_day.rtf" style=journal bodytitle;
proc print data=ivh_only label;
title "Days on IVH Diagnosed Date (n=&yes_ivh)";
var id imagedate dob onday leftivhgrade rightivhgrade/style=[cellwidth=1.25in just=center];
label id="LBWI ID"
      imagedate="IVH DiagDate"
      dob="Birthday"
      onday="Days from Birthday to IVH DiagDate"
      leftivhgrade="Left IVH Grade"
      rightivhgrade="Right IVH Grade"
      ;
run;
ods rtf close;
*/
proc sort data=ivh nodupkey; by id pltdate; run;

proc means data=ivh;
	class ivh dfseq;
	var id;
	output out=wbh;
run;


%let a1= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b1= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;
%let c0= 0; %let c1= 0; %let c4= 0; %let c7= 0; %let c14= 0; %let c21= 0; %let c28=0; %let c40=0;  %let c60=0;

data _null_;
	set wbh;
	if ivh=0 and dfseq=1  then call symput( "a1",   compress(_freq_));
	if ivh=0 and dfseq=4  then call symput( "a4",   compress(_freq_));
	if ivh=0 and dfseq=7  then call symput( "a7",   compress(_freq_));
	if ivh=0 and dfseq=14 then call symput( "a14",  compress(_freq_));
	if ivh=0 and dfseq=21 then call symput( "a21",  compress(_freq_));
	if ivh=0 and dfseq=28 then call symput( "a28",  compress(_freq_));
	if ivh=0 and dfseq=40 then call symput( "a40",  compress(_freq_));
	if ivh=0 and dfseq=60 then call symput( "a60",  compress(_freq_));

	if ivh=1 and dfseq=1  then call symput( "b1",   compress(_freq_));
	if ivh=1 and dfseq=4  then call symput( "b4",   compress(_freq_));
	if ivh=1 and dfseq=7  then call symput( "b7",   compress(_freq_));
	if ivh=1 and dfseq=14 then call symput( "b14",  compress(_freq_));
	if ivh=1 and dfseq=21 then call symput( "b21",  compress(_freq_));
	if ivh=1 and dfseq=28 then call symput( "b28",  compress(_freq_));
	if ivh=1 and dfseq=40 then call symput( "b40",  compress(_freq_));
	if ivh=1 and dfseq=60 then call symput( "b60",  compress(_freq_));
	
	if ivh=2 and dfseq=1  then call symput( "c1",   compress(_freq_));
	if ivh=2 and dfseq=4  then call symput( "c4",   compress(_freq_));
	if ivh=2 and dfseq=7  then call symput( "c7",   compress(_freq_));
	if ivh=2 and dfseq=14 then call symput( "c14",  compress(_freq_));
	if ivh=2 and dfseq=21 then call symput( "c21",  compress(_freq_));
	if ivh=2 and dfseq=28 then call symput( "c28",  compress(_freq_));
	if ivh=2 and dfseq=40 then call symput( "c40",  compress(_freq_));
	if ivh=2 and dfseq=60 then call symput( "c60",  compress(_freq_));
run;

proc format;

value dt   
 0="0" 1="1"  2=" " 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "60" ;
 
value dta   
  0=" " 1="&a1"  2=" " 3=" " 4 = "&a4" 5=" " 6=" " 7="&a7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&a14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&a21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&a28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&a40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&a60" ;
 

value dtb   
  0=" " 1="&b1"  2=" " 3=" " 4 = "&b4" 5=" " 6=" " 7="&b7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&b14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&b21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&b28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&b40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&b60" ;

value dtc   
  0=" " 1="&c1"  2=" " 3=" " 4 = "&c4" 5=" " 6=" " 7="&c7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&c14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&c21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&c28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&c40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&c60" ;
  
value dd   
  0=" " 1=" "  2=" " 3=" " 4 = " " 5=" " 6=" " 7=" " 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = " " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21=" " 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = " "  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40=" " 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = " " ;
  
run;


*ods trace on/label listing;
proc mixed method=ml data=ivh covtest;
	class id ivh;
	model platelet=ivh day ivh*day gestage/s;
	*random int day/type=un subject=id;
	random int/type=un subject=id;
	estimate "No tx, slope" day 1 ivh*day 1 0 0;
	estimate "Yes IVH, slope" day 1 ivh*day 0 1 0;
	estimate "Yes tx, slope" day 1 ivh*day 0 0 1;
	estimate "Compare slopes between tx vs no-tx" ivh*day 1 0 -1;
	estimate "Compare slopes between no-tx vs IVH" ivh*day 1 -1 0;
    estimate "Compare slopes between yes-tx vs IVH" ivh*day 0  1 -1;

	estimate "Compare intercept between tx vs no-tx" ivh 1 0 -1;
	estimate "Compare intercept between no-tx vs IVH" ivh 1 -1 0;
    estimate "Compare intercept between yes-tx vs IVH" ivh 0  1 -1;
/*
	estimate "Compare day1 between tx vs no-tx" ivh 1 0 -1 ivh*day 1 0 -1;
	estimate "Compare day1 between no-tx vs IVH" ivh 1 -1 0 ivh*day 1 -1 0;
    estimate "Compare day1 between yes-tx vs IVH" ivh 0  1 -1 ivh*day 0 1 -1;

	estimate "Compare day4 between tx vs no-tx" ivh 1 0 -1 ivh*day 4 0 -4;
	estimate "Compare day4 between no-tx vs IVH" ivh 1 -1 0 ivh*day 4 -4 0;
    estimate "Compare day4 between yes-tx vs IVH" ivh 0  1 -1 ivh*day 0 4 -4;
    
	estimate "Compare day7 between tx vs no-tx" ivh 1 0 -1 ivh*day 7 0 -7;
	estimate "Compare day7 between no-tx vs IVH" ivh 1 -1 0 ivh*day 7 -7 0;
    estimate "Compare day7 between yes-tx vs IVH" ivh 0  1 -1 ivh*day 0 7 -7;    

	estimate "Compare day14 between tx vs no-tx" ivh 1 0 -1 ivh*day 14 0 -14;
	estimate "Compare day14 between no-tx vs IVH" ivh 1 -1 0 ivh*day 14 -14 0;
    estimate "Compare day14 between yes-tx vs IVH" ivh 0  1 -1 ivh*day 0 14 -14;
*/
	estimate "No tx, intercept" int 1 ivh 1 0 0 gestage &nage/cl;
	estimate "No tx, Day1"  int 1 ivh 1 0 0 day 1 day*ivh 1  0  0 gestage &nage;
	estimate "No tx, Day4"  int 1 ivh 1 0 0 day 4 day*ivh 4  0  0 gestage &nage;
	estimate "No tx, Day7"  int 1 ivh 1 0 0 day 7 day*ivh 7  0  0 gestage &nage;
	estimate "No tx, Day14" int 1 ivh 1 0 0 day 14 day*ivh 14  0 0 gestage &nage;
	estimate "No tx, Day21" int 1 ivh 1 0 0 day 21 day*ivh 21  0 0 gestage &nage;
	estimate "No tx, Day28" int 1 ivh 1 0 0 day 28 day*ivh 28  0 0 gestage &nage;
	estimate "No tx, Day40" int 1 ivh 1 0 0 day 40 day*ivh 40  0 0 gestage &nage;
	estimate "No tx, Day60" int 1 ivh 1 0 0 day 60 day*ivh 60  0 0 gestage &nage/e;

	estimate "Yes IVH, intercept" int 1 ivh 0 1 0 gestage &nage/cl;
	estimate "    IVH, Day1"  int 1 ivh 0 1 0 day 1  day*ivh 0 1  0 gestage &nage;
	estimate "    IVH, Day4"  int 1 ivh 0 1 0 day 4 day*ivh  0 4  0 gestage &nage;
	estimate "    IVH, Day7"  int 1 ivh 0 1 0 day 7 day*ivh  0 7  0 gestage &nage;
	estimate "    IVH, Day14" int 1 ivh 0 1 0 day 14 day*ivh 0 14 0  gestage &nage;
	estimate "    IVH, Day21" int 1 ivh 0 1 0 day 21 day*ivh 0 21 0  gestage &nage;
	estimate "    IVH, Day28" int 1 ivh 0 1 0 day 28 day*ivh 0 28 0  gestage &nage;
	estimate "    IVH, Day40" int 1 ivh 0 1 0 day 40 day*ivh 0 40 0  gestage &nage;
	estimate "    IVH, Day60" int 1 ivh 0 1 0 day 60 day*ivh 0 60 0  gestage &nage/e;
	
	estimate "yes tx, intercept" int 1 ivh 0 0 1 gestage &nage/cl;
	estimate "yes tx, Day1"  int 1 ivh 0 0 1 day 1 day*ivh 0  0 1   gestage &nage;
	estimate "yes tx, Day4"  int 1 ivh 0 0 1 day 4 day*ivh 0  0 4   gestage &nage;
	estimate "yes tx, Day7"  int 1 ivh 0 0 1 day 7 day*ivh 0  0 7   gestage &nage;
	estimate "yes tx, Day14" int 1 ivh 0 0 1 day 14 day*ivh 0  0 14 gestage &nage;
	estimate "yes tx, Day21" int 1 ivh 0 0 1 day 21 day*ivh 0  0 21 gestage &nage;
	estimate "yes tx, Day28" int 1 ivh 0 0 1 day 28 day*ivh 0  0 28 gestage &nage;
	estimate "yes tx, Day40" int 1 ivh 0 0 1 day 40 day*ivh 0  0 40 gestage &nage;
	estimate "yes tx, Day60" int 1 ivh 0 0 1 day 60 day*ivh 0  0 60 gestage &nage/e;	
	
	
	ods output Mixed.Estimates=ivh_estimate;
run;
*ods trace off;

data ivh_pv;
	set ivh_estimate(firstobs=1 obs=9);
	if probt<0.001 then pv="<0.001"; else pv=put(probt, 5.3);
    if _n_=1 then call symput("sp0", compress(put(estimate,4.1)||"&pm"||put(stderr,4.1)));
    if _n_=2 then call symput("sp1", compress(put(estimate,4.1)||"&pm"||put(stderr,4.1)));
    if _n_=3 then call symput("sp2", compress(put(estimate,4.1)||"&pm"||put(stderr,4.1)));

	if _n_=4 then call symput("p0", compress(pv));
	if _n_=5 then call symput("p1", compress(pv));
	if _n_=6 then call symput("p2", compress(pv));
	if _n_=7 then call symput("ip0", compress(pv));
	if _n_=8 then call symput("ip1", compress(pv));
	if _n_=9 then call symput("ip2", compress(pv));
run;

data ivh_estimate;
	set ivh_estimate(firstobs=10);
	if find(label,"No tx") then group=0; 
	else if find(label,"yes tx") then group=2; 
	else group=1;
	
	if find(label,"intercept") then day=0; 
	else day= compress(scan(label,2,","),"Day");
	day1=day+0.2;
	day2=day-0.2;


	if upper<0 then upper=0;
	if lower<0 then lower=0;
	if estimate<0 then delete;
	
	if group=1 and day>=14 then delete;
		if group=0 and day>=40 then delete;
	
	keep group day day1 day2 estimate upper lower;
run;

		DATA anno0; 
			set ivh_estimate;
			
			where group=0;
			xsys='2'; ysys='2'; color='blue ';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;
	
data anno0A;
	length function text $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set ivh_estimate;
	function='move'; x=day; y=20; output;
	function='draw'; x=day; y=18; output;
	function='label'; 
	x=day; y=17; size=1.25;	text=left(put(day,dt.));	output;
	x=day; y=15; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=13; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=11; size=1; 	text=left(put(day,dtc.));	output;
run;

data anno0;
	length color $6 function $8;
	set anno0 /*anno0A*/;
run;


		DATA anno1; 
			set ivh_estimate;
			
			where group=1;
			xsys='2'; ysys='2'; color='red ';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day1-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;
	
data anno1A;
	length function text $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set ivh_estimate;
	function='move'; x=day; y=20; output;
	function='draw'; x=day; y=18; output;
	function='label'; 
	x=day; y=17; size=1.25;	text=left(put(day,dt.));	output;
    x=day; y=15; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=13; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=11; size=1; 	text=left(put(day,dtc.));	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;

	
	DATA anno2; 
			set ivh_estimate;
			
			where group=2;
			xsys='2'; ysys='2'; color='green';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day2; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day2-.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day2+.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day2;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;

data anno2A;
	length function text $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set ivh_estimate;
	function='move'; x=day; y=20; output;
	function='draw'; x=day; y=18; output;
	function='label'; 
	x=day; y=17; size=1.25;	text=left(put(day,dt.));	output;
    x=day; y=15; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=13; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=11; size=1; 	text=left(put(day,dtc.));	output;
run;

data anno2;
	length color $6 function $8;
	set anno2 anno2A;
run;

data anno;
	set anno0 anno1 anno2;
run;

data ivh_estimate;
	merge ivh_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
    ivh_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	ivh_estimate(where=(group=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) ; by day;
	lu0=put(estimate0,4.1)||"["||put(lower0,4.1)||"-"||put(upper0,4.1)||"]";
	lu1=put(estimate1,4.1)||"["||put(lower1,4.1)||"-"||put(upper1,4.1)||"]";
	lu2=put(estimate2,4.1)||"["||put(lower2,4.1)||"-"||put(upper2,4.1)||"]";	
	if  day>=14 then lu1="-";
		if  day>=40 then lu0="-";
run;


goptions reset=global rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext="Times" FTITLE="Times" FBY="Times";

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=1;
	symbol2 i=j ci=red value=dot co=red cv=red h=2 w=1;
	symbol3 i=j ci=green value=square co=green cv=green h=2 w=1;

	   
	axis1 	label=(h=3 " " ) split="*"	
	   value=(h=1.25) major=(c=black) origin=(,20)pct order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	   
	axis2 	label=(h=3 a=90 "Platelet Count(1000/&mu L)") value=(h=2.5) c=black order= (0 to 500 by 50) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top left inside) shape = symbol(3,2) label=NONE 
    value = ( h=2 c=black "Non-IVH without platelet tx" "IVH" "Non-IVH with platelet tx") offset=(0.5in, -0.4 in) frame cframe=white cborder=black;
	                
	title1 	height=4 "Platelet Count vs Age (non-IVH without platelet tx=&n0(&m0 obs), IVH=&n1(&m1 obs), non-IVH with platelet tx=&n2(&m2 obs))";
	title2 	height=2.5 "Slope of non-IVH without platelet tx =&sp0, Slope of IVH=&sp1, Slope of non-IVH with platelet tx=&sp2";
	title3  height=2.5 "Test of equal slopes between Non-IVH without platelet tx and with platelet tx, p=&p0; between Non-IVH without platelet tx and IVH, p=&p1; between Non-IVH with platelet tx and IVH, p=&p2";


	ods pdf file = "plt_ivh_tx_gestage.pdf" style=journal;
			proc gplot data= ivh_estimate;
				plot estimate0*day estimate1*day1 estimate2*day2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 estimate2 4.0 day dd.;
				
            	note h=2.5 m=(45pct, 5 pct) "Age (Days)" ;
				note h=1 m=(2pct, 16 pct) "Day :" ;
               	note h=1 m=(0pct, 14 pct) "#Non-IVH no platelet Tx" ;
               	note h=1 m=(0pct, 12 pct) "#IVH" ;
               	note h=1 m=(0pct, 10 pct) "#Non-IVH with platelet Tx" ;
			run;	
			
			proc print data=ivh_estimate noobs label;
			title2 " ";
			title3 " ";
			var day lu0 lu1 lu2/style=[just=center width=2in];
			label day="Day"
			      lu0="Non-IVH without tx" lu1="IVH" lu2="Non-IVH with tx";
			run;

	ods pdf close;

