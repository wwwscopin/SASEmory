/*
proc contents data=cmv.sus_cmv_p1 short varnum; run;
proc contents data=cmv.sus_cmv_p2 short varnum; run;
proc contents data=cmv.sus_cmv_p3 short varnum; run;
proc contents data=cmv.sus_cmv_p4 short varnum; run;
proc contents data=cmv.sus_cmv_p5 short varnum; run;
*/

data sus_cmv;
	merge cmv.sus_cmv_p1 cmv.sus_cmv_p2 cmv.sus_cmv_p3 cmv.sus_cmv_p4 cmv.sus_cmv_p5; by id;

	keep
CMVSuspDate FeverDate RashDate JaundiceDate PetechiaeDate SeizureDate HepatomegalyDate SplenomegalyDate MicrocephalyDate 
labtestDate Fio2Date VentIncreaseDate SPO2DecreaseDate id Fever Rash jaundice petechiae seizure hepatomegaly splenomegaly 
microcephaly labtest Fio2 Fio2SetBefore Fio2SetAfter VentIncrease DecreaseSPO2 SPO2BeforeDecrease SPO2AfterDecrease  

AbBrainParenDate BrainCalcDate HydrocephalusDate PneumonitisDate Comments id AbBrainParenchyma       
AbBrainParenImage BrainCalc BrainCalcImage Hydrocephalus HydrocephalusImage Pneumonitis PneumonitisImage IsNarrative 

HighASTDate HighALTDate HighGGTDate HighTBiliDate HighDBiliDate AbLipaseDate AbChDate AbWBCDate AbPlateletDate AHctDate id  
HighAST ASTValue HighALT ALTValue HighGGT GGTValue HighTBili TBiliValue HighDBili DBiliValue AbLipase AbLipaseValue AbCh 
AbChValue AbWBC AbWBCcount AbPlatelet AbPlateletCount AbHct AbHctCount

AbHbDate AbNeutroDate AbLymphoDate BloodNATTestDate UrineNATTestDate SerologyDate UrineCultureDate UrineResultsDate id  
AbHb AbHbValue AbNeutro AbNeutroValue AbLympho AbLymphoValue BloodNATTest BloodNATResult BloodNATCopyNumber  
UrineNATTest UrineNATResult UrineNATCopyNumber SerologyTest SerologyResult UrineCulture UrineCultureResult 

CMVConfirmedDate CMVRuleOutDate Comments id colonoscopy ConfirmColitis OpExam ConfirmRetinitis Broncho ConfirmPneumonitis 
SkinBiopsy ConfirmDermatitis SpinalTap ConfirmEncephal ConfirmReport CMVDisConf CMVDisNo IsNarrative;

run;

proc means data=sus_cmv noprint;

var fever Rash Jaundice Petechiae Seizure Hepatomegaly Splenomegaly Microcephaly labtest Fio2 VentIncrease DecreaseSPO2
AbBrainParenchyma BrainCalc Hydrocephalus Pneumonitis HighAST HighALT HighGGT HighTBili AbLipase AbCh AbWBC AbPlatelet AbHct
AbHb AbNeutro AbLympho BloodNATTest UrineNATTest SerologyTest UrineCulture UrineCultureResult colonoscopy OpExam Broncho
SkinBiopsy SpinalTap CMVDisConf CMVDisNo;

output out=tmp;
run;

data avg_cmv; 
	set tmp;
	if _STAT_="MEAN";
	drop _TYPE_ _FREQ_ _STAT_;
run;

data _null_;
	set avg_cmv;
	if _n_=1 then do;
		call symput("fever",compress(fever));
		call symput("rash",compress(rash));
		call symput("Jaundice",compress(Jaundice));
		call symput("Petechiae",compress(Petechiae));
		call symput("Seizure",compress(Seizure));
		call symput("Hepatomegaly",compress(Hepatomegaly));
		call symput("Splenomegaly",compress(Splenomegaly));
		call symput("Microcephaly",compress(Microcephaly));
		call symput("labtest",compress(labtest));
		call symput("Fio2",compress(Fio2));
		call symput("VentIncrease",compress(VentIncrease));
		call symput("DecreaseSPO2",compress(DecreaseSPO2));
		call symput("AbBrainParenchyma",compress(AbBrainParenchyma));
		call symput("BrainCalc",compress(BrainCalc));
		call symput("Hydrocephalus",compress(Hydrocephalus));
		call symput("Pneumonitis",compress(Pneumonitis));
		call symput("HighAST",compress(HighAST));
		call symput("HighALT",compress(HighALT));
		call symput("HighGGT",compress(HighGGT));
		call symput("HighTBili",compress(HighTBili));
		call symput("HighALT",compress(HighALT));
		call symput("HighGGT",compress(HighGGT));
		call symput("HighTBili",compress(HighTBili));
		call symput("AbLipase",compress(AbLipase));
		call symput("AbCh",compress(AbCh));
		call symput("AbWBC",compress(AbWBC));
		call symput("AbPlatelet",compress(AbPlatelet));
		call symput("AbHct",compress(AbHct));
		call symput("AbHb",compress(AbHb));
		call symput("AbNeutro",compress(AbNeutro));
		call symput("AbLympho",compress(AbLympho));
		call symput("BloodNATTest",compress(BloodNATTest));
		call symput("UrineNATTest",compress(UrineNATTest));
		call symput("SerologyTest",compress(SerologyTest));
		call symput("UrineCulture",compress(UrineCulture));
		call symput("UrineCultureResult",compress(UrineCultureResult));
		call symput("colonoscopy",compress(colonoscopy));
		call symput("OpExam",compress(OpExam));
		call symput("Broncho",compress(Broncho));
		call symput("SkinBiopsy",compress(SkinBiopsy));
		call symput("SpinalTap",compress(SpinalTap));
		call symput("CMVDisConf",compress(CMVDisConf));
		call symput("CMVDisNo",compress(CMVDisNo));
	end;
