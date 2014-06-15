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
		cmv.plate_031(keep=id Hb DFSEQ DateHbHct rename=(DateHbHct=hbdate));

	if hb=. then delete;
	if Hbdate=. then Hbdate=BloodCollectDate;
	if hb>25 then hb=.;

    if id=2014411 and dfseq=101 then hbdate=mdy(12,01,11);				
    if id=3043411 and dfseq=14 then hbdate=mdy(03,03,12);
	if id=3006711 and hbdate='30Dec11'd then hbdate='30Dec10'd;
	keep id HbDate Hb;
run;

proc sort nodupkey; by id hbdate hb;run;

data nec0;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id;
	keep id necdate NECResolveDate;
run;

proc sort; by id necdate;run;
data nec;
    set nec0; by id necdate;
    if first.id;
run;

data rbc_tx;
    merge nec(in=tmp) cmv.plate_031(keep=id DateTransfusion rename=(DateTransfusion=dtx));by id;
    if tmp then if dtx<=necdate;
run;
proc sort nodupkey; by id; run;

data hb_nec;
    merge nec(in=tmp) hb0 
    cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
    cmv.completedstudylist(in=comp keep=id); by id; 
    
    day=hbdate-dob+1;
    if comp;

    if tmp then nec=1; else nec=0;
    if tmp then if hbdate>necdate then delete;
    if 0<hb<=8 then anemia=1; else anemia=0;
run;

proc print data=hb_nec(where=(nec=1 and anemia=1));
var id nec hb hbdate anemia;
run;


proc means data=hb_nec noprint;
    by id;
    class nec;
    var anemia;
    output out=wbh sum(anemia)=n;
run;

proc freq data=wbh(where=(nec^=.));
    *tables n*nec/nocol norow nopercent;
    tables n*nec;
run;


data anemia0;
    set hb_nec;
    if anemia;
run;

proc sort; by id day; run;

data anemia;
    set anemia0; by id day; 
    if first.id;
    if day>28 then anemia28=1; else anemia28=0;
    rename HbDate=anemia_date;
    keep id nec anemia anemia28 hbdate;
run;

proc freq; 
    tables nec*anemia28;
run;

data anemia_rbc;
    merge rbc_tx(in=tx keep=id) anemia  cmv.endofstudy(keep=id StudyLeftDate)
    cmv.plate_005(keep=id LBWIDOB Gender rename=(lbwidob=dob))
    cmv.completedstudylist(in=comp keep=id); by id;
    
    if comp;
    if tx then rbc=1; else rbc=0;
    if anemia=. then anemia=0;
    
    day=StudyLeftDate-dob;
    if anemia then day=anemia_date-dob;
run;

proc freq;
tables rbc*anemia;
ods output crosstabfreqs=tmp;
run;

data _null_;
    set tmp;
    if anemia=.;
    if rbc=0 then call symput("n", compress(frequency));
    if rbc=1 then call symput("m", compress(frequency));
run;

proc lifetest nocensplot data=anemia_rbc timelist=0 3 7 14 21 28 35 42 49 56 63 70 77 84 outsurv=pl1;
ods output productlimitestimates=plt;
	time day*anemia(0);
    strata rbc;
run;

data _null_;
	set plt;
	if rbc=0 then do;
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
	end;
	if rbc=1 then do;
       if Timelist=0  then call symput( "m0",   compress(put(left, 3.0))); 
	   if Timelist=3  then call symput( "m3",   compress(put(left, 3.0))); 
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
	end;
run;

proc format;
		value dd  0="0*(&n0)*(&m0)" 3="3*(&n3)*(&m3)" 7="7*(&n7)*(&m7)" 14="14*(&n14)*(&m14)" 21="21*(&n21)*(&m21)" 
		28="28*(&n28)*(&m28)" 35="35*(&n35)*(&m35)"  42="42*(&n42)*(&m42)"  49="49*(&n49)*(&m49)" 56="56*(&n56)*(&m56)"	
		63="63*(&n63)*(&m63)" 	70="70*(&n70)*(&m70)" 77="77*(&n77)*(&m77)" 84="84*(&n84)*(&m84)";
