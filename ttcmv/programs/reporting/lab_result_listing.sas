%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


/**** LBWI NAT BLOOD */
data LBWI_blood_NAT_result; set cmv.LBWI_blood_NAT_result; run;
proc sort data = LBWI_blood_NAT_result; by id; run;

data blood_0; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_0)); if DFSEQ = 1; keep id result_blood_0; run;
data blood_21; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_21)); if DFSEQ = 21; keep id result_blood_21; run;
data blood_40; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_40)); if DFSEQ = 40; keep id result_blood_40; run;
data blood_60; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_60)); if DFSEQ = 60; keep id result_blood_60; run;
data blood_63; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_63)); if DFSEQ = 63; keep id result_blood_63; run;
data blood_65; set LBWI_blood_NAT_result (rename =(NATTestResult = result_blood_65)); if DFSEQ = 65; keep id result_blood_65; run;


/**** LBWI NAT URINE */
data LBWI_urine_NAT_result; set cmv.LBWI_Urine_NAT_Result; run;
proc sort data = LBWI_urine_NAT_result; by id; run;

data urine_0; set LBWI_urine_NAT_result (rename =(UrineTestResult = result_urine_0)); if DFSEQ = 1; keep id result_urine_0;  run;
data urine_63; set LBWI_urine_NAT_result (rename =(UrineTestResult = result_urine_63)); if DFSEQ = 63; keep id result_urine_63;  run;


/**** MOC SERO */
data moc_sero; set cmv.MOC_sero; run;
proc sort data = moc_sero; by id; run;
data moc_sero; set moc_sero;	
	keep id ComboTestResult IgMTestResult; 
	if IgMTestResult = 99 then IgMTestResult = .;  
run;


/**** MOC NAT */
data moc_nat; set cmv.MOC_NAT; run;
proc sort data = moc_nat; by id; run;

data moc_nat_0; set moc_nat (rename = (NATTestResult = moc_nat_0)); if DFSEQ = 1; keep id moc_nat_0; run; 
data moc_nat_63; set moc_nat (rename = (NATTestResult = moc_nat_63)); if DFSEQ = 63; keep id moc_nat_63; run; 


/**** MERGE ALL RESULTS */
data results;
	merge 	moc_sero moc_nat_0 moc_nat_63 
				blood_0 urine_0 blood_21 blood_40 blood_60 blood_63 urine_63 blood_65;
	by id;

	format 	ComboTestResult IgMTestResult MOCSeroResult.
				moc_nat_0 moc_nat_63
				result_blood_0 result_urine_0 result_blood_21 result_blood_40 
				result_blood_60 result_blood_63 result_urine_63 result_blood_65 CMVNATResult.
	;

	* use asterisk as split char in print statement ;
	label 	id = "LBWI ID"
				ComboTestResult = "MOC*Serology*IgG/IgM*Enrollment"
				IgMTestResult = "MOC*Serology*IgM*Enrollment"
				moc_nat_0 = "MOC*CMV NAT*Blood*Enrollment"
				moc_nat_63 = "MOC*CMV NAT*Blood*End of Study"
				result_blood_0 = "LBWI*CMV NAT*Blood*DOB"
				result_urine_0 = "LBWI*CMV NAT*Urine*DOB"
				result_blood_21 = "LBWI*CMV NAT*Blood*DOL 21"
				result_blood_40 = "LBWI*CMV NAT*Blood*DOL 40"
				result_blood_60 = "LBWI*CMV NAT*Blood*DOL 60"
				result_blood_63 = "LBWI*CMV NAT*Blood*End of Study"
				result_urine_63 = "LBWI*CMV NAT*Urine*End of Study"
				result_blood_65 = "LBWI*CMV NAT*Blood*Post-D/C"
	;

run;


/**** PRINT */
options nodate orientation = landscape;
ods rtf file = "&output./lab_result_listing.rtf" style = journal bodytitle;
	title1 "CMV NAT and Serology Test Result Listing for LBWI and MOC";
	proc print data = results label split = "*" noobs style(data) = [just=center font_size=.9]; 
		id id;
	run;
ods rtf close;



