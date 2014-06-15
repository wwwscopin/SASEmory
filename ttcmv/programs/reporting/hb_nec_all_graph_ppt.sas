options ORIENTATION="LANDSCAPE" nodate nonumber;
libname wbh "/ttcmv/sas/programs";	

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

run;

data hb0;
	set cmv.plate_015 
		cmv.plate_031(keep=id Hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate) in=B);

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;
	if B then tx=1; else tx=0;
	
		if id=3006711 and hbdate='30Dec11'd then hbdate='30Dec10'd;
	*rename dfseq=day;
	keep id HbDate Hb dfseq;
run;

proc sort nodupkey; by id hbdate hb;run;

proc sort data=hb0 out=hb_last; by id decending hbdate;run;

data hb_last;
    set hb_last; by id descending hbdate;
    if first.id;
    rename hbdate=ndate;
    keep id hbdate;
run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate laparotomydone NECResolveDate;
	rename laparotomydone=type;
	format laparotomydone type.;
	lable laparotomydone="NEC Type";
run;

data nec;
	merge hb0 nec0 cmv.completedstudylist(in=comp) hb_last
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob)); by id;
	
	
	if comp;
	if necdate=. then nec=0; else nec=1;
	retain ndate;
	if nec and first.id then ndate=necdate;

	day=hbdate-ndate;
	
	if  day=0 then dday=0;
	else if -6<day<-1 then dday=-4;
	else if -9<day<=-6 then dday=-7;
	else if -18<day<=-9 then dday=-14;
	else if -25<day<=-18 then dday=-21;
	else if -35<day<=-25 then dday=-28;
	else if  -50<day<=-35 then dday=-40;
	else if  day<=-50 then dday=-60;
	
	if hbdate>ndate and nec then hb=.;
	if hb^=. then if hb<=9 then anemic=1; else anemic=0;

	if hb<6 or hb>25 or day=. or day<-300 then delete;
	format gender gender. ndate mmddyy8. anemic anemic.;
run;

proc print;
where day<-300;
run;

proc means data=nec noprint;
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

proc means data=nec_id noprint;
	class nec;
	var id;
	output out=nec_num n(id)=n;
run;

data _null_;
	set nec_num;
	if nec=0 then call symput("no_nec",compress(n));
	if nec=1 then call symput("yes_nec",compress(n));
run;
proc sort data=nec nodupkey; by id hbdate; run;
proc sort data=nec out=nec_id nodupkey; by nec dday id; run;

proc means data=nec_id noprint;
	class nec dday;
	var id;
	output out=wbh;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;

data _null_;
	set wbh;
	if nec=0 and dday=0  then call symput( "a0",   compress(_freq_));
	if nec=0 and dday=-4  then call symput( "a4",   compress(_freq_));
	if nec=0 and dday=-7  then call symput( "a7",   compress(_freq_));
	if nec=0 and dday=-14 then call symput( "a14",  compress(_freq_));
	if nec=0 and dday=-21 then call symput( "a21",  compress(_freq_));
	if nec=0 and dday=-28 then call symput( "a28",  compress(_freq_));
	if nec=0 and dday=-40 then call symput( "a40",  compress(_freq_));
	if nec=0 and dday=-60 then call symput( "a60",  compress(_freq_));

	if nec=1 and dday=0  then call symput( "b0",   compress(_freq_));
	if nec=1 and dday=-4  then call symput( "b4",   compress(_freq_));
	if nec=1 and dday=-7  then call symput( "b7",   compress(_freq_));
	if nec=1 and dday=-14 then call symput( "b14",  compress(_freq_));
	if nec=1 and dday=-21 then call symput( "b21",  compress(_freq_));
	if nec=1 and dday=-28 then call symput( "b28",  compress(_freq_));
	if nec=1 and dday=-40 then call symput( "b40",  compress(_freq_));
	if nec=1 and dday=-60 then call symput( "b60",  compress(_freq_));
run;

