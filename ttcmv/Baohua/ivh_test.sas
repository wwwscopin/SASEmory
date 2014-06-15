options nodate nonumber;

%include "/ttcmv/sas/programs/reporting/baohua/macro.sas";

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh0;
	merge   cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade in=A)
			cmv.completedstudylist(in=comp);
	by id;
	if A and comp;
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
run;

proc sort; by id imagedate; run;

data ivhdate; 
    set ivh0; by id imagedate; 
    if first.id;
    keep id imagedate;
run;

data ivh1;
    set ivh0; by id imagedate;
    if LeftIVHGrade in(1,2,3,4) and RightIVHGrade in(1,2,3,4) then bilateral=1; else bilateral=0; 
    
   	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
    
    retain num_ivh 0;
    ini=0;
    if first.id then do; num_ivh=0; ini=1; end;
    num_ivh=num_ivh+1;

  	center=floor(id/1000000);
  	  	
    if	LeftIVHGrade=99 then LeftIVHGrade=0;
    if	RightIVHGrade=99 then RightIVHGrade=0;
run;

proc sort; by id descending ivh; run;

data img_mark; 
    set ivh1; by id descending ivh; 
    if first.id; 
    keep id ivh imagedate; 
    rename imagedate=idate;
run;

data tx_id;
	set     cmv.plate_031(keep=id DateTransfusion in=A)
			cmv.plate_033(keep=id DateTransfusion in=B)
			cmv.plate_035(keep=id DateTransfusion in=C)
			cmv.plate_037(keep=id DateTransfusion in=D)
			/*cmv.plate_039(keep=id )*/
		;
    if A then rbc=1;  
    if B then plt=1;  
    if C then fp=1;   
    if D then cryo=1;
run;

proc sort; by id DateTransfusion;run;

data tx;
	merge img_mark(in=A) tx_id cmv.comp_pat(in=comp); by id;
    *if datetransfusion<=dob+3;

    if A and comp;
    if rbc=. then rbc=0;
        if plt=. then plt=0;
            if fp=. then fp=0;
                if cryo=. then cryo=0;
    keep id datetransfusion rbc plt fp cryo ivh;
run;

%let varlist=fp plt;
%tab(tx, ivh, tabtx, &varlist); quit;

data tab_tx; 
    set tabtx;
    item=item+8;
    keep item nfy nfn pv pvalue;
    rename nfy=mean1 nfn=mean0;
run;

data lab;
    set cmv.plate_015(in=A) 
    cmv.plate_033(keep=id dateplateletcount plateletnum rename=(dateplateletcount=pltdate plateletnum=platelet))
    cmv.plate_035(keep=id dateptptttest pt ptt fibrinogen rename=(dateptptttest=ptdate))
    cmv.plate_037(keep=id datefibrinogen fibrinogenlevel rename=(datefibrinogen=ptdate fibrinogenlevel=fibrinogen));

    if A then do;
       if WeightDate=. then WeightDate=AnthroMeasureDate;
	   if PltDate=. then PltDate=BloodCollectDate; 
	   if HctDate=. then HctDate=BloodCollectDate;
	   if HbDate=. then HbDate=BloodCollectDate; 
    end;
    keep id weightdate hbdate hctdate pltdate ptdate hb hct platelet pt ptt fibrinogen;
run;

proc sort; by id; run;

data lab; 
    merge lab(in=A) cmv.comp_pat(in=comp) ivhdate; by id; 
    if A;
  
    /*
    if pltdate>dob+3 then platelet=.;
    if ptdate>dob+3 then  do; pt=.; ptt=.; fibrinogen=.; end;
    */
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

data lbwi;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender)
	cmv.plate_006
	cmv.plate_008(keep=id ROM Steroids)	
	cmv.plate_010(keep=id PO2Value  PCO2  FiO2  OxyIndex) 
	cmv.plate_012(keep=id SNAPTotalScore)
    lab
	cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
	cmv.ivh_image(in=xxx keep=id ImageDate LeftIVHGrade RightIVHGrade)
	img_mark
	tx(in=txx drop=ivh) sepsis(in=S)
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=B);
	by id;

	
	if S then sepsis=1; else sepsis=0;
	if B;
	
	day=StudyLeftDate-lbwidob;
	if ivh then day=Idate-LBWIDOB;
	
    center=floor(id/1000000);

	PCO=PCO2;

    if ivh in (0,1);
	
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight BirthResus  BirthResusOxygen BirthResusCPAP PO2Value PCO2 PCO 
			FiO2 OxyIndex StudyLeftDate day SNAPTotalScore  Platelet Hct Hb ivh0 ivh IVHDiagDate ImageDate td LeftIVHGrade sepsis 
			RightIVHGrade 	Indomethacin AntiConvulsant ROM Steroids Indomethacin  AntiConvulsant apgar1min apgar5min cordph
			datetransfusion rbc plt fp cryo platelet pt ptt fibrinogen pltdate ptdate hbdate hctdate weightdate;		 
