
options ls=120 orientation=portrait fmtsearch=(library);
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs "&path\CROI ABSTRACT-MEDICAL CRF.xls" lrecl=1000;

PROC IMPORT OUT= CRF_con0 
            DATAFILE= rfs  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A3:FB133"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;

	 DBDSOPTS="DBSASTYPE=('START11'='CHAR(11)' 'START12'='CHAR(11)' 'START13'='CHAR(11)' 'date9'='CHAR(11)' 'date10'='CHAR(11)')" ; 
RUN;

data  crf_con;
	set crf_con0(rename=(date1=date_1 date2=date_2 date3=date_3 date7=date_7 date8=date_8 date9=date_9 
				date10=date_10 date11=date_11 date14=date_14 date15=date_15 date16=date_16 date17=date_17
			dispens7=dispens_7 	cd45=cd45_
		ini_date=ini_date_ ini_date1=ini_date_1 ini_date2=ini_date_2 ini_date3=ini_date_3 ini_date4=ini_date_4 ini_date5=ini_date_5
		rec_date=rec_date_ rec_date1=rec_date_1 rec_date3=rec_date_3 rec_date4=rec_date_4));

	date1 = input (compress(date_1,'-') , date9.); 
		date2 = input (compress(date_2,'-') , date9.); 	
			date3 = input (compress(date_3,'-') , date9.); 
				date7 = input (compress(date_7,'-') , date9.); 
					date8 = input (compress(date_8,'-') , date9.); 
						date9 = input (compress(date_9,'-') , date9.); 
							date10 = input (compress(date_10,'-') , date9.); 
								date11 = input (compress(date_11,'-') , date9.); 
									date14 = input (compress(date_14,'-') , date9.); 
										date15 = input (compress(date_15,'-') , date9.); 
											date16 = input (compress(date_16,'-') , date9.); 
												date17 = input (compress(date_17,'-') , date9.); 
	dispens7=dispens_7+0; 	cd45=cd45_+0;
	ini_date= input (compress(ini_date_,'-') , date9.); 
		ini_date2= input (compress(ini_date_2,'-') , date9.); 
				ini_date3= input (compress(ini_date_3,'-') , date9.); 
					ini_date4= input (compress(ini_date_4,'-') , date9.); 
						ini_date5= input (compress(ini_date_5,'-') , date9.); 
	rec_date= input (compress(rec_date_,'-') , date9.); 
		rec_date1= input (compress(rec_date_1,'-') , date9.); 
				rec_date3= input (compress(rec_date_3,'-') , date9.); 
					rec_date4= input (compress(rec_date_4,'-') , date9.); 

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
	start_14 = start14; 
	start_15 = start15; 
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

	rename study_no_=study_no;
	drop date_1-date_3 date_7-date_11 date_14-date_17 ini_date_ ini_date_2-ini_date_5 rec_date_ rec_date_1 rec_date_3 rec_date_4
	start1-start22 stop stop1-stop7 cd45_ dispens_7;
run;		
	
PROC IMPORT OUT= CRF_case0 
            DATAFILE= rfs  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A3:FS88"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('START16'='CHAR(11)' 'START17'='CHAR(11)' 'START18'='CHAR(11)')" ; 
RUN;

