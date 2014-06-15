options /*orientation=landscape*/;
libname wbh "/ttcmv/sas/data";	
%let pm=%sysfunc(byte(177)); 


data hwl0;
	merge cmv.plate_015 cmv.plate_008 	cmv.plate_006(keep=id gestage) cmv.plate_012(keep=id SNAPTotalScore) 
			cmv.plate_005(keep=id LBWIDOB Gender  IsHispanic  race RaceOther); by id;
	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	wk=DFSEQ/7;
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate MultipleBirth gestage SNAPTotalScore
			LBWIDOB Gender  IsHispanic  race RaceOther hb wk;
	rename DFSEQ=day SNAPTotalScore=snap;
	format weightdate mmddyy9.;
run;

proc sql;
	create table hwl1 as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sort nodupkey; by id day;run;

data tx0;
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

	format /*tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx.*/ dt mmddyy9.;
run;

proc sort nodupkey; by id dt; run;

data tx;
	set tx0; by id dt;
	if first.id;
run;

data hwl;
	merge hwl1(in=A) tx(in=trans keep=id dt); by id;
	retain dw;
	if first.id then dw=weightdate;
	daytx=WeightDate-dt;
	if not trans then tx=0; else if dw=dt then tx=2; else tx=1;
	if A;
	format dw mmddyy.;
run;

data  hwl_before_tx;
	set hwl;
	if tx and daytx<0;
run;

data  hwl_after_tx;
	set hwl;
	if tx and daytx>=0;
run;

data hwl_C;
	set hwl(where=(tx=0)) hwl_before_tx(in=before drop=tx ) hwl_after_tx(in=after drop=tx);
	if before then tx=1; 
	if after then tx=2; 
	wk=day/7;
run;

proc sort data=hwl nodupkey out=hwl_id; by id;run;
	
proc freq data=hwl_id;
	tables tx;
	ods output onewayfreqs=tab;
run;

data _null_;
	set tab;
	if tx=0 then call symput("no", compress(frequency));
	if tx=1 then call symput("before",compress(frequency));
	if tx=2 then call symput("after",compress(frequency));
run;
%let total=%eval(&no+&before+&after);


********************************************************************;
proc means data=hwl(where=(day=1));
var gestage snap hb;
output out=mad median=/autoname;
run;

data _null_;
	set mad;
	call symput("md_ga", compress( put(gestage_median,4.0)));
	call symput("md_snap", compress( put(snap_median,4.0)));
	call symput("md_hb", compress(put(hb_median,4.1)));
run;

******************************************************************************;

proc format;
	value tx	0="No Transfusion"	1="Before 1st pRBC Transfusion" 2="After 1st pRBC Transfusion";

	value item 1="Gender"
					2="Race"
					3="Ever Tansfusion"
					4="Gestational Age"
					5="SNAP at Birth"
					6="Hemoglobin at Birth"
					;

	value ga     0="<Median(&md_ga weeks)" 1=">=Median" ;
	value gsnap  0="<Median(&md_snap)" 1=">=Median" ;
	value ghb    0="<Median(&md_hb g/dL)" 1=">=Median" ;
	
   value gender   
                 1 = "Male"
                 2 = "Female"
                 3 = "Ambiguous" ;
   value race   
                 1 = "Black"
                 2 = "American Indian or Alaskan Native"
                 3 = "White"
                 4 = "Native Hawaiian or Other Pacific Islander"
                 5 = "Asian"
                 6 = "More than one race"
                 7 = "Other" 
						;
run;

data hwl;
	set hwl;
	if gestage<&md_ga then ga=0; else ga=1;
	if snap<&md_snap then gsnap=0; else gsnap=1;
	if hb<&md_hb then ghb=0; else ghb=1;
	format ga ga. gsnap gsnap. ghb ghb. gender gender. race race. tx tx.;
run;


*ods trace on/label listing;
*ods trace off;

%macro wt(data, out, slope, varlist);

data &out;	if 1=1 then delete; run;
data &slope;	if 1=1 then delete; run;

%let i = 1;
%let var = %scan(&varlist, &i);

%do %while ( &var NE );

proc freq data=&data(where=(day=1)); 
	table &var;
	ods output Freq.Table1.OneWayFreqs=n_&var;
run;

