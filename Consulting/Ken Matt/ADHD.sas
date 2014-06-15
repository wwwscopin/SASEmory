options orientation=portrait;
%include "tab_stat.sas";
PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Ken Matt\ADD study 2009-2012 data.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*
proc print;run;
proc freq; 
tables sport;
run;
*/

proc format;
	value sport 1="Basketballl" 2="Wrestle" 3="Cheer" 4="Football" 5="Lax" 6="Soccer";
	value sex 0="Female" 1="Male";
	value adhd 0="No" 1="Yes";
	value long 0="Short(<21 days)" 1="Long(>=21 days)";
	value yn 0="No" 1="Yes";
run;

data adhd;
	retain id sex age sport adhd Previous_Concussions Days_till_Improvement;
	set temp(rename=(sport=sport0));
	if id=. then delete;
	if gender="m" then sex=1; else sex=0;
	if lowcase(add__adhd)="y" then adhd=1; else adhd=0;
	if sport0="bskbl" or sport0="bsktbl" then sport=1;
	else if sport0="wre" or sport0="wres" then sport=2;
	else if sport0="cheer"  then sport=3;
	else if sport0="fb"  then sport=4;
	else if sport0="lax"  then sport=5;
	else if sport0="soccer"  then sport=6;
	if Days_till_Improvement>=21 then long=1;else long=0;
	if Days_till_Improvement>13 then med=1; else med=0;
	if Previous_Concussions>0 then concurr=1; else concurr=0;
	format sport sport. sex sex. adhd adhd. long long. concurr yn.;

	if Previous_Concussions=3 then Previous_Concussions=2;

	keep id age sport sex adhd Previous_Concussions Days_till_Improvement long concurr med;
	rename Previous_Concussions=concussion Days_till_Improvement=day;
	label age="Age"
		  sex="Gender"
		  Concussion="# Pervious Concussion"
		  day="Days till Improvement"
		  long="Short/Long"
		  concurr="Pervious Have Concussion?"
		 ;
run;

proc glm data = adhd/*(where=(concussion>0))*/;
  class concussion adhd;
  model day = concussion adhd concussion*adhd/solution;
run;

proc sgscatter data=adhd;
	plot concussion*day;
run;

proc means data=adhd/*(where=(concussion>0))*/ n mean std min Q1 median Q3 max maxdec=1;
	types () ADHD concussion ADHD*concussion;
	class ADHD concussion;
	var day;
run;

proc freq data=adhd;
tables adhd*med/fisher;
run;

proc freq data=adhd;
tables adhd*long/fisher;
run;

/*
proc univariate data=adhd plot;
	var day;
run;

proc freq data=adhd;
	tables adhd*sport/chisq fisher;
run;

proc npar1way data=adhd(where=(concussion>0)) wilcoxon;
	class ADHD;
	var day;
run;

proc npar1way data=adhd wilcoxon;
	class concussion;
	var day;
run;
*/

proc freq data=adhd;
	tables adhd*long/chisq fisher;
run;

proc means data=adhd mean std stderr min Q1 median Q3 max maxdec=1;
	class adhd;
	var day;
run;
proc npar1way data=adhd wilcoxon;
	class adhd;
	var day;
run;
/*
proc means data=adhd;
	var day;
run;

proc ttest data=adhd;
	class adhd;
	var day;
run;

proc power; 
   twosamplemeans test=diff 
   groupmeans = 15.0 | 20.4 
   stddev = 12.3
   npergroup = . 
   power = 0.7 0.8 0.9; 
run;

proc power; 
   twosamplemeans test=diff 
   groupmeans = 15.0 | 20.4 
   stddev = 12.3
   groupns = (72 69)
   power = .; 
run;
*/

data ADD;
	set adhd;
run;

%table(data_in=ADD,data_out=adhd_tab,gvar=adhd,var=age,type=con, first_var=1, title="Table Summary");
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=sex,type=cat);
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=concussion,type=con);
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=concussion,type=cat);
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=concurr,type=cat);
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=day,type=con);
%table(data_in=add,data_out=adhd_tab,gvar=adhd,var=long,type=cat, last_var=1);
