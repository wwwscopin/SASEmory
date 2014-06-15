options orientation=portrait nodate nonumber nofmterr;
libname x "H:\SAS_Emory\Consulting\Joseph";

PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\Joseph\kslice saved and sorted data.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'master all$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc contents data=tmp short varnum;run;

data master;
	set tmp(rename=(gender=gender0));
	if gender0="f" then gender=0; else gender=1;
	if L_or_R="L" then LR=0; else LR=1;

	rfpe=fvp/fve;
	rfmle=vmef/vlef;
	rtpe=tpv/tve;
	rteml=mtev/ltev;
	rce=fcw/wfe;
	rteml=tcw/tew;

	rename  Femur_Cartilage_volume=fcv   Femur_Cartilage_width=fcw    Femur_M_L_epiphysis=fmle   Femur_Physis_Epiphysis=fpe
			Femur_volume_epiphysis=fve   Femur_volume_physis=fvp      Lateral_tibial_epiphyseal_volume=ltev  Medial_tibial_epiphyseal_volume=mtev
			Tibial_Cartilage_Cap=tcc	 Tibial_Cartilage_width=tcw   Tibial_Cartilagewidth_epiphyseal=tce   Tibial_Epiphysis_Volume=tev
 			Tibial_epiphysis_width=tew   Tibial_physis_epiphysis=tpe  Tibial_physis_volume=tpv   Volume_Lateral_Epiphysis_of_Femu=vlef
			Volume_Medial_Epiphysis_of_Femur=vmef  Width_of_Femur_epiphysis=wfe  _CartilageCapToEpiphysisXRatioF_=ratio  tibial_epiphysis_M_L=teml;

	drop gender0 l_or_r;
	*drop fpe fmle tpe teml ratio teml;
run;



proc format; 

value item 
	1="Femur volume physis"
	2="Femur volume epiphysis"
	3="Volume Lateral Epiphysis of Femu"
	4="Volume Medial Epiphysis of Femur"
	5="Ratio of Femur Physis to Epiphysis"
	6="Ratio of Femur M:L Epiphysis"
	7="Tibial physis volume"
	8="Tibial Epiphysis Volume"
	9="Lateral tibial epiphyseal volume"
	10="Medial tibial epiphyseal volume"
	11="Ratio of Tibial Physis to Epiphysis"
	12="Ratio of Tibial M:L Epiphysis"
	13="Femur Cartilage volume"
	14="Tibial Cartilage Cap"
	15="Width of Femur epiphysis"
	16="Tibial epiphysis width"
	17="Femur Cartilage width"
	18="Tibial Cartilage width"
	19="Ratio of CartilageCap to Epiphysis"
	20="Ratio of Tibial Cartilage width to Epiphyseal width"
;

value gender 0="Female" 1="Male";
value LR 0="Left" 1="Right";
run;
/*
proc univariate data=master plot; 
class gender;
var fvp fve vlef vmef fpe fmle tpv tev ltev mtev tpe teml fcv tcc wfe tew fcw tcw ratio tce; 
run;
*/

%macro test(data, gp, out, varlist);
data &out; if 1=1 then delete; run;
data &gp._outlier; if 1=1 then delete; run;

proc sort data=&data; by &gp; run;

%let i=1; 
%let var=%scan(&varlist, &i);
%do %while(&var NE);
	proc corr data=&data;
		by &gp;
		var &var age;
		ods output PearsonCorr=pc;
	run;
	
	data pc;
		set pc;
		if _n_ in(1,3);
		keep &gp age page;
	run; 

	proc reg data=&data;
		by &gp;
		model &var=age;
		ods output FitStatistics=fvp;
		output out=&gp.&var.res(keep=&gp &var age r lev cd dffit) rstudent=r h=lev cookd=cd dffits=dffit;
	run;



data outlier&i;
	set &gp.&var.res(keep=&gp &var age r lev cd dffit);
  	if &gp=0 then do;
		if abs(r)>2 then idx1=1; else idx1=0;
		if lev>(4/121) then idx2=1; else idx2=0; 
		if cd >(4/121) then idx3=1; else idx3=0;
		if abs(dffit)>(2*sqrt(1/121)) then idx4=1; else idx4=0;
	end;
	if &gp=1 then do; 
		if abs(r)>2 then idx1=1; else idx1=0;
		if lev>(4/133) then idx2=1; else idx2=0; 
		if cd >(4/133) then idx3=1; else idx3=0;
		if abs(dffit)>(2*sqrt(1/133)) then idx4=1; else idx4=0;
	end;
	idx=sum(of idx1 idx2 idx3 idx4);
	if idx>2;
	rename &var=variable;
	item=&i;
