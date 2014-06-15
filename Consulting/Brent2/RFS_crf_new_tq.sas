
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


	if arvs='EFAVIRENZ' then do; dose_day=1; pill_dose=1;  end;
		if arvs='LAMIVUDINE' then do; dose_day=2; pill_dose=1;  end;
			if arvs='EMTRICITABINE' then do; dose_day=1; pill_dose=1;  end;
				if arvs="NEVIRAPINE" then do; dose_day=2; pill_dose=1; end;
	if arvs1='EFAVIRENZ' then do; dose_day1=1; pill_dose1=1;  end;
		if arvs1='LAMIVUDINE' then do; dose_day1=2; pill_dose1=1;  end;
			if arvs1='LOPINAVIR/RITONAVIR OR KALETRA' then do; dose_day1=1; pill_dose1=2;  end;
				if arvs1='NEVIRAPINE' then do; dose_day1=2; pill_dose1=1; end;
	if arvs2='LAMIVUDINE' then do; dose_day2=2; pill_dose2=1;  end;
		if arvs2='STAVUDINE' then do; dose_day2=2; pill_dose2=1;  end;
			if arvs2='TENOFOVIR' then do; dose_day2=1; pill_dose2=1;  end;
				if arvs2='TRUVADA' then do; dose_day2=1; pill_dose2=1;  end;

	if a then gp=0; 
	if b then gp=1;
	format _char_;
	informat _char_;


	if dispens0 in(-77,-88,-99) then dispens0=.;
		if dispens1 in(-77,-88,-99) then dispens1=.;
			if dispens2 in(-77,-88,-99) then dispens2=.;
				if dispens3 in(-77,-88,-99) then dispens3=.;
					if dispens4 in(-77,-88,-99) then dispens4=.;
						if dispens5 in(-77,-88,-99) then dispens5=.;
							if dispens6 in(-77,-88,-99) then dispens6=.;
								if dispens7 in(-77,-88,-99) then dispens7=.;

	*dday=date4-min(of date4-date11); /* Should we count the actual days or just use 180 days?*/
	/* If count the actual days, how? the end date will be the enrollment date or the latest refill date + the last dispens days?*/
	if date=date4 then do;
		dispens=sum(of dispens1-dispens7); /*Should we count the dispens days next to the enrollment date?*/
		mean_dispens=sum(of dispens1-dispens7)/180;/*What is the denifition for the "Total number of Pill Day Dispensed" from the email?*/
	end;
	else do;
		dispens=sum(of dispens0-dispens7); /*Should we count the dispens days next to the enrollment date?*/
		mean_dispens=sum(of dispens0-dispens7)/180;/*What is the denifition for the "Total number of Pill Day Dispensed" from the email?*/
	end;

	delay1=max(date4-date5-dispens1,0);
	delay2=max(date5-date6-dispens2,0);
	delay3=max(date6-date7-dispens3,0);
	delay4=max(date7-date8-dispens4,0);
	delay5=max(date8-date9-dispens5,0);
	delay6=max(date9-date10-dispens6,0);
	delay7=max(date10-date11-dispens7,0);

    delayday=sum(of delay1-delay7);

	pillday=date-min(of date4-date11);

	leftday=dispens-pillday; /*Which drug does this correspond?*/
	expected_pill=leftday*dose_day*pill_dose; /*Which drug does this correspond?*/

	if expected_pill>0 then do;
		*pill0=(1-(pil_coun-expected_pill))/dispens;
		pill=1-(pil_coun-expected_pill)/dispens;
	end;
	else do;
		*pill0=(1-(pil_coun-expected_pill))/(dispens-expected_pill);
		pill=1-(pil_coun-expected_pill)/(dispens-expected_pill);
	end;

	cd_1=cd4+0; vl_1=vl+0; 
	cd_2=cd41+0; vl_2=vl1+0; 
	cd_3=cd42+0; vl_3=vl2+0; 
	cd_4=cd43+0; vl_4=vl3+0; 
	cd_5=cd44+0; vl_5=vl4+0; 
	cd_6=cd45+0; vl_6=vl5+0; 

		format date1-date17 date9.;
run;

proc sort; by study_no gp;run;

