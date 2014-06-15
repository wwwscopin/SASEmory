
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
run;


data rbc;
	set cmv.plate_031;
    keep id DateTransfusion Hb DateHbHct;
	rename DateHbHct=hbdate;
run;

proc sort nodupkey; by id DateTransfusion; run;

data hb;
	set cmv.plate_015 rbc(keep=id hbdate Hb); by id;
	if hbdate=. then hbdate=BloodCollectDate;
run;

proc sort nodupkey; by id hbdate;run;

data hwl;
        merge cmv.plate_005(keep=id LBWIDOB Gender IsHispanic race RaceOther)
	      cmv.plate_006(keep=id gestage) 
	      hb
	      cmv.completedstudylist(in=comp)
	; 
	by id;
	
	if comp;
	retain bw; 
	if DFSEQ=1 then bw=Weight;
	if DFSEQ=0 then delete;

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
	
	
	keep id DFSEQ Weight WeightDate HeadCircum HeadDate HtLength HeightDate LeftIVHGrade RightIVHGrade gender LBWIDOB race gestage bw;
	rename DFSEQ=day LBWIDOB=dob ;
run;

data tx;
	set cmv.plate_031(in=A keep=id Hb DateTransfusion rename=(DateTransfusion=date_rbc))
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

data tx_id;
    set tx; by id dt;
    if first.id;
    rename hb=hb0;
run;

data tx;
    set tx; by id;
    retain num;
    if first.id then do; num=0;end;
    num=num+1;
    idx=num;
    if num>3 then idx=4;
    
    retain dt1 dt2 dt3;
    if num=1 then do; dt1=dt; dt2=.; dt3=.; end;
        if num=2 then do; dt2=dt; dt3=.; end;
            if num=3 then dt3=dt;
    if dt=. then delete;
    if last.id;
     
    keep id dt dt1-dt3 num idx;
    format dt1-dt3 mmddyy9.;
run;

data anemia;
    merge cmv.plate_015 tx_id; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=9) or 0<hb0<=9;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data anemia8;
    merge cmv.plate_015 tx_id; by id;
    if HbDate=. then Hbdate=BloodCollectDate;
    if (hbdate<=dt and 0<hb<=8) or 0<hb0<=8;
   	keep id hb hb0;
   	if hb=. then delete;
run;

proc sort; by id hb;run;
proc sort nodupkey; by id; run;

data hwl hwl_base;
	merge hwl(in=hwl) tx(in=trans) cmv.endofstudy(keep=id studyleftdate) anemia(in=A keep=id) anemia8(in=B keep=id); by id;
	if trans then tx=1; else tx=0;
	if hwl;
	
	if A then anemic=1; else anemic=0;
	if B then anemic8=1; else anemic8=0;
	
	age1=dt1-dob; 
	age2=dt2-dob;
	age3=dt3-dob;
	
	left1=studyleftdate-dt1;
	left2=studyleftdate-dt2;
	left3=studyleftdate-dt3;
	
	if id=1008411 then left3=.;
	
	daytx=WeightDate-dt;
      
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
         
	if day=1 then output hwl_base;
	output hwl;
run;


data ttt1;
    set hwl;
    if weightdate<=dt1 then gw=0; else gw=1;
    if weight=. or dt1=. then delete;
run;

proc sort nodupkey; by id weightdate weight; run;
proc freq;table anemic*gw;run;


data ttt2;
    set hwl;
    if weightdate<=dt2 then gw=0; else gw=1;
    if weight=. or dt2=. then delete;
run;

proc sort nodupkey; by id weightdate weight; run;
proc freq;table anemic*gw;run;


proc freq data=hwl_base;
tables num*(anemic anemic8);
ods output crosstabfreqs=wbh;
run;

proc sort; by num; run;

proc format;
    value num 99="Total";

data anemia_tx;
    merge wbh(where=(anemic=0)   keep=anemic num frequency colpercent rename=(frequency=n0 colpercent=pct0))  
           wbh(where=(anemic=1)  keep=anemic num frequency colpercent rename=(frequency=n1 colpercent=pct1))  
           wbh(where=(anemic8=0) keep=anemic8 num frequency colpercent rename=(frequency=m0 colpercent=pt0))  
           wbh(where=(anemic8=1) keep=anemic8 num frequency colpercent rename=(frequency=m1 colpercent=pt1)) ; 
    by num;
    if num=. then num=99;
    ane90=n0||"("||put(pct0,3.0)||"%)";
        ane91=n1||"("||put(pct1,3.0)||"%)";
            ane80=m0||"("||put(pt0,3.0)||"%)";
                ane81=m1||"("||put(pt1,3.0)||"%)";
    if num=99 then do;  
        ane90=n0;
            ane91=n1;
                ane80=m0;
                    ane81=m1;    
    end;
    if n0=0 then ane90="-";
        if n1=0 then ane91="-";
            if m0=0 then ane80="-";
                if m1=0 then ane81="-";
    format num num.;
run;

proc sort; by num;run;

*ods trace on/label listing;
proc means data=hwl_base n mean median min max;
    var age1-age3 left1-left3;
    ods output Means.Summary=tmp;
run;
*ods trace off;

%macro med(data, out, varlist);
data &out;
    if 1=1 then delete;
run;

%let i=1;
%let var=%scan(&varlist, &i);
%do %while (&var NE);
proc means data=&data n mean median min max;
    var &var;
    ods output Means.Summary=tmp(rename=(&var._n=n &var._median=med &var._min=min &var._max=max));
run;

data tmp;
    set tmp;
    item=&i;
    col=med||"["||compress(min)||"-"||compress(max)||"],"||compress(n);
run;

data &out;
    set &out tmp;
run;

%let i=%eval(&i+1);
%let var=%scan(&varlist, &i);
%end;
%mend med;

%let varlist=age1 age2 age3 left1 left2 left3;
%med(hwl_base,med, &varlist);

proc format;
value item  1="Age at 1st pRBC Transfusion"
            2="Age at 2nd pRBC Transfusion"
            3="Age at 3rd pRBC Transfusion"
            4="Days from 1st pRBC Transfusion to Discharge"
            5="Days from 2nd pRBC Transfusion to Discharge"
            6="Days from 3rd pRBC Transfusion to Discharge"
            ;
run;

ods rtf file="tx.rtf" style=journal bodytitle startpage=no ;
proc print noobs label ;
title "Table1: Age at Date of Transfusion and Time before Discharge";
var item/style=[just=left cellwidth=3in];
var col/style=[just=center cellwidth=2in];
label item="."
       col="Median[min-max],N"
       ;
       
       format item item.;
run;


proc print data=anemia_tx noobs label split='*';
title "Table2: Transfusion Number by Anemia Status";
var num/style=[just=left cellwidth=0.5in];
var ane90 ane91 ane80 ane81/style=[just=center cellwidth=1.6in];
label  num="# Tx"
       ane90="Not Anemic (Hb>9 g/dL)*n(%)"
       ane91="Anemic (Hb<=9 g/dL)*n(%)"
       ane80="Not Anemic (Hb>8 g/dL)*n(%)"
       ane81="Anemic (Hb<=8 g/dL)*n(%)"
       ;
run;
ods rtf close;
