options ls=120 orientation=portrait fmtsearch=(library) nofmterr spool;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path.\data";
*%include "tab_stat.sas";

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
	value factive 1='Very active' 2='Somewhat active' 	3='Not active';
	value faith_specify 1='Which one(s)? (choice=Christian)'
		 2='Which one(s)? (choice=Traditional African)'
		 3='Which one(s)? (choice=Hindu)'
		 4='Which one(s)? (choice=Muslim)'
		 5='Which one(s)? (choice=Other)';

	value marital 1='Married' 2='Divorced' 	3='Single living with partner' 4='Single not living with partner' 
		5='Single no partner' 6='Widowed' 	7='Separated';
	value psafe 1='Always (100%)' 2='Often (>50%)' 3='Sometimes (< 50%)' 4='Rarely (< 25%)' 5='Never, or none (0%)' 9='Declined to answer';
	value arv_train 1='0' 2='1-2' 	3='3-5' 4='>5';
	value session_num 0='0' 1='1' 	2='2' 3='3' 4='4' 5='5' 6='6' 7='7' 8='10+';

	value ext 1='None of the time' 2='A little of the time' 3='Some of the time' 4='Most of the time' 	5='All of the time';
	value symptom 0='Patient does not have symptom' 1='It does not bother patient' 	2='It bothers patient a little' 3='It bothers patient a lot' 
		4='It bothers patient terribly';
	value arv_start 1='Sinikithemba (Ridge House)' 2='Siyaphila Inpatient Ward' 	3='Private Provider' 4='DOH Clinic' 5='Other';
	value clinic_feel 1='Pleased' 2='Worried' 	3='Ashamed' 4='Neutral' 	5='Other';
	value sympt 1='Yes' 2='No' 	9='N/A';
	value cd 0="0-49" 1="50-99" 2="100-199" 3="200-349" 4=">=350";
	value race 1='Black' 2='Colored' 	3='White' 4='Indian';
	value employ 	
		1='Are you (choice=Employed full-time)'
		2='Are you (choice=Employed part-time)'
	    3='Are you (choice=Self-employed)'
		4='Are you (choice=Attending school)'
		5='Are you (choice=Disabled)'
		6='Are you (choice=Unemployed seeking work)'
		7='Are you (choice=Unemployed NOT seeking work)'
		8='Are you (choice=Retired)'
		;
	value pay 
		1='How do you pay for clinic meds? (choice=Sponsor)'
		2='How do you pay for clinic meds? (choice=Grant)'
		3='How do you pay for clinic meds? (choice=Employer)'
		4='How do you pay for clinic meds? (choice=Self-pay)'
		5='How do you pay for clinic meds? (choice=Family Member)'
		6='How do you pay for clinic meds? (choice=Spouse)'
		7='How do you pay for clinic meds? (choice=Other)'
		;
	value living 1='Own home' 2='Rent' 3='Stay with family' 4='Stay with friends' 5='Stay with employer';
	value trans
		1='Transport to clinic: (choice=Your car)'
		2='Transport to clinic: (choice=Friend/relative car)'
		3='Transport to clinic: (choice=Meter Taxi)'
		4='Transport to clinic: (choice=Mini Bus/Bus)'
		5='Transport to clinic: (choice=Walk)'
		6='Transport to clinic: (choice=Other (i.e. hired car))'
		;
	value safe_sex
		 1='Which forms of safe sex do you practice? (choice=Abstinence)'
		  2='Which forms of safe sex do you practice? (choice=Condoms)'
		  3='Which forms of safe sex do you practice? (choice=Pull out)'
		  4='Which forms of safe sex do you practice? (choice=None)'
		  5='Which forms of safe sex do you practice? (choice=Other)'
		  ;
	value rhiv
		 1='Who first recommended you to go to an HIV clinic? (choice=Provider (doctor or nurse))'
		 2='Who first recommended you to go to an HIV clinic? (choice=Traditional Healer (Isangoma))'
		 3='Who first recommended you to go to an HIV clinic? (choice=Herbalist (Inyanga))'
		 4='Who first recommended you to go to an HIV clinic? (choice=Friend)'
		 5='Who first recommended you to go to an HIV clinic? (choice=Family)'
		 6='Who first recommended you to go to an HIV clinic? (choice=Member of religious faith)'
		 7='Who first recommended you to go to an HIV clinic? (choice=Other)'
		;

	value hiv_edu 1="Much" 2="Some" 3="Little" 4="None";
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
	value genotype_done 1='Done' 2='Not done';
	value mut_k65_ 0="K (WT)" 1="N" 2="R" 9="Other";
	value mut_k70_ 0="K (WT)" 1="E" 2="G" 3="R" 4="T" 9="Other";
	value mut_m184_ 0="M (WT)" 1="C" 2="I" 3="V" 9="Other";
