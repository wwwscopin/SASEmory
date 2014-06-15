options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\rest1.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='Viral Load at Enrollment'
	2='HPP Recent Viral Load'
	3='Recent Viral Load at McCord'
	4='Genotype done'

	5='3TC'
	6='ABC'
	7='AZT'
	8='D4T'
	9='DDI'
	10='DLV'
	11='EFV'
	12='ETR'
	13='FTC'
	14='NPV'
	15='RPV'
	16='TDF'
	17='NRTI Mutations'
	18='NNRTI Mutations'
	19='PI Major Mutations'
	20='PI Minor Mutations'

	21='M41'
	22='44'
	23='A62'
	24='K65'
	25='D67'
	26='T69'
	27='K70'
	28='L74'
	29='V75'
	30='F77'
	31='V90'
	32='A98'
	33='L100'
	34='K101'
	35='K103'
	36='V106'
	37='V108'
	38='G109'
	39='Y115'
	40='F116'
	41='118'
	42='E138'
	43='Q151'
	44='V179'
	45='Y181'
	46='M184'
	47='Y188'
	48='G190'
	49='L210'
	50='T215'
	51='K219'
	52='H221'
	53='F227'
	54='M230'
	55='234'
	56='236'
	57='238'
	58='Y318'
	59='333'
	60='N348'

	61='L10'
	62='V11'
	63='13'
	64='G16'
	65='K20'
	66='23'
	67='L24'
	68='D30'
	69='V32'
	70='L33'
	71='35'
	72='M36'
	73='K43'
	74='M46'
	75='I47'
	76='G48'
	77='I50'
	78='F53'
	79='I54'
	80='Q58'
	81='D60'
	82='I62'
	83='L63'
	84='A71'
	85='G73'
	86='T74'
	87='L76'
	88='V77'
	89='V82'
	90='N83'
	91='I84 '
	92='I85'
	93='N88'
	94='L89'
	95='L90'
	96='I93'
	;

	value mut_m41_ 0='M (WT)' 1='L' 9='Other';
	value mut_44_  0='E (WT)' 1='A' 2='D'  9='Other';
	value mut_A62_ 0='A (WT)' 1='V' 9='Other';
	value mut_K65_ 0='K (WT)' 1='N' 2='R' 9='Other';
	value mut_D67_  0='D (WT)' 1='E' 2='G' 3='N' 4='d' 9='Other';
	value mut_T69_ 0='T (WT)' 1='A' 2='D' 3='G' 4='I' 5='N' 6='S' 7='i' 9='Other';
	value mut_K70_ 0='K (WT)' 1='E' 2='G' 3='R' 4='T' 9='Other';
	value mut_L74_ 0='L (WT)' 1='I' 2='V' 9='Other';
	value mut_V75_ 0='V (WT)' 1='A' 2='I' 3='L' 4='M' 5='S' 6='T' 9='Other';
	value mut_F77_ 0='F (WT)' 1='L' 9='Other';
	value mut_V90_ 0='V (WT)' 1='I' 9='Other';
	value mut_A98_ 0='A (WT)' 1='G' 2='S' 9='Other';
	value mut_L100_ 0='L (WT)' 1='I' 9='Other';
	value mut_K101_ 0='K (WT)' 1='E' 2='H' 3='N' 4='P' 5='Q' 6='R' 9='Other';
	value mut_K103_ 0='K (WT)' 1='E' 2='H' 3='N' 4='Q' 5='R' 6='S' 7='T' 9='Other';
	value mut_V106_ 0='V (WT)' 1='A' 2='I' 3='L' 4='M' 9='Other';
	value mut_V108_ 0='V (WT)' 1='I' 9='Other';
	value mut_G109_ 0='G (WT)' 1='E' 2='S' 9='Other';
	value mut_Y115_ 0='Y (WT)' 1='F' 2='S' 9='Other';
	value mut_F116_ 0='F (WT)' 1='Y' 9='Other';
	value mut_118_ 0='V (WT)' 1='I' 9='Other';
	value mut_E138_ 0='E (WT)' 1='A' 2='G' 3='K' 4='Q' 9='Other';
	value mut_Q151_ 0='Q (WT)' 1='L' 2='M' 9='Other';
	value mut_V179_ 0='V (WT)' 1='D' 2='E' 3='F' 4='I' 5='T' 6='Y' 9='Other';
	value mut_Y181_ 0='Y (WT)' 1='C' 2='I' 3='S' 4='V' 9='Other';
	value mut_M184_ 0='M (WT)' 1='C' 2='I' 3='V' 9='Other';
	value mut_Y188_ 0='Y (WT)' 1='C' 2='F' 3='H' 4='L' 5='N' 9='Other';
	value mut_G190_ 0='G (WT)' 1='A' 2='C' 3='D' 4='E' 5='Q' 6='S' 7='T' 8='V' 9='Other';
	value mut_L210_ 0='L (WT)' 1='F' 2='S' 3='W' 9='Other';
	value mut_T215_ 0='T (WT)' 1='C' 2='D' 3='E' 4='F' 5='I' 6='S' 7='V' 8='Y' 9='Other';
	value mut_K219_ 0='K (WT)' 1='D' 2='E' 3='H' 4='N' 5='Q' 6='R' 7='W' 9='Other';
	value mut_H221_ 0='H (WT)' 1='Y' 9='Other';
	value mut_P225_ 0='P (WT)' 1='H' 9='Other'; 
	value mut_F227_ 0='F (WT)' 1='C' 2='L' 9='Other';
	value mut_M230_ 0='M (WT)' 1='L' 9='Other';
	value mut_234_  0='L (WT)' 1='I' 9='Other';
	value mut_236_  0='P (WT)' 1='L' 9='Other';
	value mut_238_  0='K (WT)' 1='N' 2='R' 3='T' 9='Other';
	value mut_Y318_ 0='Y (WT)' 1='F' 9='Other';
	value mut_333_  0='G (WT)' 1='D' 2='E' 9='Other';
	value mut_N348_ 0='N (WT)' 1='I' 9='Other';
	value mut_L10_  0='L (WT)' 1='F' 2='I' 3='R' 4='V' 5='Y' 9='Other';
	value mut_V11_  0='V (WT)' 1='I' 9='Other';
	value mut_13_   0='I (WT)' 1='V' 9='Other';
	value mut_G16_  0='G (WT)' 1='E' 9='Other';
	value mut_K20_  0='K (WT)' 1='I' 2='M' 3='R' 4='T' 5='V' 9='Other';
	value mut_23_   0='L (WT)' 1='I' 9='Other';
	value mut_L24_  0='L (WT)' 1='F' 2='I' 9='Other';
	value mut_D30_  0='D (WT)' 1='N' 9='Other';
	value mut_V32_  0='V (WT)' 1='I' 9='Other';
	value mut_L33_  0='L (WT)' 1='F' 2='I' 3='V' 9='Other';
	value mut_35_   0='E (WT)' 1='G' 9='Other';
	value mut_M36_  0='M (WT)' 1='I' 2='L' 3='T' 4='V' 9='Other';
	value mut_K43_  0='K (WT)' 1='T' 9='Other';
	value mut_M46_  0='M (WT)' 1='I' 2='L' 3='V' 9='Other';
	value mut_I47_  0='I (WT)' 1='A' 2='V' 9='Other';
	value mut_G48_  0='G (WT)' 1='A' 2='M' 3='Q' 4='S' 5='T' 6='V' 9='Other';
	value mut_I50_  0='I (WT)' 1='L' 2='V' 9='Other';
	value mut_F53_  0='F (WT)' 1='L' 2='Y' 9='Other';
	value mut_I54_  0='I (WT)' 1='A' 2='L' 3='M' 4='S' 5='T' 7='V' 9='Other';
	value mut_Q58_  0='Q (WT)' 1='E' 9='Other';
	value mut_D60_  0='D (WT)' 1='E' 9='Other';
	value mut_I62_  0='I (WT)' 1='V' 9='Other';
	value mut_L63_  0='L (WT)' 1='P' 9='Other';
	value mut_A71_  0='A (WT)' 1='I' 2='L' 3='T' 4='V' 9='Other';
	value mut_G73_  0='G (WT)' 1='A' 2='C' 3='S' 4='T' 9='Other';
	value mut_T74_  0='T (WT)' 1='P' 2='S' 9='Other';
	value mut_L76_  0='L (WT)' 1='V' 9='Other';
	value mut_V77_  0='V (WT)' 1='I' 9='Other';
	value mut_V82_  0='V (WT)' 1='A' 2='C' 3='F' 4='I' 5='L' 6='M' 7='S' 8='T' 9='Other';
	value mut_N83_  0='N (WT)' 1='D' 9='Other';
	value mut_I84_  0='I (WT)' 1='A' 2='C' 3='V' 9='Other';
	value mut_I85_  0='I (WT)' 1='V' 9='Other';
	value mut_N88_  0='N (WT)' 1='D' 2='G' 3='S' 4='T' 9='Other';
	value mut_L89_  0='L (WT)' 1='I' 2='M' 3='T' 4='V' 9='Other';
	value mut_L90_  0='L (WT)' 1='M' 9='Other';
	value mut_I93_  0='I (WT)' 1='L' 2='M' 9='Other';

	value genotype_done 1='Done' 2='Not done';
	value rest 1='Resistant' 2='Intermediate Resistance' 3='Possible Resistance' 4='Susceptible' 9='Not done';

	value yn 1="Yes" 2="No";
	value ny 0="No" 1="Yes";
	value idx 0="Control" 1="Case";
