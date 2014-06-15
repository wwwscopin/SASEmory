%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\aids.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 	informat patient_id $500. ;
	informat patient_id $500. ;
	informat aids_condition___1 best32. ;
	informat aids_condition___2 best32. ;
	informat aids_condition___3 best32. ;
	informat aids_condition___4 best32. ;
	informat aids_condition___5 best32. ;
	informat aids_condition___6 best32. ;
	informat aids_condition___7 best32. ;
	informat aids_condition___8 best32. ;
	informat aids_condition___9 best32. ;
	informat aids_condition___10 best32. ;
	informat aids_condition___11 best32. ;
	informat aids_condition___12 best32. ;
	informat aids_condition___13 best32. ;
	informat aids_condition___14 best32. ;
	informat aids_condition___15 best32. ;
	informat aids_condition___16 best32. ;
	informat aids_condition___17 best32. ;
	informat aids_condition___18 best32. ;
	informat aids_condition___19 best32. ;
	informat aids_condition___20 best32. ;
	informat aids_condition___21 best32. ;
	informat aids_condition___22 best32. ;
	informat aids_condition___23 best32. ;
	informat aids_condition___24 best32. ;
	informat aids_condition___25 best32. ;
	informat aids_condition___26 best32. ;
	informat aids_condition___27 best32. ;
	informat aids_condition___28 best32. ;
	informat aids_condition___99 best32. ;
	informat infect_site $500. ;
	informat infect_num $500. ;
	informat dt_infect yymmdd10. ;
	informat dt_recent_infect yymmdd10. ;
	informat infect_ongoing best32. ;
	informat cand_eso_num $500. ;
	informat dt_cand_eso yymmdd10. ;
	informat dt_recent_cand_eso yymmdd10. ;
	informat cand_eso_ongoing best32. ;
	informat candida_oth_site $500. ;
	informat cand_oth_num $500. ;
	informat dt_cand_oth yymmdd10. ;
	informat dt_recent_cand_oth yymmdd10. ;
	informat cand_oth_ongoing best32. ;
	informat cancer_num $500. ;
	informat dt_cancer yymmdd10. ;
	informat dt_recent_cancer yymmdd10. ;
	informat cancer_ongoing best32. ;
	informat coccid_site $500. ;
	informat coccid_num $500. ;
	informat dt_coccid yymmdd10. ;
	informat dt_recent_coccid yymmdd10. ;
	informat coccid_ongoing best32. ;
	informat crypto_site $500. ;
	informat crypto_num $500. ;
	informat dt_crypto yymmdd10. ;
	informat dt_recent_crypto yymmdd10. ;
	informat crypto_ongoing best32. ;
	informat cryptospor_site $500. ;
	informat cryptospor_num $500. ;
	informat dt_cryptospor yymmdd10. ;
	informat dt_recent_cryptospor yymmdd10. ;
	informat cryptospor_ongoing best32. ;
	informat cmv_ret_num $500. ;
	informat dt_cmv_ret yymmdd10. ;
	informat dt_recent_cmv_ret yymmdd10. ;
	informat cmv_ret_ongoing best32. ;
	informat cmv_oth_site $500. ;
	informat cmv_oth_num $500. ;
	informat dt_cmv_oth yymmdd10. ;
	informat dt_recent_cmv_oth yymmdd10. ;
	informat cmv_oth_ongoing best32. ;
	informat dementia_num $500. ;
	informat dt_dementia yymmdd10. ;
	informat dt_recent_dementia yymmdd10. ;
	informat dementia_ongoing best32. ;
	informat hsv_oth_site $500. ;
	informat hsv_oth_num $500. ;
	informat dt_hsv_oth yymmdd10. ;
	informat dt_recent_hsv_oth yymmdd10. ;
	informat hsv_oth_ongoing best32. ;
	informat histo_site $500. ;
	informat histo_num $500. ;
	informat dt_histo yymmdd10. ;
	informat dt_recent_histo yymmdd10. ;
	informat histo_ongoing best32. ;
	informat isospor_site $500. ;
	informat isospor_num $500. ;
	informat dt_isospor yymmdd10. ;
	informat dt_recent_isospor yymmdd10. ;
	informat isospor_ongoing best32. ;
	informat ks_site $500. ;
	informat ks_num $500. ;
	informat dt_ks yymmdd10. ;
	informat dt_recent_ks yymmdd10. ;
	informat ks_ongoing best32. ;
	informat lip_num $500. ;
	informat dt_lip yymmdd10. ;
	informat dt_recent_lip yymmdd10. ;
	informat lip_ongoing best32. ;
	informat burkitts_site $500. ;
	informat burkitts_num $500. ;
	informat dt_burkitts yymmdd10. ;
	informat dt_recent_burkitts yymmdd10. ;
	informat burkitts_ongoing best32. ;
	informat lymphoma_site $500. ;
	informat lymphoma_num $500. ;
	informat dt_lymphoma yymmdd10. ;
	informat dt_recent_lymphoma yymmdd10. ;
	informat lymphoma_ongoing best32. ;
	informat cns_num $500. ;
	informat dt_cns yymmdd10. ;
	informat dt_recent_cns yymmdd10. ;
	informat cns_ongoing best32. ;
	informat mac_site $500. ;
	informat mac_num $500. ;
	informat dt_mac yymmdd10. ;
	informat dt_recent_mac yymmdd10. ;
	informat mac_ongoing best32. ;
	informat mtb_num $500. ;
	informat dt_mtb yymmdd10. ;
	informat dt_recent_mtb yymmdd10. ;
	informat mtb_ongoing best32. ;
	informat eptb_site $500. ;
	informat eptb_num $500. ;
	informat dt_eptb yymmdd10. ;
	informat dt_recent_eptb yymmdd10. ;
	informat eptb_ongoing best32. ;
	informat ntm_site $500. ;
	informat ntm_num $500. ;
	informat dt_ntm yymmdd10. ;
	informat dt_recent_ntm yymmdd10. ;
	informat ntm_ongoing best32. ;
	informat pcp_num $500. ;
	informat dt_pcp yymmdd10. ;
	informat dt_recent_pcp yymmdd10. ;
	informat pcp_ongoing best32. ;
	informat pneumonia_num $500. ;
	informat dt_pneumonia yymmdd10. ;
	informat dt_recent_pneumonia yymmdd10. ;
	informat pneumonia_ongoing best32. ;
	informat pml_num $500. ;
	informat dt_pml yymmdd10. ;
	informat dt_recent_pml yymmdd10. ;
	informat pml_ongoing best32. ;
	informat salmonella_site $500. ;
	informat salmonella_num $500. ;
	informat dt_salmonella yymmdd10. ;
	informat dt_recent_salmonella yymmdd10. ;
	informat salmonella_ongoing best32. ;
	informat toxo_site $500. ;
	informat toxo_num $500. ;
	informat dt_toxo yymmdd10. ;
	informat dt_recent_toxo yymmdd10. ;
	informat toxo_ongoing best32. ;
	informat wasting_num $500. ;
	informat dt_wasting yymmdd10. ;
	informat dt_recent_wasting yymmdd10. ;
	informat wasting_ongoing best32. ;
	informat other_aids1 $500. ;
	informat other_site1 $500. ;
	informat other_aids_num1 $500. ;
	informat dt_initial_aids1 yymmdd10. ;
	informat dt_recent_aids1 yymmdd10. ;
	informat other_aids1_ongoing best32. ;
	informat other_aids2 $500. ;
	informat other_site2 $500. ;
	informat other_aids_num2 $500. ;
	informat dt_initial_aids2 yymmdd10. ;
	informat dt_recent_aids2 yymmdd10. ;
	informat other_aids2_ongoing best32. ;
	informat other_aids3 $500. ;
	informat other_site3 $500. ;
	informat other_aids_num3 $500. ;
	informat dt_initial_aids3 yymmdd10. ;
	informat dt_recent_aids3 yymmdd10. ;
	informat other_aids3_ongoing best32. ;
	informat other_aids4 $500. ;
	informat other_site4 $500. ;
	informat other_aids_num4 $500. ;
	informat dt_initial_aids4 yymmdd10. ;
	informat dt_recent_aids4 yymmdd10. ;
	informat other_aids4_ongoing best32. ;
	informat other_aids5 $500. ;
	informat other_site5 $500. ;
	informat other_aids_num5 $500. ;
	informat dt_initial_aids5 yymmdd10. ;
	informat dt_recent_aids5 yymmdd10. ;
	informat other_aids5_ongoing best32. ;
	informat aids_conditions_eeaa_complete best32. ;

	format patient_id $500. ;
	format aids_condition___1 best12. ;
	format aids_condition___2 best12. ;
	format aids_condition___3 best12. ;
	format aids_condition___4 best12. ;
	format aids_condition___5 best12. ;
	format aids_condition___6 best12. ;
	format aids_condition___7 best12. ;
	format aids_condition___8 best12. ;
	format aids_condition___9 best12. ;
	format aids_condition___10 best12. ;
	format aids_condition___11 best12. ;
	format aids_condition___12 best12. ;
	format aids_condition___13 best12. ;
	format aids_condition___14 best12. ;
	format aids_condition___15 best12. ;
	format aids_condition___16 best12. ;
	format aids_condition___17 best12. ;
	format aids_condition___18 best12. ;
	format aids_condition___19 best12. ;
	format aids_condition___20 best12. ;
	format aids_condition___21 best12. ;
	format aids_condition___22 best12. ;
	format aids_condition___23 best12. ;
	format aids_condition___24 best12. ;
	format aids_condition___25 best12. ;
	format aids_condition___26 best12. ;
	format aids_condition___27 best12. ;
	format aids_condition___28 best12. ;
	format aids_condition___99 best12. ;
	format infect_site $500. ;
	format infect_num $500. ;
	format dt_infect yymmdd10. ;
	format dt_recent_infect yymmdd10. ;
	format infect_ongoing best12. ;
	format cand_eso_num $500. ;
	format dt_cand_eso yymmdd10. ;
	format dt_recent_cand_eso yymmdd10. ;
	format cand_eso_ongoing best12. ;
	format candida_oth_site $500. ;
	format cand_oth_num $500. ;
	format dt_cand_oth yymmdd10. ;
	format dt_recent_cand_oth yymmdd10. ;
	format cand_oth_ongoing best12. ;
	format cancer_num $500. ;
	format dt_cancer yymmdd10. ;
	format dt_recent_cancer yymmdd10. ;
	format cancer_ongoing best12. ;
	format coccid_site $500. ;
	format coccid_num $500. ;
	format dt_coccid yymmdd10. ;
	format dt_recent_coccid yymmdd10. ;
	format coccid_ongoing best12. ;
	format crypto_site $500. ;
	format crypto_num $500. ;
	format dt_crypto yymmdd10. ;
	format dt_recent_crypto yymmdd10. ;
	format crypto_ongoing best12. ;
	format cryptospor_site $500. ;
	format cryptospor_num $500. ;
	format dt_cryptospor yymmdd10. ;
	format dt_recent_cryptospor yymmdd10. ;
	format cryptospor_ongoing best12. ;
	format cmv_ret_num $500. ;
	format dt_cmv_ret yymmdd10. ;
	format dt_recent_cmv_ret yymmdd10. ;
	format cmv_ret_ongoing best12. ;
	format cmv_oth_site $500. ;
	format cmv_oth_num $500. ;
	format dt_cmv_oth yymmdd10. ;
	format dt_recent_cmv_oth yymmdd10. ;
	format cmv_oth_ongoing best12. ;
	format dementia_num $500. ;
	format dt_dementia yymmdd10. ;
	format dt_recent_dementia yymmdd10. ;
	format dementia_ongoing best12. ;
	format hsv_oth_site $500. ;
	format hsv_oth_num $500. ;
	format dt_hsv_oth yymmdd10. ;
	format dt_recent_hsv_oth yymmdd10. ;
	format hsv_oth_ongoing best12. ;
	format histo_site $500. ;
	format histo_num $500. ;
	format dt_histo yymmdd10. ;
	format dt_recent_histo yymmdd10. ;
	format histo_ongoing best12. ;
	format isospor_site $500. ;
	format isospor_num $500. ;
	format dt_isospor yymmdd10. ;
	format dt_recent_isospor yymmdd10. ;
	format isospor_ongoing best12. ;
	format ks_site $500. ;
	format ks_num $500. ;
	format dt_ks yymmdd10. ;
	format dt_recent_ks yymmdd10. ;
	format ks_ongoing best12. ;
	format lip_num $500. ;
	format dt_lip yymmdd10. ;
	format dt_recent_lip yymmdd10. ;
	format lip_ongoing best12. ;
	format burkitts_site $500. ;
	format burkitts_num $500. ;
	format dt_burkitts yymmdd10. ;
	format dt_recent_burkitts yymmdd10. ;
	format burkitts_ongoing best12. ;
	format lymphoma_site $500. ;
	format lymphoma_num $500. ;
	format dt_lymphoma yymmdd10. ;
	format dt_recent_lymphoma yymmdd10. ;
	format lymphoma_ongoing best12. ;
	format cns_num $500. ;
	format dt_cns yymmdd10. ;
	format dt_recent_cns yymmdd10. ;
	format cns_ongoing best12. ;
	format mac_site $500. ;
	format mac_num $500. ;
	format dt_mac yymmdd10. ;
	format dt_recent_mac yymmdd10. ;
	format mac_ongoing best12. ;
	format mtb_num $500. ;
	format dt_mtb yymmdd10. ;
	format dt_recent_mtb yymmdd10. ;
	format mtb_ongoing best12. ;
	format eptb_site $500. ;
	format eptb_num $500. ;
	format dt_eptb yymmdd10. ;
	format dt_recent_eptb yymmdd10. ;
	format eptb_ongoing best12. ;
	format ntm_site $500. ;
	format ntm_num $500. ;
	format dt_ntm yymmdd10. ;
	format dt_recent_ntm yymmdd10. ;
	format ntm_ongoing best12. ;
	format pcp_num $500. ;
	format dt_pcp yymmdd10. ;
	format dt_recent_pcp yymmdd10. ;
	format pcp_ongoing best12. ;
	format pneumonia_num $500. ;
	format dt_pneumonia yymmdd10. ;
	format dt_recent_pneumonia yymmdd10. ;
	format pneumonia_ongoing best12. ;
	format pml_num $500. ;
	format dt_pml yymmdd10. ;
	format dt_recent_pml yymmdd10. ;
	format pml_ongoing best12. ;
	format salmonella_site $500. ;
	format salmonella_num $500. ;
	format dt_salmonella yymmdd10. ;
	format dt_recent_salmonella yymmdd10. ;
	format salmonella_ongoing best12. ;
	format toxo_site $500. ;
	format toxo_num $500. ;
	format dt_toxo yymmdd10. ;
	format dt_recent_toxo yymmdd10. ;
	format toxo_ongoing best12. ;
	format wasting_num $500. ;
	format dt_wasting yymmdd10. ;
	format dt_recent_wasting yymmdd10. ;
	format wasting_ongoing best12. ;
	format other_aids1 $500. ;
	format other_site1 $500. ;
	format other_aids_num1 $500. ;
	format dt_initial_aids1 yymmdd10. ;
	format dt_recent_aids1 yymmdd10. ;
	format other_aids1_ongoing best12. ;
	format other_aids2 $500. ;
	format other_site2 $500. ;
	format other_aids_num2 $500. ;
	format dt_initial_aids2 yymmdd10. ;
	format dt_recent_aids2 yymmdd10. ;
	format other_aids2_ongoing best12. ;
	format other_aids3 $500. ;
	format other_site3 $500. ;
	format other_aids_num3 $500. ;
	format dt_initial_aids3 yymmdd10. ;
	format dt_recent_aids3 yymmdd10. ;
	format other_aids3_ongoing best12. ;
	format other_aids4 $500. ;
	format other_site4 $500. ;
	format other_aids_num4 $500. ;
	format dt_initial_aids4 yymmdd10. ;
	format dt_recent_aids4 yymmdd10. ;
	format other_aids4_ongoing best12. ;
	format other_aids5 $500. ;
	format other_site5 $500. ;
	format other_aids_num5 $500. ;
	format dt_initial_aids5 yymmdd10. ;
	format dt_recent_aids5 yymmdd10. ;
	format other_aids5_ongoing best12. ;
	format aids_conditions_eeaa_complete best12. ;

