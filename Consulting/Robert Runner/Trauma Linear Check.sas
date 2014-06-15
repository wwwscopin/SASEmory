options nodate nonumber orientation=portrait;
libname run "H:\SAS_Emory\Consulting\Robert Runner";
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.pre0 
            DATAFILE= "H:\SAS_Emory\Consulting\Robert Runner\SaturdayOR.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Pre$A1:R74"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc freq data=pre0 order=freq;
	*tables Mechanism__GSW__MVA__MCA__fall__;
	tables race;
run;
*/
proc format;
	value mechanism 1="Fall"
				    2="GSW"
					3="Assault"
					4="MVC"
					5="Accident"
					6="Pedestrian"
					7="Mtrcycle"
					8="Struck"
					9="Bicycle"
					10="ATV"
					11="Animal"
					12="Sports"
					;
	value race 1="White" 2="Black" 3="Hispanic" 4="Asian" 5="Other";
	value gender 1="Male" 0="Female";
	value yn 0="No" 1="Yes";
	value post 0="Pre" 1="Post";
	value wkday 1="Monday" 2="Tuesday" 3="Wednesday" 4="Thursday" 5="Friday" 6="Saturday" 7="Sunday";
run;


data pre;
	set pre0(rename=(Patient__=PatientID IM_nail_used_=Nail race=race0 male=gender));
	date_ed=input(Date_presented_to_ED,date9.);
	date_c=input(D_C_date,date9.);
	weekday=weekday(date_ed);
	time_ed=input(arrival_time_in_ED__hrs_, time8.);
	hr_to_surgery=intck('day', date_ed, date_of_surgery)*24+intck('minute',time_ed,surgical_incision_time__hrs_)/60;
	los=intck('day',date_ed,date_c);
	if Mechanism__GSW__MVA__MCA__fall__="Fall"  then mechanism=1; 
		else if Mechanism__GSW__MVA__MCA__fall__="GSW"  then mechanism=2; 
		else if Mechanism__GSW__MVA__MCA__fall__="Assault"  then mechanism=3; 
		else if Mechanism__GSW__MVA__MCA__fall__="MVC"  then mechanism=4; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Mtrcycle"  then mechanism=7; 
		else if Mechanism__GSW__MVA__MCA__fall__="Struck"  then mechanism=8; 
		else if Mechanism__GSW__MVA__MCA__fall__="Bicycle"  then mechanism=9; 
		else if Mechanism__GSW__MVA__MCA__fall__="ATV"  then mechanism=10; 
		else if Mechanism__GSW__MVA__MCA__fall__="Animal"  then mechanism=11; 
	if date_of_surgery=. then delete;
	if race0="W" then race=1; else if race0="B" then race=2; else if race0="H" then race=3; else if race0="O" then race=4;
	format mechanism mechanism. femur_fx tibia_fx nail yn. race race. gender gender. date_ed date_c date9. weekday wkday. hr_to_surgery 5.1;
	keep patientid mechanism femur_fx tibia_fx nail race age gender date_ed date_c los date_of_surgery hr_to_surgery weekday iss;
run;

proc print;
where hr_to_surgery<0 or hr_to_surgery>500;
run;


PROC IMPORT OUT= WORK.post0 
            DATAFILE= "H:\SAS_Emory\Consulting\Robert Runner\SaturdayOR.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Post$A1:R95"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc freq data=post0 order=freq;
	tables Mechanism__GSW__MVA__MCA__fall__;
run;
*/

data post;
	set post0(rename=(Patient__=PatientID IM_nail_used_=Nail race=race0 male=gender date_of_surgery=date_s));
	date_ed=input(Date_presented_to_ED,date9.);
	date_c=input(D_C_date,date9.);
	date_of_surgery=mdy(scan(date_s, 1, '/'), scan(date_s, 2, '/'), scan(date_s, 3, '/'));
	weekday=weekday(date_ed);
	time_ed=input(arrival_time_in_ED__hrs_, time8.);
	time_s=input(surgical_incision_time__hrs_, time8.);
	hr_to_surgery=intck('day', date_ed, date_of_surgery)*24+intck('minute',time_ed,time_s)/60;
	los=intck('day',date_ed,date_c);
	if Mechanism__GSW__MVA__MCA__fall__="Fall"  then mechanism=1; 
		else if Mechanism__GSW__MVA__MCA__fall__="GSW"  then mechanism=2; 
		else if Mechanism__GSW__MVA__MCA__fall__="Assault"  then mechanism=3; 
		else if Mechanism__GSW__MVA__MCA__fall__="MVC"  then mechanism=4; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Mtrcycle"  then mechanism=7; 
		else if Mechanism__GSW__MVA__MCA__fall__="Struck"  then mechanism=8; 
		else if Mechanism__GSW__MVA__MCA__fall__="Bicycle"  then mechanism=9; 
		else if Mechanism__GSW__MVA__MCA__fall__="ATV"  then mechanism=10; 
		else if Mechanism__GSW__MVA__MCA__fall__="Animal"  then mechanism=11; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident / fell off truck"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian vs auto"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Sports"  then mechanism=12; 

	if race0="W" then race=1; else if race0="B" then race=2; else if race0="H" then race=3; else if race0="A" then race=4; else if race0="O" then race=4;
	if date_of_surgery=. then delete;
	format mechanism mechanism. femur_fx tibia_fx nail yn. race race. gender gender. date_ed date_c date_of_surgery date9. weekday wkday. hr_to_surgery 5.1;
	keep patientid mechanism femur_fx tibia_fx nail race age gender date_ed date_c los date_of_surgery hr_to_surgery weekday iss;
run;


proc print;
where hr_to_surgery<0 or hr_to_surgery>500;
run;

