options nodate nonumber papersize=("7" "8");

/*proc contents data=cmv.pda;run;*/

data pda;
	set cmv.pda;
	center=floor(id/1000000);
	format center center.;
	if ContMurmur=99 then ContMurmur=.;  
	if HyperPrecoidium=99 then HyperPrecoidium=. ; 
	if BoundPulses=99 then BoundPulses=. ;
	if WidePulsePressure=99 then WidePulsePressure=.;
	if PulVasulature=99 then PulVasulature=.;
	if CHF=99 then CHF=.; 
	if PosImgResult=99	 then PosImgResult=.;
	if IsPDAConfirmEcho=99  then IsPDAConfirmEcho=.;
	if IsPDAConfirmXray=99 then IsPDAConfirmXray=.;
	if PDAMeds=99  then PDAMeds=.;
	if PDASurgery=99 then PDASurgery=.;
	if PDALigation=99 then PDALigation=.;
run;

proc means data=pda noprint;
 class center;
 output out=pda_num n(center)=num;
run;

data pda_num;
	set pda_num(drop=_TYPE_ _FREQ_);
	if center=. then center=100;
run;

*******************************************************************;
** Looks no use, keep for time being ******************************;
proc sql;

create table enrolled as
select a.id  , LBWIDOB as DateOfBirth 
from 
cmv.Eligibility as a
left join

cmv.LBWI_Demo as b
on a.id =b.id


where IsEligible=1 ;

quit;

********************************************************************;


data all_pat;
	set cmv.endofstudy;
	where reason In (1,2,3,6);
	center=floor(id/1000000);
	format center center.;
run;

proc sort data=all_pat nodupkey; by id;run;


proc means data=all_pat noprint;
	class center;
	output out=all_pat n(center)=num;
run;

data all_pat;
	set all_pat(drop=_TYPE_ _FREQ_);
 	if center=.  then center=100;
run;

proc sql;
	create table pda_pat as 
	select pda_num.*, all_pat.num as num_tot, pda_num.num/num_tot*100 as pct format=4.0 
	from pda_num, all_pat
	where pda_num.center=all_pat.center
	;


data pda_pat;
	set pda_pat;
	list=strip(num)||"/"||strip(num_tot)||"("||strip(put(pct,5.1))||")";
	*if center=100 then	call symput("wbh", strip(num)||"/"||strip(num_tot)||"("||strip(put(pct,5.1))||"%)");
	if center=100 then	call symput("wbh", strip(num));
run;
 
data _null_;
	set pda_pat;
	if center=1 then call symput("Midtown",put(num,2.0));
	if center=2 then call symput("Grady",put(num,2.0));
	if center=3 then call symput("Northside",put(num,2.0));
	if center=100 then call symput("Total",put(num,2.0));
run;


proc transpose data=pda_pat out=pda_tab(drop=_NAME_);
	var list;
	id center;
run;

****************************************************************************;
*ods trace on/label listing;

