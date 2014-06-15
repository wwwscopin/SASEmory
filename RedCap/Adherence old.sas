options ls=120 orientation=portrait fmtsearch=(library) nofmterr;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path";

data crf0; 
	set brent.anti;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	tdf=current_regimen___14 or current_regimen___15;
	if current_regimen___1 then tdf=.;
	if current_regimen___13 then d4t=1; else d4t=0;

	/*
	if tdf or d4t;
	if "3Aug2010"d<=dt_start_tdf<='17Mar2011'd or "3Aug2010"d<=dt_start_ftc_tdf<='17Mar2011'd or "3Aug2010"d<=dt_start_d4t<='17Mar2011'd;
	*/

	start_date=dt_start_tdf;
	if start_date=. then start_date=dt_start_d4t;
	if start_date=. then start_date=dt_start_ftc_d4t;

	if current_regimen___3 then do; dose_day_3=2; pill_dose_3=2;  end; /*Didanosine (DDI)*/
	if current_regimen___4 then do; dose_day_4=1; pill_dose_4=1;  end; /*Efavirenz (EFV)*/
	if current_regimen___5 then do; dose_day_5=1; pill_dose_5=1;  end; /*Emtricitabine (FTC)*/
	if current_regimen___8 then do; dose_day_8=2; pill_dose_8=1;  end;/*Lamivudine (3TC)*/
	if current_regimen___9 then do; dose_day_9=1; pill_dose_9=2;  end;/*Lopinavir/ritonavir or Kaletra (LPV/r)*/
	if current_regimen___10 then do; dose_day_10=2; pill_dose_10=1;  end;/*Nevirapine (NPV)*/
	if current_regimen___13 then do; dose_day_13=2; pill_dose_13=1;  end;/*Stavudine (D4T)*/
	if current_regimen___14 then do; dose_day_14=1; pill_dose_14=1;  end;/*Tenofovir (TDF)*/
	if current_regimen___15 then do; dose_day_15=1; pill_dose_15=1;  end;/*Truvada (FTC/TDF)*/


	dose_day=dose_day_4; 
		if dose_day=. then dose_day=dose_day_14; 
		if dose_day=. then dose_day=dose_day_5; 
		if dose_day=. then dose_day=dose_day_8;
		if dose_day=. then dose_day=dose_day_13;
		if dose_day=. then dose_day=dose_day_3;
		if dose_day=. then dose_day=dose_day_9;

	pill_dose=pill_dose_4; 
		if pill_dose=. then pill_dose=pill_dose_14; 
		if pill_dose=. then pill_dose=pill_dose_5;
		if pill_dose=. then pill_dose=pill_dose_8; 
		if pill_dose=. then pill_dose=pill_dose_13;
		if pill_dose=. then pill_dose=pill_dose_3; 
		if pill_dose=. then pill_dose=pill_dose_9;


	pill_ct=pill_ct_efv; 
		if pill_ct=. then pill_ct=pill_ct_tdf; 
		if pill_ct=. then pill_ct=pill_ct_ftc;
		if pill_ct=. then pill_ct=pill_ct_3tc; 
		if pill_ct=. then pill_ct=pill_ct_d4t;
		if pill_ct=. then pill_ct=pill_ct_ddi; 
		if pill_ct=. then pill_ct=pill_ct_lpv_r;

	keep id patient_id idx tdf d4t dt_start_tdf dt_start_ftc_tdf dt_start_d4t start_date dose_day pill_dose pill_ct;
	*format idx idx. tdf yn.;
run;

proc sort; by idx id; run;
/*proc print;run;*/

data demo;
	set brent.demo;
	*if demographics_complete;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	age=(dt_visit-dob)/365.25;
	keep patient_id id idx dt_visit dob age gender;
	format age 4.1;
run;
proc sort; by idx id; run;
proc print;run;


data lab;
	set brent.lab;
	if laboratory_results_complete;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	if compress(cd4_enroll) in("-77","-88","-99") then cd4=.; else cd4=compress(cd4_enroll)+0;
	if compress(hiv_rna_enroll) in("-77","-88","-99") then vl=.; else vl=compress(hiv_rna_enroll)+0;

	if 0  <=cd4<=49   then ncd=0;
	if 50 <=cd4<=99   then ncd=1;
	if 100<=cd4<=199  then ncd=2;
	if 200<=cd4<=349  then ncd=3;
	if 350<=cd4		  then ncd=4;


	if 400  <=vl<=4999   then nvl=0;
	if 5000 <=vl<=29999  then nvl=1;
	if 30000<=vl<=99999  then nvl=2;
	if 100000<=vl		  then nvl=3;

	keep patient_id id idx cd4 vl ncd nvl;
