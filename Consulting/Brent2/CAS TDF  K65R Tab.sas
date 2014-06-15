
options ls=120 orientation=portrait fmtsearch=(library) nonumber nodate ;
libname library "H:/SAS_Emory/Consulting/Brent2";		
%let path=H:\SAS_Emory\Consulting\Brent2;
libname brent "&path";
%include "&path\stat_macro.sas";

/*
proc contents data=brent.crf;run;
proc contents data=brent.quest;run;
proc contents data=brent.tdf;run;
*/

data quest_cas;
	set brent.quest(where=(gp=1));
run;

data crf_tdf;
	set brent.crf(where=(gp=1));
	if arvs2="TENOFOVIR" or arvs2="TRUVADA" then tdf=1; else tdf=0;
	if arvs="ABACAVIR" then delete;
	if arvs2="STAVUDINE" then d4t=1; else d4t=0;
	*if "3Aug2010"d<=start_cur_arv1<='17Mar2011'd or "3Aug2010"d<=start_cur_arv2<='17Mar2011'd or "3Aug2010"d<=start_cur_arv3<='17Mar2011'd;
	*if "3Aug2010"d<=start_cur_arv3<='17Mar2011'd;
	*if "27Jul2010"d<=start_cur_arv3<='24Mar2011'd;
	format start_cur_arv3 date9.;
	if gp=1 then id=compress(study_no, "CAS")+0;
	*if gp=0 then id=compress(study_no, "CON")+0;
	if id=14 then do; tdf=0; d4t=1; end;
run;

data brent.tdf;
	set crf_tdf;
	keep id study_no tdf d4t arvs2 start_cur_arv3 gp;
run;


data tdf;
	merge brent.quest(drop=other) brent.crf(drop=other) brent.tdf(keep=study_no tdf d4t in=A ) brent.kidx;by study_no;
	if A;
	if cd4<0  then cd4=.;
	if cd41<0 then cd41=.;
	if cd42<0 then cd42=.;
	if cd43<0 then cd43=.;
	if cd44<0 then cd44=.;
	if cd45<0 then cd45=.;

	if vl  in("-77", "-88", "-99")  then vl =" ";
	if vl1 in("-77", "-88", "-99")  then vl1=" ";
	if vl2 in("-77", "-88", "-99")  then vl2=" ";
	if vl3 in("-77", "-88", "-99")  then vl3=" ";
	if vl4 in("-77", "-88", "-99")  then vl4=" ";
	if vl5 in("-77", "-88", "-99")  then vl5=" ";


	if num_epis   in(-77, -88, -99)  then num_epis  =.;
	if num_epis1  in(-77, -88, -99)  then num_epis1 =.;
	if num_epis2  in(-77, -88, -99)  then num_epis2 =.;
	
	
	if arvs='EFAVIRENZ' then efv=1; else efv=0;

	if 0  <=cd4<=49   then ncd=0;
	if 50 <=cd4<=99   then ncd=1;
	if 100<=cd4<=199  then ncd=2;
	if 200<=cd4<=349  then ncd=3;
	if 350<=cd4		  then ncd=4;


	if 400  <=vl0<=4999   then nvl=0;
	if 5000 <=vl0<=29999  then nvl=1;
	if 30000<=vl0<=99999  then nvl=2;
	if 100000<=vl0		  then nvl=3;


	start_date2=min(of start_23-start_26);
	if start_date2=. then start_date2=start_22;

	if tdf then  do;
		if arvs3="TENOFOVIR" then 	do; tdf_date1=start_23; if 0<stop_23-start_23<14 then tdf_date1=.; end;
		if arvs4="TENOFOVIR" then 	do; tdf_date2=start_24; if 0<stop_24-start_24<14 then tdf_date2=.; end;
		if arvs5="TENOFOVIR" then 	do; tdf_date3=start_25; if 0<stop_25-start_25<14 then tdf_date3=.; end;
		if arvs6="TENOFOVIR" then 	do; tdf_date4=start_26; if 0<stop_26-start_26<14 then tdf_date4=.; end;
		tdf_date5=start_22;
		start_date1=min(tdf_date1,tdf_date2,tdf_date3,tdf_date4,tdf_date5);
	end;

	if d4t then do;
		if arvs3="STAVUDINE" then 	do; d4t_date1=start_23; if 0<stop_23-start_23<14 then d4t_date1=.; end;
		if arvs4="STAVUDINE" then 	do; d4t_date2=start_24; if 0<stop_24-start_24<14 then d4t_date2=.; end;
		if arvs5="STAVUDINE" then 	do; d4t_date3=start_25; if 0<stop_25-start_25<14 then d4t_date3=.; end;
		if arvs6="STAVUDINE" then 	do; d4t_date4=start_26; if 0<stop_26-start_26<14 then d4t_date4=.; end;
		d4t_date5=start_22;
		start_date1=min(d4t_date1,d4t_date2,d4t_date3,d4t_date4,d4t_date5);
	end;

	if "3Aug2010"d<=start_date1<='17Mar2011'd;


	nday1=(date-start_date1)/30.42;
	nday2=(date-start_date2)/30.42;

	naids=sum(of num_epis, num_epis1, num_epis2);

	if diag_dis="TB" or diag_dis1='TB' or diag_dis2='TB'  then TB=1; else TB=0;
	if diag_dis="CRYPTOCOCCUS" or diag_dis1='CRYPTOCOCCUS' or diag_dis2='CRYPTOCOCCUS'  then cryp=1; else cryp=0;
	if diag_dis="HSV" or diag_dis1='HSV' or diag_dis2='HSV'  then HSV=1; else HSV=0;
	if diag_dis="KS" or diag_dis1='KS' or diag_dis2='KS'  then KS=1; else KS=0;
	if diag_dis="TOXO" or diag_dis1='TOXO' or diag_dis2='TOXO'  then TOXO=1; else TOXO=0;

	if study_no="CAS 107" then  do; K65="R"; kidx=1; end;
	if study_no="CAS 109" then  do; K65="R"; kidx=1; end;

	keep study_no tdf d4t age gender date12 arvs efv cd4 ncd cd41 cd42 cd43 cd44 cd45  vl vl1 vl2 vl3 vl4 vl5 vl0 start_22-start_26 start_date1 start_date2 date nday1 nday2 nvl
		start_22-start_26 arvs1-arvs6 num_epis num_epis1 num_epis2 naids diag_dis diag_dis1 diag_dis2 TB cryp HSV KS TOXO kidx k65; 
	format start_22-start_26 start_date2 date date9.;
