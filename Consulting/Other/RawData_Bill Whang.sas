PROC IMPORT OUT= control_excel
            DATAFILE= "H:\SAS_Emory\Consulting\LovenoxDVT.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="modified"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data control_raw;
	set control_excel;
	if pt="" then delete;
	drop F21-F27 age1 days___doses hemorrhage;
	rename units=hemorrhage ht_wt=bmi;
	if risk_factors in ('no','none') then risk_factors='None';
	group=0;
	hormone=PROPCASE(hormone);
	smoker=PROPCASE(smoker);
    dvt=PROPCASE(dvt);
	dg=PROPCASE(dg);
	pe=PROPCASE(pe);
	risk_factors=PROPCASE(risk_factors);
	wound_problem=PROPCASE(wound_problem);
	if hip_or_knee='TKA' then doses=(days-1)*2;
	else if hip_or_knee in ('THA','THR') then doses= (days-1)*1;
	if scan(hormone,1,1)^='N' then hormone='Y';
	if wound_problem='No' or wound_problem=" "  then wound=0; else wound=1;
	if wound_problem=" " then  wound_problem='No';
run;

proc format;
value HK 0='Hip' 1='Knee';
value gender 0='F' 1='M';
value Hormone 0='N' 1='Y';
value smoker  0='N' 1='Y';
value dvt 0='N' 1='Y';
value pe 0='N' 1='Y';
value death	0='N' 1='Y';
value group 0='Control' 1='Study';
value wound 0='N' 1='Y';
run;

Data Control;
	set control_raw(rename=(gender=gender0 hormone=hormone0 smoker=smoker0 dvt=dvt0 pe=pe0 death=death0));
	if hip_or_knee='THA' then HK=0;
	else if hip_or_knee='TKA' then HK=1;
	else if hip_or_knee='THR' then HK=0;

	if gender0='F' then gender=0; else gender=1;
	if Hormone0='N' then Hormone=0; else Hormone=1;
	if Smoker0='N' then Smoker=0; else Smoker=1;
	if dvt0='No' then dvt=0; else dvt=1;
	if pe0='No' then pe=0; else pe=1;
	if death0='no' then death=0; else death=1;
	drop gender0 hormone0 smoker0 dvt0 pe0 death0 hip_or_knee;
run;
/*
proc freq data=control(keep=HK gender hormone smoker dvt pe death dg);run;
proc freq data=control(keep=risk_factors dg wound_problem);run;

proc means data=control;
var age BMI ASA days hemorrhage;
run;
*/

PROC IMPORT OUT= study_excel
            DATAFILE= "H:\SAS_Emory\Consulting\inpt enoxaparin.xls" 
            DBMS=EXCEL REPLACE;
     SHEET="sheet1"; 
     GETNAMES=YES;
     MIXED=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data study_raw;
	length hip_knee $8;
	set study_excel(rename=(days_=days gen=gender hemorrhage=hemo));
	if pt="" then delete;
	drop F21-F22 age1  days_1;
	group=1;
	if wound_problem='none' then wound_problem='no';
	if pe='yes - 11/25 - 3 months' then pe='yes';
	if dvt^='yes' then dvt='no';
	if hormone in ('n','N - quit') then hormone='N';


	hemorrhage=compress(hemo,'units')+0;
	if hemo='no' then hemorrhage=0;

	dvt=PROPCASE(dvt);
	smoker=PROPCASE(smoker);
	dg=PROPCASE(dg);
	pe=PROPCASE(pe);
	gender=PROPCASE(gender);
	hip_or_knee=PROPCASE(hip_or_knee);
	risk_factors=PROPCASE(risk_factors);
	wound_problem=PROPCASE(wound_problem);

	if scan(hip_or_knee,1, ' ') in ('Hip', 'Tha') then hip_knee='Hip';
	else if scan(hip_or_knee,1, ' ') in ('Knee', 'Tka') then hip_knee='Knee';
	if wound_problem='No' or wound_problem=" "  then wound=0; else wound=1;
	if wound_problem=" " then  wound_problem='No';
	drop hemo;
run;

Data study;
	set study_raw(rename=(gender=gender0 hormone=hormone0 smoker=smoker0 dvt=dvt0 pe=pe0 death=death0));
	if hip_knee='Hip' then HK=0; else HK=1;
	
	if gender0='F' then gender=0; else gender=1;
	if Hormone0='N' then Hormone=0; else Hormone=1;
	if Smoker0='N' then Smoker=0; else Smoker=1;
	if dvt0='No' then dvt=0; else dvt=1;
	if pe0='No' then pe=0; else pe=1;
	if death0='no' then death=0; else death=1;
	drop gender0 hormone0 smoker0 dvt0 pe0 death0 hip_knee hip_or_knee;
run;

data HK;
	set study control;
	format HK HK. gender gender. Hormone Hormone. smoker smoker. dvt dvt. pe pe. death death. group group. wound wound.;
run;

proc print;run;
proc contents;run; 

proc freq data=HK;
	table group*(HK gender hormone smoker dvt pe death wound)/nopercent nocol chisq fisher;
run;
proc freq data=HK;
	tables (risk_factors dg wound_problem)*group /nopercent norow nocol;
run;

proc means data=HK MAXDEC=2;
by group notsorted;
var age BMI ASA days hemorrhage;
run;
/*
proc genmod data=HK;
	class group;
	model age=group/noint dist=normal;
	estimate 'Means of study and control' group -1 1;
	*estimate 'Means of study and control'intercept 1 group 0 1;
	CONTRAST 'compare study with control' group 1  -1;
run;


proc genmod data=HK;
	where HK=0;
	class group;
	model HK=group/noint dist=binomial;
	CONTRAST 'compare study with control' group 1  -1;
run;
*/

option MINOPERATOR;
%macro compare(dataset,varlist) /parmbuff ;
%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
    proc genmod data = &dataset descend;
		class group;
		%if &var in (age BMI ASA days hemorrhage) %then 
		%do;
     		model &var=group /noint dist=normal;
		%end;
		%else %do;
     		model &var=group /noint dist=binomial;
		%end;
		contrast 'Compare study with control' group -1 1;
    run;
    %let i= %eval(&i+1);
    %let var = %scan(&varlist,&i);
%end;
%mend ;

title "Compare patient characteristics between study and control groups";
%compare(HK, age gender BMI smoker ASA hormone HK);quit; 
title "Compare outcomes between study and control groups";
%compare(HK, dvt pe wound days hemorrhage);quit;
