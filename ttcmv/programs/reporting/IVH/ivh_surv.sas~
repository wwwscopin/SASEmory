options ORIENTATION=landscape nodate nonumber;
libname wbh "/ttcmv/sas/programs/reporting/baohua/IVH";	


proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh0;
    set cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade); 
 	if LeftIVHGrade in(2,3,4) or RightIVHGrade in(2,3,4);
run;

proc sort; by id imagedate;run;


data ivh;
	merge ivh0(in=A) cmv.comp_pat(in=comp keep=id dob) cmv.endofstudy(keep=id StudyLeftDate); by id;
	if comp;
	if not A then ivh=0; else ivh=1;
	retain idate;
	if first.id then idate=imagedate;

	day=StudyLeftDate-dob;
	if ivh then day=iDate-dob;

	format idate mmddyy8.;
run;

proc sort nodupkey; by id day;run;

proc lifetest nocensplot data=ivh timelist=0 3 7 14 21 28 35 42 49 56 outsurv=pl1;
ods output productlimitestimates=plt;
	time day*ivh(0);
run;

data _null_;
	set plt;
	if Timelist=0  then call symput( "n0",   compress(put(left, 3.0))); 
	if Timelist=3  then call symput( "n3",   compress(put(left, 3.0))); 
	if Timelist=7  then call symput( "n7",   compress(put(left, 3.0))); 
	if Timelist=14 then call symput( "n14",  compress(put(left, 3.0))); 
	if Timelist=21 then call symput( "n21",  compress(put(left, 3.0))); 
	if Timelist=28 then call symput( "n28",  compress(put(left, 3.0))); 
	if Timelist=35 then call symput( "n35",  compress(put(left, 3.0))); 
	if Timelist=42 then call symput( "n42",  compress(put(left, 3.0))); 
	if Timelist=49 then call symput( "n49",  compress(put(left, 3.0))); 
	if Timelist=56 then call symput( "n56",  compress(put(left, 3.0))); 
run;

proc format;
		value dd  2=" " 4=" " 3="3*(&n3)" 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35="35*(&n35) " 36=" " 37=" " 38=" " 39=" "
 		41=" "	42="42*(&n42) " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 0="0*(&n0)" 
		1=" " 7="7*(&n7)" 14="14*(&n14)" 21="21*(&n21)" 28="28*(&n28)" 49="49*(&n49)" 56="56*(&n56)"	40=" ";
run;


proc lifetest /*nocensplot*/ plots=(s) data=ivh confband=all outsurv=pl1;
*ods output productlimitestimates=pl;
	time day*ivh(0);
run;

data pl;
    set pl1;
    prob=1-SURVIVAL;
	lower=1-SDF_UCL;
	upper=1-SDF_LCL;

	/*
	retain tmp1 tmp2 tmp3;
	if prob^=. then do; tmp1=prob; tmp2=lower; tmp3=upper; end;
	if prob=. then do; prob=tmp1; lower=tmp2; upper=tmp3; end;
	*/   
	
    keep day prob upper lower;  
run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct colors=(orange green red) 
ftitle=zapf ftext=zapf hby = 3;

symbol2 i=stepjl mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=3;
symbol1 i=stepjl mode=exclude value=circle co=black cv=black height=0.6 bwidth=4 width=1.5 l=1;
symbol3 i=stepjl mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=3;


title h=3 justify=center "Cumulative Incidence of IVH and 95% Confidence Intervals";
         
axis1 	label=(h=2.5 'Age of Low Birth Weight Infants' ) split="*" value=(h=2) order= (0 3 7 to 42 by 7) minor=none;
axis2 	label=(h=2.5 a=90 f=zapf "Probability of IVH") order=(0 to 0.20 by 0.05) value=(h=2) ;
     
             
proc gplot data=pl gout=wbh.graphs;
	plot  prob*day upper*day lower*day/overlay haxis = axis1 vaxis = axis2  nolegend;

	note h=2 m=(0pct, 8.25 pct) "(#At Risk)" ;
	note h=2 m=(0pct, 11.0 pct) "(Day:)" ;
	format day dd.;
run;	

goptions reset=all  /*device=jpeg*/ gunit=pct noborder colors=(orange green red) ftext=Times hby = 3;
ods pdf file = "ivh_km_curve234.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;
ods pdf close;
