%include "&include./descriptive_stat.sas";
*%include "&include./annual_toc.sas";


* TOTAL NUMBER OF PATIENTS IN STUDY **********************;
	data _null_; set cmv.completedstudylist nobs=nobs;	call symput('N',trim(left(put(nobs,8.)))); run;
data completedstudylist1; set cmv.completedstudylist; if center = 1; run;
	data _null_; set completedstudylist1 nobs=nobs;	call symput('N1',trim(left(put(nobs,8.)))); run;
data completedstudylist2; set cmv.completedstudylist; if center = 2; run;
	data _null_; set completedstudylist2 nobs=nobs;	call symput('N2',trim(left(put(nobs,8.)))); run;
data completedstudylist3; set cmv.completedstudylist; if center = 3; run;
	data _null_; set completedstudylist3 nobs=nobs;	call symput('N3',trim(left(put(nobs,8.)))); run;


*** CMV disease ************************************************************************************************;

* SEE OUTCOME_FREQ.SAS FOR REAL CMV DISEASE FREQ CODE ;

data cmv_disease; 
	length row $ 120; row = "^S={font_weight = bold} Confirmed CMV disease" || "^S={font_weight = medium} - No. / Total no. patients (%)";
	disp = compress(put(0, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((0/&N) * 100, 12.1)) || ")"; 
	keep row disp; 
run;


*** CMV infection **********************************************************************************************;

* keep patients who have completed study, check to see if any positive result, keep 1 positive result per patient ;

data blood_nat; set cmv.lbwi_blood_nat_result; keep id dfseq nattestresult; run;
data blood_nat_unscheduled; set cmv.plate_210_long; keep id dfseq nattestresult; run;

data blood_nat; set blood_nat blood_nat_unscheduled; run;
proc sort data = blood_nat; by id dfseq; run;

data blood_nat; merge cmv.completedstudylist (in=a) blood_nat; by id; if a; run;

data blood_nat; set blood_nat; if nattestresult = 2 | nattestresult = 3; run;
data blood_nat; set blood_nat; by id; if first.id; run;

	data _null_; set blood_nat nobs=nobs;	call symput('cmv_inf1',trim(left(put(nobs,8.)))); run;


data urine_nat; set cmv.lbwi_urine_nat_result; keep id dfseq urinetestresult; run;
data urine_nat_unscheduled; set cmv.plate_211_long; if dfseq = 91 | dfseq = 92 | dfseq = 93; keep id dfseq nattestresult; run;

data urine_nat; set urine_nat urine_nat_unscheduled; run;
proc sort data = urine_nat; by id dfseq; run;

data urine_nat; merge cmv.completedstudylist (in=a) urine_nat; by id; if a; run;
data urine_nat; set urine_nat; if urinetestresult = 2 | urinetestresult = 3; run;
data urine_nat; set urine_nat; by id; if first.id; run;

	data _null_; set urine_nat nobs=nobs;	call symput('cmv_inf2',trim(left(put(nobs,8.)))); run;


data overall_nat; set blood_nat urine_nat; run;
proc sort data = overall_nat; by id; run;
data overall_nat; set overall_nat; by id; if first.id; run;

	data _null_; set overall_nat nobs=nobs;	call symput('cmv_inf',trim(left(put(nobs,8.)))); run;


data cmv_infection1; 
	length row $ 120; row = "^S={font_weight = bold} Confirmed CMV infection";
	disp = compress(put(&cmv_inf, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put(((&cmv_inf)/&N) * 100, 12.1)) || ")";  
run;
data cmv_infection2; 
	length row $ 120; row = "	Positive NAT result, LBWI blood";
	disp = compress(put(&cmv_inf1, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&cmv_inf1/&N) * 100, 12.1)) || ")";  
run;
data cmv_infection3; 
	length row $ 120; row = "	Positive NAT result, LBWI urine";
	disp = compress(put(&cmv_inf2, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&cmv_inf2/&N) * 100, 12.1)) || ")";  
run;

data cmv_infection; set cmv_infection1 cmv_infection2 cmv_infection3; run;


*** NEC ********************************************************************************************************;
proc sort data = cmv.nec out = nec; by id; run;
data nec; merge nec (in=b) cmv.completedstudylist (in=a); by id; if a & b; run;
proc sort data = nec; by id dfseq; run;
data nec; set nec;	by id;	if first.id; center = floor(id/1000000); run;
	data _null_; set nec nobs=nobs; call symput('N_nec',trim(left(put(nobs,8.)))); run;
