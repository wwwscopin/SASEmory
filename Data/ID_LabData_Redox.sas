%let path=H:\SAS_Emory\Data\;

proc import datafile="&path.glndlab\Redox\B572_GLND_TZ_Redox.xls"
	out=redox1  dbms=excel replace; 
	sheet="Data Summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data redox1;
	set redox1;
	CySS=input(F2, best5.);
	Cys=input(F3, best5.);
    CySGSH=input(F4, best5.);
	GSH=input(F5, best5.);
	GSSG=input(F6, best5.);
	GSSG_GSH=input(F7, best5.);
	CySS_Cys=input(F8, best5.);
	Total_GSH=input(F9, best5.);
	Total_CyS=input(F10, best5.);
	rename Sample_Set__B572=ID0;
	drop F2-F10;
run;

data lab_redox1;
	set redox1;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,3),2,2)+0;
	index= substr(scan(id0,4),1,1)+0;
	dt_run='01Apr10'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox1;by id day index;run;

proc import datafile="&path.glndlab\Redox\Redox.xls"
	out=redox2  dbms=excel replace; 
	sheet="Data Summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data redox2;
	set redox2;
	CySS=input(F2, best5.);
	Cys=input(F3, best5.);
    CySGSH=input(F4, best5.);
	GSH=input(F5, best5.);
	GSSG=input(F6, best5.);
	GSSG_GSH=input(F7, best5.);
	CySS_Cys=input(F8, best5.);
	Total_GSH=input(F9, best5.);
	Total_CyS=input(F10, best5.);
	rename Sample_Set__B476=ID0;
	drop F2-F10;
run;

data lab_redox2;
	set redox2;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,4),1,2)+0;
	index= substr(scan(id0,5),1,1)+0;
	dt_run='16Apr09'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox2;by id day index;run;


proc import datafile="&path.glndlab\Redox\B354_GLND_report 011608_Redox.xls"
	out=redox3  dbms=excel replace; 
	sheet="data summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;

data redox3;
	set redox3;
	CySS=input(F2, best5.);
	Cys=input(F3, best5.);
    CySGSH=input(F4, best5.);
	GSH=input(F5, best5.);
	GSSG=input(F6, best5.);
	GSSG_GSH=input(F7, best5.);
	CySS_Cys=input(F8, best5.);
	Total_GSH=input(F9, best5.);
	Total_CyS=input(F10, best5.);
	rename Sample_Set__B354_GLND=ID0;
	drop F2-F10;
run;


data lab_redox3;
	set redox3;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,3),2,2)+0;
	index= substr(scan(id0,4),1,1)+0;
	dt_run='06Jan08'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox3;by id day index;run;

proc import datafile="&path.glndlab\Redox\Redox GLND.xls"
	out=redox4  dbms=excel replace; 
	sheet="data summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;

data redox4;
	set redox4;
	CySS=input(F2, best5.);
	Cys=input(F3, best5.);
    CySGSH=input(F4, best5.);
	GSH=input(F5, best5.);
	GSSG=input(F6, best5.);
	GSSG_GSH=input(F7, best5.);
	CySS_Cys=input(F8, best5.);
	Total_GSH=input(F9, best5.);
	Total_CyS=input(F10, best5.);
	rename  Sample_Set__B389_GLND_Tom=ID0;
	drop F2-F10;
run;

proc print;run;

data lab_redox4;
	set redox4;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,3),2,2)+0;
	index= substr(scan(id0,4),1,1)+0;
	dt_run='03Jun08'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox4;by id day index;run;

*********************************************************************************************************************;

proc import datafile="&path.glndlab\Redox\B630_TZ(2).xls"
	out=redox5  dbms=excel replace; 
	sheet="data summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;

data redox5;
	set redox5;
	CySS=input(F2, best6.);
	Cys=input(F3, best6.);
    CySGSH=input(F4, best6.);
	GSH=input(F5, best6.);
	GSSG=input(F6, best6.);
	GSSG_GSH=input(F7, best6.);
	CySS_Cys=input(F8, best6.);
	Total_GSH=input(F9, best6.);
	Total_CyS=input(F10, best6.);
	rename  Sample_Set__=ID0;
	drop F2-F10;
run;

data lab_redox5;
	set redox5;
	if id0="REF!" then delete;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,3),2,2)+0;
	index= substr(scan(id0,4),1,1)+0;
	dt_run='17Dec10'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox5;by id day index;run;


proc import datafile="&path.glndlab\Redox\GLND Redox.xls"
	out=redox6  dbms=excel replace; 
	sheet="data summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

proc contents;run;

data redox6;
	set redox6;
	CySS=input(F2, best6.);
	Cys=input(F3, best6.);
    CySGSH=input(F4, best6.);
	GSH=input(F5, best6.);
	GSSG=input(F6, best6.);
	GSSG_GSH=input(F7, best6.);
	CySS_Cys=input(F8, best6.);
	Total_GSH=input(F9, best6.);
	Total_CyS=input(F10, best6.);
	rename  Sample_Set__=ID0;
	drop F2-F10;
run;

data lab_redox6;
	set redox6;
	if id0="REF!" then delete;
	if _n_>=6;
	id1=substr(id0,1,1)||substr(id0,3,4);
	id=input(id1,5.);
	day= substr(scan(id0,3),2,2)+0;
	index= substr(scan(id0,4),1,1)+0;
	dt_run='28Aug08'd;
	format dt_run date9. ;
	drop id0 id1;
	if id<10000 then delete;
run;

proc sort data=lab_redox6;by id day index;run;

proc import datafile="&path.glndlab\Redox\B649adj_GLND.XLS"
	out=redox7  dbms=excel replace; 
	sheet="data summary"; 
         GETNAMES=YES;
         MIXED=YES;
run;

data redox7;
	set redox7;
	CySS=input(F2, best6.);
	Cys=input(F3, best6.);
    CySGSH=input(F4, best6.);
	GSH=input(F5, best6.);
	GSSG=input(F6, best6.);
	GSSG_GSH=input(F7, best6.);
	CySS_Cys=input(F8, best6.);
	Total_GSH=input(F9, best6.);
	Total_CyS=input(F10, best6.);
	rename   Sample_Set__B649=ID0;
	drop F2-F10;
run;

data lab_redox7;
	set redox7;
	if id0="REF!" then delete;
	if _n_>=6;
	id=scan(id0,1)+0;
	day=compress(scan(id0,2),"Bbd")+0;
	if lowcase(substr(scan(id0,2),1,1))="b" then day=0;
	index= scan(id0,3)+0;
	dt_run='4May11'd;
	format dt_run date9. ;
	drop id0;
	if id<10000 then delete;
run;

proc sort data=lab_redox7;by id day index;run;

libname wbh "&path";
data wbh.redox_ex;
	set lab_redox1 lab_redox2 lab_redox3 lab_redox4 lab_redox5 lab_redox6 lab_redox7; by id day index;
	rename index=replicate GSSG_GSH=GSH_GSSG_redox Cyss_Cys=Cys_CySS_redox GSH=GSH_concentration
	GSSG=GSSG_concentration Cys=Cys_concentration CySS=CysSS_concentration;
	
	visit=day;
	if day not in(0 3 7 14 21 28) then
	if day>7 then visit=round(day/7)*7;
	else if day>=5 then visit=7;
	else visit=3;

run;

proc sort data=wbh.redox_ex; by id day;run;

proc print;run;
proc contents;run;
