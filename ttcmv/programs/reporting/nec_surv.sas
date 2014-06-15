options ORIENTATION=landscape nodate nonumber;
libname wbh "/ttcmv/sas/programs";	

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

data nec;
	merge nec0 cmv.comp_pat(in=comp keep=id dob) 
	cmv.km(where=(bellstage2=1) keep=id bellstage2 in=bell)
	cmv.endofstudy(keep=id StudyLeftDate); by id;
	if comp;
	if bell then nec=1; else nec=0;
	retain ndate;
	if first.id then ndate=necdate;

	day=StudyLeftDate-dob;
	if nec then day=nDate-dob;
	if day>1000 then day=.;

	format ndate mmddyy8.;
run;

proc sort nodupkey; by id day;run;

proc lifetest nocensplot data=nec timelist=0 3 7 14 21 28 35 42 49 56 63 70 77 84 outsurv=pl1;
ods output productlimitestimates=plt;
	time day*nec(0);
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
	if Timelist=63 then call symput( "n63",  compress(put(left, 3.0))); 
	if Timelist=70 then call symput( "n70",  compress(put(left, 3.0))); 
	if Timelist=77 then call symput( "n77",  compress(put(left, 3.0))); 
	if Timelist=84 then call symput( "n84",  compress(put(left, 3.0))); 
run;

proc format;
		value dd  0="0*(&n0)" 3="3*(&n3)" 7="7*(&n7)" 14="14*(&n14)" 21="21*(&n21)" 28="28*(&n28)" 35="35*(&n35)" 
		42="42*(&n42)"  49="49*(&n49)" 56="56*(&n56)"	63="63*(&n63)" 	70="70*(&n70)" 77="77*(&n77)" 84="84*(&n84)";
run;


proc lifetest /*nocensplot*/ plots=(s) data=nec confband=all outsurv=pl1;
*ods output productlimitestimates=pl;
	time day*nec(0);
run;

data pl;
    set pl1 end=last;
    prob=1-SURVIVAL;
	lower=1-SDF_UCL;
	upper=1-SDF_LCL;
	
	retain p1 p2 p3 lday;
	if prob^=. then do; p1=prob; p2=lower; p3=upper; lday=day; end;
	
    output;	
    if last then do; 
        day=lday+7; 
        call symput("lday", compress(day));
        prob=p1; lower=p2; upper=p3; output; 
    end;
    
    keep day prob upper lower;  
run;

data pl; set pl; if day<=&lday;run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct colors=(orange green red) 
ftitle=zapf ftext=zapf hby = 3;

symbol1 i=stepjl mode=exclude value=circle co=black cv=black height=0.6 bwidth=4 width=1.5 l=1;
symbol2 i=stepjl mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=3;
symbol3 i=stepjl mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=3;


title h=3 justify=center Cumulative Incidence of NEC and 95% Confidence Intervals;
         
axis1 	label=(h=2.5 'Age of Low Birth Weight Infants' ) split="*" value=(h=2) order= (0 to 84 by 7) minor=none;
axis2 	label=(h=2.5 a=90 "Probability of NEC") order=(0 to 0.20 by 0.05) value=(h=2) ;
     
             
proc gplot data=pl gout=wbh.graphs;
	plot  prob*day upper*day lower*day/overlay haxis = axis1 vaxis = axis2  nolegend;

	note h=2 m=(2pct, 11.0 pct) "Day:" ;
	note h=2 m=(0pct, 8.25 pct) "(# At Risk)" ;
	format day dd. failure 4.2;
run;	


/* ** For outout tiff format only!*/;
filename output "test.tiff";

goptions reset=global gsfmode=replace gunit=pct border ctext=black ftitle=swissb ftext=swiss htitle=3 htext=3
device=tiffb gsfname=output gsfmode=replace;


goptions reset=all  gunit=pct noborder colors=(orange green red) ftext=Times hby = 3;
ods pdf file = "nec_km_curve.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;