data nec1; set nec; if center = 1; run;	
	data _null_; set nec1 nobs=nobs; call symput('N_nec1',trim(left(put(nobs,8.)))); run;
data nec2; set nec; if center = 2; run;	
	data _null_; set nec2 nobs=nobs; call symput('N_nec2',trim(left(put(nobs,8.)))); run;
data nec3; set nec; if center = 3; run;	
	data _null_; set nec3 nobs=nobs; call symput('N_nec3',trim(left(put(nobs,8.)))); run;

data nec_number; 
	length row $ 120; row = "^S={font_weight = bold} Necrotizing enterocolitis (NEC)";
	disp = compress(put(&N_nec, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_nec/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_nec1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_nec1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_nec2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_nec2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_nec3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_nec3/&N3) * 100, 12.1)) || ")";
run; 

******************;
**** surgical nec ;
******************;
data nec; merge nec (in=b) cmv.completedstudylist (in=a); by id; if a & b; 
	center = floor(id/1000000); if laparotomydone = 1 | abdominaldrain = 1 | bowelresecdone = 1 | surgeryreqd = 1; run;

	data _null_; set nec nobs=nobs; call symput('N_nec_surg',trim(left(put(nobs,8.)))); run;
data nec1; set nec; if center = 1; run;	
	data _null_; set nec1 nobs=nobs; call symput('N_nec1_surg',trim(left(put(nobs,8.)))); run;
data nec2; set nec; if center = 2; run;	
	data _null_; set nec2 nobs=nobs; call symput('N_nec2_surg',trim(left(put(nobs,8.)))); run;
data nec3; set nec; if center = 3; run;	
	data _null_; set nec3 nobs=nobs; call symput('N_nec3_surg',trim(left(put(nobs,8.)))); run;

data nec_number_surg; 
	length row $ 120; row = "	Surgical NEC";
	disp = compress(put(&N_nec_surg, 12.0)) || "/" || compress(put(&N_nec, 12.0)) || " (" || compress(put((&N_nec_surg/&N_nec) * 100, 12.1)) || ")";  
	disp1 = ""; *compress(put(&N_nec1_surg, 12.0)) || "/" || compress(put(&N1_nec1, 12.0)) || " (" || compress(put((&N_nec1_surg/&N1_nec1) * 100, 12.1)) || ")";
	disp2 = ""; *compress(put(&N_nec2_surg, 12.0)) || "/" || compress(put(&N2_nec1, 12.0)) || " (" || compress(put((&N_nec2_surg/&N2_nec2) * 100, 12.1)) || ")";
	disp3 = ""; *compress(put(&N_nec3_surg, 12.0)) || "/" || compress(put(&N3_nec3, 12.0)) || " (" || compress(put((&N_nec3_surg/&N3_nec3) * 100, 12.1)) || ")";
run; 


*** IVH ********************************************************************************************************;
proc sort data = cmv.ivh out = ivh; by id; run;
data ivh; merge ivh (in=b) cmv.completedstudylist (in=a); by id; if a & b; center = floor(id/1000000); run;
	data _null_; set ivh nobs=nobs; call symput('N_ivh',trim(left(put(nobs,8.)))); run;
data ivh1; set ivh; if center = 1; run;	
	data _null_; set ivh1 nobs=nobs; call symput('N_ivh1',trim(left(put(nobs,8.)))); run;
data ivh2; set ivh; if center = 2; run;	
	data _null_; set ivh2 nobs=nobs; call symput('N_ivh2',trim(left(put(nobs,8.)))); run;
data ivh3; set ivh; if center = 3; run;	
	data _null_; set ivh3 nobs=nobs; call symput('N_ivh3',trim(left(put(nobs,8.)))); run;

data ivh_number; 
	length row $ 120; row = "^S={font_weight = bold} Intraventricular hemorrhage (IVH)";
	disp = compress(put(&N_ivh, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_ivh/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_ivh1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_ivh1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_ivh2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_ivh2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_ivh3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_ivh3/&N3) * 100, 12.1)) || ")";
run; 


****************;
**** grade2 ivh ;
****************;
proc sort data = cmv.ivh_image out=ivh_grade2; by id dfseq; run;
data ivh_grade2; merge ivh_grade2 (in=b) cmv.completedstudylist (in=a); by id; if a & b; run;

