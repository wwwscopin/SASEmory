options orientation=portrait nodate nonumber /*papersize=("7" "8")*/;

/*
proc contents data=cmv.nec_p1 short varnum; run;	*plate57;
proc contents data=cmv.nec_p2 short varnum; run;	*plate58;
proc contents data=cmv.nec_p3 short varnum; run;	*plate59;

DateFormComplete NECDate id DFSTATUS DFVALID DFSEQ MOCInit FormCompletedBy IsBloodStool IsEmesis IsAbnDistension LBWIWeight         
ImageNumber AntibioticNEC   

LaparotomyDate AbdominalDrainDate BowelResecDate WoundCultureDate id DFSTATUS DFVALID DFSEQ MOCInit LaparotomyDone NecBowel         
GangrenousBowel BowelHarden LargeIntestinePerfor SmallIntestinePerfor AbdominalDrain BowelResecDone PortionResec LengthResec        
WoundCulture IsCulturePositive CultureCode1 CultureCode2 CultureCode3 SurgeryReqd  

NECResolveDate Comments id DFSTATUS DFVALID DFSEQ MOCInit LBWISBSyndrome IsNarrative
*/

data nec;
	merge cmv.nec_p1 cmv.nec_p2 cmv.nec_p3; by id; 

	center=floor(id/1000000);
	format center center.;

	keep 
			NECDate id center IsBloodStool IsEmesis IsAbnDistension LBWIWeight ImageNumber AntibioticNEC  

			LaparotomyDate AbdominalDrainDate BowelResecDate WoundCultureDate id LaparotomyDone NecBowel GangrenousBowel BowelHarden
	 		LargeIntestinePerfor SmallIntestinePerfor AbdominalDrain BowelResecDone PortionResec LengthResec LengthResecMin LengthResecmax 			WoundCulture 	IsCulturePositive CultureCode1 CultureCode2 CultureCode3 SurgeryReqd 

			NECResolveDate Comments id LBWISBSyndrome IsNarrative;
run;

*********************************************************************************************************************************;
proc sql;
	create table nec as
	select a.*, b.dob, NECDate-dob as age, NECResolveDate-NECDate as t
	from nec as a, cmv.comp_pat as b
	where a.id=b.id
	;

proc means data=nec; 
	class center;
	var age;
	output out=nec_age n(age)=n mean(age)=mean median(age)=median min(age)=min max(age)=max;
run;

data nec_age;
	set nec_age;
	if center=. then center=0;
	keep center n mean median min max;
	format center center. mean 3.0;
run;

proc means data=nec; 
	class center;
	var t;
	output out=nec_t n(t)=n mean(t)=mean median(t)=median min(t)=min max(t)=max;
run;

data nec_t;
	set nec_t;
	if center=. then center=0;
	keep center n mean median min max;
	format center center. mean 3.0;
run;

*******************************************************************************************************************************;

proc means data=nec noprint;
 class center;
 output out=nec_num n(center)=num;
run;

data nec_num;
	set nec_num(drop=_TYPE_ _FREQ_);
	if center=. then do; center=0;	call symput("n",compress(num)); end;
	if center=1 then do; call symput("n1",compress(num)); end;
	if center=2 then do; call symput("n2",compress(num)); end;
	if center=3 then do; call symput("n3",compress(num)); end;
run;

proc means data=cmv.comp_pat noprint;
	class center;
	output out=comp_pat n(center)=num;
run;

data comp_pat;
	set comp_pat(drop=_TYPE_ _FREQ_);
 	if center=.  then center=0;
run;

proc sql;
	create table nec_pat0 as 
	select a.*, b.num as num_tot, a.num/num_tot*100 as pct format=4.1
	from nec_num as a, comp_pat as b
	where a.center=b.center
	order by center
	;

proc sql;
	create table nec_pat as 
	select a.*, b.mean, b.median, b.min, b.max 
	from nec_pat0  as a, nec_age as b
	where a.center=b.center
	order by center
	;


data nec_pat;
	set nec_pat;
	nf=num||"/"||compress(num_tot)||"("||put(pct,4.1)||"%)";
run;


proc sql;
	create table nec_t as 
	select a.center, a.num, b.mean, b.median, b.min, b.max 
	from nec_num  as a, nec_t as b
	where a.center=b.center
	order by center
	;


**************************************************************************************************************************************;
proc format;
value group 
				1="Clinical Diagnosis"
				3="Antibiotic Treatment"
				4="Surgical Interventions"
				5="Follow-up"
		;

value itemA 
				1="Was bloody stools observed?"
				2="Was emesis observed?"
				3="Was abdominal distention observed?"
			;

value itemC 
				1="Did the LBWI receive antibiotics to treat NEC?"
		;

