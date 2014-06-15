
options ls=120 orientation=portrait ;
*filename kim "monkey.xls" lrecl=1000;

PROC IMPORT OUT= WORK.TMP 
            DATAFILE= "H:\SAS_Emory\Consulting\Kim\Statistic Data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Data $'"; 
     GETNAMES=YES;
     MIXED=Yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

/*
proc contents short varnum;run;
*/

data monkey;
	set tmp;
	if Age_yr_<=11 then group=1; else group=2;
	rename Monkey_No_=id  Age_yr_=age_yr  Age_Mo_=age_mo   Weight_kg_=wt    Length_cm_=length  Disc_Height_Loss=dhl
	 Facet_Joint_Degeneration=fjd  Grade_of_Disc_Degeneration=gdd;
run;


proc npar1way data = monkey wilcoxon;
  class group;
  var dhl;
run;

proc glm data=monkey;
	class group;
	model gdd=group/solution;
run;

proc glm data=monkey;
	class group;
	model gdd=age_yr group/solution;
run;


proc npar1way data = monkey wilcoxon;
  class group;
  var gdd;
run;

proc glm data=monkey;
	class group;
	model fjd=group/solution;
run;

proc glm data=monkey;
	class group;
	model gdd=bmi group/solution;
run;

proc glm data=monkey;
	model fjd=bmi/solution;
run;

proc glm data=monkey;
	class group;
	model fjd=bmi group/solution;
run;


proc glm data=monkey;
	class group;
	model fjd=gdd group/solution;
run;

proc glm data=monkey;
	model fjd=gdd;
run;
