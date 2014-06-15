%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\non_aids.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat non_aids_condition___1 best32. ;
	informat non_aids_condition___2 best32. ;
	informat non_aids_condition___3 best32. ;
	informat non_aids_condition___4 best32. ;
	informat non_aids_condition___5 best32. ;
	informat non_aids_condition___6 best32. ;
	informat non_aids_condition___7 best32. ;
	informat non_aids_condition___8 best32. ;
	informat non_aids_condition___9 best32. ;
	informat non_aids_condition___98 best32. ;
	informat non_aids_condition___10 best32. ;
	informat non_aids_condition___11 best32. ;
	informat non_aids_condition___12 best32. ;
	informat non_aids_condition___13 best32. ;
	informat non_aids_condition___14 best32. ;
	informat non_aids_condition___15 best32. ;
	informat non_aids_condition___16 best32. ;
	informat non_aids_condition___17 best32. ;
	informat non_aids_condition___18 best32. ;
	informat non_aids_condition___19 best32. ;
	informat non_aids_condition___20 best32. ;
	informat non_aids_condition___21 best32. ;
	informat non_aids_condition___22 best32. ;
	informat non_aids_condition___99 best32. ;
	informat rash_num $500. ;
	informat rash_spec $500. ;
	informat dt_rash yymmdd10. ;
	informat dt_recent_rash yymmdd10. ;
	informat rash_ongoing best32. ;
	informat anemia_num $500. ;
	informat anemia_spec $500. ;
	informat dt_anemia yymmdd10. ;
	informat dt_recent_anemia yymmdd10. ;
	informat anemia_ongoing best32. ;
	informat pancreatitis_num $500. ;
	informat pancreatitis_spec $500. ;
	informat dt_pancreatitis yymmdd10. ;
	informat dt_recent_pancreatitis yymmdd10. ;
	informat pancreatitis_ongoing best32. ;
	informat hepatitis_num $500. ;
	informat hepatitis_cond_spec $500. ;
	informat dt_hepatitis yymmdd10. ;
	informat dt_recent_hepatitis yymmdd10. ;
	informat hepatitis_ongoing best32. ;
	informat lipo_num $500. ;
	informat lipo_spec $500. ;
	informat dt_lipo yymmdd10. ;
	informat dt_recent_lipo yymmdd10. ;
	informat lipo_ongoing best32. ;
	informat neuropathy_num $500. ;
	informat neuropathy_spec $500. ;
	informat dt_neuropathy yymmdd10. ;
	informat dt_recent_neuropathy yymmdd10. ;
	informat neuropathy_ongoing best32. ;
	informat diarrhea_num $500. ;
	informat diarrhea_spec $500. ;
	informat dt_diarrhea yymmdd10. ;
	informat dt_recent_diarrhea yymmdd10. ;
	informat diarrhea_ongoing best32. ;
	informat acidosis_num $500. ;
	informat acidosis_spec $500. ;
	informat dt_acidosis yymmdd10. ;
	informat dt_recent_acidosis yymmdd10. ;
	informat acidosis_ongoing best32. ;
	informat lipidemia_num $500. ;
	informat lipidemia_spec $500. ;
	informat dt_lipidemia yymmdd10. ;
	informat dt_recent_lipidemia yymmdd10. ;
	informat lipidemia_ongoing best32. ;
	informat ae_other_num $500. ;
	informat ae_other_spec $500. ;
	informat dt_ae_other yymmdd10. ;
	informat dt_recent_ae_other yymmdd10. ;
	informat ae_other_ongoing best32. ;
	informat neuro_num $500. ;
	informat neuro_spec $500. ;
	informat dt_neuro yymmdd10. ;
	informat dt_recent_neuro yymmdd10. ;
	informat neuro_ongoing best32. ;
	informat cardio_num $500. ;
	informat cardio_spec $500. ;
	informat dt_cardio yymmdd10. ;
	informat dt_recent_cardio yymmdd10. ;
	informat cardio_ongoing best32. ;
	informat pulmonary_num $500. ;
	informat pulmonary_spec $500. ;
	informat dt_pulmonary yymmdd10. ;
	informat dt_recent_pulmonary yymmdd10. ;
	informat pulmonary_ongoing best32. ;
	informat hema_num $500. ;
	informat hema_spec $500. ;
	informat dt_hema yymmdd10. ;
	informat dt_recent_hema yymmdd10. ;
	informat hema_ongoing best32. ;
	informat malig_num $500. ;
	informat malig_spec $500. ;
	informat dt_malig yymmdd10. ;
	informat dt_recent_malig yymmdd10. ;
	informat malig_ongoing best32. ;
	informat endocrine_num $500. ;
	informat endocrine_spec $500. ;
	informat dt_endocrine yymmdd10. ;
	informat dt_recent_endocrine yymmdd10. ;
	informat endocrine_ongoing best32. ;
	informat renal_num $500. ;
	informat renal_spec $500. ;
	informat dt_renal yymmdd10. ;
	informat dt_recent_renal yymmdd10. ;
	informat renal_ongoing best32. ;
	informat hepato_num $500. ;
	informat hepato_spec $500. ;
	informat dt_hepato yymmdd10. ;
	informat dt_recent_hepato yymmdd10. ;
	informat hepato_ongoing best32. ;
	informat gastro_num $500. ;
	informat gastro_spec $500. ;
	informat dt_gastro yymmdd10. ;
	informat dt_recent_gastro yymmdd10. ;
	informat gastro_ongoing best32. ;
	informat derm_num $500. ;
	informat derm_spec $500. ;
	informat dt_derm yymmdd10. ;
	informat dt_recent_derm yymmdd10. ;
	informat derm_ongoing best32. ;
	informat id_num $500. ;
	informat id_spec $500. ;
	informat dt_id yymmdd10. ;
	informat dt_recent_id yymmdd10. ;
	informat id_ongoing best32. ;
	informat rheum_num $500. ;
	informat rheum_spec $500. ;
	informat dt_rheum yymmdd10. ;
	informat dt_recent_rheum yymmdd10. ;
	informat rheum_ongoing best32. ;
	informat obgyn_list $500. ;
	informat obgyn_num $500. ;
	informat dt_obgyn yymmdd10. ;
	informat dt_recent_obgyn yymmdd10. ;
	informat obgyn_ongoing best32. ;
	informat other_non_aids1 $500. ;
	informat other_non_aids_num1 $500. ;
	informat dt_initial_non_aids1 yymmdd10. ;
	informat dt_recent_non_aids1 yymmdd10. ;
	informat other_non_aids1_ongoing best32. ;
	informat other_non_aids2 $500. ;
	informat other_non_aids_num2 $500. ;
	informat dt_initial_non_aids2 yymmdd10. ;
	informat dt_recent_non_aids2 yymmdd10. ;
	informat other_non_aids2_ongoing best32. ;
	informat other_non_aids3 $500. ;
	informat other_non_aids_num3 $500. ;
	informat dt_initial_non_aids3 yymmdd10. ;
	informat dt_recent_non_aids3 yymmdd10. ;
	informat other_non_aids3_ongoing best32. ;
	informat other_non_aids4 $500. ;
	informat other_non_aids_num4 $500. ;
	informat dt_initial_non_aids4 yymmdd10. ;
	informat dt_recent_non_aids4 yymmdd10. ;
	informat other_non_aids4_ongoing best32. ;
	informat other_non_aids5 $500. ;
	informat other_non_aids_num5 $500. ;
	informat dt_initial_non_aids5 yymmdd10. ;
	informat dt_recent_non_aids5 yymmdd10. ;
	informat other_non_aids5_ongoing best32. ;
	informat nonaids_conditions_complete best32. ;

	format patient_id $500. ;
	format non_aids_condition___1 best12. ;
	format non_aids_condition___2 best12. ;
	format non_aids_condition___3 best12. ;
	format non_aids_condition___4 best12. ;
	format non_aids_condition___5 best12. ;
	format non_aids_condition___6 best12. ;
	format non_aids_condition___7 best12. ;
	format non_aids_condition___8 best12. ;
	format non_aids_condition___9 best12. ;
	format non_aids_condition___98 best12. ;
	format non_aids_condition___10 best12. ;
	format non_aids_condition___11 best12. ;
	format non_aids_condition___12 best12. ;
	format non_aids_condition___13 best12. ;
	format non_aids_condition___14 best12. ;
	format non_aids_condition___15 best12. ;
	format non_aids_condition___16 best12. ;
	format non_aids_condition___17 best12. ;
	format non_aids_condition___18 best12. ;
	format non_aids_condition___19 best12. ;
	format non_aids_condition___20 best12. ;
	format non_aids_condition___21 best12. ;
	format non_aids_condition___22 best12. ;
	format non_aids_condition___99 best12. ;
	format rash_num $500. ;
	format rash_spec $500. ;
	format dt_rash yymmdd10. ;
	format dt_recent_rash yymmdd10. ;
	format rash_ongoing best12. ;
	format anemia_num $500. ;
	format anemia_spec $500. ;
	format dt_anemia yymmdd10. ;
	format dt_recent_anemia yymmdd10. ;
	format anemia_ongoing best12. ;
	format pancreatitis_num $500. ;
	format pancreatitis_spec $500. ;
	format dt_pancreatitis yymmdd10. ;
	format dt_recent_pancreatitis yymmdd10. ;
	format pancreatitis_ongoing best12. ;
	format hepatitis_num $500. ;
	format hepatitis_cond_spec $500. ;
	format dt_hepatitis yymmdd10. ;
	format dt_recent_hepatitis yymmdd10. ;
	format hepatitis_ongoing best12. ;
	format lipo_num $500. ;
	format lipo_spec $500. ;
	format dt_lipo yymmdd10. ;
	format dt_recent_lipo yymmdd10. ;
	format lipo_ongoing best12. ;
	format neuropathy_num $500. ;
	format neuropathy_spec $500. ;
	format dt_neuropathy yymmdd10. ;
	format dt_recent_neuropathy yymmdd10. ;
	format neuropathy_ongoing best12. ;
	format diarrhea_num $500. ;
	format diarrhea_spec $500. ;
	format dt_diarrhea yymmdd10. ;
	format dt_recent_diarrhea yymmdd10. ;
	format diarrhea_ongoing best12. ;
	format acidosis_num $500. ;
	format acidosis_spec $500. ;
	format dt_acidosis yymmdd10. ;
	format dt_recent_acidosis yymmdd10. ;
	format acidosis_ongoing best12. ;
	format lipidemia_num $500. ;
	format lipidemia_spec $500. ;
	format dt_lipidemia yymmdd10. ;
	format dt_recent_lipidemia yymmdd10. ;
	format lipidemia_ongoing best12. ;
	format ae_other_num $500. ;
	format ae_other_spec $500. ;
	format dt_ae_other yymmdd10. ;
	format dt_recent_ae_other yymmdd10. ;
	format ae_other_ongoing best12. ;
	format neuro_num $500. ;
	format neuro_spec $500. ;
	format dt_neuro yymmdd10. ;
	format dt_recent_neuro yymmdd10. ;
	format neuro_ongoing best12. ;
	format cardio_num $500. ;
	format cardio_spec $500. ;
	format dt_cardio yymmdd10. ;
	format dt_recent_cardio yymmdd10. ;
	format cardio_ongoing best12. ;
	format pulmonary_num $500. ;
	format pulmonary_spec $500. ;
	format dt_pulmonary yymmdd10. ;
	format dt_recent_pulmonary yymmdd10. ;
	format pulmonary_ongoing best12. ;
	format hema_num $500. ;
	format hema_spec $500. ;
	format dt_hema yymmdd10. ;
	format dt_recent_hema yymmdd10. ;
	format hema_ongoing best12. ;
	format malig_num $500. ;
	format malig_spec $500. ;
	format dt_malig yymmdd10. ;
	format dt_recent_malig yymmdd10. ;
	format malig_ongoing best12. ;
	format endocrine_num $500. ;
	format endocrine_spec $500. ;
	format dt_endocrine yymmdd10. ;
	format dt_recent_endocrine yymmdd10. ;
	format endocrine_ongoing best12. ;
	format renal_num $500. ;
	format renal_spec $500. ;
	format dt_renal yymmdd10. ;
	format dt_recent_renal yymmdd10. ;
	format renal_ongoing best12. ;
	format hepato_num $500. ;
	format hepato_spec $500. ;
	format dt_hepato yymmdd10. ;
	format dt_recent_hepato yymmdd10. ;
	format hepato_ongoing best12. ;
	format gastro_num $500. ;
	format gastro_spec $500. ;
	format dt_gastro yymmdd10. ;
	format dt_recent_gastro yymmdd10. ;
	format gastro_ongoing best12. ;
	format derm_num $500. ;
	format derm_spec $500. ;
	format dt_derm yymmdd10. ;
	format dt_recent_derm yymmdd10. ;
	format derm_ongoing best12. ;
	format id_num $500. ;
	format id_spec $500. ;
	format dt_id yymmdd10. ;
	format dt_recent_id yymmdd10. ;
	format id_ongoing best12. ;
	format rheum_num $500. ;
	format rheum_spec $500. ;
	format dt_rheum yymmdd10. ;
	format dt_recent_rheum yymmdd10. ;
	format rheum_ongoing best12. ;
	format obgyn_list $500. ;
	format obgyn_num $500. ;
	format dt_obgyn yymmdd10. ;
	format dt_recent_obgyn yymmdd10. ;
	format obgyn_ongoing best12. ;
	format other_non_aids1 $500. ;
	format other_non_aids_num1 $500. ;
	format dt_initial_non_aids1 yymmdd10. ;
	format dt_recent_non_aids1 yymmdd10. ;
	format other_non_aids1_ongoing best12. ;
	format other_non_aids2 $500. ;
	format other_non_aids_num2 $500. ;
	format dt_initial_non_aids2 yymmdd10. ;
	format dt_recent_non_aids2 yymmdd10. ;
	format other_non_aids2_ongoing best12. ;
	format other_non_aids3 $500. ;
	format other_non_aids_num3 $500. ;
	format dt_initial_non_aids3 yymmdd10. ;
	format dt_recent_non_aids3 yymmdd10. ;
	format other_non_aids3_ongoing best12. ;
	format other_non_aids4 $500. ;
	format other_non_aids_num4 $500. ;
	format dt_initial_non_aids4 yymmdd10. ;
	format dt_recent_non_aids4 yymmdd10. ;
	format other_non_aids4_ongoing best12. ;
	format other_non_aids5 $500. ;
	format other_non_aids_num5 $500. ;
	format dt_initial_non_aids5 yymmdd10. ;
	format dt_recent_non_aids5 yymmdd10. ;
	format other_non_aids5_ongoing best12. ;
	format nonaids_conditions_complete best12. ;

