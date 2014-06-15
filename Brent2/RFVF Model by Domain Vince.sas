options ls=120 orientation=portrait fmtsearch=(library) nofmterr spool;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path.\data";
%include "tab_stat.sas";

proc format;
	value gender 0="Male" 1="Female";
	value black_ethnicity 1='Zulu' 2='Xhosa' 3='Malawian' 4='Other';
	value yn 1='Yes' 2='No';
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 
		2='It bothers patient a little' 3='It bothers patient a lot' 	4='It bothers patient terribly';
	value ny 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
	value age 1="Young Men" 2="Old Men" 3="Young Women" 4="Old Women";
	value freq 0='Never' 1='Rarely' 2='Sometimes' 3='Frequently';
	value factive 1='Active' 0='Not Active/No Religion';
	value faith_specify 1='Which one(s)? (choice=Christian)'
		 2='Which one(s)? (choice=Traditional African)'
		 3='Which one(s)? (choice=Hindu)'
		 4='Which one(s)? (choice=Muslim)'
		 5='Which one(s)? (choice=Other)'
		 9="No religion";

	value marital 1='Married' 2='Divorced' 	3='Single living with partner' 4='Single not living with partner' 
		5='Single no partner' 6='Widowed' 	7='Separated';
	value psafe 1='Always (100%)' 2='Often (>50%)' 3='Sometimes (< 50%)' 4='Rarely (< 25%)' 5='Never, or none (0%)' 9='Declined to answer';
	value arv_train 1='0' 2='1-2' 	3='3-5' 4='>5';
	value session_num 0='0' 1='1' 	2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='10+';

	value ext 1='None of the time' 2='A little of the time' 3='Some of the time' 4='Most of the time' 	5='All of the time';
	
	/*
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 	2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	*/

	value symptom 0='Patient have symptom=No' 1="Patient have symptom=Yes";

	*value arv_start 1='Sinikithemba (Ridge House)' 2='Siyaphila Inpatient Ward' 	3='Private Provider' 4='DOH Clinic' 5='Other';
	value arv_start 1='Sinikithemba (Ridge House)' 2='Other';
	value clinic_feel 1='Pleased' 2='Neutral';
	value sympt 1='Yes' 2='No' 	9='N/A';
	value cd 0="0-49" 1="50-99" 2="100-199" 3="200-349" 4=">=350";
	value race 1='Black' 2='Colored' 	3='White' 4='Indian';
	value employ 
		1="Employed" 0="Unemployed";
		/*	
		1='Are you (choice=Employed full-time)'
		2='Are you (choice=Employed part-time)'
	    3='Are you (choice=Self-employed)'
		4='Are you (choice=Attending school)'
		5='Are you (choice=Disabled)'
		6='Are you (choice=Unemployed seeking work)'
		7='Are you (choice=Unemployed NOT seeking work)'
		8='Are you (choice=Retired)'
		*/
		;
	value pay 
		1="Family Member/Spouse Pay" 2="Self Pay + Other";
		/*
		1='How do you pay for clinic meds? (choice=Sponsor)'
		2='How do you pay for clinic meds? (choice=Grant)'
		3='How do you pay for clinic meds? (choice=Employer)'
		4='How do you pay for clinic meds? (choice=Self-pay)'
		5='How do you pay for clinic meds? (choice=Family Member)'
		6='How do you pay for clinic meds? (choice=Spouse)'
		7='How do you pay for clinic meds? (choice=Other)'
		*/
		;
	/*value living 1='Own home' 2='Rent' 3='Stay with family' 4='Stay with friends' 5='Stay with employer';*/
	value living 1='Own home/Rent' 2='Stay with family/friends/employer';
	value trans 1='Transport to clinic: (choice=Your car)' 2="Transport to clinic: (choice=All Other)"
		/*
		1='Transport to clinic: (choice=Your car)'
		2='Transport to clinic: (choice=Friend/relative car)'
		3='Transport to clinic: (choice=Meter Taxi)'
		4='Transport to clinic: (choice=Mini Bus/Bus)'
		5='Transport to clinic: (choice=Walk)'
		6='Transport to clinic: (choice=Other (i.e. hired car))'
	  */
		;
	value safe_sex
		 1='Safe Sex with other'
		 2='Safe Sex with Condoms'
		 ;
	/*
		  value safe_sex
		  1='Which forms of safe sex do you practice? (choice=Abstinence)'
		  2='Which forms of safe sex do you practice? (choice=Condoms)'
		  3='Which forms of safe sex do you practice? (choice=Pull out)'
		  4='Which forms of safe sex do you practice? (choice=None)'
		  5='Which forms of safe sex do you practice? (choice=Other)'
		  ;
	*/
	value rhiv
		 1='Who first recommended you to go to an HIV clinic? (choice=Provider (doctor or nurse))'
		
		 3='Who first recommended you to go to an HIV clinic? (choice=Herbalist (Inyanga))'
		 4='Who first recommended you to go to an HIV clinic? (choice=Friend)'
		 5='Who first recommended you to go to an HIV clinic? (choice=Family)'
		
		 2='Who first recommended you to go to an HIV clinic? (choice=Other)'
		;

	/*
		value rhiv
		 1='Who first recommended you to go to an HIV clinic? (choice=Provider (doctor or nurse))'
		 2='Who first recommended you to go to an HIV clinic? (choice=Traditional Healer (Isangoma))'
		 3='Who first recommended you to go to an HIV clinic? (choice=Herbalist (Inyanga))'
		 4='Who first recommended you to go to an HIV clinic? (choice=Friend)'
		 5='Who first recommended you to go to an HIV clinic? (choice=Family)'
		 6='Who first recommended you to go to an HIV clinic? (choice=Member of religious faith)'
		 7='Who first recommended you to go to an HIV clinic? (choice=Other)'
		
	*/

	value hivedu 1="Much" 2="Some" 3="Little" 4="None";
	value type 1="MND/ANI" 2="HAD" 3="NA";
	value arv_train_bin 0="0-2" 1="3+";
	value Depre 0="10 or 11" 1="12+";
	value depre_bin 0="10-19" 1="20+";
	value bin 0="No,A Little of time" 1="Some,Most,All of the time";
	value Faith_act 1="No Faith" 0="Other";
	value faith_scaleA 1="Faith, but not active" 0="Other";
	value faith_scaleB 1="Faith, somewhat or very active" 0="Other";
	value FM_HIV 0="none" 1="1-4";
	value DFM_HIV 0="none" 1="1-6";
	value HIV_Edu 0="much" 1="some,little,none";
	value nrbin 0="No" 1="A little,Some,Most,All of the time";
	value psafe_bin 0="Always"  1="Often,Sometimes,Rarely,Never" 9="missing";
	value regimen 1="D4T" 2="ZDV" 3="Other";
	value cd4_level 1=">=350" 0="<350";
	value ses_num 1="0-1" 2="2-4" 3="5+";
	value access_mpr 0="Access<1" 1="Access=1";

	value drug 1='Abacavir (ABC)'
			   2='Combivir (3TC/ZDV)'
			   3='Didanosine (DDI)'
			   4='Efavirenz (EFV)'
			   5='Emtricitabine (FTC)'
			   6='Epzicom (3TC/ABC)'
			   7='Indinavir (IDV)'
			   8='Lamivudine (3TC)'
			   9='Lopinavir/ritonavir or Kaletra (LPV/r)'
			  10='Nevirapine (NPV)'
			  11='Ritonavir (RTV)'
			  12='Saquinavir (SQV)'
			  13='Stavudine (D4T)'
			  14='Tenofovir (TDF)'
			  15='Truvada (FTC/TDF)'
	          16='Zidovudine (ZDV)'
			  ;
