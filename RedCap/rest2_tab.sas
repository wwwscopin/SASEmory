options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\rest2.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='3TC'
	2='ABC'
	3='AZT'
	4='D4T'
	5='DDI'
	6='DLV'
	7='EFV'
	8='ETR'
	9='FTC'
	10='NPV'
	11='RPV'
	12='TDF'
	13='NRTI Mutations'
	14='NNRTI Mutations'

	15='M41 (choice=M (WT))'
	16='M41 (choice=L)'
	17='M41 (choice=Other)'
	18='44 (choice=E (WT))'
	19='44 (choice=A)'
	20='44 (choice=D)'
	21='44 (choice=Other)'
	22='A62 (choice=A (WT))'
	23='A62 (choice=V)'
	24='A62 (choice=Other)'
	25='K65 (choice=K (WT))'
	26='K65 (choice=N)'
	27='K65 (choice=R)'
	28='K65 (choice=Other)'
	29='D67 (choice=D (WT))'
	30='D67 (choice=E)'
	31='D67 (choice=G)'
	32='D67 (choice=N)'
	33='D67 (choice=d)'
	34='D67 (choice=Other)'
	35='T69 (choice=T (WT))'
	36='T69 (choice=A)'
	37='T69 (choice=D)'
	38='T69 (choice=G)'
	39='T69 (choice=I)'
	40='T69 (choice=N)'

	41='T69 (choice=S)'
	42='T69 (choice=i)'
	43='T69 (choice=Other)'
	44='K70 (choice=K (WT))'
	45='K70 (choice=E)'
	46='K70 (choice=G)'
	47='K70 (choice=R)'
	48='K70 (choice=T)'
	49='K70 (choice=Other)'
	50='L74 (choice=L (WT))'
	51='L74 (choice=I)'
	52='L74 (choice=V)'
	53='L74 (choice=Other)'
	54='V75 (choice=V (WT))'
	55='V75 (choice=A)'
	56='V75 (choice=I)'
	57='V75 (choice=L)'
	58='V75 (choice=M)'
	59='V75 (choice=S)'
	60='V75 (choice=T)'
	61='V75 (choice=Other)'
	62='F77 (choice=F (WT))'
	63='F77 (choice=L)'
	64='F77 (choice=Other)'
	65='V90 (choice=V (WT))'
	66='V90 (choice=I)'

	67='V90 (choice=Other)'
	68='A98 (choice=A (WT))'
	69='A98 (choice=G)'
	70='A98 (choice=S)'
	71='A98 (choice=Other)'
	72='L100 (choice=L (WT))'
	73='L100 (choice=I)'
	74='L100 (choice=Other)'
	75='K101 (choice=K (WT))'
	76='K101 (choice=E)'
	77='K101 (choice=H)'
	78='K101 (choice=N)'
	79='K101 (choice=P)'
	80='K101 (choice=Q)'
	81='K101 (choice=R)'
	82='K101 (choice=Other)'
	83='K103 (choice=K (WT))'
	84='K103 (choice=E)'
	85='K103 (choice=H)'
	86='K103 (choice=N)'
	87='K103 (choice=Q)'
	88='K103 (choice=R)'
	89='K103 (choice=S)'
	90='K103 (choice=T)'
	91='K103 (choice=Other)'
	92='V106 (choice=V (WT))'
	93='V106 (choice=A)'
	94='V106 (choice=I)'
	95='V106 (choice=L)'
	96='V106 (choice=M)'

	97='V106 (choice=Other)'
	98='V108 (choice=V (WT))'
	99='V108 (choice=I)'
	100='V108 (choice=Other)'
	101='G109 (choice=G (WT))'
	102='G109 (choice=E)'
	103='G109 (choice=S)'
	104='G109 (choice=Other)'
	105='Y115 (choice=Y (WT))'
	106='Y115 (choice=F)'
	107='Y115 (choice=S)'
	108='Y115 (choice=Other)'
	109='F116 (choice=F (WT))'
	110='F116 (choice=Y)'
	111='F116 (choice=Other)'
	112='118 (choice=V (WT))'
	113='118 (choice=I)'
	114='118 (choice=Other)'
	115='E138 (choice=E (WT))'
	116='E138 (choice=A)'
	117='E138 (choice=G)'
	118='E138 (choice=K)'
	119='E138 (choice=Q)'
	120='E138 (choice=Other)'
	121='Q151 (choice=Q (WT))'
	122='Q151 (choice=L)'
	123='Q151 (choice=M)'
	124='Q151 (choice=Other)'
	125='V179 (choice=V (WT))'
	126='V179 (choice=D)'
	127='V179 (choice=E)'
	128='V179 (choice=F)'
	129='V179 (choice=I)'
	130='V179 (choice=T)'
	131='V179 (choice=Y)'
	132='V179 (choice=Other)'
	133='Y181 (choice=Y (WT))'
	134='Y181 (choice=C)'
	135='Y181 (choice=I)'
	136='Y181 (choice=S)'

	137='Y181 (choice=V)'
	138='Y181 (choice=Other)'
	139='M184 (choice=M (WT))'
	140='M184 (choice=C)'
	141='M184 (choice=I)'
	142='M184 (choice=V)'
	143='M184 (choice=Other)'
	144='Y188 (choice=Y (WT))'
	145='Y188 (choice=C)'
	146='Y188 (choice=F)'
	147='Y188 (choice=H)'
	148='Y188 (choice=L)'
	149='Y188 (choice=N)'
	150='Y188 (choice=Other)'
	151='G190 (choice=G (WT))'
	152='G190 (choice=A)'
	153='G190 (choice=C)'
	154='G190 (choice=D)'
	155='G190 (choice=E)'
	156='G190 (choice=Q)'
	157='G190 (choice=S)'
	158='G190 (choice=T)'
	159='G190 (choice=V)'
	160='G190 (choice=Other)'
	161='L210 (choice=L (WT))'
	162='L210 (choice=F)'
	163='L210 (choice=S)'
	164='L210 (choice=W)'
	165='L210 (choice=Other)'
	166='T215 (choice=T (WT))'
	167='T215 (choice=C)'
	168='T215 (choice=D)'
	169='T215 (choice=E)'
	170='T215 (choice=F)'
	171='T215 (choice=I)'
	172='T215 (choice=S)'
	173='T215 (choice=V)'
	174='T215 (choice=Y)'
	175='T215 (choice=Other)'
	176='K219 (choice=K (WT))'
	177='K219 (choice=D)'
	178='K219 (choice=E)'
	179='K219 (choice=H)'
	180='K219 (choice=N)'
	181='K219 (choice=Q)'
	182='K219 (choice=R)'
	183='K219 (choice=W)'
	184='K219 (choice=Other)'
	185='H221 (choice=H (WT))'
	186='H221 (choice=Y)'
	187='H221 (choice=Other)'
	188='P225 (choice=P (WT))'
	189='P225 (choice=H)'
	190='P225 (choice=Other)'
	191='F227 (choice=F (WT))'
	192='F227 (choice=C)'
	193='F227 (choice=L)'
	194='F227 (choice=Other)'
	195='M230 (choice=M (WT))'
	196='M230 (choice=L)'
	197='M230 (choice=Other)'
	198='234 (choice=L (WT))'
	199='234 (choice=I)'
	200='234 (choice=Other)'
	201='236 (choice=P (WT))'
	202='236 (choice=L)'
	203='236 (choice=Other)'
	204='238 (choice=K (WT))'
	205='238 (choice=N)'
	206='238 (choice=R)'
	207='238 (choice=T)'
	208='238 (choice=Other)'
	209='Y318 (choice=Y (WT))'
	210='Y318 (choice=F)'
	211='Y318 (choice=Other)'
	212='333 (choice=G (WT))'
	213='333 (choice=D)'
	214='333 (choice=E)'
	215='333 (choice=Other)'
	216='N348 (choice=N (WT))'
	217='N348 (choice=I)'
	218='N348 (choice=Other)'
	219='PI Major Mutations'
	220='PI Minor Mutations'
	221='L10 (choice=L (WT))'
	222='L10 (choice=F)'
	223='L10 (choice=I)'
	224='L10 (choice=R)'
	225='L10 (choice=V)'
	226='L10 (choice=Y)'
	227='L10 (choice=Other)'
	228='V11 (choice=V (WT))'
	229='V11 (choice=I)'
	230='V11 (choice=Other)'
	231='13 (choice=I (WT))'
	232='13 (choice=V)'
	233='13 (choice=Other)'
	234='G16 (choice=G (WT))'
	235='G16 (choice=E)'
	236='G16 (choice=Other)'
	237='K20 (choice=K (WT))'
	238='K20 (choice=I)'
	239='K20 (choice=M)'
	240='K20 (choice=R)'
	241='K20 (choice=T)'
	242='K20 (choice=V)'
	243='K20 (choice=Other)'
	244='23 (choice=L (WT))'
	245='23 (choice=I)'
	246='23 (choice=Other)'
	247='L24 (choice=L (WT))'
	248='L24 (choice=F)'
	249='L24 (choice=I)'
	250='L24 (choice=Other)'
	251='D30 (choice=D (WT))'
	252='D30 (choice=N)'
	253='D30 (choice=Other)'
	254='V32 (choice=V (WT))'
	255='V32 (choice=I)'
	256='V32 (choice=Other)'
	257='L33 (choice=L (WT))'
	258='L33 (choice=F)'
	259='L33 (choice=I)'
	260='L33 (choice=V)'
	261='L33 (choice=Other)'
	262='35 (choice=E (WT))'
	263='35 (choice=G)'
	264='35 (choice=Other)'
	265='M36 (choice=M (WT))'
	266='M36 (choice=I)'
	267='M36 (choice=L)'
	268='M36 (choice=T)'
	269='M36 (choice=V)'
	270='M36 (choice=Other)'
	271='K43 (choice=K (WT))'
	272='K43 (choice=T)'
	273='K43 (choice=Other)'
	274='M46 (choice=M (WT))'
	275='M46 (choice=I)'
	276='M46 (choice=L)'
	277='M46 (choice=V)'
	278='M46 (choice=Other)'
	279='I47 (choice=I (WT))'
	280='I47 (choice=A)'
	281='I47 (choice=V)'
	282='I47 (choice=Other)'
	283='G48 (choice=G (WT))'
	284='G48 (choice=A)'
	285='G48 (choice=M)'
	286='G48 (choice=Q)'
	287='G48 (choice=S)'
	288='G48 (choice=T)'
	289='G48 (choice=V)'
	290='G48 (choice=Other)'
	291='I50 (choice=I (WT))'
	292='I50 (choice=L)'
	293='I50 (choice=V)'
	294='I50 (choice=Other)'
	295='F53 (choice=F (WT))'
	296='F53 (choice=L)'
	297='F53 (choice=Y)'
	298='F53 (choice=Other)'
	299='I54 (choice=I (WT))'
	300='I54 (choice=A)'
	301='I54 (choice=L)'
	302='I54 (choice=M)'
	303='I54 (choice=S)'
	304='I54 (choice=T)'
	305='I54 (choice=V)'
	306='I54 (choice=Other)'
	307='Q58 (choice=Q (WT))'
	308='Q58 (choice=E)'
	309='Q58 (choice=Other)'
	310='D60 (choice=D (WT))'
	311='D60 (choice=E)'
	312='D60 (choice=Other)'
	313='I62 (choice=I (WT))'
	314='I62 (choice=V)'
	315='I62 (choice=Other)'
	316='L63 (choice=L (WT))'
	317='L63 (choice=P)'
	318='L63 (choice=Other)'
	319='A71 (choice=A (WT))'
	320='A71 (choice=I)'
	321='A71 (choice=L)'
	322='A71 (choice=T)'
	323='A71 (choice=V)'
	324='A71 (choice=Other)'
	325='G73 (choice=G (WT))'
	326='G73 (choice=A)'
	327='G73 (choice=C)'
	328='G73 (choice=S)'
	329='G73 (choice=T)'
	330='G73 (choice=Other)'
	331='T74 (choice=T (WT))'
	332='T74 (choice=P)'
	333='T74 (choice=S)'
	334='T74 (choice=Other)'
	335='L76 (choice=L (WT))'
	336='L76 (choice=V)'
	337='L76 (choice=Other)'
	338='V77 (choice=V (WT))'
	339='V77 (choice=I)'
	340='V77 (choice=Other)'
	341='V82 (choice=V (WT))'
	342='V82 (choice=A)'
	343='V82 (choice=C)'
	344='V82 (choice=F)'
	345='V82 (choice=I)'
	346='V82 (choice=L)'
	347='V82 (choice=M)'
	348='V82 (choice=S)'
	349='V82 (choice=T)'
	350='V82 (choice=Other)'
	351='N83 (choice=N (WT))'
	352='N83 (choice=D)'
	353='N83 (choice=Other)'
	354='I84 (choice=I (WT))'
	355='I84 (choice=A)'
	356='I84 (choice=C)'
	357='I84 (choice=V)'
	358='I84 (choice=Other)'
	359='I85 (choice=I (WT))'
	360='I85 (choice=V)'
	361='I85 (choice=Other)'
	362='N88 (choice=N (WT))'
	363='N88 (choice=D)'
	364='N88 (choice=G)'
	365='N88 (choice=S)'
	366='N88 (choice=T)'
	367='N88 (choice=Other)'
	368='L89 (choice=L (WT))'
	369='L89 (choice=I)'
	370='L89 (choice=M)'
	371='L89 (choice=T)'
	372='L89 (choice=V)'
	373='L89 (choice=Other)'
	374='L90 (choice=L (WT))'
	375='L90 (choice=M)'
	376='L90 (choice=Other)'
	377='I93 (choice=I (WT))'
	378='I93 (choice=L)'
	379='I93 (choice=M)'
	380='I93 (choice=Other)'
	;

	value genotype_done 1='Done' 2='Not done';
	value rest 1='Resistant' 2='Intermediate Resistance' 3='Possible Resistance' 4='Susceptible' 9='Not done';

	value yn 1="Yes" 2="No";
	value ny 0="No" 1="Yes";
	value idx 0="Control" 1="Case";
