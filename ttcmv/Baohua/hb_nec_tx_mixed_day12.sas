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
	keep id HbDate Hb;
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
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob)); by id;
	
	
	if comp;
	if necdate=. then nec=0; else nec=1;
	day=hbdate-dob+1;
	retain ndate;
	if nec and first.id then ndate=necdate;
	
    discharge_day=StudyLeftDate-dob;
	
	if hbdate>ndate and nec then hb=.;
	if hb<6 or hb>25 or hbdate<dob then delete;

	if nec=0 then if in_tx=0 then nec=0; else if in_tx=1 then nec=2;
	format gender gender. ndate mmddyy8.;
	
	*rename dfseq=dday;
    if day in(1) then dday=1;
      else if day in(2) then dday=2;
        else if day in(3,4,5) then dday=4;
           else if day in(6,7,8,9) then dday=7;
              else if 10<=day<=17 then dday=14;
                  else if 18<=day<=24 then dday=21;
                       else if 25<=day<=34 then dday=28;
                            else if 35<=day<=48 then dday=40;
                                 else if 49<=day then dday=60;
run;

/*
proc sort nodupkey; by id day hb;run;

proc print;
where dday in(1,2);
run;
*/

proc means data=nec mean;
    var gestage;
    output out=test;
run;

data _null_;
    set test;
    if _n_=4;
    call symput("nage", compress(put(gestage, 4.1)));
run;

/*
proc sort data=nec out=nec_tmp nodupkey;by nec id; run;

proc means data=nec_tmp mean median noprint;
	class nec;
	var  discharge_day;
run;
*/

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

%let a0= 0; %let a1= 0; %let a2= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40=0;  %let a60=0;
%let b0= 0; %let b1= 0; %let b2= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40=0;  %let b60=0;
%let c0= 0; %let c1= 0; %let c2= 0; %let c4= 0; %let c7= 0; %let c14= 0; %let c21= 0; %let c28=0; %let c40=0;  %let c60=0;

data _null_;
	set wbh;
	if nec=0 and dday=1  then call symput( "a1",   compress(_freq_));
	if nec=0 and dday=2  then call symput( "a2",   compress(_freq_));
	if nec=0 and dday=4  then call symput( "a4",   compress(_freq_));
	if nec=0 and dday=7  then call symput( "a7",   compress(_freq_));
	if nec=0 and dday=14 then call symput( "a14",  compress(_freq_));
	if nec=0 and dday=21 then call symput( "a21",  compress(_freq_));
	if nec=0 and dday=28 then call symput( "a28",  compress(_freq_));
	if nec=0 and dday=40 then call symput( "a40",  compress(_freq_));
	if nec=0 and dday=60 then call symput( "a60",  compress(_freq_));

	if nec=1 and dday=1  then call symput( "b1",   compress(_freq_));
	if nec=1 and dday=2  then call symput( "b2",   compress(_freq_));
	if nec=1 and dday=4  then call symput( "b4",   compress(_freq_));
	if nec=1 and dday=7  then call symput( "b7",   compress(_freq_));
	if nec=1 and dday=14 then call symput( "b14",  compress(_freq_));
	if nec=1 and dday=21 then call symput( "b21",  compress(_freq_));
	if nec=1 and dday=28 then call symput( "b28",  compress(_freq_));
	if nec=1 and dday=40 then call symput( "b40",  compress(_freq_));
	if nec=1 and dday=60 then call symput( "b60",  compress(_freq_));
	
	if nec=2 and dday=1  then call symput( "c1",   compress(_freq_));
	if nec=2 and dday=2  then call symput( "c2",   compress(_freq_));
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
 0="0" 1="1"  2="2" 3=" " 4 = "4" 5=" " 6=" " 7="7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "60" ;
 
value dta   
  0=" " 1="&a1"  2="&a2" 3=" " 4 = "&a4" 5=" " 6=" " 7="&a7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&a14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&a21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&a28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&a40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&a60" ;
 

value dtb   
  0=" " 1="&b1"  2="&b2" 3=" " 4 = "&b4" 5=" " 6=" " 7="&b7" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "&b14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="&b21" 22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "&b28"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="&b40" 43=" "	44=" " 45=" " 46=" " 47=" " 48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" "   60 = "&b60" ;

