libname library "H:/SAS_Emory/Consulting/Brent2";	
options ls=256 orientation=landscape fmtsearch=(library) nofmterr;
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\CROI ABSTRACT- QUESTIONNAIRES.xls" lrecl=1000;
ods listing;
PROC IMPORT OUT= QUEST_con0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A4:GM134"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 TEXTSIZE=1024;
	 DBDSOPTS="DBSASTYPE=('WHI_DRUG'='CHAR(11)' 'other6'='CHAR(11)' 'other13'='CHAR(11)')" ; 
RUN;

data  quest_con;
	set quest_con0(rename=(other9=other_9 other14=other_14 other16=other_16 other18=other_18));
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);
	drop other_9 other_14 other_16 other_18;
run;

PROC IMPORT OUT= QUEST_case0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A4:GM89"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('name'='CHAR(11)' 'form'='CHAR(11)' 'route'='CHAR(11)' 'color'='CHAR(11)'  
		'reason'='CHAR(11)' 'where'='CHAR(11)' 'feel'='CHAR(11)' 'other4'='CHAR(11)' 'other7'='CHAR(11)')" ; 
RUN;

data  quest_case;
	set quest_case0(rename=(MONTH1=MONTH_1 other9=other_9 other14=other_14 other16=other_16 other18=other_18));
	MONTH1 =MONTH_1+0; 
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);
	drop month_1 other_9 other_14 other_16 other_18;
run;

proc print data=brent.quest;
var study_no date dob age; 
run;

proc compare base=quest_con compare=quest_case LISTCOMPVAR; 
   title 'Comparison of Variables in Different Data Sets';
run; 

data  brent.quest;
	length  STUDY_NO_ $8 id_num $14 other other1-other20 $60 address $43 WHAT_WRK $40 WHAT_FIN $43 
			yes_date $22  WHAT_sup1 $19 which $29 CHR_DENO $47  WHAT_SUP $24  WHAT_TRE $38  SAFE_SEX $3 EMO_SUPP $21  RELAT $21 
			NO_WHY $77 DIFF_ARV $267  DIFF_HEA $230  DIFF_CLI $127  ADD_COMM $605 name $11 form $11 route $11 color $11  where $11 feel $11;
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
/*
data brent.quest;
	merge brent.quest brent.pill(keep=study_no tq); by study_no;
run;
*/

data brent.quest;
	merge brent.quest brent.test(keep=study_no idx rename=(idx=tq)); by study_no;
run;

proc freq data=brent.quest;
	table tq;
	ods output OneWayFreqs =freq;
run;

data _null_;
	set freq;
	if tq=1 then call symput("ntq1", compress(frequency));
	if tq=2 then call symput("ntq2", compress(frequency));
	if tq=3 then call symput("ntq3", compress(frequency));
run;
%let n=%eval(&ntq1+&ntq2+&ntq3);

proc freq data=brent.quest;
	table TRAD_MED*tq;
	ods output crosstabfreqs =med;
run;

data _null_;
	set med;
	if tq=1 and trad_med=1 then call symput("m1", compress(frequency));
	if tq=2 and trad_med=1 then call symput("m2", compress(frequency));
	if tq=3 and trad_med=1 then call symput("m3", compress(frequency));
run;

%let pm=%sysfunc(byte(177));  
%macro stat(data, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data(where=(&var not in(-77,-88,-99))) /*noprint*/;
		class tq;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.1))||" - "||compress(put(Q3,5.1))||"]";
		range=put(Q1,5.1)||" - "||compress(put(Q3,5.1));
		if tq=. then delete;
		format median 5.1;
		item=&i;
		keep tq mean0 median range item;
	run;

	*ods trace on/label listing;
	proc npar1way data = &data wilcoxon;
  		class tq;
  		var &var;
  		ods output Wilcoxon.KruskalWallisTest=wp&i;
	run;

	*ods trace off;

	data wp&i;
		set wp&i;
		if _n_=3;
		item=&i;
		pvalue=nvalue1;
		pv=put(pvalue, 7.3);
		if pvalue<0.001 then pv='<0.001';
		keep item pvalue pv;
	run;

	data tab&i;
		merge 
			tab&i(where=(tq=1) rename=(mean0=mean1 range=range1 median=median1)) 
			tab&i(where=(tq=2) rename=(mean0=mean2 range=range2 median=median2)) 
			tab&i(where=(tq=3) rename=(mean0=mean3 range=range3 median=median3))
		wp&i; by item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend stat;	

