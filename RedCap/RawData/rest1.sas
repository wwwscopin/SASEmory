%let path=H:\SAS_Emory\RedCap;
libname brent "&path";

%macro removeOldFile(bye); %if %sysfunc(exist(&bye.)) %then %do; proc delete data=&bye.; run; %end; %mend removeOldFile; %removeOldFile(work.redcap); data REDCAP; %let _EFIERR_ = 0;
infile "&path.\csv\rest1.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=1 ; 
	informat patient_id $500. ;
	informat dt_enroll $500. ;
	informat vl_enroll $500. ;
	informat hpp_recent $500. ;
	informat vl_mccord $500. ;
	informat dt_mccord yymmdd10. ;
	informat genotype_done best32. ;
	informat dt_results_rec yymmdd10. ;
	informat genotype_comments $5000. ;
	informat resist_3tc best32. ;
	informat resist_abc best32. ;
	informat resist_azt best32. ;
	informat resist_d4t best32. ;
	informat resist_ddi best32. ;
	informat resist_dlv best32. ;
	informat resist_efv best32. ;
	informat resist_etr best32. ;
	informat resist_ftc best32. ;
	informat resist_npv best32. ;
	informat resist_rpv best32. ;
	informat resist_tdf best32. ;
	informat mut_nrti best32. ;
	informat mut_nnrti best32. ;
	informat mut_m41___0 best32. ;
	informat mut_m41___1 best32. ;
	informat mut_m41___9 best32. ;
	informat mut_m41_other $500. ;
	informat mut_44___0 best32. ;
	informat mut_44___1 best32. ;
	informat mut_44___2 best32. ;
	informat mut_44___9 best32. ;
	informat mut_44_other $500. ;
	informat mut_a62___0 best32. ;
	informat mut_a62___1 best32. ;
	informat mut_a62___9 best32. ;
	informat mut_a62_other $500. ;
	informat mut_k65___0 best32. ;
	informat mut_k65___1 best32. ;
	informat mut_k65___2 best32. ;
	informat mut_k65___9 best32. ;
	informat mut_k65_other $500. ;
	informat mut_d67___0 best32. ;
	informat mut_d67___1 best32. ;
	informat mut_d67___2 best32. ;
	informat mut_d67___3 best32. ;
	informat mut_d67___4 best32. ;
	informat mut_d67___9 best32. ;
	informat mut_d67_other $500. ;
	informat mut_t69___0 best32. ;
	informat mut_t69___1 best32. ;
	informat mut_t69___2 best32. ;
	informat mut_t69___3 best32. ;
	informat mut_t69___4 best32. ;
	informat mut_t69___5 best32. ;
	informat mut_t69___6 best32. ;
	informat mut_t69___7 best32. ;
	informat mut_t69___9 best32. ;
	informat mut_t69_other $500. ;
	informat mut_k70___0 best32. ;
	informat mut_k70___1 best32. ;
	informat mut_k70___2 best32. ;
	informat mut_k70___3 best32. ;
	informat mut_k70___4 best32. ;
	informat mut_k70___9 best32. ;
	informat mut_k70_other $500. ;
	informat mut_l74___0 best32. ;
	informat mut_l74___1 best32. ;
	informat mut_l74___2 best32. ;
	informat mut_l74___9 best32. ;
	informat mut_l74_other $500. ;
	informat mut_v75___0 best32. ;
	informat mut_v75___1 best32. ;
	informat mut_v75___2 best32. ;
	informat mut_v75___3 best32. ;
	informat mut_v75___4 best32. ;
	informat mut_v75___5 best32. ;
	informat mut_v75___6 best32. ;
	informat mut_v75___9 best32. ;
	informat mut_v75_other $500. ;
	informat mut_f77___0 best32. ;
	informat mut_f77___1 best32. ;
	informat mut_f77___9 best32. ;
	informat mut_f77_other $500. ;
	informat mut_v90___0 best32. ;
	informat mut_v90___1 best32. ;
	informat mut_v90___9 best32. ;
	informat mut_v90_other $500. ;
	informat mut_a98___0 best32. ;
	informat mut_a98___1 best32. ;
	informat mut_a98___2 best32. ;
	informat mut_a98___9 best32. ;
	informat mut_a98_other $500. ;
	informat mut_l100___0 best32. ;
	informat mut_l100___1 best32. ;
	informat mut_l100___9 best32. ;
	informat mut_l100_other $500. ;
	informat mut_k101___0 best32. ;
	informat mut_k101___1 best32. ;
	informat mut_k101___2 best32. ;
	informat mut_k101___3 best32. ;
	informat mut_k101___4 best32. ;
	informat mut_k101___5 best32. ;
	informat mut_k101___6 best32. ;
	informat mut_k101___9 best32. ;
	informat mut_k101_other $500. ;
	informat mut_k103___0 best32. ;
	informat mut_k103___1 best32. ;
	informat mut_k103___2 best32. ;
	informat mut_k103___3 best32. ;
	informat mut_k103___4 best32. ;
	informat mut_k103___5 best32. ;
	informat mut_k103___6 best32. ;
	informat mut_k103___7 best32. ;
	informat mut_k103___9 best32. ;
	informat mut_k103_other $500. ;
	informat mut_v106___0 best32. ;
	informat mut_v106___1 best32. ;
	informat mut_v106___2 best32. ;
	informat mut_v106___3 best32. ;
	informat mut_v106___4 best32. ;
	informat mut_v106___9 best32. ;
	informat mut_v106_other $500. ;
	informat mut_v108___0 best32. ;
	informat mut_v108___1 best32. ;
	informat mut_v108___9 best32. ;
	informat mut_v108_other $500. ;
	informat mut_g109___0 best32. ;
	informat mut_g109___1 best32. ;
	informat mut_g109___2 best32. ;
	informat mut_g109___9 best32. ;
	informat mut_g109_other $500. ;
	informat mut_y115___0 best32. ;
	informat mut_y115___1 best32. ;
	informat mut_y115___2 best32. ;
	informat mut_y115___9 best32. ;
	informat mut_y115_other $500. ;
	informat mut_f116___0 best32. ;
	informat mut_f116___1 best32. ;
	informat mut_f116___9 best32. ;
	informat mut_f116_other $500. ;
	informat mut_118___0 best32. ;
	informat mut_118___1 best32. ;
	informat mut_118___9 best32. ;
	informat mut_118_other $500. ;
	informat mut_e138___0 best32. ;
	informat mut_e138___1 best32. ;
	informat mut_e138___2 best32. ;
	informat mut_e138___3 best32. ;
	informat mut_e138___4 best32. ;
	informat mut_e138___9 best32. ;
	informat mut_e138_other $500. ;
	informat mut_q151___0 best32. ;
	informat mut_q151___1 best32. ;
	informat mut_q151___2 best32. ;
	informat mut_q151___9 best32. ;
	informat mut_q151_other $500. ;
	informat mut_v179___0 best32. ;
	informat mut_v179___1 best32. ;
	informat mut_v179___2 best32. ;
	informat mut_v179___3 best32. ;
	informat mut_v179___4 best32. ;
	informat mut_v179___5 best32. ;
	informat mut_v179___6 best32. ;
	informat mut_v179___9 best32. ;
	informat mut_v179_other $500. ;
	informat mut_y181___0 best32. ;
	informat mut_y181___1 best32. ;
	informat mut_y181___2 best32. ;
	informat mut_y181___3 best32. ;
	informat mut_y181___4 best32. ;
	informat mut_y181___9 best32. ;
	informat mut_y181_other $500. ;
	informat mut_m184___0 best32. ;
	informat mut_m184___1 best32. ;
	informat mut_m184___2 best32. ;
	informat mut_m184___3 best32. ;
	informat mut_m184___9 best32. ;
	informat mut_m184_other $500. ;
	informat mut_y188___0 best32. ;
	informat mut_y188___1 best32. ;
	informat mut_y188___2 best32. ;
	informat mut_y188___3 best32. ;
	informat mut_y188___4 best32. ;
	informat mut_y188___5 best32. ;
	informat mut_y188___9 best32. ;
	informat mut_y188_other $500. ;
	informat mut_g190___0 best32. ;
	informat mut_g190___1 best32. ;
	informat mut_g190___2 best32. ;
	informat mut_g190___3 best32. ;
	informat mut_g190___4 best32. ;
	informat mut_g190___5 best32. ;
	informat mut_g190___6 best32. ;
	informat mut_g190___7 best32. ;
	informat mut_g190___8 best32. ;
	informat mut_g190___9 best32. ;
	informat mut_g190_other $500. ;
	informat mut_l210___0 best32. ;
	informat mut_l210___1 best32. ;
	informat mut_l210___2 best32. ;
	informat mut_l210___3 best32. ;
	informat mut_l210___9 best32. ;
	informat mut_l210_other $500. ;
	informat mut_t215___0 best32. ;
	informat mut_t215___1 best32. ;
	informat mut_t215___2 best32. ;
	informat mut_t215___3 best32. ;
	informat mut_t215___4 best32. ;
	informat mut_t215___5 best32. ;
	informat mut_t215___6 best32. ;
	informat mut_t215___7 best32. ;
	informat mut_t215___8 best32. ;
	informat mut_t215___9 best32. ;
	informat mut_t215_other $500. ;
	informat mut_k219___0 best32. ;
	informat mut_k219___1 best32. ;
	informat mut_k219___2 best32. ;
	informat mut_k219___3 best32. ;
	informat mut_k219___4 best32. ;
	informat mut_k219___5 best32. ;
	informat mut_k219___6 best32. ;
	informat mut_k219___7 best32. ;
	informat mut_k219___9 best32. ;
	informat mut_k219_other $500. ;
	informat mut_h221___0 best32. ;
	informat mut_h221___1 best32. ;
	informat mut_h221___9 best32. ;
	informat mut_h221_other $500. ;
	informat mut_p225___0 best32. ;
	informat mut_p225___1 best32. ;
	informat mut_p225___9 best32. ;
	informat mut_p225_other $500. ;
	informat mut_f227___0 best32. ;
	informat mut_f227___1 best32. ;
	informat mut_f227___2 best32. ;
	informat mut_f227___9 best32. ;
	informat mut_f227_other $500. ;
	informat mut_m230___0 best32. ;
	informat mut_m230___1 best32. ;
	informat mut_m230___9 best32. ;
	informat mut_m230_other $500. ;
	informat mut_234___0 best32. ;
	informat mut_234___1 best32. ;
	informat mut_234___9 best32. ;
	informat mut_234_other $500. ;
	informat mut_236___0 best32. ;
	informat mut_236___1 best32. ;
	informat mut_236___9 best32. ;
	informat mut_236_other $500. ;
	informat mut_238___0 best32. ;
	informat mut_238___1 best32. ;
	informat mut_238___2 best32. ;
	informat mut_238___3 best32. ;
	informat mut_238___9 best32. ;
	informat mut_238_other $500. ;
	informat mut_y318___0 best32. ;
	informat mut_y318___1 best32. ;
	informat mut_y318___9 best32. ;
	informat mut_y318_other $500. ;
	informat mut_333___0 best32. ;
	informat mut_333___1 best32. ;
	informat mut_333___2 best32. ;
	informat mut_333___9 best32. ;
	informat mut_333_other $500. ;
	informat mut_n348___0 best32. ;
	informat mut_n348___1 best32. ;
	informat mut_n348___9 best32. ;
	informat mut_n348_other $500. ;
	informat other_rt_mut $5000. ;
	informat mut_pi_major best32. ;
	informat mut_pi_minor best32. ;
	informat mut_l10___0 best32. ;
	informat mut_l10___1 best32. ;
	informat mut_l10___2 best32. ;
	informat mut_l10___3 best32. ;
	informat mut_l10___4 best32. ;
	informat mut_l10___5 best32. ;
	informat mut_l10___9 best32. ;
	informat mut_l10_other $500. ;
	informat mut_v11___0 best32. ;
	informat mut_v11___1 best32. ;
	informat mut_v11___9 best32. ;
	informat mut_v11_other $500. ;
	informat mut_13___0 best32. ;
	informat mut_13___1 best32. ;
	informat mut_13___9 best32. ;
	informat mut_13_other $500. ;
	informat mut_g16___0 best32. ;
	informat mut_g16___1 best32. ;
	informat mut_g16___9 best32. ;
	informat mut_g16_other $500. ;
	informat mut_k20___0 best32. ;
	informat mut_k20___1 best32. ;
	informat mut_k20___2 best32. ;
	informat mut_k20___3 best32. ;
	informat mut_k20___4 best32. ;
	informat mut_k20___5 best32. ;
	informat mut_k20___9 best32. ;
	informat mut_k20_other $500. ;
	informat mut_23___0 best32. ;
	informat mut_23___1 best32. ;
	informat mut_23___9 best32. ;
	informat mut_23_other $500. ;
	informat mut_l24___0 best32. ;
	informat mut_l24___1 best32. ;
	informat mut_l24___2 best32. ;
	informat mut_l24___9 best32. ;
	informat mut_l24_other $500. ;
	informat mut_d30___0 best32. ;
	informat mut_d30___1 best32. ;
	informat mut_d30___9 best32. ;
	informat mut_d30_other $500. ;
	informat mut_v32___0 best32. ;
	informat mut_v32___1 best32. ;
	informat mut_v32___9 best32. ;
	informat mut_v32_other $500. ;
	informat mut_l33___0 best32. ;
	informat mut_l33___1 best32. ;
	informat mut_l33___2 best32. ;
	informat mut_l33___3 best32. ;
	informat mut_l33___9 best32. ;
	informat mut_l33_other $500. ;
	informat mut_35___0 best32. ;
	informat mut_35___1 best32. ;
	informat mut_35___9 best32. ;
	informat mut_35_other $500. ;
	informat mut_m36___0 best32. ;
	informat mut_m36___1 best32. ;
	informat mut_m36___2 best32. ;
	informat mut_m36___3 best32. ;
	informat mut_m36___4 best32. ;
	informat mut_m36___9 best32. ;
	informat mut_m36_other $500. ;
	informat mut_k43___0 best32. ;
	informat mut_k43___1 best32. ;
	informat mut_k43___9 best32. ;
	informat mut_k43_other $500. ;
	informat mut_m46___0 best32. ;
	informat mut_m46___1 best32. ;
	informat mut_m46___2 best32. ;
	informat mut_m46___3 best32. ;
	informat mut_m46___9 best32. ;
	informat mut_m46_other $500. ;
	informat mut_i47___0 best32. ;
	informat mut_i47___1 best32. ;
	informat mut_i47___2 best32. ;
	informat mut_i47___9 best32. ;
	informat mut_i47_other $500. ;
	informat mut_g48___0 best32. ;
	informat mut_g48___1 best32. ;
	informat mut_g48___2 best32. ;
	informat mut_g48___3 best32. ;
	informat mut_g48___4 best32. ;
	informat mut_g48___5 best32. ;
	informat mut_g48___6 best32. ;
	informat mut_g48___9 best32. ;
	informat mut_g48_other $500. ;
	informat mut_i50___0 best32. ;
	informat mut_i50___1 best32. ;
	informat mut_i50___2 best32. ;
	informat mut_i50___9 best32. ;
	informat mut_i50_other $500. ;
	informat mut_f53___0 best32. ;
	informat mut_f53___1 best32. ;
	informat mut_f53___2 best32. ;
	informat mut_f53___9 best32. ;
	informat mut_f53_other $500. ;
	informat mut_i54___0 best32. ;
	informat mut_i54___1 best32. ;
	informat mut_i54___2 best32. ;
	informat mut_i54___3 best32. ;
	informat mut_i54___4 best32. ;
	informat mut_i54___5 best32. ;
	informat mut_i54___6 best32. ;
	informat mut_i54___9 best32. ;
	informat mut_i54_other $500. ;
	informat mut_q58___0 best32. ;
	informat mut_q58___1 best32. ;
	informat mut_q58___9 best32. ;
	informat mut_q58_other $500. ;
	informat mut_d60___0 best32. ;
	informat mut_d60___1 best32. ;
	informat mut_d60___9 best32. ;
	informat mut_d60_other $500. ;
	informat mut_i62___0 best32. ;
	informat mut_i62___1 best32. ;
	informat mut_i62___9 best32. ;
	informat mut_i62_other $500. ;
	informat mut_l63___0 best32. ;
	informat mut_l63___1 best32. ;
	informat mut_l63___9 best32. ;
	informat mut_l63_other $500. ;
	informat mut_a71___0 best32. ;
	informat mut_a71___1 best32. ;
	informat mut_a71___2 best32. ;
	informat mut_a71___3 best32. ;
	informat mut_a71___4 best32. ;
	informat mut_a71___9 best32. ;
	informat mut_a71_other $500. ;
	informat mut_g73___0 best32. ;
	informat mut_g73___1 best32. ;
	informat mut_g73___2 best32. ;
	informat mut_g73___3 best32. ;
	informat mut_g73___4 best32. ;
	informat mut_g73___9 best32. ;
	informat mut_g73_other $500. ;
	informat mut_t74___0 best32. ;
	informat mut_t74___1 best32. ;
	informat mut_t74___2 best32. ;
	informat mut_t74___9 best32. ;
	informat mut_t74_other $500. ;
	informat mut_l76___0 best32. ;
	informat mut_l76___1 best32. ;
	informat mut_l76___9 best32. ;
	informat mut_l76_other $500. ;
	informat mut_v77___0 best32. ;
	informat mut_v77___1 best32. ;
	informat mut_v77___9 best32. ;
	informat mut_v77_other $500. ;
	informat mut_v82___0 best32. ;
	informat mut_v82___1 best32. ;
	informat mut_v82___2 best32. ;
	informat mut_v82___3 best32. ;
	informat mut_v82___4 best32. ;
	informat mut_v82___5 best32. ;
	informat mut_v82___6 best32. ;
	informat mut_v82___7 best32. ;
	informat mut_v82___8 best32. ;
	informat mut_v82___9 best32. ;
	informat mut_v82_other $500. ;
	informat mut_n83___0 best32. ;
	informat mut_n83___1 best32. ;
	informat mut_n83___9 best32. ;
	informat mut_n83_other $500. ;
	informat mut_i84___0 best32. ;
	informat mut_i84___1 best32. ;
	informat mut_i84___2 best32. ;
	informat mut_i84___3 best32. ;
	informat mut_i84___9 best32. ;
	informat mut_i84_other $500. ;
	informat mut_i85___0 best32. ;
	informat mut_i85___1 best32. ;
	informat mut_i85___9 best32. ;
	informat mut_i85_other $500. ;
	informat mut_n88___0 best32. ;
	informat mut_n88___1 best32. ;
	informat mut_n88___2 best32. ;
	informat mut_n88___3 best32. ;
	informat mut_n88___4 best32. ;
	informat mut_n88___9 best32. ;
	informat mut_n88_other $500. ;
	informat mut_l89___0 best32. ;
	informat mut_l89___1 best32. ;
	informat mut_l89___2 best32. ;
	informat mut_l89___3 best32. ;
	informat mut_l89___4 best32. ;
	informat mut_l89___9 best32. ;
	informat mut_l89_other $500. ;
	informat mut_l90___0 best32. ;
	informat mut_l90___1 best32. ;
	informat mut_l90___9 best32. ;
	informat mut_l90_other $500. ;
	informat mut_i93___0 best32. ;
	informat mut_i93___1 best32. ;
	informat mut_i93___2 best32. ;
	informat mut_i93___9 best32. ;
	informat mut_i93_other $500. ;
	informat resistance_data_1_complete best32. ;

	format patient_id $500. ;
	format dt_enroll $500. ;
	format vl_enroll $500. ;
	format hpp_recent $500. ;
	format vl_mccord $500. ;
	format dt_mccord yymmdd10. ;
	format genotype_done best12. ;
	format dt_results_rec yymmdd10. ;
	format genotype_comments $5000. ;
	format resist_3tc best12. ;
	format resist_abc best12. ;
	format resist_azt best12. ;
	format resist_d4t best12. ;
	format resist_ddi best12. ;
	format resist_dlv best12. ;
	format resist_efv best12. ;
	format resist_etr best12. ;
	format resist_ftc best12. ;
	format resist_npv best12. ;
	format resist_rpv best12. ;
	format resist_tdf best12. ;
	format mut_nrti best12. ;
	format mut_nnrti best12. ;
	format mut_m41___0 best12. ;
	format mut_m41___1 best12. ;
	format mut_m41___9 best12. ;
	format mut_m41_other $500. ;
	format mut_44___0 best12. ;
	format mut_44___1 best12. ;
	format mut_44___2 best12. ;
	format mut_44___9 best12. ;
	format mut_44_other $500. ;
	format mut_a62___0 best12. ;
	format mut_a62___1 best12. ;
	format mut_a62___9 best12. ;
	format mut_a62_other $500. ;
	format mut_k65___0 best12. ;
	format mut_k65___1 best12. ;
	format mut_k65___2 best12. ;
	format mut_k65___9 best12. ;
	format mut_k65_other $500. ;
	format mut_d67___0 best12. ;
	format mut_d67___1 best12. ;
	format mut_d67___2 best12. ;
	format mut_d67___3 best12. ;
	format mut_d67___4 best12. ;
	format mut_d67___9 best12. ;
	format mut_d67_other $500. ;
	format mut_t69___0 best12. ;
	format mut_t69___1 best12. ;
	format mut_t69___2 best12. ;
	format mut_t69___3 best12. ;
	format mut_t69___4 best12. ;
	format mut_t69___5 best12. ;
	format mut_t69___6 best12. ;
	format mut_t69___7 best12. ;
	format mut_t69___9 best12. ;
	format mut_t69_other $500. ;
	format mut_k70___0 best12. ;
	format mut_k70___1 best12. ;
	format mut_k70___2 best12. ;
	format mut_k70___3 best12. ;
	format mut_k70___4 best12. ;
	format mut_k70___9 best12. ;
	format mut_k70_other $500. ;
	format mut_l74___0 best12. ;
	format mut_l74___1 best12. ;
	format mut_l74___2 best12. ;
	format mut_l74___9 best12. ;
	format mut_l74_other $500. ;
	format mut_v75___0 best12. ;
	format mut_v75___1 best12. ;
	format mut_v75___2 best12. ;
	format mut_v75___3 best12. ;
	format mut_v75___4 best12. ;
	format mut_v75___5 best12. ;
	format mut_v75___6 best12. ;
	format mut_v75___9 best12. ;
	format mut_v75_other $500. ;
	format mut_f77___0 best12. ;
	format mut_f77___1 best12. ;
	format mut_f77___9 best12. ;
	format mut_f77_other $500. ;
	format mut_v90___0 best12. ;
	format mut_v90___1 best12. ;
	format mut_v90___9 best12. ;
	format mut_v90_other $500. ;
	format mut_a98___0 best12. ;
	format mut_a98___1 best12. ;
	format mut_a98___2 best12. ;
	format mut_a98___9 best12. ;
	format mut_a98_other $500. ;
	format mut_l100___0 best12. ;
	format mut_l100___1 best12. ;
	format mut_l100___9 best12. ;
	format mut_l100_other $500. ;
	format mut_k101___0 best12. ;
	format mut_k101___1 best12. ;
	format mut_k101___2 best12. ;
	format mut_k101___3 best12. ;
	format mut_k101___4 best12. ;
	format mut_k101___5 best12. ;
	format mut_k101___6 best12. ;
	format mut_k101___9 best12. ;
	format mut_k101_other $500. ;
	format mut_k103___0 best12. ;
	format mut_k103___1 best12. ;
	format mut_k103___2 best12. ;
	format mut_k103___3 best12. ;
	format mut_k103___4 best12. ;
	format mut_k103___5 best12. ;
	format mut_k103___6 best12. ;
	format mut_k103___7 best12. ;
	format mut_k103___9 best12. ;
	format mut_k103_other $500. ;
	format mut_v106___0 best12. ;
	format mut_v106___1 best12. ;
	format mut_v106___2 best12. ;
	format mut_v106___3 best12. ;
	format mut_v106___4 best12. ;
	format mut_v106___9 best12. ;
	format mut_v106_other $500. ;
	format mut_v108___0 best12. ;
	format mut_v108___1 best12. ;
	format mut_v108___9 best12. ;
	format mut_v108_other $500. ;
	format mut_g109___0 best12. ;
	format mut_g109___1 best12. ;
	format mut_g109___2 best12. ;
	format mut_g109___9 best12. ;
	format mut_g109_other $500. ;
	format mut_y115___0 best12. ;
	format mut_y115___1 best12. ;
	format mut_y115___2 best12. ;
	format mut_y115___9 best12. ;
	format mut_y115_other $500. ;
	format mut_f116___0 best12. ;
	format mut_f116___1 best12. ;
	format mut_f116___9 best12. ;
	format mut_f116_other $500. ;
	format mut_118___0 best12. ;
	format mut_118___1 best12. ;
	format mut_118___9 best12. ;
	format mut_118_other $500. ;
	format mut_e138___0 best12. ;
	format mut_e138___1 best12. ;
	format mut_e138___2 best12. ;
	format mut_e138___3 best12. ;
	format mut_e138___4 best12. ;
	format mut_e138___9 best12. ;
	format mut_e138_other $500. ;
	format mut_q151___0 best12. ;
	format mut_q151___1 best12. ;
	format mut_q151___2 best12. ;
	format mut_q151___9 best12. ;
	format mut_q151_other $500. ;
	format mut_v179___0 best12. ;
	format mut_v179___1 best12. ;
	format mut_v179___2 best12. ;
	format mut_v179___3 best12. ;
	format mut_v179___4 best12. ;
	format mut_v179___5 best12. ;
	format mut_v179___6 best12. ;
	format mut_v179___9 best12. ;
	format mut_v179_other $500. ;
	format mut_y181___0 best12. ;
	format mut_y181___1 best12. ;
	format mut_y181___2 best12. ;
	format mut_y181___3 best12. ;
	format mut_y181___4 best12. ;
	format mut_y181___9 best12. ;
	format mut_y181_other $500. ;
	format mut_m184___0 best12. ;
	format mut_m184___1 best12. ;
	format mut_m184___2 best12. ;
	format mut_m184___3 best12. ;
	format mut_m184___9 best12. ;
	format mut_m184_other $500. ;
	format mut_y188___0 best12. ;
	format mut_y188___1 best12. ;
	format mut_y188___2 best12. ;
	format mut_y188___3 best12. ;
	format mut_y188___4 best12. ;
	format mut_y188___5 best12. ;
	format mut_y188___9 best12. ;
	format mut_y188_other $500. ;
	format mut_g190___0 best12. ;
	format mut_g190___1 best12. ;
	format mut_g190___2 best12. ;
	format mut_g190___3 best12. ;
	format mut_g190___4 best12. ;
	format mut_g190___5 best12. ;
	format mut_g190___6 best12. ;
	format mut_g190___7 best12. ;
	format mut_g190___8 best12. ;
	format mut_g190___9 best12. ;
	format mut_g190_other $500. ;
	format mut_l210___0 best12. ;
	format mut_l210___1 best12. ;
	format mut_l210___2 best12. ;
	format mut_l210___3 best12. ;
	format mut_l210___9 best12. ;
	format mut_l210_other $500. ;
	format mut_t215___0 best12. ;
	format mut_t215___1 best12. ;
	format mut_t215___2 best12. ;
	format mut_t215___3 best12. ;
	format mut_t215___4 best12. ;
	format mut_t215___5 best12. ;
	format mut_t215___6 best12. ;
	format mut_t215___7 best12. ;
	format mut_t215___8 best12. ;
	format mut_t215___9 best12. ;
	format mut_t215_other $500. ;
	format mut_k219___0 best12. ;
	format mut_k219___1 best12. ;
	format mut_k219___2 best12. ;
	format mut_k219___3 best12. ;
	format mut_k219___4 best12. ;
	format mut_k219___5 best12. ;
	format mut_k219___6 best12. ;
	format mut_k219___7 best12. ;
	format mut_k219___9 best12. ;
	format mut_k219_other $500. ;
	format mut_h221___0 best12. ;
	format mut_h221___1 best12. ;
	format mut_h221___9 best12. ;
	format mut_h221_other $500. ;
	format mut_p225___0 best12. ;
	format mut_p225___1 best12. ;
	format mut_p225___9 best12. ;
	format mut_p225_other $500. ;
	format mut_f227___0 best12. ;
	format mut_f227___1 best12. ;
	format mut_f227___2 best12. ;
	format mut_f227___9 best12. ;
	format mut_f227_other $500. ;
	format mut_m230___0 best12. ;
	format mut_m230___1 best12. ;
	format mut_m230___9 best12. ;
	format mut_m230_other $500. ;
	format mut_234___0 best12. ;
	format mut_234___1 best12. ;
	format mut_234___9 best12. ;
	format mut_234_other $500. ;
	format mut_236___0 best12. ;
	format mut_236___1 best12. ;
	format mut_236___9 best12. ;
	format mut_236_other $500. ;
	format mut_238___0 best12. ;
	format mut_238___1 best12. ;
	format mut_238___2 best12. ;
	format mut_238___3 best12. ;
	format mut_238___9 best12. ;
	format mut_238_other $500. ;
	format mut_y318___0 best12. ;
	format mut_y318___1 best12. ;
	format mut_y318___9 best12. ;
	format mut_y318_other $500. ;
	format mut_333___0 best12. ;
	format mut_333___1 best12. ;
	format mut_333___2 best12. ;
	format mut_333___9 best12. ;
	format mut_333_other $500. ;
	format mut_n348___0 best12. ;
	format mut_n348___1 best12. ;
	format mut_n348___9 best12. ;
	format mut_n348_other $500. ;
	format other_rt_mut $5000. ;
	format mut_pi_major best12. ;
	format mut_pi_minor best12. ;
	format mut_l10___0 best12. ;
	format mut_l10___1 best12. ;
	format mut_l10___2 best12. ;
	format mut_l10___3 best12. ;
	format mut_l10___4 best12. ;
	format mut_l10___5 best12. ;
	format mut_l10___9 best12. ;
	format mut_l10_other $500. ;
	format mut_v11___0 best12. ;
	format mut_v11___1 best12. ;
	format mut_v11___9 best12. ;
	format mut_v11_other $500. ;
	format mut_13___0 best12. ;
	format mut_13___1 best12. ;
	format mut_13___9 best12. ;
	format mut_13_other $500. ;
	format mut_g16___0 best12. ;
	format mut_g16___1 best12. ;
	format mut_g16___9 best12. ;
	format mut_g16_other $500. ;
	format mut_k20___0 best12. ;
	format mut_k20___1 best12. ;
	format mut_k20___2 best12. ;
	format mut_k20___3 best12. ;
	format mut_k20___4 best12. ;
	format mut_k20___5 best12. ;
	format mut_k20___9 best12. ;
	format mut_k20_other $500. ;
	format mut_23___0 best12. ;
	format mut_23___1 best12. ;
	format mut_23___9 best12. ;
	format mut_23_other $500. ;
	format mut_l24___0 best12. ;
	format mut_l24___1 best12. ;
	format mut_l24___2 best12. ;
	format mut_l24___9 best12. ;
	format mut_l24_other $500. ;
	format mut_d30___0 best12. ;
	format mut_d30___1 best12. ;
	format mut_d30___9 best12. ;
	format mut_d30_other $500. ;
	format mut_v32___0 best12. ;
	format mut_v32___1 best12. ;
	format mut_v32___9 best12. ;
	format mut_v32_other $500. ;
	format mut_l33___0 best12. ;
	format mut_l33___1 best12. ;
	format mut_l33___2 best12. ;
	format mut_l33___3 best12. ;
	format mut_l33___9 best12. ;
	format mut_l33_other $500. ;
	format mut_35___0 best12. ;
	format mut_35___1 best12. ;
	format mut_35___9 best12. ;
	format mut_35_other $500. ;
	format mut_m36___0 best12. ;
	format mut_m36___1 best12. ;
	format mut_m36___2 best12. ;
	format mut_m36___3 best12. ;
	format mut_m36___4 best12. ;
	format mut_m36___9 best12. ;
	format mut_m36_other $500. ;
	format mut_k43___0 best12. ;
	format mut_k43___1 best12. ;
	format mut_k43___9 best12. ;
	format mut_k43_other $500. ;
	format mut_m46___0 best12. ;
	format mut_m46___1 best12. ;
	format mut_m46___2 best12. ;
	format mut_m46___3 best12. ;
	format mut_m46___9 best12. ;
	format mut_m46_other $500. ;
	format mut_i47___0 best12. ;
	format mut_i47___1 best12. ;
	format mut_i47___2 best12. ;
	format mut_i47___9 best12. ;
	format mut_i47_other $500. ;
	format mut_g48___0 best12. ;
	format mut_g48___1 best12. ;
	format mut_g48___2 best12. ;
	format mut_g48___3 best12. ;
	format mut_g48___4 best12. ;
	format mut_g48___5 best12. ;
	format mut_g48___6 best12. ;
	format mut_g48___9 best12. ;
	format mut_g48_other $500. ;
	format mut_i50___0 best12. ;
	format mut_i50___1 best12. ;
	format mut_i50___2 best12. ;
	format mut_i50___9 best12. ;
	format mut_i50_other $500. ;
	format mut_f53___0 best12. ;
	format mut_f53___1 best12. ;
	format mut_f53___2 best12. ;
	format mut_f53___9 best12. ;
	format mut_f53_other $500. ;
	format mut_i54___0 best12. ;
	format mut_i54___1 best12. ;
	format mut_i54___2 best12. ;
	format mut_i54___3 best12. ;
	format mut_i54___4 best12. ;
	format mut_i54___5 best12. ;
	format mut_i54___6 best12. ;
	format mut_i54___9 best12. ;
	format mut_i54_other $500. ;
	format mut_q58___0 best12. ;
	format mut_q58___1 best12. ;
	format mut_q58___9 best12. ;
	format mut_q58_other $500. ;
	format mut_d60___0 best12. ;
	format mut_d60___1 best12. ;
	format mut_d60___9 best12. ;
	format mut_d60_other $500. ;
	format mut_i62___0 best12. ;
	format mut_i62___1 best12. ;
	format mut_i62___9 best12. ;
	format mut_i62_other $500. ;
	format mut_l63___0 best12. ;
	format mut_l63___1 best12. ;
	format mut_l63___9 best12. ;
	format mut_l63_other $500. ;
	format mut_a71___0 best12. ;
	format mut_a71___1 best12. ;
	format mut_a71___2 best12. ;
	format mut_a71___3 best12. ;
	format mut_a71___4 best12. ;
	format mut_a71___9 best12. ;
	format mut_a71_other $500. ;
	format mut_g73___0 best12. ;
	format mut_g73___1 best12. ;
	format mut_g73___2 best12. ;
	format mut_g73___3 best12. ;
	format mut_g73___4 best12. ;
	format mut_g73___9 best12. ;
	format mut_g73_other $500. ;
	format mut_t74___0 best12. ;
	format mut_t74___1 best12. ;
	format mut_t74___2 best12. ;
	format mut_t74___9 best12. ;
	format mut_t74_other $500. ;
	format mut_l76___0 best12. ;
	format mut_l76___1 best12. ;
	format mut_l76___9 best12. ;
	format mut_l76_other $500. ;
	format mut_v77___0 best12. ;
	format mut_v77___1 best12. ;
	format mut_v77___9 best12. ;
	format mut_v77_other $500. ;
	format mut_v82___0 best12. ;
	format mut_v82___1 best12. ;
	format mut_v82___2 best12. ;
	format mut_v82___3 best12. ;
	format mut_v82___4 best12. ;
	format mut_v82___5 best12. ;
	format mut_v82___6 best12. ;
	format mut_v82___7 best12. ;
	format mut_v82___8 best12. ;
	format mut_v82___9 best12. ;
	format mut_v82_other $500. ;
	format mut_n83___0 best12. ;
	format mut_n83___1 best12. ;
	format mut_n83___9 best12. ;
	format mut_n83_other $500. ;
	format mut_i84___0 best12. ;
	format mut_i84___1 best12. ;
	format mut_i84___2 best12. ;
	format mut_i84___3 best12. ;
	format mut_i84___9 best12. ;
	format mut_i84_other $500. ;
	format mut_i85___0 best12. ;
	format mut_i85___1 best12. ;
	format mut_i85___9 best12. ;
	format mut_i85_other $500. ;
	format mut_n88___0 best12. ;
	format mut_n88___1 best12. ;
	format mut_n88___2 best12. ;
	format mut_n88___3 best12. ;
	format mut_n88___4 best12. ;
	format mut_n88___9 best12. ;
	format mut_n88_other $500. ;
	format mut_l89___0 best12. ;
	format mut_l89___1 best12. ;
	format mut_l89___2 best12. ;
	format mut_l89___3 best12. ;
	format mut_l89___4 best12. ;
	format mut_l89___9 best12. ;
	format mut_l89_other $500. ;
	format mut_l90___0 best12. ;
	format mut_l90___1 best12. ;
	format mut_l90___9 best12. ;
	format mut_l90_other $500. ;
	format mut_i93___0 best12. ;
	format mut_i93___1 best12. ;
	format mut_i93___2 best12. ;
	format mut_i93___9 best12. ;
	format mut_i93_other $500. ;
	format resistance_data_1_complete best12. ;

