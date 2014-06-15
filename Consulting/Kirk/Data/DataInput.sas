%let path=H:\SAS_Emory\Consulting\Kirk\Data\;
filename ppt "&path.RawData.xls";
*libname wbh "&path";
libname wbh "C:\Documents and Settings\bwu2\Desktop";
options fmtsearch=(wbh);

PROC IMPORT OUT= infection0 
            DATAFILE= ppt 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
proc format library=wbh; 
	value group
		1="Lung"
		2="Spleen"
	;
	
	value data
		1="Sham Treated Lungs"
		2="Gleevec Lo Lungs"
		3="Gleevec Hi Lungs"
		4="Sham Treated Spleen"
		5="Gleevec Lo Spleen"
		6="Gleevec Hi Spleen"
	;

	value t
		0="PREOP"
		1="6 WEEK"
		2="6 MONTH"
		3="1 YEAR"
		4="2 YEAR"
		;
run;


data wbh.infection;

	length id $6 status $10;
	set infection0(in=A keep=F1 F2 F3 rename=(F1=ID0 F2=status0 F3=CFU0)) 
		infection0(in=B keep=F4 F5 F6 rename=(F4=ID0 F5=status0 F6=CFU0))
		infection0(in=C keep=F7 F8 F9 rename=(F7=ID0 F8=status0 F9=CFU0))
		infection0(in=D keep=F10 F11 F12 rename=(F10=ID0 F11=status0 F12=CFU0))
		infection0(in=E keep=F13 F14 F15 rename=(F13=ID0 F14=status0 F15=CFU0))
		infection0(in=F keep=F16 F17 F18 rename=(F16=ID0 F17=status0 F18=CFU0))
	;
	if id0=" " or CFU0=" " then delete;
	id=compress(id0);

	status1=status0+0;
	if status1=. then status='Intact'; else status=put(status1-21916, mmddyy10.);

	CFU=CFU0+0;

	if A then do; data=1; group=1; end;
	if B then do; data=2; group=1; end;
	if C then do; data=3; group=1; end;
	if D then do; data=4; group=2; end;
	if E then do; data=5; group=2; end;	
	if F then do; data=6; group=2; end;

	data0=put(data, data.); group0=put(group, group.);
	*format data data. group group. CFU E8.;
	*drop id0 status0 status1 CFU0;
	format /*data data. group group.*/ CFU E8.;
	drop id0 status0 status1 CFU0 data group;
	label data0="Data" group0="Group";
run;
proc contents; run;
proc print label;run;