run;

data demo;
	set brent.demo;
	age=(dt_visit-dob)/365.25;
	edu=education+0;
	keep patient_id id idx dt_visit dob age gender race edu black_ethnicity;
	format age 4.1 idx idx. dt_visit date9. gender gender. race race. black_ethnicity black_ethnicity.;
run;
proc sort; by idx id; run;

data ses;
	set brent.ses_health(rename=(living=living0 clinic_feel=clinic_feel0 arv_start=arv_start0));
	/*
	if employ1 then employ=1; if employ2 then employ=2;  if employ3 then employ=3; if employ4 then employ=4; 
	if employ5 then employ=5; if employ6 then employ=6;  if employ7 then employ=7; if employ8 then employ=8; 
	*/
	if employ6 or employ7  then employ=0; else employ=1;
	
	/*
	if cmed1 then pay=1; if  cmed2 then pay=2; if  cmed3 then pay=3; if cmed4 then pay=4; if cmed5 then pay=5; 
	if cmed6 then pay=6; if cmed7 then pay=7;
	*/
	if cmed5 or cmed6 then pay=1; else pay=2;
	if living0  in(1,2) then living=1; else living=2;

	/*
	if ctran1 then trans=1; if ctran2 then trans=2;  if ctran3 then trans=3;  if ctran4 then trans=4;  
	if ctran5 then trans=5;  if ctran6 then trans=6; 
	*/

	if ctran1 then trans=1; else trans=2;
	if clinic_feel0=1 then clinic_feel=1; else clinic_feel=2;
	if arv_start0=1 then arv_start=1; else arv_start=2;
	
	keep patient_id id idx income employ pay living trans arv_start clinic_feel hcw_touch treat_poorly rejected talk_loud;
	format idx idx. income yn. employ employ. pay pay. living living. trans trans. arv_start arv_start. clinic_feel clinic_feel. 
		hcw_touch treat_poorly rejected talk_loud freq.; 
