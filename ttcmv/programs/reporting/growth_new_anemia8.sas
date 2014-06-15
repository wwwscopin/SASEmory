
options orientation=portrait nodate nofmterr nonumber;
libname wbh "/ttcmv/sas/data";	
libname gcx "/ttcmv/sas/programs";	

%let pm=%sysfunc(byte(177)); 
%let jing=%sysfunc(byte(35)); 
%let dollar=%sysfunc(byte(36)); 
%let link=%sysfunc(byte(38)); 
%let csign=%sysfunc(byte(162)); 
%let circ=%sysfunc(byte(164)); 
%let ds=%sysfunc(byte(167)); 
%let sign=%sysfunc(byte(182)); 
%let rsign=%sysfunc(byte(174)); 
%let blank=   ;

proc format;
    value group 1="SGA"  2="AGA"  3="LGA";
	value gw 1="<=750" 2="751-1000" 3="1001-1250" 4="1251-1500" 9="";
	value yn 1="Yes" 0="No";
	value tx 0="No Tx" 1="Before Tx" 2="After Tx";
	value feed 1="Bottle Feeding" 0="Breast Feeding";
	value item 
        0="Number"
        1="Gestational age (wk)*"
        2="Age at 1st pRBC Tx (day)"
        3="SNAP score@"
        4="Male"
		5="White"
		6="SGA&circ"
		7="Survival"
		8="BPD"
		9="Sepsis&ds"
		10="Severe IVH&sign"
		11="NEC"
		12="Surgical PDA&link"
		13="ROP&rsign"
		14="Hemoglobin at Birth (g/dL)"
    	15="Hemoglobin at TX (g/dL)"
		16="Ever pRBC Transfused "
		17="Always Formula Fed"
	;
	
	value ref 
        0="Patient Number(%)"
        1="Gestational age(wk)$"
        2="SNAP score$"
        3="Male"
		4="White"
        5="#pRBC Transfusions"
        6="- 1"
                7="- 2"
                        8="- 3"
                                9="- >3";
 	;
run;


data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate;
run;

proc sort nodupkey; by id DateTransfusion; run;

data rbc_tx;
	set rbc; by id DateTransfusion;
	if first.id;
run;

data hb;
	set cmv.plate_015(rename=(dfseq=day)) rbc(keep=id hbdate Hb); by id;
run;

proc sort; by id hbdate;run;

data tx;
	set cmv.plate_031(in=A keep=id hb DateTransfusion rename=(DateTransfusion=date_rbc))
			cmv.plate_033(in=B keep=id DateTransfusion rename=(DateTransfusion=date_plt))
			cmv.plate_035(in=C keep=id DateTransfusion rename=(DateTransfusion=date_ffp))
			cmv.plate_037(in=D keep=id DateTransfusion rename=(DateTransfusion=date_cyro));
			/*cmv.plate_039(in=E keep=id DateTransfusion rename=(DateTransfusion=date_granulocyte))*/

	if A then do; tx_RBC=1; dt=date_rbc; end; else tx_RBC=0; 
	/*if B then do; tx_platelet=1; dt=date_plt; end; else tx_platelet=0; 
	if C then do; tx_FFP=1; dt=date_ffp; end; else tx_FFP=0;
	if D then do; tx_Cyro=1; dt=date_cyro; end; else tx_Cyro=0; 
	if E then do; tx_Granulocyte=1; dt=date_granulocyte; end; else tx_Granulocyte=0; */
	
    if dt=. then delete;
	format tx_RBC tx_Platelet tx_FFP tx_Cyro tx_Granulocyte tx. dt mmddyy9.;
run;

proc sort nodupkey; by id dt; run;

data tx_num;
    set tx; by id;
    retain num;
    if first.id then num=0;
    num=num+1;
    idx=num;
    if num>3 then idx=4;
    if last.id;
    keep id num idx;
run;

proc sort data=tx nodupkey; by id dt; run;

data tx;
    merge tx tx_num; by id;
    if first.id;
    rename hb=hb0;
run;