input
		patient_id $
		dt_enroll $
		vl_enroll $
		hpp_recent $
		vl_mccord $
		dt_mccord
		genotype_done
		dt_results_rec
		genotype_comments $
		resist_3tc
		resist_abc
		resist_azt
		resist_d4t
		resist_ddi
		resist_dlv
		resist_efv
		resist_etr
		resist_ftc
		resist_npv
		resist_rpv
		resist_tdf
		mut_nrti
		mut_nnrti
		mut_m41___0
		mut_m41___1
		mut_m41___9
		mut_m41_other $
		mut_44___0
		mut_44___1
		mut_44___2
		mut_44___9
		mut_44_other $
		mut_a62___0
		mut_a62___1
		mut_a62___9
		mut_a62_other $
		mut_k65___0
		mut_k65___1
		mut_k65___2
		mut_k65___9
		mut_k65_other $
		mut_d67___0
		mut_d67___1
		mut_d67___2
		mut_d67___3
		mut_d67___4
		mut_d67___9
		mut_d67_other $
		mut_t69___0
		mut_t69___1
		mut_t69___2
		mut_t69___3
		mut_t69___4
		mut_t69___5
		mut_t69___6
		mut_t69___7
		mut_t69___9
		mut_t69_other $
		mut_k70___0
		mut_k70___1
		mut_k70___2
		mut_k70___3
		mut_k70___4
		mut_k70___9
		mut_k70_other $
		mut_l74___0
		mut_l74___1
		mut_l74___2
		mut_l74___9
		mut_l74_other $
		mut_v75___0
		mut_v75___1
		mut_v75___2
		mut_v75___3
		mut_v75___4
		mut_v75___5
		mut_v75___6
		mut_v75___9
		mut_v75_other $
		mut_f77___0
		mut_f77___1
		mut_f77___9
		mut_f77_other $
		mut_v90___0
		mut_v90___1
		mut_v90___9
		mut_v90_other $
		mut_a98___0
		mut_a98___1
		mut_a98___2
		mut_a98___9
		mut_a98_other $
		mut_l100___0
		mut_l100___1
		mut_l100___9
		mut_l100_other $
		mut_k101___0
		mut_k101___1
		mut_k101___2
		mut_k101___3
		mut_k101___4
		mut_k101___5
		mut_k101___6
		mut_k101___9
		mut_k101_other $
		mut_k103___0
		mut_k103___1
		mut_k103___2
		mut_k103___3
		mut_k103___4
		mut_k103___5
		mut_k103___6
		mut_k103___7
		mut_k103___9
		mut_k103_other $
		mut_v106___0
		mut_v106___1
		mut_v106___2
		mut_v106___3
		mut_v106___4
		mut_v106___9
		mut_v106_other $
		mut_v108___0
		mut_v108___1
		mut_v108___9
		mut_v108_other $
		mut_g109___0
		mut_g109___1
		mut_g109___2
		mut_g109___9
		mut_g109_other $
		mut_y115___0
		mut_y115___1
		mut_y115___2
		mut_y115___9
		mut_y115_other $
		mut_f116___0
		mut_f116___1
		mut_f116___9
		mut_f116_other $
		mut_118___0
		mut_118___1
		mut_118___9
		mut_118_other $
		mut_e138___0
		mut_e138___1
		mut_e138___2
		mut_e138___3
		mut_e138___4
		mut_e138___9
		mut_e138_other $
		mut_q151___0
		mut_q151___1
		mut_q151___2
		mut_q151___9
		mut_q151_other $
		mut_v179___0
		mut_v179___1
		mut_v179___2
		mut_v179___3
		mut_v179___4
		mut_v179___5
		mut_v179___6
		mut_v179___9
		mut_v179_other $
		mut_y181___0
		mut_y181___1
		mut_y181___2
		mut_y181___3
		mut_y181___4
		mut_y181___9
		mut_y181_other $
		mut_m184___0
		mut_m184___1
		mut_m184___2
		mut_m184___3
		mut_m184___9
		mut_m184_other $
		mut_y188___0
		mut_y188___1
		mut_y188___2
		mut_y188___3
		mut_y188___4
		mut_y188___5
		mut_y188___9
		mut_y188_other $
		mut_g190___0
		mut_g190___1
		mut_g190___2
		mut_g190___3
		mut_g190___4
		mut_g190___5
		mut_g190___6
		mut_g190___7
		mut_g190___8
		mut_g190___9
		mut_g190_other $
		mut_l210___0
		mut_l210___1
		mut_l210___2
		mut_l210___3
		mut_l210___9
		mut_l210_other $
		mut_t215___0
		mut_t215___1
		mut_t215___2
		mut_t215___3
		mut_t215___4
		mut_t215___5
		mut_t215___6
		mut_t215___7
		mut_t215___8
		mut_t215___9
		mut_t215_other $
		mut_k219___0
		mut_k219___1
		mut_k219___2
		mut_k219___3
		mut_k219___4
		mut_k219___5
		mut_k219___6
		mut_k219___7
		mut_k219___9
		mut_k219_other $
		mut_h221___0
		mut_h221___1
		mut_h221___9
		mut_h221_other $
		mut_p225___0
		mut_p225___1
		mut_p225___9
		mut_p225_other $
		mut_f227___0
		mut_f227___1
		mut_f227___2
		mut_f227___9
		mut_f227_other $
		mut_m230___0
		mut_m230___1
		mut_m230___9
		mut_m230_other $
		mut_234___0
		mut_234___1
		mut_234___9
		mut_234_other $
		mut_236___0
		mut_236___1
		mut_236___9
		mut_236_other $
		mut_238___0
		mut_238___1
		mut_238___2
		mut_238___3
		mut_238___9
		mut_238_other $
		mut_y318___0
		mut_y318___1
		mut_y318___9
		mut_y318_other $
		mut_333___0
		mut_333___1
		mut_333___2
		mut_333___9
		mut_333_other $
		mut_n348___0
		mut_n348___1
		mut_n348___9
		mut_n348_other $
		other_rt_mut $
		mut_pi_major
		mut_pi_minor
		mut_l10___0
		mut_l10___1
		mut_l10___2
		mut_l10___3
		mut_l10___4
		mut_l10___5
		mut_l10___9
		mut_l10_other $
		mut_v11___0
		mut_v11___1
		mut_v11___9
		mut_v11_other $
		mut_13___0
		mut_13___1
		mut_13___9
		mut_13_other $
		mut_g16___0
		mut_g16___1
		mut_g16___9
		mut_g16_other $
		mut_k20___0
		mut_k20___1
		mut_k20___2
		mut_k20___3
		mut_k20___4
		mut_k20___5
		mut_k20___9
		mut_k20_other $
		mut_23___0
		mut_23___1
		mut_23___9
		mut_23_other $
		mut_l24___0
		mut_l24___1
		mut_l24___2
		mut_l24___9
		mut_l24_other $
		mut_d30___0
		mut_d30___1
		mut_d30___9
		mut_d30_other $
		mut_v32___0
		mut_v32___1
		mut_v32___9
		mut_v32_other $
		mut_l33___0
		mut_l33___1
		mut_l33___2
		mut_l33___3
		mut_l33___9
		mut_l33_other $
		mut_35___0
		mut_35___1
		mut_35___9
		mut_35_other $
		mut_m36___0
		mut_m36___1
		mut_m36___2
		mut_m36___3
		mut_m36___4
		mut_m36___9
		mut_m36_other $
		mut_k43___0
		mut_k43___1
		mut_k43___9
		mut_k43_other $
		mut_m46___0
		mut_m46___1
		mut_m46___2
		mut_m46___3
		mut_m46___9
		mut_m46_other $
		mut_i47___0
		mut_i47___1
		mut_i47___2
		mut_i47___9
		mut_i47_other $
		mut_g48___0
		mut_g48___1
		mut_g48___2
		mut_g48___3
		mut_g48___4
		mut_g48___5
		mut_g48___6
		mut_g48___9
		mut_g48_other $
		mut_i50___0
		mut_i50___1
		mut_i50___2
		mut_i50___9
		mut_i50_other $
		mut_f53___0
		mut_f53___1
		mut_f53___2
		mut_f53___9
		mut_f53_other $
		mut_i54___0
		mut_i54___1
		mut_i54___2
		mut_i54___3
		mut_i54___4
		mut_i54___5
		mut_i54___6
		mut_i54___9
		mut_i54_other $
		mut_q58___0
		mut_q58___1
		mut_q58___9
		mut_q58_other $
		mut_d60___0
		mut_d60___1
		mut_d60___9
		mut_d60_other $
		mut_i62___0
		mut_i62___1
		mut_i62___9
		mut_i62_other $
		mut_l63___0
		mut_l63___1
		mut_l63___9
		mut_l63_other $
		mut_a71___0
		mut_a71___1
		mut_a71___2
		mut_a71___3
		mut_a71___4
		mut_a71___9
		mut_a71_other $
		mut_g73___0
		mut_g73___1
		mut_g73___2
		mut_g73___3
		mut_g73___4
		mut_g73___9
		mut_g73_other $
		mut_t74___0
		mut_t74___1
		mut_t74___2
		mut_t74___9
		mut_t74_other $
		mut_l76___0
		mut_l76___1
		mut_l76___9
		mut_l76_other $
		mut_v77___0
		mut_v77___1
		mut_v77___9
		mut_v77_other $
		mut_v82___0
		mut_v82___1
		mut_v82___2
		mut_v82___3
		mut_v82___4
		mut_v82___5
		mut_v82___6
		mut_v82___7
		mut_v82___8
		mut_v82___9
		mut_v82_other $
		mut_n83___0
		mut_n83___1
		mut_n83___9
		mut_n83_other $
		mut_i84___0
		mut_i84___1
		mut_i84___2
		mut_i84___3
		mut_i84___9
		mut_i84_other $
		mut_i85___0
		mut_i85___1
		mut_i85___9
		mut_i85_other $
		mut_n88___0
		mut_n88___1
		mut_n88___2
		mut_n88___3
		mut_n88___4
		mut_n88___9
		mut_n88_other $
		mut_l89___0
		mut_l89___1
		mut_l89___2
		mut_l89___3
		mut_l89___4
		mut_l89___9
		mut_l89_other $
		mut_l90___0
		mut_l90___1
		mut_l90___9
		mut_l90_other $
		mut_i93___0
		mut_i93___1
		mut_i93___2
		mut_i93___9
		mut_i93_other $
		resistance_data_1_complete
