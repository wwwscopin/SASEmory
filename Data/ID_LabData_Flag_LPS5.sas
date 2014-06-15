%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler June2011.xls"
	out=flg_lps5A dbms=excel replace; 
	sheet="Anti-Flagellin"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;
proc print;run;

data lab_flg_lps5A;
	set flg_lps5A(keep= GLND_Code  Study_Day   OD_Values___650nm
	rename=(OD_Values___650nm=anti_flag_OD650nm));
	id=GLND_Code+0;
	day=Compress(Study_day, "day-")+0;
	if Study_day="baseline" then day=0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 
proc print;run;

data lab_flg_lps5A;
	set lab_flg_lps5A;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps5A; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler June2011.xls"
	out=flg_lps5B dbms=excel replace; 
	sheet="Anti-LPS Limulus Test"; 
         GETNAMES=YES;
         MIXED=YES;
run;
proc contents data=flg_lps5B;run;

data lab_flg_lps5B;
	set flg_lps5B(keep= GLND_Code  Study_Day   Pre_Read_exposure  __min__exposure  Difference_in_OD
	rename=(Pre_Read_exposure=Anti_LPS_OD1 __min__exposure=Anti_LPS_OD30 Difference_in_OD=Anti_LPS_OD_Diff));
	id=GLND_Code+0;
	day=Compress(Study_day, "day-")+0;
	if Study_day="baseline" then day=0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps5B;
	set lab_flg_lps5B;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps5B; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler June2011.xls"
	out=flg_lps5C dbms=excel replace; 
	sheet="Flagellin Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps5C;
	set flg_lps5C(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgA=anti_flag_IgA  __100_IgM=anti_flag_IgM));
	id=GLND_Code+0;
	day=Compress(Study_day, "day-")+0;
	if Study_day="baseline" then day=0;
	anti_flag_IgG=__100_IgG+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 
proc contents data=flg_lps5C;run;

data lab_flg_lps5C;
	set lab_flg_lps5C;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps5C; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler June2011.xls"
	out=flg_lps5D dbms=excel replace; 
	sheet="LPS Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps5D;
	set flg_lps5D(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_lps_IgG __100_IgA=anti_lps_IgA  __100_IgM=anti_lps_IgM));
	id=GLND_Code+0;
	day=Compress(Study_day, "day-")+0;
	if Study_day="baseline" then day=0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps5D;
	set lab_flg_lps5D;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps5D; by id day;run;

libname wbh "&path";

data wbh.lab_flg_lps5;
	merge lab_flg_lps5A lab_flg_lps5B lab_flg_lps5C lab_flg_lps5D; by id day;
run;

proc import datafile="&path.glndlab\Flag_LPS\Sample List FLAG April 2012-Results.xls"
	out=flg_lps60 dbms=excel replace; 
	sheet="Results$A2:L65"; 
         GETNAMES=YES;
         MIXED=YES;
run;
/*
proc contents;run;
proc print;run;
*/

data wbh.lab_flg_lps6;
	set flg_lps60(rename=(GLND_ID_Number=id));
	retain tmp;
	if id^=. then tmp=id;
	if id=. then id=tmp;

	if F3="Baseline" then day=0;
	else day=Compress(F3, "Day")+0;
	rename Flic__IgA=anti_flg_IgA Flic__IgG=anti_flg_IgG LPS__IgA=anti_LPS_IgA LPS__IgG=anti_LPS_IgG;
	drop tmp Comment;
run;


data wbh.flag_lps_ex;
	set  wbh.lab_flg_lps1 wbh.lab_flg_lps2 wbh.lab_flg_lps3 wbh.lab_flg_lps4 wbh.lab_flg_lps5 wbh.lab_flg_lps6;
		visit=day;
	if day not in(0 3 7 14 21 28) then
	if day>7 then visit=round(day/7)*7;
	else if day>=5 then visit=7;
	else visit=3;
run;

proc sort data=wbh.flag_lps_ex; by id day;run;