value itemD 
				1="Was exploratory laparotomy done?"
				2="--Yes, Necrotic bowel observed?"
				3="--Yes, Gangrenous bowel observed?"
				4="--Yes, Bowel wall hardening observed?"
				5="--Yes, Perforation of the large intestine observed?"
				6="--Yes, Perforation of the small intestine observed?"
				7="Were abdominal drains placed?"
				8='Was a bowel resection done?'
				9="--Yes, Portion resected:"
				10="--Yes, Was a wound culture obtained"
				11="==Yes, Was the culture positive"
				12="Was any additional surgery required?"
		;

value itemE 
				1="Did the LBWI develop short bowel syndrome?"
		;


value code 
				0="No"
				1="Yes"
				99="Unknown"
		;

value intestine 
				1="Small intestine"
				2="Large intestine"
				3="Both"
				99="Unknown"
		;

value culture_org 
				1="1"
				2="2"
				3="3"
				99="Unknown"
		;

value stat 
				1="LBWI's weight at diagnosis(g):"
				2="In total, how many images were reported on NEC Image Forms?"				
				3="Total length resected minimum(cm):"				
				4="Total length resected maximum(cm):"
		;
run;

*********************************************************************************************************************************;


proc means data=nec noprint missing n mean std max min median;

var LBWIWeight ImageNumber LengthResecMin LengthResecmax /*CultureCode1 CultureCode2 CultureCode3*/;

output out=nec_mean;
output out=nec_median median= / autoname ;
run;

proc transpose data=nec_mean out=nec_mean; run;

data nec_mean;
	set nec_mean;
	if _n_>2;
	ind=_n_-2;
	rename _name_=name col1=n col2=min col3=max col4=mean col5=std;
	drop _freq_;
run;


proc transpose data=nec_median out=nec_median; run;
data nec_median;
	set nec_median;
	if _n_>2;
	ind=_n_-2;
	rename _name_=name col1=median;
	drop _freq_;
run;

proc sql; 
	create table nec_stat as 
	select a.ind format=stat., a.n,  a.min, a.max, a.mean format=5.1, a.std format=5.1, b.median format=5.1
	from nec_mean as a, nec_median as b
	where a.ind=b.ind
	;

*******************************************************************************************************************************;
%macro tab(data, out, varlist)/ parmbuff ;

data &out;
	if 1=1 then delete;
run;

%let i = 1;
%let var = %scan(&varlist, &i);
%do %while ( &var NE );
		*ods trace on;
		proc freq data=&data;
			table &var*center/norow nocol;
			ods output crosstabfreqs = tab&i;
		run;
		*ods trace off;

	data tab&i;
		set tab&i;
		item=&i;
		if center=. then center=0;
		if &var=. then delete;
		rename &var=code;
	run;

	data &out;
		length item0 $100 code0 $20;
		set &out tab&i;

		%if &out=sec1 %then %do; group=1; item0=put(item, itemA.); code0=put(code, code.); format group group.; %end;
		%if &out=sec3 %then %do; group=3; item0=put(item, itemC.); code0=put(code, code.); format group group.; %end;
		%if &out=sec4 %then %do; 
					group=4; item0=put(item, itemD.); format group group.;
					if item^=9 then do; code0=put(code, code.);  end;
					if item=9 then do; code0=put(code, intestine.); end;
					if item in (2,3,4,5,6,9,10,11) and code=99 then delete;
			%end;
		%if &out=sec5 %then %do; group=5; item0=put(item, itemE.); code0=put(code, code.); format group group.; %end;

		keep code code0 center group frequency percent item item0;
	run; 

   %let i= %eval(&i+1);
   %let var = %scan(&varlist,&i);
%end;
%mend tab;

%let varlist=IsBloodStool IsEmesis IsAbnDistension;
%tab(nec, sec1, &varlist);

%let varlist=AntibioticNEC;
%tab(nec, sec3, &varlist);


%let varlist=LaparotomyDone NecBowel GangrenousBowel BowelHarden LargeIntestinePerfor SmallIntestinePerfor AbdominalDrain BowelResecDone PortionResec WoundCulture IsCulturePositive SurgeryReqd;
%tab(nec, sec4, &varlist);


%let varlist=LBWISBSyndrome;
%tab(nec, sec5, &varlist);

data nec_new;
	set sec1 sec3 sec4 sec5;
run;


proc transpose data=nec_new out=nec_new1; by group item item0 code code0; 
var frequency;
run;

proc transpose data=nec_new out=nec_new2; by group item item0 code code0; 
var percent;
run;


%let ny41=0;%let ny411=0; %let ny412=0; %let ny413=0;
%let ny48=0;%let ny481=0; %let ny482=0; %let ny483=0;
%let ny410=0;%let ny4101=0; %let ny4102=0; %let ny4103=0;


data _null_;
	set nec_new1(rename=(col1=n1 COL2=n2 COL3=n));
	n3=0;

if group=4 and item=1 and code=1 then do;
call symput("ny41", compress(n)); call symput("ny411", compress(n1)); call symput("ny412", compress(n2)); call symput("ny413", compress(n3));end;

