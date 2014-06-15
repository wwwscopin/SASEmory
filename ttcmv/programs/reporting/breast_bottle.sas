options nodate nonumber papersize=("7" "8");

libname wbh "/ttcmv/sas/data";

proc format; 
	value gp 1="Always breast feeding"
				4="Bottle feeding only"
				2="Breast feeding to bottle feeding"
				3="Bottle feeding to breast feeding"
				;
run;


data bb0;
	merge wbh.bm_collection(in=A) wbh.comp_pat(in=B keep=id); by id; *plate019;
	keep id DFSEQ BreastMilkObtained;
	rename DFSEQ=day;
	if DFSEQ<=40;
	if A and B;
run;
proc sort; by id day;run;

proc freq; 
tables day*BreastMilkObtained;
run;

*ods trace on/label listing;
proc means;
class id;
var BreastMilkObtained;
ods output Means.Summary=feed(keep=id BreastMilkObtained_Mean rename=(BreastMilkObtained_Mean=avg));
run;
*ods trace off;

data bb;
	merge bb0 feed; by id;
	if first.id then bm0=BreastMilkObtained;
	if avg=1 then gp=1;
	if avg=0 then gp=4;	
	if 0<avg<1 then if bm0=1 then gp=2; else gp=3;	
	if first.id;
	format gp gp.;
run;

data wbh.feed;
	set bb;
run;

proc freq data=bb; 
tables gp;
ods output onewayfreqs=feeding(rename=(frequency=n percent=pct));
run;

/*
symbol1 i=j ci=blue value=circle h=0.5 w=1 repeat=200;  
axis1 	label=(f=zapf h=3 'Week' ) value=(f=zapf h=1.0) split="*" order= (7 14 21 28 40) minor=none offset=(0 in, 0 in);
axis2 	label=(f=zapf h=3 a=90 'Feeding') value=(f=zapf h=2) order= (0 1) minor=none ;

proc gplot;
	plot BreastMilkObtained*day=id/overlay haxis = axis1 vaxis = axis2  nolegend; 
run;
*/

data _null_;
	set  bb;
	call symput('n',compress(_n_));
run;

%put &n;

ods rtf file="feeding.rtf" style=journal bodytitle;
proc print data=feeding noobs label;
title "LBWIs Feeding Pattern (n=&n)";
var gp/style(data)=[just=left cellwidth=2in];
var n pct/style(data)=[just=center cellwidth=1.25in] style(header)=[just=center];
format pct 4.0;
label gp="Group"
		n="N"
		pct="Percent(%)"
		;
run;
ods rtf close;
