%let path=H:\SAS_Emory\Placebo_Muscadine;
%put &path;

PROC IMPORT OUT= B572
            DATAFILE= "&path\B572_GMS_TZ(2).xls" 
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
	visit=substr(vd,2,1)+0;
	day=substr(vd,4,1)+0;
	time=compress(scan(Sample_Set__B572,3,' '),'hr');
	CySS=F2+0; Cys=F3+0; CySGSH=F4+0; GSH=F5+0; GSSG=F6+0; GSSG_GSH=F7+0;	CySS_Cys=F8+0; Total_GSH=F9+0; Total_Cys=F10+0;
	if 5<_n_<34;
	if time='bsln' then time=0;
	if time='1/2' then time=0.5;
	t=time+0;
	if t=. then t=0;
	drop  Sample_Set__B572 time F2-F10 vd;
	format date date9.;
run;


PROC IMPORT OUT= B612
            DATAFILE= "&path\B612(1).xls" 
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
	if substr(vd,1,3)='vid' then vd='v1d'||substr(vd,4,1);
	visit=substr(vd,2,1)+0;
	day=substr(vd,4,1)+0;
	time=compress(scan(Sample_Set__B612,3,' '),'hr');
	CySS=F2+0;	Cys=F3+0; CySGSH=F4+0; GSH=F5+0; GSSG=F6+0; GSSG_GSH=F7+0; CySS_Cys=F8+0; Total_GSH=F9+0; Total_Cys=F10+0;
	if 5<_n_<59;
	if time='bsline' then time=0;
	t=time+0;
	drop  Sample_Set__B612 time F2-F10 vd;
	format date date9.;
run;

proc format;
	value group 1='Muscadine'
			 	0='Placebo'
		 ;
	value id  1='MGS-001'
			  3='MGS-003'
			  4='MGS-004'
		 ;
run;

Data Bdata;
	set BdataA BDataB;
	if sample='MGS001' then 
	do;
		sample='MGS-001';
		id=1;
		if visit=1 then group=1;
		if visit=2 then group=0;
	end;

	if sample='MGS-003' then 
	do;
		id=3;
		if visit=1 then group=0;
		if visit=2 then group=1;
	end;

	if sample='MGS-004' then 
	do;
		id=4;
		if visit=1 then group=1;
		if visit=2 then group=0;
	end;
	
	format group group. id id.;
run;

proc print;run;

data REP;
	set Bdata;
	where t=0;
run;

data AUC;
	set Bdata;
	if day in(2,3) or t=6 then delete;
	drop sample;
run;

proc print;run;

proc glm data=AUC;
class id group;
model CySS=id GROUP; lsmeans Group/pdiff;
run;

%MACRO AUC(dataset,output,var,id=1, group=0, day=1);

data _null_;
	set &dataset;
	where id=&id and group=&group and day=&day and t=0;
	call symput('base',put(&var,6.2));
run; 

DATA &output;
SET &dataset;
where id=&id and group=&group and day=&day and t>=0;
DROP Lag_t LagValue;
Lag_t = LAG(t);
LagValue = LAG(&var);
IF t = 0 THEN DO;
Lag_t = 0;
LagValue = 0;
END;
IF LagValue = 0.0 THEN DO;
* Connecting line with positive slope, only the area of right triangle (above baseline) is counted.;
DROP Ratio;
Ratio = &var/ (ABS(LagValue)+&var);
Trapezoid = Ratio*(t-Lag_t)*&var/2;
END;
/*
ELSE IF &var < 0 AND LagValue >= 0.0 THEN DO;
* Connecting line with negative slope, only the area of left triangle (above baseline) is counted.;
DROP Ratio;
Ratio = LagValue / (LagValue+ABS(&var));
Trapezoid = Ratio*(t-Lag_t)*LagValue/2;
END;
ELSE IF &var < 0 AND LagValue < 0 THEN Trapezoid = 0.0;
* Negative trapezoidal area is not counted.;
*/
ELSE Trapezoid = (t-Lag_t)*(&var+LagValue)/2;
* The rest of all positive trapezoidal areas are counted.;
SumTrapezoid + Trapezoid;
FORMAT Trapezoid SumTrapezoid 8.3;
RUN;
proc print;run;
%MEND AUC;

%AUC(AUC, out, CySS, id=1,group=0, day=1);
%AUC(AUC, out, CySS, id=1,group=0, day=4);
%AUC(AUC, out, CySS, id=1,group=1, day=1);
%AUC(AUC, out, CySS, id=1,group=1, day=4);

%AUC(AUC, out, Cys, id=1,group=0, day=1);
%AUC(AUC, out, Cys, id=1,group=0, day=4);
%AUC(AUC, out, Cys, id=1,group=1, day=1);
%AUC(AUC, out, Cys, id=1,group=1, day=4);

%AUC(AUC, out, GSH, id=1,group=0, day=1);
%AUC(AUC, out, GSH, id=1,group=0, day=4);
%AUC(AUC, out, GSH, id=1,group=1, day=1);
%AUC(AUC, out, GSH, id=1,group=1, day=4);

%AUC(AUC, out, GSSG, id=1,group=0, day=1);
%AUC(AUC, out, GSSG, id=1,group=0, day=4);
%AUC(AUC, out, GSSG, id=1,group=1, day=1);
%AUC(AUC, out, GSSG, id=1,group=1, day=4);

%AUC(AUC, out, GSSG_GSH, id=1,group=0, day=1);
%AUC(AUC, out, GSSG_GSH, id=1,group=0, day=4);
%AUC(AUC, out, GSSG_GSH, id=1,group=1, day=1);
%AUC(AUC, out, GSSG_GSH, id=1,group=1, day=4);

