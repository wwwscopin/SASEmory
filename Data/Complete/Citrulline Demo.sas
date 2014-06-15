option nofmterr nodate nonumber orientation=landscape;
libname wbh "H:\SAS_Emory\Data\complete";
%let mu=%sysfunc(byte(181));
%put &mu;
%include "tab_stat.sas";

/*proc contents data=wbh.info;run;*/
proc format; 
	value cit   1="<=10 &mu.mol/L" 2="10-20 &mu.mol/L" 3=">20 &mu.mol/L";
	value citru 1="<=10 &mu.mol/L" 2=">10 &mu.mol/L";
	value yn    0="No" 1="Yes";
	value apache   99 = "Blank"
                 1 = "APACHE <=15"
                 2 = "APACHE >15" ;
	value surg_index 0="Non-GI" 1="GI";
	value gender   99 = "Blank"
                 1 = "Male"
 				 2 = "Female" ;
    value race   99 = "Blank"
                 1 = "American Indian / Alaskan Native"
                 2 = "Asian"
                 3 = "Black or African American"
                 4 = "Native Hawaiian or Pacific Islan"
                 5 = "White"
                 6 = "More than one race"
                 7 = "Other" ; 
  value op   99 = "Blank"
                 1 = "CABG"
                 2 = "Cardiac valve"
                 3 = "Vascular"
                 4 = "Intestinal resection" 
                 5='Peritonitis'
                 6='Upper GI resection';   
  value treatment   99 = "Blank"
                 1 = "AG-PN"
                 2 = "STD-PN" ; 
run;

PROC IMPORT OUT= citrulline0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="citrulline$A1:G661"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data citrulline;
	set citrulline0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	citrulline=round(result);
	if id=32006 then delete;
	keep id day citrulline;
	label citrulline="Citrulline (&mu.mol/L)";
run;
proc sort; by id day; run;
proc means data=citrulline(where=(day=0)) noprint n Q1 median Q3 maxdec=1;
	var citrulline;
	output out=wbh q1(citrulline)=Qc1 median(citrulline)=Qc2  q3(citrulline)=Qc3 /autoname;
run;

data _null_;
	set wbh;
	call symput("qc1", qc1);
	call symput("qc2", qc2);
	call symput("qc3", qc3);
run;

proc sql;
	create table wbh.citrulline as 
	select a.*, count(citrulline) as n
	from citrulline as a
	group by id
	;

PROC IMPORT OUT= glutamine0 
            DATAFILE= "H:\SAS_Emory\Data\complete\Complete Amino Acid profilel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="glutamine$A1:G658"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data glutamine;
	set glutamine0;
	id=first_name+0;
	day=compress(study_day, "day")+0;
	rename result=glutamine;
	if id=32006 then delete;
	keep id day result;
	label result="Glutamine (&mu.M)";
run;
proc sort; by id day; run;

proc sql;
	create table wbh.glutamine as 
	select a.*, count(glutamine) as n
	from glutamine as a
	group by id
	;
quit;
proc format;
	value qcit 1="Citrulline<~&qc1.&mu.m" 2="Citrulline=&qc1.~&qc2.&mu.m" 3="Citrulline=&qc2.~&qc3.&mu.m" 4="Citrulline>=&qc3&mu.m";
	value sofa 1="<=6" 2=">6";
run;

/*proc contents data=wbh.info;run;*/

data glnd;
	merge citrulline(where=(day=0)) glutamine(where=(day=0)) wbh.followup_all_long(keep=id day sofa_tot where=(day=1))
	wbh.info(keep=id age gender race surg ap0 ap1 apache_2 dt_discharge dt_death dt_random hospital_death deceased 
		day_28_death followup_days days_sicu days_sicu_post_entry days_hosp days_hosp_post_entry
		ni_bsi ni_any ni_lri treatment); 
	by id; 
	if 0<=citrulline<=10 then cit=1;
		else if 10<citrulline<=20 then cit=2;
		else if 20<citrulline then cit=3;
	
	if cit=1 then citru=1; else if cit in(2,3) then citru=2;

	if  0<=citrulline<&Qc1 then qcit=1;
	else if &Qc1<=citrulline<&Qc2 then qcit=2;
	else if &Qc2<=citrulline<&Qc3 then qcit=3;
	else if &Qc3<=citrulline then qcit=4;
	
	if 0<ap1<=15 then apache_icu=1; else if ap1>15 then apache_icu=2;
	if glutamine>2000 then glutamine=.;
	if sofa_tot>6 then sofa=2; else sofa=1;
	if ni_bsi>0 then bsi=1; else bsi=0;
	if ni_lri>0 then lri=1; else lri=0;
	if ni_any>0 then any=1; else any=0;
	if surg="Upper GI resection" then surg_index=1; else surg_index=0;
	if surg="Upper GI resection" then surg_code=6;
	else if surg="Peritonitis" then surg_code=5;
	else if surg="Intestinal resection" then surg_code=4;
	else if surg="Vascular" then surg_code=3;
	else if surg="Cardiac valve" then surg_code=2;
	else if surg="CABG" then surg_code=1;
	else surg_code=99;

	days_sicu_pre_entry=days_sicu-days_sicu_post_entry;
	days_hosp_pre_entry=days_hosp-days_hosp_post_entry;

	dday=dt_death-dt_random;
	if dday=. then dday=dt_discharge-dt_random;
	drop day;
	label cit="Citrulline" citru="Citrulline" 
		  days_sicu_pre_entry="Days in SICU prior to study entry"
		  days_hosp_pre_entry="Days in Hospital prior to study entry"
		  surg_code="Surgery Index";
	format cit cit. citru citru. qcit qcit. apache_2 apache_icu apache. sofa sofa. bsi lri any yn. 
		surg_index surg_index. surg_code op. gender gender. race race. treatment treatment.;
run;

proc sgscatter data=glnd;
  title "Scatterplot Matrix for GLND";
  *matrix citrulline ap0 sofa_tot / group=treatment;
  compare x=(ap0 sofa_tot)
          y=(citrulline)
          / group=treatment;
  *plot (ap0 sofa_tot)*(citrulline)
       / pbspline;
  label citrulline="Baeline Citrulline (&mu.mol/L)"
	ap0="Apache II at Randomization"
	sofa_tot="SOFA at Randomization";
run;

/*
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=age,type=con, first_var=1, title="Table1: Citrulline Related Demo");
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=gender,type=cat);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=race,type=cat);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=surg_code,type=cat);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=apache_2,type=cat);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=ap0,type=con);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=days_sicu_pre_entry,type=con);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=days_sicu_post_entry,type=con);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=days_hosp_pre_entry,type=con);
%table(data_in=glnd,data_out=citrulline_tab,gvar=qcit,var=days_hosp_post_entry,type=con, last_var=1);
*/

proc univariate data=wbh.info plots;
var followup_days days_sicu days_sicu_post_entry days_hosp days_hosp_post_entry;
qqplot;
run;

