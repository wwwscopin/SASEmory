
options ls=120 orientation=portrait fmtsearch=(library);
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\Copy of RFS AMMENDED QUEST DATABASE-15 June 2011.xls" lrecl=1000;
filename rfs2 "&path\RFS AMMENDED CRF DATABASE- 15 June 2011.xls" lrecl=1000;

PROC IMPORT OUT= QUEST_con0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A4:GH111"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data  quest_con;
	set quest_con0(rename=(dob=dob0 ETH_GRP=ETH_GRP0  PRAC_REL= PRAC_REL0 yes_supp=yes_supp0 STOP_ARV=STOP_ARV0
		how_med=how_med0 side_eff=side_eff0 LIVE_YOU=LIVE_YOU0 benefic=benefic0 benefic1=benefic10));
	dob = input (compress(dob0,'-') , date9.); 
	ETH_GRP=ETH_GRP0+0;
	PRAC_REL= PRAC_REL+0;

	drop dob0 ETH_GRP0 PRAC_REL0;
run;

PROC IMPORT OUT= QUEST_case0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A4:GG67"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data  quest_case;
	set quest_case0(rename=(MONTH1=MONTH_1 yes_supp=yes_supp0 STOP_ARV=STOP_ARV0 how_med=how_med0 side_eff=side_eff0
		LIVE_YOU=LIVE_YOU0 benefic=benefic0 benefic1=benefic10));
	MONTH1 =MONTH_1+0; 
	drop month_1;
run;

data  brent.quest;
	length  STUDY_NO_ $8 id_num $14 other other1-other20 $60 address $43 WHAT_WRK $40 WHAT_FIN $43 
			yes_date $22  WHAT_WAL $7 which $29 CHR_DENO $47 form $4 route $4 COLOR $5 reason $18 where $7 
			feel $6  WHAT_SUP $24  WHAT_TRE $38  SAFE_SEX $3 EMO_SUPP $21  RELAT $15  WHI_DRUG $5  
			NO_WHY $77 DIFF_ARV $267  DIFF_HEA $230  DIFF_CLI $102  ADD_COMM $605;
	set quest_con(in=a ) quest_case(in=b);
	if a then gp=0; 
	if b then gp=1;

	age=(date-dob)/365.25;
	yes_supp=yes_supp0+0;
	STOP_ARV=STOP_ARV0+0;

	prearv=pre_arv+0;
	if STOP_ARV0="NA" then STOP_ARV=99;
	how_med=how_med0+0;
	if how_med0="NA" then how_med=99;
	side_eff=side_eff0+0;
	if side_eff0="NA" then side_eff=99;
	LIVE_YOU=LIVE_YOU0+0;
	benefic=benefic0+0; 
	benefic1=benefic10+0;

	what_serv=what_ser+0;

	who=whom+0;
	who1=whom1+0;
	if whom="NA" then who=99;
	if whom1="NA" then who1=99;

	safesex=safe_sex+0;
	if safe_sex='2a' then safesex=21; 
	if safe_sex='2b' then safesex=22; 

	CUT_DRINk= CUT_DRIN+0;
	if  CUT_DRIN="NA" then cut_drink=99;

	 CRIT_DRIn=   CRIT_DRI+0;
	if CRIT_DRI="NA" then   CRIT_DRIn=99;

	if score>=20 then slevel=1; else slevel=0;

	format _char_;
	informat _char_;
	rename  STUDY_NO_= STUDY_NO;
run;

proc sort; by study_no;run;
proc contents;run;

/*
proc compare base=quest_con compare=quest_case; 
   title 'Comparison of Variables in Different Data Sets';
run; 
proc contents data=brent.quest;run;
*/

PROC IMPORT OUT= CRF_con 
            DATAFILE= rfs2  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A3:EB110"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;

	 DBDSOPTS="DBSASTYPE=('START11'='CHAR(11)' 'START12'='CHAR(11)' 'START13'='CHAR(11)' 'date9'='CHAR(11)' 'date10'='CHAR(11)')" ; 
RUN;

PROC IMPORT OUT= CRF_case 
            DATAFILE= rfs2  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A3:EM66"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('START16'='CHAR(11)' 'START17'='CHAR(11)' 'START18'='CHAR(11)')" ; 
