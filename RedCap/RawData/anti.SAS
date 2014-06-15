%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%let path1=H:\SAS_Emory\Consulting\Brent2;
libname brent1 "&path1";

%macro removeOldFile(bye);
%if %sysfunc(exist(&bye.)) %then %do;
proc delete data=&bye.;
run;
%end;
%mend removeOldFile;
%removeOldFile(work.redcap);

data REDCAP;
%let _EFIERR_ = 0;
infile "&path.\csv\anti.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat current_regimen___1 best32. ;
	informat current_regimen___2 best32. ;
	informat current_regimen___3 best32. ;
	informat current_regimen___4 best32. ;
	informat current_regimen___5 best32. ;
	informat current_regimen___6 best32. ;
	informat current_regimen___7 best32. ;
	informat current_regimen___8 best32. ;
	informat current_regimen___9 best32. ;
	informat current_regimen___10 best32. ;
	informat current_regimen___11 best32. ;
	informat current_regimen___12 best32. ;
	informat current_regimen___13 best32. ;
	informat current_regimen___14 best32. ;
	informat current_regimen___15 best32. ;
	informat current_regimen___16 best32. ;
	informat current_regimen___99 best32. ;
	informat pill_ct_abc best32. ;
	informat dt_start_abc yymmdd10. ;
	informat dt_stop_abc yymmdd10. ;
	informat pill_ct_6mos_abc best32. ;
	informat dt_refill_abc yymmdd10. ;
	informat pill_ct_3tc_zdv best32. ;
	informat dt_start_3tc_zdv yymmdd10. ;
	informat dt_stop_3tc_zdv yymmdd10. ;
	informat pill_ct_6mos_3tc_zdv best32. ;
	informat dt_refill_3tc_zdv yymmdd10. ;
	informat pill_ct_ddi best32. ;
	informat dt_start_ddi yymmdd10. ;
	informat dt_stop_ddi yymmdd10. ;
	informat pill_ct_6mos_ddi best32. ;
	informat dt_refill_ddi yymmdd10. ;
	informat pill_ct_efv best32. ;
	informat dt_start_efv yymmdd10. ;
	informat dt_stop_efv yymmdd10. ;
	informat pill_ct_6mos_efv best32. ;
	informat dt_refill_efv yymmdd10. ;
	informat pill_ct_ftc best32. ;
	informat dt_start_ftc yymmdd10. ;
	informat dt_stop_ftc yymmdd10. ;
	informat pill_ct_6mos_ftc best32. ;
	informat dt_refill_ftc yymmdd10. ;
	informat pill_ct_3tc_abc best32. ;
	informat dt_start_3tc_abc yymmdd10. ;
	informat dt_stop_3tc_abc yymmdd10. ;
	informat pill_ct_6mos_3tc_abc best32. ;
	informat dt_refill_3tc_abc yymmdd10. ;
	informat pill_ct_idv best32. ;
	informat dt_start_idv yymmdd10. ;
	informat dt_stop_idv yymmdd10. ;
	informat pill_ct_6mos_idv best32. ;
	informat dt_refill_idv yymmdd10. ;
	informat pill_ct_3tc best32. ;
	informat dt_start_3tc yymmdd10. ;
	informat dt_stop_3tc yymmdd10. ;
	informat pill_ct_6mos_3tc best32. ;
	informat dt_refill_3tc yymmdd10. ;
	informat pill_ct_lpv_r best32. ;
	informat dt_start_lpv_r yymmdd10. ;
	informat dt_stop_lpv_r yymmdd10. ;
	informat pill_ct_6mos_lpv_r best32. ;
	informat dt_refill_lpv_r yymmdd10. ;
	informat pill_ct_nvp best32. ;
	informat dt_start_nvp yymmdd10. ;
	informat dt_stop_nvp yymmdd10. ;
	informat pill_ct_6mos_nvp best32. ;
	informat dt_refill_nvp yymmdd10. ;
	informat pill_ct_rtv best32. ;
	informat dt_start_rtv yymmdd10. ;
	informat dt_stop_rtv yymmdd10. ;
	informat pill_ct_6mos_rtv best32. ;
	informat dt_refill_rtv yymmdd10. ;
	informat pill_ct_sqv best32. ;
	informat dt_start_sqv yymmdd10. ;
	informat dt_stop_sqv yymmdd10. ;
	informat pill_ct_6mos_sqv best32. ;
	informat dt_refill_sqv yymmdd10. ;
	informat pill_ct_d4t best32. ;
	informat dt_start_d4t yymmdd10. ;
	informat dt_stop_d4t yymmdd10. ;
	informat pill_ct_6mos_d4t best32. ;
	informat dt_refill_d4t yymmdd10. ;
	informat pill_ct_tdf best32. ;
	informat dt_start_tdf yymmdd10. ;
	informat dt_stop_tdf yymmdd10. ;
	informat pill_ct_6mos_tdf best32. ;
	informat dt_refill_tdf yymmdd10. ;
	informat pill_ct_ftc_tdf best32. ;
	informat dt_start_ftc_tdf yymmdd10. ;
	informat dt_stop_ftc_tdf yymmdd10. ;
	informat pill_ct_6mos_ftc_tdf best32. ;
	informat dt_refill_ftc_tdf yymmdd10. ;
	informat pill_ct_zdv best32. ;
	informat dt_start_zdv yymmdd10. ;
	informat dt_stop_zdv yymmdd10. ;
	informat pill_ct_6mos_zdv best32. ;
	informat dt_refill_zdv yymmdd10. ;
	informat other_arv_list $500. ;
	informat pill_ct_oth best32. ;
	informat dt_start_oth yymmdd10. ;
	informat dt_stop_oth yymmdd10. ;
	informat pill_ct_6mos_oth best32. ;
	informat dt_refill_oth yymmdd10. ;
	informat previous_regimen___1 best32. ;
	informat previous_regimen___2 best32. ;
	informat previous_regimen___3 best32. ;
	informat previous_regimen___4 best32. ;
	informat previous_regimen___5 best32. ;
	informat previous_regimen___6 best32. ;
	informat previous_regimen___7 best32. ;
	informat previous_regimen___8 best32. ;
	informat previous_regimen___9 best32. ;
	informat previous_regimen___10 best32. ;
	informat previous_regimen___11 best32. ;
	informat previous_regimen___12 best32. ;
	informat previous_regimen___13 best32. ;
	informat previous_regimen___14 best32. ;
	informat previous_regimen___15 best32. ;
	informat previous_regimen___16 best32. ;
	informat previous_regimen___99 best32. ;
	informat dt_start_abc_prev yymmdd10. ;
	informat dt_stop_abc_prev yymmdd10. ;
	informat dt_start_3tc_zdv_prev yymmdd10. ;
	informat dt_stop_3tc_zdv_prev yymmdd10. ;
	informat dt_start_ddi_prev yymmdd10. ;
	informat dt_stop_ddi_prev yymmdd10. ;
	informat dt_start_efv_prev yymmdd10. ;
	informat dt_stop_efv_prev yymmdd10. ;
	informat dt_start_ftc_prev yymmdd10. ;
	informat dt_stop_ftc_prev yymmdd10. ;
	informat dt_start_3tc_abc_prev yymmdd10. ;
	informat dt_stop_3tc_abc_prev yymmdd10. ;
	informat dt_start_idv_prev yymmdd10. ;
	informat dt_stop_idv_prev yymmdd10. ;
	informat dt_start_3tc_prev yymmdd10. ;
	informat dt_stop_3tc_prev yymmdd10. ;
	informat dt_start_lpv_r_prev yymmdd10. ;
	informat dt_stop_lpv_r_prev yymmdd10. ;
	informat dt_start_npv_prev yymmdd10. ;
	informat dt_stop_npv_prev yymmdd10. ;
	informat dt_start_rtv_prev yymmdd10. ;
	informat dt_stop_rtv_prev yymmdd10. ;
	informat dt_start_sqv_prev yymmdd10. ;
	informat dt_stop_sqv_prev yymmdd10. ;
	informat dt_start_d4t_prev yymmdd10. ;
	informat dt_stop_d4t_prev yymmdd10. ;
	informat dt_start_tdf_prev yymmdd10. ;
	informat dt_stop_tdf_prev yymmdd10. ;
	informat dt_start_ftc_tdf_prev yymmdd10. ;
	informat dt_stop_ftc_tdf_prev yymmdd10. ;
	informat dt_start_zdv_prev yymmdd10. ;
	informat dt_stop_zdv_prev yymmdd10. ;
	informat dt_start_oth_prev yymmdd10. ;
	informat dt_stop_oth_prev yymmdd10. ;
	informat antiretrovirals_complete best32. ;

	format patient_id $500. ;
	format current_regimen___1 best12. ;
	format current_regimen___2 best12. ;
	format current_regimen___3 best12. ;
	format current_regimen___4 best12. ;
	format current_regimen___5 best12. ;
	format current_regimen___6 best12. ;
	format current_regimen___7 best12. ;
	format current_regimen___8 best12. ;
	format current_regimen___9 best12. ;
	format current_regimen___10 best12. ;
	format current_regimen___11 best12. ;
	format current_regimen___12 best12. ;
	format current_regimen___13 best12. ;
	format current_regimen___14 best12. ;
	format current_regimen___15 best12. ;
	format current_regimen___16 best12. ;
	format current_regimen___99 best12. ;
	format pill_ct_abc best12. ;
	format dt_start_abc yymmdd10. ;
	format dt_stop_abc yymmdd10. ;
	format pill_ct_6mos_abc best12. ;
	format dt_refill_abc yymmdd10. ;
	format pill_ct_3tc_zdv best12. ;
	format dt_start_3tc_zdv yymmdd10. ;
	format dt_stop_3tc_zdv yymmdd10. ;
	format pill_ct_6mos_3tc_zdv best12. ;
	format dt_refill_3tc_zdv yymmdd10. ;
	format pill_ct_ddi best12. ;
	format dt_start_ddi yymmdd10. ;
	format dt_stop_ddi yymmdd10. ;
	format pill_ct_6mos_ddi best12. ;
	format dt_refill_ddi yymmdd10. ;
	format pill_ct_efv best12. ;
	format dt_start_efv yymmdd10. ;
	format dt_stop_efv yymmdd10. ;
	format pill_ct_6mos_efv best12. ;
	format dt_refill_efv yymmdd10. ;
	format pill_ct_ftc best12. ;
	format dt_start_ftc yymmdd10. ;
	format dt_stop_ftc yymmdd10. ;
	format pill_ct_6mos_ftc best12. ;
	format dt_refill_ftc yymmdd10. ;
	format pill_ct_3tc_abc best12. ;
	format dt_start_3tc_abc yymmdd10. ;
	format dt_stop_3tc_abc yymmdd10. ;
	format pill_ct_6mos_3tc_abc best12. ;
	format dt_refill_3tc_abc yymmdd10. ;
	format pill_ct_idv best12. ;
	format dt_start_idv yymmdd10. ;
	format dt_stop_idv yymmdd10. ;
	format pill_ct_6mos_idv best12. ;
	format dt_refill_idv yymmdd10. ;
	format pill_ct_3tc best12. ;
	format dt_start_3tc yymmdd10. ;
	format dt_stop_3tc yymmdd10. ;
	format pill_ct_6mos_3tc best12. ;
	format dt_refill_3tc yymmdd10. ;
	format pill_ct_lpv_r best12. ;
	format dt_start_lpv_r yymmdd10. ;
	format dt_stop_lpv_r yymmdd10. ;
	format pill_ct_6mos_lpv_r best12. ;
	format dt_refill_lpv_r yymmdd10. ;
	format pill_ct_nvp best12. ;
	format dt_start_nvp yymmdd10. ;
	format dt_stop_nvp yymmdd10. ;
	format pill_ct_6mos_nvp best12. ;
	format dt_refill_nvp yymmdd10. ;
	format pill_ct_rtv best12. ;
	format dt_start_rtv yymmdd10. ;
	format dt_stop_rtv yymmdd10. ;
	format pill_ct_6mos_rtv best12. ;
	format dt_refill_rtv yymmdd10. ;
	format pill_ct_sqv best12. ;
	format dt_start_sqv yymmdd10. ;
	format dt_stop_sqv yymmdd10. ;
	format pill_ct_6mos_sqv best12. ;
	format dt_refill_sqv yymmdd10. ;
	format pill_ct_d4t best12. ;
	format dt_start_d4t yymmdd10. ;
	format dt_stop_d4t yymmdd10. ;
	format pill_ct_6mos_d4t best12. ;
	format dt_refill_d4t yymmdd10. ;
	format pill_ct_tdf best12. ;
	format dt_start_tdf yymmdd10. ;
	format dt_stop_tdf yymmdd10. ;
	format pill_ct_6mos_tdf best12. ;
	format dt_refill_tdf yymmdd10. ;
	format pill_ct_ftc_tdf best12. ;
	format dt_start_ftc_tdf yymmdd10. ;
	format dt_stop_ftc_tdf yymmdd10. ;
	format pill_ct_6mos_ftc_tdf best12. ;
	format dt_refill_ftc_tdf yymmdd10. ;
	format pill_ct_zdv best12. ;
	format dt_start_zdv yymmdd10. ;
	format dt_stop_zdv yymmdd10. ;
	format pill_ct_6mos_zdv best12. ;
	format dt_refill_zdv yymmdd10. ;
	format other_arv_list $500. ;
	format pill_ct_oth best12. ;
	format dt_start_oth yymmdd10. ;
	format dt_stop_oth yymmdd10. ;
	format pill_ct_6mos_oth best12. ;
	format dt_refill_oth yymmdd10. ;
	format previous_regimen___1 best12. ;
	format previous_regimen___2 best12. ;
	format previous_regimen___3 best12. ;
	format previous_regimen___4 best12. ;
	format previous_regimen___5 best12. ;
	format previous_regimen___6 best12. ;
	format previous_regimen___7 best12. ;
	format previous_regimen___8 best12. ;
	format previous_regimen___9 best12. ;
	format previous_regimen___10 best12. ;
	format previous_regimen___11 best12. ;
	format previous_regimen___12 best12. ;
	format previous_regimen___13 best12. ;
	format previous_regimen___14 best12. ;
	format previous_regimen___15 best12. ;
	format previous_regimen___16 best12. ;
	format previous_regimen___99 best12. ;
	format dt_start_abc_prev yymmdd10. ;
	format dt_stop_abc_prev yymmdd10. ;
	format dt_start_3tc_zdv_prev yymmdd10. ;
	format dt_stop_3tc_zdv_prev yymmdd10. ;
	format dt_start_ddi_prev yymmdd10. ;
	format dt_stop_ddi_prev yymmdd10. ;
	format dt_start_efv_prev yymmdd10. ;
	format dt_stop_efv_prev yymmdd10. ;
	format dt_start_ftc_prev yymmdd10. ;
	format dt_stop_ftc_prev yymmdd10. ;
	format dt_start_3tc_abc_prev yymmdd10. ;
	format dt_stop_3tc_abc_prev yymmdd10. ;
	format dt_start_idv_prev yymmdd10. ;
	format dt_stop_idv_prev yymmdd10. ;
	format dt_start_3tc_prev yymmdd10. ;
	format dt_stop_3tc_prev yymmdd10. ;
	format dt_start_lpv_r_prev yymmdd10. ;
	format dt_stop_lpv_r_prev yymmdd10. ;
	format dt_start_npv_prev yymmdd10. ;
	format dt_stop_npv_prev yymmdd10. ;
	format dt_start_rtv_prev yymmdd10. ;
	format dt_stop_rtv_prev yymmdd10. ;
	format dt_start_sqv_prev yymmdd10. ;
	format dt_stop_sqv_prev yymmdd10. ;
	format dt_start_d4t_prev yymmdd10. ;
	format dt_stop_d4t_prev yymmdd10. ;
	format dt_start_tdf_prev yymmdd10. ;
	format dt_stop_tdf_prev yymmdd10. ;
	format dt_start_ftc_tdf_prev yymmdd10. ;
	format dt_stop_ftc_tdf_prev yymmdd10. ;
	format dt_start_zdv_prev yymmdd10. ;
	format dt_stop_zdv_prev yymmdd10. ;
	format dt_start_oth_prev yymmdd10. ;
	format dt_stop_oth_prev yymmdd10. ;
	format antiretrovirals_complete best12. ;

