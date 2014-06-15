PROC IMPORT OUT= WORK.Temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Desai Mihir\Project2\Cobb Angles.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc format;
	value group 1="A" 2="B";
	value idx 1="0~25" 2="25~40" 3=">40";
run;
data cobb;
	set temp(keep=A rename=(A=angle))
		temp(keep=B rename=(B=angle) in=B);
	if 0<angle<25 then idx=1;
	else if angle<=40 then idx=2;
	else if angle>40 then idx=3;
	if B then group=2; else group=1;
	format group group. idx idx.; 
run;
proc sort;by idx group;run;

proc  means data=cobb n mean min std Q1 median Q3 max maxdec=1;
	by idx;
	class group;
	var angle;
run;

proc npar1way data=cobb wilcoxon;
	by idx;
	class group;
	var angle;
run;
