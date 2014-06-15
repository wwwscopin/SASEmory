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
infile "&path\CSV\followup_non_aids.CSV" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat non_aids_condition_follow___1 best32. ;
	informat non_aids_condition_follow___2 best32. ;
	informat non_aids_condition_follow___3 best32. ;
	informat non_aids_condition_follow___4 best32. ;
	informat non_aids_condition_follow___5 best32. ;
	informat non_aids_condition_follow___6 best32. ;
	informat non_aids_condition_follow___7 best32. ;
	informat non_aids_condition_follow___8 best32. ;
	informat non_aids_condition_follow___9 best32. ;
	informat non_aids_condition_follow___98 best32. ;
	informat non_aids_condition_follow___10 best32. ;
	informat non_aids_condition_follow___11 best32. ;
	informat non_aids_condition_follow___12 best32. ;
	informat non_aids_condition_follow___13 best32. ;
	informat non_aids_condition_follow___14 best32. ;
	informat non_aids_condition_follow___15 best32. ;
	informat non_aids_condition_follow___16 best32. ;
	informat non_aids_condition_follow___17 best32. ;
	informat non_aids_condition_follow___18 best32. ;
	informat non_aids_condition_follow___19 best32. ;
	informat non_aids_condition_follow___20 best32. ;
	informat non_aids_condition_follow___21 best32. ;
	informat non_aids_condition_follow___22 best32. ;
	informat non_aids_condition_follow___99 best32. ;
	informat rash_num_follow $500. ;
	informat dt_rash_follow yymmdd10. ;
	informat dt_recent_rash_follow yymmdd10. ;
	informat rash_ongoing_follow best32. ;
	informat anemia_num_follow $500. ;
	informat dt_anemia_follow yymmdd10. ;
	informat dt_recent_anemia_follow yymmdd10. ;
	informat anemia_ongoing_follow best32. ;
	informat pancreatitis_num_follow $500. ;
	informat dt_pancreatitis_follow yymmdd10. ;
	informat dt_recent_pancreatitis_follow yymmdd10. ;
	informat pancreatitis_ongoing_follow best32. ;
	informat hepatitis_num_follow $500. ;
	informat dt_hepatitis_follow yymmdd10. ;
	informat dt_recent_hepatitis_follow yymmdd10. ;
	informat hepatitis_ongoing_follow best32. ;
	informat lipo_num_follow $500. ;
	informat dt_lipo_follow yymmdd10. ;
	informat dt_recent_lipo_follow yymmdd10. ;
	informat lipo_ongoing_follow best32. ;
	informat neuropathy_num_follow $500. ;
	informat dt_neuropathy_follow yymmdd10. ;
	informat dt_recent_neuropathy_follow yymmdd10. ;
	informat neuropathy_ongoing_follow best32. ;
	informat diarrhea_num_follow $500. ;
	informat dt_diarrhea_follow yymmdd10. ;
	informat dt_recent_diarrhea_follow yymmdd10. ;
	informat diarrhea_ongoing_follow best32. ;
	informat acidosis_num_follow $500. ;
	informat dt_acidosis_follow yymmdd10. ;
	informat dt_recent_acidosis_follow yymmdd10. ;
	informat acidosis_ongoing_follow best32. ;
	informat lipidemia_num_follow $500. ;
	informat dt_lipidemia_follow yymmdd10. ;
	informat dt_recent_lipidemia_follow yymmdd10. ;
	informat lipidemia_ongoing_follow best32. ;
	informat ae_other_spec_follow $500. ;
	informat ae_other_num_follow $500. ;
	informat dt_ae_other_follow yymmdd10. ;
	informat dt_recent_ae_other_follow yymmdd10. ;
	informat ae_other_ongoing_follow best32. ;
	informat neuro_num_follow $500. ;
	informat dt_neuro_follow yymmdd10. ;
	informat dt_recent_neuro_follow yymmdd10. ;
	informat neuro_ongoing_follow best32. ;
	informat cardio_num_follow $500. ;
	informat dt_cardio_follow yymmdd10. ;
	informat dt_recent_cardio_follow yymmdd10. ;
	informat cardio_ongoing_follow best32. ;
	informat pulmonary_num_follow $500. ;
	informat dt_pulmonary_follow yymmdd10. ;
	informat dt_recent_pulmonary_follow yymmdd10. ;
	informat pulmonary_ongoing_follow best32. ;
	informat hema_num_follow $500. ;
	informat dt_hema_follow yymmdd10. ;
	informat dt_recent_hema_follow yymmdd10. ;
	informat hema_ongoing_follow best32. ;
	informat malig_num_follow $500. ;
	informat dt_malig_follow yymmdd10. ;
	informat dt_recent_malig_follow yymmdd10. ;
	informat malig_ongoing_follow best32. ;
	informat endocrine_num_follow $500. ;
	informat dt_endocrine_follow yymmdd10. ;
	informat dt_recent_endocrine_follow yymmdd10. ;
	informat endocrine_ongoing_follow best32. ;
	informat renal_num_follow $500. ;
	informat dt_renal_follow yymmdd10. ;
	informat dt_recent_renal_follow yymmdd10. ;
	informat renal_ongoing_follow best32. ;
	informat hepato_num_follow $500. ;
	informat dt_hepato_follow yymmdd10. ;
	informat dt_recent_hepato_follow yymmdd10. ;
	informat hepato_ongoing_follow best32. ;
	informat gastro_num_follow $500. ;
	informat dt_gastro_follow yymmdd10. ;
	informat dt_recent_gastro_follow yymmdd10. ;
	informat gastro_ongoing_follow best32. ;
	informat derm_num_follow $500. ;
	informat dt_derm_follow yymmdd10. ;
	informat dt_recent_derm_follow yymmdd10. ;
	informat derm_ongoing_follow best32. ;
	informat id_num_follow $500. ;
	informat dt_id_follow yymmdd10. ;
	informat dt_recent_id_follow yymmdd10. ;
	informat id_ongoing_follow best32. ;
	informat rheum_num_follow $500. ;
	informat dt_rheum_follow yymmdd10. ;
	informat dt_recent_rheum_follow yymmdd10. ;
	informat rheum_ongoing_follow best32. ;
	informat obgyn_list_follow $500. ;
	informat obgyn_num_follow $500. ;
	informat dt_obgyn_follow yymmdd10. ;
	informat dt_recent_obgyn_follow yymmdd10. ;
	informat obgyn_ongoing_follow best32. ;
	informat other_non_aids1_follow $500. ;
	informat other_non_aids_num1_follow $500. ;
	informat dt_initial_non_aids1_follow yymmdd10. ;
	informat dt_recent_non_aids1_follow yymmdd10. ;
	informat other_non_aids1_ongoing_follow best32. ;
	informat other_non_aids2_follow $500. ;
	informat other_non_aids_num2_follow $500. ;
	informat dt_initial_non_aids2_follow yymmdd10. ;
	informat dt_recent_non_aids2_follow yymmdd10. ;
	informat other_non_aids2_ongoing_follow best32. ;
	informat other_non_aids3_follow $500. ;
	informat other_non_aids_num3_follow $500. ;
	informat dt_initial_non_aids3_follow yymmdd10. ;
	informat dt_recent_non_aids3_follow yymmdd10. ;
	informat other_non_aids3_ongoing_follow best32. ;
	informat other_non_aids4_follow $500. ;
	informat other_non_aids_num4_follow $500. ;
	informat dt_initial_non_aids4_follow yymmdd10. ;
	informat dt_recent_non_aids4_follow yymmdd10. ;
	informat other_non_aids4_ongoing_follow best32. ;
	informat other_non_aids5_follow $500. ;
	informat other_non_aids_num5_follow $500. ;
	informat dt_initial_non_aids5_follow yymmdd10. ;
	informat dt_recent_non_aids5_follow yymmdd10. ;
	informat other_non_aids5_ongoing_follow best32. ;
	informat follow_up_nonaids_co_v_0 best32. ;

	format patient_id $500. ;
	format non_aids_condition_follow___1 best12. ;
	format non_aids_condition_follow___2 best12. ;
	format non_aids_condition_follow___3 best12. ;
	format non_aids_condition_follow___4 best12. ;
	format non_aids_condition_follow___5 best12. ;
	format non_aids_condition_follow___6 best12. ;
	format non_aids_condition_follow___7 best12. ;
	format non_aids_condition_follow___8 best12. ;
	format non_aids_condition_follow___9 best12. ;
	format non_aids_condition_follow___98 best12. ;
	format non_aids_condition_follow___10 best12. ;
	format non_aids_condition_follow___11 best12. ;
	format non_aids_condition_follow___12 best12. ;
	format non_aids_condition_follow___13 best12. ;
	format non_aids_condition_follow___14 best12. ;
	format non_aids_condition_follow___15 best12. ;
	format non_aids_condition_follow___16 best12. ;
	format non_aids_condition_follow___17 best12. ;
	format non_aids_condition_follow___18 best12. ;
	format non_aids_condition_follow___19 best12. ;
	format non_aids_condition_follow___20 best12. ;
	format non_aids_condition_follow___21 best12. ;
	format non_aids_condition_follow___22 best12. ;
	format non_aids_condition_follow___99 best12. ;
	format rash_num_follow $500. ;
	format dt_rash_follow yymmdd10. ;
	format dt_recent_rash_follow yymmdd10. ;
	format rash_ongoing_follow best12. ;
	format anemia_num_follow $500. ;
	format dt_anemia_follow yymmdd10. ;
	format dt_recent_anemia_follow yymmdd10. ;
	format anemia_ongoing_follow best12. ;
	format pancreatitis_num_follow $500. ;
	format dt_pancreatitis_follow yymmdd10. ;
	format dt_recent_pancreatitis_follow yymmdd10. ;
	format pancreatitis_ongoing_follow best12. ;
	format hepatitis_num_follow $500. ;
	format dt_hepatitis_follow yymmdd10. ;
	format dt_recent_hepatitis_follow yymmdd10. ;
	format hepatitis_ongoing_follow best12. ;
	format lipo_num_follow $500. ;
	format dt_lipo_follow yymmdd10. ;
	format dt_recent_lipo_follow yymmdd10. ;
	format lipo_ongoing_follow best12. ;
	format neuropathy_num_follow $500. ;
	format dt_neuropathy_follow yymmdd10. ;
	format dt_recent_neuropathy_follow yymmdd10. ;
	format neuropathy_ongoing_follow best12. ;
	format diarrhea_num_follow $500. ;
	format dt_diarrhea_follow yymmdd10. ;
	format dt_recent_diarrhea_follow yymmdd10. ;
	format diarrhea_ongoing_follow best12. ;
	format acidosis_num_follow $500. ;
	format dt_acidosis_follow yymmdd10. ;
	format dt_recent_acidosis_follow yymmdd10. ;
	format acidosis_ongoing_follow best12. ;
	format lipidemia_num_follow $500. ;
	format dt_lipidemia_follow yymmdd10. ;
	format dt_recent_lipidemia_follow yymmdd10. ;
	format lipidemia_ongoing_follow best12. ;
	format ae_other_spec_follow $500. ;
	format ae_other_num_follow $500. ;
	format dt_ae_other_follow yymmdd10. ;
	format dt_recent_ae_other_follow yymmdd10. ;
	format ae_other_ongoing_follow best12. ;
	format neuro_num_follow $500. ;
	format dt_neuro_follow yymmdd10. ;
	format dt_recent_neuro_follow yymmdd10. ;
	format neuro_ongoing_follow best12. ;
	format cardio_num_follow $500. ;
	format dt_cardio_follow yymmdd10. ;
	format dt_recent_cardio_follow yymmdd10. ;
	format cardio_ongoing_follow best12. ;
	format pulmonary_num_follow $500. ;
	format dt_pulmonary_follow yymmdd10. ;
	format dt_recent_pulmonary_follow yymmdd10. ;
	format pulmonary_ongoing_follow best12. ;
	format hema_num_follow $500. ;
	format dt_hema_follow yymmdd10. ;
	format dt_recent_hema_follow yymmdd10. ;
	format hema_ongoing_follow best12. ;
	format malig_num_follow $500. ;
	format dt_malig_follow yymmdd10. ;
	format dt_recent_malig_follow yymmdd10. ;
	format malig_ongoing_follow best12. ;
	format endocrine_num_follow $500. ;
	format dt_endocrine_follow yymmdd10. ;
	format dt_recent_endocrine_follow yymmdd10. ;
	format endocrine_ongoing_follow best12. ;
	format renal_num_follow $500. ;
	format dt_renal_follow yymmdd10. ;
	format dt_recent_renal_follow yymmdd10. ;
	format renal_ongoing_follow best12. ;
	format hepato_num_follow $500. ;
	format dt_hepato_follow yymmdd10. ;
	format dt_recent_hepato_follow yymmdd10. ;
	format hepato_ongoing_follow best12. ;
	format gastro_num_follow $500. ;
	format dt_gastro_follow yymmdd10. ;
	format dt_recent_gastro_follow yymmdd10. ;
	format gastro_ongoing_follow best12. ;
	format derm_num_follow $500. ;
	format dt_derm_follow yymmdd10. ;
	format dt_recent_derm_follow yymmdd10. ;
	format derm_ongoing_follow best12. ;
	format id_num_follow $500. ;
	format dt_id_follow yymmdd10. ;
	format dt_recent_id_follow yymmdd10. ;
	format id_ongoing_follow best12. ;
	format rheum_num_follow $500. ;
	format dt_rheum_follow yymmdd10. ;
	format dt_recent_rheum_follow yymmdd10. ;
	format rheum_ongoing_follow best12. ;
	format obgyn_list_follow $500. ;
	format obgyn_num_follow $500. ;
	format dt_obgyn_follow yymmdd10. ;
	format dt_recent_obgyn_follow yymmdd10. ;
	format obgyn_ongoing_follow best12. ;
	format other_non_aids1_follow $500. ;
	format other_non_aids_num1_follow $500. ;
	format dt_initial_non_aids1_follow yymmdd10. ;
	format dt_recent_non_aids1_follow yymmdd10. ;
	format other_non_aids1_ongoing_follow best12. ;
	format other_non_aids2_follow $500. ;
	format other_non_aids_num2_follow $500. ;
	format dt_initial_non_aids2_follow yymmdd10. ;
	format dt_recent_non_aids2_follow yymmdd10. ;
	format other_non_aids2_ongoing_follow best12. ;
	format other_non_aids3_follow $500. ;
	format other_non_aids_num3_follow $500. ;
	format dt_initial_non_aids3_follow yymmdd10. ;
	format dt_recent_non_aids3_follow yymmdd10. ;
	format other_non_aids3_ongoing_follow best12. ;
	format other_non_aids4_follow $500. ;
	format other_non_aids_num4_follow $500. ;
	format dt_initial_non_aids4_follow yymmdd10. ;
	format dt_recent_non_aids4_follow yymmdd10. ;
	format other_non_aids4_ongoing_follow best12. ;
	format other_non_aids5_follow $500. ;
	format other_non_aids_num5_follow $500. ;
	format dt_initial_non_aids5_follow yymmdd10. ;
	format dt_recent_non_aids5_follow yymmdd10. ;
	format other_non_aids5_ongoing_follow best12. ;
	format follow_up_nonaids_co_v_0 best12. ;

