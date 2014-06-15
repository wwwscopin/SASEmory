options orientation=landscape nonumber nodate ;
libname pain "H:\SAS_Emory\Consulting\Jessica";
%include "stat_macro.sas";
%let pm=%sysfunc(byte(177));  


PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Jessica\ACL Pain.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

data pain0;
	set temp;

	sp_sx=compress(s_p_SX, "weeks")+0;

	rename ACL_Type__1_Quad__2_Ham__3_BPtB_=acl Gender__1_M__2_F_=gender  KT_1000=kt
		day_2=day2 day_3=day3 day_4=day4 day_7=day7 day_14=day14 day_21=day21 day_28=day28;
	id=_n_;
	 
	if id in(45,54) then delete;
	keep id ACL_Type__1_Quad__2_Ham__3_BPtB_ Gender__1_M__2_F_ day_2 day_3 day_4 day_7 day_14 day_21 day_28 
		age gender f_tunnel t_tunnel med slr sp_sx kt_1000;
run;

proc means data=pain0 Q1 median Q3; 
var age f_tunnel t_tunnel;
output out=wbh Q1(age)=Q1_age median(age)=median_age Q3(age)=Q3_age Q1(f_tunnel)=Q1_f median(f_tunnel)=median_f Q3(f_tunnel)=Q3_f
	Q1(t_tunnel)=Q1_t median(t_tunnel)=median_t Q3(t_tunnel)=Q3_t;
run;
data _null_;
	set wbh;
	call symput("q1", compress(q1_age));
	call symput("q2", compress(median_age));
	call symput("q3", compress(q3_age));
	call symput("q1f", compress(q1_f));
	call symput("q2f", compress(median_f));
	call symput("q3f", compress(q3_f));
	call symput("q1t", compress(q1_t));
	call symput("q2t", compress(median_t));
	call symput("q3t", compress(q3_t));
run;

proc format; 
	value gender 1="M" 2="F";
	value acl 1="Quad" 2="Ham" 3="BPtB" 4="Allo";
	value gage 1="Age<&q1" 2="Age between &q1~&q2" 3="Age between &q2~&q3" 4="Age>=&q3";
	value gf 1="F Tunnel<&q1f" 2="F Tunnel in &q1f~&q2f" 3="F Tunnel in &q2f~&q3f" 4="F Tunnel>=&q3f";
	value gt 1="T Tunnel<&q1t" 2="T Tunnel in &q1t~&q2t" 3="T Tunnel in &q2t~&q3t" 4="T Tunnel>=&q3t";
	value idx 1="ACL" 2="Age" 3="F-Tunnel" 4="T-Tunnel";
	value item 1="Med" 2="SLR" 3="KT-1000" 4="s/p SX";
run;


data pain;
	set pain0;
	if age<=&q1 then gage=1;  else if &q1<age<=&q2 then gage=2; else if &q2<age<=&q3 then gage=3; else if &q3<age then gage=4;
	if f_tunnel<=&q1f then gf=1;  else if &q1f<f_tunnel<=&q2f then gf=2; else if &q2f<f_tunnel<=&q3f then gf=3; else if &q3f<f_tunnel then gf=4;
	if t_tunnel<=&q1t then gt=1;  else if &q1t<t_tunnel<=&q2t then gt=2; else if &q2t<t_tunnel<=&q3t then gt=3; else if &q3t<t_tunnel then gt=4;

	format gender gender. gage gage. acl acl. gf gf. gt gt.;
run;

PROC GCHART DATA=pain;
      VBAR day2;
RUN; 

proc sgplot data=pain;
  vbox day2 / category=acl;
run;

/*
%let varlist=day2 day3 day4;
%stat(pain, acl, &varlist);
%stat(pain, gender, &varlist);
%stat(pain, gage, &varlist);
%stat(pain, gf, &varlist);
%stat(pain, gt, &varlist);
*/

%let varlist=med slr kt sp_sx;
%stat(pain, acl, &varlist);

data stat;
	set stat;
	format item item.;
run;



