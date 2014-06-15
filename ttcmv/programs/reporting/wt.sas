libname wbh "/ttcmv/sas/data";	

proc format;
		value tx 
		0="No"
		1="Yes"
		;
run;

data hwl;
	set cmv.plate_015;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate;
	rename DFSEQ=day;
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
		;
run;

proc sort nodupkey; by id dt; run;

data hwl hwl_tx hwl_no_tx;
	merge hwl(in=hwl) tx(in=trans keep=id dt); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	daytx0=WeightDate-dt;

	if 50<=daytx0 then daytx=60;
	else if 35<=daytx0<50 then daytx=40;
	else if 32<=daytx0<35 then daytx=28;
	else if 6<=daytx0<32 then daytx=round(daytx0/7)*7;
	else if daytx0>1 then daytx=4;
	else if  -1<=daytx0<=1 then daytx=0;
	else if -6<daytx0<-1 then daytx=-4;
	else if -9<daytx0<=-6 then daytx=-7;
	else if -18<daytx0<=-9 then daytx=-14;
	else if -25<daytx0<=-18 then daytx=-21;
	else if -35<daytx0<=-25 then daytx=-28;
	else if  -50<daytx0<=-35 then daytx=-40;
	else if  daytx0<=-50 then daytx=-60;

	daytx1= daytx - .3 + .6*uniform(613);	

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

data  hwl_before_tx;
	set hwl_tx;
	if daytx<=0;
run;


data  hwl_after_tx;
	set hwl_tx(drop=day);
	if daytx>=0;
	rename daytx=day;
run;

data hwl_A;
	set hwl_no_tx hwl_before_tx(in=before);
	if before then tx=1; else tx=0;
run;
proc sort nodupkey; by day id;run;

data hwl_B;
	set hwl_after_tx hwl_before_tx(in=before);
	if before then tx=1; else tx=0;
run;
proc sort nodupkey; by day id;run;

data hwl_C;
	set hwl_no_tx hwl_before_tx(in=before) hwl_after_tx(in=after);
	if before then tx=1; 
	else if after then tx=2; else tx=0;
run;
proc sort nodupkey; by day id;run;

proc mixed method=ml data=hwl_C covtest;
	class id tx;
	model weight=tx day tx*day/s;
	random int day/type=un subject=id;

	estimate "No-Tx, slope" day 1 tx*day 0 0 1;
	estimate "Before, slope" day 1 tx*day 0 1 0;
	estimate "After, slope" day 1 tx*day 1 0 0;
	estimate "Compare slopes" tx*day 1 -1 0;
	estimate "Compare slopes" tx*day 1 0 -1;
	estimate "Compare slopes" tx*day 0 1 -1;

/*
	estimate "No-tx, intercept" int 1 tx 0 1/cl;
	estimate "No-tx, Day1"   int 1 tx 0 1 day 1   day*tx 0 1   ;
	estimate "No-tx, Day4"   int 1 tx 0 1 day 4   day*tx 0 4   ;
	estimate "No-tx, Day7"   int 1 tx 0 1 day 7   day*tx 0 7   ;
	estimate "No-tx, Day14"  int 1 tx 0 1 day 14  day*tx 0 14  ;
	estimate "No-tx, Day21"  int 1 tx 0 1 day 21  day*tx 0 21  ;
	estimate "No-tx, Day28"  int 1 tx 0 1 day 28  day*tx 0 28  ;
	estimate "No-tx, Day40"  int 1 tx 0 1 day 40  day*tx 0 40  ;
	estimate "No-tx, Day60"  int 1 tx 0 1 day 60  day*tx 0 60  /e;

	estimate "tx, intercept" int 1 tx 1 0/cl;
	estimate "tx, Day1"   int 1 tx 1 0 day 1   day*tx 1  0;
	estimate "tx, Day4"   int 1 tx 1 0 day 4   day*tx 4  0;
	estimate "tx, Day7"   int 1 tx 1 0 day 7   day*tx 7  0;
	estimate "tx, Day14"  int 1 tx 1 0 day 14  day*tx 14 0;
	estimate "tx, Day21"  int 1 tx 1 0 day 21  day*tx 21 0;
	estimate "tx, Day28"  int 1 tx 1 0 day 28  day*tx 28 0;
	estimate "tx, Day40"  int 1 tx 1 0 day 40  day*tx 40 0;
	estimate "tx, Day60"  int 1 tx 1 0 day 60  day*tx 60 0/e;
	ods output Mixed.Estimates=estimate_&var;
*/
run;

