%include "&include./descriptive_stat.sas";
%include "&include./annual_toc.sas";


* TOTAL NUMBER OF PATIENTS IN STUDY **********************;
* List of all patients who have completed study (not including withdrawals) ;
data completedstudylist; set cmv.endofstudy; if reason ~= 5; keep id; run;
data _null_; set completedstudylist nobs=nobs;
  call symput('N',trim(left(put(nobs,8.))));
run;

*** CMV ********************************************************************************************************;
data cmv; set cmv.sus_cmv; run;
proc sort data = cmv; by id dfseq; run;
data cmv; set cmv;
	by id;
	if first.id then number = 1; 
	if last.id then case = dfseq-150;
run;

data _null_; set cmv nobs=nobs;
  call symput('N_cmv',trim(left(put(nobs,8.))));
run;

proc freq data = cmv;
	tables cmvdisconf / nocum out = cmv_number;
run; 

data cmv_number; set cmv_number;
	if cmvdisconf = 1;
	length row $ 120; row = "^S={font_weight = bold} Confirmed CMV infection" || "^S={font_weight = medium} - No. / Total no. suspected cases (%)";
	disp_overall = compress(put(count, 12.0)) || "/" || compress(put(&N_cmv, 12.0)) || " (" || compress(put((count/&N_cmv) * 100, 12.1)) || ")";
	keep row disp_overall; 
run;

data cmv_number; 
	length row $ 120; row = "^S={font_weight = bold} Confirmed CMV disease" || "^S={font_weight = medium} - No. / Total no. patients (%)";
	disp_overall = compress(put(0, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((0/&N) * 100, 12.1)) || ")"; 
	keep row disp_overall; 
run;

*** NEC ********************************************************************************************************;
data nec; set cmv.nec; run;
proc sort data = nec; by id dfseq; run;
data nec; set nec;
	by id;
	if first.id then number = 1; 
	if last.id then case = dfseq-160;
run;

proc freq data = nec;
	tables number / nocum out = nec_number;
run; 
proc freq data = nec;
	tables case / nocum out = nec_cases;
run; 

data _null_; set nec_number;
  call symput('N_nec', count);
run;

data nec_number; set nec_number;
	if number = 1;
	length row $ 120; row = "^S={font_weight = bold} Necrotizing enterocolitis (NEC)";
	disp_overall = compress(put(count, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((count/&N) * 100, 12.1)) || ")";  
	keep row disp_overall; 
run;

data nec_cases; set nec_cases;
	if case ~= .; 
	length row $ 120; 
	if case = 1 then row = "	^S={font_weight = bold} 1 instance" || "^S={font_weight = medium} - No. / Total no. cases (%)";
	if case = 2 then row = "	^S={font_weight = bold} 2 instances";
	if case = 3 then row = "	^S={font_weight = bold} 3 instances";
	disp_overall = compress(put(count, 12.0)) || "/" || compress(put(&N_nec, 12.0)) || " (" || compress(put(percent, 12.1)) || ")";  
	keep row disp_overall; 
run;


*** IVH ********************************************************************************************************;
data _null_; set cmv.ivh nobs=nobs;
  call symput('N_ivh',trim(left(put(nobs,8.))));
run;

data ivh_number; 
	length row $ 120; row = "^S={font_weight = bold} Intraventricular hemorrhage (IVH)";
	disp_overall = compress(put(&N_ivh, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_ivh/&N) * 100, 12.1)) || ")";  
run; 


*** PDA ********************************************************************************************************;
data _null_; set cmv.pda nobs=nobs;
  call symput('N_pda',trim(left(put(nobs,8.))));
run;

data pda_number; 
	length row $ 120; row = "^S={font_weight = bold} Patent ductus arteriosus (PDA)";
	disp_overall = compress(put(&N_pda, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_pda/&N) * 100, 12.1)) || ")";  
run; 


*** BPD ********************************************************************************************************;
data _null_; set cmv.bpd nobs=nobs;
  call symput('N_bpd',trim(left(put(nobs,8.))));
run;

data bpd_number; 
	length row $ 120; row = "^S={font_weight = bold} Bronchopulmonary dysplasia (BPD)";
	disp_overall = compress(put(&N_bpd, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_pda/&N) * 100, 12.1)) || ")";  
run; 


*** ROP ********************************************************************************************************;
data _null_; set cmv.rop nobs=nobs;
  call symput('N_rop',trim(left(put(nobs,8.))));
run;

data rop_number; 
	length row $ 120; row = "^S={font_weight = bold} Retinopathy of prematurity (ROP)";
	disp_overall = compress(put(&N_rop, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_rop/&N) * 100, 12.1)) || ")";  
run; 


*** Infection **************************************************************************************************;
data inf; set cmv.infection_all;	if culturepositive = 1; run;
proc sort data = inf; by id; run;
data inf; set inf; by id; if first.id; run;

data _null_; set inf nobs=nobs;
  call symput('N_inf',trim(left(put(nobs,8.))));
run;

data inf_number; 
	length row $ 120; row = "^S={font_weight = bold} Nosocomial Infection";
	disp_overall = compress(put(&N_inf, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_inf/&N) * 100, 12.1)) || ")";  
run; 


*** Death ******************************************************************************************************;
data death; set cmv.plate_100 (keep = id deathdate) cmv.plate_101 (keep = id deathdate); if deathdate ~= .; run;

data _null_; set death nobs=nobs;
  call symput('N_death',trim(left(put(nobs,8.))));
run;

data death_number; 
	length row $ 120; row = "^S={font_weight = bold} Death";
	disp_overall = compress(put(&N_death, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_death/&N) * 100, 12.1)) || ")";  
run; 


*** MERGE ***********************************************;
data outcome_freq; set cmv_number pda_number rop_number bpd_number nec_number nec_cases ivh_number inf_number death_number; 
	label 
		disp_overall = '00'x
		row = '00'x
	;
run;



*** PRINT ***********************************************;
options nodate orientation = portrait;
%descriptive_stat(print_rtf = 1, data_out= outcome_freq, file= "&output./annual/&outcome_freq_mon_file.outcome_freq.rtf", title = "&outcome_fre_mon_pre Outcome Frequency Summary");


