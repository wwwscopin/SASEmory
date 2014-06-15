options orientation=landscape ls=120 minoperator;
%let path=H:\SAS_Emory\Consulting\Brain\BrainOCD\;
libname olt "&path";
filename olt "&path\OCD Megadatabase 5311 final_new.xls" lrecl=1000;

proc import out=main0
			datafile=olt
			DBMS=EXCEL REPLACE;
			RANGE="main$B1:z86";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
			*DBDSOPTS="DBSASTYPE=('DOS'='CHAR(12)')" ; 
run;
data main;
	set main0(rename=(ICRS=ICRS0));
	rename  F_u__months_=fu_month  Post_AHF_= Post_AHF;
	sizeA=scan(compress(size,"mm"),1, "xX")*scan(compress(size,"mm"),2, "xX");
	ICRS=ICRS0+0;
	drop ICRS0;
run;

proc import out=microfx0
			datafile=olt
			DBMS=EXCEL REPLACE;
			RANGE="microfx$B1:AA32";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
data microfx;
	set microfx0;
	rename  F_u__months_=fu_month  Post_AHF_= Post_AHF  Size__mm2_=sizeA;
run;

proc import out=oats0
			datafile=olt
			DBMS=EXCEL REPLACE;
			RANGE="oats$A1:z18";
			mixed=yes;
			getnames=yes;
			SCANTEXT=YES;
    	 	USEDATE=YES;
     		SCANTIME=YES;
run;
data oats;
	set oats0;
	rename  F_u__months_=fu_month  Post_AHF_= Post_AHF  Size__mm2_=sizeA;
run;

data olt;
	length size $8;
	set /*main(in=A)*/ microfx(in=B rename=(prior_sx=prior_sx0 Trauma=trauma0)) 
			oats(in=C rename=(prior_sx=prior_sx0 Trauma=trauma0));
	if B then group=0;
	if C then group=1;
	if Satisfied in ("N", "n") then satisfy=0; else satisfy=1;
	if sex="F" then gender=0; else gender=1;
	if prior_sx0 in("N", "n") then prior_sx=0; else prior_sx=1;
	if F_U_sx^=" " then FU_sx=1; else FU_sx=0;
	if Trauma0 in("Y", "yes") then trauma=1; else trauma=0;
run;

proc contents;run;
proc print;run;

proc freq data=olt;
	table group;
	ods output OneWayFreqs =wbh;
run;

data _null_;
	set wbh;
	if group=0 then call symput("no", compress(frequency));
	if group=1 then call symput("yes", compress(frequency));
run;
%let n=%eval(&yes+&no);
%put &yes;
*******************************************************************************************;
proc format;
	value item 
		1="Sex"
		2="Age"
		3="BMI"
		4="Size(mm2)"
		5="Syptoms"
		6="Pre AHF"
		7="Post AHF"
		8="Prior Surgery"
		9="Follow-up Surgery"
		10="Trauma"
		11="ICRS"
		12="Post P"
		13="Post F"
		14="Pre P"
		15="Pre F"
		16="Satisfied"
		;
	value gender 0="Female" 1="Male";
	value yn 0="No" 1="Yes";
	value pp 1="Pre AHF" 2="Post AHF";
	value gp 0="Microfx" 1="OATS";

	value it 
		1="Sex"
		2="Prior Surgery"
		3="Follow-up Surgery"
		4="Trauma"
		5="ICRS"
		6="Satisfied"
		;
run;


