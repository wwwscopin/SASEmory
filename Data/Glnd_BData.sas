PROC IMPORT OUT= B572
            DATAFILE= "H:\SAS_Emory\Data\B572_GMS_TZ(2).xls" 
            DBMS=EXCEL REPLACE;
     SHEET="Data Summary"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

Data BDataA;
	set B572;
	Date=mdy(04,11,10);
	sample= scan(Sample_Set__B572,1,' ');
	vd= scan(Sample_Set__B572,2,' ');
	time=compress(scan(Sample_Set__B572,3,' '),'hr');
	rename F2= CySS	F3=Cys F4=CySGSH F5=GSH F6=GSSG F7=GSSG_GSH	F8=CySS_Cys F9=Total_GSH F10=Total_Cys;
	if 5<_n_<34;
	if time='bsln' then time=0;
	if time='1/2' then time=0.5;
	t=time+0;
	if t=. then t=0;
	drop  Sample_Set__B572 time;
	format date date9.;
run;


PROC IMPORT OUT= B612
            DATAFILE= "H:\SAS_Emory\Data\B612(1).xls" 
            DBMS=EXCEL REPLACE;
     SHEET="Data Summary"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

Data BDataB;
	set B612;
	Date=mdy(09,22,10);
	sample= scan(Sample_Set__B612,1,' ');
	vd= scan(Sample_Set__B612,2,' ');
	time=compress(scan(Sample_Set__B612,3,' '),'hr');
	rename F2= CySS	F3=Cys F4=CySGSH F5=GSH F6=GSSG F7=GSSG_GSH	F8=CySS_Cys F9=Total_GSH F10=Total_Cys;
	if 5<_n_<59;
	if substr(vd,1,3)='vid' then vd='v1d'||substr(vd,4,1);
	if time='bsline' then time=0;
	t=time+0;
	drop  Sample_Set__B612 time;
	format date date9.;
run;

Data Bdata;
	set BdataA BDataB;
	if sample='MGS001' then sample='MGS-001';
	if substr(vd,1, 3)='v1d' then group=0;
	if substr(vd,1, 3)='v2d' then group=1;
run;

proc print;run;
