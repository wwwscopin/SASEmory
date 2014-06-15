options orientation=portrait nodate nonumber /*papersize=("7" "8")*/;

/*
proc contents data=cmv.sus_cmv_p1 short varnum; run;	*plate51;
proc contents data=cmv.sus_cmv_p2 short varnum; run;	*plate52;
proc contents data=cmv.sus_cmv_p3 short varnum; run;	*plate53;
proc contents data=cmv.sus_cmv_p4 short varnum; run;	*plate54;
proc contents data=cmv.sus_cmv_p5 short varnum; run;	*plate55;
*/

data sus_cmv_sec1;
	set cmv.sus_cmv_p1;
	center=floor(id/1000000);
	format center center.;
	keep id center CMVSuspDate 
		FeverDate RashDate JaundiceDate PetechiaeDate SeizureDate HepatomegalyDate SplenomegalyDate MicrocephalyDate labtestDate 
		Fever Rash jaundice petechiae seizure hepatomegaly splenomegaly microcephaly labtest;
run;

*********************************************************************************************************************************;
proc sql;
	create table sus_cmv_sec1 as
	select a.*, b.dob, CMVSuspDate-dob as age
	from sus_cmv_sec1 as a, cmv.comp_pat as b
	where a.id=b.id
	;

proc means data=sus_cmv_sec1; 
	class center;
	var age;
	output out=sus_cmv_age n(age)=n mean(age)=mean median(age)=median min(age)=min max(age)=max;
run;

data sus_cmv_age;
	set sus_cmv_age;
	if center=. then center=0;
	keep center n mean median min max;
	format center center. mean 3.0;
run;

*********************************************************************************************************************************;
proc means data=sus_cmv_sec1 noprint;
 class center;
 output out=sus_cmv_num n(center)=num;
run;

data sus_cmv_num;
	set sus_cmv_num(drop=_TYPE_ _FREQ_);
	if center=. then do; center=0;	call symput("n",compress(num)); end;
	if center=1 then do; call symput("n1",compress(num)); end;
	if center=2 then do; call symput("n2",compress(num)); end;
	if center=3 then do; call symput("n3",compress(num)); end;
run;

proc means data=cmv.comp_pat noprint;
	class center;
	output out=comp_pat n(center)=num;
run;

data comp_pat;
	set comp_pat(drop=_TYPE_ _FREQ_);
 	if center=.  then center=0;
run;

proc sql;
	create table sus_cmv_pat0 as 
	select a.*, b.num as num_tot, a.num/num_tot*100 as pct format=5.1
	from sus_cmv_num as a, comp_pat as b
	where a.center=b.center
	order by center
	;

proc sql;
	create table sus_cmv_pat as 
	select a.*, b.mean, b.median, b.min, b.max 
	from sus_cmv_pat0  as a, sus_cmv_age as b
	where a.center=b.center
	order by center
	;


data sus_cmv_pat;
	set sus_cmv_pat;
	nf=num||"/"||compress(num_tot)||"("||put(pct,5.1)||"%)";
run;

proc print;run;


/*
%macro special_char(unicode=, name=);
%global &name;
data _null_;
A=input("&unicode."x,$UCS2B4.);
call symput("&name.",trim(left(A)));
stop;
run;
%put Note: special_char: &name = ->|&&&name.|<- ;
%mend;

%special_char(unicode='3BC'x,name=mu);
*/

proc format;
value group 
				1="General Clinical Signs & Symptoms"
				2="Pulmonary Findings"
				3="Imaging Findings"
				4="Labratory Findings"
				5="Test Results"
				6="Procedure Results"
				7="Confirmation of CMV Disease"
				8="Comments"
		;

value itemA 
				1="Fever"
				2="Rash"
				3="Jaundice"
				4="Patechiae"
				5="Seizures"
				6="Hepatomegaly"
				7="Splenomegaly"
				8="Microcephaly"
				9="Lab Testing"
			;

value itemB 
				1='Increase in FiO^{sub 2}'
				2="Increase in other vent settings"
				3="Decrease in SPO^{sub 2}"
		;

