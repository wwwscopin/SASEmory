PROC IMPORT OUT= temp1 
            DATAFILE= "H:\SAS_Emory\Consulting\Smith\Bradbury LLD updated.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Bradbury and Smith 1#6#12$Q1:X72"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


data brad;
	set temp1;
	pre_lld=Pre_op_LLD;
	if Goal_of_surgery_met="Yes" then goal=1;  else if Goal_of_surgery_met="No" then goal=0; 
	keep pre_lld goal;
run;


PROC IMPORT OUT= temp2 
            DATAFILE= "H:\SAS_Emory\Consulting\Smith\LLD Erens Modified.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$Q1:Y72"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data eren;
	set temp2;
	pre_lld=Preop_LLD;
	if Goal_of_surgery_met="Yes" then goal=1;  else if Goal_of_surgery_met="No" then goal=0; 
	keep pre_lld goal;
run;

data leg;
	set brad(in=A) eren(in=B);
	if A then group=0; 
	if B then group=1;
	if 0<=abs(pre_lld)<3 then sub=1;
	else if 3<=abs(pre_lld)<6 then sub=2;
	else if 6<=abs(pre_lld)<9 then sub=3;
	else if 9<=abs(pre_lld)<12 then sub=4;
	else if 12<=abs(pre_lld)<15 then sub=5;
	else if 15<=abs(pre_lld) then sub=6;
run;

proc freq;
	tables group*goal/chisq fisher;
	tables group*sub/chisq fisher;
run;

proc npar1way data=brad Wilcoxon;
	class goal;
	var pre_lld;
run;

proc npar1way data=eren Wilcoxon;
	class goal;
	var pre_lld;
run;

proc npar1way data=leg Wilcoxon;
	class goal;
	var pre_lld;
run;
