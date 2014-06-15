
options orientation=portrait;
%include "tab_stat.sas";

PROC IMPORT OUT= WORK.temp 
            DATAFILE= "H:\SAS_Emory\Consulting\Todd Dane Christopher\Kslice tibia and femoral volume cleaned data.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="'master all$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
/*
proc contents;run;
proc print data=temp;run;
proc freq;
	tables knee gender;
run;
*/
proc format;
	value knee 1="Left" 2="Right";
	value gender 0="Female" 1="Male";
run;

data tf0;
	set temp(rename=(knee=knee0 gender=gender0));
	if knee0='L' then knee=1; else if knee0='R' then knee=2;
	if gender0='f' then gender=0; else if gender0='m' then gender=1;
	format knee knee. gender gender.;
	drop gender0 knee0;
	if gender=. then delete;
run;
proc sort; by gender;run;
/*
proc univariate data=tf0 plot;
	by gender;
	var age;
run;
*/
proc means data=tf0 n mean std Q1 median Q3 noprint;
	var age;
	output out=age Q1(age)=Q1_age median(age)=median_age Q3(age)=Q3_age;
run;
data _null_;
	set age;
	call symput ("Q1_age", put(Q1_age, 4.1));
	call symput ("median_age", put(median_age, 4.1));
	call symput ("Q3_age", put(Q3_age, 4.1));
run;

proc format;
	value age_group 1="Age<=&Q1_age(Q1)"  2="Age=&Q1_age(Q1)~&median_age(Median)"  3="Age=&median_age(median)~&Q3_age(Q3)"  4="Age>&Q3_age(Q3)";
	value age .="Overall";
run;

data tf;
	set tf0;
	if age<=&Q1_age then age_group=1;
	else if &q1_age<age<=&median_age then age_group=2;
	else if &median_age<age<=&Q3_age then age_group=3;
	else age_group=4;
	format age_group age_group.;
run;

