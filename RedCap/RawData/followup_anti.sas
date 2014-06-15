%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\followup_anti.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat current_regimen_follow___1 best32. ;
	informat current_regimen_follow___2 best32. ;
	informat current_regimen_follow___3 best32. ;
	informat current_regimen_follow___4 best32. ;
	informat current_regimen_follow___5 best32. ;
	informat current_regimen_follow___6 best32. ;
	informat current_regimen_follow___7 best32. ;
	informat current_regimen_follow___8 best32. ;
	informat current_regimen_follow___9 best32. ;
	informat current_regimen_follow___10 best32. ;
	informat current_regimen_follow___11 best32. ;
	informat current_regimen_follow___12 best32. ;
	informat current_regimen_follow___13 best32. ;
	informat current_regimen_follow___14 best32. ;
	informat current_regimen_follow___15 best32. ;
	informat current_regimen_follow___16 best32. ;
	informat current_regimen_follow___99 best32. ;
	informat dt_start_abc_follow yymmdd10. ;
	informat dt_stop_abc_follow yymmdd10. ;
	informat dt_refill_abc_follow yymmdd10. ;
	informat dt_start_3tc_zdv_follow yymmdd10. ;
	informat dt_stop_3tc_zdv_follow yymmdd10. ;
	informat dt_refill_3tc_zdv_follow yymmdd10. ;
	informat dt_start_ddi_follow yymmdd10. ;
	informat dt_stop_ddi_follow yymmdd10. ;
	informat dt_refill_ddi_follow yymmdd10. ;
	informat dt_start_efv_follow yymmdd10. ;
	informat dt_stop_efv_follow yymmdd10. ;
	informat dt_refill_efv_follow yymmdd10. ;
	informat dt_start_ftc_follow yymmdd10. ;
	informat dt_stop_ftc_follow yymmdd10. ;
	informat dt_refill_ftc_follow yymmdd10. ;
	informat dt_start_3tc_abc_follow yymmdd10. ;
	informat dt_stop_3tc_abc_follow yymmdd10. ;
	informat dt_refill_3tc_abc_follow yymmdd10. ;
	informat dt_start_idv_follow yymmdd10. ;
	informat dt_stop_idv_follow yymmdd10. ;
	informat dt_refill_idv_follow yymmdd10. ;
	informat dt_start_3tc_follow yymmdd10. ;
	informat dt_stop_3tc_follow yymmdd10. ;
	informat dt_refill_3tc_follow yymmdd10. ;
	informat dt_start_lpv_r_follow yymmdd10. ;
	informat dt_stop_lpv_r_follow yymmdd10. ;
	informat dt_refill_lpv_r_follow yymmdd10. ;
	informat dt_start_nvp_follow yymmdd10. ;
	informat dt_stop_nvp_follow yymmdd10. ;
	informat dt_refill_nvp_follow yymmdd10. ;
	informat dt_start_rtv_follow yymmdd10. ;
	informat dt_stop_rtv_follow yymmdd10. ;
	informat dt_refill_rtv_follow yymmdd10. ;
	informat dt_start_sqv_follow yymmdd10. ;
	informat dt_stop_sqv_follow yymmdd10. ;
	informat dt_refill_sqv_follow yymmdd10. ;
	informat dt_start_d4t_follow yymmdd10. ;
	informat dt_stop_d4t_follow yymmdd10. ;
	informat dt_refill_d4t_follow yymmdd10. ;
	informat dt_start_tdf_follow yymmdd10. ;
	informat dt_stop_tdf_follow yymmdd10. ;
	informat dt_refill_tdf_follow yymmdd10. ;
	informat dt_start_ftc_tdf_follow yymmdd10. ;
	informat dt_stop_ftc_tdf_follow yymmdd10. ;
	informat dt_refill_ftc_tdf_follow yymmdd10. ;
	informat dt_start_zdv_follow yymmdd10. ;
	informat dt_stop_zdv_follow yymmdd10. ;
	informat dt_refill_zdv_follow yymmdd10. ;
	informat other_arv_list_follow $500. ;
	informat dt_start_oth_follow yymmdd10. ;
	informat dt_stop_oth_follow yymmdd10. ;
	informat dt_refill_oth_follow yymmdd10. ;
	informat follow_up_antiretrov_v_0 best32. ;

	format patient_id $500. ;
	format current_regimen_follow___1 best12. ;
	format current_regimen_follow___2 best12. ;
	format current_regimen_follow___3 best12. ;
	format current_regimen_follow___4 best12. ;
	format current_regimen_follow___5 best12. ;
	format current_regimen_follow___6 best12. ;
	format current_regimen_follow___7 best12. ;
	format current_regimen_follow___8 best12. ;
	format current_regimen_follow___9 best12. ;
	format current_regimen_follow___10 best12. ;
	format current_regimen_follow___11 best12. ;
	format current_regimen_follow___12 best12. ;
	format current_regimen_follow___13 best12. ;
	format current_regimen_follow___14 best12. ;
	format current_regimen_follow___15 best12. ;
	format current_regimen_follow___16 best12. ;
	format current_regimen_follow___99 best12. ;
	format dt_start_abc_follow yymmdd10. ;
	format dt_stop_abc_follow yymmdd10. ;
	format dt_refill_abc_follow yymmdd10. ;
	format dt_start_3tc_zdv_follow yymmdd10. ;
	format dt_stop_3tc_zdv_follow yymmdd10. ;
	format dt_refill_3tc_zdv_follow yymmdd10. ;
	format dt_start_ddi_follow yymmdd10. ;
	format dt_stop_ddi_follow yymmdd10. ;
	format dt_refill_ddi_follow yymmdd10. ;
	format dt_start_efv_follow yymmdd10. ;
	format dt_stop_efv_follow yymmdd10. ;
	format dt_refill_efv_follow yymmdd10. ;
	format dt_start_ftc_follow yymmdd10. ;
	format dt_stop_ftc_follow yymmdd10. ;
	format dt_refill_ftc_follow yymmdd10. ;
	format dt_start_3tc_abc_follow yymmdd10. ;
	format dt_stop_3tc_abc_follow yymmdd10. ;
	format dt_refill_3tc_abc_follow yymmdd10. ;
	format dt_start_idv_follow yymmdd10. ;
	format dt_stop_idv_follow yymmdd10. ;
	format dt_refill_idv_follow yymmdd10. ;
	format dt_start_3tc_follow yymmdd10. ;
	format dt_stop_3tc_follow yymmdd10. ;
	format dt_refill_3tc_follow yymmdd10. ;
	format dt_start_lpv_r_follow yymmdd10. ;
	format dt_stop_lpv_r_follow yymmdd10. ;
	format dt_refill_lpv_r_follow yymmdd10. ;
	format dt_start_nvp_follow yymmdd10. ;
	format dt_stop_nvp_follow yymmdd10. ;
	format dt_refill_nvp_follow yymmdd10. ;
	format dt_start_rtv_follow yymmdd10. ;
	format dt_stop_rtv_follow yymmdd10. ;
	format dt_refill_rtv_follow yymmdd10. ;
	format dt_start_sqv_follow yymmdd10. ;
	format dt_stop_sqv_follow yymmdd10. ;
	format dt_refill_sqv_follow yymmdd10. ;
	format dt_start_d4t_follow yymmdd10. ;
	format dt_stop_d4t_follow yymmdd10. ;
	format dt_refill_d4t_follow yymmdd10. ;
	format dt_start_tdf_follow yymmdd10. ;
	format dt_stop_tdf_follow yymmdd10. ;
	format dt_refill_tdf_follow yymmdd10. ;
	format dt_start_ftc_tdf_follow yymmdd10. ;
	format dt_stop_ftc_tdf_follow yymmdd10. ;
	format dt_refill_ftc_tdf_follow yymmdd10. ;
	format dt_start_zdv_follow yymmdd10. ;
	format dt_stop_zdv_follow yymmdd10. ;
	format dt_refill_zdv_follow yymmdd10. ;
	format other_arv_list_follow $500. ;
	format dt_start_oth_follow yymmdd10. ;
	format dt_stop_oth_follow yymmdd10. ;
	format dt_refill_oth_follow yymmdd10. ;
	format follow_up_antiretrov_v_0 best12. ;

