%include "tab_stat.sas";
PROC IMPORT OUT= WORK.Bicep0 
            DATAFILE= "H:\SAS_Emory\Consulting\Rachel Burdette\Biceps tenodesis data sheet - updated.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:M37"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*proc contents;run;*/

proc format;
	value gender 0="F" 1="M";
	value side 1="Left" 2="Right";
	value level 1="Level=I" 2="Level=II" 3="Level=III";
run;
data bicep;
	set bicep0(rename=(ASES_post__Final_Score=ases_post gender=gender0 activity_level_1_3__Highest_to_l=level side=side0 subject__=subject));
	if gender0="M" then gender=1; else gender=0;
	if lowcase(side0)="right" then side=2; else side=1;
	drop gender0 side0;
	format Surgery_Date mmddyy10. gender gender. side side. level level.;
	ases_diff=ases_post-ases_pre;
	pain_diff=pain_post-pain_pre;
	label ases_diff="Post ASES - Pre ASES"
		  pain_diff="Post Pain - Pre Pain";
	if subject in(2 3 4 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 27 29 30 31 32 33 34 35 36);
run;
proc print;run;

proc means data=bicep n mean stderr min Q1 median Q3 max maxdec=1;
var age ases_post ases_pre pain_post pain_pre;
output out=wbh median(age)=med_age;
run;

data _null_;
	set wbh;
	call symput("med_age", put(med_age,3.0));
run;

proc format;
	value age_group 0="age<=&med_age" 1="age>&med_age";
run;
data bicep; 
	set bicep; 
	if age>&med_age then age_group=1; else if 0<age<=&med_age then age_group=0;
	format age_group age_group.;
run;

proc corr data=bicep plots=matrix(histogram);
	var ases_diff pain_diff;
run;

proc univariate data=bicep;
	class /*age_group gender side level */;
	var ases_diff pain_diff;
run;

%table(data_in=bicep,data_out=tab1,gvar=gender,var=ases_pre,type=con, first_var=1, title="Table Summary by Gender");
%table(data_in=bicep,data_out=tab1,gvar=gender,var=ases_post,type=con);
%table(data_in=bicep,data_out=tab1,gvar=gender,var=ases_diff,type=con);
%table(data_in=bicep,data_out=tab1,gvar=gender,var=pain_pre,type=con);
%table(data_in=bicep,data_out=tab1,gvar=gender,var=pain_post,type=con);
%table(data_in=bicep,data_out=tab1,gvar=gender,var=pain_diff,type=con, last_var=1);



%table(data_in=bicep,data_out=tab2,gvar=age_group,var=ases_pre,type=con, first_var=1, title="Table Summary by Age Group");
%table(data_in=bicep,data_out=tab2,gvar=age_group,var=ases_post,type=con);
%table(data_in=bicep,data_out=tab2,gvar=age_group,var=ases_diff,type=con);
%table(data_in=bicep,data_out=tab2,gvar=age_group,var=pain_pre,type=con);
%table(data_in=bicep,data_out=tab2,gvar=age_group,var=pain_post,type=con);
%table(data_in=bicep,data_out=tab2,gvar=age_group,var=pain_diff,type=con, last_var=1);


%table(data_in=bicep,data_out=tab3,gvar=side,var=ases_pre,type=con, first_var=1, title="Table Summary by Side");
%table(data_in=bicep,data_out=tab3,gvar=side,var=ases_post,type=con);
%table(data_in=bicep,data_out=tab3,gvar=side,var=ases_diff,type=con);
%table(data_in=bicep,data_out=tab3,gvar=side,var=pain_pre,type=con);
%table(data_in=bicep,data_out=tab3,gvar=side,var=pain_post,type=con);
%table(data_in=bicep,data_out=tab3,gvar=side,var=pain_diff,type=con, last_var=1);


%table(data_in=bicep,data_out=tab4,gvar=level,var=ases_pre,type=con, first_var=1, title="Table Summary by Activity Level");
%table(data_in=bicep,data_out=tab4,gvar=level,var=ases_post,type=con);
%table(data_in=bicep,data_out=tab4,gvar=level,var=ases_diff,type=con);
%table(data_in=bicep,data_out=tab4,gvar=level,var=pain_pre,type=con);
%table(data_in=bicep,data_out=tab4,gvar=level,var=pain_post,type=con);
%table(data_in=bicep,data_out=tab4,gvar=level,var=pain_diff,type=con,last_var=1);
