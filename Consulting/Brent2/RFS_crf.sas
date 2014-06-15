
options ls=120 orientation=portrait fmtsearch=(library);
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\Copy of RFS AMMENDED QUEST DATABASE-15 June 2011.xls" lrecl=1000;
filename rfs2 "&path\RFS AMMENDED CRF DATABASE- 15 June 2011.xls" lrecl=1000;

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

	cd_1=cd4+0; vl_1=vl+0; 
	cd_2=cd41+0; vl_2=vl1+0; 
	cd_3=cd42+0; vl_3=vl2+0; 
	cd_4=cd43+0; vl_4=vl3+0; 
	cd_5=cd44+0; vl_5=vl4+0; 
	cd_6=cd45+0; vl_6=vl5+0; 

		
	drop  date4-date14 INI_DATE INI_DATE1-INI_DATE6 REC_DATE REC_DATE1-REC_DATE6
	start1-start22 stop stop1-stop7;
	rename  STUDY_NO_= STUDY_NO date=date_0 date1=date_1 date2=date_2 date3=date_3;

	format date_4-date_14 INI_DATE_0-INI_DATE_6 REC_DATE_0-REC_DATE_6 start_0-start_22 stop_0-stop_7 date9.;
run;

proc sort; by study_no;run;

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

proc contents data=brent.crf;run;

%let varlist=diag_dis num_epis cur_diag diag_dis1 num_epis1 cur_diag1 diag_dis2 num_epis2 cur_diag2;
%chartab(brent.crf, aids, &varlist);

%let varlist=diag_dis3 num_epis3 cur_diag3 diag_dis4 num_epis4 cur_diag4 diag_dis5 num_epis5 cur_diag5;
%chartab(brent.crf, nonaids, &varlist);

%let varlist=med med1 med2 med3 med4 med5 med6 med7 med8 med9 med10 med11 med12 med13 med14 med15;
%chartab(brent.crf, med, &varlist);

%let varlist=arvs arvs1 arvs2;
%chartab(brent.crf, cur_arvs, &varlist);

%let varlist=arvs3 arvs4 arvs5 arvs6 arvs7;
%chartab(brent.crf, pre_arvs, &varlist);

%let varlist=cd_1 vl_1 cd_2 vl_2  cd_3 vl_3  cd_4 vl_4  cd_5 vl_5;
%stat(brent.crf, &varlist);

data stat1;
	set stat;
run;

%let varlist=FATIGUE FEV_CHIL FEEL_DIZ PAIN_TIN TRO_REM NAUS_VOM DIARRHEA SAD_DEPR NERV_ANX DIF_SLPN SKIN_PRB COUGH
HEADACHE LOSS_APE BLOATING MUSC_ACH PROB_SEX CHA_BODY PROB_WEI CHA_HAIR;
%stat(brent.crf, &varlist);

data stat2;
	set stat;
run;

%let varlist=CAU_ARVS HAR_ARVS ADD_COMM;
%chartab(brent.crf, last, &varlist);

data crf0;
	length item0 nfn nfy $40;
	set aids(in=A) nonaids(in=B) med(in=C) cur_arvs(in=D) pre_arvs(in=E)  
		stat1(in=F keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy))
		stat2(in=G keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy))
		last(in=H);
	if A then do; group=1; item0=put(item, aids.); end;
	if B then do; group=2; item0=put(item, aids.); end;
	if C then do; group=3; item0=put(item, med.); end;
	if D then do; group=4; item0=put(item, curarvs.); end;
	if E then do; group=5; item0=put(item, prearvs.); end;
	if F then do; group=6; item0=put(item, lab.); end;
	if G then do; group=7; item0=put(item, symptom.); end;
	if H then do; group=8; item0=put(item, last.); end;

	keep group item item0 nfy nfn code0 pv;	
run;

proc sort; by group item;run;

data crf;
	set crf0; by group item;
	if not first.item then item0=" ";
	format group gp.;
run;

ods rtf file="clinical.rtf" style=journal startpage=no bodytitle;

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
