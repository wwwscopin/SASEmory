options ls=120 orientation=portrait fmtsearch=(library) nofmterr spool;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path";
%include "macro.sas";

proc format;
	value gender 0="Male" 1="Female";
	value yn 1='Yes' 2='No';
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 	4='It bothers patient terribly';
	value ny 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
	value age 1="Young Men" 2="Old Men" 3="Young Women" 4="Old Women";
run;


data crf0; 
	set brent.anti;

	tdf=current_regimen___14 or current_regimen___15;
	if current_regimen___1 then tdf=.;
	if current_regimen___13 then d4t=1; else d4t=0;

	/*
	if tdf or d4t;
	if "3Aug2010"d<=dt_start_tdf<='17Mar2011'd or "3Aug2010"d<=dt_start_ftc_tdf<='17Mar2011'd or "3Aug2010"d<=dt_start_d4t<='17Mar2011'd;

	start_date=dt_start_tdf;
	if start_date=. then start_date=dt_start_d4t;
	if start_date=. then start_date=dt_start_ftc_d4t;
	*/

	if current_regimen___1 then do; dose_day_1=2; pill_dose_1=1; drug=1;  end; /*Abacavir (ABC))*/
	if current_regimen___2 then do; dose_day_2=2; pill_dose_2=1; drug=2;  end; /*Combivir (3TC/ZDV))*/
	if current_regimen___3 then do; dose_day_3=2; pill_dose_3=2; drug=3;  end; /*Didanosine (DDI)*/
	if current_regimen___4 then do; dose_day_4=1; pill_dose_4=1; drug=4; end; /*Efavirenz (EFV)*/
	if current_regimen___5 then do; dose_day_5=1; pill_dose_5=1; drug=5; end; /*Emtricitabine (FTC)*/
	if current_regimen___6 then do; dose_day_6=1; pill_dose_6=1; drug=6; end; /*Epzicom (3TC/ABC))*/
	if current_regimen___7 then do; dose_day_7=2; pill_dose_7=1; drug=7; end; /*Indinavir (IDV))*/
	if current_regimen___8 then do; dose_day_8=2; pill_dose_8=1; drug=8; end;/*Lamivudine (3TC)*/
	if current_regimen___9 then do; dose_day_9=1; pill_dose_9=2; drug=9; end;/*Lopinavir/ritonavir or Kaletra (LPV/r)*/
	if current_regimen___10 then do; dose_day_10=2; pill_dose_10=1; drug=10;  end;/*Nevirapine (NPV)*/
	if current_regimen___11 then do; dose_day_11=2; pill_dose_11=1; drug=11;  end;/*Ritonavir (RTV))*/
	if current_regimen___12 then do; dose_day_12=2; pill_dose_12=1; drug=12;  end;/*Saquinavir (SQV))*/
	if current_regimen___13 then do; dose_day_13=2; pill_dose_13=1; drug=13; end;/*Stavudine (D4T)*/
	if current_regimen___14 then do; dose_day_14=1; pill_dose_14=1; drug=14;  end;/*Tenofovir (TDF)*/
	if current_regimen___15 then do; dose_day_15=1; pill_dose_15=1; drug=15; end;/*Truvada (FTC/TDF)*/
	if current_regimen___16 then do; dose_day_16=1; pill_dose_16=1; drug=16; end;/*Zidovudine (ZDV))*/


	dose_day=dose_day_4; 
		if dose_day=. then dose_day=dose_day_14; 
		if dose_day=. then dose_day=dose_day_15; 
		if dose_day=. then dose_day=dose_day_5; 
		if dose_day=. then dose_day=dose_day_8;
		if dose_day=. then dose_day=dose_day_2;
		if dose_day=. then dose_day=dose_day_6;
		if dose_day=. then dose_day=dose_day_13;
		if dose_day=. then dose_day=dose_day_3;
		if dose_day=. then dose_day=dose_day_9;
		if dose_day=. then dose_day=dose_day_1;

	pill_dose=pill_dose_4; 
		if pill_dose=. then pill_dose=pill_dose_14; 
		if pill_dose=. then pill_dose=pill_dose_15; 
		if pill_dose=. then pill_dose=pill_dose_5;
		if pill_dose=. then pill_dose=pill_dose_8; 
		if pill_dose=. then pill_dose=pill_dose_2; 
		if pill_dose=. then pill_dose=pill_dose_6; 
		if pill_dose=. then pill_dose=pill_dose_13;
		if pill_dose=. then pill_dose=pill_dose_3; 
		if pill_dose=. then pill_dose=pill_dose_9;
		if pill_dose=. then pill_dose=pill_dose_1;


	pill_ct=pill_ct_efv; 
		if pill_ct=. then pill_ct=pill_ct_tdf; 
		if pill_ct=. then pill_ct=pill_ct_ftc_tdf; 
		if pill_ct=. then pill_ct=pill_ct_ftc;
		if pill_ct=. then pill_ct=pill_ct_3tc; 
		if pill_ct=. then pill_ct=pill_ct_3tc_zdv; 
		if pill_ct=. then pill_ct=pill_ct_3tc_abc; 
		if pill_ct=. then pill_ct=pill_ct_d4t;
		if pill_ct=. then pill_ct=pill_ct_ddi; 
		if pill_ct=. then pill_ct=pill_ct_lpv_r;
		if pill_ct=. then pill_ct=pill_ct_abc;

	start_date=start_date_pre;
		if start_date=. then start_date=start_date_current;

	keep id patient_id idx tdf d4t dt_start_tdf dt_start_ftc_tdf dt_start_d4t start_date dose_day pill_dose pill_ct drug
		 start_date_pre start_date_current;
	*format idx idx. tdf yn.;
	format drug drug.;