input
		patient_id $
		current_regimen___1
		current_regimen___2
		current_regimen___3
		current_regimen___4
		current_regimen___5
		current_regimen___6
		current_regimen___7
		current_regimen___8
		current_regimen___9
		current_regimen___10
		current_regimen___11
		current_regimen___12
		current_regimen___13
		current_regimen___14
		current_regimen___15
		current_regimen___16
		current_regimen___99
		pill_ct_abc
		dt_start_abc
		dt_stop_abc
		pill_ct_6mos_abc
		dt_refill_abc
		pill_ct_3tc_zdv
		dt_start_3tc_zdv
		dt_stop_3tc_zdv
		pill_ct_6mos_3tc_zdv
		dt_refill_3tc_zdv
		pill_ct_ddi
		dt_start_ddi
		dt_stop_ddi
		pill_ct_6mos_ddi
		dt_refill_ddi
		pill_ct_efv
		dt_start_efv
		dt_stop_efv
		pill_ct_6mos_efv
		dt_refill_efv
		pill_ct_ftc
		dt_start_ftc
		dt_stop_ftc
		pill_ct_6mos_ftc
		dt_refill_ftc
		pill_ct_3tc_abc
		dt_start_3tc_abc
		dt_stop_3tc_abc
		pill_ct_6mos_3tc_abc
		dt_refill_3tc_abc
		pill_ct_idv
		dt_start_idv
		dt_stop_idv
		pill_ct_6mos_idv
		dt_refill_idv
		pill_ct_3tc
		dt_start_3tc
		dt_stop_3tc
		pill_ct_6mos_3tc
		dt_refill_3tc
		pill_ct_lpv_r
		dt_start_lpv_r
		dt_stop_lpv_r
		pill_ct_6mos_lpv_r
		dt_refill_lpv_r
		pill_ct_nvp
		dt_start_nvp
		dt_stop_nvp
		pill_ct_6mos_nvp
		dt_refill_nvp
		pill_ct_rtv
		dt_start_rtv
		dt_stop_rtv
		pill_ct_6mos_rtv
		dt_refill_rtv
		pill_ct_sqv
		dt_start_sqv
		dt_stop_sqv
		pill_ct_6mos_sqv
		dt_refill_sqv
		pill_ct_d4t
		dt_start_d4t
		dt_stop_d4t
		pill_ct_6mos_d4t
		dt_refill_d4t
		pill_ct_tdf
		dt_start_tdf
		dt_stop_tdf
		pill_ct_6mos_tdf
		dt_refill_tdf
		pill_ct_ftc_tdf
		dt_start_ftc_tdf
		dt_stop_ftc_tdf
		pill_ct_6mos_ftc_tdf
		dt_refill_ftc_tdf
		pill_ct_zdv
		dt_start_zdv
		dt_stop_zdv
		pill_ct_6mos_zdv
		dt_refill_zdv
		other_arv_list $
		pill_ct_oth
		dt_start_oth
		dt_stop_oth
		pill_ct_6mos_oth
		dt_refill_oth
		previous_regimen___1
		previous_regimen___2
		previous_regimen___3
		previous_regimen___4
		previous_regimen___5
		previous_regimen___6
		previous_regimen___7
		previous_regimen___8
		previous_regimen___9
		previous_regimen___10
		previous_regimen___11
		previous_regimen___12
		previous_regimen___13
		previous_regimen___14
		previous_regimen___15
		previous_regimen___16
		previous_regimen___99
		dt_start_abc_prev
		dt_stop_abc_prev
		dt_start_3tc_zdv_prev
		dt_stop_3tc_zdv_prev
		dt_start_ddi_prev
		dt_stop_ddi_prev
		dt_start_efv_prev
		dt_stop_efv_prev
		dt_start_ftc_prev
		dt_stop_ftc_prev
		dt_start_3tc_abc_prev
		dt_stop_3tc_abc_prev
		dt_start_idv_prev
		dt_stop_idv_prev
		dt_start_3tc_prev
		dt_stop_3tc_prev
		dt_start_lpv_r_prev
		dt_stop_lpv_r_prev
		dt_start_npv_prev
		dt_stop_npv_prev
		dt_start_rtv_prev
		dt_stop_rtv_prev
		dt_start_sqv_prev
		dt_stop_sqv_prev
		dt_start_d4t_prev
		dt_stop_d4t_prev
		dt_start_tdf_prev
		dt_stop_tdf_prev
		dt_start_ftc_tdf_prev
		dt_stop_ftc_tdf_prev
		dt_start_zdv_prev
		dt_stop_zdv_prev
		dt_start_oth_prev
		dt_stop_oth_prev
		antiretrovirals_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label current_regimen___1='Antiretrovirals from CURRENT REGIMEN (choice=Abacavir (ABC))';
	label current_regimen___2='Antiretrovirals from CURRENT REGIMEN (choice=Combivir (3TC/ZDV))';
	label current_regimen___3='Antiretrovirals from CURRENT REGIMEN (choice=Didanosine (DDI))';
	label current_regimen___4='Antiretrovirals from CURRENT REGIMEN (choice=Efavirenz (EFV))';
	label current_regimen___5='Antiretrovirals from CURRENT REGIMEN (choice=Emtricitabine (FTC))';
	label current_regimen___6='Antiretrovirals from CURRENT REGIMEN (choice=Epzicom (3TC/ABC))';
	label current_regimen___7='Antiretrovirals from CURRENT REGIMEN (choice=Indinavir (IDV))';
	label current_regimen___8='Antiretrovirals from CURRENT REGIMEN (choice=Lamivudine (3TC))';
	label current_regimen___9='Antiretrovirals from CURRENT REGIMEN (choice=Lopinavir/ritonavir or Kaletra (LPV/r))';
	label current_regimen___10='Antiretrovirals from CURRENT REGIMEN (choice=Nevirapine (NPV))';
	label current_regimen___11='Antiretrovirals from CURRENT REGIMEN (choice=Ritonavir (RTV))';
	label current_regimen___12='Antiretrovirals from CURRENT REGIMEN (choice=Saquinavir (SQV))';
	label current_regimen___13='Antiretrovirals from CURRENT REGIMEN (choice=Stavudine (D4T))';
	label current_regimen___14='Antiretrovirals from CURRENT REGIMEN (choice=Tenofovir (TDF))';
	label current_regimen___15='Antiretrovirals from CURRENT REGIMEN (choice=Truvada (FTC/TDF))';
	label current_regimen___16='Antiretrovirals from CURRENT REGIMEN (choice=Zidovudine (ZDV))';
	label current_regimen___99='Antiretrovirals from CURRENT REGIMEN (choice=Other)';
	label pill_ct_abc='(ABC) Pill count at enrollment';
	label dt_start_abc='Start date';
	label dt_stop_abc='Stop date';
	label pill_ct_6mos_abc='Pill count at earliest refill in last 6 mos';
	label dt_refill_abc='Date of earliest refill in last 6 mos';
	label pill_ct_3tc_zdv='(3TC/ZDV) Pill count at enrollment';
	label dt_start_3tc_zdv='Start date';
	label dt_stop_3tc_zdv='Stop date';
	label pill_ct_6mos_3tc_zdv='Pill count at earliest refill in last 6 mos';
	label dt_refill_3tc_zdv='Date of earliest refill in last 6 mos';
	label pill_ct_ddi='(DDI) Pill count at enrollment';
	label dt_start_ddi='Start date';
	label dt_stop_ddi='Stop date';
	label pill_ct_6mos_ddi='Pill count at earliest refill in last 6 mos';
	label dt_refill_ddi='Date of earliest refill in last 6 mos';
	label pill_ct_efv='(EFV) Pill count at enrollment';
	label dt_start_efv='Start date';
	label dt_stop_efv='Stop date';
	label pill_ct_6mos_efv='Pill count at earliest refill in last 6 mos';
	label dt_refill_efv='Date of earliest refill in last 6 mos';
	label pill_ct_ftc='(FTC) Pill count at enrollment';
	label dt_start_ftc='Start date';
	label dt_stop_ftc='Stop date';
	label pill_ct_6mos_ftc='Pill count at earliest refill in last 6 mos';
	label dt_refill_ftc='Date of earliest refill in last 6 mos';
	label pill_ct_3tc_abc='(3TC/ABC) Pill count at enrollment';
	label dt_start_3tc_abc='Start date';
	label dt_stop_3tc_abc='Stop date';
	label pill_ct_6mos_3tc_abc='Pill count at earliest refill in last 6 mos';
	label dt_refill_3tc_abc='Date of earliest refill in last 6 mos';
	label pill_ct_idv='(IDV) Pill count at enrollment';
	label dt_start_idv='Start date';
	label dt_stop_idv='Stop date';
	label pill_ct_6mos_idv='Pill count at earliest refill in last 6 mos';
	label dt_refill_idv='Date of earliest refill in last 6 mos';
	label pill_ct_3tc='(3TC) Pill count at enrollment';
	label dt_start_3tc='Start date';
	label dt_stop_3tc='Stop date';
	label pill_ct_6mos_3tc='Pill count at earliest refill in last 6 mos';
	label dt_refill_3tc='Date of earliest refill in last 6 mos';
	label pill_ct_lpv_r='(LPV/r) Pill count at enrollment';
	label dt_start_lpv_r='Start date';
	label dt_stop_lpv_r='Stop date';
	label pill_ct_6mos_lpv_r='Pill count at earliest refill in last 6 mos';
	label dt_refill_lpv_r='Date of earliest refill in last 6 mos';
	label pill_ct_nvp='(NVP) Pill count at enrollment';
	label dt_start_nvp='Start date';
	label dt_stop_nvp='Stop date';
	label pill_ct_6mos_nvp='Pill count at earliest refill in last 6 mos';
	label dt_refill_nvp='Date of earliest refill in last 6 mos';
	label pill_ct_rtv='(RTV) Pill count at enrollment';
	label dt_start_rtv='Start date';
	label dt_stop_rtv='Stop date';
	label pill_ct_6mos_rtv='Pill count at earliest refill in last 6 mos';
	label dt_refill_rtv='Date of earliest refill in last 6 mos';
	label pill_ct_sqv='(SQV) Pill count at enrollment';
	label dt_start_sqv='Start date';
	label dt_stop_sqv='Stop date';
	label pill_ct_6mos_sqv='Pill count at earliest refill in last 6 mos';
	label dt_refill_sqv='Date of earliest refill in last 6 mos';
	label pill_ct_d4t='(D4T) Pill count at enrollment';
	label dt_start_d4t='Start date';
	label dt_stop_d4t='Stop date';
	label pill_ct_6mos_d4t='Pill count at earliest refill in last 6 mos';
	label dt_refill_d4t='Date of earliest refill in last 6 mos';
	label pill_ct_tdf='(TDF) Pill count at enrollment';
	label dt_start_tdf='Start date';
	label dt_stop_tdf='Stop date';
	label pill_ct_6mos_tdf='Pill count at earliest refill in last 6 mos';
	label dt_refill_tdf='Date of earliest refill in last 6 mos';
	label pill_ct_ftc_tdf='(FTC/TDF) Pill count at enrollment';
	label dt_start_ftc_tdf='Start date';
	label dt_stop_ftc_tdf='Stop date';
	label pill_ct_6mos_ftc_tdf='Pill count at earliest refill in last 6 mos';
	label dt_refill_ftc_tdf='Date of earliest refill in last 6 mos';
	label pill_ct_zdv='(ZDV) Pill count at enrollment';
	label dt_start_zdv='Start date';
	label dt_stop_zdv='Stop date';
	label pill_ct_6mos_zdv='Pill count at earliest refill in last 6 mos';
	label dt_refill_zdv='Date of earliest refill in last 6 mos';
	label other_arv_list='List';
	label pill_ct_oth='(Other) Pill count at enrollment';
	label dt_start_oth='Start date';
	label dt_stop_oth='Stop date';
	label pill_ct_6mos_oth='Pill count at earliest refill in last 6 mos';
	label dt_refill_oth='Date of earliest refill in last 6 mos';
	label previous_regimen___1='PREVIOUS Antiretrovirals (choice=Abacavir (ABC))';
	label previous_regimen___2='PREVIOUS Antiretrovirals (choice=Combivir (3TC/ZDV))';
	label previous_regimen___3='PREVIOUS Antiretrovirals (choice=Didanosine (DDI))';
	label previous_regimen___4='PREVIOUS Antiretrovirals (choice=Efavirenz (EFV))';
	label previous_regimen___5='PREVIOUS Antiretrovirals (choice=Emtricitabine (FTC))';
	label previous_regimen___6='PREVIOUS Antiretrovirals (choice=Epzicom (3TC/ABC))';
	label previous_regimen___7='PREVIOUS Antiretrovirals (choice=Indinavir (IDV))';
	label previous_regimen___8='PREVIOUS Antiretrovirals (choice=Lamivudine (3TC))';
	label previous_regimen___9='PREVIOUS Antiretrovirals (choice=Lopinavir/ritonavir or Kaletra (LPV/r))';
	label previous_regimen___10='PREVIOUS Antiretrovirals (choice=Nevirapine (NPV))';
	label previous_regimen___11='PREVIOUS Antiretrovirals (choice=Ritonavir (RTV))';
	label previous_regimen___12='PREVIOUS Antiretrovirals (choice=Saquinavir (SQV))';
	label previous_regimen___13='PREVIOUS Antiretrovirals (choice=Stavudine (D4T))';
	label previous_regimen___14='PREVIOUS Antiretrovirals (choice=Tenofovir (TDF))';
	label previous_regimen___15='PREVIOUS Antiretrovirals (choice=Truvada (FTC/TDF))';
	label previous_regimen___16='PREVIOUS Antiretrovirals (choice=Zidovudine (ZDV))';
	label previous_regimen___99='PREVIOUS Antiretrovirals (choice=Other)';
	label dt_start_abc_prev='(ABC) Start date';
	label dt_stop_abc_prev='(ABC) Stop date';
	label dt_start_3tc_zdv_prev='(3TC/ZDV) Start date';
	label dt_stop_3tc_zdv_prev='(3TC/ZDV) Stop date';
	label dt_start_ddi_prev='(DDI) Start date';
	label dt_stop_ddi_prev='(DDI) Stop date';
	label dt_start_efv_prev='(EFV) Start date';
	label dt_stop_efv_prev='(EFV) Stop date';
	label dt_start_ftc_prev='(FTC) Start date';
	label dt_stop_ftc_prev='(FTC) Stop date';
	label dt_start_3tc_abc_prev='(3TC/ABC) Start date';
	label dt_stop_3tc_abc_prev='(3TC/ABC) Stop date';
	label dt_start_idv_prev='(IDV) Start date';
	label dt_stop_idv_prev='(IDV) Stop date';
	label dt_start_3tc_prev='(3TC) Start date';
	label dt_stop_3tc_prev='(3TC) Stop date';
	label dt_start_lpv_r_prev='(LPV/r) Start date';
	label dt_stop_lpv_r_prev='(LPV/r) Stop date';
	label dt_start_npv_prev='(NPV) Start date';
	label dt_stop_npv_prev='(NPV) Stop date';
	label dt_start_rtv_prev='(RTV) Start date';
	label dt_stop_rtv_prev='(RTV) Stop date';
	label dt_start_sqv_prev='(SQV) Start date';
	label dt_stop_sqv_prev='(SQV) Stop date';
	label dt_start_d4t_prev='(D4T) Start date';
	label dt_stop_d4t_prev='(D4T) Stop date';
	label dt_start_tdf_prev='(TDF) Start date';
	label dt_stop_tdf_prev='(TDF) Stop date';
	label dt_start_ftc_tdf_prev='(FTC/TDF) Start date';
	label dt_stop_ftc_tdf_prev='(FTC/TDF) Stop date';
	label dt_start_zdv_prev='(ZDV) Start date';
	label dt_stop_zdv_prev='(ZDV) Stop date';
	label dt_start_oth_prev='(Other) Start date';
	label dt_stop_oth_prev='(Other) Stop date';
	label antiretrovirals_complete='Complete?';
	run;

