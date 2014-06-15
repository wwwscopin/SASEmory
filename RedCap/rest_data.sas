
options ls=120 orientation=portrait nobyline;
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\RFS RESISTANCE DATABASE.xls" lrecl=1000;

PROC IMPORT OUT= rest0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 1$A1:CM111"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data rd1;
	set rest0;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id;
run;


PROC IMPORT OUT= rest1 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 2$A2:CX112"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data rd2;
	set rest1;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id;
run;


proc compare data=rd2 compare=rd1 LISTCOMPVAR;run;


data brent.kidx;
	length genotype $50;
	set rd1(in=A) rd2(in=B); 
	if A then idx=1; 
	if B then idx=2;
		if k65='-77' then k65=" ";
		if K65="K" then kidx=0; else if K65="R" or K65="KR" or k65="N" then kidx=1; else kidx=.;
		if study_no="CAS 088R" then delete;
		if idx=1;
		*keep study_no k65 kidx;
run;

proc contents;run;


data brent.rest;
	length genotype $50;
	set rd1(in=A) rd2(in=B); 
	if A then idx=1; 
	if B then idx=2;
		if k65='-77' then k65=" ";
		if K65="K" then kidx=0; else if K65="R" or K65="KR" or k65="N" then kidx=1; else kidx=.;
		if study_no="CAS 088R" then delete;
		if idx=1;
		keep study_no k65 kidx Y115 L74 M184 T69 K70 V179 Y181 V106 Y188 G190 V108 A98 K103;
run;


data tmp;
	merge brent.rd (keep=study_no idx K65 kidx where=(idx=1) rename=(K65=K65A kidx=KidxA)) brent.rd (keep=study_no idx K65 kidx where=(idx=2) rename=(K65=K65B kidx=KidxB)); by study_no;
run;

proc print data=tmp;
	var study_no  K65A kidxA K65B kidxB;
run;

data brent.mut;
	length genotype $50;
	set rd1(in=A); 
	
	if study_no="CAS 088R" then delete;
	keep STUDY_no DATE_OF_ENROLLMENT NRTI_MUTATIONS NNRTI_MUTATIONS M41 _4 A62 K65 D67 T69 K70
L74 V75 F77 V90 A98 L100 K101 K103 V106 V108 G109 Y115 F116 _18 E138 Q151 V179 Y181 M184 Y188 G190
L210 T215 K219 H221 P225 F227 M230 _34 _36 _38 Y318 _33 N348 OTHER_RT_MUTATIONS PI_MAJOR_MUTATIONS
L10 V11 _3 G16 K20 _30 L24 D30 V32 L33 _5 M36 K43 M46 I47 G48 I50 F53 I54 Q58 D60 I62 L63 A71 G73
T74 L76 V77 V82 N83 I84 I85 N88 L89 L90 I93;
run;

data brent.mutation;
	merge brent.mut brent.tdf(in=A keep=study_no tdf d4t);by study_no;
	if A;
	
run;

proc print;run;
