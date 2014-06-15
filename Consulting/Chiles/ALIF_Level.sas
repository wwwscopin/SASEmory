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

ods listing close;
options orientation=landscape;
%table(data_in=alif,data_out=demo,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1: Comparison between Procedures");
%table(data_in=alif,data_out=demo,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif,data_out=demo,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif,data_out=demo,gvar=procedure,var=levels,type=cat, label="Levels");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif,data_out=demo,gvar=procedure,var=Implants,type=con, decmax=0,last_var=1, label="Devices($)", prn=1);

%table(data_in=alif,data_out=demo4,gvar=level_num,var=age,type=con, first_var=1,label="Age",title="Table3: Comparison between Levels");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=BMI,type=con, label="BMI");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Procedure,type=cat, label="Treatment");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=gender,type=cat, label="Gender");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif,data_out=demo4,gvar=level_num,var=Implants,type=con, decmax=0,last_var=1, label="Devices($)", prn=1);

options orientation=portrait;
%table(data_in=alif,data_out=cost,gvar=level_num,var=Total_Charges, decmax=0, type=con, first_var=1, label="Total Cost($)",title="Table2: Comparison between Levels");
%table(data_in=alif,data_out=cost,gvar=level_num,var=Total_Supplies,type=con,  decmax=0,label="Supply Cost($)") ;
%table(data_in=alif,data_out=cost,gvar=level_num,var=Total_Time_Costs,type=con,decmax=0, label="Operating Cost($)");
%table(data_in=alif,data_out=cost,gvar=level_num,var=All_Other_Costs,type=con, decmax=0, label="All Other Cost($)");
%table(data_in=alif,data_out=cost,gvar=level_num,var=Surgical_Supplies,type=con, decmax=0, label="Surgical_Supplies($)");
%table(data_in=alif,data_out=cost,gvar=level_num,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif,data_out=cost,gvar=level_num,var=Implants,type=con, decmax=0, last_var=1, label="Implants($)", prn=1);

%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Total_Charges, decmax=0, type=con, first_var=1, label="Total Cost($)",title="Table2a: Comparison between Procedures @Level=1");
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Total_Supplies,type=con,  decmax=0,label="Supply Cost($)") ;
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Total_Time_Costs,type=con,decmax=0, label="Operating Cost($)");
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=All_Other_Costs,type=con, decmax=0, label="All Other Cost($)");
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical_Supplies($)");
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif,where=levels=1, data_out=cost1,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Implants($)", prn=1);

%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Total_Charges, decmax=0, type=con, first_var=1, label="Total Cost($)",title="Table2b: Comparison between Procedures @Level=2");
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Total_Supplies,type=con,  decmax=0,label="Supply Cost($)") ;
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Total_Time_Costs,type=con,decmax=0, label="Operating Cost($)");
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=All_Other_Costs,type=con, decmax=0, label="All Other Cost($)");
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical_Supplies($)");
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif,where=levels=2, data_out=cost2,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Implants($)", prn=1);

ods listing;
/*
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1a: Comparison between ALIF and ALIF+Post");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=procedure in(1,2), data_out=demo1,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1b: Comparison between ALIF and ALIF+Plate");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=procedure in(1,3), data_out=demo2,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1c: Comparison between ALIF+Post and ALIF+Plate");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Charges,type=con,decmax=0, label="Total Cost($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0, label="Operating Cost($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=All_Other_Costs,type=con, decmax=0, label="All Other Cost($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=procedure in(2,3), data_out=demo3,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);


%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table3a: Comparison between Procedure @Level=1");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=levels=1, data_out=demo5,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table3b: Comparison between Procedure @Level=2");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=levels=2, data_out=demo6,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);
*/

/*
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1a: Comparison between ALIF and ALIF+Post @Level1");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=levels=1 and procedure in(1,2), data_out=demo1,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1b: Comparison between ALIF and ALIF+Plate @Level1");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Charges,type=con, decmax=0, label="Total Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0,label="Operating Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=All_Other_Costs,type=con, decmax=0,label="All Other Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=levels=1 and procedure in(1,3), data_out=demo2,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=age,type=con, first_var=1,label="Age",title="Table1c: Comparison between ALIF+Post and ALIF+Plate @Level1");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=BMI,type=con, label="BMI");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=los,type=con, label="Length of Stay(Day)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=opera_time,type=con, label="Operation Time(min)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=gender,type=cat, label="Gender");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Charges,type=con,decmax=0, label="Total Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Supplies,type=con, decmax=0, label="Supply Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Total_Time_Costs,type=con, decmax=0, label="Operating Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=All_Other_Costs,type=con, decmax=0, label="All Other Cost($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Surgical_Supplies,type=con, decmax=0, label="Surgical Supplies($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Devices,type=con, decmax=0, label="Devices($)");
%table(data_in=alif, where=levels=1 and procedure in(2,3), data_out=demo3,gvar=procedure,var=Implants,type=con, decmax=0, last_var=1, label="Devices($)", prn=1);

*/

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
proc contents;run;
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
	keep idx EMPI LName FName Image_Date Procedure Cage_Type Level ProcDate ProcMonth Image_Date Cage_Type Level Score Left_ Center_ Right_ Fused 
		 Score1 Left_1 Center_1 Right_1 Fused1 Score2 Left_2 Center_2 Right_2 Fused2 fused_combine pmonth __Levels;
	format level level. fused fused1 fused2 fused_combine fused. procmonth 5.2 pmonth pmonth.;
run;
proc sort; by empi;run;

proc freq;
tables Cage_Type;
run;
proc sort data=alif; by empi;run;

data image;
	merge image alif(keep=empi dob); by empi;
	age=(procdate-dob)/365.25;
run;

/*
proc freq data=image(where=(procmonth<=6 and level=1)); 
	tables procedure*fused_combine/fisher;
run;
proc freq data=image(where=(procmonth<=6 and level=2)); 
	tables procedure*fused_combine/fisher;
run;

proc freq data=image(where=(procmonth<=6)); 
	tables procedure*fused_combine/fisher;
run;


proc freq data=image(where=(procmonth>6 and level=1)); 
	tables procedure*fused_combine/fisher;
run;
proc freq data=image(where=(procmonth>6 and level=2)); 
	tables procedure*fused_combine/fisher;
run;
proc freq data=image(where=(procmonth>6)); 
	tables procedure*fused_combine/fisher;
run;

proc freq data=image; 
	tables procedure*fused_combine/fisher;
run;

proc freq data=image; 
	tables level*fused_combine/fisher;
run;

proc freq data=image; 
	tables fused_combine*pmonth/fisher trend measures cl
          plots=freqplot(twoway=stacked);
		  exact trend / maxtime=60;
run;
*/

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

%table(data_in=image,data_out=rate,gvar=later,var=fused_combine,type=cat, first_var=1, last_var=1, label="Fused?",title="Table3: Comparison between Rating Earlier and Later", prn=1);


proc logistic data=image descending;
  class procedure level/param=ref ref=first order=internal;
  model fused_combine =procedure level  procmonth/lackfit scale=none aggregate  rsquare;
  format procedure procedure. level level.;
run;

proc logistic data=image descending;
  class procedure /param=ref ref=first order=internal;
  model fused_combine =procedure procmonth/lackfit scale=none aggregate  rsquare;
  format procedure procedure. ;
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