;
if _ERROR_ then call symput('_EFIERR_',"1");
run;

proc contents;run;


data redcap;
	set redcap;
	label patient_id='Patient ID Number';
	label dt_enroll='Date of enrollment';
	label vl_enroll='Viral Load at Enrollment';
	label hpp_recent='HPP Recent Viral Load';
	label vl_mccord='Recent Viral Load at McCord';
	label dt_mccord='Date';
	label genotype_done='Genotype done';
	label dt_results_rec='Date results received';
	label genotype_comments='Genotype Comments';
	label resist_3tc='3TC';
	label resist_abc='ABC';
	label resist_azt='AZT';
	label resist_d4t='D4T';
	label resist_ddi='DDI';
	label resist_dlv='DLV';
	label resist_efv='EFV';
	label resist_etr='ETR';
	label resist_ftc='FTC';
	label resist_npv='NPV';
	label resist_rpv='RPV';
	label resist_tdf='TDF';
	label mut_nrti='NRTI Mutations';
	label mut_nnrti='NNRTI Mutations';
	label mut_m41___0='M41 (choice=M (WT))';
	label mut_m41___1='M41 (choice=L)';
	label mut_m41___9='M41 (choice=Other)';
	label mut_m41_other='Other ';
	label mut_44___0='44 (choice=E (WT))';
	label mut_44___1='44 (choice=A)';
	label mut_44___2='44 (choice=D)';
	label mut_44___9='44 (choice=Other)';
	label mut_44_other='Other';
	label mut_a62___0='A62 (choice=A (WT))';
	label mut_a62___1='A62 (choice=V)';
	label mut_a62___9='A62 (choice=Other)';
	label mut_a62_other='Other';
	label mut_k65___0='K65 (choice=K (WT))';
	label mut_k65___1='K65 (choice=N)';
	label mut_k65___2='K65 (choice=R)';
	label mut_k65___9='K65 (choice=Other)';
	label mut_k65_other='Other';
	label mut_d67___0='D67 (choice=D (WT))';
	label mut_d67___1='D67 (choice=E)';
	label mut_d67___2='D67 (choice=G)';
	label mut_d67___3='D67 (choice=N)';
	label mut_d67___4='D67 (choice=d)';
	label mut_d67___9='D67 (choice=Other)';
	label mut_d67_other='Other';
	label mut_t69___0='T69 (choice=T (WT))';
	label mut_t69___1='T69 (choice=A)';
	label mut_t69___2='T69 (choice=D)';
	label mut_t69___3='T69 (choice=G)';
	label mut_t69___4='T69 (choice=I)';
	label mut_t69___5='T69 (choice=N)';
	label mut_t69___6='T69 (choice=S)';
	label mut_t69___7='T69 (choice=i)';
	label mut_t69___9='T69 (choice=Other)';
	label mut_t69_other='Other';
	label mut_k70___0='K70 (choice=K (WT))';
	label mut_k70___1='K70 (choice=E)';
	label mut_k70___2='K70 (choice=G)';
	label mut_k70___3='K70 (choice=R)';
	label mut_k70___4='K70 (choice=T)';
	label mut_k70___9='K70 (choice=Other)';
	label mut_k70_other='Other';
	label mut_l74___0='L74 (choice=L (WT))';
	label mut_l74___1='L74 (choice=I)';
	label mut_l74___2='L74 (choice=V)';
	label mut_l74___9='L74 (choice=Other)';
	label mut_l74_other='Other';
	label mut_v75___0='V75 (choice=V (WT))';
	label mut_v75___1='V75 (choice=A)';
	label mut_v75___2='V75 (choice=I)';
	label mut_v75___3='V75 (choice=L)';
	label mut_v75___4='V75 (choice=M)';
	label mut_v75___5='V75 (choice=S)';
	label mut_v75___6='V75 (choice=T)';
	label mut_v75___9='V75 (choice=Other)';
	label mut_v75_other='Other';
	label mut_f77___0='F77 (choice=F (WT))';
	label mut_f77___1='F77 (choice=L)';
	label mut_f77___9='F77 (choice=Other)';
	label mut_f77_other='Other';
	label mut_v90___0='V90 (choice=V (WT))';
	label mut_v90___1='V90 (choice=I)';
	label mut_v90___9='V90 (choice=Other)';
	label mut_v90_other='Other';
	label mut_a98___0='A98 (choice=A (WT))';
	label mut_a98___1='A98 (choice=G)';
	label mut_a98___2='A98 (choice=S)';
	label mut_a98___9='A98 (choice=Other)';
	label mut_a98_other='Other';
	label mut_l100___0='L100 (choice=L (WT))';
	label mut_l100___1='L100 (choice=I)';
	label mut_l100___9='L100 (choice=Other)';
	label mut_l100_other='Other';
	label mut_k101___0='K101 (choice=K (WT))';
	label mut_k101___1='K101 (choice=E)';
	label mut_k101___2='K101 (choice=H)';
	label mut_k101___3='K101 (choice=N)';
	label mut_k101___4='K101 (choice=P)';
	label mut_k101___5='K101 (choice=Q)';
	label mut_k101___6='K101 (choice=R)';
	label mut_k101___9='K101 (choice=Other)';
	label mut_k101_other='Other';
	label mut_k103___0='K103 (choice=K (WT))';
	label mut_k103___1='K103 (choice=E)';
	label mut_k103___2='K103 (choice=H)';
	label mut_k103___3='K103 (choice=N)';
	label mut_k103___4='K103 (choice=Q)';
	label mut_k103___5='K103 (choice=R)';
	label mut_k103___6='K103 (choice=S)';
	label mut_k103___7='K103 (choice=T)';
	label mut_k103___9='K103 (choice=Other)';
	label mut_k103_other='Other';
	label mut_v106___0='V106 (choice=V (WT))';
	label mut_v106___1='V106 (choice=A)';
	label mut_v106___2='V106 (choice=I)';
	label mut_v106___3='V106 (choice=L)';
	label mut_v106___4='V106 (choice=M)';
	label mut_v106___9='V106 (choice=Other)';
	label mut_v106_other='Other';
	label mut_v108___0='V108 (choice=V (WT))';
	label mut_v108___1='V108 (choice=I)';
	label mut_v108___9='V108 (choice=Other)';
	label mut_v108_other='Other';
	label mut_g109___0='G109 (choice=G (WT))';
	label mut_g109___1='G109 (choice=E)';
	label mut_g109___2='G109 (choice=S)';
	label mut_g109___9='G109 (choice=Other)';
	label mut_g109_other='Other';
	label mut_y115___0='Y115 (choice=Y (WT))';
	label mut_y115___1='Y115 (choice=F)';
	label mut_y115___2='Y115 (choice=S)';
	label mut_y115___9='Y115 (choice=Other)';
	label mut_y115_other='Other';
	label mut_f116___0='F116 (choice=F (WT))';
	label mut_f116___1='F116 (choice=Y)';
	label mut_f116___9='F116 (choice=Other)';
	label mut_f116_other='Other';
	label mut_118___0='118 (choice=V (WT))';
	label mut_118___1='118 (choice=I)';
	label mut_118___9='118 (choice=Other)';
	label mut_118_other='Other';
	label mut_e138___0='E138 (choice=E (WT))';
	label mut_e138___1='E138 (choice=A)';
	label mut_e138___2='E138 (choice=G)';
	label mut_e138___3='E138 (choice=K)';
	label mut_e138___4='E138 (choice=Q)';
	label mut_e138___9='E138 (choice=Other)';
	label mut_e138_other='Other';
	label mut_q151___0='Q151 (choice=Q (WT))';
	label mut_q151___1='Q151 (choice=L)';
	label mut_q151___2='Q151 (choice=M)';
	label mut_q151___9='Q151 (choice=Other)';
	label mut_q151_other='Other';
	label mut_v179___0='V179 (choice=V (WT))';
	label mut_v179___1='V179 (choice=D)';
	label mut_v179___2='V179 (choice=E)';
	label mut_v179___3='V179 (choice=F)';
	label mut_v179___4='V179 (choice=I)';
	label mut_v179___5='V179 (choice=T)';
	label mut_v179___6='V179 (choice=Y)';
	label mut_v179___9='V179 (choice=Other)';
	label mut_v179_other='Other';
	label mut_y181___0='Y181 (choice=Y (WT))';
	label mut_y181___1='Y181 (choice=C)';
	label mut_y181___2='Y181 (choice=I)';
	label mut_y181___3='Y181 (choice=S)';
	label mut_y181___4='Y181 (choice=V)';
	label mut_y181___9='Y181 (choice=Other)';
	label mut_y181_other='Other';
	label mut_m184___0='M184 (choice=M (WT))';
	label mut_m184___1='M184 (choice=C)';
	label mut_m184___2='M184 (choice=I)';
	label mut_m184___3='M184 (choice=V)';
	label mut_m184___9='M184 (choice=Other)';
	label mut_m184_other='Other';
	label mut_y188___0='Y188 (choice=Y (WT))';
	label mut_y188___1='Y188 (choice=C)';
	label mut_y188___2='Y188 (choice=F)';
	label mut_y188___3='Y188 (choice=H)';
	label mut_y188___4='Y188 (choice=L)';
	label mut_y188___5='Y188 (choice=N)';
	label mut_y188___9='Y188 (choice=Other)';
	label mut_y188_other='Other';
	label mut_g190___0='G190 (choice=G (WT))';
	label mut_g190___1='G190 (choice=A)';
	label mut_g190___2='G190 (choice=C)';
	label mut_g190___3='G190 (choice=D)';
	label mut_g190___4='G190 (choice=E)';
	label mut_g190___5='G190 (choice=Q)';
	label mut_g190___6='G190 (choice=S)';
	label mut_g190___7='G190 (choice=T)';
	label mut_g190___8='G190 (choice=V)';
	label mut_g190___9='G190 (choice=Other)';
	label mut_g190_other='Other';
	label mut_l210___0='L210 (choice=L (WT))';
	label mut_l210___1='L210 (choice=F)';
	label mut_l210___2='L210 (choice=S)';
	label mut_l210___3='L210 (choice=W)';
	label mut_l210___9='L210 (choice=Other)';
	label mut_l210_other='Other';
	label mut_t215___0='T215 (choice=T (WT))';
	label mut_t215___1='T215 (choice=C)';
	label mut_t215___2='T215 (choice=D)';
	label mut_t215___3='T215 (choice=E)';
	label mut_t215___4='T215 (choice=F)';
	label mut_t215___5='T215 (choice=I)';
	label mut_t215___6='T215 (choice=S)';
	label mut_t215___7='T215 (choice=V)';
	label mut_t215___8='T215 (choice=Y)';
	label mut_t215___9='T215 (choice=Other)';
	label mut_t215_other='Other';
	label mut_k219___0='K219 (choice=K (WT))';
	label mut_k219___1='K219 (choice=D)';
	label mut_k219___2='K219 (choice=E)';
	label mut_k219___3='K219 (choice=H)';
	label mut_k219___4='K219 (choice=N)';
	label mut_k219___5='K219 (choice=Q)';
	label mut_k219___6='K219 (choice=R)';
	label mut_k219___7='K219 (choice=W)';
	label mut_k219___9='K219 (choice=Other)';
	label mut_k219_other='Other';
	label mut_h221___0='H221 (choice=H (WT))';
	label mut_h221___1='H221 (choice=Y)';
	label mut_h221___9='H221 (choice=Other)';
	label mut_h221_other='Other';
	label mut_p225___0='P225 (choice=P (WT))';
	label mut_p225___1='P225 (choice=H)';
	label mut_p225___9='P225 (choice=Other)';
	label mut_p225_other='Other';
	label mut_f227___0='F227 (choice=F (WT))';
	label mut_f227___1='F227 (choice=C)';
	label mut_f227___2='F227 (choice=L)';
	label mut_f227___9='F227 (choice=Other)';
	label mut_f227_other='Other';
	label mut_m230___0='M230 (choice=M (WT))';
	label mut_m230___1='M230 (choice=L)';
	label mut_m230___9='M230 (choice=Other)';
	label mut_m230_other='Other';
	label mut_234___0='234 (choice=L (WT))';
	label mut_234___1='234 (choice=I)';
	label mut_234___9='234 (choice=Other)';
	label mut_234_other='Other';
	label mut_236___0='236 (choice=P (WT))';
	label mut_236___1='236 (choice=L)';
	label mut_236___9='236 (choice=Other)';
	label mut_236_other='Other';
	label mut_238___0='238 (choice=K (WT))';
	label mut_238___1='238 (choice=N)';
	label mut_238___2='238 (choice=R)';
	label mut_238___3='238 (choice=T)';
	label mut_238___9='238 (choice=Other)';
	label mut_238_other='Other';
	label mut_y318___0='Y318 (choice=Y (WT))';
	label mut_y318___1='Y318 (choice=F)';
	label mut_y318___9='Y318 (choice=Other)';
	label mut_y318_other='Other';
	label mut_333___0='333 (choice=G (WT))';
	label mut_333___1='333 (choice=D)';
	label mut_333___2='333 (choice=E)';
	label mut_333___9='333 (choice=Other)';
	label mut_333_other='Other';
	label mut_n348___0='N348 (choice=N (WT))';
	label mut_n348___1='N348 (choice=I)';
	label mut_n348___9='N348 (choice=Other)';
	label mut_n348_other='Other';
	label other_rt_mut='Other RT Mutations';
	label mut_pi_major='PI Major Mutations';
	label mut_pi_minor='PI Minor Mutations';
	label mut_l10___0='L10 (choice=L (WT))';
	label mut_l10___1='L10 (choice=F)';
	label mut_l10___2='L10 (choice=I)';
	label mut_l10___3='L10 (choice=R)';
	label mut_l10___4='L10 (choice=V)';
	label mut_l10___5='L10 (choice=Y)';
	label mut_l10___9='L10 (choice=Other)';
	label mut_l10_other='Other';
	label mut_v11___0='V11 (choice=V (WT))';
	label mut_v11___1='V11 (choice=I)';
	label mut_v11___9='V11 (choice=Other)';
	label mut_v11_other='Other';
	label mut_13___0='13 (choice=I (WT))';
	label mut_13___1='13 (choice=V)';
	label mut_13___9='13 (choice=Other)';
	label mut_13_other='Other';
	label mut_g16___0='G16 (choice=G (WT))';
	label mut_g16___1='G16 (choice=E)';
	label mut_g16___9='G16 (choice=Other)';
	label mut_g16_other='Other';
	label mut_k20___0='K20 (choice=K (WT))';
	label mut_k20___1='K20 (choice=I)';
	label mut_k20___2='K20 (choice=M)';
	label mut_k20___3='K20 (choice=R)';
	label mut_k20___4='K20 (choice=T)';
	label mut_k20___5='K20 (choice=V)';
	label mut_k20___9='K20 (choice=Other)';
	label mut_k20_other='Other';
	label mut_23___0='23 (choice=L (WT))';
	label mut_23___1='23 (choice=I)';
	label mut_23___9='23 (choice=Other)';
	label mut_23_other='Other';
	label mut_l24___0='L24 (choice=L (WT))';
	label mut_l24___1='L24 (choice=F)';
	label mut_l24___2='L24 (choice=I)';
	label mut_l24___9='L24 (choice=Other)';
	label mut_l24_other='Other';
	label mut_d30___0='D30 (choice=D (WT))';
	label mut_d30___1='D30 (choice=N)';
	label mut_d30___9='D30 (choice=Other)';
	label mut_d30_other='Other';
	label mut_v32___0='V32 (choice=V (WT))';
	label mut_v32___1='V32 (choice=I)';
	label mut_v32___9='V32 (choice=Other)';
	label mut_v32_other='Other';
	label mut_l33___0='L33 (choice=L (WT))';
	label mut_l33___1='L33 (choice=F)';
	label mut_l33___2='L33 (choice=I)';
	label mut_l33___3='L33 (choice=V)';
	label mut_l33___9='L33 (choice=Other)';
	label mut_l33_other='Other';
	label mut_35___0='35 (choice=E (WT))';
	label mut_35___1='35 (choice=G)';
	label mut_35___9='35 (choice=Other)';
	label mut_35_other='Other';
	label mut_m36___0='M36 (choice=M (WT))';
	label mut_m36___1='M36 (choice=I)';
	label mut_m36___2='M36 (choice=L)';
	label mut_m36___3='M36 (choice=T)';
	label mut_m36___4='M36 (choice=V)';
	label mut_m36___9='M36 (choice=Other)';
	label mut_m36_other='Other';
	label mut_k43___0='K43 (choice=K (WT))';
	label mut_k43___1='K43 (choice=T)';
	label mut_k43___9='K43 (choice=Other)';
	label mut_k43_other='Other';
	label mut_m46___0='M46 (choice=M (WT))';
	label mut_m46___1='M46 (choice=I)';
	label mut_m46___2='M46 (choice=L)';
	label mut_m46___3='M46 (choice=V)';
	label mut_m46___9='M46 (choice=Other)';
	label mut_m46_other='Other';
	label mut_i47___0='I47 (choice=I (WT))';
	label mut_i47___1='I47 (choice=A)';
	label mut_i47___2='I47 (choice=V)';
	label mut_i47___9='I47 (choice=Other)';
	label mut_i47_other='Other';
	label mut_g48___0='G48 (choice=G (WT))';
	label mut_g48___1='G48 (choice=A)';
	label mut_g48___2='G48 (choice=M)';
	label mut_g48___3='G48 (choice=Q)';
	label mut_g48___4='G48 (choice=S)';
	label mut_g48___5='G48 (choice=T)';
	label mut_g48___6='G48 (choice=V)';
	label mut_g48___9='G48 (choice=Other)';
	label mut_g48_other='Other';
	label mut_i50___0='I50 (choice=I (WT))';
	label mut_i50___1='I50 (choice=L)';
	label mut_i50___2='I50 (choice=V)';
	label mut_i50___9='I50 (choice=Other)';
	label mut_i50_other='Other';
	label mut_f53___0='F53 (choice=F (WT))';
	label mut_f53___1='F53 (choice=L)';
	label mut_f53___2='F53 (choice=Y)';
	label mut_f53___9='F53 (choice=Other)';
	label mut_f53_other='Other';
	label mut_i54___0='I54 (choice=I (WT))';
	label mut_i54___1='I54 (choice=A)';
	label mut_i54___2='I54 (choice=L)';
	label mut_i54___3='I54 (choice=M)';
	label mut_i54___4='I54 (choice=S)';
	label mut_i54___5='I54 (choice=T)';
	label mut_i54___6='I54 (choice=V)';
	label mut_i54___9='I54 (choice=Other)';
	label mut_i54_other='Other';
	label mut_q58___0='Q58 (choice=Q (WT))';
	label mut_q58___1='Q58 (choice=E)';
	label mut_q58___9='Q58 (choice=Other)';
	label mut_q58_other='Other';
	label mut_d60___0='D60 (choice=D (WT))';
	label mut_d60___1='D60 (choice=E)';
	label mut_d60___9='D60 (choice=Other)';
	label mut_d60_other='Other';
	label mut_i62___0='I62 (choice=I (WT))';
	label mut_i62___1='I62 (choice=V)';
	label mut_i62___9='I62 (choice=Other)';
	label mut_i62_other='Other';
	label mut_l63___0='L63 (choice=L (WT))';
	label mut_l63___1='L63 (choice=P)';
	label mut_l63___9='L63 (choice=Other)';
	label mut_l63_other='Other';
	label mut_a71___0='A71 (choice=A (WT))';
	label mut_a71___1='A71 (choice=I)';
	label mut_a71___2='A71 (choice=L)';
	label mut_a71___3='A71 (choice=T)';
	label mut_a71___4='A71 (choice=V)';
	label mut_a71___9='A71 (choice=Other)';
	label mut_a71_other='Other';
	label mut_g73___0='G73 (choice=G (WT))';
	label mut_g73___1='G73 (choice=A)';
	label mut_g73___2='G73 (choice=C)';
	label mut_g73___3='G73 (choice=S)';
	label mut_g73___4='G73 (choice=T)';
	label mut_g73___9='G73 (choice=Other)';
	label mut_g73_other='Other';
	label mut_t74___0='T74 (choice=T (WT))';
	label mut_t74___1='T74 (choice=P)';
	label mut_t74___2='T74 (choice=S)';
	label mut_t74___9='T74 (choice=Other)';
	label mut_t74_other='Other';
	label mut_l76___0='L76 (choice=L (WT))';
	label mut_l76___1='L76 (choice=V)';
	label mut_l76___9='L76 (choice=Other)';
	label mut_l76_other='Other';
	label mut_v77___0='V77 (choice=V (WT))';
	label mut_v77___1='V77 (choice=I)';
	label mut_v77___9='V77 (choice=Other)';
	label mut_v77_other='Other';
	label mut_v82___0='V82 (choice=V (WT))';
	label mut_v82___1='V82 (choice=A)';
	label mut_v82___2='V82 (choice=C)';
	label mut_v82___3='V82 (choice=F)';
	label mut_v82___4='V82 (choice=I)';
	label mut_v82___5='V82 (choice=L)';
	label mut_v82___6='V82 (choice=M)';
	label mut_v82___7='V82 (choice=S)';
	label mut_v82___8='V82 (choice=T)';
	label mut_v82___9='V82 (choice=Other)';
	label mut_v82_other='Other';
	label mut_n83___0='N83 (choice=N (WT))';
	label mut_n83___1='N83 (choice=D)';
	label mut_n83___9='N83 (choice=Other)';
	label mut_n83_other='Other';
	label mut_i84___0='I84 (choice=I (WT))';
	label mut_i84___1='I84 (choice=A)';
	label mut_i84___2='I84 (choice=C)';
	label mut_i84___3='I84 (choice=V)';
	label mut_i84___9='I84 (choice=Other)';
	label mut_i84_other='Other';
	label mut_i85___0='I85 (choice=I (WT))';
	label mut_i85___1='I85 (choice=V)';
	label mut_i85___9='I85 (choice=Other)';
	label mut_i85_other='Other';
	label mut_n88___0='N88 (choice=N (WT))';
	label mut_n88___1='N88 (choice=D)';
	label mut_n88___2='N88 (choice=G)';
	label mut_n88___3='N88 (choice=S)';
	label mut_n88___4='N88 (choice=T)';
	label mut_n88___9='N88 (choice=Other)';
	label mut_n88_other='Other';
	label mut_l89___0='L89 (choice=L (WT))';
	label mut_l89___1='L89 (choice=I)';
	label mut_l89___2='L89 (choice=M)';
	label mut_l89___3='L89 (choice=T)';
	label mut_l89___4='L89 (choice=V)';
	label mut_l89___9='L89 (choice=Other)';
	label mut_l89_other='Other';
	label mut_l90___0='L90 (choice=L (WT))';
	label mut_l90___1='L90 (choice=M)';
	label mut_l90___9='L90 (choice=Other)';
	label mut_l90_other='Other';
	label mut_i93___0='I93 (choice=I (WT))';
	label mut_i93___1='I93 (choice=L)';
	label mut_i93___2='I93 (choice=M)';
	label mut_i93___9='I93 (choice=Other)';
	label mut_i93_other='Other';
	label resistance_data_1_complete='Complete?';
	run;