proc format;
	value current_regimen___1_ 0='Unchecked' 1='Checked';
	value current_regimen___2_ 0='Unchecked' 1='Checked';
	value current_regimen___3_ 0='Unchecked' 1='Checked';
	value current_regimen___4_ 0='Unchecked' 1='Checked';
	value current_regimen___5_ 0='Unchecked' 1='Checked';
	value current_regimen___6_ 0='Unchecked' 1='Checked';
	value current_regimen___7_ 0='Unchecked' 1='Checked';
	value current_regimen___8_ 0='Unchecked' 1='Checked';
	value current_regimen___9_ 0='Unchecked' 1='Checked';
	value current_regimen___10_ 0='Unchecked' 1='Checked';
	value current_regimen___11_ 0='Unchecked' 1='Checked';
	value current_regimen___12_ 0='Unchecked' 1='Checked';
	value current_regimen___13_ 0='Unchecked' 1='Checked';
	value current_regimen___14_ 0='Unchecked' 1='Checked';
	value current_regimen___15_ 0='Unchecked' 1='Checked';
	value current_regimen___16_ 0='Unchecked' 1='Checked';
	value current_regimen___99_ 0='Unchecked' 1='Checked';
	value previous_regimen___1_ 0='Unchecked' 1='Checked';
	value previous_regimen___2_ 0='Unchecked' 1='Checked';
	value previous_regimen___3_ 0='Unchecked' 1='Checked';
	value previous_regimen___4_ 0='Unchecked' 1='Checked';
	value previous_regimen___5_ 0='Unchecked' 1='Checked';
	value previous_regimen___6_ 0='Unchecked' 1='Checked';
	value previous_regimen___7_ 0='Unchecked' 1='Checked';
	value previous_regimen___8_ 0='Unchecked' 1='Checked';
	value previous_regimen___9_ 0='Unchecked' 1='Checked';
	value previous_regimen___10_ 0='Unchecked' 1='Checked';
	value previous_regimen___11_ 0='Unchecked' 1='Checked';
	value previous_regimen___12_ 0='Unchecked' 1='Checked';
	value previous_regimen___13_ 0='Unchecked' 1='Checked';
	value previous_regimen___14_ 0='Unchecked' 1='Checked';
	value previous_regimen___15_ 0='Unchecked' 1='Checked';
	value previous_regimen___16_ 0='Unchecked' 1='Checked';
	value previous_regimen___99_ 0='Unchecked' 1='Checked';
	value antiretrovirals_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format current_regimen___1 current_regimen___1_.;
	format current_regimen___2 current_regimen___2_.;
	format current_regimen___3 current_regimen___3_.;
	format current_regimen___4 current_regimen___4_.;
	format current_regimen___5 current_regimen___5_.;
	format current_regimen___6 current_regimen___6_.;
	format current_regimen___7 current_regimen___7_.;
	format current_regimen___8 current_regimen___8_.;
	format current_regimen___9 current_regimen___9_.;
	format current_regimen___10 current_regimen___10_.;
	format current_regimen___11 current_regimen___11_.;
	format current_regimen___12 current_regimen___12_.;
	format current_regimen___13 current_regimen___13_.;
	format current_regimen___14 current_regimen___14_.;
	format current_regimen___15 current_regimen___15_.;
	format current_regimen___16 current_regimen___16_.;
	format current_regimen___99 current_regimen___99_.;
	format previous_regimen___1 previous_regimen___1_.;
	format previous_regimen___2 previous_regimen___2_.;
	format previous_regimen___3 previous_regimen___3_.;
	format previous_regimen___4 previous_regimen___4_.;
	format previous_regimen___5 previous_regimen___5_.;
	format previous_regimen___6 previous_regimen___6_.;
	format previous_regimen___7 previous_regimen___7_.;
	format previous_regimen___8 previous_regimen___8_.;
	format previous_regimen___9 previous_regimen___9_.;
	format previous_regimen___10 previous_regimen___10_.;
	format previous_regimen___11 previous_regimen___11_.;
	format previous_regimen___12 previous_regimen___12_.;
	format previous_regimen___13 previous_regimen___13_.;
	format previous_regimen___14 previous_regimen___14_.;
	format previous_regimen___15 previous_regimen___15_.;
	format previous_regimen___16 previous_regimen___16_.;
	format previous_regimen___99 previous_regimen___99_.;
	format antiretrovirals_complete antiretrovirals_complete_.;
	run;