/*
%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=Fem_Ph_V,type=con, label="Femoral Physis Volume ", first_var=1, title="Table: Comparison by Gender");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=Fem_Ph_V,type=con, label="Femoral Physis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=Fem_Ph_V,type=con, label="Femoral Physis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=Fem_Ph_V,type=con, label="Femoral Physis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=Fem_Ph_V,type=con, label="Femoral Physis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=Fem_Ep_V,type=con, label="Femoral Epiphysis Volume");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=Fem_Ep_V,type=con, label="Femoral Epiphysis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=Fem_Ep_V,type=con, label="Femoral Epiphysis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=Fem_Ep_V,type=con, label="Femoral Epiphysis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=Fem_Ep_V,type=con, label="Femoral Epiphysis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=L_F_Ep_V,type=con, label="Lateral Femoral Epiphysis Volume ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=L_F_Ep_V,type=con, label="Lateral Femoral Epiphysis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=L_F_Ep_V,type=con, label="Lateral Femoral Epiphysis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=L_F_Ep_V,type=con, label="Lateral Femoral Epiphysis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=L_F_Ep_V,type=con, label="Lateral Femoral Epiphysis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=M_F_Ep_V,type=con, label="Medial Femoral Epiphysis Volume ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=M_F_Ep_V,type=con, label="Medial Femoral Epiphysis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=M_F_Ep_V,type=con, label="Medial Femoral Epiphysis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=M_F_Ep_V,type=con, label="Medial Femoral Epiphysis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=M_F_Ep_V,type=con, label="Medial Femoral Epiphysis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_PE_Rat,type=con, decmax=2, label="Femur Physis to Epiphysis Ratio");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_PE_Rat,type=con,decmax=2, label="Femur Physis to Epiphysis Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_PE_Rat,type=con,decmax=2, label="Femur Physis to Epiphysis Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_PE_Rat,type=con,decmax=2, label="Femur Physis to Epiphysis Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_PE_Rat,type=con,decmax=2, label="Femur Physis to Epiphysis Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_ML_Rat,type=con, decmax=2, label="Femur Medial to Lateral Epiphysis Ratio");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_ML_Rat,type=con,decmax=2, label="Femur Medial to Lateral Epiphysis Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_ML_Rat,type=con,decmax=2, label="Femur Medial to Lateral Epiphysis Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_ML_Rat,type=con,decmax=2, label="Femur Medial to Lateral Epiphysis Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_ML_Rat,type=con,decmax=2, label="Femur Medial to Lateral Epiphysis Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=Tib_Ph_V,type=con, label="Tibia Physis Volume");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=Tib_Ph_V,type=con, label="Tibia Physis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=Tib_Ph_V,type=con, label="Tibia Physis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=Tib_Ph_V,type=con, label="Tibia Physis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=Tib_Ph_V,type=con, label="Tibia Physis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=Tib_Ep_V,type=con, label="Tibia Epiphysis Volume");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=Tib_Ep_V,type=con, label="Tibia Epiphysis Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=Tib_Ep_V,type=con, label="Tibia Epiphysis Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=Tib_Ep_V,type=con, label="Tibia Epiphysis Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=Tib_Ep_V,type=con, label="Tibia Epiphysis Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=L_T_Ep_V,type=con, label="Lateral Tibia epiphyseal volume ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=L_T_Ep_V,type=con, label="Lateral Tibia epiphyseal volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=L_T_Ep_V,type=con, label="Lateral Tibia epiphyseal volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=L_T_Ep_V,type=con, label="Lateral Tibia epiphyseal volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=L_T_Ep_V,type=con, label="Lateral Tibia epiphyseal volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=M_T_Ep_V,type=con, label="Medial Tibia epiphyseal volume");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=M_T_Ep_V,type=con, label="Medial Tibia epiphyseal volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=M_T_Ep_V,type=con, label="Medial Tibia epiphyseal volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=M_T_Ep_V,type=con, label="Medial Tibia epiphyseal volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=M_T_Ep_V,type=con, label="Medial Tibia epiphyseal volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_PE_Rat,type=con,decmax=2, label="Tibia physis to epiphysis ratio ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_PE_Rat,type=con,decmax=2, label="Tibia Physis to Epiphysis Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_PE_Rat,type=con,decmax=2, label="Tibia Physis to Epiphysis Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_PE_Rat,type=con,decmax=2, label="Tibia Physis to Epiphysis Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_PE_Rat,type=con,decmax=2, label="Tibia Physis to Epiphysis Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_ML_Rat,type=con,decmax=2, label="Tibia Medial to Lateral Epiphysis Ratio ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_ML_Rat,type=con,decmax=2, label="Tibia Medial to Lateral Epiphysis Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_ML_Rat,type=con,decmax=2, label="Tibia Medial to Lateral Epiphysis Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_ML_Rat,type=con,decmax=2, label="Tibia Medial to Lateral Epiphysis Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_ML_Rat,type=con,decmax=2, label="Tibia Medial to Lateral Epiphysis Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_Cart_V,type=con, label="Femur Cartilage Cap Volume ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_Cart_V,type=con, label="Femur Cartilage Cap Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_Cart_V,type=con, label="Femur Cartilage Cap Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_Cart_V,type=con, label="Femur Cartilage Cap Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_Cart_V,type=con, label="Femur Cartilage Cap Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_Cart_V,type=con, label="Tibial Cartilage Cap Volume ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_Cart_V,type=con, label="Tibia Cartilage Cap Volume for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_Cart_V,type=con, label="Tibia Cartilage Cap Volume for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_Cart_V,type=con, label="Tibia Cartilage Cap Volume for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_Cart_V,type=con, label="Tibia Cartilage Cap Volume for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_Epi_Wd,type=con, label="Width of Femur Epiphysis");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_Epi_Wd,type=con, label="Width of Femur Epiphysis for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_Epi_Wd,type=con, label="Width of Femur Epiphysis for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_Epi_Wd,type=con, label="Width of Femur Epiphysis for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_Epi_Wd,type=con, label="Width of Femur Epiphysis for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_Epi_Wd,type=con, label="Width of Tibia Epiphysis");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_Epi_Wd,type=con, label="Width of Tibia Epiphysis for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_Epi_Wd,type=con, label="Width of Tibia Epiphysis for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_Epi_Wd,type=con, label="Width of Tibia Epiphysis for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_Epi_Wd,type=con, label="Width of Tibia Epiphysis for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_Cart_W,type=con, label="Femur Cartilage Cap Width ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_Cart_W,type=con, label="Femur Cartilage Cap Width for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_Cart_W,type=con, label="Femur Cartilage Cap Width for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_Cart_W,type=con, label="Femur Cartilage Cap Width for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_Cart_W,type=con, label="Femur Cartilage Cap Width for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_Cart_W,type=con, label="Tibia Cartilage Cap Width ");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_Cart_W,type=con, label="Tibia Cartilage Cap Width for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_Cart_W,type=con, label="Tibia Cartilage Cap Width for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_Cart_W,type=con, label="Tibia Cartilage Cap Width for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_Cart_W,type=con, label="Tibia Cartilage Cap Width for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=F_CEWd_R,type=con, decmax=2,label="Femur Cartilage Cap width to Epiphysis width Ratio");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=F_CEWd_R,type=con,decmax=2, label="Femur Cartilage Cap width to Epiphysis width Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=F_CEWd_R,type=con,decmax=2, label="Femur Cartilage Cap width to Epiphysis width Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=F_CEWd_R,type=con,decmax=2, label="Femur Cartilage Cap width to Epiphysis width Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=F_CEWd_R,type=con,decmax=2, label="Femur Cartilage Cap width to Epiphysis width Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=T_CEWd_R,type=con,decmax=2, label="Tibia Cartilage Cap width to Epiphysis width Ratio");
%table(data_in=tf,where=(age_group=1),data_out=femur_tabia,gvar=gender,var=T_CEWd_R,type=con,decmax=2, label="Tibia Cartilage Cap width to Epiphysis width Ratio for Age<=&Q1_age(Q1)");
%table(data_in=tf,where=(age_group=2),data_out=femur_tabia,gvar=gender,var=T_CEWd_R,type=con,decmax=2, label="Tibia Cartilage Cap width to Epiphysis width Ratio for Age=&Q1_age(Q1)~&median_age(Median)");
%table(data_in=tf,where=(age_group=3),data_out=femur_tabia,gvar=gender,var=T_CEWd_R,type=con,decmax=2, label="Tibia Cartilage Cap width to Epiphysis width Ratio for Age=&median_age(median)~&Q3_age(Q3)");
%table(data_in=tf,where=(age_group=4),data_out=femur_tabia,gvar=gender,var=T_CEWd_R,type=con,decmax=2, label="Tibia Cartilage Cap width to Epiphysis width Ratio for Age>&Q3_age(Q3)");

%table(data_in=tf,data_out=femur_tabia,gvar=gender,var=knee,type=cat, label="Knee", last_var=1);
*/