input
		patient_id $
		non_aids_condition_follow___1
		non_aids_condition_follow___2
		non_aids_condition_follow___3
		non_aids_condition_follow___4
		non_aids_condition_follow___5
		non_aids_condition_follow___6
		non_aids_condition_follow___7
		non_aids_condition_follow___8
		non_aids_condition_follow___9
		non_aids_condition_follow___98
		non_aids_condition_follow___10
		non_aids_condition_follow___11
		non_aids_condition_follow___12
		non_aids_condition_follow___13
		non_aids_condition_follow___14
		non_aids_condition_follow___15
		non_aids_condition_follow___16
		non_aids_condition_follow___17
		non_aids_condition_follow___18
		non_aids_condition_follow___19
		non_aids_condition_follow___20
		non_aids_condition_follow___21
		non_aids_condition_follow___22
		non_aids_condition_follow___99
		rash_num_follow $
		dt_rash_follow
		dt_recent_rash_follow
		rash_ongoing_follow
		anemia_num_follow $
		dt_anemia_follow
		dt_recent_anemia_follow
		anemia_ongoing_follow
		pancreatitis_num_follow $
		dt_pancreatitis_follow
		dt_recent_pancreatitis_follow
		pancreatitis_ongoing_follow
		hepatitis_num_follow $
		dt_hepatitis_follow
		dt_recent_hepatitis_follow
		hepatitis_ongoing_follow
		lipo_num_follow $
		dt_lipo_follow
		dt_recent_lipo_follow
		lipo_ongoing_follow
		neuropathy_num_follow $
		dt_neuropathy_follow
		dt_recent_neuropathy_follow
		neuropathy_ongoing_follow
		diarrhea_num_follow $
		dt_diarrhea_follow
		dt_recent_diarrhea_follow
		diarrhea_ongoing_follow
		acidosis_num_follow $
		dt_acidosis_follow
		dt_recent_acidosis_follow
		acidosis_ongoing_follow
		lipidemia_num_follow $
		dt_lipidemia_follow
		dt_recent_lipidemia_follow
		lipidemia_ongoing_follow
		ae_other_spec_follow $
		ae_other_num_follow $
		dt_ae_other_follow
		dt_recent_ae_other_follow
		ae_other_ongoing_follow
		neuro_num_follow $
		dt_neuro_follow
		dt_recent_neuro_follow
		neuro_ongoing_follow
		cardio_num_follow $
		dt_cardio_follow
		dt_recent_cardio_follow
		cardio_ongoing_follow
		pulmonary_num_follow $
		dt_pulmonary_follow
		dt_recent_pulmonary_follow
		pulmonary_ongoing_follow
		hema_num_follow $
		dt_hema_follow
		dt_recent_hema_follow
		hema_ongoing_follow
		malig_num_follow $
		dt_malig_follow
		dt_recent_malig_follow
		malig_ongoing_follow
		endocrine_num_follow $
		dt_endocrine_follow
		dt_recent_endocrine_follow
		endocrine_ongoing_follow
		renal_num_follow $
		dt_renal_follow
		dt_recent_renal_follow
		renal_ongoing_follow
		hepato_num_follow $
		dt_hepato_follow
		dt_recent_hepato_follow
		hepato_ongoing_follow
		gastro_num_follow $
		dt_gastro_follow
		dt_recent_gastro_follow
		gastro_ongoing_follow
		derm_num_follow $
		dt_derm_follow
		dt_recent_derm_follow
		derm_ongoing_follow
		id_num_follow $
		dt_id_follow
		dt_recent_id_follow
		id_ongoing_follow
		rheum_num_follow $
		dt_rheum_follow
		dt_recent_rheum_follow
		rheum_ongoing_follow
		obgyn_list_follow $
		obgyn_num_follow $
		dt_obgyn_follow
		dt_recent_obgyn_follow
		obgyn_ongoing_follow
		other_non_aids1_follow $
		other_non_aids_num1_follow $
		dt_initial_non_aids1_follow
		dt_recent_non_aids1_follow
		other_non_aids1_ongoing_follow
		other_non_aids2_follow $
		other_non_aids_num2_follow $
		dt_initial_non_aids2_follow
		dt_recent_non_aids2_follow
		other_non_aids2_ongoing_follow
		other_non_aids3_follow $
		other_non_aids_num3_follow $
		dt_initial_non_aids3_follow
		dt_recent_non_aids3_follow
		other_non_aids3_ongoing_follow
		other_non_aids4_follow $
		other_non_aids_num4_follow $
		dt_initial_non_aids4_follow
		dt_recent_non_aids4_follow
		other_non_aids4_ongoing_follow
		other_non_aids5_follow $
		other_non_aids_num5_follow $
		dt_initial_non_aids5_follow
		dt_recent_non_aids5_follow
		other_non_aids5_ongoing_follow
		follow_up_nonaids_co_v_0
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label non_aids_condition_follow___1='Serious non-AIDS condition (choice=Rash)';
	label non_aids_condition_follow___2='Serious non-AIDS condition (choice=Anemia)';
	label non_aids_condition_follow___3='Serious non-AIDS condition (choice=Pancreatitis)';
	label non_aids_condition_follow___4='Serious non-AIDS condition (choice=Hepatitis)';
	label non_aids_condition_follow___5='Serious non-AIDS condition (choice=Lipodystrophy)';
	label non_aids_condition_follow___6='Serious non-AIDS condition (choice=Peripheral Neuropathy)';
	label non_aids_condition_follow___7='Serious non-AIDS condition (choice=Diarrhea)';
	label non_aids_condition_follow___8='Serious non-AIDS condition (choice=Lactic Acidosis)';
	label non_aids_condition_follow___9='Serious non-AIDS condition (choice=Hyperlipidemia)';
	label non_aids_condition_follow___98='Serious non-AIDS condition (choice=Other Adverse Event)';
	label non_aids_condition_follow___10='Serious non-AIDS condition (choice=Neuropsychological)';
	label non_aids_condition_follow___11='Serious non-AIDS condition (choice=Cardiovascular)';
	label non_aids_condition_follow___12='Serious non-AIDS condition (choice=Pulmonary)';
	label non_aids_condition_follow___13='Serious non-AIDS condition (choice=Hematological)';
	label non_aids_condition_follow___14='Serious non-AIDS condition (choice=Malignancy)';
	label non_aids_condition_follow___15='Serious non-AIDS condition (choice=Endocrine)';
	label non_aids_condition_follow___16='Serious non-AIDS condition (choice=Renal)';
	label non_aids_condition_follow___17='Serious non-AIDS condition (choice=Hepatobiliary)';
	label non_aids_condition_follow___18='Serious non-AIDS condition (choice=Gastrointestinal)';
	label non_aids_condition_follow___19='Serious non-AIDS condition (choice=Dermatological)';
	label non_aids_condition_follow___20='Serious non-AIDS condition (choice=Infectious Disease)';
	label non_aids_condition_follow___21='Serious non-AIDS condition (choice=Rheumatological)';
	label non_aids_condition_follow___22='Serious non-AIDS condition (choice=OB/GYN)';
	label non_aids_condition_follow___99='Serious non-AIDS condition (choice=Other)';
	label rash_num_follow='Rash number of episodes';
	label dt_rash_follow='Initial Date';
	label dt_recent_rash_follow='Most Recent Date';
	label rash_ongoing_follow='Current ongoing diagnosis';
	label anemia_num_follow='Anemia number of episodes';
	label dt_anemia_follow='Initial Date';
	label dt_recent_anemia_follow='Most Recent Date';
	label anemia_ongoing_follow='Current ongoing diagnosis';
	label pancreatitis_num_follow='Pancreatitis number of episodes';
	label dt_pancreatitis_follow='Initial Date';
	label dt_recent_pancreatitis_follow='Most Recent Date';
	label pancreatitis_ongoing_follow='Current ongoing diagnosis';
	label hepatitis_num_follow='Hepatitis number of episodes';
	label dt_hepatitis_follow='Initial Date';
	label dt_recent_hepatitis_follow='Most Recent Date';
	label hepatitis_ongoing_follow='Current ongoing diagnosis';
	label lipo_num_follow='Lipodystrophy number of episodes';
	label dt_lipo_follow='Initial Date';
	label dt_recent_lipo_follow='Most Recent Date';
	label lipo_ongoing_follow='Current ongoing diagnosis';
	label neuropathy_num_follow='Peripheral Neuropathy number of episodes';
	label dt_neuropathy_follow='Initial Date';
	label dt_recent_neuropathy_follow='Most Recent Date';
	label neuropathy_ongoing_follow='Current ongoing diagnosis';
	label diarrhea_num_follow='Diarrhea number of episodes';
	label dt_diarrhea_follow='Initial Date';
	label dt_recent_diarrhea_follow='Most Recent Date';
	label diarrhea_ongoing_follow='Current ongoing diagnosis';
	label acidosis_num_follow='Lactic Acidosis number of episodes';
	label dt_acidosis_follow='Initial Date';
	label dt_recent_acidosis_follow='Most Recent Date';
	label acidosis_ongoing_follow='Current ongoing diagnosis';
	label lipidemia_num_follow='Hyperlipidemia number of episodes';
	label dt_lipidemia_follow='Initial Date';
	label dt_recent_lipidemia_follow='Most Recent Date';
	label lipidemia_ongoing_follow='Current ongoing diagnosis';
	label ae_other_spec_follow='Other Specific';
	label ae_other_num_follow='Other Adverse Event number of episodes';
	label dt_ae_other_follow='Initial Date';
	label dt_recent_ae_other_follow='Most Recent Date';
	label ae_other_ongoing_follow='Current ongoing diagnosis';
	label neuro_num_follow='Neuropsychological number of episodes';
	label dt_neuro_follow='Initial Date';
	label dt_recent_neuro_follow='Most Recent Date';
	label neuro_ongoing_follow='Current ongoing diagnosis';
	label cardio_num_follow='Cardiovascular number of episodes';
	label dt_cardio_follow='Initial Date';
	label dt_recent_cardio_follow='Most Recent Date';
	label cardio_ongoing_follow='Current ongoing diagnosis';
	label pulmonary_num_follow='Pulmonary number of episodes';
	label dt_pulmonary_follow='Initial Date';
	label dt_recent_pulmonary_follow='Most Recent Date';
	label pulmonary_ongoing_follow='Current ongoing diagnosis';
	label hema_num_follow='Hematological number of episodes';
	label dt_hema_follow='Initial Date';
	label dt_recent_hema_follow='Most Recent Date';
	label hema_ongoing_follow='Current ongoing diagnosis';
	label malig_num_follow='Malignancy number of episodes';
	label dt_malig_follow='Initial Date';
	label dt_recent_malig_follow='Most Recent Date';
	label malig_ongoing_follow='Current ongoing diagnosis';
	label endocrine_num_follow='Endocrine number of episodes';
	label dt_endocrine_follow='Initial Date';
	label dt_recent_endocrine_follow='Most Recent Date';
	label endocrine_ongoing_follow='Current ongoing diagnosis';
	label renal_num_follow='Renal number of episodes';
	label dt_renal_follow='Initial Date';
	label dt_recent_renal_follow='Most Recent Date';
	label renal_ongoing_follow='Current ongoing diagnosis';
	label hepato_num_follow='Hepatobiliary number of episodes';
	label dt_hepato_follow='Initial Date';
	label dt_recent_hepato_follow='Most Recent Date';
	label hepato_ongoing_follow='Current ongoing diagnosis';
	label gastro_num_follow='Gastrointestinal number of episodes';
	label dt_gastro_follow='Initial Date';
	label dt_recent_gastro_follow='Most Recent Date';
	label gastro_ongoing_follow='Current ongoing diagnosis';
	label derm_num_follow='Dermatological number of episodes';
	label dt_derm_follow='Initial Date';
	label dt_recent_derm_follow='Most Recent Date';
	label derm_ongoing_follow='Current ongoing diagnosis';
	label id_num_follow='Infectious Disease number of episodes';
	label dt_id_follow='Initial Date';
	label dt_recent_id_follow='Most Recent Date';
	label id_ongoing_follow='Current ongoing diagnosis';
	label rheum_num_follow='Rheumatological number of episodes';
	label dt_rheum_follow='Initial Date';
	label dt_recent_rheum_follow='Most Recent Date';
	label rheum_ongoing_follow='Current ongoing diagnosis';
	label obgyn_list_follow='OB/GYN List';
	label obgyn_num_follow='OB/GYN number of episodes';
	label dt_obgyn_follow='Initial Date';
	label dt_recent_obgyn_follow='Most Recent Date';
	label obgyn_ongoing_follow='Current ongoing diagnosis';
	label other_non_aids1_follow='1. Other Non-AIDS Condition';
	label other_non_aids_num1_follow='Other number of episodes';
	label dt_initial_non_aids1_follow='Initial Date';
	label dt_recent_non_aids1_follow='Most Recent Date';
	label other_non_aids1_ongoing_follow='Current ongoing diagnosis';
	label other_non_aids2_follow='2. Other Non-AIDS Condition';
	label other_non_aids_num2_follow='Other number of episodes';
	label dt_initial_non_aids2_follow='Initial Date';
	label dt_recent_non_aids2_follow='Most Recent Date';
	label other_non_aids2_ongoing_follow='Current ongoing diagnosis';
	label other_non_aids3_follow='3. Other Non-AIDS Condition';
	label other_non_aids_num3_follow='Other number of episodes';
	label dt_initial_non_aids3_follow='Initial Date';
	label dt_recent_non_aids3_follow='Most Recent Date';
	label other_non_aids3_ongoing_follow='Current ongoing diagnosis';
	label other_non_aids4_follow='4. Other Non-AIDS Condition';
	label other_non_aids_num4_follow='Other number of episodes';
	label dt_initial_non_aids4_follow='Initial Date';
	label dt_recent_non_aids4_follow='Most Recent Date';
	label other_non_aids4_ongoing_follow='Current ongoing diagnosis';
	label other_non_aids5_follow='5. Other Non-AIDS Condition';
	label other_non_aids_num5_follow='Other number of episodes';
	label dt_initial_non_aids5_follow='Initial Date';
	label dt_recent_non_aids5_follow='Most Recent Date';
	label other_non_aids5_ongoing_follow='Current ongoing diagnosis';
	label follow_up_nonaids_co_v_0='Complete?';
	run;