ods output Freq.Table1.CrossTabFreqs=tab1(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table2.CrossTabFreqs=tab2(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table3.CrossTabFreqs=tab3(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table4.CrossTabFreqs=tab4(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table5.CrossTabFreqs=tab5(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table6.CrossTabFreqs=tab6(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table7.CrossTabFreqs=tab7(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table8.CrossTabFreqs=tab8(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table9.CrossTabFreqs=tab9(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table10.CrossTabFreqs=tab10(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table11.CrossTabFreqs=tab11(drop=table  _TYPE_  _TABLE_ Missing);
ods output Freq.Table12.CrossTabFreqs=tab12(drop=table  _TYPE_  _TABLE_ Missing);

proc freq data=pda;
	*by center;

	table (ContMurmur HyperPrecoidium BoundPulses WidePulsePressure PulVasulature CHF PosImgResult
	IsPDAConfirmEcho IsPDAConfirmXray PDAMeds PDASurgery PDALigation)*center/nocol norow;
run;

*ods trace off;

%macro tab(var,index);
data tab&index;
	set tab&index;
	item=&index;
	if center=. then center=100;
	if &var=. then &var=100;
	rename &var=code;
run;
%mend tab;

%tab(ContMurmur,1);
%tab(HyperPrecoidium,2);
%tab(BoundPulses,3);
%tab(WidePulsePressure,4);
%tab(PulVasulature,5);
%tab(CHF,6);
%tab(PosImgResult,7);
%tab(IsPDAConfirmEcho,8);
%tab(IsPDAConfirmXray,9);
%tab(PDAMeds,10);
%tab(PDASurgery,11);
%tab(PDALigation,12);

proc format;
value group 1="Clinical Diagnosis"
				2="Imaging Findings"
				3="Intervention"
				99=" "
		;

value item 1="Continuous Murmur"
				2="Hyperdynamic Precordium"
				3="Bounding Pulses"
				4="Wide Pulse Pressure"
				5="Increased Pulmonary Vasulature"
				6="Congestive Heart Failure"
				7="Positive Image Results"
				8="PDA Confirmed by Echocardiogram"
				9="PDA Confirmed by X-ray"
				10="Medication Given to Treat PDA"
				11="Surgery Performed"
				12="PDA Ligation Successful"
				99=" "
		;

value int 
				10="Drug Therapy Only for PDA"
				11="Surgery Closure of PDA"
				99="Not Treated Medically or Surgically"
		;
value code 1="Yes"
				0="No"
				2="No X-ray taken"
				99="Unknown"
				100="Overall"
		;
run;


data tab;
	set tab1 tab2 tab3 tab4 tab5 tab6 tab7 tab8 tab9 tab10 tab11 tab12;
	format item item. code code.;
run; 

proc sort data=tab; by item code;run;

proc transpose data=tab out=tab; by item code;run; 
data tab_A tab_B;
	set tab;
	where _name_^='center';
	rename COL1=Midtown COL2=Grady COL3=Northside COL4=Total;

	if _name_='Frequency' then output tab_A;
	if _name_='Percent' then output tab_B;
	drop _name_ _label_;
run;

%let n1_1= 0; %let n1_2= 0; %let n1_3= 0; %let n1_4= 0; %let n1_5= 0; %let n1_6= 0; 
		%let n1_7= 0; %let n1_8= 0; %let n1_9= 0; %let n1_10= 0;	%let n1_11= 0; %let n1_12= 0;

%let n2_1= 0; %let n2_2= 0; %let n2_3= 0; %let n2_4= 0; %let n2_5= 0; %let n2_6= 0; 
		%let n2_7= 0; %let n2_8= 0; %let n2_9= 0; %let n2_10= 0;	%let n2_11= 0; %let n2_12= 0;

%let n3_1= 0; %let n3_2= 0; %let n3_3= 0; %let n3_4= 0; %let n3_5= 0; %let n3_6= 0; 
		%let n3_7= 0; %let n3_8= 0; %let n3_9= 0; %let n3_10= 0;	%let n3_11= 0; %let n3_12= 0;

%let n_1= 0; %let n_2= 0; %let n_3= 0; %let n_4= 0; %let n_5= 0; %let n_6= 0; 
		%let n_7= 0; %let n_8= 0; %let n_9= 0; %let n_10= 0;	%let n_11= 0; %let n_12= 0;

%let m1_10= 0;	%let m1_11= 0; %let m2_10= 0;	%let m2_11= 0; %let m3_10= 0;	%let m3_11= 0; %let m_10= 0; %let m_11= 0; 

%macro total;

%do i=1 %to 12;
data _null_;
	set tab_A;
	where item=&i and code=100;
	call symput("n1_&i", compress(put(Midtown,3.0)));
	call symput("n2_&i", compress(put(Grady,3.0)));
	call symput("n3_&i", compress(put(Northside,3.0)));
	call symput("n_&i", compress(put(Total,3.0)));
run;
%end;

%do i=10 %to 11;
data _null_;
	set tab_A;
	where item=&i and code=1;
	call symput("m1_&i", compress(put(Midtown,3.0)));
	call symput("m2_&i", compress(put(Grady,3.0)));
	call symput("m3_&i", compress(put(Northside,3.0)));
	call symput("m_&i", compress(put(Total,3.0)));
run;
%end;

%mend;
%total; quit;

%put &n_1;


data tab_A;
	set tab_A;
	if item=1  then do;  Midtown0=&n1_1;  Grady0=&n2_1;  Northside0=&n3_1;  Total0=&n_1;  end;
	if item=2  then do;  Midtown0=&n1_2;  Grady0=&n2_2;  Northside0=&n3_2;  Total0=&n_2;  end;
	if item=3  then do;  Midtown0=&n1_3;  Grady0=&n2_3;  Northside0=&n3_3;  Total0=&n_3;  end;
	if item=4  then do;  Midtown0=&n1_4;  Grady0=&n2_4;  Northside0=&n3_4;  Total0=&n_4;  end;
	if item=5  then do;  Midtown0=&n1_5;  Grady0=&n2_5;  Northside0=&n3_5;  Total0=&n_5;  end;
	if item=6  then do;  Midtown0=&n1_6;  Grady0=&n2_6;  Northside0=&n3_6;  Total0=&n_6;  end;
	if item=7  then do;  Midtown0=&n1_7;  Grady0=&n2_7;  Northside0=&n3_7;  Total0=&n_7;  end;
	if item=8  then do;  Midtown0=&n1_8;  Grady0=&n2_8;  Northside0=&n3_8;  Total0=&n_8;  end;
	if item=9  then do;  Midtown0=&n1_9;  Grady0=&n2_9;  Northside0=&n3_9;  Total0=&n_9;  end;
	if item=10 then do;  Midtown0=&n1_10; Grady0=&n2_10; Northside0=&n3_10; Total0=&n_10; end;
	if item=11 then do;  Midtown0=&n1_11; Grady0=&n2_11; Northside0=&n3_11; Total0=&n_11; end;
	if item=12 then do;  Midtown0=&n1_12; Grady0=&n2_12; Northside0=&n3_12; Total0=&n_12; end;
run;



data int;
	length tmp_Midtown tmp_Grady tmp_Northside  tmp_Total $40;
	merge tab_A(rename=(Midtown=Midtown_num Grady=Grady_num Northside=Northside_num Total=Total_num)) tab_B; by item code;

	where item in (10,11);

	Midtown=Midtown_num/&Midtown*100;
	Grady=Grady_num/&Grady*100;
	Northside=Northside_num/&Northside*100;
	tmp_Midtown=Midtown_num||"/"||compress(put(&Midtown,3.0))||"("||put(Midtown,5.1)||"%)";
	tmp_Grady=Grady_num||"/"||compress(put(&Grady,3.0))||"("||put(Grady,5.1)||"%)";
	tmp_Northside=Northside_num||"/"||compress(put(&Northside,3.0))||"("||put(Northside,5.1)||"%)";
	tmp_Total=Total_num||"/"||compress(put(&Total,3.0))||"("||put(Total,5.1)||"%)";
	output;

	item=99; 
	Total_num=%eval(&Total-&m_10-&m_11);
	Midtown_num=%eval(&Midtown-&m1_10-&m1_11);
	Grady_num=%eval(&Grady-&m2_10-&m2_11);
	Northside_num=%eval(&Northside-&m3_10-&m3_11);

	Midtown=Midtown_num/put(&Midtown,3.0)*100;
	Grady=Grady_num/put(&Grady,3.0)*100;
	Northside=Northside_num/put(&Northside,3.0)*100;
	Total=Total_num/put(&Total,3.0)*100;
	tmp_Midtown=Midtown_num||"/"||compress(put(&Midtown,3.0))||"("||put(Midtown,5.1)||"%)";
	tmp_Grady=Grady_num||"/"||compress(put(&Grady,3.0))||"("||put(Grady,5.1)||"%)";
	tmp_Northside=Northside_num||"/"||compress(put(&Northside,3.0))||"("||put(Northside,5.1)||"%)";
	tmp_Total=Total_num||"/"||compress(put(&Total,3.0))||"("||put(Total,5.1)||"%)";
	output;

	format item int.;
run;

data int;
	set int;
	if _n_=4 then delete;
run;

data new_tab;
	length tmp_Midtown tmp_Grady tmp_Northside  tmp_Total $40;
	merge tab_A(rename=(Midtown=Midtown_num Grady=Grady_num Northside=Northside_num Total=Total_num)) tab_B; by item code;

	Midtown=Midtown_num/Midtown0*100;
	Grady=Grady_num/Grady0*100;
	Northside=Northside_num/Northside0*100;
	
	if Midtown=. then Midtown=0;
	if Grady=. then Grady=0;
	if Northside=. then Northside=0;

	tmp_Midtown=Midtown_num||"/"||compress(put(Midtown0,3.0))||"("||put(Midtown,5.1)||"%)";
	tmp_Grady=Grady_num||"/"||compress(put(Grady0,3.0))||"("||put(Grady,5.1)||"%)";
	tmp_Northside=Northside_num||"/"||compress(put(Northside0,3.0))||"("||put(Northside,5.1)||"%)";
	tmp_Total=Total_num||"/"||compress(put(Total0,3.0))||"("||put(Total,5.1)||"%)";


	if item in (1,2,3,4,5,6,7) then group=1;
	if item in (8,9) then group=2;
	if item in (10,11,12) then group=3;
	/*
	if item=12 then do;
		num_surgery=&tmp;
		Midtown=Midtown_num/num_surgery*100;
		Grady=Grady_num/num_surgery*100;
		Northside=Northside_num/num_surgery*100;
		Total=Total_num/num_surgery*100;

		tmp_Midtown=Midtown_num||"/"||strip(&tmp)||"("||compress(put(Midtown,5.1))||"%)";
		tmp_Grady=Grady_num||"/"||strip(&tmp)||"("||compress(put(Grady,5.1))||"%)";
		tmp_Northside=Northside_num||"/"||strip(&tmp)||"("||compress(put(Northside,3.1))||"%)";
		tmp_Total=Total_num||"/"||strip(&tmp)||"("||compress(put(Total,5.1))||"%)";

	end;
*/
run;

proc sort data=new_tab; by group item;run;

data new_tab;
	set new_tab; by group item;
	if not first.group then group=99;	
   if not first.item then item=99;
	format group group. item item.;
run;

** This is for age of PDA analysis ;
************************************************************;
data pat;
	set cmv.LBWI_Demo;
	keep id LBWIDOB;
run;

proc sql;
	create table pda_age as 
	select pda.id, center, PDADiagDate, LBWIDOB, PDADiagDate-LBWIDOB as age
	from pda, pat
	where pda.id=pat.id;

proc sort data=pda_age nodupkey; by id LBWIDOB; run;

proc means data=pda_age; 

class center;
var age;
output out=age n(age)=n mean(age)=mean median(age)=median min(age)=min max(age)=max;
run;

data age;
	set age;
	if center=. then center=8;
	keep center n mean median min max;
	format center center. mean 3.0;
run;

proc sort data=age; by center;run;

/*
ods rtf file="age.rtf" style=journal;
title "PDA Age Diagnosis";
proc print noobs label split="*" style(data) = [cellwidth=1in just=center];

var center/style(data) = [cellwidth=1in just=left];

var n/style(data) = [cellwidth=0.5in just=center];

var mean median min max;

label n='Num'
		center='Center'
		mean='Mean*(Day)'
		median='Median*(Day)'
		min='Min*(Day)'
		max='Max*(Day)'
;
run;

ods rtf close;
*/


ods rtf file = "&output./pda.rtf" style=journal startpage=no bodytitle;
title "Incidence of PDA";
proc print data=pda_tab noobs label style(data) = [just=center];

label Total='Overall(%)'
      Midtown='EUHM(%)'
      Grady='Grady(%)'
      Northside='Northside(%)'
;

run;


title "Age of PDA Diagnosis";
proc print noobs label split="*" style(data) = [cellwidth=1in just=center];

var center/style(data) = [cellwidth=1in just=left];
var n/style(data) = [cellwidth=0.5in just=center];
var mean median min max;

label n='Num'
		center='Center'
		mean='Mean*(Day)'
		median='Median*(Day)'
		min='Min*(Day)'
		max='Max*(Day)'
;
run;


title "Intervention for PDA";
proc print data=int noobs label split="*" style(data)=[just=left];
where code=1;
var item tmp_Total tmp_Midtown tmp_Grady  tmp_Northside;
label  tmp_Midtown="EUHM*(n=&Midtown)"
		  tmp_Grady="Grady*(n=&Grady)"
		  tmp_Northside="Northside*(n=&Northside)"
	    tmp_Total="Overall*(n=&Total)"
		 /*code="Results"*/
		 item="Item"
		;
run;




ods rtf startpage=yes;

title  "Summary of PDA Data (n=&wbh)";
proc print data=new_tab noobs label split="*" style(data)=[just=left];
*by group notsorted;
where code not in(99, 100);
*id group;
var group item code tmp_Total tmp_Midtown tmp_Grady  tmp_Northside;
label  tmp_Midtown="EUHM*(n=&Midtown)"
		  tmp_Grady="Grady*(n=&Grady)"
		  tmp_Northside="Northside*(n=&Northside)"
	    tmp_Total="Overall*(n=&Total)"
		 code="Results"
		 group="Section"
		 item="Item"
		;
run;

ods rtf close;

	
	



