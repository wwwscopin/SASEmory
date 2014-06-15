options orientation=landscape ls=100 minoperator byline;
ods listing;

proc import out=job0
			datafile="H:\SAS_Emory\Consulting\DParker\Job\coded on.xls"
			DBMS=EXCEL REPLACE;
			sheet="sheet1";
			mixed=yes;
			getnames=No;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
proc contents data=job0;run;

proc transpose data=job0 out=job1; 
var F1-F205;
run;

proc format; 
	value item
		1="AOA"
		2="Publications-in medical school"
		3="Publications-in residency"
		4="Publications-book chapters/reviews"
		5="Publications-scientific projects (total)"
		6="Publications-1st author"
		7="Advanced degree"
		8="Extra year off"
		9="Age"
		10="Military"
		11="Presentation"
		12="First author"
		13="Teaching jobs"
		14="Marital"
		15="Phi Beta Kappa"
		16="Varsity athlete"
		17="College"
		18="MedsSchool"
		19="Residency"
		20="Strength of spine"
		21="PS (academic, no interest, in middle)"
		22="Letters (academic will hire back)"
		;
	value YN 
		1="Yes" 0="No"  .="N/A";
	value aoa 
		1="Yes" 0="No"  9="N/A";
	value pub 
		0="0" 1="<5" 2=">=5";
	value age 
		1="< 5 yrs from straight thru" 0="Spent more than 5 years doing something in between training";
	value edu 
		1="US news top 20" 0=">20";
	value res 
		1="Top 20" 0=">20";
	value spine 
		1="Fellowship" 0="No Fellowship";
	value ps 
		1="Academic" 2="Academic setting" 3="Private" 4="Unsure/Not mention";
	value letter 
		1="Hire back or pursue back" 2="Academic " 3="Private" 4="Unsure/Not mention";
	value job
		1="Academic" 0="Private";
run;


data job;
	set job1(keep=col1-col27);
	if 1<_n_;
	if find(col2, "academic") then job=1; else if find(col2, "private") or find(col2, "pirvate") then job=0;
	if find(col2, "then") then job=1;

	if col3='n' then aoa=0; else if col3='y' or col3="yes" then aoa=1; else aoa=9;

	if aoa^=9;

	if col5='a' then pub_ms=0; else if col5='b' then pub_ms=1; else if col5='c' or col5='d' then pub_ms=2;
	if col6='a' then pub_res=0; else if col6='b' then pub_res=1; else if col6='c' or col6='d' then pub_res=2; 
	if col7='a' then pub_bcr=0; else if col7='b' then pub_bcr=1; else if col7='c' or col7='d' then pub_bcr=2;  
	if col8='a' then pub_project=0; else if col8='b' then pub_project=1; else if col8='c' or col8='d' then pub_project=2;  
	if substr(col9,1,1)='a' then pub_author=0; else if substr(col9,1,1)='b' then pub_author=1; else if substr(col9,1,1)='c' or substr(col9,1,1)='d' then pub_author=2; 

	if col11='n' then degree=0; else if col11='y' then degree=1; else degree=.;
	if col12='n' then yearoff=0; else if col12='y' then yearoff=1; else yearoff=.;
	if col13='a' then age=1; else if col13='b' then age=0; else age=.;
	if col14='n' then military=0; else if col14='y' then military=1; else military=.;

	if col15='a' then present=0; else if col15='b' then present=1; else if col15='c' or col15='d' then present=2; 
	if col16='a' then p_author=0; else if col16='b' then p_author=1; else if col16='c' or col16='d' then p_author=2; 

	if col18='n' then teaching=0; else if col18='y' then teaching=1; else teaching=.;
	if col19='n' then marital=0; else if col19='y' then marital=1; else marital=.;
	if col20='n' then PBK=0; else if col20='y' then PBK=1; else PBK=.;
	if col21='n' then athelete=0; else if col21='y' then athelete=1; else athelete=.;
	if col22='a' or col22='b'  then college=1; else if col22='c' then college=0; 
	if col23='a' or col23='b' then medschool=1; else if col23='c' then medschool=0; 
	if col24='a' or col24='b' then res=1; else if col24='c' then res=0; 
	if col25='A' or col25='B' then spine=1; else if col25='C' or col25='D' then spine=0; 
	if col26='a' then ps=1; else if col26='b' then ps=2; else if col26='c' then ps=3; else if col26='d' then ps=4; 
	/*if col26='a' then ps=1; else if col26='b' then ps=2; else if col26='c' or col26='d' then ps=3;*/
	if col27='a' then letter=1; else if col27='b' then letter=2; else if col27='c' then letter=3;  else if col27='d' then letter=4; 
	
	rename col1=name;
	format job job. aoa aoa.  degree yearoff military teaching marital PBK athelete yn. 
		pub_ms pub_res pub_bcr pub_project pub_author present p_author pub.  college medschool edu. res res. spine spine. 
		letter letter. ps ps. age age.;
	label ps='Personal Statement'
		  pub_ms="Publication in Medical School"
		  yearoff="Extra year off"
		  medschool="Medical School"
		  spine="Strength of spine";
	drop col2-col27; 
