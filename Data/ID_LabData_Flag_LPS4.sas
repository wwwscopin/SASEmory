%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler Nov.2010.xls"
	out=flg_lps4A dbms=excel replace; 
	sheet="Anti-Flagellin"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;
proc print;run;

data lab_flg_lps4A;
	set flg_lps4A(keep= GLND_Code  Study_Day   OD_Values___650nm
	rename=(OD_Values___650nm=anti_flag_OD650nm));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps4A;
	set lab_flg_lps4A;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps4A; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler Nov.2010.xls"
	out=flg_lps4B dbms=excel replace; 
	sheet="Anti-LPS Limulus Test"; 
         GETNAMES=YES;
         MIXED=YES;
run;
proc contents data=flg_lps4B;run;

data lab_flg_lps4B;
	set flg_lps4B(keep= GLND_Code  Study_Day   Pre_Read_exposure  __min__exposure  Difference_in_OD
	rename=(Pre_Read_exposure=Anti_LPS_OD1 __min__exposure=Anti_LPS_OD30 Difference_in_OD=Anti_LPS_OD_Diff));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps4B;
	set lab_flg_lps4B;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps4B; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler Nov.2010.xls"
	out=flg_lps4C dbms=excel replace; 
	sheet="Flagellin Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps4C;
	set flg_lps4C(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM );
	anti_flag_IgG=__100_IgG+0; anti_flag_IgA=__100_IgA+0;  anti_flag_IgM=__100_IgM+0;
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps4C;
	set lab_flg_lps4C;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps4C; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples for Dr.Ziegler Nov.2010.xls"
	out=flg_lps4D dbms=excel replace; 
	sheet="LPS Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps4D;
	set flg_lps4D(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM);
	anti_lps_IgG=__100_IgG+0; anti_lps_IgA=__100_IgA+0;  anti_lps_IgM=__100_IgM+0;
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps4D;
	set lab_flg_lps4D;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps4D; by id day;run;

libname wbh "&path";

data wbh.lab_flg_lps4;
	merge lab_flg_lps4A lab_flg_lps4B lab_flg_lps4C lab_flg_lps4D; by id day;
run;

proc contents;run;
proc print;run;
