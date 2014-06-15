%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\rest2.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat dt_results_rec_2 yymmdd10. ;
	informat genotype_comments_2 $5000. ;
	informat resist_3tc_2 best32. ;
	informat resist_abc_2 best32. ;
	informat resist_azt_2 best32. ;
	informat resist_d4t_2 best32. ;
	informat resist_ddi_2 best32. ;
	informat resist_dlv_2 best32. ;
	informat resist_efv_2 best32. ;
	informat resist_etr_2 best32. ;
	informat resist_ftc_2 best32. ;
	informat resist_npv_2 best32. ;
	informat resist_rpv_2 best32. ;
	informat resist_tdf_2 best32. ;
	informat mut_nrti_2 best32. ;
	informat mut_nnrti_2 best32. ;
	informat mut_m41_2___0 best32. ;
	informat mut_m41_2___1 best32. ;
	informat mut_m41_2___9 best32. ;
	informat mut_m41_other_2 $500. ;
	informat mut_44_2___0 best32. ;
	informat mut_44_2___1 best32. ;
	informat mut_44_2___2 best32. ;
	informat mut_44_2___9 best32. ;
	informat mut_44_other_2 $500. ;
	informat mut_a62_2___0 best32. ;
	informat mut_a62_2___1 best32. ;
	informat mut_a62_2___9 best32. ;
	informat mut_a62_other_2 $500. ;
	informat mut_k65_2___0 best32. ;
	informat mut_k65_2___1 best32. ;
	informat mut_k65_2___2 best32. ;
	informat mut_k65_2___9 best32. ;
	informat mut_k65_other_2 $500. ;
	informat mut_d67_2___0 best32. ;
	informat mut_d67_2___1 best32. ;
	informat mut_d67_2___2 best32. ;
	informat mut_d67_2___3 best32. ;
	informat mut_d67_2___4 best32. ;
	informat mut_d67_2___9 best32. ;
	informat mut_d67_other_2 $500. ;
	informat mut_t69_2___0 best32. ;
	informat mut_t69_2___1 best32. ;
	informat mut_t69_2___2 best32. ;
	informat mut_t69_2___3 best32. ;
	informat mut_t69_2___4 best32. ;
	informat mut_t69_2___5 best32. ;
	informat mut_t69_2___6 best32. ;
	informat mut_t69_2___7 best32. ;
	informat mut_t69_2___9 best32. ;
	informat mut_t69_other_2 $500. ;
	informat mut_k70_2___0 best32. ;
	informat mut_k70_2___1 best32. ;
	informat mut_k70_2___2 best32. ;
	informat mut_k70_2___3 best32. ;
	informat mut_k70_2___4 best32. ;
	informat mut_k70_2___9 best32. ;
	informat mut_k70_other_2 $500. ;
	informat mut_l74_2___0 best32. ;
	informat mut_l74_2___1 best32. ;
	informat mut_l74_2___2 best32. ;
	informat mut_l74_2___9 best32. ;
	informat mut_l74_other_2 $500. ;
	informat mut_v75_2___0 best32. ;
	informat mut_v75_2___1 best32. ;
	informat mut_v75_2___2 best32. ;
	informat mut_v75_2___3 best32. ;
	informat mut_v75_2___4 best32. ;
	informat mut_v75_2___5 best32. ;
	informat mut_v75_2___6 best32. ;
	informat mut_v75_2___9 best32. ;
	informat mut_v75_other_2 $500. ;
	informat mut_f77_2___0 best32. ;
	informat mut_f77_2___1 best32. ;
	informat mut_f77_2___9 best32. ;
	informat mut_f77_other_2 $500. ;
	informat mut_v90_2___0 best32. ;
	informat mut_v90_2___1 best32. ;
	informat mut_v90_2___9 best32. ;
	informat mut_v90_other_2 $500. ;
	informat mut_a98_2___0 best32. ;
	informat mut_a98_2___1 best32. ;
	informat mut_a98_2___2 best32. ;
	informat mut_a98_2___9 best32. ;
	informat mut_a98_other_2 $500. ;
	informat mut_l100_2___0 best32. ;
	informat mut_l100_2___1 best32. ;
	informat mut_l100_2___9 best32. ;
	informat mut_l100_other_2 $500. ;
	informat mut_k101_2___0 best32. ;
	informat mut_k101_2___1 best32. ;
	informat mut_k101_2___2 best32. ;
	informat mut_k101_2___3 best32. ;
	informat mut_k101_2___4 best32. ;
	informat mut_k101_2___5 best32. ;
	informat mut_k101_2___6 best32. ;
	informat mut_k101_2___9 best32. ;
	informat mut_k101_other_2 $500. ;
	informat mut_k103_2___0 best32. ;
	informat mut_k103_2___1 best32. ;
	informat mut_k103_2___2 best32. ;
	informat mut_k103_2___3 best32. ;
	informat mut_k103_2___4 best32. ;
	informat mut_k103_2___5 best32. ;
	informat mut_k103_2___6 best32. ;
	informat mut_k103_2___7 best32. ;
	informat mut_k103_2___9 best32. ;
	informat mut_k103_other_2 $500. ;
	informat mut_v106_2___0 best32. ;
	informat mut_v106_2___1 best32. ;
	informat mut_v106_2___2 best32. ;
	informat mut_v106_2___3 best32. ;
	informat mut_v106_2___4 best32. ;
	informat mut_v106_2___9 best32. ;
	informat mut_v106_other_2 $500. ;
	informat mut_v108_2___0 best32. ;
	informat mut_v108_2___1 best32. ;
	informat mut_v108_2___9 best32. ;
	informat mut_v108_other_2 $500. ;
	informat mut_g109_2___0 best32. ;
	informat mut_g109_2___1 best32. ;
	informat mut_g109_2___2 best32. ;
	informat mut_g109_2___9 best32. ;
	informat mut_g109_other_2 $500. ;
	informat mut_y115_2___0 best32. ;
	informat mut_y115_2___1 best32. ;
	informat mut_y115_2___2 best32. ;
	informat mut_y115_2___9 best32. ;
	informat mut_y115_other_2 $500. ;
	informat mut_f116_2___0 best32. ;
	informat mut_f116_2___1 best32. ;
	informat mut_f116_2___9 best32. ;
	informat mut_f116_other_2 $500. ;
	informat mut_118_2___0 best32. ;
	informat mut_118_2___1 best32. ;
	informat mut_118_2___9 best32. ;
	informat mut_118_other_2 $500. ;
	informat mut_e138_2___0 best32. ;
	informat mut_e138_2___1 best32. ;
	informat mut_e138_2___2 best32. ;
	informat mut_e138_2___3 best32. ;
	informat mut_e138_2___4 best32. ;
	informat mut_e138_2___9 best32. ;
	informat mut_e138_other_2 $500. ;
	informat mut_q151_2___0 best32. ;
	informat mut_q151_2___1 best32. ;
	informat mut_q151_2___2 best32. ;
	informat mut_q151_2___9 best32. ;
	informat mut_q151_other_2 $500. ;
	informat mut_v179_2___0 best32. ;
	informat mut_v179_2___1 best32. ;
	informat mut_v179_2___2 best32. ;
	informat mut_v179_2___3 best32. ;
	informat mut_v179_2___4 best32. ;
	informat mut_v179_2___5 best32. ;
	informat mut_v179_2___6 best32. ;
	informat mut_v179_2___9 best32. ;
	informat mut_v179_other_2 $500. ;
	informat mut_y181_2___0 best32. ;
	informat mut_y181_2___1 best32. ;
	informat mut_y181_2___2 best32. ;
	informat mut_y181_2___3 best32. ;
	informat mut_y181_2___4 best32. ;
	informat mut_y181_2___9 best32. ;
	informat mut_y181_other_2 $500. ;
	informat mut_m184_2___0 best32. ;
	informat mut_m184_2___1 best32. ;
	informat mut_m184_2___2 best32. ;
	informat mut_m184_2___3 best32. ;
	informat mut_m184_2___9 best32. ;
	informat mut_m184_other_2 $500. ;
	informat mut_y188_2___0 best32. ;
	informat mut_y188_2___1 best32. ;
	informat mut_y188_2___2 best32. ;
	informat mut_y188_2___3 best32. ;
	informat mut_y188_2___4 best32. ;
	informat mut_y188_2___5 best32. ;
	informat mut_y188_2___9 best32. ;
	informat mut_y188_other_2 $500. ;
	informat mut_g190_2___0 best32. ;
	informat mut_g190_2___1 best32. ;
	informat mut_g190_2___2 best32. ;
	informat mut_g190_2___3 best32. ;
	informat mut_g190_2___4 best32. ;
	informat mut_g190_2___5 best32. ;
	informat mut_g190_2___6 best32. ;
	informat mut_g190_2___7 best32. ;
	informat mut_g190_2___8 best32. ;
	informat mut_g190_2___9 best32. ;
	informat mut_g190_other_2 $500. ;
	informat mut_l210_2___0 best32. ;
	informat mut_l210_2___1 best32. ;
	informat mut_l210_2___2 best32. ;
	informat mut_l210_2___3 best32. ;
	informat mut_l210_2___9 best32. ;
	informat mut_l210_other_2 $500. ;
	informat mut_t215_2___0 best32. ;
	informat mut_t215_2___1 best32. ;
	informat mut_t215_2___2 best32. ;
	informat mut_t215_2___3 best32. ;
	informat mut_t215_2___4 best32. ;
	informat mut_t215_2___5 best32. ;
	informat mut_t215_2___6 best32. ;
	informat mut_t215_2___7 best32. ;
	informat mut_t215_2___8 best32. ;
	informat mut_t215_2___9 best32. ;
	informat mut_t215_other_2 $500. ;
	informat mut_k219_2___0 best32. ;
	informat mut_k219_2___1 best32. ;
	informat mut_k219_2___2 best32. ;
	informat mut_k219_2___3 best32. ;
	informat mut_k219_2___4 best32. ;
	informat mut_k219_2___5 best32. ;
	informat mut_k219_2___6 best32. ;
	informat mut_k219_2___7 best32. ;
	informat mut_k219_2___9 best32. ;
	informat mut_k219_other_2 $500. ;
	informat mut_h221_2___0 best32. ;
	informat mut_h221_2___1 best32. ;
	informat mut_h221_2___9 best32. ;
	informat mut_h221_other_2 $500. ;
	informat mut_p225_2___0 best32. ;
	informat mut_p225_2___1 best32. ;
	informat mut_p225_2___9 best32. ;
	informat mut_p225_other_2 $500. ;
	informat mut_f227_2___0 best32. ;
	informat mut_f227_2___1 best32. ;
	informat mut_f227_2___2 best32. ;
	informat mut_f227_2___9 best32. ;
	informat mut_f227_other_2 $500. ;
	informat mut_m230_2___0 best32. ;
	informat mut_m230_2___1 best32. ;
	informat mut_m230_2___9 best32. ;
	informat mut_m230_other_2 $500. ;
	informat mut_234_2___0 best32. ;
	informat mut_234_2___1 best32. ;
	informat mut_234_2___9 best32. ;
	informat mut_234_other_2 $500. ;
	informat mut_236_2___0 best32. ;
	informat mut_236_2___1 best32. ;
	informat mut_236_2___9 best32. ;
	informat mut_236_other_2 $500. ;
	informat mut_238_2___0 best32. ;
	informat mut_238_2___1 best32. ;
	informat mut_238_2___2 best32. ;
	informat mut_238_2___3 best32. ;
	informat mut_238_2___9 best32. ;
	informat mut_238_other_2 $500. ;
	informat mut_y318_2___0 best32. ;
	informat mut_y318_2___1 best32. ;
	informat mut_y318_2___9 best32. ;
	informat mut_y318_other_2 $500. ;
	informat mut_333_2___0 best32. ;
	informat mut_333_2___1 best32. ;
	informat mut_333_2___2 best32. ;
	informat mut_333_2___9 best32. ;
	informat mut_333_other_2 $500. ;
	informat mut_n348_2___0 best32. ;
	informat mut_n348_2___1 best32. ;
	informat mut_n348_2___9 best32. ;
	informat mut_n348_other_2 $500. ;
	informat other_rt_mut_2 $5000. ;
	informat mut_pi_major_2 best32. ;
	informat mut_pi_minor_2 best32. ;
	informat mut_l10_2___0 best32. ;
	informat mut_l10_2___1 best32. ;
	informat mut_l10_2___2 best32. ;
	informat mut_l10_2___3 best32. ;
	informat mut_l10_2___4 best32. ;
	informat mut_l10_2___5 best32. ;
	informat mut_l10_2___9 best32. ;
	informat mut_l10_other_2 $500. ;
	informat mut_v11_2___0 best32. ;
	informat mut_v11_2___1 best32. ;
	informat mut_v11_2___9 best32. ;
	informat mut_v11_other_2 $500. ;
	informat mut_13_2___0 best32. ;
	informat mut_13_2___1 best32. ;
	informat mut_13_2___9 best32. ;
	informat mut_13_other_2 $500. ;
	informat mut_g16_2___0 best32. ;
	informat mut_g16_2___1 best32. ;
	informat mut_g16_2___9 best32. ;
	informat mut_g16_other_2 $500. ;
	informat mut_k20_2___0 best32. ;
	informat mut_k20_2___1 best32. ;
	informat mut_k20_2___2 best32. ;
	informat mut_k20_2___3 best32. ;
	informat mut_k20_2___4 best32. ;
	informat mut_k20_2___5 best32. ;
	informat mut_k20_2___9 best32. ;
	informat mut_k20_other_2 $500. ;
	informat mut_23_2___0 best32. ;
	informat mut_23_2___1 best32. ;
	informat mut_23_2___9 best32. ;
	informat mut_23_other_2 $500. ;
	informat mut_l24_2___0 best32. ;
	informat mut_l24_2___1 best32. ;
	informat mut_l24_2___2 best32. ;
	informat mut_l24_2___9 best32. ;
	informat mut_l24_other_2 $500. ;
	informat mut_d30_2___0 best32. ;
	informat mut_d30_2___1 best32. ;
	informat mut_d30_2___9 best32. ;
	informat mut_d30_other_2 $500. ;
	informat mut_v32_2___0 best32. ;
	informat mut_v32_2___1 best32. ;
	informat mut_v32_2___9 best32. ;
	informat mut_v32_other_2 $500. ;
	informat mut_l33_2___0 best32. ;
	informat mut_l33_2___1 best32. ;
	informat mut_l33_2___2 best32. ;
	informat mut_l33_2___3 best32. ;
	informat mut_l33_2___9 best32. ;
	informat mut_l33_other_2 $500. ;
	informat mut_35_2___0 best32. ;
	informat mut_35_2___1 best32. ;
	informat mut_35_2___9 best32. ;
	informat mut_35_other_2 $500. ;
	informat mut_m36_2___0 best32. ;
	informat mut_m36_2___1 best32. ;
	informat mut_m36_2___2 best32. ;
	informat mut_m36_2___3 best32. ;
	informat mut_m36_2___4 best32. ;
	informat mut_m36_2___9 best32. ;
	informat mut_m36_other_2 $500. ;
	informat mut_k43_2___0 best32. ;
	informat mut_k43_2___1 best32. ;
	informat mut_k43_2___9 best32. ;
	informat mut_k43_other_2 $500. ;
	informat mut_m46_2___0 best32. ;
	informat mut_m46_2___1 best32. ;
	informat mut_m46_2___2 best32. ;
	informat mut_m46_2___3 best32. ;
	informat mut_m46_2___9 best32. ;
	informat mut_m46_other_2 $500. ;
	informat mut_i47_2___0 best32. ;
	informat mut_i47_2___1 best32. ;
	informat mut_i47_2___2 best32. ;
	informat mut_i47_2___9 best32. ;
	informat mut_i47_other_2 $500. ;
	informat mut_g48_2___0 best32. ;
	informat mut_g48_2___1 best32. ;
	informat mut_g48_2___2 best32. ;
	informat mut_g48_2___3 best32. ;
	informat mut_g48_2___4 best32. ;
	informat mut_g48_2___5 best32. ;
	informat mut_g48_2___6 best32. ;
	informat mut_g48_2___9 best32. ;
	informat mut_g48_other_2 $500. ;
	informat mut_i50_2___0 best32. ;
	informat mut_i50_2___1 best32. ;
	informat mut_i50_2___2 best32. ;
	informat mut_i50_2___9 best32. ;
	informat mut_i50_other_2 $500. ;
	informat mut_f53_2___0 best32. ;
	informat mut_f53_2___1 best32. ;
	informat mut_f53_2___2 best32. ;
	informat mut_f53_2___9 best32. ;
	informat mut_f53_other_2 $500. ;
	informat mut_i54_2___0 best32. ;
	informat mut_i54_2___1 best32. ;
	informat mut_i54_2___2 best32. ;
	informat mut_i54_2___3 best32. ;
	informat mut_i54_2___4 best32. ;
	informat mut_i54_2___5 best32. ;
	informat mut_i54_2___6 best32. ;
	informat mut_i54_2___9 best32. ;
	informat mut_i54_other_2 $500. ;
	informat mut_q58_2___0 best32. ;
	informat mut_q58_2___1 best32. ;
	informat mut_q58_2___9 best32. ;
	informat mut_q58_other_2 $500. ;
	informat mut_d60_2___0 best32. ;
	informat mut_d60_2___1 best32. ;
	informat mut_d60_2___9 best32. ;
	informat mut_d60_other_2 $500. ;
	informat mut_i62_2___0 best32. ;
	informat mut_i62_2___1 best32. ;
	informat mut_i62_2___9 best32. ;
	informat mut_i62_other_2 $500. ;
	informat mut_l63_2___0 best32. ;
	informat mut_l63_2___1 best32. ;
	informat mut_l63_2___9 best32. ;
	informat mut_l63_other_2 $500. ;
	informat mut_a71_2___0 best32. ;
	informat mut_a71_2___1 best32. ;
	informat mut_a71_2___2 best32. ;
	informat mut_a71_2___3 best32. ;
	informat mut_a71_2___4 best32. ;
	informat mut_a71_2___9 best32. ;
	informat mut_a71_other_2 $500. ;
	informat mut_g73_2___0 best32. ;
	informat mut_g73_2___1 best32. ;
	informat mut_g73_2___2 best32. ;
	informat mut_g73_2___3 best32. ;
	informat mut_g73_2___4 best32. ;
	informat mut_g73_2___9 best32. ;
	informat mut_g73_other_2 $500. ;
	informat mut_t74_2___0 best32. ;
	informat mut_t74_2___1 best32. ;
	informat mut_t74_2___2 best32. ;
	informat mut_t74_2___9 best32. ;
	informat mut_t74_other_2 $500. ;
	informat mut_l76_2___0 best32. ;
	informat mut_l76_2___1 best32. ;
	informat mut_l76_2___9 best32. ;
	informat mut_l76_other_2 $500. ;
	informat mut_v77_2___0 best32. ;
	informat mut_v77_2___1 best32. ;
	informat mut_v77_2___9 best32. ;
	informat mut_v77_other_2 $500. ;
	informat mut_v82_2___0 best32. ;
	informat mut_v82_2___1 best32. ;
	informat mut_v82_2___2 best32. ;
	informat mut_v82_2___3 best32. ;
	informat mut_v82_2___4 best32. ;
	informat mut_v82_2___5 best32. ;
	informat mut_v82_2___6 best32. ;
	informat mut_v82_2___7 best32. ;
	informat mut_v82_2___8 best32. ;
	informat mut_v82_2___9 best32. ;
	informat mut_v82_other_2 $500. ;
	informat mut_n83_2___0 best32. ;
	informat mut_n83_2___1 best32. ;
	informat mut_n83_2___9 best32. ;
	informat mut_n83_other_2 $500. ;
	informat mut_i84_2___0 best32. ;
	informat mut_i84_2___1 best32. ;
	informat mut_i84_2___2 best32. ;
	informat mut_i84_2___3 best32. ;
	informat mut_i84_2___9 best32. ;
	informat mut_i84_other_2 $500. ;
	informat mut_i85_2___0 best32. ;
	informat mut_i85_2___1 best32. ;
	informat mut_i85_2___9 best32. ;
	informat mut_i85_other_2 $500. ;
	informat mut_n88_2___0 best32. ;
	informat mut_n88_2___1 best32. ;
	informat mut_n88_2___2 best32. ;
	informat mut_n88_2___3 best32. ;
	informat mut_n88_2___4 best32. ;
	informat mut_n88_2___9 best32. ;
	informat mut_n88_other_2 $500. ;
	informat mut_l89_2___0 best32. ;
	informat mut_l89_2___1 best32. ;
	informat mut_l89_2___2 best32. ;
	informat mut_l89_2___3 best32. ;
	informat mut_l89_2___4 best32. ;
	informat mut_l89_2___9 best32. ;
	informat mut_l89_other_2 $500. ;
	informat mut_l90_2___0 best32. ;
	informat mut_l90_2___1 best32. ;
	informat mut_l90_2___9 best32. ;
	informat mut_l90_other_2 $500. ;
	informat mut_i93_2___0 best32. ;
	informat mut_i93_2___1 best32. ;
	informat mut_i93_2___2 best32. ;
	informat mut_i93_2___9 best32. ;
	informat mut_i93_other_2 $500. ;
	informat resistance_data_2_complete best32. ;

	format patient_id $500. ;
	format dt_results_rec_2 yymmdd10. ;
	format genotype_comments_2 $5000. ;
	format resist_3tc_2 best12. ;
	format resist_abc_2 best12. ;
	format resist_azt_2 best12. ;
	format resist_d4t_2 best12. ;
	format resist_ddi_2 best12. ;
	format resist_dlv_2 best12. ;
	format resist_efv_2 best12. ;
	format resist_etr_2 best12. ;
	format resist_ftc_2 best12. ;
	format resist_npv_2 best12. ;
	format resist_rpv_2 best12. ;
	format resist_tdf_2 best12. ;
	format mut_nrti_2 best12. ;
	format mut_nnrti_2 best12. ;
	format mut_m41_2___0 best12. ;
	format mut_m41_2___1 best12. ;
	format mut_m41_2___9 best12. ;
	format mut_m41_other_2 $500. ;
	format mut_44_2___0 best12. ;
	format mut_44_2___1 best12. ;
	format mut_44_2___2 best12. ;
	format mut_44_2___9 best12. ;
	format mut_44_other_2 $500. ;
	format mut_a62_2___0 best12. ;
	format mut_a62_2___1 best12. ;
	format mut_a62_2___9 best12. ;
	format mut_a62_other_2 $500. ;
	format mut_k65_2___0 best12. ;
	format mut_k65_2___1 best12. ;
	format mut_k65_2___2 best12. ;
	format mut_k65_2___9 best12. ;
	format mut_k65_other_2 $500. ;
	format mut_d67_2___0 best12. ;
	format mut_d67_2___1 best12. ;
	format mut_d67_2___2 best12. ;
	format mut_d67_2___3 best12. ;
	format mut_d67_2___4 best12. ;
	format mut_d67_2___9 best12. ;
	format mut_d67_other_2 $500. ;
	format mut_t69_2___0 best12. ;
	format mut_t69_2___1 best12. ;
	format mut_t69_2___2 best12. ;
	format mut_t69_2___3 best12. ;
	format mut_t69_2___4 best12. ;
	format mut_t69_2___5 best12. ;
	format mut_t69_2___6 best12. ;
	format mut_t69_2___7 best12. ;
	format mut_t69_2___9 best12. ;
	format mut_t69_other_2 $500. ;
	format mut_k70_2___0 best12. ;
	format mut_k70_2___1 best12. ;
	format mut_k70_2___2 best12. ;
	format mut_k70_2___3 best12. ;
	format mut_k70_2___4 best12. ;
	format mut_k70_2___9 best12. ;
	format mut_k70_other_2 $500. ;
	format mut_l74_2___0 best12. ;
	format mut_l74_2___1 best12. ;
	format mut_l74_2___2 best12. ;
	format mut_l74_2___9 best12. ;
	format mut_l74_other_2 $500. ;
	format mut_v75_2___0 best12. ;
	format mut_v75_2___1 best12. ;
	format mut_v75_2___2 best12. ;
	format mut_v75_2___3 best12. ;
	format mut_v75_2___4 best12. ;
	format mut_v75_2___5 best12. ;
	format mut_v75_2___6 best12. ;
	format mut_v75_2___9 best12. ;
	format mut_v75_other_2 $500. ;
	format mut_f77_2___0 best12. ;
	format mut_f77_2___1 best12. ;
	format mut_f77_2___9 best12. ;
	format mut_f77_other_2 $500. ;
	format mut_v90_2___0 best12. ;
	format mut_v90_2___1 best12. ;
	format mut_v90_2___9 best12. ;
	format mut_v90_other_2 $500. ;
	format mut_a98_2___0 best12. ;
	format mut_a98_2___1 best12. ;
	format mut_a98_2___2 best12. ;
	format mut_a98_2___9 best12. ;
	format mut_a98_other_2 $500. ;
	format mut_l100_2___0 best12. ;
	format mut_l100_2___1 best12. ;
	format mut_l100_2___9 best12. ;
	format mut_l100_other_2 $500. ;
	format mut_k101_2___0 best12. ;
	format mut_k101_2___1 best12. ;
	format mut_k101_2___2 best12. ;
	format mut_k101_2___3 best12. ;
	format mut_k101_2___4 best12. ;
	format mut_k101_2___5 best12. ;
	format mut_k101_2___6 best12. ;
	format mut_k101_2___9 best12. ;
	format mut_k101_other_2 $500. ;
	format mut_k103_2___0 best12. ;
	format mut_k103_2___1 best12. ;
	format mut_k103_2___2 best12. ;
	format mut_k103_2___3 best12. ;
	format mut_k103_2___4 best12. ;
	format mut_k103_2___5 best12. ;
	format mut_k103_2___6 best12. ;
	format mut_k103_2___7 best12. ;
	format mut_k103_2___9 best12. ;
	format mut_k103_other_2 $500. ;
	format mut_v106_2___0 best12. ;
	format mut_v106_2___1 best12. ;
	format mut_v106_2___2 best12. ;
	format mut_v106_2___3 best12. ;
	format mut_v106_2___4 best12. ;
	format mut_v106_2___9 best12. ;
	format mut_v106_other_2 $500. ;
	format mut_v108_2___0 best12. ;
	format mut_v108_2___1 best12. ;
	format mut_v108_2___9 best12. ;
	format mut_v108_other_2 $500. ;
	format mut_g109_2___0 best12. ;
	format mut_g109_2___1 best12. ;
	format mut_g109_2___2 best12. ;
	format mut_g109_2___9 best12. ;
	format mut_g109_other_2 $500. ;
	format mut_y115_2___0 best12. ;
	format mut_y115_2___1 best12. ;
	format mut_y115_2___2 best12. ;
	format mut_y115_2___9 best12. ;
	format mut_y115_other_2 $500. ;
	format mut_f116_2___0 best12. ;
	format mut_f116_2___1 best12. ;
	format mut_f116_2___9 best12. ;
	format mut_f116_other_2 $500. ;
	format mut_118_2___0 best12. ;
	format mut_118_2___1 best12. ;
	format mut_118_2___9 best12. ;
	format mut_118_other_2 $500. ;
	format mut_e138_2___0 best12. ;
	format mut_e138_2___1 best12. ;
	format mut_e138_2___2 best12. ;
	format mut_e138_2___3 best12. ;
	format mut_e138_2___4 best12. ;
	format mut_e138_2___9 best12. ;
	format mut_e138_other_2 $500. ;
	format mut_q151_2___0 best12. ;
	format mut_q151_2___1 best12. ;
	format mut_q151_2___2 best12. ;
	format mut_q151_2___9 best12. ;
	format mut_q151_other_2 $500. ;
	format mut_v179_2___0 best12. ;
	format mut_v179_2___1 best12. ;
	format mut_v179_2___2 best12. ;
	format mut_v179_2___3 best12. ;
	format mut_v179_2___4 best12. ;
	format mut_v179_2___5 best12. ;
	format mut_v179_2___6 best12. ;
	format mut_v179_2___9 best12. ;
	format mut_v179_other_2 $500. ;
	format mut_y181_2___0 best12. ;
	format mut_y181_2___1 best12. ;
	format mut_y181_2___2 best12. ;
	format mut_y181_2___3 best12. ;
	format mut_y181_2___4 best12. ;
	format mut_y181_2___9 best12. ;
	format mut_y181_other_2 $500. ;
	format mut_m184_2___0 best12. ;
	format mut_m184_2___1 best12. ;
	format mut_m184_2___2 best12. ;
	format mut_m184_2___3 best12. ;
	format mut_m184_2___9 best12. ;
	format mut_m184_other_2 $500. ;
	format mut_y188_2___0 best12. ;
	format mut_y188_2___1 best12. ;
	format mut_y188_2___2 best12. ;
	format mut_y188_2___3 best12. ;
	format mut_y188_2___4 best12. ;
	format mut_y188_2___5 best12. ;
	format mut_y188_2___9 best12. ;
	format mut_y188_other_2 $500. ;
	format mut_g190_2___0 best12. ;
	format mut_g190_2___1 best12. ;
	format mut_g190_2___2 best12. ;
	format mut_g190_2___3 best12. ;
	format mut_g190_2___4 best12. ;
	format mut_g190_2___5 best12. ;
	format mut_g190_2___6 best12. ;
	format mut_g190_2___7 best12. ;
	format mut_g190_2___8 best12. ;
	format mut_g190_2___9 best12. ;
	format mut_g190_other_2 $500. ;
	format mut_l210_2___0 best12. ;
	format mut_l210_2___1 best12. ;
	format mut_l210_2___2 best12. ;
	format mut_l210_2___3 best12. ;
	format mut_l210_2___9 best12. ;
	format mut_l210_other_2 $500. ;
	format mut_t215_2___0 best12. ;
	format mut_t215_2___1 best12. ;
	format mut_t215_2___2 best12. ;
	format mut_t215_2___3 best12. ;
	format mut_t215_2___4 best12. ;
	format mut_t215_2___5 best12. ;
	format mut_t215_2___6 best12. ;
	format mut_t215_2___7 best12. ;
	format mut_t215_2___8 best12. ;
	format mut_t215_2___9 best12. ;
	format mut_t215_other_2 $500. ;
	format mut_k219_2___0 best12. ;
	format mut_k219_2___1 best12. ;
	format mut_k219_2___2 best12. ;
	format mut_k219_2___3 best12. ;
	format mut_k219_2___4 best12. ;
	format mut_k219_2___5 best12. ;
	format mut_k219_2___6 best12. ;
	format mut_k219_2___7 best12. ;
	format mut_k219_2___9 best12. ;
	format mut_k219_other_2 $500. ;
	format mut_h221_2___0 best12. ;
	format mut_h221_2___1 best12. ;
	format mut_h221_2___9 best12. ;
	format mut_h221_other_2 $500. ;
	format mut_p225_2___0 best12. ;
	format mut_p225_2___1 best12. ;
	format mut_p225_2___9 best12. ;
	format mut_p225_other_2 $500. ;
	format mut_f227_2___0 best12. ;
	format mut_f227_2___1 best12. ;
	format mut_f227_2___2 best12. ;
	format mut_f227_2___9 best12. ;
	format mut_f227_other_2 $500. ;
	format mut_m230_2___0 best12. ;
	format mut_m230_2___1 best12. ;
	format mut_m230_2___9 best12. ;
	format mut_m230_other_2 $500. ;
	format mut_234_2___0 best12. ;
	format mut_234_2___1 best12. ;
	format mut_234_2___9 best12. ;
	format mut_234_other_2 $500. ;
	format mut_236_2___0 best12. ;
	format mut_236_2___1 best12. ;
	format mut_236_2___9 best12. ;
	format mut_236_other_2 $500. ;
	format mut_238_2___0 best12. ;
	format mut_238_2___1 best12. ;
	format mut_238_2___2 best12. ;
	format mut_238_2___3 best12. ;
	format mut_238_2___9 best12. ;
	format mut_238_other_2 $500. ;
	format mut_y318_2___0 best12. ;
	format mut_y318_2___1 best12. ;
	format mut_y318_2___9 best12. ;
	format mut_y318_other_2 $500. ;
	format mut_333_2___0 best12. ;
	format mut_333_2___1 best12. ;
	format mut_333_2___2 best12. ;
	format mut_333_2___9 best12. ;
	format mut_333_other_2 $500. ;
	format mut_n348_2___0 best12. ;
	format mut_n348_2___1 best12. ;
	format mut_n348_2___9 best12. ;
	format mut_n348_other_2 $500. ;
	format other_rt_mut_2 $5000. ;
	format mut_pi_major_2 best12. ;
	format mut_pi_minor_2 best12. ;
	format mut_l10_2___0 best12. ;
	format mut_l10_2___1 best12. ;
	format mut_l10_2___2 best12. ;
	format mut_l10_2___3 best12. ;
	format mut_l10_2___4 best12. ;
	format mut_l10_2___5 best12. ;
	format mut_l10_2___9 best12. ;
	format mut_l10_other_2 $500. ;
	format mut_v11_2___0 best12. ;
	format mut_v11_2___1 best12. ;
	format mut_v11_2___9 best12. ;
	format mut_v11_other_2 $500. ;
	format mut_13_2___0 best12. ;
	format mut_13_2___1 best12. ;
	format mut_13_2___9 best12. ;
	format mut_13_other_2 $500. ;
	format mut_g16_2___0 best12. ;
	format mut_g16_2___1 best12. ;
	format mut_g16_2___9 best12. ;
	format mut_g16_other_2 $500. ;
	format mut_k20_2___0 best12. ;
	format mut_k20_2___1 best12. ;
	format mut_k20_2___2 best12. ;
	format mut_k20_2___3 best12. ;
	format mut_k20_2___4 best12. ;
	format mut_k20_2___5 best12. ;
	format mut_k20_2___9 best12. ;
	format mut_k20_other_2 $500. ;
	format mut_23_2___0 best12. ;
	format mut_23_2___1 best12. ;
	format mut_23_2___9 best12. ;
	format mut_23_other_2 $500. ;
	format mut_l24_2___0 best12. ;
	format mut_l24_2___1 best12. ;
	format mut_l24_2___2 best12. ;
	format mut_l24_2___9 best12. ;
	format mut_l24_other_2 $500. ;
	format mut_d30_2___0 best12. ;
	format mut_d30_2___1 best12. ;
	format mut_d30_2___9 best12. ;
	format mut_d30_other_2 $500. ;
	format mut_v32_2___0 best12. ;
	format mut_v32_2___1 best12. ;
	format mut_v32_2___9 best12. ;
	format mut_v32_other_2 $500. ;
	format mut_l33_2___0 best12. ;
	format mut_l33_2___1 best12. ;
	format mut_l33_2___2 best12. ;
	format mut_l33_2___3 best12. ;
	format mut_l33_2___9 best12. ;
	format mut_l33_other_2 $500. ;
	format mut_35_2___0 best12. ;
	format mut_35_2___1 best12. ;
	format mut_35_2___9 best12. ;
	format mut_35_other_2 $500. ;
	format mut_m36_2___0 best12. ;
	format mut_m36_2___1 best12. ;
	format mut_m36_2___2 best12. ;
	format mut_m36_2___3 best12. ;
	format mut_m36_2___4 best12. ;
	format mut_m36_2___9 best12. ;
	format mut_m36_other_2 $500. ;
	format mut_k43_2___0 best12. ;
	format mut_k43_2___1 best12. ;
	format mut_k43_2___9 best12. ;
	format mut_k43_other_2 $500. ;
	format mut_m46_2___0 best12. ;
	format mut_m46_2___1 best12. ;
	format mut_m46_2___2 best12. ;
	format mut_m46_2___3 best12. ;
	format mut_m46_2___9 best12. ;
	format mut_m46_other_2 $500. ;
	format mut_i47_2___0 best12. ;
	format mut_i47_2___1 best12. ;
	format mut_i47_2___2 best12. ;
	format mut_i47_2___9 best12. ;
	format mut_i47_other_2 $500. ;
	format mut_g48_2___0 best12. ;
	format mut_g48_2___1 best12. ;
	format mut_g48_2___2 best12. ;
	format mut_g48_2___3 best12. ;
	format mut_g48_2___4 best12. ;
	format mut_g48_2___5 best12. ;
	format mut_g48_2___6 best12. ;
	format mut_g48_2___9 best12. ;
	format mut_g48_other_2 $500. ;
	format mut_i50_2___0 best12. ;
	format mut_i50_2___1 best12. ;
	format mut_i50_2___2 best12. ;
	format mut_i50_2___9 best12. ;
	format mut_i50_other_2 $500. ;
	format mut_f53_2___0 best12. ;
	format mut_f53_2___1 best12. ;
	format mut_f53_2___2 best12. ;
	format mut_f53_2___9 best12. ;
	format mut_f53_other_2 $500. ;
	format mut_i54_2___0 best12. ;
	format mut_i54_2___1 best12. ;
	format mut_i54_2___2 best12. ;
	format mut_i54_2___3 best12. ;
	format mut_i54_2___4 best12. ;
	format mut_i54_2___5 best12. ;
	format mut_i54_2___6 best12. ;
	format mut_i54_2___9 best12. ;
	format mut_i54_other_2 $500. ;
	format mut_q58_2___0 best12. ;
	format mut_q58_2___1 best12. ;
	format mut_q58_2___9 best12. ;
	format mut_q58_other_2 $500. ;
	format mut_d60_2___0 best12. ;
	format mut_d60_2___1 best12. ;
	format mut_d60_2___9 best12. ;
	format mut_d60_other_2 $500. ;
	format mut_i62_2___0 best12. ;
	format mut_i62_2___1 best12. ;
	format mut_i62_2___9 best12. ;
	format mut_i62_other_2 $500. ;
	format mut_l63_2___0 best12. ;
	format mut_l63_2___1 best12. ;
	format mut_l63_2___9 best12. ;
	format mut_l63_other_2 $500. ;
	format mut_a71_2___0 best12. ;
	format mut_a71_2___1 best12. ;
	format mut_a71_2___2 best12. ;
	format mut_a71_2___3 best12. ;
	format mut_a71_2___4 best12. ;
	format mut_a71_2___9 best12. ;
	format mut_a71_other_2 $500. ;
	format mut_g73_2___0 best12. ;
	format mut_g73_2___1 best12. ;
	format mut_g73_2___2 best12. ;
	format mut_g73_2___3 best12. ;
	format mut_g73_2___4 best12. ;
	format mut_g73_2___9 best12. ;
	format mut_g73_other_2 $500. ;
	format mut_t74_2___0 best12. ;
	format mut_t74_2___1 best12. ;
	format mut_t74_2___2 best12. ;
	format mut_t74_2___9 best12. ;
	format mut_t74_other_2 $500. ;
	format mut_l76_2___0 best12. ;
	format mut_l76_2___1 best12. ;
	format mut_l76_2___9 best12. ;
	format mut_l76_other_2 $500. ;
	format mut_v77_2___0 best12. ;
	format mut_v77_2___1 best12. ;
	format mut_v77_2___9 best12. ;
	format mut_v77_other_2 $500. ;
	format mut_v82_2___0 best12. ;
	format mut_v82_2___1 best12. ;
	format mut_v82_2___2 best12. ;
	format mut_v82_2___3 best12. ;
	format mut_v82_2___4 best12. ;
	format mut_v82_2___5 best12. ;
	format mut_v82_2___6 best12. ;
	format mut_v82_2___7 best12. ;
	format mut_v82_2___8 best12. ;
	format mut_v82_2___9 best12. ;
	format mut_v82_other_2 $500. ;
	format mut_n83_2___0 best12. ;
	format mut_n83_2___1 best12. ;
	format mut_n83_2___9 best12. ;
	format mut_n83_other_2 $500. ;
	format mut_i84_2___0 best12. ;
	format mut_i84_2___1 best12. ;
	format mut_i84_2___2 best12. ;
	format mut_i84_2___3 best12. ;
	format mut_i84_2___9 best12. ;
	format mut_i84_other_2 $500. ;
	format mut_i85_2___0 best12. ;
	format mut_i85_2___1 best12. ;
	format mut_i85_2___9 best12. ;
	format mut_i85_other_2 $500. ;
	format mut_n88_2___0 best12. ;
	format mut_n88_2___1 best12. ;
	format mut_n88_2___2 best12. ;
	format mut_n88_2___3 best12. ;
	format mut_n88_2___4 best12. ;
	format mut_n88_2___9 best12. ;
	format mut_n88_other_2 $500. ;
	format mut_l89_2___0 best12. ;
	format mut_l89_2___1 best12. ;
	format mut_l89_2___2 best12. ;
	format mut_l89_2___3 best12. ;
	format mut_l89_2___4 best12. ;
	format mut_l89_2___9 best12. ;
	format mut_l89_other_2 $500. ;
	format mut_l90_2___0 best12. ;
	format mut_l90_2___1 best12. ;
	format mut_l90_2___9 best12. ;
	format mut_l90_other_2 $500. ;
	format mut_i93_2___0 best12. ;
	format mut_i93_2___1 best12. ;
	format mut_i93_2___2 best12. ;
	format mut_i93_2___9 best12. ;
	format mut_i93_other_2 $500. ;
	format resistance_data_2_complete best12. ;

