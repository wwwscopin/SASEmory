
/*
proc contents data = cmv.sus_cmv noprint out = cmv.sus_cmv_names; run; 
ods rtf file = "/ttcmv/sas/output/names.rtf";	
proc print data = cmv.sus_cmv_names; var name; run;
ods rtf close;
*/

proc sort data = cmv.sus_cmv out = cmv; by id; run;

data cmv; set cmv; 

* section 1;
length symptoms $ 200; symptoms = " ";
if fever = 1 then symptoms = compbl(symptoms) || " Fever,";
if rash = 1 then symptoms = compbl(symptoms) || " Rash,";
if jaundice = 1 then symptoms = compbl(symptoms) || " Jaundice,";
if petechiae = 1 then symptoms = compbl(symptoms) || " Petechiae,";
if seizure = 1 then symptoms = compbl(symptoms) || " Seizure,";
if hepatomegaly = 1 then symptoms = compbl(symptoms) || " Hepatomegaly,";
if splenomegaly = 1 then symptoms = compbl(symptoms) || " Splenomegaly,";
if microcephaly = 1 then symptoms = compbl(symptoms) || " Microcephaly,";
*if labtest = 1 then symptoms = compbl(symptoms) || " Lab test,";
if symptoms ~= " " then symptoms_print = substr(symptoms,1,length(symptoms)-1); else symptoms_print = "-";

* section 2;
length pulmonary $ 200; pulmonary = " ";
if Fio2 = 1 then pulmonary = compbl(pulmonary) || " Increase in FiO2,";
if VentIncrease = 1 then pulmonary = compbl(pulmonary) || " Increase in vent settings,";
if DecreaseSPO2 = 1 then pulmonary = compbl(pulmonary) || " Decrease in SPO2,";
if pulmonary ~= " " then pulmonary_print = substr(pulmonary,1,length(pulmonary)-1); else pulmonary_print = "-";

* section 3;
length imaging $ 200; imaging = " ";
if AbBrainParenchyma = 1 then imaging = compbl(imaging) || " Abnormal brain parenchyma,";
if BrainCalc = 1 then imaging = compbl(imaging) || " Brain calcification,";
if Hydrocephalus  = 1 then imaging = compbl(imaging) || " Hydrocephalus,";
if Pneumonitis = 1 then imaging = compbl(imaging) || " Pneumonitis,";
if imaging ~= " " then imaging_print = substr(imaging,1,length(imaging)-1); else imaging_print = "-";

* section 4;
length lab $ 300; lab = " ";
if HighAST = 1 then lab = compbl(lab) || " Elevated AST,";
if HighALT = 1 then lab = compbl(lab) || " Elevated ALT,";
if HighGGT = 1 then lab = compbl(lab) || " Elevated GGT,";
if HighTBili = 1 then lab = compbl(lab) || " Elevated total bilirubin,";
if HighDBili = 1 then lab = compbl(lab) || " Elevated direct bilirubin,";
if AbLipase = 1 then lab = compbl(lab) || " Abnoraml lipase,";
if AbCh = 1 then lab = compbl(lab) || " Abnormal cholesterol,";
if AbWBC = 1 then lab = compbl(lab) || " Abnormal WBC count,";
if AbPlatelet = 1 then lab = compbl(lab) || " Abnormal platelet count,";
if AbHct = 1 then lab = compbl(lab) || " Abnormal Hematocrit,";
if AbHb = 1 then lab = compbl(lab) || " Abnormal Hemoglobin,";
if AbNeutro = 1 then lab = compbl(lab) || "Abnormal Neutrophil count,";
if AbLympho = 1 then lab = compbl(lab) || "Abnormal Lymphocytes,";
if lab ~= " " then lab_print = substr(lab,1,length(lab)-1); else lab_print = "-";

* section 5;
length cmvtest $ 200; cmvtest = " ";
if BloodNATTest = 1 then cmvtest = compbl(cmvtest) || " Blood NAT test,";
if UrineNATTest = 1 then cmvtest = compbl(cmvtest) || " Urine NAT test,";
if SerologyTest = 1 then cmvtest = compbl(cmvtest) || " Serology test,";
if UrineCulture = 1 then cmvtest = compbl(cmvtest) || "Urine culture,";
if cmvtest ~= " " then do;
	cmvtest_print = substr(cmvtest,1,length(cmvtest)-1); 
	if 	bloodnatresult = 2 | bloodnatresult = 4 | urinenatresult = 2 | urinenatresult = 4 | 
		serologyresult = 2 | urinecultureresult = 2 then anytestpos = 1; else anytestpos = 0; format anytestpos yn.;
	end;
else do; cmvtest_print = "-"; anytestpos = "-"; end;

* section 6;
length procedure $ 200; procedure = " ";
if colonoscopy = 1 then procedure = compbl(procedure) || "Colonoscopy,";
if OpExam = 1 then procedure = compbl(procedure) || "Opthalmologic exam,";
if Broncho = 1 then procedure = compbl(procedure) || "Bronchoscopy/Lung biopsy,";
if SkinBiopsy = 1 then procedure = compbl(procedure) || "Skin Biopsy,";
if SpinalTap = 1 then procedure = compbl(procedure) || "Spinal Tap,";
if procedure ~= " " then do;
	procedure_print = substr(procedure,1,length(procedure)-1); 
	if 	ConfirmColitis = 1 | ConfirmRetinitis = 1 | ConfirmPneumonitis = 1 | ConfirmDermatitis = 1 | 
		ConfirmEncephal = 1 then procconfdisease = 1; else procconfdisease = 0; format procconfdisease yn.;
	end;
else do; procedure_print = "-"; procconfdisease = "-"; end;

run;

options nodate orientation="landscape";
ods rtf file = "/ttcmv/sas/output/names.rtf" style=journal;
	title "Summary of findings reported on suspected CMV disease form";	
	proc print data = cmv noobs label split="*"; 
		var id cmvsuspdate symptoms_print pulmonary_print imaging_print lab_print cmvtest_print anytestpos procedure_print procconfdisease; 
		label 	id = "Patient ID"
			cmvsuspdate = "Date CMV first suspected"
			symptoms_print = "Clinical signs & symptoms"
			pulmonary_print = "Pulmonary findings"
			imaging_print = "Imaging findings*"
			lab_print = "Laboratory findings"
			cmvtest_print = "CMV tests ordered*"
			anytestpos = "Any positive CMV test results?"
			procedure_print = "Procedures ordered*"
			procconfdisease = "CMV disease confirmed by procedure?"
		;
	run;
ods rtf close;