data pain_new;
	set pain(keep=id day2 rename=(day2=pain) in=A)
	pain(keep=id day3 rename=(day3=pain) in=B)
	pain(keep=id day4 rename=(day4=pain) in=C)
	pain(keep=id day7 rename=(day7=pain) in=D)
	pain(keep=id day14 rename=(day14=pain) in=E)
	pain(keep=id day21 rename=(day21=pain) in=F)
	pain(keep=id day28 rename=(day28=pain) in=G);
	if A then day=2;
	if B then day=3; 
	if C then day=4;
	if D then day=7; 
	if E then day=14;
	if F then day=21;
	if G then day=28;
	if pain in (1,2,3) then pl=1; else if pain in (4,5,6) then pl=2; else if pain>6 then pl=3;
run;


proc sort; by id day;run;

data pain_new;
	merge pain_new pain(keep=id acl age gage f_tunnel gf t_tunnel gt gender med slr sp_sx kt ); by id;
run;

proc sort data=pain_new out=pl; by day; run;

proc npar1way data=pl(where=(acl in(3,4))) wilcoxon; 
	class acl;
	var med slr;
run;

proc freq data=pl(where=(acl in(3,4))); 
	by day;
	tables pain*acl/chisq fisher;
run;



proc greplay igout=pain.graphs  nofs; delete _ALL_; run;
goptions rotate = landscape;


%mixedpain(pain_new,pain,acl);
%mixedpain(pain_new,pain,gage);
%mixedpain(pain_new,pain,gf);
%mixedpain(pain_new,pain,gt);
%mixed(pain_new,pain);

ods pdf file = "graph_all.pdf" style=journal;
goptions reset=all border;
/*
proc greplay igout = pain.graphs tc=sashelp.templt nofs nobyline;
	template l2r2s;
	treplay 1:1 2:2 3:3 4:4;
run;
*/
options orientation=portrait;

proc greplay igout = pain.graphs tc=sashelp.templt nofs nobyline;
	template v2s;
	treplay 1:1 2:2;
	treplay 1:3 2:4;
	treplay 1:5 ;
run;
ods pdf close;

ods rtf file="estimate_all.rtf" style=journal bodytitle  startpage=never;
proc report data=estimate_acl nowindows style(column)=[just=center] split="*";
title "Estimate by ACL  and Day ";
column day col1-col4;
define day/"Day"  style(column)=[width=1in];
define col1/"Quad";
define col2/"Ham";
define col3/"BPTB";
define col4/"Allo";
run;

proc report data=estimate_gage nowindows style(column)=[just=center] split="*";
title "Estimate by Age and Day ";
column day col1-col4;
define day/"Day"  style(column)=[width=1in];
define col1/"Age<=&q1";
define col2/"Age in &q1~&q2";
define col3/"Age in &q2~&q3";
define col4/"Age>&q3";
run;

proc report data=estimate_gf nowindows style(column)=[just=center] split="*";
title "Estimate by F Tunnel  and Day ";
column day col1-col4;
define day/"Day"  style(column)=[width=1in];
define col1/"F Tunnel <=&q1f";
define col2/"F Tunnel in &q1f~&q2f";
define col3/"F Tunnel in &q2f~&q3f";
define col4/"F Tunnel>&q3f";
run;

proc report data=estimate_gt nowindows style(column)=[just=center] split="*";
title "Estimate by ACL  and Day ";
column day col1-col4;
define day/"Day"  style(column)=[width=1in];
define col1/"T Tunnel <=&q1t";
define col2/"T Tunnel in &q1t~&q2t";
define col3/"T Tunnel in &q2t~&q3t";
define col4/"T Tunnel>&q3t";
run;

proc report data=estimate_pain nowindows style(column)=[just=center] split="*";
title "Estimate by Gender  and Day ";
column day col1-col2;
define day/"Day"  style(column)=[width=1in];
define col1/"Male";
define col2/"Female";
run;

proc report data=stat nowindows style(column)=[just=center] split="*";
title "Comparison between ACL Type";
column item mean1-mean4 pv;
define item/"Variable" format=item.  style(column)=[width=1in];
define mean1/"Quad*Mean &pm Std, Median, n" style(column)=[width=1.5in];
define mean2/"Ham*Mean &pm Std, Median, n" style(column)=[width=1.5in];
define mean3/"BPTB*Mean &pm Std, Median, n" style(column)=[width=1.5in];
define mean4/"Allo*Mean &pm Std, Median, n" style(column)=[width=1.5in];
define pv/"p value";
run;
ods rtf close;