run;

data demo;
	set brent.demo;
	age=(dt_visit-dob)/365.25;
	edu=education+0;
	keep patient_id id idx dt_visit dob age gender race edu black_ethnicity;
	format age 4.1 idx idx. dt_visit date9. gender gender. race race. black_ethnicity black_ethnicity.;
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
	if current_regimen___4 then efv_nvp="EFV";
	if current_regimen___10 then efv_nvp="NVP";

	if not (previous_regimen___14 or previous_regimen___14) then  do;
		if previous_regimen___3 then nrti_reg="DDI";
		if previous_regimen___10 then nrti_reg="NVP";
		if previous_regimen___13 then nrti_reg="D4T";
		if previous_regimen___16 then nrti_reg="AZT/ZDV";
	end;


	keep id patient_id idx start_date start_date_pre start_date_current current_regimen___4 current_regimen___10 current_regimen___14  efv_nvp nrti_reg
		current_regimen___15 tdf previous_regimen___1-previous_regimen___16 dt_start_tdf dt_start_ftc_tdf dt_start_tdf_prev dt_start_ftc_tdf_prev;
	format current_regimen___4 current_regimen___10 current_regimen___14 current_regimen___15 tdf previous_regimen___1-previous_regimen___16 ny.
		start_date start_date_pre start_date_current dt_start_tdf dt_start_ftc_tdf dt_start_tdf_prev dt_start_ftc_tdf_prev mmddyy.;

run;
proc sort; by idx id; run;

data arv;
	merge  anti brent.tdf(keep=study_no rename=(study_no=patient_id)); by patient_id;
run;

proc export data=anti outfile='ARV.csv' replace label dbms=csv; run;



