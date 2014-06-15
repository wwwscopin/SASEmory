
*****************************************************************;
*options minoperator;
****************************************************************;

libname wbh "/ttcmv/sas/data";

data tmp;
	set cmv.snap2(rename=(Po2value=Po2));
	center=floor(id/1000000);
	if not BloodCollect then do; LowPh=99; PO2FO2Ratio=99; end;
	keep DOLDate id center DFSEQ MeanBP LowestTemp Seizures UOP BloodCollect Fio2 Foi2Missing pO2 pO2Missing LowPh PO2FO2Ratio SNAP2Score;
	if 1<DFSEQ<=60;
	format center center.;
run;

proc print;
where bloodcollect and (LowPh not in(0,7,16,999) or PO2FO2Ratio not in(0,5,16,28,999));
run;

proc sql; 
	create table snap2 as 
	select a.*
	from tmp as a, cmv.comp_pat as b
	where a.id=b.id
;




data blood_FP;
	set snap2;
	where bloodcollect;
	keep id center DFSEQ bloodcollect Fio2 Foi2Missing pO2 pO2Missing;
run;

proc means data=blood_FP noprint;
class DFSEQ;
var FiO2;
output out=BloodF n(FiO2)= mean(FiO2)= std(FiO2)= median(FiO2)= min(FiO2)= max(FiO2)= /autoname;
run;

%let pm=%sysfunc(byte(177));

data bloodF;
	set bloodF;
	ms=put(FiO2_Mean,5.1)||"&pm"||put(FiO2_stddev,5.1);
	if DFSEQ=. then delete;
	if DFSEQ in (162,163) then ms=put(FiO2_mean,5.1);
	keep DFSEQ   FiO2_N   FiO2_Mean FiO2_stddev ms FiO2_Median    FiO2_Min    FiO2_Max;
		label 	
				FiO2_N="Num"
				ms="Mean &pm Std"
				FiO2_Median="Median"
				FiO2_Min="Minmum"    
				FiO2_Max="Maximum"
				DFSEQ="Visit*(days)";
run;

proc means data=blood_FP noprint;
class DFSEQ;
var Po2;
output out=BloodP n(Po2)= mean(Po2)= std(PO2)= median(Po2)= min(Po2)= max(Po2)= /autoname;
run;

data bloodP;
	set bloodP;
	ms=put(PO2_Mean,5.1)||"&pm"||put(PO2_stddev,5.1);
	if DFSEQ=. then delete;
	if DFSEQ in (162,163) then ms=put(Po2_Mean,5.1);
	keep DFSEQ   Po2_N    Po2_Mean PO2_stddev ms  Po2_Median    Po2_Min    Po2_Max;
	if DFSEQ=. then delete;

		label 	
				PO2_N="Num"
				ms="Mean &pm Std"
				PO2_Median="Median"
				PO2_Min="Minmum"    
				PO2_Max="Maximum"
				DFSEQ="Visit*(days)";
run;

proc means data=cmv.comp_pat noprint;
class center;
output out=pat_num n(center)=num;
run;

data pat_num;
	set pat_num(drop=_TYPE_ _FREQ_);
	if center=. then do; center=0;	call symput("n",compress(num)); end;
	if center=1 then do; call symput("n1",compress(num)); end;
	if center=2 then do; call symput("n2",compress(num)); end;
	if center=3 then do; call symput("n3",compress(num)); end;
run;


%let n=%eval(&n1+&n2+&n3);

proc format;

value item 
				1="Mean arterial pressure(mm/Hg)"
				2="Lowest temperature(°C)"
				3="Multiple seizures?"
				4="Urine output(mL/kg/h)"
				5="Was any blood collected for laboratory testing?"
				6="FiO^{sub 2}"
				7="PO^{sub 2}"
				8="Lowest serum pH"
				9="PO^{sub 2}/FiO^{sub 2}"
				;

value codeA 
				0=">30(0)"
				9="20-29(9)"
				19="<20(19)"
				999="Missing"
		;

value codeB 
				0=">35.5(0)"
				8="35-35.5(9)"
				15="<35(15)"
				999="Missing"
		;