run;


data rest1;
	set brent.rest1(rename=(vl_enroll=vl_enroll0 vl_mccord=vl_mccord0 hpp_recent=hpp_recent0));
	vl_enroll=vl_enroll0+0;
	vl_mccord=vl_mccord0+0;
	hpp_recent=hpp_recent0+0;


	drop vl_enroll0 vl_mccord0 hpp_recent0;

	if mut_m41___0  then mut_m41=0;  if mut_m41___1  then mut_m41=1;  if mut_m41___9  then mut_m41=9;
	if mut_44___0   then mut_44=0;  if mut_44___1   then mut_44=1;  if mut_44___2   then mut_44=2;  if mut_44___9   then mut_44=9;
	if mut_a62___0  then mut_a62=0;  if mut_a62___1  then mut_a62=1;  if mut_a62___9  then mut_a62=9;
	if mut_k65___0  then mut_k65=0;  if mut_k65___1  then mut_k65=1;  if mut_k65___2  then mut_k65=2;  if mut_k65___9  then mut_k65=9; 

	if mut_d67___0  then mut_d67=0;  if mut_d67___1  then mut_d67=1;  if mut_d67___2  then mut_d67=2;  if mut_d67___3  then mut_d67=3;  if mut_d67___4  then mut_d67=4; if mut_d67___9  then mut_d67=9;
	if mut_t69___0  then mut_t69=0;  if mut_t69___1  then mut_t69=1;  if mut_t69___2  then mut_t69=2;  if mut_t69___3  then mut_t69=3;  if mut_t69___4  then mut_t69=4; if mut_t69___5  then mut_t69=5; if mut_t69___6 then mut_t69=6; if mut_t69___7 then mut_t69=7; if  mut_t69___9 then mut_t69=9;
	if mut_k70___0  then mut_k70=0;  if mut_k70___1  then mut_k70=1;  if mut_k70___2  then mut_k70=2;  if mut_k70___3  then mut_k70=3;	if mut_k70___4  then mut_k70=4; if mut_k70___9  then mut_k70=9;
	if mut_l74___0  then mut_l74=0;  if mut_l74___1  then mut_l74=1;  if mut_l74___2  then mut_l74=2;  if mut_l74___9  then mut_l74=9; 
	if mut_v75___0  then mut_v75=0;  if mut_v75___1  then mut_v75=1;  if mut_v75___2  then mut_v75=2;  if mut_v75___3  then mut_v75=3;  if mut_v75___4  then mut_v75=4; if mut_v75___5  then mut_v75=5; if mut_v75___6 then mut_v75=6; if mut_v75___9 then mut_v75=9;
	if mut_f77___0  then mut_f77=0;  if mut_f77___1  then mut_f77=1;  if mut_f77___9  then mut_f77=9; 
	if mut_v90___0  then mut_v90=0;  if mut_v90___1  then mut_v90=1;  if mut_v90___9  then mut_v90=9; 
	if mut_a98___0  then mut_a98=0;  if mut_a98___1  then mut_a98=1;  if mut_a98___2  then mut_a98=2;  if mut_a98___9 then mut_a98=9; 
	if mut_l100___0 then mut_l100=0; if mut_l100___1 then mut_l100=1; if mut_l100___9 then mut_l100=9;
	if mut_k101___0 then mut_k101=0; if mut_k101___1 then mut_k101=1; if mut_k101___2 then mut_k101=2; if mut_k101___3 then mut_k101=3; if mut_k101___4 then mut_k101=4;if mut_k101___5 then mut_k101=5; if mut_k101___6 then mut_k101=6; if mut_k101___9 then mut_k101=9;
	if mut_k103___0 then mut_k103=0; if mut_k103___1 then mut_k102=1; if mut_k103___2 then mut_k102=2; if mut_k103___3 then mut_k103=3; if mut_k103___4 then mut_k103=4;if mut_k103___5 then mut_k103=5; if mut_k103___6 them mut_k103=6; if mut_k103___7 then mut_k103=7; if mut_k103___9 then mut_k103=9; 
	if mut_v106___0 then mut_v106=0; if mut_v106___1 then mut_v106=1; if mut_v106___2 then mut_v106=2; if mut_v106___3 then mut_v106=3; if mut_v106___4 then mut_v106=4;if mut_v106___9 then mut_v106=9;
	if mut_v108___0 then mut_v108=0; if mut_v108___1 then mut_v108=1; if mut_v108___9 then mut_v108=9;
	if mut_g109___0 then mut_g109=0; if mut_g109___1 then mut_g109=1; if mut_g109___2 then mut_g109=2; if mut_g109___9 then mut_g109=9;
	if mut_y115___0 then mut_y115=0; if mut_y115___1 then mut_y115=1; if mut_y115___2 then mut_y115=2; if mut_y115___9 then mut_y115=9;
	if mut_f116___0 then mut_f116=0; if mut_f116___1 then mut_f116=1; if mut_f116___9 then mut_f116=9; 
	if mut_118___0  then mut_118=0;  if mut_118___1  then mut_118=1;  if mut_118___9  then mut_118=9;
	if mut_e138___0 then mut_e138=0; if mut_e138___1 then mut_e138=1; if mut_e138___2 then mut_e138=2; if mut_e138___3 then mut_e138=3; if mut_e138___4 then mut_e138=4; if  mut_e138___9  then mut_e138=9;
	if mut_q151___0 then mut_q151=0; if mut_q151___1 then mut_q151=1; if mut_q151___2 then mut_q151=2; if mut_q151___9 then mut_q151=9;
	if mut_v179___0 then mut_v179=0; if mut_v179___1 then mut_v179=1; if mut_v179___2 then mut_v179=2; if mut_v179___3 then mut_v179=3; if mut_v179___4 then mut_v179=4; if mut_v179___5 then mut_v179=5; if mut_v179___6 then mut_v179=6; if mut_v179___9 then mut_v179=9;
	if mut_y181___0 then mut_y181=0; if mut_y181___1 then mut_y181=1; if mut_y181___2 then mut_y181=2; if mut_y181___3 then mut_y181=3; if mut_y181___4 then mut_y181=4; if mut_y181___9 then mut_y181=9;
	if mut_m184___0 then mut_m184=0; if mut_m184___1 then mut_m184=1; if mut_m184___2 then mut_m184=2; if mut_m184___3 then mut_m184=3;	if mut_m184___9 then mut_m184=9;
	if mut_y188___0 then mut_y188=0; if mut_y188___1 then mut_y188=1; if mut_y188___2 then mut_y188=2; if mut_y188___3 then mut_y188=3;	if mut_y188___4 then mut_y188=4; if mut_y188___5 then mut_y188=5; if mut_y188___9 then mut_y188=9;
	if mut_g190___0 then mut_g190=0; if mut_g190___1 then mut_g190=1; if mut_g190___2 then mut_g190=2; if mut_g190___3 then mut_g190=3; if mut_g190___4 then mut_g190=4; if mut_g190___5 then mut_g190=5; if mut_g190___6 then mut_g190=6; if mut_g190___7 then mut_g190=7; if mut_g190___8 then mut_g190=8; if mut_g190___9 then mut_g190=9; 
	if mut_l210___0 then mut_l210=0; if mut_l210___1 then mut_l210=1; if mut_l210___2 then mut_l210=2; if mut_l210___3 then mut_l210=3; if mut_l210___9 then mut_l210=9; 
	if mut_t215___0 then mut_t215=0; if mut_t215___1 then mut_t215=1; if mut_t215___2 then mut_t215=2; if mut_t215___3 then mut_t215=3; if mut_t215___4 then mut_t215=4; if mut_t215___5 then mut_t215=5; if mut_t215___6 then mut_t215=6; if mut_t215___7 then mut_t215=7; if mut_t215___8 then mut_t215=8; if mut_t215___9 then mut_t215=9;
	if mut_k219___0 then mut_k219=0; if mut_k219___1 then mut_k219=1; if mut_k219___2 then mut_k219=2; if mut_k219___3 then mut_k219=3; if mut_k219___4 then mut_k219=4; if mut_k219___5 then mut_k219=5; if mut_k219___6 then mut_k219=6; if mut_k219___7 then mut_k219=7; if mut_k219___9 then mut_k219=9; 
	if mut_h221___0 then mut_h221=0; if mut_h221___1 then mut_h221=1; if mut_h221___9 then mut_h221=9;
	if mut_p225___0 then mut_p225=0; if mut_p225___1 then mut_p225=1; if mut_p225___9 then mut_p225=9;
	if mut_f227___0 then mut_f227=0; if mut_f227___1 then mut_f227=1; if mut_f227___2 then mut_f227=2; if mut_f227___9 then mut_f227=9;
	if mut_m230___0 then mut_m230=0; if mut_m230__1  then mut_m230=1; if mut_m230___9 then mut_m230=9;
	if mut_234___0  then mut_234=0;  if mut_234___1  then mut_234=1; if mut_234___9 then mut_234=9;
	if mut_236___0  then mut_236=0;  if mut_236___1  then mut_236=1; if mut_236___9 then mut_236=9; 
	if mut_238___0  then mut_238=0;  if mut_238___1  then mut_238=1; if mut_238___2 then mut_238=2; if mut_238___3 then mut_238=3; if mut_238___9 then mut_238=9;
	if mut_y318___0 then mut_y318=0; if mut_y318___1 then mut_y318=1; if mut_y318___9 then mut_y318=9;
	if mut_333___0  then mut_333=0;  if mut_333___1  then mut_333=1; if mut_333___2 then mut_333=2; if mut_333___9 then mut_333=9;
	if mut_n348___0 then mut_n348=0; if mut_n348___1 then mut_n348=1; if mut_n348___9 then mut_n348=9;
	if mut_l10___0  then mut_l10=0;  if mut_l10___1  then mut_l10=1; if mut_l10___2 then mut_l10=2; if mut_l10___3 then mut_l10=3; if mut_l10___4 then mut_l10=4; if mut_l10___5 then mut_l10=5; if mut_l10___9 then mut_l10=9;
	if mut_v11___0  then mut_v11=0;  if mut_v11___1  then mut_v11=1; if mut_v11___9 then mut_v11=9; 
	if mut_13___0   then mut_13=0;   if mut_13___1   then mut_13=1; if  mut_13___9 then mut_13=9;
	if mut_g16___0  then mut_g16=0;  if mut_g16___1  then mut_g16=1; if mut_g16___9 then mut_g16=9;
	if mut_k20___0  then mut_k20=0;  if mut_k20___1  then mut_k20=1; if mut_k20___2 then mut_k20=2; if mut_k20___3 then mut_k20=3; if mut_k20___4 then mut_k20=4; if mut_k20___5 then mut_k20=5; if mut_k20___9 then mut_k20=9;
	if mut_23___0   then mut_23=0;   if mut_23___1   then mut_23=1; if mut_23___9 then mut_23=9; 
	if mut_l24___0  then mut_l24=0;  if mut_l24___1  then mut_l24=1; if mut_l24___2 then mut_l24=2; if mut_l24___9 then mut_l24=9; 
	if mut_d30___0  then mut_d30=0;  if mut_d30___1  then mut_d30=1; if mut_d30___9 then mut_d30=9; 
	if mut_v32___0  then mut_v32=0;  if mut_v32___1  then mut_v32=1; if mut_v32___9 then mut_v32=9; 
	if mut_l33___0  then mut_l33=0;  if mut_l33___1  then mut_l33=1; if mut_l33___2 then mut_l33=2; if mut_l33___3 then mut_l33=3; if mut_l33___9 then mut_l33=9;
	if mut_35___0   then mut_35=0;   if mut_35___1   then mut_35=1;  if mut_35___9  then mut_35=9; 
	if mut_m36___0  then mut_m36=0;  if mut_m36___1  then mut_m36=1; if mut_m36___2 then mut_m36=2; if mut_m36___3 then mut_m36=3; if mut_m36___4 then mut_m36=4; if mut_m36___9 then mut_m36=9;
	if mut_k43___0  then mut_k43=0;  if mut_k43___1  then mut_k43=1; if mut_k43___9 then mut_k43=9; 
	if mut_m46___0  then mut_m46=0;  if mut_m46___1  then mut_m46=1; if mut_m46___2 then mut_m46=2; if mut_m46___3 then mut_m46=3; if mut_m46___9 then mut_m46=9;
	if mut_i47___0  then mut_i47=0;  if mut_i47___1  then mut_i47=1; if mut_i47___2 then mut_i47=2; if mut_i47___9 then mut_i47=9;
	if mut_g48___0  then mut_g48=0;  if mut_g48___1  then mut_g48=1; if mut_g48___2 then mut_g48=2; if mut_g48___3 then mut_g48=3; if mut_g48___4 then mut_g48=4; if mut_g48___5 then mut_g48=5; if  mut_g48___6 then mut_g48=6; if  mut_g48___9 then mut_g48=9;
	if mut_i50___0  then mut_i50=0;  if mut_i50___1  then mut_i50=1; if mut_i50___2 then mut_i50=2; if mut_i50___9 then mut_i50=9;
	if mut_f53___0  then mut_f53=0;  if mut_f53___1  then mut_f53=1; if mut_f53___2 then mut_f53=2; if mut_f53___9 then mut_f53=9; 
	if mut_i54___0  then mut_i54=0;  if mut_i54___1  then mut_i54=1; if mut_i54___2 then mut_i54=2; if mut_i54___3 then mut_i54=3; if mut_i54___4 then mut_i54=4; if mut_i54___5 then mut_i54=5; if mut_i54___6 then mut_i54=6; if  mut_i54___9 then mut_i54=9;
	if mut_q58___0  then mut_q58=0;  if mut_q58___1  then mut_q58=1; if mut_q58___9 then mut_q58=9;
	if mut_d60___0  then mut_d60=0;  if mut_d60___1  then mut_d60=1; if mut_d60___9 then mut_d60=9;
	if mut_i62___0  then mut_i62=0;  if mut_i62___1  then mut_i62=1; if mut_i62___9 then mut_i62=9;
	if mut_l63___0  then mut_l63=0;  if mut_l63___1  then mut_l63=1; if mut_l63___9 then mut_l63=9;
	if mut_a71___0  then mut_a71=0;  if mut_a71___1  then mut_a71=1; if mut_a71___2 then mut_a71=2; if mut_a71___3 then mut_a71=3; if mut_a71___4  then mut_a71=4; if mut_a71___9 then mut_a71=9; 
	if mut_g73___0  then mut_g73=0;  if mut_g73___1  then mut_g73=1; if mut_g73___2 then mut_g73=2; if mut_g73___3 then mut_g73=3; if mut_g73___4 then mut_g73=4; if mut_g73___9 then mut_g73=9;
	if mut_t74___0  then mut_t74=0;  if mut_t74___1  then mut_t74=1; if mut_t74___2 then mut_t74=2; if  mut_t74___9 then mut_t74=9;
	if mut_l76___0  then mut_l76=0;  if mut_l76___1  then mut_l76=1; if mut_l76___9 then mut_l76=9; 
	if mut_v77___0  then mut_v77=0;  if mut_v77___1  then mut_v77=1; if mut_v77___9 then mut_v77=9;
	if mut_v82___0  then mut_v82=0;  if mut_v82___1  then mut_v82=1; if mut_v82___2 then mut_v82=2;  if mut_v82___3 then mut_v82=3; if mut_v82___4 then mut_v82=4; if mut_v82___5 then mut_v82=5; if mut_v82___6 then mut_v82=6; if mut_v82___7 then mut_v82=7; if  mut_v82___8 then mut_v82=8; if mut_v82___9 then mut_v82=9; 
	if mut_n83___0  then mut_n83=0;  if mut_n83___1  then mut_n83=1; if mut_n83___9 then mut_n83=9; 
	if mut_i84___0  then mut_i84=0;  if mut_i84___1  then mut_i84=1; if mut_i84___2 then mut_i84=2; if mut_i84___3 then mut_i84=3; if mut_i84___9 then mut_i84=9;
	if mut_i85___0  then mut_i85=0;  if mut_i85___1  then mut_i85=1; if mut_i85___9 then mut_i85=9;
	if mut_n88___0  then mut_n88=0;  if mut_n88___1  then mut_n88=1; if mut_n88___2 then mut_n88=2; if mut_n88___3 then mut_n88=3; if mut_n88___4 then mut_n88=4; if mut_n88___9 then mut_n88=9;
	if mut_l89___0  then mut_l89=0;  if mut_l89___1  then mut_l89=1; if mut_l89___2 then mut_l89=2; if mut_l89___3  then mut_l89=3; if mut_l89___4 then mut_l89=4; if mut_l89___9 then mut_l89=9; 
	if mut_l90___0  then mut_l90=0;  if mut_l90___1  then mut_l90=1; if mut_l90___9 then mut_l90=9; 
	if mut_i93___0  then mut_i93=0;  if mut_i93___1  then mut_i93=1; if mut_i93___2 then mut_i93=2; if mut_i93___9 then mut_i93=9;

	format idx idx.
	mut_m41 mut_m41_. mut_44 mut_44_. mut_a62 mut_a62_. mut_k65 mut_k65_. mut_d67 mut_d67_. mut_t69 mut_t69_. mut_k70 mut_k70_. mut_l74 mut_l74_.
	mut_v75 mut_v75_.  mut_f77 mut_f77_. mut_v90 mut_v90_. mut_a98 mut_a98_. mut_l100 mut_l100_. mut_k101 mut_k101_. mut_k103 mut_k103_.
	mut_v106 mut_v106_. mut_v108 mut_v108_. mut_g109 mut_g109_. mut_y115 mut_y115_. mut_f116 mut_f116_. mut_118 mut_118_. mut_e138 mut_e138_.
	mut_q151 mut_q151_. mut_v179 mut_v179_. mut_y181 mut_y181_. mut_m184 mut_m184_. mut_y188 mut_y188_. mut_g190 mut_g190_. mut_l210 mut_l210_.
	mut_t215 mut_t215_. mut_k219 mut_k219_. mut_h221 mut_h221_. mut_p225 mut_p225_. mut_f227 mut_f227_. mut_m230 mut_m230_. mut_234 mut_234_.
	mut_236 mut_236_. mut_238 mut_238_. mut_y318 mut_y318_. mut_333 mut_333_. mut_n348 mut_n348_. mut_l10 mut_l10_. mut_v11 mut_v11_. mut_13 mut_13_.
	mut_g16 mut_g16_. mut_k20 mut_k20_. mut_23 mut_23_. mut_l24 mut_l24_. mut_d30 mut_d30_. mut_v32 mut_v32_. mut_l33 mut_l33_. mut_35 mut_35_.
	mut_m36 mut_m36_. mut_m46 mut_m46_. mut_k43 mut_k43_. mut_i47 mut_i47_. mut_g48 mut_g48_. mut_i50 mut_i50_. mut_f53 mut_f53_.  mut_i54 mut_i54_.
 	mut_q58 mut_q58_. mut_d60 mut_d60_. mut_i62 mut_i62_. mut_l63 mut_l63_. mut_a71 mut_a71_. mut_g73 mut_g73_. mut_t74 mut_t74_. mut_l76 mut_l76_.
	mut_v77 mut_v77_. mut_v82 mut_v82_. mut_n83 mut_n83_. mut_i84 mut_i84_. mut_i85 mut_i85_. mut_n88 mut_n88_. mut_l89 mut_l89_. mut_l90 mut_l90_.
	mut_i93 mut_i93_.;
