
*** get ever txn ;

	*** Calculate ever transfused for all patients who have completed study ;	
	proc sort data = cmv.plate_031 out = rbc; by id; run;
	data rbc; set rbc; by id; if first.id; keep id; run;
	
	data cmv.lbwi_demo; merge cmv.lbwi_demo (in=a) rbc (in=b); by id; if a; 
		if b then evertxn = 1; else evertxn = 0; run;
	run;
	
***************;



/* lbwi_demo.sas
 *
 * produce tables summarizing LBWI Demographic Data 
 *
 */

%include "&include./descriptive_stat.sas";
%include "&include./annual_toc.sas";

proc format;
		value bw_cat
							1 = "Extremely Low (<1000g)"
							2 = "Very Low (1000-1500g)"
							3 = "Greater than 1500g"
	;
run;

proc sort data = cmv.lbwi_demo out = lbwi_demo; by id; run;
data lbwi_demo; merge lbwi_demo cmv.completedstudylist (in=a); by id; if a; run;


data lbwi_demo; set lbwi_demo; 
	moc_id = input(substr(put(id,7.0),1,5),5.0); run;
proc sort data = lbwi_demo; by moc_id; run;

data lbwi_demo; set lbwi_demo; 
	by moc_id; retain multiple;
	if first.moc_id then multiple = 1; else multiple = multiple + 1; 
	if last.moc_id & multiple = 1 then singleton = 1; else singleton = 0;  
run;


data lbwi_demo; set lbwi_demo (rename = (BirthResusinutbation = BirthResusintubation));

	format Gender gender. IsHispanic yn. race race. bloodgastype bloodgastype.;

	if IsOutborn = 99 then IsOutborn = .;
	if IsBloodGas = 99 then IsBloodGas = .;

	if gender = 2 then gender = 0; *change so 0=female 1=male report var as binary male gender ;
	if bloodgastype = 2 then arterial = 1;
	if bloodgastype = 1 then arterial = 0;

	if birthweight < 1000 then bw_cat = 1;
	if birthweight >= 1000 & birthweight <= 1500 then bw_cat = 2;
	if birthweight > 1500 then bw_cat = 3;
	format bw_cat bw_cat.;

	label 	gender = "Male gender - no. (%)"
				ishispanic = "Hispanic ethnicity - no. (%)"
				race = "Race - no. (%)"
				Gestage = "Gestational age (weeks) - mean (sd) [min-max], N"
				BirthWeight = "Weight (g) - mean (sd) [min-max], N"
				bw_cat = "Weight category (g) - no. (%)"
				singleton = "Singleton births - no. (%)"
				olsen_weight_z = "Weight Z-score - mean (sd) [min-max], N"
				olsen_weight_tenth = "Weight < 10th percentile for gestational age - no. (%)"
				olsen_weight_fiftieth = "Weight < 50th percentile for gestational age - no. (%)"
				Length = "Length (cm) - mean (sd) [min-max], N"
				olsen_length_z = "Length Z-score - mean (sd) [min-max], N"
				olsen_length_tenth = "Length < 10th percentile for gestational age - no. (%)"
				olsen_length_fiftieth = "Length < 50th percentile for gestational age - no. (%)"
				Headcircum = "Head circumference (cm) - mean (sd) [min-max], N"
				olsen_hc_z = "Head circumference Z-score - mean (sd) [min-max], N"	
				olsen_hc_tenth = "Head circumference < 10th percentile for gestational age - no. (%)"
				olsen_hc_fiftieth = "Head circumference < 50th percentile for gestational age - no. (%)"
				apgar1min = "1  Minute Apgar Score - mean (sd) [min-max], N"
				apgar5min = "5  Minute Apgar Score - mean (sd) [min-max], N"
				IsOutborn = "Born outside study hospital - no. (%)"
				BirthResus = "Birth resuscitation required - no. (%)"
				BirthResusoxygen = "	- Oxygen"
				BirthResuscompression = "	- Chest compression"
				BirthResuscpap = "	- CPAP"
				BirthResusepi = "	- Epinephrine"
				BirthResusintubation = "	- Intubation"
				BirthResusmask = "	- Bagging and mask"
				IsBloodGas = "Cord blood gas done - no. (%)"
				cordph = "Cord pH - mean (sd) [min-max], N"
				basedeficit = "Base deficit - mean (sd) [min-max], N"
				arterial = "Arterial blood gas - no. (%)"
	;
run;


*** DATA SET OF ONLY SINGLETONS ;
data singletons; set lbwi_demo; if singleton = 1; run;
/*
data singletons; set lbwi_demo; 
	moc_id = input(substr(put(id,7.0),1,5),5.0); run;
proc sort data = singletons; by moc_id; run;

data singletons; set singletons; 

	by moc_id; retain multiple;
	if first.moc_id then multiple = 1; else multiple = multiple + 1; 

	if last.moc_id & multiple = 1;  

run;
*/


data lbwi_demo1; set lbwi_demo; if evertxn = 0; run;
data lbwi_demo2; set lbwi_demo; if evertxn = 1; run;

