options nodate nonumber;
%include "macro.sas";

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;
    retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(3,4) or RightIVHGrade in (3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
run;

data _null_;
    set ivh2 nobs=nobs;
    call symput("k", compress(nobs));
run;


proc sort data=cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime) out=tx_rbc;by id DateTransfusion rbc_TxStartTime; run;


data tx_rbc;
    merge tx_rbc(in=tx) ivh2(in=tmp); by id;
    if tmp then if DateTransfusion>=imagedate then delete;
    if tx;
run;

data tx_rbc;
	set tx_rbc; by id DateTransfusion rbc_TxStartTime;
	retain dt_rbc;
	if first.id then do; nrbc=0; dt_rbc=DateTransfusion; end;
	nrbc+1;
	if last.id;
	format dt_rbc mmddyy.;
run;

proc freq; 
tables nrbc;
run;

proc sort data=cmv.plate_033(keep=id  DateTransfusion plt_TxStartTime) out=tx_plt;by id DateTransfusion plt_TxStartTime; run;
data tx_plt;
    merge tx_plt(in=tx) ivh2(in=tmp); by id;
    if tmp then if DateTransfusion>=imagedate then delete;
    if tx;
run;

data tx_plt;
	set tx_plt; by id DateTransfusion plt_TxStartTime;
	retain dt_plt;
	if first.id then do; nplt=0; dt_plt=DateTransfusion; end;
	nplt+1;
	if last.id;
	format dt_plt mmddyy.;
run;

proc freq; 
tables nplt;
run;


