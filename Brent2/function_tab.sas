options orientation=landscape nonumber nodate ;
%include "stat_macro.sas";
%include "H:\SAS_Emory\RedCap\RawData\function.sas";
libname brent "H:\SAS_Emory\RedCap";

proc format;
	value item
	1='Number of seconds for Trail A test'
	2='Number of seconds for Trail B test'
	3='Total Forward Score'
	4='Total Backwards Score'
	5='Karnofsky Score (%)'
	;
	value idx 0="Control" 1="Case";
run;


data func;
	set brent.func(rename=(trail_a=trail_a0 trail_b=trail_b0 tot_forward=tot_forward0 tot_back=tot_back0 karn_score=karn_score0));
	trail_a=trail_a0+0;
	trail_b=trail_b0+0;
	tot_forward=tot_forward0+0;
	tot_back=tot_back0+0;
	karn_score=karn_score0+0;
	format idx idx.;
	drop trail_a0 trail_b0 tot_forward0 tot_back0 karn_score0;
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


%let varlist= trail_a trail_b tot_forward tot_back karn_score ;
%stat(func, idx, &varlist);


data tab;
	length nfn nfy nft code0 $40 pv $7;
	set stat(keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft));

	format item item.;	
run;

ods rtf file="function_table.rtf" style=journal bodytitle startpage=never ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Comparison between Case and Control";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left width=4in];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"Case*(n=&n1)";
define nfn/"Control*(n=&n0)";
define pv/"p value" group;
run;
ods rtf close; 
