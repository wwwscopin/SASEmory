options ls=120 orientation=portrait nonumber nodate ;
%include "stat_macro.sas";
libname ravi "H:\SAS_Emory\Consulting\Ravi";

PROC IMPORT OUT= WORK.ravi1
            DATAFILE= "H:\SAS_Emory\Consulting\Ravi\Data Format.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="'Basic Data$'"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc format;
	value ny 0="No" 1="Yes";
	value gender 0="Female" 1="Male";
	value insur 0="Government"  1="Private";
	value type 0="TA" 1="GH";
	value tech 0="TA" 1="GH" 3="TA with wire";
run;

data fusion;
	set ravi1(rename=(gender=gender0 insurance=insurance0 smoking=smoking0));
	rename Days_in_Hospital_Stay=day_hosp Days_in_ICU=day_icu Follow_up__wks_=followup Tech_Type__0_is_TA__1_is_GH_=type
		Fused_per_ravi_on_Xray__wks_=xray_ravi Fused_per_ravi_on_CT__wks_=ct_ravi Fused_per_MD_on_Xray__wks_=xray_md Fused_per_MD_on_CT__wks_=ct_md;
	if gender0="F" then gender=0; else if gender0="M" then gender=1;
	if Insurance0="Government" then insurance=0; else if Insurance0="Private" then insurance=1;
	if smoking0="No" then smoking=0; else if smoking0="Yes" then smoking=1;

	xray_wk=max(of Fused_per_ravi_on_Xray__wks_, Fused_per_MD_on_Xray__wks_);
	CT_wk=max(of Fused_per_ravi_on_CT__wks_, Fused_per_MD_on_CT__wks_);

	keep Patient_ID age Days_in_Hospital_Stay Days_in_ICU Follow_up__wks_ Tech_Type__0_is_TA__1_is_GH_ Fused_per_ravi_on_Xray__wks_ Fused_per_MD_on_Xray__wks_
	Fused_per_ravi_on_CT__wks_ Fused_per_MD_on_CT__wks_ gender insurance smoking xray_wk ct_wk;

	format gender gender. insurance insur. smoking ny. Tech_Type__0_is_TA__1_is_GH type.;
run;
proc sort; by patient_id;run;


PROC IMPORT OUT= WORK.ravi2
            DATAFILE= "H:\SAS_Emory\Consulting\Ravi\Data Format.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="XR Measures$A1:F96"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
	

data xr;
	set ravi2;
	retain temp_id temp_type;
	if patient_id^=. then do; temp_id=patient_id; temp_type=Tech_Type; end;
	if patient_id=. then do; patient_id=temp_id; tech_type=temp_type; end;

	rename Angle__degrees_=angle  Distance__mm_=distance Time__wks_=wk tech_type=type; 
	keep patient_id Angle__degrees_ Distance__mm_ Time__wks_ Tech_Type; 
	format tech_type type.;
run;

proc sort; by patient_id;run;



PROC IMPORT OUT= WORK.ravi3
            DATAFILE= "H:\SAS_Emory\Consulting\Ravi\Data Format.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="cost$A1:E20"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
	

data cost;
	set ravi3;
	rename Tech_Type__0_is_TA__1_is_GH__3_i=tech;
	keep patient_id implant_cost Total_Cost Tech_Type__0_is_TA__1_is_GH__3_i;
	format Tech_Type__0_is_TA__1_is_GH__3_i tech.;
run;

proc sort; by patient_id;run;


*ods trace on/label listing;
proc freq data=fusion; 
	table type;
	ods output onewayfreqs=wbh;
run;
*ods trace off;

data _null_;
	set wbh;
	if type=0 then call symput("n0", compress(frequency));
	if type=1 then call symput("n1", compress(frequency));
run;

%let n=%eval(&n0+&n1);

%let varlist1=age day_hosp day_icu followup xray_wk ct_wk;
%stat(fusion,type,&varlist1);

%let varlist3=gender smoking insurance;
%tab(fusion,type,tab,&varlist3);
proc print;run;

proc format; 
	value item  1="Age, Mean &pm STD [IQR]"
			    2="Gender(%)"
			    3="Smoking (%)"
			    4="Insurance (%)"
				5="Days in Hospital"
			    6="Days in ICU"
			    7="Follow up (wks)"
			    8="Time to X-Ray Fusion"
			    9="Time to CT Fusion"
				10="Implant Cost"
				11="Total Cost"
			   ;
	 value dd 3=" " 6="6" 13="13" 26="26" 52="52" 104="104" 150=" ";
run;

