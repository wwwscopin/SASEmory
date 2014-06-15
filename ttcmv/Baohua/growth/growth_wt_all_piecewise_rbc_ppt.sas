options orientation=portrait nodate nobyline nonumber;
libname wbh "/ttcmv/sas/programs";	
%let pm=%sysfunc(byte(177)); 
%let ds=%sysfunc(byte(167)); 
%let one=%sysfunc(byte(185)); 
%let two=%sysfunc(byte(178)); 

proc means data=cmv.plate_012 median;
var SNAPTotalScore;
output out=tmp median(SNAPTotalScore)=median;
run;

data _null_;
    set tmp;
    call symput("median",compress(median));
run;


proc format; value tx 0="No"	1="Yes";
       
value item 0="--"
           1="Gender"
           2="Race(only for Black and White)"
           3="Center"
           4="Anemia(Hemoglobin<=9 g/dL) before 1st pRBC transfusion"
           5="Anemia(Hemoglobin<=8 g/dL) before 1st pRBC transfusion"
           6="Gestational Age Group"
           7="Gestational Age by Median"
           8="SNAP at Birth"
           9="Any breast milk fed before 1st pRBC transfusion"
           10="Caffeine used before 1st pRBC transfusion"
           ;
value Anemic 0="Not Anemic" 1="Anemic";
value snapg  0="SNAP Score <=Median(&median)" 1="SNAP Score >Median";

    value group 1="SGA"  2="AGA"  3="LGA";

run;

data hwl0;
	merge cmv.plate_008(keep=id MultipleBirth) 
    cmv.plate_006(keep=id gestage) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(rename=(dfseq=day))
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	center=floor(id/1000000);
	if SNAPTotalScore>&median then snapg=1;else snapg=0;
	
		if id=2002711 and dfseq=28 then weight=.;
		if id=3023511 and dfseq=21 then weight=.;
		
	if gestage>=28 then gesta=0; else gesta=1;
	
	retain bw; 
	if day=1 then bw=Weight;
	
	keep id day Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth SNAPTotalScore
			LBWIDOB Gender  IsHispanic  Race RaceOther Hb HbDate Center snapg bw gestage gesta;
	rename SNAPTotalScore=snap LBWIDOB=dob;
run;

data tmp;
    merge cmv.plate_006 cmv.comp_pat(in=A); by id;
	if gestage>=28 then gesta=0; else gesta=1;
    if A;
run;

proc freq; 
tables gesta;
run;

proc means data=tmp n mean median;
    var gestage;
    ouput out=gest median(gestage)=med;
run;

data _null_;
    set gest;
    call symput("gestage", compress(med));
run;


proc sql;
	create table hwl1 as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;
	
proc sql;
create table hwl as 
select a.* , b.* 
from hwl1 as a 
inner join cmv.olsen as b
on a.gender=b.gender and a.gestage=b.gestage;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id hb DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0;
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	/*if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */

    if A;

	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
run;

proc sort nodupkey; by id dt; run;

data tx;
    set tx; by id dt;
    if first.id;
    rename hb=hb0;
run;

data feed;
    merge cmv.bm_collection(keep=id DFSEQ BreastMilkObtained) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    retain age;
    if first.id then age=dt-dob;
    if dfseq<age or (dfseq=7 and age^=.) then feed=BreastMilkObtained;
    if feed=1;
run;
proc sort nodupkey; by id;run;


%macro conmed(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 9;
		center=floor(id/1000000);
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

		keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
run;
%mend;

%conmed(cmv.con_meds);quit;

data anemia;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=9) or 0<hb0<=9;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data anemia8;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=8) or 0<hb0<=8;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;


data cafe;
    merge tmp(where=(medcode=5) keep=id medcode enddate) 
    cmv.plate_005(keep=id LBWIDOB rename=(lbwidob=dob))
    tx; by id;
    if /*enddate-dob<=7 and*/ enddate<dt;
run;
proc sort nodupkey; by id;run;


