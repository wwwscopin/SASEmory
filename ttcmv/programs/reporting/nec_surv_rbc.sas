options ORIENTATION=landscape nodate nonumber;
libname wbh "/ttcmv/sas/programs";	


proc sort data=cmv.plate_031(keep=id) out=rbc_id nodupkey; by id;run;

data donor;
	set cmv.plate_001_bu;
	keep DonorUnitId DateDonated;
run;
proc sort; by donorunitid;run;

data tx_id;
	set cmv.plate_031(keep=id DonorUnitId DateTransfusion);
run;

proc sql;
 create table tx_id as 
	select a.*, b.dob
	from tx_id as a, cmv.comp_pat as b
	where a.id=b.id;

proc sort; by donorunitid;run;

data rbc7;
	merge donor tx_id(in=tmp); by DonorUnitId;
	age=DateTransfusion-DateDonated;
	if age=. then delete;
	if tmp and age>7;
run;

proc sort nodupkey; by id; run;

data rbc_id;
    merge rbc_id rbc7(in=tmp); by id;
    if tmp then erbc=0; else erbc=1;
run;

data rbc_donor;
	merge donor tx_id(in=tmp); by DonorUnitId;
	age=DateTransfusion-DateDonated;
	if tmp;
run;

proc sort; by id ; run;

data rbc_donor;
    merge rbc_donor rbc_id(keep=id erbc); by id;  
run;

proc means data=rbc_donor n median;
    class erbc;
    var age;
    output out=tmp median(age)=median_age;
run;

data _null_;
    set tmp;
    if erbc=1 then call symput("median1", compress(median_age));
        if erbc=0 then call symput("median0", compress(median_age));
run;


data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

data nec neca necb;
	merge nec0 cmv.comp_pat(in=comp keep=id dob) cmv.endofstudy(keep=id StudyLeftDate) rbc_id(keep=id erbc in=temp); by id;
	if temp;
	if necdate=. then nec=0; else nec=1;
	retain ndate;
	if first.id then ndate=necdate;

	day=StudyLeftDate-dob;
	if nec then day=nDate-dob;
	if day>1000 then day=.;
	
    if erbc=1 then output neca;
        if erbc=0 then output necb;
	format ndate mmddyy8.;
	output nec;
run;

proc sort data=nec nodupkey; by id day;run;
proc sort data=neca nodupkey; by id day;run;
proc sort data=necb nodupkey; by id day;run;

*ods trace on/label listing;
proc lifetest nocensplot data=nec timelist=0 7 14 21 28 35 42 49 56 63 70 outsurv=pl1;
    strata erbc;
	time day*nec(0);
	ods output Lifetest.StrataHomogeneity.HomTests=homp;
run;
*ods trace off;
proc print data=homp;run;

data _null_;
    length pv $6;
    set homp;
    if _n_=1;
    if probchisq<0.0001 then pv="<0.001"; else pv=compress(put(probchisq, 7.4));
    call symput ("homp", pv);
run;


proc lifetest nocensplot data=neca timelist=0 7 14 21 28 35 42 49 56 63 70 77 84 91 98 outsurv=pl1;
ods output productlimitestimates=plta;
	time day*nec(0);
run;

data _null_;
	set plta;
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

proc lifetest nocensplot data=necb timelist=0 7 14 21 28 35 42 49 56 63 70 77 84 91 98 outsurv=pl1;
ods output productlimitestimates=pltb;
	time day*nec(0);
run;

data _null_;
	set pltb;
	if Timelist=0  then call symput( "m0",   compress(put(left, 3.0))); 
	if Timelist=7  then call symput( "m7",   compress(put(left, 3.0))); 
	if Timelist=14 then call symput( "m14",  compress(put(left, 3.0))); 
	if Timelist=21 then call symput( "m21",  compress(put(left, 3.0))); 
	if Timelist=28 then call symput( "m28",  compress(put(left, 3.0))); 
	if Timelist=35 then call symput( "m35",  compress(put(left, 3.0))); 
	if Timelist=42 then call symput( "m42",  compress(put(left, 3.0))); 
	if Timelist=49 then call symput( "m49",  compress(put(left, 3.0))); 
	if Timelist=56 then call symput( "m56",  compress(put(left, 3.0))); 
	if Timelist=63 then call symput( "m63",  compress(put(left, 3.0))); 
	if Timelist=70 then call symput( "m70",  compress(put(left, 3.0))); 
	if Timelist=77 then call symput( "m77",  compress(put(left, 3.0))); 
	if Timelist=84 then call symput( "m84",  compress(put(left, 3.0))); 
	if Timelist=91 then call symput( "m91",  compress(put(left, 3.0))); 
	if Timelist=98 then call symput( "m98",  compress(put(left, 3.0))); 
run;