RUN;

/*
proc compare base=crf_con compare=crf_case; 
   title 'Comparison of Variables in Different Data Sets';
run; 
*/

data  brent.crf;
	length diag_dis diag_dis1-diag_dis5 $30 num_epis4 $4 med med1-med15 $25  CUR_DIAG CUR_DIAG1-CUR_DIAG6 $10 
		arvs arvs1-arvs6 $30 cd4 cd41-cd45 $4 vl vl3-vl4 $12 other $40 cau_arvs $40 har_arvs $10 add_comm $500
		INI_DATE2  REC_DATE2 REC_DATE4 REC_DATE5 stop6 start18 $11 ;
	set crf_con(in=a) crf_case(in=b);
	date_4 = input (compress(date4,'-') , date9.); 
	date_5 = input (compress(date5,'-') , date9.); 
	date_6 = input (compress(date6,'-') , date9.); 
	date_7 = input (compress(date7,'-') , date9.); 
	date_8 = input (compress(date8,'-') , date9.); 
	date_9 = input (compress(date9,'-') , date9.); 
	date_10 = input (compress(date10,'-') , date9.); 
	date_11 = input (compress(date11,'-') , date9.); 
	date_12 = input (compress(date12,'-') , date9.); 
	date_13 = input (compress(date13,'-') , date9.); 
	date_14 = input (compress(date14,'-') , date9.);

	INI_DATE_0 = input (compress(INI_DATE,'-') , date9.); 
	INI_DATE_1 = input (compress(INI_DATE1,'-') , date9.); 
	INI_DATE_2 = input (compress(INI_DATE2,'-') , date9.); 
	INI_DATE_3 = input (compress(INI_DATE3,'-') , date9.); 
	INI_DATE_4 = input (compress(INI_DATE4,'-') , date9.); 
	INI_DATE_5 = input (compress(INI_DATE5,'-') , date9.); 
	INI_DATE_6 = input (compress(INI_DATE6,'-') , date9.); 

	REC_DATE_0 = input (compress(REC_DATE,'-') , date9.); 
	REC_DATE_1 = input (compress(REC_DATE1,'-') , date9.); 
	REC_DATE_2 = input (compress(REC_DATE2,'-') , date9.); 
  	REC_DATE_3 = input (compress(REC_DATE3,'-') , date9.); 
	REC_DATE_4 = input (compress(REC_DATE4,'-') , date9.); 
	REC_DATE_5 = input (compress(REC_DATE5,'-') , date9.); 
  	REC_DATE_6 = input (compress(REC_DATE6,'-') , date9.); 


	start_0 = input (compress(start,'-') , date9.); 
	start_1 = input (compress(start1,'-') , date9.); 
	start_2 = input (compress(start2,'-') , date9.); 
	start_3 = input (compress(start3,'-') , date9.); 
	start_4 = input (compress(start4,'-') , date9.); 
	start_5 = input (compress(start5,'-') , date9.); 
	start_6 = input (compress(start6,'-') , date9.); 
	start_7 = input (compress(start7,'-') , date9.); 
	start_8 = input (compress(start8,'-') , date9.); 
	start_9 = input (compress(start9,'-') , date9.); 
	start_10 = input (compress(start10,'-') , date9.); 
	start_11 = input (compress(start11,'-') , date9.); 
	start_12 = input (compress(start12,'-') , date9.); 
	start_13 = input (compress(start13,'-') , date9.); 
	start_14 = input (compress(start14,'-') , date9.); 
	start_15 = input (compress(start15,'-') , date9.); 
	start_16 = input (compress(start16,'-') , date9.); 
	start_17 = input (compress(start17,'-') , date9.); 
	start_18 = input (compress(start18,'-') , date9.); 
	start_19 = input (compress(start19,'-') , date9.); 
	start_20 = input (compress(start20,'-') , date9.); 
	start_21 = input (compress(start21,'-') , date9.); 
	start_22 = input (compress(start22,'-') , date9.); 

	stop_0 = input (compress(stop,'-') , date9.); 
	stop_1 = input (compress(stop1,'-') , date9.); 
	stop_2 = input (compress(stop2,'-') , date9.); 
	stop_3 = input (compress(stop3,'-') , date9.); 
	stop_4 = input (compress(stop4,'-') , date9.); 
	stop_5 = input (compress(stop5,'-') , date9.); 
	stop_6 = input (compress(stop6,'-') , date9.); 
	stop_7 = input (compress(stop7,'-') , date9.); 

	if a then gp=0; 
	if b then gp=1;
	format _char_;
	informat _char_;

	if a then do; 
		start_cur_arv1=start_11; 
		start_cur_arv2=start_12;
		start_cur_arv3=start_13; 
		start_pre_arv1=start_14;
		start_pre_arv2=start_15;
		start_pre_arv3=start_16;
		start_pre_arv4=start_17;
		start_pre_arv5=start_18;
		cv_date1=date_9;
		cv_date2=date_10;
		cv_date3=date_11;
		cv_date4=date_12;
		cv_date5=date_13;
		cv_date6=date_14;
	end; 

	else do; 
		start_cur_arv1=start_16; 
		start_cur_arv2=start_17;
		start_cur_arv3=start_18; 
		start_pre_arv1=start_19;
		start_pre_arv2=start_20;
		start_pre_arv3=start_21;
		start_pre_arv4=start_22;
		cv_date1=date_8;
		cv_date2=date_9;
		cv_date3=date_10;
		cv_date4=date_11;
		cv_date5=date_12;
		cv_date6=date_13;
	end;
		
	drop  date4-date14 INI_DATE INI_DATE1-INI_DATE6 REC_DATE REC_DATE1-REC_DATE6
	start1-start22 stop stop1-stop7;
	rename  STUDY_NO_= STUDY_NO date=date_0 date1=date_1 date2=date_2 date3=date_3;

	format date_4-date_14 INI_DATE_0-INI_DATE_6 REC_DATE_0-REC_DATE_6 start_0-start_22 stop_0-stop_7 date9.;