%macro data(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 6;
		center=floor(id/1000000);
		CultureDate=Culture&i.Date;
		CultureOrg=Culture&i.Org;
		CultureOrgOther=Culture&i.OrgOther;
		CultureSite=Culture&i.Site;
		CultureSiteOther=Culture&i.SiteOther;
		i=&i;
		output;
	%end;


		keep id center CultureDate CultureOrg CultureOrgOther CultureSite CultureSiteOther CulturePositive CultureYes i 
		InfecConfirm SiteBlood SiteCNS SiteCardio SiteGI SiteLowerResp SiteSurgical SiteUT SiteOther InfectionSiteOther
		XrayDate Comments  /*DFSEQ DFSTATUS DFVALID MOCInit*/; 
		format CultureDate XrayDate mmddyy. center center. InfecConfirm InfecConfirm. CultureYes CultureYes. CulturePositive CulturePositive. CultureSite CultureSite. CultureOrg CultureOrg. i CulturePos.;
run;
%mend;

%data(cmv.infection_all);quit;

data sepsis;
    merge tmp 	cmv.plate_005(keep=id LBWIDOB); by id;
    if CultureDate^=. and CultureDate-LBWIDOB<=3;
run;

proc sort nodupkey; by id;run;

data indo;
    merge cmv.med cmv.plate_005(keep=id LBWIDOB); by id;
    if medcode=14 and StartDate-LBWIDOB<=3; 
    keep id;
run;

proc sort nodupkey; by id;run;

data indom;
    merge cmv.med cmv.plate_005(keep=id LBWIDOB); by id;
    if medcode=14 and StartDate-LBWIDOB<=1; 
    keep id;
run;

proc sort nodupkey; by id;run;


**********************************************************************************;
data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate DateTransfusion=dt;
run;

proc sort nodupkey; by id dt; run;

data hb;
	set cmv.plate_015(keep=id hb hbdate BloodCollectDate in=A) rbc(keep=id hbdate Hb); by id;
		if A and hbdate=. then hbdate=BloodCollectDate;
		if hb=. then delete;
run;

data platelet;
	set cmv.plate_033;
    keep id DateTransfusion plateletnum DatePlateletCount;
	rename DatePlateletCount=pltdate DateTransfusion=dt plateletnum=platelet;
run;

proc sort nodupkey; by id dt; run;

data plt;
	set cmv.plate_015(keep=id platelet pltdate BloodCollectDate in=A) platelet(keep=id pltdate platelet); by id;
		if A and pltdate=. then pltdate=BloodCollectDate;
		if platelet=. then delete;
run;


data first_plt;
    set cmv.plate_015(keep=id dfseq platelet pltdate BloodCollectDate where=(dfseq=1)); 
    if pltdate=. then pltdate=bloodcollectdate;
    if platelet=. then delete;
    keep id platelet pltdate;
run;


data tx_platelet;
    merge plt(in=A) ivh2(in=B) cmv.comp_pat(in=comp); by id;
    if A then if 4<=pltdate-dob<=10;
    if B then if pltdate<imagedate;
    if comp;
    keep id pltdate platelet;
run;

proc sort; by id pltdate;run;

data tx_platelet;
    set tx_platelet; by id pltdate; 
    if last.id;
    rename pltdate=last_pltdate;
    keep id pltdate platelet;
run;

data anemia7;
    merge hb ivh2(in=ivh) ; by id;
    if 0<hb<=7;
    if ivh then if hbdate>=imagedate then delete;
    keep id;
run;
proc sort nodupkey; by id; run;

data anemia8;
    merge hb ivh2(in=ivh) ; by id;
    if 0<hb<=8;
    if ivh then if hbdate>=imagedate then delete;
    keep id;
run;
proc sort nodupkey; by id; run;

data anemia9;
    merge hb ivh2(in=ivh) ; by id;
    if 0<hb<=9;
    if ivh then if hbdate>=imagedate then delete;
    keep id;
run;
proc sort nodupkey; by id; run;

data anemia9_any;
    merge hb ivh2 cmv.completedstudylist(in=comp); by id;
    if 0<hb<=9;
    if comp;
    keep id;
run;
proc sort nodupkey; by id; run;

data first_hb;
    merge cmv.plate_015(keep=id dfseq hb hbdate BloodCollectDate where=(dfseq=1)) cmv.completedstudylist(in=comp); by id;
    if hbdate=. then hbdate=BloodCollectDate;
    if hb=. then delete;
    if comp;
    keep id hb hbdate;
run;

proc print;
var id hb hbdate;
run;

data lbwi;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	cmv.plate_006
	cmv.plate_008(keep=id ROM Steroids)	
	cmv.plate_009(keep=id IsChorloConfirm HistoChloro)	
	cmv.plate_010(keep=id PO2Value  PCO2  FiO2  OxyIndex) 
	cmv.plate_012(keep=id SNAPTotalScore)
	/*cmv.plate_015(where=(DFSEQ=1)keep=id DFSEQ AnthroMeasureDate BloodCollectDate Platelet PltDate Hct HctDate Hb HbDate)*/
	first_hb first_plt
	cmv.plate_068(keep=id Indomethacin  AntiConvulsant)
	sepsis(in=S)
	indo(in=indoA) indom(in=indoB)
	ivh2 
	/*tx_hb(rename=(hb=dt_hb))
	tx_platelet(rename=(platelet=dt_platelet))*/
	tx_rbc(in=tx_rbc) tx_plt(in=tx_plt)
	anemia8(in=tmpa keep=id)
	anemia9(in=tmpb keep=id)
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=comp);
	
	by id;
	
	if comp;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if PltDate=. then PltDate=BloodCollectDate; 
	if HctDate=. then HctDate=BloodCollectDate;
	if HbDate=. then HbDate=BloodCollectDate; 
	
	if indoa then indo=1; else indo=0;
	if indob or indomethacin=1 then indom=1; else indom=0;
	if AntiConvulsant=. then AntiConvulsant=0;

	if ivh=. then ivh=0;
	if S then sepsis=1; else sepsis=0;

	if 50<=po2value<65 then pov=1; if 30<=po2value<50 then pov=3; if po2value<30 then pov=5; if po2value>65 then pov=0;
	Ratio=pO2Value/FiO2*100;
	if ratio>250 then gr=0; if 100<=ratio<250 then gr=5; if ratio<100 then gr=16;
	day=StudyLeftDate-lbwidob;
	if ivh then day=Imagedate-LBWIDOB;
	