proc format;
/*
value dt   
 1=" " 0="0*(&a0)*(&b0)" -1=" "  -2=" " -3=" " -4 = "-4*(&a4)*(&b4)" -5=" " -6=" " -7="-7*(&a7)*(&b7)" -8=" " -9=" " -10=" " 
 -11=" " -12=" " -13=" " -14 = "-14*(&a14)*(&b14)" -15=" " -16=" " -17=" " -18=" " -19=" " -20=" " 
 -21="-21*(&a21)*(&b21)"  -22=" " -23=" " -24=" " -25=" " -26=" " -27=" " -28 = "-28*(&a28)*(&b28)"  -29=" " -30=" "
 -31=" " -32=" " -33=" " -34=" " -35=" "  -36=" " -37=" "	-38=" " -39=" " -42=" " 
 -41=" " -40="-40*(&a40)*(&b40)" -43=" "	-44=" " -45=" " -46=" " -47=" "  -48=" "	-49=" " -50=" " 
 -51=" " -52=" " -53=" " -54=" " -55=" " -56=" " -57=" " -58=" " -59=" " -61=" " -62=" "  -60 = "-60*(&a60)*(&b60)" ;
*/ 

value dt   
 1=" " 0="0" -1="-1"  -2=" " -3=" " -4 = "-4" -5=" " -6=" " -7="-7" -8=" " -9=" " -10=" " 
 -11=" " -12=" " -13=" " -14 = "-14" -15=" " -16=" " -17=" " -18=" " -19=" " -20=" " 
 -21="-21"  -22=" " -23=" " -24=" " -25=" " -26=" " -27=" " -28 = "-28"  -29=" " -30=" "
 -31=" " -32=" " -33=" " -34=" " -35=" "  -36=" " -37=" "	-38=" " -39=" " -42=" " 
 -41=" " -40="-40" -43=" "	-44=" " -45=" " -46=" " -47=" "  -48=" "	-49=" " -50=" " 
 -51=" " -52=" " -53=" " -54=" " -55=" " -56=" " -57=" " -58=" " -59=" " -61=" "   -60 = "-60" ;
 
 
 value dd   
 1=" " 0=" " -1=" "  -2=" " -3=" " -4 = " " -5=" " -6=" " -7=" " -8=" " -9=" " -10=" " 
 -11=" " -12=" " -13=" " -14 = " " -15=" " -16=" " -17=" " -18=" " -19=" " -20=" " 
 -21=" "  -22=" " -23=" " -24=" " -25=" " -26=" " -27=" " -28 = " "  -29=" " -30=" "
 -31=" " -32=" " -33=" " -34=" " -35=" "  -36=" " -37=" "	-38=" " -39=" " -42=" " 
 -41=" " -40=" " -43=" "	-44=" " -45=" " -46=" " -47=" "  -48=" "	-49=" " -50=" " 
 -51=" " -52=" " -53=" " -54=" " -55=" " -56=" " -57=" " -58=" " -59=" " -61=" "   -60 = " " ;
 
 
 
run;

