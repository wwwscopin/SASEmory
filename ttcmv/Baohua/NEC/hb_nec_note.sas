options ORIENTATION="LANDSCAPE" nodate nonumber;
libname wbh "/ttcmv/sas/programs";	

%let pm=%sysfunc(byte(177));

proc format;
		value anemic 0="Not Anemic" 1="Anemic";
		value tx 
		0="No"
		1="Yes"
		;
		value type
		0="Medical NEC"
		1="Surgical NEC"
		.="No NEC"
		;

		value dd -1=" " 2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" " 36=" " 37=" " 38=" " 39=" " 41=" "
		42=" " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" "
		61=" " 0="0" 1="1" 7="7" 14="14" 21="21" 28="28" 40="40" 60="60"
		;
run;

data hb0;
	set cmv.plate_015 
		cmv.plate_031(keep=id Hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate) in=B);

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if B then tx=1; else tx=0;
	
	if id=3006711 and hbdate='30Dec11'd then hbdate='30Dec10'd;
	keep id HbDate Hb dfseq;
run;

proc sort nodupkey; by id hbdate hb;run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format laparotomydone type.;
	lable laparotomydone="NEC Type";
run;

data nec;
	merge hb0 nec0 cmv.completedstudylist(in=comp)
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob)); by id;
	
		
    if comp;
	if bell then nec=1; else nec=0;
	day=hbdate-dob+1;
	retain ndate;
	if first.id then ndate=necdate;
	

	if hbdate>ndate and nec then hb=.;
	if hb^=. then if hb<=9 then anemic=1; else anemic=0;

	format gender gender. ndate mmddyy8. anemic anemic.;
	if hb<6 or hb>25 or day=. or day<1 then delete;
run;

proc print; 
where day<1;
var id dob day hbdate dob;
run;


proc means data=nec;
	class nec;
	var id;
	output out=nec_obs n(id)=n;
run;


data _null_;
	set nec_obs;
	if nec=0 then call symput("no",compress(n));
	if nec=1 then call symput("yes",compress(n));
run;

%put &yes;


proc sort data=nec nodupkey out=nec_id; by id;run;

proc means data=nec_id;
	class nec;
	var id;
	output out=nec_num n(id)=n;
run;

data _null_;
	set nec_num;
	if nec=0 then call symput("no_nec",compress(n));
	if nec=1 then call symput("yes_nec",compress(n));
run;
proc sort data=nec nodupkey out=nec_day; by id hbdate; run;

proc means data=nec_day;
	class nec dfseq;
	var id;
	output out=wbh;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;

data _null_;
	set wbh;
	if nec=0 and dfseq=1  then call symput( "a1",   compress(_freq_));
	if nec=0 and dfseq=4  then call symput( "a4",   compress(_freq_));
	if nec=0 and dfseq=7  then call symput( "a7",   compress(_freq_));
	if nec=0 and dfseq=14 then call symput( "a14",  compress(_freq_));
	if nec=0 and dfseq=21 then call symput( "a21",  compress(_freq_));
	if nec=0 and dfseq=28 then call symput( "a28",  compress(_freq_));
	if nec=0 and dfseq=40 then call symput( "a40",  compress(_freq_));
	if nec=0 and dfseq=60 then call symput( "a60",  compress(_freq_));

	if nec=1 and dfseq=1  then call symput( "b1",   compress(_freq_));
	if nec=1 and dfseq=4  then call symput( "b4",   compress(_freq_));
	if nec=1 and dfseq=7  then call symput( "b7",   compress(_freq_));
	if nec=1 and dfseq=14 then call symput( "b14",  compress(_freq_));
	if nec=1 and dfseq=21 then call symput( "b21",  compress(_freq_));
	if nec=1 and dfseq=28 then call symput( "b28",  compress(_freq_));
	if nec=1 and dfseq=40 then call symput( "b40",  compress(_freq_));
	if nec=1 and dfseq=60 then call symput( "b60",  compress(_freq_));
run;

proc format;
/*
value dt -1=" "  
 0=" " 1="1*(&a1)*(&b1)"  2=" " 3=" " 4 = "4*(&a4)*(&b4)" 5=" " 6=" " 7="7*(&a7)*(&b7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&a14)*(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&a21)*(&b21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&a28)*(&b28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&a40)*(&b40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&a60)*(&b60)" ;
 */
 
 value dt -1=" "  
 0="0" 1="1"  2=" " 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60" ;
 
 value dta -1=" "  
 0=" " 1="&a1"  2=" " 3=" " 4 = "&a4" 5=" " 6=" " 7="&a7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&a14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&a21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&a28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&a40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "&a60" ;
 
  value dtb -1=" "  
 0=" " 1="&b1"  2=" " 3=" " 4 = "&b4" 5=" " 6=" " 7="&b7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&b14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&b21"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&b28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&b40" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "&b60" ;
 
  value dd -1=" "  
 0=" " 1=" "  2=" " 3=" " 4 = " " 5=" " 6=" " 7=" " 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = " " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21=" "  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = " "  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40=" " 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 60 = " " 61=" " 62=" "   ;
 
run;