value codeC 
				0="No(0)"
				19="Yes(19)"
				999="Missing"
		;

value codeD 
				0=">=1.0(0)"
				5="0.1-0.9(5)"
				18="<0.1(18)"
				999="Missing"
		;
value codeE 
				0="No"
				1="Yes"
				99="Unknown"
		;

value miss 
				0="Non Missing"
				1="Missing"
		;

value codeH 
				0=">=7.2(0)"
				7="7.1-7.19(7)"
				16="<7(16)"
				99="No Answer"
				999="Missing"
		;

value codeI 
				0=">=2.5(0)"
				5="1-2.49(5)"
				16="0.3-0.99(16)"
				28="<0.3(28)"
				99="No Answer"
				999="Missing"
		;

run;
*********************************************************************************************************************************;
%macro tab(data, out, varlist)/parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		*ods trace on;
		proc freq data=&data;
			table &var*DFSEQ/norow nopct;
			ods output crosstabfreqs = tab&i;
		run;
		*ods trace off;

	data tab&i;
		set tab&i;
		item=&i;
		if DFSEQ=. then delete;
		if &var=. then delete;
		rename &var=code;
	run;

	data &out;

		set &out tab&i;
		length code0 $20;
		if item=1 then  do; code0=put(code, codeA.); end;
		if item=2 then  do; code0=put(code, codeB.); end;
		if item=3 then  do; code0=put(code, codeC.); end;
		if item=4 then  do; code0=put(code, codeD.); end;
		if item=5 then  do; code0=put(code, codeE.); end;
		if item=6 or item=7 then  do; code0=put(code, miss.); end;
		if item=8 then  do; code0=put(code, codeH.); end;
		if item=9 then  do; code0=put(code, codeI.); end;

		keep DFSEQ item code code0 frequency;
		format item item.;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=MeanBP LowestTemp Seizures UOP BloodCollect Foi2Missing pO2Missing LowPh PO2FO2Ratio;
%tab(snap2, tab, &varlist);


proc sort; by item DFSEQ code code0;run;
proc transpose data=tab out=tab; by item DFSEQ; run;

proc print;run;

data BP;
	set tab;
	where _NAME_="Frequency" and item=1;
	n=col1+col2+col3;
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3="--";
	nf4=col3||"/"||compress(n)||"("||put(col3/n*100,5.1)||"%)";
	label nf1=">30(0)*n(%)"
			 nf2="20-29(9)*n(%)"
			nf3="<20(19)*n(%)"
			nf4="Missing*n(%)"
			DFSEQ="Visit*(days)";
	keep item  DFSEQ  nf1-nf4;
run;


data temp;
	set tab;
	where _NAME_="Frequency" and item=2;
	n=col1+col2+col3;
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3=col3||"/"||compress(n)||"("||put(col3/n*100,5.1)||"%)";
	nf4="--";
	label 	nf1=">35.5(0)*n(%)"
				nf2="35-35.5(9)*n(%)"
				nf3="<35(15)*n(%)"
				nf4="Missing*n(%)"
			DFSEQ="Visit*(days)";
	keep item  DFSEQ  nf1-nf4;
run;


data Seizures;
	set tab;
	where _NAME_="Frequency" and item=3;
	n=col1+col2;
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3="--";
	label 	nf1="No(0)*n(%)"
				nf2="Yes(19)*n(%)"
				nf3="Missing*n(%)"
			DFSEQ="Visit*(days)";
	keep item  DFSEQ  nf1-nf3;
run;

data UOP;
	set tab;

	where _NAME_="Frequency" and item=4;
	n=col1+col2+col3+col4;
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3=col3||"/"||compress(n)||"("||put(col3/n*100,5.1)||"%)";
	nf4=col4||"/"||compress(n)||"("||put(col4/n*100,5.1)||"%)";
	label 	nf1=">=1.0(0)*n(%)"
				nf2="0.1-0.9(5)*n(%)"
				nf3="<0.1(18)*n(%)"
				nf4="Missing*n(%)"
			DFSEQ="Visit*(days)";
	keep item  DFSEQ  nf1-nf4;
run;