run;
proc sort; by idx id; run;

data med_ad;
	set brent.med_adhe;
	if remember_meds___1 or remember_meds___4 or remember_meds___5 or remember_meds___6 or remember_meds___8 or remember_meds___9 then remember_meds_other=1; else remember_meds_other=0;
	keep patient_id id idx remember_meds___2 remember_meds___3 or remember_meds___7 remember_meds_other arvs_home arvs_busy;
	format idx idx. remember_meds___2 remember_meds___3 or remember_meds___7 remember_meds_other ny. arvs_home arvs_busy freq.;
run;
proc sort; by idx id; run;
/*
data med_ad;
	set brent.med_adhe;
run;
proc freq data=med_ad;
tables remember_meds___1-remember_meds___9;
run;
*/

data trt;
	set brent.trt;
	if clinic_rec___1 then rhiv=1;
		if clinic_rec___2 or clinic_rec___6 or clinic_rec___7 then rhiv=2;
			if clinic_rec___3 then rhiv=3;
				if clinic_rec___4 then rhiv=4;
					if clinic_rec___5 then rhiv=5;


	if faith_specify___1 then faith_specify=1;
		if faith_specify___2 then faith_specify=2;
			if faith_specify___3 then faith_specify=3;
				if faith_specify___4 then faith_specify=4;
					if faith_specify___5 then faith_specify=5;

	if faith_active=3 or faith_active=. then faith_act=0; else faith_act=1;
	if faith_specify=. then faith_specify=9;

	keep patient_id id idx faith faith_active rhiv traditional_ever faith_specify faith_active faith_act;
	format idx idx. faith yn. rhiv rhiv. traditional_ever yn. faith_specify faith_specify. faith_act factive.;
run;
proc sort; by idx id; run;

