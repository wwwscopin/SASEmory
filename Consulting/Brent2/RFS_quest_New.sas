
libname brent "H:/SAS_Emory/Consulting/Brent2";	
options ls=256 orientation=landscape fmtsearch=(brent) nofmterr;
%let path=H:\SAS_Emory\Consulting\Brent2;

filename rfs1 "&path\RFS AMMENDED QUEST DATABASE.xls" lrecl=2000;
ods listing;

%include "vince_macro.sas";

PROC IMPORT OUT= QUEST_con0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A4:GL209"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 TEXTSIZE=1024;
	 DBDSOPTS="DBSASTYPE=('WHI_DRUG'='CHAR(11)' 'relat'='CHAR(11)'  'other8'='CHAR(8)'  'other13'='CHAR(11)' 'other10'='CHAR(11)'  
			              'other19'='CHAR(11)'  'other20'='CHAR(11)' 'other4'='CHAR(21)' )" ; 
RUN;

data  quest_con;
	set quest_con0(rename=(other9=other_9 other14=other_14 other16=other_16 other18=other_18));
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);

	drop other_9 other_14 other_16 other_18;
run;
proc print data=quest_con0;
var study_no_  dob;
run;


PROC IMPORT OUT= QUEST_case0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A4:GL114"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('what_fin'='CHAR(43)' 'no_why'='CHAR(63)'  'other'='CHAR(11)'  'other5'='CHAR(21)' 'other4'='CHAR(21)')" ; 
RUN;

data  quest_case;
	set quest_case0(rename=(MONTH1=MONTH_1 other9=other_9 other14=other_14 other16=other_16 other18=other_18 live_you=live_you_tmp));
	MONTH1 =MONTH_1+0; 
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);
	live_you=live_you_tmp+0;
	drop month_1 other_9 other_14 other_16 other_18;
run;

proc compare base=quest_con compare=quest_case LISTCOMPVAR; 
   title 'Comparison of Variables in Different Data Sets';
run; 

data  brent.quest;
	length  STUDY_NO_ $8 id_num $14 other other1-other3 other5 other8-other10 other12-other20 $60 address $45 WHAT_WRK $40 WHAT_FIN $43  WHAT_sup1 $19 which $29 CHR_DENO $47  
			WHAT_SUP $24  SAFE_SEX $3 EMO_SUPP $21  RELAT $21 NO_WHY $77 DIFF_ARV $267  DIFF_HEA $230  DIFF_CLI $127  ADD_COMM $605 ;
	set quest_con(in=a ) quest_case(in=b);
	if a then gp=0; 
	if b then gp=1;

	age=(date-dob)/365.25;
	
	prearv=pre_arv+0;
	safesex=safe_sex+0;
	if safe_sex='2a' then safesex=21;  
	if safe_sex='2b' then safesex=22; 

	if score>=20 then slevel=1; else slevel=0;
	if 	WHAT_WRK="-77" then WHAT_WRK="NA(-77)";
		if 	WHAT_FIN="-77" then WHAT_FIN="NA(-77)";
			if 	WHICH="-77" then WHICH="NA(-77)";
					if 	CHR_DENO="-77" then CHR_DENO="NA(-77)";
							if 	stop_arv="-77" then stop_arv="NA(-77)";
								if 	how_med="-77" then how_med="NA(-77)";
									if 	what_sup="-77" then what_sup="NA(-77)";
									if 	what_sup="-88" then what_sup="NA(-88)";
										if EMO_SUPP="-77" then EMO_SUPP="NA(-77)";
										if EMO_SUPP="-88" then EMO_SUPP="NA(-88)";
										if relat="-77" then relat="NA(-77)";
										if WHAT_SUP1="-77" then WHAT_SUP1="NA(-77)";
	format _char_;
	informat _char_;
	rename  STUDY_NO_= STUDY_NO _forward=forward;
run;

proc sort; by study_no;run;

proc print data=brent.quest;
var study_no date dob age; 
run;
proc contents;run;

proc freq data=brent.quest;
	table gp;
	ods output OneWayFreqs =freq;
run;

