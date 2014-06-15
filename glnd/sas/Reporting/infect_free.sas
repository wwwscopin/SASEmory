options ORIENTATION=landscape nodate nonumber;

	proc sort data =  glnd_rep.suspected_noso_after_adj; by id site_code type_code dt_infect ; run;
	
	/*proc contents data=glnd.status;run;*/

	* this is the patient infections, with the adjudicated infection data for those people adjudicated ;
	data all_infect0;
	     
		set glnd_rep.all_infections_with_adj;
		if incident=1 and compress(site_code) in("BSI", "LRI", "GI", "CVS", "SSI", "UTI");
		if compress(site_code)="UTI" and compress(type_code) = "SUTI" then delete;
		keep id dt_infect site_code;
	run;
	
	proc sort; by id dt_infect;run;
	
	data all_infect;
	   set all_infect0; by id dt_infect;
	   if first.id;
	run;
	
	
	data infect;
	   merge all_infect(in=A)
	   glnd.status(keep=id days_hosp_post_entry)
	   glnd.george (keep = id treatment dt_random);	by id;
	   if A then infect=1; else infect=0;
	   rename days_hosp_post_entry=day;
	run;
	
	proc print;run;
	

proc lifetest nocensplot data=infect timelist=0 7 14 21 28 35 42 49 56 63 70 77 84 91 98 outsurv=pl1;
ods output productlimitestimates=hosp;
	time day*infect(0);
run;

data _null_;
	set hosp;
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
	if Timelist=77 then call symput( "n77",  compress(put(left, 3.0))); 
	if Timelist=84 then call symput( "n84",  compress(put(left, 3.0))); 
	if Timelist=91 then call symput( "n91",  compress(put(left, 3.0))); 
	if Timelist=98 then call symput( "n98",  compress(put(left, 3.0))); 
run;

proc format;
		value dd  2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35="35|(&n35) " 36=" " 37=" " 38=" " 39=" "
 		41=" "	42="42|(&n42) " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 0="0|(&n0*)" 
		1=" " 7="7|(&n7)" 14="14|(&n14)" 21="21|(&n21)" 28="28|(&n28)" 49="49|(&n49)" 56="56|(&n56)" 40=" " 63="63|(&n63)" 70="70|(&n70)"
		77="77|(&n77)" 84="84|(&n84)" 91="91|(&n91)" 98="98|*(&n98)";
run;


proc lifetest /*nocensplot*/ plots=(s) data=infect confband=all outsurv=hop1;
ods output productlimitestimates=hop;
	time day*infect(0);
run;

data hop1;
    set hop1;
    if SDF_LCL=. then delete;
run;


data hop; 
    merge hop hop1(keep=day SDF_LCL SDF_UCL); by day; 
run;

proc sort data=hop; by Failed;run;

data hop;
	set hop; by failed;
	retain prob1 upper1 lower1;
	if first.failed then do;
	   prob1=failure;
	   upper1=1-SDF_UCL;
	   lower1=1-SDF_LCL;
	end;
	if prob1=. then delete;
run;

data hop;
	set hop; by failed;
	retain prob2 upper2 lower2;
	if last.failed then do;
	   prob2=prob1;
	   upper2=upper1;
	   lower2=lower1;
	   
   	   prob3=lag(prob1);
	   upper3=lag(upper1);
	   lower3=lag(lower1);
	end;
run;

data hop;
	set hop; by failed;
	if not first.failed then prob2=.;
	if prob2=. then do; prob3=.; upper3=.; lower3=.; end;
run;

data hop;	
	set hop(keep=day prob1 upper1 lower1 rename=(prob1=prob upper1=upper lower1=lower)) 
    	hop(keep=day prob3 upper3 lower3 rename=(prob3=prob upper3=upper lower3=lower)) 
	    hop(keep=day prob2 upper2 lower2 rename=(prob2=prob upper2=upper lower2=lower)); by day; 
	if prob=. then delete;
	prob0=1-prob;
	upper0=1-upper;
	lower0=1-lower;
	if prob0<0 then prob0=0;
	if upper0<0 then upper0=0;
	if lower0<0 then lower0=0;
	if day=201 then day=91;
	if upper=. then delete;
run;

proc sort; by day prob; run;

proc print;run;

proc greplay igout= glnd_rep.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct colors=(orange green red) 
ftitle=zapf ftext=zapf hby = 3;

symbol1 i=j mode=exclude value=none co=black cv=black height=0.6 bwidth=4 width=1.5 l=1;
symbol2 i=j mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=3;
symbol3 i=j mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=3;

title h=3 justify=center Cumulative Incidence of Infect-Free and 95% Confidence Intervals;
         
axis1 	label=(h=2.5 'Day on Study' ) split="|" value=(h=2) order= (0 to 95 by 7) minor=none;
axis2 	label=(h=2.5 a=90 "Incidece Probality") order=(0 to 1 by 0.10) value=(h=2) ;
     
             
proc gplot data=hop gout=glnd_rep.graphs;
	plot  prob0*day upper0*day lower0*day/overlay haxis = axis1 vaxis = axis2  nolegend;

	note h=2 m=(1pct, 11.0 pct) "Day:" ;
	note h=2 m=(1pct, 8.25 pct) "(#free)" ;
	format day dd. failure 4.2;

	note h=1.5 m=(1pct, 6pct) "* Asymptomatic UTI are excluded from infection, one patient died on date of randomized." ;
run;	


filename output 'infect_free.eps';
goptions reset=all rotate = landscape device=pslepsfc gsfname=output gsfmode=replace;

ods pdf file = "infect_free.pdf";
	proc greplay igout =glnd_rep.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;
ods pdf close;