/*
	if ivh then do;
	if imageDate<=hbdate then hb=.;
	if imageDate<=pltdate then platelet=.;
	end;
*/
	
	center=floor(id/1000000);

	if 1000<=BirthWeight<=1500 then wc=1;	else if BirthWeight<1000 then wc=2; else wc=0;
	
    if pco2=999 or pCO2=5 then pco2=.;
	PCO=PCO2;

	
	if tmpa then anemic8=1; else anemic8=0; 
	if tmpb then anemic9=1; else anemic9=0; 
	
	if 0<Apgar5Min<3 then apg=1; else if Apgar5Min>=3 then apg=0;
	
	if tx_rbc then rbc=1; else rbc=0;
	if tx_plt then plt=1; else plt=0;
	*if rbc=0 then dt_hb=.;
	*if plt=0 then dt_platelet=.;


	if nrbc in(1,2) then idx_rbc=1; else if nrbc>2 then idx_rbc=2; else idx_rbc=0; 
	if nplt in(1,2) then idx_plt=1; else if nplt>2 then idx_plt=2; else idx_plt=0; 

	
	if nrbc=. then nrbc=0;
	if nplt=. then nplt=0;
	
    rbc_day=imageDate-dt_rbc;
    plt_day=imageDate-dt_plt;
    
   	
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight wc BirthResus  BirthResusOxygen BirthResusCPAP PO2Value 
			PCO2 PCO FiO2 ratio OxyIndex StudyLeftDate day SNAPTotalScore  Platelet Hct Hb ivh IVHDiagDate ImageDate LeftIVHGrade 
			sepsis indo indom RightIVHGrade ROM Steroids Indomethacin  AntiConvulsant gr pov platelet pltdate hbdate  rbc_day
			plt_day	rbc plt	IsChorloConfirm HistoChloro Apgar5Min apg anemic8 anemic9 idx_rbc idx_plt dt_rbc dt_plt nrbc nplt;		 
run;

proc freq; 
table nplt*ivh;
run;

/*
proc print;
where plt=2;
var id ivh imagedate plt platelet pltdate;
run;


title "xxx";
proc print data=lbwi(where=(rbc=1 or plt=1));
var id rbc imagedate dt_rbc rbc_day plt dt_plt plt_day;
run;
*/

proc means data=lbwi(where=(ivh=1)) n median;
var day;
output out=median_day median=/autoname;
run;

data _null_;
	set median_day;
	call symput("ivh_day", compress(put(day_median,4.0)));
run;

%put &ivh_day;

proc means data=lbwi median;
var GestAge SNAPTotalScore  hb Platelet ratio pO2Value FiO2;
output out=mad median=/autoname;
run;


proc univariate data=lbwi;
var hb;
output out=one Q1=Q1 median=Q2 Q3=Q3;
run;

data _null_;
    set one;
    call symput("hb_Q1", put(Q1,4.1));
	call symput("hb_Q2", put(Q2,4.1));
	call symput("hb_Q3", put(Q3,4.1));
run;

proc univariate data=lbwi;
var Platelet;
output out=two Q1=Q1 median=Q2 Q3=Q3;
run;

data _null_;
    set two;
    call symput("plt_Q1", put(Q1,4.1));
	call symput("plt_Q2", put(Q2,4.1));
	call symput("plt_Q3", put(Q3,4.1));
run;


data _null_;
	set mad;
	call symput("md_Gestage", compress(put(GestAge_median,4.1)));
	call symput("md_SNAPTotalScore", compress( put(SNAPTotalScore_median,4.0)));
	call symput("md_hb", compress(put(hb_median,4.1)));
	/*call symput("md_dt_hb", compress(put(dt_hb_median,4.1)));
	call symput("md_dt_platelet", compress(put(dt_platelet_median,4.1)));*/
	call symput("md_Platelet", compress(put(Platelet_median,5.0)));
	call symput("md_ratio", compress(put(ratio_median,4.1)));
	call symput("md_PO2", compress(put(PO2Value_median,4.1)));
	call symput("md_FiO", compress(put(FiO2_median,4.1)));
run;

%put &md_FiO;


%let mu=%sysfunc(byte(181));

proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value wc  0="Low"  1="Very Low(1000-1500g)" 2="Extremely Low(<1000g)" ;
	value ny 0="No" 1="Yes";
	value pco 0="<50(0 pt)" 1="50-65(1 pt)" 3="66-90(3 pts)"  5=">90(5 pts)" 999="Missing";
	value pov 0=">65(0 pt)" 1="50-65(1 pt)" 3="30-50(3 pts)"  5="<30(5 pts)" 999="Missing";
	value gga    0="<=Median(&md_Gestage weeks)" 1=">Median" ;
	value gsnap  0="<=Median(&md_SNAPTotalScore)" 1=">Median" ;

	value ghb    0="<=Median(&md_hb g/dL)" 1=">Median" ;
	value gdt_hb    0="<=Median(&md_dt_hb g/dL)" 1=">Median" ;
	value gdt_platelet    0="<=Median(&md_dt_platelet *1000/&mu.L)" 1=">Median" ;
	
	value gplt   0="<=Median(&md_Platelet *1000/&mu.L)" 1=">Median" ;
	value tbc    1="Platelet Count<150 *1000/&mu.L" 0="Platelet Count>=150 *1000/&mu.L";
	value ttbc   0="Normal(>=150*1000/&mu.L)" 1="Mild(100-149*1000/&mu.L)" 2="Moderate(50-99*1000/&mu.L)" 3="Severe(30-49*1000/&mu.L)" 4="Very Severe(<30*1000/&mu.L)";
	
	value gratio 0="<=Median(&md_ratio mmHg)" 1=">Median" ;
	value gpo    0="<=Median(&md_pO2 mmHg)" 1=">Median" ;
	value gfio   0="<=Median(&md_FiO %)" 1=">Median" ;
	value gr     0=">=250(mmHg)(0 pt)" 5="100-250(5 pts)" 16="<100(16 pts)";
	value apg    1="<3" 0=">=3";
	
	value ane_e 1="Yes(Hb<=8 g/dL)" 0="No(Hb>8 g/dL)";
	value ane_n 1="Yes(Hb<=9 g/dL)" 0="No(Hb>9 g/dL)";
	value ntx   0="tx=0" 1="tx=1-2" 2="tx>=3";
	value hb_idx  1="<=&hb_Q1 g/dL" 2="&hb_Q1 g/dL - &hb_Q2 g/dL" 3="&hb_Q2 g/dL - &hb_Q3 g/dL" 4=">&hb_Q3 g/dL";
	value plt_idx 1="<=&plt_Q1 *1000/&mu.L" 2="&plt_Q1 *1000/&mu.L - &plt_Q2 *1000/&mu.L" 3="&plt_Q2 *1000/&mu.L - &plt_Q3 *1000/&mu.L" 4=">&plt_Q3 *1000/&mu.L";
	
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
	6 = "SNAP at Birth"
	7 = "Hemoglobin at Birth"
	8 = "Hemoglobin at Birth by Quartile"
	/*9="Hemoglobin at 1st RBC Transfusion"*/
	9= "pRBC Transfusion"
	10= "pRBC Transfusion by Number"
	11= "Ever Anemic (Hb<=8 g/dL)"
	12 = "Ever Anemic (Hb<=9 g/dL)"
	13 = "Platelet Count at Birth"
	14 = "Platelet Count at Birth by Quartile"
	/*
	16 = "Platelet at 1st Platelet Transfusion"
	16="Platelet count at week 1 (4-10 days)"
	*/
	
	15= "Platelet Transfusion"
	16= "Platelet Transfusion by Number"
	17= "Thrombocytopenia at Birth*"
	18= "Thrombocytopenia at Birth by Platelet Count*"
	19= "Birth resuscitation/stabilization with Oxygen"
	20= "Birth resuscitation/stabilization with CPAP"
	21= "Premature rupture of membranes"
	22= "Steroids given prior to delivery to accelerate maturity?"
	23= "PCO2 Value(mmHg) at Birth"
	24= "PO2(mmHg) at Birth"
	25= "PO2(mmHg) at Birth."
	26= "FiO2 (%) at Birth"
	27= "PO2/FiO2 at Birth"
	28= "PO2/FiO2 at Birth."
	29= "Was Indomethacin given within the first 24 hours of life for any prophylaxis?"
	30= "Was Indomethacin given within the first 72 hours of life for any prophylaxis?"
	31= "Was seizures treated with an anti-convulsant for 72 hours?"
	32= "Early Sepsis(<=72 hrs)"
	33= "5-minute Apgar score"
	34= "Was clinical diagnosis of chorioamnionitis confirmed?"
	35= "Was histologic chorioamnionitis confirmed?"
