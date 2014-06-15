%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye);
%if %sysfunc(exist(&bye.)) %then %do;
proc delete data=&bye.;
run;
%end;
%mend removeOldFile;
%removeOldFile(work.redcap);

data REDCAP;
%let _EFIERR_ = 0;
infile "&path\CSV\followup_aids.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat aids_condition_follow___1 best32. ;
	informat aids_condition_follow___2 best32. ;
	informat aids_condition_follow___3 best32. ;
	informat aids_condition_follow___4 best32. ;
	informat aids_condition_follow___5 best32. ;
	informat aids_condition_follow___6 best32. ;
	informat aids_condition_follow___7 best32. ;
	informat aids_condition_follow___8 best32. ;
	informat aids_condition_follow___9 best32. ;
	informat aids_condition_follow___10 best32. ;
	informat aids_condition_follow___11 best32. ;
	informat aids_condition_follow___12 best32. ;
	informat aids_condition_follow___13 best32. ;
	informat aids_condition_follow___14 best32. ;
	informat aids_condition_follow___15 best32. ;
	informat aids_condition_follow___16 best32. ;
	informat aids_condition_follow___17 best32. ;
	informat aids_condition_follow___18 best32. ;
	informat aids_condition_follow___19 best32. ;
	informat aids_condition_follow___20 best32. ;
	informat aids_condition_follow___21 best32. ;
	informat aids_condition_follow___22 best32. ;
	informat aids_condition_follow___23 best32. ;
	informat aids_condition_follow___24 best32. ;
	informat aids_condition_follow___25 best32. ;
	informat aids_condition_follow___26 best32. ;
	informat aids_condition_follow___27 best32. ;
	informat aids_condition_follow___28 best32. ;
	informat aids_condition_follow___99 best32. ;
	informat infect_site_follow $500. ;
	informat infect_num_follow $500. ;
	informat dt_infect_follow yymmdd10. ;
	informat dt_recent_infect_follow yymmdd10. ;
	informat infect_ongoing_follow best32. ;
	informat cand_eso_num_follow $500. ;
	informat dt_cand_eso_follow yymmdd10. ;
	informat dt_recent_cand_eso_follow yymmdd10. ;
	informat cand_eso_ongoing_follow best32. ;
	informat candida_oth_site_follow $500. ;
	informat cand_oth_num_follow $500. ;
	informat dt_cand_oth_follow yymmdd10. ;
	informat dt_recent_cand_oth_follow yymmdd10. ;
	informat cand_oth_ongoing_follow best32. ;
	informat cancer_num_follow $500. ;
	informat dt_cancer_follow yymmdd10. ;
	informat dt_recent_cancer_follow yymmdd10. ;
	informat cancer_ongoing_follow best32. ;
	informat coccid_site_follow $500. ;
	informat coccid_num_follow $500. ;
	informat dt_coccid_follow yymmdd10. ;
	informat dt_recent_coccid_follow yymmdd10. ;
	informat coccid_ongoing_follow best32. ;
	informat crypto_site_follow $500. ;
	informat crypto_num_follow $500. ;
	informat dt_crypto_follow yymmdd10. ;
	informat dt_recent_crypto_follow yymmdd10. ;
	informat crypto_ongoing_follow best32. ;
	informat cryptospor_site_follow $500. ;
	informat cryptospor_num_follow $500. ;
	informat dt_cryptospor_ret_follow yymmdd10. ;
	informat dt_recent_cryptospor_follow yymmdd10. ;
	informat cryptospor_ongoing_follow best32. ;
	informat cmv_ret_num_follow $500. ;
	informat dt_cmv_ret_follow yymmdd10. ;
	informat dt_recent_cmv_ret_follow yymmdd10. ;
	informat cmv_ret_ongoing_follow best32. ;
	informat cmv_oth_site_follow $500. ;
	informat cmv_oth_num_follow $500. ;
	informat dt_cmv_oth_follow yymmdd10. ;
	informat dt_recent_cmv_oth_follow yymmdd10. ;
	informat cmv_oth_ongoing_follow best32. ;
	informat dementia_num_follow $500. ;
	informat dt_dementia_follow yymmdd10. ;
	informat dt_recent_dementia_follow yymmdd10. ;
	informat dementia_ongoing_follow best32. ;
	informat hsv_site_follow $500. ;
	informat hsv_oth_num_follow $500. ;
	informat dt_hsv_oth_follow yymmdd10. ;
	informat dt_recent_hsv_oth_follow yymmdd10. ;
	informat hsv_oth_ongoing_follow best32. ;
	informat histo_site_follow $500. ;
	informat histo_num_follow $500. ;
	informat dt_histo_follow yymmdd10. ;
	informat dt_recent_histo_follow yymmdd10. ;
	informat histo_ongoing_follow best32. ;
	informat isospor_site_follow $500. ;
	informat isospor_num_follow $500. ;
	informat dt_isospor_follow yymmdd10. ;
	informat dt_recent_isospor_follow yymmdd10. ;
	informat isospor_ongoing_follow best32. ;
	informat ks_site_follow $500. ;
	informat ks_num_follow $500. ;
	informat dt_ks_follow yymmdd10. ;
	informat dt_recent_ks_follow yymmdd10. ;
	informat ks_ongoing_follow best32. ;
	informat lip_num_follow $500. ;
	informat dt_lip_follow yymmdd10. ;
	informat dt_recent_lip_follow yymmdd10. ;
	informat lip_ongoing_follow best32. ;
	informat burkitts_site_follow $500. ;
	informat burkitts_num_follow $500. ;
	informat dt_burkitts_follow yymmdd10. ;
	informat dt_recent_burkitts_follow yymmdd10. ;
	informat burkitts_ongoing_follow best32. ;
	informat lymphoma_site_follow $500. ;
	informat lymphoma_num_follow $500. ;
	informat dt_lymphoma_follow yymmdd10. ;
	informat dt_recent_lymphoma_follow yymmdd10. ;
	informat lymphoma_ongoing_follow best32. ;
	informat cns_num_follow $500. ;
	informat dt_cns_follow yymmdd10. ;
	informat dt_recent_cns_follow yymmdd10. ;
	informat cns_ongoing_follow best32. ;
	informat mac_site_follow $500. ;
	informat mac_num_follow $500. ;
	informat dt_mac_follow yymmdd10. ;
	informat dt_recent_mac_follow yymmdd10. ;
	informat mac_ongoing_follow best32. ;
	informat mtb_num_follow $500. ;
	informat dt_mtb_follow yymmdd10. ;
	informat dt_recent_mtb_follow yymmdd10. ;
	informat mtb_ongoing_follow best32. ;
	informat eptb_site_follow $500. ;
	informat eptb_num_follow $500. ;
	informat eptb_sites_follow $500. ;
	informat dt_eptb_follow yymmdd10. ;
	informat dt_recent_eptb_follow yymmdd10. ;
	informat eptb_ongoing_follow best32. ;
	informat ntm_site_follow $500. ;
	informat ntm_num_follow $500. ;
	informat dt_ntm_follow yymmdd10. ;
	informat dt_recent_ntm_follow yymmdd10. ;
	informat ntm_ongoing_follow best32. ;
	informat pcp_num_follow $500. ;
	informat dt_pcp_follow yymmdd10. ;
	informat dt_recent_pcp_follow yymmdd10. ;
	informat pcp_ongoing_follow best32. ;
	informat pneumonia_num_follow $500. ;
	informat dt_pneumonia_follow yymmdd10. ;
	informat dt_recent_pneumonia_follow yymmdd10. ;
	informat pneumonia_ongoing_follow best32. ;
	informat pml_num_follow $500. ;
	informat dt_pml_follow yymmdd10. ;
	informat dt_recent_pml_follow yymmdd10. ;
	informat pml_ongoing_follow best32. ;
	informat salmonella_site_follow $500. ;
	informat salmonella_num_follow $500. ;
	informat dt_salmonella_follow yymmdd10. ;
	informat dt_recent_salmonella_follow yymmdd10. ;
	informat salmonella_ongoing_follow best32. ;
	informat toxo_site_follow $500. ;
	informat toxo_num_follow $500. ;
	informat dt_toxo_follow yymmdd10. ;
	informat dt_recent_toxo_follow yymmdd10. ;
	informat toxo_ongoing_follow best32. ;
	informat wasting_num_follow $500. ;
	informat dt_wasting_follow yymmdd10. ;
	informat dt_recent_wasting_follow yymmdd10. ;
	informat wasting_ongoing_follow best32. ;
	informat other_aids1_follow $500. ;
	informat other_site1_follow $500. ;
	informat other_aids_num1_follow $500. ;
	informat dt_initial_aids1_follow yymmdd10. ;
	informat dt_recent_aids1_follow yymmdd10. ;
	informat other_aids1_ongoing_follow best32. ;
	informat other_aids2_follow $500. ;
	informat other_site2_follow $500. ;
	informat other_aids_num2_follow $500. ;
	informat dt_initial_aids2_follow yymmdd10. ;
	informat dt_recent_aids2_follow yymmdd10. ;
	informat other_aids2_ongoing_follow best32. ;
	informat other_aids3_follow $500. ;
	informat other_site3_follow $500. ;
	informat other_aids_num3_follow $500. ;
	informat dt_initial_aids3_follow yymmdd10. ;
	informat dt_recent_aids3_follow yymmdd10. ;
	informat other_aids3_ongoing_follow best32. ;
	informat other_aids4_follow $500. ;
	informat other_site4_follow $500. ;
	informat other_aids_num4_follow $500. ;
	informat dt_initial_aids4_follow yymmdd10. ;
	informat dt_recent_aids4_follow yymmdd10. ;
	informat other_aids4_ongoing_follow best32. ;
	informat other_aids5_follow $500. ;
	informat other_site5_follow $500. ;
	informat other_aids_num5_follow $500. ;
	informat dt_initial_aids5_follow yymmdd10. ;
	informat dt_recent_aids5_follow yymmdd10. ;
	informat other_aids5_ongoing_follow best32. ;
	informat follow_up_aids_condi_v_0 best32. ;

	format patient_id $500. ;
	format aids_condition_follow___1 best12. ;
	format aids_condition_follow___2 best12. ;
	format aids_condition_follow___3 best12. ;
	format aids_condition_follow___4 best12. ;
	format aids_condition_follow___5 best12. ;
	format aids_condition_follow___6 best12. ;
	format aids_condition_follow___7 best12. ;
	format aids_condition_follow___8 best12. ;
	format aids_condition_follow___9 best12. ;
	format aids_condition_follow___10 best12. ;
	format aids_condition_follow___11 best12. ;
	format aids_condition_follow___12 best12. ;
	format aids_condition_follow___13 best12. ;
	format aids_condition_follow___14 best12. ;
	format aids_condition_follow___15 best12. ;
	format aids_condition_follow___16 best12. ;
	format aids_condition_follow___17 best12. ;
	format aids_condition_follow___18 best12. ;
	format aids_condition_follow___19 best12. ;
	format aids_condition_follow___20 best12. ;
	format aids_condition_follow___21 best12. ;
	format aids_condition_follow___22 best12. ;
	format aids_condition_follow___23 best12. ;
	format aids_condition_follow___24 best12. ;
	format aids_condition_follow___25 best12. ;
	format aids_condition_follow___26 best12. ;
	format aids_condition_follow___27 best12. ;
	format aids_condition_follow___28 best12. ;
	format aids_condition_follow___99 best12. ;
	format infect_site_follow $500. ;
	format infect_num_follow $500. ;
	format dt_infect_follow yymmdd10. ;
	format dt_recent_infect_follow yymmdd10. ;
	format infect_ongoing_follow best12. ;
	format cand_eso_num_follow $500. ;
	format dt_cand_eso_follow yymmdd10. ;
	format dt_recent_cand_eso_follow yymmdd10. ;
	format cand_eso_ongoing_follow best12. ;
	format candida_oth_site_follow $500. ;
	format cand_oth_num_follow $500. ;
	format dt_cand_oth_follow yymmdd10. ;
	format dt_recent_cand_oth_follow yymmdd10. ;
	format cand_oth_ongoing_follow best12. ;
	format cancer_num_follow $500. ;
	format dt_cancer_follow yymmdd10. ;
	format dt_recent_cancer_follow yymmdd10. ;
	format cancer_ongoing_follow best12. ;
	format coccid_site_follow $500. ;
	format coccid_num_follow $500. ;
	format dt_coccid_follow yymmdd10. ;
	format dt_recent_coccid_follow yymmdd10. ;
	format coccid_ongoing_follow best12. ;
	format crypto_site_follow $500. ;
	format crypto_num_follow $500. ;
	format dt_crypto_follow yymmdd10. ;
	format dt_recent_crypto_follow yymmdd10. ;
	format crypto_ongoing_follow best12. ;
	format cryptospor_site_follow $500. ;
	format cryptospor_num_follow $500. ;
	format dt_cryptospor_ret_follow yymmdd10. ;
	format dt_recent_cryptospor_follow yymmdd10. ;
	format cryptospor_ongoing_follow best12. ;
	format cmv_ret_num_follow $500. ;
	format dt_cmv_ret_follow yymmdd10. ;
	format dt_recent_cmv_ret_follow yymmdd10. ;
	format cmv_ret_ongoing_follow best12. ;
	format cmv_oth_site_follow $500. ;
	format cmv_oth_num_follow $500. ;
	format dt_cmv_oth_follow yymmdd10. ;
	format dt_recent_cmv_oth_follow yymmdd10. ;
	format cmv_oth_ongoing_follow best12. ;
	format dementia_num_follow $500. ;
	format dt_dementia_follow yymmdd10. ;
	format dt_recent_dementia_follow yymmdd10. ;
	format dementia_ongoing_follow best12. ;
	format hsv_site_follow $500. ;
	format hsv_oth_num_follow $500. ;
	format dt_hsv_oth_follow yymmdd10. ;
	format dt_recent_hsv_oth_follow yymmdd10. ;
	format hsv_oth_ongoing_follow best12. ;
	format histo_site_follow $500. ;
	format histo_num_follow $500. ;
	format dt_histo_follow yymmdd10. ;
	format dt_recent_histo_follow yymmdd10. ;
	format histo_ongoing_follow best12. ;
	format isospor_site_follow $500. ;
	format isospor_num_follow $500. ;
	format dt_isospor_follow yymmdd10. ;
	format dt_recent_isospor_follow yymmdd10. ;
	format isospor_ongoing_follow best12. ;
	format ks_site_follow $500. ;
	format ks_num_follow $500. ;
	format dt_ks_follow yymmdd10. ;
	format dt_recent_ks_follow yymmdd10. ;
	format ks_ongoing_follow best12. ;
	format lip_num_follow $500. ;
	format dt_lip_follow yymmdd10. ;
	format dt_recent_lip_follow yymmdd10. ;
	format lip_ongoing_follow best12. ;
	format burkitts_site_follow $500. ;
	format burkitts_num_follow $500. ;
	format dt_burkitts_follow yymmdd10. ;
	format dt_recent_burkitts_follow yymmdd10. ;
	format burkitts_ongoing_follow best12. ;
	format lymphoma_site_follow $500. ;
	format lymphoma_num_follow $500. ;
	format dt_lymphoma_follow yymmdd10. ;
	format dt_recent_lymphoma_follow yymmdd10. ;
	format lymphoma_ongoing_follow best12. ;
	format cns_num_follow $500. ;
	format dt_cns_follow yymmdd10. ;
	format dt_recent_cns_follow yymmdd10. ;
	format cns_ongoing_follow best12. ;
	format mac_site_follow $500. ;
	format mac_num_follow $500. ;
	format dt_mac_follow yymmdd10. ;
	format dt_recent_mac_follow yymmdd10. ;
	format mac_ongoing_follow best12. ;
	format mtb_num_follow $500. ;
	format dt_mtb_follow yymmdd10. ;
	format dt_recent_mtb_follow yymmdd10. ;
	format mtb_ongoing_follow best12. ;
	format eptb_site_follow $500. ;
	format eptb_num_follow $500. ;
	format eptb_sites_follow $500. ;
	format dt_eptb_follow yymmdd10. ;
	format dt_recent_eptb_follow yymmdd10. ;
	format eptb_ongoing_follow best12. ;
	format ntm_site_follow $500. ;
	format ntm_num_follow $500. ;
	format dt_ntm_follow yymmdd10. ;
	format dt_recent_ntm_follow yymmdd10. ;
	format ntm_ongoing_follow best12. ;
	format pcp_num_follow $500. ;
	format dt_pcp_follow yymmdd10. ;
	format dt_recent_pcp_follow yymmdd10. ;
	format pcp_ongoing_follow best12. ;
	format pneumonia_num_follow $500. ;
	format dt_pneumonia_follow yymmdd10. ;
	format dt_recent_pneumonia_follow yymmdd10. ;
	format pneumonia_ongoing_follow best12. ;
	format pml_num_follow $500. ;
	format dt_pml_follow yymmdd10. ;
	format dt_recent_pml_follow yymmdd10. ;
	format pml_ongoing_follow best12. ;
	format salmonella_site_follow $500. ;
	format salmonella_num_follow $500. ;
	format dt_salmonella_follow yymmdd10. ;
	format dt_recent_salmonella_follow yymmdd10. ;
	format salmonella_ongoing_follow best12. ;
	format toxo_site_follow $500. ;
	format toxo_num_follow $500. ;
	format dt_toxo_follow yymmdd10. ;
	format dt_recent_toxo_follow yymmdd10. ;
	format toxo_ongoing_follow best12. ;
	format wasting_num_follow $500. ;
	format dt_wasting_follow yymmdd10. ;
	format dt_recent_wasting_follow yymmdd10. ;
	format wasting_ongoing_follow best12. ;
	format other_aids1_follow $500. ;
	format other_site1_follow $500. ;
	format other_aids_num1_follow $500. ;
	format dt_initial_aids1_follow yymmdd10. ;
	format dt_recent_aids1_follow yymmdd10. ;
	format other_aids1_ongoing_follow best12. ;
	format other_aids2_follow $500. ;
	format other_site2_follow $500. ;
	format other_aids_num2_follow $500. ;
	format dt_initial_aids2_follow yymmdd10. ;
	format dt_recent_aids2_follow yymmdd10. ;
	format other_aids2_ongoing_follow best12. ;
	format other_aids3_follow $500. ;
	format other_site3_follow $500. ;
	format other_aids_num3_follow $500. ;
	format dt_initial_aids3_follow yymmdd10. ;
	format dt_recent_aids3_follow yymmdd10. ;
	format other_aids3_ongoing_follow best12. ;
	format other_aids4_follow $500. ;
	format other_site4_follow $500. ;
	format other_aids_num4_follow $500. ;
	format dt_initial_aids4_follow yymmdd10. ;
	format dt_recent_aids4_follow yymmdd10. ;
	format other_aids4_ongoing_follow best12. ;
	format other_aids5_follow $500. ;
	format other_site5_follow $500. ;
	format other_aids_num5_follow $500. ;
	format dt_initial_aids5_follow yymmdd10. ;
	format dt_recent_aids5_follow yymmdd10. ;
	format other_aids5_ongoing_follow best12. ;
	format follow_up_aids_condi_v_0 best12. ;

