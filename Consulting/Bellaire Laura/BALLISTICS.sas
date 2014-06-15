options orientation=landscape SPOOL;
%include "macro.sas";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Bellaire Laura\BALLISTICS DATA_Stats Round 3.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Data sheet$A1:M490"; 
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
 value yn 1="Yes" 0="No" 9="Unknown/ incomplete chart records for data";
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
	2="Prophylactic Fasciotomy"
	3="Compartment syndrome"
	4="Vascular injury"
	5="Infection"
	6="Hardware complications (breakage, promenince, backed-out screws, ect)"
	7="Non-union/Malunion"
	8="Other"
	;
run;

proc freq data=temp; 
	table Prophylactic_Fasciotomy;
run;

data gsw;
	set temp(rename=(other=other0));
	
	if _n_=1 then delete;
	if Coagulation__DVT_PE_="Y" then coag=1;  else if Coagulation__DVT_PE_="N" then  coag=0; else coag=9;
	if Prophylactic_Fasciotomy ="Y" then pf=1; else if Prophylactic_Fasciotomy ="N" then pf=0; else pf=9;
	if Compartment_syndrome="Y" then compartment=1; else if Compartment_syndrome="N" then compartment=0; else compartment=9;

	if Hardware_complications__breakage="Y" then hardware=1; else if Hardware_complications__breakage="N" then hardware=0; else hardware=9;
	if Vascular_injury="Y" then vascular=1; else if Vascular_injury="N" then vascular=0; else vascular=9;
	if infection="Y" then infect=1; else if infection="N" then infect=0;  else  infect=9;
	if Non_union_Malunion="Y" then malunion=1; else if Non_union_Malunion="N" then malunion=0; else malunion=9;
	if other0="Y" then other=1; else if other0="N" then other=0; else other=9;

	drop F4 F5;
	rename Study_Year=year Fracture_classification__see_Def=fracture ;

	keep Study_Year mrn Fracture_classification__see_Def coag pf compartment hardware vascular infect malunion other;
	format coag compartment hardware vascular infect malunion other yn. Fracture_classification__see_Def fracture.;
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
%table(gsw, tab2, fracture, pf); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab3, fracture, compartment); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab4, fracture, vascular); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab5, fracture, infect); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab6, fracture, hardware); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab7, fracture, malunion); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;
%table(gsw, tab8, fracture, other); quit;
%let n1=0; %let n2=0; %let n3=0; %let n=0;


data tab;
	set tab1(in=t1) tab2(in=t2) tab3(in=t3) tab4(in=t4) tab5(in=t5) tab6(in=t6) tab7(in=t7) tab8(in=t8);
	if t1 then idx=1; 
	if t2 then idx=2; 
	if t3 then idx=3; 
	if t4 then idx=4; 
	if t5 then idx=5; 
	if t6 then idx=6; 
	if t7 then idx=7; 
	if t8 then idx=8; 
	format idx idx.;
run;

ods rtf file="laura_tab.rtf" style=journal bodytitle;
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

data gsw_new;
	set gsw;
	if vascular=9 then vascular=.;
    if compartment=9 then compartment=.;
    if infect=9 then infect=.;
run;

proc freq data=gsw_new;
tables vascular*compartment/nocol nopercent chisq fisher;
tables compartment*infect/nocol nopercent chisq fisher;
tables vascular*infect/nocol nopercent chisq fisher;
run;

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Bellaire Laura\Infection Round2.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:F42"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


%macro como(data, out, varlist,n);
data &out;
	if 1=1 then delete;
run;

%do j=1 %to &n;
	data _null_;
		set &data;
		if _n_=&j;
		call symput("char",&varlist);
	run;

	data temp;
		set &data;
		if _n_=&j;
	
		%let i = 1;
		%let cm=%scan(%bquote(&char), &i);
		%do %while(&cm NE );
			*value type 1="IM Nail"	2="ExFix Pins"	3="Plate"	4="Screws"	5="Bone Graft"	N="none";
			if &cm=1  then nail=1;    
			if &cm=2  then pin=1;    
			if &cm=3  then plate=1;  
			if &cm=4  then screw=1;  
			if &cm=5  then graft=1; 
			if &cm=other  then other=1;    
			if &cm=N  then None=1;  
			
   			%let i= %eval(&i+1);
   			%let cm= %scan(%bquote(&char),&i);
		%end;
	run;

	data &out;
		set &out temp;
		drop N;
	run;
%end;
%mend como;
%como(tmp, tab0, Type_Implant,41);


data infect;
	set tab0;
	/*
	if nail=. then nail=0;
	if pin=. then pin=0;
	if plate=. then plate=0;
	if screw=. then screw=0;
	if graft=. then graft=0;
	if other=. then other=0;
	if none=. then none=0;
	*/
	rename Days_from_Injury_to_Dx_of_Infect=day_Injury_Infect
		Days_from_Implant_to_Dx_of_Infec=Day_implant_infect
		Days_from_ExFix_to_Dx_of_Infecti=day_ExFix_Infect;
run;


data infect1;
	set infect(keep=Day_implant_infect rename=(Day_implant_infect=day) in=A) 
	infect(keep=Day_ExFix_infect rename=(Day_ExFix_infect=day) in=B);
	if A then group=1; else group=2;
run;

proc means data=infect1 n mean std median Q1 Q3 maxdec=1;
	class group;
	var day;
run;
proc npar1way data=infect1 wilcoxon;
	class group;
	var day;
run;

data infect2;
	set infect(where=(nail=1) rename=(Day_implant_infect=day) in=A) 
	infect(where=(pin=1) rename=(Day_ExFix_infect=day) in=B) 
	infect(where=(plate=1) rename=(Day_implant_infect=day) in=C) 
	infect(where=(screw=1) rename=(Day_implant_infect=day) in=D) 
	infect(where=(graft=1) rename=(Day_implant_infect=day) in=E);
	if A then idx=1;
	if B then idx=2;
	if C then idx=3;
	if D then idx=4;
	if E then idx=5;
run;

proc means data=infect2 n mean std median Q1 Q3 maxdec=1;
	class idx;
	var day;
run;

proc npar1way data=infect2 wilcoxon;
	class idx;
	var day;
run;


proc means data=infect n mean std median Q1 Q3 maxdec=1;
	var day_Injury_Infect;
run;
