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
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
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
		keep id hb hbdate;
run;


data plt;
	set cmv.plate_033;
    keep id DateTransfusion plateletnum DatePlateletCount;
	rename DatePlateletCount=pltdate DateTransfusion=dt plateletnum=platelet;
run;

proc sort nodupkey; by id dt; run;

data plt;
	set cmv.plate_015(keep=id platelet pltdate BloodCollectDate in=A) plt(keep=id pltdate platelet); by id;
		if A and pltdate=. then pltdate=BloodCollectDate;
		if platelet^=.;
		keep id platelet pltdate;
run;

data lbwi;
	merge 
	cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	cmv.plate_006
	cmv.plate_009(keep=id IsChorloConfirm HistoChloro)	
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_068(keep=id Indomethacin  AntiConvulsant)
	indo(in=indoA) indom(in=indoB)
	ivh2 plt

    cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=comp);
	
	by id;
	
	if comp;
	if AntiConvulsant=. then AntiConvulsant=0;
	if ivh=. then ivh=0;

	day=StudyLeftDate-lbwidob;
	if ivh then day=Imagedate-LBWIDOB;
	

	if ivh then do;
	if imageDate<=hbdate then do; hb=.; hbdate=.; end;
	if imageDate<=pltdate then do; platelet=.; pltdate=.; end;
	end;
	
	center=floor(id/1000000);

    pday=pltdate-lbwidob;
		
	keep 
			id center Gender IsHispanic race LBWIDOB GestAge BirthWeight Platelet ivh ImageDate indo indom Indomethacin  
			AntiConvulsant pltdate pday day StudyLeftDate;				 
run;

proc transpose data=lbwi out=tplt;
by id;
var pday platelet; 
run;
proc print;run;


proc print;
var id lbwidob StudyLeftDate day ivh imagedate platelet pltdate pday;
run;