data  crf_case;
	set crf_case0(rename=(date1=date_1 date2=date_2 date3=date_3 date7=date_7 date8=date_8 date9=date_9 
				date10=date_10 date11=date_11 date13=date_13 date14=date_14 date15=date_15 date16=date_16 date17=date_17
			 dispens6=dispens_6 dispens7=dispens_7 	cd43=cd43_    NUM_EPIS3=  NUM_EPIS3_ 	cd45=cd45_   NUM_EPIS4=  NUM_EPIS4_	
		ini_date=ini_date_ ini_date1=ini_date_1 ini_date2=ini_date_2 ini_date3=ini_date_3 ini_date4=ini_date_4 ini_date5=ini_date_5 ini_date6=ini_date_6
		rec_date=rec_date_ rec_date1=rec_date_1 rec_date2=rec_date_2 rec_date3=rec_date_3 rec_date4=rec_date_4 rec_date5=rec_date_5));

	date1 = input (compress(date_1,'-') , date9.); 
		date2 = input (compress(date_2,'-') , date9.); 	
			date3 = input (compress(date_3,'-') , date9.); 
				date7 = input (compress(date_7,'-') , date9.); 
					date8 = input (compress(date_8,'-') , date9.); 
						date9 = input (compress(date_9,'-') , date9.); 
							date10 = input (compress(date_10,'-') , date9.); 
								date11 = input (compress(date_11,'-') , date9.); 
									date13 = input (compress(date_13,'-') , date9.); 
									date14 = input (compress(date_14,'-') , date9.); 
										date15 = input (compress(date_15,'-') , date9.); 
											date16 = input (compress(date_16,'-') , date9.); 
												date17 = input (compress(date_17,'-') , date9.); 

	dispens6=dispens_6+0; 	dispens7=dispens_7+0;	  NUM_EPIS3=  NUM_EPIS3_+0; cd43=cd43_+0; cd45=cd45_+0;  NUM_EPIS4= NUM_EPIS4_+0;

	ini_date= input (compress(ini_date_,'-') , date9.); 
		ini_date1= input (compress(ini_date_1,'-') , date9.); 
		ini_date2= input (compress(ini_date_2,'-') , date9.); 
				ini_date3= input (compress(ini_date_3,'-') , date9.); 
					ini_date4= input (compress(ini_date_4,'-') , date9.); 
						ini_date5= input (compress(ini_date_5,'-') , date9.); 
							ini_date6= input (compress(ini_date_6,'-') , date9.); 
	rec_date= input (compress(rec_date_,'-') , date9.); 
		rec_date1= input (compress(rec_date_1,'-') , date9.); 
				rec_date2= input (compress(rec_date_2,'-') , date9.); 
					rec_date3= input (compress(rec_date_3,'-') , date9.); 
					rec_date5= input (compress(rec_date_5,'-') , date9.); 
					rec_date4= input (compress(rec_date_4,'-') , date9.); 

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
	start_20 = start20; 
	start_21 = start21; 
	start_22 = input (compress(start22,'-') , date9.); 
	start_23 = input (compress(start23,'-') , date9.); 
	start_24 = input (compress(start24,'-') , date9.); 
	start_25 = input (compress(start25,'-') , date9.); 
	start_26 = input (compress(start26,'-') , date9.); 


	stop_0 = input (compress(stop,'-') , date9.); 
	stop_1 = input (compress(stop1,'-') , date9.); 
	stop_2 = input (compress(stop2,'-') , date9.); 
	stop_3 = input (compress(stop3,'-') , date9.); 
	stop_4 = input (compress(stop4,'-') , date9.); 
	stop_5 = input (compress(stop5,'-') , date9.); 
	stop_6 = input (compress(stop6,'-') , date9.); 
	stop_7 = input (compress(stop7,'-') , date9.); 

	rename study_no_=study_no vl=vl0;
	drop date_1-date_3 date_7-date_11 date_13-date_17 ini_date_ ini_date_1-ini_date_6 rec_date_ rec_date_1-rec_date_5 
	start start1-start19 start22-start26 stop stop1-stop7 cd45_  cd43_ dispens_6 dispens_7;
run;		
	
proc contents data=crf_con;run;
proc contents data=crf_case;run;

proc compare base=crf_con compare=crf_case; 
   title 'Comparison of Variables in Different Data Sets';
run; 

data  brent.crf;
	length study_no $8 site site1-site5 $25  DIAG_DIS1-diag_dis5 $25  med med1-med15 $25  arvs arvs1-arvs6 $30 
			vl vl3-vl4 $12 other which $40 add_comm $500;
	set crf_con(in=a rename=(dispens=dispens0)) crf_case(in=b rename=(dispens=dispens0));

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

	if dispens0 in(-77,-88,-99) then dispens0=.;
		if dispens1 in(-77,-88,-99) then dispens1=.;
			if dispens2 in(-77,-88,-99) then dispens2=.;
				if dispens3 in(-77,-88,-99) then dispens3=.;
					if dispens4 in(-77,-88,-99) then dispens4=.;
						if dispens5 in(-77,-88,-99) then dispens5=.;
							if dispens6 in(-77,-88,-99) then dispens6=.;
								if dispens7 in(-77,-88,-99) then dispens7=.;

	dday=date5-min(of date5-date11);
	*dispens=sum(of dispens1-dispens7)/180;
	dispens=sum(of dispens1-dispens7)/dday;

	delay1=max(date4-date5-dispens1,0);
	delay2=max(date5-date6-dispens2,0);
	delay3=max(date6-date7-dispens3,0);
	delay4=max(date7-date8-dispens4,0);
	delay5=max(date8-date9-dispens5,0);
	delay6=max(date9-date10-dispens6,0);
	delay7=max(date10-date11-dispens7,0);


    delayday=sum(of delay1-delay7);
	pillday=date-date5;

	cd_1=cd4+0; vl_1=vl+0; 
	cd_2=cd41+0; vl_2=vl1+0; 
	cd_3=cd42+0; vl_3=vl2+0; 
	cd_4=cd43+0; vl_4=vl3+0; 
	cd_5=cd44+0; vl_5=vl4+0; 
	cd_6=cd45+0; vl_6=vl5+0; 

		format date1-date17 date9.;
run;

proc sort; by study_no;run;

proc print data=brent.crf;
where 0<dispens0<30 or 0<dispens1<30 or 0<dispens2<30 or 0<dispens3<30 or 0<dispens4<30 or 0<dispens5<30 or  0<dispens6<30 or  0<dispens7<30;
var study_no gp dispens0-dispens7;
run;

proc print data=brent.crf;
where delayday>100;
var study_no gp date4-date11 delay1-delay7 delayday;
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