input
		patient_id $
		dt_results_rec_2
		genotype_comments_2 $
		resist_3tc_2
		resist_abc_2
		resist_azt_2
		resist_d4t_2
		resist_ddi_2
		resist_dlv_2
		resist_efv_2
		resist_etr_2
		resist_ftc_2
		resist_npv_2
		resist_rpv_2
		resist_tdf_2
		mut_nrti_2
		mut_nnrti_2
		mut_m41_2___0
		mut_m41_2___1
		mut_m41_2___9
		mut_m41_other_2 $
		mut_44_2___0
		mut_44_2___1
		mut_44_2___2
		mut_44_2___9
		mut_44_other_2 $
		mut_a62_2___0
		mut_a62_2___1
		mut_a62_2___9
		mut_a62_other_2 $
		mut_k65_2___0
		mut_k65_2___1
		mut_k65_2___2
		mut_k65_2___9
		mut_k65_other_2 $
		mut_d67_2___0
		mut_d67_2___1
		mut_d67_2___2
		mut_d67_2___3
		mut_d67_2___4
		mut_d67_2___9
		mut_d67_other_2 $
		mut_t69_2___0
		mut_t69_2___1
		mut_t69_2___2
		mut_t69_2___3
		mut_t69_2___4
		mut_t69_2___5
		mut_t69_2___6
		mut_t69_2___7
		mut_t69_2___9
		mut_t69_other_2 $
		mut_k70_2___0
		mut_k70_2___1
		mut_k70_2___2
		mut_k70_2___3
		mut_k70_2___4
		mut_k70_2___9
		mut_k70_other_2 $
		mut_l74_2___0
		mut_l74_2___1
		mut_l74_2___2
		mut_l74_2___9
		mut_l74_other_2 $
		mut_v75_2___0
		mut_v75_2___1
		mut_v75_2___2
		mut_v75_2___3
		mut_v75_2___4
		mut_v75_2___5
		mut_v75_2___6
		mut_v75_2___9
		mut_v75_other_2 $
		mut_f77_2___0
		mut_f77_2___1
		mut_f77_2___9
		mut_f77_other_2 $
		mut_v90_2___0
		mut_v90_2___1
		mut_v90_2___9
		mut_v90_other_2 $
		mut_a98_2___0
		mut_a98_2___1
		mut_a98_2___2
		mut_a98_2___9
		mut_a98_other_2 $
		mut_l100_2___0
		mut_l100_2___1
		mut_l100_2___9
		mut_l100_other_2 $
		mut_k101_2___0
		mut_k101_2___1
		mut_k101_2___2
		mut_k101_2___3
		mut_k101_2___4
		mut_k101_2___5
		mut_k101_2___6
		mut_k101_2___9
		mut_k101_other_2 $
		mut_k103_2___0
		mut_k103_2___1
		mut_k103_2___2
		mut_k103_2___3
		mut_k103_2___4
		mut_k103_2___5
		mut_k103_2___6
		mut_k103_2___7
		mut_k103_2___9
		mut_k103_other_2 $
		mut_v106_2___0
		mut_v106_2___1
		mut_v106_2___2
		mut_v106_2___3
		mut_v106_2___4
		mut_v106_2___9
		mut_v106_other_2 $
		mut_v108_2___0
		mut_v108_2___1
		mut_v108_2___9
		mut_v108_other_2 $
		mut_g109_2___0
		mut_g109_2___1
		mut_g109_2___2
		mut_g109_2___9
		mut_g109_other_2 $
		mut_y115_2___0
		mut_y115_2___1
		mut_y115_2___2
		mut_y115_2___9
		mut_y115_other_2 $
		mut_f116_2___0
		mut_f116_2___1
		mut_f116_2___9
		mut_f116_other_2 $
		mut_118_2___0
		mut_118_2___1
		mut_118_2___9
		mut_118_other_2 $
		mut_e138_2___0
		mut_e138_2___1
		mut_e138_2___2
		mut_e138_2___3
		mut_e138_2___4
		mut_e138_2___9
		mut_e138_other_2 $
		mut_q151_2___0
		mut_q151_2___1
		mut_q151_2___2
		mut_q151_2___9
		mut_q151_other_2 $
		mut_v179_2___0
		mut_v179_2___1
		mut_v179_2___2
		mut_v179_2___3
		mut_v179_2___4
		mut_v179_2___5
		mut_v179_2___6
		mut_v179_2___9
		mut_v179_other_2 $
		mut_y181_2___0
		mut_y181_2___1
		mut_y181_2___2
		mut_y181_2___3
		mut_y181_2___4
		mut_y181_2___9
		mut_y181_other_2 $
		mut_m184_2___0
		mut_m184_2___1
		mut_m184_2___2
		mut_m184_2___3
		mut_m184_2___9
		mut_m184_other_2 $
		mut_y188_2___0
		mut_y188_2___1
		mut_y188_2___2
		mut_y188_2___3
		mut_y188_2___4
		mut_y188_2___5
		mut_y188_2___9
		mut_y188_other_2 $
		mut_g190_2___0
		mut_g190_2___1
		mut_g190_2___2
		mut_g190_2___3
		mut_g190_2___4
		mut_g190_2___5
		mut_g190_2___6
		mut_g190_2___7
		mut_g190_2___8
		mut_g190_2___9
		mut_g190_other_2 $
		mut_l210_2___0
		mut_l210_2___1
		mut_l210_2___2
		mut_l210_2___3
		mut_l210_2___9
		mut_l210_other_2 $
		mut_t215_2___0
		mut_t215_2___1
		mut_t215_2___2
		mut_t215_2___3
		mut_t215_2___4
		mut_t215_2___5
		mut_t215_2___6
		mut_t215_2___7
		mut_t215_2___8
		mut_t215_2___9
		mut_t215_other_2 $
		mut_k219_2___0
		mut_k219_2___1
		mut_k219_2___2
		mut_k219_2___3
		mut_k219_2___4
		mut_k219_2___5
		mut_k219_2___6
		mut_k219_2___7
		mut_k219_2___9
		mut_k219_other_2 $
		mut_h221_2___0
		mut_h221_2___1
		mut_h221_2___9
		mut_h221_other_2 $
		mut_p225_2___0
		mut_p225_2___1
		mut_p225_2___9
		mut_p225_other_2 $
		mut_f227_2___0
		mut_f227_2___1
		mut_f227_2___2
		mut_f227_2___9
		mut_f227_other_2 $
		mut_m230_2___0
		mut_m230_2___1
		mut_m230_2___9
		mut_m230_other_2 $
		mut_234_2___0
		mut_234_2___1
		mut_234_2___9
		mut_234_other_2 $
		mut_236_2___0
		mut_236_2___1
		mut_236_2___9
		mut_236_other_2 $
		mut_238_2___0
		mut_238_2___1
		mut_238_2___2
		mut_238_2___3
		mut_238_2___9
		mut_238_other_2 $
		mut_y318_2___0
		mut_y318_2___1
		mut_y318_2___9
		mut_y318_other_2 $
		mut_333_2___0
		mut_333_2___1
		mut_333_2___2
		mut_333_2___9
		mut_333_other_2 $
		mut_n348_2___0
		mut_n348_2___1
		mut_n348_2___9
		mut_n348_other_2 $
		other_rt_mut_2 $
		mut_pi_major_2
		mut_pi_minor_2
		mut_l10_2___0
		mut_l10_2___1
		mut_l10_2___2
		mut_l10_2___3
		mut_l10_2___4
		mut_l10_2___5
		mut_l10_2___9
		mut_l10_other_2 $
		mut_v11_2___0
		mut_v11_2___1
		mut_v11_2___9
		mut_v11_other_2 $
		mut_13_2___0
		mut_13_2___1
		mut_13_2___9
		mut_13_other_2 $
		mut_g16_2___0
		mut_g16_2___1
		mut_g16_2___9
		mut_g16_other_2 $
		mut_k20_2___0
		mut_k20_2___1
		mut_k20_2___2
		mut_k20_2___3
		mut_k20_2___4
		mut_k20_2___5
		mut_k20_2___9
		mut_k20_other_2 $
		mut_23_2___0
		mut_23_2___1
		mut_23_2___9
		mut_23_other_2 $
		mut_l24_2___0
		mut_l24_2___1
		mut_l24_2___2
		mut_l24_2___9
		mut_l24_other_2 $
		mut_d30_2___0
		mut_d30_2___1
		mut_d30_2___9
		mut_d30_other_2 $
		mut_v32_2___0
		mut_v32_2___1
		mut_v32_2___9
		mut_v32_other_2 $
		mut_l33_2___0
		mut_l33_2___1
		mut_l33_2___2
		mut_l33_2___3
		mut_l33_2___9
		mut_l33_other_2 $
		mut_35_2___0
		mut_35_2___1
		mut_35_2___9
		mut_35_other_2 $
		mut_m36_2___0
		mut_m36_2___1
		mut_m36_2___2
		mut_m36_2___3
		mut_m36_2___4
		mut_m36_2___9
		mut_m36_other_2 $
		mut_k43_2___0
		mut_k43_2___1
		mut_k43_2___9
		mut_k43_other_2 $
		mut_m46_2___0
		mut_m46_2___1
		mut_m46_2___2
		mut_m46_2___3
		mut_m46_2___9
		mut_m46_other_2 $
		mut_i47_2___0
		mut_i47_2___1
		mut_i47_2___2
		mut_i47_2___9
		mut_i47_other_2 $
		mut_g48_2___0
		mut_g48_2___1
		mut_g48_2___2
		mut_g48_2___3
		mut_g48_2___4
		mut_g48_2___5
		mut_g48_2___6
		mut_g48_2___9
		mut_g48_other_2 $
		mut_i50_2___0
		mut_i50_2___1
		mut_i50_2___2
		mut_i50_2___9
		mut_i50_other_2 $
		mut_f53_2___0
		mut_f53_2___1
		mut_f53_2___2
		mut_f53_2___9
		mut_f53_other_2 $
		mut_i54_2___0
		mut_i54_2___1
		mut_i54_2___2
		mut_i54_2___3
		mut_i54_2___4
		mut_i54_2___5
		mut_i54_2___6
		mut_i54_2___9
		mut_i54_other_2 $
		mut_q58_2___0
		mut_q58_2___1
		mut_q58_2___9
		mut_q58_other_2 $
		mut_d60_2___0
		mut_d60_2___1
		mut_d60_2___9
		mut_d60_other_2 $
		mut_i62_2___0
		mut_i62_2___1
		mut_i62_2___9
		mut_i62_other_2 $
		mut_l63_2___0
		mut_l63_2___1
		mut_l63_2___9
		mut_l63_other_2 $
		mut_a71_2___0
		mut_a71_2___1
		mut_a71_2___2
		mut_a71_2___3
		mut_a71_2___4
		mut_a71_2___9
		mut_a71_other_2 $
		mut_g73_2___0
		mut_g73_2___1
		mut_g73_2___2
		mut_g73_2___3
		mut_g73_2___4
		mut_g73_2___9
		mut_g73_other_2 $
		mut_t74_2___0
		mut_t74_2___1
		mut_t74_2___2
		mut_t74_2___9
		mut_t74_other_2 $
		mut_l76_2___0
		mut_l76_2___1
		mut_l76_2___9
		mut_l76_other_2 $
		mut_v77_2___0
		mut_v77_2___1
		mut_v77_2___9
		mut_v77_other_2 $
		mut_v82_2___0
		mut_v82_2___1
		mut_v82_2___2
		mut_v82_2___3
		mut_v82_2___4
		mut_v82_2___5
		mut_v82_2___6
		mut_v82_2___7
		mut_v82_2___8
		mut_v82_2___9
		mut_v82_other_2 $
		mut_n83_2___0
		mut_n83_2___1
		mut_n83_2___9
		mut_n83_other_2 $
		mut_i84_2___0
		mut_i84_2___1
		mut_i84_2___2
		mut_i84_2___3
		mut_i84_2___9
		mut_i84_other_2 $
		mut_i85_2___0
		mut_i85_2___1
		mut_i85_2___9
		mut_i85_other_2 $
		mut_n88_2___0
		mut_n88_2___1
		mut_n88_2___2
		mut_n88_2___3
		mut_n88_2___4
		mut_n88_2___9
		mut_n88_other_2 $
		mut_l89_2___0
		mut_l89_2___1
		mut_l89_2___2
		mut_l89_2___3
		mut_l89_2___4
		mut_l89_2___9
		mut_l89_other_2 $
		mut_l90_2___0
		mut_l90_2___1
		mut_l90_2___9
		mut_l90_other_2 $
		mut_i93_2___0
		mut_i93_2___1
		mut_i93_2___2
		mut_i93_2___9
		mut_i93_other_2 $
		resistance_data_2_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label dt_results_rec_2='Date results received';
	label genotype_comments_2='Genotype Comments';
	label resist_3tc_2='3TC';
	label resist_abc_2='ABC';
	label resist_azt_2='AZT';
	label resist_d4t_2='D4T';
	label resist_ddi_2='DDI';
	label resist_dlv_2='DLV';
	label resist_efv_2='EFV';
	label resist_etr_2='ETR';
	label resist_ftc_2='FTC';
	label resist_npv_2='NPV';
	label resist_rpv_2='RPV';
	label resist_tdf_2='TDF';
	label mut_nrti_2='NRTI Mutations';
	label mut_nnrti_2='NNRTI Mutations';
	label mut_m41_2___0='M41 (choice=M (WT))';
	label mut_m41_2___1='M41 (choice=L)';
	label mut_m41_2___9='M41 (choice=Other)';
	label mut_m41_other_2='Other ';
	label mut_44_2___0='44 (choice=E (WT))';
	label mut_44_2___1='44 (choice=A)';
	label mut_44_2___2='44 (choice=D)';
	label mut_44_2___9='44 (choice=Other)';
	label mut_44_other_2='Other';
	label mut_a62_2___0='A62 (choice=A (WT))';
	label mut_a62_2___1='A62 (choice=V)';
	label mut_a62_2___9='A62 (choice=Other)';
	label mut_a62_other_2='Other';
	label mut_k65_2___0='K65 (choice=K (WT))';
	label mut_k65_2___1='K65 (choice=N)';
	label mut_k65_2___2='K65 (choice=R)';
	label mut_k65_2___9='K65 (choice=Other)';
	label mut_k65_other_2='Other';
	label mut_d67_2___0='D67 (choice=D (WT))';
	label mut_d67_2___1='D67 (choice=E)';
	label mut_d67_2___2='D67 (choice=G)';
	label mut_d67_2___3='D67 (choice=N)';
	label mut_d67_2___4='D67 (choice=d)';
	label mut_d67_2___9='D67 (choice=Other)';
	label mut_d67_other_2='Other';
	label mut_t69_2___0='T69 (choice=T (WT))';
	label mut_t69_2___1='T69 (choice=A)';
	label mut_t69_2___2='T69 (choice=D)';
	label mut_t69_2___3='T69 (choice=G)';
	label mut_t69_2___4='T69 (choice=I)';
	label mut_t69_2___5='T69 (choice=N)';
	label mut_t69_2___6='T69 (choice=S)';
	label mut_t69_2___7='T69 (choice=i)';
	label mut_t69_2___9='T69 (choice=Other)';
	label mut_t69_other_2='Other';
	label mut_k70_2___0='K70 (choice=K (WT))';
	label mut_k70_2___1='K70 (choice=E)';
	label mut_k70_2___2='K70 (choice=G)';
	label mut_k70_2___3='K70 (choice=R)';
	label mut_k70_2___4='K70 (choice=T)';
	label mut_k70_2___9='K70 (choice=Other)';
	label mut_k70_other_2='Other';
	label mut_l74_2___0='L74 (choice=L (WT))';
	label mut_l74_2___1='L74 (choice=I)';
	label mut_l74_2___2='L74 (choice=V)';
	label mut_l74_2___9='L74 (choice=Other)';
	label mut_l74_other_2='Other';
	label mut_v75_2___0='V75 (choice=V (WT))';
	label mut_v75_2___1='V75 (choice=A)';
	label mut_v75_2___2='V75 (choice=I)';
	label mut_v75_2___3='V75 (choice=L)';
	label mut_v75_2___4='V75 (choice=M)';
	label mut_v75_2___5='V75 (choice=S)';
	label mut_v75_2___6='V75 (choice=T)';
	label mut_v75_2___9='V75 (choice=Other)';
	label mut_v75_other_2='Other';
	label mut_f77_2___0='F77 (choice=F (WT))';
	label mut_f77_2___1='F77 (choice=L)';
	label mut_f77_2___9='F77 (choice=Other)';
	label mut_f77_other_2='Other';
	label mut_v90_2___0='V90 (choice=V (WT))';
	label mut_v90_2___1='V90 (choice=I)';
	label mut_v90_2___9='V90 (choice=Other)';
	label mut_v90_other_2='Other';
	label mut_a98_2___0='A98 (choice=A (WT))';
	label mut_a98_2___1='A98 (choice=G)';
	label mut_a98_2___2='A98 (choice=S)';
	label mut_a98_2___9='A98 (choice=Other)';
	label mut_a98_other_2='Other';
	label mut_l100_2___0='L100 (choice=L (WT))';
	label mut_l100_2___1='L100 (choice=I)';
	label mut_l100_2___9='L100 (choice=Other)';
	label mut_l100_other_2='Other';
	label mut_k101_2___0='K101 (choice=K (WT))';
	label mut_k101_2___1='K101 (choice=E)';
	label mut_k101_2___2='K101 (choice=H)';
	label mut_k101_2___3='K101 (choice=N)';
	label mut_k101_2___4='K101 (choice=P)';
	label mut_k101_2___5='K101 (choice=Q)';
	label mut_k101_2___6='K101 (choice=R)';
	label mut_k101_2___9='K101 (choice=Other)';
	label mut_k101_other_2='Other';
	label mut_k103_2___0='K103 (choice=K (WT))';
	label mut_k103_2___1='K103 (choice=E)';
	label mut_k103_2___2='K103 (choice=H)';
	label mut_k103_2___3='K103 (choice=N)';
	label mut_k103_2___4='K103 (choice=Q)';
	label mut_k103_2___5='K103 (choice=R)';
	label mut_k103_2___6='K103 (choice=S)';
	label mut_k103_2___7='K103 (choice=T)';
	label mut_k103_2___9='K103 (choice=Other)';
	label mut_k103_other_2='Other';
	label mut_v106_2___0='V106 (choice=V (WT))';
	label mut_v106_2___1='V106 (choice=A)';
	label mut_v106_2___2='V106 (choice=I)';
	label mut_v106_2___3='V106 (choice=L)';
	label mut_v106_2___4='V106 (choice=M)';
	label mut_v106_2___9='V106 (choice=Other)';
	label mut_v106_other_2='Other';
	label mut_v108_2___0='V108 (choice=V (WT))';
	label mut_v108_2___1='V108 (choice=I)';
	label mut_v108_2___9='V108 (choice=Other)';
	label mut_v108_other_2='Other';
	label mut_g109_2___0='G109 (choice=G (WT))';
	label mut_g109_2___1='G109 (choice=E)';
	label mut_g109_2___2='G109 (choice=S)';
	label mut_g109_2___9='G109 (choice=Other)';
	label mut_g109_other_2='Other';
	label mut_y115_2___0='Y115 (choice=Y (WT))';
	label mut_y115_2___1='Y115 (choice=F)';
	label mut_y115_2___2='Y115 (choice=S)';
	label mut_y115_2___9='Y115 (choice=Other)';
	label mut_y115_other_2='Other';
	label mut_f116_2___0='F116 (choice=F (WT))';
	label mut_f116_2___1='F116 (choice=Y)';
	label mut_f116_2___9='F116 (choice=Other)';
	label mut_f116_other_2='Other';
	label mut_118_2___0='118 (choice=V (WT))';
	label mut_118_2___1='118 (choice=I)';
	label mut_118_2___9='118 (choice=Other)';
	label mut_118_other_2='Other';
	label mut_e138_2___0='E138 (choice=E (WT))';
	label mut_e138_2___1='E138 (choice=A)';
	label mut_e138_2___2='E138 (choice=G)';
	label mut_e138_2___3='E138 (choice=K)';
	label mut_e138_2___4='E138 (choice=Q)';
	label mut_e138_2___9='E138 (choice=Other)';
	label mut_e138_other_2='Other';
	label mut_q151_2___0='Q151 (choice=Q (WT))';
	label mut_q151_2___1='Q151 (choice=L)';
	label mut_q151_2___2='Q151 (choice=M)';
	label mut_q151_2___9='Q151 (choice=Other)';
	label mut_q151_other_2='Other';
	label mut_v179_2___0='V179 (choice=V (WT))';
	label mut_v179_2___1='V179 (choice=D)';
	label mut_v179_2___2='V179 (choice=E)';
	label mut_v179_2___3='V179 (choice=F)';
	label mut_v179_2___4='V179 (choice=I)';
	label mut_v179_2___5='V179 (choice=T)';
	label mut_v179_2___6='V179 (choice=Y)';
	label mut_v179_2___9='V179 (choice=Other)';
	label mut_v179_other_2='Other';
	label mut_y181_2___0='Y181 (choice=Y (WT))';
	label mut_y181_2___1='Y181 (choice=C)';
	label mut_y181_2___2='Y181 (choice=I)';
	label mut_y181_2___3='Y181 (choice=S)';
	label mut_y181_2___4='Y181 (choice=V)';
	label mut_y181_2___9='Y181 (choice=Other)';
	label mut_y181_other_2='Other';
	label mut_m184_2___0='M184 (choice=M (WT))';
	label mut_m184_2___1='M184 (choice=C)';
	label mut_m184_2___2='M184 (choice=I)';
	label mut_m184_2___3='M184 (choice=V)';
	label mut_m184_2___9='M184 (choice=Other)';
	label mut_m184_other_2='Other';
	label mut_y188_2___0='Y188 (choice=Y (WT))';
	label mut_y188_2___1='Y188 (choice=C)';
	label mut_y188_2___2='Y188 (choice=F)';
	label mut_y188_2___3='Y188 (choice=H)';
	label mut_y188_2___4='Y188 (choice=L)';
	label mut_y188_2___5='Y188 (choice=N)';
	label mut_y188_2___9='Y188 (choice=Other)';
	label mut_y188_other_2='Other';
	label mut_g190_2___0='G190 (choice=G (WT))';
	label mut_g190_2___1='G190 (choice=A)';
	label mut_g190_2___2='G190 (choice=C)';
	label mut_g190_2___3='G190 (choice=D)';
	label mut_g190_2___4='G190 (choice=E)';
	label mut_g190_2___5='G190 (choice=Q)';
	label mut_g190_2___6='G190 (choice=S)';
	label mut_g190_2___7='G190 (choice=T)';
	label mut_g190_2___8='G190 (choice=V)';
	label mut_g190_2___9='G190 (choice=Other)';
	label mut_g190_other_2='Other';
	label mut_l210_2___0='L210 (choice=L (WT))';
	label mut_l210_2___1='L210 (choice=F)';
	label mut_l210_2___2='L210 (choice=S)';
	label mut_l210_2___3='L210 (choice=W)';
	label mut_l210_2___9='L210 (choice=Other)';
	label mut_l210_other_2='Other';
	label mut_t215_2___0='T215 (choice=T (WT))';
	label mut_t215_2___1='T215 (choice=C)';
	label mut_t215_2___2='T215 (choice=D)';
	label mut_t215_2___3='T215 (choice=E)';
	label mut_t215_2___4='T215 (choice=F)';
	label mut_t215_2___5='T215 (choice=I)';
	label mut_t215_2___6='T215 (choice=S)';
	label mut_t215_2___7='T215 (choice=V)';
	label mut_t215_2___8='T215 (choice=Y)';
	label mut_t215_2___9='T215 (choice=Other)';
	label mut_t215_other_2='Other';
	label mut_k219_2___0='K219 (choice=K (WT))';
	label mut_k219_2___1='K219 (choice=D)';
	label mut_k219_2___2='K219 (choice=E)';
	label mut_k219_2___3='K219 (choice=H)';
	label mut_k219_2___4='K219 (choice=N)';
	label mut_k219_2___5='K219 (choice=Q)';
	label mut_k219_2___6='K219 (choice=R)';
	label mut_k219_2___7='K219 (choice=W)';
	label mut_k219_2___9='K219 (choice=Other)';
	label mut_k219_other_2='Other';
	label mut_h221_2___0='H221 (choice=H (WT))';
	label mut_h221_2___1='H221 (choice=Y)';
	label mut_h221_2___9='H221 (choice=Other)';
	label mut_h221_other_2='Other';
	label mut_p225_2___0='P225 (choice=P (WT))';
	label mut_p225_2___1='P225 (choice=H)';
	label mut_p225_2___9='P225 (choice=Other)';
	label mut_p225_other_2='Other';
	label mut_f227_2___0='F227 (choice=F (WT))';
	label mut_f227_2___1='F227 (choice=C)';
	label mut_f227_2___2='F227 (choice=L)';
	label mut_f227_2___9='F227 (choice=Other)';
	label mut_f227_other_2='Other';
	label mut_m230_2___0='M230 (choice=M (WT))';
	label mut_m230_2___1='M230 (choice=L)';
	label mut_m230_2___9='M230 (choice=Other)';
	label mut_m230_other_2='Other';
	label mut_234_2___0='234 (choice=L (WT))';
	label mut_234_2___1='234 (choice=I)';
	label mut_234_2___9='234 (choice=Other)';
	label mut_234_other_2='Other';
	label mut_236_2___0='236 (choice=P (WT))';
	label mut_236_2___1='236 (choice=L)';
	label mut_236_2___9='236 (choice=Other)';
	label mut_236_other_2='Other';
	label mut_238_2___0='238 (choice=K (WT))';
	label mut_238_2___1='238 (choice=N)';
	label mut_238_2___2='238 (choice=R)';
	label mut_238_2___3='238 (choice=T)';
	label mut_238_2___9='238 (choice=Other)';
	label mut_238_other_2='Other';
	label mut_y318_2___0='Y318 (choice=Y (WT))';
	label mut_y318_2___1='Y318 (choice=F)';
	label mut_y318_2___9='Y318 (choice=Other)';
	label mut_y318_other_2='Other';
	label mut_333_2___0='333 (choice=G (WT))';
	label mut_333_2___1='333 (choice=D)';
	label mut_333_2___2='333 (choice=E)';
	label mut_333_2___9='333 (choice=Other)';
	label mut_333_other_2='Other';
	label mut_n348_2___0='N348 (choice=N (WT))';
	label mut_n348_2___1='N348 (choice=I)';
	label mut_n348_2___9='N348 (choice=Other)';
	label mut_n348_other_2='Other';
	label other_rt_mut_2='Other RT Mutations';
	label mut_pi_major_2='PI Major Mutations';
	label mut_pi_minor_2='PI Minor Mutations';
	label mut_l10_2___0='L10 (choice=L (WT))';
	label mut_l10_2___1='L10 (choice=F)';
	label mut_l10_2___2='L10 (choice=I)';
	label mut_l10_2___3='L10 (choice=R)';
	label mut_l10_2___4='L10 (choice=V)';
	label mut_l10_2___5='L10 (choice=Y)';
	label mut_l10_2___9='L10 (choice=Other)';
	label mut_l10_other_2='Other';
	label mut_v11_2___0='V11 (choice=V (WT))';
	label mut_v11_2___1='V11 (choice=I)';
	label mut_v11_2___9='V11 (choice=Other)';
	label mut_v11_other_2='Other';
	label mut_13_2___0='13 (choice=I (WT))';
	label mut_13_2___1='13 (choice=V)';
	label mut_13_2___9='13 (choice=Other)';
	label mut_13_other_2='Other';
	label mut_g16_2___0='G16 (choice=G (WT))';
	label mut_g16_2___1='G16 (choice=E)';
	label mut_g16_2___9='G16 (choice=Other)';
	label mut_g16_other_2='Other';
	label mut_k20_2___0='K20 (choice=K (WT))';
	label mut_k20_2___1='K20 (choice=I)';
	label mut_k20_2___2='K20 (choice=M)';
	label mut_k20_2___3='K20 (choice=R)';
	label mut_k20_2___4='K20 (choice=T)';
	label mut_k20_2___5='K20 (choice=V)';
	label mut_k20_2___9='K20 (choice=Other)';
	label mut_k20_other_2='Other';
	label mut_23_2___0='23 (choice=L (WT))';
	label mut_23_2___1='23 (choice=I)';
	label mut_23_2___9='23 (choice=Other)';
	label mut_23_other_2='Other';
	label mut_l24_2___0='L24 (choice=L (WT))';
	label mut_l24_2___1='L24 (choice=F)';
	label mut_l24_2___2='L24 (choice=I)';
	label mut_l24_2___9='L24 (choice=Other)';
	label mut_l24_other_2='Other';
	label mut_d30_2___0='D30 (choice=D (WT))';
	label mut_d30_2___1='D30 (choice=N)';
	label mut_d30_2___9='D30 (choice=Other)';
	label mut_d30_other_2='Other';
	label mut_v32_2___0='V32 (choice=V (WT))';
	label mut_v32_2___1='V32 (choice=I)';
	label mut_v32_2___9='V32 (choice=Other)';
	label mut_v32_other_2='Other';
	label mut_l33_2___0='L33 (choice=L (WT))';
	label mut_l33_2___1='L33 (choice=F)';
	label mut_l33_2___2='L33 (choice=I)';
	label mut_l33_2___3='L33 (choice=V)';
	label mut_l33_2___9='L33 (choice=Other)';
	label mut_l33_other_2='Other';
	label mut_35_2___0='35 (choice=E (WT))';
	label mut_35_2___1='35 (choice=G)';
	label mut_35_2___9='35 (choice=Other)';
	label mut_35_other_2='Other';
	label mut_m36_2___0='M36 (choice=M (WT))';
	label mut_m36_2___1='M36 (choice=I)';
	label mut_m36_2___2='M36 (choice=L)';
	label mut_m36_2___3='M36 (choice=T)';
	label mut_m36_2___4='M36 (choice=V)';
	label mut_m36_2___9='M36 (choice=Other)';
	label mut_m36_other_2='Other';
	label mut_k43_2___0='K43 (choice=K (WT))';
	label mut_k43_2___1='K43 (choice=T)';
	label mut_k43_2___9='K43 (choice=Other)';
	label mut_k43_other_2='Other';
	label mut_m46_2___0='M46 (choice=M (WT))';
	label mut_m46_2___1='M46 (choice=I)';
	label mut_m46_2___2='M46 (choice=L)';
	label mut_m46_2___3='M46 (choice=V)';
	label mut_m46_2___9='M46 (choice=Other)';
	label mut_m46_other_2='Other';
	label mut_i47_2___0='I47 (choice=I (WT))';
	label mut_i47_2___1='I47 (choice=A)';
	label mut_i47_2___2='I47 (choice=V)';
	label mut_i47_2___9='I47 (choice=Other)';
	label mut_i47_other_2='Other';
	label mut_g48_2___0='G48 (choice=G (WT))';
	label mut_g48_2___1='G48 (choice=A)';
	label mut_g48_2___2='G48 (choice=M)';
	label mut_g48_2___3='G48 (choice=Q)';
	label mut_g48_2___4='G48 (choice=S)';
	label mut_g48_2___5='G48 (choice=T)';
	label mut_g48_2___6='G48 (choice=V)';
	label mut_g48_2___9='G48 (choice=Other)';
	label mut_g48_other_2='Other';
	label mut_i50_2___0='I50 (choice=I (WT))';
	label mut_i50_2___1='I50 (choice=L)';
	label mut_i50_2___2='I50 (choice=V)';
	label mut_i50_2___9='I50 (choice=Other)';
	label mut_i50_other_2='Other';
	label mut_f53_2___0='F53 (choice=F (WT))';
	label mut_f53_2___1='F53 (choice=L)';
	label mut_f53_2___2='F53 (choice=Y)';
	label mut_f53_2___9='F53 (choice=Other)';
	label mut_f53_other_2='Other';
	label mut_i54_2___0='I54 (choice=I (WT))';
	label mut_i54_2___1='I54 (choice=A)';
	label mut_i54_2___2='I54 (choice=L)';
	label mut_i54_2___3='I54 (choice=M)';
	label mut_i54_2___4='I54 (choice=S)';
	label mut_i54_2___5='I54 (choice=T)';
	label mut_i54_2___6='I54 (choice=V)';
	label mut_i54_2___9='I54 (choice=Other)';
	label mut_i54_other_2='Other';
	label mut_q58_2___0='Q58 (choice=Q (WT))';
	label mut_q58_2___1='Q58 (choice=E)';
	label mut_q58_2___9='Q58 (choice=Other)';
	label mut_q58_other_2='Other';
	label mut_d60_2___0='D60 (choice=D (WT))';
	label mut_d60_2___1='D60 (choice=E)';
	label mut_d60_2___9='D60 (choice=Other)';
	label mut_d60_other_2='Other';
	label mut_i62_2___0='I62 (choice=I (WT))';
	label mut_i62_2___1='I62 (choice=V)';
	label mut_i62_2___9='I62 (choice=Other)';
	label mut_i62_other_2='Other';
	label mut_l63_2___0='L63 (choice=L (WT))';
	label mut_l63_2___1='L63 (choice=P)';
	label mut_l63_2___9='L63 (choice=Other)';
	label mut_l63_other_2='Other';
	label mut_a71_2___0='A71 (choice=A (WT))';
	label mut_a71_2___1='A71 (choice=I)';
	label mut_a71_2___2='A71 (choice=L)';
	label mut_a71_2___3='A71 (choice=T)';
	label mut_a71_2___4='A71 (choice=V)';
	label mut_a71_2___9='A71 (choice=Other)';
	label mut_a71_other_2='Other';
	label mut_g73_2___0='G73 (choice=G (WT))';
	label mut_g73_2___1='G73 (choice=A)';
	label mut_g73_2___2='G73 (choice=C)';
	label mut_g73_2___3='G73 (choice=S)';
	label mut_g73_2___4='G73 (choice=T)';
	label mut_g73_2___9='G73 (choice=Other)';
	label mut_g73_other_2='Other';
	label mut_t74_2___0='T74 (choice=T (WT))';
	label mut_t74_2___1='T74 (choice=P)';
	label mut_t74_2___2='T74 (choice=S)';
	label mut_t74_2___9='T74 (choice=Other)';
	label mut_t74_other_2='Other';
	label mut_l76_2___0='L76 (choice=L (WT))';
	label mut_l76_2___1='L76 (choice=V)';
	label mut_l76_2___9='L76 (choice=Other)';
	label mut_l76_other_2='Other';
	label mut_v77_2___0='V77 (choice=V (WT))';
	label mut_v77_2___1='V77 (choice=I)';
	label mut_v77_2___9='V77 (choice=Other)';
	label mut_v77_other_2='Other';
	label mut_v82_2___0='V82 (choice=V (WT))';
	label mut_v82_2___1='V82 (choice=A)';
	label mut_v82_2___2='V82 (choice=C)';
	label mut_v82_2___3='V82 (choice=F)';
	label mut_v82_2___4='V82 (choice=I)';
	label mut_v82_2___5='V82 (choice=L)';
	label mut_v82_2___6='V82 (choice=M)';
	label mut_v82_2___7='V82 (choice=S)';
	label mut_v82_2___8='V82 (choice=T)';
	label mut_v82_2___9='V82 (choice=Other)';
	label mut_v82_other_2='Other';
	label mut_n83_2___0='N83 (choice=N (WT))';
	label mut_n83_2___1='N83 (choice=D)';
	label mut_n83_2___9='N83 (choice=Other)';
	label mut_n83_other_2='Other';
	label mut_i84_2___0='I84 (choice=I (WT))';
	label mut_i84_2___1='I84 (choice=A)';
	label mut_i84_2___2='I84 (choice=C)';
	label mut_i84_2___3='I84 (choice=V)';
	label mut_i84_2___9='I84 (choice=Other)';
	label mut_i84_other_2='Other';
	label mut_i85_2___0='I85 (choice=I (WT))';
	label mut_i85_2___1='I85 (choice=V)';
	label mut_i85_2___9='I85 (choice=Other)';
	label mut_i85_other_2='Other';
	label mut_n88_2___0='N88 (choice=N (WT))';
	label mut_n88_2___1='N88 (choice=D)';
	label mut_n88_2___2='N88 (choice=G)';
	label mut_n88_2___3='N88 (choice=S)';
	label mut_n88_2___4='N88 (choice=T)';
	label mut_n88_2___9='N88 (choice=Other)';
	label mut_n88_other_2='Other';
	label mut_l89_2___0='L89 (choice=L (WT))';
	label mut_l89_2___1='L89 (choice=I)';
	label mut_l89_2___2='L89 (choice=M)';
	label mut_l89_2___3='L89 (choice=T)';
	label mut_l89_2___4='L89 (choice=V)';
	label mut_l89_2___9='L89 (choice=Other)';
	label mut_l89_other_2='Other';
	label mut_l90_2___0='L90 (choice=L (WT))';
	label mut_l90_2___1='L90 (choice=M)';
	label mut_l90_2___9='L90 (choice=Other)';
	label mut_l90_other_2='Other';
	label mut_i93_2___0='I93 (choice=I (WT))';
	label mut_i93_2___1='I93 (choice=L)';
	label mut_i93_2___2='I93 (choice=M)';
	label mut_i93_2___9='I93 (choice=Other)';
	label mut_i93_other_2='Other';
	label resistance_data_2_complete='Complete?';
	run;

