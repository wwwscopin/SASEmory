options ls=120 orientation=portrait fmtsearch=(library) nofmterr spool;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path.\data";
%include "tab_stat.sas";

proc format;
	value gender 0="Male" 1="Female";
	value yn 1='Yes' 2='No';
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 	4='It bothers patient terribly';
	value ny 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
	value age 1="Young Men" 2="Old Men" 3="Young Women" 4="Old Women";
	value freq 0='Never (0)' 1='Rarely (1)' 2='Sometimes (2)' 3='Frequently (3)';
	value factive 1='Very active (1)' 2='Somewhat active (2)' 	3='Not active (3)';
	value marital 1='Married (1)' 2='Divorced (2)' 
		3='Single living with partner (3)' 4='Single not living with partner (4)' 
		5='Single no partner (5)' 6='Widowed (6)' 	7='Separated (7)';
	value psafe 1='Always (100%)(1)' 2='Often (>50%)(2)' 3='Sometimes (< 50%)(3)' 4='Rarely (< 25%)(4)' 5='Never, or none (0%)(5)' 9='Declined to answer (9)';
	value arv_train 1='0(1)' 2='1-2 (2)' 	3='3-5 (3)' 4='>5 (4)';
	value session_num 0='0' 1='1' 	2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='10+';

	value ext 1='None of the time (1)' 2='A little of the time (2)' 3='Some of the time (3)' 4='Most of the time (4)' 	5='All of the time (5)';
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 	2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value arv_start 1='Sinikithemba (Ridge House)(1)' 2='Siyaphila Inpatient Ward (2)' 	3='Private Provider (3)' 4='DOH Clinic (4)' 5='Other (5)';
	value clinic_feel 1='Pleased (1)' 2='Worried (2)' 	3='Ashamed (3)' 4='Neutral (4)' 	5='Other (5)';
	value sympt 1='Yes' 2='No' 	9='N/A';
	value cd 0="0-49" 1="50-99" 2="100-199" 3="200-349" 4=">=350";
run;

data demo;
	set brent.demo;
	age=(dt_visit-dob)/365.25;
	keep patient_id id idx dt_visit dob age gender;
	format age 4.1 idx idx. dt_visit date9. gender gender.;
run;
proc sort; by idx id; run;

data ses;
	set brent.ses_health;
	keep patient_id id idx income employ6 living trans1 trans4 arv_start ctran1 ctran4 cmed4 cmed5 clinic_feel ill;
	format idx idx. income yn. employ6 trans1 trans4 ctran1 ctran4 cmed4 cmed5 ny. arv_start arv_start. clinic_feel clinic_feel.; 
run;
proc sort; by idx id; run;

data med_ad;
	set brent.med_adhe;
	keep patient_id id idx remember_meds___3 remember_meds___7 remember_collect___3 arvs_home arvs_busy arvs_forgot arvs_sleep;
	format idx idx. remember_meds___3 remember_meds___7 remember_collect___3 ny. arvs_home arvs_busy arvs_forgot arvs_sleep freq.;
run;
proc sort; by idx id; run;

data trt;
	set brent.trt;
	keep patient_id id idx faith faith_specify___1 faith_specify___2 faith_active clinic_rec___4 clinic_rec___5;
	format idx idx. faith yn. faith_active factive. faith_specify___1 faith_specify___2 clinic_rec___4 clinic_rec___5 ny.;
run;
proc sort; by idx id; run;


data psyc;
	set brent.psycho;
	keep patient_id id idx marital_status safe_sex___1 safe_sex___2 practice_safe knows_hiv___1 knows_hiv___3 treat_support  safe_condom___1
		alcohol_type___2 arv_train session_num services_spec___2 tired nervous hopeless restless depressed worthless total_score;
	format idx idx. marital_status marital. treat_support yn. 
		safe_sex___1 safe_sex___2 knows_hiv___1 knows_hiv___3 alcohol_type___2_ services_spec___2 safe_condom___1 ny.  
		practice_safe psafe. arv_train arv_train. session_num  session_num.  tired nervous hopeless restless depressed worthless ext.;
run;
proc sort; by idx id; run;


data symptom;
	set brent.symptom;
	keep patient_id id idx symptom_fever symptom_fatigue  symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous 
		symptom_sleep symptom_skin symptom_head symptom_gi symptom_sex symptom_waste symptom_hair symptom_pain sympt_caused;
	format idx idx. symptom_fever symptom_fatigue  symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous 
		symptom_sleep symptom_skin symptom_head symptom_gi symptom_sex symptom_waste symptom_hair symptom_pain symptom. 
		sympt_caused sympt.;
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

	keep patient_id id idx num;