value itemC 
				1="Abnormal brain parenchyma"
				2="--If 'Yes', Type of Image"
				3="Brain calcification"
				4="--If 'Yes', Type of Image"
				5="Hydrocephalus"
				6="--If 'Yes', Type of Image"
				7="Pneumonitis"
				8="--If 'Yes', Type of Image"
		;

value itemD 
				1="Elevated AST"
				2="Elevated ALT"
				3="Elevated GGT"
				4="Elevated Total Bilirubin"
				5="Elevated Direct Bilirubin"
				6="Abnormal Lipase"
				7="Abnormal Cholesterol"
				8='Abnormal WBC count'
				9='Abnormal Platelet count'
				10='Abnormal Hematocrit'
				11="Abnormal Hemoglobin"
				12="Abnormal neutrophil count"
				13="Abnormal Lymphocytes"
		;

value itemE 
				1="Has a CMV NAT test for LBWI blood been ordered?"
				2="--If 'Yes', Blood Test Result"
				3="Has a CMV NAT test for LBWI urine been ordered?"
				4="--If 'Yes', Urine Test Result"
				5="Has a CMV serology test for LBWI been ordered?"
				6="--If 'Yes', Serology Test Result"
				7="Has a CMV urine culture for LBWI been ordered?"
				8="--If 'Yes', Urine Culture Result"
		;

value itemF
				1="Colonoscopy"
				2="--If 'Yes', Confirmed CMV Colitis?"
				3="Ophthalmologic exam"
				4="--If 'Yes', Confirmed CMV Retinitis?"
				5="Bronchoscopy/Lung Biopsy"
				6="--If 'Yes', Confirmed CMV Pneumonitis?"
				7="Skin Biopsy"
				8="--If 'Yes', Confirmed CMV Dermatitis?"
				9="Spinal tap"
				10="--If 'Yes', Confirmed CMV Encephalopathy?"
		;

value itemG 
				1="Was CMV disease confirmed?"
				2="Was CMV disease ruled out?"
		;

value code 
				0="No"
				1="Yes"
				99="Unknown"
		;

value test 
				1="Not detected"
				2="Low Positive(<300 copies/ml)"
				3="Indetermined"
				4="Positive"
				99="Unknown"
		;

value image 
				1="MRI"
				2="CT Scan"
				3="Ultrasound"
				4="X-ray"
				99="Unknown"
		;
value stat 
				1="FiO^{sub 2} setting before increase(%):"
				2="FiO^{sub 2} setting after increase(%):"				
				3="SPO^{sub 2} before increase(%):"
				4="SPO^{sub 2} after increase(%):"
				5="AST value(units/L):"
				6="ALT value(units/L):"
				7="GGT value(units/L):"
				8="Total bilirubin value(mg/dL):"
				9="Direct bilirubin value(mg/dL):"
				10="Lipase value(units/L):"
				11="Cholesterol value(mg/dL):"
				12="WBC count(10^{super 3}/^S={font_face=Symbol}m^S={}L):"
				13="Platelet count(10^{super 3}/^S={font_face=Symbol}m^S={}L):"
				14="Hematocrit(%):"
				15="Hemoglobin value(g/dL):"
				16="Neutrophil count(^S={font_face=Symbol}m^S={}l):"
				17="Lymphocytes(%):"
				18="CMV NAT blood test result-Positive(Copies/ml):"
				19="CMV NAT urine test result-Positive(Copies/ml):"
		;

run;