input
		patient_id $
		non_aids_condition___1
		non_aids_condition___2
		non_aids_condition___3
		non_aids_condition___4
		non_aids_condition___5
		non_aids_condition___6
		non_aids_condition___7
		non_aids_condition___8
		non_aids_condition___9
		non_aids_condition___98
		non_aids_condition___10
		non_aids_condition___11
		non_aids_condition___12
		non_aids_condition___13
		non_aids_condition___14
		non_aids_condition___15
		non_aids_condition___16
		non_aids_condition___17
		non_aids_condition___18
		non_aids_condition___19
		non_aids_condition___20
		non_aids_condition___21
		non_aids_condition___22
		non_aids_condition___99
		rash_num $
		rash_spec $
		dt_rash
		dt_recent_rash
		rash_ongoing
		anemia_num $
		anemia_spec $
		dt_anemia
		dt_recent_anemia
		anemia_ongoing
		pancreatitis_num $
		pancreatitis_spec $
		dt_pancreatitis
		dt_recent_pancreatitis
		pancreatitis_ongoing
		hepatitis_num $
		hepatitis_cond_spec $
		dt_hepatitis
		dt_recent_hepatitis
		hepatitis_ongoing
		lipo_num $
		lipo_spec $
		dt_lipo
		dt_recent_lipo
		lipo_ongoing
		neuropathy_num $
		neuropathy_spec $
		dt_neuropathy
		dt_recent_neuropathy
		neuropathy_ongoing
		diarrhea_num $
		diarrhea_spec $
		dt_diarrhea
		dt_recent_diarrhea
		diarrhea_ongoing
		acidosis_num $
		acidosis_spec $
		dt_acidosis
		dt_recent_acidosis
		acidosis_ongoing
		lipidemia_num $
		lipidemia_spec $
		dt_lipidemia
		dt_recent_lipidemia
		lipidemia_ongoing
		ae_other_num $
		ae_other_spec $
		dt_ae_other
		dt_recent_ae_other
		ae_other_ongoing
		neuro_num $
		neuro_spec $
		dt_neuro
		dt_recent_neuro
		neuro_ongoing
		cardio_num $
		cardio_spec $
		dt_cardio
		dt_recent_cardio
		cardio_ongoing
		pulmonary_num $
		pulmonary_spec $
		dt_pulmonary
		dt_recent_pulmonary
		pulmonary_ongoing
		hema_num $
		hema_spec $
		dt_hema
		dt_recent_hema
		hema_ongoing
		malig_num $
		malig_spec $
		dt_malig
		dt_recent_malig
		malig_ongoing
		endocrine_num $
		endocrine_spec $
		dt_endocrine
		dt_recent_endocrine
		endocrine_ongoing
		renal_num $
		renal_spec $
		dt_renal
		dt_recent_renal
		renal_ongoing
		hepato_num $
		hepato_spec $
		dt_hepato
		dt_recent_hepato
		hepato_ongoing
		gastro_num $
		gastro_spec $
		dt_gastro
		dt_recent_gastro
		gastro_ongoing
		derm_num $
		derm_spec $
		dt_derm
		dt_recent_derm
		derm_ongoing
		id_num $
		id_spec $
		dt_id
		dt_recent_id
		id_ongoing
		rheum_num $
		rheum_spec $
		dt_rheum
		dt_recent_rheum
		rheum_ongoing
		obgyn_list $
		obgyn_num $
		dt_obgyn
		dt_recent_obgyn
		obgyn_ongoing
		other_non_aids1 $
		other_non_aids_num1 $
		dt_initial_non_aids1
		dt_recent_non_aids1
		other_non_aids1_ongoing
		other_non_aids2 $
		other_non_aids_num2 $
		dt_initial_non_aids2
		dt_recent_non_aids2
		other_non_aids2_ongoing
		other_non_aids3 $
		other_non_aids_num3 $
		dt_initial_non_aids3
		dt_recent_non_aids3
		other_non_aids3_ongoing
		other_non_aids4 $
		other_non_aids_num4 $
		dt_initial_non_aids4
		dt_recent_non_aids4
		other_non_aids4_ongoing
		other_non_aids5 $
		other_non_aids_num5 $
		dt_initial_non_aids5
		dt_recent_non_aids5
		other_non_aids5_ongoing
		nonaids_conditions_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label non_aids_condition___1='Serious non-AIDS condition (choice=Rash)';
	label non_aids_condition___2='Serious non-AIDS condition (choice=Anemia)';
	label non_aids_condition___3='Serious non-AIDS condition (choice=Pancreatitis)';
	label non_aids_condition___4='Serious non-AIDS condition (choice=Hepatitis)';
	label non_aids_condition___5='Serious non-AIDS condition (choice=Lipodystrophy)';
	label non_aids_condition___6='Serious non-AIDS condition (choice=Peripheral Neuropathy)';
	label non_aids_condition___7='Serious non-AIDS condition (choice=Diarrhea)';
	label non_aids_condition___8='Serious non-AIDS condition (choice=Lactic Acidosis)';
	label non_aids_condition___9='Serious non-AIDS condition (choice=Hyperlipidemia)';
	label non_aids_condition___98='Serious non-AIDS condition (choice=Other Adverse Event)';
	label non_aids_condition___10='Serious non-AIDS condition (choice=Neuropsychological)';
	label non_aids_condition___11='Serious non-AIDS condition (choice=Cardiovascular)';
	label non_aids_condition___12='Serious non-AIDS condition (choice=Pulmonary)';
	label non_aids_condition___13='Serious non-AIDS condition (choice=Hematological)';
	label non_aids_condition___14='Serious non-AIDS condition (choice=Malignancy)';
	label non_aids_condition___15='Serious non-AIDS condition (choice=Endocrine)';
	label non_aids_condition___16='Serious non-AIDS condition (choice=Renal)';
	label non_aids_condition___17='Serious non-AIDS condition (choice=Hepatobiliary)';
	label non_aids_condition___18='Serious non-AIDS condition (choice=Gastrointestinal)';
	label non_aids_condition___19='Serious non-AIDS condition (choice=Dermatological)';
	label non_aids_condition___20='Serious non-AIDS condition (choice=Infectious Disease)';
	label non_aids_condition___21='Serious non-AIDS condition (choice=Rheumatological)';
	label non_aids_condition___22='Serious non-AIDS condition (choice=OB/GYN)';
	label non_aids_condition___99='Serious non-AIDS condition (choice=Other)';
	label rash_num='Rash number of episodes';
	label rash_spec='Specify';
	label dt_rash='Initial Date';
	label dt_recent_rash='Most Recent Date';
	label rash_ongoing='Current ongoing diagnosis';
	label anemia_num='Anemia number of episodes';
	label anemia_spec='Specify';
	label dt_anemia='Initial Date';
	label dt_recent_anemia='Most Recent Date';
	label anemia_ongoing='Current ongoing diagnosis';
	label pancreatitis_num='Pancreatitis number of episodes';
	label pancreatitis_spec='Specify';
	label dt_pancreatitis='Initial Date';
	label dt_recent_pancreatitis='Most Recent Date';
	label pancreatitis_ongoing='Current ongoing diagnosis';
	label hepatitis_num='Hepatitis number of episodes';
	label hepatitis_cond_spec='Specify';
	label dt_hepatitis='Initial Date';
	label dt_recent_hepatitis='Most Recent Date';
	label hepatitis_ongoing='Current ongoing diagnosis';
	label lipo_num='Lipodystrophy number of episodes';
	label lipo_spec='Specify';
	label dt_lipo='Initial Date';
	label dt_recent_lipo='Most Recent Date';
	label lipo_ongoing='Current ongoing diagnosis';
	label neuropathy_num='Peripheral Neuropathy number of episodes';
	label neuropathy_spec='Specify';
	label dt_neuropathy='Initial Date';
	label dt_recent_neuropathy='Most Recent Date';
	label neuropathy_ongoing='Current ongoing diagnosis';
	label diarrhea_num='Diarrhea number of episodes';
	label diarrhea_spec='Specify';
	label dt_diarrhea='Initial Date';
	label dt_recent_diarrhea='Most Recent Date';
	label diarrhea_ongoing='Current ongoing diagnosis';
	label acidosis_num='Lactic Acidosis number of episodes';
	label acidosis_spec='Specify';
	label dt_acidosis='Initial Date';
	label dt_recent_acidosis='Most Recent Date';
	label acidosis_ongoing='Current ongoing diagnosis';
	label lipidemia_num='Hyperlipidemia number of episodes';
	label lipidemia_spec='Specify';
	label dt_lipidemia='Initial Date';
	label dt_recent_lipidemia='Most Recent Date';
	label lipidemia_ongoing='Current ongoing diagnosis';
	label ae_other_num='Other Adverse Event number of episodes';
	label ae_other_spec='Specify';
	label dt_ae_other='Initial Date';
	label dt_recent_ae_other='Most Recent Date';
	label ae_other_ongoing='Current ongoing diagnosis';
	label neuro_num='Neuropsychological number of episodes';
	label neuro_spec='Specify';
	label dt_neuro='Initial Date';
	label dt_recent_neuro='Most Recent Date';
	label neuro_ongoing='Current ongoing diagnosis';
	label cardio_num='Cardiovascular number of episodes';
	label cardio_spec='Specify';
	label dt_cardio='Initial Date';
	label dt_recent_cardio='Most Recent Date';
	label cardio_ongoing='Current ongoing diagnosis';
	label pulmonary_num='Pulmonary number of episodes';
	label pulmonary_spec='Specify';
	label dt_pulmonary='Initial Date';
	label dt_recent_pulmonary='Most Recent Date';
	label pulmonary_ongoing='Current ongoing diagnosis';
	label hema_num='Hematological number of episodes';
	label hema_spec='Specify';
	label dt_hema='Initial Date';
	label dt_recent_hema='Most Recent Date';
	label hema_ongoing='Current ongoing diagnosis';
	label malig_num='Malignancy number of episodes';
	label malig_spec='Specify';
	label dt_malig='Initial Date';
	label dt_recent_malig='Most Recent Date';
	label malig_ongoing='Current ongoing diagnosis';
	label endocrine_num='Endocrine number of episodes';
	label endocrine_spec='Specify';
	label dt_endocrine='Initial Date';
	label dt_recent_endocrine='Most Recent Date';
	label endocrine_ongoing='Current ongoing diagnosis';
	label renal_num='Renal number of episodes';
	label renal_spec='Specify';
	label dt_renal='Initial Date';
	label dt_recent_renal='Most Recent Date';
	label renal_ongoing='Current ongoing diagnosis';
	label hepato_num='Hepatobiliary number of episodes';
	label hepato_spec='Specify';
	label dt_hepato='Initial Date';
	label dt_recent_hepato='Most Recent Date';
	label hepato_ongoing='Current ongoing diagnosis';
	label gastro_num='Gastrointestinal number of episodes';
	label gastro_spec='Specify';
	label dt_gastro='Initial Date';
	label dt_recent_gastro='Most Recent Date';
	label gastro_ongoing='Current ongoing diagnosis';
	label derm_num='Dermatological number of episodes';
	label derm_spec='Specify';
	label dt_derm='Initial Date';
	label dt_recent_derm='Most Recent Date';
	label derm_ongoing='Current ongoing diagnosis';
	label id_num='Infectious Disease number of episodes';
	label id_spec='Specify';
	label dt_id='Initial Date';
	label dt_recent_id='Most Recent Date';
	label id_ongoing='Current ongoing diagnosis';
	label rheum_num='Rheumatological number of episodes';
	label rheum_spec='Specify';
	label dt_rheum='Initial Date';
	label dt_recent_rheum='Most Recent Date';
	label rheum_ongoing='Current ongoing diagnosis';
	label obgyn_list='OB/GYN List';
	label obgyn_num='OB/GYN number of episodes';
	label dt_obgyn='Initial Date';
	label dt_recent_obgyn='Most Recent Date';
	label obgyn_ongoing='Current ongoing diagnosis';
	label other_non_aids1='1. Other Non-AIDS Condition';
	label other_non_aids_num1='Other number of episodes';
	label dt_initial_non_aids1='Initial Date';
	label dt_recent_non_aids1='Most Recent Date';
	label other_non_aids1_ongoing='Current ongoing diagnosis';
	label other_non_aids2='2. Other Non-AIDS Condition';
	label other_non_aids_num2='Other number of episodes';
	label dt_initial_non_aids2='Initial Date';
	label dt_recent_non_aids2='Most Recent Date';
	label other_non_aids2_ongoing='Current ongoing diagnosis';
	label other_non_aids3='3. Other Non-AIDS Condition';
	label other_non_aids_num3='Other number of episodes';
	label dt_initial_non_aids3='Initial Date';
	label dt_recent_non_aids3='Most Recent Date';
	label other_non_aids3_ongoing='Current ongoing diagnosis';
	label other_non_aids4='4. Other Non-AIDS Condition';
	label other_non_aids_num4='Other number of episodes';
	label dt_initial_non_aids4='Initial Date';
	label dt_recent_non_aids4='Most Recent Date';
	label other_non_aids4_ongoing='Current ongoing diagnosis';
	label other_non_aids5='5. Other Non-AIDS Condition';
	label other_non_aids_num5='Other number of episodes';
	label dt_initial_non_aids5='Initial Date';
	label dt_recent_non_aids5='Most Recent Date';
	label other_non_aids5_ongoing='Current ongoing diagnosis';
	label nonaids_conditions_complete='Complete?';
	run;