data BloodCollect;
	set tab;
	where _NAME_="Frequency" and item=5;
	n=col1+col2;
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	label 	nf1="No*n(%)"
				nf2="Yes*n(%)"
				DFSEQ="Visit*(days)";
	keep item  DFSEQ  nf1-nf2;
run;

data Blood;
	merge 
			tab(where=(item=5 and _NAME_="Frequency") keep=item _NAME_ DFSEQ col2 rename=(col2=n)) 
			tab(where=(item=6 and _NAME_="Frequency") keep=item _NAME_ DFSEQ col2 rename=(col2=F_missing)) 
			tab(where=(item=7 and _NAME_="Frequency") keep=item _NAME_ DFSEQ col2 rename=(col2=P_missing));
	by DFSEQ;
	nf1=F_missing||"/"||compress(n)||"("||put(F_missing/n*100,5.1)||"%)";
	nf2=P_missing||"/"||compress(n)||"("||put(P_missing/n*100,5.1)||"%)";
	label 	
				n="BloodCollection*(n)"
				nf1="FiO^{sub 2} Missing*n(%)"
				nf2="PO^{sub 2} Missing*n(%)"
				DFSEQ="Visit*(days)";
	keep item  DFSEQ n  nf1-nf2;
run;


data LowPh;
	merge 
			tab(where=(item=5 and _NAME_="Frequency") keep=item _NAME_ DFSEQ col1 col2 rename=(col1=no col2=ny)) 
			tab(where=(item=8 and _NAME_="Frequency"));
	by DFSEQ;
	n=no+ny;
	nf=no||"/"||compress(n)||"("||put(no/n*100,5.1)||"%)";
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3=col3||"/"||compress(n)||"("||put(col3/n*100,5.1)||"%)";
	col4=n-col1-col2-col3-col5;
	nf4=col4||"/"||compress(n)||"("||put(col4/n*100,5.1)||"%)";
	nf5=col5||"/"||compress(n)||"("||put(col5/n*100,5.1)||"%)";
	label 	
				n="BloodCollection*(n)"
				nf="No Blood*Collection(n)"
				nf1=">=7.2(0)*n(%)"
				nf2="7.1-7.19(7)*n(%)"
				nf3="<7(16)*n(%)"
				nf4="No Answer*n(%)"
				nf5="Missing*n(%)"
				DFSEQ="Visit*(days)";
	keep item  DFSEQ n nf nf1-nf5;
run;

data Ratio;
	merge 
			tab(where=(item=5 and _NAME_="Frequency") keep=item _NAME_ DFSEQ col1 col2 rename=(col1=no col2=ny)) 
			tab(where=(item=9 and _NAME_="Frequency")); 
	by DFSEQ;
	n=no+ny;
	nf=no||"/"||compress(n)||"("||put(no/n*100,5.1)||"%)";
	nf1=col1||"/"||compress(n)||"("||put(col1/n*100,5.1)||"%)";
	nf2=col2||"/"||compress(n)||"("||put(col2/n*100,5.1)||"%)";
	nf3=col3||"/"||compress(n)||"("||put(col3/n*100,5.1)||"%)";
	nf4=col4||"/"||compress(n)||"("||put(col4/n*100,5.1)||"%)";
	col5=n-col1-col2-col3-col4-col6;
	nf5=col5||"/"||compress(n)||"("||put(col5/n*100,5.1)||"%)";
	nf6=col6||"/"||compress(n)||"("||put(col6/n*100,5.1)||"%)";
	label 	
				n="BloodCollection*(n)"
				nf="No Blood* Collection(n)"
				nf1=">=2.5(0)*n(%)"
				nf2="1-2.49(5)*n(%)"
				nf3="0.3-0.99(16)*n(%)"
				nf4="<0.3(28)*n(%)"
				nf5="No Answer*n(%)"
				nf6="Missing*n(%)"
				DFSEQ="Visit*(days)";
	keep item  DFSEQ n nf nf1-nf6;
run;

%let deg=%sysfunc(byte(176));

ods rtf file="snap2.rtf" style=journal startpage=no bodytitle;
ods escapechar="^";
proc print data=BP noobs label split="*" style(data)=[just=center];
title "Mean arterial pressure(mm/Hg)(n=&n)";
var DFSEQ nf1-nf4/style(data)=[cellwidth=1in];
run;