/*
ods graphics on;
proc freq data=tf;
   tables gender*age_group / trend measures cl
          plots=freqplot(twoway=stacked);
   test smdrc;
   exact trend / maxtime=60;
run;
ods graphics off;

proc freq data=tf;
	tables age*gender;
run;

proc corr data=tf nomiss spearman;
   	var Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R;
	with age;
run;

proc corr data=tf nomiss plots(MAXPOINTS=100000)=matrix(histogram);
   	var Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R;
run;

proc univariate data=tf;
	histogram Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R/normal;
run;


proc sgscatter data=tf;
	*compare x=age y=(Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R)/reg ellipse=(type=mean) spacing=4 group=gender;
	plot (Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R)*(age) /pbspline group=gender;
run;

proc sgpanel data=tf;
  title "Scatter plot for Femur and Tibia";
  panelby gender / columns=2;
  reg x=age y=Fem_Ph_V / cli clm;
run;


proc sgplot data=tf;
	series x=age y=Fem_Ph_V/group=gender;
  	series x=age y=Fem_Ep_V/group=gender;
  	series x=age y=L_F_Ep_V/group=gender;
	series x=age y=M_F_Ep_V/group=gender;
run;

proc sgscatter data=tf;
	plot (Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat)*(age) /pbspline group=gender;
run;

proc sgscatter data=tf;
	plot (Tib_Ph_V Tib_Ep_V L_T_Ep_V M_T_Ep_V T_PE_Rat T_ML_Rat)*(age) /pbspline group=gender;
run;

proc sgscatter data=tf;
	plot (F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R)*(age) /pbspline group=gender;
run;

proc glm data=tf;
	class gender;
	model Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V 
	M_T_Ep_V T_PE_Rat T_ML_Rat F_Cart_V T_Cart_V F_Epi_Wd T_Epi_Wd F_Cart_W T_Cart_W F_CEWd_R T_CEWd_R=age gender age*gender/solution ss3;
	lsmeans gender/cl;
	*manova h=gender;
run;

proc insight data=tf;
  scatter Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V *
          Fem_Ph_V Fem_Ep_V L_F_Ep_V M_F_Ep_V F_PE_Rat F_ML_Rat Tib_Ph_V Tib_Ep_V L_T_Ep_V ;
run;

PROC INSIGHT data=tf;
FIT Fem_Ph_V=age;
dist Fem_Ph_V;
RUN;
quit;
*/

