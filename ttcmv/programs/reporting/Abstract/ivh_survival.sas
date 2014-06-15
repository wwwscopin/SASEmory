data ivh0;
	merge cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade);
	by id;
	td=ImageDate-IVHDiagDate;
run;

proc sort; by id td;run;
/*
ods rtf file="IVH_day.rtf";
proc print label;
var id IVHDiagDate ImageDate td LeftIVHGrade RightIVHGrade;
label td="ImageDate-IVHDiagDate";
run;
ods rtf close;
*/

data ivh_mark;
	set ivh0; by id td;
	if td<=7;
   if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
	keep id ivh;
run;

proc sort data=ivh_mark(where=(ivh=1)) nodupkey; by id;

data lbwi;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	cmv.plate_006(keep=id GestAge  BirthWeight  Length  HeadCircum Apgar1Min Apgar5Min BirthResus  BirthResusOxygen BirthResusCompression BirthResusCPAP  BirthResusEpi  BirthResusInutbation BirthResusMask IsBloodGas  CordPh  BaseDeficit  BloodGasType)

	cmv.plate_008(keep=id ROM Steroids)	
	cmv.plate_010(keep=id PO2Value  PCO2  FiO2  OxyIndex) 
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(where=(DFSEQ=1)keep=id DFSEQ AnthroMeasureDate BloodCollectDate Platelet PltDate Hct HctDate Hb HbDate)
	cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
	cmv.ivh_image(in=xxx keep=id ImageDate LeftIVHGrade RightIVHGrade)
	ivh_mark
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=B);
	by id;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if PltDate=. then PltDate=BloodCollectDate; 
	if HctDate=. then HctDate=BloodCollectDate;
	if HbDate=. then HbDate=BloodCollectDate; 

	if xxx then ivh0=1; else ivh0=0;
	if ivh=. then ivh=0;
	if B;

	if 50<=po2value<65 then pov=1; if 30<=po2value<50 then pov=3; if po2value<30 then pov=5; if po2value>65 then pov=0;
	Ratio=pO2Value/FiO2*100;
	if ratio>250 then gr=0; if 100<=ratio<250 then gr=5; if ratio<100 then gr=16;
	rt=ratio/100;
	day=StudyLeftDate-lbwidob;
	if ivh then day=IVHDiagDate-LBWIDOB;
	center=floor(id/1000000);

	if 1000<=BirthWeight<1500 then wc=1;	else if BirthWeight<1000 then wc=2; else wc=0;
	bw=birthweight/100;
	PCO=PCO2;

	if Indomethacin=. then Indomethacin=0;
	if AntiConvulsant=. then AntiConvulsant=0;
	
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight wc BirthResus  BirthResusOxygen BirthResusCPAP PO2Value PCO2 PCO 			FiO2 ratio OxyIndex StudyLeftDate day SNAPTotalScore  Platelet Hct Hb ivh0 ivh IVHDiagDate ImageDate td LeftIVHGrade 
			RightIVHGrade 	Indomethacin AntiConvulsant ROM Steroids Indomethacin  AntiConvulsant gr bw rt pov;		 
run;


proc means data=lbwi;
var GestAge SNAPTotalScore hb Platelet ratio pO2Value FiO2;
output out=mad median=/autoname;
run;

data _null_;
	set mad;
	call symput("md_Gestage", compress(put(GestAge_median,4.1)));
	call symput("md_SNAPTotalScore", compress( put(SNAPTotalScore_median,4.0)));
	call symput("md_hb", compress(put(hb_median,4.1)));
	call symput("md_Platelet", compress(put(Platelet_median,5.0)));
	call symput("md_ratio", compress(put(ratio_median,4.1)));
	call symput("md_PO2", compress(put(PO2Value_median,4.1)));
	call symput("md_FiO2", compress(put(FiO2_median,4.1)));
run;


%let mu=%sysfunc(byte(181));

proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value wc  0="Low"  1="Very Low(1000-1500g)" 2="Extremely Low(<1000g)" ;
	value ny 0="No" 1="Yes";
	value pco 0="<50(0 pt)" 1="50-65(1 pt)" 3="66-90(3 pts)"  5=">90(5 pts)" 999="Missing";
	value pov 0=">65(0 pt)" 1="50-65(1 pt)" 3="30-50(3 pts)"  5="<30(5 pts)" 999="Missing";
	value gga    0="<Median(&md_Gestage weeks)" 1=">=Median" ;
	value gsnap  0="<Median(&md_SNAPTotalScore)" 1=">=Median" ;
	value ghb    0="<Median(&md_hb g/dL)" 1=">=Median" ;
	value gplt   0="<Median(&md_Platelet *1000/&mu L)" 1=">=Median" ;
	value tbc    1="Platelet Count<150 *1000/&mu L" 0="Platelet Count>=150 *1000/&mu L";
	value gratio 0="<Median(&md_ratio mmHg)" 1=">=Median" ;
	value gpo    0="<Median(&md_pO2 mmHg)" 1=">=Median" ;
	value gfio   0="<Median(&md_FiO2%)" 1=">=Median" ;
	value gr     0=">=250(mmHg)(0 pt)" 5="100-250(5 pts)" 16="<100(16 pts)";
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
	3 = "Race"
	4 = "Birth Weight"
	5 = "Gestational Age"
	6 = "SNAP"
	7 = "Hemoglobin at Birth"
	8 = "Platelet Count at Birth"
	9 = "Thrombocytopenia at Birth"
	10= "Birth resuscitation/stabilization with Oxygen"
	11= "Birth resuscitation/stabilization with CPAP"
	12= "Premature rupture of membranes"
	13= "Steroids given prior to delivery to accelerate maturity?"
	14= "PCO2 Value(mmHg) at Birth"
	15= "PO2(mmHg) at Birth"
	16= "PO2(mmHg) at Birth."
	17= "FiO2 (%) at Birth"
	18= "PO2/FiO2 at Birth"
	19= "PO2/FiO2 at Birth."
	20= "Was Indomethacin given within the first 24 hours of life for any prophylaxis?"
	21= "Were Seizures treated with an anti-convulstant for >72 hours?"
;
/*
  value idx
	1="Birth Weight(per 100g)"
	2="Gestational Age"
	3="SNAP"
	4="Hemoglobin at Birth"
	5="Platelet Count at Birth"
	6="PO2 Value" 
	7="FiO2"
	8="PO2/FiO2 Ratio(per 100mmHg)"
;
*/

  value idx
	1="Birth Weight(per 100g increase)"
	2="Gestational Age(per week increase)"
	3="Thrombocytopenia at Birth('<150(1000/&mu L)' vs '>=150')"
	4="Birth resuscitation/stabilization with Oxygen('Yes' vs 'No')"
	5="Birth resuscitation/stabilization with CPAP('Yes' vs 'No')"
	6="Steroids given prior to delivery to accelerate maturity?('Yes' vs 'No')" 
	8="PCO2 Value(mmHg) at Birth('50-65' vs '<50')"
	9="PCO2 Value(mmHg) at Birth('66-90' vs '<50')"
	7="PO2(mmHg) at Birth('< Median(&md_PO2)' vs '>= Median')"
;
run;

data lbwi;
	set lbwi;
	if Gestage<&md_Gestage then gga=0; else gga=1;
	if SNAPTotalScore<&md_SNAPTotalScore then gsnap=0; else gsnap=1;
	if hb<&md_hb then ghb=0; else ghb=1;
	if Platelet<&md_Platelet then gplt=0; else gplt=1;
	if Platelet<150 then tbc=1; else tbc=0;
	if ratio<&md_ratio then gratio=0; else gratio=1;
	if PO2value<&md_PO2 then po=0; else po=1;
	if FiO2<&md_FiO2 then fio=0; else fio=1;
		
	format gga gga. gsnap gsnap. ghb ghb. gplt gplt. gratio gratio. pco pco. po gpo. center center. gender gender. race race. ivh ivh. wc wc. BirthResusOxygen BirthResusCPAP ROM Steroids Indomethacin  AntiConvulsant ny. tbc tbc. gr gr. pov pov.;
run;

proc sort nodupkey; by id; run;

*ods trace on/label listing;
proc tphreg data=lbwi;
	class tbc(ref=last);
	model day*ivh(0)=tbc;
run;
*ods trace off;

*******************************************************************************************************************************;
*ods trace on/lable listing;

%macro cox(data,out,varlist);

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

%if &var=bw or &var=Gestage %then %do;
proc phreg data=&data;
	model day*ivh(0)=&var/rl;
	ods output Phreg.ParameterEstimates=cox&i;
run;
%end;
%else %do;
proc tphreg data=&data;

	%if &var=tbc or &var=po	%then %do;	class &var(ref=last);	%end;
	%else %do; class &var(ref=first);%end;

	class &var(ref=last);	
	model day*ivh(0)=&var/rl;
	ods output tPhreg.ParameterEstimates=cox&i;
run;
%end;

%if &var^=pco2 %then %do;
data cox&i;
	set cox&i;
	idx=&i;
	format idx idx.;