data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt) feed(keep=id in=breast) cafe(keep=id in=cafe) anemia(in=A) anemia8(in=B); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	if breast then feed=1; else feed=0;
	if cafe then caffine=1;else caffine=0;
	if A then anemic=1; else anemic=0;
		if B then anemic8=1; else anemic8=0;
		
	if bw<weight_tenth then group=1;
	if weight_tenth<=bw<=weight_ninetieth then group=2;
	*if bw>weight_ninetieth then group=3;
	
	daytx0=WeightDate-dt;
	
	age=dt-dob;

	format dtx mmddyy.;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if -1<=daytx0<=1 then daytx=daytx0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	

	wk=day/7;
	if tx then output hwl_tx;
	if not tx then output hwl_no_tx;
	output hwl;
run;

data hwl_no_tx;
    set hwl_no_tx;
    st1=min(day,7);
    st2=max(0,day-7);
run;

data hwl_id;
	set hwl; 
	keep id tx;
run;

proc sort nodupkey; by id;run;
	
proc freq data=hwl_id;
	tables tx;
	ods output onewayfreqs=tab;
run;

data _null_;
	set tab;
	if tx=0 then call symput("no", compress(frequency));
	if tx=1 then call symput("yes",compress(frequency));
run;
%let total=%eval(&yes+&no);

%put &no;

proc sort data=hwl_no_tx nodupkey out=hwl0_id; by tx id day;run;

proc means data=hwl0_id noprint;
    	class tx day;
    	var weight;
 		output out = num_wt0 n(weight) = num_obs;
run;

data num_wt0;
	set num_wt0;
	if tx=. or day=. then delete;
run;

data  hwl_tx;
	set hwl_tx(drop=day);
	if daytx0<=0 then tx=0; else tx=1;
	rename daytx0=day;
	d1=min(daytx0,0);
	d2=max(daytx0,0);
run;

proc means data=hwl_tx(where=(anemic8=0)); 
var hb;
run;

proc means data=hwl_tx(where=(anemic=0)); 
var hb;
run;

proc means data=hwl(where=(-1<=daytx0<=1)); 
var hb;
run;

proc sort nodupkey out=hwl_id; by tx id daytx;run;

proc means data=hwl_id median;
    	var age;
 		output out =median_age median(age)=med_age;
run;

data _null_;
    set median_age;
    call symput("medage", compress(med_age));
run;

proc means data=hwl_id ;
    	class tx daytx;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or daytx=. then delete;
run;

%let a0= 0; %let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n0= 0; %let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b0= 0; %let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if daytx=0   then call symput( "a0",   compress(put(num_obs, 3.0)));
	if daytx=-1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if daytx=-4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if daytx=-7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if daytx=-14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if daytx=-21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if daytx=-28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if daytx=-40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if daytx=-60 then call symput( "a60",  compress(put(num_obs, 3.0)));

	if daytx=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if daytx=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if daytx=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if daytx=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if daytx=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if daytx=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if daytx=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if daytx=60 then call symput( "b60",  compress(put(num_obs, 3.0)));
run;


data _null_;
	set num_wt0;
	*if tx=0 and day=0  then call symput( "n0",   compress(put(num_obs, 3.0)));
	if tx=0 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));
run;

%put &n0;
%put &n1;
%put &n4;

proc format;