%macro tab(data, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data(where=(&var not in(-77,-88,-99))) ;
			table &var*tq/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			set p&i;
			item=&i;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,7.4);

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 7.4;
		run;

			proc print data=p1;run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;

	data tab&i;
		length nf1-nf3 $25;
		merge 
			tab&i(where=(tq=1) keep=&var tq frequency rowpercent rename=(frequency=n1 rowpercent=rp1)) 
			tab&i(where=(tq=2) keep=&var tq frequency rowpercent rename=(frequency=n2 rowpercent=rp2)) 
			tab&i(where=(tq=3) keep=&var tq frequency rowpercent rename=(frequency=n3 rowpercent=rp3)); 
		by &var;

		item=&i;

		if &var=. then delete;

		%if &var^=when %then %do;
		f1=n1/&ntq1*100; 		f2=n2/&ntq2*100; f3=n3/&ntq3*100;
		nf1=n1||"("||put(f1,5.1)||"%)";			nf2=n2||"("||put(f2,5.1)||"%)"; 	nf3=n3||"("||put(f3,5.1)||"%)";
		%end;
		%else %do;
		f1=n1/&m1*100; 		f2=n2/&m2*100; 	f3=n3/&m3*100;
		nf1=n1||"/&m1"||"("||put(f1,5.1)||"%)";		nf2=n2||"/&m2"||"("||put(f2,5.1)||"%)"; nf3=n3||"/&m3"||"("||put(f3,5.1)||"%)";
		%end;

		tmp=n1+n2+n3;
		rpct1=n1||"/"||compress(tmp)||"("||put(rp1,4.1)||"%)";
		rpct2=n2||"/"||compress(tmp)||"("||put(rp2,4.1)||"%)";
		rpct3=n3||"/"||compress(tmp)||"("||put(rp3,4.1)||"%)";

		rename &var=code;
		drop tq;
	run;

	%if &data=brent.quest %then %do;
	%if %eval(&i in 1 3 5 8) %then %do; proc sort data=tab&i; by code; run; %end;
	%else %do; proc sort data=tab&i; by descending code; run; %end;
	%end;

	data tab&i;
		merge tab&i p&i; by item ;
		/*if fy<5 and fn<5 then do; or=.; range=.; pvalue=.; end;*/
		if not first.item then do; pvalue=.; or=.; range=.; pv=" "; end;
	run;

	data &out;
		length item0 $100;
		set &out tab&i; 
		item0=put(item, item.); 
		keep code item item0 n1-n3 f1-f3 nf1-nf3 rpct1-rpct3 or range pvalue pv;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;


%macro chartab(data, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data(where=(&var not in('-77','-88','-99'))) ;
			table &var*tq/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH+0;
			if pvalue=. then pvalue= P_PCHI+0;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,7.4);

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 7.4;
		run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;

	data tab&i;
		length nf1-nf3 $25;
		merge 
			tab&i(where=(tq=1) keep=&var tq frequency rowpercent rename=(frequency=n1 rowpercent=rp1)) 
			tab&i(where=(tq=2) keep=&var tq frequency rowpercent rename=(frequency=n2 rowpercent=rp2)) 
			tab&i(where=(tq=3) keep=&var tq frequency rowpercent rename=(frequency=n3 rowpercent=rp3)); 
		by &var;

		item=&i;

		if &var=" " then delete;

		f1=n1/&ntq1*100; 		f2=n2/&ntq2*100; f3=n3/&ntq3*100;
		nf1=n1||"("||put(f1,5.1)||"%)";			nf2=n2||"("||put(f2,5.1)||"%)"; nf3=n3||"("||put(f3,5.1)||"%)";

		tmp=n1+n2+n3;
		rpct1=n1||"/"||compress(tmp)||"("||put(rp1,4.1)||"%)";
		rpct2=n2||"/"||compress(tmp)||"("||put(rp2,4.1)||"%)";
		rpct3=n3||"/"||compress(tmp)||"("||put(rp3,4.1)||"%)";

		rename &var=code0;
		drop tq;
	run;