proc format;
	value resist_3tc_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_abc_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_azt_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_d4t_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_ddi_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_dlv_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_efv_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_etr_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_ftc_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_npv_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_rpv_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_tdf_2_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value mut_nrti_2_ 1='Yes' 2='No';
	value mut_nnrti_2_ 1='Yes' 2='No';
	value mut_m41_2___0_ 0='Unchecked' 1='Checked';
	value mut_m41_2___1_ 0='Unchecked' 1='Checked';
	value mut_m41_2___9_ 0='Unchecked' 1='Checked';
	value mut_44_2___0_ 0='Unchecked' 1='Checked';
	value mut_44_2___1_ 0='Unchecked' 1='Checked';
	value mut_44_2___2_ 0='Unchecked' 1='Checked';
	value mut_44_2___9_ 0='Unchecked' 1='Checked';
	value mut_a62_2___0_ 0='Unchecked' 1='Checked';
	value mut_a62_2___1_ 0='Unchecked' 1='Checked';
	value mut_a62_2___9_ 0='Unchecked' 1='Checked';
	value mut_k65_2___0_ 0='Unchecked' 1='Checked';
	value mut_k65_2___1_ 0='Unchecked' 1='Checked';
	value mut_k65_2___2_ 0='Unchecked' 1='Checked';
	value mut_k65_2___9_ 0='Unchecked' 1='Checked';
	value mut_d67_2___0_ 0='Unchecked' 1='Checked';
	value mut_d67_2___1_ 0='Unchecked' 1='Checked';
	value mut_d67_2___2_ 0='Unchecked' 1='Checked';
	value mut_d67_2___3_ 0='Unchecked' 1='Checked';
	value mut_d67_2___4_ 0='Unchecked' 1='Checked';
	value mut_d67_2___9_ 0='Unchecked' 1='Checked';
	value mut_t69_2___0_ 0='Unchecked' 1='Checked';
	value mut_t69_2___1_ 0='Unchecked' 1='Checked';
	value mut_t69_2___2_ 0='Unchecked' 1='Checked';
	value mut_t69_2___3_ 0='Unchecked' 1='Checked';
	value mut_t69_2___4_ 0='Unchecked' 1='Checked';
	value mut_t69_2___5_ 0='Unchecked' 1='Checked';
	value mut_t69_2___6_ 0='Unchecked' 1='Checked';
	value mut_t69_2___7_ 0='Unchecked' 1='Checked';
	value mut_t69_2___9_ 0='Unchecked' 1='Checked';
	value mut_k70_2___0_ 0='Unchecked' 1='Checked';
	value mut_k70_2___1_ 0='Unchecked' 1='Checked';
	value mut_k70_2___2_ 0='Unchecked' 1='Checked';
	value mut_k70_2___3_ 0='Unchecked' 1='Checked';
	value mut_k70_2___4_ 0='Unchecked' 1='Checked';
	value mut_k70_2___9_ 0='Unchecked' 1='Checked';
	value mut_l74_2___0_ 0='Unchecked' 1='Checked';
	value mut_l74_2___1_ 0='Unchecked' 1='Checked';
	value mut_l74_2___2_ 0='Unchecked' 1='Checked';
	value mut_l74_2___9_ 0='Unchecked' 1='Checked';
	value mut_v75_2___0_ 0='Unchecked' 1='Checked';
	value mut_v75_2___1_ 0='Unchecked' 1='Checked';
	value mut_v75_2___2_ 0='Unchecked' 1='Checked';
	value mut_v75_2___3_ 0='Unchecked' 1='Checked';
	value mut_v75_2___4_ 0='Unchecked' 1='Checked';
	value mut_v75_2___5_ 0='Unchecked' 1='Checked';
	value mut_v75_2___6_ 0='Unchecked' 1='Checked';
	value mut_v75_2___9_ 0='Unchecked' 1='Checked';
	value mut_f77_2___0_ 0='Unchecked' 1='Checked';
	value mut_f77_2___1_ 0='Unchecked' 1='Checked';
	value mut_f77_2___9_ 0='Unchecked' 1='Checked';
	value mut_v90_2___0_ 0='Unchecked' 1='Checked';
	value mut_v90_2___1_ 0='Unchecked' 1='Checked';
	value mut_v90_2___9_ 0='Unchecked' 1='Checked';
	value mut_a98_2___0_ 0='Unchecked' 1='Checked';
	value mut_a98_2___1_ 0='Unchecked' 1='Checked';
	value mut_a98_2___2_ 0='Unchecked' 1='Checked';
	value mut_a98_2___9_ 0='Unchecked' 1='Checked';
	value mut_l100_2___0_ 0='Unchecked' 1='Checked';
	value mut_l100_2___1_ 0='Unchecked' 1='Checked';
	value mut_l100_2___9_ 0='Unchecked' 1='Checked';
	value mut_k101_2___0_ 0='Unchecked' 1='Checked';
	value mut_k101_2___1_ 0='Unchecked' 1='Checked';
	value mut_k101_2___2_ 0='Unchecked' 1='Checked';
	value mut_k101_2___3_ 0='Unchecked' 1='Checked';
	value mut_k101_2___4_ 0='Unchecked' 1='Checked';
	value mut_k101_2___5_ 0='Unchecked' 1='Checked';
	value mut_k101_2___6_ 0='Unchecked' 1='Checked';
	value mut_k101_2___9_ 0='Unchecked' 1='Checked';
	value mut_k103_2___0_ 0='Unchecked' 1='Checked';
	value mut_k103_2___1_ 0='Unchecked' 1='Checked';
	value mut_k103_2___2_ 0='Unchecked' 1='Checked';
	value mut_k103_2___3_ 0='Unchecked' 1='Checked';
	value mut_k103_2___4_ 0='Unchecked' 1='Checked';
	value mut_k103_2___5_ 0='Unchecked' 1='Checked';
	value mut_k103_2___6_ 0='Unchecked' 1='Checked';
	value mut_k103_2___7_ 0='Unchecked' 1='Checked';
	value mut_k103_2___9_ 0='Unchecked' 1='Checked';
	value mut_v106_2___0_ 0='Unchecked' 1='Checked';
	value mut_v106_2___1_ 0='Unchecked' 1='Checked';
	value mut_v106_2___2_ 0='Unchecked' 1='Checked';
	value mut_v106_2___3_ 0='Unchecked' 1='Checked';
	value mut_v106_2___4_ 0='Unchecked' 1='Checked';
	value mut_v106_2___9_ 0='Unchecked' 1='Checked';
	value mut_v108_2___0_ 0='Unchecked' 1='Checked';
	value mut_v108_2___1_ 0='Unchecked' 1='Checked';
	value mut_v108_2___9_ 0='Unchecked' 1='Checked';
	value mut_g109_2___0_ 0='Unchecked' 1='Checked';
	value mut_g109_2___1_ 0='Unchecked' 1='Checked';
	value mut_g109_2___2_ 0='Unchecked' 1='Checked';
	value mut_g109_2___9_ 0='Unchecked' 1='Checked';
	value mut_y115_2___0_ 0='Unchecked' 1='Checked';
	value mut_y115_2___1_ 0='Unchecked' 1='Checked';
	value mut_y115_2___2_ 0='Unchecked' 1='Checked';
	value mut_y115_2___9_ 0='Unchecked' 1='Checked';
	value mut_f116_2___0_ 0='Unchecked' 1='Checked';
	value mut_f116_2___1_ 0='Unchecked' 1='Checked';
	value mut_f116_2___9_ 0='Unchecked' 1='Checked';
	value mut_118_2___0_ 0='Unchecked' 1='Checked';
	value mut_118_2___1_ 0='Unchecked' 1='Checked';
	value mut_118_2___9_ 0='Unchecked' 1='Checked';
	value mut_e138_2___0_ 0='Unchecked' 1='Checked';
	value mut_e138_2___1_ 0='Unchecked' 1='Checked';
	value mut_e138_2___2_ 0='Unchecked' 1='Checked';
	value mut_e138_2___3_ 0='Unchecked' 1='Checked';
	value mut_e138_2___4_ 0='Unchecked' 1='Checked';
	value mut_e138_2___9_ 0='Unchecked' 1='Checked';
	value mut_q151_2___0_ 0='Unchecked' 1='Checked';
	value mut_q151_2___1_ 0='Unchecked' 1='Checked';
	value mut_q151_2___2_ 0='Unchecked' 1='Checked';
	value mut_q151_2___9_ 0='Unchecked' 1='Checked';
	value mut_v179_2___0_ 0='Unchecked' 1='Checked';
	value mut_v179_2___1_ 0='Unchecked' 1='Checked';
	value mut_v179_2___2_ 0='Unchecked' 1='Checked';
	value mut_v179_2___3_ 0='Unchecked' 1='Checked';
	value mut_v179_2___4_ 0='Unchecked' 1='Checked';
	value mut_v179_2___5_ 0='Unchecked' 1='Checked';
	value mut_v179_2___6_ 0='Unchecked' 1='Checked';
	value mut_v179_2___9_ 0='Unchecked' 1='Checked';
	value mut_y181_2___0_ 0='Unchecked' 1='Checked';
	value mut_y181_2___1_ 0='Unchecked' 1='Checked';
	value mut_y181_2___2_ 0='Unchecked' 1='Checked';
	value mut_y181_2___3_ 0='Unchecked' 1='Checked';
	value mut_y181_2___4_ 0='Unchecked' 1='Checked';
	value mut_y181_2___9_ 0='Unchecked' 1='Checked';
	value mut_m184_2___0_ 0='Unchecked' 1='Checked';
	value mut_m184_2___1_ 0='Unchecked' 1='Checked';
	value mut_m184_2___2_ 0='Unchecked' 1='Checked';
	value mut_m184_2___3_ 0='Unchecked' 1='Checked';
	value mut_m184_2___9_ 0='Unchecked' 1='Checked';
	value mut_y188_2___0_ 0='Unchecked' 1='Checked';
	value mut_y188_2___1_ 0='Unchecked' 1='Checked';
	value mut_y188_2___2_ 0='Unchecked' 1='Checked';
	value mut_y188_2___3_ 0='Unchecked' 1='Checked';
	value mut_y188_2___4_ 0='Unchecked' 1='Checked';
	value mut_y188_2___5_ 0='Unchecked' 1='Checked';
	value mut_y188_2___9_ 0='Unchecked' 1='Checked';
	value mut_g190_2___0_ 0='Unchecked' 1='Checked';
	value mut_g190_2___1_ 0='Unchecked' 1='Checked';
	value mut_g190_2___2_ 0='Unchecked' 1='Checked';
	value mut_g190_2___3_ 0='Unchecked' 1='Checked';
	value mut_g190_2___4_ 0='Unchecked' 1='Checked';
	value mut_g190_2___5_ 0='Unchecked' 1='Checked';
	value mut_g190_2___6_ 0='Unchecked' 1='Checked';
	value mut_g190_2___7_ 0='Unchecked' 1='Checked';
	value mut_g190_2___8_ 0='Unchecked' 1='Checked';
	value mut_g190_2___9_ 0='Unchecked' 1='Checked';
	value mut_l210_2___0_ 0='Unchecked' 1='Checked';
	value mut_l210_2___1_ 0='Unchecked' 1='Checked';
	value mut_l210_2___2_ 0='Unchecked' 1='Checked';
	value mut_l210_2___3_ 0='Unchecked' 1='Checked';
	value mut_l210_2___9_ 0='Unchecked' 1='Checked';
	value mut_t215_2___0_ 0='Unchecked' 1='Checked';
	value mut_t215_2___1_ 0='Unchecked' 1='Checked';
	value mut_t215_2___2_ 0='Unchecked' 1='Checked';
	value mut_t215_2___3_ 0='Unchecked' 1='Checked';
	value mut_t215_2___4_ 0='Unchecked' 1='Checked';
	value mut_t215_2___5_ 0='Unchecked' 1='Checked';
	value mut_t215_2___6_ 0='Unchecked' 1='Checked';
	value mut_t215_2___7_ 0='Unchecked' 1='Checked';
	value mut_t215_2___8_ 0='Unchecked' 1='Checked';
	value mut_t215_2___9_ 0='Unchecked' 1='Checked';
	value mut_k219_2___0_ 0='Unchecked' 1='Checked';
	value mut_k219_2___1_ 0='Unchecked' 1='Checked';
	value mut_k219_2___2_ 0='Unchecked' 1='Checked';
	value mut_k219_2___3_ 0='Unchecked' 1='Checked';
	value mut_k219_2___4_ 0='Unchecked' 1='Checked';
	value mut_k219_2___5_ 0='Unchecked' 1='Checked';
	value mut_k219_2___6_ 0='Unchecked' 1='Checked';
	value mut_k219_2___7_ 0='Unchecked' 1='Checked';
	value mut_k219_2___9_ 0='Unchecked' 1='Checked';
	value mut_h221_2___0_ 0='Unchecked' 1='Checked';
	value mut_h221_2___1_ 0='Unchecked' 1='Checked';
	value mut_h221_2___9_ 0='Unchecked' 1='Checked';
	value mut_p225_2___0_ 0='Unchecked' 1='Checked';
	value mut_p225_2___1_ 0='Unchecked' 1='Checked';
	value mut_p225_2___9_ 0='Unchecked' 1='Checked';
	value mut_f227_2___0_ 0='Unchecked' 1='Checked';
	value mut_f227_2___1_ 0='Unchecked' 1='Checked';
	value mut_f227_2___2_ 0='Unchecked' 1='Checked';
	value mut_f227_2___9_ 0='Unchecked' 1='Checked';
	value mut_m230_2___0_ 0='Unchecked' 1='Checked';
	value mut_m230_2___1_ 0='Unchecked' 1='Checked';
	value mut_m230_2___9_ 0='Unchecked' 1='Checked';
	value mut_234_2___0_ 0='Unchecked' 1='Checked';
	value mut_234_2___1_ 0='Unchecked' 1='Checked';
	value mut_234_2___9_ 0='Unchecked' 1='Checked';
	value mut_236_2___0_ 0='Unchecked' 1='Checked';
	value mut_236_2___1_ 0='Unchecked' 1='Checked';
	value mut_236_2___9_ 0='Unchecked' 1='Checked';
	value mut_238_2___0_ 0='Unchecked' 1='Checked';
	value mut_238_2___1_ 0='Unchecked' 1='Checked';
	value mut_238_2___2_ 0='Unchecked' 1='Checked';
	value mut_238_2___3_ 0='Unchecked' 1='Checked';
	value mut_238_2___9_ 0='Unchecked' 1='Checked';
	value mut_y318_2___0_ 0='Unchecked' 1='Checked';
	value mut_y318_2___1_ 0='Unchecked' 1='Checked';
	value mut_y318_2___9_ 0='Unchecked' 1='Checked';
	value mut_333_2___0_ 0='Unchecked' 1='Checked';
	value mut_333_2___1_ 0='Unchecked' 1='Checked';
	value mut_333_2___2_ 0='Unchecked' 1='Checked';
	value mut_333_2___9_ 0='Unchecked' 1='Checked';
	value mut_n348_2___0_ 0='Unchecked' 1='Checked';
	value mut_n348_2___1_ 0='Unchecked' 1='Checked';
	value mut_n348_2___9_ 0='Unchecked' 1='Checked';
	value mut_pi_major_2_ 1='Yes' 2='No';
	value mut_pi_minor_2_ 1='Yes' 2='No';
	value mut_l10_2___0_ 0='Unchecked' 1='Checked';
	value mut_l10_2___1_ 0='Unchecked' 1='Checked';
	value mut_l10_2___2_ 0='Unchecked' 1='Checked';
	value mut_l10_2___3_ 0='Unchecked' 1='Checked';
	value mut_l10_2___4_ 0='Unchecked' 1='Checked';
	value mut_l10_2___5_ 0='Unchecked' 1='Checked';
	value mut_l10_2___9_ 0='Unchecked' 1='Checked';
	value mut_v11_2___0_ 0='Unchecked' 1='Checked';
	value mut_v11_2___1_ 0='Unchecked' 1='Checked';
	value mut_v11_2___9_ 0='Unchecked' 1='Checked';
	value mut_13_2___0_ 0='Unchecked' 1='Checked';
	value mut_13_2___1_ 0='Unchecked' 1='Checked';
	value mut_13_2___9_ 0='Unchecked' 1='Checked';
	value mut_g16_2___0_ 0='Unchecked' 1='Checked';
	value mut_g16_2___1_ 0='Unchecked' 1='Checked';
	value mut_g16_2___9_ 0='Unchecked' 1='Checked';
	value mut_k20_2___0_ 0='Unchecked' 1='Checked';
	value mut_k20_2___1_ 0='Unchecked' 1='Checked';
	value mut_k20_2___2_ 0='Unchecked' 1='Checked';
	value mut_k20_2___3_ 0='Unchecked' 1='Checked';
	value mut_k20_2___4_ 0='Unchecked' 1='Checked';
	value mut_k20_2___5_ 0='Unchecked' 1='Checked';
	value mut_k20_2___9_ 0='Unchecked' 1='Checked';
	value mut_23_2___0_ 0='Unchecked' 1='Checked';
	value mut_23_2___1_ 0='Unchecked' 1='Checked';
	value mut_23_2___9_ 0='Unchecked' 1='Checked';
	value mut_l24_2___0_ 0='Unchecked' 1='Checked';
	value mut_l24_2___1_ 0='Unchecked' 1='Checked';
	value mut_l24_2___2_ 0='Unchecked' 1='Checked';
	value mut_l24_2___9_ 0='Unchecked' 1='Checked';
	value mut_d30_2___0_ 0='Unchecked' 1='Checked';
	value mut_d30_2___1_ 0='Unchecked' 1='Checked';
	value mut_d30_2___9_ 0='Unchecked' 1='Checked';
	value mut_v32_2___0_ 0='Unchecked' 1='Checked';
	value mut_v32_2___1_ 0='Unchecked' 1='Checked';
	value mut_v32_2___9_ 0='Unchecked' 1='Checked';
	value mut_l33_2___0_ 0='Unchecked' 1='Checked';
	value mut_l33_2___1_ 0='Unchecked' 1='Checked';
	value mut_l33_2___2_ 0='Unchecked' 1='Checked';
	value mut_l33_2___3_ 0='Unchecked' 1='Checked';
	value mut_l33_2___9_ 0='Unchecked' 1='Checked';
	value mut_35_2___0_ 0='Unchecked' 1='Checked';
	value mut_35_2___1_ 0='Unchecked' 1='Checked';
	value mut_35_2___9_ 0='Unchecked' 1='Checked';
	value mut_m36_2___0_ 0='Unchecked' 1='Checked';
	value mut_m36_2___1_ 0='Unchecked' 1='Checked';
	value mut_m36_2___2_ 0='Unchecked' 1='Checked';
	value mut_m36_2___3_ 0='Unchecked' 1='Checked';
	value mut_m36_2___4_ 0='Unchecked' 1='Checked';
	value mut_m36_2___9_ 0='Unchecked' 1='Checked';
	value mut_k43_2___0_ 0='Unchecked' 1='Checked';
	value mut_k43_2___1_ 0='Unchecked' 1='Checked';
	value mut_k43_2___9_ 0='Unchecked' 1='Checked';
	value mut_m46_2___0_ 0='Unchecked' 1='Checked';
	value mut_m46_2___1_ 0='Unchecked' 1='Checked';
	value mut_m46_2___2_ 0='Unchecked' 1='Checked';
	value mut_m46_2___3_ 0='Unchecked' 1='Checked';
	value mut_m46_2___9_ 0='Unchecked' 1='Checked';
	value mut_i47_2___0_ 0='Unchecked' 1='Checked';
	value mut_i47_2___1_ 0='Unchecked' 1='Checked';
	value mut_i47_2___2_ 0='Unchecked' 1='Checked';
	value mut_i47_2___9_ 0='Unchecked' 1='Checked';
	value mut_g48_2___0_ 0='Unchecked' 1='Checked';
	value mut_g48_2___1_ 0='Unchecked' 1='Checked';
	value mut_g48_2___2_ 0='Unchecked' 1='Checked';
	value mut_g48_2___3_ 0='Unchecked' 1='Checked';
	value mut_g48_2___4_ 0='Unchecked' 1='Checked';
	value mut_g48_2___5_ 0='Unchecked' 1='Checked';
	value mut_g48_2___6_ 0='Unchecked' 1='Checked';
	value mut_g48_2___9_ 0='Unchecked' 1='Checked';
	value mut_i50_2___0_ 0='Unchecked' 1='Checked';
	value mut_i50_2___1_ 0='Unchecked' 1='Checked';
	value mut_i50_2___2_ 0='Unchecked' 1='Checked';
	value mut_i50_2___9_ 0='Unchecked' 1='Checked';
	value mut_f53_2___0_ 0='Unchecked' 1='Checked';
	value mut_f53_2___1_ 0='Unchecked' 1='Checked';
	value mut_f53_2___2_ 0='Unchecked' 1='Checked';
	value mut_f53_2___9_ 0='Unchecked' 1='Checked';
	value mut_i54_2___0_ 0='Unchecked' 1='Checked';
	value mut_i54_2___1_ 0='Unchecked' 1='Checked';
	value mut_i54_2___2_ 0='Unchecked' 1='Checked';
	value mut_i54_2___3_ 0='Unchecked' 1='Checked';
	value mut_i54_2___4_ 0='Unchecked' 1='Checked';
	value mut_i54_2___5_ 0='Unchecked' 1='Checked';
	value mut_i54_2___6_ 0='Unchecked' 1='Checked';
	value mut_i54_2___9_ 0='Unchecked' 1='Checked';
	value mut_q58_2___0_ 0='Unchecked' 1='Checked';
	value mut_q58_2___1_ 0='Unchecked' 1='Checked';
	value mut_q58_2___9_ 0='Unchecked' 1='Checked';
	value mut_d60_2___0_ 0='Unchecked' 1='Checked';
	value mut_d60_2___1_ 0='Unchecked' 1='Checked';
	value mut_d60_2___9_ 0='Unchecked' 1='Checked';
	value mut_i62_2___0_ 0='Unchecked' 1='Checked';
	value mut_i62_2___1_ 0='Unchecked' 1='Checked';
	value mut_i62_2___9_ 0='Unchecked' 1='Checked';
	value mut_l63_2___0_ 0='Unchecked' 1='Checked';
	value mut_l63_2___1_ 0='Unchecked' 1='Checked';
	value mut_l63_2___9_ 0='Unchecked' 1='Checked';
	value mut_a71_2___0_ 0='Unchecked' 1='Checked';
	value mut_a71_2___1_ 0='Unchecked' 1='Checked';
	value mut_a71_2___2_ 0='Unchecked' 1='Checked';
	value mut_a71_2___3_ 0='Unchecked' 1='Checked';
	value mut_a71_2___4_ 0='Unchecked' 1='Checked';
	value mut_a71_2___9_ 0='Unchecked' 1='Checked';
	value mut_g73_2___0_ 0='Unchecked' 1='Checked';
	value mut_g73_2___1_ 0='Unchecked' 1='Checked';
	value mut_g73_2___2_ 0='Unchecked' 1='Checked';
	value mut_g73_2___3_ 0='Unchecked' 1='Checked';
	value mut_g73_2___4_ 0='Unchecked' 1='Checked';
	value mut_g73_2___9_ 0='Unchecked' 1='Checked';
	value mut_t74_2___0_ 0='Unchecked' 1='Checked';
	value mut_t74_2___1_ 0='Unchecked' 1='Checked';
	value mut_t74_2___2_ 0='Unchecked' 1='Checked';
	value mut_t74_2___9_ 0='Unchecked' 1='Checked';
	value mut_l76_2___0_ 0='Unchecked' 1='Checked';
	value mut_l76_2___1_ 0='Unchecked' 1='Checked';
	value mut_l76_2___9_ 0='Unchecked' 1='Checked';
	value mut_v77_2___0_ 0='Unchecked' 1='Checked';
	value mut_v77_2___1_ 0='Unchecked' 1='Checked';
	value mut_v77_2___9_ 0='Unchecked' 1='Checked';
	value mut_v82_2___0_ 0='Unchecked' 1='Checked';
	value mut_v82_2___1_ 0='Unchecked' 1='Checked';
	value mut_v82_2___2_ 0='Unchecked' 1='Checked';
	value mut_v82_2___3_ 0='Unchecked' 1='Checked';
	value mut_v82_2___4_ 0='Unchecked' 1='Checked';
	value mut_v82_2___5_ 0='Unchecked' 1='Checked';
	value mut_v82_2___6_ 0='Unchecked' 1='Checked';
	value mut_v82_2___7_ 0='Unchecked' 1='Checked';
	value mut_v82_2___8_ 0='Unchecked' 1='Checked';
	value mut_v82_2___9_ 0='Unchecked' 1='Checked';
	value mut_n83_2___0_ 0='Unchecked' 1='Checked';
	value mut_n83_2___1_ 0='Unchecked' 1='Checked';
	value mut_n83_2___9_ 0='Unchecked' 1='Checked';
	value mut_i84_2___0_ 0='Unchecked' 1='Checked';
	value mut_i84_2___1_ 0='Unchecked' 1='Checked';
	value mut_i84_2___2_ 0='Unchecked' 1='Checked';
	value mut_i84_2___3_ 0='Unchecked' 1='Checked';
	value mut_i84_2___9_ 0='Unchecked' 1='Checked';
	value mut_i85_2___0_ 0='Unchecked' 1='Checked';
	value mut_i85_2___1_ 0='Unchecked' 1='Checked';
	value mut_i85_2___9_ 0='Unchecked' 1='Checked';
	value mut_n88_2___0_ 0='Unchecked' 1='Checked';
	value mut_n88_2___1_ 0='Unchecked' 1='Checked';
	value mut_n88_2___2_ 0='Unchecked' 1='Checked';
	value mut_n88_2___3_ 0='Unchecked' 1='Checked';
	value mut_n88_2___4_ 0='Unchecked' 1='Checked';
	value mut_n88_2___9_ 0='Unchecked' 1='Checked';
	value mut_l89_2___0_ 0='Unchecked' 1='Checked';
	value mut_l89_2___1_ 0='Unchecked' 1='Checked';
	value mut_l89_2___2_ 0='Unchecked' 1='Checked';
	value mut_l89_2___3_ 0='Unchecked' 1='Checked';
	value mut_l89_2___4_ 0='Unchecked' 1='Checked';
	value mut_l89_2___9_ 0='Unchecked' 1='Checked';
	value mut_l90_2___0_ 0='Unchecked' 1='Checked';
	value mut_l90_2___1_ 0='Unchecked' 1='Checked';
	value mut_l90_2___9_ 0='Unchecked' 1='Checked';
	value mut_i93_2___0_ 0='Unchecked' 1='Checked';
	value mut_i93_2___1_ 0='Unchecked' 1='Checked';
	value mut_i93_2___2_ 0='Unchecked' 1='Checked';
	value mut_i93_2___9_ 0='Unchecked' 1='Checked';
	value resistance_data_2_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format resist_3tc_2 resist_3tc_2_.;
	format resist_abc_2 resist_abc_2_.;
	format resist_azt_2 resist_azt_2_.;
	format resist_d4t_2 resist_d4t_2_.;
	format resist_ddi_2 resist_ddi_2_.;
	format resist_dlv_2 resist_dlv_2_.;
	format resist_efv_2 resist_efv_2_.;
	format resist_etr_2 resist_etr_2_.;
	format resist_ftc_2 resist_ftc_2_.;
	format resist_npv_2 resist_npv_2_.;
	format resist_rpv_2 resist_rpv_2_.;
	format resist_tdf_2 resist_tdf_2_.;
	format mut_nrti_2 mut_nrti_2_.;
	format mut_nnrti_2 mut_nnrti_2_.;
	format mut_m41_2___0 mut_m41_2___0_.;
	format mut_m41_2___1 mut_m41_2___1_.;
	format mut_m41_2___9 mut_m41_2___9_.;
	format mut_44_2___0 mut_44_2___0_.;
	format mut_44_2___1 mut_44_2___1_.;
	format mut_44_2___2 mut_44_2___2_.;
	format mut_44_2___9 mut_44_2___9_.;
	format mut_a62_2___0 mut_a62_2___0_.;
	format mut_a62_2___1 mut_a62_2___1_.;
	format mut_a62_2___9 mut_a62_2___9_.;
	format mut_k65_2___0 mut_k65_2___0_.;
	format mut_k65_2___1 mut_k65_2___1_.;
	format mut_k65_2___2 mut_k65_2___2_.;
	format mut_k65_2___9 mut_k65_2___9_.;
	format mut_d67_2___0 mut_d67_2___0_.;
	format mut_d67_2___1 mut_d67_2___1_.;
	format mut_d67_2___2 mut_d67_2___2_.;
	format mut_d67_2___3 mut_d67_2___3_.;
	format mut_d67_2___4 mut_d67_2___4_.;
	format mut_d67_2___9 mut_d67_2___9_.;
	format mut_t69_2___0 mut_t69_2___0_.;
	format mut_t69_2___1 mut_t69_2___1_.;
	format mut_t69_2___2 mut_t69_2___2_.;
	format mut_t69_2___3 mut_t69_2___3_.;
	format mut_t69_2___4 mut_t69_2___4_.;
	format mut_t69_2___5 mut_t69_2___5_.;
	format mut_t69_2___6 mut_t69_2___6_.;
	format mut_t69_2___7 mut_t69_2___7_.;
	format mut_t69_2___9 mut_t69_2___9_.;
	format mut_k70_2___0 mut_k70_2___0_.;
	format mut_k70_2___1 mut_k70_2___1_.;
	format mut_k70_2___2 mut_k70_2___2_.;
	format mut_k70_2___3 mut_k70_2___3_.;
	format mut_k70_2___4 mut_k70_2___4_.;
	format mut_k70_2___9 mut_k70_2___9_.;
	format mut_l74_2___0 mut_l74_2___0_.;
	format mut_l74_2___1 mut_l74_2___1_.;
	format mut_l74_2___2 mut_l74_2___2_.;
	format mut_l74_2___9 mut_l74_2___9_.;
	format mut_v75_2___0 mut_v75_2___0_.;
	format mut_v75_2___1 mut_v75_2___1_.;
	format mut_v75_2___2 mut_v75_2___2_.;
	format mut_v75_2___3 mut_v75_2___3_.;
	format mut_v75_2___4 mut_v75_2___4_.;
	format mut_v75_2___5 mut_v75_2___5_.;
	format mut_v75_2___6 mut_v75_2___6_.;
	format mut_v75_2___9 mut_v75_2___9_.;
	format mut_f77_2___0 mut_f77_2___0_.;
	format mut_f77_2___1 mut_f77_2___1_.;
	format mut_f77_2___9 mut_f77_2___9_.;
	format mut_v90_2___0 mut_v90_2___0_.;
	format mut_v90_2___1 mut_v90_2___1_.;
	format mut_v90_2___9 mut_v90_2___9_.;
	format mut_a98_2___0 mut_a98_2___0_.;
	format mut_a98_2___1 mut_a98_2___1_.;
	format mut_a98_2___2 mut_a98_2___2_.;
	format mut_a98_2___9 mut_a98_2___9_.;
	format mut_l100_2___0 mut_l100_2___0_.;
	format mut_l100_2___1 mut_l100_2___1_.;
	format mut_l100_2___9 mut_l100_2___9_.;
	format mut_k101_2___0 mut_k101_2___0_.;
	format mut_k101_2___1 mut_k101_2___1_.;
	format mut_k101_2___2 mut_k101_2___2_.;
	format mut_k101_2___3 mut_k101_2___3_.;
	format mut_k101_2___4 mut_k101_2___4_.;
	format mut_k101_2___5 mut_k101_2___5_.;
	format mut_k101_2___6 mut_k101_2___6_.;
	format mut_k101_2___9 mut_k101_2___9_.;
	format mut_k103_2___0 mut_k103_2___0_.;
	format mut_k103_2___1 mut_k103_2___1_.;
	format mut_k103_2___2 mut_k103_2___2_.;
	format mut_k103_2___3 mut_k103_2___3_.;
	format mut_k103_2___4 mut_k103_2___4_.;
	format mut_k103_2___5 mut_k103_2___5_.;
	format mut_k103_2___6 mut_k103_2___6_.;
	format mut_k103_2___7 mut_k103_2___7_.;
	format mut_k103_2___9 mut_k103_2___9_.;
	format mut_v106_2___0 mut_v106_2___0_.;
	format mut_v106_2___1 mut_v106_2___1_.;
	format mut_v106_2___2 mut_v106_2___2_.;
	format mut_v106_2___3 mut_v106_2___3_.;
	format mut_v106_2___4 mut_v106_2___4_.;
	format mut_v106_2___9 mut_v106_2___9_.;
	format mut_v108_2___0 mut_v108_2___0_.;
	format mut_v108_2___1 mut_v108_2___1_.;
	format mut_v108_2___9 mut_v108_2___9_.;
	format mut_g109_2___0 mut_g109_2___0_.;
	format mut_g109_2___1 mut_g109_2___1_.;
	format mut_g109_2___2 mut_g109_2___2_.;
	format mut_g109_2___9 mut_g109_2___9_.;
	format mut_y115_2___0 mut_y115_2___0_.;
	format mut_y115_2___1 mut_y115_2___1_.;
	format mut_y115_2___2 mut_y115_2___2_.;
	format mut_y115_2___9 mut_y115_2___9_.;
	format mut_f116_2___0 mut_f116_2___0_.;
	format mut_f116_2___1 mut_f116_2___1_.;
	format mut_f116_2___9 mut_f116_2___9_.;
	format mut_118_2___0 mut_118_2___0_.;
	format mut_118_2___1 mut_118_2___1_.;
	format mut_118_2___9 mut_118_2___9_.;
	format mut_e138_2___0 mut_e138_2___0_.;
	format mut_e138_2___1 mut_e138_2___1_.;
	format mut_e138_2___2 mut_e138_2___2_.;
	format mut_e138_2___3 mut_e138_2___3_.;
	format mut_e138_2___4 mut_e138_2___4_.;
	format mut_e138_2___9 mut_e138_2___9_.;
	format mut_q151_2___0 mut_q151_2___0_.;
	format mut_q151_2___1 mut_q151_2___1_.;
	format mut_q151_2___2 mut_q151_2___2_.;
	format mut_q151_2___9 mut_q151_2___9_.;
	format mut_v179_2___0 mut_v179_2___0_.;
	format mut_v179_2___1 mut_v179_2___1_.;
	format mut_v179_2___2 mut_v179_2___2_.;
	format mut_v179_2___3 mut_v179_2___3_.;
	format mut_v179_2___4 mut_v179_2___4_.;
	format mut_v179_2___5 mut_v179_2___5_.;
	format mut_v179_2___6 mut_v179_2___6_.;
	format mut_v179_2___9 mut_v179_2___9_.;
	format mut_y181_2___0 mut_y181_2___0_.;
	format mut_y181_2___1 mut_y181_2___1_.;
	format mut_y181_2___2 mut_y181_2___2_.;
	format mut_y181_2___3 mut_y181_2___3_.;
	format mut_y181_2___4 mut_y181_2___4_.;
	format mut_y181_2___9 mut_y181_2___9_.;
	format mut_m184_2___0 mut_m184_2___0_.;
	format mut_m184_2___1 mut_m184_2___1_.;
	format mut_m184_2___2 mut_m184_2___2_.;
	format mut_m184_2___3 mut_m184_2___3_.;
	format mut_m184_2___9 mut_m184_2___9_.;
	format mut_y188_2___0 mut_y188_2___0_.;
	format mut_y188_2___1 mut_y188_2___1_.;
	format mut_y188_2___2 mut_y188_2___2_.;
	format mut_y188_2___3 mut_y188_2___3_.;
	format mut_y188_2___4 mut_y188_2___4_.;
	format mut_y188_2___5 mut_y188_2___5_.;
	format mut_y188_2___9 mut_y188_2___9_.;
	format mut_g190_2___0 mut_g190_2___0_.;
	format mut_g190_2___1 mut_g190_2___1_.;
	format mut_g190_2___2 mut_g190_2___2_.;
	format mut_g190_2___3 mut_g190_2___3_.;
	format mut_g190_2___4 mut_g190_2___4_.;
	format mut_g190_2___5 mut_g190_2___5_.;
	format mut_g190_2___6 mut_g190_2___6_.;
	format mut_g190_2___7 mut_g190_2___7_.;
	format mut_g190_2___8 mut_g190_2___8_.;
	format mut_g190_2___9 mut_g190_2___9_.;
	format mut_l210_2___0 mut_l210_2___0_.;
	format mut_l210_2___1 mut_l210_2___1_.;
	format mut_l210_2___2 mut_l210_2___2_.;
	format mut_l210_2___3 mut_l210_2___3_.;
	format mut_l210_2___9 mut_l210_2___9_.;
	format mut_t215_2___0 mut_t215_2___0_.;
	format mut_t215_2___1 mut_t215_2___1_.;
	format mut_t215_2___2 mut_t215_2___2_.;
	format mut_t215_2___3 mut_t215_2___3_.;
	format mut_t215_2___4 mut_t215_2___4_.;
	format mut_t215_2___5 mut_t215_2___5_.;
	format mut_t215_2___6 mut_t215_2___6_.;
	format mut_t215_2___7 mut_t215_2___7_.;
	format mut_t215_2___8 mut_t215_2___8_.;
	format mut_t215_2___9 mut_t215_2___9_.;
	format mut_k219_2___0 mut_k219_2___0_.;
	format mut_k219_2___1 mut_k219_2___1_.;
	format mut_k219_2___2 mut_k219_2___2_.;
	format mut_k219_2___3 mut_k219_2___3_.;
	format mut_k219_2___4 mut_k219_2___4_.;
	format mut_k219_2___5 mut_k219_2___5_.;
	format mut_k219_2___6 mut_k219_2___6_.;
	format mut_k219_2___7 mut_k219_2___7_.;
	format mut_k219_2___9 mut_k219_2___9_.;
	format mut_h221_2___0 mut_h221_2___0_.;
	format mut_h221_2___1 mut_h221_2___1_.;
	format mut_h221_2___9 mut_h221_2___9_.;
	format mut_p225_2___0 mut_p225_2___0_.;
	format mut_p225_2___1 mut_p225_2___1_.;
	format mut_p225_2___9 mut_p225_2___9_.;
	format mut_f227_2___0 mut_f227_2___0_.;
	format mut_f227_2___1 mut_f227_2___1_.;
	format mut_f227_2___2 mut_f227_2___2_.;
	format mut_f227_2___9 mut_f227_2___9_.;
	format mut_m230_2___0 mut_m230_2___0_.;
	format mut_m230_2___1 mut_m230_2___1_.;
	format mut_m230_2___9 mut_m230_2___9_.;
	format mut_234_2___0 mut_234_2___0_.;
	format mut_234_2___1 mut_234_2___1_.;
	format mut_234_2___9 mut_234_2___9_.;
	format mut_236_2___0 mut_236_2___0_.;
	format mut_236_2___1 mut_236_2___1_.;
	format mut_236_2___9 mut_236_2___9_.;
	format mut_238_2___0 mut_238_2___0_.;
	format mut_238_2___1 mut_238_2___1_.;
	format mut_238_2___2 mut_238_2___2_.;
	format mut_238_2___3 mut_238_2___3_.;
	format mut_238_2___9 mut_238_2___9_.;
	format mut_y318_2___0 mut_y318_2___0_.;
	format mut_y318_2___1 mut_y318_2___1_.;
	format mut_y318_2___9 mut_y318_2___9_.;
	format mut_333_2___0 mut_333_2___0_.;
	format mut_333_2___1 mut_333_2___1_.;
	format mut_333_2___2 mut_333_2___2_.;
	format mut_333_2___9 mut_333_2___9_.;
	format mut_n348_2___0 mut_n348_2___0_.;
	format mut_n348_2___1 mut_n348_2___1_.;
	format mut_n348_2___9 mut_n348_2___9_.;
	format mut_pi_major_2 mut_pi_major_2_.;
	format mut_pi_minor_2 mut_pi_minor_2_.;
	format mut_l10_2___0 mut_l10_2___0_.;
	format mut_l10_2___1 mut_l10_2___1_.;
	format mut_l10_2___2 mut_l10_2___2_.;
	format mut_l10_2___3 mut_l10_2___3_.;
	format mut_l10_2___4 mut_l10_2___4_.;
	format mut_l10_2___5 mut_l10_2___5_.;
	format mut_l10_2___9 mut_l10_2___9_.;
	format mut_v11_2___0 mut_v11_2___0_.;
	format mut_v11_2___1 mut_v11_2___1_.;
	format mut_v11_2___9 mut_v11_2___9_.;
	format mut_13_2___0 mut_13_2___0_.;
	format mut_13_2___1 mut_13_2___1_.;
	format mut_13_2___9 mut_13_2___9_.;
	format mut_g16_2___0 mut_g16_2___0_.;
	format mut_g16_2___1 mut_g16_2___1_.;
	format mut_g16_2___9 mut_g16_2___9_.;
	format mut_k20_2___0 mut_k20_2___0_.;
	format mut_k20_2___1 mut_k20_2___1_.;
	format mut_k20_2___2 mut_k20_2___2_.;
	format mut_k20_2___3 mut_k20_2___3_.;
	format mut_k20_2___4 mut_k20_2___4_.;
	format mut_k20_2___5 mut_k20_2___5_.;
	format mut_k20_2___9 mut_k20_2___9_.;
	format mut_23_2___0 mut_23_2___0_.;
	format mut_23_2___1 mut_23_2___1_.;
	format mut_23_2___9 mut_23_2___9_.;
	format mut_l24_2___0 mut_l24_2___0_.;
	format mut_l24_2___1 mut_l24_2___1_.;
	format mut_l24_2___2 mut_l24_2___2_.;
	format mut_l24_2___9 mut_l24_2___9_.;
	format mut_d30_2___0 mut_d30_2___0_.;
	format mut_d30_2___1 mut_d30_2___1_.;
	format mut_d30_2___9 mut_d30_2___9_.;
	format mut_v32_2___0 mut_v32_2___0_.;
	format mut_v32_2___1 mut_v32_2___1_.;
	format mut_v32_2___9 mut_v32_2___9_.;
	format mut_l33_2___0 mut_l33_2___0_.;
	format mut_l33_2___1 mut_l33_2___1_.;
	format mut_l33_2___2 mut_l33_2___2_.;
	format mut_l33_2___3 mut_l33_2___3_.;
	format mut_l33_2___9 mut_l33_2___9_.;
	format mut_35_2___0 mut_35_2___0_.;
	format mut_35_2___1 mut_35_2___1_.;
	format mut_35_2___9 mut_35_2___9_.;
	format mut_m36_2___0 mut_m36_2___0_.;
	format mut_m36_2___1 mut_m36_2___1_.;
	format mut_m36_2___2 mut_m36_2___2_.;
	format mut_m36_2___3 mut_m36_2___3_.;
	format mut_m36_2___4 mut_m36_2___4_.;
	format mut_m36_2___9 mut_m36_2___9_.;
	format mut_k43_2___0 mut_k43_2___0_.;
	format mut_k43_2___1 mut_k43_2___1_.;
	format mut_k43_2___9 mut_k43_2___9_.;
	format mut_m46_2___0 mut_m46_2___0_.;
	format mut_m46_2___1 mut_m46_2___1_.;
	format mut_m46_2___2 mut_m46_2___2_.;
	format mut_m46_2___3 mut_m46_2___3_.;
	format mut_m46_2___9 mut_m46_2___9_.;
	format mut_i47_2___0 mut_i47_2___0_.;
	format mut_i47_2___1 mut_i47_2___1_.;
	format mut_i47_2___2 mut_i47_2___2_.;
	format mut_i47_2___9 mut_i47_2___9_.;
	format mut_g48_2___0 mut_g48_2___0_.;
	format mut_g48_2___1 mut_g48_2___1_.;
	format mut_g48_2___2 mut_g48_2___2_.;
	format mut_g48_2___3 mut_g48_2___3_.;
	format mut_g48_2___4 mut_g48_2___4_.;
	format mut_g48_2___5 mut_g48_2___5_.;
	format mut_g48_2___6 mut_g48_2___6_.;
	format mut_g48_2___9 mut_g48_2___9_.;
	format mut_i50_2___0 mut_i50_2___0_.;
	format mut_i50_2___1 mut_i50_2___1_.;
	format mut_i50_2___2 mut_i50_2___2_.;
	format mut_i50_2___9 mut_i50_2___9_.;
	format mut_f53_2___0 mut_f53_2___0_.;
	format mut_f53_2___1 mut_f53_2___1_.;
	format mut_f53_2___2 mut_f53_2___2_.;
	format mut_f53_2___9 mut_f53_2___9_.;
	format mut_i54_2___0 mut_i54_2___0_.;
	format mut_i54_2___1 mut_i54_2___1_.;
	format mut_i54_2___2 mut_i54_2___2_.;
	format mut_i54_2___3 mut_i54_2___3_.;
	format mut_i54_2___4 mut_i54_2___4_.;
	format mut_i54_2___5 mut_i54_2___5_.;
	format mut_i54_2___6 mut_i54_2___6_.;
	format mut_i54_2___9 mut_i54_2___9_.;
	format mut_q58_2___0 mut_q58_2___0_.;
	format mut_q58_2___1 mut_q58_2___1_.;
	format mut_q58_2___9 mut_q58_2___9_.;
	format mut_d60_2___0 mut_d60_2___0_.;
	format mut_d60_2___1 mut_d60_2___1_.;
	format mut_d60_2___9 mut_d60_2___9_.;
	format mut_i62_2___0 mut_i62_2___0_.;
	format mut_i62_2___1 mut_i62_2___1_.;
	format mut_i62_2___9 mut_i62_2___9_.;
	format mut_l63_2___0 mut_l63_2___0_.;
	format mut_l63_2___1 mut_l63_2___1_.;
	format mut_l63_2___9 mut_l63_2___9_.;
	format mut_a71_2___0 mut_a71_2___0_.;
	format mut_a71_2___1 mut_a71_2___1_.;
	format mut_a71_2___2 mut_a71_2___2_.;
	format mut_a71_2___3 mut_a71_2___3_.;
	format mut_a71_2___4 mut_a71_2___4_.;
	format mut_a71_2___9 mut_a71_2___9_.;
	format mut_g73_2___0 mut_g73_2___0_.;
	format mut_g73_2___1 mut_g73_2___1_.;
	format mut_g73_2___2 mut_g73_2___2_.;
	format mut_g73_2___3 mut_g73_2___3_.;
	format mut_g73_2___4 mut_g73_2___4_.;
	format mut_g73_2___9 mut_g73_2___9_.;
	format mut_t74_2___0 mut_t74_2___0_.;
	format mut_t74_2___1 mut_t74_2___1_.;
	format mut_t74_2___2 mut_t74_2___2_.;
	format mut_t74_2___9 mut_t74_2___9_.;
	format mut_l76_2___0 mut_l76_2___0_.;
	format mut_l76_2___1 mut_l76_2___1_.;
	format mut_l76_2___9 mut_l76_2___9_.;
	format mut_v77_2___0 mut_v77_2___0_.;
	format mut_v77_2___1 mut_v77_2___1_.;
	format mut_v77_2___9 mut_v77_2___9_.;
	format mut_v82_2___0 mut_v82_2___0_.;
	format mut_v82_2___1 mut_v82_2___1_.;
	format mut_v82_2___2 mut_v82_2___2_.;
	format mut_v82_2___3 mut_v82_2___3_.;
	format mut_v82_2___4 mut_v82_2___4_.;
	format mut_v82_2___5 mut_v82_2___5_.;
	format mut_v82_2___6 mut_v82_2___6_.;
	format mut_v82_2___7 mut_v82_2___7_.;
	format mut_v82_2___8 mut_v82_2___8_.;
	format mut_v82_2___9 mut_v82_2___9_.;
	format mut_n83_2___0 mut_n83_2___0_.;
	format mut_n83_2___1 mut_n83_2___1_.;
	format mut_n83_2___9 mut_n83_2___9_.;
	format mut_i84_2___0 mut_i84_2___0_.;
	format mut_i84_2___1 mut_i84_2___1_.;
	format mut_i84_2___2 mut_i84_2___2_.;
	format mut_i84_2___3 mut_i84_2___3_.;
	format mut_i84_2___9 mut_i84_2___9_.;
	format mut_i85_2___0 mut_i85_2___0_.;
	format mut_i85_2___1 mut_i85_2___1_.;
	format mut_i85_2___9 mut_i85_2___9_.;
	format mut_n88_2___0 mut_n88_2___0_.;
	format mut_n88_2___1 mut_n88_2___1_.;
	format mut_n88_2___2 mut_n88_2___2_.;
	format mut_n88_2___3 mut_n88_2___3_.;
	format mut_n88_2___4 mut_n88_2___4_.;
	format mut_n88_2___9 mut_n88_2___9_.;
	format mut_l89_2___0 mut_l89_2___0_.;
	format mut_l89_2___1 mut_l89_2___1_.;
	format mut_l89_2___2 mut_l89_2___2_.;
	format mut_l89_2___3 mut_l89_2___3_.;
	format mut_l89_2___4 mut_l89_2___4_.;
	format mut_l89_2___9 mut_l89_2___9_.;
	format mut_l90_2___0 mut_l90_2___0_.;
	format mut_l90_2___1 mut_l90_2___1_.;
	format mut_l90_2___9 mut_l90_2___9_.;
	format mut_i93_2___0 mut_i93_2___0_.;
	format mut_i93_2___1 mut_i93_2___1_.;
	format mut_i93_2___2 mut_i93_2___2_.;
	format mut_i93_2___9 mut_i93_2___9_.;
	format resistance_data_2_complete resistance_data_2_complete_.;
	run;
proc print data=redcap;
var patient_id mut_nrti_2 mut_nnrti_2 mut_pi_major_2 mut_pi_minor_2;
run;

data brent.rest2;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;

	mut_nrti0=abs(mut_nrti_2-2);
	mut_nnrti0=abs(mut_nnrti_2-2);
	mut_pi_major0=abs(mut_pi_major_2-2);
	mut_pi_minor0=abs(mut_pi_minor_2-2);

	if idx then if sum(of mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0)>=1 then mut=1; 
		else if sum(of mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0)^=. then mut=0;
	drop mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0;
run;

proc freq data=brent.rest2(where=(idx=1)); 
tables mut;
run;


proc contents data=brent.rest2 short varnum; run;