proc format;
		value dd  2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35="35*(&n35)*(&m35)" 36=" " 37=" " 
		38=" " 39=" " 41=" "	42="42*(&n42)*(&m42) " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 50=" " 51=" " 52=" " 53=" " 
		54=" " 55=" " 0="0*(&n0)*(&m0)" 1=" " 7="7*(&n7)*(&m7)" 14="14*(&n14)*(&m14)" 21="21*(&n21)*(&m21)" 28="28*(&n28)*(&m28)" 
		49="49*(&n49)*(&m49)" 56="56*(&n56)*(&m56)"	40=" " 63="63*(&n63)*(&m63)" 70="70*(&n70)*(&m70)" 77="77*(&n77)*(&m77)" 
		84="84*(&n84)*(&m84)" 91="91*(&n91)*(&m91)" 98="98*(&n98)*(&m98)";
run;

%macro km(data,out);

data &out; if 1=1 then delete;run;

proc lifetest /*nocensplot*/ plots=(s) data=&data confband=all outsurv=pl1;
ods output productlimitestimates=pl;
	time day*nec(0);
run;

data pl1;
    set pl1;
    if SDF_LCL=. then delete;
run;

ods output close;
/*proc contents data=pl;run;*/

data pl; 
    merge pl pl1(keep=day SDF_LCL SDF_UCL); by day; 
run;

proc sort data=pl; by Failed;run;

data pl;
	set pl; by failed;
	retain prob1 upper1 lower1;
	if first.failed then do;
	   prob1=failure;
	   upper1=1-SDF_UCL;
	   lower1=1-SDF_LCL;
	end;
	if prob1=. then delete;
run;


data pl;
	set pl; by failed;
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

data pl;
	set pl; by failed;
	if not first.failed then prob2=.;
	if prob2=. then do; prob3=.; upper3=.; lower3=.; end;
run;

data &out;	
	set pl(keep=day prob1 upper1 lower1 rename=(prob1=prob upper1=upper lower1=lower)) 
    	pl(keep=day prob3 upper3 lower3 rename=(prob3=prob upper3=upper lower3=lower)) 
	    pl(keep=day prob2 upper2 lower2 rename=(prob2=prob upper2=upper lower2=lower)); by day; 
	if prob=. then delete;
run;

proc sort; by day prob; run;

%mend km;

%km(neca, pla);
%km(necb, plb);

data pl;
    merge pla(rename=(prob=prob1 upper=upper1 lower=lower1)) 
          plb(rename=(prob=prob0 upper=upper0 lower=lower0)); 
    by day;
run;

proc print;run;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct colors=(orange green red) 
ftitle=zapf ftext=zapf hby = 3;

symbol2 i=j mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=3;
symbol1 i=j mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=1;
symbol3 i=j mode=exclude value=none co=red cv=red height=0.6 bwidth=4 width=1.5 l=3;

symbol5 i=j mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=3;
symbol4 i=j mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=1;
symbol6 i=j mode=exclude value=none co=blue cv=blue height=0.6 bwidth=4 width=1.5 l=3;

legend1 frame cborder=black value=("RBC<=7 days" " " " " "RBC>7 days" " " " ") position=(top left inside);


title1 h=3 justify=center Cumulative Incidence of NEC and 95% Confidence Intervals;
title2 h=2.5 justify=center For RBC Transfusion Only;
         
axis1 	label=(h=2.5 'Age of Low Birth Weight Infants' ) split="*" value=(h=1.75) order= (0 to 84 by 7) minor=none;
axis2 	label=(h=2.5 a=90 "Probability of NEC") order=(0 to 0.30 by 0.05) value=(h=2) ;
     
             
proc gplot data=pl gout=wbh.graphs;
	*plot  prob*day upper*day lower*day/overlay haxis = axis1 vaxis = axis2  nolegend;
		plot  prob1*day upper1*day lower1*day prob0*day upper0*day lower0*day/overlay haxis = axis1 vaxis = axis2  nolegend;

	note m=(12,-8) h=2 "red->RBC<=7 days (Median=&median1 days); blue->RBC>7 days (Median=&median0 days)";
	note m=(12,-10) h=2 "p value=&homp";
    
	note h=1.75 m=(2pct, 12.75 pct) "Day:" ;
	note h=1.75 m=(-1.5pct, 10.25 pct) "(#RBC<=7 days)" ;
	note h=1.75 m=(-1.5pct, 8.25 pct) "(#RBC>7 days)" ;
	format day dd. failure 4.2;
run;	

goptions reset=all  /*device=jpeg*/ gunit=pct noborder colors=(orange green red) ftext=Times hby = 3;
*ods pdf file = "/ttcmv/sas/output/april2011abstracts/nec_km_curve.pdf";
ods pdf file = "nec_surv_rbc.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;
