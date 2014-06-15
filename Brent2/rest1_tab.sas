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

	21='M41 (choice=M (WT))'
	22='M41 (choice=L)'

	23='M41 (choice=Other)'
	24='44 (choice=E (WT))'
	25='44 (choice=A)'
	26='44 (choice=D)'
	27='44 (choice=Other)'
	28='A62 (choice=A (WT))'
	29='A62 (choice=V)'
	30='A62 (choice=Other)'
	31='K65 (choice=K (WT))'
	32='K65 (choice=N)'
	33='K65 (choice=R)'
	34='K65 (choice=Other)'
	35='D67 (choice=D (WT))'
	36='D67 (choice=E)'
	37='D67 (choice=G)'
	38='D67 (choice=N)'
	39='D67 (choice=d)'
	40='D67 (choice=Other)'
	41='T69 (choice=T (WT))'
	42='T69 (choice=A)'
	43='T69 (choice=D)'
	44='T69 (choice=G)'
	45='T69 (choice=I)'
	46='T69 (choice=N)'
	47='T69 (choice=S)'
	48='T69 (choice=i)'
	49='T69 (choice=Other)'
	50='K70 (choice=K (WT))'
	51='K70 (choice=E)'
	52='K70 (choice=G)'
	53='K70 (choice=R)'
	54='K70 (choice=T)'
	55='K70 (choice=Other)'
	56='L74 (choice=L (WT))'
	57='L74 (choice=I)'
	58='L74 (choice=V)'
	59='L74 (choice=Other)'
	60='V75 (choice=V (WT))'
	61='V75 (choice=A)'
	62='V75 (choice=I)'
	63='V75 (choice=L)'
	64='V75 (choice=M)'
	65='V75 (choice=S)'
	66='V75 (choice=T)'
	67='V75 (choice=Other)'
	68='F77 (choice=F (WT))'
	69='F77 (choice=L)'
	70='F77 (choice=Other)'
	71='V90 (choice=V (WT))'
	72='V90 (choice=I)'
	73='V90 (choice=Other)'
	74='A98 (choice=A (WT))'
	75='A98 (choice=G)'
	76='A98 (choice=S)'
	77='A98 (choice=Other)'
	78='L100 (choice=L (WT))'
	79='L100 (choice=I)'
	80='L100 (choice=Other)'
	81='K101 (choice=K (WT))'
	82='K101 (choice=E)'
	83='K101 (choice=H)'
	84='K101 (choice=N)'
	85='K101 (choice=P)'
	86='K101 (choice=Q)'
	87='K101 (choice=R)'
	88='K101 (choice=Other)'
	89='K103 (choice=K (WT))'
	90='K103 (choice=E)'
	91='K103 (choice=H)'
	92='K103 (choice=N)'
	93='K103 (choice=Q)'
	94='K103 (choice=R)'
	95='K103 (choice=S)'
	96='K103 (choice=T)'
	97='K103 (choice=Other)'
	98='V106 (choice=V (WT))'
	99='V106 (choice=A)'
	100='V106 (choice=I)'
	101='V106 (choice=L)'
	102='V106 (choice=M)'
	103='V106 (choice=Other)'
	104='V108 (choice=V (WT))'
	105='V108 (choice=I)'
	106='V108 (choice=Other)'
	107='G109 (choice=G (WT))'
	108='G109 (choice=E)'
	109='G109 (choice=S)'
	110='G109 (choice=Other)'
	111='Y115 (choice=Y (WT))'
	112='Y115 (choice=F)'
	113='Y115 (choice=S)'
	114='Y115 (choice=Other)'
	115='F116 (choice=F (WT))'
	116='F116 (choice=Y)'
	117='F116 (choice=Other)'
	118='118 (choice=V (WT))'
	119='118 (choice=I)'
	120='118 (choice=Other)'
	121='E138 (choice=E (WT))'
	122='E138 (choice=A)'
	123='E138 (choice=G)'
	124='E138 (choice=K)'
	125='E138 (choice=Q)'
	126='E138 (choice=Other)'
	127='Q151 (choice=Q (WT))'
	128='Q151 (choice=L)'
	129='Q151 (choice=M)'
	130='Q151 (choice=Other)'
	131='V179 (choice=V (WT))'
	132='V179 (choice=D)'
	133='V179 (choice=E)'
	134='V179 (choice=F)'
	135='V179 (choice=I)'
	136='V179 (choice=T)'
	137='V179 (choice=Y)'
	138='V179 (choice=Other)'
	139='Y181 (choice=Y (WT))'
	140='Y181 (choice=C)'
	141='Y181 (choice=I)'
	142='Y181 (choice=S)'
	143='Y181 (choice=V)'
	144='Y181 (choice=Other)'
	145='M184 (choice=M (WT))'
	146='M184 (choice=C)'
	147='M184 (choice=I)'
	148='M184 (choice=V)'
	149='M184 (choice=Other)'
	150='Y188 (choice=Y (WT))'
	151='Y188 (choice=C)'
	152='Y188 (choice=F)'
	153='Y188 (choice=H)'
	154='Y188 (choice=L)'
	155='Y188 (choice=N)'
	156='Y188 (choice=Other)'
	157='G190 (choice=G (WT))'
	158='G190 (choice=A)'
	159='G190 (choice=C)'
	160='G190 (choice=D)'
	161='G190 (choice=E)'
	162='G190 (choice=Q)'
	163='G190 (choice=S)'
	164='G190 (choice=T)'
	165='G190 (choice=V)'
	166='G190 (choice=Other)'
	167='L210 (choice=L (WT))'
	168='L210 (choice=F)'
	169='L210 (choice=S)'
	170='L210 (choice=W)'
	171='L210 (choice=Other)'
	172='T215 (choice=T (WT))'
	173='T215 (choice=C)'
	174='T215 (choice=D)'
	175='T215 (choice=E)'
	176='T215 (choice=F)'
	177='T215 (choice=I)'
	178='T215 (choice=S)'
	179='T215 (choice=V)'
	180='T215 (choice=Y)'
	181='T215 (choice=Other)'
	182='K219 (choice=K (WT))'
	183='K219 (choice=D)'
	184='K219 (choice=E)'
	185='K219 (choice=H)'
	186='K219 (choice=N)'
	187='K219 (choice=Q)'
	188='K219 (choice=R)'
	189='K219 (choice=W)'
	190='K219 (choice=Other)'
	191='H221 (choice=H (WT))'
	192='H221 (choice=Y)'
	193='H221 (choice=Other)'
	194='P225 (choice=P (WT))'
	195='P225 (choice=H)'
	196='P225 (choice=Other)'
	197='F227 (choice=F (WT))'
	198='F227 (choice=C)'
	199='F227 (choice=L)'
	200='F227 (choice=Other)'
	201='M230 (choice=M (WT))'
	202='M230 (choice=L)'
	203='M230 (choice=Other)'
	204='234 (choice=L (WT))'
	205='234 (choice=I)'
	206='234 (choice=Other)'
	207='236 (choice=P (WT))'
	208='236 (choice=L)'
	209='236 (choice=Other)'
	210='238 (choice=K (WT))'
	211='238 (choice=N)'
	212='238 (choice=R)'
	213='238 (choice=T)'
	214='238 (choice=Other)'
	215='Y318 (choice=Y (WT))'
	216='Y318 (choice=F)'
	217='Y318 (choice=Other)'
	218='333 (choice=G (WT))'
	219='333 (choice=D)'
	220='333 (choice=E)'
	221='333 (choice=Other)'
	222='N348 (choice=N (WT))'
	223='N348 (choice=I)'
	224='N348 (choice=Other)'
	225='PI Major Mutations'
	226='L10 (choice=L (WT))'
	227='L10 (choice=F)'
	228='L10 (choice=I)'
	229='L10 (choice=R)'
	230='L10 (choice=V)'
	231='L10 (choice=Y)'
	232='L10 (choice=Other)'
	233='V11 (choice=V (WT))'
	234='V11 (choice=I)'
	235='V11 (choice=Other)'
	236='13 (choice=I (WT))'
	237='13 (choice=V)'
	238='13 (choice=Other)'
	239='G16 (choice=G (WT))'
	240='G16 (choice=E)'
	241='G16 (choice=Other)'
	242='K20 (choice=K (WT))'
	243='K20 (choice=I)'
	244='K20 (choice=M)'
	245='K20 (choice=R)'
	246='K20 (choice=T)'
	247='K20 (choice=V)'
	248='K20 (choice=Other)'
	249='23 (choice=L (WT))'
	250='23 (choice=I)'
	251='23 (choice=Other)'
	252='L24 (choice=L (WT))'
	253='L24 (choice=F)'
	254='L24 (choice=I)'
	255='L24 (choice=Other)'
	256='D30 (choice=D (WT))'
	257='D30 (choice=N)'
	258='D30 (choice=Other)'
	259='V32 (choice=V (WT))'
	260='V32 (choice=I)'
	261='V32 (choice=Other)'
	262='L33 (choice=L (WT))'
	263='L33 (choice=F)'
	264='L33 (choice=I)'
	265='L33 (choice=V)'
	266='L33 (choice=Other)'
	267='35 (choice=E (WT))'
	268='35 (choice=G)'
	269='35 (choice=Other)'
	270='M36 (choice=M (WT))'
	271='M36 (choice=I)'
	272='M36 (choice=L)'
	273='M36 (choice=T)'
	274='M36 (choice=V)'
	275='M36 (choice=Other)'
	276='K43 (choice=K (WT))'
	277='K43 (choice=T)'
	278='K43 (choice=Other)'
	279='M46 (choice=M (WT))'
	280='M46 (choice=I)'
	281='M46 (choice=L)'
	282='M46 (choice=V)'
	283='M46 (choice=Other)'
	284='I47 (choice=I (WT))'
	285='I47 (choice=A)'
	286='I47 (choice=V)'
	287='I47 (choice=Other)'
	288='G48 (choice=G (WT))'
	289='G48 (choice=A)'
	290='G48 (choice=M)'
	291='G48 (choice=Q)'
	292='G48 (choice=S)'
	293='G48 (choice=T)'
	294='G48 (choice=V)'
	295='G48 (choice=Other)'
	296='I50 (choice=I (WT))'
	297='I50 (choice=L)'
	298='I50 (choice=V)'
	299='I50 (choice=Other)'
	300='F53 (choice=F (WT))'
	301='F53 (choice=L)'
	302='F53 (choice=Y)'
	303='F53 (choice=Other)'
	304='I54 (choice=I (WT))'
	305='I54 (choice=A)'
	306='I54 (choice=L)'
	307='I54 (choice=M)'
	308='I54 (choice=S)'
	309='I54 (choice=T)'
	310='I54 (choice=V)'
	311='I54 (choice=Other)'
	312='Q58 (choice=Q (WT))'
	313='Q58 (choice=E)'
	314='Q58 (choice=Other)'
	315='D60 (choice=D (WT))'
	316='D60 (choice=E)'
	317='D60 (choice=Other)'
	318='I62 (choice=I (WT))'
	319='I62 (choice=V)'
	320='I62 (choice=Other)'
	321='L63 (choice=L (WT))'
	322='L63 (choice=P)'
	323='L63 (choice=Other)'
	324='A71 (choice=A (WT))'
	325='A71 (choice=I)'
	326='A71 (choice=L)'
	327='A71 (choice=T)'
	328='A71 (choice=V)'
	329='A71 (choice=Other)'
	330='G73 (choice=G (WT))'
	331='G73 (choice=A)'
	332='G73 (choice=C)'
	333='G73 (choice=S)'
	334='G73 (choice=T)'
	335='G73 (choice=Other)'
	336='T74 (choice=T (WT))'
	337='T74 (choice=P)'
	338='T74 (choice=S)'
	339='T74 (choice=Other)'
	340='L76 (choice=L (WT))'
	341='L76 (choice=V)'
	342='L76 (choice=Other)'
	343='V77 (choice=V (WT))'
	344='V77 (choice=I)'
	345='V77 (choice=Other)'
	346='V82 (choice=V (WT))'
	347='V82 (choice=A)'
	348='V82 (choice=C)'
	349='V82 (choice=F)'
	350='V82 (choice=I)'
	351='V82 (choice=L)'
	352='V82 (choice=M)'
	353='V82 (choice=S)'
	354='V82 (choice=T)'
	355='V82 (choice=Other)'
	356='N83 (choice=N (WT))'
	357='N83 (choice=D)'
	358='N83 (choice=Other)'
	359='I84 (choice=I (WT))'
	360='I84 (choice=A)'
	361='I84 (choice=C)'
	362='I84 (choice=V)'
	363='I84 (choice=Other)'
	364='I85 (choice=I (WT))'
	365='I85 (choice=V)'
	366='I85 (choice=Other)'
	367='N88 (choice=N (WT))'
	368='N88 (choice=D)'
	369='N88 (choice=G)'
	370='N88 (choice=S)'
	371='N88 (choice=T)'
	372='N88 (choice=Other)'
	373='L89 (choice=L (WT))'
	374='L89 (choice=I)'
	375='L89 (choice=M)'
	376='L89 (choice=T)'
	377='L89 (choice=V)'
	378='L89 (choice=Other)'
	379='L90 (choice=L (WT))'
	380='L90 (choice=M)'
	381='L90 (choice=Other)'
	382='I93 (choice=I (WT))'
	383='I93 (choice=L)'
	384='I93 (choice=M)'
	385='I93 (choice=Other)'
	;

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
	format idx idx.;
	drop vl_enroll0 vl_mccord0 hpp_recent0;