*********************************************************************************************************************************;
%macro tab(data, out, varlist)/ parmbuff ;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		*ods trace on;
		proc freq data=&data;
			table &var*center/norow nocol;
			ods output crosstabfreqs = tab&i;
		run;
		*ods trace off;

	data tab&i;
		set tab&i;
		item=&i;
		if center=. then center=0;
		if &var=. then delete;
		rename &var=code;
	run;

	data &out;
		length item0 $100 code0 $20;
		set &out tab&i;

		%if &out=sec1 %then %do; group=1; item0=put(item, itemA.); code0=put(code, code.); format group group.; %end;
		%if &out=sec2 %then %do; group=2; item0=put(item, itemB.); code0=put(code, code.); format group group.; %end;
		%if &out=sec3 %then %do; 
					group=3; item0=put(item, itemC.); format group group.;
					if item in (1,3,5,7) then do; code0=put(code, code.);  end;
					if item in (2,4,6,8) then do; code0=put(code, image.); end;
					if item in (2,4,6,8) and code=99 then delete;
			%end;
		%if &out=sec4 %then %do; group=4; item0=put(item, itemD.); code0=put(code, code.); format group group.; %end;
		%if &out=sec5 %then %do; 
					group=5; item0=put(item, itemE.); format group group.; 
					if item in (1,3,5,7) then do; code0=put(code, code.);  end; 
					if item in (2,4,6,8) then do; code0=put(code, test.);  end;
					if item in (2,4,6,8) and code=99 then delete;
			%end;
		%if &out=sec6 %then %do; 
					group=6; item0=put(item, itemF.); code0=put(code, code.); format group group.; 
					if item in (2,4,6,8,10) and code=99 then delete;
			%end;
		%if &out=sec7 %then %do; group=7; item0=put(item, itemG.); code0=put(code, code.); format group group.; %end;

		keep code code0 center group frequency percent item item0;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=Fever Rash jaundice petechiae seizure hepatomegaly splenomegaly microcephaly labtest;
%tab(sus_cmv_sec1, sec1, &varlist);

data sus_cmv_sec2;
	set cmv.sus_cmv_p1;
	center=floor(id/1000000);
	format center center.;
	keep id center
		Fio2Date VentIncreaseDate SPO2DecreaseDate Fio2 Fio2SetBefore Fio2SetAfter VentIncrease DecreaseSPO2 
		SPO2BeforeDecrease SPO2AfterDecrease;
run;

proc sql;
	create table sus_cmv_sec2 as
	select a.* 
	from sus_cmv_sec2 as a, cmv.comp_pat as b
	where a.id=b.id
	;

%let varlist=Fio2 VentIncrease DecreaseSPO2;
%tab(sus_cmv_sec2, sec2, &varlist);

data sus_cmv_sec3;
	set cmv.sus_cmv_p2;
	center=floor(id/1000000);
	format center center.;
	keep id center
		AbBrainParenDate BrainCalcDate HydrocephalusDate PneumonitisDate Comments AbBrainParenchyma AbBrainParenImage 
		BrainCalc BrainCalcImage Hydrocephalus HydrocephalusImage Pneumonitis PneumonitisImage IsNarrative ;
run;

proc sql;
	create table sus_cmv_sec3 as
	select a.* 
	from sus_cmv_sec3 as a, cmv.comp_pat as b
	where a.id=b.id
	;

%let varlist=AbBrainParenchyma AbBrainParenImage BrainCalc BrainCalcImage Hydrocephalus HydrocephalusImage Pneumonitis PneumonitisImage;
%tab(sus_cmv_sec3,sec3, &varlist);

data sus_cmv_sec4;
	merge cmv.sus_cmv_p3 cmv.sus_cmv_p4; by id;
	center=floor(id/1000000);
	format center center.;
	keep id center
		HighASTDate HighALTDate HighGGTDate HighTBiliDate HighDBiliDate AbLipaseDate AbChDate AbWBCDate AbPlateletDate AHctDate 
		HighAST ASTValue HighALT ALTValue HighGGT GGTValue HighTBili TBiliValue HighDBili DBiliValue AbLipase AbLipaseValue 
		AbCh AbChValue AbWBC AbWBCcount AbPlatelet AbPlateletCount AbHct AbHctCount 
		AbHbDate AbNeutroDate AbLymphoDate AbHb AbHbValue AbNeutro AbNeutroValue AbLympho AbLymphoValue;
run;

proc sql;
	create table sus_cmv_sec4 as
	select a.* 
	from sus_cmv_sec4 as a, cmv.comp_pat as b
	where a.id=b.id
	;