run;

proc sort; by study_no;run;
proc contents data=brent.quest;run;
proc freq data=brent.quest;
	table side_eff*gp;
run;


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

%let pm=%sysfunc(byte(177));  
%macro stat(data, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data noprint;
		class gp;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		mean0=put(mean,5.1)||" &pm "||compress(put(std,5.1))||"["||compress(put(Q1,5.1))||" - "||compress(put(Q3,5.1))||"]";
		range=put(Q1,5.1)||" - "||compress(put(Q3,5.1));
		if gp=. then delete;
		format median 5.1;
		item=&i;
		keep gp mean0 median range item;
	run;

	proc npar1way data = &data wilcoxon;
  		class gp;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $5;
		set wp&i;
		if _n_=10;
		item=&i;
		pvalue=cvalue1+0;
		pv=put(pvalue, 4.2);
		if pvalue<0.01 then pv='<0.01';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(gp=0)) 
			tab&i(where=(gp=1)rename=(mean0=mean1 range=range1 median=median1)) wp&i; by item;
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
		proc freq data=&data ;
			table &var*gp/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH+0;
			if pvalue=. then pvalue= P_PCHI+0;
			if pvalue^=. and pvalue<0.01 then pv='<0.01'; else pv=put(pvalue,4.2);

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 4.2;
		run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;

	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(gp=1) keep=&var gp frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(gp=0) keep=&var gp frequency rename=(frequency=no)); 
		by &var;

		item=&i;

		if &var=. then delete;

		%if &var^=when %then %do;
		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";
		%end;
		%else %do;
		fy=ny/&ny*100; 		fn=no/&nn*100;
		nfy=ny||"/&ny"||"("||put(fy,5.1)||"%)";		nfn=no||"/&nn"||"("||put(fn,5.1)||"%)";
		%end;

		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";

		rename &var=code;
		drop gp;
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
		keep code item item0 ny no fy fn nfy nfn rpct or range pvalue pv;
		format RowPercent 5.1;
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
		proc freq data=&data ;
			table &var*gp/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH+0;
			if pvalue=. then pvalue= P_PCHI+0;
			if pvalue^=. and pvalue<0.01 then pv='<0.01'; else pv=put(pvalue,4.2);

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 4.2;
		run;

		data p&i;
			merge p&i(firstobs=1 obs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;

	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(gp=1) keep=&var gp frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(gp=0) keep=&var gp frequency rename=(frequency=no)); 
		by &var;

		item=&i;

		if &var=" " then delete;

		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";

		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";

		rename &var=code0;
		drop gp;
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
		keep code0 item item0 ny no fy fn nfy nfn rpct or range pvalue pv;
		format RowPercent 5.1;
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
	length nfy nfn $50 pv $5 code0 $50;
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

	format item demo.;
