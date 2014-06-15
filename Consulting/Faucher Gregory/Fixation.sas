PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Faucher Gregory\Stats.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A1:G25"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

proc format;
	value fix 0="Longitudinal" 1="Perpendicular";
	value tf  1="Fracture" 2="Screw unthread";
run;

data fix;
	set temp;
	if Fixation="Perpendicular" then fix=1; 
		else if Fixation="Longitudinal" then fix=0; 
	if  Type_of_failure="Fracture" then tf=1;
		else if  Type_of_failure="Screw unthread" then tf=2;

	screw=compress(Screw_size,'mm')+0;
	load=compress(Load_at_failure,'N')+0;
	load_screw=load/screw;
	if fix^=.;
	format fix fix. tf tf. load_screw 4.1;
run;
/*
proc print;
var fix screw load cycles load_screw;
run;
*/
proc means data=fix n mean std median min max maxdec=1;
	var screw load cycles load_screw;
run;

proc means data=fix n mean std median min max maxdec=1;
	class fix;
	var screw load cycles load_screw;
run;

proc npar1way data=fix wilcoxon;
	class fix;
	var screw load cycles load_screw;
run;

proc freq data =fix;
	tables fix*tf/nopercent nocol fisher;
run;
proc print data=fix;
	var load;
run;

proc sgplot data=fix;
	histogram load;
run;
	

proc power; 
   twosamplemeans test=diff 
   groupmeans = 294.3 | 278.1
   stddev = 93.3
   npergroup = . 
   power = 0.8; 
 run;

proc power; 
   twosamplemeans test=diff 
   groupmeans = 269.5 | 306
   stddev = 93.3
   npergroup = . 
   power = 0.8; 
run;
