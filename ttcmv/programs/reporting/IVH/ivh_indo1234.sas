options nodate nonumber;
%include "macro.sas";

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.comp_pat(in=comp);
	by id;
	
	if comp;
	retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(3,4) or RightIVHGrade in (3,4) then sivh=1; else sivh=0;
run;

proc sort nodupkey out=ivh_id; by id;run;
proc sort data=ivh(where=(sivh=1)) out=sivh nodupkey; by id;run;

proc sort data=cmv.plate_033(keep=id  DateTransfusion plt_TxStartTime) out=tx_plt;by id DateTransfusion plt_TxStartTime; run;

data tx_plt;
	set tx_plt; by id DateTransfusion plt_TxStartTime;
	retain dt_plt;
	if first.id then do; nplt=0; dt_plt=DateTransfusion; end;
	nplt+1;
	if last.id;
	format dt_plt date9.;
run;

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

	cmv.plate_005(keep=id LBWIDOB Gender)
	cmv.plate_006
	cmv.plate_008
	cmv.plate_009(keep=id IsChorloConfirm HistoChloro)
	cmv.plate_012(keep=id SNAPTotalScore)
	/*cmv.plate_015(where=(DFSEQ=1)keep=id DFSEQ BloodCollectDate Platelet PltDate)*/
	first_hb first_plt
	ivh_id(in=A) sivh(keep=id imagedate rename=(imagedate=sivh_date) in=B) 
	tx_plt(in=C)

	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=comp);
		
	by id;
	
	if comp;
	if A then ivh=1; else ivh=0;
	if B then sivh=1; else sivh=0;
	if C then tx_plt=1; else tx_plt=0;
		
	
	day1=StudyLeftDate-lbwidob; if ivh then day1=imagedate-LBWIDOB;
	day2=day1;	if sivh then day2=sivh_date-LBWIDOB;
	
	if ivh then do;
	if imageDate<=hbdate then hb=.;
	if imageDate<=pltdate then platelet=.;
	end;
	
	keep 	id Gender LBWIDOB GestAge BirthWeight birthresus BirthResusOxygen BirthResusCPAP StudyLeftDate day1 day2 
	        SNAPTotalScore Platelet tx_plt dt_plt nplt	IVHDiagDate ImageDate LeftIVHGrade RightIVHGrade ivh sivh sivh_date 
	        Indomethacin Apgar5Min Hypertension DeliveryMode IsChorloConfirm;
			
run;

proc univariate data=lbwi;
var Platelet;
output out=one Q1=Q1 median=Q2 Q3=Q3;
run;

data _null_;
    set one;
    call symput("Q1", put(Q1,4.1));
	call symput("Q2", put(Q2,4.1));
	call symput("Q3", put(Q3,4.1));
run;

proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value wc  0="Low"  1="Very Low(1000-1500g)" 2="Extremely Low(<1000g)" ;
	value ny 0="No" 1="Yes";

	value gplt   1="Platelet Count<=Q1(&Q1 mu L)" 2="Platelet Count in Q1~Q2(&Q2 mu L)" 3="Platelet Count in Q2~Q3(&Q3 mu L)" 4="Platelet Count>Q3(&Q3 mu L)";

	value tbc    1="Platelet Count<150 *1000/&mu L" 0="Platelet Count>=150 *1000/&mu L";
	value ttbc   0="Normal(>=150*1000/&mu L)" 1="Mild(100-149*1000/&mu L)" 2="Moderate(50-99*1000/&mu L)" 3="Severe(30-49*1000/&mu L)" 4="Very Severe(<30*1000/&mu L)";
    value dmode  1="Vaginal vertx" 2="Caesarean section" 3=" Vaginal breech" 4="Vaginal NOS" 99="missing"	;
	
run;

data lbwi;
    set lbwi;
    if 0<platelet<=&Q1 then gplt=1; else if &Q1<platelet<=&Q2 then gplt=2; 
    else if &Q2<platelet<=&Q3 then gplt=3; else if platelet^=. then gplt=4;
    if 0<Platelet<150 then tbc=1; else if platelet^=. then tbc=0;
	if 100<=Platelet<150 then ttbc=1; else if 50<=Platelet<100 then ttbc=2; else if 30<=Platelet<50 then ttbc=3; 
	else if 0<Platelet<30 then ttbc=4; else if platelet^=. then ttbc=0;
	
	if tx_plt then do; if nplt in(1,2) then idx_plt=1; else if nplt>2 then idx_plt=2; end; else idx_plt=0; 

	format tbc tbc. ttbc ttbc. gplt gplt. ivh ivh. DeliveryMode dmode. Hypertension ny.;
run;

%let varlist=gplt tbc ttbc tx_plt idx_plt Hypertension IsChorloConfirm DeliveryMode birthresus BirthResusOxygen BirthResusCPAP;
%tab(lbwi,Indomethacin,tab,&varlist);

proc print;run;

/*
proc phreg data=lbwi(where=(ivh=1));
    class  Indomethacin;
	model day1*ivh(0)=platelet Indomethacin/rl;
	ods output Phreg.ParameterEstimates=cox1;
run;

proc phreg data=lbwi(where=(ivh=1));
	model day1*ivh(0)=snaptotalscore GestAge/rl;
	ods output Phreg.ParameterEstimates=cox2;
	hazardratio 'A' snaptotalscore / units=5 cl=both;
run;


proc phreg data=lbwi(where=(sivh=1));
    class  Indomethacin;
	model day2*sivh(0)=platelet Indomethacin/rl;
	ods output Phreg.ParameterEstimates=cox1;
run;

proc phreg data=lbwi(where=(sivh=1));
	model day2*sivh(0)=snaptotalscore GestAge/rl;
	ods output Phreg.ParameterEstimates=cox2;
	hazardratio 'A' snaptotalscore / units=5 cl=both;
run;


proc freq data=lbwi(where=(sivh=1)); 
tables (gplt tbc ttbc tx_plt idx_plt Hypertension IsChorloConfirm DeliveryMode BirthResusOxygen BirthResusCPAP)*Indomethacin/fisher;
run;

proc freq data=lbwi(where=(ivh=1)); 
tables (gplt tbc ttbc tx_plt idx_plt Hypertension IsChorloConfirm DeliveryMode BirthResusOxygen BirthResusCPAP)*Indomethacin/fisher;
run;

proc npar1way data=lbwi(where=(sivh=1)) wilcoxon; 
    class Indomethacin;
    var GestAge BirthWeight snaptotalscore Apgar5Min;
run;

proc npar1way data=lbwi(where=(ivh=1)) wilcoxon; 
    class Indomethacin;
    var GestAge BirthWeight snaptotalscore Apgar5Min;
run;
*/