run;
proc sort; by idx id; run;


data noaids;
	set brent.nonaids;
	keep patient_id id idx non_aids_condition___5 non_aids_condition___16;
	format idx idx. non_aids_condition___5 non_aids_condition___16 ny.;
run;
proc sort; by idx id; run;


data anti;
	set brent.anti;

	tdf=current_regimen___14 or current_regimen___15;
	if current_regimen___1 then tdf=.;
	if current_regimen___13 then d4t=1; else d4t=0;

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

	keep id patient_id idx start_date dose_day pill_dose pill_ct drug start_date_pre start_date_current;
run;
proc sort; by idx id; run;


data func;
	set brent.func;
	keep patient_id id idx karn_score;
	format idx idx.;
run;
proc sort; by idx id; run;

data lab;
	set brent.lab;
	*if laboratory_results_complete;

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
	format ncd cd.;
run;
proc sort; by idx id; run;

data refill;
	set brent.refill;

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

data rfvf;
	merge demo ses med_ad trt psyc symptom aids noaids anti func lab refill; by idx id;
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
	expected_pill=(dispens-pillday)*dose_day*pill_dose;

	if expected_pill>0 then do;
		pill=1-(pill_ct-expected_pill)/dispens;
	end;
	else do;
		pill=1-(pill_ct-expected_pill)/(dispens-expected_pill);
	end;

	par=(1-pill_ct/dispens)*100;

	drop dt_refill_1-dt_refill_10 dispens1-dispens10;
run;
/*proc contents data=rfvf;run;*/

data brent.rfvf;
	set rfvf;
run;


ods listing close;
* From Demo form;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=age, type=con, label="Age", first_var=1, title="Comparison between Case and Control");
%table(data_in=rfvf,data_out=tab,gvar=idx,var=gender, type=cat);
* From SES Health form;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=income, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=employ6, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=trans1, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=trans4, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=arv_start, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=ctran1, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=ctran4, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=cmed4, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=cmed5, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=clinic_feel, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=ill, type=cat );

* From Med Adherence form;
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=remember_meds___3, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=remember_meds___7, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=arvs_home, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=arvs_busy, type=cat );

* From Alt Treatment/Spiritual from;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=faith, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=faith_specify___1, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=faith_specify___2, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=faith_active, type=cat );
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=clinic_rec___4 , type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=clinic_rec___5 , type=cat );

* From Psychology form;

%table(data_in=rfvf,data_out=tab,gvar=idx,var=marital_status, type=cat, nonparm=0);
%table(data_in=rfvf,data_out=tab,gvar=idx,var=safe_sex___1, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=safe_sex___2, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=safe_condom___1, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=practice_safe, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=knows_hiv___1, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=knows_hiv___3, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=treat_support, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=arv_train, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=session_num, type=cat, nonparm=0);
%table(data_in=rfvf,data_out=tab,gvar=idx,var=tired, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=nervous, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=restless, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=depressed, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=total_score, type=con );

* From Symptom form;

%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_fatigue, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_fever, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_rememb, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_vomit, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_diarr, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_sad, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_nervous, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_sleep, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_skin, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_head, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_gi, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_sex, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=symptom_waste, type=cat );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=sympt_caused, type=cat );

* From Aids form;
*%table(data_in=rfvf,data_out=tab,gvar=idx,var=num, type=con, label="Num of Infection" );
* From Non-Aids form;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=non_aids_condition___5, type=cat );
* From Function form;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=karn_score, type=con, label="Karnofsky Score (%)" );
* From lab form;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=ncd, type=cat, label="CD4 Level");
* Other variables;
%table(data_in=rfvf,data_out=tab,gvar=idx,var=nmon, type=con, label="Duration of ART (months)" );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=access, type=con, label="Access" );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=pill, type=con, label="Adherence" );
%table(data_in=rfvf,data_out=tab,gvar=idx,var=par, type=con, last_var=1, label="(1-pill count/Dispens)(%)" );
ods listing;