proc mixed data=tf;
	class gender;
	model Fem_Ph_V=age gender age*gender/solution;
	estimate "Female, slope" age 1 age*gender 1 0;
	estimate "Male, slope" age 1 age*gender 0 1;
	estimate "Compare slopes" age*gender 1 -1;
run;

proc mixed data =tf covtest;
	class gender age; 	
	model Fem_Ph_V=age gender age*gender/ solution ; 
	lsmeans gender age*gender/pdiff cl;
	ods output lsmeans = lsmean0;
	ods output Mixed.Diffs= diff0;
run;

data lsmean;
	set lsmean0(rename=(age=age0));
	age=age0+0;
run;


data lsmean_plot;
	set lsmean0(rename=(age=age0));
	age=age0+0;
	if gender=1 then age=age+0.2;
run;

data diff;
	set diff0(where=(age=_age));
	age=age+0;
run;

proc means data=tf n;
	class gender age;
	output out=wbh n(age)=n;
run;

data vw;
	retain age est0 est1 diff probt;
	length est0 est1 diff $20;
	merge lsmean(where=(gender=0) keep=gender age Estimate lower upper rename=(Estimate=Estimate0 lower=lower0 upper=upper0)) 
		  lsmean(where=(gender=1) keep=gender age Estimate lower upper rename=(Estimate=Estimate1 lower=lower1 upper=upper1))
		  wbh(where=(gender=0) keep=gender age n rename=(n=n0))
		  wbh(where=(gender=1) keep=gender age n rename=(n=n1))
		  diff(keep=age estimate lower upper Probt); by age;
		  est0=compress(put(estimate0, 5.2)||"["||put(lower0, 5.2)||"-"||put(upper0, 5.2))||"], "||compress(n0);
		  est1=compress(put(estimate1, 5.2)||"["||put(lower1, 5.2)||"-"||put(upper1, 5.2))||"], "||compress(n1);
		  diff=compress(put(estimate, 5.2)||"["||put(lower, 5.2)||"-"||put(upper, 5.2))||"]";
		  keep age est0 est1 diff probt;
		  format age age.;
		  Label est0="Estimate[95%CI],N *Female" est1="Estimate[95%CI],N *Male" diff="Difference" probt="p value" age="Age";
run;
ods rtf file="estimate.rtf" style=journal bodytitle ;
proc print data=vw noobs label split="*" ;
	title "Femoral Physis Volume";
	var age est0 est1 diff probt/style=[just=c];
run;
ods rtf close;

ods listing close;
ods graphics / reset width=600px height=400px imagename='vw' imagefmt=gif;
ods html file='vw.html' path='.'; 

proc sgplot data=lsmean_plot;
   scatter x=age y=estimate / group=gender yerrorlower=lower yerrorupper=upper   markerattrs=(symbol=circlefilled) name="scat";
   series x=age y=estimate / group=gender lineattrs=(pattern=solid);
   xaxis integer values=(0 to 16 by 1) label="Age";
   yaxis label="Femoral Physis Volume";
   keylegend "scat" / title="" border  location=inside across=1 position=topleft ;
run;

ods html close;
ods listing;
