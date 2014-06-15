options nodate nonumber;
%include "macro.sas";

%let mu=%sysfunc(byte(181));
%let pm=%sysfunc(byte(177));

proc format; 
   value grade 1="I" 2="II" 3="III" 4="IV" 0="NA";
   value birth 1="Singleton" 2="Twin" 3="Triplet";
   value yn 0="No" 1="Yes";
   value ntx 0="No Tx" 1="1-2 Tx" 2=">2 Tx";
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

proc means data=ivh max;
	class id; 
	var LeftIVHGrade RightIVHGrade;
	ods output means.summary=ivh_max;
run;

data ivh_grade;
    set ivh_max;
    grade=max(LeftIVHGrade_max, rightIVHGrade_max);
    keep id LeftIVHGrade_max rightIVHGrade_max grade;
run;


proc sort data=cmv.plate_033(keep=id  DateTransfusion plt_TxStartTime) out=tx_plt;by id DateTransfusion plt_TxStartTime; run;

data tx_plt;
    merge tx_plt(in=A) ivh_id(keep=id imagedate in=B); by id;
    if A and B then if 0<DateTransfusion<=imagedate;
    drop imagedate;
    if A;
run;

/*
data tx_ivh;
    merge tx_plt(in=A) ivh_id(keep=id imagedate in=B); by id;
    if A and B then if 0<DateTransfusion<=imagedate;
    if B then ivh=1; else ivh=0;
    if ivh=1 and A;
run;
proc sort nodupkey; by id; run;
proc print;run;
*/

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


data indom;
    merge cmv.med cmv.plate_005(keep=id LBWIDOB); by id;
    if medcode=14 and StartDate-LBWIDOB<=1; 
    keep id;
run;

proc sort nodupkey; by id;run;

/*
data ivh_indom;
    merge indom(in=A) cmv.plate_068(keep=id Indomethacin) ivh_grade(keep=id grade); by id;
    if A or indomethacin then indo=1; else indo=0;
run;

%let n1=0;
%let n2=0;
%let n3=0;
%let n4=0;
%let n=0;

%table(ivh_indom, indo_tab, indo, grade); quit;

proc format;
	value ny 0="No" 1="Yes";
run;


ods rtf file="indo_tab.rtf" style=journal bodytitle;
proc print data=indo_tab noobs label split="*" style(header) = [just=center];
title "Table1: Indomethacin by IVH grade";
Var indo /style(data)=[cellwidth=1.5in just=left];
var c1-c4 c /style(data) = [cellwidth=0.8in just=center] ;
format indo ny.;
label  indo="Indomethacin"
       c1="Grade I*(n=&n1)"   
       c2="Grade II*(n=&n2)"
       c3="Grade III*(n=&n3)"
       c4="Grade IV*(n=&n4)"
       c="Total*(n=&n)";
run;

ods rtf close;
*/


data lbwi;
	merge 
	
	cmv.plate_005(keep=id LBWIDOB race Gender)
	cmv.plate_006
	cmv.plate_008
	cmv.plate_009(keep=id IsChorloConfirm HistoChloro)
	cmv.plate_010(keep=id PO2Value  PCO2  FiO2)
	cmv.plate_012(keep=id SNAPTotalScore)
	/*cmv.plate_015(where=(DFSEQ=1)keep=id DFSEQ BloodCollectDate Platelet PltDate)*/
	cmv.plate_068(keep=id IVHDiagDate Indomethacin  AntiConvulsant)
	first_hb first_plt
	ivh_id(in=A) 
	indom(in=tmp)
    ivh_grade(keep=id grade)
	tx_plt(in=C)
	
	cmv.plate_100(keep=id in=death1)
    cmv.plate_101(where=(deathdate^=.) keep=id deathdate in=death2)

    cmv.pda(keep=id in=pda_temp)
    cmv.enrolled
	cmv.endofstudy(keep=id StudyLeftDate)
	cmv.completedstudylist(in=comp);
		
	by id;
	
	if comp;
	if pda_temp then pda=1; else pda=0;
	if death1 or death2 then death=1; else death=0;
	if A then ivh=1; else ivh=0;
	if C then plt=1; else plt=0;
	if C then do; if nplt in(1,2) then idx_plt=1; else if nplt>2 then idx_plt=2; end; else idx_plt=0; 
	if tmp or Indomethacin then Indomethacin=1; else Indomethacin=0;
	
	if ivh then do;
	if pltdate>imageDate then platelet=.;
	end;
	format idx_plt ntx.;
	
	keep 	id Gender LBWIDOB GestAge BirthWeight birthresus BirthResusOxygen BirthResusCPAP StudyLeftDate day Steroids
	        SNAPTotalScore Platelet plt idx_plt dt_plt nplt	IVHDiagDate ImageDate LeftIVHGrade RightIVHGrade ivh  
	        Indomethacin Apgar5Min Hypertension DeliveryMode IsChorloConfirm grade Fio2 ismultiple death pda race;
			
