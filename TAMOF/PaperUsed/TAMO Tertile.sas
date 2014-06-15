options orientation=portrait nodate nonumber nofmterr;
%include "tab_stat.sas";
ods listing;
proc format; 
value yn 0= "No" 1= "Yes" ;

value censor 0="Non-Survivors" 1="Survivors";
value idx_a  1="Adamts13<30%" 2="Adamts13 in 30-57%" 3="Adamts13>57%";
value pe 0="No PLEX" 1="PLEX";
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

data TAMOF.survival; set TAMOF.survival;
      if patientid = 111001 then pelodtotalscore = 21;
      if patientid = 111003 then pelodtotalscore = 30;
      if patientid = 111006 then pelodtotalscore = 22;
      if patientid = 111008 then pelodtotalscore = 22;

      if patientid = 111003 then daysonpex = 3;
      if patientid = 111004 then daysonpex = 3;

      if patientid = 111007 then plasmaexchange = 1;
      if patientid = 111007 then daysonpex = 3; 
run;


data plt;
	merge   tamof.daily(keep=patientid treatmentday PelodTotalScore platelets rename=(treatmentday=day) in=A)
			tamof.demographic(keep=patientid in=B)
	 		tamof.survival(keep=patientid  PlasmaExchange censor in=C); by patientid;
	pelod0=PelodTotalScore;
	if B;
run;


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
	if day in(2,3,4,5) then day=4;
	if day in(7,8,9) then day=8;
	if day in(21,25,28) then day=28;
	if B and day^=.;
run;

data adamt; 
	merge pelod lab; by patientid day;
	rename patientid=id PlasmaExchange=pe;
	where day=0;
	if adamts13>57 then idx_a=3;
	else if 30<=adamts13<=57 then idx_a=2;
	else if 0<=adamts13<30 then idx_a=1;
	keep patientid adamts13 idx_a censor plasmaexchange vwf_ag;
	format censor censor. idx_a idx_a. plasmaexchange pe.;
run;
proc univariate data=adamt; var adamts13; output out=tertile1 pctlpts=33 67 pctlpre=p ;run;
proc univariate data=adamt; var vwf_ag; output out=tertile12 pctlpts=33 67 pctlpre=p ;run;


data _null_;
	set tertile1;
	call symput("aq1", put(p33,4.1));
	call symput("aq2", put(p67,4.1));
run;
data _null_;
	set tertile2;
	call symput("vq1", put(p33,4.1));
	call symput("vq2", put(p67,4.1));
run;


%put &aq1;
%put &vq2;

proc format;
value idx 1="Adamts13<=&aq1%" 2="Adamts13 in &aq1-&aq2%" 3="Adamts13>&aq2%";
value index 1="vWF Antigen<=&vq1%" 2="vWF Antigen in &vq1-&vq2%" 3="vWF Antigen>&vq2%";
run;

data adamts;
	set adamt;
	if 0<=adamts13<=&aq1 then idx=1;
	else if &aq1<adamts13<=&aq2 then idx=2;
	else if &aq2<adamts13 then idx=3;

	if 0<=vwf_ag<=&vq1 then index=1;
	else if &vq1<vwf_ag<=&vq2 then index=2;
	else if &vq2<vwf_ag then index=3;
	format idx idx. index index.;
run;

proc univariate data=adamts ciquantnormal(alpha=.1);
var adamts13 vwf_ag;
run;

ods rtf file="range.rtf" style=journal bodytitle;
title " ";
proc means data=adamts n mean std clm min Q1 median Q3 max maxdec=1;
var adamts13 vwf_ag;
run;
ods rtf close;


/*
proc freq data=adamts ;
	tables idx_a*pe/fisher;
	tables idx*pe/fisher;
	tables index*pe/fisher;

	tables idx_a*censor/fisher;
	tables idx*censor/fisher;
	tables index*censor/fisher;
run;
*/

%table(data_in=adamts,data_out=plex1,gvar=pe,var=idx_a,type=cat, first_var=1, label="Adamts13 by Range", title="Table 1: Comparison Between PLEX and No-PLEX");
%table(data_in=adamts,data_out=plex1,gvar=pe,var=idx,type=cat,  label="Adamts13 by Tertile");
%table(data_in=adamts,data_out=plex1,gvar=pe,var=index,type=cat, last_var=1, label="vWF Antigen by Tertile");

%table(data_in=adamts,data_out=survivor1,gvar=censor,var=idx_a,type=cat, first_var=1, label="Adamts13 by Range", title="Table 2: Comparison Between Survivors and Non-Survivors");
%table(data_in=adamts,data_out=survivor1,gvar=censor,var=idx,type=cat,  label="Adamts13 by Tertile");
%table(data_in=adamts,data_out=survivor1,gvar=censor,var=index,type=cat, last_var=1, label="vWF Antigen by Tertile");