run;

data tmp;
	set rest1;
	if idx=1;
	keep patient_id mut_m41 mut_44 mut_a62 mut_k65 mut_d67 mut_t69 mut_k70 mut_l74 mut_v75 mut_f77 mut_v90 mut_a98 mut_l100 mut_k101 mut_k103 
	mut_v106 mut_v108 mut_g109 mut_y115 mut_f116 mut_118 mut_e138 mut_q151 mut_v179 mut_y181 mut_m184 mut_y188 mut_g190 mut_l210 mut_t215 
	mut_k219 mut_h221 mut_p225 mut_f227 mut_m230 mut_234 mut_236  mut_238  mut_y318 mut_333 mut_n348 mut_l10 mut_v11  mut_13
	mut_g16  mut_k20  mut_23  mut_l24 mut_d30  mut_v32  mut_l33  mut_35 mut_m36 mut_m46 mut_k43 mut_i47  mut_g48 mut_i50 mut_f53 mut_i54 
 	mut_q58 mut_d60 mut_i62 mut_l63 mut_a71 mut_g73 mut_t74 mut_l76 mut_v77 mut_v82 mut_n83 mut_i84 mut_i85 mut_n88 mut_l89 mut_l90 mut_i93;
run;

data brent.mut;
	set tmp;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
