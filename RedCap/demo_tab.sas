options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\demo.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	0="Age*Mean &pm Std [Q1-Q3],n"
	1='Gender'
	2='How do you describe your race/ethnicity?'
	3='If black, what is your ethnic group and/or nationality?'
	4='Which languages can you read? (choice=Zulu (1))'
	5='Which languages can you read? (choice=English (2))'
	6='Which languages can you read? (choice=Other (3))'
	7='Which languages can you read? (choice=Cannot read (4))'
	8='Which spoken languages do you understand? (choice=Zulu (1))'
	9='Which spoken languages do you understand? (choice=English (2))'
	10='Which spoken languages do you understand? (choice=Other (3))'
	11='Which languages do you speak? (choice=Zulu (1))'
	12='Which languages do you speak? (choice=English (2))'
	13='Which languages do you speak? (choice=Other (3))'
	14='Do you have any problems with the following? (choice=Hearing (1))'
	15='Do you have any problems with the following? (choice=Seeing (2))'
	16='Do you have any problems with the following? (choice=Voice (3))'
	17='Do you have any problems with the following? (choice=None (4))'
	;
	value gender 0='Male' 1='Female';
	value race 1='Black (1)' 2='Colored (2)' 	3='White (3)' 4='Indian (4)';
	value black_ethnicity 1='Zulu (1)' 2='Xhosa (2)' 	3='Malawian (3)' 4='Other (4)';
	value yn 0='No' 1='Yes';
	value idx 0="Control" 1="Case";
run;


data demo;
	set brent.demo;
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


%let varlist=age;
%stat(demo, idx, &varlist);


%let varlist=gender race black_ethnicity read1 read2 read3 read4 understand1 understand2 understand3 speak1 speak2 speak3 
	problem1 problem2 problem3 problem4;
%tab(demo, idx, tab, &varlist);




data tab;
	length nfn nfy nft code0 $40 pv $7;
	set stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=A)
		tab
		;
	if A then do; item=item-1; end;
	if item=1 then code0=put(code, gender.);	
	if item=2 then code0=put(code, race.);	
	if item=3 then code0=put(code, black_ethnicity.);	
	if item>=4 then code0=put(code, yn.);	

	format item item.;	
run;

ods rtf file="demo_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"Case*(n=&n1)";
define nfn/"Control*(n=&n0)";
define pv/"p value" group;
run;
ods rtf close;