proc format;
	value non_aids_condition_follow___1_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___2_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___3_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___4_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___5_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___6_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___7_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___8_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___9_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___98_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___10_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___11_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___12_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___13_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___14_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___15_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___16_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___17_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___18_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___19_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___20_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___21_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___22_ 0='Unchecked' 1='Checked';
	value non_aids_condition_follow___99_ 0='Unchecked' 1='Checked';
	value rash_ongoing_follow_ 1='Yes' 2='No';
	value anemia_ongoing_follow_ 1='Yes' 2='No';
	value pancreatitis_ongoing_follow_ 1='Yes' 2='No';
	value hepatitis_ongoing_follow_ 1='Yes' 2='No';
	value lipo_ongoing_follow_ 1='Yes' 2='No';
	value neuropathy_ongoing_follow_ 1='Yes' 2='No';
	value diarrhea_ongoing_follow_ 1='Yes' 2='No';
	value acidosis_ongoing_follow_ 1='Yes' 2='No';
	value lipidemia_ongoing_follow_ 1='Yes' 2='No';
	value ae_other_ongoing_follow_ 1='Yes' 2='No';
	value neuro_ongoing_follow_ 1='Yes' 2='No';
	value cardio_ongoing_follow_ 1='Yes' 2='No';
	value pulmonary_ongoing_follow_ 1='Yes' 2='No';
	value hema_ongoing_follow_ 1='Yes' 2='No';
	value malig_ongoing_follow_ 1='Yes' 2='No';
	value endocrine_ongoing_follow_ 1='Yes' 2='No';
	value renal_ongoing_follow_ 1='Yes' 2='No';
	value hepato_ongoing_follow_ 1='Yes' 2='No';
	value gastro_ongoing_follow_ 1='Yes' 2='No';
	value derm_ongoing_follow_ 1='Yes' 2='No';
	value id_ongoing_follow_ 1='Yes' 2='No';
	value rheum_ongoing_follow_ 1='Yes' 2='No';
	value obgyn_ongoing_follow_ 1='Yes' 2='No';
	value other_non_aids1_ongoing_follow_ 1='Yes' 2='No';
	value other_non_aids2_ongoing_follow_ 1='Yes' 2='No';
	value other_non_aids3_ongoing_follow_ 1='Yes' 2='No';
	value other_non_aids4_ongoing_follow_ 1='Yes' 2='No';
	value other_non_aids5_ongoing_follow_ 1='Yes' 2='No';
	value follow_up_nonaids_co_v_0_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format non_aids_condition_follow___1 non_aids_condition_follow___1_.;
	format non_aids_condition_follow___2 non_aids_condition_follow___2_.;
	format non_aids_condition_follow___3 non_aids_condition_follow___3_.;
	format non_aids_condition_follow___4 non_aids_condition_follow___4_.;
	format non_aids_condition_follow___5 non_aids_condition_follow___5_.;
	format non_aids_condition_follow___6 non_aids_condition_follow___6_.;
	format non_aids_condition_follow___7 non_aids_condition_follow___7_.;
	format non_aids_condition_follow___8 non_aids_condition_follow___8_.;
	format non_aids_condition_follow___9 non_aids_condition_follow___9_.;
	format non_aids_condition_follow___98 non_aids_condition_follow___98_.;
	format non_aids_condition_follow___10 non_aids_condition_follow___10_.;
	format non_aids_condition_follow___11 non_aids_condition_follow___11_.;
	format non_aids_condition_follow___12 non_aids_condition_follow___12_.;
	format non_aids_condition_follow___13 non_aids_condition_follow___13_.;
	format non_aids_condition_follow___14 non_aids_condition_follow___14_.;
	format non_aids_condition_follow___15 non_aids_condition_follow___15_.;
	format non_aids_condition_follow___16 non_aids_condition_follow___16_.;
	format non_aids_condition_follow___17 non_aids_condition_follow___17_.;
	format non_aids_condition_follow___18 non_aids_condition_follow___18_.;
	format non_aids_condition_follow___19 non_aids_condition_follow___19_.;
	format non_aids_condition_follow___20 non_aids_condition_follow___20_.;
	format non_aids_condition_follow___21 non_aids_condition_follow___21_.;
	format non_aids_condition_follow___22 non_aids_condition_follow___22_.;
	format non_aids_condition_follow___99 non_aids_condition_follow___99_.;
	format rash_ongoing_follow rash_ongoing_follow_.;
	format anemia_ongoing_follow anemia_ongoing_follow_.;
	format pancreatitis_ongoing_follow pancreatitis_ongoing_follow_.;
	format hepatitis_ongoing_follow hepatitis_ongoing_follow_.;
	format lipo_ongoing_follow lipo_ongoing_follow_.;
	format neuropathy_ongoing_follow neuropathy_ongoing_follow_.;
	format diarrhea_ongoing_follow diarrhea_ongoing_follow_.;
	format acidosis_ongoing_follow acidosis_ongoing_follow_.;
	format lipidemia_ongoing_follow lipidemia_ongoing_follow_.;
	format ae_other_ongoing_follow ae_other_ongoing_follow_.;
	format neuro_ongoing_follow neuro_ongoing_follow_.;
	format cardio_ongoing_follow cardio_ongoing_follow_.;
	format pulmonary_ongoing_follow pulmonary_ongoing_follow_.;
	format hema_ongoing_follow hema_ongoing_follow_.;
	format malig_ongoing_follow malig_ongoing_follow_.;
	format endocrine_ongoing_follow endocrine_ongoing_follow_.;
	format renal_ongoing_follow renal_ongoing_follow_.;
	format hepato_ongoing_follow hepato_ongoing_follow_.;
	format gastro_ongoing_follow gastro_ongoing_follow_.;
	format derm_ongoing_follow derm_ongoing_follow_.;
	format id_ongoing_follow id_ongoing_follow_.;
	format rheum_ongoing_follow rheum_ongoing_follow_.;
	format obgyn_ongoing_follow obgyn_ongoing_follow_.;
	format other_non_aids1_ongoing_follow other_non_aids1_ongoing_follow_.;
	format other_non_aids2_ongoing_follow other_non_aids2_ongoing_follow_.;
	format other_non_aids3_ongoing_follow other_non_aids3_ongoing_follow_.;
	format other_non_aids4_ongoing_follow other_non_aids4_ongoing_follow_.;
	format other_non_aids5_ongoing_follow other_non_aids5_ongoing_follow_.;
	format follow_up_nonaids_co_v_0 follow_up_nonaids_co_v_0_.;
	run;

data brent.followup_non_aids;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;