run;

proc print;run;

%let varlist=yes_supp NUM_PEOP;
%stat(brent.quest, &varlist);

%let varlist=income emp_stat othr_fin reside INF_SETT LIV_ARR WHAT_FAC WHI_HAVE NOT_ENOU AMT_FOOD WOUT_FOO 
	WHAT_CLI WHER_ARV TRAV_TIM TRAN_CLI PAYMENT FEEL_CLI TOUC_HIV MISTREAT REFU_MED TALK_PUB
	COST_VIS COS_TRAN TIME_WRK CHIL_CARE ILL FAM_CIRC; 
%tab(brent.quest, sociA, &varlist);
%let varlist=what_wrk WHAT_FIN WHAT_WAL WHAT_FLO;
%chartab(brent.quest, sociB, &varlist);

data quest_soci;
	length nfy nfn $50 pv $5 code0 $50;
	set socia(keep=item nfy nfn code pv where=(item=1))/*income*/
		stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=1) in=A) /*yes_supp*/
		socia(keep=item nfy nfn code pv where=(item=2) in=B) /*emp_stat*/
		socib(keep=item nfy nfn code0 pv where=(item=1) in=C) /*what_wrk*/
		socia(keep=item nfy nfn code pv where=(item=3) in=D) /*other income*/
		socib(keep=item nfy nfn code0 pv where=(item=2) in=E) /*what source*/
		socia(keep=item nfy nfn code pv where=(3<item<7) in=F) /*reside, inf_sett live_arr*/
		stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) where=(item=2) in=G)  /*num_peop*/
		socia(keep=item nfy nfn code pv where=(item=6) in=H) /*what_fac*/
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

	format item soci.;
run;


%let varlist=week month week1 month1;
%stat(brent.quest, &varlist);

%let varlist= REM_TAKE REM_PICK AWAY_HME WER_BUSY FORG_PIL MANY_PIL AVOI_SID OTH_SEE CHA_EVRY FEL_ASLP FELT_ILL
			PROB_PIL FORG_OBT RAN_PILL MON_ARVS TIR_ARVS DISL_PIL DIFF_SWA;
%tab(brent.quest, med, &varlist);


data quest_med;
	length nfy nfn $50 pv $5 code0 $50;
	set stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy)) 
		med(keep=item nfy nfn code pv in=A )
	;

	if A then item=item+4;

	if item in(5) then do; code0=put(code, rem_med.);  end;
	if item in(6) then do; code0=put(code, rem_apt.);  end;
	if item>6 then do; code0=put(code, freq.);    end;

	format item med.;
	group=3;
run;


%let varlist=RELIGION PRAC_REL stop_arv TRAD_MED when how_med TAKE_SUP HOW_FEEL ALT_TREA HOW_FEEL1 RECOMMEN;
%tab(brent.quest, faithA, &varlist);

%let varlist=WHICH CHR_DENO WHAT_SUP;
%chartab(brent.quest, faithB, &varlist);


data quest_faith;
	length nfy nfn $50 pv $5 code0 $50;
	set faithA(keep=item nfy nfn code pv where=(item=1))
	 	faithB(keep=item nfy nfn code0 pv where=(item<3)in=A )
		faithA(keep=item nfy nfn code pv where=(1<item<8) in=B )
		faithB(keep=item nfy nfn code0 pv where=(item=3)in=C )
		faithA(keep=item nfy nfn code pv where=(8<=item) in=D )
	;

	if A then item=item+1;
	if B then item=item+2;
	if C then item=item+8;
	if D then item=item+3;

	if item in(1,5,6,9,10,12) then do; code0=put(code, yn.);  end;
	if item in(4) then do; code0=put(code, pra_rel.);  end;
	if item in(7) then do; code0=put(code, when.);  end;
	if item in(8) then do; code0=put(code, how_med.);  end;
	if item in(11,13) then do; code0=put(code, how_feel.);  end;
	if item in(14) then do; code0=put(code, recom.);  end;

	format item faith.;
	group=4;
