/*	annual_toc.sas
 *
 *	stores table of contents data for the TT-CMV monthly report
 */


* lbwi_demo.sas andrea;
%let lbwi_demo_mon_file = 012_;
%let lbwi_demo_mon_pre = Table 10:;

* moc_demo.sas  andrea;
%let moc_demo_mon_file = 013_;
%let moc_demo_mon_pre = Table 11:;


/* SNAP_plots.sas neeta */
%let snap_plots_whole_file = 014_;
	%let snap_plots_whole_title = Figure 3:;


/* lbwi_growth_plots.sas panel neeta*/
%let growth_plots_panel_file = 015_;
	%let growth_plots_panel_title = Figure 4:;


/* lbwi_growth_plots.sas  neeta */
%let growth_plots_whole_file = 016_;
	%let growth_plots_whole_title = Figure 5:;

* all_tx_summary.sas neeta;
%let all_tx_summary_file = 017_;
	%let all_tx_summary_title = Table 12:;

* table - RBC Tx Summary  neeta;

* all_tx_summary.sas;
	%let rbc_tx_summary_file = 018_;
	%let rbc_tx_summary_title = Table 13:;

* rbc_tx_summary.sas;
	%let rbc_tx_summary_file2 = 019_;
	%let rbc_tx_summary_title2 = Table 14:;

* table - TX combo summary for those who completed tx_combo_eos.sas;

	%let combo_tx_summary_file = 020_;
	%let combo_tx_summary_title = Table 15;

	
	%let combo_donor_summary_file = 021_;
	%let combo_donor_summary_title = Table 16;

* infection.sas  neeta;
	%let infection_summary_file1 = 022_;
	%let infection_summary_title1 = Table 17:;

* infection.sas  neeta;
	%let infection_summary_file2 = 023_;
	%let infection_summary_title2 = Table 18:;

* outcome_freq.sas  andrea;
	%let outcome_freq_mon_file = 024_;
	%let outcome_fre_mon_pre = Table 19:;

* nat_results_summary.sas  neeta;
	%let nat_result_summary_file = 025_;
	%let nat_result_summary_title = Table 20;

/* snap2_mixed_plot.sas  neeta*/
%let snap2_plots_whole_file = 026_;
	%let snap2_plots_whole_title = Figure 6:;

/* snap2_summary.sas  neeta*/
%let snap2_summary_file = 026_;
	%let snap2_summary_title = Table 21;


/* bpd_summary.sas  neeta*/
%let bpd_summary_file = 027_;
	%let bpd_summary_title = Table 22;

/* ivh_summary.sas  neeta*/
%let ivh_summary_file = 028_;
	%let ivh_summary_title = Table 23;

