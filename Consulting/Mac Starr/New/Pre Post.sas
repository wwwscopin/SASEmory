PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Mac Starr\New\hookplate data2.2013.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:AA48"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

data hookplate;
	set temp(keep=age TOI pre_VAS VAS_rest ASES_post ASES_pre rename=(pre_VAS=pre_VAS0 ASES_pre=ASES_pre0));
	pre_VAS=pre_VAS0+0;
	ASES_pre=ASES_pre0+0;
	row=_n_+1;
	if row in(2,4,6,8,10,12,32,34,38,46) then sub=1;
	if row in(14,16,18,20,22,24,26,28,30,36,40,42,44,48) then sub=2;
	if row in(30,34,42) then sub=3;
	if age=. then delete;
	vas=vas_rest-pre_vas;
	ases=ases_post-ases_pre;
run;

proc means data = hookplate n mean stderr min Q1 median Q3 max maxdec=1;
  var pre_vas vas_rest ases_pre ases_post;
run;
proc means data = hookplate n mean stderr min Q1 median Q3 max maxdec=1;
  class sub;
  var pre_vas vas_rest ases_pre ases_post;
run;

proc univariate data = hookplate;
  var vas ases;
run;
proc univariate data = hookplate;
  class sub;
  var vas ases;
run;
