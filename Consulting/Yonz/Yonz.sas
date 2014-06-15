options orientation=landscape SPOOL;
%include "macro.sas";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Yonz\Reformatted GSW datasheet.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Data sheet$A2:L490"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents short varnum; run;
proc print;run;
*/


proc format; 
 value yn 1="Yes" 0="No" 9="unknown/ incomplete chart records for data";
 value fracture 
 		1="Femur proximal 1/3"
		2="Femur mid 1/3"
		3="Femur distal 1/3"
		4="Patella"
		5="Intra-articular, no fx"
		6="Tibia prox 1/3"
		7="Tibia mid, distal 1/3"
		8="Fibula prox 1/3"
		9="Fibula mid,distal 1/3"
		10="Foot"
		0="- Any Type -"
		;
value idx 
	1="Coagulation (DVT/PE)"
	2="Compartment syndrome"
	3="Vascular injury"
	4="Infection"
	5="Hardware complications (breakage, promenince, backed-out screws, ect)"
	6="Non-union/Malunion"
	7="Other"
	;
run;

data gsw;
	set temp(rename=(other=other0));

	if Coagulation__DVT_PE_="Y" then coag=1;  else if Coagulation__DVT_PE_="N" then  coag=0; else coag=9;
	if Compartment_syndrome="Y" then compartment=1; else if Compartment_syndrome="N" then compartment=0; else compartment=9;
	if Hardware_complications__breakage="Y" then hardware=1; else if Hardware_complications__breakage="N" then hardware=0; else hardware=9;
	if Vascular_injury="Y" then vascular=1; else if Vascular_injury="N" then vascular=0; else vascular=9;
	if infection="Y" then infect=1; else if infection="N" then infect=0;  else  infect=9;
	if Non_union_Malunion="Y" then malunion=1; else if Non_union_Malunion="N" then malunion=0; else malunion=9;
	if other0="Y" then other=1; else if other0="N" then other=0; else other=9;

	drop F4 F5;
	rename Study_Year=year Fracture_classification=fracture ;

	keep Study_Year mrn Fracture_classification coag compartment hardware vascular infect malunion other;
	format coag compartment hardware vascular infect malunion other yn. Fracture_classification fracture.;
run;


proc freq data=gsw; 
	table vascular*compartment/chisq fisher;
run;
data _null_;
	set gsw;
	call symput("k", compress(_n_));
run;

%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab1, fracture, coag); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab2, fracture, compartment); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab3, fracture, vascular); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab4, fracture, infect); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab5, fracture, hardware); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab6, fracture, malunion); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab7, fracture, other); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;


data tab;
	set tab1(in=t1) tab2(in=t2) tab3(in=t3) tab4(in=t4) tab5(in=t5) tab6(in=t6) tab7(in=t7);
	if t1 then idx=1; 
	if t2 then idx=2; 
	if t3 then idx=3; 
	if t4 then idx=4; 
	if t5 then idx=5; 
	if t6 then idx=6; 
	if t7 then idx=7; 
	format idx idx.;
run;



ods rtf file="gsw_tab.rtf" style=journal bodytitle;
proc report data=tab nowindows split="*" style(column) = [just=center];
title "Table: Incidence of Complication by Fracture (n=&k)";
column idx fracture c1-c2 c pv rf;
define idx/ format=idx. "Complication" group order=internal style=[cellwidth=2in just=left];
define fracture/ format=fracture. "Fracture Type" order=internal style=[cellwidth=2in just=left];
define c1/"No" style(column)=[cellwidth=1.1in just=center]; 
define c2/"Yes" style(column)=[cellwidth=1.1in just=center]; 
define c/"Total" style(column)=[cellwidth=1.1in just=center]; 
define pv/"p value" style(column)=[cellwidth=1in just=center]; 
define rf/"Risk Factor" format=4.2 style(column)=[cellwidth=1in just=center]; 
run;
ods rtf close;