input
		patient_id $
		aids_condition___1
		aids_condition___2
		aids_condition___3
		aids_condition___4
		aids_condition___5
		aids_condition___6
		aids_condition___7
		aids_condition___8
		aids_condition___9
		aids_condition___10
		aids_condition___11
		aids_condition___12
		aids_condition___13
		aids_condition___14
		aids_condition___15
		aids_condition___16
		aids_condition___17
		aids_condition___18
		aids_condition___19
		aids_condition___20
		aids_condition___21
		aids_condition___22
		aids_condition___23
		aids_condition___24
		aids_condition___25
		aids_condition___26
		aids_condition___27
		aids_condition___28
		aids_condition___99
		infect_site $
		infect_num $
		dt_infect
		dt_recent_infect
		infect_ongoing
		cand_eso_num $
		dt_cand_eso
		dt_recent_cand_eso
		cand_eso_ongoing
		candida_oth_site $
		cand_oth_num $
		dt_cand_oth
		dt_recent_cand_oth
		cand_oth_ongoing
		cancer_num $
		dt_cancer
		dt_recent_cancer
		cancer_ongoing
		coccid_site $
		coccid_num $
		dt_coccid
		dt_recent_coccid
		coccid_ongoing
		crypto_site $
		crypto_num $
		dt_crypto
		dt_recent_crypto
		crypto_ongoing
		cryptospor_site $
		cryptospor_num $
		dt_cryptospor
		dt_recent_cryptospor
		cryptospor_ongoing
		cmv_ret_num $
		dt_cmv_ret
		dt_recent_cmv_ret
		cmv_ret_ongoing
		cmv_oth_site $
		cmv_oth_num $
		dt_cmv_oth
		dt_recent_cmv_oth
		cmv_oth_ongoing
		dementia_num $
		dt_dementia
		dt_recent_dementia
		dementia_ongoing
		hsv_oth_site $
		hsv_oth_num $
		dt_hsv_oth
		dt_recent_hsv_oth
		hsv_oth_ongoing
		histo_site $
		histo_num $
		dt_histo
		dt_recent_histo
		histo_ongoing
		isospor_site $
		isospor_num $
		dt_isospor
		dt_recent_isospor
		isospor_ongoing
		ks_site $
		ks_num $
		dt_ks
		dt_recent_ks
		ks_ongoing
		lip_num $
		dt_lip
		dt_recent_lip
		lip_ongoing
		burkitts_site $
		burkitts_num $
		dt_burkitts
		dt_recent_burkitts
		burkitts_ongoing
		lymphoma_site $
		lymphoma_num $
		dt_lymphoma
		dt_recent_lymphoma
		lymphoma_ongoing
		cns_num $
		dt_cns
		dt_recent_cns
		cns_ongoing
		mac_site $
		mac_num $
		dt_mac
		dt_recent_mac
		mac_ongoing
		mtb_num $
		dt_mtb
		dt_recent_mtb
		mtb_ongoing
		eptb_site $
		eptb_num $
		dt_eptb
		dt_recent_eptb
		eptb_ongoing
		ntm_site $
		ntm_num $
		dt_ntm
		dt_recent_ntm
		ntm_ongoing
		pcp_num $
		dt_pcp
		dt_recent_pcp
		pcp_ongoing
		pneumonia_num $
		dt_pneumonia
		dt_recent_pneumonia
		pneumonia_ongoing
		pml_num $
		dt_pml
		dt_recent_pml
		pml_ongoing
		salmonella_site $
		salmonella_num $
		dt_salmonella
		dt_recent_salmonella
		salmonella_ongoing
		toxo_site $
		toxo_num $
		dt_toxo
		dt_recent_toxo
		toxo_ongoing
		wasting_num $
		dt_wasting
		dt_recent_wasting
		wasting_ongoing
		other_aids1 $
		other_site1 $
		other_aids_num1 $
		dt_initial_aids1
		dt_recent_aids1
		other_aids1_ongoing
		other_aids2 $
		other_site2 $
		other_aids_num2 $
		dt_initial_aids2
		dt_recent_aids2
		other_aids2_ongoing
		other_aids3 $
		other_site3 $
		other_aids_num3 $
		dt_initial_aids3
		dt_recent_aids3
		other_aids3_ongoing
		other_aids4 $
		other_site4 $
		other_aids_num4 $
		dt_initial_aids4
		dt_recent_aids4
		other_aids4_ongoing
		other_aids5 $
		other_site5 $
		other_aids_num5 $
		dt_initial_aids5
		dt_recent_aids5
		other_aids5_ongoing
		aids_conditions_eeaa_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label aids_condition___1='AIDS Condition (choice=Bacterial infection)';
	label aids_condition___2='AIDS Condition (choice=Candida Esophagitis)';
	label aids_condition___3='AIDS Condition (choice=Candida Other)';
	label aids_condition___4='AIDS Condition (choice=Cervical Cancer)';
	label aids_condition___5='AIDS Condition (choice=Coccidioidomycosis)';
	label aids_condition___6='AIDS Condition (choice=Cryptococcus)';
	label aids_condition___7='AIDS Condition (choice=Cryptosporidiosis)';
	label aids_condition___8='AIDS Condition (choice=CMV retinitis)';
	label aids_condition___9='AIDS Condition (choice=CMV Other)';
	label aids_condition___10='AIDS Condition (choice=HIV Dementia)';
	label aids_condition___11='AIDS Condition (choice=HSV Other)';
	label aids_condition___12='AIDS Condition (choice=Histoplasmosis)';
	label aids_condition___13='AIDS Condition (choice=Isosporiasis)';
	label aids_condition___14='AIDS Condition (choice=KS)';
	label aids_condition___15='AIDS Condition (choice=LIP)';
	label aids_condition___16='AIDS Condition (choice=Burkitts)';
	label aids_condition___17='AIDS Condition (choice=Immunoblastic Lymphoma)';
	label aids_condition___18='AIDS Condition (choice=CNS Lymphoma)';
	label aids_condition___19='AIDS Condition (choice=MAC/M. kansasii)';
	label aids_condition___20='AIDS Condition (choice=MTB (Pulmonary))';
	label aids_condition___21='AIDS Condition (choice=EPTB)';
	label aids_condition___22='AIDS Condition (choice=NTM)';
	label aids_condition___23='AIDS Condition (choice=PCP)';
	label aids_condition___24='AIDS Condition (choice=Recurrent Pneumonia)';
	label aids_condition___25='AIDS Condition (choice=PML)';
	label aids_condition___26='AIDS Condition (choice=Salmonella)';
	label aids_condition___27='AIDS Condition (choice=Toxoplasmosis)';
	label aids_condition___28='AIDS Condition (choice=Wasting Syndrome)';
	label aids_condition___99='AIDS Condition (choice=Other)';
	label infect_site='Site';
	label infect_num='Bacterial infection number of episodes';
	label dt_infect='Initial Date';
	label dt_recent_infect='Most Recent Date';
	label infect_ongoing='Current ongoing diagnosis';
	label cand_eso_num='Candida Esophagitis number of episodes';
	label dt_cand_eso='Initial Date';
	label dt_recent_cand_eso='Most Recent Date';
	label cand_eso_ongoing='Current ongoing diagnosis';
	label candida_oth_site='Site';
	label cand_oth_num='Candida Other number of episodes';
	label dt_cand_oth='Initial Date';
	label dt_recent_cand_oth='Most Recent Date';
	label cand_oth_ongoing='Current ongoing diagnosis';
	label cancer_num='Cervical Cancer number of episodes';
	label dt_cancer='Initial Date';
	label dt_recent_cancer='Most Recent Date';
	label cancer_ongoing='Current ongoing diagnosis';
	label coccid_site='Site';
	label coccid_num='Coccidioidomycosis number of episodes';
	label dt_coccid='Initial Date';
	label dt_recent_coccid='Most Recent Date';
	label coccid_ongoing='Current ongoing diagnosis';
	label crypto_site='Site';
	label crypto_num='Cryptococcus number of episodes';
	label dt_crypto='Initial Date';
	label dt_recent_crypto='Most Recent Date';
	label crypto_ongoing='Current ongoing diagnosis';
	label cryptospor_site='Site';
	label cryptospor_num='Cryptosporidiosis number of episodes';
	label dt_cryptospor='Initial Date';
	label dt_recent_cryptospor='Most Recent Date';
	label cryptospor_ongoing='Current ongoing diagnosis';
	label cmv_ret_num='CMV Retinitis number of episodes';
	label dt_cmv_ret='Initial Date';
	label dt_recent_cmv_ret='Most Recent Date';
	label cmv_ret_ongoing='Current ongoing diagnosis';
	label cmv_oth_site='Site';
	label cmv_oth_num='CMV Other number of episodes';
	label dt_cmv_oth='Initial Date';
	label dt_recent_cmv_oth='Most Recent Date';
	label cmv_oth_ongoing='Current ongoing diagnosis';
	label dementia_num='HIV Dementia number of episodes';
	label dt_dementia='Initial Date';
	label dt_recent_dementia='Most Recent Date';
	label dementia_ongoing='Current ongoing diagnosis';
	label hsv_oth_site='Site';
	label hsv_oth_num='HSV Other number of episodes';
	label dt_hsv_oth='Initial Date';
	label dt_recent_hsv_oth='Most Recent Date';
	label hsv_oth_ongoing='Current ongoing diagnosis';
	label histo_site='Site';
	label histo_num='Histoplasmosis number of episodes';
	label dt_histo='Initial Date';
	label dt_recent_histo='Most Recent Date';
	label histo_ongoing='Current ongoing diagnosis';
	label isospor_site='Site';
	label isospor_num='Isosporiasis number of episodes';
	label dt_isospor='Initial Date';
	label dt_recent_isospor='Most Recent Date';
	label isospor_ongoing='Current ongoing diagnosis';
	label ks_site='Site';
	label ks_num='KS number of episodes';
	label dt_ks='Initial Date';
	label dt_recent_ks='Most Recent Date';
	label ks_ongoing='Current ongoing diagnosis';
	label lip_num='LIP number of episodes';
	label dt_lip='Initial Date';
	label dt_recent_lip='Most Recent Date';
	label lip_ongoing='Current ongoing diagnosis';
	label burkitts_site='Site';
	label burkitts_num='Burkitts number of episodes';
	label dt_burkitts='Initial Date';
	label dt_recent_burkitts='Most Recent Date';
	label burkitts_ongoing='Current ongoing diagnosis';
	label lymphoma_site='Site';
	label lymphoma_num='Immunoblastic Lymphoma number of episodes';
	label dt_lymphoma='Initial Date';
	label dt_recent_lymphoma='Most Recent Date';
	label lymphoma_ongoing='Current ongoing diagnosis';
	label cns_num='CNS Lymphoma number of episodes';
	label dt_cns='Initial Date';
	label dt_recent_cns='Most Recent Date';
	label cns_ongoing='Current ongoing diagnosis';
	label mac_site='Site';
	label mac_num='MAC/M. kansasii number of episodes';
	label dt_mac='Initial Date';
	label dt_recent_mac='Most Recent Date';
	label mac_ongoing='Current ongoing diagnosis';
	label mtb_num='MTB (Pulmonary) number of episodes';
	label dt_mtb='Initial Date';
	label dt_recent_mtb='Most Recent Date';
	label mtb_ongoing='Current ongoing diagnosis';
	label eptb_site='Site';
	label eptb_num='EPTB number of episodes';
	label dt_eptb='Initial Date';
	label dt_recent_eptb='Most Recent Date';
	label eptb_ongoing='Current ongoing diagnosis';
	label ntm_site='Site';
	label ntm_num='NTM number of episodes';
	label dt_ntm='Initial Date';
	label dt_recent_ntm='Most Recent Date';
	label ntm_ongoing='Current ongoing diagnosis';
	label pcp_num='PCP number of episodes';
	label dt_pcp='Initial Date';
	label dt_recent_pcp='Most Recent Date';
	label pcp_ongoing='Current ongoing diagnosis';
	label pneumonia_num='Recurrent Pneumonia number of episodes';
	label dt_pneumonia='Initial Date';
	label dt_recent_pneumonia='Most Recent Date';
	label pneumonia_ongoing='Current ongoing diagnosis';
	label pml_num='PML number of episodes';
	label dt_pml='Initial Date';
	label dt_recent_pml='Most Recent Date';
	label pml_ongoing='Current ongoing diagnosis';
	label salmonella_site='Site';
	label salmonella_num='Salmonella number of episodes';
	label dt_salmonella='Initial Date';
	label dt_recent_salmonella='Most Recent Date';
	label salmonella_ongoing='Current ongoing diagnosis';
	label toxo_site='Site';
	label toxo_num='Toxoplasmosis number of episodes';
	label dt_toxo='Initial Date';
	label dt_recent_toxo='Most Recent Date';
	label toxo_ongoing='Current ongoing diagnosis';
	label wasting_num='Wasting Syndrome number of episodes';
	label dt_wasting='Initial Date';
	label dt_recent_wasting='Most Recent Date';
	label wasting_ongoing='Current ongoing diagnosis';
	label other_aids1='1. Other AIDS Condition';
	label other_site1='Site';
	label other_aids_num1='Other number of episodes';
	label dt_initial_aids1='Initial Date';
	label dt_recent_aids1='Most Recent Date';
	label other_aids1_ongoing='Current ongoing diagnosis';
	label other_aids2='2. Other AIDS Condition';
	label other_site2='Site';
	label other_aids_num2='Other number of episodes';
	label dt_initial_aids2='Initial Date';
	label dt_recent_aids2='Most Recent Date';
	label other_aids2_ongoing='Current ongoing diagnosis';
	label other_aids3='3. Other AIDS Condition';
	label other_site3='Site';
	label other_aids_num3='Other number of episodes';
	label dt_initial_aids3='Initial Date';
	label dt_recent_aids3='Most Recent Date';
	label other_aids3_ongoing='Current ongoing diagnosis';
	label other_aids4='4. Other AIDS Condition';
	label other_site4='Site';
	label other_aids_num4='Other number of episodes';
	label dt_initial_aids4='Initial Date';
	label dt_recent_aids4='Most Recent Date';
	label other_aids4_ongoing='Current ongoing diagnosis';
	label other_aids5='5. Other AIDS Condition';
	label other_site5='Site';
	label other_aids_num5='Other number of episodes';
	label dt_initial_aids5='Initial Date';
	label dt_recent_aids5='Most Recent Date';
	label other_aids5_ongoing='Current ongoing diagnosis';
	label aids_conditions_eeaa_complete='Complete?';
	run;

