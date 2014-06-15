
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
	if "3Aug2010"d<=start_cur_arv3<='17Mar2011'd;
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
*ods trace on/label listing;
proc freq; 
	table tdf;
	ods output onewayfreqs=wbh;
run;
*ods trace off;

data _null_;
	set wbh;
	if tdf=0 then call symput("n0", compress(frequency));
	if tdf=1 then call symput("n1", compress(frequency));
run;

%let n=%eval(&n0+&n1);


data tdf;
	merge brent.quest(drop=other) brent.crf(drop=other) brent.tdf(keep=study_no tdf d4t in=A) brent.kidx;by study_no;
	if  A;
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

	if study_no="CAS 107" then  do; K65="R"; kidx=1; end;
	if study_no="CAS 109" then do; K65="R"; kidx=1; end;


	if diag_dis="TB" or diag_dis1='TB' or diag_dis2='TB'  then TB=1; else TB=0;
	if diag_dis="CRYPTOCOCCUS" or diag_dis1='CRYPTOCOCCUS' or diag_dis2='CRYPTOCOCCUS'  then cryp=1; else cryp=0;
	if diag_dis="HSV" or diag_dis1='HSV' or diag_dis2='HSV'  then HSV=1; else HSV=0;
	if diag_dis="KS" or diag_dis1='KS' or diag_dis2='KS'  then KS=1; else KS=0;
	if diag_dis="TOXO" or diag_dis1='TOXO' or diag_dis2='TOXO'  then TOXO=1; else TOXO=0;

	keep study_no tdf d4t age gender arvs efv cd4 ncd cd41 cd42 cd43 cd44 cd45  vl vl1 vl2 vl3 vl4 vl5 vl0 start_22-start_26 start_date1 start_date2 date nday1 nday2 nvl
		 naids k65 kidx TB cryp HSV KS TOXO kidx; 
	format start_22-start_26 start_date2 date mmddyy. nday1 nday2 4.1;
run;

ods listing;
ods rtf file="data.rtf" style=journal bodytitle;
proc print data=tdf label;
var study_no gender tdf d4t k65 efv date start_date2;
var nday2/style=[width=1.25in];
var naids;
format gender gender. tdf d4t efv yn. date start_date2 mmddyy.;
label date="Enrollment Date"
	  start_date2="Start Date"
	  tdf="TDF"
	  d4t="D4T"
	  efv="EFAVIRENZ"
	  nday2="Months from Start to Enrollment Date"
	  naids="Episodes";
run;
ods rtf close;

proc format; 
	value idx 1="Age"  2="Gender" 3="Regimen(EFV)" 4="CD4 Count" 5="Viral Load" 6="Duration of ART" 7="Prior AIDS-defining illness";
run;

%macro logic(data,out, gp, varlist)/minoperator;
data &out;
	if 1=1 then delete;
run;

%let i=1;
%let var=%scan(&varlist,&i);
%do %while(&var NE);
*ods trace on/label listing;
proc logistic data=&data;
	%if &var=gender or  &var=efv or &var=ncd or &var=nvl %then %do;
	class &var/param=ref ref=first order=internal;
	%end; 
	model &gp(event="1")=&var;
	%if &var=ncd or &var=nvl or &var=gender or  &var=efv %then %do; 
		exact &var / estimate = both; 
		ods output exactoddsratio=tmp&i; 
	%end;
	%else %do; ods output oddsratios=tmp&i; 
			   ods output ParameterEstimates=p&i;
	%end;
run;
*ods trace off;