%let pm=%sysfunc(byte(177));  
%macro stat(data, varlist);
	data stat;
		if 1=1 then delete;
	run;

	%let i = 1;
	%let var = %scan(&varlist, &i);
	%do %while ( &var NE );

	proc means data=&data noprint;
		class group;
		var &var;
		output out=tab&i n(&var)=n mean(&var)=mean std(&var)=std median(&var)=median q1(&var)=Q1 q3(&var)=Q3;
	run;

	data tab&i;
		set tab&i;
		%if &var=post_p or &var=post_f or &var=pre_p or &var=pre_f %then  %do;
			mean0=put(mean,4.1)||" &pm "||compress(put(std,4.1))||"["||compress(put(Q1,4.0))||" - "||compress(put(Q3,4.0))||"]";
		%end;
		%else  %do;
			mean0=put(mean,5.0)||" &pm "||compress(put(std,5.0))||"["||compress(put(Q1,5.0))||" - "||compress(put(Q3,5.0))||"]";
		%end;
		if group=. then delete;
		format median 5.0;
		item=&i;
		keep group mean0 median item;
	run;

	proc npar1way data = &data wilcoxon;
  		class group;
  		var &var;
  		ods output WilcoxonTest=wp&i;
	run;

	data wp&i;
		length pv $5;
		set wp&i;
		if _n_=10;
		item=&i;
		pvalue=cvalue1+0;
		pv=put(pvalue, 4.2);
		if pvalue<0.01 then pv='<0.01';
		keep item pvalue pv;
	run;

	data tab&i;
		merge tab&i(where=(group=0)) 
			tab&i(where=(group=1)rename=(mean0=mean1 median=median1)) wp&i; by item;
	run;

	data stat;
		set stat tab&i;
	run; 

	%let i= %eval(&i+1);
	%let var = %scan(&varlist,&i);
	%end;
%mend stat;	
%let varlist=age bmi sizeA symptoms pre_ahf post_ahf post_p post_f pre_p pre_f;
%stat(olt, &varlist);

*******************************************************************************************;

%macro tab(data, out, varlist)/minoperator parmbuff;

data &out comp;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		proc freq data=&data ;
			table &var*group/nocol nopercent chisq cmh;
			ods output crosstabfreqs = tab&i;
			output out = p&i chisq exact cmh;
		run;

		data p&i;
			length pv $20;
			XP2_FISH=.;
			set p&i;
			item=&i;
			pvalue=XP2_FISH;
			if pvalue=. then pvalue= P_PCHI;
		 	pv=put(pvalue, 4.2);
			if pvalue^=. and pvalue<0.01 then pv='<0.01';
			
			if XP2_FISH^=. then pv=compress(pv||"(Fisher)");
			else pv=compress(pv||"(Chisq)");

			or=_MHOR_+0;
			range=put(L_MHOR,4.2)||"--"||compress(put(U_MHOR,4.2));
			if or=. then range=" ";
			keep item pvalue pv or range;
			format or pvalue 4.2;
		run;

		data p&i;
			merge p&i(firstobs=1 keep=item pvalue pv) p&i(firstobs=2 keep=item or range); by item;
		run;

	proc sort data=tab&i; by &var; run;
	data tab&i;
		length nfy nfn $25;
		merge tab&i(where=(group=0) keep=&var group frequency rowpercent rename=(frequency=no)) 
		tab&i(where=(group=1) keep=&var group frequency rename=(frequency=ny)); 
		by &var;

		item=&i;
		if &var=. then delete;
		fy=ny/&yes*100; 		fn=no/&no*100;
		nfy=ny||"("||put(fy,5.1)||"%)";			nfn=no||"("||put(fn,5.1)||"%)";
		tmp=ny+no; 
		rp=100-rowpercent;
		rpct=ny||"/"||compress(tmp)||"("||put(rp,4.1)||"%)";
		rename &var=code;
		drop group;
	run;

	proc sort data=tab&i; by descending code; run;

	data tab&i;
		merge tab&i p&i; by item ;
		if fy<5 and fn<5 then do; or=.; range=.; pv=" "; end;
		if not first.item then do; pv=" "; or=.; range=.;end;
	run;

	data &out;
		length code0 $50;
		set &out tab&i; 
		if item in (1) then do; code0=put(code, gender.);  end;
		if item in (2,3,4,6) then do; code0=put(code, yn.);  end;
		if item in (5) then do; code0=put(code, 2.0);  end;


		keep code code0 item ny no fy fn nfy nfn rpct or range pvalue pv;
		format RowPercent 5.1;
	run; 