run;

data &gp._outlier;
	set &gp._outlier outlier&i;
run;

	data fvp1;
		set fvp;
		if _n_ in(1,4);
		keep &gp nvalue2;
		rename nvalue2=pv1;
	run;

	
	data fvp2;
		set fvp;
		if _n_ in(2,5);
		keep &gp nvalue2;
		rename nvalue2=pv2;
	run;

	data pc_fvp;
		merge pc fvp1 fvp2; by &gp;
		item=&i;
	run;

	data &out;
		length page0 $8;
		set &out pc_fvp;
		%if &gp=gender %then %do; format gender gender. item item. page pv1 pv2 7.4; %end;
		%if &gp=lr     %then %do; format lr lr. item item. page pv1 pv2 7.4; %end;
		if page<=0.0001 then page0="<0.0001"; else page0=put(page, 7.4);
	run;
	%let i=%eval(&i+1);
	%let var=%scan(&varlist, &i);
%end;
%mend test;
%let varlist=fvp fve vlef vmef fpe fmle tpv tev ltev mtev tpe teml fcv tcc wfe tew fcw tcw ratio tce;

%test(master, gender, ptab1, &varlist); quit;
*%test(master, lr,     ptab2, &varlist); quit;

proc sort data=gender_outlier; by item descending idx; run;
proc sort data=lr_outlier; by item descending idx; run;

ods rtf file="corr.rtf" style=journal bodytitle;
title "Person Correlation Coefficients by Gender";

proc report data=ptab1 nowindows headline spacing=1 split='*' style(column)=[just=right];
column item gender age page0 pv1 pv2;
define item/order format=item. "Variable" style=[just=left cellwidth=2.5in];
define gender/format=gender. "Gender" style=[cellwidth=.75in];
define age/"corr" style=[cellwidth=.75in];
define page0/"p value" style=[cellwidth=.75in];
define pv1/"R-Square" style=[cellwidth=.75in];
define pv2/"Adjust R-Square" style=[cellwidth=.75in];
run;

ods rtf startpage=never;
/*
title "Person Correlation Coefficients by Left/Right";
proc report data=ptab2 nowindows headline spacing=1 split='*' style(column)=[just=right];
column item lr age page0 pv1 pv2;
define item/order format=item. "Variable" style=[just=left cellwidth=2.5in];
define lr/format=lr. "Left/Right" style=[cellwidth=.75in];
define age/"corr" style=[cellwidth=.75in];
define page0/"p value" style=[cellwidth=.75in];
define pv1/"R-Square" style=[cellwidth=.75in];
define pv2/"Adjust R-Square" style=[cellwidth=.75in];
run;
*/

title "Outlier listing by Gender";
proc report data=gender_outlier nowindows headline spacing=1 split='*' style(column)=[just=center];
column item gender age variable r lev cd dffit idx;
define item/order format=item. "Variable" style=[just=left cellwidth=1in];
define variable/"Value" format=7.4 style=[cellwidth=.75in];
define gender/format=gender. "Gender" style=[cellwidth=.75in];
define age/"Age" style=[cellwidth=.75in];
define r /"rstu" format=7.4 style=[cellwidth=.75in];
define lev/"Leverage" format=7.4 style=[cellwidth=.75in];
define cd/"Cook' D" format=7.4 style=[cellwidth=.75in];
define dffit/"Dfits"  format=7.4 style=[cellwidth=.75in];
define idx/"Index" style=[cellwidth=.75in];
run;
/*
title "Outlier listing by Left/Right";
proc report data=lr_outlier nowindows headline spacing=1 split='*' style(column)=[just=center];
column item lr age variable r lev cd dffit idx;
define item/order format=item. "Variable" style=[just=left cellwidth=1in];
define variable/"Value" format=7.4 style=[cellwidth=.75in];
define lr/format=lr. "Gender" style=[cellwidth=.75in];
define age/"Age" style=[cellwidth=.75in];
define r /"rstu" format=7.4 style=[cellwidth=.75in];
define lev/"Leverage" format=7.4 style=[cellwidth=.75in];
define cd/"Cook' D" format=7.4 style=[cellwidth=.75in];
define dffit/"Dfits"  format=7.4 style=[cellwidth=.75in];
define idx/"Index" style=[cellwidth=.75in];
run;
*/
ods rtf close;

