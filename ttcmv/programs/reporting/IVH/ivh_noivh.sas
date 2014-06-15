options nodate nonumber;
%include "macro.sas";

%let mu=%sysfunc(byte(181));

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
run;

data ivh;
	merge cmv.plate_068(keep=id IVHDiagDate)
			cmv.ivh_image(keep=id ImageDate LeftIVHGrade RightIVHGrade)
			cmv.comp_pat(in=comp keep=id center);
	by id;
	
	if comp;
	retain x_date;
	if first.id then x_date=imagedate;
	if ivhdiagdate=. then ivhdiagdate=x_date;
	
	if LeftIVHGrade=99 then LeftIVHGrade=.;
	if rightIVHGrade=99 then rightIVHGrade=.;	
	
	if LeftIVHGrade in(2,3,4) or RightIVHGrade in(2,3,4);
run;  

proc sort; by id imagedate;run;

data ivh_id;
    set ivh; by id imagedate;
    if first.id;
run;


data rbc;
	set cmv.plate_031; 
    keep id DateTransfusion;
	rename DateTransfusion=dt_rbc;
run;

proc sort nodupkey; by id dt_rbc; run;

data rbc;
    set rbc; by id dt_rbc;
    if first.id;
run;

data platelet;
	set cmv.plate_033;
    keep id DateTransfusion ;
	rename DateTransfusion=dt_plt;
run;

proc sort nodupkey; by id dt_plt; run;

data platelet;
    merge platelet(in=A) ivh_id(keep=id imagedate in=B); by id;
    if A and B then if dt_plt<=imagedate;
    drop imagedate;
    if A;
run;

data platelet;
    set platelet; by id dt_plt;
    if first.id;
run;

proc format;
	value ivh 0="IVH=No" 1="IVH=Yes";
	value wc  0="Low"  1="Very Low(1000-1500g)" 2="Extremely Low(<1000g)" ;
	value ny 0="No" 1="Yes";
	
	value tbc    1="Platelet Count<150 *1000/&mu.L" 0="Platelet Count>=150 *1000/&mu.L";
	value ttbc   0="Normal(>=150*1000/&mu.L)" 1="Mild(100-149*1000/&mu.L)" 2="Moderate(50-99*1000/&mu.L)" 3="Severe(30-49*1000/&mu.L)" 4="Very Severe(<30*1000/&mu.L)";
   
    value item
    	  1="Birth Weight(g), Mean &pm sd(n)"
          2="Gestational Age(week), Mean &pm sd(n)"
	      3="SNAP score, Mean &pm sd(N)"
	      4="Hemoglobin at Birth(g/dL), Mean &pm sd(n)"
	      5="Platelet Count at Birth(*1000/&mu.L), Mean &pm sd(n)"
          6="Thrombocytopenia at Birth*"
	      7="Thrombocytopenia at Birth"
	      8= "pRBC Transfusion"
	      9= "Platelet Transfusion"
	      ; 
	 value ntx 0="No Tx" 1="1-2 Tx" 2=">2 Tx";
run;

data lbwi;
	merge 

	cmv.plate_005(keep=id LBWIDOB Gender)
	cmv.plate_006(keep=id gestage BirthWeight)
	cmv.plate_012(keep=id SNAPTotalScore)
	cmv.plate_015(keep=id dfseq hb Platelet where=(dfseq=1))
	ivh_id(in=A) 
	rbc(in=B) platelet(in=C)
	cmv.completedstudylist(in=comp);
	by id;
	
	if comp;
	if A then ivh=1; else ivh=0;
	if B then rbc=1; else rbc=0;
	if A and dt_rbc>=imagedate then rbc=0;
	
	if C then plt=1; else plt=0;
	
	if 0<Platelet<150 then tbc=1; else if platelet^=. then tbc=0;
	if 100<=Platelet<150 then ttbc=1; else if 50<=Platelet<100 then ttbc=2; else if 30<=Platelet<50 then ttbc=3; 
	else if 0<Platelet<30 then ttbc=4; else if Platelet^=. then ttbc=0; 
	
	keep 	id Gender LBWIDOB GestAge BirthWeight SNAPTotalScore Platelet plt hb rbc ImageDate ivh tbc ttbc;

	format tbc tbc. ttbc ttbc. ivh ivh. rbc plt ny.;		
run;

data _null_;
    set lbwi(where=(ivh=1));
    call symput ("n1", compress(_n_));
run;

data _null_;
    set lbwi(where=(ivh=0));
    call symput ("n0", compress(_n_));
run;

proc mixed data=lbwi;
    class id ivh; 
    model hb=ivh platelet ivh*platelet/s;
    *random id;
    *random int/subject=id;
    *repeated /type=un subject=id;
    repeated;

    estimate "Non-IVH, slope" platelet 1 ivh*platelet 1 0;
	estimate "IVH,     slope" platelet 1 ivh*platelet 0 1 ;
	estimate "Compare the slopes" ivh*platelet 1 -1 ;
	estimate "Compare the intercepts" ivh 1 -1 ;
run;

data tmp;
    set lbwi;
    if hb=. and platelet=. then delete;
run;

data _null_;
    set tmp(where=(ivh=1));
    call symput ("m1", compress(_n_));
run;

data _null_;
    set tmp(where=(ivh=0));
    call symput ("m0", compress(_n_));
run;

ods pdf file="hb_plt_scatter.pdf";
proc sgplot data=tmp noautolegend; 
    title "Initial Hemoglobin by Platelet Count for IVH(n=&m1, '+') and non-IVH(n=&m0, 'o') LBWIs";
    reg x=platelet y=hb/group=ivh;
    label platelet="Platelet Count(*1000/&mu.L)" ;
    yaxis label="Hemoglobin(g/dL)"  grid values=(8 to 24 by 2) offsetmin=0.01 offsetmax=0.01;
    keylegend/position=topright across=1 location=inside;
run;
ods pdf close;


%let varlist=BirthWeight GestAge snaptotalscore hb Platelet;
%stat(lbwi,ivh,&varlist);


%let varlist=tbc ttbc rbc plt;
%tab(lbwi,ivh,tab,&varlist);

data tab;   
	length code0 $100;
    set tab; by item code;
		if item=1 then  do; code0=put(code, tbc.); end;
		if item=2 then  do; code0=put(code, ttbc.); end;
		if item in (3,4) then  do; code0=put(code, ny.); end;
run;

data tab_ivh;
	length nfn nfy nft code0 $40;
    set stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft)) 
        tab(in=B);
        by item;
        
        if B then item=item+5;
        format item item.;
run;


ods rtf file="ivh_noivh.rtf" style=journal bodytitle ;
proc report data=tab_ivh nowindows style(column)=[just=center] split="*";
title "Comparison between IVH or non-IVH";
column item code0 nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." style=[just=left];
define nfy/"IVH >=grade II*(n=&n1)" style=[width=1.25in];
define nfn/"Non-IVH*(n=&n0)";
define pv/"p value" group;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
* Thrombocytopenia was defined by Lindern et al. as a platelet count  below 150 x 10^{super 9}/L : BMC Pediatrics 2011,11:16.
^n
** Only included data prior to IVH diagnosis for LBWIs with IVH.";
ods rtf close;