data cmv.ivh_grade2; set ivh_grade2;
	by id; retain grade2;
	
	if first.id then grade2 = 0; 

		if leftivhgrade = 2 | leftivhgrade = 3 | leftivhgrade = 4 | rightivhgrade = 2 | rightivhgrade = 3 | rightivhgrade = 4 then grade2 = 1;
	
	if last.id;
	if grade2 = 1;

	center = floor(id/1000000); 
	keep center id dfseq leftivhgrade rightivhgrade grade2;
run;

	data _null_; set cmv.ivh_grade2 nobs=nobs; call symput('N_ivh_grade2',trim(left(put(nobs,8.)))); run;

data ivh_number_grade2; 
	length row $ 120; row = "	Grade II/III/IV IVH";
	disp = compress(put(&N_ivh_grade2, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_ivh_grade2/&N) * 100, 12.1)) || ")";  
run; 


****************;
**** grade3 ivh ;
****************;
proc sort data = cmv.ivh_image out=ivh_grade3; by id dfseq; run;
data ivh_grade3; merge ivh_grade3 (in=b) cmv.completedstudylist (in=a); by id; if a & b; run;

data cmv.ivh_grade3; set ivh_grade3;
	by id; retain grade3;
	
	if first.id then grade3 = 0; 

		if leftivhgrade = 3 | leftivhgrade = 4 | rightivhgrade = 3 | rightivhgrade = 4 then grade3 = 1;
	
	if last.id;
	if grade3 = 1;

	center = floor(id/1000000); 
	keep center id dfseq leftivhgrade rightivhgrade grade3;
run;

	data _null_; set cmv.ivh_grade3 nobs=nobs; call symput('N_ivh_grade3',trim(left(put(nobs,8.)))); run;
data ivh1_grade3; set cmv.ivh_grade3; if center = 1; run;	
	data _null_; set ivh1_grade3 nobs=nobs; call symput('N_ivh1_grade3',trim(left(put(nobs,8.)))); run;
data ivh2_grade3; set ivh_grade3; if center = 2; run;	
	data _null_; set ivh2_grade3 nobs=nobs; call symput('N_ivh2_grade3',trim(left(put(nobs,8.)))); run;
data ivh3_grade3; set ivh_grade3; if center = 3; run;	
	data _null_; set ivh3_grade3 nobs=nobs; call symput('N_ivh3_grade3',trim(left(put(nobs,8.)))); run;

data ivh_number_grade3; 
	length row $ 120; row = "	Grade III/IV IVH";
	disp = compress(put(&N_ivh_grade3, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_ivh_grade3/&N) * 100, 12.1)) || ")";  
	disp1 = ""; *compress(put(&N_ivh1_grade3, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_ivh1_grade3/&N1) * 100, 12.1)) || ")";
	disp2 = ""; *compress(put(&N_ivh2_grade3, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_ivh2_grade3/&N2) * 100, 12.1)) || ")";
	disp3 = ""; *compress(put(&N_ivh3_grade3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_ivh3_grade3/&N3) * 100, 12.1)) || ")";
run; 


*** PDA ********************************************************************************************************;
proc sort data = cmv.pda out = pda; by id; run;
data pda; set pda; center = floor(id/1000000); run;
	data _null_; set pda nobs=nobs; call symput('N_pda',trim(left(put(nobs,8.)))); run;
data pda1; set pda; if center = 1; run;	
	data _null_; set pda1 nobs=nobs; call symput('N_pda1',trim(left(put(nobs,8.)))); run;
data pda2; set pda; if center = 2; run;	
	data _null_; set pda2 nobs=nobs; call symput('N_pda2',trim(left(put(nobs,8.)))); run;
data pda3; set pda; if center = 3; run;	
	data _null_; set pda3 nobs=nobs; call symput('N_pda3',trim(left(put(nobs,8.)))); run;

data pda_number; 
	length row $ 120; row = "^S={font_weight = bold} Patent ductus arteriosus (PDA)";
	disp = compress(put(&N_pda, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_pda/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_pda1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_pda1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_pda2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_pda2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_pda3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_pda3/&N3) * 100, 12.1)) || ")";
run; 

******************;
**** surgical pda ;
******************;
proc sort data = cmv.pda out = pda; by id; run;
data pda; set pda; center = floor(id/1000000); if pdasurgery = 1; run;
	data _null_; set pda nobs=nobs; call symput('N_pda_surg',trim(left(put(nobs,8.)))); run;
data pda1; set pda; if center = 1; run;	
	data _null_; set pda1 nobs=nobs; call symput('N_pda1_surg',trim(left(put(nobs,8.)))); run;