proc logistic data=rfvf;
	class gender income  trans1 trans4 arv_start ctran1 ctran4 cmed5 clinic_feel remember_meds___7 arvs_home  faith clinic_rec___5
	safe_sex___1 safe_condom___1 knows_hiv___1 knows_hiv___3 treat_support arv_train session_num nervous restless depressed total_score
	symptom_fatigue symptom_fever symptom_vomit symptom_sad symptom_nervous 
	symptom_skin symptom_head symptom_gi symptom_waste  non_aids_condition___5 ncd	/param=ref ref=first;

	model idx(event="case")=gender income  trans1 trans4 arv_start ctran1 ctran4 cmed5 clinic_feel remember_meds___7 arvs_home  
	faith clinic_rec___5 safe_sex___1 safe_condom___1 knows_hiv___1 knows_hiv___3 treat_support arv_train session_num nervous 
	restless depressed total_score	symptom_fatigue symptom_fever symptom_vomit symptom_sad symptom_nervous 
	symptom_skin symptom_head symptom_gi symptom_waste non_aids_condition___5 ncd
	total_score karn_score nmon pill par  /selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit;
run;

/*
******************  Full Model *************************; 
proc logistic data=rfvf;
	class gender income employ6 trans1 trans4 arv_start ctran1 ctran4 cmed5 clinic_feel 
	remember_meds___7 arvs_home arvs_busy faith clinic_rec___5
	marital_status safe_sex___1 safe_sex___2 safe_condom___1 practice_safe knows_hiv___1 knows_hiv___3
	treat_support arv_train session_num tired nervous restless depressed total_score
	symptom_fatigue symptom_fever symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous symptom_sleep
	symptom_skin symptom_head symptom_gi symptom_sex symptom_waste sympt_caused non_aids_condition___5 ncd	/param=ref ref=first;

	model idx(event="case")=gender income employ6 trans1 trans4 arv_start ctran1 ctran4 cmed5 clinic_feel 
	remember_meds___7 arvs_home arvs_busy faith clinic_rec___5
	marital_status safe_sex___1 safe_sex___2 safe_condom___1 practice_safe knows_hiv___1 knows_hiv___3
	treat_support arv_train session_num tired nervous restless depressed total_score
	symptom_fatigue symptom_fever symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous symptom_sleep
	symptom_skin symptom_head symptom_gi symptom_sex symptom_waste sympt_caused non_aids_condition___5 ncd
	total_score karn_score nmon pill par  /selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit;
run;

******************  Model A  *************************; 
proc logistic data=rfvf plots(only)=(roc);
	class gender clinic_feel  remember_meds___7 clinic_rec___5  safe_sex___1   safe_condom___1 knows_hiv___1  knows_hiv___3
		symptom_nervous   symptom_skin  symptom_waste ncd/param=ref ref=first;
	model idx(event="case")=gender clinic_feel  remember_meds___7 clinic_rec___5  safe_sex___1   safe_condom___1 knows_hiv___1  
		knows_hiv___3	symptom_nervous   symptom_skin  symptom_waste ncd pill par/lackfit;
run;

******************  Model B  *************************; 
proc logistic data=rfvf plots(only)=(roc);
	class trans1 cmed5 faith session_num symptom_fatigue symptom_gi non_aids_condition___5 /param=ref ref=first;
	model idx(event="case")=trans1 cmed5 faith  session_num symptom_fatigue symptom_gi non_aids_condition___5 /lackfit;
run;

******************  Model C  *************************; 
proc logistic data=rfvf plots(only)=(roc);
	class gender clinic_feel  remember_meds___7 clinic_rec___5  knows_hiv___3 symptom_nervous   symptom_waste ncd/param=ref ref=first;
	model idx(event="case")=gender clinic_feel  remember_meds___7 clinic_rec___5  knows_hiv___3 symptom_nervous symptom_waste ncd pill par/lackfit;
run;

******************  Model D  *************************; 
proc logistic data=rfvf plots(only)=(roc);
	class gender clinic_feel  remember_meds___7 faith clinic_rec___5  knows_hiv___3 session_num symptom_fatigue symptom_nervous 
		symptom_waste non_aids_condition___5 ncd/param=ref ref=first;
	model idx(event="case")=gender clinic_feel  remember_meds___7 faith clinic_rec___5  knows_hiv___3 session_num symptom_fatigue 
		symptom_nervous symptom_waste ncd pill par/lackfit;
run;

******************  For possible seperation variables  *************************; 
* 1- arvs_busy;
* 2- employ6;
* 3- sympt_caused;
* 4- marital_status;
* 5- symptom_diarr;
* 6- symptom_sleep;
* 7- symptom_sex;
* 8- safe_sex_2;
* 9- tired;
* 10- practice_safe;
* 11- symptom_rememb;
*/