data rest1;
	set brent.rest1;
	if mut_k65___0 then mut_k65=0; if mut_k65___1 then mut_k65=1;  if mut_k65___2 then mut_k65=2;  if mut_k65___9 then mut_k65=9; 
	if mut_k70___0 then mut_k70=0; if mut_k70___1 then mut_k70=1;  if mut_k70___2 then mut_k70=2;  if mut_k70___3 then mut_k70=9;
	if mut_k70___4 then mut_k70=4; if mut_k70___9 then mut_k70=9;
	if mut_m184___0 then mut_m184=0; if mut_m184___1 then mut_m184=1; if mut_m184___2 then mut_m184=2; if mut_m184___3 then mut_m184=3;
	if mut_m184___9 then mut_m184=9;

	if idx then if sum(of mut_nrti0 mut_nnrti0 )>=1 then RT=1; else RT=0;
	if idx then if sum(of mut_pi_major0 mut_pi_minor0 )>=1 then PR=1; else PR=0;

	if idx and id=156 then genotype_done=1;
	
	keep id patient_id idx mut_nnrti mut_nrti vl_enroll hpp_recent vl_mccord genotype_done /*mut_k65 mut_k70 mut_m184*/ RT PR mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0;
		/*mut_k65___0 mut_k65___1 mut_k65___2 mut_k65___9 mut_k70___0 mut_k70___1 mut_k70___2 mut_k70___3 mut_k70___4 mut_k70___9
		mut_i84___0 mut_i84___1 mut_i84___2 mut_i84___3 mut_i84___9*/;
	format mut_nnrti mut_nrti yn. value genotype_done genotype_done. mut_k65 mut_k65_. mut_k70 mut_k70_. mut_m184 mut_m184_.
		RT PR ny.;
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

	
	max_rna=max(of dt_rna1, dt_rna2, dt_rna3, dt_rna4, dt_rna5, dt_rna6, dt_rna7);
	max_cd4=max(of dt_cd4_1, dt_cd4_2, dt_cd4_3, dt_cd4_4, dt_cd4_5, dt_cd4_6, dt_cd4_7);

	if dt_rna1=dt_hiv_rna_enroll then max_rna=max(of dt_rna2, dt_rna3, dt_rna4, dt_rna5, dt_rna6, dt_rna7);
	if dt_rna2=dt_hiv_rna_enroll then max_rna=max(of dt_rna1, dt_rna3, dt_rna4, dt_rna5, dt_rna6, dt_rna7);
	if dt_rna3=dt_hiv_rna_enroll then max_rna=max(of dt_rna1, dt_rna2, dt_rna4, dt_rna5, dt_rna6, dt_rna7);
	if dt_rna4=dt_hiv_rna_enroll then max_rna=max(of dt_rna2, dt_rna3, dt_rna1, dt_rna5, dt_rna6, dt_rna7);
	if dt_rna5=dt_hiv_rna_enroll then max_rna=max(of dt_rna2, dt_rna3, dt_rna4, dt_rna1, dt_rna6, dt_rna7);
	if dt_rna6=dt_hiv_rna_enroll then max_rna=max(of dt_rna2, dt_rna3, dt_rna4, dt_rna5, dt_rna1, dt_rna7);
	if dt_rna7=dt_hiv_rna_enroll then max_rna=max(of dt_rna2, dt_rna3, dt_rna4, dt_rna5, dt_rna6, dt_rna1);

	if dt_cd4_1=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_3, dt_cd4_4, dt_cd4_5, dt_cd4_6, dt_cd4_7);
	if dt_cd4_2=dt_cd4_enroll then max_cd4=max(of dt_cd4_1, dt_cd4_3, dt_cd4_4, dt_cd4_5, dt_cd4_6, dt_cd4_7);
	if dt_cd4_3=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_1, dt_cd4_4, dt_cd4_5, dt_cd4_6, dt_cd4_7);
	if dt_cd4_4=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_3, dt_cd4_1, dt_cd4_5, dt_cd4_6, dt_cd4_7);
	if dt_cd4_5=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_3, dt_cd4_4, dt_cd4_1, dt_cd4_6, dt_cd4_7);
	if dt_cd4_6=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_3, dt_cd4_4, dt_cd4_5, dt_cd4_1, dt_cd4_7);
	if dt_cd4_7=dt_cd4_enroll then max_cd4=max(of dt_cd4_2, dt_cd4_3, dt_cd4_4, dt_cd4_5, dt_cd4_6, dt_cd4_1);


	if max_rna=dt_rna1 then if dt_rna1<dt_hiv_rna_enroll then baseline_vl=hiv_rna1;
	if baseline_vl<0 then do; if max_rna=dt_rna2 then if dt_rna2<dt_hiv_rna_enroll then baseline_vl=hiv_rna2; end;
	if baseline_vl<0 then do; if max_rna=dt_rna3 then if dt_rna3<dt_hiv_rna_enroll then baseline_vl=hiv_rna3; end;
	if baseline_vl<0 then do; if max_rna=dt_rna4 then if dt_rna4<dt_hiv_rna_enroll then baseline_vl=hiv_rna4; end;
	if baseline_vl<0 then do; if max_rna=dt_rna5 then if dt_rna5<dt_hiv_rna_enroll then baseline_vl=hiv_rna5; end;
	if baseline_vl<0 then do; if max_rna=dt_rna6 then if dt_rna6<dt_hiv_rna_enroll then baseline_vl=hiv_rna6; end;
	if baseline_vl<0 then do; if max_rna=dt_rna7 then if dt_rna7<dt_hiv_rna_enroll then baseline_vl=hiv_rna7; end;

	if max_cd4=dt_cd4_1 then if dt_cd4_1<dt_cd4_enroll  then baseline_cd4=cd4_1;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_2 then if dt_cd4_2<dt_cd4_enroll  then baseline_cd4=cd4_2; end;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_3 then if dt_cd4_3<dt_cd4_enroll  then baseline_cd4=cd4_3; end;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_4 then if dt_cd4_4<dt_cd4_enroll  then baseline_cd4=cd4_4; end;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_5 then if dt_cd4_5<dt_cd4_enroll  then baseline_cd4=cd4_5; end;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_6 then if dt_cd4_6<dt_cd4_enroll  then baseline_cd4=cd4_6; end;
	if baseline_cd4<0 then do; if max_cd4=dt_cd4_7 then if dt_cd4_7<dt_cd4_enroll  then baseline_cd4=cd4_7; end;

	keep patient_id id idx cd4 vl ncd nvl baseline_vl baseline_cd4;
	format ncd cd. dt_rna1-dt_rna7 dt_cd4_1-dt_cd4_7 dt_hiv_rna_enroll dt_cd4_enroll max_rna max_cd4 mmddyy.;