data psyc;
	set brent.psycho(rename=(tired=tired0 nervous=nervous0 nervous_rate=nervous_rate0 hopeless=hopeless0 restless=restless0 
		restless_sit=restless_sit0 depressed=depressed0 depressed_cheer=depressed_cheer0 effort=effort0 worthless=worthless0));
	if knows_hiv___1 or knows_hiv___2 or knows_hiv___3 then knows_hiv=1; else knows_hiv=0;
	if safe_sex___1 then safe_sex=1;  if safe_sex___2 then safe_sex=2;  if safe_sex___3 then safe_sex=1;  
		if safe_sex___4 then safe_sex=1; if safe_sex___5 then safe_sex=1; 
	safe_condom=safe_condom___1;
	partner=(partners+0)>0;
	plive=(partners_live+0)>0;
	ptest=(partners_test+0)>0;
	ppos=(partners_pos+0)>0;
	parv=(partners_arv+0)>0;

	if session_num  in(0,1) then ses_num=1; else if session_num  in(2,3,4) then ses_num=2; if session_num>=5 then ses_num=3;
	if tired0=1 then tired=0; else tired=1;
	if nervous0=1 then nervous=0; else nervous=1;
	if nervous_rate0=1 then nervous_rate=0; else nervous_rate=1;
	if hopeless0=1 then hopeless=0; else hopeless=1;
	if restless0=1 then restless=0; else restless=1;
	if restless_sit0=1 then restless_sit=0; else restless_sit=1;
	if depressed0=1 then depressed=0; else depressed=1;
	if depressed_cheer0=1 then depressed_cheer=0; else depressed_cheer=1;
	if effort0=1 then effort=0; else effort=1;
	if worthless0=1 then worthless=0; else worthless=1;

	keep patient_id id idx marital_status safe_sex safe_condom practice_safe knows_hiv hiv_educate tired ses_num partner plive ptest ppos parv 
		treat_support  arv_train session_num tired nervous nervous_rate hopeless restless restless_sit depressed depressed_cheer effort 
		worthless total_score;
	format idx idx. marital_status marital. treat_support yn.	safe_sex safe_sex. knows_hiv safe_condom partner plive ptest ppos parv ny.  
		practice_safe psafe. arv_train arv_train. session_num  session_num.  hiv_educate hivedu. ses_num ses_num. 
		tired nervous nervous_rate hopeless restless restless_sit depressed depressed_cheer effort worthless ny.;
run;
proc sort; by idx id; run;

data symptom;
	set brent.symptom(rename=(symptom_fatigue=symptom_fatigue0 symptom_fever=symptom_fever0 symptom_rememb=symptom_rememb0 
		symptom_vomit=symptom_vomit0 symptom_diarr=symptom_diarr0 symptom_sad=symptom_sad0 symptom_nervous =symptom_nervous0
		symptom_sleep=symptom_sleep0 symptom_skin=symptom_skin0 symptom_head=symptom_head0 symptom_gi=symptom_gi0 symptom_sex=symptom_sex0
		symptom_waste=symptom_waste0 symptom_hair=symptom_hair0 symptom_pain=symptom_pain0));
	    symptom_fatigue=symptom_fatigue0>0;
		symptom_fever=symptom_fever0>0;
		symptom_rememb=symptom_rememb0>0;
		symptom_vomit=symptom_vomit0>0;
		symptom_diarr=symptom_diarr0>0;
		symptom_sad=symptom_sad0>0;
		symptom_nervous=symptom_nervous0>0;
		symptom_sleep=symptom_sleep0>0;
		symptom_skin=symptom_skin0>0;
		symptom_head=symptom_head0>0;
		symptom_gi=symptom_gi0>0;
		symptom_sex=symptom_sex0>0;
		symptom_waste=symptom_waste0>0;
		symptom_hair=symptom_hair0>0;
		symptom_pain=symptom_pain0>0;


	keep patient_id id idx symptom_fatigue symptom_fever symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous 
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

	if num=0 then tb=0; else tB=1;
	keep patient_id id idx num TB aids_condition___6 aids_condition___27;
	format tb aids_condition___6 aids_condition___27 ny.;
run;
proc sort; by idx id; run;


data nonaids;
	set brent.nonaids;
	keep patient_id id idx non_aids_condition___5 non_aids_condition___16;
	rename non_aids_condition___5=non_aids_condition5 non_aids_condition___16=non_aids_condition16;
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

	if current_regimen___13 then current_regimen=1; 
	if current_regimen___16 then current_regimen=2; 
	if current_regimen not in(1,2) then current_regimen=3; 

	keep id patient_id idx start_date dose_day pill_dose pill_ct drug start_date_pre start_date_current 
		current_regimen;
	format current_regimen regimen. drug drug.;