run;
ods listing;

proc print data=tdf;
var study_no tdf d4t kidx k65 arvs3-arvs6;
run;

*ods trace on/label listing;
proc freq; 
	table kidx;
	ods output onewayfreqs=wbh;
run;
*ods trace off;
data _null_;
	set wbh;
	if kidx=0 then call symput("n0", compress(frequency));
	if kidx=1 then call symput("n1", compress(frequency));
run;

%let n=%eval(&n0+&n1);

proc print data=tdf;
var study_no num_epis num_epis1 num_epis2 naids;
run;

%let varlist1=age nday1 nday2 cd4 vl0 naids;
%stat(tdf,kidx,&varlist1);

proc print;run;

%let varlist2=gender efv ncd nvl;
%tab(tdf,kidx,tab,&varlist2);
proc print;run;

*%let varlist3=diag_dis diag_dis1 diag_dis2;
%let varlist3=TB cryp HSV KS TOXO;
%tab(tdf,kidx,tabB,&varlist3);
proc print;run;


proc format; 
	value item  1="Age, Mean &pm SEM [IQR]"
			    2="Women(%)"
			    3="EFV(%)"
			    4="Median duration of ART (months) [IQR] by TDF/D4T*"
				5="Median duration of ART (months) [IQR]*"
			    6="Median CD4 count at virologic failure (cells/ul) [IQR]"
			    7="CD4 cell count category (%)"
			    8="Median plasma viral load at virologic failure (copies/ml) [IQR]"
			    9="Viral load category (copies/ml) (%)"
			    10="Prior AIDS-defining illness"
				11="TB"
				12="KS"
				13="HSV"
				14="TOXO"
				15="CRYPTOCOCCUS"
			   ;
	value ncd   0="0-49 cells/ul"
				1="50-99 cells/ul"
				2="100-199 cells/ul"
				3="200-349 cells/ul"
				4=">350 cells/ul"
				;

	value nvl   0="400-4,999"
				1="5,000-29,999"
				2="30,000-99,999"
				3="> 100,000"
				;
run;

data tab;
	length nfn nfy nft code0 $40;
	set stat(where=(item=1) keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
	    tab (where=(item in(1,2)) in=A) 
		stat(where=(item in(2,3,4)) in=B keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft))
		tab (where=(item in(3))   in=C) 
		stat(where=(item=5) keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=D)
		tab (where=(item in(4))   in=E) 
		stat(where=(item=6) keep=item mean0 mean1 mean9 pv rename=(mean0=nfn mean1=nfy mean9=nft) in=F)
		tabB (in=G) 
		;
	if A then do; item=item+1; if code=1; end;
	if B then item=item+2;
	if C then do; item=item+4; code0=put(code, ncd.); end;
	if D then do; item=item+3; end;
	if E then do; item=item+5; code0=put(code, nvl.); end;
	if F then do; item=item+4; end;
	if G then do; item=item+10; if code=1 and item in(11,13,14,15); end;
run;

data tab;
	set tab; by item;
	if not first.item then do; pvalue=.; or=.; range=.; pv=" "; end;
run;


ods rtf file="tab_K65R.rtf" style=journal bodytitle ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Table 1: Baseline characteristics of patients with virologic failure during first-line ART with and without tenofovir";
column item code0 nft nfy nfn pv;
define item/"Characteristic" group order=internal format=item. style=[just=left];
define code0/"." ;
define nft/"All patients*(n=&n)";
define nfy/"K65=R*(n=&n1)";
define nfn/"K65=K*(n=&n0)";
define pv/"p value";
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
Wilcoxon and Chi-square, Fisher’s tests used for two group comparisons (>1 resistance mutation vs. no resistance).
* p<0.05, ** p<0.001; TDF – tenofovir, EFV – efavirenz, ART – antiretroviral therapy, IQR – interquartile range';
ods rtf close;
