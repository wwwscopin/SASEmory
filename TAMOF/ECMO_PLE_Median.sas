options orientation=landscape nodate nonumber nofmterr;
%let mu=%sysfunc(byte(181));


libname TAMOF "S:\bios\TAMOF\Reporting\data";

proc sort data=tamof.daily; by patientid; run;
proc sort data=tamof.endofstudy; by patientid; run;
proc contents data=tamof.endofstudy;run;
proc contents data=tAMOF.demographic; run;

data tamof;
	merge 
		tamof.endofstudy(keep=patientid ptDiscontDay ptDiscontDay28Yes EnrollmentDate LastTreatDate  
			ExtubDate  PICUDischargeDate   HospDischargeDate Vent1EndDate  
			Vent1StartDate Vent2EndDate  Vent2StartDate Vent3EndDate  Vent3StartDate)
		TAMOF.survival(in=sub keep=patientid plasmaexchange ecmo time censor rename=(time=day))
		TAMOF.mortality(keep=patientid DeathDate)
		TAMOF.demographic(keep=patientid  HosAdmitDate  IntubDate  PICUAdmitDate); 
		by patientid;

		if patientid=101017 then IntubDate=.;
		if patientid=111003 then do; IntubDate=.; PICUAdmitDate=.; HosAdmitDate=.;end;

		vday1=DATEPART(Vent1EndDate)-datepart(Vent1StartDate);
		vday2=DATEPART(Vent2EndDate)-datepart(Vent2StartDate);
		vday3=DATEPART(Vent3EndDate)-datepart(Vent3StartDate);
		tday=DATEPART(LastTreatDate)-datepart(EnrollmentDate);
		dday=DATEPART(DeathDate)-datepart(EnrollmentDate);
		eday=DATEPART(ExtubDate)-datepart(IntubDate);
		pday=DATEPART(PICUDischargeDate)-datepart(PICUAdmitDate);
		hday=DATEPART(HospDischargeDate)-datepart(HosAdmitDate);
		if plasmaexchange=1 and ecmo=0;
run; 

proc print;

run;

proc freq data=tamof;
	tables ptDiscontDay*ptDiscontDay28Yes;
run; 

proc freq data=tamof; 
	tables censor;
	ods output onewayfreqs=tmp;
run;

data _null_;
	set tmp;
	if censor=0 then call symput("d", compress(frequency));
	if censor=1 then call symput("s", compress(frequency));
run;

%put &d;

data vday;
	set tamof(keep=patientid censor vday1 rename=(vday1=vday)) 
		tamof(keep=patientid censor vday2 rename=(vday2=vday)) 
		tamof(keep=patientid censor vday3 rename=(vday3=vday));
	if  vday=. then delete;
run;

proc sort; by patientid;run;
proc sort nodupkey out=vid; by patientid;run;

*ods trace on/label listing; 
proc means data=tamof n median min max;
	class censor;
	var dday tday eday pday hday;
	output out=tmp1 n(dday tday eday pday hday)= median(dday tday eday pday hday)= 
			min(dday tday eday pday hday)= 	max(dday tday eday pday hday)=/autoname;
run;

proc means data=vday n median min max;
	class censor;
	var vday;
	output out=tmp2 n(vday)= median(vday)= min(vday)= max(vday)=/autoname;
run;

proc format; 
	value censor 0="Non-Survivor" 1="Survivor";
	value item
		1="From Enrollment to Death"
		2="From Enrollment to Last Treatment with PEx"
		3="From Intubation to Extubation"
		4="From PICU Admission to PICU Discharge"
		5="From Hospital Admission to Hospital Discharge"
		6="Ventilation Days"
		;
run;

data median;
	length dday tday eday pday hday vday $30;
	merge tmp1(drop=_type_ _freq_) tmp2(drop=_type_ _freq_); by censor;
	if censor=. then delete;
	if censor=0 then do; fd=dday_n/&d*100; ft=tday_n/&d*100; fe=eday_n/&d*100; fp=pday_n/&d*100; fh=hday_n/&d*100; fv=vday_n/&d*100;end;
	if censor=1 then do; fd=dday_n/&s*100; ft=tday_n/&s*100; fe=eday_n/&s*100; fp=pday_n/&s*100; fh=hday_n/&s*100; fv=vday_n/&s*100;end;

		dday=compress(put(dday_median,3.0)||"["||dday_min||"-"||dday_max||"],"||dday_n);
		tday=compress(put(tday_median,3.0)||"["||tday_min||"-"||tday_max||"],"||tday_n);
		eday=compress(put(eday_median,3.0)||"["||eday_min||"-"||eday_max||"],"||eday_n);
		pday=compress(put(pday_median,3.0)||"["||pday_min||"-"||pday_max||"],"||pday_n);
		hday=compress(put(hday_median,3.0)||"["||hday_min||"-"||hday_max||"],"||hday_n);
		vday=compress(put(vday_median,3.0)||"["||vday_min||"-"||vday_max||"],"||vday_n);

	format censor censor.;
	keep censor dday tday eday pday hday vday 
		dday_median tday_median eday_median pday_median hday_median vday_median
		dday_min tday_min eday_min pday_min hday_min vday_min 
		dday_max tday_max eday_max pday_max hday_max vday_max;
run;

data med_day;
	set median(in=d keep=censor dday rename=(dday=mmm))
		median(in=t keep=censor tday rename=(tday=mmm))
		median(in=e keep=censor eday rename=(eday=mmm))
		median(in=p keep=censor pday rename=(pday=mmm))
		median(in=h keep=censor hday rename=(hday=mmm))
		median(in=v keep=censor vday rename=(vday=mmm));
	if d then item=1;
		if t then item=2;
			if e then item=3;
				if p then item=4;
					if h then item=5;
						if v then item=6;
run;

proc transpose data=med_day out=medday; var mmm; by item; run;

data med;
	set medday(where=(_name_='mmm') rename=(col1=mmm0 col2=mmm1)); 
	by item;
	if item=1 then mmm1="--";
	if item in(3,4,5) then mmm0="--";
run;

options orientation=portrait;run;

ods rtf file="median.rtf" style=journal bodytitle;
proc report data=med nowindows headline spacing=1 split='*' style(column)=[just=right] style(header)=[just=center]; 
title "Summary of End of Study / Final Outcomes (Survivors=&s, Non-Survivors=&d)*";
column item ("Non-Survivors"  mmm0) ("Survivors" mmm1)	;

define item/"End of Study" format=item. style(column)=[cellwidth=3.5in just=left] style(header)=[just=left];
define mmm0/"Median Day[Min-Max], N" style(column)=[cellwidth=2in just=center];
define mmm1/"Median Day[Min-Max], N" style(column)=[cellwidth=2in just=center];
run;

ODS ESCAPECHAR="^";
ODS rtf TEXT="^S={LEFTMARGIN=0.9in RIGHTMARGIN=0.9in font_size=10pt}
1. There are 24 patients who left the study before 28 days; 17 Survivors left study because of 'Patient Improvement/Treatment Goal Met', 7 patients died.
^n 2. 10 Patients left the study after 28 days.
^n 3. 2 patients in the survival group died after 28 days.
";

ods rtf close;