data _null_;
	set freq;
	if gp=1 then call symput("yes", compress(frequency));
	if gp=0 then call symput("no", compress(frequency));
run;
%let n=%eval(&yes+&no);

proc freq data=brent.quest;
	table TRAD_MED*gp;
	ods output crosstabfreqs =med;
run;

data _null_;
	set med;
	if gp=0 and trad_med=1 then call symput("nn", compress(frequency));
	if gp=1 and trad_med=1 then call symput("ny", compress(frequency));
run;

%put &nn;
%put &ny;

%let varlist=age gr_educ;
%stat(brent.quest, gp, &varlist);

%let varlist=gender race_eth eth_grp read UNDRSTND speak sens_imp;
%tab(brent.quest, gp, demo, &varlist);

data quest_demo;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=1)) 
		demo(keep=item nfy nfn code pv where=(item in (1,2,3)) in=A )
		stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=2) in=B) 
		demo(keep=item nfy nfn code pv where=(3<item) in=C)
	;

	if A then item=item+1;
	if B then item=item+3;
	if C then item=item+2;

	if item in(2) then do; code0=put(code, gender.);  end;
	if item in(3) then do; code0=put(code, race.);  end;
	if item in(4) then do; code0=put(code, eth.);    end;
	if item in(6,7,8) then do; code0=put(code, lang.); end;
	if item in(9) then do; code0=put(code, sense.);  end;

	group=1;

	item0=put(item, demo.);
run;
proc print;run;

%let varlist=yes_supp NUM_PEOP;
%stat(brent.quest, gp, &varlist);

%let varlist=income emp_stat othr_fin reside INF_SETT LIV_ARR WHAT_FAC WHI_HAVE NOT_ENOU AMT_FOOD WOUT_FOO 
	WHAT_CLI WHER_ARV TRAV_TIM TRAN_CLI PAYMENT FEEL_CLI TOUC_HIV MISTREAT REFU_MED TALK_PUB
	COST_VIS COS_TRAN TIME_WRK CHIL_CARE ILL FAM_CIRC; 
%tab(brent.quest, gp, sociA, &varlist);
%let varlist=what_wrk WHAT_FIN WHAT_WAL WHAT_FLO;
%chartab(brent.quest, gp, sociB, &varlist);

data quest_soci;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set socia(keep=item nfy nfn code pv where=(item=1))/*income*/
		stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=1) in=A) /*yes_supp*/
		socia(keep=item nfy nfn code pv where=(item=2) in=B) /*emp_stat*/
		socib(keep=item nfy nfn code0 pv where=(item=1) in=C) /*what_wrk*/
		socia(keep=item nfy nfn code pv where=(item=3) in=D) /*other income*/
		socib(keep=item nfy nfn code0 pv where=(item=2) in=E) /*what source*/
		socia(keep=item nfy nfn code pv where=(3<item<7) in=F) /*reside, inf_sett live_arr*/
		stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=2) in=G)  /*num_peop*/
		socia(keep=item nfy nfn code pv where=(item=7) in=H) /*what_fac*/
		socib(keep=item nfy nfn code0 pv where=(item in(3,4)) in=I) /*what wal, what flo*/
		socia(keep=item nfy nfn code pv where=(7<item) in=J)	
	;
	

	if A then item=item+1;
	if B then item=item+1;
	if C then item=item+3;
	if D then item=item+2;
	if E then item=item+4;
	if F then item=item+3;
	if G then item=item+8;
	if H then item=item+4;
	if I then item=item+9;
	if J then item=item+6;

	if item=6 and code0="NA" then delete;

	if item in(1,5,8) then do; code0=put(code, yn.);  end;
	if item in(3) then do; code0=put(code, employ.);  end;
	if item in(7) then do; code0=put(code, reside.);    end;
	if item in(9) then do; code0=put(code, live.); end;
	if item in(11) then do; code0=put(code, fac.);  end;
	if item in(14) then do; code0=put(code, tool.);  end;
	if item in(15) then do; code0=put(code, food.);  end;
	if item in(16) then do; code0=put(code, amount.);  end;
	if item in(17) then do; code0=put(code, nofood.);  end;
	if item in(18) then do; code0=put(code, clin.);  end;
	if item in(19) then do; code0=put(code, arv.);  end;
	if item in(20) then do; code0=put(code, tclin.);  end;
	if item in(21) then do; code0=put(code, tranclin.);  end;
	if item in(22) then do; code0=put(code, payclin.);  end;
	if item in(23) then do; code0=put(code, feelclin.);  end;
	if 24<=item<=33  then do; code0=put(code, freq.);  end;

	group=2;

	item0=put(item, soci.);