data singletons1; set singletons; if evertxn = 0; run;
data singletons2; set singletons; if evertxn = 1; run;



	* SECTION 1 ***********************************************************************************************************;
	data header1; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Demographic factors"; run;
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary1, var= Gender, type= bin, first_var=1);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary1, var= IsHispanic, type= bin);	
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary1, var= race, type= cat, last_var=1);
	* SECTION 2 ***********************************************************************************************************;
	data header2; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Anthropometric data at birth*"; run;
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= GestAge, type= cont, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= BirthWeight, type= cont, non_param=0, dec_places=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= bw_cat, type= cat);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= singleton, type= bin);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_weight_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_weight_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_weight_fiftieth, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= Length, type= cont, non_param=0);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_length_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_length_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_length_fiftieth, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= HeadCircum, type= cont, non_param=0);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_hc_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_hc_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons1, data_out= lbwi_demo_summary2, var= olsen_hc_fiftieth, type= bin, non_param=0, last_var=1);
	* SECTION 3 ***********************************************************************************************************;
	data header3; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Neonatal health scores and birth risk factors"; run;
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= Apgar1Min, type= cont, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= Apgar5min, type= cont, non_param=0);
	* Include SNAP Score ;
	data snap; set cmv.snap;	label SNAPTotalScore = "SNAP - mean (sd), N"; run;
	data lbwi_demo1; merge lbwi_demo1 (in=a) snap (keep = SNAPTotalScore); if a; run;
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary2, var= SNAPTotalScore, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= IsOutborn, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResus, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResusoxygen, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResuscompression, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResuscpap, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResusepi, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResusintubation, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary3, var= BirthResusmask, type= bin, non_param=0, last_var=1);
	* SECTION 4 ***********************************************************************************************************;
	data header4; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Umbilical cord blood gas data"; run;
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary4, var= IsBloodGas, type= bin, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary4, var= cordph, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary4, var= basedeficit, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo1, data_out= lbwi_demo_summary4, var= arterial, type= bin, non_param=0, last_var=1);
	***********************************************************************************************************************;

* Merge tables and headers;
	data lbwi_demo_summary_1; 
		set 	header1 lbwi_demo_summary1 
				header2 lbwi_demo_summary2
				header3 lbwi_demo_summary3
				header4 lbwi_demo_summary4
		; 
	run;


	* SECTION 1 ***********************************************************************************************************;
	data header1; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Demographic factors"; run;
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary1, var= Gender, type= bin, first_var=1);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary1, var= IsHispanic, type= bin);	
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary1, var= race, type= cat, last_var=1);
	* SECTION 2 ***********************************************************************************************************;
	data header2; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Anthropometric data at birth*"; run;
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= GestAge, type= cont, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= BirthWeight, type= cont, non_param=0, dec_places=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= bw_cat, type= cat);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= singleton, type= bin);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_weight_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_weight_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_weight_fiftieth, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= Length, type= cont, non_param=0);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_length_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_length_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_length_fiftieth, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= HeadCircum, type= cont, non_param=0);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_hc_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_hc_tenth, type= bin, non_param=0);
	%descriptive_stat(data_in= singletons2, data_out= lbwi_demo_summary2, var= olsen_hc_fiftieth, type= bin, non_param=0, last_var=1);
	* SECTION 3 ***********************************************************************************************************;
	data header3; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Neonatal health scores and birth risk factors"; run;
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= Apgar1Min, type= cont, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= Apgar5min, type= cont, non_param=0);
	* Include SNAP Score ;
	data snap; set cmv.snap;	label SNAPTotalScore = "SNAP - mean (sd), N"; run;
	data lbwi_demo2; merge lbwi_demo2 (in=a) snap (keep = SNAPTotalScore); if a; run;
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary2, var= SNAPTotalScore, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= IsOutborn, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResus, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResusoxygen, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResuscompression, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResuscpap, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResusepi, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResusintubation, type= bin, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary3, var= BirthResusmask, type= bin, non_param=0, last_var=1);
	* SECTION 4 ***********************************************************************************************************;
	data header4; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Umbilical cord blood gas data"; run;
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary4, var= IsBloodGas, type= bin, non_param=0, first_var=1);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary4, var= cordph, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary4, var= basedeficit, type= cont, non_param=0);
	%descriptive_stat(data_in= lbwi_demo2, data_out= lbwi_demo_summary4, var= arterial, type= bin, non_param=0, last_var=1);
	***********************************************************************************************************************;

* Merge tables and headers;
	data lbwi_demo_summary_2; 
		set 	header1 lbwi_demo_summary1 
				header2 lbwi_demo_summary2
				header3 lbwi_demo_summary3
				header4 lbwi_demo_summary4
		; 
	run;



	data lbwi_demo_summary_2; set lbwi_demo_summary_2; order = _N_; run;
	proc sort data = lbwi_demo_summary_1; by row; run;
	proc sort data = lbwi_demo_summary_2; by row; run;
	data lbwi_demo_summary; merge lbwi_demo_summary_1 (rename = (disp_overall = disp1)) lbwi_demo_summary_2 (rename = (disp_overall = disp2)); by row; run;
	proc sort data = lbwi_demo_summary; by order; run;

	proc sql; select count(*) into :evertxn1 from lbwi_demo where evertxn=0;
	proc sql; select count(*) into :evertxn2 from lbwi_demo where evertxn=1;

	data lbwi_demo_summary; set lbwi_demo_summary; 	
		keep row disp1 disp2; 
		label 	disp1 = "Never Transfused*(n = &evertxn1)"
					disp2 = "Transfused*(n = &evertxn2)";
	run;



	options nodate orientation = portrait;

	ods rtf file = "&output./april2011abstracts/lbwi_demo_summary_by_txn.rtf"  style=journal toc_data startpage = no bodytitle;
		title1 "LBWI Demographic and Birth Characteristics Summary - By Ever Transfused"; 
		footnote1 "*Percentiles for gestational age based on data from 391,681 infants aged 22 to 42 weeks  at birth within 33 US states (1998-2006) as reported by Olsen et al (Pediatrics 2010;125:e214-e224).";
		proc print data = lbwi_demo_summary label noobs split = "*" style(header) = {just=center} contents = "";
			id  row /style(data) = [font_size=1.8 font_style=Roman];
			by  row notsorted;
				var disp1 disp2 /style(data) = [just=center font_size=1.8];
			run;
	ods rtf close;