run;

/*
data case_rest;
	set rest1;
	if idx=1;
run;
proc sort; by id;run;
proc print;run;
*/

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

%let varlist= vl_enroll vl_mccord hpp_recent;
%avg(rest1,&varlist);

proc print data=stat;run;

%let varlist= genotype_done resist_3tc resist_abc resist_azt resist_d4t resist_ddi resist_dlv resist_efv resist_etr resist_ftc resist_npv resist_rpv resist_tdf 
	mut_nrti mut_nnrti mut_pi_major mut_pi_minor;
%tab(rest1, idx, tab, &varlist);

%let varlist= mut_m41___0 mut_m41___1 mut_m41___9 mut_44___0 mut_44___1 mut_44___2 mut_44___9 mut_a62___0 mut_a62___1 mut_a62___9 
	mut_k65___0 mut_k65___1 mut_k65___2 mut_k65___9 mut_d67___0 mut_d67___1 mut_d67___2 mut_d67___3 mut_d67___4 mut_d67___9 mut_t69___0 mut_t69___1 
	mut_t69___2 mut_t69___3 mut_t69___4 mut_t69___5 mut_t69___6 mut_t69___7 mut_t69___9 mut_k70___0 mut_k70___1 mut_k70___2 mut_k70___3 mut_k70___4 
	mut_k70___9 mut_l74___0 mut_l74___1 mut_l74___2 mut_l74___9 mut_v75___0 mut_v75___1 mut_v75___2 mut_v75___3 mut_v75___4 mut_v75___5 mut_v75___6 
	mut_v75___9 mut_f77___0 mut_f77___1 mut_f77___9 mut_v90___0 mut_v90___1 mut_v90___9 mut_a98___0 mut_a98___1 mut_a98___2 mut_a98___9 mut_l100___0 
	mut_l100___1 mut_l100___9 mut_k101___0 mut_k101___1 mut_k101___2 mut_k101___3 mut_k101___4 mut_k101___5 mut_k101___6 mut_k101___9 mut_k103___0 
	mut_k103___1 mut_k103___2 mut_k103___3 mut_k103___4 mut_k103___5 mut_k103___6 mut_k103___7 mut_k103___9 mut_v106___0 mut_v106___1 mut_v106___2 
	mut_v106___3 mut_v106___4 mut_v106___9 mut_v108___0 mut_v108___1 mut_v108___9 mut_g109___0 mut_g109___1 mut_g109___2 mut_g109___9 mut_y115___0 
	mut_y115___1 mut_y115___2 mut_y115___9 mut_f116___0 mut_f116___1 mut_f116___9 mut_118___0 mut_118___1 mut_118___9 mut_e138___0 mut_e138___1 
	mut_e138___2 mut_e138___3 mut_e138___4 mut_e138___9 mut_q151___0 mut_q151___1 mut_q151___2 mut_q151___9 mut_v179___0 mut_v179___1 mut_v179___2 
	mut_v179___3 mut_v179___4 mut_v179___5 mut_v179___6 mut_v179___9 mut_y181___0 mut_y181___1 mut_y181___2 mut_y181___3 mut_y181___4 mut_y181___9 
	mut_m184___0 mut_m184___1 mut_m184___2 mut_m184___3 mut_m184___9 mut_y188___0 mut_y188___1 mut_y188___2 mut_y188___3 mut_y188___4 mut_y188___5 
	mut_y188___9 mut_g190___0 mut_g190___1 mut_g190___2 mut_g190___3 mut_g190___4 mut_g190___5 mut_g190___6 mut_g190___7 mut_g190___8 mut_g190___9 
	mut_l210___0 mut_l210___1 mut_l210___2 mut_l210___3 mut_l210___9 mut_t215___0 mut_t215___1 mut_t215___2 mut_t215___3 mut_t215___4 mut_t215___5 
	mut_t215___6 mut_t215___7 mut_t215___8 mut_t215___9 mut_k219___0 mut_k219___1 mut_k219___2 mut_k219___3 mut_k219___4 mut_k219___5 mut_k219___6 
	mut_k219___7 mut_k219___9 mut_h221___0 mut_h221___1 mut_h221___9 mut_p225___0 mut_p225___1 mut_p225___9 mut_f227___0 mut_f227___1 mut_f227___2 
	mut_f227___9 mut_m230___0 mut_m230___1 mut_m230___9 mut_234___0 mut_234___1 mut_234___9 mut_236___0 mut_236___1 mut_236___9 mut_238___0 
	mut_238___1 mut_238___2 mut_238___3 mut_238___9 mut_y318___0 mut_y318___1 mut_y318___9 mut_333___0 mut_333___1 mut_333___2 mut_333___9 
	mut_n348___0 mut_n348___1 mut_n348___9 mut_pi_major mut_l10___0 mut_l10___1 mut_l10___2 mut_l10___3 mut_l10___4 mut_l10___5 mut_l10___9 
	mut_v11___0 mut_v11___1 mut_v11___9 mut_13___0 mut_13___1 mut_13___9 mut_g16___0 mut_g16___1 mut_g16___9 mut_k20___0 mut_k20___1 mut_k20___2 
	mut_k20___3 mut_k20___4 mut_k20___5 mut_k20___9 mut_23___0 mut_23___1 mut_23___9 mut_l24___0 mut_l24___1 mut_l24___2 mut_l24___9 mut_d30___0 
	mut_d30___1 mut_d30___9 mut_v32___0 mut_v32___1 mut_v32___9 mut_l33___0 mut_l33___1 mut_l33___2 mut_l33___3 mut_l33___9 mut_35___0 mut_35___1 
	mut_35___9 mut_m36___0 mut_m36___1 mut_m36___2 mut_m36___3 mut_m36___4 mut_m36___9 mut_k43___0 mut_k43___1 mut_k43___9 mut_m46___0 mut_m46___1 
	mut_m46___2 mut_m46___3 mut_m46___9 mut_i47___0 mut_i47___1 mut_i47___2 mut_i47___9 mut_g48___0 mut_g48___1 mut_g48___2 mut_g48___3 mut_g48___4
	mut_g48___5 mut_g48___6 mut_g48___9 mut_i50___0 mut_i50___1 mut_i50___2 mut_i50___9 mut_f53___0 mut_f53___1 mut_f53___2 mut_f53___9 mut_i54___0 
	mut_i54___1 mut_i54___2 mut_i54___3 mut_i54___4 mut_i54___5 mut_i54___6 mut_i54___9 mut_q58___0 mut_q58___1 mut_q58___9 mut_d60___0 mut_d60___1 
	mut_d60___9 mut_i62___0 mut_i62___1 mut_i62___9 mut_l63___0 mut_l63___1 mut_l63___9 mut_a71___0 mut_a71___1 mut_a71___2 mut_a71___3 mut_a71___4 
	mut_a71___9 mut_g73___0 mut_g73___1 mut_g73___2 mut_g73___3 mut_g73___4 mut_g73___9 mut_t74___0 mut_t74___1 mut_t74___2 mut_t74___9 mut_l76___0 
	mut_l76___1 mut_l76___9 mut_v77___0 mut_v77___1 mut_v77___9 mut_v82___0 mut_v82___1 mut_v82___2 mut_v82___3 mut_v82___4 mut_v82___5 mut_v82___6 
	mut_v82___7 mut_v82___8 mut_v82___9 mut_n83___0 mut_n83___1 mut_n83___9 mut_i84___0 mut_i84___1 mut_i84___2 mut_i84___3 mut_i84___9 mut_i85___0 
	mut_i85___1 mut_i85___9 mut_n88___0 mut_n88___1 mut_n88___2 mut_n88___3 mut_n88___4 mut_n88___9 mut_l89___0 mut_l89___1 mut_l89___2 mut_l89___3 
	mut_l89___4 mut_l89___9 mut_l90___0 mut_l90___1 mut_l90___9 mut_i93___0 mut_i93___1 mut_i93___2 mut_i93___9;
%binci(rest1, idx, table, &varlist);


data tab;
	length ci code0 $40;
	set stat(keep=item mean0 rename=(mean0=ci))
		tab(in=A keep=item nfy code rename=(nfy=ci))
		table(in=B keep=item ci pv);
	if A then do; item=item+3; 
		if item=4 then code0=put(code,genotype_done.); 
		else if item in(17,18,19,20) then code0=put(code,yn.);
		else code0=put(code,rest.);
	end;
	if B then item=item+20;

	format item item.;	
run;

ods rtf file="rest1_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 ci;
define item/"Characteristic" group order=internal format=item. style=[just=left width=3in];
define code0/"." ;
define ci/"#/n, %(95%CI)" ;
define pv/"p value";
run;
ods rtf close; 
