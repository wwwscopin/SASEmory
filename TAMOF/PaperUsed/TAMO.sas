options orientation=portrait nodate nonumber nofmterr;
%include "tab_stat.sas";
ods listing;
proc format; 
value yn 0= "No" 1= "Yes" ;

value censor 0="Non-Survivors" 1="Survivors";
value idx_a  3="Adamts13<30%" 2="Adamts13 in 30-57%" 1="Adamts13>57%";
value pe 0="No PLEX" 1="PLEX";
value var 0=" " 1="Adamts13 Activity(%)" 2="vWF Antigen (%)" 3=" ";
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
	if adamts13>57 then idx_a=1;
	else if 30<=adamts13<=57 then idx_a=2;
	else if 0<=adamts13<30 then idx_a=3;
	keep patientid adamts13 idx_a censor plasmaexchange vwf_ag;
	format censor censor. idx_a idx_a. plasmaexchange pe.;
	label vwf_ag="vWF Antigen(%)";
run;
proc npar1way data=adamt wilcoxon;
class pe;
var adamts13 vwf_ag;
run;

data adamts;
	set adamt(keep=id adamts13 )
	    adamt(keep=id vwf_ag in=A);
		if A then var=2; else var=1;
		vvar= var -0.1  + .2*uniform(613);;
		format var var.;
run;

axis1 label=(" ") value=(h=1.2) split="*" order= (0 to 3 by 1 ) minor=none offset=(0 in, 0 in);
axis2 label=(a=90 h=2 "Admats13 Activity (%) ") value=(h=1.2) split="*" order= (0 to 120 by 10 ) minor=none offset=(0 in, 0 in);
axis3 label=(a=90 h=2 "vWF Antigen (%) ") value=(h=1.2) split="*" order= (60 to 320 by 20 ) minor=none offset=(0 in, 0 in);

symbol1 interpol=boxt mode=exclude value=none co=black cv=black height=1 bwidth=5 width=2; 	 
symbol2 ci=red value=dot h=0.75;         
symbol3 interpol=boxt mode=exclude value=none co=black cv=black height=1 bwidth=5 width=2; 	 
symbol4 ci=blue value=dot h=0.75;         
                                                      
proc gplot data=adamts;
	plot   adamts13*var adamts13*vvar/overlay haxis = axis1 vaxis = axis2;
	plot2  vwf_ag*var vwf_ag*vvar/overlay vaxis = axis3;
	format var var.;
run;


proc sgplot data=adamts;
  vbox adamts13/category=var;
  vbox vwf_ag/ y2axis category=var;
  xaxis display=(nolabel noticks);
  yaxis VALUES= (0 to 120 by 10);
  y2axis VALUES= (60 to 320 by 20);
run;

proc sgplot data=adamt;
  vbox adamts13/category=pe;
  xaxis display=(nolabel noticks);
  yaxis VALUES= (0 to 120 by 10);
run;

proc sgplot data=adamt;
  vbox adamts13/category=censor;
  xaxis display=(nolabel noticks);
  yaxis VALUES= (0 to 120 by 10);
run;

proc sgplot data=adamt;
  vbox vwf_ag/category=pe;
  xaxis display=(nolabel noticks);
  yaxis VALUES= (60 to 360 by 20);
run;

proc sgplot data=adamt;
  vbox vwf_ag/category=censor;
  xaxis display=(nolabel noticks);
  yaxis VALUES= (60 to 360 by 20);
run;
