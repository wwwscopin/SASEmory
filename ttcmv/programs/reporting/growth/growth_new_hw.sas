
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
        2="SNAP score@"
        3="Male"
		4="White"
		5="SGA&circ"
		6="Survival"
		7="BPD"
		8="Sepsis&ds"
		9="Severe IVH&sign"
		10="NEC"
		11="Surgical PDA&link"
		12="ROP&rsign"
		13="Hemoglobin (g/dL)"
		14="Ever pRBC Transfused "
		15="Always Formula Fed"
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

data hwl0;
        merge cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	      cmv.plate_006(keep=id gestage) 
	      cmv.plate_008(keep=id MultipleBirth)
	      cmv.plate_015
	      cmv.plate_012(keep=id SNAPTotalScore rename=(SNAPTotalScore=snap))
	      cmv.bpd(where=(IsOxygenDOL28=1) keep=id IsOxygenDOL28 in=A)
	      cmv.infection_p1(where=(CulturePositive=1) keep=id CulturePositive in=B)
	      cmv.ivh_image(where=(LeftIVHGrade in(3,4) or RightIVHGrade in(3,4)) keep=id LeftIVHGrade RightIVHGrade in=C)
	      cmv.nec_p1(keep=id in=D)
	      cmv.pda(where=(PDASurgery=1) keep=id PDASurgery in=P)
   	      cmv.plate_078(where=(LeftRetinopathyStage>2 or RightRetinopathyStage>2) keep=id LeftRetinopathyStage RightRetinopathyStage in=R)
          wbh.feed(where=(gp=4) keep=id gp in=E)
	; 
	by id;
	
	retain bw; 
	if DFSEQ=1 then bw=Weight;
	if DFSEQ=0 then delete;
	*if 501<bw<=750 then gw=1;
	if bw<=750 then gw=1;
	if 750<bw<=1000 then gw=2;
	if 1000<bw<=1250 then gw=3;
	if 1250<bw<=1500 then gw=4;

	if A then bpd=1; else bpd=0;
	if B then sepsis=1; else sepsis=0;
	if C then ivh=1; else ivh=0;
	if D then nec=1; else nec=0;
	if E then feed=1; else feed=0;
	if P then pda=1; else pda=0;
	if R then ROP=1; else rop=0;

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
	
	
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade 
	MultipleBirth gender LBWIDOB race gestage bw gw bpd sepsis ivh nec feed snap pda rop hb;
	rename DFSEQ=day LBWIDOB=dob ;
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
	merge hwl(in=A) wbh.death(keep=id in=B); by id;
	if bw<weight_tenth then group=1;
	if weight_tenth<=bw<=weight_ninetieth then group=2;
	if bw>weight_ninetieth then group=3;
	if B then death=1; else death=0;
	if A;
	if group=2 and bpd=0 and sepsis=0 and ivh=0 and nec=0 and pda=0 and rop=0 then ref=1; else ref=0; 
run;

data tx;
	set cmv.plate_031(in=A keep=id DateTransfusion rename=(DateTransfusion=date_rbc))
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
    keep id tx num idx;
run;

proc sort data=tx nodupkey; by id dt; run;

data tx;
    merge tx tx_num; by id;
    if first.id;
run;

data hwl hwl_base;
	merge hwl(in=hwl) tx(in=trans keep=id dt idx); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	
	daytx=WeightDate-dt;
	
	day0=weightdate-dob;
	day1=HeadDate-dob;
	day2=HeightDate-dob;
	
	
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
        
        st1=min(day0,7);
        st2=max(0,day0-7);
        
    wk=day/7;    
	if day=1 then output hwl_base;
	output hwl;
run;

data hwl;
    set hwl(where=(tx=0) in=A) hwl(where=(daytx<0 and daytx^=.) in=B) hwl(where=(daytx>=0) in=C);
    if A then tx=0;
    if B then tx=1; 
    if C then tx=2;
run;

/*
proc print data=hwl;
id id; 
var weight weightdate day0 headdate headcircum day1 Heightdate Htlength day2;
run;
*/
*****************************************************;
proc mixed data=hwl /*method=ml*/ ORDER=internal;

        class id; 
        model weight=st1 st2/s chisq /*outp=pred*/;
       	random int st2/type=un subject=id s;

        ods output Mixed.SolutionF=slope;
        ods output Mixed.SolutionR=ind_slope;
run;

data _null_;
    set slope;
    if _n_=3 then call symput("swt", put(estimate,7.4));
run;

data cmv.wt_slope(where=(effect='st2'));
    set ind_slope;
run;

proc mixed data=hwl/*method=ml*/ ORDER=internal;

        class id; 
        model headcircum=day1/s chisq ;
       	random int day1/type=un subject=id s;
        ods output Mixed.SolutionF=slope;
        ods output Mixed.SolutionR=ind_slope;
run;

data _null_;
    set slope;
    if _n_=2 then call symput("shc", put(estimate,7.4));
run;

data cmv.hc_slope(where=(effect='day1'));
    set ind_slope;
run;

proc mixed data=hwl /*method=ml*/ ORDER=internal;

        class id; 
        model htlength=day2/s chisq;
       	random int day2/type=un subject=id s;
        ods output Mixed.SolutionF=slope;
        ods output Mixed.SolutionR=ind_slope;
run;

data _null_;
    set slope;
    if _n_=2 then call symput("shl", put(estimate,7.4));
run;

data cmv.hl_slope(where=(effect='day2'));
    set ind_slope;
run;

%put &shl;

data hwl;
    merge cmv.wt_slope(keep=id estimate rename=(estimate=wt0))
    cmv.hc_slope(keep=id estimate rename=(estimate=hc0))
    cmv.hl_slope(keep=id estimate rename=(estimate=hl0)); by id;
    wt=&swt+wt0;
    hc=(hc0+&shc)*7;
    hl=(hl0+&shl)*7;
run;
proc print;run;

proc corr data=hwl /*spearman*/;
var wt hc hl;
run;

symbol i=j repeat=200;
proc gplot data=hwl;
plot wt*hc=id/overlay; 
run;
