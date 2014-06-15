
options ls=120 orientation=portrait nobyline;
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\CROI ABSTRACT- RESISTANCE DATA.xls" lrecl=1000;

PROC IMPORT OUT= rest0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 1$A1:CM83"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data rd1;
	set rest0;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id  F14=N_44 F33=N_118 F48=N_234 F49=N_236 F50=N_238 F51=N_318 F52=N_333
			F58=N_13 F61=N_23 F66=N_35;
run;

PROC IMPORT OUT= rest1 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="RESISTANCE DATA 2$A2:CW84"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data rd2;
	set rest1;
	rename STUDY_NUM=STUDY_no ID_NUMBER=id F24=N_44 F43=N_118  F58=N_234  F59=N_236  F60=N_238  F61=N_318  F62=N_333
			F68=N_13 F71=N_23  F76=N_35;
run;

proc compare data=rd2 compare=rd1 LISTCOMPVAR;run;

data rdA;
	length genotype $40 study_no $10 k65 $3;
	merge rd1(in=A) brent.quest(where=(gp=1)keep=gender STUDY_no gp); by STUDY_no;
	if k65='-77' then k65=" ";
	if A;
run;

data _null_;
	set rda;
	call symput("na", compress(_n_));
run;

data _null_;
	set rda(where=(k65=" "));
	call symput("ma", compress(_n_));
run;

data rdB;
	length genotype $40 study_no $10;
	merge rd2(in=A) brent.quest(where=(gp=1)keep=gender STUDY_no gp); by STUDY_no;
	if k65='-77' then k65=" ";
	if A;
run;

data brent.rd;
	length genotype $50;
	set rd1(in=A) rd2(in=B); 
	if A then idx=1; 
	if B then idx=2;
		if k65='-77' then k65=" ";
run;


proc freq; 
*by idx;
tables idx*k65;
run;

data _null_;
	set rdb;
	call symput("nb", compress(_n_));
run;

data _null_;
	set rdb(where=(k65=" "));
	call symput("mb", compress(_n_));
run;
%put &mb;

proc contents;run;
ods trace on/label listing;
proc freq; 
table gender*k65;
ods output Freq.Table1.crosstabFreqs=tab;
run;
ods trace off;

proc format;
	value gender 0="Male" 1="Female";
	value item 1="Gender";
	value group 1="Data 1" 2="Data 2";
run;

%macro tab(data, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &var*k65/chisq exact;
			ods output Freq.Table1.crosstabFreqs=tmp0;
			output out = p&i chisq exact;
		run;

		data p&i;
			set p&i;
			item=&i;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
			if pvalue^=. and pvalue<0.001 then pv='<0.001'; else pv=put(pvalue,5.3);

			keep item pvalue pv;
		run;

	data tmp;
		set tmp0;
		nf=frequency||"("||put(percent,4.1)||"%)";
		item=&i;
		if _type_=11;
		keep item &var nf;
		rename &var=code;
	run;

	proc transpose data=tmp out=temp; by item code; var nf;run;

	data tab&i;
		set temp;
		rename col1=K col2=KR col3=N col4=R;
		drop _name_;
	run;

	data tab&i;	
		merge tab&i p&i; by item;
		item0=put(item, item.); 
		code0=put(code, gender.);
		if not first.item then do; pv=" "; item0=" "; end;
	run;

	data &out;
		set &out tab&i; 
	run; 
	
   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=gender;
%tab(rda, resta, &varlist);
%tab(rdb, restb, &varlist);

data rest;
	set resta(in=A)  restb(in=B);
	if A then group=1; 
	if B then group=2;
	format group group.;
run;

ods rtf file="rest.rtf" style=journal bodytitle;
proc print data=rest(where=(group=1)) noobs label;
title1 "K65 Frequency Table (n=&na)";
title2 #byval(group);
by group;
id item0/style(data)=[just=Right] style(header)=[just=Right];
var code0 K R KR N pv/style=[width=1in just=center];
label item0="Item"
	  code0="."
	  pv="p value"
	 ;
format item item.;
run;
ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=1.0in RIGHTMARGIN=0.5in font_size=10pt}
* There are &ma patients with k65 'Not Applicable'!";
ods rtf close;