%AUC(AUC, out, CySS_Cys, id=1,group=0, day=1);
%AUC(AUC, out, CySS_Cys, id=1,group=0, day=4);
%AUC(AUC, out, CySS_Cys, id=1,group=1, day=1);
%AUC(AUC, out, CySS_Cys, id=1,group=1, day=4);

%AUC(AUC, out, Total_GSH, id=1,group=0, day=1);
%AUC(AUC, out, Total_GSH, id=1,group=0, day=4);
%AUC(AUC, out, Total_GSH, id=1,group=1, day=1);
%AUC(AUC, out, Total_GSH, id=1,group=1, day=4);

%AUC(AUC, out, Total_Cys, id=1,group=0, day=1);
%AUC(AUC, out, Total_Cys, id=1,group=0, day=4);
%AUC(AUC, out, Total_Cys, id=1,group=1, day=1);
%AUC(AUC, out, Total_Cys, id=1,group=1, day=4);


***********************************************************;
%AUC(AUC, out, CySS, id=3,group=0, day=1);
%AUC(AUC, out, CySS, id=3,group=0, day=4);
%AUC(AUC, out, CySS, id=3,group=1, day=1);
%AUC(AUC, out, CySS, id=3,group=1, day=4);

%AUC(AUC, out, Cys, id=3,group=0, day=1);
%AUC(AUC, out, Cys, id=3,group=0, day=4);
%AUC(AUC, out, Cys, id=3,group=1, day=1);
%AUC(AUC, out, Cys, id=3,group=1, day=4);

%AUC(AUC, out, GSH, id=3,group=0, day=1);
%AUC(AUC, out, GSH, id=3,group=0, day=4);
%AUC(AUC, out, GSH, id=3,group=1, day=1);
%AUC(AUC, out, GSH, id=3,group=1, day=4);

%AUC(AUC, out, GSSG, id=3,group=0, day=1);
%AUC(AUC, out, GSSG, id=3,group=0, day=4);
%AUC(AUC, out, GSSG, id=3,group=1, day=1);
%AUC(AUC, out, GSSG, id=3,group=1, day=4);

%AUC(AUC, out, GSSG_GSH, id=3,group=0, day=1);
%AUC(AUC, out, GSSG_GSH, id=3,group=0, day=4);
%AUC(AUC, out, GSSG_GSH, id=3,group=1, day=1);
%AUC(AUC, out, GSSG_GSH, id=3,group=1, day=4);

%AUC(AUC, out, CySS_Cys, id=3,group=0, day=1);
%AUC(AUC, out, CySS_Cys, id=3,group=0, day=4);
%AUC(AUC, out, CySS_Cys, id=3,group=1, day=1);
%AUC(AUC, out, CySS_Cys, id=3,group=1, day=4);

%AUC(AUC, out, Total_GSH, id=3,group=0, day=1);
%AUC(AUC, out, Total_GSH, id=3,group=0, day=4);
%AUC(AUC, out, Total_GSH, id=3,group=1, day=1);
%AUC(AUC, out, Total_GSH, id=3,group=1, day=4);

%AUC(AUC, out, Total_Cys, id=3,group=0, day=1);
%AUC(AUC, out, Total_Cys, id=3,group=0, day=4);
%AUC(AUC, out, Total_Cys, id=3,group=1, day=1);
%AUC(AUC, out, Total_Cys, id=3,group=1, day=4);

********************************************************************;

%AUC(AUC, out, CySS, id=4,group=0, day=1);
%AUC(AUC, out, CySS, id=4,group=0, day=4);
%AUC(AUC, out, CySS, id=4,group=1, day=1);
%AUC(AUC, out, CySS, id=4,group=1, day=4);

%AUC(AUC, out, Cys, id=4,group=0, day=1);
%AUC(AUC, out, Cys, id=4,group=0, day=4);
%AUC(AUC, out, Cys, id=4,group=1, day=1);
%AUC(AUC, out, Cys, id=4,group=1, day=4);

%AUC(AUC, out, GSH, id=4,group=0, day=1);
%AUC(AUC, out, GSH, id=4,group=0, day=4);
%AUC(AUC, out, GSH, id=4,group=1, day=1);
%AUC(AUC, out, GSH, id=4,group=1, day=4);

%AUC(AUC, out, GSSG, id=4,group=0, day=1);
%AUC(AUC, out, GSSG, id=4,group=0, day=4);
%AUC(AUC, out, GSSG, id=4,group=1, day=1);
%AUC(AUC, out, GSSG, id=4,group=1, day=4);

%AUC(AUC, out, GSSG_GSH, id=4,group=0, day=1);
%AUC(AUC, out, GSSG_GSH, id=4,group=0, day=4);
%AUC(AUC, out, GSSG_GSH, id=4,group=1, day=1);
%AUC(AUC, out, GSSG_GSH, id=4,group=1, day=4);

%AUC(AUC, out, CySS_Cys, id=4,group=0, day=1);
%AUC(AUC, out, CySS_Cys, id=4,group=0, day=4);
%AUC(AUC, out, CySS_Cys, id=4,group=1, day=1);
%AUC(AUC, out, CySS_Cys, id=4,group=1, day=4);

%AUC(AUC, out, Total_GSH, id=4,group=0, day=1);
%AUC(AUC, out, Total_GSH, id=4,group=0, day=4);
%AUC(AUC, out, Total_GSH, id=4,group=1, day=1);
%AUC(AUC, out, Total_GSH, id=4,group=1, day=4);

%AUC(AUC, out, Total_Cys, id=4,group=0, day=1);
%AUC(AUC, out, Total_Cys, id=4,group=0, day=4);
%AUC(AUC, out, Total_Cys, id=4,group=1, day=1);
%AUC(AUC, out, Total_Cys, id=4,group=1, day=4);
