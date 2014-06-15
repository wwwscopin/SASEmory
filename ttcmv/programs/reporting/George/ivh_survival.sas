proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value wc  0="Low"  1="Very Low(1000-1500g)" 2="Extremely Low(<1000g)" ;
	value pco 0="PCO2<50(mmHg)" 1="PCO2>50(mmHg)" ;
	value IsHispanic 0="No" 1="Yes" ;
	value gga    0="<Median(Gestational Age)" 1=">=Median(Gestational Age)" ;
	value gsnap  0="<Median(SNAPTotalScore)"  1=">=Median(SNAPTotalScore)" ;
	value ghb    0="<Median(Hemoglobin)"      1=">=Median(Hemoglobin)" ;
	value gplt   0="<Median(Pletelet Count)"  1=">=Median(Pletelet Count)" ;
	value gratio 0="<Median(PO2/FiO2)"        1=">=Median(PO2/FiO2)" ;
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

 value center
	0 = "OVERALL"
	1 = "Midtown"
	2 = "Grady"
	3 = "Northside";

 value item
	0 = "All LBWI"
	1 = "Center"
	2 = "Gender"
	3 = "Is Hispanic"
	4 = "Race"
	5 = "Birth Weight"
	6 = "PCO2 Value(mmHg)"
	7 = "Gestational Age"
	8 = "SNAPTotalScore"
	9 = "Hemoglobin"
	10= "Pletelet Count"
	11="PO2/FiO2"
;


run;

data lbwi;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	
	cmv.plate_006(keep=id GestAge  BirthWeight  Length  HeadCircum Apgar1Min Apgar5Min BirthResus  BirthResusOxygen BirthResusCompression BirthResusCPAP  BirthResusEpi  BirthResusInutbation BirthResusMask IsBloodGas  CordPh  BaseDeficit  BloodGasType)
	
	cmv.plate_010(keep=id pO2Value  PCO2  Fio2  OxyIndex) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(where=(DFSEQ=1)keep=id DFSEQ AnthroMeasureDate BloodCollectDate Platelet PltDate Hct HctDate Hb HbDate)
	cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
	cmv.ivh_image(in=xxx keep=id LeftIVHGrade RightIVHGrade)
	cmv.endofstudy(keep=id StudyLeftDate);
	by id;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if PltDate=. then PltDate=BloodCollectDate; 
	if HctDate=. then HctDate=BloodCollectDate;
	if HbDate=. then HbDate=BloodCollectDate; 
	if xxx then ivh0=1; else ivh0=0;
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;

	ratio=pO2Value/FiO2*100;
	day=StudyLeftDate-lbwidob;
	if ivh then day=IVHDiagDate-LBWIDOB;
	center=floor(id/1000000);

	if 1000<=BirthWeight<1500 then wc=1;	else if BirthWeight<1000 then wc=2; else wc=0;
	if PCO2=0 then PCO=0; else if PCO2^=999 then PCO=1;
	
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight wc BirthResus  BirthResusOxygen pO2Value PCO2 PCO Fio2 ratio 
			OxyIndex StudyLeftDate day SNAPTotalScore  Platelet Hct Hb ivh0 ivh IVHDiagDate LeftIVHGrade RightIVHGrade
			Indomethacin AntiConvulsant;		 

	format center center. gender gender. race race. ivh ivh. wc wc. IsHispanic IsHispanic. ;
run;

proc means data=lbwi;
var GestAge SNAPTotalScore hb Platelet ratio;
output out=mad median=/autoname;
run;

data _null_;
	set mad;
	call symput("md_Gestage", put(GestAge_median,5.2));
	call symput("md_SNAPTotalScore", put(SNAPTotalScore_median,5.2));
	call symput("md_hb", put(hb_median,5.2));
	call symput("md_Platelet", put(Platelet_median,5.2));
	call symput("md_ratio", put(ratio_median,5.2));
run;

data lbwi;
	set lbwi;
	if Gestage<&md_Gestage then gga=0; else gga=1;
	if SNAPTotalScore<&md_SNAPTotalScore then gsnap=0; else gsnap=1;
	if hb<&md_hb then ghb=0; else ghb=1;
	if Platelet<&md_Platelet then gplt=0; else gplt=1;
	if ratio<&md_ratio then gratio=0; else gratio=1;
	format gga gga. gsnap gsnap. ghb ghb. gplt gplt. gratio gratio. pco pco.;
run;


proc sort nodupkey; by id descending ivh;run;

data lbwi;
	merge lbwi(in=A) cmv.completedstudylist(in=B); by id;
	if first.id;
	if A and B;
run;

proc print;
where ivh0;
var id;
run;

*********************************************************************************************************************************;
%macro tab(data, out, varlist);

proc freq data=&data;
	table ivh/norow nopct;
	ods output onewayfreqs = tab0;
run;

data tab0; 
	set tab0(where=(ivh=1) rename=(frequency=n1 CumFrequency=n)); 
	item=0;
	f=n1/n*100;
	if ivh=. then delete;
	format f 4.1;
	keep item ivh n n1 f;
	rename ivh=code;