*ods trace on/label listing;
proc mixed data=nec covtest;
	class id nec;
	model hb=nec day nec*day/s;
	random int day/type=un subject=id;
	estimate "No NEC, slope" day 1 nec*day 1 0;
	estimate "   NEC, slope" day 1 nec*day 0 1;
	estimate "Compare slopes" nec*day 1 -1;

	estimate "No NEC, intercept" int 1 nec 1 0/cl;
	estimate "No NEC, Day1"  int 1 nec 1 0 day 1  day*nec 1  0;
	estimate "No NEC, Day4"  int 1 nec 1 0 day 4  day*nec 4  0;
	estimate "No NEC, Day7"  int 1 nec 1 0 day 7  day*nec 7  0;
	estimate "No NEC, Day14" int 1 nec 1 0 day 14 day*nec 14 0;
	estimate "No NEC, Day21" int 1 nec 1 0 day 21 day*nec 21 0;
	estimate "No NEC, Day28" int 1 nec 1 0 day 28 day*nec 28 0;
	estimate "No NEC, Day40" int 1 nec 1 0 day 40 day*nec 40 0;
	estimate "No NEC, Day60" int 1 nec 1 0 day 60 day*nec 60 0/e;

	estimate "Yes NEC, intercept" int 1 nec 0 1/cl;
	estimate "    NEC, Day1"  int 1 nec 0 1 day 1  day*nec 0 1  ;
	estimate "    NEC, Day4"  int 1 nec 0 1 day 4  day*nec 0 4  ;
	estimate "    NEC, Day7"  int 1 nec 0 1 day 7  day*nec 0 7  ;
	estimate "    NEC, Day14" int 1 nec 0 1 day 14 day*nec 0 14 ;
	estimate "    NEC, Day21" int 1 nec 0 1 day 21 day*nec 0 21 ;
	estimate "    NEC, Day28" int 1 nec 0 1 day 28 day*nec 0 28 ;
	estimate "    NEC, Day40" int 1 nec 0 1 day 40 day*nec 0 40 ;
	estimate "    NEC, Day60" int 1 nec 0 1 day 60 day*nec 0 60 /e;
	ods output Mixed.Estimates=nec_estimate;
run;
*ods trace off;

data nec_slope;
	set nec_estimate(firstobs=1 obs=3);
    if _n_=1 then call symput("sp0", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    if _n_=2 then call symput("sp1", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    if _n_=3 then call symput("p", put(Probt,4.2));
run;

data nec_estimate;
	set nec_estimate(firstobs=4);
	if find(label,"No NEC") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= compress(scan(label,2,","), "Day");
	day1=day+0.2;
	
    if day in(40) and group=1 then do; group=.; estimate=.; upper=.; lower=.; end;
    if day in(60) then do; group=.; estimate=.; upper=.; lower=.; end;
	keep group day day1 estimate upper lower;
run;


		DATA anno0; 
			set nec_estimate;
			
			where group=0;
			xsys='2'; ysys='2'; color='blue';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day+0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;
	
data anno0A;
	length function $8 text $4;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; 
	x=day; y=12; size=1.25;	text=compress(put(day,dt.));	output;
	x=day; y=10; size=1; 	text=compress(put(day,dta.));	output;
	x=day; y=8.0; size=1; 	text=compress(put(day,dtb.));	output;
run;

data anno0;
	length color $6 function $8;
	set anno0 anno0A;
run;

		DATA anno1; 
			set nec_estimate;
			
			where group=1;
			xsys='2'; ysys='2'; color='red';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day1-0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1+0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
			return;
	run;

data anno1A;
	length function $8 text $4;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; 
	x=day; y=12; size=1.25;	text=compress(put(day,dt.));	output;
    x=day; y=10; size=1; 	text=compress(put(day,dta.));	output;
	x=day; y=8.0; size=1; 	text=compress(put(day,dtb.));	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;



data anno;
	set anno0 anno1;
run;

data nec_estimate;
	merge nec_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	nec_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
	lu0=put(estimate0,4.1)||"["||put(lower0,4.1)||"-"||put(upper0,4.1)||"]";
	lu1=put(estimate1,4.1)||"["||put(lower1,4.1)||"-"||put(upper1,4.1)||"]";
	if day in(40) then do; lu1="-"; end;
	if day in(60) then do; lu0="-"; lu1="-"; end;
run;


	goptions reset=all  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext="Times" FTITLE="Times" FBY="Times";

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=3 width=1;
	symbol2 i=j ci=red value=dot co=red cv=red h=3 w=1;

	axis1 	label=(h=3 " " ) split="*"	value=(h=1.25)  origin=(,15)pct  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(h=3 a=90 "Hemoglobin(g/dL)") value=(h=2.5) order= (7 to 16 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve shape = symbol(3,2) label=NONE 
    value = ( h=2 "Non-NEC" "NEC") offset=(-0.2in, -0.4 in) frame;
	                
	title1 	height=4 "Hemoglobin vs Days (Non-NEC=&no_nec(&no obs), NEC=&yes_nec(&yes obs))";
	title2 	height=3 "Slope of Non-NEC=&sp0, Slope of NEC=&sp1; Test of equal slopes, p=&p";

	ods pdf file = "hb_nec_slope.pdf" style=journal;
			proc gplot data= nec_estimate;
			    plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 4.0 day dd.;
				
				note h=3 m=(20pct, 0 pct) "Age Before the First NEC Diagnosis (NEC) or Age of non-NEC LBWIs";
				note h=1.5 m=(2pct, 11 pct) "Day :" ;
               	note h=1.5 m=(2pct, 9 pct) "#Non-NEC" ;
               	note h=1.5 m=(2pct, 7.0 pct) "#NEC" ;
			run;	
			
			proc print data=nec_estimate noobs label;
			var day lu0 lu1/style=[just=center width=2in];
			label day="Day"
			      lu0="Non-NEC" lu1="NEC";
			run;
	ods pdf close;