%let varlist=HighAST HighALT HighGGT HighTBili HighDBili AbLipase AbCh AbWBC AbPlatelet AbHct AbHb AbNeutro AbLympho;
%tab(sus_cmv_sec4,sec4, &varlist);

data sus_cmv_sec5;
	set cmv.sus_cmv_p4;
	center=floor(id/1000000);
	format center center.;
	if id=1004111 and UrineNATTest=0 then UrineNATResult=99;
	keep id center
		BloodNATTestDate UrineNATTestDate SerologyDate UrineCultureDate UrineResultsDate BloodNATTest BloodNATResult
		BloodNATCopyNumber  UrineNATTest UrineNATResult UrineNATCopyNumber SerologyTest SerologyResult UrineCulture 
		UrineCultureResult;
run;

proc sql;
	create table sus_cmv_sec5 as
	select a.* 
	from sus_cmv_sec5 as a, cmv.comp_pat as b
	where a.id=b.id
	;

%let varlist=BloodNATTest BloodNATResult UrineNATTest UrineNATResult SerologyTest SerologyResult UrineCulture UrineCultureResult;
%tab(sus_cmv_sec5,sec5, &varlist);

data sus_cmv_sec6;
	set cmv.sus_cmv_p5;
	center=floor(id/1000000);
	format center center.;
	keep id center
		colonoscopy ConfirmColitis OpExam ConfirmRetinitis Broncho ConfirmPneumonitis 
		SkinBiopsy ConfirmDermatitis SpinalTap ConfirmEncephal ConfirmReport;
run;

proc sql;
	create table sus_cmv_sec6 as
	select a.* 
	from sus_cmv_sec6 as a, cmv.comp_pat as b
	where a.id=b.id
	;

%let varlist=colonoscopy ConfirmColitis OpExam ConfirmRetinitis Broncho ConfirmPneumonitis SkinBiopsy ConfirmDermatitis SpinalTap ConfirmEncephal;
%tab(sus_cmv_sec6,sec6, &varlist);

data sus_cmv_sec7;
	set cmv.sus_cmv_p5;
	center=floor(id/1000000);
	format center center.;
	keep id center CMVConfirmedDate CMVRuleOutDate CMVDisConf CMVDisNo;
run;

proc sql;
	create table sus_cmv_sec7 as
	select a.* 
	from sus_cmv_sec7 as a, cmv.comp_pat as b
	where a.id=b.id
	;
title "Sucecepted CMV ID";
proc print;run;

%let varlist=CMVDisConf CMVDisNo;
%tab(sus_cmv_sec7,sec7, &varlist);

data sus_cmv_sec8;
	set cmv.sus_cmv_p5;
	center=floor(id/1000000);
	format center center.;
	keep id cetner Comments IsNarrative;
run;

proc sql;
	create table sus_cmv_sec8 as
	select a.* 
	from sus_cmv_sec8 as a, cmv.comp_pat as b
	where a.id=b.id
	;

****************************************************************************************************************************;
** To analyze the qutantitative data;

data sus_cmv_value;
	merge 
			sus_cmv_sec2(keep=id center Fio2SetBefore Fio2SetAfter SPO2BeforeDecrease SPO2AfterDecrease) 
			sus_cmv_sec4(keep=id center ASTValue ALTValue GGTValue TBiliValue DBiliValue AbLipaseValue AbChValue AbWBCcount
										AbPlateletCount AbHctCount AbHbValue AbNeutroValue AbLymphoValue)
			sus_cmv_sec5(keep=id center BloodNATCopyNumber UrineNATCopyNumber);
	by id;
run;

proc means data=sus_cmv_value noprint missing n mean std max min median;

var Fio2SetBefore Fio2SetAfter SPO2BeforeDecrease SPO2AfterDecrease ASTValue ALTValue GGTValue TBiliValue DBiliValue AbLipaseValue AbChValue AbWBCcount AbPlateletCount AbHctCount AbHbValue AbNeutroValue AbLymphoValue BloodNATCopyNumber UrineNATCopyNumber;

