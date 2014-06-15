options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\lab.sas";
libname brent "H:\SAS_Emory\RedCap";

proc print data=brent.lab;run;

proc format;
	value item
	1="HIV-1 RNA Viral Load(Enrollment)"
	2='1. HIV-1 RNA Viral Load'
	3='2. HIV-1 RNA Viral Load'
	4='3. HIV-1 RNA Viral Load'
	5='4. HIV-1 RNA Viral Load'
	6='5. HIV-1 RNA Viral Load'
	7='6. HIV-1 RNA Viral Load'
	8='7. HIV-1 RNA Viral Load'
	
	9="Absolute CD4 (Enrollment)"
	10='1. Absolute CD4 Count'
	11='2. Absolute CD4 Count'
	12='3. Absolute CD4 Count'
	13='4. Absolute CD4 Count'
	14='5. Absolute CD4 Count'
	15='6. Absolute CD4 Count'
	16='7. Absolute CD4 Count'
	;
	value idx 0="Control" 1="Case";
run;


data lab;
	set brent.lab(rename=(cd4_1=cd4_10 cd4_2=cd4_20 cd4_3=cd4_30 cd4_4=cd4_40 cd4_5=cd4_50 cd4_6=cd4_60 cd4_7=cd4_70));
	hran1=hiv_rna1+0;
	hran2=hiv_rna2+0;
	hran3=hiv_rna3+0;
	hran4=hiv_rna4+0;
	hran5=hiv_rna5+0;
	hran6=hiv_rna6+0;
	hran7=hiv_rna7+0;

	cd4_1=cd4_10+0;
	cd4_2=cd4_20+0;
	cd4_3=cd4_30+0;
	cd4_4=cd4_40+0;
	cd4_5=cd4_50+0;
	cd4_6=cd4_60+0;
	cd4_7=cd4_70+0;

	cd4_0=cd4_enroll+0;
	hran0=hiv_rna_enroll+0;

	if hran0<0 then hran0=.;
	if hran1<0 then hran1=.;
	if hran2<0 then hran2=.;
	if hran3<0 then hran3=.;
	if hran4<0 then hran4=.;
	if hran5<0 then hran5=.;
	if hran6<0 then hran6=.;
	if hran7<0 then hran7=.;

	if cd4_0<0 then cd4_0=.;
	if cd4_1<0 then cd4_1=.;
	if cd4_2<0 then cd4_2=.;
	if cd4_3<0 then cd4_3=.;
	if cd4_4<0 then cd4_4=.;
	if cd4_5<0 then cd4_5=.;
	if cd4_6<0 then cd4_6=.;
	if cd4_7<0 then cd4_7=.;

	format idx idx.;
run;

proc freq; 
tables idx;
ods output onewayfreqs=tmp;
run;
*ods trace off;
data _null_;
	set tmp;
	if idx=0 then call symput("n0", compress(Frequency));
	if idx=1 then call symput("n1", compress(Frequency));
run;
%let n=%eval(&n0+&n1);

%let varlist= hran0 hran1 hran2 hran3 hran4 hran5 hran6 hran7 cd4_0 cd4_1  cd4_2  cd4_3 cd4_4 cd4_5 cd4_6 cd4_7;
%log_med(lab, idx, &varlist);

data tab;
	length nfn nfy nft code0 $40 pv $7;
	set stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft));

	format item item.;	
run;

ods rtf file="lab_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control(Process with Log Transformation)";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left width=3in];
define code0/"." ;
define nft/"All patients*(n=&n)*Median[Q1-Q3],N";
define nfy/"Case*(n=&n1)*Median[Q1-Q3],N";
define nfn/"Control*(n=&n0)*Median[Q1-Q3],N";
define pv/"p value" group;
run;
ods rtf close; 
