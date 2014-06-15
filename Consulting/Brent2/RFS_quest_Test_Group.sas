
options ls=256 orientation=landscape fmtsearch=(library);
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
filename rfs1 "&path\CROI ABSTRACT- QUESTIONNAIRES.xls" lrecl=1000;
filename test "&path\Normative Scores for NC Test.xls" lrecl=1000;
 
proc format; 
value gender 0="Male" 1="Female";
value test 1="DSF" 2="DSB" 3="TMTA" 4="TMTB";
value group 1="18-29" 2="30-50" 3=">50";
value idx 0="NA" 1="MND/ANI" 2="HAD" 3="NA";
run;

PROC IMPORT OUT= nc0 
            DATAFILE= test  
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$A1:f17"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 TEXTSIZE=1024;
RUN;

data nc;
	set nc0(rename=(gender=gender0 Test=test0));
	rename 	 Normal__median_=normal_median  _SD=sd1  _SD0=sd2;
	if gender0='Male' then gender=0; else gender=1;
	if test0="DSF" then test=1;	else if test0="DSB" then test=2; else if test0="TMTA" then test=3;else 	if test0="TMTB" then test=4;
	if age_group="18-29" then group=1;	else if age_group="30-50" then group=2; 
	format gender gender. test test. group group.;
	drop gender0 test0;
run;

proc sort; by group gender; run;
proc print;run;	quit;

PROC IMPORT OUT= QUEST_con0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CONTROLS$A4:GM134"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 TEXTSIZE=1024;
	 *DBDSOPTS="DBSASTYPE=('dob'='CHAR(11)' 'WHI_DRUG'='CHAR(11)' 'other6'='CHAR(11)' 'other13'='CHAR(11)')" ; 
	 DBDSOPTS="DBSASTYPE=('WHI_DRUG'='CHAR(11)' 'other6'='CHAR(11)' 'other13'='CHAR(11)')" ; 
RUN;
proc contents;run;

data  quest_con;
	set quest_con0(rename=(other9=other_9 other14=other_14 other16=other_16 other18=other_18));
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);
	format dob mmddyy.;
	drop other_9 other_14 other_16 other_18;
run;

PROC IMPORT OUT= QUEST_case0 
            DATAFILE= rfs1  
            DBMS=EXCEL REPLACE;
     RANGE="CASES$A4:GM89"; 
     GETNAMES=YES;
     MIXED=yes;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
	 DBDSOPTS="DBSASTYPE=('name'='CHAR(11)' 'form'='CHAR(11)' 'route'='CHAR(11)' 'color'='CHAR(11)'  
		'reason'='CHAR(11)' 'where'='CHAR(11)' 'feel'='CHAR(11)' 'other4'='CHAR(11)' 'other7'='CHAR(11)')" ; 
RUN;

data  quest_case;
	set quest_case0(rename=(MONTH1=MONTH_1 other9=other_9 other14=other_14 other16=other_16 other18=other_18));
	MONTH1 =MONTH_1+0; 
	other9=put(other_9,7.0);
		other14=put(other_14,7.0);
			other16=put(other_16,7.0);
				other18=put(other_18,7.0);
	drop month_1 other_9 other_14 other_16 other_18;
run;

proc compare base=quest_con compare=quest_case LISTCOMPVAR; 
   title 'Comparison of Variables in Different Data Sets';
run; 

data  brent.quest;
	length  STUDY_NO_ $8 id_num $14 other other1-other20 $60 address $43 WHAT_WRK $40 WHAT_FIN $43 
			yes_date $22  WHAT_sup1 $19 which $29 CHR_DENO $47  WHAT_SUP $24  WHAT_TRE $38  SAFE_SEX $3 EMO_SUPP $21  RELAT $21 
			NO_WHY $77 DIFF_ARV $267  DIFF_HEA $230  DIFF_CLI $127  ADD_COMM $605 name $11 form $11 route $11 color $11  where $11 feel $11;
	set quest_con(in=a ) quest_case(in=b);
	if a then gp=0; 
	if b then gp=1;

	age=(date-dob)/365.25;
	
	prearv=pre_arv+0;
	safesex=safe_sex+0;
	if safe_sex='2a' then safesex=21;  
	if safe_sex='2b' then safesex=22; 

	if score>=20 then slevel=1; else slevel=0;
	if 	WHAT_WRK="-77" then WHAT_WRK="NA(-77)";
		if 	WHAT_FIN="-77" then WHAT_FIN="NA(-77)";
			if 	WHICH="-77" then WHICH="NA(-77)";
					if 	CHR_DENO="-77" then CHR_DENO="NA(-77)";
							if 	stop_arv="-77" then stop_arv="NA(-77)";
								if 	how_med="-77" then how_med="NA(-77)";
									if 	what_sup="-77" then what_sup="NA(-77)";
									if 	what_sup="-88" then what_sup="NA(-88)";
										if EMO_SUPP="-77" then EMO_SUPP="NA(-77)";
										if EMO_SUPP="-88" then EMO_SUPP="NA(-88)";
										if relat="-77" then relat="NA(-77)";
										if WHAT_SUP1="-77" then WHAT_SUP1="NA(-77)";
		if 18<=age<=29 then group=1; 
		if 30<=age<=50 then group=2; 
		else group=3;

	format _char_;
	informat _char_;
	rename  STUDY_NO_= STUDY_NO _forward=forward;