output out=sus_cmv_stat0;
output out=sus_cmv_median median= / autoname ;
run;

proc transpose data=sus_cmv_stat0 out=sus_cmv_stat0; run;
data sus_cmv_stat0;
	set sus_cmv_stat0;
	if _n_>2;
	ind=_n_-2;
	rename _name_=name col1=n col2=min col3=max col4=mean col5=std;
	drop _freq_;
run;

proc transpose data=sus_cmv_median out=sus_cmv_median; run;
data sus_cmv_median;
	set sus_cmv_median;
	if _n_>2;
	ind=_n_-2;
	rename _name_=name col1=median;
	drop _freq_;
run;

proc sql; 
	create table sus_cmv_stat as 
	select a.ind format=stat., a.n,  a.min, a.max, a.mean format=5.1, a.std format=5.1, b.median format=5.1
	from sus_cmv_stat0 as a, sus_cmv_median as b
	where a.ind=b.ind
	;

data sus_cmv_stat;
	set sus_cmv_stat;
	n_char=put(n,2.0);
	if n=0 then n_char="--";
run;

****************************************************************************************************************************;


data sus_cmv;
	set sec1 sec2 sec3 sec4 sec5 sec6 sec7;
run;

proc sort data=sec7; by center;run;
proc transpose data=sec7 out=sec7; by center; 
var frequency;
run;

data sec7; 
	set sec7; 
	rename col1=non_confirmed col3=ruledout;
	drop _NAME_   _LABEL_;
run;

proc transpose data=sus_cmv out=sus_cmv1; by group item item0 code code0; 
var frequency;
run;


proc transpose data=sus_cmv out=sus_cmv2; by group item item0 code code0; 
var percent;
run;


%let ny31=0;%let ny311=0; %let ny312=0; %let ny313=0;
%let ny33=0;%let ny331=0; %let ny332=0; %let ny333=0;
%let ny35=0;%let ny351=0; %let ny352=0; %let ny353=0;
%let ny37=0;%let ny371=0; %let ny372=0; %let ny373=0;

%let ny51=0;%let ny511=0; %let ny512=0; %let ny513=0;
%let ny53=0;%let ny531=0; %let ny532=0; %let ny533=0;
%let ny55=0;%let ny551=0; %let ny552=0; %let ny553=0;
%let ny57=0;%let ny571=0; %let ny572=0; %let ny573=0;

%let ny61=0;%let ny611=0; %let ny612=0; %let ny613=0;
%let ny63=0;%let ny631=0; %let ny632=0; %let ny633=0;
%let ny65=0;%let ny651=0; %let ny652=0; %let ny653=0;
%let ny67=0;%let ny671=0; %let ny672=0; %let ny673=0;
%let ny69=0;%let ny691=0; %let ny692=0; %let ny693=0;


data _null_;
	set sus_cmv1(rename=(col1=n1 COL2=n2 COL3=n3 COL4=n));

if group=3 and item=1 and code=1 then do;
call symput("ny31", compress(n)); call symput("ny311", compress(n1)); call symput("ny312", compress(n2)); call symput("ny313", compress(n3));end;

if group=3 and item=3 and code=1 then do;
call symput("ny33", compress(n)); call symput("ny331", compress(n1)); call symput("ny332", compress(n2)); call symput("ny333", compress(n3));end;

if group=3 and item=5 and code=1 then do;
call symput("ny35", compress(n)); call symput("ny351", compress(n1)); call symput("ny352", compress(n2)); call symput("ny353", compress(n3)); end;

if group=3 and item=7 and code=1 then do;
call symput("ny37", compress(n)); call symput("ny371", compress(n1)); call symput("ny372", compress(n2)); call symput("ny373", compress(n3));end;

if group=5 and item=1 and code=1 then do;
call symput("ny51", compress(n)); call symput("ny511", compress(n1)); call symput("ny512", compress(n2)); call symput("ny513", compress(n3));end;