value dtc   
  0=" " 1="&c1"  2="&c2" 3=" " 4 = "&c4" 5=" " 6=" " 7="&c7" 8=" " 9=" " 10=" " 
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

data new_nec;
    set nec(drop=day);
    rename dday=day;
run;


*ods trace on/label listing;
proc mixed data=new_nec covtest;
	class id nec day;
	model hb=nec day nec*day/s;
	repeated day/type=cs subject=id;
	lsmeans nec nec*day/cl ;
	
	ods output lsmeans = avg;
	ods output Mixed.Tests3=pv;
run;
*ods trace off;



data pv;
    length pv $8;
	set pv(firstobs=1 obs=3);
	if probf<0.0001 then pv="<0.0001"; else pv=compress(put(probf, 7.4));
    if _n_=1 then call symput("pn", pv);
    if _n_=2 then call symput("pd", pv);
    if _n_=3 then call symput("pi", pv);
run;

data avg;
    set avg;
    if _n_ in(1,2,3) then delete;
    day1=sum(of day,0.2);
    day2=sum(of day,-0.2);
    /*if day in(40,60) and nec in(0,1) then do; nec=.; end;*/
run;

		DATA anno0; 
			set avg;
			
			where nec=0;
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
	set avg;
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
			set avg;
			
			where nec=1;
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
	set avg;
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
			set avg;
			
			where nec=2;
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
	set avg;
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
	merge avg(where=(nec=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	avg(where=(nec=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) 
	avg(where=(nec=2) rename=(estimate=estimate2 lower=lower2 upper=upper2)) ; by day;
	lu0=put(estimate0,4.1)||"["||put(lower0,4.1)||"-"||put(upper0,4.1)||"]";
	lu1=put(estimate1,4.1)||"["||put(lower1,4.1)||"-"||put(upper1,4.1)||"]";
	lu2=put(estimate2,4.1)||"["||put(lower2,4.1)||"-"||put(upper2,4.1)||"]";
				/*if day>=40 then do; lu0="-"; lu1="-"; end;*/
run;



options orientation=landscape;		
proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;

goptions reset=global rotate=landscape gunit=pct noborder cback=white
		colors = (black red) ftext="Times" FTITLE="Times" FBY="Times";

/*
goptions reset=global rotate=landscape gunit=pct noborder CBACK=blue ctext=white ctitle=white colors=(orange green red)
 ftitle="Times New Roman/bold" ftext="Times New Roman/bold" htitle=3.5 htext=3;
*/	

	symbol1 interpol=j mode=exclude value=circle co=blue cv=blue height=3 bwidth=3 width=1;
	symbol2 i=j ci=red value=dot co=red cv=red h=3 w=1;
	symbol3 i=j ci=green value=square co=green cv=green h=3 w=1;

	   
	axis1 	label=(h=3 " " ) split="*"	
	   value=(h=1.25) major=(c=black) origin=(,15)pct order= (-1 to 61 by 1) minor=none offset=(0 in, 0 in);
	   
	axis2 	label=(h=3 a=90 "Hemoglobin(g/dL)") value=(h=2.5) c=black order= (7 to 17 by 1) offset=(.25 in, .25 in) minor=(number=1); 


	legend across = 1 position=(top right inside) mode = reserve shape = symbol(3,2) label=NONE 
    value = ( h=2 c=black "Non-NEC without tx" "NEC" "Non-NEC with tx") offset=(-1in, -0.4 in) frame cframe=white cborder=black;
	                
	title1 	height=4 "Hemoglobin vs Days (non-NEC without tx=&n0(&m0 obs), NEC=&n1(&m1 obs), non-NEC with tx=&n2(&m2 obs))";
	title2 	height=3 "p(NEC)=&pn, p(Day)=&pd, p(NEC*Day)=&pi";

	ods pdf file = "hb_nec_tx_repeated_day1_2.pdf" style=journal;
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
			title2 " ";
			
			var day lu0 lu1 lu2/style=[just=center width=2in];
			label day="Day"
			      lu0="Non-NEC without tx" lu1="NEC" lu2="Non-NEC with tx";
			run;

	ods pdf close;