PROC IMPORT OUT= WORK.all_pre0 
            DATAFILE= "H:\SAS_Emory\Consulting\Robert Runner\All Trauma.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Pre$A1:P253"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 *DBDSOPTS="DBSASTYPE=('surgical_incision_time__hrs_'='CHAR(11)')"  ; 
RUN;

/*
proc contents;run;

proc freq data=post0 order=freq;
	tables Mechanism__GSW__MVA__MCA__fall__;
run;
*/

data all_pre;
	set all_pre0(rename=(Patient__=PatientID race=race0));
	date_ed=input(Date_presented_to_ED,date9.);
	date_c=input(D_C_date,date9.);
	weekday=weekday(date_ed);
	time_ed=input(arrival_time_in_ED__hrs_, time8.);
	time_s=input(surgical_incision_time__hrs_, time8.);
	hr_to_surgery=intck('day', date_ed, date_of_surgery)*24+intck('minute',time_ed,time_s)/60;
	los=intck('day',date_ed,date_c);
	if Mechanism__GSW__MVA__MCA__fall__="Fall"  then mechanism=1; 
		else if Mechanism__GSW__MVA__MCA__fall__="GSW"  then mechanism=2; 
		else if Mechanism__GSW__MVA__MCA__fall__="Assault"  then mechanism=3; 
		else if Mechanism__GSW__MVA__MCA__fall__="MVC"  then mechanism=4; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Mtrcycle"  then mechanism=7; 
		else if Mechanism__GSW__MVA__MCA__fall__="Struck"  then mechanism=8; 
		else if Mechanism__GSW__MVA__MCA__fall__="Bicycle"  then mechanism=9; 
		else if Mechanism__GSW__MVA__MCA__fall__="ATV"  then mechanism=10; 
		else if Mechanism__GSW__MVA__MCA__fall__="Animal"  then mechanism=11; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident / fell off truck"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian vs auto"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Sports"  then mechanism=12; 

	if Male="M" then gender=1; else if Male="F"  then gender=0;
	if race0="W" then race=1; else if race0="B" then race=2; else if race0="H" then race=3; else if race0="A" then race=4; else if race0="O" then race=4;
	if date_of_surgery=. then delete;
	if patientid in(3,63,66,114,224) then delete;
	format mechanism mechanism. race race. gender gender. date_ed date_c date_of_surgery date9. 
		   hr_to_surgery 5.1 time_ed time_s time8. weekday wkday.;
	keep patientid mechanism race age gender date_ed date_c los date_of_surgery hr_to_surgery weekday iss time_ed time_s;
run;

PROC IMPORT OUT= WORK.all_post0 
            DATAFILE= "H:\SAS_Emory\Consulting\Robert Runner\All Trauma.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Post$A1:P224"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;

proc freq data=post0 order=freq;
	tables Mechanism__GSW__MVA__MCA__fall__;
run;
*/

data all_post;
	set all_post0(rename=(Patient__=PatientID race=race0 surgical_incision_time__hrs_=time_s));
	date_ed=input(Date_presented_to_ED,date9.);
	date_c=input(D_C_date,date9.);
	weekday=weekday(date_ed);
	time_ed=input(arrival_time_in_ED__hrs_, time8.);
	hr_to_surgery=intck('day', date_ed, date_of_surgery)*24+intck('minute',time_ed,time_s)/60;
	los=intck('day',date_ed,date_c);
	if Mechanism__GSW__MVA__MCA__fall__="Fall"  then mechanism=1; 
		else if Mechanism__GSW__MVA__MCA__fall__="GSW"  then mechanism=2; 
		else if Mechanism__GSW__MVA__MCA__fall__="Assault"  then mechanism=3; 
		else if Mechanism__GSW__MVA__MCA__fall__="MVC"  then mechanism=4; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Mtrcycle"  then mechanism=7; 
		else if Mechanism__GSW__MVA__MCA__fall__="Struck"  then mechanism=8; 
		else if Mechanism__GSW__MVA__MCA__fall__="Bicycle"  then mechanism=9; 
		else if Mechanism__GSW__MVA__MCA__fall__="ATV"  then mechanism=10; 
		else if Mechanism__GSW__MVA__MCA__fall__="Animal"  then mechanism=11; 
		else if Mechanism__GSW__MVA__MCA__fall__="Accident / fell off truck"  then mechanism=5; 
		else if Mechanism__GSW__MVA__MCA__fall__="Pedestrian vs auto"  then mechanism=6; 
		else if Mechanism__GSW__MVA__MCA__fall__="Sports"  then mechanism=12; 

	if Male="M" then gender=1; else if Male="F"  then gender=0;
	if race0="W" then race=1; else if race0="B" then race=2; else if race0="H" then race=3; else if race0="A" then race=4; else if race0="O" then race=4;
	if date_of_surgery=. then delete;
	if patientid in(19,42) then delete;
	format mechanism mechanism. race race. gender gender. date_ed date_c date_of_surgery date9. hr_to_surgery 5.1 weekday wkday.;
	keep patientid mechanism race age gender date_ed date_c los date_of_surgery hr_to_surgery weekday iss;
run;


data sat;
	set pre post(in=A);
	if A then post=1; else post=0;
	format post post.;
run;

data run.sat;
	set sat;
run;

data truma;
	set all_pre all_post(in=A);
	if A then post=1; else post=0;
	format post post.;
run;

proc reg data=truma;
        model los = iss /stb spec;
		output out=wbh rstudent=r h=lev cookd=cd dffits=dffit;
		plot r.*p.;
run; quit;
/*
data tmp;
	set wbh;
	if r>10 then delete;
run;

proc univariate data=tmp plots plotsize=30;
  var r;
  qqplot r / normal(mu=est sigma=est);
run;
*/
