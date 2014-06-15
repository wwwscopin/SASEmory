
options ls=120 orientation=portrait fmtsearch=(library) ;
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
%include "&path\vince_macro.sas";

/*
proc contents data=brent.crf;run;
proc contents data=brent.quest;run;
*/

data quest_cas;
	set brent.quest(where=(gp=1));
run;

data crf_tdf;
	set brent.crf(where=(gp=1));
	if arvs2="STAVUDINE" then d4t=1; else d4t=0;
	*if arvs="ABACAVIR" then delete;
	*if "3Aug2010"d<=start_cur_arv1<='17Mar2011'd or "3Aug2010"d<=start_cur_arv2<='17Mar2011'd or "3Aug2010"d<=start_cur_arv3<='17Mar2011'd;
	if "3Aug2010"d<=start_cur_arv3<='17Mar2011'd;
	*if "27Jul2010"d<=start_cur_arv3<='24Mar2011'd;
	format start_cur_arv3 date9.;
	id=compress(study_no, "CAS")+0;
run;

data crf;
	set brent.crf;
	id=compress(study_no, "CAS")+0;
run;

data temp;
	set crf_tdf;
	if gp=1 and d4t=1;
run;

proc freq; 
tables gp*d4t;
format gp idx. d4t d4t.;
run;

data tdf;
	merge brent.quest(where=(gp=1)) crf_tdf(keep=study_no d4t); by study_no;
run;

%let varlist=age;
%stat(tdf, d4t, &varlist);

%let varlist=gender;
%tab(tdf, d4t, demo, &varlist);

data quest_demo;
	length nfy nfn $50 pv $5 code0 $50 item0 $100;
	set stat(keep=item mean0 mean1 pv rename=(mean0=nfn mean1=nfy)) 
		demo(keep=item nfy nfn code pv in=A )
	;

	if A then item=item+1;
	if item in(2) then do; code0=put(code, gender.);  end;

run;

%macro data(dataset);
data tmp;
	set &dataset;
	%do i=3 %to 6;
		
		prearvs=arvs&i;
		if prearvs="-77" then prearvs=" ";
		i=&i;
		output;
	%end;
run;
%mend;

%data(crf_tdf);quit;


data xxx;
	set tmp;
	if prearvs^=" ";
run;

proc sort nodupkey out=wbh; by id; run;

data _null_;
	set wbh;
	call symput("n", compress(_n_));
run;

/*

data tmp;
	set tmp;
 	if prearvs^=" ";
run;

proc print data=tmp; 
var study_no prearvs tdf i;
run;
*/
proc freq data=tmp;
	tables prearvs*tdf/nocol nopercent out=prearv;
run;

data prearv;
	merge prearv(where=(tdf=0) rename=(count=count0)) prearv(where=(tdf=1) rename=(count=count1)); by prearvs;
	if prearvs=" " then delete;
run;

ods rtf file="D4T.rtf" style=journal bodytitle;
/*
proc report data=prearv nowindows headline spacing=1 split='*';
title1 h=3 "Pre ARVS Analysis Based on TDF";
title2 h=2 "Only those met conditions ID were included here (n=&n).";
column prearvs count0 count1;
define prearvs/"ARVS" style=[cellwidth=1.25in just=left asis=on];
define count0/"No TDF" style=[cellwidth=1.25in just=center asis=on];
define count1/"  TDF" style=[cellwidth=1.25in just=center asis=on];
run;
*/

proc print data=temp label;
title h=3 "ID listing during 08/03/2010-03/17/2011";
var study_no arvs2 start_cur_arv3 arvs3 arvs4 arvs5 arvs6 d4t;
label study_no="Study No"
	arvs2="Drug"
		arvs3="Pre Arvs1"
			arvs4="Pre Arvs2"
				arvs5="Pre Arvs3"
					arvs6="Pre Arvs4"
	start_cur_arv3="Start Date"
	d4t="D4T";
run;
/*
proc print data=crf label;
title "Melisa's listing";
where id in(042, 062, 075);
var study_no arvs2 start_cur_arv3 arvs3 arvs4 arvs5 arvs6;
label study_no="Study No"
	arvs2="Drug"
		arvs3="Pre Arvs1"
			arvs4="Pre Arvs2"
				arvs5="Pre Arvs3"
					arvs6="Pre Arvs4"
	start_cur_arv3="Start Date"
;
	format start_cur_arv3 date9.;
run;
*/
ods rtf close;