run;
proc sort; by idx id; run;

data aids;
	set brent.aids;
	if aids_conditions_eeaa_complete;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	num=sum(of infect_num, cand_eso_num, cand_oth_num, cancer_num, coccid_num, crypto_num, cryptospor_num, cmv_ret_num, cmv_oth_num,
		dementia_num, hsv_oth_num, histo_num, isospor_num, ks_num, lip_num, burkitts_num, lymphoma_num, cns_num, mac_num, mtb_num, eptb_num,
		ntm_num, pcp_num, pneumonia_num, pml_num, salmonella_num, toxo_num, wasting_num, other_aids_num1, other_aids_num2, other_aids_num3,
		other_aids_num4, other_aids_num5);
	if num=. then num=0;

	keep patient_id id idx num aids_condition___1-aids_condition___28;
run;
proc sort; by idx id; run;

proc freq; tables aids_condition___1-aids_condition___28;run;

data concom_med;
	set brent.concom_med;
	if concomitant_medicati_v_0;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	keep patient_id id idx;
run;
proc sort; by idx id; run;


data refill;
	set brent.refill;
	if pharmacy_refills_complete;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	dispens1=refill_amt_1+0; delay1=max(dt_refill_1-dt_refill_2-dispens1,0);
	dispens2=refill_amt_2+0; delay2=max(dt_refill_2-dt_refill_3-dispens2,0);
	dispens3=refill_amt_3+0; delay3=max(dt_refill_3-dt_refill_4-dispens3,0);
	dispens4=refill_amt_4+0; delay4=max(dt_refill_4-dt_refill_5-dispens4,0);
	dispens5=refill_amt_5+0; delay5=max(dt_refill_5-dt_refill_6-dispens5,0);
	dispens6=refill_amt_6+0; delay6=max(dt_refill_6-dt_refill_7-dispens6,0);
	dispens7=refill_amt_7+0; delay7=max(dt_refill_7-dt_refill_8-dispens7,0);
	dispens8=refill_amt_8+0; delay8=max(dt_refill_8-dt_refill_9-dispens8,0);
	dispens9=refill_amt_9+0; delay9=max(dt_refill_9-dt_refill_10-dispens9,0);
	dispens10=refill_amt_10+0; 

	delayday=sum(of delay1-delay9);

	keep patient_id id idx dt_refill_1-dt_refill_10 dispens1-dispens10 delayday;
run;
proc sort; by idx id; run;

data crf; 
	merge crf0(in=crf) demo lab aids refill; by idx id; 
	*if crf;
	nmon=(dt_visit-start_date)/30.42;
	pillday=dt_visit-min(of dt_refill_1-dt_refill_10);


	if dt_visit=dt_refill_1 then do;
		dispens=sum(of dispens2-dispens10); /*Should we count the dispens days next to the enrollment date?*/
	end;
	else do;
		dispens=sum(of dispens1-dispens10); /*Should we count the dispens days next to the enrollment date?*/
	end;

	leftday=dispens-pillday;
	expected_pill=leftday*dose_day*pill_dose;

	if expected_pill>0 then do;
		*pill0=(1-(pil_coun-expected_pill))/dispens;
		pill=1-(pill_ct-expected_pill)/dispens;
	end;
	else do;
		*pill0=(1-(pil_coun-expected_pill))/(dispens-expected_pill);
		pill=1-(pill_ct-expected_pill)/(dispens-expected_pill);
	end;

	keep id idx patient_id dt_visit dt_refill_1 tdf d4t start_date idx cd4 vl ncd nvl nmon num pillday leftday expected_pill pill pill_ct dispens delayday dose_day pill_dose;
	format nmon 4.1 start_date date9. pill 7.4;
run;

proc print;
var patient_id dt_visit dt_refill_1;
run;

ods rtf file="pill_count.rtf" style=journal bodytitle;
proc print data=crf noobs label;
title "Pill Counts Outcome";
var  patient_id dispens pillday leftday delayday expected_pill pill_ct pill/style=[cellwidth=0.75in];
label dispens="Total Dispens Days"
	  pillday="Total Number Pill Days"
	  leftday="Total Number of Pill Days Remaning"
	  Expected_pill="Expected Pill Count"
	  delayday="Delay Days"
	  Pill_Ct="Actual Pill Count"
	  Pill="Pill Count (Outcome)"
	  ;
run;
ods rtf close;
