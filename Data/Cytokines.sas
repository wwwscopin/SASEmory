libname wbh "H:\SAS_Emory\Data";
filename cyto "H:\SAS_Emory\Data\glndlab\Cytokines\Copy of GLND Cytokine sum.xls";
filename cyto1 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 091510 sum.xls";
filename cyto2 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 092310 sum.xls";
filename cyto3 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 120210 sum.xls";
filename cyto4 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 051011 sum.xls";
filename cyto5 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 051811 sum.xls";
filename cyto6 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 060611 Sum.xls";
filename cyto7 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine 062111 Sum.xls";
filename cyto8 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine data 042412.xls";
filename cyto9 "H:\SAS_Emory\Data\glndlab\Cytokines\cytokine 050212 sum.xls";
filename cyto10 "H:\SAS_Emory\Data\glndlab\Cytokines\Cytokine update 060712.xls";


PROC IMPORT OUT= Cytokines1 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="072407$A5:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;

	DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 

RUN;

data Cytokines1;
	set Cytokines1(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;

	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='24Jul07'd;
	format date date9.;
	plate=1;
run;


PROC IMPORT OUT= Cytokines2 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="030508$A6:E44"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
     DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines2;
	set Cytokines2(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='05Mar08'd;
	format date date9.;
	plate=2;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines3 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="031208$A6:E44"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines3;
	set Cytokines3(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='12Mar08'd;
	format date date9.;
	plate=3;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines4 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="042610$A6:E44"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines4;
	set Cytokines4(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=input(substr(F1,1,1)||substr(F1,3,4),5.);
	day=substr(F1,10,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='26Apr10'd;
	format date date9.;
	plate=4;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines5 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="052810$A4:E42"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines5;
	set Cytokines5(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='28May10'd;
	format date date9.;
	plate=5;
run;
proc contents;run;
/*
PROC IMPORT OUT= Cytokines6 
            DATAFILE= cyto  
            DBMS=EXCEL REPLACE;
     RANGE="'061710$'"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data Cytokines6;
	set Cytokines6(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8 F4=IFN F5=TNF));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if _n_>=4 and id^=.;
	drop F1;
	date='17Jun10'd;
	format date date9.;
	plate=6;
run;
*/

PROC IMPORT OUT= Cytokines7 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="062510$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines7;
	set Cytokines7(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='25Jun10'd;
	format date date9.;
	plate=7;
run;

proc contents;run;

PROC IMPORT OUT= Cytokines8 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="071310$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines8;
	set Cytokines8(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='13Jul10'd;
	format date date9.;
	plate=8;
run;
proc contents;run;


PROC IMPORT OUT= Cytokines9 
            DATAFILE= cyto 
            DBMS=EXCEL REPLACE;
     RANGE="081110$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines9;
	set Cytokines9(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='11Aug10'd;
	format date date9.;
	plate=9;
run;
proc contents;run;


PROC IMPORT OUT= Cytokines10 
            DATAFILE= cyto1 
            DBMS=EXCEL REPLACE;
     RANGE="091510 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines10;
	set Cytokines10(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='15Sep10'd;
	format date date9.;
	plate=10;
run;
proc contents;run;


PROC IMPORT OUT= Cytokines11 
            DATAFILE= cyto2 
            DBMS=EXCEL REPLACE;
     RANGE="092310 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines11;
	set Cytokines11(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='23Sep10'd;
	format date date9.;
	plate=11;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines12 
            DATAFILE= cyto3 
            DBMS=EXCEL REPLACE;
     RANGE="120210 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;


data Cytokines12;
	set Cytokines12(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='12Dec10'd;
	format date date9.;
	plate=12;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines13 
            DATAFILE= cyto4 
            DBMS=EXCEL REPLACE;
     RANGE="051011 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines13;
	set Cytokines13(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='10May11'd;
	format date date9.;
	plate=13;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines14 
            DATAFILE= cyto5 
            DBMS=EXCEL REPLACE;
     RANGE="051811 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines14;
	set Cytokines14(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='18May11'd;
	format date date9.;
	plate=13;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines15 
            DATAFILE= cyto6 
            DBMS=EXCEL REPLACE;
     RANGE="060611 cytokine sum$A4:E43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines15;
	set Cytokines15(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='06Jun11'd;
	format date date9.;
	plate=15;
run;

proc contents;run;


PROC IMPORT OUT= Cytokines16 
            DATAFILE= cyto7 
            DBMS=EXCEL REPLACE;
     RANGE="062111 cytokine sum$a4:e43"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;


data Cytokines16;
	set Cytokines16(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if  id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='21Jun11'd;
	format date date9.;
	plate=15;
run;
proc contents;run;

PROC IMPORT OUT= Cytokines17 
            DATAFILE= cyto8 
            DBMS=EXCEL REPLACE;
     RANGE="042412 sum$A5:E44"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines17;
	set Cytokines17(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='12Apr12'd;
	format date date9.;
	plate=17;
run;

proc contents;run;

PROC IMPORT OUT= Cytokines18 
            DATAFILE= cyto9 
            DBMS=EXCEL REPLACE;
     RANGE="050212 sum$A5:E38"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines18;
	set Cytokines18(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='2May12'd;
	format date date9.;
	plate=18;
run;

proc contents;run;

PROC IMPORT OUT= Cytokines19 
            DATAFILE= cyto10 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A6:E29"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('F4'='CHAR(11)' 'F5'='CHAR(11)')"  ; 
RUN;

data Cytokines19;
	set Cytokines19(keep=F1 F2 F3 F4 F5 Rename=(F2=IL6 F3=IL8));
	id=substr(F1,1,5)+0;
	day=substr(F1,9,2)+0;
	if id^=.;
	IFN=F4+0;
	TNF=F5+0;
	drop F1;
	date='2May12'd;
	format date date9.;
	plate=18;
run;

data wbh.Cytokines_ex;
	set Cytokines1 Cytokines2 Cytokines3 Cytokines4 Cytokines5 Cytokines7 Cytokines8 Cytokines9 Cytokines10 
		Cytokines11 Cytokines12 Cytokines13 Cytokines14 Cytokines15 Cytokines16 Cytokines17 cytokines18 cytokines19;
run;

proc sort data=wbh.Cytokines_ex nodupkey;by id day date;run;

proc datasets lib=wbh memtype=data;
   modify Cytokines_ex; 
     attrib _all_ label=' '; 
run;

data wbh.cytokines_ex;
	set wbh.cytokines_ex;
	*drop il6c il8c IFNc tnfc;
	visit=day;
	if day not in(0 3 7 14 21 28) then
	if day>7 then visit=round(day/7)*7;
	else if day>=5 then visit=7;
	else visit=3;
	if IFN=. then IFN=0;
	if TNF=. then TNF=0;
	rename F4=IFNC F5=TNFC;
run;

proc contents;run;

proc print;run;
