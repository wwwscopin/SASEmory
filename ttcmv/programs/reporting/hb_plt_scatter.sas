options ORIENTATION="LANDSCAPE" nonumber nodate;
libname wbh "/ttcmv/sas/porgrams";	
%let mu=%sysfunc(byte(181));

proc format;
		value tc 0="Not Thrombocytopenia" 1="Thrombocytopenia";
		value tx 
		0="No"
		1="Yes"
		;


		value dd -1=" " 2=" " 3=" " 4=" " 5=" " 6=" " 8=" " 9=" " 10=" " 11=" " 12=" " 13=" " 15=" " 16=" " 17=" " 18=" " 19=" " 20=" "
		22=" " 23=" " 24=" " 25=" " 26=" " 27=" " 29=" " 30=" " 31=" " 32=" " 33=" " 34=" " 35=" " 36=" " 37=" " 38=" " 39=" " 41=" "
		42=" " 43=" " 44=" " 45=" " 46=" " 47=" " 48=" " 49=" " 50=" " 51=" " 52=" " 53=" " 54=" " 55=" " 56=" " 57=" " 58=" " 59=" "
		61=" " 0="0" 1="1" 7="7" 14="14" 21="21" 28="28" 40="40" 60="60"
		;
run;


data hb0;
	set cmv.plate_015 
		 cmv.plate_031(keep=id hb /*DFSEQ*/ DateHbHct rename=(DateHbHct=hbdate));
	
	if hb=. then delete;
	if hbdate=. then hbdate=BloodCollectDate;

	keep id hbDate hb;
run;

proc sort nodupkey; by id hbdate hb;run;

data plt0;
	set cmv.plate_015 
		 cmv.plate_033(keep=id PlateletCount DatePlateletCount rename=(DatePlateletCount=pltdate PlateletCount=platelet));
	
	if platelet=. then delete;
	if pltdate=. then pltdate=BloodCollectDate;
	if Platelet>150 then tc=0; else if Platelet^=. then tc=1;
	*rename dfseq=day;
	keep id pltDate platelet tc;
	format tc tc.;
run;

proc sort nodupkey; by id pltdate platelet;run;

**********************************************************************************************;
data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.completedstudylist(in=comp);
	by id;
	if comp;
	
	if LeftIVHGrade in(1,2,3,4) or RightIVHGrade in(1,2,3,4);
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in (2,3,4) then ivh=1; else ivh=0;
run;

proc sort; by id imagedate;run;

data ivh2;
    set ivh(where=(ivh=1)); by id imagedate;
    if first.id;
    keep id ivh imagedate;
run;


***********************************************************************************************;

data tx;
	set cmv.plate_031(keep=id  DateTransfusion rbc_TxStartTime in=A)
			cmv.plate_033(keep=id DateTransfusion plt_TxStartTime in=B)
			/*cmv.plate_035(keep=id DateTransfusion ffp_TxStartTime)
			cmv.plate_037(keep=id DateTransfusion cryo_TxStartTime)
			cmv.plate_039(keep=id )*/
		;
run;

proc sort; by id DateTransfusion; run;
data tx; 
    merge tx ivh2(in=temp); by id;
    if temp then if DateTransfusion<imagedate;
    keep id;
run;
proc sort nodupkey; by id; run;


data ivh;
	merge hb0 plt0 ivh2 tx(in=tmp) cmv.comp_pat(in=comp keep=id gender dob) cmv.plate_006(keep=id gestage); by id;
	if comp;
	day=hbdate-dob;

	if tmp then tx=1; else tx=0;
	if ivh=. then ivh=0;
	if hbdate>=imagedate and ivh then hb=.;	
	if pltdate>=imagedate and ivh then platelet=.;
    if hb=. and platelet=. then delete;
	format gender gender. imagedate mmddyy8.;
run;

ODS PDF FILE ="hb_plt_scatter.pdf";  
PROC sgplot DATA=ivh(where=(ivh=1));
title "Hemoglobin vs Platelet Count for IVH";

SCATTER X =hb Y =platelet / LEGENDLABEL = 'Emory: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=red);
xaxis label="Hemoglobin"  grid values=(0 to 40 by 2) offsetmin=0 offsetmax=0;
yaxis label="Platelet"    grid values=(0 to 1000 by 50) offsetmin=0.01 offsetmax=0;
RUN;

PROC sgplot DATA=ivh(where=(ivh=0));
title "Hemoglobin vs Platelet Count for non-IVH";

SCATTER X =hb Y =platelet / LEGENDLABEL = 'Emory: Non-NEC' MARKERATTRS=(size=8 SYMBOL=circle color=blue);
xaxis label="Hemoglobin"  grid values=(0 to 40 by 2) offsetmin=0 offsetmax=0;
yaxis label="Platelet"    grid values=(0 to 1000 by 50)offsetmin=0.01 offsetmax=0;
RUN;
ods pdf close;