/*
	%if &data=brent.quest %then %do;
	%if %eval(&i in 1 3 5 8) %then %do; proc sort data=tab&i; by code; run; %end;
	%else %do; proc sort data=tab&i; by descending code; run; %end;
	%end;
*/
	data tab&i;
		merge tab&i p&i; by item ;
		/*if fy<5 and fn<5 then do; or=.; range=.; pvalue=.; end;*/
		if not first.item then do; pvalue=.; or=.; range=.; pv=" "; end;
	run;

	data &out;
		length item0 $100;
		set &out tab&i; 
		keep code0 item item0 n1-n3 f1-f3 nf1-nf3 rpct1-rpct3 or range pvalue pv;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend chartab;

%let varlist=age gr_educ;
%stat(brent.quest, &varlist);

%let varlist=gender race_eth eth_grp read UNDRSTND speak sens_imp;
%tab(brent.quest, demo, &varlist);

data quest_demo;
	length nf1-nf3 $50 pv $10 code0 $100 item0 $100;
	set stat(keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) where=(item=1)) 
		demo(keep=item nf1-nf3 code pv where=(item in (1,2,3)) in=A )
		stat(keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) where=(item=2) in=B) 
		demo(keep=item nf1-nf3 code pv where=(3<item) in=C)
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


%let varlist=yes_supp NUM_PEOP;
%stat(brent.quest, &varlist);

%let varlist=income emp_stat othr_fin reside INF_SETT LIV_ARR WHAT_FAC WHI_HAVE NOT_ENOU AMT_FOOD WOUT_FOO 
	WHAT_CLI WHER_ARV TRAV_TIM TRAN_CLI PAYMENT FEEL_CLI TOUC_HIV MISTREAT REFU_MED TALK_PUB
	COST_VIS COS_TRAN TIME_WRK CHIL_CARE ILL FAM_CIRC; 
%tab(brent.quest, sociA, &varlist);
%let varlist=what_wrk WHAT_FIN WHAT_WAL WHAT_FLO;
%chartab(brent.quest, sociB, &varlist);

data quest_soci;
	length nf1-nf3 $50 pv $10 code0 $100 item0 $100;
	set socia(keep=item nf1-nf3 code pv where=(item=1))/*income*/
		stat(keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) where=(item=1) in=A) /*yes_supp*/
		socia(keep=item nf1-nf3 code pv where=(item=2) in=B) /*emp_stat*/
		socib(keep=item nf1-nf3 code0 pv where=(item=1) in=C) /*what_wrk*/
		socia(keep=item nf1-nf3 code pv where=(item=3) in=D) /*other income*/
		socib(keep=item nf1-nf3 code0 pv where=(item=2) in=E) /*what source*/
		socia(keep=item nf1-nf3 code pv where=(3<item<7) in=F) /*reside, inf_sett live_arr*/
		stat(keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) where=(item=2) in=G)  /*num_peop*/
		socia(keep=item nf1-nf3 code pv where=(item=7) in=H) /*what_fac*/
		socib(keep=item nf1-nf3 code0 pv where=(item in(3,4)) in=I) /*what wal, what flo*/
		socia(keep=item nf1-nf3 code pv where=(7<item) in=J)	
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
%stat(brent.quest, &varlist);

%let varlist= REM_TAKE REM_PICK AWAY_HME WER_BUSY FORG_PIL MANY_PIL AVOI_SID OTH_SEE CHA_EVRY FEL_ASLP FELT_ILL
			PROB_PIL FORG_OBT RAN_PILL MON_ARVS TIR_ARVS DISL_PIL DIFF_SWA;
%tab(brent.quest, med, &varlist);


data quest_med;
	length nf1-nf3 $50 pv $10 code0 $100 item0 $100;
	set stat(keep=item mean1 mean2  mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3)) 
		med(keep=item nf1-nf3 code pv in=A )
	;

	if A then item=item+4;

	if item in(5) then do; code0=put(code, rem_med.);  end;
	if item in(6) then do; code0=put(code, rem_apt.);  end;
	if item>6 then do; code0=put(code, freq.);    end;

	item0=put(item, qmed.);
	group=3;
