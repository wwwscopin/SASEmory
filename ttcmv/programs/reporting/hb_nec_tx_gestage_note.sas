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

run;

data hb0;
	set cmv.plate_015 
		cmv.plate_031(keep=id Hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate));

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;
		
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
    if id<1000000 then delete;
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
	cmv.plate_031(keep=id in=in_tx)
	cmv.plate_006(keep=id gestage)
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob)); by id;
	
	
	if comp;
	if bell then nec=1; else nec=0;
	day=hbdate-dob+1;
	retain ndate;
	if nec and first.id then ndate=necdate;

	
	if hbdate>ndate and nec then hb=.;
	if hb<6 or hb>25 or hbdate<dob then delete;

	if nec=0 then if in_tx=0 then nec=0; else if in_tx=1 then nec=2;
	format gender gender. ndate mmddyy8.;
	
	rename dfseq=dday;
run;

proc means data=nec mean;
    var gestage;
    output out=test;
run;

data _null_;
    set test;
    if _n_=4;
    call symput("nage", compress(put(gestage, 4.1)));
run;


proc means data=nec /*noprint*/;
	class nec;
	var id;
	output out=nec_obs n(id)=n;
run;


data _null_;
	set nec_obs;
	if nec=0 then call symput("m0",compress(n));
	if nec=1 then call symput("m1",compress(n));
	if nec=2 then call symput("m2",compress(n));
run;

proc sort data=nec nodupkey out=nec_id; by id;run;

proc means data=nec_id noprint;
	class nec;
	var id;
	output out=nec_num n(id)=n;
run;

data _null_;
	set nec_num;
	if nec=0 then call symput("n0",compress(n));
	if nec=1 then call symput("n1",compress(n));
	if nec=2 then call symput("n2",compress(n));
run;

proc sort data=nec nodupkey; by id hbdate; run;
proc sort data=nec out=nec_id nodupkey; by nec dday id; run;

proc means data=nec_id /*noprint*/;
	class nec dday;
	var id;
	output out=wbh;
run;

%let a0= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b0= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;
%let c0= 0; %let c1= 0; %let c4= 0; %let c7= 0; %let c14= 0; %let c21= 0; %let c28=0; %let c40=0;  %let c60=0;