if group=5 and item=3 and code=1 then do;
call symput("ny53", compress(n)); call symput("ny531", compress(n1)); call symput("ny532", compress(n2)); call symput("ny533", compress(n3));end;

if group=5 and item=5 and code=1 then do;
call symput("ny55", compress(n)); call symput("ny551", compress(n1)); call symput("ny552", compress(n2)); call symput("ny553", compress(n3));end;

if group=5 and item=7 and code=1 then do;
call symput("ny57", compress(n)); call symput("ny571", compress(n1)); call symput("ny572", compress(n2)); call symput("ny573", compress(n3));end;

if group=6 and item=1 and code=1 then do;
call symput("ny61", compress(n)); call symput("ny611", compress(n1)); call symput("ny612", compress(n2)); call symput("ny613", compress(n3));end;

if group=6 and item=3 and code=1 then do;
call symput("ny63", compress(n)); call symput("ny631", compress(n1)); call symput("ny632", compress(n2)); call symput("ny633", compress(n3));end;

if group=6 and item=5 and code=1 then do;
call symput("ny65", compress(n)); call symput("ny651", compress(n1)); call symput("ny652", compress(n2)); call symput("ny653", compress(n3));end;

if group=6 and item=7 and code=1 then do;
call symput("ny67", compress(n)); call symput("ny671", compress(n1)); call symput("ny672", compress(n2)); call symput("ny673", compress(n3));end;

if group=6 and item=9 and code=1 then do;
call symput("ny69", compress(n)); call symput("ny691", compress(n1)); call symput("ny692", compress(n2)); call symput("ny693", compress(n3));end;
run;


data sus_cmv;
	*merge sus_cmv1(rename=(col1=n1 COL2=n2 COL3=n3 COL4=n)) /*sus_cmv2(rename=(col1=f1 COL2=f2 COL3=f3 COL4=f))*/; 
	length nf1 nf2 nf3 nf $25;
	set sus_cmv1(rename=(col1=n1 COL2=n2 COL3=n3 COL4=n)); by group item code;

	f1=n1/&n1*100; 
	f2=n2/&n2*100; 
	f3=n3/&n3*100; 
	f=n/&n*100;

	nf1=n1||"("||put(f1,5.1)||"%)";
	nf2=n2||"("||put(f2,5.1)||"%)";
	nf3=n3||"("||put(f3,5.1)||"%)";
	nf=n||"("||put(f,5.1)||"%)";


if group=3 and item=2 then do; 
	m=&ny31; m1=&ny311; m2=&ny312; m3=&ny313; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=3 and item=4 then do;
	m=&ny33; m1=&ny331; m2=&ny332; m3=&ny333; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=3 and item=6 then do; 
	m=&ny35; m1=&ny351; m2=&ny352; m3=&ny353; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=3 and item=8 then do; 
	m=&ny37; m1=&ny371; m2=&ny372; m3=&ny373; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 


if group=5 and item=2 then do; 
	m=&ny51; m1=&ny511; m2=&ny512; m3=&ny513; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=5 and item=4 then do;
	m=&ny53; m1=&ny531; m2=&ny532; m3=&ny533; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=5 and item=6 then do; 
	m=&ny55; m1=&ny551; m2=&ny552; m3=&ny553; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=5 and item=8 then do; 
	m=&ny57; m1=&ny571; m2=&ny572; m3=&ny573; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 


if group=6 and item=2 then do; 
	m=&ny61; m1=&ny611; m2=&ny612; m3=&ny613; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=6 and item=4 then do;
	m=&ny63; m1=&ny631; m2=&ny632; m3=&ny633; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
if group=6 and item=6 then do; 
	m=&ny65; m1=&ny651; m2=&ny652; m3=&ny653; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=6 and item=8 then do; 
	m=&ny67; m1=&ny671; m2=&ny672; m3=&ny673; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=6 and item=10 then do; 
	m=&ny69; m1=&ny691; m2=&ny692; m3=&ny693; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 
	drop  _NAME_   _LABEL_;
run;