proc contents data=redcap;
data brent.anti;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	start_date_pre=min(of dt_start_abc_prev dt_start_3tc_zdv_prev dt_start_ddi_prev dt_start_efv_prev dt_start_ftc_prev dt_start_3tc_abc_prev
				  dt_start_idv_prev dt_start_3tc_prev dt_start_lpv_r_prev dt_start_npv_prev dt_start_rtv_prev dt_start_sqv_prev dt_start_d4t_prev
				  dt_start_tdf_prev dt_start_ftc_tdf_prev dt_start_zdv_prev dt_start_oth_prev);

	start_date_current=min(of dt_start_abc dt_start_3tc_zdv dt_start_ddi dt_start_efv dt_start_ftc dt_start_3tc_abc dt_start_idv dt_start_3tc 
				  dt_start_lpv_r dt_start_npv dt_start_rtv dt_start_sqv dt_start_d4t dt_start_tdf dt_start_ftc_tdf dt_start_zdv dt_start_oth);

run;
proc sort; by idx id;run;

/*
proc print data=brent.anti;
	var patient_id start_date_pre start_date_current;
run;

proc contents data=brent.anti short varnum; run;

data anti_tdf;
	set brent.anti;
	if idx;
 	if current_regimen___14 or current_regimen___15;
	if "3Aug2010"d<=start_date<='17Mar2011'd;
run;
*/

data arv;
	merge  brent.anti brent1.tdf(keep=idx id in=A); by idx id;
	if A ;
	attrib dt_start_abc dt_start_3tc_zdv dt_start_ddi dt_start_efv dt_start_ftc dt_start_3tc_abc dt_start_idv dt_start_3tc 
		dt_start_lpv_r dt_start_npv dt_start_rtv dt_start_sqv dt_start_d4t dt_start_tdf dt_start_ftc_tdf dt_start_zdv dt_start_oth label=' ';

	keep  patient_id
		current_regimen___1-current_regimen___16 current_regimen___99
		dt_start_abc dt_start_3tc_zdv dt_start_ddi dt_start_efv dt_start_ftc dt_start_3tc_abc dt_start_idv dt_start_3tc 
		dt_start_lpv_r dt_start_npv dt_start_rtv dt_start_sqv dt_start_d4t dt_start_tdf dt_start_ftc_tdf dt_start_zdv dt_start_oth;
run;


proc export data=arv outfile='ARV.csv' replace label dbms=csv; run;
