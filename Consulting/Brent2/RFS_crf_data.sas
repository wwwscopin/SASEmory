

libname brent "H:/SAS_Emory/Consulting/Brent2";		
options ls=120 orientation=portrait fmtsearch=(brent);
filename rfs "RFS AMMENDED CRF DATABASE.xls" lrecl=1000;

PROC IMPORT OUT= CRF_con0 
            DATAFILE= rfs  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A3:FT208"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;

	 DBDSOPTS="DBSASTYPE=('START11'='CHAR(11)' 'START12'='CHAR(11)' 'which'='char(11)' 'med8'='char(25)' 'DIAGDIS2'='char(11)' 'DIAGDIS5'='char(11)' 
			              'med9'='char(25)' 'med10'='char(25)' 'arvs6'='char(11)')"  ; 
RUN;

proc print data=crf_con0(obs=50);run;
proc contents;run;

data  crf_con;
	set crf_con0(rename=(date1=date_1 date2=date_2 date3=date_3 date8=date_8 date9=date_9 date10=date_10 date11=date_11   
						 date14=date_14 date15=date_15 date16=date_16 date17=date_17      dispens7=dispens_7 	
		ini_date=ini_date_ ini_date1=ini_date_1 ini_date3=ini_date_3 ini_date4=ini_date_4 
		rec_date=rec_date_ rec_date1=rec_date_1 rec_date3=rec_date_3 rec_date4=rec_date_4 ));

	date1 = input (compress(date_1,'-') , date9.); 
		date2 = input (compress(date_2,'-') , date9.); 	
			date3 = input (compress(date_3,'-') , date9.); 
				date8 = input (compress(date_8,'-') , date9.); 
					date9 = input (compress(date_9,'-') , date9.); 
						date10 = input (compress(date_10,'-') , date9.); 
							date11 = input (compress(date_11,'-') , date9.); 
								date14 = input (compress(date_14,'-') , date9.); 
									date15 = input (compress(date_15,'-') , date9.); 
										date16 = input (compress(date_16,'-') , date9.); 
											date17 = input (compress(date_17,'-') , date9.); 

	dispens7=dispens_7+0; 	


	ini_date= input (compress(ini_date_,'-') , date9.); 
		ini_date3= input (compress(ini_date_3,'-') , date9.); 
				ini_date4= input (compress(ini_date_4,'-') , date9.); 
						ini_date1= input (compress(ini_date_1,'-') , date9.); 
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
	start_14 = input (compress(start14,'-') , date9.); 
	start_15 = input (compress(start15,'-') , date9.); 
	start_16 = input (compress(start16,'-') , date9.); 
	start_17 = input (compress(start17,'-') , date9.); 
	start_18 = input (compress(start18,'-') , date9.); 
	start_19 = input (compress(start19,'-') , date9.); 
	start_20 = input (compress(start20,'-') , date9.); 
	start_21 = input (compress(start21,'-') , date9.); 

	start_22 = start22;
	start_23 = start23;
	start_24 = start24;

	start_25 = input (compress(start25,'-') , date9.); 
	start_26 = input (compress(start26,'-') , date9.); 
	start_27 = input (compress(start27,'-') , date9.); 
	start_28 = input (compress(start28,'-') , date9.); 
	start_29 = input (compress(start29,'-') , date9.); 
	


	stop_0 = input (compress(stop,'-') , date9.); 
	stop_1 = input (compress(stop1,'-') , date9.); 
	stop_2 = stop2;
	stop_3 = input (compress(stop3,'-') , date9.); 
	stop_4 = input (compress(stop4,'-') , date9.); 
	stop_5 = input (compress(stop5,'-') , date9.); 
	stop_6 = input (compress(stop6,'-') , date9.); 
	stop_7 = input (compress(stop7,'-') , date9.); 


	rename study_no_=study_no; 
	drop date_1-date_3 date_8-date_11 date_14-date_17 ini_date_ ini_date_1 ini_date_3 ini_date_4 rec_date_ rec_date_1 rec_date_3 rec_date4 
	start1-start22 stop stop1-stop7 dispens_7;

run;

PROC IMPORT OUT= CRF_case0 
            DATAFILE= rfs  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A3:FS113"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('START16'='CHAR(11)' 'START17'='CHAR(11)' 'START18'='CHAR(11)' 'arvs6'='char(11)' 'med11'='char(25)' 'med12'='char(25)' 
				'DIAGDIS2'='char(11)' 'DIAGDIS5'='char(11)' 'DIAGDIS6'='char(11)')" ; 
RUN;

proc print data=crf_case0(obs=50);run;
proc contents;run;