proc sort; by F_&var;run;

/* Need to make sure to include intercept or not!*******************;
proc mixed data = wbh;
  class &var;
  model weight=wk &var*wk/noint s ;
	 random int wk/type=un subject=id;
run;
*/

%if &var=tx %then %do;
*ods trace on/label listing;
proc mixed data =hwl_c;
  class &var;
  model weight=&var wk &var*wk/s;
	 random int wk/type=un subject=id;
	ods output Mixed.SolutionF=slope_&var.0;
run;
%end;
%else %do;
proc mixed data = &data;
  class &var;
  model weight=&var wk &var*wk/s;
	 random int wk/type=un subject=id;
	ods output Mixed.SolutionF=slope_&var.0;
run;
%end;

data slope_&var;
	set slope_&var.0;
	if not find(Effect, "wk") then delete;
	if	effect="wk" then do; call symput("est",put(estimate,9.4));  call symput("err",put(StdErr,9.4)); call symput("pv",put(probt,7.4)); end;
run;

data slope_&var;
	set slope_&var;
	if	&var^=. then do; estimate=estimate+"&est"; end;
	if Probt=. then do; Probt="&pv"; StdErr="&err";end;

	if _n_^=1;

	code=&var;
	item=&i;
	keep item code estimate stderr probt;
run;

data &slope;
	length item0 $100 code0 $40 pv $6;
	set &slope slope_&var;
	item0=put(item, item.); 
	if item=1 then code0=put(code, gender.);
	if item=2 then code0=put(code, race.);
	if item=3 then code0=put(code, tx.);
	if item=4 then code0=put(code, ga.);
	if item=5 then code0=put(code, gsnap.);
	if item=6 then code0=put(code, ghb.);
	pv=put(probt, 5.3);
	if probt<0.001 then pv="<0.001";
run;

*ods trace off;

proc glm data = &data(where=(day=1));
  class id &var;
  model weight=&var;
  lsmeans &var/cl;
  ods output GLM.LSMEANS.&var..Weight.LSMeanCL=lm;
run;
proc sort; by &var;run;

data nlm;
	merge n_&var(keep=F_&var frequency rename=(frequency=n F_&var=&var)) lm; by &var; 
run;

proc npar1way data =&data(where=(day=1));
  class &var;
  var weight;
	ods output Npar1way.KruskalWallisTest=kw;
run;

data wt&i;
	length pv $6 code $40;
	merge nlm(keep=&var n LSMean LowerCL UpperCL) kw(firstobs=3 keep=nValue1);
	ci="["||put(lowerCL,4.0)||","||put(upperCL,4.0)||"]";
	pv=put(nvalue1, 5.3);
	if nvalue1<0.001 and nvalue1^=. then pv="<0.001";
	item=&i;
	code=&var;
run;

	data &out;
		length item0 $100;
		set &out wt&i; 
		item0=put(item, item.); 
		keep item item0 code n lsmean ci pv;
		format lsmean 4.0;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend wt;

%let varlist=gender race tx ga gsnap ghb;
%wt(hwl, wt, slope, &varlist);

data wt;
	set wt; by item;
	if not first.item then item0=" ";
	output;
	if last.item then do; Call missing( of _all_ ) ; output; end;
run;

data slope;
	set slope; by item;
	if not first.item then item0=" ";
	output;
	if last.item then do; Call missing( of _all_ ) ; output; end;
run;

ods rtf file="wt.rtf" style=journal bodytitle;
proc print data=wt noobs label;
title "Univariate Analysis of Birth Weight for &total LBWIs";
var item0 code; 
var n lsmean ci pv/style(data)=[cellwidth=1in just=right] style(header)=[just=right];
label item0="Variable"
		code="Category"
		n="n"
		lsmean="Mean"
		ci="95% CI"
		pv="p Value"
		;
run;

proc print data=slope noobs label;
title "Univariate Analysis of Growth Rate for &total LBWIs";
var item0 code0; 
var  estimate stderr pv/style(data)=[cellwidth=1in just=right] style(header)=[just=right];
label item0="Variable"
		code0="Category"
		estimate="Slope(g/wk)"
		stderr="Std Err"
		pv="p Value"
		;
		format estimate stderr 4.0 probt 5.3;
run;
ods rtf close;