run;


data test;
    set lbwi;
    if ivh=1;
run;

proc print;
where ivh=1;
var id ivh plt nplt idx_plt dt_plt imagedate;
run;

proc freq;
title "xxx";
table grade*idx_plt;
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
	
	value ntx   0="tx=0" 1="tx=1-2" 2="tx>=3";

	value gplt   1="Platelet Count<=Q1(&Q1 &mu.L)" 2="Platelet Count in Q1~Q2(&Q2 &mu.L)" 3="Platelet Count in Q2~Q3(&Q3 &mu.L)" 4="Platelet Count>Q3(&Q3 &mu.L)";

	value tbc    1="Platelet Count<150 *1000/&mu.L" 0="Platelet Count>=150 *1000/&mu.L";
	value ttbc   0="Normal(>=150*1000/&mu.L)" 1="Mild(100-149*1000/&mu.L)" 2="Moderate(50-99*1000/&mu.L)" 3="Severe(30-49*1000/&mu.L)" 4="Very Severe(<30*1000/&mu.L)";
    value dmode  1="Vaginal vertex" 2="Caesarean section" 3="Vaginal breech" 4="Vaginal NOS" 99="missing"	;
    
    value item
          1="Gender"
          2="Race"
          3="Multiple Birth"
          4="Death"
          5="PDA"
          6="Platelet Count at Birth(*1000/&mu.L), Mean &pm SD (N)"
          7="Platelet Count at Birth by Quartile"
          8="Thrombocytopenia at Birth*"
	      9="Thrombocytopenia at Birth"
	      10="Platelet Transfusion"
	      11="Platelet Transfusion by Number"
	      12="Hypertension existed prior to pregnancy?"
	      13="Chorioamnionitis"
	      14="Mode of Delivery"
	      15="Gestational Age(week), Mean &pm SD (N)"
	      16="Birthweight(g), Mean &pm SD (N)"
	      17="SNAP score, Mean &pm SD (N)"
	      18="APGAR at 5 min, Mean &pm SD (N)"
          19="FiO2 at Birth, Mean &pm SD (N)"
	      20="Delivery room resuscitation"
    	  21="Birth resuscitation/stabilization with Oxygen"
	      22="Birth resuscitation/stabilization with CPAP"
	      23="Prophylactic indomethacin"
	      24="Steroids given to accelerate maturity?"
	      ; 
	      
	 value group 1="Platelet + Indomethacin" 2="SNAP + Gestional Age";
	 value grade 1="I" 2="II" 3="III" 4="IV";
	
run;

