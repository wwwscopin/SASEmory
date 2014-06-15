%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\Flag_LPS\GLND 10-2009 Ziegler_FLG_LPS.xls"
	out=flg_lps3A dbms=excel replace; 
	sheet="Anti-Flagellin"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps3A;
	set flg_lps3A(keep= GLND_Code  Study_Day   OD_Values___650nm
	rename=(OD_Values___650nm=anti_flag_OD650nm));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps3A;
	set lab_flg_lps3A;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;

proc sort data=lab_flg_lps3A; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND 10-2009 Ziegler_FLG_LPS.xls"
	out=flg_lps3B dbms=excel replace; 
	sheet="Anti-LPS Limulus Test"; 
         GETNAMES=YES;
         MIXED=YES;
run;
proc contents data=flg_lps3B;run;

data lab_flg_lps3B;
	set flg_lps3B(keep= GLND_Code  Study_Day   _Pre_Read_exposure  __min__exposure  Difference_in_OD
	rename=(_Pre_Read_exposure=Anti_LPS_OD1 __min__exposure=Anti_LPS_OD30 Difference_in_OD=Anti_LPS_OD_Diff));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
run; 

data lab_flg_lps3B;
	set lab_flg_lps3B;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps3B; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND 10-2009 Ziegler_FLG_LPS.xls"
	out=flg_lps3C dbms=excel replace; 
	sheet="Flagellin Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps3C;
	set flg_lps3C(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_flag_IgG __100_IgA=anti_flag_IgA  __100_IgM=anti_flag_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps3C;
	set lab_flg_lps3C;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps3C; by id day;run;

proc import datafile="&path.glndlab\Flag_LPS\GLND 10-2009 Ziegler_FLG_LPS.xls"
	out=flg_lps3D dbms=excel replace; 
	sheet="LPS Antibodies"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data lab_flg_lps3D;
	set flg_lps3D(keep= GLND_Code  Study_Day  __100_IgG  __100_IgA  __100_IgM
	rename=(__100_IgG=anti_lps_IgG __100_IgA=anti_lps_IgA  __100_IgM=anti_lps_IgM));
	id=COMPRESS(GLND_Code,"(-)")+0;
	day=Compress(Study_day, "day-")+0;
	if day=. then delete;
	drop Glnd_Code Study_day;
	if id>59999 then delete;
run; 

data lab_flg_lps3D;
	set lab_flg_lps3D;
	if id^=. then tmp=id;
	retain tmp;
	if id=. then id=tmp;
	drop tmp;
run;
proc sort data=lab_flg_lps3D; by id day;run;

libname wbh "&path";

data wbh.lab_flg_lps3;
	merge lab_flg_lps3A lab_flg_lps3B lab_flg_lps3C lab_flg_lps3D; by id day;
run;



	