run;
proc sort; by idx id; run;
/*
proc freq; 
	tables drug;
run;

proc print data=brent.anti;
	where idx=0 and id in(163,288) or idx=1 and id in(62,128);
	var patient_id pill_ct_3tc dt_start_3tc dt_stop_3tc dt_start_3tc_prev dt_stop_3tc_prev pill_ct_nvp dt_start_nvp dt_stop_nvp dt_start_npv_prev dt_stop_npv_prev;
run;

proc print data=anti;
	where drug in(8,10);
	var patient_id drug start_date_pre start_date_current;
	format start_date_pre start_date_current mmddyy10.;
run;
*/

data func;
	set brent.func;
	keep patient_id id idx karn_score;
	format idx idx.;
run;
proc sort; by idx id; run;

data neurocogntive;
	set brent.neurocogntive;
	keep patient_id id idx type;
	format idx idx. type type.;
run;
proc sort; by idx id; run;

data med;
	set brent.med;
	keep patient_id id idx med1-med4;
	format idx idx. med1-med4 ny.;
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
	log_cd4=log10(cd4);

	if ncd=4 then cd4_350=1; else cd4_350=0;

	keep patient_id id idx cd4 vl ncd nvl cd4_350 log_cd4;
	format ncd cd. cd4_350 cd4_level.;
run;
proc sort; by idx id; run;

data refill;
	set brent.refill;

	dispens1 =refill_amt_1+0; 	last_dt1 =dt_refill_1+dispens1;
	dispens2 =refill_amt_2+0; 	last_dt2 =dt_refill_2+dispens2;
	dispens3 =refill_amt_3+0; 	last_dt3 =dt_refill_3+dispens3;
	dispens4 =refill_amt_4+0; 	last_dt4 =dt_refill_4+dispens4;
	dispens5 =refill_amt_5+0; 	last_dt5 =dt_refill_5+dispens5;
	dispens6 =refill_amt_6+0; 	last_dt6 =dt_refill_6+dispens6;
	dispens7 =refill_amt_7+0; 	last_dt7 =dt_refill_7+dispens7;
	dispens8 =refill_amt_8+0; 	last_dt8 =dt_refill_8+dispens8;
	dispens9 =refill_amt_9+0; 	last_dt9 =dt_refill_9+dispens9;
	dispens10=refill_amt_10+0;  last_dt10=dt_refill_10+dispens10;
	
	ttldsup=sum(of dispens1-dispens10);
	index_dt=min(of dt_refill_1-dt_refill_10);
	last_dt=max(of last_dt1-last_dt10);
	duration=last_dt-index_dt;
	if  duration>180 then do;
		dsuptrnc=ttldsup-duration+180;
		mpr=dsuptrnc/180;
	end;
	else do;
		mpr=ttldsup/180;
 	end;
	/*If want to mpr to have max of 1 and duration have max of 180 days*/
	mpr=min(mpr,1.0);
	durtrnc=min(duration,180);

	keep patient_id id idx dt_refill_1-dt_refill_10 dispens1-dispens10 last_dt last_dt1-last_dt10 ttldsup index_dt duration dsuptrnc mpr;
	format last_dt last_dt1-last_dt10 index_dt mmddyy.;
run;
proc sort; by idx id; run;
/*
proc univariate data=refill plot;
	var access;
run;

proc print;
where access>1;
run;
*/

data depress;
	set brent.derivedvar_dec7;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	if practice_safe_bin=9 then practice_safe_bin=1;
	format arv_train_bin arv_train_bin. cheer_bin depressed_bin effort_bin bin. dep_11 depre. dep_binary depre_bin.
		faith_scale_0 faith_act. faith_scale_1 faith_scaleA. faith_scale_2 faith_scaleB. family_HIV_bin FM_HIV. family_died_bin DFM_HIV.
		hiv_educate_bin HIV_edu. nervous_bin restless_bin nrbin. practice_safe_bin psafe_bin.;
