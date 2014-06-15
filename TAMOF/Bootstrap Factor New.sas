options orientation=portrait nodate nonumber nofmterr byline;
proc format; 

value StudySite
	1 ="CHOA-Egleston"
	2 ="Pittsburgh" 
	3 ="LSU-Shreveport" 
	4 ="Columbus" 
	5 ="CNMC"
	6 ="Cincinnati" 
	7 ="CHOA-Scottish Rite"
	8 ="Cook Children's (Texas)" 
	9 ="Texas Children's" 
	10 ="Minnesota" 
	11 ="Vanderbilt" 
	12 ="Stanford" 
	13 ="Michigan" 
	14 ="Phoenix" 
	15 ="Iowa" 
	16 ="All Sites"
; 

value VisitList
	-1 ="Screening"
	0="Day 0"
	1 ="Day 1"
	2 ="Day 2" 
	3 ="Day 3" 
	4 ="Day 4"
	5 ="Day 5"
	6 ="Day 6"
	7 ="Day 7"
	8 ="Day 8"
	9 ="Day 9"
	10 ="Day 10"
	11 ="Day 11"
	12 ="Day 12"
	13 ="Day 13"
	14 ="Day 14"
	15 ="Day 15"
	16 ="Day 16"
	17 ="Day 17" 
	18 ="Day 18" 
	19 ="Day 19"
	20 ="Day 20"
	21="Day 21"
	22="Day 22"
	23="Day 23"
	24="Day 24"
	25="Day 25"
	26 ="Day 26"
	27 ="Day 27"
	28 ="Day 28"
	99 ="Overall"
; 

value yn
	0= "No"
	1= "Yes"
;

value whyleft
	1= "Withdrawal of consent"
	2= "Patient improvement / Treatment goal met"
	3 = "Death"
	4 = "Complications"
;

value icd_death
	1="Incision of vessels, unspecified"
	2="Endarterectomy, intracranial vessels"
	3="Other malignant lymphomas, unspecified site"
	4="Cardiorespiratory / cardiopulmonary arrest (cardiac arrest)"
	5="Hemorrhage cerebral NOS / Massive pontine hemorrhage - intracerebral hemorrhage"
	6="Acute respiratory failure"
	7="Septic shock"
	8="Sepsis"
;

value deathrate
	0 = "Low predicted death rate by PELOD (< 50%)"
	1 = "High predicted death rate by PELOD (> 50%)"
;   

value group 1="Plasma Exchange" 2="Vital Status";
value censor 0="Non-Survivor" 1="Survivor";

value item 1="PELOD Score" 2="PELOD Score Change(%)" 3="PELOD Score Change" 4="PELOD Score" 5="PELOD Score Change(%)" 6="PELOD Score Change";
value idx  0="Intercept" 1="PEx Change" 2="ECMO" 3="CVVH" 4="MRSA" 5="Baseline PELOD Score*";
run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";



/*
proc contents data=TAMOF.ecmo_survival;run;
proc print data=TAMOF.ecmo_survival;var patientid censor time pelodtotalscore; run;
proc print data=TAMOF.daily;var patientid treatmentday PelodTotalScore platelets; run;
proc print data=TAMOF.lab;var patientid day adamts13  vwf_ag  vwf_rca; run;
proc contents data=TAMOF.daily;run;
proc contents data=TAMOF.pex;run;
proc contents data=TAMOF.lab;run;
*/
proc sort data=tamof.pex; by patientid;run;
proc sort data=tamof.lab; by patientid;run;
proc sort data=tamof.demographic; by patientid;run;


data mrsa;
	set tamof.infection;
	if orgcode1=3 or orgcode2=3 or orgcode3=3 or orgcode4=3 or orgcode5=3 or orgcode6=3;
	rename patientid=id;
run;

proc sort nodupkey; by id;run;

data plt;
	merge   tamof.daily(keep=patientid treatmentday PelodTotalScore platelets rename=(treatmentday=day) in=A)
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	pelod0=PelodTotalScore;
	if B;
run;

%let pm=%sysfunc(byte(177)); 
%put &pm;

data dead0;
	set plt(where=(censor=0)); by patientid day;
	if last.patientid and day<7 then 
		do i=day+1 to 7;
			day=i; PelodTotalScore=71;
			output;
		end;
	drop i platelets;
run;

data pelod;
	set dead0 plt;
	by patientid day;
	if PelodTotalScore=71 then pelod0=.;
run;

data lab;
	merge   tamof.lab(keep=patientid day adamts13  vwf_ag  vwf_rca in=A)
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	if patientid= 111002 and day=3 then day=4;
	if B and day^=.;
run;

data mixed; 
	merge pelod lab; by patientid day;
	rename PelodTotalScore=pelod patientid=id platelets=plt PlasmaExchange=pe;
	if patientid=110002 then censor=1;
	retain bp;
	if day=1 then bp=pelod0;
	dbp=pelod0-bp;
	chg=dbp/bp*100;
run;

data mixed;
	merge mixed tamof.survival(keep=patientid ecmo cvvh rename=(patientid=id)) mrsa(in=infect); by id; 
	if infect then mrsa=1; else mrsa=0;
run;

proc sort nodupkey; by id; run;

data mixed;
	set mixed;
	idx=_n_;
run;

%let numsamp=10000;
%let numpat=81;
data bmixed;
	do bootsamp=1 to &numsamp;
		do bootsamp_id=1 to &numpat;
		 rdx=ceil(&numpat*ranuni(1));
		 output;
		 end;
	end;
run;


