/*	monthly_toc.sas
 *
 *	stores table of contents data for the TT-CMV monthly report
 */


	* table - Cumulative patient screening and enrollment ;
	%let mon_file_screen_enroll = 001_;
	%let mon_pre_screen_enroll = Table 1:;

	* table - Patients recruited by month ;
	%let mon_file_recruitment_table = 002_;
	%let mon_pre_recruitment_table = Table 2:;

	* figure - Recruitment curve (overall) ;
	%let mon_file_recruit_curve = 003_;
	%let mon_pre_recruit_curve = Figure 1:;

	* figure - Recruitment curve (by site) ;
	%let mon_file_recruit_curve_site = 004_;
	%let mon_pre_recruit_curve_site = Figure 2:;

	* table - Patient screening and enrollment by month ;
	%let mon_file_screen_enroll_by_month = 005_;
	%let mon_pre_screen_enroll_by_month = Table 3:;

	* table - Reasons patients inelgibile at screening ;
	%let mon_file_reasons_not_eligible = 006_;
	%let mon_pre_reasons_not_eligible = Table 4:;

	* table - Reasons patients eligible at screening were not enrolled ;
	%let mon_file_reasons_no_consent = 007_;
	%let mon_pre_reasons_no_consent = Table 5:;

	* table - MOC serostatus  SAS file : moc_sero_status2.sas;
	%let moc_sero_status_file = 008_;
	%let moc_sero_status_title = Table 6:;



* table - Patient study status by center  SAS file : patient_study_status.sas;
	%let patient_study_status_file = 009_;
	%let patient_study_status_title = Table 7:;

* table - Patient study status by center  SAS file : patient_study_status.sas;
	%let patient_bm_tr_etc_file = 010_;
	%let patient_bm_tr_etc_title = Table 8:;


* table - patient matrix listing SAS file : patient_matrix.sas;
	%let exp_obs_count_mon_file = 011_;
	%let exp_obs_count_mon_title = Table 9;

* table - Race Ethnicity Status race_etnnic.sas;
	%let race_ethnic_file = 012_;
	%let race_ethnic_title = Table 10:;


* table - rbc TX summary for those who completed rbc_tx_eos.sas;
	

	%let rbc_tx_summary_file2 = 013_;
	%let rbc_tx_summary_title2 = Table 11:;


* table - Plt TX summary for those who completed plt_tx_eos.sas;
	

	%let plt_tx_summary_file2 = 014_;
	%let plt_tx_summary_title2 = Table 12:;


* table - FFP TX summary for those who completed ffp_tx_eos.sas;
	

	%let ffp_tx_summary_file2 = 015_;
	%let ffp_tx_summary_title2 = Table 13:;

* table - TX combo summary for those who completed tx_combo_eos.sas.it is in annual;

* table - TX combo summary for those who completed tx_combo_eos.sas. it is in annual;
	

* table - Transfusion record listing;
	%let mon_file_unit_status = 018_;
	%let mon_pre_unit_status = Table 16:;


* table - target_window.sas;
	%let window_file = 019_;
	%let window_title = Table 17:;


/************************************************************************/
/*

* table - patient matrix listing SAS file : qc_report.sas;
	%let qc_report_file = 010_;
	%let qc_report_title = Table 8:;

* table - LBWI CMV STATUS  SAS file lbwi_cmv_status2.sas ;
	%let lbwi_cmv_status_file = 010_;
	%let lbwi_cmv_status_title = Table 10:;

* table - Blood Unit Status ;
	%let bu_status_file = 011_;
	%let bu_status_title = Table 11:;

* table - patient matrix listing SAS file : patient_matrix.sas;
	%let form_submission_detail_file = 011_;
	%let form_submission_detail_title = Table 11:;

* table - Race Ethnicity Status race_etnnic.sas;
	%let race_ethnic_file = 012_;
	%let race_ethnic_title = Table 12:;

* table - outcomes race_etnnic.sas;
	%let outcome_tx_status_file = 013_;
	%let outcome_tx_status_title = Table 13:;

*/
/************************************************************************/