%if &var=ncd or &var=nvl or &var=gender or  &var=efv %then %do; 
data tmp;
	length effect $40 range $12;


	set tmp&i;
	item=&i;
	rang=compress("["||put(lowerCL,7.2)||"-"||put(upperCL,7.2)||"]");

	if item=2 then do; 
		if classval0="1"  then effect="Male vs Female";
	end;

	if item=3 then do; 
		if classval0="1"  then effect="EFV Yes vs No";
	end;

	if item=4 then do; 
		if classval0="1"  then effect="50-99 cells/ul vs 0-49 cells/ul"; 
			if classval0="2"  then effect="100-199 cells/ul vs 0-49 cells/ul"; 
				if classval0="3"  then effect="200-349 cells/ul vs 0-49 cells/ul"; 
					if classval0="4"  then effect=">350 cells/ul vs 0-49 cells/ul"; 
	end;

	if item=5 then do; 
		if classval0="1"  then effect="5,000-29,999 vs 400-4,999"; 
			if classval0="2"  then effect="30,000-99,999 vs 400-4,999"; 
				if classval0="3"  then effect=">100,000 vs 400-4,999"; 
	end;
	rename estimate=OddsRatioEst;
run;
%end;

%else %do;
data tmp;
	length effect $40 range $12;
	merge tmp&i p&i(firstobs=2 obs=2 keep=probchisq rename=(probchisq=pvalue));
	item=&i;
	rang=compress("["||put(lowerCL,7.2)||"-"||put(upperCL,7.2)||"]");
	if item in (1,6,7) then effect=" ";
run;

%end;

data &out;
	set &out tmp;
	format item idx.;
run;

%let i=%eval(&i+1);
%let var=%scan(&varlist,&i);
%end;
%mend logic;

%let varlist=age gender efv ncd nvl nday2 naids;
%logic(tdf, tab, kidx, &varlist);


proc logistic data=tdf;
	class gender efv ncd nvl/param=ref ref=first order=internal;
	*model kidx(event="1")=age gender efv ncd /*nvl*/ nday2 naids;
	model kidx(event="1")=gender efv ncd nvl;
	exact gender efv ncd nvl/estimate=both;
	*ods output oddsratios=tmp;
run;

ods rtf file="factor.rtf" style=journal bodytitle ;
proc report data=tab nowindows style(column)=[just=center] split="*";
title "Table 2: Factors associated with K65R amongst patients failing a tenofovir-based first-line ART";
column item effect OddsRatioEst rang pvalue;
define item/"Factor" group order=internal format=idx. style=[just=left];
define effect/"."  style=[just=left width=2in];
define OddsRatioEst/"Odds Ratio" format=7.2 style=[width=0.75in];
define rang/"95% CI";
define pvalue/"p value" format=5.2 style=[width=0.75in];
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=2in RIGHTMARGIN=1in font_size=11pt}RT – antiretroviral therapy';
ods rtf close;

proc format;
	value index 1="Gender" 2="Regimen(EFV)" 3="CD4 Count" 4="Viral Load";
	value gender 0="Male" 1="Female";
	value cd  0="0-49 cells/ul"
			  1="50-99 cells/ul"
			  2="100-199 cells/ul"
			  3="200-349 cells/ul"
 			  4=">350 cells/ul"; 

	value vl  0="400-4,999"
			  1="5,000-29,999"
			  2="30,000-99,999"
			  3=">100,000"; 
	value yn  0="No" 1="Yes";
run;

%let varlist=gender efv ncd nvl;
%tab(tdf, kidx, tabf, &varlist);

data tabf;
	length sec $20;
	set tabf;
	if item=1 then sec=put(code,gender.);
	if item=2 then sec=put(code,yn.);
	if item=3 then sec=put(code,cd.);
	if item=4 then sec=put(code,vl.);
run;

ods rtf file="tab_freq.rtf" style=journal bodytitle ;
proc report data=tabf nowindows style(column)=[just=center] split="*";
title "Table 3: Mutation Frequency by Categories";
column item sec rpct ;
define item/"Factor" group order=internal format=index. style=[just=left];
define sec/"."  style=[just=left width=2in];
define rpct/"Mutation Rates" style=[width=1in];
define pvalue/"p value" group format=5.2 style=[width=1in];
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=2in RIGHTMARGIN=1in font_size=11pt}RT – antiretroviral therapy';
ods rtf close;
