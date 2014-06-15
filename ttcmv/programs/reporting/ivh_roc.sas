options nodate nonumber;
libname wbh "/ttcmv/sas/programs";

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.comp_pat(in=comp keep=id);
	by id;
	if comp;
	
	retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
run;

/*
proc print;
var id ivhdiagdate imagedate;
run;
*/

proc sort data=cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime) out=tx_rbc;by id DateTransfusion rbc_TxStartTime; run;
data tx_rbc;
	set tx_rbc; by id DateTransfusion rbc_TxStartTime;
	retain dt_rbc;
	if first.id then do; nrbc=0; dt_rbc=DateTransfusion; end;
	nrbc+1;
	if last.id;
	format dt_rbc date9.;
run;

proc sort data=cmv.plate_033(keep=id  DateTransfusion plt_TxStartTime) out=tx_plt;by id DateTransfusion plt_TxStartTime; run;

data tx_plt;
	set tx_plt; by id DateTransfusion plt_TxStartTime;
	retain dt_plt;
	if first.id then do; nplt=0; dt_plt=DateTransfusion; end;
	nplt+1;
	if last.id;
	format dt_plt date9.;
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
    merge cmv.med cmv.plate_005(keep=id LBWIDOB) cmv.plate_068(keep=id in=A); by id;
    if A and medcode=14;
    if StartDate-LBWIDOB<=3; 
    keep id;
run;

proc sort nodupkey; by id;run;

data indo3;
    merge indo(in=A) cmv.plate_068(keep=id); by id;
    if not A;
    keep id;
run;
proc sort nodupkey; by id;run;

data indo;
    merge indo(in=A) indo3(in=B); by id;
    if A then indo=1; else indo=0;
run;


**********************************************************************************;

data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate DateTransfusion=dt;
run;

proc sort nodupkey; by id dt; run;

data hb;
	set cmv.plate_015(keep=id hb hbdate BloodCollectDate) rbc(keep=id hbdate Hb); by id;
		if hbdate=. then hbdate=BloodCollectDate;
		if hb=. then delete;
run;

proc sort; by id hbdate;run;

data first_hb;
    set hb; by id hbdate;
    if first.id;
    keep id hb hbdate;
run;

data anemia8;
    merge hb ivh2 ; by id;
    if hbdate<=imagedate and hb<=8;
run;
proc sort nodupkey; by id; run;

data anemia9;
    merge hb ivh2 ; by id;
    if hbdate<=imagedate and hb<=9;
run;
proc sort nodupkey; by id; run;

data rbc_hb;
    set rbc; by id dt;
    if first.id;
    keep id dt;
run;

data tx_hb;
    merge hb rbc_hb; by id;
    if hbdate<=dt and hb^=.;
run;

data tx_hb;
    set tx_hb; by id hbdate; 
    if last.id;
    keep id hb;
run;


data platelet;
	set cmv.plate_033;
    keep id DateTransfusion plateletnum DatePlateletCount;
	rename DatePlateletCount=pltdate DateTransfusion=dt plateletnum=platelet;
run;

proc sort nodupkey; by id dt; run;

data plt;
	set cmv.plate_015(keep=id platelet pltdate BloodCollectDate) platelet(keep=id pltdate platelet); by id;
		if pltdate=. then pltdate=BloodCollectDate;
		if platelet^=.;
run;

proc sort; by id pltdate;run;

