PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Michael Smith\Project2 Power\Quadrigia Study.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data quad0;
	set temp;
	if F1=. then delete;
	rename F6=arm_5 F7=arm_6;
run;
data quad;
	set quad0;
	if _n_<=10 then advan=0;
		else if _n_<=20 then advan=1;
		else if _n_<=30 then advan=2;
		else if _n_<=40 then advan=3;
run;

proc means data=quad n mean stderr min Q1 median Q3 max maxdec=1 ;
	class advan;
	var arm_1 arm_2 arm_3 arm_4 arm_5 arm_6;
run;

proc npar1way data=quad wilcoxon;
	class advan;
	var arm_1 arm_2 arm_3 arm_4 arm_5 arm_6;
run;


proc npar1way data=quad(where=(advan in(3,2))) wilcoxon;
	class advan;
	var arm_1 arm_2 arm_3 arm_4 arm_5 arm_6;
run;


data quad1;
	set quad(keep=F1 arm_1 advan rename=(arm_1=arm) in=A)
		quad(keep=F1 arm_2 advan rename=(arm_2=arm) in=B)
		quad(keep=F1 arm_3 advan rename=(arm_3=arm) in=C)
		quad(keep=F1 arm_4 advan rename=(arm_4=arm) in=D)
		quad(keep=F1 arm_5 advan rename=(arm_5=arm) in=E)
		quad(keep=F1 arm_6 advan rename=(arm_6=arm) in=F)
	;
	if A then id=1;
	if B then id=2;
	if C then id=3;
	if D then id=4;
	if E then id=5;
	if F then id=6;
run;

proc means data=quad1 n mean stderr min Q1 median Q3 max maxdec=1;
	class advan;
	var arm;
run;
proc npar1way data=quad1 wilcoxon;
	class advan;
	var arm;
run;
proc npar1way data=quad1(where=(advan in(3,2))) wilcoxon;
	class advan;
	var arm;
run;

/* One Way ANOVA */
proc glm data=quad1;
	class advan;
	model arm=advan/solution;
	means advan;
run;

proc mixed data=quad1;
	class id advan;
	model arm=advan/solution;
	repeated /type=cs sub=id;
run;
