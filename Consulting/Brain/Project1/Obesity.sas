%let path=H:\SAS_Emory\Consulting\Brain\;
filename obe "&path.obesity knee OA database.xls";

PROC IMPORT OUT= obe 
            DATAFILE= obe 
            DBMS=EXCEL REPLACE;
     sheet="Sheet1"; 
     GETNAMES=NO;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data obe;
	set obe;
	if 2<=_n_<=11;
	VOS0=F10+0;
	IKDC0=F11+0;
	WOMAC_P0=F12+0;
	WOMAC_S0=F13+0;
	SF0=F14+0;
	VOS1=F23+0;
	IKDC1=F24+0;
	WOMAC_P1=F25+0;
	WOMAC_S1=F26+0;
	SF1=F27+0;
	voso=VOS1-VOS0;	IKDC=IKDC1-IKDC0; WOMAC_P=WOMAC_P1-WOMAC_P0; WOMAC_S=WOMAC_S1-WOMAC_S0;	SF=SF1-SF0;
	keep  voso VOS0 VOS1 IKDC IKDC0 IKDC1	WOMAC_P WOMAC_P0 WOMAC_P1 WOMAC_S WOMAC_S0 WOMAC_S1 SF SF0 SF1;
run;
proc print;run;

PROC TTEST;
  PAIRED VOS0*VOS1 IKDC0*IKDC1 WOMAC_P0*WOMAC_P1 WOMAC_S0*WOMAC_S1 SF0*SF1;
RUN;

proc univariate data = obe;
  var voso IKDC WOMAC_P WOMAC_S SF;
run;