proc format;
	value non_aids_condition___1_ 0='Unchecked' 1='Checked';
	value non_aids_condition___2_ 0='Unchecked' 1='Checked';
	value non_aids_condition___3_ 0='Unchecked' 1='Checked';
	value non_aids_condition___4_ 0='Unchecked' 1='Checked';
	value non_aids_condition___5_ 0='Unchecked' 1='Checked';
	value non_aids_condition___6_ 0='Unchecked' 1='Checked';
	value non_aids_condition___7_ 0='Unchecked' 1='Checked';
	value non_aids_condition___8_ 0='Unchecked' 1='Checked';
	value non_aids_condition___9_ 0='Unchecked' 1='Checked';
	value non_aids_condition___98_ 0='Unchecked' 1='Checked';
	value non_aids_condition___10_ 0='Unchecked' 1='Checked';
	value non_aids_condition___11_ 0='Unchecked' 1='Checked';
	value non_aids_condition___12_ 0='Unchecked' 1='Checked';
	value non_aids_condition___13_ 0='Unchecked' 1='Checked';
	value non_aids_condition___14_ 0='Unchecked' 1='Checked';
	value non_aids_condition___15_ 0='Unchecked' 1='Checked';
	value non_aids_condition___16_ 0='Unchecked' 1='Checked';
	value non_aids_condition___17_ 0='Unchecked' 1='Checked';
	value non_aids_condition___18_ 0='Unchecked' 1='Checked';
	value non_aids_condition___19_ 0='Unchecked' 1='Checked';
	value non_aids_condition___20_ 0='Unchecked' 1='Checked';
	value non_aids_condition___21_ 0='Unchecked' 1='Checked';
	value non_aids_condition___22_ 0='Unchecked' 1='Checked';
	value non_aids_condition___99_ 0='Unchecked' 1='Checked';
	value rash_ongoing_ 1='Yes' 2='No';
	value anemia_ongoing_ 1='Yes' 2='No';
	value pancreatitis_ongoing_ 1='Yes' 2='No';
	value hepatitis_ongoing_ 1='Yes' 2='No';
	value lipo_ongoing_ 1='Yes' 2='No';
	value neuropathy_ongoing_ 1='Yes' 2='No';
	value diarrhea_ongoing_ 1='Yes' 2='No';
	value acidosis_ongoing_ 1='Yes' 2='No';
	value lipidemia_ongoing_ 1='Yes' 2='No';
	value ae_other_ongoing_ 1='Yes' 2='No';
	value neuro_ongoing_ 1='Yes' 2='No';
	value cardio_ongoing_ 1='Yes' 2='No';
	value pulmonary_ongoing_ 1='Yes' 2='No';
	value hema_ongoing_ 1='Yes' 2='No';
	value malig_ongoing_ 1='Yes' 2='No';
	value endocrine_ongoing_ 1='Yes' 2='No';
	value renal_ongoing_ 1='Yes' 2='No';
	value hepato_ongoing_ 1='Yes' 2='No';
	value gastro_ongoing_ 1='Yes' 2='No';
	value derm_ongoing_ 1='Yes' 2='No';
	value id_ongoing_ 1='Yes' 2='No';
	value rheum_ongoing_ 1='Yes' 2='No';
	value obgyn_ongoing_ 1='Yes' 2='No';
	value other_non_aids1_ongoing_ 1='Yes' 2='No';
	value other_non_aids2_ongoing_ 1='Yes' 2='No';
	value other_non_aids3_ongoing_ 1='Yes' 2='No';
	value other_non_aids4_ongoing_ 1='Yes' 2='No';
	value other_non_aids5_ongoing_ 1='Yes' 2='No';
	value nonaids_conditions_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format non_aids_condition___1 non_aids_condition___1_.;
	format non_aids_condition___2 non_aids_condition___2_.;
	format non_aids_condition___3 non_aids_condition___3_.;
	format non_aids_condition___4 non_aids_condition___4_.;
	format non_aids_condition___5 non_aids_condition___5_.;
	format non_aids_condition___6 non_aids_condition___6_.;
	format non_aids_condition___7 non_aids_condition___7_.;
	format non_aids_condition___8 non_aids_condition___8_.;
	format non_aids_condition___9 non_aids_condition___9_.;
	format non_aids_condition___98 non_aids_condition___98_.;
	format non_aids_condition___10 non_aids_condition___10_.;
	format non_aids_condition___11 non_aids_condition___11_.;
	format non_aids_condition___12 non_aids_condition___12_.;
	format non_aids_condition___13 non_aids_condition___13_.;
	format non_aids_condition___14 non_aids_condition___14_.;
	format non_aids_condition___15 non_aids_condition___15_.;
	format non_aids_condition___16 non_aids_condition___16_.;
	format non_aids_condition___17 non_aids_condition___17_.;
	format non_aids_condition___18 non_aids_condition___18_.;
	format non_aids_condition___19 non_aids_condition___19_.;
	format non_aids_condition___20 non_aids_condition___20_.;
	format non_aids_condition___21 non_aids_condition___21_.;
	format non_aids_condition___22 non_aids_condition___22_.;
	format non_aids_condition___99 non_aids_condition___99_.;
	format rash_ongoing rash_ongoing_.;
	format anemia_ongoing anemia_ongoing_.;
	format pancreatitis_ongoing pancreatitis_ongoing_.;
	format hepatitis_ongoing hepatitis_ongoing_.;
	format lipo_ongoing lipo_ongoing_.;
	format neuropathy_ongoing neuropathy_ongoing_.;
	format diarrhea_ongoing diarrhea_ongoing_.;
	format acidosis_ongoing acidosis_ongoing_.;
	format lipidemia_ongoing lipidemia_ongoing_.;
	format ae_other_ongoing ae_other_ongoing_.;
	format neuro_ongoing neuro_ongoing_.;
	format cardio_ongoing cardio_ongoing_.;
	format pulmonary_ongoing pulmonary_ongoing_.;
	format hema_ongoing hema_ongoing_.;
	format malig_ongoing malig_ongoing_.;
	format endocrine_ongoing endocrine_ongoing_.;
	format renal_ongoing renal_ongoing_.;
	format hepato_ongoing hepato_ongoing_.;
	format gastro_ongoing gastro_ongoing_.;
	format derm_ongoing derm_ongoing_.;
	format id_ongoing id_ongoing_.;
	format rheum_ongoing rheum_ongoing_.;
	format obgyn_ongoing obgyn_ongoing_.;
	format other_non_aids1_ongoing other_non_aids1_ongoing_.;
	format other_non_aids2_ongoing other_non_aids2_ongoing_.;
	format other_non_aids3_ongoing other_non_aids3_ongoing_.;
	format other_non_aids4_ongoing other_non_aids4_ongoing_.;
	format other_non_aids5_ongoing other_non_aids5_ongoing_.;
	format nonaids_conditions_complete nonaids_conditions_complete_.;
	run;

proc contents data=redcap;
data brent.nonaids;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;


proc contents data=brent.nonaids short varnum; run;