run;
proc sort; by idx id;run;

/*
proc print;
var patient_id 	mut_m41 mut_44 mut_a62 mut_k65 mut_d67 mut_t69 mut_k70 mut_174 mut_v75 mut_f77 mut_v90 mut_a98 mut_l100 mut_k101 mut_k103 
	mut_v106 mut_v108 mut_g109 mut_y115 mut_f116 mut_118 mut_e138 mut_q151 mut_v179 mut_y181 mut_m184 mut_y188 mut_g190 mut_l210 mut_t215 
	mut_k219 mut_h221 mut_p225 mut_f227 mut_m230 mut_234 mut_236  mut_238  mut_y318 mut_333 mut_n348 mut_l10 mut_v11  mut_13
	mut_g16  mut_k20  mut_23  mut_l24 mut_d30  mut_v32  mut_l33  mut_35 mut_m36 mut_m46 mut_k43 mut_i47  mut_g48 mut_i50 mut_f53 mut_i54 
 	mut_q58 mut_d60 mut_i62 mut_l63 mut_a71 mut_g73 mut_t74 mut_l76 mut_v77 mut_v82 mut_n83 mut_i84 mut_i85 mut_n88 mut_l89 mut_l90 mut_i93;
run;
*/

proc export data=tmp outfile='H:\SAS_Emory\RedCap\Data\rest_condo.csv' dbms=csv replace; run;