proc print data=temp noobs label split="*" style(data)=[just=center];
title "Lowest temperature (&deg.C)(n=&n)";
var DFSEQ nf1-nf4/style(data)=[cellwidth=1in];
run;

proc print data=Seizures noobs label split="*" style(data)=[just=center];
title "Multiple seizures?(n=&n)";
var DFSEQ nf1-nf3/style(data)=[cellwidth=1in];
run;


proc print data=UOP noobs label split="*" style(data)=[just=center];
title "Urine output(mL/kg/h)(n=&n)";
var DFSEQ nf1-nf4/style(data)=[cellwidth=1in];
run;

ods rtf startpage=no;

proc print data=BloodCollect noobs label split="*" style(data)=[just=center];
title "Was any blood collected for laboratory testing?(n=&n)";
var DFSEQ nf1-nf2/style(data)=[cellwidth=1in];
run;

ods rtf startpage=no;

proc print data=Blood noobs label split="*" style(data)=[just=center];
title1 "Lab results from the first blood collection of the day";
title2 "FiO^{sub 2} and PO^{sub 2}";
var DFSEQ /*n*/ nf1-nf2/style(data)=[cellwidth=1.2in];
run;

ods rtf startpage=no;

proc print data=BloodF noobs label split="*" style(data)=[just=center];
title "Lab results from the first blood collection of the day FiO^{sub 2}(%) ";
var DFSEQ FiO2_N ms FiO2_Median FiO2_Min FiO2_Max/style(data)=[cellwidth=1.0in];
run;

ods rtf startpage=no;

proc print data=BloodP noobs label split="*" style(data)=[just=center];
title "Lab results from the first blood collection of the day PO^{sub 2}(mmHg) ";
var DFSEQ PO2_N ms PO2_Median PO2_Min PO2_Max/style(data)=[cellwidth=1.0in];
run;


ods rtf startpage=no;

proc print data=LowPh noobs label split="*" style(data)=[just=center];
title1 "Lab results from the first blood collection of the day";
title2 "Lowest serum pH";
var DFSEQ/style(data)=[cellwidth=0.5in];
var nf/style(data)=[cellwidth=1.2in];
var nf1-nf5/style(data)=[cellwidth=1.0in];
run;

ods rtf startpage=no;

proc print data=Ratio noobs label split="*" style(data)=[just=center];
title1 "Lab results from the first blood collection of the day";
title2 "PO^{sub 2}/FiO^{sub 2}";
var DFSEQ/style(data)=[cellwidth=0.5in];
var nf/style(data)=[cellwidth=1.2in];
var nf1-nf6/style(data)=[cellwidth=1.0in];
run;

ods rtf close;


proc greplay igout= wbh.graphs nofs; delete _ALL_; run; 	*clear out the graphs catalog;
goptions reset=global rotate=landscape gunit=pct noborder /*colors=(orange green red)*/
	ctext=black ftitle=swissb ftext=swiss htitle=3.5 htext=3;

 	
		%let description = f=zapf "Bar Chart for SNAP II Score on Day 4";
		%let mp=(1 to 30 by 1);
		
		axis1 label=(a=90 h=4 c=black "Frequency") order=(0 to 50 by 5) minor=none;
		axis2 label=(a=0 h=4 c=black "SNAP II Score") value=(/*f=zapf*/ h= 2.5) /*order=(1 to 40 by 1)*/ minor=none;

		title1 &description (n=&n);

		pattern1 color=orange;
		Proc gchart data=snap2 gout=wbh.graphs;
			where DFSEQ=4;
			vbar SNAP2Score/ midpoints=&mp raxis=axis1 maxis=axis2 space=0.5 coutline=black width=2;
		run;

options orientation=landscape;
ods ps file = "bar_snap2.ps";
ods pdf file = "bar_snap2.pdf";
proc greplay igout = wbh.graphs tc=sashelp.templt template=whole nofs; * L2R2s;
     treplay 1:1;
run;
ods pdf close;
ods ps close;