proc format;
	value aids_condition___1_ 0='Unchecked' 1='Checked';
	value aids_condition___2_ 0='Unchecked' 1='Checked';
	value aids_condition___3_ 0='Unchecked' 1='Checked';
	value aids_condition___4_ 0='Unchecked' 1='Checked';
	value aids_condition___5_ 0='Unchecked' 1='Checked';
	value aids_condition___6_ 0='Unchecked' 1='Checked';
	value aids_condition___7_ 0='Unchecked' 1='Checked';
	value aids_condition___8_ 0='Unchecked' 1='Checked';
	value aids_condition___9_ 0='Unchecked' 1='Checked';
	value aids_condition___10_ 0='Unchecked' 1='Checked';
	value aids_condition___11_ 0='Unchecked' 1='Checked';
	value aids_condition___12_ 0='Unchecked' 1='Checked';
	value aids_condition___13_ 0='Unchecked' 1='Checked';
	value aids_condition___14_ 0='Unchecked' 1='Checked';
	value aids_condition___15_ 0='Unchecked' 1='Checked';
	value aids_condition___16_ 0='Unchecked' 1='Checked';
	value aids_condition___17_ 0='Unchecked' 1='Checked';
	value aids_condition___18_ 0='Unchecked' 1='Checked';
	value aids_condition___19_ 0='Unchecked' 1='Checked';
	value aids_condition___20_ 0='Unchecked' 1='Checked';
	value aids_condition___21_ 0='Unchecked' 1='Checked';
	value aids_condition___22_ 0='Unchecked' 1='Checked';
	value aids_condition___23_ 0='Unchecked' 1='Checked';
	value aids_condition___24_ 0='Unchecked' 1='Checked';
	value aids_condition___25_ 0='Unchecked' 1='Checked';
	value aids_condition___26_ 0='Unchecked' 1='Checked';
	value aids_condition___27_ 0='Unchecked' 1='Checked';
	value aids_condition___28_ 0='Unchecked' 1='Checked';
	value aids_condition___99_ 0='Unchecked' 1='Checked';
	value infect_ongoing_ 1='Yes' 2='No';
	value cand_eso_ongoing_ 1='Yes' 2='No';
	value cand_oth_ongoing_ 1='Yes' 2='No';
	value cancer_ongoing_ 1='Yes' 2='No';
	value coccid_ongoing_ 1='Yes' 2='No';
	value crypto_ongoing_ 1='Yes' 2='No';
	value cryptospor_ongoing_ 1='Yes' 2='No';
	value cmv_ret_ongoing_ 1='Yes' 2='No';
	value cmv_oth_ongoing_ 1='Yes' 2='No';
	value dementia_ongoing_ 1='Yes' 2='No';
	value hsv_oth_ongoing_ 1='Yes' 2='No';
	value histo_ongoing_ 1='Yes' 2='No';
	value isospor_ongoing_ 1='Yes' 2='No';
	value ks_ongoing_ 1='Yes' 2='No';
	value lip_ongoing_ 1='Yes' 2='No';
	value burkitts_ongoing_ 1='Yes' 2='No';
	value lymphoma_ongoing_ 1='Yes' 2='No';
	value cns_ongoing_ 1='Yes' 2='No';
	value mac_ongoing_ 1='Yes' 2='No';
	value mtb_ongoing_ 1='Yes' 2='No';
	value eptb_ongoing_ 1='Yes' 2='No';
	value ntm_ongoing_ 1='Yes' 2='No';
	value pcp_ongoing_ 1='Yes' 2='No';
	value pneumonia_ongoing_ 1='Yes' 2='No';
	value pml_ongoing_ 1='Yes' 2='No';
	value salmonella_ongoing_ 1='Yes' 2='No';
	value toxo_ongoing_ 1='Yes' 2='No';
	value wasting_ongoing_ 1='Yes' 2='No';
	value other_aids1_ongoing_ 1='Yes' 2='No';
	value other_aids2_ongoing_ 1='Yes' 2='No';
	value other_aids3_ongoing_ 1='Yes' 2='No';
	value other_aids4_ongoing_ 1='Yes' 2='No';
	value other_aids5_ongoing_ 1='Yes' 2='No';
	value aids_conditions_eeaa_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format aids_condition___1 aids_condition___1_.;
	format aids_condition___2 aids_condition___2_.;
	format aids_condition___3 aids_condition___3_.;
	format aids_condition___4 aids_condition___4_.;
	format aids_condition___5 aids_condition___5_.;
	format aids_condition___6 aids_condition___6_.;
	format aids_condition___7 aids_condition___7_.;
	format aids_condition___8 aids_condition___8_.;
	format aids_condition___9 aids_condition___9_.;
	format aids_condition___10 aids_condition___10_.;
	format aids_condition___11 aids_condition___11_.;
	format aids_condition___12 aids_condition___12_.;
	format aids_condition___13 aids_condition___13_.;
	format aids_condition___14 aids_condition___14_.;
	format aids_condition___15 aids_condition___15_.;
	format aids_condition___16 aids_condition___16_.;
	format aids_condition___17 aids_condition___17_.;
	format aids_condition___18 aids_condition___18_.;
	format aids_condition___19 aids_condition___19_.;
	format aids_condition___20 aids_condition___20_.;
	format aids_condition___21 aids_condition___21_.;
	format aids_condition___22 aids_condition___22_.;
	format aids_condition___23 aids_condition___23_.;
	format aids_condition___24 aids_condition___24_.;
	format aids_condition___25 aids_condition___25_.;
	format aids_condition___26 aids_condition___26_.;
	format aids_condition___27 aids_condition___27_.;
	format aids_condition___28 aids_condition___28_.;
	format aids_condition___99 aids_condition___99_.;
	format infect_ongoing infect_ongoing_.;
	format cand_eso_ongoing cand_eso_ongoing_.;
	format cand_oth_ongoing cand_oth_ongoing_.;
	format cancer_ongoing cancer_ongoing_.;
	format coccid_ongoing coccid_ongoing_.;
	format crypto_ongoing crypto_ongoing_.;
	format cryptospor_ongoing cryptospor_ongoing_.;
	format cmv_ret_ongoing cmv_ret_ongoing_.;
	format cmv_oth_ongoing cmv_oth_ongoing_.;
	format dementia_ongoing dementia_ongoing_.;
	format hsv_oth_ongoing hsv_oth_ongoing_.;
	format histo_ongoing histo_ongoing_.;
	format isospor_ongoing isospor_ongoing_.;
	format ks_ongoing ks_ongoing_.;
	format lip_ongoing lip_ongoing_.;
	format burkitts_ongoing burkitts_ongoing_.;
	format lymphoma_ongoing lymphoma_ongoing_.;
	format cns_ongoing cns_ongoing_.;
	format mac_ongoing mac_ongoing_.;
	format mtb_ongoing mtb_ongoing_.;
	format eptb_ongoing eptb_ongoing_.;
	format ntm_ongoing ntm_ongoing_.;
	format pcp_ongoing pcp_ongoing_.;
	format pneumonia_ongoing pneumonia_ongoing_.;
	format pml_ongoing pml_ongoing_.;
	format salmonella_ongoing salmonella_ongoing_.;
	format toxo_ongoing toxo_ongoing_.;
	format wasting_ongoing wasting_ongoing_.;
	format other_aids1_ongoing other_aids1_ongoing_.;
	format other_aids2_ongoing other_aids2_ongoing_.;
	format other_aids3_ongoing other_aids3_ongoing_.;
	format other_aids4_ongoing other_aids4_ongoing_.;
	format other_aids5_ongoing other_aids5_ongoing_.;
	format aids_conditions_eeaa_complete aids_conditions_eeaa_complete_.;
	run;

proc contents data=redcap;
data brent.aids;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.aids short varnum; run;