proc sort data=cmv.nec_p1; by id necdate;run;
data nec; set cmv.nec_p1; by id necdate; if first.id;run;

proc sort data=cmv.ivh_image(where=(LeftIVHGrade in(3,4) or RightIVHGrade in(3,4)) keep=id imagedate LeftIVHGrade RightIVHGrade) out=ivh; by id imagedate;run;
data ivh; set ivh; by id imagedate; if first.id; run;

proc sort data=cmv.pda(where=(PDASurgery=1) keep=id PDADiagDate PDASurgery) out=pda; by id PDADiagDate;run;
data pda; set pda; by id pdadiagdate; if first.id; run;

proc sort data=cmv.plate_078(where=(LeftRetinopathyStage>2 or RightRetinopathyStage>2) keep=id ROPExamDate LeftRetinopathyStage RightRetinopathyStage) out=rop; by id ROPExamDate;run;
data rop; set rop; by id ropexamdate; if first.id; run;

data hwl0;
        merge cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	      cmv.plate_006(keep=id gestage) 
	      cmv.plate_008(keep=id MultipleBirth)
	      hb
	      cmv.plate_012(keep=id SNAPTotalScore rename=(SNAPTotalScore=snap))
	      cmv.bpd(where=(IsOxygenDOL28=1) keep=id IsOxygenDOL28 in=A)
	      cmv.infect(where=(CulturePositive=1) keep=id culturedate CulturePositive in=B)
	      ivh(in=C)
	      nec(keep=id necdate in=D)
	      pda(in=P)
   	      rop(in=R)
          wbh.feed(where=(gp=4) keep=id gp in=E)
          tx 
          wbh.death(keep=id deathdate in=dead)
	; 
	by id;
	
	retain bw; 
	if day=1 then bw=Weight;
	if day=0 then delete;
	*if 501<bw<=750 then gw=1;
	if bw<=750 then gw=1;
	if 750<bw<=1000 then gw=2;
	if 1000<bw<=1250 then gw=3;
	if 1250<bw<=1500 then gw=4;
	
		age=dt-lbwidob;
	
	if dead and deathdate<=dt then death=1; else death=0;

	if A then bpd=1; else bpd=0;
	if B and culturedate<=dt then sepsis=1; else sepsis=0;
	if C and imagedate<=dt then ivh=1; else ivh=0;
	if D and necdate<=dt then nec=1; else nec=0;
	if E then feed=1; else feed=0;
	if P and PDADiagDate<=dt then pda=1; else pda=0;
	if R and ROPExamDate<=dt then ROP=1; else rop=0;

	if WeightDate=. then WeightDate=AnthroMeasureDate;
	if HeadDate=. then HeadDate=AnthroMeasureDate;
	if HeightDate=. then HeightDate=AnthroMeasureDate;
	
	if id=2002711 and dfseq=28 then weight=.;
		if id=3023511 and dfseq=21 then weight=.;
			if id=1003511 and dfseq=40 then HtLength=.;
						if id=1009211 and dfseq=21 then HtLength=.;
									if id=2005111 and dfseq=28 then HtLength=.;
												if id=2007911 and dfseq=14 then HtLength=.;
															if id=2008511 and dfseq in(4,7) then HtLength=.;
	if id=1000311 and dfseq=21 then HeadCircum=.;
	if id=1003511 and dfseq=40 then HeadCircum=.;
	if id=1009211 and dfseq=21 then HeadCircum=.;
	if id=2002411 and dfseq=28 then HeadCircum=.;
	if id=2002711 and dfseq=4 then HeadCircum=.;
	if id=2002811 and dfseq=14 then HeadCircum=.;
	if id=2005111 and dfseq in(4,7) then HeadCircum=.;
	if id=2005311 and dfseq=14 then HeadCircum=.;
	if id=2008011 and dfseq=21 then HeadCircum=.;
	if id=3010921 and dfseq=21 then HeadCircum=.;
	if id=3012511 and dfseq=40 then HeadCircum=.;
	if id=3018511 and dfseq=40 then HeadCircum=.;
	
	
	keep id day Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade 
	MultipleBirth gender LBWIDOB race gestage bw gw bpd sepsis ivh nec feed snap pda rop hb death age;
	rename LBWIDOB=dob ;
	*if not MultipleBirth and gender=1;