proc format;
	value genotype_done_ 1='Done' 2='Not done';
	value resist_3tc_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_abc_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_azt_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_d4t_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_ddi_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_dlv_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_efv_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_etr_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_ftc_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_npv_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_rpv_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value resist_tdf_ 1='Resistant' 2='Intermediate Resistance' 
		3='Possible Resistance' 4='Susceptible' 
		9='Not done';
	value mut_nrti_ 1='Yes' 2='No';
	value mut_nnrti_ 1='Yes' 2='No';
	value mut_m41___0_ 0='Unchecked' 1='Checked';
	value mut_m41___1_ 0='Unchecked' 1='Checked';
	value mut_m41___9_ 0='Unchecked' 1='Checked';
	value mut_44___0_ 0='Unchecked' 1='Checked';
	value mut_44___1_ 0='Unchecked' 1='Checked';
	value mut_44___2_ 0='Unchecked' 1='Checked';
	value mut_44___9_ 0='Unchecked' 1='Checked';
	value mut_a62___0_ 0='Unchecked' 1='Checked';
	value mut_a62___1_ 0='Unchecked' 1='Checked';
	value mut_a62___9_ 0='Unchecked' 1='Checked';
	value mut_k65___0_ 0='Unchecked' 1='Checked';
	value mut_k65___1_ 0='Unchecked' 1='Checked';
	value mut_k65___2_ 0='Unchecked' 1='Checked';
	value mut_k65___9_ 0='Unchecked' 1='Checked';
	value mut_d67___0_ 0='Unchecked' 1='Checked';
	value mut_d67___1_ 0='Unchecked' 1='Checked';
	value mut_d67___2_ 0='Unchecked' 1='Checked';
	value mut_d67___3_ 0='Unchecked' 1='Checked';
	value mut_d67___4_ 0='Unchecked' 1='Checked';
	value mut_d67___9_ 0='Unchecked' 1='Checked';
	value mut_t69___0_ 0='Unchecked' 1='Checked';
	value mut_t69___1_ 0='Unchecked' 1='Checked';
	value mut_t69___2_ 0='Unchecked' 1='Checked';
	value mut_t69___3_ 0='Unchecked' 1='Checked';
	value mut_t69___4_ 0='Unchecked' 1='Checked';
	value mut_t69___5_ 0='Unchecked' 1='Checked';
	value mut_t69___6_ 0='Unchecked' 1='Checked';
	value mut_t69___7_ 0='Unchecked' 1='Checked';
	value mut_t69___9_ 0='Unchecked' 1='Checked';
	value mut_k70___0_ 0='Unchecked' 1='Checked';
	value mut_k70___1_ 0='Unchecked' 1='Checked';
	value mut_k70___2_ 0='Unchecked' 1='Checked';
	value mut_k70___3_ 0='Unchecked' 1='Checked';
	value mut_k70___4_ 0='Unchecked' 1='Checked';
	value mut_k70___9_ 0='Unchecked' 1='Checked';
	value mut_l74___0_ 0='Unchecked' 1='Checked';
	value mut_l74___1_ 0='Unchecked' 1='Checked';
	value mut_l74___2_ 0='Unchecked' 1='Checked';
	value mut_l74___9_ 0='Unchecked' 1='Checked';
	value mut_v75___0_ 0='Unchecked' 1='Checked';
	value mut_v75___1_ 0='Unchecked' 1='Checked';
	value mut_v75___2_ 0='Unchecked' 1='Checked';
	value mut_v75___3_ 0='Unchecked' 1='Checked';
	value mut_v75___4_ 0='Unchecked' 1='Checked';
	value mut_v75___5_ 0='Unchecked' 1='Checked';
	value mut_v75___6_ 0='Unchecked' 1='Checked';
	value mut_v75___9_ 0='Unchecked' 1='Checked';
	value mut_f77___0_ 0='Unchecked' 1='Checked';
	value mut_f77___1_ 0='Unchecked' 1='Checked';
	value mut_f77___9_ 0='Unchecked' 1='Checked';
	value mut_v90___0_ 0='Unchecked' 1='Checked';
	value mut_v90___1_ 0='Unchecked' 1='Checked';
	value mut_v90___9_ 0='Unchecked' 1='Checked';
	value mut_a98___0_ 0='Unchecked' 1='Checked';
	value mut_a98___1_ 0='Unchecked' 1='Checked';
	value mut_a98___2_ 0='Unchecked' 1='Checked';
	value mut_a98___9_ 0='Unchecked' 1='Checked';
	value mut_l100___0_ 0='Unchecked' 1='Checked';
	value mut_l100___1_ 0='Unchecked' 1='Checked';
	value mut_l100___9_ 0='Unchecked' 1='Checked';
	value mut_k101___0_ 0='Unchecked' 1='Checked';
	value mut_k101___1_ 0='Unchecked' 1='Checked';
	value mut_k101___2_ 0='Unchecked' 1='Checked';
	value mut_k101___3_ 0='Unchecked' 1='Checked';
	value mut_k101___4_ 0='Unchecked' 1='Checked';
	value mut_k101___5_ 0='Unchecked' 1='Checked';
	value mut_k101___6_ 0='Unchecked' 1='Checked';
	value mut_k101___9_ 0='Unchecked' 1='Checked';
	value mut_k103___0_ 0='Unchecked' 1='Checked';
	value mut_k103___1_ 0='Unchecked' 1='Checked';
	value mut_k103___2_ 0='Unchecked' 1='Checked';
	value mut_k103___3_ 0='Unchecked' 1='Checked';
	value mut_k103___4_ 0='Unchecked' 1='Checked';
	value mut_k103___5_ 0='Unchecked' 1='Checked';
	value mut_k103___6_ 0='Unchecked' 1='Checked';
	value mut_k103___7_ 0='Unchecked' 1='Checked';
	value mut_k103___9_ 0='Unchecked' 1='Checked';
	value mut_v106___0_ 0='Unchecked' 1='Checked';
	value mut_v106___1_ 0='Unchecked' 1='Checked';
	value mut_v106___2_ 0='Unchecked' 1='Checked';
	value mut_v106___3_ 0='Unchecked' 1='Checked';
	value mut_v106___4_ 0='Unchecked' 1='Checked';
	value mut_v106___9_ 0='Unchecked' 1='Checked';
	value mut_v108___0_ 0='Unchecked' 1='Checked';
	value mut_v108___1_ 0='Unchecked' 1='Checked';
	value mut_v108___9_ 0='Unchecked' 1='Checked';
	value mut_g109___0_ 0='Unchecked' 1='Checked';
	value mut_g109___1_ 0='Unchecked' 1='Checked';
	value mut_g109___2_ 0='Unchecked' 1='Checked';
	value mut_g109___9_ 0='Unchecked' 1='Checked';
	value mut_y115___0_ 0='Unchecked' 1='Checked';
	value mut_y115___1_ 0='Unchecked' 1='Checked';
	value mut_y115___2_ 0='Unchecked' 1='Checked';
	value mut_y115___9_ 0='Unchecked' 1='Checked';
	value mut_f116___0_ 0='Unchecked' 1='Checked';
	value mut_f116___1_ 0='Unchecked' 1='Checked';
	value mut_f116___9_ 0='Unchecked' 1='Checked';
	value mut_118___0_ 0='Unchecked' 1='Checked';
	value mut_118___1_ 0='Unchecked' 1='Checked';
	value mut_118___9_ 0='Unchecked' 1='Checked';
	value mut_e138___0_ 0='Unchecked' 1='Checked';
	value mut_e138___1_ 0='Unchecked' 1='Checked';
	value mut_e138___2_ 0='Unchecked' 1='Checked';
	value mut_e138___3_ 0='Unchecked' 1='Checked';
	value mut_e138___4_ 0='Unchecked' 1='Checked';
	value mut_e138___9_ 0='Unchecked' 1='Checked';
	value mut_q151___0_ 0='Unchecked' 1='Checked';
	value mut_q151___1_ 0='Unchecked' 1='Checked';
	value mut_q151___2_ 0='Unchecked' 1='Checked';
	value mut_q151___9_ 0='Unchecked' 1='Checked';
	value mut_v179___0_ 0='Unchecked' 1='Checked';
	value mut_v179___1_ 0='Unchecked' 1='Checked';
	value mut_v179___2_ 0='Unchecked' 1='Checked';
	value mut_v179___3_ 0='Unchecked' 1='Checked';
	value mut_v179___4_ 0='Unchecked' 1='Checked';
	value mut_v179___5_ 0='Unchecked' 1='Checked';
	value mut_v179___6_ 0='Unchecked' 1='Checked';
	value mut_v179___9_ 0='Unchecked' 1='Checked';
	value mut_y181___0_ 0='Unchecked' 1='Checked';
	value mut_y181___1_ 0='Unchecked' 1='Checked';
	value mut_y181___2_ 0='Unchecked' 1='Checked';
	value mut_y181___3_ 0='Unchecked' 1='Checked';
	value mut_y181___4_ 0='Unchecked' 1='Checked';
	value mut_y181___9_ 0='Unchecked' 1='Checked';
	value mut_m184___0_ 0='Unchecked' 1='Checked';
	value mut_m184___1_ 0='Unchecked' 1='Checked';
	value mut_m184___2_ 0='Unchecked' 1='Checked';
	value mut_m184___3_ 0='Unchecked' 1='Checked';
	value mut_m184___9_ 0='Unchecked' 1='Checked';
	value mut_y188___0_ 0='Unchecked' 1='Checked';
	value mut_y188___1_ 0='Unchecked' 1='Checked';
	value mut_y188___2_ 0='Unchecked' 1='Checked';
	value mut_y188___3_ 0='Unchecked' 1='Checked';
	value mut_y188___4_ 0='Unchecked' 1='Checked';
	value mut_y188___5_ 0='Unchecked' 1='Checked';
	value mut_y188___9_ 0='Unchecked' 1='Checked';
	value mut_g190___0_ 0='Unchecked' 1='Checked';
	value mut_g190___1_ 0='Unchecked' 1='Checked';
	value mut_g190___2_ 0='Unchecked' 1='Checked';
	value mut_g190___3_ 0='Unchecked' 1='Checked';
	value mut_g190___4_ 0='Unchecked' 1='Checked';
	value mut_g190___5_ 0='Unchecked' 1='Checked';
	value mut_g190___6_ 0='Unchecked' 1='Checked';
	value mut_g190___7_ 0='Unchecked' 1='Checked';
	value mut_g190___8_ 0='Unchecked' 1='Checked';
	value mut_g190___9_ 0='Unchecked' 1='Checked';
	value mut_l210___0_ 0='Unchecked' 1='Checked';
	value mut_l210___1_ 0='Unchecked' 1='Checked';
	value mut_l210___2_ 0='Unchecked' 1='Checked';
	value mut_l210___3_ 0='Unchecked' 1='Checked';
	value mut_l210___9_ 0='Unchecked' 1='Checked';
	value mut_t215___0_ 0='Unchecked' 1='Checked';
	value mut_t215___1_ 0='Unchecked' 1='Checked';
	value mut_t215___2_ 0='Unchecked' 1='Checked';
	value mut_t215___3_ 0='Unchecked' 1='Checked';
	value mut_t215___4_ 0='Unchecked' 1='Checked';
	value mut_t215___5_ 0='Unchecked' 1='Checked';
	value mut_t215___6_ 0='Unchecked' 1='Checked';
	value mut_t215___7_ 0='Unchecked' 1='Checked';
	value mut_t215___8_ 0='Unchecked' 1='Checked';
	value mut_t215___9_ 0='Unchecked' 1='Checked';
	value mut_k219___0_ 0='Unchecked' 1='Checked';
	value mut_k219___1_ 0='Unchecked' 1='Checked';
	value mut_k219___2_ 0='Unchecked' 1='Checked';
	value mut_k219___3_ 0='Unchecked' 1='Checked';
	value mut_k219___4_ 0='Unchecked' 1='Checked';
	value mut_k219___5_ 0='Unchecked' 1='Checked';
	value mut_k219___6_ 0='Unchecked' 1='Checked';
	value mut_k219___7_ 0='Unchecked' 1='Checked';
	value mut_k219___9_ 0='Unchecked' 1='Checked';
	value mut_h221___0_ 0='Unchecked' 1='Checked';
	value mut_h221___1_ 0='Unchecked' 1='Checked';
	value mut_h221___9_ 0='Unchecked' 1='Checked';
	value mut_p225___0_ 0='Unchecked' 1='Checked';
	value mut_p225___1_ 0='Unchecked' 1='Checked';
	value mut_p225___9_ 0='Unchecked' 1='Checked';
	value mut_f227___0_ 0='Unchecked' 1='Checked';
	value mut_f227___1_ 0='Unchecked' 1='Checked';
	value mut_f227___2_ 0='Unchecked' 1='Checked';
	value mut_f227___9_ 0='Unchecked' 1='Checked';
	value mut_m230___0_ 0='Unchecked' 1='Checked';
	value mut_m230___1_ 0='Unchecked' 1='Checked';
	value mut_m230___9_ 0='Unchecked' 1='Checked';
	value mut_234___0_ 0='Unchecked' 1='Checked';
	value mut_234___1_ 0='Unchecked' 1='Checked';
	value mut_234___9_ 0='Unchecked' 1='Checked';
	value mut_236___0_ 0='Unchecked' 1='Checked';
	value mut_236___1_ 0='Unchecked' 1='Checked';
	value mut_236___9_ 0='Unchecked' 1='Checked';
	value mut_238___0_ 0='Unchecked' 1='Checked';
	value mut_238___1_ 0='Unchecked' 1='Checked';
	value mut_238___2_ 0='Unchecked' 1='Checked';
	value mut_238___3_ 0='Unchecked' 1='Checked';
	value mut_238___9_ 0='Unchecked' 1='Checked';
	value mut_y318___0_ 0='Unchecked' 1='Checked';
	value mut_y318___1_ 0='Unchecked' 1='Checked';
	value mut_y318___9_ 0='Unchecked' 1='Checked';
	value mut_333___0_ 0='Unchecked' 1='Checked';
	value mut_333___1_ 0='Unchecked' 1='Checked';
	value mut_333___2_ 0='Unchecked' 1='Checked';
	value mut_333___9_ 0='Unchecked' 1='Checked';
	value mut_n348___0_ 0='Unchecked' 1='Checked';
	value mut_n348___1_ 0='Unchecked' 1='Checked';
	value mut_n348___9_ 0='Unchecked' 1='Checked';
	value mut_pi_major_ 1='Yes' 2='No';
	value mut_pi_minor_ 1='Yes' 2='No';
	value mut_l10___0_ 0='Unchecked' 1='Checked';
	value mut_l10___1_ 0='Unchecked' 1='Checked';
	value mut_l10___2_ 0='Unchecked' 1='Checked';
	value mut_l10___3_ 0='Unchecked' 1='Checked';
	value mut_l10___4_ 0='Unchecked' 1='Checked';
	value mut_l10___5_ 0='Unchecked' 1='Checked';
	value mut_l10___9_ 0='Unchecked' 1='Checked';
	value mut_v11___0_ 0='Unchecked' 1='Checked';
	value mut_v11___1_ 0='Unchecked' 1='Checked';
	value mut_v11___9_ 0='Unchecked' 1='Checked';
	value mut_13___0_ 0='Unchecked' 1='Checked';
	value mut_13___1_ 0='Unchecked' 1='Checked';
	value mut_13___9_ 0='Unchecked' 1='Checked';
	value mut_g16___0_ 0='Unchecked' 1='Checked';
	value mut_g16___1_ 0='Unchecked' 1='Checked';
	value mut_g16___9_ 0='Unchecked' 1='Checked';
	value mut_k20___0_ 0='Unchecked' 1='Checked';
	value mut_k20___1_ 0='Unchecked' 1='Checked';
	value mut_k20___2_ 0='Unchecked' 1='Checked';
	value mut_k20___3_ 0='Unchecked' 1='Checked';
	value mut_k20___4_ 0='Unchecked' 1='Checked';
	value mut_k20___5_ 0='Unchecked' 1='Checked';
	value mut_k20___9_ 0='Unchecked' 1='Checked';
	value mut_23___0_ 0='Unchecked' 1='Checked';
	value mut_23___1_ 0='Unchecked' 1='Checked';
	value mut_23___9_ 0='Unchecked' 1='Checked';
	value mut_l24___0_ 0='Unchecked' 1='Checked';
	value mut_l24___1_ 0='Unchecked' 1='Checked';
	value mut_l24___2_ 0='Unchecked' 1='Checked';
	value mut_l24___9_ 0='Unchecked' 1='Checked';
	value mut_d30___0_ 0='Unchecked' 1='Checked';
	value mut_d30___1_ 0='Unchecked' 1='Checked';
	value mut_d30___9_ 0='Unchecked' 1='Checked';
	value mut_v32___0_ 0='Unchecked' 1='Checked';
	value mut_v32___1_ 0='Unchecked' 1='Checked';
	value mut_v32___9_ 0='Unchecked' 1='Checked';
	value mut_l33___0_ 0='Unchecked' 1='Checked';
	value mut_l33___1_ 0='Unchecked' 1='Checked';
	value mut_l33___2_ 0='Unchecked' 1='Checked';
	value mut_l33___3_ 0='Unchecked' 1='Checked';
	value mut_l33___9_ 0='Unchecked' 1='Checked';
	value mut_35___0_ 0='Unchecked' 1='Checked';
	value mut_35___1_ 0='Unchecked' 1='Checked';
	value mut_35___9_ 0='Unchecked' 1='Checked';
	value mut_m36___0_ 0='Unchecked' 1='Checked';
	value mut_m36___1_ 0='Unchecked' 1='Checked';
	value mut_m36___2_ 0='Unchecked' 1='Checked';
	value mut_m36___3_ 0='Unchecked' 1='Checked';
	value mut_m36___4_ 0='Unchecked' 1='Checked';
	value mut_m36___9_ 0='Unchecked' 1='Checked';
	value mut_k43___0_ 0='Unchecked' 1='Checked';
	value mut_k43___1_ 0='Unchecked' 1='Checked';
	value mut_k43___9_ 0='Unchecked' 1='Checked';
	value mut_m46___0_ 0='Unchecked' 1='Checked';
	value mut_m46___1_ 0='Unchecked' 1='Checked';
	value mut_m46___2_ 0='Unchecked' 1='Checked';
	value mut_m46___3_ 0='Unchecked' 1='Checked';
	value mut_m46___9_ 0='Unchecked' 1='Checked';
	value mut_i47___0_ 0='Unchecked' 1='Checked';
	value mut_i47___1_ 0='Unchecked' 1='Checked';
	value mut_i47___2_ 0='Unchecked' 1='Checked';
	value mut_i47___9_ 0='Unchecked' 1='Checked';
	value mut_g48___0_ 0='Unchecked' 1='Checked';
	value mut_g48___1_ 0='Unchecked' 1='Checked';
	value mut_g48___2_ 0='Unchecked' 1='Checked';
	value mut_g48___3_ 0='Unchecked' 1='Checked';
	value mut_g48___4_ 0='Unchecked' 1='Checked';
	value mut_g48___5_ 0='Unchecked' 1='Checked';
	value mut_g48___6_ 0='Unchecked' 1='Checked';
	value mut_g48___9_ 0='Unchecked' 1='Checked';
	value mut_i50___0_ 0='Unchecked' 1='Checked';
	value mut_i50___1_ 0='Unchecked' 1='Checked';
	value mut_i50___2_ 0='Unchecked' 1='Checked';
	value mut_i50___9_ 0='Unchecked' 1='Checked';
	value mut_f53___0_ 0='Unchecked' 1='Checked';
	value mut_f53___1_ 0='Unchecked' 1='Checked';
	value mut_f53___2_ 0='Unchecked' 1='Checked';
	value mut_f53___9_ 0='Unchecked' 1='Checked';
	value mut_i54___0_ 0='Unchecked' 1='Checked';
	value mut_i54___1_ 0='Unchecked' 1='Checked';
	value mut_i54___2_ 0='Unchecked' 1='Checked';
	value mut_i54___3_ 0='Unchecked' 1='Checked';
	value mut_i54___4_ 0='Unchecked' 1='Checked';
	value mut_i54___5_ 0='Unchecked' 1='Checked';
	value mut_i54___6_ 0='Unchecked' 1='Checked';
	value mut_i54___9_ 0='Unchecked' 1='Checked';
	value mut_q58___0_ 0='Unchecked' 1='Checked';
	value mut_q58___1_ 0='Unchecked' 1='Checked';
	value mut_q58___9_ 0='Unchecked' 1='Checked';
	value mut_d60___0_ 0='Unchecked' 1='Checked';
	value mut_d60___1_ 0='Unchecked' 1='Checked';
	value mut_d60___9_ 0='Unchecked' 1='Checked';
	value mut_i62___0_ 0='Unchecked' 1='Checked';
	value mut_i62___1_ 0='Unchecked' 1='Checked';
	value mut_i62___9_ 0='Unchecked' 1='Checked';
	value mut_l63___0_ 0='Unchecked' 1='Checked';
	value mut_l63___1_ 0='Unchecked' 1='Checked';
	value mut_l63___9_ 0='Unchecked' 1='Checked';
	value mut_a71___0_ 0='Unchecked' 1='Checked';
	value mut_a71___1_ 0='Unchecked' 1='Checked';
	value mut_a71___2_ 0='Unchecked' 1='Checked';
	value mut_a71___3_ 0='Unchecked' 1='Checked';
	value mut_a71___4_ 0='Unchecked' 1='Checked';
	value mut_a71___9_ 0='Unchecked' 1='Checked';
	value mut_g73___0_ 0='Unchecked' 1='Checked';
	value mut_g73___1_ 0='Unchecked' 1='Checked';
	value mut_g73___2_ 0='Unchecked' 1='Checked';
	value mut_g73___3_ 0='Unchecked' 1='Checked';
	value mut_g73___4_ 0='Unchecked' 1='Checked';
	value mut_g73___9_ 0='Unchecked' 1='Checked';
	value mut_t74___0_ 0='Unchecked' 1='Checked';
	value mut_t74___1_ 0='Unchecked' 1='Checked';
	value mut_t74___2_ 0='Unchecked' 1='Checked';
	value mut_t74___9_ 0='Unchecked' 1='Checked';
	value mut_l76___0_ 0='Unchecked' 1='Checked';
	value mut_l76___1_ 0='Unchecked' 1='Checked';
	value mut_l76___9_ 0='Unchecked' 1='Checked';
	value mut_v77___0_ 0='Unchecked' 1='Checked';
	value mut_v77___1_ 0='Unchecked' 1='Checked';
	value mut_v77___9_ 0='Unchecked' 1='Checked';
	value mut_v82___0_ 0='Unchecked' 1='Checked';
	value mut_v82___1_ 0='Unchecked' 1='Checked';
	value mut_v82___2_ 0='Unchecked' 1='Checked';
	value mut_v82___3_ 0='Unchecked' 1='Checked';
	value mut_v82___4_ 0='Unchecked' 1='Checked';
	value mut_v82___5_ 0='Unchecked' 1='Checked';
	value mut_v82___6_ 0='Unchecked' 1='Checked';
	value mut_v82___7_ 0='Unchecked' 1='Checked';
	value mut_v82___8_ 0='Unchecked' 1='Checked';
	value mut_v82___9_ 0='Unchecked' 1='Checked';
	value mut_n83___0_ 0='Unchecked' 1='Checked';
	value mut_n83___1_ 0='Unchecked' 1='Checked';
	value mut_n83___9_ 0='Unchecked' 1='Checked';
	value mut_i84___0_ 0='Unchecked' 1='Checked';
	value mut_i84___1_ 0='Unchecked' 1='Checked';
	value mut_i84___2_ 0='Unchecked' 1='Checked';
	value mut_i84___3_ 0='Unchecked' 1='Checked';
	value mut_i84___9_ 0='Unchecked' 1='Checked';
	value mut_i85___0_ 0='Unchecked' 1='Checked';
	value mut_i85___1_ 0='Unchecked' 1='Checked';
	value mut_i85___9_ 0='Unchecked' 1='Checked';
	value mut_n88___0_ 0='Unchecked' 1='Checked';
	value mut_n88___1_ 0='Unchecked' 1='Checked';
	value mut_n88___2_ 0='Unchecked' 1='Checked';
	value mut_n88___3_ 0='Unchecked' 1='Checked';
	value mut_n88___4_ 0='Unchecked' 1='Checked';
	value mut_n88___9_ 0='Unchecked' 1='Checked';
	value mut_l89___0_ 0='Unchecked' 1='Checked';
	value mut_l89___1_ 0='Unchecked' 1='Checked';
	value mut_l89___2_ 0='Unchecked' 1='Checked';
	value mut_l89___3_ 0='Unchecked' 1='Checked';
	value mut_l89___4_ 0='Unchecked' 1='Checked';
	value mut_l89___9_ 0='Unchecked' 1='Checked';
	value mut_l90___0_ 0='Unchecked' 1='Checked';
	value mut_l90___1_ 0='Unchecked' 1='Checked';
	value mut_l90___9_ 0='Unchecked' 1='Checked';
	value mut_i93___0_ 0='Unchecked' 1='Checked';
	value mut_i93___1_ 0='Unchecked' 1='Checked';
	value mut_i93___2_ 0='Unchecked' 1='Checked';
	value mut_i93___9_ 0='Unchecked' 1='Checked';
	value resistance_data_1_complete_ 0='Incomplete' 1='Unverified' 
		2='Complete';
	run;