data _null_;
	set wbh;
	if nec=0 and dday=1  then call symput( "a1",   compress(_freq_));
	if nec=0 and dday=4  then call symput( "a4",   compress(_freq_));
	if nec=0 and dday=7  then call symput( "a7",   compress(_freq_));
	if nec=0 and dday=14 then call symput( "a14",  compress(_freq_));
	if nec=0 and dday=21 then call symput( "a21",  compress(_freq_));
	if nec=0 and dday=28 then call symput( "a28",  compress(_freq_));
	if nec=0 and dday=40 then call symput( "a40",  compress(_freq_));
	if nec=0 and dday=60 then call symput( "a60",  compress(_freq_));

	if nec=1 and dday=1  then call symput( "b1",   compress(_freq_));
	if nec=1 and dday=4  then call symput( "b4",   compress(_freq_));
	if nec=1 and dday=7  then call symput( "b7",   compress(_freq_));
	if nec=1 and dday=14 then call symput( "b14",  compress(_freq_));
	if nec=1 and dday=21 then call symput( "b21",  compress(_freq_));
	if nec=1 and dday=28 then call symput( "b28",  compress(_freq_));
	if nec=1 and dday=40 then call symput( "b40",  compress(_freq_));
	if nec=1 and dday=60 then call symput( "b60",  compress(_freq_));
	
	if nec=2 and dday=1  then call symput( "c1",   compress(_freq_));
	if nec=2 and dday=4  then call symput( "c4",   compress(_freq_));
	if nec=2 and dday=7  then call symput( "c7",   compress(_freq_));
	if nec=2 and dday=14 then call symput( "c14",  compress(_freq_));
	if nec=2 and dday=21 then call symput( "c21",  compress(_freq_));
	if nec=2 and dday=28 then call symput( "c28",  compress(_freq_));
	if nec=2 and dday=40 then call symput( "c40",  compress(_freq_));
	if nec=2 and dday=60 then call symput( "c60",  compress(_freq_));
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
proc mixed data=nec covtest method=MIVQUE0;
	class id nec;
	model hb=nec day nec*day gestage/s;
	random int day/type=un subject=id;
	estimate "No tx, slope" day 1 nec*day 1 0 0;
	estimate "Yes NEC, slope" day 1 nec*day 0 1 0;
	estimate "Yes tx, slope" day 1 nec*day 0 0 1;
	estimate "Compare slopes between tx vs no-tx" nec*day 1 0 -1;
	estimate "Compare slopes between no-tx vs NEC" nec*day 1 -1 0;
    estimate "Compare slopes between yes-tx vs NEC" nec*day 0  1 -1;

	estimate "No tx, intercept" int 1 nec 1 0 0 gestage &nage/cl;
	estimate "No tx, Day1"  int 1 nec 1 0 0 day 1  day*nec 1  0 0 gestage &nage;
	estimate "No tx, Day4"  int 1 nec 1 0 0 day 4  day*nec 4  0 0 gestage &nage;
	estimate "No tx, Day7"  int 1 nec 1 0 0 day 7  day*nec 7  0 0 gestage &nage;
	estimate "No tx, Day14" int 1 nec 1 0 0 day 14 day*nec 14 0 0 gestage &nage;
	estimate "No tx, Day21" int 1 nec 1 0 0 day 21 day*nec 21 0 0 gestage &nage;
	estimate "No tx, Day28" int 1 nec 1 0 0 day 28 day*nec 28 0 0 gestage &nage;
	estimate "No tx, Day40" int 1 nec 1 0 0 day 40 day*nec 40 0 0 gestage &nage;
	estimate "No tx, Day60" int 1 nec 1 0 0 day 60 day*nec 60 0 0 gestage &nage/e;

	estimate "Yes NEC, intercept" int 1 nec 0 1 0 gestage &nage/cl;
	estimate "    NEC, Day1"  int 1 nec 0 1 0 day 1  day*nec 0 1  0 gestage &nage;
	estimate "    NEC, Day4"  int 1 nec 0 1 0 day 4  day*nec 0 4  0 gestage &nage;
	estimate "    NEC, Day7"  int 1 nec 0 1 0 day 7  day*nec 0 7  0 gestage &nage;
	estimate "    NEC, Day14" int 1 nec 0 1 0 day 14 day*nec 0 14 0 gestage &nage;
	estimate "    NEC, Day21" int 1 nec 0 1 0 day 21 day*nec 0 21 0 gestage &nage;
	estimate "    NEC, Day28" int 1 nec 0 1 0 day 28 day*nec 0 28 0 gestage &nage;
	estimate "    NEC, Day40" int 1 nec 0 1 0 day 40 day*nec 0 40 0 gestage &nage;
	estimate "    NEC, Day60" int 1 nec 0 1 0 day 60 day*nec 0 60 0 gestage &nage/e;
	
	estimate "Yes tx, intercept" int 1 nec 0 0 1 gestage &nage/cl;
	estimate "Yes tx, Day1"  int 1 nec 0 0 1 day 1  day*nec 0 0 1 gestage &nage;
	estimate "Yes tx, Day4"  int 1 nec 0 0 1 day 4  day*nec 0 0 4 gestage &nage;
	estimate "Yes tx, Day7"  int 1 nec 0 0 1 day 7  day*nec 0 0 7 gestage &nage;
	estimate "Yes tx, Day14" int 1 nec 0 0 1 day 14 day*nec 0 0 14 gestage &nage;
	estimate "Yes tx, Day21" int 1 nec 0 0 1 day 21 day*nec 0 0 21 gestage &nage;
	estimate "Yes tx, Day28" int 1 nec 0 0 1 day 28 day*nec 0 0 28 gestage &nage;
	estimate "Yes tx, Day40" int 1 nec 0 0 1 day 40 day*nec 0 0 40 gestage &nage;
	estimate "Yes tx, Day60" int 1 nec 0 0 1 day 60 day*nec 0 0 60 gestage &nage/e;
	
	ods output Mixed.Estimates=nec_estimate;
run;
*ods trace off;

data nec_slope;
    length pv $8;
	set nec_estimate(firstobs=1 obs=6);
    if _n_=1 then call symput("sp0", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    if _n_=2 then call symput("sp1", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));
    if _n_=3 then call symput("sp2", compress(put(estimate,7.3)||"&pm"||put(stderr,7.3)));

    if _n_>=4  then do;  if probt>0.01 then pv=put(Probt,4.2);  else pv="<0.01"; end;
    
    if _n_=4 then call symput("p1", compress(pv));
        if _n_=5 then call symput("p2",  compress(pv));
            if _n_=6 then call symput("p3",  compress(pv));
run;