run;

%macro wbh(data);
data cmv_out;
	set sus_cmv;
	%if &fever=0 %then %do; drop feverdate fever; %end;
	%if &Rash=0 %then %do; drop RashDate Rash; %end;
	%if &Jaundice=0 %then %do; drop JaundiceDate Jaundice; %end;
	%if &Petechiae=0 %then %do; drop PetechiaeDate Petechiae; %end;
	%if &Seizure=0 %then %do; drop SeizureDate Seizure; %end;
	%if &Hepatomegaly=0 %then %do; drop HepatomegalyDate Hepatomegaly; %end;
	%if &Splenomegaly=0 %then %do; drop SplenomegalyDate Splenomegaly; %end;
	%if &Microcephaly=0 %then %do; drop MicrocephalyDate Microcephaly; %end;
	%if &labtest=0 %then %do; drop labtestDate labtest; %end;
	%if &Fio2=0 %then %do; drop Fio2Date Fio2 Fio2SetBefore Fio2SetAfter; %end;
	%if &VentIncrease=0 %then %do; drop VentIncreaseDate VentIncrease; %end;
	%if &DecreaseSPO2=0 %then %do; drop SPO2DecreaseDate DecreaseSPO2 SPO2BeforeDecrease SPO2AfterDecrease; %end;

	%if &AbBrainParenchyma=0 %then %do; drop AbBrainParenDate AbBrainParenchyma AbBrainParenImage; %end;
	%if &BrainCalc=0 %then %do; drop BrainCalcDate BrainCalc BrainCalcImage; %end;
	%if &Hydrocephalus=0 %then %do; drop HydrocephalusDate Hydrocephalus HydrocephalusImage; %end;
	%if &Pneumonitis=0 %then %do; drop PneumonitisDate Pneumonitis PneumonitisImage; %end;

	%if &HighAST=0 %then %do; drop HighASTDate HighAST ASTValue; %end;
	%if &HighALT=0 %then %do; drop HighALTDate HighALT ALTValue; %end;
	%if &HighGGT=0 %then %do; drop HighGGTDate HighGGT GGTValue; %end;
	%if &HighTBili=0 %then %do; drop HighTBiliDate HighTBili TBiliValue; %end;
	%if &AbLipase=0 %then %do; drop AbLipaseDate AbLipase AbLipaseValue; %end;
	%if &AbCh=0 %then %do; drop AbChDate AbCh AbChValue; %end;
	%if &AbWBC=0 %then %do; drop AbWBCDate AbWBC AbWBCcount; %end;
	%if &AbPlatelet=0 %then %do; drop AbPlateletDate AbPlatelet AbPlateletCount; %end;
	%if &AbHct=0 %then %do; drop AHctDate AbHct AbHctCount; %end;

	%if &AbHb=0 %then %do; drop AbHbDate AbHb AbHbValue; %end;
	%if &AbNeutro=0 %then %do; drop AbNeutroDate AbNeutro AbNeutroValue; %end;
	%if &AbLympho=0 %then %do; drop AbLymphoDate AbLympho AbLymphoValue; %end;
	%if &BloodNATTest=0 %then %do; drop BloodNATTestDate BloodNATTest BloodNATResult BloodNATCopyNumber; %end;
	%if &UrineNATTest=0 %then %do; drop UrineNATTestDate UrineNATTest UrineNATResult UrineNATCopyNumber; %end;
	%if &SerologyTest=0 %then %do; drop SerologyDate SerologyTest SerologyResult; %end;
	%if &UrineCulture=0 %then %do; drop UrineCultureDate UrineCulture; %end;
	%if &UrineCultureResult=0 %then %do; drop UrineCultureResult UrineResultsDate; %end;

	%if &colonoscopy=0 %then %do; drop colonoscopy ConfirmColitis ; %end;
	%if &OpExam=0 %then %do; drop OpExam ConfirmRetinitis; %end;
	%if &Broncho=0 %then %do; drop Broncho ConfirmPneumonitis ; %end;
	%if &SkinBiopsy=0 %then %do; drop SkinBiopsy ConfirmDermatitis; %end;
	%if &SpinalTap=0 %then %do; drop SpinalTap ConfirmEncephal; %end;
	%if &CMVDisConf=0 %then %do; drop CMVConfirmedDate ; %end;
	%if &CMVDisNo=0 %then %do; drop CMVRuleOutDate; %end;
run;
%mend;
%wbh(sus_cmv);

proc contents short varnum;run;
proc print;run;

proc sort nodupkey out=cmv_id; by id; run;

data _null_;
	set cmv_id;
	call symput("n_cmv", compress(_n_));
run;

%put &n_cmv;

/*
labtest HighAST ASTValue HighTBili TBiliValue HighDBili DBiliValue AbWBC AbWBCcount AbPlatelet AbPlateletCount AbHct AbHctCount 
AbHb AbHbValue AbNeutro AbNeutroValue AbLympho AbLymphoValue BloodNATTest BloodNATResult BloodNATCopyNumber UrineNATTest UrineNATResult UrineNATCopyNumber UrineCulture  UrineCultureResult OpExam ConfirmRetinitis SpinalTap ConfirmEncephal ConfirmReport CMVDisConf CMVDisNo
*/

proc freq data=sus_cmv;
	table labtest HighAST HighTBili HighDBili AbWBC AbPlatelet AbHct AbHb AbNeutro AbLympho BloodNATTest UrineNATTest UrineCulture  UrineCultureResult OpExam SpinalTap CMVDisConf CMVDisNo;
run;