run;


data rest2;
	set brent.rest2;
	format idx idx.;
run;

proc freq; 
tables idx;
ods output onewayfreqs=tmp;
run;
*ods trace off;
data _null_;
	set tmp;
	if idx=0 then call symput("n0", compress(Frequency));
	if idx=1 then call symput("n1", compress(Frequency));
run;
%let n=%eval(&n0+&n1);

%let varlist=resist_3tc_2 resist_abc_2 resist_azt_2 resist_d4t_2 resist_ddi_2 resist_dlv_2 resist_efv_2 resist_etr_2 resist_ftc_2 
	resist_npv_2 resist_rpv_2 resist_tdf_2 mut_nrti_2 mut_nnrti_2;
%tab(rest2, idx, tab, &varlist);

%let varlist=mut_m41_2___0 mut_m41_2___1 mut_m41_2___9 mut_44_2___0 mut_44_2___1 mut_44_2___2 mut_44_2___9 mut_a62_2___0 mut_a62_2___1 mut_a62_2___9
	mut_k65_2___0 mut_k65_2___1 mut_k65_2___2 mut_k65_2___9 mut_d67_2___0 mut_d67_2___1 mut_d67_2___2 mut_d67_2___3 mut_d67_2___4 mut_d67_2___9 
	mut_t69_2___0 mut_t69_2___1 mut_t69_2___2 mut_t69_2___3 mut_t69_2___4 mut_t69_2___5 mut_t69_2___6 mut_t69_2___7 mut_t69_2___9 
	mut_k70_2___0 mut_k70_2___1 mut_k70_2___2 mut_k70_2___3 mut_k70_2___4 mut_k70_2___9 mut_l74_2___0 mut_l74_2___1 mut_l74_2___2 mut_l74_2___9 
	mut_v75_2___0 mut_v75_2___1 mut_v75_2___2 mut_v75_2___3 mut_v75_2___4 mut_v75_2___5 mut_v75_2___6 mut_v75_2___9 mut_f77_2___0 mut_f77_2___1 
	mut_f77_2___9 mut_v90_2___0 mut_v90_2___1 mut_v90_2___9 mut_a98_2___0 mut_a98_2___1 mut_a98_2___2 mut_a98_2___9 mut_l100_2___0 mut_l100_2___1 
	mut_l100_2___9 mut_k101_2___0 mut_k101_2___1 mut_k101_2___2 mut_k101_2___3 mut_k101_2___4 mut_k101_2___5 mut_k101_2___6 mut_k101_2___9 
	mut_k103_2___0 mut_k103_2___1 mut_k103_2___2 mut_k103_2___3 mut_k103_2___4 mut_k103_2___5 mut_k103_2___6 mut_k103_2___7 mut_k103_2___9 
	mut_v106_2___0 mut_v106_2___1 mut_v106_2___2 mut_v106_2___3 mut_v106_2___4 mut_v106_2___9 mut_v108_2___0 mut_v108_2___1 
	mut_v108_2___9 mut_g109_2___0 mut_g109_2___1 mut_g109_2___2 mut_g109_2___9 mut_y115_2___0 mut_y115_2___1 mut_y115_2___2 mut_y115_2___9 
	mut_f116_2___0 mut_f116_2___1 mut_f116_2___9 mut_118_2___0 mut_118_2___1 mut_118_2___9 mut_e138_2___0 mut_e138_2___1 mut_e138_2___2 
	mut_e138_2___3 mut_e138_2___4 mut_e138_2___9 mut_q151_2___0 mut_q151_2___1 mut_q151_2___2 mut_q151_2___9 mut_v179_2___0 mut_v179_2___1 
	mut_v179_2___2 mut_v179_2___3 mut_v179_2___4 mut_v179_2___5 mut_v179_2___6 mut_v179_2___9 mut_y181_2___0 mut_y181_2___1 mut_y181_2___2 
	mut_y181_2___3 mut_y181_2___4 mut_y181_2___9 mut_m184_2___0 mut_m184_2___1 mut_m184_2___2 mut_m184_2___3 mut_m184_2___9 mut_y188_2___0 
	mut_y188_2___1 mut_y188_2___2 mut_y188_2___3 mut_y188_2___4 mut_y188_2___5 mut_y188_2___9 mut_g190_2___0 mut_g190_2___1 mut_g190_2___2 
	mut_g190_2___3 mut_g190_2___4 mut_g190_2___5 mut_g190_2___6 mut_g190_2___7 mut_g190_2___8 mut_g190_2___9 mut_l210_2___0 mut_l210_2___1 
	mut_l210_2___2 mut_l210_2___3 mut_l210_2___9 mut_t215_2___0 mut_t215_2___1 mut_t215_2___2 mut_t215_2___3 mut_t215_2___4 mut_t215_2___5 
	mut_t215_2___6 mut_t215_2___7 mut_t215_2___8 mut_t215_2___9 mut_k219_2___0 mut_k219_2___1 mut_k219_2___2 mut_k219_2___3 mut_k219_2___4 
	mut_k219_2___5 mut_k219_2___6 mut_k219_2___7 mut_k219_2___9 mut_h221_2___0 mut_h221_2___1 mut_h221_2___9 mut_p225_2___0 mut_p225_2___1 
	mut_p225_2___9 mut_f227_2___0 mut_f227_2___1 mut_f227_2___2 mut_f227_2___9 mut_m230_2___0 mut_m230_2___1 mut_m230_2___9 mut_234_2___0 
	mut_234_2___1 mut_234_2___9   mut_236_2___0 mut_236_2___1 mut_236_2___9 mut_238_2___0 mut_238_2___1 mut_238_2___2 mut_238_2___3 mut_238_2___9 
	mut_y318_2___0 mut_y318_2___1 mut_y318_2___9 mut_333_2___0 mut_333_2___1 mut_333_2___2 mut_333_2___9 mut_n348_2___0 mut_n348_2___1 mut_n348_2___9
	mut_pi_major_2 mut_pi_minor_2 mut_l10_2___0 mut_l10_2___1 mut_l10_2___2 mut_l10_2___3 mut_l10_2___4 mut_l10_2___5 mut_l10_2___9 
	mut_v11_2___0 mut_v11_2___1 mut_v11_2___9  mut_13_2___0 mut_13_2___1 mut_13_2___9  mut_g16_2___0 mut_g16_2___1 mut_g16_2___9 
	mut_k20_2___0 mut_k20_2___1 mut_k20_2___2 mut_k20_2___3 mut_k20_2___4 mut_k20_2___5 mut_k20_2___9 mut_23_2___0 mut_23_2___1 mut_23_2___9 
	mut_l24_2___0 mut_l24_2___1 mut_l24_2___2 mut_l24_2___9 mut_d30_2___0 mut_d30_2___1 mut_d30_2___9 mut_v32_2___0 mut_v32_2___1 mut_v32_2___9 
	mut_l33_2___0 mut_l33_2___1 mut_l33_2___2 mut_l33_2___3 mut_l33_2___9 mut_35_2___0 mut_35_2___1 mut_35_2___9 mut_m36_2___0 mut_m36_2___1 
	mut_m36_2___2 mut_m36_2___3 mut_m36_2___4 mut_m36_2___9 mut_k43_2___0 mut_k43_2___1 mut_k43_2___9 mut_m46_2___0 mut_m46_2___1 mut_m46_2___2 
	mut_m46_2___3 mut_m46_2___9 mut_i47_2___0 mut_i47_2___1 mut_i47_2___2 mut_i47_2___9 mut_g48_2___0 mut_g48_2___1 mut_g48_2___2 mut_g48_2___3 
	mut_g48_2___4 mut_g48_2___5 mut_g48_2___6 mut_g48_2___9 mut_i50_2___0 mut_i50_2___1 mut_i50_2___2 mut_i50_2___9 mut_f53_2___0 mut_f53_2___1 
	mut_f53_2___2 mut_f53_2___9 mut_i54_2___0 mut_i54_2___1 mut_i54_2___2 mut_i54_2___3 mut_i54_2___4 mut_i54_2___5 mut_i54_2___6 mut_i54_2___9 
	mut_q58_2___0 mut_q58_2___1 mut_q58_2___9 mut_d60_2___0 mut_d60_2___1 mut_d60_2___9 mut_i62_2___0 mut_i62_2___1 mut_i62_2___9 mut_l63_2___0 
	mut_l63_2___1 mut_l63_2___9 mut_a71_2___0 mut_a71_2___1 mut_a71_2___2 mut_a71_2___3 mut_a71_2___4 mut_a71_2___9 mut_g73_2___0 mut_g73_2___1 
	mut_g73_2___2 mut_g73_2___3 mut_g73_2___4 mut_g73_2___9 mut_t74_2___0 mut_t74_2___1 mut_t74_2___2 mut_t74_2___9 mut_l76_2___0 mut_l76_2___1 
	mut_l76_2___9 mut_v77_2___0 mut_v77_2___1 mut_v77_2___9 mut_v82_2___0 mut_v82_2___1 mut_v82_2___2 mut_v82_2___3 mut_v82_2___4 mut_v82_2___5
	mut_v82_2___6 mut_v82_2___7 mut_v82_2___8 mut_v82_2___9 mut_n83_2___0 mut_n83_2___1 mut_n83_2___9 mut_i84_2___0 mut_i84_2___1 mut_i84_2___2 
	mut_i84_2___3 mut_i84_2___9 mut_i85_2___0 mut_i85_2___1 mut_i85_2___9 mut_n88_2___0 mut_n88_2___1 mut_n88_2___2 mut_n88_2___3 mut_n88_2___4 
	mut_n88_2___9 mut_l89_2___0 mut_l89_2___1 mut_l89_2___2 mut_l89_2___3 mut_l89_2___4 mut_l89_2___9 mut_l90_2___0 mut_l90_2___1 mut_l90_2___9 
	mut_i93_2___0 mut_i93_2___1 mut_i93_2___2 mut_i93_2___9 ;
%binci(rest2, idx, table, &varlist);


data tab;
	length ci code0 $40;
	set tab(in=A keep=item nfy code rename=(nfy=ci))
		table(in=B keep=item ci pv);
	if A then do;  
		if item in(13,14) then code0=put(code,yn.);
		else code0=put(code,rest.);
	end;
	if B then item=item+14;

	format item item.;	
run;

ods rtf file="rest2_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 ci;
define item/"Characteristic" group order=internal format=item. style=[just=left width=3in];
define code0/"." ;
define ci/"#/n, %(95%CI)" ;
define pv/"p value";
run;
ods rtf close; 