proc ttest data =&data;
  by group;
  class &var;
  var pre_ahf post_ahf;
  ods output  
	Ttest.ByGroup1.Pre_AHF.ConfLimits=preA1   Ttest.ByGroup1.Pre_AHF.TTests=preA2
	Ttest.ByGroup1.Post_AHF.ConfLimits=postA1  Ttest.ByGroup1.Post_AHF.TTests=postA2
	Ttest.ByGroup2.Pre_AHF.ConfLimits=preB1   Ttest.ByGroup2.Pre_AHF.TTests=preB2
	Ttest.ByGroup2.Post_AHF.ConfLimits=postB1  Ttest.ByGroup2.Post_AHF.TTests=postB2;
run;

data tab_&var;
	merge preA1(obs=2 keep=class mean  StdDev ) preA2(firstobs=2 obs=2 keep=  Probt);  var=1; gp=0; item=&i; output;
	merge postA1(obs=2 keep=class mean  StdDev ) postA2(firstobs=2 obs=2 keep=  Probt);  var=2; gp=0; item=&i; output;
	merge preB1(obs=2 keep=class mean  StdDev) preB2(firstobs=2 obs=2 keep=  Probt); var=1; gp=1;  item=&i; output;
	merge postB1(obs=2 keep=class mean  StdDev) postB2(firstobs=2 obs=2 keep=  Probt); var=2; gp=1; item=&i; output;
run;

data tab_&var;
	set tab_&var;
	code=class+0;
	drop class;
run;

proc sort data=tab_&var; by gp var code;run;

data comp;
	set comp tab_&var;
		if item in (1) then do; code0=put(code, gender.);  end;
		if item in (2,3,4,6) then do; code0=put(code, yn.);  end;
		if item in (5) then do; code0=put(code, 2.0);  end;
	format var pp. gp gp. item it.;;
run;

proc sort; by gp var item;run;
   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist1=gender prior_sx Fu_sx Trauma icrs satisfy;
%tab(olt, olt_tab, &varlist1);

data stat;
	set stat;
	rename mean0=nfn mean1=nfy;
	keep item mean0 mean1 pvalue pv;
run;

data MO;
	length nfn nfy $30;
	set olt_tab(where=(item=1)) 
		stat(where=(item<=6) in=A)
		olt_tab(where=(item in (2,3,4,5)) in=B)
		stat(where=(item>6) in=C)
		olt_tab(where=(item=6) in=D);
	if A then item=item+1;
	if B then item=item+6;
	if C then item=item+5;
	if D then item=item+10;
	format item item.;
	keep item code code0 nfy nfn rpct or range pvalue pv;
run;
proc sort; by item; run;

*****************************************************************************;
* Here is so nice code to insert blank line between each ID or items.
*****************************************************************************;

data mo;
	set mo; by item;
	output;
	if last.item and item in(1,7,8,9,10,11,15) then do; Call missing( of _all_ ) ; output; end;
run;
*ods trace on/label listing;

/*
proc reg data=olt;
	by group;
	model pre_ahf =age bmi sizeA symptoms post_p post_f pre_p pre_f/selection=stepwise noint;
run;

proc reg data=olt;
	by group;
	model post_ahf =age bmi sizeA symptoms post_p post_f pre_p pre_f pre_ahf/selection=stepwise noint;
run;
*/

proc glm data=olt(where=(group=0));
	model pre_ahf =bmi pre_p pre_f/solution noint;
	ods output  GLM.ANOVA.Pre_AHF.ParameterEstimates=pre_est0;
run;
/*
proc glm data=olt(where=(group=0));
	class gender prior_sx;
	model pre_ahf =bmi pre_p pre_f gender prior_sx/solution noint;
	ods output  GLM.ANOVA.Pre_AHF.ParameterEstimates=pre_est0;
run;
*/

