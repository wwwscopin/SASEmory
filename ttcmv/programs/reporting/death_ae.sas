%include "death_sae.sas";

options ORIENTATION = LANDSCAPE nodate nonumber sysprintfont=("times" 12);
libname wbh "/ttcmv/sas/data";

/*
proc contents data=cmv.plate_100;run;
proc print data=cmv.plate_100;run;

proc contents data=cmv.plate_101;run;
proc print data=cmv.plate_101;run;
*/


proc format; 	
	value DeathCause 
		1="CMV disease"
		2="IVH"
		3="Infection/Sepsis"
		4="Transfusion reaction"
		5="NEC"
		6="BPD"
		7="PDA"
		;
	value check
		0="No"
		1="Yes"
		99=" "
		;	
run;


data tmp;
	set cmv.plate_100;
	if DeathContCause=0 then DeathCauseText="--";
	else if DeathContCause=1 and DeathCauseText=" " then DeathCauseText="Pending";
	keep id DeathDate deathcause DeathContCause DeathCauseText Autopsy;
run;

proc sql;
create table death as
select a.*  , gender, race, LBWIDOB as dob 
from 
tmp as a
left join
cmv.plate_005 as b
on a.id =b.id
;

data snap2;
	set cmv.snap2;
	if SNAP2Score=. then delete;
	keep id DOLdate SNAP2Score DFSEQ;
	RENAME DFSEQ=day;
run;

proc sort; by id day; run;

data snap2;
	set snap2;  by id;
	if last.id;
run;

data urine_nat;
	set cmv.LBWI_Urine_NAT_Result(rename=(UrineTestResult=urine DFSEQ=day));
	keep id urine day;
	format urine CMVNATResult.;
run;

proc sort nodupkey; by id decending urine;run;

data urine_nat;
	set urine_nat;by id;
	if first.id;
run;


data blood_nat;
	set cmv.LBWI_blood_NAT_result(rename=(NATTestResult=blood DFSEQ=day));
	if blood^=99;
	keep id blood day;
	format blood CMVNATResult.;
run;

proc sort nodupkey; by id decending blood;run;

data blood_nat;
	set blood_nat;by id;
	if first.id;
run;

data death;
	length deathcause0 $100	deathcausetext $100;
	set death(in=ae) wbh.sae(where=(death=1));
	age=DeathDate-dob;
	center=floor(id/1000000);
	DeathCauseText=propcase(DeathCauseText);
	if ae then deathcause0=put(deathcause, deathcause.);
	*if id=2005211 then deathcause0=strip(deathcause0)||"*"; 

	drop death;
	format center center. deathCause deathcause. DeathContCause check. Autopsy check. gender gender. race race.;
	label deathcause="Death Cause"
			age="Age at death*(days)"
			DeathContCause="Contributing cause* of death determined?"
			DeathCauseText="Contributing cause* of death"
			Autopsy="Autopsy*performed?"
			gender="Gender"
			race="Race"
	;
run;

proc sort nodupkey; by id;run;


data death; 
	length bu $30;
	merge death(in=tmp) snap2 urine_nat(rename=(day=day_urine)) blood_nat(rename=(day=day_blood)) cmv.completedstudylist(in=comp); by id;
	if blood=urine then bu=put(blood, CMVNATResult.);
	else if blood^=. and urine^=. then bu="Blood-"||strip(put(blood, CMVNATResult.))||"/Urine-"||strip(put(urine, CMVNATResult.));
	else if blood^=. and urine=. then bu="Blood-"||strip(put(blood, CMVNATResult.));
	else if blood=. and urine^=. then bu="/Urine-"||strip(put(urine, CMVNATResult.));
	
	if tmp and comp;
run;

proc sort nodupkey; by id deathcause0 urine blood;run;


data death_id; 
	set death;
	keep id;
run;

data rbc_id;
	set cmv.plate_031;
	keep id DateTransfusion;
run;

proc sql;
	create table rbc_death as 
	select a.*
	from rbc_id as a, death_id as b
	where a.id=b.id;

proc means data=rbc_death;
	class id;
	var DateTransfusion;
	output out=rbc_num n(DateTransfusion)=n;
run;

data rbc_num;
	set rbc_num;
	if id^=.;
	keep id n;
run;

data death; 
	merge death rbc_num; by id;
run;

data wbh.death; 
	set death;
run;

proc freq data=death;
	table center;
	ods output Freq.Table1.OneWayFreqs=tab;
run;

data _null_;
	set tab;
	if center=1 then call symput("n1", strip(put(frequency, 3.0)));
	if center=2 then call symput("n2", strip(put(frequency, 3.0)));
	if center=3 then call symput("n3", strip(put(frequency, 3.0)));
run;

%let n=%eval(&n1+&n2+&n3);

%let path=/ttcmv/sas/output/monthly_internal/;

ods rtf file="&path.&file_mortality.death.rtf" style=journal startpage=no bodytitle;
title1 "&title_mortality-- &n Total Deaths";
title2 "Midtown (n=&n1)";
proc print data=death noobs label split="*" style(data)=[just=center];
	where center=1;
	var id age gender race dob N;
	var bu/style(data) =[cellwidth=1in];
	var SNAP2Score;
	var deathcause0/style(data) =[just=left cellwidth=2in];
	var deathcontcause/style(data) =[just=center cellwidth=1in];
	var deathcausetext/style(data) =[just=left cellwidth=1in];
	var autopsy;
	label n="Num of RBC Transfusions"
			bu="CMV NAT*Test Results*(Blood/Urine)" 
			snap2score="Snap II *Score"
			deathcause0="Primary Death Cause"		
	;
run;

ods rtf startpage=yes;

title1 "TTCMV LBWI Death Summary --&n Total Deaths";
title2 "Grady (n=&n2)";
proc print data=death noobs label split="*" style(data)=[just=center];
	where center=2;
	var id age gender race dob N;
	var bu/style(data) =[cellwidth=1in];
	var SNAP2Score;
	var deathcause0/style(data) =[just=left];
	var deathcontcause;
	var deathcausetext/style(data) =[just=left];
	var autopsy;
	label n="Num of RBC Transfusions"  
			bu="CMV NAT*Test Results*(Blood/Urine)" 
			snap2score="Snap II *Score"
			deathcause0="Primary Death Cause"		
	;
run;

/*
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in}
*Cause of death: Pulmonary Hypertension; RDS syndrome; Prematurity; Sepsis (Culture negative); PVC; Hypotension; Coagulopathy; Pleural Effusions.';
*/

ods rtf startpage=yes;

title1 "TTCMV LBWI Death Summary --&n Total Deaths";
title2 "Northside (n=&n3)";
proc print data=death noobs label split="*" style(data)=[just=center];
	where center=3;
	var id age gender race dob N;
	var bu/style(data) =[cellwidth=1in];
	var SNAP2Score;
	var deathcause0/style(data) =[just=left];
	var deathcontcause;
	var deathcausetext/style(data) =[just=left];
	var autopsy;
	label n="Num of RBC Transfusions" 
			bu="CMV NAT*Test Results*(Blood/Urine)"  
			snap2score="Snap II *Score"
			deathcause0="Primary Death Cause"		
	;
run;
ods rtf close;

proc contents data=wbh.death;run;