run;


%let varlist=week month week1 month1;
%stat(brent.quest, gp, &varlist);

%let varlist= REM_TAKE REM_PICK AWAY_HME WER_BUSY FORG_PIL MANY_PIL AVOI_SID OTH_SEE CHA_EVRY FEL_ASLP FELT_ILL
			PROB_PIL FORG_OBT RAN_PILL MON_ARVS TIR_ARVS DISL_PIL DIFF_SWA;
%tab(brent.quest, gp, med, &varlist);


data quest_med;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy)) 
		med(keep=item nfy nfn code pv in=A )
	;

	if A then item=item+4;

	if item in(5) then do; code0=put(code, rem_med.);  end;
	if item in(6) then do; code0=put(code, rem_apt.);  end;
	if item>6 then do; code0=put(code, freq.);    end;

	item0=put(item, med.);
	group=3;
run;


%let varlist=RELIGION PRAC_REL stop_arv TRAD_MED when how_med TAKE_SUP HOW_FEEL ALT_TREA HOW_FEEL1 RECOMMEN;
%tab(brent.quest,  gp, faithA, &varlist);

%let varlist=WHICH CHR_DENO WHAT_SUP;
%chartab(brent.quest, gp, faithB, &varlist);


data quest_faith;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set faithA(keep=item nfy nfn code pv where=(item=1)) /*1*/
	 	faithB(keep=item nfy nfn code0 pv where=(item<3)in=A ) /*2-3*/
		faithA(keep=item nfy nfn code pv where=(1<item<=7) in=B ) /*4-9*/
		faithB(keep=item nfy nfn code0 pv where=(item=3)in=C ) /*10*/
		faithA(keep=item nfy nfn code pv where=(8<=item) in=D )	/*11*/
	;

	if A then item=item+1;
	if B then item=item+2;
	if C then item=item+7;
	if D then item=item+3;

	if item in(1,5,6,9,12) then do; code0=put(code, yn.);  end;
	if item in(4) then do; code0=put(code, pra_rel.);  end;
	if item in(7) then do; code0=put(code, when.);  end;
	if item in(8) then do; code0=put(code, how_med.);  end;
	if item in(11,13) then do; code0=put(code, how_feel.);  end;
	if item in(14) then do; code0=put(code, recom.);  end;

	if item=2 and code0="NA" then delete;

	item0=put(item, faith.);
	group=4;
run;


%let varlist=NUM_PART PART_LIV PART_TES PART_POS PART_ARV CHILDREN CARE_OF CHIL_TES CHIL_POS POSITIVE DIED;
%stat(brent.quest, gp, &varlist);

%let varlist=MAR_STAT HOW_OFT who_hiv live_you TREA_SUP HAVE_HUR HOW_HURT HAVE_SEX whom PERF_SEX whom1 WHEN_LAS 
	USE_DRUG DRI_ALCO WHAT_ALC SMOKE WHAT_SMO ENOU_EDU prearv benefic ADH_COUN benefic1 ADD_SUPP ACC_SERV WHAT_SER;
%tab(brent.quest, gp, psyA, &varlist);

%let varlist=SAFE_SEX EMO_SUPP RELAT WHAT_SUP1;
%chartab(brent.quest, gp, psyB, &varlist);

