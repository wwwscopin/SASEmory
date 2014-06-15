options orientation=portrait;
%let path=H:\SAS_Emory\Consulting\George\Nexgen Flex;
libname  george "&path";
%include "tab_stat.sas";

/*
filename surgy 	"&path.\Surgical Device Information.xls";
filename reg 	"&path.\Registry Completion.xls";
filename rad 	"&path.\Radiographic Evaluation.xls";
filename phys 	"&path.\Physical Exam.xls";
filename pat 	"&path.\Patient Questionnaire.xls";
filename opera 	"&path.\Operative Information.xls";
filename knee 	"&path.\Knee Assessment.xls";
filename postop	"&path.\Immediate Postoperative Evaluation.xls";
filename health "&path.\Health Status Questionnaire-SF36.xls";
filename demo 	"&path.\Demographic Evaluation.xls";
filename comp 	"&path.\Complications Report.xls";
*/
filename demo0 "&path.\demo.xls";
filename surgy0 "&path.\surgy.xls";
filename postop0 "&path.\postop.xls";
filename health0 "&path.\health.xls";
filename phys0 "&path.\phys.xls";
filename rad0 "&path.\rad.xls";

PROC IMPORT OUT= demo0 
            DATAFILE= demo0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:I279"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
*/
proc freq data=demo0;
	tables gender Preoperative_Diagnosis Operative_Side;
run;

proc format;
	value diag 1="OSTEOARTHRITIS" 2="RHEUMATOID ARTHRITIS" 3="POST-TRAUMATIC ARTHRITIS" 4="INFLAMMATORY ARTHRITIS" 5="AVASCULAR NECROSIS" 6="OTHER";
	value sex  0="Female" 1="Male";
	value side 1="Left" 2="Right";
	value type 0="LPS" 1="LPS FLEX";
	value cpe 0="PREOP" 1="6 Week" 2="6 Month" 3="1 Year" 4="2 Year";
	value apsl 0="None" 1="< 5mm" 2="5-10mm" 3="> 10mm";
	value tfa 1="VALGUS" 2="VARUS";
	value yn 0="No" 1="Yes";
	value atypea 0="--" 1="PCA PUMP";
	value atypeb 0="--" 1="EPIDURAL";
	value atypec 0="--" 1="MORPHINE";
	value atyped 0="--" 1="FEMORAL NERVE BLOCK";
	value item 1="Gender"
			   2="Patient Age"
			   3="Patient Height (Inch)"
			   4="Preoperative Diagnosis"
			   5="Analgesia Type 1"
			   6="Analgesia Type 2"
			   7="Analgesia Type 3"
			   8="Analgesia Type 4"
			   ;
	 value sidx 1="SF12(Mental)"
		 	    2="SF12(Physical)"
				3="Range Of Motion-Flexion"
				4="Range Of Motion-Extension"
				5="Weight"
				6="Records calcuated HSS Score"
				7="Records calculated KSS Score for function"
				8="Records calculated KSS Assessment score"
				;
	value tidx  1="A/P Stability/Laxity"
				2="Tibio-Femoral Alignment"
				3="Patella Tilt"
				4="Derived y/n for Skyline View Pat RL"
				5="Derives y/n for all RL LV Femur zones"
				6="Derives y/n for all RL LV Tibia zones"
				;
run;

data demo;
	set demo0;
	id=Case_ID+0;
	if Gender="MALE" then sex=1; else sex=0;
	if Preoperative_Diagnosis="OSTEOARTHRITIS" then diag0=1;
		else if Preoperative_Diagnosis="RHEUMATOID ARTHRITIS" then diag0=2;
		else if Preoperative_Diagnosis="POST-TRAUMATIC ARTHRITIS" then diag0=3;
		else if Preoperative_Diagnosis="INFLAMMATORY ARTHRITIS" then diag0=4;
		else if Preoperative_Diagnosis="AVASCULAR NECROSIS" then diag0=5;
		else if Preoperative_Diagnosis="OTHER" then diag0=6;

	if Operative_Side="LEFT" then side=1; else side=2;

	rename Calculated_Patient_Height_Inches=height_inch Calculated_Patient_Height_Cm=height_cm;
	format sex sex. diag0 diag. side side.;
	label diag0="Preoperative Diagnosis";
	keep id sex diag0 side Patient_Age Patient_height Calculated_Patient_Height_Inches Calculated_Patient_Height_Cm;
run;

proc sort nodupkey; by id; run;

PROC IMPORT OUT= surgy0 
            DATAFILE= surgy0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:B279"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
*/
proc freq data=surgy0;
	tables implant_Model;
run;

data surgy;
	set surgy0;
	id=Case_ID+0;

	if implant_Model="LPS FLEX" then type=1; else type=0;
	
	label type="Implant Model";
	format type type.;
	keep id type;
run;

proc sort nodupkey; by id; run;

PROC IMPORT OUT= postop0 
            DATAFILE= postop0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:E279"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
*/
proc freq data=postop0;
	tables Analgesia_Type_1 Analgesia_Type_2 Analgesia_Type_3 Analgesia_Type_4;
