%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\HSP\GLND HSP analysis Group 2.xls"
	out=HSP1 
	dbms=excel replace;
	sheet="HSP analysis";
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_hsp1;
	set hsp1;
	rename  Study_site=center  Date_sent=dt_sent
           HSP70__ng_ml_=hsp70_ng HSP27__pg_ml_=hsp27_pg group_2=sample_num;
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=compress(Study_day, "day-")+0;
run;

data lab_hsp1;
	set lab_hsp1(drop=GLND_Code Study_day);
	where hsp70_ng^=. or hsp27_pg^=.;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc import datafile="&path.\glndlab\hsp\HSP_group-3_GLND-2(1).xls"
	out=HSP2 
	dbms=excel replace;
	sheet="HSP group-3";
         GETNAMES=YES;
         MIXED=YES;
run;
data lab_hsp2;
	set hsp2;
	rename Study_site=center  Samples_Fedex_to_Dr__Wischmeyer_=dt_sent
           HSP70_ng_ml=hsp70_ng  HSP_25_pg_mL=hsp27_pg group_3=sample_num;
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=compress(Study_day, "day-")+0;
run;

data lab_hsp2;
	set lab_hsp2(drop=GLND_Code Study_day);
	where hsp70_ng^=. or hsp27_pg^=.;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc import datafile="&path.glndlab\hsp\GLND Group 4 HSP analysis.xls"
	out=HSP3 
	dbms=excel replace;
	sheet="Sheet1";
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_hsp3;
	set hsp3;
	rename Study_site=center  Samples_Fedex_to_Dr__Wischmeyer_=dt_sent
           HSP70_conc_corrected_for_dilutio=hsp70_ng HSP25=hsp27_pg group_4=sample_num;
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=compress(Study_day, "day-")+0;
	drop Collection_day;
run;

data lab_hsp3;
	set lab_hsp3(drop=GLND_Code Study_day);
	where hsp70_ng^=. or hsp27_pg^=.;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
	if dt_collect1="" then dt_collect=.;
run;

proc import datafile="&path.glndlab\hsp\GLND Group 5 HSP analysis.xls"
	out=HSP4 
	dbms=excel replace;
	sheet="Sheet1";
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_hsp4;
	set hsp4;
	rename HSP25_pg_mL=hsp27_pg  GROUP_5=sample_num;
	id=COMPRESS(GLND_Code)+0;
	day=compress(Study_day, "day-")+0;
	hsp70_ng=HSP70_conc_from_comp+0;
run;

data lab_hsp4;
	set lab_hsp4(drop=GLND_Code Study_day HSP70_conc_from_comp);
	where hsp27_pg^=.;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc contents;run;

proc import datafile="&path.glndlab\hsp\GLND Group 7 HSP analysis.xlsx"
	out=HSP5 
	dbms=excel replace;
	sheet="Sheet1$B4:E57";
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_hsp5;
	set hsp5;
	rename Total_HSP27=hsp27_pg
	Patient=id
	Draw_Day=day
	Total_HSP70=hsp70_ng;
run;
proc sort; by id day; run;


libname wbh "&path";

data wbh.hsp_ex;
	set lab_hsp1 lab_hsp2 lab_hsp3 lab_hsp4 lab_hsp5;
	visit=day;
	if day not in(0 3 7 14 21 28) then
	if day>7 then visit=round(day/7)*7;
	else if day>=5 then visit=7;
	else visit=3;
run;

proc sort data=wbh.hsp_ex;by id day; run;
proc print data=wbh.hsp_ex;run;
