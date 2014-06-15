PROC IMPORT OUT= WORK.TEMP1 
            DATAFILE= "H:\SAS_Emory\Consulting\TateJordan\Rad exposure Excel.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents;run;

proc format; 
	value type 1="cervical" 2="lumbar" 3="hip";
	value norm 1="Yes" 0="No";
run;


data rad;
	set temp1;
	drop Quantity;
	rename category=type RAD_Time=time;
	format category  type. norm norm.;
	if category=3 then delete;
	if BMI>25 then norm=1; else if 0<BMI<=25 then norm=0;
	keep BMI RAD_Time GY Category norm;
run;
proc sort; by type; run;

proc means data=rad maxdec=4;
class type norm;
var gy;
output out=wbh;
run;
proc print;run;

proc means data=rad maxdec=4;
by type;
var gy;
run;

proc freq; 
	tables norm*type/chisq fisher;
run;


proc glm data=rad;
	class type norm;
 	model gy=norm type time norm*time type*time norm*type;
run;
/*
proc glmselect;
	class type norm;
 	model gy=norm|type|time @2/selection=stepwise;
run;
*/

proc power; 
   twosamplemeans test=diff 
   groupmeans = 1.27 | 3.98 
   stddev = 6.36
   groupweights=(1 5) 
   /*npergroup = . */
   ntotal=.
   power = 0.8; 
 run;

 proc power; 
   twosamplemeans test=diff 
   groupmeans = 1.27 | 3.98 
   stddev = 6.36
   groupweights=(1 5) 
   /*npergroup = . */
   ntotal=24
   power = .; 
 run;

 proc power; 
   twosamplemeans test=diff 
   groupmeans = 1.27 | 3.98 
   stddev = 6.36
   groupweights=(1 1) 
   /*npergroup = . */
   ntotal=.
   power = 0.8; 
 run;

 proc power; 
   twosamplemeans test=diff 
   groupmeans = 3.02 | 5.49 
   stddev = 7.45
   groupweights=(1 2) 
   /*npergroup = . */
   ntotal=.
   power = 0.8; 
 run;

 proc power; 
   twosamplemeans test=diff 
   groupmeans = 3.02 | 5.49 
   stddev = 7.45
   groupweights=(1 2) 
   /*npergroup = . */
   ntotal=.
   power =0.8; 
 run;

  proc power; 
   twosamplemeans test=diff 
   groupmeans = 3.02 | 5.49 
   stddev = 7.45
   groupweights=(1 1) 
   /*npergroup = . */
   ntotal=.
   power = 0.8; 
 run;
	
/*
proc glm;
	class type;
 	model gy=bmi type time type*time;
run;
*/

proc npar1way data=rad wilcoxon;
	class type;
 	var gy;
run;

proc npar1way data=rad wilcoxon;
	by type;
	class norm;
 	var gy;
run;
/*
proc sort  data=rad; by norm type;run;
proc npar1way data=rad wilcoxon;
	by norm;
	class type;
 	var gy;
run;
*/
proc corr data=rad pearson;
	var gy time;
run;