run;

data postop;
	set postop0;
	id=Case_ID+0;
	if Analgesia_Type_1="PCA PUMP" then atype1=1; else atype1=0;
	if Analgesia_Type_2="EPIDURAL" then atype2=1; else atype2=0;
	if Analgesia_Type_3="MORPHINE" then atype3=1; else atype3=0;
	if Analgesia_Type_4="FEMORAL NERVE BLOCK" then atype4=1; else atype4=0;
	keep id atype1-atype4;
	format atype1 atypea. atype2 atypeb.  atype3 atypec. atype4 atyped.;
run;

proc sort nodupkey; by id; run;


PROC IMPORT OUT= health0 
            DATAFILE= health0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:D1327"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
*/
proc freq data=health0;
	tables CPE_Name;
run;

data health;
	set health0;
	id=Case_ID+0;
	if CPE_Name="PREOP"            then do; cpe=0; t=0;   end;
		else if CPE_Name="6 WEEK"  then do; cpe=1; t=6;   end;
		else if CPE_Name="6 MONTH" then do; cpe=2; t=26;  end;
		else if CPE_Name="1 YEAR"  then do; cpe=3; t=52;  end;
		else if CPE_Name="2 YEAR"  then do; cpe=4; t=104; end;
	rename SF12_Mental_=mental SF12_Physical_=physical;
	drop CPE_Name;
	format cpe cpe.;
run;

proc sort nodupkey; by id cpe; run;


PROC IMPORT OUT= phys0 
            DATAFILE= phys0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:J1337"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents ;run;
*/
proc freq data=phys0;
	tables A_P_Stability_Laxity Tibio_Femoral_Alignment;
run;

data phys;
	set phys0;
	id=Case_ID+0;
	if CPE_Name="PREOP"            then do; cpe=0; t=0;   end;
		else if CPE_Name="6 WEEK"  then do; cpe=1; t=6;   end;
		else if CPE_Name="6 MONTH" then do; cpe=2; t=26;  end;
		else if CPE_Name="1 YEAR"  then do; cpe=3; t=52;  end;
		else if CPE_Name="2 YEAR"  then do; cpe=4; t=104; end;

	if A_P_Stability_Laxity="NONE" then apsl=0; 
		else if A_P_Stability_Laxity="< 5 MM" then apsl=1; 
			else if A_P_Stability_Laxity="5-10 MM" then apsl=2; 
				else if A_P_Stability_Laxity=">10 MM" then apsl=3; 

	if Tibio_Femoral_Alignment="VALGUS" then tfa=1; 
		else if Tibio_Femoral_Alignment="VARUS" then tfa=2; 
			
    rename Range_Of_Motion_Flexion=flexion Range_Of_Motion_Extension=extension Records_calcuated_HSS_Score=hss 
		   Records_calculated_KSS_Score_for=kss_func Records_calculated_KSS_Assessmen=kss_asses;

	label apsl="A_P_Stability_Laxity"
		  tfa="Tibio_Femoral_Alignment";

	
	drop CPE_Name;
	format cpe cpe. apsl apsl. tfa tfa.;
	keep id cpe t apsl tfa weight Range_Of_Motion_Flexion Range_Of_Motion_Extension Records_calcuated_HSS_Score Records_calculated_KSS_Score_for
		Records_calculated_KSS_Assessmen;
run;

proc sort nodupkey; by id cpe; run;


PROC IMPORT OUT= rad0 
            DATAFILE= rad0 
            DBMS=EXCEL REPLACE;
	 RANGE="Sheet1$A1:F1055"; 
     GETNAMES=Yes;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc contents short varnum;run;
*/
proc freq data=rad0;
	tables Patella_Tilt__yes_no_ Derived_y_n_for_Skyline_View_Pat Derives_y_n_for_all_RL_LV_Femur_ Derives_y_n_for_all_RL_LV_Tibia_ ;
run;

data rad;
	set rad0;
	id=Case_ID+0;
	if CPE_Name="PREOP"            then do; cpe=0; t=0;   end;
		else if CPE_Name="6 WEEK"  then do; cpe=1; t=6;   end;
		else if CPE_Name="6 MONTH" then do; cpe=2; t=26;  end;
		else if CPE_Name="1 YEAR"  then do; cpe=3; t=52;  end;
		else if CPE_Name="2 YEAR"  then do; cpe=4; t=104; end;

	if Patella_Tilt__yes_no_="NO" then pt=0;  else pt=1;
	if Derived_y_n_for_Skyline_View_Pat="NO" then svp=0; else svp=1;
	if Derives_y_n_for_all_RL_LV_Femur_="NO" then rlf=0; else rlf=1;
	if Derives_y_n_for_all_RL_LV_Tibia_="NO" then rlt=0; else rlt=1;

    drop CPE_Name;
	format cpe cpe. pt svp rlf rlt yn.;
	keep id cpe t pt svp rlf rlt;
	label pt="Patella Tilt"
		  svp="Derived y/n for Skyline View Pat"
		  rlf="Derives y/nfor all RL LV Femur"
		  rlt="Derives y/n for all RL LV Tibia";