run;

%let varlist=RELIGION PRAC_REL stop_arv TRAD_MED when how_med TAKE_SUP HOW_FEEL ALT_TREA HOW_FEEL1 RECOMMEN;
%tab(brent.quest, faithA, &varlist);

%let varlist=WHICH CHR_DENO WHAT_SUP;
%chartab(brent.quest, faithB, &varlist);


data quest_faith;
	length nf1-nf3 $50 pv $10 code0 $150 item0 $100;
	set faithA(keep=item nf1-nf3 code pv where=(item=1)) /*1*/
	 	faithB(keep=item nf1-nf3 code0 pv where=(item<3)in=A ) /*2-3*/
		faithA(keep=item nf1-nf3 code pv where=(1<item<=7) in=B ) /*4-9*/
		faithB(keep=item nf1-nf3 code0 pv where=(item=3)in=C ) /*10*/
		faithA(keep=item nf1-nf3 code pv where=(8<=item) in=D )	/*11*/
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
%stat(brent.quest, &varlist);

%let varlist=MAR_STAT SAFESEX HOW_OFT who_hiv live_you TREA_SUP HAVE_HUR HOW_HURT HAVE_SEX whom PERF_SEX whom1 WHEN_LAS 
	USE_DRUG DRI_ALCO WHAT_ALC SMOKE WHAT_SMO ENOU_EDU prearv benefic ADH_COUN benefic1 ADD_SUPP ACC_SERV WHAT_SER;
%tab(brent.quest, psyA, &varlist);

%let varlist=EMO_SUPP RELAT WHAT_SUP1;
%chartab(brent.quest, psyB, &varlist);

data quest_psy;
	length nf1-nf3 $50 pv $10 code0 $100 item0 $100;
	set psyA(keep=item nf1-nf3 code pv where=(item<=3))	/*1-3*/
	 	stat(keep=item mean1 mean2  mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) in=A) /*4-14*/
		psyA(keep=item nf1-nf3 code pv where=(item=4) in=B)	/*15*/
		psyB(keep=item nf1-nf3 code0 pv where=(item=1) in=C) /*16*/
		psyA(keep=item nf1-nf3 code pv where=(item in(5,6)) in=D)/*17-18*/
		psyB(keep=item nf1-nf3 code0 pv where=(item=2) in=E) /*19*/
		psyA(keep=item nf1-nf3 code pv where=(7<=item<=24) in=F) /*20-37*/
		psyB(keep=item nf1-nf3 code0 pv where=(item=3) in=G) /*38*/
		psyA(keep=item nf1-nf3 code pv where=(item>24) in=H)	/*39-40*/
	;

	if A then item=item+3;
	if B then item=item+11;
	if C then item=item+15;
	if D then item=item+12;
	if E then item=item+17;
	if F then item=item+13;
	if G then item=item+35;
	if H then item=item+14;

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
%tab(brent.quest, scale, &varlist);

%let varlist=SCORE;
%stat(brent.quest, &varlist);

%let varlist=slevel RES_COUN RES_DOCT;
%tab(brent.quest, share, &varlist);


data quest_scale;
	length nf1-nf3 $50 pv $10 code0 $100 item0 $100;
	set scale(keep=item nf1-nf3 code pv)	/*1-3*/
	 	stat(keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3) in=A) /*4-14*/
		share(keep=item nf1-nf3 code pv in=B)	/*15*/
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

ods rtf file="quest_test.rtf" style=journal startpage=no bodytitle;

proc print data=quest_tab split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient characteristic at study enrollment.";
	by group;
	id  item0/style(data)=[just=left cellwidth=2.5in] style(header)=[just=left];
	var code0/style(data)=[just=left cellwidth=2.0in] style(header)=[just=center];
	var nf1 nf2 nf3 /style(data)=[just=right cellwidth=1.5in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=1.0in]  style(header)=[just=center];
	label 
		Item0="Characteristic"
		code0="."
		nf1="MND/ANI(n=&ntq1)"
		nf2="HAD(n=&ntq2)"
		nf3="NA(n=&ntq3)"
		pv="p value";
run;
ods rtf close;
