options ORIENTATION="LANDSCAPE";
*options ORIENTATION="PORTRAIT";
libname wbh "/ttcmv/sas/data";	

proc format;
		value tx 
		0="No"
		1="Yes"
		;

		value dd -1=" " 2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" " 36=" " 37=" " 38=" " 39=" " 41=" "
		42=" " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" "
		61=" " 0=" " 1="1" 7="7" 14="14" 21="21" 28="28" 40="40" 60="60"
		;
run;

data hb0;
	set cmv.plate_015 
		 cmv.plate_031(keep=id Hb DateHbHct rename=(DateHbHct=hbdate));

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	*if hb>25 then hb=.;
	if hb<=9 then anemic=1; else anemic=0;
	*rename dfseq=day;
	keep id HbDate Hb dfseq anemic;
run;

proc sort nodupkey; by id hbdate hb;run;


data ivh0;
	merge cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade);
	by id;
	td=ImageDate-IVHDiagDate;
run;

proc sort; by id td;run;
data ivh_mark;
	set ivh0; by id td;
	if td<=7;
   if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
	keep id ivh;
run;

proc sort data=ivh_mark(where=(ivh=1)) nodupkey; by id;

data ivh;
	merge hb0 
			cmv.plate_068(keep=id IVHDiagDate) 	
			cmv.ivh_image(keep=id LeftIVHGrade RightIVHGrade)
			ivh_mark cmv.comp_pat(in=comp keep=id gender dob);
			by id;
	if comp;

	if ivh=. then ivh=0;
	day=hbdate-dob;
	retain idate;
	if first.id then idate=IVHDiagDate;
	
	if hbdate>=idate and ivh then hb=.;
	format gender gender. idate mmddyy8.;
run;


proc sort nodupkey out=ivh_id; by id;run;

proc means data=ivh_id;
	class ivh;
	var id;
	output out=ivh_num n(id)=n;
run;

data _null_;
	set ivh_num;
	if ivh=0 then call symput("no_ivh",compress(n));
	if ivh=1 then call symput("yes_ivh",compress(n));
run;

proc sort data=ivh nodupkey; by id hbdate; run;

proc means data=ivh;
	class ivh;
	var id;
	output out=ivh_obs n(id)=n;
run;


data _null_;
	set ivh_obs;
	if ivh=0 then call symput("no",compress(n));
	if ivh=1 then call symput("yes",compress(n));
run;

*ods trace on/label listing;
proc mixed method=ml data=ivh covtest;
	class id ivh;
	model hb=ivh day ivh*day/s;
	random int day/type=un subject=id;
	estimate "No IVH, slope" day 1 ivh*day 1 0;
	estimate "   IVH, slope" day 1 ivh*day 0 1;

	estimate "No IVH, intercept" int 1 ivh 1 0/cl;
	estimate "No IVH, Day1"  int 1 ivh 1 0 day 1  day*ivh 1  0;
	estimate "No IVH, Day7"  int 1 ivh 1 0 day 7  day*ivh 7  0;
	estimate "No IVH, Day14" int 1 ivh 1 0 day 14 day*ivh 14 0;
	estimate "No IVH, Day21" int 1 ivh 1 0 day 21 day*ivh 21 0;
	estimate "No IVH, Day28" int 1 ivh 1 0 day 28 day*ivh 28 0;
	estimate "No IVH, Day40" int 1 ivh 1 0 day 40 day*ivh 40 0;
	estimate "No IVH, Day60" int 1 ivh 1 0 day 60 day*ivh 60 0/e;

	estimate "Yes IVH, intercept" int 1 ivh 0 1/cl;
	estimate "    IVH, Day1"  int 1 ivh 0 1 day 1  day*ivh 0 1  ;
	estimate "    IVH, Day7"  int 1 ivh 0 1 day 7  day*ivh 0 7  ;
	estimate "    IVH, Day14" int 1 ivh 0 1 day 14 day*ivh 0 14 ;
	estimate "    IVH, Day21" int 1 ivh 0 1 day 21 day*ivh 0 21 ;
	estimate "    IVH, Day28" int 1 ivh 0 1 day 28 day*ivh 0 28 ;
	estimate "    IVH, Day40" int 1 ivh 0 1 day 40 day*ivh 0 40 ;
	estimate "    IVH, Day60" int 1 ivh 0 1 day 60 day*ivh 0 60 /e;
	ods output Mixed.Estimates=ivh_estimate;
run;
*ods trace off;

data ivh_slope;
	set ivh_estimate(firstobs=3 obs=3);

	if probt<0.01 then p0="<0.01"; else p0=compress(put(Probt,5.2));

	call symput("p", p0);
run;

proc print data=ivh_slope;run;


data ivh_estimate;
	set ivh_estimate(firstobs=4);
	if find(label,"No IVH") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= substr(compress(scan(label,2,",")),4,2)+0;
	day1=day+0.2;
	keep group day day1 estimate upper lower;
	if estimate<0 then delete;
	if lower<0 then lower=0;
run;

proc print;run;

		DATA anno0; 
			set ivh_estimate;			
			where group=0;
			xsys='2'; ysys='2'; color='blue';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;

		DATA anno1; 
			set ivh_estimate;
			
			where group=1;
			xsys='2'; ysys='2'; color='red';

			* AFTER that, draw bars ('A' option ensure properly layering over the greay bars!);
			X=day1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
					Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT; * draw down;
		
			LINK TIPS; * make bar;

			Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=4;  OUTPUT; * draw up; 
		
			LINK TIPS; * make bar;
		
			* draw top and bottoms of bars;
			TIPS:
			  X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT;
			  X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=4; OUTPUT;
			  X=day1;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;


data anno;
	set anno0 anno1;
run;

data ivh_estimate;
	merge ivh_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	ivh_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;

	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=2;
	symbol2 i=j ci=red value=dot co=red cv=red h=2 w=2;

	axis1 	label=(f=zapf h=2.5 "Days Before IVH Diagnosis Date" ) split="*"	value=(f=zapf h=1.5)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Hemoglobin(g/dL)") value=(f=zapf h=2) order= (0 to 20 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=3 "No IVH" "IVH") offset=(0, -0.4 in) frame;
	                
	title1 	height=3 f=zapf "Hemoglobin vs Days (No IVH=&no_ivh(&no obs), IVH=&yes_ivh(&yes obs))";
	title2 	height=3 f=zapf "Test of equal slopes, p=&p";

	ods pdf file = "hb_ivh_slope.pdf";
			proc gplot data= ivh_estimate;
				plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 4.0 day dd.;
			run;	

	ods pdf close;


proc mixed method=ml data=ivh covtest;
	class id ivh;
	model hb=ivh day*ivh/noint s;
	random int day/type=un subject=id;
run;
