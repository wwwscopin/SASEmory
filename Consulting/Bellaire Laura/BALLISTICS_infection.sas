options orientation=portrait SPOOL;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Bellaire Laura\WITH DAYS FROM INJURY TO SURGERY_v2_to stats.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Data sheet$J1:K490"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents short varnum; run;
proc contents; run;
proc print;run;
proc freq; tables infection;r
un;
*/

proc format; 
 value yn 1="Yes" 0="No";
 value idx 0="0 Day" 1="1 Day" 2="2 Days" 3="3+ Days" 9="Never has a surgery";
 value index 1="0-1 Day" 2="2+ Days (Including 'Never has a surgery!')";
run;

data ball_infect;
	set temp;
	if _n_=1 then delete;
	if infection="N" then infect=0; else if infection="Y" then infect=1; else if infection="U" then infect=.; 

	if Days_from_Injury_to_1st_surgery=0 then day_idx=0;
		else if Days_from_Injury_to_1st_surgery=1 then day_idx=1;
		else if Days_from_Injury_to_1st_surgery=2 then day_idx=2;
		else if Days_from_Injury_to_1st_surgery>=3 then day_idx=3;
		else if Days_from_Injury_to_1st_surgery=. then day_idx=9;

	if day_idx in(0, 1) then day_index=1; else day_index=2;

	rename Days_from_Injury_to_1st_surgery=day_infect;
	format infect yn. day_idx idx. day_index index.;
run;

proc print;run;

%table(data_in=ball_infect, data_out=tab, gvar=infect, var=day_idx, type=cat, first_var=1, label="Days from Injury to 1st Surgery", title="Comparison between Infection or Not");
%table(data_in=ball_infect, data_out=tab, gvar=infect, var=day_index, type=cat,  label="Days from Injury to 1st Surgery");
%table(data_in=ball_infect, data_out=tab, gvar=infect, var=day_infect, type=con, last_var=1, label="Days from Injury to 1st Surgery");