run;

proc print data=job; 
where aoa=9;
var name job aoa;
run;

proc freq data=job;
	table job;
	ods output OneWayFreqs =wbh;
run;

data _null_;
	set wbh;
	if job=1 then call symput("yes", compress(frequency));
	if job=0 then call symput("no", compress(frequency));
run;
%let n=%eval(&yes+&no);

proc contents short varnum;run;
/*
proc freq data=job; 
	table (aoa pub_ms pub_res pub_bcr pub_project pub_author degree yearoff age military present p_author teaching marital
PBK athelete college medschool res spine ps letter)*job/chisq;
run;
*/

%macro tab(data, out, varlist)/minoperator parmbuff;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &var*job/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			length pv $10;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
		 	pv=put(pvalue, 7.4);
			if pvalue^=. and pvalue<0.0001 then pv='<0.0001';


			or=_MHOR_+0;
			rg=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then rg=" ";
			keep item pvalue pv or rg;
			format or pvalue 7.4;
		run;
		data p&i;
			merge p&i(firstobs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or rg); by item;
		run;

	proc sort data=tab&i; by &var; run;
	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(job=1) keep=&var job frequency rowpercent rename=(frequency=ny)) 
		tab&i(where=(job=0) keep=&var job frequency rename=(frequency=no)); 
		by &var;

		item=&i;
		if &var=. then delete;
		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";
		tmp=ny+no;
		rpct=ny||"/"||compress(tmp)||"("||put(rowpercent,4.1)||"%)";
		rename &var=code;
		drop job;
	run;
/*
	%if %eval(&i in 1 7 8 9 10 13 14 15 16) %then %do; proc sort data=tab&i; by descending code; run; %end;
	%else %do; proc sort data=tab&i; by code; run;	%end;
*/
	proc sort data=tab&i; by descending code; run;

	data tab&i;
		merge tab&i p&i; by item ;
		if fy<5 and fn<5 then do; or=.; rg=.; pv=" "; end;
		if not first.item then do; pv=" "; or=.; rg=.;end;
	run;

	data &out;
		length item0 $100 code0 $50;
		set &out tab&i; 
		item0=put(item, item.); 
		if item in (1) then do; code0=put(code, aoa.);  end;
		if item in (7,8,10,13,14,15,16) then do; code0=put(code, yn.);  end;
		if item in(2,3,4,5,6,11,12) then do; code0=put(code, pub.);    end;
		if item in(9) then do; code0=put(code, age.);  end;
		if item in(17,18) then do; code0=put(code, edu.); end;
		if item in(19) then do; code0=put(code, res.);  end;
		if item in(20) then do; code0=put(code, spine.);  end;
		if item in(21) then do; code0=put(code, ps.);  end;
		if item in(22) then do; code0=put(code, letter.);  end;
		keep code code0 item item0 ny no fy fn nfy nfn rpct or rg pvalue pv;
		format RowPercent 5.1;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist1=aoa pub_ms pub_res pub_bcr pub_project pub_author degree yearoff age military present p_author teaching marital
PBK athelete college medschool res spine ps letter;

%tab(job, job_tab, &varlist1);

proc freq data=job; 
tables ps*job/all measures;
run;

*****************************************************************************;
* Here is so nice code to insert blank line between each ID or items.
*****************************************************************************;

data job_tab;
	set job_tab; by item;
	output;
	if last.item then do; Call missing( of _all_ ) ; output; end;
run;
*options orientation=portrait nodate;

ods graphics on;
*ods trace on/label listing;
/*
proc logistic data=job ;
	class pub_ms yearoff medschool spine /param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine/aggregate scale=none rsquare outroc=roc1;
	ods output  Logistic.ParameterEstimates=est;
	ods output  Logistic.OddsRatios=or;
run;
*/

