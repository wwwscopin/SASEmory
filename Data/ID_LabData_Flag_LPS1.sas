%let path=H:\SAS_Emory\Data\;
proc import datafile="&path.glndlab\Flag_LPS\Copy of GLND Study Samples for Anti-Flagellin Anti-LPS Flagellin Antibodies_Dr Ziegler 08-2008 (2).xls"
	out=flg_lps1A dbms=excel replace; 
	sheet="Anti-Flagellin"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps1A;
	set flg_lps1A(keep= GLND_Code  Study_Day   OD_Values___650nm
	rename=(OD_Values___650nm=anti_flag_OD650nm));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps1A;
	set lab_flg_lps1A;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps1A; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\Copy of GLND Study Samples for Anti-Flagellin Anti-LPS Flagellin Antibodies_Dr Ziegler 08-2008 (2).xls"
	out=flg_lps1B dbms=excel replace; 
	sheet="Anti-LPS Limulus Test"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps1B;
	set flg_lps1B(keep= GLND_Code  Study_Day  _0_min__exposure  __min__exposure  Difference_in_OD
	rename=( _0_min__exposure=Anti_LPS_OD30 __min__exposure=Anti_LPS_OD1 Difference_in_OD=Anti_LPS_OD_Diff));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps1B;
	set lab_flg_lps1B;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps1B; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\Copy of GLND Study Samples for Anti-Flagellin Anti-LPS Flagellin Antibodies_Dr Ziegler 08-2008 (2).xls"
	out=flg_lps1C dbms=excel replace; 
	sheet="Flagellin Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps1C;
	set flg_lps1C(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_flag_IgG __100_IgA=anti_flag_IgA  __100_IgM=anti_flag_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps1C;
	set lab_flg_lps1C;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps1C; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\Copy of GLND Study Samples for Anti-Flagellin Anti-LPS Flagellin Antibodies_Dr Ziegler 08-2008 (2).xls"
	out=flg_lps1D dbms=excel replace; 
	sheet="LPS Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps1D;
	set flg_lps1D(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_lps_IgG __100_IgA=anti_lps_IgA  __100_IgM=anti_lps_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps1D;
	set lab_flg_lps1D;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps1D; by id day;run;

libname wbh "&path";
data wbh.lab_flg_lps1;
	merge lab_flg_lps1A lab_flg_lps1B lab_flg_lps1C lab_flg_lps1D; by id day;
run;

proc print data=wbh.lab_flg_lps1;run;



