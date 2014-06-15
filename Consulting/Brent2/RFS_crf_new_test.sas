

libname brent "H:/SAS_Emory/Consulting/Brent2";		
options ls=120 orientation=portrait fmtsearch=(brent);
%include "vince_macro.sas";

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
%let pm=%sysfunc(byte(177));  

proc contents data=brent.crf;run;

proc print data=brent.crf;
var study_no arvs6 arvs7;
run;



%let varlist=diag_dis diag_dis1 diag_dis2;
%chartab(brent.crf, gp, aidsA, &varlist);

%let varlist=num_epis cur_diag num_epis1 cur_diag1 num_epis2 cur_diag2;
%tab(brent.crf, gp, aidsB, &varlist);

data aids; 
	set aidsA(where=(item=1)) aidsB (where=(item in(1,2)) in=A)
		aidsA(where=(item=2) in=B) aidsB (where=(item in(3,4)) in=C)
		aidsA(where=(item=3) in=D) aidsB (where=(item in(5,6)) in=E);
	if A then item=item+1;
	if B then item=item+2;
	if C then item=item+2;
	if D then item=item+4;
	if E then item=item+3;
run;


%let varlist=diag_dis3 diag_dis4 diag_dis5;
%chartab(brent.crf, gp, nonaidsA, &varlist);

%let varlist=num_epis3 cur_diag3 num_epis4 cur_diag4 num_epis5 cur_diag5;
%tab(brent.crf, gp, nonaidsB, &varlist);

data nonaids; 
	set nonaidsA(where=(item=1)) nonaidsB (where=(item in(1,2)) in=A)
		nonaidsA(where=(item=2) in=B) nonaidsB (where=(item in(3,4)) in=C)
		nonaidsA(where=(item=3) in=D) nonaidsB (where=(item in(5,6)) in=E);
	if A then item=item+1;
	if B then item=item+2;
	if C then item=item+2;
	if D then item=item+4;
	if E then item=item+3;
run;


%let varlist=med med1 med2 med3 med4 med5 med6 med7 med8 med9 med10 med11 med12 med13 med14 med15;
%chartab(brent.crf, gp, med, &varlist);

%let varlist=arvs arvs1 arvs2;
%chartab(brent.crf, gp, cur_arvs, &varlist);

%let varlist=arvs3 arvs4 arvs5 arvs6 arvs7;
%chartab(brent.crf, gp, pre_arvs, &varlist);

%let varlist=cd_1 vl_1 cd_2 vl_2  cd_3 vl_3  cd_4 vl_4  cd_5 vl_5;
%stat(brent.crf, gp, &varlist);

data stat1;
	set stat;
run;

%let varlist=FATIGUE FEV_CHIL FEEL_DIZ PAIN_TIN TRO_REM NAUS_VOM DIARRHEA SAD_DEPR NERV_ANX DIF_SLPN SKIN_PRB COUGH
HEADACHE LOSS_APE BLOATING MUSC_ACH PROB_SEX CHA_BODY PROB_WEI CHA_HAIR;
%stat(brent.crf, gp, &varlist);

data stat2;
	set stat;
run;

%let varlist=CAU_ARVS HAR_ARVS ;
%tab(brent.crf, gp, lastA, &varlist);

%let varlist=ADD_COMM;
%chartab(brent.crf, gp, lastB, &varlist);

data last;
	set lastA lastB(in=B);
	if B then item=item+2;
run;

%let varlist=mean_dispens;
%stat(brent.crf, gp, &varlist);

data stat3;
	set stat;
run;

%let varlist=tq;
%tab(brent.crf, gp, tq, &varlist);

data crf0;
	length item0 code0 nfn nfy $100;
	set aids(in=A) nonaids(in=B) med(in=C) cur_arvs(in=D) pre_arvs(in=E)  
		stat1(in=F keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy))
		stat2(in=G keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy))
		last(in=H)
		stat3(in=I keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy))
		tq(in=J)
		;
	if A then do; group=1; item0=put(item, aids.); end;
	if B then do; group=2; item0=put(item, aids.); end;
	if C then do; group=3; item0=put(item, med.); end;
	if D then do; group=4; item0=put(item, curarvs.); end;
	if E then do; group=5; item0=put(item, prearvs.); end;
	if F then do; group=6; item0=put(item, lab.); end;
	if G then do; group=7; item0=put(item, symptom.); end;
	if H then do; group=8; item0=put(item, last.); end;
	if J then do; item=item+1; code0=put(code,adh.); end;
	if I or J then do; group=9; item0=put(item, tq.); end;

	keep group item item0 nfy nfn code0 pv;	
run;

proc sort; by group item;run;

data crf;
	set crf0; by group item;
	if not first.item then item0=" ";
	format group gp.;
run;

ods rtf file="clinical_con_cas.rtf" style=journal startpage=no bodytitle;

proc print data=crf split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient History of Clinical";
	by group;
	id item0;
	var code0/style(data)=[just=left cellwidth=1.5in] style(header)=[just=center];
	var nfn nfy /style(data)=[just=right cellwidth=2in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=0.6in]  style(header)=[just=center];
	format item clinical.;
	label 
		Item0="Variable"
		code0="."
		nfn="Control (n=&no)"
		nfy="Cases (n=&yes)"
		pv="P value";
run;
ods rtf close;