;

  value idx
	1="Birth Weight(per 100g increase)"
	2="Gestational Age(per week increase)"
	3="SNAP(per 5 unit increase)"
	4="Hemoglobin at Birth(per 5 g/dL increase)"
	5="Hemoglobin at Birth('>=Median(&md_hb)' vs '< Median')"
	6 = "Ever Anemic (Hb<=8 g/dL)"
	7 = "Ever Anemic (Hb<=9 g/dL)"
	8="Thrombocytopenia at Birth('<150(1000/&mu.L)' vs '>=150')"
	9="Platelet Count at Birth(per 25*1000/&mu.L increase)"
	/*10="Platelet count at week 1 (4-10 days, per 25*1000/&mu.L increase)"*/
	10="Birth resuscitation/stabilization with Oxygen('Yes' vs 'No')"
	11="Birth resuscitation/stabilization with CPAP('Yes' vs 'No')"
	12="Steroids given prior to delivery to accelerate maturity?('Yes' vs 'No')" 
	13="pRBC Transfusion(per 1 tx increase)"
	14="Platelet Transfusion(per 1 tx increase)"
	15= "Was Indomethacin given within the first 24 hours of life for any prophylaxis?('Yes' vs 'No')"
	16= "PO2 at Birth (per 5 unit increase)"
	17= "FiO2 at Birth (per 5 percent increase)"
	18= "PO2/FiO2 at Birth (per 5 unit increase)"
	19= "5-minute Apgar score (per 1 unit increase)"
	20= "pRBC Transfusion (tx=1-2 vs tx=0)"
	21= "pRBC Transfusion (tx>=3 vs tx=0)"
	22= "Platelet Transfusion (tx=1-2 vs tx=0)"
	23= "Platelet Transfusion (tx>=3 vs tx=0)"

;
run;

data lbwi;
	set lbwi;
	if 0<Gestage<=&md_Gestage then gga=0; else if gestage^=. then gga=1;
	if 0<SNAPTotalScore<=&md_SNAPTotalScore then gsnap=0; else if SNAPTotalScore^=. then gsnap=1;
	if 0<hb<=&md_hb then ghb=0; else if hb^=. then ghb=1;
	/*
	if 0<dt_hb<=&md_dt_hb then gdt_hb=0; else if dt_hb>&md_dt_hb then gdt_hb=1; else gdt_hb=.;
	if 0<dt_platelet<=&md_dt_platelet then gdt_platelet=0; else if dt_platelet>&md_dt_platelet then gdt_platelet=1; else gdt_platelet=.;
	*/
	
	
	if 0<Platelet<=&md_Platelet then gplt=0; else if Platelet^=. then gplt=1;
	if 0<Platelet<150 then tbc=1; else if platelet^=. then tbc=0;
	if 100<=Platelet<150 then ttbc=1; else if 50<=Platelet<100 then ttbc=2; else if 30<=Platelet<50 then ttbc=3; 
	else if 0<Platelet<30 then ttbc=4; else if Platelet^=. then ttbc=0; 
	
	if 0<ratio<=&md_ratio then gratio=0; else if ratio^=. then gratio=1;
	if 0<PO2value<=&md_PO2 then po=0; else if PO2value^=. then po=1;
	if 0<FiO2<=&md_FiO then fio=0; else if FiO2>&md_FiO then fio=1;
	
	if 0<hb<=&hb_Q1 then hb_idx=1; else if &hb_Q1<hb<=&hb_Q2 then hb_idx=2; else if &hb_Q2<hb<=&hb_Q3 then hb_idx=3; else if hb^=. then hb_idx=4;
	if 0<platelet<=&plt_Q1 then plt_idx=1; else if &plt_Q1<platelet<=&plt_Q2 then plt_idx=2; else if &plt_Q2<platelet<=&plt_Q3 then plt_idx=3; else if platelet^=. then plt_idx=4;
		
	format gga gga. gsnap gsnap. ghb ghb. gplt gplt. gratio gratio. pco pco. po gpo. center center. gender gender. race race. 
	ivh ivh. wc wc. BirthResusOxygen BirthResusCPAP ROM Steroids Indomethacin  AntiConvulsant tx ny. tbc tbc. ttbc ttbc. 
	gr gr. pov pov. hb_idx hb_idx. plt_idx plt_idx. anemic8 ane_e. anemic9 ane_n. idx_rbc idx_plt ntx. ;
run;


*ods trace on/label listing;

proc freq data = lbwi;
  tables tbc / binomial(p=.5);
  exact binomial;