/*
proc logistic data=job ;
	class pub_ms yearoff medschool spine ps(ref='Private')/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps/ scale=none aggregate  rsquare outroc=roc1 lackfit;
	ods output  Logistic.ParameterEstimates=est;
	ods output  Logistic.OddsRatios=or;
	ods output   Logistic.Type3=pv;
run;
ods trace off;
*/

proc logistic data=job ;
	class pub_ms yearoff medschool spine ps(ref='Private' /*ref=last*/)/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps/selection=backward slentry=0.2 slstay=0.2 details lackfit;
run;

proc logistic data=job PLOTS=roc;
	class yearoff medschool  ps(ref='Academic' /*ref=last*/) /param=ref ref=first order=internal;
	model job=yearoff medschool ps/scale=none aggregate  rsquare lackfit OUTROC=wbh;
	roc ;
	estimate "a" int 1 yearoff 1 medschool 1 ps 2;
	estimate "b" int 1 yearoff 1 medschool 1 ps 0;
	ods output  Logistic.ParameterEstimates=est;
	ods output  Logistic.OddsRatios=or;
	ods output   Logistic.Type3=pv;

	output out=pred p=phat lower=lcl upper=ucl  predprobs=(individual crossvalidate);
run;

proc print data=wbh;run;
proc print data=pred;run;

data phat;
	set pred;
	pci=put(phat*100,3.0)||"%["||put(lcl*100,3.0)||" - "||put(ucl*100,3.0)||"]";
	pid=_n_;
run;
proc sort nodupkey; by yearoff medschool ps;run;
options orietation=portrait nodate;
ods rtf file="pre.rtf" style=journal startpage=no bodytitle;
 proc report data=phat nowindows split="*" style(column)=[just=center];
      title 'Predicted Probabilities to Enter Academia and 95% Confidence Limits';
	  column yearoff medschool  ps pci;
	  define yearoff/"Sponsored Research Fellowship" style(column)=[width=1.5in];
	  define medschool/"Medical School";
	  define ps/"Personal Statement";
	  define pci/"Probability of Entering Academia*Estimate[95%CI]" style(column)=[width=2in];
  run;
ods rtf close;

options orientation=landscape ls=100 minoperator byline;

proc logistic data=job ;
	class yearoff medschool  ps(ref='Academic setting' /*ref=last*/) /param=ref ref=first order=internal;
	model job=yearoff medschool ps/scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool  ps(ref='Unsure/Not mention' /*ref=last*/) /param=ref ref=first order=internal;
	model job=yearoff medschool ps/scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool  ps(ref='Private' /*ref=last*/) /param=ref ref=first order=internal;
	model job=yearoff medschool ps/scale=none aggregate  rsquare lackfit;
run;
/*
proc logistic data=job ;
	*class pub_ms yearoff medschool spine ps(ref='Private')/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps letter present/selection=score best=1 start=1 stop=5 details lackfit;
run;

proc logistic data=job ;
	class yearoff medschool ps(ref='Private') letter present/param=ref ref=first order=internal;
	model job=yearoff medschool ps letter present/ scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool spine ps(ref='Private' ) letter/param=ref ref=first order=internal;
	model job=yearoff medschool spine ps letter/ scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class pub_ms yearoff medschool ps(ref='Private') letter/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool ps letter/ scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool spine ps(ref='Private')/param=ref ref=first order=internal;
	model job=yearoff medschool spine ps / scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool letter ps(ref='Private' )/param=ref ref=first order=internal;
	model job=yearoff medschool ps letter/ scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class yearoff medschool present ps(ref='Private')/param=ref ref=first order=internal;
	model job=yearoff medschool present letter/ scale=none aggregate  rsquare lackfit;
run;

proc logistic data=job ;
	class pub_ms yearoff medschool spine ps(ref='Unsure/Not mention')/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps/aggregate scale=none rsquare outroc=roc1;
run;


proc logistic data=job ;
	class pub_ms yearoff medschool spine ps(ref='Academic setting')/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps/aggregate scale=none rsquare outroc=roc1;
run;

proc logistic data=job ;
	class pub_ms yearoff medschool spine ps(ref='Academic')/param=ref ref=first order=internal;
	model job=pub_ms yearoff medschool spine ps/aggregate scale=none rsquare outroc=roc1;
run;
*/

proc logistic data=job;
	class present(ref='0')/param=ref order=internal;
	model job=present/aggregate /*scale=none*/ rsquare;
		exact present/estimate;