run;
proc sort; by idx id; run;

data dispo;
	set brent.dispo;
	keep patient_id id idx disposition___2 disposition___3;
	format disposition___2 disposition___3 ny.;
run;
proc sort; by idx id; run;

data tdf;
	merge demo anti lab rest1 dispo brent.mut; by idx id;
	if idx and tdf;
	*if "3Aug2010"d<=start_date<='17Mar2011'd;
	if dt_visit>'18Dec2010'd;

	nmon=(dt_visit-min(of dt_start_tdf, dt_start_ftc_tdf, dt_start_tdf_prev, dt_start_ftc_tdf_prev))/30.42;
	format nmon 4.1;
run;

proc export data=tdf outfile='H:\SAS_Emory\RedCap\Data\tdf.csv' dbms=csv replace; run;


data temp;
	set tdf;
	if idx=1;
	keep patient_id mut_m41 mut_44 mut_a62 mut_k65 mut_d67 mut_t69 mut_k70 mut_l74 mut_v75 mut_f77 mut_v90 mut_a98 mut_l100 mut_k101 mut_k103 
	mut_v106 mut_v108 mut_g109 mut_y115 mut_f116 mut_118 mut_e138 mut_q151 mut_v179 mut_y181 mut_m184 mut_y188 mut_g190 mut_l210 mut_t215 
	mut_k219 mut_h221 mut_p225 mut_f227 mut_m230 mut_234 mut_236  mut_238  mut_y318 mut_333 mut_n348 mut_l10 mut_v11  mut_13
	mut_g16  mut_k20  mut_23  mut_l24 mut_d30  mut_v32  mut_l33  mut_35 mut_m36 mut_m46 mut_k43 mut_i47  mut_g48 mut_i50 mut_f53 mut_i54 
 	mut_q58 mut_d60 mut_i62 mut_l63 mut_a71 mut_g73 mut_t74 mut_l76 mut_v77 mut_v82 mut_n83 mut_i84 mut_i85 mut_n88 mut_l89 mut_l90 mut_i93;
run;

proc export data=temp outfile='H:\SAS_Emory\RedCap\Data\tdf_condo.csv' dbms=csv replace; run;
