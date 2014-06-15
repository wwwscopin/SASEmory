PROC IMPORT OUT= WORK.Inbone0 
            DATAFILE= "H:\SAS_Emory\Consulting\Tom\Inbone Outcomes statistical analysis.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents data=inbone0 short varnum; run;

data inbone;
	set inbone0;
	if name=" " then delete;
	diff_AOFAS=post_aofas-pre;
	diff_p=post_p-pre_P;
	diff_F=post_F-pre_f;

	keep Name Clinic_ Pre Post_AOFAS Pre_P Post_P Pre_F Post_F diff_aofas diff_p diff_f;
	rename clinic_=clinic pre=pre_AOFAS;
run;
proc means data=inbone;
var pre_aofas post_aofas pre_p post_p pre_f post_f;
run;

proc univariate data = inbone;
  var diff_aofas diff_p diff_f;
run;

data inbone2;
	set inbone(in=A) inbone(in=B);
	if A then idx=1; else idx=2;
	if A then AOFAS=pre_aofas;
	if B then AOFAS=post_aofas;
	if A then f=pre_f;
	if B then f=post_f;
	if A then p=pre_p;
	if B then p=post_p;
	keep idx aofas f p;
run;


proc npar1way data = inbone2;
  class idx;
  var aofas p f;
run;


PROC IMPORT OUT= WORK.bad0 
            DATAFILE= "H:\SAS_Emory\Consulting\Tom\Inbone Outcomes statistical analysis  mod severe coronal deformity.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents short varnum;run;

data bad;
	set bad0;
	if name=" " then delete;
	diff_AOFAS=post_aofas-pre;

	keep Name Clinic_ Pre Post_AOFAS  diff_aofas;
	rename clinic_=clinic pre=pre_AOFAS;
run;

proc means data=bad;
var pre_aofas post_aofas;
run;

proc univariate data = bad;
  var diff_aofas;
run;

data bad2;
	set bad(in=A) bad(in=B);
	if A then idx=1; else idx=2;
	if A then AOFAS=pre_aofas;
	if B then AOFAS=post_aofas;
	keep idx aofas;
run;


proc npar1way data = bad2;
  class idx;
  var aofas;
run;