data  crf_case;
	set crf_case0(rename=(date1=date_1 date2=date_2 date3=date_3 date11=date_11 date15=date_15 date16=date_16 date17=date_17 
				vl=vl0 	NUM_EPIS3= NUM_EPIS3_ 	NUM_EPIS4=  NUM_EPIS4_	
		ini_date=ini_date_ ini_date1=ini_date_1 ini_date2=ini_date_2 ini_date3=ini_date_3 ini_date4=ini_date_4 ini_date5=ini_date_5 
		rec_date=rec_date_ rec_date1=rec_date_1 rec_date2=rec_date_2 rec_date3=rec_date_3 rec_date4=rec_date_4 rec_date5=rec_date_5));

	date1 = input (compress(date_1,'-') , date9.); 
		date2 = input (compress(date_2,'-') , date9.); 	
			date3 = input (compress(date_3,'-') , date9.); 
				date11 = input (compress(date_11,'-') , date9.); 
					date15 = input (compress(date_15,'-') , date9.); 
						date16 = input (compress(date_16,'-') , date9.); 
							date17 = input (compress(date_17,'-') , date9.); 

	
	ini_date= input (compress(ini_date_,'-') , date9.); 
		ini_date1= input (compress(ini_date_1,'-') , date9.); 
		ini_date2= input (compress(ini_date_2,'-') , date9.); 
				ini_date3= input (compress(ini_date_3,'-') , date9.); 
					ini_date4= input (compress(ini_date_4,'-') , date9.); 
						ini_date5= input (compress(ini_date_5,'-') , date9.); 

	rec_date= input (compress(rec_date_,'-') , date9.); 
		rec_date1= input (compress(rec_date_1,'-') , date9.); 
					rec_date2= input (compress(rec_date_2,'-') , date9.); 
					rec_date3= input (compress(rec_date_3,'-') , date9.); 
					rec_date4= input (compress(rec_date_4,'-') , date9.); 
					rec_date5= input (compress(rec_date_5,'-') , date9.); 

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
	start_22 = start22; 
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


	vl=compress(vl0);
	rename study_no_=study_no  __MONTH2=month2;
	drop date_1-date_3 date_11 date_15-date_17 ini_date_ ini_date_1-ini_date_5 rec_date_ rec_date_1-rec_date_5 
	start start1-start26  stop0-stop6;
run;		
	
proc contents data=crf_con;run;
proc contents data=crf_case;run;

proc compare base=crf_con compare=crf_case; 
   title 'Comparison of Variables in Different Data Sets';
run;

data  brent.crf;
	length study_no $8 site site1 site3 site4 $32    med med1-med18 $25  arvs arvs1-arvs5 $30  diagdis diagdis1-diagdis6 $30
			vl vl3-vl4 $12 add_comm $500 which $18;
	set crf_con(in=a rename=(dispens=dispens0)) crf_case(in=b rename=(dispens=dispens0));

	if a then gp=0; 
	if b then gp=1;
	format _char_;
	informat _char_;

	if a then do; 
		start_cur_arv1=start_13; 
		start_cur_arv2=start_14;
		start_cur_arv3=start_15; 
		start_pre_arv1=start_16;
		start_pre_arv2=start_17;
		start_pre_arv3=start_18;
		start_pre_arv4=start_19;
		start_pre_arv5=start_20;
		cv_date1=date_9;
		cv_date2=date_10;
		cv_date3=date_11;
		cv_date4=date_12;
		cv_date5=date_13;
		cv_date6=date_14;
	end; 

	else do; 
		start_cur_arv1=start_20; 
		start_cur_arv2=start_21;
		start_cur_arv3=start_22; 
		start_pre_arv1=start_23;
		start_pre_arv2=start_24;
		start_pre_arv3=start_25;
		start_pre_arv4=start_26;
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

	cd_1=cd4+0;  vl_1=vl+0; 
	cd_2=cd41+0; vl_2=vl1+0; 
	cd_3=cd42+0; vl_3=vl2+0; 
	cd_4=cd43+0; vl_4=vl3+0; 
	cd_5=cd44+0; vl_5=vl4+0; 
	cd_6=cd45+0; vl_6=vl5+0; 

	rename diagdis=diag_dis diagdis1=diag_dis1 diagdis2=diag_dis2 diagdis3=diag_dis3 diagdis4=diag_dis4 diagdis5=diag_dis5 diagdis6=diag_dis6;

		format date1-date17 date9.;
run;

proc sort; by study_no gp;run;



proc contents data=brent.crf;run;

proc print data=brent.crf;
var study_no cd4 cd41 cd42 cd43 cd44 cd45 vl vl1 vl2 vl3 vl4 vl5 ;  
run;

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
	*histogram;
	output out=one pctlpts=80 95 pct

lpre=pill;
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