run;

%let t1=7;
%let t2=60;

proc lifetest data=lbwi timelist=&t1 &t2;
	time day*ivh(0);
	ods output Lifetest.Stratum1.ProductLimitEstimates=s0(keep=Timelist survival StdErr);
run;

data s0;	
	merge s0(where=(timelist=&t1) rename=(survival=survival&t1 StdErr=StdErr&t1)) 
			s0(where=(timelist=&t2) rename=(survival=survival&t2 StdErr=StdErr&t2)); 
	code=1; item=0;
	drop timelist;
run;	

data tab0;
	merge tab0 s0; by item code;
run;

data &out;
	if 1=1 then delete;
run;

data &out;
	set tab0;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data;
			table &var*ivh/nocol nopct;
			ods output crosstabfreqs = tab&i;
		run;

	proc sort; by &var;run;
	data tab&i;
		merge tab&i(where=(ivh=0) rename=(frequency=n0)) tab&i(where=(ivh=1) rename=(frequency=n1)); by &var;
		item=&i;
		n=n0+n1;
		f=n1/n*100;
		if &var=. then delete;
		rename &var=code;
		keep item &var n n1 f;
		format f 4.1;
	run;

proc lifetest data=lbwi timelist=&t1 &t2;
	time day*ivh(0);
	strata &var;
	survival out=s&var(keep=&var timelist survival sdf_stderr) REDUCEOUT stderr;
	ods output Lifetest.StrataHomogeneity.HomTests=p&var(keep=probchisq);
run;

data s&var;	
	if _n_=1 then set p&var(obs=1);
	merge s&var(where=(timelist=&t1) rename=(survival=survival&t1 sdf_stderr=stderr&t1)) s&var(where=(timelist=&t2) rename=(survival=survival&t2 sdf_stderr=stderr&t2)) ;
	item=&i;
	rename &var=code;
run;

proc sort; by item code;run;

	data tab&i;
		merge tab&i s&var; by item code;
	run;


	data &out;

		length code0 $100;
		set &out tab&i;

		/*if item=0 then  do; code0=put(code, ivh.); end;*/
		if item=1 then  do; code0=put(code, center.); end;
		if item=2 then  do; code0=put(code, gender.); end;
		if item=3 then  do; code0=put(code, IsHispanic.); end;
		if item=4 then  do; code0=put(code, race.); end;
		if item=5 then  do; code0=put(code, wc.); end;

		if item=6 then  do; code0=put(code, pco.); end;
		if item=7 then  do; code0=put(code, gga.); end;
		if item=8 then  do; code0=put(code, gsnap.); end;
		if item=9 then  do; code0=put(code, ghb.); end;
		if item=10 then  do; code0=put(code, gplt.); end;
		if item=11 then  do; code0=put(code, gratio.); end;

		keep item code code0 n n1 f survival&t1 StdErr&t1 survival&t2 StdErr&t2 ProbChiSq;
	run; 


	data &out;
		set &out;
		Format code;
		INFORMAT code;
 	run;

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=center gender IsHispanic race wc pco gga gsnap ghb gplt gratio;
%tab(lbwi, tab, &varlist);

%let pm=%sysfunc(byte(177));

data tab;
	set tab; by item code;
	if not first.item then probchisq=.;
	format probchisq 4.2;
	surv_err&t1=put((1-survival&t1)*100,4.1)||"&pm"||put(stderr&t1*100,4.1);
	surv_err&t2=put((1-survival&t2)*100,4.1)||"&pm"||put(stderr&t2*100,4.1);
	rename n=nt;
	format item item.;
run;

data tab1;
	set tab; by item;
	output;
	if last.item then do;
	Call missing( of code code0 nt n1 f survival&t1 StdErr&t1 survival&t2 StdErr&t2 ProbChiSq surv_err&t1 surv_err&t2) ; 
   output; end;
run;

proc print data=tab1;
by item notsorted;id item;
var code0 nt n1 f surv_err&t1 surv_err&t2 probchisq;
run;

ods rtf file="ivh.rtf" style=journal;
proc report data=tab1 nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title "Frequency and Cumulative Incidence of IVH by Baseline Demographic and Clinical Characteristics";
column item code0 nt ("*IVH Grade>=2" n1 f) ("*Cumulative IVH(%) &pm SEE" surv_err&t1 surv_err&t2) probchisq;

define item/order ORDER=INTERNAL width=50 "Characteristic" style(column)=[just=left] style(header)=[just=left];
define code0/width=50 "Value" style(column)=[just=left];
define nt/"n" width=20;
define n1/"n" width=20;
define f/"%" width=20;
define surv_err&t1/"&t1 days" width=20;
define surv_err&t1/"&t1 days" width=20;
define probchisq/"p value" style(column)=[cellwidth=0.8in just=center];

break after item / dol dul skip;
run;
ods rtf close;