run;

proc sql;
	create table hwl1 as 
	select a.*
	from hwl0 as a, cmv.completedstudylist as b
	where a.id=b.id
	;

proc sql;
create table hwl as 
select a.* , b.* 
from hwl1 as a 
inner join cmv.olsen as b
on a.gender=b.gender and a.gestage=b.gestage;

data hwl;
	set hwl; 
	if bw<weight_tenth then group=1;
	if weight_tenth<=bw<=weight_ninetieth then group=2;
	if bw>weight_ninetieth then group=3;
	if group=2 and bpd=0 and sepsis=0 and ivh=0 and nec=0 and pda=0 and rop=0 then ref=1; else ref=0; 
run;

data anemia;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=9) or 0<hb0<=9;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data hb_anemia;
    merge rbc anemia(keep=id in=A) cmv.comp_pat(keep=id in=comp); by id;
    if comp;
    if A then anemic=1; else anemic=0;
    if first.id;
run;

data anemia8;
    merge cmv.plate_015 tx; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=8) or 0<hb0<=8;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data anemia_tx;
    merge tx anemia(keep=id in=A) anemia8(keep=id in=B) cmv.comp_pat(in=comp); by id;
    if A then anemic=1; else anemic=0;
        if B then anemic8=1; else anemic8=0;
        if comp;
run;

proc freq data=anemia_tx;
tables anemic*idx;
tables anemic8*idx;
run;


data hb_anemia8;
    merge rbc anemia8(keep=id in=A) cmv.comp_pat(keep=id in=comp); by id;
    if comp;
    if A then anemic8=1; else anemic8=0;
    if first.id;
run;

data hwl hwl_base;
	merge hwl(in=hwl) tx(in=trans keep=id dt idx) anemia(keep=id in=ane) anemia8(keep=id in=A); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	if A then anemic8=1; else anemic8=0;
	if ane then anemic=1; else anemic=0;
	
	daytx=WeightDate-dt;
	
    gtx=tx;

	format gw gw. group group. feed feed. death bpd sepsis ivh nec yn. tx tx.;
        
        if day=1  then t=1;
        if day=4  then t=2;
        if day=7  then t=3;
        if day=14 then t=4;
        if day=21 then t=5;
        if day=28 then t=6;
        if day=40 then t=7;
        if day=60 then t=8;
        
        st1=min(day,7);
        st2=max(0,day-7);
        
    wk=day/7;    
	if day=1 then output hwl_base;
	output hwl;
run;


proc means  data=hwl_base(where=(tx=1));
class anemic;
var age;
run;

proc means  data=hwl_base(where=(tx=1));
class anemic8;
var age;
run;

proc print ;
where dt^=.;
var id dob dt age anemic anemic8;
run;

data hwl;
    set hwl(where=(tx=0) in=A) hwl(where=(daytx<0 and daytx^=.) in=B) hwl(where=(daytx>=0) in=C);
    if A then tx=0;
    if B then tx=1; 
    if C then tx=2;
run;

proc freq data=hwl_base; tables ref*idx;run;
proc sort data=hwl_base(where=(tx^=0)) nodupkey; by id gw group death bpd sepsis ivh nec;run;
proc freq data=hwl_base; tables ref*gw;run;

data _null_;
	set hwl_base;
	call symput("n", compress(_n_));
run;
%put &n;

proc freq data=hwl_base;
table tx;
ods output onewayfreqs=tmp;
run;

data _null_;
	set tmp;
    if tx=0 then call symput("t0", compress(frequency));
        if tx=1 then call symput("t1", compress(frequency));
run;

