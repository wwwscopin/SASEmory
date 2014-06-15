%let path=H:\SAS_Emory\Data\;
proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples_Patient ID Samples for Anti-Flagellin.Anti-LPS.Flagellin Antibodies_Dr.Ziegler-Dr.Cole.xls"
	out=flg_lps2A dbms=excel replace; 
	sheet="Flagellin"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps2A;
	set flg_lps2A(keep= GLND_Code  Study_Day   OD_Values___650nm
	rename=(OD_Values___650nm=anti_flag_OD650nm));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps2A;
	set lab_flg_lps2A;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps2A; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples_Patient ID Samples for Anti-Flagellin.Anti-LPS.Flagellin Antibodies_Dr.Ziegler-Dr.Cole.xls"
	out=flg_lps2B dbms=excel replace; 
	sheet="LPS Limulus Test"; 
         GETNAMES=YES;
         MIXED=YES;
run;


data lab_flg_lps2B;
	set flg_lps2B(keep= GLND_Code  Study_Day  _0_min__exposure  _0_min__exposure__zero_value_  Difference_in_OD
	rename=(_0_min__exposure=Anti_LPS_OD30 _0_min__exposure__zero_value_=Anti_LPS_OD1 Difference_in_OD=Anti_LPS_OD_Diff));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps2B;
	set lab_flg_lps2B;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps2B; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples_Patient ID Samples for Anti-Flagellin.Anti-LPS.Flagellin Antibodies_Dr.Ziegler-Dr.Cole.xls"
	out=flg_lps2C dbms=excel replace; 
	sheet="Flagellin Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps2C;
	set flg_lps2C(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_flag_IgG __100_IgA=anti_flag_IgA  __100_IgM=anti_flag_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps2C;
	set lab_flg_lps2C;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps2C; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND Study Samples_Patient ID Samples for Anti-Flagellin.Anti-LPS.Flagellin Antibodies_Dr.Ziegler-Dr.Cole.xls"
	out=flg_lps2D dbms=excel replace; 
	sheet="LPS Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps2D;
	set flg_lps2D(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_lps_IgG __100_IgA=anti_lps_IgA  __100_IgM=anti_lps_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps2D;
	set lab_flg_lps2D;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps2D; by id day;run;

libname wbh "&path";


data wbh.lab_flg_lps2;
	merge lab_flg_lps2A lab_flg_lps2B lab_flg_lps2C lab_flg_lps2D; by id day;
run;

proc print data=wbh.lab_flg_lps2;run;