input
		patient_id $
		aids_condition_follow___1
		aids_condition_follow___2
		aids_condition_follow___3
		aids_condition_follow___4
		aids_condition_follow___5
		aids_condition_follow___6
		aids_condition_follow___7
		aids_condition_follow___8
		aids_condition_follow___9
		aids_condition_follow___10
		aids_condition_follow___11
		aids_condition_follow___12
		aids_condition_follow___13
		aids_condition_follow___14
		aids_condition_follow___15
		aids_condition_follow___16
		aids_condition_follow___17
		aids_condition_follow___18
		aids_condition_follow___19
		aids_condition_follow___20
		aids_condition_follow___21
		aids_condition_follow___22
		aids_condition_follow___23
		aids_condition_follow___24
		aids_condition_follow___25
		aids_condition_follow___26
		aids_condition_follow___27
		aids_condition_follow___28
		aids_condition_follow___99
		infect_site_follow $
		infect_num_follow $
		dt_infect_follow
		dt_recent_infect_follow
		infect_ongoing_follow
		cand_eso_num_follow $
		dt_cand_eso_follow
		dt_recent_cand_eso_follow
		cand_eso_ongoing_follow
		candida_oth_site_follow $
		cand_oth_num_follow $
		dt_cand_oth_follow
		dt_recent_cand_oth_follow
		cand_oth_ongoing_follow
		cancer_num_follow $
		dt_cancer_follow
		dt_recent_cancer_follow
		cancer_ongoing_follow
		coccid_site_follow $
		coccid_num_follow $
		dt_coccid_follow
		dt_recent_coccid_follow
		coccid_ongoing_follow
		crypto_site_follow $
		crypto_num_follow $
		dt_crypto_follow
		dt_recent_crypto_follow
		crypto_ongoing_follow
		cryptospor_site_follow $
		cryptospor_num_follow $
		dt_cryptospor_ret_follow
		dt_recent_cryptospor_follow
		cryptospor_ongoing_follow
		cmv_ret_num_follow $
		dt_cmv_ret_follow
		dt_recent_cmv_ret_follow
		cmv_ret_ongoing_follow
		cmv_oth_site_follow $
		cmv_oth_num_follow $
		dt_cmv_oth_follow
		dt_recent_cmv_oth_follow
		cmv_oth_ongoing_follow
		dementia_num_follow $
		dt_dementia_follow
		dt_recent_dementia_follow
		dementia_ongoing_follow
		hsv_site_follow $
		hsv_oth_num_follow $
		dt_hsv_oth_follow
		dt_recent_hsv_oth_follow
		hsv_oth_ongoing_follow
		histo_site_follow $
		histo_num_follow $
		dt_histo_follow
		dt_recent_histo_follow
		histo_ongoing_follow
		isospor_site_follow $
		isospor_num_follow $
		dt_isospor_follow
		dt_recent_isospor_follow
		isospor_ongoing_follow
		ks_site_follow $
		ks_num_follow $
		dt_ks_follow
		dt_recent_ks_follow
		ks_ongoing_follow
		lip_num_follow $
		dt_lip_follow
		dt_recent_lip_follow
		lip_ongoing_follow
		burkitts_site_follow $
		burkitts_num_follow $
		dt_burkitts_follow
		dt_recent_burkitts_follow
		burkitts_ongoing_follow
		lymphoma_site_follow $
		lymphoma_num_follow $
		dt_lymphoma_follow
		dt_recent_lymphoma_follow
		lymphoma_ongoing_follow
		cns_num_follow $
		dt_cns_follow
		dt_recent_cns_follow
		cns_ongoing_follow
		mac_site_follow $
		mac_num_follow $
		dt_mac_follow
		dt_recent_mac_follow
		mac_ongoing_follow
		mtb_num_follow $
		dt_mtb_follow
		dt_recent_mtb_follow
		mtb_ongoing_follow
		eptb_site_follow $
		eptb_num_follow $
		eptb_sites_follow $
		dt_eptb_follow
		dt_recent_eptb_follow
		eptb_ongoing_follow
		ntm_site_follow $
		ntm_num_follow $
		dt_ntm_follow
		dt_recent_ntm_follow
		ntm_ongoing_follow
		pcp_num_follow $
		dt_pcp_follow
		dt_recent_pcp_follow
		pcp_ongoing_follow
		pneumonia_num_follow $
		dt_pneumonia_follow
		dt_recent_pneumonia_follow
		pneumonia_ongoing_follow
		pml_num_follow $
		dt_pml_follow
		dt_recent_pml_follow
		pml_ongoing_follow
		salmonella_site_follow $
		salmonella_num_follow $
		dt_salmonella_follow
		dt_recent_salmonella_follow
		salmonella_ongoing_follow
		toxo_site_follow $
		toxo_num_follow $
		dt_toxo_follow
		dt_recent_toxo_follow
		toxo_ongoing_follow
		wasting_num_follow $
		dt_wasting_follow
		dt_recent_wasting_follow
		wasting_ongoing_follow
		other_aids1_follow $
		other_site1_follow $
		other_aids_num1_follow $
		dt_initial_aids1_follow
		dt_recent_aids1_follow
		other_aids1_ongoing_follow
		other_aids2_follow $
		other_site2_follow $
		other_aids_num2_follow $
		dt_initial_aids2_follow
		dt_recent_aids2_follow
		other_aids2_ongoing_follow
		other_aids3_follow $
		other_site3_follow $
		other_aids_num3_follow $
		dt_initial_aids3_follow
		dt_recent_aids3_follow
		other_aids3_ongoing_follow
		other_aids4_follow $
		other_site4_follow $
		other_aids_num4_follow $
		dt_initial_aids4_follow
		dt_recent_aids4_follow
		other_aids4_ongoing_follow
		other_aids5_follow $
		other_site5_follow $
		other_aids_num5_follow $
		dt_initial_aids5_follow
		dt_recent_aids5_follow
		other_aids5_ongoing_follow
		follow_up_aids_condi_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label aids_condition_follow___1='AIDS Condition (choice=Bacterial infection)';
	label aids_condition_follow___2='AIDS Condition (choice=Candida Esophagitis)';
	label aids_condition_follow___3='AIDS Condition (choice=Candida Other)';
	label aids_condition_follow___4='AIDS Condition (choice=Cervical Cancer)';
	label aids_condition_follow___5='AIDS Condition (choice=Coccidioidomycosis)';
	label aids_condition_follow___6='AIDS Condition (choice=Cryptococcus)';
	label aids_condition_follow___7='AIDS Condition (choice=Cryptosporidiosis)';
	label aids_condition_follow___8='AIDS Condition (choice=CMV retinitis)';
	label aids_condition_follow___9='AIDS Condition (choice=CMV Other)';
	label aids_condition_follow___10='AIDS Condition (choice=HIV Dementia)';
	label aids_condition_follow___11='AIDS Condition (choice=HSV Other)';
	label aids_condition_follow___12='AIDS Condition (choice=Histoplasmosis)';
	label aids_condition_follow___13='AIDS Condition (choice=Isosporiasis)';
	label aids_condition_follow___14='AIDS Condition (choice=KS)';
	label aids_condition_follow___15='AIDS Condition (choice=LIP)';
	label aids_condition_follow___16='AIDS Condition (choice=Burkitts)';
	label aids_condition_follow___17='AIDS Condition (choice=Immunoblastic Lymphoma)';
	label aids_condition_follow___18='AIDS Condition (choice=CNS Lymphoma)';
	label aids_condition_follow___19='AIDS Condition (choice=MAC/M. kansasii)';
	label aids_condition_follow___20='AIDS Condition (choice=MTB (Pulmonary))';
	label aids_condition_follow___21='AIDS Condition (choice=EPTB)';
	label aids_condition_follow___22='AIDS Condition (choice=NTM)';
	label aids_condition_follow___23='AIDS Condition (choice=PCP)';
	label aids_condition_follow___24='AIDS Condition (choice=Recurrent Pneumonia)';
	label aids_condition_follow___25='AIDS Condition (choice=PML)';
	label aids_condition_follow___26='AIDS Condition (choice=Salmonella)';
	label aids_condition_follow___27='AIDS Condition (choice=Toxoplasmosis)';
	label aids_condition_follow___28='AIDS Condition (choice=Wasting Syndrome)';
	label aids_condition_follow___99='AIDS Condition (choice=Other)';
	label infect_site_follow='Site';
	label infect_num_follow='Bacterial infection number of episodes';
	label dt_infect_follow='Initial Date';
	label dt_recent_infect_follow='Most Recent Date';
	label infect_ongoing_follow='Current ongoing diagnosis';
	label cand_eso_num_follow='Candida Esophagitis number of episodes';
	label dt_cand_eso_follow='Initial Date';
	label dt_recent_cand_eso_follow='Most Recent Date';
	label cand_eso_ongoing_follow='Current ongoing diagnosis';
	label candida_oth_site_follow='Site';
	label cand_oth_num_follow='Candida Other number of episodes';
	label dt_cand_oth_follow='Initial Date';
	label dt_recent_cand_oth_follow='Most Recent Date';
	label cand_oth_ongoing_follow='Current ongoing diagnosis';
	label cancer_num_follow='Cervical Cancer number of episodes';
	label dt_cancer_follow='Initial Date';
	label dt_recent_cancer_follow='Most Recent Date';
	label cancer_ongoing_follow='Current ongoing diagnosis';
	label coccid_site_follow='Site';
	label coccid_num_follow='Coccidioidomycosis number of episodes';
	label dt_coccid_follow='Initial Date';
	label dt_recent_coccid_follow='Most Recent Date';
	label coccid_ongoing_follow='Current ongoing diagnosis';
	label crypto_site_follow='Site';
	label crypto_num_follow='Cryptococcus number of episodes';
	label dt_crypto_follow='Initial Date';
	label dt_recent_crypto_follow='Most Recent Date';
	label crypto_ongoing_follow='Current ongoing diagnosis';
	label cryptospor_site_follow='Site';
	label cryptospor_num_follow='Cryptosporidiosis number of episodes';
	label dt_cryptospor_ret_follow='Initial Date';
	label dt_recent_cryptospor_follow='Most Recent Date';
	label cryptospor_ongoing_follow='Current ongoing diagnosis';
	label cmv_ret_num_follow='CMV Retinitis number of episodes';
	label dt_cmv_ret_follow='Initial Date';
	label dt_recent_cmv_ret_follow='Most Recent Date';
	label cmv_ret_ongoing_follow='Current ongoing diagnosis';
	label cmv_oth_site_follow='Site';
	label cmv_oth_num_follow='CMV Other number of episodes';
	label dt_cmv_oth_follow='Initial Date';
	label dt_recent_cmv_oth_follow='Most Recent Date';
	label cmv_oth_ongoing_follow='Current ongoing diagnosis';
	label dementia_num_follow='HIV Dementia number of episodes';
	label dt_dementia_follow='Initial Date';
	label dt_recent_dementia_follow='Most Recent Date';
	label dementia_ongoing_follow='Current ongoing diagnosis';
	label hsv_site_follow='Site';
	label hsv_oth_num_follow='HSV Other number of episodes';
	label dt_hsv_oth_follow='Initial Date';
	label dt_recent_hsv_oth_follow='Most Recent Date';
	label hsv_oth_ongoing_follow='Current ongoing diagnosis';
	label histo_site_follow='Site';
	label histo_num_follow='Histoplasmosis number of episodes';
	label dt_histo_follow='Initial Date';
	label dt_recent_histo_follow='Most Recent Date';
	label histo_ongoing_follow='Current ongoing diagnosis';
	label isospor_site_follow='Site';
	label isospor_num_follow='Isosporiasis number of episodes';
	label dt_isospor_follow='Initial Date';
	label dt_recent_isospor_follow='Most Recent Date';
	label isospor_ongoing_follow='Current ongoing diagnosis';
	label ks_site_follow='Site';
	label ks_num_follow='KS number of episodes';
	label dt_ks_follow='Initial Date';
	label dt_recent_ks_follow='Most Recent Date';
	label ks_ongoing_follow='Current ongoing diagnosis';
	label lip_num_follow='LIP number of episodes';
	label dt_lip_follow='Initial Date';
	label dt_recent_lip_follow='Most Recent Date';
	label lip_ongoing_follow='Current ongoing diagnosis';
	label burkitts_site_follow='Site';
	label burkitts_num_follow='Burkitts number of episodes';
	label dt_burkitts_follow='Initial Date';
	label dt_recent_burkitts_follow='Most Recent Date';
	label burkitts_ongoing_follow='Current ongoing diagnosis';
	label lymphoma_site_follow='Site';
	label lymphoma_num_follow='Immunoblastic Lymphoma number of episodes';
	label dt_lymphoma_follow='Initial Date';
	label dt_recent_lymphoma_follow='Most Recent Date';
	label lymphoma_ongoing_follow='Current ongoing diagnosis';
	label cns_num_follow='CNS Lymphoma number of episodes';
	label dt_cns_follow='Initial Date';
	label dt_recent_cns_follow='Most Recent Date';
	label cns_ongoing_follow='Current ongoing diagnosis';
	label mac_site_follow='Site';
	label mac_num_follow='MAC/M. kansasii number of episodes';
	label dt_mac_follow='Initial Date';
	label dt_recent_mac_follow='Most Recent Date';
	label mac_ongoing_follow='Current ongoing diagnosis';
	label mtb_num_follow='MTB (Pulmonary) number of episodes';
	label dt_mtb_follow='Initial Date';
	label dt_recent_mtb_follow='Most Recent Date';
	label mtb_ongoing_follow='Current ongoing diagnosis';
	label eptb_site_follow='Site';
	label eptb_num_follow='EPTB number of episodes';
	label eptb_sites_follow='Sites:';
	label dt_eptb_follow='Initial Date';
	label dt_recent_eptb_follow='Most Recent Date';
	label eptb_ongoing_follow='Current ongoing diagnosis';
	label ntm_site_follow='Site';
	label ntm_num_follow='NTM number of episodes';
	label dt_ntm_follow='Initial Date';
	label dt_recent_ntm_follow='Most Recent Date';
	label ntm_ongoing_follow='Current ongoing diagnosis';
	label pcp_num_follow='PCP number of episodes';
	label dt_pcp_follow='Initial Date';
	label dt_recent_pcp_follow='Most Recent Date';
	label pcp_ongoing_follow='Current ongoing diagnosis';
	label pneumonia_num_follow='Recurrent Pneumonia number of episodes';
	label dt_pneumonia_follow='Initial Date';
	label dt_recent_pneumonia_follow='Most Recent Date';
	label pneumonia_ongoing_follow='Current ongoing diagnosis';
	label pml_num_follow='PML number of episodes';
	label dt_pml_follow='Initial Date';
	label dt_recent_pml_follow='Most Recent Date';
	label pml_ongoing_follow='Current ongoing diagnosis';
	label salmonella_site_follow='Site';
	label salmonella_num_follow='Salmonella number of episodes';
	label dt_salmonella_follow='Initial Date';
	label dt_recent_salmonella_follow='Most Recent Date';
	label salmonella_ongoing_follow='Current ongoing diagnosis';
	label toxo_site_follow='Site';
	label toxo_num_follow='Toxoplasmosis number of episodes';
	label dt_toxo_follow='Initial Date';
	label dt_recent_toxo_follow='Most Recent Date';
	label toxo_ongoing_follow='Current ongoing diagnosis';
	label wasting_num_follow='Wasting Syndrome number of episodes';
	label dt_wasting_follow='Initial Date';
	label dt_recent_wasting_follow='Most Recent Date';
	label wasting_ongoing_follow='Current ongoing diagnosis';
	label other_aids1_follow='1. Other AIDS Condition';
	label other_site1_follow='Site';
	label other_aids_num1_follow='Other number of episodes';
	label dt_initial_aids1_follow='Initial Date';
	label dt_recent_aids1_follow='Most Recent Date';
	label other_aids1_ongoing_follow='Current ongoing diagnosis';
	label other_aids2_follow='2. Other AIDS Condition';
	label other_site2_follow='Site';
	label other_aids_num2_follow='Other number of episodes';
	label dt_initial_aids2_follow='Initial Date';
	label dt_recent_aids2_follow='Most Recent Date';
	label other_aids2_ongoing_follow='Current ongoing diagnosis';
	label other_aids3_follow='3. Other AIDS Condition';
	label other_site3_follow='Site';
	label other_aids_num3_follow='Other number of episodes';
	label dt_initial_aids3_follow='Initial Date';
	label dt_recent_aids3_follow='Most Recent Date';
	label other_aids3_ongoing_follow='Current ongoing diagnosis';
	label other_aids4_follow='4. Other AIDS Condition';
	label other_site4_follow='Site';
	label other_aids_num4_follow='Other number of episodes';
	label dt_initial_aids4_follow='Initial Date';
	label dt_recent_aids4_follow='Most Recent Date';
	label other_aids4_ongoing_follow='Current ongoing diagnosis';
	label other_aids5_follow='5. Other AIDS Condition';
	label other_site5_follow='Site';
	label other_aids_num5_follow='Other number of episodes';
	label dt_initial_aids5_follow='Initial Date';
	label dt_recent_aids5_follow='Most Recent Date';
	label other_aids5_ongoing_follow='Current ongoing diagnosis';
	label follow_up_aids_condi_v_0='Complete?';
	run;

