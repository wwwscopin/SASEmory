options ORIENTATION="LANDSCAPE" nonumber nodate;
libname wbh "/ttcmv/sas/porgrams";	
%let mu=%sysfunc(byte(181));
%let pm=%sysfunc(byte(177));
%put &pm;

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


data hb0;
	set cmv.plate_015 
		 cmv.plate_031(keep=id hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate));
	
	if hb=. then delete;
	if hbdate=. then hbdate=BloodCollectDate;

	keep id hbDate hb dfseq ;
run;

proc sort nodupkey; by id hbdate hb;run;

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


***********************************************************************************************;

data tx;
	set cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime in=A)
			/*cmv.plate_033(keep=id DateTransfusion plt_TxStartTime in=B)
			cmv.plate_035(keep=id DateTransfusion ffp_TxStartTime)
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


data ivh;
	merge hb0 ivh2 tx(in=tmp) cmv.comp_pat(in=comp keep=id gender dob) 	cmv.plate_006(keep=id gestage); by id;
	if comp;
	day=hbdate-dob;

	
	if tmp then tx=1; else tx=0;
	if ivh=. then ivh=0;
	if hbdate>=imagedate and ivh then hb=.;
    if hb=. then delete;
	format gender gender. imagedate mmddyy8.;
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

    axis1 	label=(h=3 'Age (days)' ) value=(h=1) split="*" order= (-1 to 40 by 1) minor=none offset=(0 in, 0 in);
    axis2 	label=(h=3 a=90 "Hb") value=(h=2) ;
    symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=100;  
    
    ods pdf file="hb_ivh_line.pdf"              ;
	proc gplot data=ivh(where=(ivh=1));
		title h=3.5 justify=center "Hb Line Plot";   
		note h=2 m=(7pct, 10 pct) "Age:" ;
		note h=2 m=(7pct, 7.5 pct) "(n)" ;
		plot hb*day=id/ overlay haxis = axis1 vaxis = axis2  nolegend; 
	run;
	ods pdf close;
	

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


proc sort data=ivh nodupkey out=ivh_id; by id;run;


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


%put &no;
%put &yes;
%put &no_ivh;
%put &yes_ivh;

proc sort data=ivh nodupkey; by id hbdate; run;

proc means data=ivh;
	class ivh dfseq;
	var id;
	output out=wbh;
run;

%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;

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
run;

proc format;

value dt -1="day*(#Non-IVH)*(#IVH)"  
 0="0" 1="1*(&a1)*(&b1)"  2=" " 3=" " 4 = "4*(&a4)*(&b4)" 5=" " 6=" " 7="7*(&a7)*(&b7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&a14)*(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&a21)*(&b21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&a28)*(&b28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&a40)*(&b40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&a60)*(&b60)" ;
 
run;

*ods trace on/label listing;
proc mixed method=ml data=ivh covtest;
	class id ivh;
	model hb=ivh day ivh*day gestage/s;
	*random int day/type=un subject=id;
	random int /type=un subject=id;
	
    estimate "No IVH, slope" day 1 ivh*day 1 0 ;
	estimate "   IVH, slope" day 1 ivh*day 0 1 ;
	estimate "Compare slopes" ivh*day 1 -1;
	estimate "Compare Intercept" ivh 1 -1 ;
	estimate "Compare day1" ivh 1 -1 ivh*day 1 -1 ;
	estimate "Compare day4" ivh 1 -1 ivh*day 4 -4 ;
	estimate "Compare day7" ivh 1 -1 ivh*day 7 -7 ;
	estimate "Compare day14" ivh 1 -1 ivh*day 14 -14 ;

	estimate "No IVH, intercept" int 1 ivh 1 0 gestage &nage/cl;
	estimate "No IVH, Day1"  int 1 ivh 1 0 day 1 day*ivh 1  0 gestage &nage;
	estimate "No IVH, Day4"  int 1 ivh 1 0 day 4 day*ivh 4  0 gestage &nage;
	estimate "No IVH, Day7"  int 1 ivh 1 0 day 7 day*ivh 7  0 gestage &nage;
	estimate "No IVH, Day14" int 1 ivh 1 0 day 14 day*ivh 14  0 gestage &nage;
	estimate "No IVH, Day21" int 1 ivh 1 0 day 21 day*ivh 21  0 gestage &nage;
	estimate "No IVH, Day28" int 1 ivh 1 0 day 28 day*ivh 28  0 gestage &nage;
	estimate "No IVH, Day40" int 1 ivh 1 0 day 40 day*ivh 40  0 gestage &nage;
	estimate "No IVH, Day60" int 1 ivh 1 0 day 60 day*ivh 60  0 gestage &nage/e;

	estimate "Yes IVH, intercept" int 1 ivh 0 1 gestage &nage/cl;
	estimate "    IVH, Day1"  int 1 ivh 0 1 day 1  day*ivh 0 1  gestage &nage;
	estimate "    IVH, Day4"  int 1 ivh 0 1 day 4 day*ivh  0 4   gestage &nage;
	estimate "    IVH, Day7"  int 1 ivh 0 1 day 7 day*ivh  0 7   gestage &nage;
	estimate "    IVH, Day14" int 1 ivh 0 1 day 14 day*ivh 0 14   gestage &nage;
	estimate "    IVH, Day21" int 1 ivh 0 1 day 21 day*ivh 0 21   gestage &nage;
	estimate "    IVH, Day28" int 1 ivh 0 1 day 28 day*ivh 0 28   gestage &nage;
	estimate "    IVH, Day40" int 1 ivh 0 1 day 40 day*ivh 0 40   gestage &nage;
	estimate "    IVH, Day60" int 1 ivh 0 1 day 60 day*ivh 0 60   gestage &nage/e;
	ods output Mixed.Estimates=ivh_estimate;
run;
*ods trace off;

data ivh_pv;
	set ivh_estimate(firstobs=1 obs=8);
	
	
	
	*if _n_=1 then call symput("sp0", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    *if _n_=2 then call symput("sp1", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    
    if _n_=1 then call symput("sp0", compress(put(estimate,7.3)||"("||put(stderr,7.3)||")"));
    if _n_=2 then call symput("sp1", compress(put(estimate,7.3)||"("||put(stderr,7.3)||")"));
 	
	if probt<0.001 then pv="<0.001"; else pv=put(probt, 5.3);
	if _n_=3 then call symput("p", compress(pv));
	if _n_=4 then call symput("pi", compress(pv));
	if _n_=5 then call symput("p1", compress(pv));
	if _n_=6 then call symput("p4", compress(pv));
	if _n_=7 then call symput("p7", compress(pv));
	if _n_=8 then call symput("p14", compress(pv));
run;


data ivh_estimate;
	set ivh_estimate(firstobs=9);
	if find(label,"No IVH") then group=0; else group=1;
	if find(label,"intercept") then day=0; 
	else day= compress(scan(label,2,","), 'Day');
	day1=day+0.2;

	if upper<0 then upper=0;
	if lower<0 then lower=0;
	if estimate<0 then delete;
	if group=1 and day>=14 then delete;
	
	if day<8;
	keep group day day1 estimate upper lower;
run;

		DATA anno0; 
			set ivh_estimate;
			
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
			  X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;

		DATA anno1; 
			set ivh_estimate;
			
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
			  X=day1-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day1;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;


data anno;
	set anno0 anno1;
run;

data ivh_estimate;
	merge ivh_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	ivh_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by day;
	lu0=put(estimate0,4.1)||"["||put(lower0,4.1)||"-"||put(upper0,4.1)||"]";
	lu1=put(estimate1,4.1)||"["||put(lower1,4.1)||"-"||put(upper1,4.1)||"]";
	if estimate0<0 then lu0="-";
	if estimate1<0 then lu1="-";

	if day=0  then pv=&pi;
		if day=1  then pv=&p1;
			if day=4  then pv=&p4;
				if day=7  then pv=&p7;
					
run;

	goptions reset=global rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext=triplex FTITLE=triplex FBY=triplex;

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=1 width=2;
	symbol2 i=j ci=red value=dot co=red cv=red h=3 w=2;

	axis1 	label=(h=4 "Age (days)" ) split="*"	value=(h=3)  order= (-1 to 8 by 1) minor=none offset=(0 in, 0 in);
	axis2 	label=(h=4 a=90 "Hemoglobin(g/dL)") value=(h=3) order= (12 to 14.5 by 0.5) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
   value = (h=3 "Non-IVH" "IVH") offset=(-0.5in, -0.4 in) frame;
	                
	*title1 	height=3 "Hemoglobin vs Age (Non-IVH=&no_ivh(&no obs), IVH=&yes_ivh(&yes obs))";
	title1 	height=4 "Hemoglobin vs Age (Non-IVH=&no_ivh, IVH=&yes_ivh (with Hemoglobin before IVH diagnosis))";
	title2 	height=3 "Test of equal slopes: p=&p(Slope of non-IVH =&sp0 vs Slope of IVH =&sp1);";
	title3 	height=3 "Test of equal intercepts: p=&pi after ajustment for gestational age";

	ods pdf file = "hb_ivh_gestage_slope.pdf" style=journal ;
			proc gplot data= ivh_estimate;
				plot estimate0*day estimate1*day1/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 4.1 day dt.;
				    /*
					note h=1 m=(2pct, 6.5 pct) "Day :" ;
                	note h=1 m=(2pct, 5.5 pct) "(#Non-IVH)" ;
                	note h=1 m=(2pct, 4.5 pct) "(#IVH)" ;
                	*/
			run;
			
			proc print data=ivh_estimate noobs label split="*";
				 title2 " ";
   			     title3 " ";
			var day lu0 lu1 pv/style=[just=center width=2in];
			label day="Day"
			      lu0="Non-IVH*Mean[95%CI]" lu1="IVH*Mean[95%CI]" pv="p value";
			run;	

	ods pdf close;