input
		patient_id $
		current_regimen_follow___1
		current_regimen_follow___2
		current_regimen_follow___3
		current_regimen_follow___4
		current_regimen_follow___5
		current_regimen_follow___6
		current_regimen_follow___7
		current_regimen_follow___8
		current_regimen_follow___9
		current_regimen_follow___10
		current_regimen_follow___11
		current_regimen_follow___12
		current_regimen_follow___13
		current_regimen_follow___14
		current_regimen_follow___15
		current_regimen_follow___16
		current_regimen_follow___99
		dt_start_abc_follow
		dt_stop_abc_follow
		dt_refill_abc_follow
		dt_start_3tc_zdv_follow
		dt_stop_3tc_zdv_follow
		dt_refill_3tc_zdv_follow
		dt_start_ddi_follow
		dt_stop_ddi_follow
		dt_refill_ddi_follow
		dt_start_efv_follow
		dt_stop_efv_follow
		dt_refill_efv_follow
		dt_start_ftc_follow
		dt_stop_ftc_follow
		dt_refill_ftc_follow
		dt_start_3tc_abc_follow
		dt_stop_3tc_abc_follow
		dt_refill_3tc_abc_follow
		dt_start_idv_follow
		dt_stop_idv_follow
		dt_refill_idv_follow
		dt_start_3tc_follow
		dt_stop_3tc_follow
		dt_refill_3tc_follow
		dt_start_lpv_r_follow
		dt_stop_lpv_r_follow
		dt_refill_lpv_r_follow
		dt_start_nvp_follow
		dt_stop_nvp_follow
		dt_refill_nvp_follow
		dt_start_rtv_follow
		dt_stop_rtv_follow
		dt_refill_rtv_follow
		dt_start_sqv_follow
		dt_stop_sqv_follow
		dt_refill_sqv_follow
		dt_start_d4t_follow
		dt_stop_d4t_follow
		dt_refill_d4t_follow
		dt_start_tdf_follow
		dt_stop_tdf_follow
		dt_refill_tdf_follow
		dt_start_ftc_tdf_follow
		dt_stop_ftc_tdf_follow
		dt_refill_ftc_tdf_follow
		dt_start_zdv_follow
		dt_stop_zdv_follow
		dt_refill_zdv_follow
		other_arv_list_follow $
		dt_start_oth_follow
		dt_stop_oth_follow
		dt_refill_oth_follow
		follow_up_antiretrov_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label current_regimen_follow___1='Antiretrovirals from CURRENT REGIMEN (choice=Abacavir (ABC))';
	label current_regimen_follow___2='Antiretrovirals from CURRENT REGIMEN (choice=Combivir (3TC/ZDV))';
	label current_regimen_follow___3='Antiretrovirals from CURRENT REGIMEN (choice=Didanosine (DDI))';
	label current_regimen_follow___4='Antiretrovirals from CURRENT REGIMEN (choice=Efavirenz (EFV))';
	label current_regimen_follow___5='Antiretrovirals from CURRENT REGIMEN (choice=Emtricitabine (FTC))';
	label current_regimen_follow___6='Antiretrovirals from CURRENT REGIMEN (choice=Epzicom (3TC/ABC))';
	label current_regimen_follow___7='Antiretrovirals from CURRENT REGIMEN (choice=Indinavir (IDV))';
	label current_regimen_follow___8='Antiretrovirals from CURRENT REGIMEN (choice=Lamivudine (3TC))';
	label current_regimen_follow___9='Antiretrovirals from CURRENT REGIMEN (choice=Lopinavir/ritonavir or Kaletra (LPV/r))';
	label current_regimen_follow___10='Antiretrovirals from CURRENT REGIMEN (choice=Nevirapine (NPV))';
	label current_regimen_follow___11='Antiretrovirals from CURRENT REGIMEN (choice=Ritonavir (RTV))';
	label current_regimen_follow___12='Antiretrovirals from CURRENT REGIMEN (choice=Saquinavir (SQV))';
	label current_regimen_follow___13='Antiretrovirals from CURRENT REGIMEN (choice=Stavudine (D4T))';
	label current_regimen_follow___14='Antiretrovirals from CURRENT REGIMEN (choice=Tenofovir (TDF))';
	label current_regimen_follow___15='Antiretrovirals from CURRENT REGIMEN (choice=Truvada (FTC/TDF))';
	label current_regimen_follow___16='Antiretrovirals from CURRENT REGIMEN (choice=Zidovudine (ZDV))';
	label current_regimen_follow___99='Antiretrovirals from CURRENT REGIMEN (choice=Other)';
	label dt_start_abc_follow='(ABC) Start date';
	label dt_stop_abc_follow='Stop date';
	label dt_refill_abc_follow='Date of earliest refill in last 6 mos';
	label dt_start_3tc_zdv_follow='(3TC/ZDV) Start date';
	label dt_stop_3tc_zdv_follow='Stop date';
	label dt_refill_3tc_zdv_follow='Date of earliest refill in last 6 mos';
	label dt_start_ddi_follow='(DDI) Start date';
	label dt_stop_ddi_follow='Stop date';
	label dt_refill_ddi_follow='Date of earliest refill in last 6 mos';
	label dt_start_efv_follow='(EFV) Start date';
	label dt_stop_efv_follow='Stop date';
	label dt_refill_efv_follow='Date of earliest refill in last 6 mos';
	label dt_start_ftc_follow='(FTC) Start date';
	label dt_stop_ftc_follow='Stop date';
	label dt_refill_ftc_follow='Date of earliest refill in last 6 mos';
	label dt_start_3tc_abc_follow='(3TC/ABC) Start date';
	label dt_stop_3tc_abc_follow='Stop date';
	label dt_refill_3tc_abc_follow='Date of earliest refill in last 6 mos';
	label dt_start_idv_follow='(IDV) Start date';
	label dt_stop_idv_follow='Stop date';
	label dt_refill_idv_follow='Date of earliest refill in last 6 mos';
	label dt_start_3tc_follow='(3TC) Start date';
	label dt_stop_3tc_follow='Stop date';
	label dt_refill_3tc_follow='Date of earliest refill in last 6 mos';
	label dt_start_lpv_r_follow='(LPV/R) Start date';
	label dt_stop_lpv_r_follow='Stop date';
	label dt_refill_lpv_r_follow='Date of earliest refill in last 6 mos';
	label dt_start_nvp_follow='(NVP) Start date';
	label dt_stop_nvp_follow='Stop date';
	label dt_refill_nvp_follow='Date of earliest refill in last 6 mos';
	label dt_start_rtv_follow='(RTV) Start date';
	label dt_stop_rtv_follow='Stop date';
	label dt_refill_rtv_follow='Date of earliest refill in last 6 mos';
	label dt_start_sqv_follow='(SQV) Start date';
	label dt_stop_sqv_follow='Stop date';
	label dt_refill_sqv_follow='Date of earliest refill in last 6 mos';
	label dt_start_d4t_follow='(D4T) Start date';
	label dt_stop_d4t_follow='Stop date';
	label dt_refill_d4t_follow='Date of earliest refill in last 6 mos';
	label dt_start_tdf_follow='(TDF) Start date';
	label dt_stop_tdf_follow='Stop date';
	label dt_refill_tdf_follow='Date of earliest refill in last 6 mos';
	label dt_start_ftc_tdf_follow='(FTC/TDF) Start date';
	label dt_stop_ftc_tdf_follow='Stop date';
	label dt_refill_ftc_tdf_follow='Date of earliest refill in last 6 mos';
	label dt_start_zdv_follow='(ZDV) Start date';
	label dt_stop_zdv_follow='Stop date';
	label dt_refill_zdv_follow='Date of earliest refill in last 6 mos';
	label other_arv_list_follow='List';
	label dt_start_oth_follow='(Other ARV) Start date';
	label dt_stop_oth_follow='Stop date';
	label dt_refill_oth_follow='Date of earliest refill in last 6 mos';
	label follow_up_antiretrov_v_0='Complete?';
	run;