data tab;
	length nfn nfy nft code0 $40;
	set stat(where=(item=1) keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
	    tab (where=(item in(1,2,3)) in=A) 
		stat(where=(item>1) in=B keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
		;
	if A then do; item=item+1; 
			if item=2 then code0=put(code, gender.); 
			if item=3 then code0=put(code, ny.); 
			if item=4 then code0=put(code, insur.); 
		end;
	if B then item=item+3;
run;

data tab;
	set tab; by item;
	if not first.item then do; pvalue=.; or=.; range=.; pv=" "; end;
run;


ods rtf file="tabA.rtf" style=journal bodytitle ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Table 1: Comparison between TA and GH group";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"Overall*(n=&n)";
define nfy/"GH*(n=&n1)";
define nfn/"TA*(n=&n0)";
define pv/"p value";
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
Wilcoxon Sum Rank test and Fisher Exact test were used for two group comparisons';

ods rtf close;


proc npar1way data=cost;
	class tech;
	var implant_cost total_cost;
run;

proc means data=cost;
	class tech;
	var implant_cost total_cost;
run;

proc means data=cost;
	var implant_cost total_cost;
run;



%macro mixed(data, varlist);

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );

	data tmp;
		set &data;
	run;

	proc sort nodupkey; by patient_id wk &var; run;


	proc mixed data =tmp empirical covtest;
	class type patient_id wk ; 	
	model &var= type wk type*wk/ solution ; 
	repeated wk / subject = patient_id type = cs;
	lsmeans type*wk type/pdiff cl ;

	ods output lsmeans = lsmeans_&i;
	ods output   Mixed.Tests3=p_&var;
run;

data p_&var;
	length effect $100;
	set p_&var;
	if effect="type" then effect="Tech Type";
		if effect="wk" then effect="Time(weeks)";
			if effect="type*wk" then effect="Interaction between Type and Time";
run;

data lsmeans_&var;
	set lsmeans_&i(where=(wk in(6,13,26,52,104)));
	if lower^=. and lower<0 then lower=0;
	wk1=wk*1.05;
run;


proc sort; by type wk;run;

DATA anno0; 
	set lsmeans_&var(where=(type=0));
	xsys='2'; ysys='2';  color='blue';
	X=wk1; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:


    	X=wk1*0.96; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=wk1*1.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;

  	X=wk1;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;


DATA anno1; 
	set lsmeans_&var(where=(type=1));
	xsys='2'; ysys='2';  color='red';
	X=wk; 	y=estimate; FUNCTION='MOVE'; when = 'A';  OUTPUT; * start at mean ;
	Y=lower; 	FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT; * draw down;
	LINK TIPS; * make bar;
	Y=upper;	FUNCTION='DRAW'; when = 'A'; line=1; size=1;  OUTPUT; * draw up; 
	LINK TIPS; * make bar;
	TIPS:
	

    	X=wk*0.96; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
		X=wk+1.05; FUNCTION='DRAW'; when = 'A'; line=1; size=1; OUTPUT;
	
  	X=wk;     FUNCTION='MOVE'; when = 'A';  OUTPUT;
  	return;
run;

data anno_&var;
	set anno0 anno1;
run;

data estimate_&var;
	merge lsmeans_&var(where=(type=0) rename=(estimate=estimate0 lower=lower0 upper=upper0)) 
	lsmeans_&var(where=(type=1) rename=(estimate=estimate1 lower=lower1 upper=upper1)) ; by wk;
run;

goptions reset=all  device=jpeg  gunit=pct noborder cback=white
colors = (black red)  ftext=Century  hby = 3;

symbol1 interpol=j mode=exclude value=dot co=red cv=red height=4 bwidth=1 width=1;
symbol2 i=j ci=blue value=circle co=blue cv=blue h=4 w=1;

axis1 	label=(f=Century h=3 "Weeks on Study" ) split="*"	value=(f=Century h=3)  order= (3, 6,13,26,52,104,150) minor=none offset=(0, 0);
legend across = 1 position=(top left inside) mode = share fwidth =.2	shape = symbol(3,2) label=NONE 
value = (f=Century h=2.5 "GH" "TA") offset=(0.2in, -0.2 in) frame;

%if &var=angle %then %do;
	axis2 	label=(f=Century h=3 a=90 "Angle (degrees)") value=(f=Century h=3) order= (0 to 5 by 0.5) offset=(-0.05, 0.05) minor=(number=1); 
	title 	height=3.5 f=Century "Angle vs Weeks on Study";
%end;

%if &var=distance %then %do;
	axis2 	label=(f=Century h=3 a=90 "Distance (mm)") value=(f=Century h=3) order= (0 to 2.4 by 0.2) offset=(-0.05, 0.05) minor=(number=1); 
	title 	height=3.5 f=Century "Distance vs Weeks on Study";
%end;

             
proc gplot data= estimate_&var gout=ravi.graphs;
	plot estimate1*wk estimate0*wk1/overlay annotate= anno_&var haxis = axis1 vaxis = axis2 legend=legend;

	%if &var=angle %then %do; 	format estimate0 estimate1 4.1; %end;
	%else %do; format estimate0 estimate1 4.2 ; %end;
	format wk dd.;
run;

%let i= %eval(&i+1);
%let var = %scan(&varlist,&i);
%put &var;
%end;
%mend mixed;



proc greplay igout=ravi.graphs  nofs; delete _ALL_; run;
goptions rotate = portrait;

%let varlist=angle distance;
*ods trace on/label listing;
%mixed(xr,&varlist); run;
*ods trace off;

ods pdf file = "trend.pdf" style=journal;
goptions reset=all border;
proc greplay igout=ravi.graphs tc=sashelp.templt nofs nobyline;
	template v2s;
	treplay 1:1 2:2;
quit; 
run; quit;
ods pdf close;