run;
proc sort; by idx id; run;

data demo;
	set brent.demo;
	*if demographics_complete;
	age=(dt_visit-dob)/365.25;
	keep patient_id id idx dt_visit dob age gender;
	format age 4.1 dt_visit date9.;
run;
proc sort; by idx id; run;

proc means data=demo mean std median min max;
	class gender;
	var age;
	output out=age median(age)=median_age;
run;

data _null_;
	set age;
	if gender=0 then call symput("age0", put(median_age,4.1));
	if gender=1 then call symput("age1", put(median_age,4.1));
run;

data demo;
	set demo;
	if gender=0 then do; if age<=&age0 then mf_age=1; else mf_age=2; end;
	else if gender=1 then do; if age<=&age1 then mf_age=3; else mf_age=4; end;
run;

proc freq; 
	tables mf_age;
run;

data lab;
	set brent.lab;
	if laboratory_results_complete;

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

	num=sum(of infect_num, cand_eso_num, cand_oth_num, cancer_num, coccid_num, crypto_num, cryptospor_num, cmv_ret_num, cmv_oth_num,
		dementia_num, hsv_oth_num, histo_num, isospor_num, ks_num, lip_num, burkitts_num, lymphoma_num, cns_num, mac_num, mtb_num, eptb_num,
		ntm_num, pcp_num, pneumonia_num, pml_num, salmonella_num, toxo_num, wasting_num, other_aids_num1, other_aids_num2, other_aids_num3,
		other_aids_num4, other_aids_num5);
	if num=. then num=0;

	keep patient_id id idx num aids_condition___1-aids_condition___28;
run;
proc sort; by idx id; run;
/*
proc freq; tables aids_condition___1-aids_condition___28;run;
*/
data concom_med;
	set brent.concom_med;
	if concomitant_medicati_v_0;

	keep patient_id id idx;
run;
proc sort; by idx id; run;


data refill;
	set brent.refill;
	if pharmacy_refills_complete;


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


data symptom;
	set brent.symptom;
	
	keep patient_id idx id symptom_fatigue symptom_fever symptom_rememb symptom_diarr symptom_sad symptom_nervous 
	symptom_sleep symptom_skin symptom_head symptom_gi symptom_sex sympt_caused;
run;
proc sort; by idx id; run;

data ses_health;
	set brent.ses_health;
	
	keep patient_id idx id income ctran1 ctran4 trans1 trans4 arv_start clinic_feel cmed5 ill;
run;
proc sort; by idx id; run;

/*proc contents data=brent.psycho;run;*/

data psycho;
	set brent.psycho;
	
	rename safe_sex___1=safe_sex1 safe_sex___2=safe_sex2 safe_condom___1=safe_condom1 knows_hiv___1=knows_hiv1 knows_hiv___3=knows_hiv3;
	keep patient_id idx id marital_status safe_sex___1 safe_sex___2 safe_condom___1 practice_safe knows_hiv___1 knows_hiv___3 treat_support
		arv_train session_num total_score;
run;
proc sort; by idx id; run;