run;

proc sort nodupkey; by id cpe; run;

data cpe;
	merge health phys rad; by id cpe;
	label id="CASE ID";
run;

data george.cpe;
	merge surgy cpe;by id;
run;
proc sort; by cpe id;run;

/*
proc sgscatter data=george.cpe;
  title "Scatterplot for variable: mental physical flexion extension weight hss kss_func kss_asses";
  *compare y=(mental physical flexion extension weight hss kss_func kss_asses)
		  x=(t);
	plot (mental physical flexion extension weight hss kss_func kss_asses)*t;
run;

proc mixed data=george.cpe;
	class id t type;
	model mental=t type t*type;
	repeated t/type=cs subject=id;
run;

proc mixed data=george.cpe;
	class id t type;
	model kss_asses=t type t*type;
	repeated t/type=cs subject=id;
run;
*/


data george.nexgen;
	merge demo surgy postop; by id;
	label id="CASE ID";
run;

*ods trace on/label listing;
proc freq data=george.nexgen; 
	table type;
	ods output onewayfreqs=wbh;
run;
*ods trace off;

data _null_;
	set wbh;
	if type=1 then call symput("n1", compress(frequency));
	if type=0 then call symput("n0", compress(frequency));
run;

%let n=%eval(&n0+&n1);


%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=sex,type=cat, first_var=1, label="Gender", title="Table1: Comparisons between LPS and LPS-Flex");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=patient_age,type=con, label="Age");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=height_inch,type=con, label="Height (Inch)");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=diag0,type=cat, label="Preoperative Diagnosis");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=atype1,type=cat, label="Analgesia Type 1");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=atype2,type=cat, label="Analgesia Type 2");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=atype3,type=cat, label="Analgesia Type 3");
%table(data_in=george.nexgen,data_out=nexgen,gvar=type,var=atype4,type=cat, last_var=1, label="Analgesia Type 4", prn=1);


%macro cpe(data=, cpe=0);
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=mental,type=con, first_var=1, label="SF12(Mental)", title="Table2: Comparisons between LPS and LPS-Flex by CPE");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="SF12(Physical)");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Range Of Motion-Flexion");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Range Of Motion-Extension");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Weight");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Records calcuated HSS Score");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Records calculated KSS Score for function");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=stat&cpe,gvar=type,var=physical,type=con, label="Records calculated KSS Assessment score");

%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=apsl,type=cat, first_var=1, label="A/P Stability/Laxity", title="Table2: Comparisons between LPS and LPS-Flex by CPE");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=tfa,type=cat, label="Tibio-Femoral Alignment");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=pt,type=cat, label="Patella Tilt");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=svp,type=cat, label="Derived y/n for Skyline View Pat RL");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=rlf,type=cat, label="Derives y/n for all RL LV Femur zones");
%table(data_in=george.cpe,where=cpe=&cpe, data_out=ctab&cpe,gvar=type,var=rlt,type=cat, label="Derives y/n for all RL LV Tibia zones");
%mend cpe;
%cpe(data=george.cpe, cpe=0);
%cpe(data=george.cpe, cpe=1);
%cpe(data=george.cpe, cpe=2);
%cpe(data=george.cpe, cpe=3);
%cpe(data=george.cpe, cpe=4);
data stat;
	 set stat0(in=A) stat1(in=B) stat2(in=C) stat3(in=D) stat4(in=E);
	 if A then cpe=0; if B then cpe=1;  if C then cpe=2; if D then cpe=3;  if E then cpe=4;
	 format cpe cpe.;
run;

data cpe_tab;
	 set ctab0(in=A) ctab1(in=B) ctab2(in=C) ctab3(in=D) ctab4(in=E);
 	 if A then cpe=0; if B then cpe=1;  if C then cpe=2; if D then cpe=3;  if E then cpe=4;
	 format cpe cpe.;
run;



ods rtf file="cpe_stat.rtf" style=journal bodytitle ;
proc report data=stat nowindows style(column)=[just=center] split="*";
title "Comparisons between LPS and LPS-Flex by CPE";
column cpe row col1-col3 pv;
define cpe/"CPE" order order=internal format=cpe. style=[just=left];
define row/"Characteristic" style(column)={asis=on just=l width=2in};
define col1/"Overall*(n=&n)";
define col2/"LPS-FLEX*(n=&n1)";
define col3/"LPS*(n=&n0)";
define pv/"p value" ;
run;
ods rtf close;

ods rtf file="cpe_tab.rtf" style=journal bodytitle ;
proc report data=cpe_tab nowindows style(column)=[just=center] split="*";
title "Comparisons between LPS and LPS-Flex by CPE";
column cpe row col1-col3 pv;
define cpe/"CPE" order order=internal format=cpe. style=[just=left];
define row/"Characteristic" style(column)={asis=on just=l width=2in};
define col1/"Overall*(n=&n)";
define col2/"LPS-FLEX*(n=&n1)";
define col3/"LPS*(n=&n0)";
define pv/"p value" ;
run;
ods rtf close;
