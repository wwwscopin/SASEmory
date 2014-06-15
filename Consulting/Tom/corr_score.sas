
options ls=80 orientation=portrait;
%let path=H:\SAS_Emory\Consulting\Tom;
%let pm=%sysfunc(byte(177));  

libname tom "&path";
filename ankle "&path\Total Ankle All data excell spreadsheet for statistical analysis 11 29 11.xls" lrecl=1000;

%include "&path\macro.sas";

PROC IMPORT OUT= ankle0 
            DATAFILE= ankle  
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:S26"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data ankle;
	set ankle0;
	if name=" " then delete;
	rename Joint_Space_Height__mm_=Joint_space_height 		    Height_of_Talus__mm_=height_of_talus  clinic_=clinic post_aofas=pa
	Angle_A__lateral_tibial_componen=AngleA Angle_B__lateral_talar_component=AngleB Angle_C__AP_tibial_compent_angle=AngleC;

		if lowcase(Ankle_Deformity)='yes' then ad=1; else ad=0;
        if lowcase(Tibial_Bone_Loss)="yes"  then tibl=1; else tibl=0;
		if lowcase(Talar_Bone_Loss)="yes" then tabl=1; else tabl=0;
		if lowcase(Talus_Collapse_AVN)="yes" then tca=1; else tca=0;
		if lowcase(Talar_Subluxation_Anterior)="yes" then tsa=1; else tsa=0;
		if lowcase(Talar_Subluxation_Medial)="yes" then tsm=1; else tsm=0;
		if lowcase(Talar_Subluxation_Lateral)="yes"  then tsl=1; else tsl=0;

run;

proc contents data=ankle /*short varnum*/;run;
proc contents data=ankle short varnum;run;
proc print data=ankle;run;

proc format; 

value item 
	1="Ankle Deformity"
	2="Tibial Bone Loss"
	3="Talar Bone Loss"
	4="Talus Collapse AVN"
	5="Talar Subluxation Anterior"
	6="Talar Subluxation Medial"
	7="Talar Subluxation Lateral"
	8="Joint space height" 
	9="Height of talus"
	10="Angle A lateral tibial component"
	11="Angle B lateral talar component" 
	12="Angle C AP tibial compent angle" 
	13="BMI"
	14="Age"
;

run;


%macro test(data,gp)/minoperator;

%let x= 1;

%do %while (&x <15);
    %if &x = 1  %then %do; %let var =ad;     %end;
    %if &x = 2  %then %do; %let var =Tibl;   %end;
	%if &x = 3  %then %do; %let var =Tabl;	 %end;
	%if &x = 4  %then %do; %let var =Tca; 	 %end;
	%if &x = 5  %then %do; %let var =Tsa; 	 %end;
	%if &x = 6  %then %do; %let var =Tsm; 	 %end;
	%if &x = 7  %then %do; %let var =Tsl ;	 %end;
	%if &x = 8  %then %do; %let var =Joint_space_height;   	%end;
	%if &x = 9  %then %do; %let var =height_of_talus;  		%end; 	
    %if &x = 10 %then %do; %let var =AngleA; %end;
	%if &x = 11 %then %do; %let var =AngleB; %end;
	%if &x = 12 %then %do; %let var =AngleC; %end;
	%if &x = 13 %then %do; %let var =bmi;  	 %end;
	%if &x = 14 %then %do; %let var =age;  	 %end;

%if %eval(&x in 1 2 3 4 5 6 7) %then %do;
	%stat(&data, &gp, stat, &var, &x);
%end;

%if %eval(&x in 8 9 10 11 12 13 14) %then %do;
	proc corr data=&data spearman;
		var &var pa;
		ods output spearmanCorr=pc;
	run;

	data pc&x;
		length pv $10;
		set pc;
		if _n_=1;
		pv=put(ppa, 7.4);
		if ppa<0.0001 then pv='<0.0001';

		item=&x;
		keep pa ppa pv item;
	run; 
%end;

%let x = %eval(&x + 1);
%end;

data stat;
	set stat1 stat2 stat3 stat4 stat5 stat6 stat7 pc8 pc9 pc10 pc11 pc12 pc13 pc14; by item;
	keep item mean0 mean1 pa ppa pv pvalue;
	rename mean0=nfn mean1=nfy;
run;

proc sort; by item;run;

%mend test;

%test(ankle, pa);run;

ods rtf file="corr.rtf" style=journal bodytitle;
title "Post AOFAS";

proc report data=stat nowindows headline spacing=1 split='*' style(column)=[just=center];
column item nfn nfy pa pv;
define item/order=internal format=item. "Variable" style=[just=left cellwidth=2in];
define nfn/"No*Mean &pm SEM[Q1~Q3]" style=[cellwidth=2in];
define nfy/"Yes*Mean &pm SEM[Q1~Q3]" style=[cellwidth=2in];
define pa/format=7.4 "Spearman  Correlation" style=[cellwidth=0.75in];
define pv/"p value" style=[cellwidth=0.75in];
run;

ods rtf close;

