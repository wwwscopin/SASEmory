options ORIENTATION="LANDSCAPE";
libname wbh "/ttcmv/sas/data";	

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
	*if hb>25 then hb=.;
	if B then tx=1; else tx=0;
	*rename dfseq=day;
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
	merge hb0 nec0 cmv.comp_pat(in=comp keep=id gender dob); by id;
	if comp;
	if necdate=. then nec=0; else nec=1;
	day=hbdate-dob;
	*rename dfseq=day;
	retain ndate;
	if first.id then ndate=necdate;
	
	if hbdate>ndate and nec then hb=.;
	if hb^=. then if hb<=9 then anemic=1; else anemic=0;

	format gender gender. ndate mmddyy8. anemic anemic.;
	if day>1000 then day=.;
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
proc sort data=nec nodupkey; by id hbdate; run;

*ods trace on/label listing;
proc mixed method=ml data=nec covtest;
	class id nec;
	model hb=nec day nec*day/s;
	random int day/type=un subject=id;
	estimate "No NEC, slope" day 1 nec*day 1 0;
	estimate "   NEC, slope" day 1 nec*day 0 1;
	estimate "Compare slopes" nec*day 1 -1;

	estimate "No NEC, intercept" int 1 nec 1 0/cl;
	estimate "No NEC, Day1"  int 1 nec 1 0 day 1  day*nec 1  0;
	estimate "No NEC, Day7"  int 1 nec 1 0 day 7  day*nec 7  0;
	estimate "No NEC, Day14" int 1 nec 1 0 day 14 day*nec 14 0;
	estimate "No NEC, Day21" int 1 nec 1 0 day 21 day*nec 21 0;
	estimate "No NEC, Day28" int 1 nec 1 0 day 28 day*nec 28 0;
	estimate "No NEC, Day40" int 1 nec 1 0 day 40 day*nec 40 0;
	estimate "No NEC, Day60" int 1 nec 1 0 day 60 day*nec 60 0/e;

	estimate "Yes NEC, intercept" int 1 nec 0 1/cl;
	estimate "    NEC, Day1"  int 1 nec 0 1 day 1  day*nec 0 1  ;
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
	set nec_estimate(firstobs=3 obs=3);
	call symput("p", put(Probt,4.2));
run;

proc print data=nec_slope;run;

data nec_estimate;
	set nec_estimate(firstobs=4);
	if find(label,"No NEC") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= substr(compress(scan(label,2,",")),4,2)+0;
	day1=day+0.2;
	keep group day day1 estimate upper lower;
run;

		DATA anno0; 
			set nec_estimate;
			
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
			set nec_estimate;
			
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

data nec_estimate;
	merge nec_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	nec_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
run;

	goptions reset=all  device=jpeg  rotate=landscape gunit=pct noborder cback=white
		colors = (black red) /*ftitle=Arial*/ ftext=zapf  /*fby =Arial*/ hby = 3;

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=2 bwidth=3 width=2;
	symbol2 i=j ci=red value=dot co=red cv=red h=2 w=2;

	axis1 	label=(f=zapf h=2.5 "Days Before the First NEC Diagnosis Date" ) split="*"	value=(f=zapf h=1.25)  order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(f=zapf h=2.5 a=90 "Hemoglobin(g/dL)") value=(f=zapf h=2) order= (0 to 16 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (f=zapf h=3 "No NEC" "NEC") offset=(0, -0.4 in) frame;
	                
	title1 	height=3 f=zapf "Hemoglobin vs Days (No NEC=&no_nec(&no obs), NEC=&yes_nec(&yes obs))";
	title2 	height=3 f=zapf "Test of equal slopes, p=&p";

	ods pdf file = "hb_nec_slope.pdf";
			proc gplot data= nec_estimate;
				plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 4.0 day dd.;
			run;	

	ods pdf close;


proc mixed method=ml data=nec covtest;
	class id nec;
	model hb=nec day*nec/noint s;
	random int day/type=un subject=id;
run;

proc mixed method=ml data=nec covtest;
	class id nec;
	model hb=nec day day*nec/noint s;
	random int day/type=un subject=id;
run;



proc freq data=nec;
	tables nec*anemic;
	ods output crosstabfreqs=wbh;
run;


proc print data=nec;
var id nec anemic day;
run;


/*
proc genmod data=nec(where=(anemic^=.));
	class id nec;
	model anemic=nec day nec*day/link=log dist=binomial type3;
	repeated subject=id/type=exch;
	*output out=pred pred=pred;
run;


proc genmod data=nec(where=(anemic^=.));
	class id nec;
	model anemic=nec day nec*day/link=logit dist=binomial type3;
	repeated subject=id/type=exch;
	*output out=pred pred=pred;
run;
*/