data pda2; set pda; if center = 2; run;	
	data _null_; set pda2 nobs=nobs; call symput('N_pda2_surg',trim(left(put(nobs,8.)))); run;
data pda3; set pda; if center = 3; run;	
	data _null_; set pda3 nobs=nobs; call symput('N_pda3_surg',trim(left(put(nobs,8.)))); run;

data pda_number_surg; 
	length row $ 120; row = "	Surgical PDA";
	disp = compress(put(&N_pda_surg, 12.0)) || "/" || compress(put(&N_pda, 12.0)) || " (" || compress(put((&N_pda_surg/&N_pda) * 100, 12.1)) || ")";  
	disp1 = ""; *compress(put(&N_pda1_surg, 12.0)) || "/" || compress(put(&N1_pda1, 12.0)) || " (" || compress(put((&N_pda1_surg/&N1_pda1) * 100, 12.1)) || ")";
	disp2 = ""; *compress(put(&N_pda2_surg, 12.0)) || "/" || compress(put(&N2_pda1, 12.0)) || " (" || compress(put((&N_pda2_surg/&N2_pda2) * 100, 12.1)) || ")";
	disp3 = ""; *compress(put(&N_pda3_surg, 12.0)) || "/" || compress(put(&N3_pda3, 12.0)) || " (" || compress(put((&N_pda3_surg/&N3_pda3) * 100, 12.1)) || ")";
run; 


*** BPD ********************************************************************************************************;
proc sort data = cmv.bpd out = bpd; by id; run;
data bpd; merge bpd (in=b) cmv.completedstudylist (in=a); by id; if a&b; center = floor(id/1000000); run;
	data _null_; set bpd nobs=nobs; call symput('N_bpd',trim(left(put(nobs,8.)))); run;
data bpd1; set bpd; if center = 1; run;	
	data _null_; set bpd1 nobs=nobs; call symput('N_bpd1',trim(left(put(nobs,8.)))); run;
data bpd2; set bpd; if center = 2; run;	
	data _null_; set bpd2 nobs=nobs; call symput('N_bpd2',trim(left(put(nobs,8.)))); run;
data bpd3; set bpd; if center = 3; run;	
	data _null_; set bpd3 nobs=nobs; call symput('N_bpd3',trim(left(put(nobs,8.)))); run;

data bpd_number; 
	length row $ 120; row = "^S={font_weight = bold} Bronchopulmonary dysplasia (BPD)";
	disp = compress(put(&N_bpd, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_bpd/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_bpd1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_bpd1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_bpd2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_bpd2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_bpd3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_bpd3/&N3) * 100, 12.1)) || ")";
run; 

/*
*** ROP ********************************************************************************************************;
proc sort data = cmv.rop out = rop; by id; run;
data rop; set rop; center = floor(id/1000000); run;
	data _null_; set rop nobs=nobs; call symput('N_rop',trim(left(put(nobs,8.)))); run;
data rop1; set rop; if center = 1; run;	
	data _null_; set rop1 nobs=nobs; call symput('N_rop1',trim(left(put(nobs,8.)))); run;
data rop2; set rop; if center = 2; run;	
	data _null_; set rop2 nobs=nobs; call symput('N_rop2',trim(left(put(nobs,8.)))); run;
data rop3; set rop; if center = 3; run;	
	data _null_; set rop3 nobs=nobs; call symput('N_rop3',trim(left(put(nobs,8.)))); run;

data rop_number; 
	length row $ 120; row = "^S={font_weight = bold} Retinopathy of prematurity (ROP)";
	disp = compress(put(&N_rop, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_rop/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_rop1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_rop1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_rop2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_rop2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_rop3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_rop3/&N3) * 100, 12.1)) || ")";
run; 
*/

*** Infection **************************************************************************************************;
proc sort data = cmv.infection_all out = inf; by id; run;
data inf; merge inf (in=b) cmv.completedstudylist (in=a); by id; if a&b; if culturepositive = 1; center = floor(id/1000000); run;
proc sort data = inf; by id; run;
data inf; set inf; by id; if first.id; run;
	data _null_; set inf nobs=nobs; call symput('N_inf',trim(left(put(nobs,8.)))); run;
data inf1; set inf; if center = 1; run;	
	data _null_; set inf1 nobs=nobs; call symput('N_inf1',trim(left(put(nobs,8.)))); run;