proc print;run;

proc sql; 
	create table sus_cmv_pat as 
	select a.*, num-non_confirmed as confirmed,(num-non_confirmed)/num*100 as f_confirmed format=4.2, ruledout, ruledout/num*100 as f_ruledout format=4.2
	from sus_cmv_pat as a, sec7 as b
	where a.center=b.center;
	; 

data sus_cmv_pat;
	set sus_cmv_pat;
	nf_confirmed=confirmed||"/"||compress(num)||"("||put(f_confirmed,4.1)||"%)";
	nf_ruledout=ruledout||"/"||compress(num)||"("||put(f_ruledout,4.1)||"%)";
run;
	
ods pdf file="sus_cmv.pdf";
ods rtf file="sus_cmv.rtf" style=Journal startpage=no bodytitle;

ODS ESCAPECHAR='^';

title "Investigation of Suscepted CMV Disease";

proc print data=sus_cmv_pat noobs label split="*" style(data) = [cellwidth=1in just=center];
var center/style(data) = [cellwidth=0.8in just=left];
*var num/style(data) = [cellwidth=0.8in just=center];
var nf_confirmed nf_ruledout mean median min max;

label
		center='Center'
		nf_confirmed="CMV Disease Confirmed(%)"
		nf_ruledout="CMV Disease Ruled Out(%)"
		mean='Age*Mean(Day)'
		median='Age*Median(Day)'
		min='Age*Min(Day)'
		max='Age*Max(Day)'
;
run;

*options orientation=landscape;

proc report data=sus_cmv split="*"; 
	where group=1;
	title1 "Suscepted CMV Disease Summary (n=&n)";
	title2 "Have any of the following signs/symptoms triggered the suspicion of CMV?";
	
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=2.25in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=1.0in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	*break after group/skip;
	*break after item0/skip;
run;

proc report data=sus_cmv split="*"; 
	where group=2;
	title1 "Suscepted CMV Disease Summary (n=&n)";
	title2 "Have any of the following changes triggered the suspicion of CMV?";
	
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.5in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;


ods rtf startpage=yes;
proc report data=sus_cmv split="*"; 
	where group=3;
	title1 "Suscepted CMV Disease Summary (n=&n)";
	title2 "Have any of the following imaging findings been observed?";
	
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.5in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

ods rtf startpage=no;

proc report data=sus_cmv split="*"; 
	where group=4;
	title1 "Suscepted CMV Disease Summary (n=&n)";
	title2 "Has any of the following findings triggered this suspicion of CMV?";
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.5in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

*options orientation=landscape;
ods rtf startpage=Yes;
proc report data=sus_cmv split="*"; 
	where group=5;
	title "Suscepted CMV Disease Summary (n=&n)";
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.0in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2.25in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

ods rtf startpage=no;
title "Data Summary for Suscepted CMV Disease (n=&n)";
proc print data=sus_cmv_stat noobs label split="*" style(data) = [cellwidth=1in just=center];

var ind/style(data) = [cellwidth=3in just=left];
var n_char mean median min max/style(data) = [cellwidth=0.6in just=center];

label 
		ind='Variable'
		n_char='Number'
		mean='Mean'
		median='Median'
		min='Min'
		max='Max'
;
run;

*ods rtf startpage=yes;

proc report data=sus_cmv split="*"; 
	where group=6;
	title1 "Suscepted CMV Disease Summary  (n=&n)";
	title2 "Have any of the following procedures been done to investigate CMV?";
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.25in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2.25in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

ods rtf startpage=no;

proc report data=sus_cmv split="*"; 
	where group=7;
	title1 "Suscepted CMV Disease Summary (n=&n)";
	columns group item0 code0 nf nf1 nf2 nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.25in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=2.25in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall*(n=&n)" style(column)={just=right};
	define nf1/"EUHM*(n=&n1)" style(column)={just=right};
	define nf2/"Grady*(n=&n2)" style(column)={just=right};
	define nf3/"Northside*(n=&n3)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

ods rtf close;
ods pdf close;