data redcap;
	set redcap;

	format genotype_done genotype_done_.;
	format resist_3tc resist_3tc_.;
	format resist_abc resist_abc_.;
	format resist_azt resist_azt_.;
	format resist_d4t resist_d4t_.;
	format resist_ddi resist_ddi_.;
	format resist_dlv resist_dlv_.;
	format resist_efv resist_efv_.;
	format resist_etr resist_etr_.;
	format resist_ftc resist_ftc_.;
	format resist_npv resist_npv_.;
	format resist_rpv resist_rpv_.;
	format resist_tdf resist_tdf_.;
	format mut_nrti mut_nrti_.;
	format mut_nnrti mut_nnrti_.;
	format mut_m41___0 mut_m41___0_.;
	format mut_m41___1 mut_m41___1_.;
	format mut_m41___9 mut_m41___9_.;
	format mut_44___0 mut_44___0_.;
	format mut_44___1 mut_44___1_.;
	format mut_44___2 mut_44___2_.;
	format mut_44___9 mut_44___9_.;
	format mut_a62___0 mut_a62___0_.;
	format mut_a62___1 mut_a62___1_.;
	format mut_a62___9 mut_a62___9_.;
	format mut_k65___0 mut_k65___0_.;
	format mut_k65___1 mut_k65___1_.;
	format mut_k65___2 mut_k65___2_.;
	format mut_k65___9 mut_k65___9_.;
	format mut_d67___0 mut_d67___0_.;
	format mut_d67___1 mut_d67___1_.;
	format mut_d67___2 mut_d67___2_.;
	format mut_d67___3 mut_d67___3_.;
	format mut_d67___4 mut_d67___4_.;
	format mut_d67___9 mut_d67___9_.;
	format mut_t69___0 mut_t69___0_.;
	format mut_t69___1 mut_t69___1_.;
	format mut_t69___2 mut_t69___2_.;
	format mut_t69___3 mut_t69___3_.;
	format mut_t69___4 mut_t69___4_.;
	format mut_t69___5 mut_t69___5_.;
	format mut_t69___6 mut_t69___6_.;
	format mut_t69___7 mut_t69___7_.;
	format mut_t69___9 mut_t69___9_.;
	format mut_k70___0 mut_k70___0_.;
	format mut_k70___1 mut_k70___1_.;
	format mut_k70___2 mut_k70___2_.;
	format mut_k70___3 mut_k70___3_.;
	format mut_k70___4 mut_k70___4_.;
	format mut_k70___9 mut_k70___9_.;
	format mut_l74___0 mut_l74___0_.;
	format mut_l74___1 mut_l74___1_.;
	format mut_l74___2 mut_l74___2_.;
	format mut_l74___9 mut_l74___9_.;
	format mut_v75___0 mut_v75___0_.;
	format mut_v75___1 mut_v75___1_.;
	format mut_v75___2 mut_v75___2_.;
	format mut_v75___3 mut_v75___3_.;
	format mut_v75___4 mut_v75___4_.;
	format mut_v75___5 mut_v75___5_.;
	format mut_v75___6 mut_v75___6_.;
	format mut_v75___9 mut_v75___9_.;
	format mut_f77___0 mut_f77___0_.;
	format mut_f77___1 mut_f77___1_.;
	format mut_f77___9 mut_f77___9_.;
	format mut_v90___0 mut_v90___0_.;
	format mut_v90___1 mut_v90___1_.;
	format mut_v90___9 mut_v90___9_.;
	format mut_a98___0 mut_a98___0_.;
	format mut_a98___1 mut_a98___1_.;
	format mut_a98___2 mut_a98___2_.;
	format mut_a98___9 mut_a98___9_.;
	format mut_l100___0 mut_l100___0_.;
	format mut_l100___1 mut_l100___1_.;
	format mut_l100___9 mut_l100___9_.;
	format mut_k101___0 mut_k101___0_.;
	format mut_k101___1 mut_k101___1_.;
	format mut_k101___2 mut_k101___2_.;
	format mut_k101___3 mut_k101___3_.;
	format mut_k101___4 mut_k101___4_.;
	format mut_k101___5 mut_k101___5_.;
	format mut_k101___6 mut_k101___6_.;
	format mut_k101___9 mut_k101___9_.;
	format mut_k103___0 mut_k103___0_.;
	format mut_k103___1 mut_k103___1_.;
	format mut_k103___2 mut_k103___2_.;
	format mut_k103___3 mut_k103___3_.;
	format mut_k103___4 mut_k103___4_.;
	format mut_k103___5 mut_k103___5_.;
	format mut_k103___6 mut_k103___6_.;
	format mut_k103___7 mut_k103___7_.;
	format mut_k103___9 mut_k103___9_.;
	format mut_v106___0 mut_v106___0_.;
	format mut_v106___1 mut_v106___1_.;
	format mut_v106___2 mut_v106___2_.;
	format mut_v106___3 mut_v106___3_.;
	format mut_v106___4 mut_v106___4_.;
	format mut_v106___9 mut_v106___9_.;
	format mut_v108___0 mut_v108___0_.;
	format mut_v108___1 mut_v108___1_.;
	format mut_v108___9 mut_v108___9_.;
	format mut_g109___0 mut_g109___0_.;
	format mut_g109___1 mut_g109___1_.;
	format mut_g109___2 mut_g109___2_.;
	format mut_g109___9 mut_g109___9_.;
	format mut_y115___0 mut_y115___0_.;
	format mut_y115___1 mut_y115___1_.;
	format mut_y115___2 mut_y115___2_.;
	format mut_y115___9 mut_y115___9_.;
	format mut_f116___0 mut_f116___0_.;
	format mut_f116___1 mut_f116___1_.;
	format mut_f116___9 mut_f116___9_.;
	format mut_118___0 mut_118___0_.;
	format mut_118___1 mut_118___1_.;
	format mut_118___9 mut_118___9_.;
	format mut_e138___0 mut_e138___0_.;
	format mut_e138___1 mut_e138___1_.;
	format mut_e138___2 mut_e138___2_.;
	format mut_e138___3 mut_e138___3_.;
	format mut_e138___4 mut_e138___4_.;
	format mut_e138___9 mut_e138___9_.;
	format mut_q151___0 mut_q151___0_.;
	format mut_q151___1 mut_q151___1_.;
	format mut_q151___2 mut_q151___2_.;
	format mut_q151___9 mut_q151___9_.;
	format mut_v179___0 mut_v179___0_.;
	format mut_v179___1 mut_v179___1_.;
	format mut_v179___2 mut_v179___2_.;
	format mut_v179___3 mut_v179___3_.;
	format mut_v179___4 mut_v179___4_.;
	format mut_v179___5 mut_v179___5_.;
	format mut_v179___6 mut_v179___6_.;
	format mut_v179___9 mut_v179___9_.;
	format mut_y181___0 mut_y181___0_.;
	format mut_y181___1 mut_y181___1_.;
	format mut_y181___2 mut_y181___2_.;
	format mut_y181___3 mut_y181___3_.;
	format mut_y181___4 mut_y181___4_.;
	format mut_y181___9 mut_y181___9_.;
	format mut_m184___0 mut_m184___0_.;
	format mut_m184___1 mut_m184___1_.;
	format mut_m184___2 mut_m184___2_.;
	format mut_m184___3 mut_m184___3_.;
	format mut_m184___9 mut_m184___9_.;
	format mut_y188___0 mut_y188___0_.;
	format mut_y188___1 mut_y188___1_.;
	format mut_y188___2 mut_y188___2_.;
	format mut_y188___3 mut_y188___3_.;
	format mut_y188___4 mut_y188___4_.;
	format mut_y188___5 mut_y188___5_.;
	format mut_y188___9 mut_y188___9_.;
	format mut_g190___0 mut_g190___0_.;
	format mut_g190___1 mut_g190___1_.;
	format mut_g190___2 mut_g190___2_.;
	format mut_g190___3 mut_g190___3_.;
	format mut_g190___4 mut_g190___4_.;
	format mut_g190___5 mut_g190___5_.;
	format mut_g190___6 mut_g190___6_.;
	format mut_g190___7 mut_g190___7_.;
	format mut_g190___8 mut_g190___8_.;
	format mut_g190___9 mut_g190___9_.;
	format mut_l210___0 mut_l210___0_.;
	format mut_l210___1 mut_l210___1_.;
	format mut_l210___2 mut_l210___2_.;
	format mut_l210___3 mut_l210___3_.;
	format mut_l210___9 mut_l210___9_.;
	format mut_t215___0 mut_t215___0_.;
	format mut_t215___1 mut_t215___1_.;
	format mut_t215___2 mut_t215___2_.;
	format mut_t215___3 mut_t215___3_.;
	format mut_t215___4 mut_t215___4_.;
	format mut_t215___5 mut_t215___5_.;
	format mut_t215___6 mut_t215___6_.;
	format mut_t215___7 mut_t215___7_.;
	format mut_t215___8 mut_t215___8_.;
	format mut_t215___9 mut_t215___9_.;
	format mut_k219___0 mut_k219___0_.;
	format mut_k219___1 mut_k219___1_.;
	format mut_k219___2 mut_k219___2_.;
	format mut_k219___3 mut_k219___3_.;
	format mut_k219___4 mut_k219___4_.;
	format mut_k219___5 mut_k219___5_.;
	format mut_k219___6 mut_k219___6_.;
	format mut_k219___7 mut_k219___7_.;
	format mut_k219___9 mut_k219___9_.;
	format mut_h221___0 mut_h221___0_.;
	format mut_h221___1 mut_h221___1_.;
	format mut_h221___9 mut_h221___9_.;
	format mut_p225___0 mut_p225___0_.;
	format mut_p225___1 mut_p225___1_.;
	format mut_p225___9 mut_p225___9_.;
	format mut_f227___0 mut_f227___0_.;
	format mut_f227___1 mut_f227___1_.;
	format mut_f227___2 mut_f227___2_.;
	format mut_f227___9 mut_f227___9_.;
	format mut_m230___0 mut_m230___0_.;
	format mut_m230___1 mut_m230___1_.;
	format mut_m230___9 mut_m230___9_.;
	format mut_234___0 mut_234___0_.;
	format mut_234___1 mut_234___1_.;
	format mut_234___9 mut_234___9_.;
	format mut_236___0 mut_236___0_.;
	format mut_236___1 mut_236___1_.;
	format mut_236___9 mut_236___9_.;
	format mut_238___0 mut_238___0_.;
	format mut_238___1 mut_238___1_.;
	format mut_238___2 mut_238___2_.;
	format mut_238___3 mut_238___3_.;
	format mut_238___9 mut_238___9_.;
	format mut_y318___0 mut_y318___0_.;
	format mut_y318___1 mut_y318___1_.;
	format mut_y318___9 mut_y318___9_.;
	format mut_333___0 mut_333___0_.;
	format mut_333___1 mut_333___1_.;
	format mut_333___2 mut_333___2_.;
	format mut_333___9 mut_333___9_.;
	format mut_n348___0 mut_n348___0_.;
	format mut_n348___1 mut_n348___1_.;
	format mut_n348___9 mut_n348___9_.;
	format mut_pi_major mut_pi_major_.;
	format mut_pi_minor mut_pi_minor_.;
	format mut_l10___0 mut_l10___0_.;
	format mut_l10___1 mut_l10___1_.;
	format mut_l10___2 mut_l10___2_.;
	format mut_l10___3 mut_l10___3_.;
	format mut_l10___4 mut_l10___4_.;
	format mut_l10___5 mut_l10___5_.;
	format mut_l10___9 mut_l10___9_.;
	format mut_v11___0 mut_v11___0_.;
	format mut_v11___1 mut_v11___1_.;
	format mut_v11___9 mut_v11___9_.;
	format mut_13___0 mut_13___0_.;
	format mut_13___1 mut_13___1_.;
	format mut_13___9 mut_13___9_.;
	format mut_g16___0 mut_g16___0_.;
	format mut_g16___1 mut_g16___1_.;
	format mut_g16___9 mut_g16___9_.;
	format mut_k20___0 mut_k20___0_.;
	format mut_k20___1 mut_k20___1_.;
	format mut_k20___2 mut_k20___2_.;
	format mut_k20___3 mut_k20___3_.;
	format mut_k20___4 mut_k20___4_.;
	format mut_k20___5 mut_k20___5_.;
	format mut_k20___9 mut_k20___9_.;
	format mut_23___0 mut_23___0_.;
	format mut_23___1 mut_23___1_.;
	format mut_23___9 mut_23___9_.;
	format mut_l24___0 mut_l24___0_.;
	format mut_l24___1 mut_l24___1_.;
	format mut_l24___2 mut_l24___2_.;
	format mut_l24___9 mut_l24___9_.;
	format mut_d30___0 mut_d30___0_.;
	format mut_d30___1 mut_d30___1_.;
	format mut_d30___9 mut_d30___9_.;
	format mut_v32___0 mut_v32___0_.;
	format mut_v32___1 mut_v32___1_.;
	format mut_v32___9 mut_v32___9_.;
	format mut_l33___0 mut_l33___0_.;
	format mut_l33___1 mut_l33___1_.;
	format mut_l33___2 mut_l33___2_.;
	format mut_l33___3 mut_l33___3_.;
	format mut_l33___9 mut_l33___9_.;
	format mut_35___0 mut_35___0_.;
	format mut_35___1 mut_35___1_.;
	format mut_35___9 mut_35___9_.;
	format mut_m36___0 mut_m36___0_.;
	format mut_m36___1 mut_m36___1_.;
	format mut_m36___2 mut_m36___2_.;
	format mut_m36___3 mut_m36___3_.;
	format mut_m36___4 mut_m36___4_.;
	format mut_m36___9 mut_m36___9_.;
	format mut_k43___0 mut_k43___0_.;
	format mut_k43___1 mut_k43___1_.;
	format mut_k43___9 mut_k43___9_.;
	format mut_m46___0 mut_m46___0_.;
	format mut_m46___1 mut_m46___1_.;
	format mut_m46___2 mut_m46___2_.;
	format mut_m46___3 mut_m46___3_.;
	format mut_m46___9 mut_m46___9_.;
	format mut_i47___0 mut_i47___0_.;
	format mut_i47___1 mut_i47___1_.;
	format mut_i47___2 mut_i47___2_.;
	format mut_i47___9 mut_i47___9_.;
	format mut_g48___0 mut_g48___0_.;
	format mut_g48___1 mut_g48___1_.;
	format mut_g48___2 mut_g48___2_.;
	format mut_g48___3 mut_g48___3_.;
	format mut_g48___4 mut_g48___4_.;
	format mut_g48___5 mut_g48___5_.;
	format mut_g48___6 mut_g48___6_.;
	format mut_g48___9 mut_g48___9_.;
	format mut_i50___0 mut_i50___0_.;
	format mut_i50___1 mut_i50___1_.;
	format mut_i50___2 mut_i50___2_.;
	format mut_i50___9 mut_i50___9_.;
	format mut_f53___0 mut_f53___0_.;
	format mut_f53___1 mut_f53___1_.;
	format mut_f53___2 mut_f53___2_.;
	format mut_f53___9 mut_f53___9_.;
	format mut_i54___0 mut_i54___0_.;
	format mut_i54___1 mut_i54___1_.;
	format mut_i54___2 mut_i54___2_.;
	format mut_i54___3 mut_i54___3_.;
	format mut_i54___4 mut_i54___4_.;
	format mut_i54___5 mut_i54___5_.;
	format mut_i54___6 mut_i54___6_.;
	format mut_i54___9 mut_i54___9_.;
	format mut_q58___0 mut_q58___0_.;
	format mut_q58___1 mut_q58___1_.;
	format mut_q58___9 mut_q58___9_.;
	format mut_d60___0 mut_d60___0_.;
	format mut_d60___1 mut_d60___1_.;
	format mut_d60___9 mut_d60___9_.;
	format mut_i62___0 mut_i62___0_.;
	format mut_i62___1 mut_i62___1_.;
	format mut_i62___9 mut_i62___9_.;
	format mut_l63___0 mut_l63___0_.;
	format mut_l63___1 mut_l63___1_.;
	format mut_l63___9 mut_l63___9_.;
	format mut_a71___0 mut_a71___0_.;
	format mut_a71___1 mut_a71___1_.;
	format mut_a71___2 mut_a71___2_.;
	format mut_a71___3 mut_a71___3_.;
	format mut_a71___4 mut_a71___4_.;
	format mut_a71___9 mut_a71___9_.;
	format mut_g73___0 mut_g73___0_.;
	format mut_g73___1 mut_g73___1_.;
	format mut_g73___2 mut_g73___2_.;
	format mut_g73___3 mut_g73___3_.;
	format mut_g73___4 mut_g73___4_.;
	format mut_g73___9 mut_g73___9_.;
	format mut_t74___0 mut_t74___0_.;
	format mut_t74___1 mut_t74___1_.;
	format mut_t74___2 mut_t74___2_.;
	format mut_t74___9 mut_t74___9_.;
	format mut_l76___0 mut_l76___0_.;
	format mut_l76___1 mut_l76___1_.;
	format mut_l76___9 mut_l76___9_.;
	format mut_v77___0 mut_v77___0_.;
	format mut_v77___1 mut_v77___1_.;
	format mut_v77___9 mut_v77___9_.;
	format mut_v82___0 mut_v82___0_.;
	format mut_v82___1 mut_v82___1_.;
	format mut_v82___2 mut_v82___2_.;
	format mut_v82___3 mut_v82___3_.;
	format mut_v82___4 mut_v82___4_.;
	format mut_v82___5 mut_v82___5_.;
	format mut_v82___6 mut_v82___6_.;
	format mut_v82___7 mut_v82___7_.;
	format mut_v82___8 mut_v82___8_.;
	format mut_v82___9 mut_v82___9_.;
	format mut_n83___0 mut_n83___0_.;
	format mut_n83___1 mut_n83___1_.;
	format mut_n83___9 mut_n83___9_.;
	format mut_i84___0 mut_i84___0_.;
	format mut_i84___1 mut_i84___1_.;
	format mut_i84___2 mut_i84___2_.;
	format mut_i84___3 mut_i84___3_.;
	format mut_i84___9 mut_i84___9_.;
	format mut_i85___0 mut_i85___0_.;
	format mut_i85___1 mut_i85___1_.;
	format mut_i85___9 mut_i85___9_.;
	format mut_n88___0 mut_n88___0_.;
	format mut_n88___1 mut_n88___1_.;
	format mut_n88___2 mut_n88___2_.;
	format mut_n88___3 mut_n88___3_.;
	format mut_n88___4 mut_n88___4_.;
	format mut_n88___9 mut_n88___9_.;
	format mut_l89___0 mut_l89___0_.;
	format mut_l89___1 mut_l89___1_.;
	format mut_l89___2 mut_l89___2_.;
	format mut_l89___3 mut_l89___3_.;
	format mut_l89___4 mut_l89___4_.;
	format mut_l89___9 mut_l89___9_.;
	format mut_l90___0 mut_l90___0_.;
	format mut_l90___1 mut_l90___1_.;
	format mut_l90___9 mut_l90___9_.;
	format mut_i93___0 mut_i93___0_.;
	format mut_i93___1 mut_i93___1_.;
	format mut_i93___2 mut_i93___2_.;
	format mut_i93___9 mut_i93___9_.;
	format resistance_data_1_complete resistance_data_1_complete_.;
	run;

data brent.rest1;
	set redcap;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	
	mut_nrti0=abs(mut_nrti-2);
	mut_nnrti0=abs(mut_nnrti-2);
	mut_pi_major0=abs(mut_pi_major-2);
	mut_pi_minor0=abs(mut_pi_minor-2);

	if idx then if sum(of mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0)>=1 then mut=1; 
		else if sum(of mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0)^=. then mut=0;
	*drop mut_nrti0 mut_nnrti0 mut_pi_major0 mut_pi_minor0;
run;
proc print;run;

proc freq data=brent.rest1(where=(idx=1)); 
tables mut;
run;

proc contents data=brent.rest1 short varnum; run;