run;

proc sort; by group gender;run;

/*
proc print data=brent.quest;
where age <0;
var study_no date dob age;
run;

proc means data=brent.quest;
var age;
run;
*/

data test;
	merge brent.quest nc(where=(test=1) rename=(normal_median=norm1 sd1=sd1A sd2=sd2A))
		nc(where=(test=2) rename=(normal_median=norm2 sd1=sd1B sd2=sd2B))
		nc(where=(test=3) rename=(normal_median=norm3 sd1=sd1C sd2=sd2C))
		nc(where=(test=4) rename=(normal_median=norm4 sd1=sd1D sd2=sd2D)); by group gender;
	if sd2A<forward<=sd1A then x1=1;  else x1=0; if forward<=sd2A then y1=1;  else y1=0;
	if sd2B<backward<=sd1B then x2=1;  else x2=0; if backward<=sd2B then y2=1;  else y2=0;
	if sd1C<=TMT_A<sd2C then x3=1;  else x3=0; if TMT_A>=sd2C then y3=1;  else y3=0;
	if sd1D<=TMT_B<sd2D then x4=1;  else x4=0; if TMT_B>=sd2D then y4=1;  else y4=0;

	x=sum(x1, x2, x3, x4);y=sum(y1, y2, y3, y4);
	if y>=2 then idx=2; 
	else if (x>=2 and y<2) or (x=1 and y=1) then idx=1;
	else idx=0;

	format age 4.0 group group. idx idx.;
	if study_no=" " then delete;
run;

proc sort data=test; by study_no;run;

data brent.test;
	set test;
	keep study_no idx;
	if idx=0 then  idx=3;
run;


proc print data=test;
var study_no age group gender forward backward tmt_a tmt_b x y idx; 
run;
*ods trace on/label listing;
proc freq data=test; 
tables gp*idx/chisq fisher;
ods output crosstabfreqs=wbh;
ods output Freq.Table1.ChiSq=chq;
run;
*ods trace off;
proc print data=wbh;
where gp=0 and idx^=.;
run;

data _null_;
	set wbh;
	if gp=0 and idx=. then call symput("n0", compress(frequency));
		if gp=1 and idx=. then call symput("n1", compress(frequency));
			if gp=. and idx=. then call symput("n", compress(frequency));
run;

data _null_;
	length pv $6;
	set chq;
	pv=put(prob, 5.2); if prob<0.001 then pv="<0.001";
	if _n_=1 then call symput("pv", pv);
run;

proc sort data=wbh; by idx;run;

data tab;
	merge wbh(where=(gp=0 and idx^=.) rename=(frequency=n0)) 
		wbh(where=(gp=1 and idx^=.) rename=(frequency=n1)); by idx;
	
	f0=n0/&n0*100; f1=n1/&n1*100;
	col0=n0||"/&n0("||put(f0,5.1)||"%)";
	col1=n1||"/&n1("||put(f1,5.1)||"%)";
	pv=&pv;
	if _n_^=1 then pv=" ";
	keep idx n0 n1 f0 f1 col0 col1 pv;
run;

options orientation=portrait;
ods rtf file="test.rtf" style=journal bodytitle;
proc print data=tab noobs label;
title "Test Outcome";
id idx /style=[just=center cellwidth=1.25in];
var col0 col1 pv/style=[just=center cellwidth=1.25in];
label idx="Group"
	  col0="Control"
	  col1="Case"
	  pv="p value"
	  ;
run;
ods rtf close;
