PROC IMPORT OUT= TFCC0 
            DATAFILE= "H:\SAS_Emory\Consulting\Desai Mihir\TFCC.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A2:E8"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents data=TFCC0;run;
proc print;run;
*/
data TFCC;
	set TFCC0;
	Diff_Failure=AA-OI;
	Diff_Diastasis=AA1-OI1;
run;

proc means data=tfcc mean std median min max maxdec=1;
	var AA OI AA1 OI1;
run;

proc univariate data=tfcc;
	var diff_failure diff_diastasis;
run;
