libname wbh "/ttcmv/sas/programs/reporting";

proc format; 
	value tx 1="RBC" 3="Plt" 5="FFP" 7="Cryo";

data tx_id0;
	set cmv.plate_031(keep=id DateTransfusion rbc_TxStartTime rename=(rbc_TxStartTime=txtime) in=tx31)
			cmv.plate_033(keep=id DateTransfusion plt_TxStartTime rename=(plt_TxStartTime=txtime) in=tx33)
			cmv.plate_035(keep=id DateTransfusion ffp_TxStartTime rename=(ffp_TxStartTime=txtime) in=tx35)
			cmv.plate_037(keep=id DateTransfusion cryo_TxStartTime rename=(cryo_TxStartTime=txtime) in=tx37)
			/*cmv.plate_039(keep=id )*/
		;

	if tx31 then tx=1;
	if tx33 then tx=3;
	if tx35 then tx=5;
	if tx37 then tx=7;
	format tx tx.;
run;

proc sql;
	create table tx_id as 
	select a.*
	from tx_id0 as a, cmv.comp_pat as b
	where a.id=b.id;
	
proc sort data=tx_id nodupkey out=tx_num; by id;run;
proc sort data=tx_id(where=(tx=1)) nodupkey out=tx_RBC; by id;run;

data _null_;
	set tx_num;
	call symput("n", compress(_n_));
run;

data _null_;
	set tx_RBC;
	call symput("nRBC", compress(_n_));
run;

%put &n;
%put &nRBC;

proc sort data=tx_id nodupkey; by tx id DateTransfusion txtime;run;

/*
data tx_id;
	set tx_id; by id tx DateTransfusion txtime;
	if not first.txtime then mark=1; else mark=0;
run;

proc print;
where mark=1;
run;
*/


proc freq /*noprint*/;
	tables id*tx/out=tx_freq;
	tables tx/out=tx_type;
	tables id/out=tx_any;
run;

proc contents data=tx_type;run;

data _null_;
	set tx_type;
	if tx=1 then call symput("mRBC", compress(COUNT ));
	if tx=3 then call symput("mPlt", compress(COUNT ));
	if tx=5 then call symput("mFFP", compress(COUNT ));
	if tx=7 then call symput("mCyro", compress(COUNT ));
run;

%put &mRBC;
%put &mPlt;

%let m=%eval(&mRBC+&mPlt+&mFFP+&mCyro);
proc greplay igout= wbh.graphs  nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=global gunit=pct noborder /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

 	
		%let description1 = f=zapf "Bar Chart for Any Transfusions";
		%let description2 = f=zapf "Bar Chart for RBC Transfusions";
		%let mp=(1 to 30 by 1);
		
		axis1 label=(a=90 h=4 c=black "#Num of IDs") order=(0 to 12 by 1) minor=none;
		axis2 label=(a=0 h=4 c=black "Num of Transfusions") value=(/*f=zapf*/ h= 2.5) /*order=(0 to 40 by 1)*/ minor=none;
		axis3 label=(a=0 h=4 c=black "Num of RBC Transfusions") value=(/*f=zapf*/ h= 2.5) /*order=(-25 to 40 by 1)*/ minor=none;
	

		pattern1 color=orange;
		Proc gchart data=tx_any gout=wbh.graphs;
			title1 &description1;
			title2 "(&m Transfusions for &n LBWIs)";
			vbar count/ midpoints=&mp raxis=axis1 maxis=axis2 space=0.5 coutline=black width=2;
		run;
		Proc gchart data=tx_freq(where=(tx=1)) gout=wbh.graphs;
		title1 &description2;
		title2 "(&mRBC Transfusions for &nRBC LBWIs)";
			vbar count/ midpoints=&mp raxis=axis1 maxis=axis3 space=0.5 coutline=black width=2;
		run;

ods ps file = "tx.ps";
ods pdf file = "tx.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=V2S nofs; * L2R2s;
     treplay 1:1 2:2;
run;
ods pdf close;
ods ps close;