*ods trace on/label listing;
proc mixed data=nec covtest method=MIVQUE0;
	class id nec;
	model hb=nec day nec*day/s;
	random int day/type=un subject=id;
	estimate "No NEC, slope" day -1 nec*day -1 0;
	estimate "   NEC, slope" day -1 nec*day 0 -1;
	estimate "Compare slopes" nec*day 1 -1;

	estimate "No NEC, intercept" int 1 nec 1 0/cl;
	estimate "No NEC, Day4"  int 1 nec 1 0 day -4  day*nec -4  0;
	estimate "No NEC, Day7"  int 1 nec 1 0 day -7  day*nec -7  0;
	estimate "No NEC, Day14" int 1 nec 1 0 day -14 day*nec -14 0;
	estimate "No NEC, Day21" int 1 nec 1 0 day -21 day*nec -21 0;
	estimate "No NEC, Day28" int 1 nec 1 0 day -28 day*nec -28 0;
	estimate "No NEC, Day40" int 1 nec 1 0 day -40 day*nec -40 0;
	estimate "No NEC, Day60" int 1 nec 1 0 day -60 day*nec -60 0/e;

	estimate "Yes NEC, intercept" int 1 nec 0 1/cl;
	estimate "    NEC, Day4"  int 1 nec 0 1 day -4  day*nec 0 -4  ;
	estimate "    NEC, Day7"  int 1 nec 0 1 day -7  day*nec 0 -7  ;
	estimate "    NEC, Day14" int 1 nec 0 1 day -14 day*nec 0 -14 ;
	estimate "    NEC, Day21" int 1 nec 0 1 day -21 day*nec 0 -21 ;
	estimate "    NEC, Day28" int 1 nec 0 1 day -28 day*nec 0 -28 ;
	estimate "    NEC, Day40" int 1 nec 0 1 day -40 day*nec 0 -40 ;
	estimate "    NEC, Day60" int 1 nec 0 1 day -60 day*nec 0 -60 /e;
	ods output Mixed.Estimates=nec_estimate;
run;
*ods trace off;

data nec_slope;
	set nec_estimate(firstobs=3 obs=3);
	call symput("p", put(Probt,4.2));
run;

data nec_estimate;
	set nec_estimate(firstobs=4);
	if find(label,"No NEC") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= -(substr(compress(scan(label,2,",")),4,2)+0);
	day1=day+0.2;
	keep group day day1 estimate upper lower;
run;

proc sort; by day;run;

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
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.5; output;
	text=left(put(day,dt.));
	output;
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
			  X=day1;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;

data anno1A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.5; output;
	text=left(put(day,dt.));
	output;
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
run;

/*
	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext="Times" FTITLE="Times" FBY="Times";
*/
		
proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=global rotate=landscape gunit=pct noborder CBACK=blue ctext=white ctitle=white colors=(orange green red)
	 ftitle="Times/bold" ftext="Times/bold" htitle=3.5 htext=3;

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=3 width=1;
	symbol2 i=j ci=red value=dot co=red cv=red h=3 w=1;

/*
	axis1 	label=(h=3 "Days Before the Last Hemoglobin Measurement Or Days Before Initial NEC Diagnosis" ) split="*"	
		   value=(h=1.25) major=(c=blue) origin=(,15)pct order= (-61 to 1 by 1) minor=none offset=(0 in, 0 in);
*/		   
	axis1 	label=(h=3 " " ) split="*"	
	   value=(h=1.25) major=(c=blue) origin=(,15)pct order= (-61 to 1 by 1) minor=none offset=(0 in, 0 in);
	   
	axis2 	label=(h=3 a=90 "Hemoglobin(g/dL)") value=(h=2.5) c=white order= (8 to 16 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve shape = symbol(3,2) label=NONE 
    value = ( h=2 c=black "No NEC" "NEC") offset=(-0.2in, -0.4 in) frame cframe=white cborder=black;
	                
	title1 	height=4 "Hemoglobin vs Days (No NEC=&no_nec(&no obs), NEC=&yes_nec(&yes obs))";
	title2 	height=3.5 "Test of equal slopes, p=&p";

	ods pdf file = "hb_nec_slope0.pdf" style=journal;
			proc gplot data= nec_estimate;
				plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 4.0 day dd.;
				
				note h=3 m=(20pct, 5 pct) "Age Before the First NEC Diagnosis (NEC) or Age of non-NEC LBWIs" ;
				
				*note h=1.25 m=(3pct, 9.0 pct) "Day :" ;
               	*note h=1.25 m=(3pct, 7.5 pct) "(#No NEC)" ;
               	*note h=1.25 m=(3pct, 6.0 pct) "(#NEC)" ;
			run;	
			
			proc print data=nec_estimate noobs label;
			var day lu0 lu1/style=[just=center width=2in];
			label day="Day"
			      lu0="No NEC" lu1="NEC";
			run;

	ods pdf close;
