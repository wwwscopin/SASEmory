
options ls=120 orientation=portrait;
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\CROI ABSTRACT- RESISTANCE DATA.xls" lrecl=1000;

PROC IMPORT OUT= rest0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 1$A1:CM83"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

data rd1;
	set rest0;
	retain tmp;
	if STUDY_NUM^=" " then tmp=STUDY_NUM;
	if STUDY_NUM=" " then STUDY_NUM=tmp;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id   RESULTS_=result;
	drop tmp;
run;

PROC IMPORT OUT= rest1 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 2$A1:CW84"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

data rd2;
	set rest1;
	retain tmp;
	if STUDY_NUM^=" " then tmp=STUDY_NUM;
	if STUDY_NUM=" " then STUDY_NUM=tmp;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id   RESULTS_=result;
	drop tmp;
run;

ods trace on/label listing;
proc freq; 
tables result GENOTYPING_RESULTS  NRTI_MUTATIONs  NNRTI_MUTATIONs  PI_MAJOR_MUTATIONS  RECENT_VL_at_McCord;
run;
ods trace off;

proc format; 
	value item
		1="Results"
		2="GENOTYPING_RESULTS"
		3="NRTI_MUTATIONs"
		4="NNRTI_MUTATIONs"
		5="PI_MAJOR_MUTATIONS"
		6="RECENT_VL_at_McCord"
		;
run;

%macro tab(data, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &var;
			ods output Freq.Table1.OneWayFreqs=tab&i;
		run;

	data tab&i;
		set tab&i;
		nf=frequency||"("||put(percent,4.1)||"%)";
		item=&i;
		keep item &var nf;
		rename &var=code;
	run;

	data &out;
		set &out tab&i; 
		item0=put(item, item.); 
		keep item  code nf;
		format item item.;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=result GENOTYPING_RESULTS  NRTI_MUTATIONs  NNRTI_MUTATIONs  PI_MAJOR_MUTATIONS  RECENT_VL_at_McCord;
%tab(rest, rest_tab, &varlist);

proc print data=tab2;run;

ods rtf file="rest.rtf" style=journal bodytitle;
proc print data=rest_tab noobs label;
title "Resistance Frequency Table";
by item;
id item/style=[just=left];
var code/style=[just=left];
var nf/style=[just=right];
label item="Item"
	 code="."
	 nf="Frequency(%)"
	 ;
run;
ods rtf close;