run;
proc sort; by idx id; run;


/*
proc contents data=depress short varnum;run;
proc freq;
	tables dep_binary dep_11 faith_scale_0 faith_scale_1 faith_scale_2 practice_safe_bin family_HIV_bin 
		family_died_bin hiv_educate_bin arv_train_bin nervous_bin restless_bin depressed_bin cheer_bin effort_bin;
run;
*/

data wealth;
	set brent.bw;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;
proc sort; by idx id; run;

data rfvf;
	merge demo ses med_ad trt psyc symptom neurocogntive aids nonaids anti func lab refill med depress wealth; by idx id;
	nmon=(dt_visit-start_date)/30.42;
	pillday=dt_visit-min(of dt_refill_1-dt_refill_10);

	

	if dt_visit=dt_refill_1 then do;
		dispens=sum(of dispens2-dispens10); /*Should we count the dispens days next to the enrollment date?*/
		duration1=max(dt_visit,last_dt2)-min(of dt_refill_1-dt_refill_10);
	end;
	else do;
		dispens=sum(of dispens1-dispens10); /*Should we count the dispens days next to the enrollment date?*/
		duration1=max(dt_visit,last_dt1)-min(of dt_refill_1-dt_refill_10);
	end;

	if duration1<=180 then mpr1=dispens/180;
	else mpr1=(dispens-durations1+180)/180;
	mpr1=min(mpr1,1.0);

	if mpr1=1 then access_mpr=1; else access_mpr=0;

	*access=sum_day/dispens;
	mean_dispens=dispens/180;
	expected_pill=(dispens-pillday)*dose_day*pill_dose;

	if expected_pill>0 then do;
		*pill=1-(pill_ct-expected_pill)/dispens;/*Old*/
		pill=1-(pill_ct-expected_pill)/dose_day/pill_dose/dispens;
	end;
	else do;
		*pill=1-(pill_ct-expected_pill)/(dispens-expected_pill);/*Old*/
		pill=1-(pill_ct-expected_pill)/(dispens*dose_day*pill_dose-expected_pill);
	end;

	par=(1-pill_ct/dispens)*100;

	*drop dt_refill_1-dt_refill_10 dispens1-dispens10;
	format type type. dt_visit yymmdd10. access_mpr access_mpr.;
run;

proc means data=rfvf Q1 median Q3;
	var mpr1 pill;
	output out=wbh Q1(mpr1)=Q1_mpr1 Q1(pill)=Q1_pill median(mpr1)=med_mpr1 median(pill)=med_pill Q3(mpr1)=Q3_mpr1 Q3(pill)=Q3_pill;
run;
data _null_;
	set wbh;
	call symput("Q1_mpr1", put(Q1_mpr1,7.4));
	call symput("Q1_pill", put(Q1_pill,7.4));
	call symput("med_mpr1", put(med_mpr1,7.4));
	call symput("med_pill", put(med_pill,7.4));
	call symput("Q3_mpr1", put(Q3_mpr1,7.4));
	call symput("Q3_pill", put(Q3_pill,7.4));
run;

proc format;
	value q_mpr   1="Access<=&Q1_mpr1(Q1)" 2="Access in &Q1_mpr1 ~ &med_mpr1(Q1-Median)" 3="Access in &med_mpr1 ~ &Q3_mpr1(Median-Q3)" 4="Access >&Q3_mpr1(Q3)";
	value q_pill  1="Adherence<=&Q1_pill(Q1)" 2="Adherence in &Q1_pill ~ &med_pill(Q1-Median)" 3="Adherence in &med_pill ~ &Q3_pill(Median-Q3)" 4="Adherence >&Q3_pill(Q3)";
run;
data rfvf;
	set rfvf;
	if mpr1<=&Q1_mpr1 then q_mpr1=1; else if &q1_mpr1<mpr1<=&med_mpr1 then q_mpr1=2; else if &med_mpr1<mpr1<=&q3_mpr1 then q_mpr1=3; else q_mpr1=4;
	if pill<=&Q1_pill then q_pill=1; else if &q1_pill<pill<=&med_pill then q_pill=2; else if &med_pill<pill<=&q3_pill then q_pill=3; else q_pill=4;
	format Q_mpr Q_mpr. Q_pill Q_pill.;