data inf2; set inf; if center = 2; run;	
	data _null_; set inf2 nobs=nobs; call symput('N_inf2',trim(left(put(nobs,8.)))); run;
data inf3; set inf; if center = 3; run;	
	data _null_; set inf3 nobs=nobs; call symput('N_inf3',trim(left(put(nobs,8.)))); run;

data inf_number; 
	length row $ 120; row = "^S={font_weight = bold} Any Nosocomial Infection";
	disp = compress(put(&N_inf, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_inf/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_inf1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_inf1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_inf2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_inf2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_inf3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_inf3/&N3) * 100, 12.1)) || ")";
run; 


			proc means data = inf fw=5 maxdec=1 nonobs n mean ;
				var siteblood sitecns siteut sitecardio sitelowerresp sitegi sitesurgical siteother;
				output out = inf_freq; *sum(siteblood) = &var._sum n(&var) = &var._n;
			run;

			proc transpose data=inf_freq out=inf_freq; run;

			data inf_details; set inf_freq;	
				length row $ 120; 
					if _LABEL_ = "SiteBlood" then row = "^S={font_weight = bold} BSI";
					if _LABEL_ = "SiteCNS" then row = "^S={font_weight = bold} CNS Infection";
					if _LABEL_ = "SiteUT" then row = "^S={font_weight = bold} UTI";
					if _LABEL_ = "SiteCardio" then row = "^S={font_weight = bold} Cardiovascular Infection";
					if _LABEL_ = "SiteLowerResp" then row = "^S={font_weight = bold} Lower Respiratory Infection";
					if _LABEL_ = "SiteGI" then row = "^S={font_weight = bold} GI Infection";
					if _LABEL_ = "SiteSurgical" then row = "^S={font_weight = bold} Surgical Site Infection";
					if _LABEL_ = "SiteOther" then row = "^S={font_weight = bold} Other Infection";	
				if row = "" then delete;
				disp = compress(put(COL1*COL4, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put(COL1*COL4/&N * 100, 12.1)) || ")";
				keep disp row;				
			run;
	



*** Death ******************************************************************************************************;
proc sort data = cmv.plate_100 out = death; by id; run;
proc sort data = cmv.plate_101 out = death2; by id; run;
data death2; set death2; if deathdate ~= .; run;
data death; merge death (keep = id deathdate in=b) death2 (keep = id deathdate in=c) cmv.completedstudylist (in=a); by id; if a & (b|c); 
	center = floor(id/1000000); run;

data cmv.death; set death; run;

	data _null_; set death nobs=nobs; call symput('N_death',trim(left(put(nobs,8.)))); run;
data death1; set death; if center = 1; run;	
	data _null_; set death1 nobs=nobs; call symput('N_death1',trim(left(put(nobs,8.)))); run;
data death2; set death; if center = 2; run;	
	data _null_; set death2 nobs=nobs; call symput('N_death2',trim(left(put(nobs,8.)))); run;
data death3; set death; if center = 3; run;	
	data _null_; set death3 nobs=nobs; call symput('N_death3',trim(left(put(nobs,8.)))); run;

data death_number; 
	length row $ 120; row = "^S={font_weight = bold} Death";
	disp = compress(put(&N_death, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_death/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_death1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_death1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_death2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_death2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_death3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_death3/&N3) * 100, 12.1)) || ")";
run; 



*** MERGE ***********************************************;
data space; length row $ 120; row = ""; run;
data outcome_freq; set 	cmv_disease cmv_infection space pda_number pda_number_surg /*rop_number*/ bpd_number 
										nec_number nec_number_surg ivh_number ivh_number_grade2 ivh_number_grade3 inf_number inf_details death_number; 
	length space $ 50; space = "	";
	label 
		disp = "All Sites"
		disp1 = "EUHM"
		disp2 = "GMH"
		disp3 = "NSH"
		space = '00'x
		row = '00'x
	;
run;

*** PRINT ***********************************************;
options nodate orientation = portrait;
ods rtf file = "&output./monthly_internal/outcome_freq_bysite.rtf"  style=journal toc_data startpage = no bodytitle;
	ods noproctitle proclabel "Incidence of Outcome";
	title1 "Incidence of Outcome"; 			
	proc print data = outcome_freq label noobs split = "*" style(header) = {just=center} contents = "";
		id  row /style(data) = [font_size=1.8 font_style=Roman];
		by  row notsorted;
		var disp space disp1 disp2 disp3 /style(data) = [just=center font_size=1.8];
	run;
	ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
ods rtf close;