proc glm data=olt(where=(group=1));
	model pre_ahf =bmi pre_f/solution noint;
	ods output  GLM.ANOVA.Pre_AHF.ParameterEstimates=pre_est1;
run;

proc glm data=olt(where=(group=0));
	model post_ahf =post_f pre_p pre_f pre_ahf/solution noint;
	ods output  GLM.ANOVA.post_AHF.ParameterEstimates=post_est0;
run;

proc glm data=olt(where=(group=1));
	model post_ahf =age bmi sizeA post_F pre_f/solution noint;
	ods output  GLM.ANOVA.post_AHF.ParameterEstimates=post_est1;
run;

options orientation=portrait nodate;
ods rtf file="olt.rtf" style=journal bodytitle startpage=no ;

proc print data=mo split="*" noobs label uniform style(head)=[just=center]; 
	title "Comparison between Microfx(n=&no) and OATS(n=&yes)";
	by item notsorted;
	id item;
	var code0/style(data)=[just=left cellwidth=0.75in] style(head)=[just=left];
	var nfy nfn /style(data)=[just=right cellwidth=1.25in];
	var rpct/style(data)=[just=right cellwidth=1.5in];
	var or range pv/style(data)=[just=right];
	label item="Question"
		rpct="Percent of *OATS(%)"
		or="Odds Ratio"
		range="95% CI"
		code0="."
		nfy="OATS * (n=&yes)"
		nfn="Microfx * (n=&no)"
		pv="*p-value";
run;
ods rtf startpage=yes;
proc print data=comp split="*" noobs label style(head)=[just=center]; 
	title "Comparison of Variable Regarading Pre AHF and Post AHF";
	by gp var item;
	id gp var item;
	var code0 mean stddev probt/style(data)=[just=left cellwidth=0.75in] style(head)=[just=left];
	label gp="Group"
		var="Score"
		Item="Variable"
		code0="."
		Mean="Mean"
		Stddev="Stand Deviation"
		probt="*p-value";
run;
ods rtf startpage=yes;

proc print data=pre_est0 split="*" noobs label uniform style(head)=[just=right]; 
	title "Multivariable Analysis for Pre AOFAS in Microfx";
	where Probt^=.;
	var  Parameter/style(data)=[just=left cellwidth=1.5in] style(head)=[just=left];
	var  Estimate  StdErr  Probt/style(data)=[just=right cellwidth=1.5in];
	format 	Estimate  StdErr  probt 7.4 ;
run;
ods rtf startpage=NO;
proc print data=pre_est1 split="*" noobs label uniform style(head)=[just=right]; 
	title "Multivariable Analysis for Pre AOFAS in OATS";
	where Probt^=.;
	var  Parameter/style(data)=[just=left cellwidth=1.5in] style(head)=[just=left];
	var  Estimate  StdErr  Probt/style(data)=[just=right cellwidth=1.5in];
	format 	Estimate  StdErr  probt 7.4 ;
run;
ods rtf startpage=no;

proc print data=post_est0 split="*" noobs label uniform style(head)=[just=right]; 
	where Probt^=.;
	title "Multivariable Analysis for Post AOFAS in Microfx";
	var  Parameter/style(data)=[just=left cellwidth=1.5in] style(head)=[just=left];
	var  Estimate  StdErr  Probt/style(data)=[just=right cellwidth=1.5in];
	format 	Estimate  StdErr  probt 7.4 ;
run;
ods rtf startpage=NO;
proc print data=post_est1 split="*" noobs label uniform style(head)=[just=right]; 
	where Probt^=.;
	title "Multivariable Analysis for Post AOFAS in OATS";
	var Parameter/style(data)=[just=left cellwidth=1.5in] style(head)=[just=left];
	var  Estimate  StdErr  Probt/style(data)=[just=right cellwidth=1.5in];
	format 	Estimate  StdErr  probt 7.4 ;
run;
ods rtf close;
