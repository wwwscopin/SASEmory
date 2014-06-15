options spool orientation=portrait;
%include "H:\SAS_Emory\Macro\tab_stat.sas";

PROC IMPORT OUT= WORK.demo0 
            DATAFILE= "H:\SAS_Emory\Consulting\Chiles\ALIF Demographics Nov. 25.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Demographics$A1:O63"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc format; 
	value gender 0="Female" 1="Male";
	value procedure 1="ALIF" 2="ALIF+Post" 3="ALIF+Plate";
	value level 1="L4-L5"  2="L5-S1";
	value fused 0="No" 1="Yes";
	value num 1="Num of Levels=1" 2="Num of Levels=2";
	value later 0="Earlier Rating" 1="Later Rating";
	value pmonth 1="0~2 Months" 2="2~4 Months" 3="4~6 Months" 4="6~8 Months" 5="8~10 Months" 6="10~12 Months" 7=">=12 Months";
	value cage 1="InFix" 2="LT-Cage (x2)" 3="PEEK" 4="PERIMETER" 5="SynFix";
run;

data demo;
	set demo0(rename=(gender=gender0 procedure=procedure0 length_of_stay=los));
	age=(procDate-dob)/365.25;
	opera_time=(Close_Time-cut_time)/60;
	if gender0="F" then gender=0; if Gender0="M" then gender=1;
	if procedure0="ALIF" then procedure=1; else if Procedure0="ALIF+Post" then procedure=2; else if Procedure0="ALIF+Plate" then procedure=3;
	keep empi LName FName dob ProcDate age close_time cut_time opera_time gender procedure los levels BMI;
	format gender gender. procedure procedure. age 4.1 levels num. ;
run;
proc sort; by lname fname; run;

PROC IMPORT OUT= WORK.cost0 
            DATAFILE= "H:\SAS_Emory\Consulting\Chiles\ALIF Study Cost Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="All Patients$A1:S62"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc contents short varnum;run;
*/

data cost;
	set cost0(rename=(__Levels=level_num));
	Keep ChartID LName FName DOB AdmitDate Discharge level_num Total_Charges Total_Supplies Total_Time_Costs Surgical_Supplies Devices 
		Implants Operating_Room Anasthesia Recovery_Room All_Other_Costs;
	format level_num num.;
	if chartid=25294970 then do;Total_Charges=.; Total_Supplies=.; Surgical_Supplies=.; end;
	if chartid=10016905 then do;Total_Charges=.; Total_Supplies=.; Implants=.; end;
run;
proc sort; by lname fname; run;

data alif;
	merge demo cost;by lname fname; 
run;

PROC IMPORT OUT= WORK.image0 
            DATAFILE= "H:\SAS_Emory\Consulting\Chiles\Composite All Imaging Reads Dec. 8th.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="ALIF CT Imaging$A2:AB129"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*
proc contents;run;
proc contents short varnum;run;
*/
data image;
	set image0(rename=(procedure=procedure0 level=level0) drop=procmonth);
	idx=_n_;
	if procedure0="ALIF" then procedure=1; else if Procedure0="ALIF+Post" then procedure=2; else if Procedure0="ALIF+Plate" then procedure=3;
	if level0="L4-L5" then level=1; else if level0="L5-S1" then level=2;
	rename score=score0 left_=left_0 Center_=center_0 right_=right_0 fused=fused0 __Levels=nlevel;
	procmonth=(image_date-procdate)/365*12;
	fused_combine=sum(of fused fused1 fused2)>=2;
	if 0<=procmonth<2 then pmonth=1; else if 2<=procmonth<4 then pmonth=2; else if 4<=procmonth<6 then pmonth=3; 
	else if 6<=procmonth<8 then pmonth=4;  else if 8<=procmonth<10 then pmonth=5;  else if 10<=procmonth<12 then pmonth=6; 
	else if procmonth>12 then pmonth=7;

	if Cage_Type="InFix"  then cage=1;
		else if Cage_Type="LT-Cage (x2)"  or Cage_Type="LT-Cage (2x)"  then cage=2;
		else if Cage_Type="PEEK"  then cage=3;
		else if Cage_Type="PERIMETER" then cage=4;
		else if Cage_Type="SynFix" then cage=5;
	keep idx EMPI LName FName Image_Date Procedure Cage_Type Level ProcDate ProcMonth Image_Date Cage_Type Level Score Left_ Center_ Right_ Fused 
		 Score1 Left_1 Center_1 Right_1 Fused1 Score2 Left_2 Center_2 Right_2 Fused2 fused_combine pmonth __Levels cage age bmi;
	format level level. fused fused1 fused2 fused_combine fused. procmonth 5.2 pmonth pmonth. Cage cage.;
run;

proc freq;
tables Cage;
run;

proc means data=image median maxdec=1;
	var procmonth;
	output out=wbh median(procmonth)=median;
run;

data _null_;
	set wbh;
	call symput("median_procmonth", put(median, 4.1));
run;

%put &median_procmonth;

data image;
	set image;
	if procmonth>&median_procmonth then later=1; else later=0;
	format later later.;
run;

%table(data_in=image,data_out=rate,gvar=later,var=fused_combine,type=cat, first_var=1, last_var=1, label="Fused?",title="TableA: Comparison between Rating Earlier and Later", prn=1);
%table(data_in=image,data_out=cage,gvar=fused_combine, var=cage, type=cat, first_var=1, last_var=1, label="Cage Type",title="TableB: Comparison between Rating Earlier and Later", prn=1);


proc logistic data=image descending plots=roc;
  class procedure level nlevel Cage/param=ref ref=last order=internal;
  model fused_combine =age BMI procedure level nlevel procmonth /*cage*//lackfit scale=none aggregate rsquare;
  format procedure procedure. level level. nlevel num. Cage cage.;
run;

proc logistic data=image descending plots=roc;
  class procedure level Cage/param=ref ref=last order=internal;
  model fused_combine =age BMI procedure level procmonth /*cage*//lackfit scale=none aggregate rsquare;
  format procedure procedure. level level. Cage cage.;
run;


data rate0;
	set image;
	where (fused0^=. and fused1^=. and fused2^=.);
	*if procmonth>6;
run;

data rate;
	set rate0(keep=idx fused0 in=A rename=(fused0=fused))
		rate0(keep=idx fused1 in=B rename=(fused1=fused))
		rate0(keep=idx fused2 in=C rename=(fused2=fused)); by idx;
	if A then rate=1; 
	if B then rate=2;
	if C then rate=3;
run;
/*
proc sort; by idx rate; run;

proc freq data=rate noprint;
    tables idx*fused /sparse out=_balance;
run;

data temp;
	set rate;
	where rate in(2 3);
run;
*/
/* Define the MAGREE macro */
%inc "H:\SAS_Emory\Consulting\Chiles\MAGREE.sas";
%magree(data=rate, items=idx,  raters=rate,  response=fused); quit;