run;

%let varlist=NUM_PART PART_LIV PART_TES PART_POS PART_ARV CHILDREN CARE_OF CHIL_TES CHIL_POS POSITIVE DIED;
%stat(brent.quest, &varlist);

%let varlist=MAR_STAT SAFESEX HOW_OFT who_hiv live_you TREA_SUP HAVE_HUR HOW_HURT HAVE_SEX who PERF_SEX who1 WHEN_LAS 
	USE_DRUG DRI_ALCO WHAT_ALC SMOKE WHAT_SMO ENOU_EDU prearv benefic ADH_COUN benefic1 ADD_SUPP ACC_SERV WHAT_SERv;
%tab(brent.quest, psyA, &varlist);

%let varlist=EMO_SUPP RELAT WHAT_SUP;
%chartab(brent.quest, psyB, &varlist);

data quest_psy;
	length nfy nfn $50 pv $5 code0 $50;
	set psyA(keep=item nfy nfn code pv where=(item<=3))	/*1-3*/
	 	stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) in=A) /*4-14*/
		psyA(keep=item nfy nfn code pv where=(item=4) in=B)	/*15*/
		psyB(keep=item nfy nfn code0 pv where=(item=1) in=C) /*16*/
		psyA(keep=item nfy nfn code pv where=(item in(5,6)) in=D)/*17-18*/
		psyB(keep=item nfy nfn code0 pv where=(item=2) in=E) /*19*/
		psyA(keep=item nfy nfn code pv where=(7<=item<=24) in=F) /*20-37*/
		psyB(keep=item nfy nfn code0 pv where=(item=3) in=G) /*38*/
		psyA(keep=item nfy nfn code pv where=(item>24) in=H)	/*39-40*/
	;

	if A then item=item+3;
	if B then item=item+11;
	if C then item=item+15;
	if D then item=item+12;
	if E then item=item+17;
	if F then item=item+13;
	if G then item=item+35;
	if H then item=item+14;


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

	format item psy.;
	group=5;
run;

%let varlist=FEEL_TIR FEEL_NER NOT_CALM HOPELESS REST_FID SO_REST FEEL_SAD SO_DEP EVER_EFF WORTHLEsS;
%tab(brent.quest, scale, &varlist);

%let varlist=SCORE;
%stat(brent.quest, &varlist);

%let varlist=slevel RES_COUN RES_DOCT;
%tab(brent.quest, share, &varlist);


data quest_scale;
	length nfy nfn $50 pv $5 code0 $50;
	set scale(keep=item nfy nfn code pv)	/*1-3*/
	 	stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy) in=A) /*4-14*/
		share(keep=item nfy nfn code pv in=B)	/*15*/
	;

	if A then item=item+10;
	if B then item=item+11;

	if 1<=item<=10 then do; code0=put(code, tt.);  end;
	if item in(12,13,14) then do; code0=put(code, yn.);  end;

	format item psy.;
	group=6;
	if in B then group=7;
run;

proc print;run;


ods rtf file="quest.rtf" style=journal startpage=no bodytitle;

proc print data=quest_tab split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient characteristic at study enrollment.";
	by item notsorted;
	id item;
	var code0/style(data)=[just=left cellwidth=2.5in] style(header)=[just=center];
	var nfn nfy /style(data)=[just=right cellwidth=1.5in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=1.0in]  style(header)=[just=center];
	label 
		Item="Characteristic"
		code0="."
		nfn="Control (n=&no)"
		nfy="Cases (n=&yes)"
		pv="P value";
run;
ods rtf close;

