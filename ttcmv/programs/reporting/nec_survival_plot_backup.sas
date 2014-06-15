options ORIENTATION="portrait";
libname wbh "/ttcmv/sas/programs";	

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

data nec;
	merge nec0 cmv.comp_pat(in=comp keep=id dob) 	cmv.endofstudy(keep=id StudyLeftDate); by id;
	if comp;
	if necdate=. then nec=0; else nec=1;
	retain ndate;
	if first.id then ndate=necdate;

	day=StudyLeftDate-dob;
	if nec then day=nDate-dob;
	if day>1000 then day=.;

	format ndate mmddyy8.;
run;

proc sort nodupkey; by id day;run;

proc lifetest nocensplot data=nec timelist=0 7 14 21 28 35 42 49 56 63 70 outsurv=pl1;
ods output productlimitestimates=plt;
	time day*nec(0);
run;

data _null_;
	set plt;
	if Timelist=0  then call symput( "n0",   compress(put(left, 3.0))); 
	if Timelist=7  then call symput( "n7",   compress(put(left, 3.0))); 
	if Timelist=14 then call symput( "n14",  compress(put(left, 3.0))); 
	if Timelist=21 then call symput( "n21",  compress(put(left, 3.0))); 
	if Timelist=28 then call symput( "n28",  compress(put(left, 3.0))); 
	if Timelist=35 then call symput( "n35",  compress(put(left, 3.0))); 
	if Timelist=42 then call symput( "n42",  compress(put(left, 3.0))); 
	if Timelist=49 then call symput( "n49",  compress(put(left, 3.0))); 
	if Timelist=56 then call symput( "n56",  compress(put(left, 3.0))); 
	if Timelist=63 then call symput( "n63",  compress(put(left, 3.0))); 
	if Timelist=70 then call symput( "n70",  compress(put(left, 3.0))); 
run;

proc format;
		value dd  2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35="35*(&n35) " 36=" " 37=" " 38=" " 39=" "
 		41=" "	42="42*(&n42) " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 0="0*(&n0)" 
		1=" " 7="7*(&n7)" 14="14*(&n14)" 21="21*(&n21)" 28="28*(&n28)" 49="49*(&n49)" 56="56*(&n56)"	40=" " 63="63*(&n63)" 70="70*(&n70)";
run;


proc lifetest /*nocensplot*/ plots=(s) data=nec outsurv=pl1;
ods output productlimitestimates=pl;
	time day*nec(0);
run;

ods output close;
proc contents data=pl;run;
/*proc print data=pl;run;*/

proc sort data=pl; by Failed;run;

data pl;
	set pl; by failed;
	retain prob1;
	if first.failed then prob1=failure;
	if prob1=. then delete;
run;

data pl;
	set pl; by failed;
	retain prob2;
	if last.failed then prob2=prob1;
run;

data pl;
	set pl; by failed;
	if not first.failed then prob2=.;
run;

proc print;run;

data pl;	
	set pl(keep=day prob1 rename=(prob1=prob)) pl(keep=day prob2 rename=(prob2=prob)); by day; 
	if prob=. then delete;
run;

proc sort; by day prob; run;
proc print;run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  device=jpeg gunit=pct noborder cback=white colors = (black red) ftext=zapf hby = 3;
symbol1 i=j mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=0.8;

title h=3.5 justify=center Time to NEC;
         
axis1 	label=(f=zapf h=3 'Infant Day of Life' ) split="*" value=(f=zapf h=2.0) order= (0 to 70 by 7) minor=none;
axis2 	label=(f=zapf h=3 a=90 "Probability of NEC") order=(0 to 0.20 by 0.05) value=(f=zapf h=2) ;
        
             
proc gplot data=pl gout=wbh.graphs;
	plot  prob*day / haxis = axis1 vaxis = axis2  nolegend;

	note h=2 m=(0pct, 10.5 pct) "Day:" ;
	note h=2 m=(0pct, 8 pct) "(No at Risk)" ;
	format day dd. failure 4.2;
run;	

goptions reset=all; 
*ods pdf file = "/ttcmv/sas/output/april2011abstracts/nec_km_curve.pdf";
ods pdf file = "nec_km_curve.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=v2s nofs;
			list igout;
			treplay 1:1; 
run;

 