proc format;
	value aids_condition_follow___1_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___2_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___3_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___4_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___5_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___6_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___7_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___8_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___9_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___10_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___11_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___12_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___13_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___14_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___15_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___16_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___17_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___18_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___19_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___20_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___21_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___22_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___23_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___24_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___25_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___26_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___27_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___28_ 0='Unchecked' 1='Checked';
	value aids_condition_follow___99_ 0='Unchecked' 1='Checked';
	value infect_ongoing_follow_ 1='Yes' 2='No';
	value cand_eso_ongoing_follow_ 1='Yes' 2='No';
	value cand_oth_ongoing_follow_ 1='Yes' 2='No';
	value cancer_ongoing_follow_ 1='Yes' 2='No';
	value coccid_ongoing_follow_ 1='Yes' 2='No';
	value crypto_ongoing_follow_ 1='Yes' 2='No';
	value cryptospor_ongoing_follow_ 1='Yes' 2='No';
	value cmv_ret_ongoing_follow_ 1='Yes' 2='No';
	value cmv_oth_ongoing_follow_ 1='Yes' 2='No';
	value dementia_ongoing_follow_ 1='Yes' 2='No';
	value hsv_oth_ongoing_follow_ 1='Yes' 2='No';
	value histo_ongoing_follow_ 1='Yes' 2='No';
	value isospor_ongoing_follow_ 1='Yes' 2='No';
	value ks_ongoing_follow_ 1='Yes' 2='No';
	value lip_ongoing_follow_ 1='Yes' 2='No';
	value burkitts_ongoing_follow_ 1='Yes' 2='No';
	value lymphoma_ongoing_follow_ 1='Yes' 2='No';
	value cns_ongoing_follow_ 1='Yes' 2='No';
	value mac_ongoing_follow_ 1='Yes' 2='No';
	value mtb_ongoing_follow_ 1='Yes' 2='No';
	value eptb_ongoing_follow_ 1='Yes' 2='No';
	value ntm_ongoing_follow_ 1='Yes' 2='No';
	value pcp_ongoing_follow_ 1='Yes' 2='No';
	value pneumonia_ongoing_follow_ 1='Yes' 2='No';
	value pml_ongoing_follow_ 1='Yes' 2='No';
	value salmonella_ongoing_follow_ 1='Yes' 2='No';
	value toxo_ongoing_follow_ 1='Yes' 2='No';
	value wasting_ongoing_follow_ 1='Yes' 2='No';
	value other_aids1_ongoing_follow_ 1='Yes' 2='No';
	value other_aids2_ongoing_follow_ 1='Yes' 2='No';
	value other_aids3_ongoing_follow_ 1='Yes' 2='No';
	value other_aids4_ongoing_follow_ 1='Yes' 2='No';
	value other_aids5_ongoing_follow_ 1='Yes' 2='No';
	value follow_up_aids_condi_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format aids_condition_follow___1 aids_condition_follow___1_.;
	format aids_condition_follow___2 aids_condition_follow___2_.;
	format aids_condition_follow___3 aids_condition_follow___3_.;
	format aids_condition_follow___4 aids_condition_follow___4_.;
	format aids_condition_follow___5 aids_condition_follow___5_.;
	format aids_condition_follow___6 aids_condition_follow___6_.;
	format aids_condition_follow___7 aids_condition_follow___7_.;
	format aids_condition_follow___8 aids_condition_follow___8_.;
	format aids_condition_follow___9 aids_condition_follow___9_.;
	format aids_condition_follow___10 aids_condition_follow___10_.;
	format aids_condition_follow___11 aids_condition_follow___11_.;
	format aids_condition_follow___12 aids_condition_follow___12_.;
	format aids_condition_follow___13 aids_condition_follow___13_.;
	format aids_condition_follow___14 aids_condition_follow___14_.;
	format aids_condition_follow___15 aids_condition_follow___15_.;
	format aids_condition_follow___16 aids_condition_follow___16_.;
	format aids_condition_follow___17 aids_condition_follow___17_.;
	format aids_condition_follow___18 aids_condition_follow___18_.;
	format aids_condition_follow___19 aids_condition_follow___19_.;
	format aids_condition_follow___20 aids_condition_follow___20_.;
	format aids_condition_follow___21 aids_condition_follow___21_.;
	format aids_condition_follow___22 aids_condition_follow___22_.;
	format aids_condition_follow___23 aids_condition_follow___23_.;
	format aids_condition_follow___24 aids_condition_follow___24_.;
	format aids_condition_follow___25 aids_condition_follow___25_.;
	format aids_condition_follow___26 aids_condition_follow___26_.;
	format aids_condition_follow___27 aids_condition_follow___27_.;
	format aids_condition_follow___28 aids_condition_follow___28_.;
	format aids_condition_follow___99 aids_condition_follow___99_.;
	format infect_ongoing_follow infect_ongoing_follow_.;
	format cand_eso_ongoing_follow cand_eso_ongoing_follow_.;
	format cand_oth_ongoing_follow cand_oth_ongoing_follow_.;
	format cancer_ongoing_follow cancer_ongoing_follow_.;
	format coccid_ongoing_follow coccid_ongoing_follow_.;
	format crypto_ongoing_follow crypto_ongoing_follow_.;
	format cryptospor_ongoing_follow cryptospor_ongoing_follow_.;
	format cmv_ret_ongoing_follow cmv_ret_ongoing_follow_.;
	format cmv_oth_ongoing_follow cmv_oth_ongoing_follow_.;
	format dementia_ongoing_follow dementia_ongoing_follow_.;
	format hsv_oth_ongoing_follow hsv_oth_ongoing_follow_.;
	format histo_ongoing_follow histo_ongoing_follow_.;
	format isospor_ongoing_follow isospor_ongoing_follow_.;
	format ks_ongoing_follow ks_ongoing_follow_.;
	format lip_ongoing_follow lip_ongoing_follow_.;
	format burkitts_ongoing_follow burkitts_ongoing_follow_.;
	format lymphoma_ongoing_follow lymphoma_ongoing_follow_.;
	format cns_ongoing_follow cns_ongoing_follow_.;
	format mac_ongoing_follow mac_ongoing_follow_.;
	format mtb_ongoing_follow mtb_ongoing_follow_.;
	format eptb_ongoing_follow eptb_ongoing_follow_.;
	format ntm_ongoing_follow ntm_ongoing_follow_.;
	format pcp_ongoing_follow pcp_ongoing_follow_.;
	format pneumonia_ongoing_follow pneumonia_ongoing_follow_.;
	format pml_ongoing_follow pml_ongoing_follow_.;
	format salmonella_ongoing_follow salmonella_ongoing_follow_.;
	format toxo_ongoing_follow toxo_ongoing_follow_.;
	format wasting_ongoing_follow wasting_ongoing_follow_.;
	format other_aids1_ongoing_follow other_aids1_ongoing_follow_.;
	format other_aids2_ongoing_follow other_aids2_ongoing_follow_.;
	format other_aids3_ongoing_follow other_aids3_ongoing_follow_.;
	format other_aids4_ongoing_follow other_aids4_ongoing_follow_.;
	format other_aids5_ongoing_follow other_aids5_ongoing_follow_.;
	format follow_up_aids_condi_v_0 follow_up_aids_condi_v_0_.;
	run;

data brent.followup_aids;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