data quest_psy;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set psyA(keep=item nfy nfn code pv where=(item=1))	/*1-3*/
		psyB(keep=item nfy nfn code0 pv where=(item=1) in=tmpa)	/*1-3*/
		psyA(keep=item nfy nfn code pv where=(item=2) in=tmpb)	/*1-3*/
	 	stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) in=A) /*4-14*/
		psyA(keep=item nfy nfn code pv where=(item=3) in=B)	/*15*/
		psyB(keep=item nfy nfn code0 pv where=(item=2) in=C) /*16*/
		psyA(keep=item nfy nfn code pv where=(item in(4,5)) in=D)/*17-18*/
		psyB(keep=item nfy nfn code0 pv where=(item=3) in=E) /*19*/
		psyA(keep=item nfy nfn code pv where=(6<=item<=23) in=F) /*20-37*/
		psyB(keep=item nfy nfn code0 pv where=(item=4) in=G) /*38*/
		psyA(keep=item nfy nfn code pv where=(item>23) in=H)	/*39-40*/
	;

	if tmpa then item=item+1;
	if tmpb then item=item+1;

	if A then item=item+3;
	if B then item=item+12;
	if C then item=item+14;
	if D then item=item+13;
	if E then item=item+16;
	if F then item=item+14;
	if G then item=item+34;
	if H then item=item+15;

	if item=19 and code0="NA" then delete;


	if item in(1) then do; code0=put(code, mar.);  end;
	if item in(2) then do; code0=put(code, safe_sex.);  end;
	if item in(3) then do; code0=put(code, how_oft.);  end;
	if item in(15) then do; code0=put(code, who_hiv.);  end;
	if item in(17,18,27,30,34,36,37,39) then do; code0=put(code, yn.);  end;
	if item in(20) then do; code0=put(code, have_hurt.);  end;
	if item in(21) then do; code0=put(code, how_hurt.);  end;
	if item in(22,24) then do; code0=put(code, force_sex.);  end;
	if item in(23,25) then do; code0=put(code, whom.);  end;
	if item in(26) then do; code0=put(code, when_las.);  end;
	if item in(28) then do; code0=put(code, alcohol.);  end;
	if item in(29) then do; code0=put(code, typ_alc.);  end;
	if item in(31) then do; code0=put(code, what_smoke.);  end;
	if item in(32) then do; code0=put(code, hiv_edu.);  end;
	if item in(33) then do; code0=put(code, pre_arv.);  end;
	if item in(35) then do; code0=put(code, adh_coun.);  end;
	if item in(40) then do; code0=put(code, what_ser.);  end;

	item0=put(item, psy.);
	group=5;
run;

%let varlist=FEEL_TIR FEEL_NER NOT_CALM HOPELESS REST_FID SO_REST FEEL_SAD SO_DEP EVER_EFF WORTHLEsS;
%tab(brent.quest, gp, scale, &varlist);

%let varlist=SCORE;
%stat(brent.quest, gp, &varlist);

%let varlist=slevel RES_COUN RES_DOCT;
%tab(brent.quest, gp, share, &varlist);


data quest_scale;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set scale(keep=item nfy nfn code pv)	/*1-3*/
	 	stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) in=A) /*4-14*/
		share(keep=item nfy nfn code pv in=B)	/*15*/
	;

	if A then item=item+10;
	if B then item=item+11;

	if 1<=item<=10 then do; code0=put(code, tt.);  end;
	if item in(12,13,14) then do; code0=put(code, yn.);  end;

	item0=put(item, scale.);
	group=6;
	if item in (13,14) then group=7;
run;

data quest_tab;
	set quest_demo quest_soci quest_med quest_faith quest_psy quest_scale; by group item;
	format group group.;
	if not first.item then item0=" ";
run;
ods listing;

ods rtf file="quest_con_cas.rtf" style=journal startpage=no bodytitle;

proc print data=quest_tab split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient characteristic at study enrollment.";
	by group;
	id  item0/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
	var code0/style(data)=[just=left cellwidth=2.0in] style(header)=[just=center];
	var nfn nfy /style(data)=[just=right cellwidth=1.5in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=1.0in]  style(header)=[just=center];
	label 
		Item0="Characteristic"
		code0="."
		nfn="Control (n=&no)"
		nfy="Cases (n=&yes)"
		pv="P value";
run;
ods rtf close;