run;

proc logistic data=job;
	class present(ref='<5')/param=ref order=internal;
	model job=present/aggregate /*scale=none*/ rsquare;
		exact present/estimate;
run;


proc logistic data=job;
	class ps(ref='Private')/param=ref order=internal;
	model job=ps/aggregate /*scale=none*/ rsquare;
	exact ps/estimate;
run;

proc logistic data=job;
	class ps(ref='Unsure/Not mention')/param=ref order=internal;
	model job=ps/aggregate rsquare;
	exact ps/estimate;
run;


proc logistic data=job;
	class ps(ref='Academic setting')/param=ref order=internal;
	model job=ps/aggregate rsquare;
	exact ps/estimate;
run;


proc logistic data=job(where=(letter^=3));
	class letter(ref='Hire back or pursue back')/param=ref order=internal;
	model job=letter/aggregate rsquare;
		exact letter/estimate;
run;

proc logistic data=job;
	class letter(ref='Hire back or pursue back')/param=ref order=internal;
	model job=letter/aggregate rsquare;
		exact letter/estimate;
run;

proc logistic data=job(where=(letter^=3));
	class letter(ref='Unsure/Not mention')/param=ref order=internal;
	model job=letter/aggregate rsquare;
	exact letter/estimate;
run;
proc logistic data=job(where=(letter^=3));
	class letter(ref='Academic')/param=ref order=internal;
	model job=letter/aggregate rsquare;
	exact letter/estimate;
run; 


*ods trace off;
ods graphics off;


data est;
	set est;
	length pvalue $10;
	pvalue=put(ProbChiSq, 7.4);
	if ProbChiSq<0.0001 then pvalue="<0.0001";
	rename stderr=err;
run;

data est1;
	set est(firstobs=2);
	idx=_n_;
run;

data  or;
	set or;
	idx=_n_;
run;

data ma;
	merge est1(keep=idx  ProbChiSq pvalue) or ; by idx;
	rg="["||put(lowerCL,4.2)||"-"||compress(put(upperCL,4.2))||"]";
run;

options orientation=landscape nodate;
ods rtf file="reg_final.rtf" style=journal bodytitle startpage=never ;

proc report data=job_tab split="*" nowindows style=[just=center] spacing=20; 
	title "Job Questionnaires (n=&n)";
	column item0 code0 nfy nfn rpct or rg pv;
	define item0/order order=internal "Question" style=[just=left];
	define code0/style=[just=left width=2in] "Results";
	define nfy /style=[just=right width=1.0in] "Academic * (n=&yes)";
	define nfn /style=[just=right width=1.0in] "Private * (n=&no)";
	define rpct/style=[just=right width=1.5in] "Percent of *Academic(%)";
	define or/style=[just=right] "Odds Ratio";
	define rg/style=[just=right] "95% CI";
	define pv/style=[just=right] "*p-value";

	break after item0 / skip;
run;

/*
proc report data=pv split="*" nowindows style=[just=center] spacing=20; 
	title "P Value from Multiple Variate Analysis";

	column Effect probchisq;
	define effect/ "Effect" order order=internal style=[just=left];
	define probchisq/style=[just=right] "*p-value" format=7.4;
	break after effect/ skip;
run;
*/
proc report data=est split="*" nowindows style=[just=center] spacing=20; 
	title "Parameter Estimation from Logistic Regression (n=&n)";

	column variable classval0 estimate err pvalue;
	define variable/ "Variable" order order=internal style=[just=left];
	define classval0/style=[just=left width=1.5in] ".";
	define estimate/style=[just=right width=1.2in] "Estimate" format=7.4;
	define err /style=[just=center width=1.5in] "Standard Error" format=7.4;
	define pvalue/style=[just=right] "*p-value";
	break after variable/ skip;
run;

proc report data=ma split="*" nowindows style=[just=center] spacing=20; 
	title "Multivariable Analysis of Factors Associated with Academic Positions for Fellows Completing the Survey (n=&n)";
	*where idx in (3,4,6,7,8);

	column effect OddsRatioEst rg pvalue;
	define effect/ "Effect" order order=internal style=[just=left width=4in];
	define OddsRatioEst/style=[just=left width=1in] "Odds Ratio" format=4.2;
	define rg/style=[just=left width=1in] "95% CI" ;
	define pvalue/style=[just=right] "*p-value";
	break after effect/ skip;
run;
ods rtf close;