proc format;
	value current_regimen_follow___1_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___2_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___3_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___4_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___5_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___6_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___7_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___8_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___9_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___10_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___11_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___12_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___13_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___14_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___15_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___16_ 0='Unchecked' 1='Checked';
	value current_regimen_follow___99_ 0='Unchecked' 1='Checked';
	value follow_up_antiretrov_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format current_regimen_follow___1 current_regimen_follow___1_.;
	format current_regimen_follow___2 current_regimen_follow___2_.;
	format current_regimen_follow___3 current_regimen_follow___3_.;
	format current_regimen_follow___4 current_regimen_follow___4_.;
	format current_regimen_follow___5 current_regimen_follow___5_.;
	format current_regimen_follow___6 current_regimen_follow___6_.;
	format current_regimen_follow___7 current_regimen_follow___7_.;
	format current_regimen_follow___8 current_regimen_follow___8_.;
	format current_regimen_follow___9 current_regimen_follow___9_.;
	format current_regimen_follow___10 current_regimen_follow___10_.;
	format current_regimen_follow___11 current_regimen_follow___11_.;
	format current_regimen_follow___12 current_regimen_follow___12_.;
	format current_regimen_follow___13 current_regimen_follow___13_.;
	format current_regimen_follow___14 current_regimen_follow___14_.;
	format current_regimen_follow___15 current_regimen_follow___15_.;
	format current_regimen_follow___16 current_regimen_follow___16_.;
	format current_regimen_follow___99 current_regimen_follow___99_.;
	format follow_up_antiretrov_v_0 follow_up_antiretrov_v_0_.;
	run;

data brent.followup_anti;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.followup_anti short varnum; run;