proc sql;
	create table boot_mixed as 
		select distinct * from mixed inner join bmixed
		on mixed.idx=bmixed.rdx
		order by bootsamp, bootsamp_id;
		quit;

data tamof.boot_mixed;
	set boot_mixed;
run;


proc means data=mixed;
class pe day;
var pelod plt adamts13  vwf_ag  vwf_rca;
run;

proc sort data=mixed nodupkey out=mixed_id; by id;run;

proc means data=mixed_id;
	class pe;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if pe=0 then call symput("no",compress(n));
	if pe=1 then call symput("ny",compress(n));
run; 
%put &no;

proc sort data=mixed nodupkey out=mixed_id1; by id;run;

proc means data=mixed_id1;
	class censor;
	var id;
	output out=id_num n(id)=n;
run;
data _null_;
	set id_num;
	if censor=0 then call symput("nd",compress(n));
	if censor=1 then call symput("ns",compress(n));
run;



ods listing close;
proc logistic data=tamof.boot_mixed outest=tamof.betas; by bootsamp;
	class pe ecmo cvvh mrsa;
	model censor(event='0')=bp pe ecmo cvvh mrsa /selection=forward slentry=0.1 lackfit;
	*model censor(event='0')=bp pe ecmo cvvh mrsa /include=1 selection=forward slentry=0.1 lackfit;
	*output out=tamof.pred p=phat;
run;
ods listing;

proc means n data=tamof.betas; var bootsamp peno ecmo0 cvvh0 mrsa0 bp;
output out=wbh ;
run;

proc transpose data=wbh(obs=1) out=tmp; 

data risk;
	set tmp;
	if _n_>3;
	rename _name_=risk_factor col1=n1;
	if _name_='peNo'  then idx=1;
	if _name_='ecmo0' then idx=2;
	if _name_='cvvh0' then idx=3;
	if _name_='mrsa0' then idx=4;
	if _name_='bp'    then idx=5;
	drop _label_;
run;


*ods trace on/label listing;
proc logistic data=mixed;
	class pe ecmo cvvh mrsa/param=ref ref=first order=internal;
	model censor(event='0')=pe ecmo cvvh mrsa bp/lackfit clodds=wald;
	*class cvvh /param=ref ref=first order=internal;
	*model censor(event='0')=cvvh bp/lackfit clodds=wald;
	units bp = 5;
	*ods output  Logistic.Type3=type3;
	ods output  Logistic.ParameterEstimates=est;
	*ods output  Logistic.OddsRatios=or;
	ods output  Logistic.CLoddsWald=or;

	ods output  Logistic.LackFit.LackFitChiSq=fit;
run;
*ds trace off;

data type3; 
	length pv $10;
	set type3; 
	if effect='pe'    then idx=1;  
	if effect='ecmo'  then idx=2;  
	if effect='cvvh'  then idx=3;  
	if effect='mrsa'  then idx=4; 
	if effect='bp'    then idx=5; 
	pv=put(probchisq,7.4);
	if probchisq<0.0001 then pv="<0.0001";
	keep   idx probchisq pv; 
run;


data est; 
	length pv $10;
	set est; 
	if variable='Intercept'  then idx=0;  
	if variable='cvvh'  then idx=3;  
	if variable='ecmo'  then idx=2;  
	if variable='pe'    then idx=1;  
	if variable='mrsa'  then idx=4; 
	if variable='bp'    then idx=5; 
	est=compress(put(estimate,7.4)||"&pm"||put(stderr,7.4));
	pv=put(probchisq,7.4);
	if probchisq<0.0001 then pv="<0.0001";

	keep idx estimate stderr est pv; 
run;


data or; 
	set or;   
	if scan(effect, 1)='pe'    then idx=1;  
	if scan(effect, 1)='ecmo'  then idx=2;  
	if scan(effect, 1)='cvvh'  then idx=3;  
	if scan(effect, 1)='mrsa'  then idx=4;  
	if scan(effect, 1)='bp'    then idx=5;  

	ci="["||put(lowercl,5.2)||"-"||put(upperCL,5.2)||"]"; 
	drop effect; 
run;

data _null_;
	set fit;
	call symput("pv", put(probchisq, 7.4));
run;

data para;
	merge /*type3*/ est or; by idx;
run;

data orp;
	merge risk para; by idx;
	/*if idx=5 then do; oddsratioest=.; ci=.;  end;*/
run;


ods rtf file = "bootstrap.rtf" style=journal bodytitle;

proc report data=orp nowindows split="*";
title1 "Multivariate Logistic Regression Analysis of Factors Associated with Hospital Mortality Based on Bootstrap Results";
title2 "Goodness-of-Fit Test p=&pv";
column idx n1 est oddsratioest ci pv;
define idx/order=formated format=idx. style=[just=left cellwidth=1.75in] "Risk Factor";
define n1/"Frequency of covariate*in 10000 bootstrap samples" style=[just=center cellwidth=1.75in];
define est/"Estimate &pm SEM" style=[just=center cellwidth=1.25in] "";
define oddsratioest/"Odds Ratio" format=5.2 style=[just=center cellwidth=0.75in];
define ci/"95% CI" style=[just=center cellwidth=1in];
define pv/"p value" style=[just=center cellwidth=0.75in];
run;
ODS ESCAPECHAR='^';
ODS rtf TEXT='^S={LEFTMARGIN=0.5in RIGHTMARGIN=0.5in font_size=11pt}
Odd Ratio was computed by 5 unit increase of baseline PELOD score.';
ods rtf close;