run;

proc contents data=rfvf; run;

ods graphics on;
/** Model 1 =Demo + Socieconomic **/
/*
proc logistic data=rfvf plots=roc;
	class gender income employ pay trans/param=ref ref=first;
	model idx(event="case")=age gender income employ pay edu trans prin1 prin2/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit 
				  clodds=pl;
	units age=5 edu=1;
run;
*/

proc logistic data=rfvf plots=roc;
	class gender income employ pay living trans faith faith_specify faith_act family_HIV_bin partner ptest ppos treat_support
		  tb aids_condition___6 aids_condition___27 rhiv arv_start rhiv arv_train_bin current_regimen med1 med2 med3 med4/param=ref ref=first;
	model idx(event="case")=age gender income employ pay living edu prin1 prin2 trans faith faith_specify faith_act family_HIV_bin partner ptest ppos treat_support
		  tb aids_condition___6 aids_condition___27 rhiv arv_start rhiv arv_train_bin current_regimen med1 med2 med3 med4 nmon/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5 edu=1 prin1=1 prin2=1 nmon=1;
run;

/** Model 2 =Demo + Socieconomic +Psycho + Symptoms + Medical History + Medications  **/
/*With all suscpted variables*/
/*
proc logistic data=rfvf plots=roc;
	class gender income employ pay trans dep_11 effort_bin faith faith_specify faith_act partner 
		  practice_safe_bin safe_condom treat_support clinic_feel 
		  symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused type
		  cd4_350 aids_condition___27 non_aids_condition5
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/param=ref ref=first;
	model idx(event="case")=age gender income employ pay edu trans prin1 prin2 dep_11 effort_bin faith faith_specify faith_act
		         partner practice_safe_bin safe_condom treat_support clinic_feel
		         symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused karn_score type
			     log_cd4 cd4_350 aids_condition___27 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit 
				  clodds=pl;
	units age=5 edu=1 prin1=1 prin2=1  nmon=1 karn_score=10 log_cd4=1;
run;
*/
/*With only domain-out from variables*/
proc logistic data=rfvf plots=roc;
	class gender pay trans dep_11 effort_bin faith faith_act family_HIV_bin practice_safe_bin treat_support clinic_feel 
		  symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex 
		  cd4_350 aids_condition___27 non_aids_condition5
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/param=ref ref=first;
	model idx(event="case")=age gender pay edu trans dep_11 effort_bin faith faith_act family_HIV_bin practice_safe_bin treat_support clinic_feel
		         symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex 
				 log_cd4 aids_condition___27 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit 
				  clodds=pl;
	units age=5 edu=1 nmon=1 log_cd4=1;
run;

/** Model 3 =Demo + Socieconomic +Psycho + Accesss **/
/*
proc logistic data=rfvf plots=roc;
	class gender income employ pay trans dep_11 effort_bin faith faith_specify faith_act partner 
		  practice_safe_bin safe_condom treat_support clinic_feel /param=ref ref=first;
	model idx(event="case")=age gender income employ pay edu trans prin1 prin2 dep_11 effort_bin faith faith_specify faith_act
		         partner practice_safe_bin safe_condom treat_support clinic_feel mpr1/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5 edu=1 prin1=1 prin2=1 mpr1=0.1;
run;
*/

proc logistic data=rfvf plots=roc;
	class gender income employ pay trans dep_11 effort_bin faith faith_specify faith_act family_HIV_bin partner ptest ppos
		  practice_safe_bin safe_condom treat_support clinic_feel access_mpr/param=ref ref=first;
	model idx(event="case")=age gender income employ pay edu trans prin1 prin2 total_score dep_11 effort_bin faith faith_specify faith_act
		         family_HIV_bin partner ptest ppos practice_safe_bin safe_condom treat_support clinic_feel mpr1/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5 edu=1 prin1=1 prin2=1 mpr1=0.1 total_score=1;
