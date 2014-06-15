options orientation=landscape nodate nonumber nofmterr;
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
run;

libname TAMOF "S:\bios\TAMOF\Reporting\data";

data TAMOF.survival; set TAMOF.survival;
      if patientid = 111001 then pelodtotalscore = 21;
      if patientid = 111003 then pelodtotalscore = 30;
      if patientid = 111006 then pelodtotalscore = 22;
      if patientid = 111008 then pelodtotalscore = 22;

      if patientid = 111003 then daysonpex = 3;
      if patientid = 111004 then daysonpex = 3;

      if patientid = 111007 then plasmaexchange = 1;
      if patientid = 111007 then daysonpex = 3; 

      *drop pelodpreddeathrate deathrate; *These are not correct anymore and we don't use them anyway ;
run;

%macro prob(data,var,pelod,pe,ecmo, cvvh, mrsa,idx);
proc logistic data=&data;
	model &var=ecmo cvvh pelodtotalscore mrsa PlasmaExchange/clodds=wald expb;
	contrast "&idx"  intercept 1 pelodtotalscore &pelod PlasmaExchange &pe ecmo &ecmo cvvh &cvvh mrsa &mrsa/estimate=prob;
	ods output ContrastEstimate=est0;
run;

data est&idx;
	set est0;
	pci=put(estimate*100,3.0)||"%["||put(LowerLimit*100,3.0)||" - "||put(UpperLimit*100,3.0)||"]";
	pelod=&pelod; 
	pe=&pe;
	ecmo=&ecmo;
	cvvh=&cvvh;
	mrsa=&mrsa;
	idx=&idx;
	call symput("prob",put(estimate,7.4));
	keep pci pelod pe ecmo cvvh mrsa idx;
run;

proc logistic data=&data;
	model &var=ecmo cvvh pelodtotalscore mrsa PlasmaExchange/ctable pprob=&prob;
	ods output Classification=ctab;
run;

data est&idx;
	merge est&idx ctab(keep=Sensitivity	Specificity);
run;

%mend prob;
%prob(tamof.survival, censor, 20, 1, 1, 1, 1, 1);
%prob(tamof.survival, censor, 20, 1, 1, 1, 0, 2);
%prob(tamof.survival, censor, 20, 1, 1, 0, 1, 3);
%prob(tamof.survival, censor, 20, 1, 1, 0, 0, 4);
%prob(tamof.survival, censor, 20, 1, 0, 1, 1, 5);
%prob(tamof.survival, censor, 20, 1, 0, 1, 0, 6);
%prob(tamof.survival, censor, 20, 1, 0, 0, 1, 7);
%prob(tamof.survival, censor, 20, 1, 0, 0, 0, 8);
%prob(tamof.survival, censor, 20, 0, 1, 1, 1, 9);
%prob(tamof.survival, censor, 20, 0, 1, 1, 0, 10);
%prob(tamof.survival, censor, 20, 0, 1, 0, 1, 11);
%prob(tamof.survival, censor, 20, 0, 1, 0, 0, 12);
%prob(tamof.survival, censor, 20, 0, 0, 1, 1, 13);
%prob(tamof.survival, censor, 20, 0, 0, 1, 0, 14);
%prob(tamof.survival, censor, 20, 0, 0, 0, 1, 15);
%prob(tamof.survival, censor, 20, 0, 0, 0, 0, 16);

data phat20;
	set est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 est11 est12 est13 est14 est15 est16; 
run;
proc sort; by idx; run;

%prob(tamof.survival, censor, 25, 1, 1, 1, 1, 1);
%prob(tamof.survival, censor, 25, 1, 1, 1, 0, 2);
%prob(tamof.survival, censor, 25, 1, 1, 0, 1, 3);
%prob(tamof.survival, censor, 25, 1, 1, 0, 0, 4);
%prob(tamof.survival, censor, 25, 1, 0, 1, 1, 5);
%prob(tamof.survival, censor, 25, 1, 0, 1, 0, 6);
%prob(tamof.survival, censor, 25, 1, 0, 0, 1, 7);
%prob(tamof.survival, censor, 25, 1, 0, 0, 0, 8);
%prob(tamof.survival, censor, 25, 0, 1, 1, 1, 9);
%prob(tamof.survival, censor, 25, 0, 1, 1, 0, 10);
%prob(tamof.survival, censor, 25, 0, 1, 0, 1, 11);
%prob(tamof.survival, censor, 25, 0, 1, 0, 0, 12);
%prob(tamof.survival, censor, 25, 0, 0, 1, 1, 13);
%prob(tamof.survival, censor, 25, 0, 0, 1, 0, 14);
%prob(tamof.survival, censor, 25, 0, 0, 0, 1, 15);
%prob(tamof.survival, censor, 25, 0, 0, 0, 0, 16);

data phat25;
	set est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 est11 est12 est13 est14 est15 est16; 
run;
proc sort; by idx; run;

data phat;
	set phat20(in=A) phat25;
run;

options orientation=portrait nodate;
ods rtf file="phat.rtf" style=journal startpage=no bodytitle;
 proc report data=phat nowindows split="*" style(column)=[just=center];
      title 'Predicted Probabilities of Death and 95% Confidence Limits';
	  column pelod pe ecmo cvvh mrsa pci Sensitivity Specificity;
	  define pelod/"PELOD" order=internal group;
	  define pe/"Plasma Exchange" format=yn.;
	  define ecmo/"ECMO" format=yn.;
	  define cvvh/"CVVH" format=yn.;
	  define mrsa/"MRSA" format=yn.;
	  define pci/"Probability of Death*Estimate[95%CI]" style(column)=[width=2in];
	  define sensitivity/"Sensitivity" format=3.0;
	  define specificity/"Specificity" format=3.0;
  run;
ods rtf close;

*goptions reset=global device=png target=png ftext='Arial' ftitle='Arial/bold'   xmax=7 in ymax=9 in   xpixels=1400 ypixels=1800;
goptions device=pslepsfc gsfname=output gsfmode=replace xmax=7 in ymax=9 in   xpixels=1400 ypixels=1800;
ods ps file="test.ps";
proc logistic data=tamof.survival;
	model censor=ecmo cvvh pelodtotalscore mrsa PlasmaExchange/clodds=wald OUTROC=wbh;
	units pelodtotalscore=5;
	roc;
	output out=preds predprobs=(individual crossvalidate);
run;
ods ps close;

/*
proc print data=wbh;run;

*ods trace on/label listing;
ods ps file="test.ps";
proc logistic data=preds;
	model censor=ecmo cvvh pelodtotalscore mrsa PlasmaExchange/clodds=wald ;
	units pelodtotalscore=5;
    roc pred=xp_0;
    roccontrast;
	output out=pred p=phat lower=lcl upper=ucl  predprob=(individual crossvalidate);
run;
*ods trace off;
*/