run;

*ods trace on/label listing;
proc lifetest /*nocensplot*/ plots=(s) data=anemia_rbc confband=all outsurv=pl1;
*ods output productlimitestimates=pl;
	time day*anemia(0);
    strata rbc;
    ods output HomTests=tmp;
run;
*ods trace off;

data _null_;
    length pv $8;
    set tmp;
    if _n_=1;
    if probchisq<0.0001 then pv="<0.0001";
    else pv=compress(put(probchisq, 7.4));
    call symput("pv", pv);    
run;

data pl;
    set pl1 end=last;
    prob=1-SURVIVAL;
	lower=1-SDF_UCL;
	upper=1-SDF_LCL;

	if lower=. then delete;
    keep rbc day prob upper lower;  
run;

data pl_rbc0;
    set pl(where=(rbc=0) keep=rbc day prob upper lower rename=(prob=prob0 upper=upper0 lower=lower0)) end=last;
    
    retain p1 p2 p3;
	if lower0^=. then do; p1=prob0; p2=lower0; p3=upper0;  end;
    output;	
    if last then do; day=day+7;  prob0=p1; lower0=p1; upper0=p2; output; end;
run;

data pl_rbc1;
    set pl(where=(rbc=1) keep=rbc day prob lower upper rename=(prob=prob1 upper=upper1 lower=lower1 day=day1)) end=last;
    retain p1 p2 p3;
	if lower1^=. then do; p1=prob1; p2=lower1; p3=upper1;  end;
    output;
    if last then do; day1=day1+7;  prob1=p1; lower1=p1; upper1=p2; output;end;
run;


data pl;
    merge pl_rbc0 pl_rbc1;
    drop rbc;
run;


proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  gunit=pct colors=(orange green red) 
ftitle=zapf ftext=zapf hby = 3;

symbol1 i=steplj mode=exclude value=circle co=blue cv=blue height=1 bwidth=4 width=1.5 l=1;
symbol2 i=steplj mode=exclude value=dot co=red cv=red height=1 bwidth=4 width=1.5 l=1;

legend1 across = 1 position=(top left inside) mode = reserve shape = symbol(3,2) label=NONE 
    value = ( h=2 c=black "No RBC Tx" "RBC Tx") offset=(0.2in, -0.4 in) frame cframe=white cborder=black;

title1 h=3 justify=center Cumulative Incidence of Anemia by RBC Tx or Not;
title2 h=2.5 justify=center Test of Equality over Strata (RBC Tx or Not): p=&pv;
         
axis1 	label=(h=2.5 'Age of Low Birth Weight Infants' ) split="*" value=(h=2) order= (0 to 85 by 7) minor=none offset=(0.5in, 0);
axis2 	label=(h=2.5 a=90 "Probability of Anemia (Hb<=8 g/dL)") order=(0 to 0.5 by 0.05) value=(h=2) ;
     
             
proc gplot data=pl gout=wbh.graphs;
	plot  prob0*day prob1*day1/overlay haxis = axis1 vaxis = axis2  legend=legend1;

	note h=2 m=(5pct, 13.25 pct) "Day:" ;
	note h=2 m=(0pct, 10.75 pct) "No RBC (#At Risk)";
	note h=2 m=(0pct, 8.25 pct) "RBC (#At Risk)" ;
	format day dd. failure 4.2;
run;	


filename output 'anemia8_rbc_surv.eps';
goptions reset=all BORDER device=pslepsfc gsfname=output gsfmode=replace ;

ods pdf file = "anemia8_km_curve.pdf";
	proc greplay igout =wbh.graphs tc=sashelp.templt template=whole nofs;
			list igout;
			treplay 1:1; 
run;
