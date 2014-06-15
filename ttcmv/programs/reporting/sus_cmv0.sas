/*
proc contents data=cmv.sus_cmv_p1 short varnum; run;	*plate51;
proc contents data=cmv.sus_cmv_p2 short varnum; run;	*plate52;
proc contents data=cmv.sus_cmv_p3 short varnum; run;	*plate53;
proc contents data=cmv.sus_cmv_p4 short varnum; run;	*plate54;
proc contents data=cmv.sus_cmv_p5 short varnum; run;	*plate55;
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

proc freq data=sus_cmv noprint;

tables fever Rash Jaundice Petechiae Seizure Hepatomegaly Splenomegaly Microcephaly labtest Fio2 VentIncrease DecreaseSPO2
AbBrainParenchyma BrainCalc Hydrocephalus Pneumonitis HighAST HighALT HighGGT HighTBili AbLipase AbCh AbWBC AbPlatelet AbHct
AbHb AbNeutro AbLympho BloodNATTest UrineNATTest SerologyTest UrineCulture UrineCultureResult colonoscopy OpExam Broncho
SkinBiopsy SpinalTap CMVDisConf CMVDisNo/out=tmp;
run;

proc print;run;