run;
%end;

%else %do;
data cox&i;
	set cox&i(obs=2);
	if _n_=1 then idx=&i;
	if _n_=2 then idx=&i+1;
	format idx idx.;
run;
%end;

data &out;
	set &out cox&i;
	CL=compress(put(HRLowerCL, 4.2))||"-"||compress(put(HRUpperCL,4.2));
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend cox;

*%let varlist=bw Gestage SNAPTotalScore hb platelet PO2Value FiO2 Rt;
%let varlist=bw Gestage tbc BirthResusOxygen BirthResusCPAP Steroids po pco2;
%cox(lbwi, cox, &varlist);

*********************************************************************************************************************************;
%let t1=3;
%let t2=7;

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
		if item=3 then  do; code0=put(code, race.); end;
		if item=4 then  do; code0=put(code, wc.); end;

	
		if item=5 then  do; code0=put(code, gga.); end;
		if item=6 then  do; code0=put(code, gsnap.); end;
		if item=7 then  do; code0=put(code, ghb.); end;
		if item=8 then  do; code0=put(code, gplt.); end;
		if item=9 then  do; code0=put(code, tbc.); end;
		if item=10 then  do; code0=put(code, ny.); end;
		if item=11 then  do; code0=put(code, ny.); end;
		if item=12 then  do; code0=put(code, ny.); end;
		if item=13 then  do; code0=put(code, ny.); end;
		if item=14 then  do; code0=put(code, pco.); end;

		if item=15 then  do; code0=put(code, gpo.); end;
		if item=16 then  do; code0=put(code, pov.); end;
		if item=17 then  do; code0=put(code, gfio.); end;
		if item=18 then  do; code0=put(code, gratio.); end;
		if item=19 then  do; code0=put(code, gr.); end;
		if item=20 then  do; code0=put(code, ny.); end;
		if item=21 then  do; code0=put(code, ny.); end;

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

%let varlist=center gender race wc gga gsnap ghb gplt tbc BirthResusOxygen BirthResusCPAP ROM steroids pco po pov fio gratio gr Indomethacin;
%tab(lbwi, tab, &varlist);

%let pm=%sysfunc(byte(177));


proc freq data=lbwi;
tables AntiConvulsant*ivh;
run;

data tab;
	length pvalue $8;
	set tab; by item code;
	pvalue=put(probchisq,4.2);
	if probchisq^=. and probchisq<0.01 then pvalue="<0.01";
	if not first.item then pvalue=" ";
	format probchisq 4.2;

	surv_err&t1=put((1-survival&t1)*100,4.1)||"&pm"||put(stderr&t1*100,4.1);
	surv_err&t2=put((1-survival&t2)*100,4.1)||"&pm"||put(stderr&t2*100,4.1);
	rename n=nt;
	if item=3 and code=6 then delete;
	if item=14 and code=999 then delete;
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

ods rtf file="ivh.rtf" style=journal startpage=no bodytitle ;

proc report data=tab1 nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title "Frequency and Cumulative Incidence of IVH by Baseline Demographic and Clinical Characteristics";

column item code0 nt ("*IVH Grade>=2" n1 f) ("*Cumulative IVH(%) &pm SEE" surv_err&t1 surv_err&t2) pvalue;

define item/order ORDER=INTERNAL width=50 "Characteristic" style(column)=[just=left] style(header)=[just=left];
define code0/" " style(column)=[just=left];
define nt/"n" style(column)=[cellwidth=0.6in just=center];
define n1/"n" style(column)=[cellwidth=0.6in just=center];
define f/"%" style(column)=[cellwidth=0.8in just=center];
define surv_err&t1/"&t1 days" style(column)=[cellwidth=1in just=center];
define surv_err&t2/"&t2 days" style(column)=[cellwidth=1in just=center];
define pvalue/"p value" style(column)=[cellwidth=0.8in just=center];

break after item / dol dul skip;
run;

ods rtf startpage=yes;
proc print data=cox noobd label split="*" style(header) = [just=center];
title "Univariable Analysis of Factors Associated With IVH";
Var idx /style(data) = [cellwidth=2in just=left] style(header) = [just=left];
var Estimate  StdErr HazardRatio CL probchisq/style(data) = [cellwidth=1.0in just=center];
label idx="Effect"
		Estimate="Estimate"
		StdErr="*Standard Error"
		HazardRatio="*Hazard Ratio"
		CL="95%CI"
		probchisq="*p value"
		;

	format estimate stderr 7.4 HazardRatio 4.2 probchisq 5.2; 
run;
ods rtf close;