ods rtf file="pill_count.rtf" style=journal bodytitle;
proc print data=brent.crf noobs label;
title "Pill Counts Outcome";
var study_no dispens mean_dispens pillday leftday delayday expected_pill pil_coun pill/style=[cellwidth=0.75in];
label gp="Group"
	  dispens="Total Dispens Days"
	  mean_dispens="Dispens Per Day"
	  pillday="Total Number Pill Days"
	  leftday="Total Number of Pill Days Remaning"
	  Expected_pill="Expected Pill Count"
	  delayday="Delay Days"
	  Pil_Coun="Actual Pill Count"
	  Pill="Pill Count (Outcome)"
	  ;
run;
ods rtf close;


data pill_count;
	set brent.crf;
	keep study_no dispens mean_dispens pillday leftday delayday expected_pill pil_coun pill;
run;

proc sort; by study_no; run;

proc univariate data=pill_count;
	var pill;
	histogram;
	output out=one pctlpts=80 95 pctlpre=pill;
run;

data _null_;
	set one;
	call symput("t1", put(pill80,7.4));
	call symput("t2", put(pill95,7.4));
run;

data brent.pill;
	set pill_count;
	if pill<&t1 then tq=1;
	else if &t1<=pill<&t2 then tq=2;
	 else if pill>=&t2 then tq=3; 
run;

data brent.crf;
	merge brent.crf brent.pill; by study_no;
run;

proc freq data=brent.crf;
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
		pv=put(pvalue, 7.4);
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
			format or pvalue 7.3;
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
		code0=put(code,4.0);
		keep code code0 item item0 n1-n3 f1-f3 nf1-nf3 rpct1-rpct3 or range pvalue pv;
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
		length code0 $150;
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

proc contents data=brent.crf;run;

%let varlist=diag_dis diag_dis1 diag_dis2;
%chartab(brent.crf, aidsA, &varlist);

%let varlist=num_epis cur_diag num_epis1 cur_diag1 num_epis2 cur_diag2;
%tab(brent.crf, aidsB, &varlist);

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
%chartab(brent.crf, nonaidsA, &varlist);

%let varlist=num_epis3 cur_diag3 num_epis4 cur_diag4 num_epis5 cur_diag5;
%tab(brent.crf, nonaidsB, &varlist);

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

%let varlist=CAU_ARVS HAR_ARVS ;
%tab(brent.crf, lastA, &varlist);

%let varlist=ADD_COMM;
%chartab(brent.crf, lastB, &varlist);

data last;
	set lastA lastB(in=B);
	if B then item=item+2;
run;

data crf0;
	length item0 nf1-nf3 $40;
	set aids(in=A) nonaids(in=B) med(in=C) cur_arvs(in=D) pre_arvs(in=E)  
		stat1(in=F keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3))
		stat2(in=G keep=item mean1 mean2 mean3 pv rename=(mean1=nf1 mean2=nf2 mean3=nf3))
		last(in=H);
	if A then do; group=1; item0=put(item, aids.); end;
	if B then do; group=2; item0=put(item, aids.); end;
	if C then do; group=3; item0=put(item, med.); end;
	if D then do; group=4; item0=put(item, curarvs.); end;
	if E then do; group=5; item0=put(item, prearvs.); end;
	if F then do; group=6; item0=put(item, lab.); end;
	if G then do; group=7; item0=put(item, symptom.); end;
	if H then do; group=8; item0=put(item, last.); end;

	keep group item item0 nf1-nf3 code0 pv;	
run;

proc sort; by group item;run;

data crf;
	set crf0; by group item;
	if not first.item then item0=" ";
	format group gp.;
run;

options ls=120 orientation=landscape;

ods rtf file="clinical.rtf" style=journal startpage=no bodytitle;

proc print data=crf split="*" noobs label style(data)=[just=center] style(header)=[just=center]; 
	title "Patient History of Clinical";
	by group;
	id item0;
	var code0/style(data)=[just=left cellwidth=1.75in] style(header)=[just=center];
	var nf1-nf3/style(data)=[just=right cellwidth=2in]  style(header)=[just=right]; 
	var pv/style(data)=[just=center cellwidth=0.6in]  style(header)=[just=center];
	format item clinical.;
	label 
		Item0="Characteristic"
		code0="."
		nf1="<80%(n=&ntq1)"
		nf2="80-95%(n=&ntq2)"
		nf3=">=95%(n=&ntq3)"
		pv="p value";
run;
ods rtf close;