value dd 0=" " 1="1(&n1)"  2=" " 3=" " 4 = "4(&n4)" 5=" " 6=" " 7="7(&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14(&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21(&n21)"  22=" " 
 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28(&n28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" "  
 36=" " 37=" " 38=" " 39=" " 42=" " 41=" " 40="40(&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	
 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60(&n60)" ;

/*
value dd 0=" " 1="1*(&n1)"  2=" " 3=" " 4 = "4*(&n4)" 5=" " 6=" " 7="7*(&n7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21*(&n21)"  22=" " 
 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" "  
 36=" " 37=" " 38=" " 39=" " 42=" " 41=" " 40="40*(&n40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	
 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 60 = "60*(&n60)" ;


value dt   
			-41=" " -40="-40*(&a40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28*(&a28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21*(&a21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14*(&a14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7*(&a7)" -6=" " - 5=" "  -4="-4*(&a4)"  -3=" "   
			-2=" "  -1=" " 0= "0*(&a0)"  1=" "  2=" " 3=" " 4="4*(&b4)" 5=" " 6=" " 7="7*(&b7)" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14*(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21*(&b21)"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28*(&b28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40*(&b40)" ;
*/

value dt   
			-41=" " -40="-40(&a40)" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28(&a28)" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21(&a21)" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14(&a14)" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7(&a7)" -6=" " - 5=" "  -4="-4(&a4)"  -3=" "   
			-2=" "  -1=" " 0= "0(&a0)"  1=" "  2=" " 3=" " 4="4(&b4)" 5=" " 6=" " 7="7(&b7)" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14(&b14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21(&b21)"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28(&b28)"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40(&b40)" ;
			

value dd   
			-41=" " -40="-40" -39=" " -38=" "  -37=" " -36=" " -35=" "  -34=" " 
     		-33=" " -32=" " -31=" " -30=" " -29=" " -28="-28" -27=" " -26=" " -25=" " -24=" " -23=" " 
			-22=" " -21="-21" -20=" " -19=" " -18=" " -17=" " -16=" " -15=" " -14="-14" -13=" " 
			-12=" " -11=" " -10=" "   -9=" "    -8=" "   -7="-7" -6=" " - 5=" "  -4="-4"  -3=" "   
			-2=" "  -1=" " 0= "0"  1=" "  2=" " 3=" " 4="4" 5=" " 6=" " 7="7" 8=" " 9=" " 
			10=" " 11=" " 12=" " 13=" " 14="14" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 21="21"  
			22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28="28"  29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 
			35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 41=" " 40="40" ;

value idx 0="Without pRBC Transfusion (n=&no)" 1="With pRBC Transfusion (n=&yes)";

value tx 0="No"	1="Yes"	;

run;

proc mixed /*method=ml*/ data=hwl_no_tx covtest;
	class id;
	model weight=st1 st2 /s;
	random int st1 st2/type=un subject=id;

	estimate "intercept" int 1/cl;
	estimate "Day1"   int 1 st1 1 ;
	estimate "Day4"   int 1 st1 4;
	estimate "Day7"   int 1 st1 7;
	estimate "Day14"  int 1 st2 7;
	estimate "Day21"  int 1 st2 14;
	estimate "Day28"  int 1 st2 21;
	estimate "Day40"  int 1 st2 33;
	estimate "Day60"  int 1 st2 53/e;

	ods output Mixed.Estimates=estimate0;
run;

data line_wt0;
	set estimate0;

	if find(label,"intercept") then day=0; 
	else day= compress(label,"Day")+0;

	keep day estimate upper lower;
	if day>0;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
run;
 

*ods trace on/label listing;
proc mixed /*method=ml*/ data=hwl_no_tx covtest;
	class id;
	model weight=st1 st2/s;
	random int st1 st2/type=un subject=id;

	estimate "Month1"  int 1 st2 30.5;  
	estimate "Month2"  int 1 st2 61.0;  

	ods output  Mixed.SolutionF=slope0;
	ods output Mixed.Estimates=estimate_notx;
run;
*ods trace off;

data info_notx;
	length effect $60;
	set slope0(in=A) estimate_notx;

	ms=put(estimate,4.0)||" &pm "||compress(put(stderr,4.0));

	if effect="Intercept"  then effect="Intercept (g, Weight at Birth)";
	if effect="st1" then delete;
	if effect="st2" then do;
	   effect="Slope for LBWIs without pRBC transfusion (g/day)";
	   ms=put(estimate,4.1)||" &pm "||compress(put(stderr,4.1));
	end;

	if find(label, "Month1") then effect="Mean Weight at 1 Month (g)";
	if find(label, "Month2") then effect="Mean Weight at 2 Month (g)";
	if ms=" " then delete;
run;

data _null_;
	set slope0;
	tmp=put(estimate, 5.1)||"("||put(stderr,3.1)||")";
	if _n_=3 then call symput("s0", compress(tmp));
run;


proc mixed /*method=ml*/ data=hwl_tx covtest;
	class id;
	model weight=d1 d2/s;
	random int d1 d2/type=un subject=id;

	estimate "Before, Day-60"  int 1 d1 -60/cl;	
	estimate "Before, Day-40"  int 1 d1 -40;  
	estimate "Before, Day-28"  int 1 d1 -28;  
	estimate "Before, Day-21"  int 1 d1 -21; 
	estimate "Before, Day-14"  int 1 d1 -14;
	estimate "Before, Day-7"   int 1 d1 -7 ; 
	estimate "Before, Day-4"   int 1 d1 -4 ;   	 
	estimate "Before, Day-1"   int 1 d1 -1 ;  
 	estimate "Before, Day0"    int 1 d1 0;
	estimate "After, Day1"   int 1 d2 1 ;  
	estimate "After, Day4"   int 1 d2 4 ;  
	estimate "After, Day7"   int 1 d2 7 ; 
	estimate "After, Day14"  int 1 d2 14;  
	estimate "After, Day21"  int 1 d2 21;  
	estimate "After, Day28"  int 1 d2 28;  
	estimate "After, Day40"  int 1 d2 40;  
	estimate "After, Day60"  int 1 d2 60;

	ods output Mixed.Estimates=estimate1;
run;

data line_wt1;
	set estimate1;
	day= compress(scan(label,2,","),"Day")+0;
	keep day estimate upper lower;
	if lower<0 then lower=0;
	/*if estimate<0 then do; estimate=.; upper=. ; lower=.; end;*/
	if estimate<0 then delete;
	if day not in(-60,60);
run;

proc mixed /*method=ml*/ data=hwl_tx covtest;
	class id;
	model weight=d1 d2/s;
	random int d1 d2/type=un subject=id;

	estimate "Before pRBC transfusion, Month1"  int 1 d1 -30.5;  
	estimate "After pRBC transfusion, Month1"  int 1 d2 30.5;  
	estimate "After pRBC transfusion, Month2"  int 1 d2 61;  

	ods output  Mixed.SolutionF=slope1;
	ods output Mixed.Estimates=estimate_tx;
run;

data info_tx;
	length effect $60;

	set slope1(in=A) estimate_tx;
	ms=put(estimate,4.0)||" &pm "||compress(put(stderr,4.0));
	if effect="Intercept"  then effect="Intercept (g, Weight at 1st pRBC transfusion)";
	if effect="d1" then do; 
	   effect="Slope Before 1st pRBC transfusion (g/day)";
	   ms=put(estimate,4.1)||" &pm "||compress(put(stderr,4.1));
	end;
	if effect="d2" then do;
	   effect="Slope After 1st pRBC transfusion (g/day)";
	   ms=put(estimate,4.1)||" &pm "||compress(put(stderr,4.1));
	 end;
	if find(label, "Before") then effect="Mean Weight at 1 Month Before 1st pRBC transfusion (g)";
	if find(label, "After") and find(label, "Month1") then effect="Mean Weight at 1 Month After 1st pRBC transfusion (g)";
	if find(label, "After") and find(label, "Month2") then effect="Mean Weight at 2 Month After 1st pRBC transfusion (g)";

	if ms=" " then delete;
run;

data info;
	set info_notx(in=A) info_tx(in=B);
	if A then idx=0; 
	if B then idx=1;
	format idx idx.;
run;

proc sort; by idx; run;

data info;
	set info; by idx; 
	idx0=put(idx, idx.);
	if not first.idx then idx0=" ";
run;

data _null_;
	set slope1;
	tmp=put(estimate, 5.1)||"("||put(stderr,4.1)||")";
	if _n_=2 then call symput("sb", compress(tmp));
	if _n_=3 then call symput("sa", compress(tmp));
run;


DATA anno0; 
	set line_wt0;
	xsys='2'; ysys='2';  color='blue';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
    X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno0A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt0;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

data anno0;
	length color $6 function $8;
	set anno0 anno0A;
run;

DATA anno1; 
	set line_wt1;
	xsys='2'; ysys='2';  color='red';
	X=day; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=2;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
   X=day-.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
	X=day+.1; FUNCTION='DRAW'; when = 'A'; line=1; size=2; OUTPUT;
  	X=day;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno1A;
	length function $8;
	retain xsys '2' ysys '3' color 'white' when 'a';
	set line_wt1;
	function='move'; x=day; y=15; output;
	function='draw'; x=day; y=13.5; output;
	function='label'; x=day; y=11; size=1.0; output;
	text=left(put(day,dd.));
	output;
run;

data anno1;
	length color $6 function $8;
	set anno1 anno1A;
run;


goptions reset=all  device=jpeg  gunit=pct noborder cback=blue colors = (black red green blue) ftitle="Times/bold" ftext="Times/bold"  hby = 3;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;
goptions reset=all  /*device=jpeg*/ gunit=pct noborder CBACK=blue CPATTERN=blue ctext=white ctitle=white  colors=(orange green red) 
ftitle="Times/Bold" ftext="Times/Bold" hby = 3;

proc greplay igout=wbh.graphs  nofs; delete _ALL_; run;

symbol1 interpol=spline mode=exclude value=circle co=blue cv=blue height=3 bwidth=1 width=1;

axis1 	label=(h=2.5  'Age of LBWIs (days)' ) split="*" value=(h=1.0 c=white)  
order= (0 to 61 by 1) minor=none offset=(0 in, 0 in) major=(c=white) origin=(,15)pct;

legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 "Without pRBC transfusion, Slope(SE)=&s0 g/day" )  offset=(0.2in, -0.4 in) frame ;


axis2 	label=( h=2.5 a=90 f=swissb "Weight(g)") value=(h=2) order= (400 to 2400 by 100) c=white offset=(.25 in, .25 in) minor=(number=1);
 
title 	height=3 "Weight vs Days for All LBWIs without pRBC transfusion (n=&no)";
proc gplot data=line_wt0 gout=wbh.graphs;
	plot estimate*day/overlay annotate= anno0 haxis = axis1 vaxis = axis2 legend=legend;
	note h=1.5 m=(5pct, 10 pct) "Day(n):" ;
	format estimate 4.0;
run;


symbol1 interpol=spline mode=exclude value=circle co=red cv=red height=2 bwidth=3 width=2;

axis1 	label=(h=2.5 'Days Before and After 1st pRBC transfusion' ) split="*"	
value=(h=1.0 c=blue) order= (-41 to 41 by 1) minor=none major=(c=blue) offset=(0in, 0in) origin=(,15)pct;


legend across = 1 position=(top left inside) mode = reserve fwidth =.2	shape = symbol(3,2) label=NONE 
value = (h=2 c=black "Pre-1st pRBC transfusion, Slope(SE)=&sb g/day; Post-1st pRBC transfusion, Slope(SE)=&sa g/day" )  offset=(0in, -0.4 in) frame cframe=white /*cborder=black*/;

title 	height=3 "Weight vs Days for All LBWIs with pRBC transfusion (n=&yes)";
proc gplot data=line_wt1 gout=wbh.graphs;
	plot estimate*day/overlay annotate= anno1 haxis = axis1 vaxis = axis2 legend=legend href=0 lhref=20 whref=2 /*cframe=blue*/;
	*note h=1.5 m=(4pct, 10.5 pct) "Day(n):" ;
	format estimate 4.0;
run;

options orientation=landscape;

goptions reset=all  /*device=jpeg*/ gunit=pct noborder CBACK=blue CPATTERN=blue ctext=white ctitle=white  colors=(orange green red) 
ftitle="Times/Bold" ftext="Times/Bold" hby = 3;

ods pdf file = "growth_all_joint_rbc.pdf";
proc greplay igout = wbh.graphs  tc=sashelp.templt template= whole nofs; * L2R2s;
	treplay 1:2;
run;

/*
ods pdf style=journal;
proc print data=info  noobs label;
title "All LBWIs Growth Rate (n=&total)";

var idx0;
var effect/style(data)=[just=left cellwidth=3.5in] style(header)=[just=left];
var ms probt/style(data)=[just=center cellwidth=1.0in] style(header)=[just=center];
label
		idx0="." 
		effect="Effect"
		ms="Estimate &pm SE"
		probt="p value"
		;
run;
*/
ods pdf close;

options orientation=portrait;

%macro test(data,out, varlist);

data &out;
    if 1=1 then delete;
run;

proc mixed data=&data covtest;
	class id ;
	model weight=d1 d2/s;
	random int d1 d2/type=un subject=id;
	estimate "int" int 1 ;
	estimate "pre" d1 1 ;
	estimate "post" d2 1;
	ods output Mixed.Estimates=slope0;
run;

data &out;
    length effect $60;
    set slope0;
    item=0;
    if label='int'  then effect="Intercept&one"; 
    if label='pre'  then effect="Pre-pRBC Transfusion Slope (g/day)";
    if label='post' then effect="Post-pRBC Transfusion Slope (g/day)";
run;


%let i=1;
%let var=%scan(&varlist, &i);

%do %while(&var NE );

data tmp;
    set &data;
    %if &var=race %then %do; where race in(1,3); %end;
run;

proc sort data=&data out=wbh nodupkey; by id &var;

proc means data=wbh;
class &var; var id; ods output means.summary=ttt;
run;

data _null_;
    set ttt;
    %if &var=gender %then %do; if &var=1 then call symput("nmale", compress(nobs)); if &var=2 then call symput("nfemale", compress(nobs));%end;
    %if &var=race   %then %do; if &var=1 then call symput("nb", compress(nobs)); if &var=3 then call symput("nw", compress(nobs));%end;
    %if &var=center %then %do; if &var=1 then call symput("nm", compress(nobs)); if &var=2 then call symput("ng", compress(nobs)); if &var=3 then call symput("nn", compress(nobs));%end;
    %if &var=anemic or &var=anemic8 %then %do; if &var=0 then call symput("na0", compress(nobs)); if &var=1 then call symput("na1", compress(nobs));%end;
    %if &var=group %then %do; if &var=1 then call symput("ng1", compress(nobs)); if &var=2 then call symput("ng2", compress(nobs)); %end;
    %if &var=snapg or &var=gesta  %then %do; if &var=0 then call symput("ns0", compress(nobs)); if &var=1 then call symput("ns1", compress(nobs));%end;
    %if &var=feed   %then %do; if &var=0 then call symput("nf0", compress(nobs)); if &var=1 then call symput("nf1", compress(nobs));%end;
    %if &var=caffine %then %do; if &var=0 then call symput("nc0", compress(nobs)); if &var=1 then call symput("nc1", compress(nobs));%end;
run;

*ods trace on/label listing;
proc mixed /*method=ml*/ data=tmp covtest;
	class id &var ;
	model weight=d1 d2 &var &var*d2/s;
	random int d1 d2/type=un subject=id;

    %if &var^=center %then %do; 
	estimate "int1" int 1 &var 1 0;
	estimate "int2" int 1 &var 0 1;
	estimate "pre" d1 1 ;
	estimate "post1" d2 1 &var*d2 1 0;
	estimate "post2" d2 1 &var*d2 0 1;
	%end;
	
	
	%else %do;
	estimate "int1" int 1 &var 1 0 0;
	estimate "int2" int 1 &var 0 1 0;
	estimate "int3" int 1 &var 0 0 1;
	estimate "pre" d1 1 ;
	estimate "post1" d2 1 &var*d2 1 0 0;
	estimate "post2" d2 1 &var*d2 0 1 0;	
	estimate "post3" d2 1 &var*d2 0 0 1;	
	%end;

	ods output Mixed.Estimates=slope;
	ods output Mixed.Tests3=interaction;
run;
*ods trace off;

data _null_;
    set interaction;
    if _n_=3 then call symput("pv0",compress(put(probf,7.5)));
    if _n_=4 then call symput("pv",compress(put(probf,7.5)));
run;

%put &pv;

data est;
    length effect $100;
    set slope;
    
    item=&i;  
    
    if label='pre' then effect="Pre-pRBC Transfusion Slope";
    if label='pre' then delete;
    
    %if &var=gender %then %do; 
    if label='int1'  then do; effect="Intercept --Male (n=&nmale)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Female (n=&nfemale)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --Male"; probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Female";probt=. ;end;
    %end;

    %if &var=race %then %do; 
    if label='int1'  then do; effect="Intercept --Black (n=&nb)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --White (n=&nw)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --Black"; probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --White";probt=. ;end;
    %end;
    
    %if &var=center %then %do; 
    if label='int1'  then do; effect="Intercept --Midtown (n=&nm)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Grady (n=&ng)"; probt=.; end;
    if label='int3'  then do; effect="Intercept --Northside (n=&nn)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --Midtown"; probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Grady"; probt=. ;end;
    if label='post3' then do; effect="Post-pRBC Transfusion Slope --Northside";probt=. ;end;
    %end;

    %if &var=group %then %do; 
    if label='int1'  then do; effect="Intercept --SGA (n=&ng1)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --AGA (n=&ng2)"; probt=.; end;

    if label='post1' then do; effect="Post-pRBC Transfusion Slope --SGA"; probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --AGA"; probt=. ;end;
    %end;    
            

    %if &var=anemic or &var=anemic8 %then %do; 
    if label='int1'  then do; effect="Intercept --Not Anemic (n=&na0)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Anemic (n=&na1)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --Not Anemic&two";probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Anemic";probt=. ;end;
    %end;
    

    %if &var=snapg %then %do; 
    if label='int1'  then do; effect="Intercept --SNAP score <=Median(&median) (n=&ns0)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --SNAP score >Median(&median) (n=&ns1)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope  --SNAP score<=Median(&median)";probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope  --SNAP score>Median(&median)"; probt=. ;end;
    %end;
    
    %if &var=feed %then %do; 
    if label='int1'  then do; effect="Intercept --No (n=&nf0)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Yes (n=&nf1)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --No";probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Yes"; probt=. ;end;
    %end;
    
    %if &var=caffine %then %do; 
    if label='int1'  then do; effect="Intercept --No (n=&nc0)"; probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Yes (n=&nc1)"; probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --No";probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Yes"; probt=. ;end;
    %end;


    %if &var=gesta %then %do; 
    if label='int1'  then do; effect="Intercept --Gestational Age >=Median(&gestage weeks) (n=&ns0)";  probt=&pv0; end;
    if label='int2'  then do; effect="Intercept --Gestational Age < Median(&gestage weeks) (n=&ns1)";  probt=.; end;
    if label='post1' then do; effect="Post-pRBC Transfusion Slope --Gestational Age >=Median(&gestage weeks)";probt=&pv;end;
    if label='post2' then do; effect="Post-pRBC Transfusion Slope --Gestational Age < Median(&gestage weeks)"; probt=. ;end;
    %end;    
 run;


data &out;

    length effect $100;
    set &out est;
    
    estd=compress(put(estimate,7.1)||"&pm"||put(stderr,5.1));
    if label='int1' or label='int2' or label='int3' or label='int' then do;
        estd=compress(put(estimate,7.0)||"&pm"||put(stderr,5.0));
    end;

    if stderr=. then delete;
         
    keep effect label code Estimate StdErr estd Probt item;
run;


%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;
%mend;

%let varlist=gender race  center anemic anemic8 group gesta snapg feed caffine;
*ods trace on/label listing;
%test(hwl_tx, tab, &varlist);
*ods trace off;


data tab;
    length pv $6;
    set tab; by item; 

    if first.item then  item0=put(item, item.); else item0=" ";
    if probt^=. then do; if probt<0.001 then pv="<0.001"; else pv=put(probt,7.4); end;
    else pv=" ";
    
    format item item.;
run;

data tab;
    set tab; by item; output;
    retain tmp;
    if last.item then do; Call missing( of _all_ ); output; end;
run;

ods rtf file="Interaction_rbc.rtf" style=journal bodytitle;
proc print data=tab noobs label;
title "Univariable Analysis of Growth Before and After 1st pRBC Transfusion* (n=&yes)";
id item0/style(data)=[just=left width=2in] style(header)=[just=left];
var effect/style(data)=[just=left width=2.5in] style(header)=[just=left];
var estd pv/style(data)=[just=center width=1.25in] style(header)=[just=center];
label 
    item0="Item"
    effect="Effect"
    Par="Parameter"
    estd="Estimate &pm SE"
    pv="p value";
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=10pt}
* Median age at 1^{super st} pRBC transfusion: &medage days.
^n 1. Weight at time of 1^{super st} pRBC transfusion.
^n 2. Growth velocity after 1^{super st} pRBC transfusion is greater if anemic before 1^{super st} pRBC transfusion compared to LBWIs who are not anemic before 1^{super st} pRBC transfusion.";

ods rtf close;
