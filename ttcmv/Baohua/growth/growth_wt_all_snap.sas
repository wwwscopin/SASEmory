options orientation=landscape;
libname wbh "/ttcmv/sas/data";	
%let pm=%sysfunc(byte(177)); 

proc format;
		value tx 
		0="No"
		1="Yes"
		;
run;

data hwl;
	merge cmv.plate_008 cmv.plate_006(keep=id gestage)	
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(where=(DFSEQ=1)keep=id AnthroMeasureDate Hb HbDate)
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	if hb^=. then if hb<=9 then anemic=1; else anemic=0;
	center=floor(id/1000000);
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth gestage SNAPTotalScore
			LBWIDOB Gender  IsHispanic  race RaceOther Hb HbDate center anemic;
	rename DFSEQ=day SNAPTotalScore=snap;
	
run;


proc sql;
	create table hwl as 
	select a.*
	from hwl as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
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

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	
	retain dtx;
	if first.id then dtx=dt;
	daytx=WeightDate-dtx;

	format dtx mmddyy.;

	if tx then output hwl_tx;
	if not tx then output hwl_no_tx;
	output hwl;
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

data  hwl_before_tx;
	set hwl_tx;
	if daytx<0;
run;


data  hwl_after_tx;
	set hwl_tx;
	if daytx>=0;
run;

data hwl_C;
	set hwl_no_tx hwl_before_tx(in=before) hwl_after_tx(in=after);
	if before then tx=1; 
	if after then tx=2; 
	if not before and not after  then tx=0;
	wk=day/7;
run;

proc sort nodupkey output=hwl_id; by tx id day;run;

proc means data=hwl_id noprint;
    	class tx day;
    	var weight;
 		output out = num_wt n(weight) = num_obs;
run;

data num_wt;
	set num_wt;
	if tx=. or day=. then delete;
run;


%let a1= 0; %let a4= 0; %let a7= 0; %let a14= 0; %let a21= 0; %let a28=0; %let a40= 0;  %let a60=0;
%let n1= 0; %let n4= 0; %let n7= 0; %let n14= 0; %let n21= 0; %let n28=0; %let n40= 0;  %let n60=0;
%let b1= 0; %let b4= 0; %let b7= 0; %let b14= 0; %let b21= 0; %let b28=0; %let b40= 0;  %let b60=0;

data _null_;
	set num_wt;
	if tx=0 and day=1  then call symput( "n1",   compress(put(num_obs, 3.0)));
	if tx=0 and day=4  then call symput( "n4",   compress(put(num_obs, 3.0)));
	if tx=0 and day=7  then call symput( "n7",   compress(put(num_obs, 3.0)));
	if tx=0 and day=14 then call symput( "n14",  compress(put(num_obs, 3.0)));
	if tx=0 and day=21 then call symput( "n21",  compress(put(num_obs, 3.0)));
	if tx=0 and day=28 then call symput( "n28",  compress(put(num_obs, 3.0)));
	if tx=0 and day=40 then call symput( "n40",  compress(put(num_obs, 3.0)));
	if tx=0 and day=60 then call symput( "n60",  compress(put(num_obs, 3.0)));

	if tx=1 and day=1  then call symput( "b1",   compress(put(num_obs, 3.0)));
	if tx=1 and day=4  then call symput( "b4",   compress(put(num_obs, 3.0)));
	if tx=1 and day=7  then call symput( "b7",   compress(put(num_obs, 3.0)));
	if tx=1 and day=14 then call symput( "b14",  compress(put(num_obs, 3.0)));
	if tx=1 and day=21 then call symput( "b21",  compress(put(num_obs, 3.0)));
	if tx=1 and day=28 then call symput( "b28",  compress(put(num_obs, 3.0)));
	if tx=1 and day=40 then call symput( "b40",  compress(put(num_obs, 3.0)));
	if tx=1 and day=60 then call symput( "b60",  compress(put(num_obs, 3.0)));

	if tx=2 and day=1  then call symput( "a1",   compress(put(num_obs, 3.0)));
	if tx=2 and day=4  then call symput( "a4",   compress(put(num_obs, 3.0)));
	if tx=2 and day=7  then call symput( "a7",   compress(put(num_obs, 3.0)));
	if tx=2 and day=14 then call symput( "a14",  compress(put(num_obs, 3.0)));
	if tx=2 and day=21 then call symput( "a21",  compress(put(num_obs, 3.0)));
	if tx=2 and day=28 then call symput( "a28",  compress(put(num_obs, 3.0)));
	if tx=2 and day=40 then call symput( "a40",  compress(put(num_obs, 3.0)));
	if tx=2 and day=60 then call symput( "a60",  compress(put(num_obs, 3.0)));
run;

%put &n1;
%put &b1;
%put &a1;

proc format;

value dd -1=" "  
 0=" " 1="1*(&n1)*(&b1)*(&a1)"  2=" " 3=" " 4 = "4*(&n4)*(&b4)*(&a4)" 5=" " 6=" " 7="7*(&n7)*(&b7)*(&a7)" 8=" " 9=" " 10=" " 
 11=" " 12=" " 13=" " 14 = "14*(&n14)*(&b14)*(&a14)" 15=" " 16=" " 17=" " 18=" " 19=" " 20=" " 
 21="21*(&n21)*(&b21)*(&a21)"  22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 28 = "28*(&n28)*(&b28)*(&a28)"  29=" " 30=" "
 31=" " 32=" " 33=" " 34=" " 35=" "  36=" " 37=" "	38=" " 39=" " 42=" " 
 41=" " 40="40*(&n40)*(&b40)*(&a40)" 43=" "	44=" " 45=" " 46=" " 47=" "  48=" "	49=" " 50=" " 
 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" " 61=" " 62=" "  60 = "60*(&n60)*(&b60)*(&a60)" ;

run;

proc mixed method=ml data=hwl_C covtest;
	class id tx gender;
	model weight=tx gender day tx*day/s;
	random int day/type=un subject=id;
run;