data nec_estimate;
	set nec_estimate(firstobs=7);
	if find(label,"No tx") then group=0; 
	else if find(label,"Yes tx") then group=2; 
	else group=1;
	
	if find(label,"intercept") then day=0; 
	else day= compress(scan(label,2,","),"Day");
	day1=day+0.2;
	day2=day-0.2;
	
	if group in(0,1) then if day>40 then delete;
	
	keep group day day1 day2 estimate upper lower;
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
	length function text $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; 
	x=day; y=12; size=1.25;	text=left(put(day,dt.));	output;
	x=day; y=10; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=8.0; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=6.0; size=1; 	text=left(put(day,dtc.));	output;
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
	length function text $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; 
	x=day; y=12; size=1.25;	text=left(put(day,dt.));	output;
    x=day; y=10; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=8.0; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=6.0; size=1; 	text=left(put(day,dtc.));	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;



		DATA anno2; 
			set nec_estimate;
			
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
			  X=day2-0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day2+0.2; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
			  X=day2;     FUNCTION='MOVE'; when = 'A';                                OUTPUT;
			return;
	run;

data anno2A;
	length function text $8;
	retain xsys '2' ysys '3' color 'black' when 'a';
	set nec_estimate;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; 
	x=day; y=12; size=1.25;	text=left(put(day,dt.));	output;
    x=day; y=10; size=1; 	text=left(put(day,dta.));	output;
	x=day; y=8.0; size=1; 	text=left(put(day,dtb.));	output;
	x=day; y=6.0; size=1; 	text=left(put(day,dtc.));	output;
run;

data anno2;
	length color $6 function $8;
	set anno2 anno2A;
run;



data anno;
	set anno0 anno1 anno2;
run;

data nec_estimate;
	merge nec_estimate(where=(group=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	nec_estimate(where=(group=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	nec_estimate(where=(group=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) ; by day;
	lu0=put(estimate0,4.1)||"["||put(lower0,4.1)||"-"||put(upper0,4.1)||"]";
	lu1=put(estimate1,4.1)||"["||put(lower1,4.1)||"-"||put(upper1,4.1)||"]";
	lu2=put(estimate2,4.1)||"["||put(lower2,4.1)||"-"||put(upper2,4.1)||"]";
		if day=60 then do; lu0=" "; lu1=" "; end;
run;



options orientation=landscape;		
proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;

goptions reset=global rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext="Times" FTITLE="Times" FBY="Times";



	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=3 width=1;
	symbol2 i=j ci=red value=dot co=red cv=red h=3 w=1;
	symbol3 i=j ci=green value=square co=green cv=green h=3 w=1;

	   
	axis1 	label=(h=3 " " ) split="*"	
	   value=(h=1.25) major=(c=black) origin=(,15)pct order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	   
	axis2 	label=(h=3 a=90 "Hemoglobin(g/dL)") value=(h=2.5) c=black order= (7 to 16 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve shape = symbol(3,2) label=NONE 
    value = ( h=2 c=black "Non-NEC without tx" "NEC" "Non-NEC with tx") offset=(-1in, -0.4 in) frame cframe=white cborder=black;
	                
	title1 	height=4 "Hemoglobin vs Days (non-NEC without tx=&n0(&m0 obs), NEC=&n1(&m1 obs), non-NEC with tx=&n2(&m2 obs))";
	title2 	height=2.5 "Slope of Non-NEC without tx=&sp0, Slope of Non-NEC with tx=&sp2, Slope of NEC=&sp1";
	title3  height=2.5 "Test of equal slopes between Non-NEC without tx and with tx, p=&p1; between Non-NEC without tx and NEC, p=&p2; between Non-NEC with tx and NEC, p=&p3";


	ods pdf file = "hb_nec_slope_tx_gestage.pdf" style=journal;
			proc gplot data= nec_estimate;
				plot estimate0*day estimate1*day1 estimate2*day2/overlay annotate= anno haxis = axis1 vaxis = axis2 legend=legend;
				format estimate0 estimate1 estimate2 4.0 day dd.;
				
				note h=3 m=(20pct, 0 pct) "Age Before the First NEC Diagnosis (NEC) or Age of non-NEC LBWIs" ;
				
				note h=1.5 m=(-2pct, 11 pct) "Day :" ;
               	note h=1.5 m=(-2pct, 9 pct) "#Non-NEC no Tx" ;
               	note h=1.5 m=(-2pct, 7 pct) "#NEC" ;
               	note h=1.5 m=(-2pct, 5 pct) "#Non-NEC with Tx" ;
			run;	
			
			proc print data=nec_estimate noobs label;
			var day lu0 lu1 lu2/style=[just=center width=2in];
			label day="Day"
			      lu0="Non-NEC without tx" lu1="NEC" lu2="Non-NEC with tx";
			run;

	ods pdf close;