run;

proc means data=lbwi(where=(ivh=1));
var day;
output out=median_day median=/autoname;
run;

data _null_;
	set median_day;
	call symput("img_day", compress(put(day_median,4.0)));
run;

%let mu=%sysfunc(byte(181));

proc format;
  value ivh    0="IVH=No" 1="IVH=Yes";
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

  value idx
	1="Gestational Age (wks)"
	2="Birth Weight (g)"
	3="5-minute Apgar score "
	4="Cord pH"
	5="PT (s)"
	
	6="PTT (s)" 
	7="Fibrinogen (mg/dL)"
	
	8="PLTs(x10^9/L)"
	9="FP Transfusion"
	10="PLT Transfusion"
;
run;

*******************************************************************************************************************************;
%let pm=%sysfunc(byte(177));  
%macro stat(data, gp, out, varlist);
	data &out;
		if 1=1 then delete;
	run;
	
    proc sort data=&data out=sub nodupkey; by id; run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );
	
	%if &var=pt or &var=ptt or &var=fibrinogen %then %do;
        data sub;
            set &data; 
            where ptdate^=.;
        run;	
     	proc sort nodupkey; by id ptdate; run;
     	    	proc print; var id ivh ptdate pt ptt fibrinogen; run;
     	data sub; set sub; by id; if first.id;run;
 	%end;
	

	%if &var=platelet %then %do;
        data sub;
            set &data; 
            where pltdate^=.;
        run;	
     	proc sort nodupkey; by id pltdate; run;
     	data sub; set sub; by id; if first.id;run;
	%end;


	proc means data=sub;
		class &gp;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		if std=. then std=0;
		%if &var=cordph %then %do;
			*mean0=put(mean,4.2)||" &pm "||compress(put(std,4.2))||"["||compress(put(Q1,4.2))||" - "||compress(put(Q3,4.2))||"]";
			mean0=put(mean,4.2)||" &pm "||compress(put(std,4.2))||"("||compress(n)||")";
			format median 3.0;
		%end;
		%else %do;
			mean0=put(mean,4.0)||" &pm "||compress(put(std,4.0))||"("||compress(n)||")";
		%end;
		if &gp=. then delete;

		item=&i;
		keep &gp mean0 median item;
	run;

	proc npar1way data = sub wilcoxon;
  		class &gp;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $10;
		set wp&i;
		if _n_=10;
		item=&i;
		pvalue=nvalue1;
		pv=put(nvalue1, 7.4);
		if pvalue<0.0001 then pv='<0.0001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(&gp=0)) 
			tab&i(where=(&gp=1)rename=(mean0=mean1 median=median1)) wp&i; by item;
		drop &gp;
	run;

	data &out;
		set &out tab&i;
	run;

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend stat;	
*********************************************************************************************************************************;

%let varlist=gestage BirthWeight apgar5min cordph pt ptt fibrinogen platelet;
*%let varlist=gestage BirthWeight apgar5min cordph pt platelet;
%stat(lbwi, ivh, tab, &varlist);

%let pm=%sysfunc(byte(177));

data tab;  set tab tab_tx; by item;run;

proc print data=tab;format item idx.; run;


ods rtf file="ivh_test.rtf" style=journal startpage=no bodytitle ;


proc report data=tab nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center];
title "Comparison between IVH Extend or Not";

column item mean0 mean1 pv;

define item/order ORDER=INTERNAL format=idx. "Variable" style(column)=[just=left cellwidth=1.75in] style(header)=[just=left];
define mean0/"IVH did not extend" style(column)=[cellwidth=1.25in just=center];
define mean1/"IVH extend" style(column)=[cellwidth=1.25in just=center];
define pv/"p value" style(column)=[cellwidth=1in just=center];
break after item / dol dul skip;

run;

ods rtf close;

