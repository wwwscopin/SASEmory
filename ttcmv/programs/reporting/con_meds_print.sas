%macro conmed();
data conmeds;
	set cmv.con_meds;
	%do i=1 %to 9;
		center=floor(id/1000000);
		dfseq = dfseq;
		Dose=Dose&i;
		DoseNumber=DoseNumber&i;
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		day=EndDate-StartDate;
		Indication=Indication&i;
		MedCode=MedCode&i;
		MedName=MedName&i;
		Unit=Unit&i;
		prn=prn&i;

		i=&i;

		output;
	%end;

	keep id dfseq center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
	format  StartDate EndDate mmddyy8. center center. MedCode MedCode. Indication Indication. unit unit.;
run;
%mend;

%conmed();
quit;

data conmeds; set conmeds; if enddate ~= . & startdate ~= .; * keep only valid entries ; run;
proc sort data = conmeds; by MedName; run;


options nodate;
ods rtf file="/ttcmv/sas/output/medication/con_med_print.rtf" style=journal;
	title "Concomitant Medications";
	proc print data = conmeds noobs label style(data)=[just=left];
		var id dfseq medname medcode; 
		label id = "ID" dfseq = "Page #" medname = "Medication Name" medcode = "Med Code";
	run;
ods rtf close;

ods rtf file="/ttcmv/sas/output/medication/con_med_freq.rtf" style=journal;
	title "Concomitant Medications";
	proc freq data = conmeds; tables medname; run;
ods rtf close;





data antibiotics; set conmeds; if medcode = 1 | medcode = 2 | medcode = 7 | medcode = 11 | medcode = 19 | medcode = 22; run;

ods rtf file="/ttcmv/sas/output/medication/con_med_print_antibiotics.rtf" style=journal;
	title "Antibiotic Medications";
	proc print data = antibiotics noobs label style(data)=[just=left];
		var id dfseq medname; 
		label id = "ID" dfseq = "Page #" medname = "Medication Name";
	run;
ods rtf close;


ods rtf file="/ttcmv/sas/output/medication/con_med_freq_antibiotics.rtf" style=journal;
	title "Antibiotic Medications";
	proc freq data = antibiotics; tables medname; run;
ods rtf close;


/*
data analgesic; set conmeds; if medcode = 04; run;

ods rtf file="/ttcmv/sas/output/medication/con_med_print_analgesic.rtf" style=journal;
	title "Analgesic Medications";
	proc print data = analgesic noobs label style(data)=[just=left];
		var id dfseq medname; 
		label id = "ID" dfseq = "Page #" medname = "Medication Name";
	run;
ods rtf close;


ods rtf file="/ttcmv/sas/output/medication/con_med_freq_analgesic.rtf" style=journal;
	title "Analgesic Medications";
	proc freq data = analgesic; tables medname; run;
ods rtf close;
*/



data caffeine; set conmeds; if medcode = 05; run;

ods rtf file="/ttcmv/sas/output/medication/con_med_print_caffeine.rtf" style=journal;
	title "Caffeine";
	proc print data = caffeine noobs label style(data)=[just=left];
		var id dfseq medname; 
		label id = "ID" dfseq = "Page #" medname = "Medication Name";
	run;
ods rtf close;


ods rtf file="/ttcmv/sas/output/medication/con_med_freq_caffeine.rtf" style=journal;
	title "Caffeine";
	proc freq data = caffeine; tables medname; run;
ods rtf close;