run;

proc phreg data=lbwi;
	class idx_rbc(ref=first) anemic9(ref=first);
	model day*ivh(0)=idx_rbc SNAPTotalScore anemic9;
	hazardratio ' ' SNAPTotalScore / units=5 cl=both;
run;

proc phreg data=lbwi;
	class anemic9(ref=first);
	model day*ivh(0)=nrbc SNAPTotalScore anemic9;
	hazardratio ' ' SNAPTotalScore / units=5 cl=both;
run;

proc phreg data=lbwi;
	class anemic9(ref=first);
	model day*ivh(0)=nplt SNAPTotalScore  anemic9;
	hazardratio ' ' SNAPTotalScore / units=5 cl=both;
run;

proc phreg data=lbwi;
	model day*ivh(0)=nplt SNAPTotalScore ;
	hazardratio ' ' SNAPTotalScore / units=5 cl=both;
run;

*ods trace off;

proc phreg data=lbwi; 
    class fio(ref=first);
	model day*ivh(0)=fio/rl;
run;

proc univariate data=lbwi plot;
    var fio2;
run;

*******************************************************************************************************************************;
*ods trace on/lable listing;

%macro cox(data,out,varlist);

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

%if &var=birthweight or &var=snaptotalscore or &var=Gestage or &var=hb or &var=platelet or &var=Apgar5Min
        or &var=dt_platelet or &var=nrbc or &var=nplt or &var=po2value or &var=fio2 or &var=ratio %then %do;
proc phreg data=&data;
	model day*ivh(0)=&var/rl;
	%if &var=birthweight %then %do; hazardratio 'A' &var / units=100 cl=both; %end;
	%if &var=snaptotalscore %then %do; hazardratio 'B' &var / units=5 cl=both; %end;
	%if &var=Gestage %then %do; hazardratio 'C' &var / units=1 cl=both; %end;
	%if &var=nrbc %then %do; hazardratio 'D' &var / units=1 cl=both; %end;
	%if &var=nplt %then %do; hazardratio 'E' &var / units=1 cl=both; %end;
	%if &var=hb %then %do; hazardratio 'F' &var / units=5 cl=both; %end;
	%if &var=platelet %then %do; hazardratio 'G' &var / units=25 cl=both; %end;
	%if &var=dt_platelet %then %do; hazardratio 'H' &var / units=25 cl=both; %end;
	%if &var=po2value %then %do; hazardratio 'I' &var / units=5 cl=both; %end;
	%if &var=fio2 %then %do; hazardratio 'J' &var / units=5 cl=both; %end;
	%if &var=ratio %then %do; hazardratio 'K' &var / units=5 cl=both; %end;
	%if &var=Apgar5Min %then %do; hazardratio 'L' &var / units=5 cl=both; %end;
	
	ods output Phreg.ParameterEstimates=cox&i;
	ods output Phreg.HazardRatios=unit&i;
	ods output Phreg.NObs=n&i;
run;

data cox&i;
    merge cox&i(drop=HazardRatio HRLowerCL HRUpperCL) unit&i(keep=HazardRatio PLLower PLUpper) n&i(rename=(NObsUsed=num)); 
    rename PLLower=HRLowerCL PLUpper=HRUpperCL;
run;
%end;

%else %do;
proc phreg data=&data; 

	%if &var=tbc %then %do;	class &var(ref=last);	%end;
	%else %do; class &var(ref=first);%end;

	model day*ivh(0)=&var/rl;
	ods output Phreg.ParameterEstimates=cox&i;
	ods output Phreg.NObs=n&i;
run;

data cox&i;
    merge cox&i n&i(rename=(NObsUsed=num)); 
run;
%end;


%if &var^=idx_rbc or &var^=idx_plt %then %do;
data cox&i;
	set cox&i;
	idx=&i;
	format idx idx.;
run;
%end;

%let t=%eval(&i+1);
%let s=%eval(&i+2);

%if &var=idx_rbc %then %do; 
data cox&i;
	set cox&i(obs=2);
    if _n_=1 then idx=&i; 
	if _n_=2 then idx=&t; 
run;
%end;

%if &var=idx_plt %then %do; 	
data cox&i;
	set cox&i(obs=2);
    if _n_=1 then idx=&t; 
	if _n_=2 then idx=&s; 