data crf;
	length study_no $8;
	merge brent.crf 
	brent.quest(keep=study_no gender GR_EDUC religion trad_med when mar_stat dri_alco income gp); 
	by study_no;

	disease_aids=diag_dis;
	if max(ini_date_0, ini_date_1-ini_date_2)=ini_date_1 then disease_aids=diag_dis1;
	if max(ini_date_0, ini_date_1-ini_date_2)=ini_date_2 then disease_aids=diag_dis2;

	disease_noaids=diag_dis3;
	if max(of ini_date_3-ini_date_5)=ini_date_4 then disease_noaids=diag_dis4;
	if max(of ini_date_3-ini_date_5)=ini_date_5 then disease_noaids=diag_dis5;

	cur_arv=arvs;
	if max(of start_cur_arv1-start_cur_arv3)=start_cur_arv2 then cur_arv=arvs1;
	if max(of start_cur_arv1-start_cur_arv3)=start_cur_arv3 then cur_arv=arvs2;

	duration=date_0-max(of start_pre_arv1-start_pre_arv5);
	
	CD_lab=CD4+0;	VL_lab=VL+0; if VL="<25" then VL_lab=25; if VL="NA" then VL_lab=.;
	if max(of cv_date1-cv_date6)=cv_date2 then do; CD_lab=CD41+0; Vl_lab=VL1+0; if VL1="<25" then VL_lab=25; if VL="NA" then VL_lab=.; end;
	if max(of cv_date1-cv_date6)=cv_date3 then do; CD_lab=CD42+0; Vl_lab=VL2+0; if VL2="<25" then VL_lab=25; if VL="NA" then VL_lab=.; end;
	if max(of cv_date1-cv_date6)=cv_date4 then do; CD_lab=CD43+0; Vl_lab=VL3+0; if VL3="<25" then VL_lab=25; if VL="NA" then VL_lab=.; end;
	if max(of cv_date1-cv_date6)=cv_date5 then do; CD_lab=CD44+0; Vl_lab=VL4+0; if VL4="<25" then VL_lab=25; if VL="NA" then VL_lab=.; end;
	if max(of cv_date1-cv_date6)=cv_date6 then do; CD_lab=CD45+0; Vl_lab=VL5+0; if VL5="<25" then VL_lab=25; if VL="NA" then VL_lab=.; end;

	if VL_lab=0 then VL_lab=.;

	keep study_no disease_aids	disease_noaids cur_arv duration CD_lab VL_lab religion trad_med when mar_stat dri_alco
	date_0 gender GR_EDUC income gp arvs arvs1 arvs2;
	
run;

proc contents data=crf; run;
proc means data=crf;
	class gp;
	var vl_lab;
run;

%let varlist=duration CD_lab VL_lab;
%stat(crf, &varlist);


data stat;	
	set stat;
	item=item+3;
run;

%let varlist=disease_aids disease_noaids cur_arv;
%chartab(crf, clinA, &varlist);

*%let varlist=disease_aids disease_noaids cur_arv religion med when mar_stat dri_alco ;
%let varlist=religion trad_med when mar_stat dri_alco ;
%tab(crf, clinB, &varlist);

data clin;	
	set clinA(in=A) 
		clinB(in=B rename=(code=code0));

	if B then item=item+6;
run;

data clinical;
	length nfy nfn $50 pv $5;
	set stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy)) clin(keep=item nfy nfn code code0 pv); by item;

	if item in(7,8) then do; code=put(code0, yn.);  end;

	if item in(9) then do;  code=put(code0, when.);    end;
	if item in(10) then do; code=put(code0, mar.);  end;
	if item in(11) then do; code=put(code0, alcohol.); end;

	format item clinical.;
	output;
	if last.item then do; Call missing( of _all_ ) ; output; end;
run;

proc print;run;

ods rtf file="clinical.rtf" style=journal startpage=no bodytitle;

proc print data=clinical split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient History of Clinical";
	by item notsorted;
	id item;
	var code/style(data)=[just=left cellwidth=2.5in] style(header)=[just=center];
	var nfn nfy /style(data)=[just=right cellwidth=1.5in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=1.0in]  style(header)=[just=center];
	format item clinical.;
	label 
		Item="Characteristic"
		code="."
		nfn="Control (n=&no)"
		nfy="Cases (n=&yes)"
		pv="P value";
run;
ods rtf close;