*******************************************************************************;
%macro tab(data, out, varlist);

	data &out;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	%if &var=death %then %let idx=0;
	%else %if &var=race %then %let idx=3;
	%else %let idx=1;

	proc freq data=&data;
		tables &var*anemic8;
		ods output Freq.Table1.CrossTabFreqs=tmp;
	run;
	
	data tmp;      
	       set tmp;
	       where &var=&idx and anemic8^=.;
	       nf=compress(frequency||"("||put(colpercent,5.1)||"%)");
	       keep &var anemic8 frequency nf colpercent;
	run;
	
	proc transpose data=tmp out=tab0&i; var nf; run;

	data tab&i;
		set tab0&i;
		item=%eval(&i);
		keep item col1-col2;
		rename col1=anemic0 col2=anemic1;
	run; 

	data &out;
		set &out tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;

%mend tab;

*ods trace off;
%let varlist=gender race group death bpd sepsis ivh nec pda rop gtx feed;
%tab(hwl_base, tab, &varlist);


%macro num(data, out, varlist);

	data &out;
		if 1=1 then delete;
	run;

%let i=1;
%let var=%scan(&varlist, &i);

%do %while(&var NE );

proc means data=&data;
	class anemic8;
	var &var;
	ods output means.summary=tmp(keep=gw NObs &var._mean &var._StdDev);
run;

data tab0;
	set tmp;
	&var=compress(put(&var._mean,4.1)||"&pm"||put(&var._stddev,4.1));
	keep anemic8 nobs &var;
run;

proc transpose data=tab0 out=tab1; var nobs &var; run;

data gnum&i;
	set tab1;
	rename col1=anemic0 col2=anemic1;
	
	%if &var=gestage %then %do;	if lowcase(_name_)='nobs' then item=0; %end;    
    %else %do;	if lowcase(_name_)='nobs' then delete;  %end;      

   	if lowcase(_name_)="&var" then item=&i;              
   	keep item col1-col4;
run;

    data &out;
		set &out gnum&i;
	run; 
	
	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
    %end;
%mend num;

%let varlist=gestage age snap hb;
%num(hwl_base, anemia, &varlist);
%let varlist=hb;
%num(hb_anemia8, hb8, &varlist);

data _null_;
    set anemia(where=(item=0));
    call symput("n0", compress(anemic0)); 
    call symput("n1", compress(anemic1)); 
run;

%let m=%eval(&n0+&n1);

proc format;
	value anemic 0="Not Anemic(n=&n0)" 1="Anemic(n=&n1)";
run;

data tab1;
    length anemic0-anemic1 $10;
	set anemia(where=(item<=3)) tab(where=(item<=10) in=A) anemia(where=(item=4) in=B) hb8(in=C) tab(where=(item>10) in=D);
	if A then item=item+3;
	if B then item=item+10;
	if C then item=item+14;
	if D then item=item+5;
	format item item.;
run;

ods rtf file="anemia8.rtf" style=journal bodytitle;
proc report nowindows headline spacing=1 split='*' style(column)=[just=center] style(header)=[just=center];
title "Infant Characteristics by Anemia Status Before 1st pRBC Transfusion";

column item anemic0 -anemic1;

define item/"." style=[just=left cellwidth=2in];
define anemic0/"Not Anemic (Hb>8 g/dL)"     style(column)=[cellwidth=2in];
define anemic1/"Anemic (Hb<=8 g/dL)"  style(column)=[cellwidth=2in];
*break after item/ dol dul skip;
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=10 pt}
1. Anemic: Hemoglobin <=8 g/dL before 1st pRBC transfusion.
^n 2. Abbreviation: SGA, small-for-gestational age; IVH, intraventricular hemorrhage; NEC, nectrotizing enterocolitis.
^n 3. Sepsis/IVH/NEC/PDA/ROP was counted only before the 1st pRBC transfusion.
^n * Mean &pm SD.
^n @ SNAP score at birth.
^n &circ Birth weight<10^{super th} percentile according to Olsen et al.(Pediatrics 2010,125:e214-e224).
^n &ds Sepsis: Positive blood culture.
^n &sign Grade 3-4 IVH.
^n &link Surgical PDA
^n &rsign Stage 3-5 ROP.
";

ods rtf close;