run; 
%end;


data &out;
	set &out cox&i;
	CL=compress(put(HRLowerCL, 4.2))||"-"||compress(put(HRUpperCL,4.2));
	if probchisq<0.001 then pv='<0.001';
	else pv=put(probchisq,5.3);
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%end;
%mend cox;


%let varlist=birthweight Gestage snaptotalscore hb ghb anemic8 anemic9 tbc platelet BirthResusOxygen BirthResusCPAP Steroids 
nrbc nplt Indom po2value fio2 ratio Apgar5Min idx_rbc idx_plt ;
%cox(lbwi, cox, &varlist);

*********************************************************************************************************************************;
%let t1=3;
%let t2=7;
%let t3=14;

%macro life(data, out, varlist);

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

proc lifetest data=lbwi timelist=&t1 &t2 &t3;
	time day*ivh(0);
	ods output Lifetest.Stratum1.ProductLimitEstimates=s0(keep=Timelist survival StdErr);
run;

data s0;	
	merge s0(where=(timelist=&t1) rename=(survival=survival&t1 StdErr=StdErr&t1)) 
			s0(where=(timelist=&t2) rename=(survival=survival&t2 StdErr=StdErr&t2)) 
			s0(where=(timelist=&t3) rename=(survival=survival&t3 StdErr=StdErr&t3)); 
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

proc lifetest data=lbwi timelist=&t1 &t2 &t3;
	time day*ivh(0);
	strata &var;
	survival out=s&var(keep=&var timelist survival sdf_stderr) REDUCEOUT stderr;
	ods output Lifetest.StrataHomogeneity.HomTests=p&var(keep=probchisq);
run;

data s&var;	
	if _n_=1 then set p&var(obs=1);
	merge s&var(where=(timelist=&t1) rename=(survival=survival&t1 sdf_stderr=stderr&t1)) 
    	s&var(where=(timelist=&t2) rename=(survival=survival&t2 sdf_stderr=stderr&t2)) 
		s&var(where=(timelist=&t3) rename=(survival=survival&t3 sdf_stderr=stderr&t3)) ;
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
		if item=8 then  do; code0=put(code, hb_idx.); end;
		/*if item=9 then  do; code0=put(code, gdt_hb.); end;*/
		if item=9 then  do; code0=put(code, ny.); end;
		if item=10 then  do; code0=put(code, ntx.); end;
	    
	    if item=11 then  do; code0=put(code, ane_e.); end;
		if item=12 then  do; code0=put(code, ane_n.); end;
		
		if item=13 then  do; code0=put(code, gplt.); end;
		if item=14 then  do; code0=put(code, plt_idx.); end;
		/*if item=16 then  do; code0=put(code, gdt_platelet.); end;*/
			
		if item=15 then  do; code0=put(code, ny.); end;
		if item=16 then  do; code0=put(code, ntx.); end;
		
		if item=17 then  do; code0=put(code, tbc.); end;
		if item=18 then  do; code0=put(code, ttbc.); end;
		
		if item=19 then  do; code0=put(code, ny.); end;
		if item=20 then  do; code0=put(code, ny.); end;
		if item=21 then  do; code0=put(code, ny.); end;
		if item=22 then  do; code0=put(code, ny.); end;
		if item=23 then  do; code0=put(code, pco.); end;

		if item=24 then  do; code0=put(code, gpo.); end;
		if item=25 then  do; code0=put(code, pov.); end;
		if item=26 then  do; code0=put(code, gfio.); end;
		if item=27 then  do; code0=put(code, gratio.); end;
		if item=28 then  do; code0=put(code, gr.); end;
		if item=29 then  do; code0=put(code, ny.); end;
		if item=30 then  do; code0=put(code, ny.); end;
		if item=31 then  do; code0=put(code, ny.); end;
		if item=32 then  do; code0=put(code, ny.); end;
		if item=33 then  do; code0=put(code, apg.); end;
		if item=34 then  do; code0=put(code, ny.); end;
		if item=35 then  do; code0=put(code, ny.); end;

		keep item code code0 n n1 f survival&t1 StdErr&t1 survival&t2 StdErr&t2 survival&t3 StdErr&t3 ProbChiSq;
		if item in(18,31) then ProbChiSq=.;
	run; 


	data &out;
		set &out;
		Format code;
		INFORMAT code;
 	run;

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend life;