data lbwi;
    set lbwi;
    if 0<platelet<=&Q1 then gplt=1; else if &Q1<platelet<=&Q2 then gplt=2; 
    else if &Q2<platelet<=&Q3 then gplt=3; else if platelet^=. then gplt=4;
    if 0<Platelet<150 then tbc=1; else if platelet^=. then tbc=0;
	if 100<=Platelet<150 then ttbc=1; else if 50<=Platelet<100 then ttbc=2; else if 30<=Platelet<50 then ttbc=3; 
	else if 0<Platelet<30 then ttbc=4; else if platelet^=. then ttbc=0;
	
    if BirthResusCPAP=99 then BirthResusCPAP=.; 
    if birthresus=99 then birthresus=.; 

	format tbc tbc. ttbc ttbc. gplt gplt. ivh ivh. DeliveryMode dmode. Hypertension ny.;
run;


*ods trace on/label listing;
proc freq data=lbwi; 
	table ivh;
	ods output onewayfreqs=wbh;
run;
*ods trace off;

data _null_;
	set wbh;
	if Ivh=0 then call symput("n0", compress(frequency));
	if Ivh=1 then call symput("n1", compress(frequency));
run;

%let n=%eval(&n0+&n1);

%let varlist=Platelet GestAge BirthWeight snaptotalscore Apgar5Min fio2;
%stat(lbwi,ivh,&varlist);


%let varlist=gender race ismultiple death pda gplt tbc ttbc plt idx_plt Hypertension IsChorloConfirm DeliveryMode birthresus BirthResusOxygen BirthResusCPAP Indomethacin Steroids;
%tab(lbwi,ivh,tab,&varlist);

data tab;   
	length code0 $100;
    set tab; by item code;
        if item=1 then  do; code0=put(code, gender.); end;
        if item=2 then  do; code0=put(code, race.); end;
        if item=3 then  do; code0=put(code, birth.); end;
        if item in(4,5) then  do; code0=put(code, yn.); end;
            
		if item=6 then  do; code0=put(code, gplt.); end;
		if item=7 then  do; code0=put(code, tbc.); end;
		if item=8 then  do; code0=put(code, ttbc.); end;
		if item=9 then  do; code0=put(code, ny.); end;

	
		if item=10 then  do; code0=put(code, ntx.); end;
		if item=11 then  do; code0=put(code, ny.); end;
		if item=12 then  do; code0=put(code, ny.); end;
		if item=13 then  do; code0=put(code, dmode.); end;
		
		if item in(14 15 16 17 18) then  do; code0=put(code, ny.); end;

		*format item item.;
run;

data tab_ivh;
	length nfn nfy nft code0 $40;
    set tab(where=(item<=5) in=A)
        stat(where=(item=1) in=B keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft)) 
        tab(where=(5<item<=13) in=C)
        stat(where=(item>1) in=D keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
        tab(where=(item>13) in=E); 
        by item;
        
        if B then item=item+5;
        if C then item=item+1;
        if D then item=item+13;
        if E then item=item+6;
        
        format item item.;
        *if item=3 then delete;
run;



ods rtf file="tab_ivh_nonivh.rtf" style=journal bodytitle ;
proc report data=tab_ivh nowindows style(column)=[just=center] split="*";
title "Approach #2: Comparisons between IVH and Non-IVH";
where item<11;
column item code0 nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." style=[just=left];
define nfy/"IVH*(n=&n1)";
define nfn/"Non-IVH*(n=&n0)";
define pv/"p value" group;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
* Thrombocytopenia was defined by Lindern et al. as a platelet count  below 150 x 10^{super 9}/L : BMC Pediatrics 2011,11:16.
^n
** Only included data prior to IVH diagnosis for LBWIs with IVH.";

proc report data=tab_ivh nowindows style(column)=[just=center] split="*";
title "Approach #2: Comparisons between IVH and Non-IVH";
where item>=11;
column item code0 nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." style=[just=left];
define nfy/"IVH*(n=&n1)";
define nfn/"Non-IVH*(n=&n0)";
define pv/"p value" group;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
* Thrombocytopenia was defined by Lindern et al. as a platelet count  below 150 x 10^{super 9}/L : BMC Pediatrics 2011,11:16.
^n
** Only included data prior to IVH diagnosis for LBWIs with IVH.";
ods rtf close;