run;


/** Model 4 =Demo + Psycho + Symptoms + Medical History + Medications + Adherence **/
/*
proc logistic data=rfvf plots=roc;
	class gender dep_11 effort_bin faith faith_specify faith_act partner 
		  practice_safe_bin safe_condom treat_support clinic_feel 
		  symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused type
		  cd4_350 aids_condition___27 non_aids_condition5
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/param=ref ref=first;
	model idx(event="case")=age gender dep_11 effort_bin faith faith_specify faith_act
		         partner practice_safe_bin safe_condom treat_support clinic_feel
		         symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused karn_score type
			     cd4_350 aids_condition___27 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3 pill/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5 karn_score=10 nmon=1 pill=0.1;
run;
*/

proc logistic data=rfvf plots=roc;
	class gender dep_11 effort_bin faith faith_specify faith_act family_HIV_bin partner practice_safe_bin safe_condom treat_support clinic_feel 
		  symptom_fatigue symptom_fever symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous symptom_sleep 
		  symptom_skin symptom_head symptom_gi symptom_sex symptom_waste symptom_hair sympt_caused 
		  cd4_350 non_aids_condition5
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3 /param=ref ref=first;
	model idx(event="case")=age gender total_score dep_11 effort_bin faith faith_specify faith_act family_HIV_bin
		         partner practice_safe_bin safe_condom treat_support clinic_feel
		         symptom_fatigue symptom_fever symptom_rememb symptom_vomit symptom_diarr symptom_sad symptom_nervous symptom_sleep 
				 symptom_skin symptom_head symptom_gi symptom_sex symptom_waste symptom_hair sympt_caused  karn_score 
			     cd4 log_cd4 cd4_350 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3 pill/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5  nmon=1 pill=0.1 total_score=1 karn_score=10 log_cd4=1;
run;

/** Model 5 =Demo + Socieconomic +Psycho + Symptoms + Medical History + Medications + Access + Adherence **/
/*With all suscepted*/
/*
proc logistic data=rfvf plots=roc;
	class gender income employ pay trans dep_11 effort_bin faith faith_specify faith_act partner 
		  practice_safe_bin safe_condom treat_support clinic_feel 
		  symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused type
		  cd4_350 aids_condition___27 non_aids_condition5
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/param=ref ref=first;
	model idx(event="case")=age gender income employ pay edu trans prin1 prin2 dep_11 effort_bin faith faith_specify faith_act
		         partner practice_safe_bin safe_condom treat_support clinic_feel
		         symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex sympt_caused karn_score type
			     cd4_350 aids_condition___27 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3 mpr1 pill/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit
				  clodds=pl;
	units age=5 edu=1 prin1=1 prin2=1 karn_score=10 nmon=1 mpr1=0.1 pill=0.1;
run;
*/
/*With single-out from domain*/
proc logistic data=rfvf plots=roc;
	class gender pay trans dep_11 effort_bin faith faith_act family_HIV_bin practice_safe_bin treat_support clinic_feel 
		  symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex 
		  cd4_350 aids_condition___27 non_aids_condition5 access_mpr
		  arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3/param=ref ref=first;
	model idx(event="case")=age gender pay edu trans dep_11 effort_bin faith faith_act family_HIV_bin practice_safe_bin treat_support clinic_feel
		         symptom_fatigue symptom_diarr symptom_sad symptom_nervous symptom_skin symptom_sex 
				 log_cd4 aids_condition___27 non_aids_condition5
				 nmon arv_start rhiv current_regimen ses_num arv_train_bin remember_meds___7 med1 med2 med3
				 mpr1 pill/selection=stepwise
                  slentry=0.3
                  slstay=0.35
                  details
                  lackfit 
				  clodds=pl;
	units age=5 edu=1 nmon=1 log_cd4=1 mpr1=0.1 pill=0.1;
run;
ods graphics off;