%let varlist=center gender race wc gga gsnap ghb hb_idx rbc idx_rbc anemic8 anemic9 gplt plt_idx plt idx_plt tbc ttbc BirthResusOxygen 
BirthResusCPAP ROM steroids pco po pov fio gratio gr indom indo AntiConvulsant sepsis apg IsChorloConfirm HistoChloro;
%life(lbwi, tab, &varlist);

%let pm=%sysfunc(byte(177));


proc freq data=lbwi;
tables AntiConvulsant*ivh;
run;

data tab;
	length pvalue $8;
	set tab; by item code;
	pvalue=put(probchisq,5.3);
	if probchisq^=. and probchisq<0.001 then pvalue="<0.001";
	if not first.item then pvalue=" ";
	format probchisq 4.2;

	surv_err&t1=put((1-survival&t1)*100,4.1)||"&pm"||put(stderr&t1*100,4.1);
	surv_err&t2=put((1-survival&t2)*100,4.1)||"&pm"||put(stderr&t2*100,4.1);
	surv_err&t3=put((1-survival&t3)*100,4.1)||"&pm"||put(stderr&t3*100,4.1);
	rename n=nt;
	if item=3 and code=6 then delete;
	if item=23 and code=999 then delete;
	format item item.;
run;

data tab1;
	set tab; by item;
	output;
	if last.item then do;
	Call missing( of code code0 nt n1 f survival&t1 StdErr&t1 survival&t2 StdErr&t2 survival&t3 StdErr&t3 ProbChiSq surv_err&t1 surv_err&t2 surv_err&t3) ; 
   output; end;
run;

options orientation=landscape;
ods rtf file="ivh_grade34.rtf" style=journal startpage=no bodytitle ;

proc report data=tab1 nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title "Frequency and Cumulative Incidence of IVH (Grade III, IV) by Baseline Demographic and Clinical Characteristics";

where item not in(11,12,33);

column item code0 nt ("*IVH Grade>=3" n1 f) ("*Cumulative IVH(%) &pm SEE" surv_err&t1 surv_err&t2 surv_err&t3) pvalue;

define item/order ORDER=INTERNAL width=50 "Characteristic" style(column)=[just=left] style(header)=[just=left];
define code0/" " style(column)=[just=left cellwidth=2in];
define nt/"n" style(column)=[cellwidth=0.6in just=center];
define n1/"n" style(column)=[cellwidth=0.6in just=center];
define f/"%" style(column)=[cellwidth=0.8in just=center];
define surv_err&t1/"&t1 days" style(column)=[cellwidth=1in just=center];
define surv_err&t2/"&t2 days" style(column)=[cellwidth=1in just=center];
define surv_err&t3/"&t3 days" style(column)=[cellwidth=1in just=center];
define pvalue/"p value" style(column)=[cellwidth=0.8in just=center];

break after item / dol dul skip;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=11pt}

* Only included data prior to IVH diagnosis for LBWIs with IVH. 
^n
** Thrombocytopenia was defined by Lindern et al. as a platelet count  below 150 x 10^{super 9}/L : BMC Pediatrics 2011,11:16.
^n
*** Scores for PCO2, PO2, PO2/FiO2 were defined by Richardson et al. : Pediatrics 1993,91:617.
";

ods rtf startpage=yes;
proc print data=cox noobs label split="*" style(header) = [just=center];
title "Univariate Cox Regression Analysis of Factors Associated with IVH (grade III, IV)";
where idx not in(6,7);
Var idx /style(data) = [cellwidth=4.25in just=left] style(header) = [just=left];
var num Estimate  StdErr HazardRatio CL pv/style(data) = [cellwidth=0.8in just=center];
label idx="Effect"
       num="n"
		Estimate="Estimate"
		StdErr="*Standard Error"
		HazardRatio="*Hazard Ratio"
		CL="95%CI"
		pv="*p value"
		;

	format estimate stderr 7.4 HazardRatio 4.2 probchisq 5.3; 
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1.5in RIGHTMARGIN=0.9in font_size=11pt}
* The median day for IVH event(IVH with grade>=3) is &ivh_day days.
^n
** Only included data prior to IVH diagnosis for LBWIs with IVH.";

ods rtf close;