if group=4 and item=8 and code=1 then do;
call symput("ny48", compress(n)); call symput("ny481", compress(n1)); call symput("ny482", compress(n2)); call symput("ny483", compress(n3));end;

if group=4 and item=10 and code=1 then do;
call symput("ny410", compress(n)); call symput("ny4101", compress(n1)); call symput("ny4102", compress(n2)); call symput("ny4103", compress(n3));end;

run;

data nec_new;
	length nf1 nf2 nf3 nf $25;
	merge nec_new1(rename=(col1=n1 COL2=n2 COL3=n)) /*nec_new2(rename=(col1=f1 COL2=f2 COL3=f))*/; by group item code;

	f1=n1/&n1*100; 
	f2=n2/&n2*100; 
	*f3=n3/&n3*100; 
	f=n/&n*100; 

	nf1=n1||"("||put(f1,4.1)||"%)";
	nf2=n2||"("||put(f2,4.1)||"%)";
	*nf3=n3||"("||put(f3,4.1)||"%)";
	nf=n||"("||put(f,4.1)||"%)";

if group=4 and item in(2,3,4,5,6) then do; 
	m=&ny41; m1=&ny411; m2=&ny412; m3=&ny413; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=4 and item in(9,10) then do; 
	m=&ny48; m1=&ny481; m2=&ny482; m3=&ny483; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end; 

if group=4 and item=11 then do; 
	m=&ny410; m1=&ny4101; m2=&ny4102; m3=&ny4103; 
	f1=(n1/m1)*100; f2=(n2/m2)*100; f3=(n3/m3)*100; f=(n/m)*100; 
	if f1=. then f1=0; 	if f2=. then f2=0; 	if f3=. then f3=0; 	if f=. then f=0;
	nf1=n1||"/"||compress(m1)||"("||put(f1,5.1)||"%)";
	nf2=n2||"/"||compress(m2)||"("||put(f2,5.1)||"%)"; 
	nf3=n3||"/"||compress(m3)||"("||put(f3,5.1)||"%)"; 
	nf =n ||"/"||compress(m) ||"("||put(f ,5.1)||"%)"; 
end;

	drop  _NAME_   _LABEL_;
run;

ods rtf file="nec.rtf" style=Journal startpage=no bodytitle;

title "Incidence of NEC Disease";

proc print data=nec_pat noobs label split="*" style(data) = [cellwidth=1in just=center];
var center/style(data) = [cellwidth=0.8in just=left];
var nf/style(data) = [cellwidth=1.2in just=center];
var mean median min max;

label
		nf='NEC*(%)'
		center='Center'
		mean='Age*Mean(Day)'
		median='Age*Median(Day)'
		min='Age*Min(Day)'
		max='Age*Max(Day)'
;
run;

proc print data=nec_t noobs label split="*" style(data) = [cellwidth=1in just=center];
title "Days from Date of NEC Diagnose to Date NEC Resolved";
var center/style(data) = [cellwidth=0.8in just=left];
var num/style(data) = [cellwidth=1.2in just=center];
var mean median min max;

label
		num='NEC*(n)'
		center='Center'
		mean='Mean*(Day)'
		median='Median*(Day)'
		min='Min*(Day)'
		max='Max*(Day)'
;
run;

/*
title1 "Data Summary for NEC (n=&n)";
proc print data=sus_cmv_stat noobs label split="*" style(data) = [cellwidth=1in just=center];

var ind/style(data) = [cellwidth=3in just=left];
var n mean median min max/style(data) = [cellwidth=0.6in just=center];

label 
		ind='Variable'
		n='Number'
		mean='Mean'
		median='Median'
		min='Min'
		max='Max'
;
run;
*/

options orientation=landscape;
ods rtf startpage=no;

proc report data=nec_new;
	*where group in (1,2,3) ;
	title1 "NEC Disease Summary (n=&n)";
	*title2 "Have any of the following signs/sumptoms been clinically observed?";
	columns group item0 code0 nf nf1 nf2; *nf3;
	define group/group order=data "Section" style(column)={just=left cellwidth=1.5in};
	define item0/group order=data "Item" style(column)={just=left cellwidth=3.5in};
	define code0/"Results" style(column)={just=center};
	define nf/"Overall(n=&n)" style(column)={just=right};
	define nf1/"EUHM(n=&n1)" style(column)={just=right};
	define nf2/"Grady(n=&n2)" style(column)={just=right};
	*define nf3/"Northside(n=&n2)" style(column)={just=right};
	break after group/skip;
	break after item0/skip;
run;

options orientation=portrait;

title "Data Summary for NEC Disease (n=&n)";
proc print data=nec_stat noobs label split="*" style(data) = [cellwidth=1in just=center];

var ind/style(data) = [cellwidth=3in just=left];
var n mean median min max/style(data) = [cellwidth=0.6in just=center];

label 
		ind='Variable'
		n='N'
		mean='Mean'
		median='Median'
		min='Min'
		max='Max'
;
run;

ods rtf close;