data crf; 
	merge crf0(in=crf) demo lab aids refill symptom ses_health psycho; by idx id; 
	*if crf;
	nmon=(dt_visit-start_date)/30.42;
	pillday=dt_visit-min(of dt_refill_1-dt_refill_10);


	if dt_visit=dt_refill_1 then do;
		dispens=sum(of dispens2-dispens10); /*Should we count the dispens days next to the enrollment date?*/
		sum_day=max(of dt_refill_2-dt_refill_10)-min(of dt_refill_2-dt_refill_10);
	end;
	else do;
		dispens=sum(of dispens1-dispens10); /*Should we count the dispens days next to the enrollment date?*/
		sum_day=max(of dt_refill_1-dt_refill_10)-min(of dt_refill_1-dt_refill_10);
	end;

	access=sum_day/dispens;

	mean_dispens=dispens/180;
	leftday=dispens-pillday;
	expected_pill=leftday*dose_day*pill_dose;

	if expected_pill>0 then do;
		pill=1-(pill_ct-expected_pill)/dispens;
	end;
	else do;
		pill=1-(pill_ct-expected_pill)/(dispens-expected_pill);
	end;

	par=(1-pill_ct/dispens)*100;

	keep id idx patient_id dt_visit dt_refill_1 tdf d4t start_date idx cd4 vl ncd nvl nmon num mean_dispens par
		pillday leftday expected_pill pill pill_ct dispens delayday dose_day pill_dose access sum_day age gender
		symptom_fatigue symptom_fever symptom_rememb symptom_diarr symptom_sad symptom_nervous symptom_sleep symptom_skin 
		symptom_head symptom_gi symptom_sex sympt_caused mf_age
		income ctran1 ctran4 trans1 trans4 arv_start clinic_feel cmed5 ill
		marital_status safe_sex1 safe_sex2 safe_condom1 practice_safe knows_hiv1 knows_hiv3 treat_support arv_train session_num total_score;
	format nmon par 4.1 mean_dispens 5.2 start_date date9. pill access 7.4 gender gender. income treat_support yn. 
		symptom_fatigue symptom_sad symptom_nervous symptom. safe_sex1 safe_sex2 ny. idx idx. mf_age age.;
run;

data brent.crf;
	set crf;
run;

/*
proc print data=crf;
var patient_id par age gender nmon num income symptom_fatigue symptom_sad symptom_nervous treat_support safe_sex1 safe_sex2;
run;
*/

proc univariate data=crf plot;
	class idx;
	var par;
run;

proc npar1way data=crf wilcoxon;
	class idx;
	var par num;
run;

proc means data=crf;
	class idx;
	var par;
run;
/*
data temp;
	set crf;
	where mf_age=1;
run;
proc freq data=temp;
	tables (income symptom_fatigue symptom_sad symptom_nervous treat_support safe_sex1 safe_sex2)*idx;
run;
*/

filename myhtml "crf.html";
ods html body=myhtml;

proc logistic data=crf;
	model idx(event='case')=par/scale=none aggregate  rsquare lackfit;
run;

proc logistic data=crf;
	class gender/param=ref ref=first order=internal;
	model idx(event='case')=par gender age nmon num/scale=none aggregate rsquare lackfit;
run;

proc logistic data=crf;
	class gender income(ref=last) symptom_fatigue symptom_sad symptom_nervous treat_support(ref=last) safe_sex1 safe_sex2/param=ref ref=first order=internal;
	model idx(event='case')=par gender age nmon num income symptom_fatigue symptom_sad symptom_nervous treat_support safe_sex1 safe_sex2/selection=backward
                     slentry=0.3 slstay=0.35 scale=none aggregate  rsquare lackfit;
run;
ods html close;


%macro age_log(data, mf_age);
data temp; if 1=1 then delete;run;
data temp;
	set &data;
	where mf_age=&mf_age;
run;

%if &mf_age=1 %then %do; %let txt=Young Men; %end;
%if &mf_age=2 %then %do; %let txt=Old Men; %end;
%if &mf_age=3 %then %do; %let txt=Young Women; %end;
%if &mf_age=4 %then %do; %let txt=Old Women; %end;

filename myhtml "&txt..html";
ods html body=myhtml;

proc logistic data=temp;
	model idx(event='case')=par/scale=none aggregate  rsquare lackfit;
run;

proc logistic data=temp;
	*class gender/param=ref ref=first order=internal;
	model idx(event='case')=par age nmon num/scale=none aggregate rsquare lackfit;
run;

proc logistic data=temp;
	class income(ref=last) /*symptom_fatigue symptom_nervous*/ treat_support(ref=last) /param=ref ref=first order=internal;
	model idx(event='case')=par age nmon num income /*symptom_fatigue symptom_nervous*/ treat_support /scale=none aggregate  rsquare lackfit;
run;
ods html close;
%mend age_log;

%age_log(crf, 1);
%age_log(crf, 2);
%age_log(crf, 3);
%age_log(crf, 4); quit;