data first_plt;
    set plt; by id pltdate;
    if first.id;
    keep id platelet pltdate;
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
	cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
	sepsis(in=S)
	indo(keep=id in=pda_indo)
	ivh2 tx_hb(rename=(hb=dt_hb))
	tx_rbc(in=tx_rbc) tx_plt(in=tx_plt)
	anemia8(in=tmpa)
	anemia9(in=tmpb)
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=comp);
	
	by id;
	
	if comp;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if PltDate=. then PltDate=BloodCollectDate; 
	if HctDate=. then HctDate=BloodCollectDate;
	if HbDate=. then HbDate=BloodCollectDate; 

	if ivh=. then ivh=0;
	if S then sepsis=1; else sepsis=0;
	
	if 50<=po2value<65 then pov=1; if 30<=po2value<50 then pov=3; if po2value<30 then pov=5; if po2value>65 then pov=0;
	Ratio=pO2Value/FiO2*100;
	if ratio>250 then gr=0; if 100<=ratio<250 then gr=5; if ratio<100 then gr=16;
	rt=ratio/100;
	day=StudyLeftDate-lbwidob;
	if ivh then day=Imagedate-LBWIDOB;
	
	if tx_rbc or tx_plt then tx=1; else tx=0;
	
	if tx_rbc and imagedate>dt_rbc then rbc=1; else if tx_rbc and imagedate<=dt_rbc then rbc=0; else rbc=.;
	if tx_plt and imagedate>dt_plt then plt=1; else if tx_plt and imagedate<=dt_plt then plt=0; else plt=.;

	
	center=floor(id/1000000);

	if 1000<=BirthWeight<=1500 then wc=1;	else if BirthWeight<1000 then wc=2; else wc=0;
	PCO=PCO2;

	if Indomethacin=. then Indomethacin=0;
	if AntiConvulsant=. then AntiConvulsant=0;

	if tmpa then anemic8=1; else anemic8=0; 
	if tmpb then anemic9=1; else anemic9=0; 
	
	if 0<Apgar5Min<3 then apg=1; else if Apgar5Min>=3 then apg=0;

	if tx_rbc then do; if nrbc in(1,2) then idx_rbc=1; else if nrbc>2 then idx_rbc=2; end; else idx_rbc=0; 
	if tx_rbc then with_rbc=1; else  with_rbc=0;
	
	if ivh then do;
	if imageDate<=hbdate then hb=.;
	if imageDate<=pltdate then platelet=.;
	end;
	
		
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight wc BirthResus  BirthResusOxygen BirthResusCPAP PO2Value 
			PCO2 PCO FiO2 ratio OxyIndex StudyLeftDate day SNAPTotalScore  Platelet Hct Hb dt_hb ivh IVHDiagDate ImageDate LeftIVHGrade 
			sepsis indo	RightIVHGrade 	ROM Steroids Indomethacin  AntiConvulsant gr rt pov snap   
			tx rbc plt	IsChorloConfirm HistoChloro Apgar5Min apg anemic8 anemic9 idx_rbc dt_rbc dt_plt nrbc with_rbc;		 
run;

ods trace on /label listing;
proc logistic data= lbwi descending; 
 model ivh = hb/outroc=roc1 details lackfit ctable pprob = (.05 to .6 by .05);
 ods output Logistic.Classification=ctab_hb;
run;
ods trace off;

proc contents data=ctab_hb short varnum; run;

proc logistic data= lbwi descending; 
 model ivh = platelet/outroc=roc2 details lackfit ctable pprob = (.05 to .6 by .05);
  ods output Logistic.Classification=ctab_plt;
run;

proc greplay igout= wbh.graphs  nofs; delete _ALL_; run;

symbol1 i=join v=none ;
proc gplot data=roc1 gout=wbh.graphs;
  title 'ROC Curve by Hb';
  plot _sensit_*_1mspec_ / vaxis=0 to 1 by .1 ;
run;
proc gplot data=roc2 gout=wbh.graphs;
  title 'ROC Curve by Platelet Number';
  plot _sensit_*_1mspec_ / vaxis=0 to 1 by .1 ;
run;
quit;
title;

goptions reset=all  gunit=pct colors=(orange green red) ftitle=Times ftext=Times hby = 3;

ods pdf file="roc.pdf" style=journal;
proc greplay igout = wbh.graphs tc=sashelp.templt template=v2s nofs; * L2R2s;
     treplay 1:1 2:2;
run;

proc print data=ctab_hb;
title "Hb";
var ProbLevel CorrectEvents CorrectNonevents IncorrectEvents IncorrectNonevents Correct Sensitivity Specificity FalsePositive           
FalseNegative/style(data)=[width=0.75in];
run;

proc print data=ctab_plt;
title "Platelet Number";
var ProbLevel CorrectEvents CorrectNonevents IncorrectEvents IncorrectNonevents Correct Sensitivity Specificity FalsePositive           
FalseNegative/style(data)=[width=0.75in];
run;
ods pdf close;
