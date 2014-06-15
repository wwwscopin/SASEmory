%include "&include./descriptive_stat.sas";
%include "&include./annual_toc.sas";


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
* unscheduled blood NAT results for LBWI are on a different plate (210). we have no unscheduled results currently ;
proc sort data = cmv.lbwi_blood_nat_result; by id dfseq; run;
data blood_nat; merge cmv.completedstudylist (in=a) cmv.lbwi_blood_nat_result; by id; run;
data blood_nat; set blood_nat; if nattestresult = 2 | nattestresult = 3; run;
data blood_nat; set blood_nat; by id; if first.id; run;

	data _null_; set blood_nat nobs=nobs;	call symput('cmv_inf1',trim(left(put(nobs,8.)))); run;

* unscheduled urine NAT results for LBWI are on a different plate (211). we have no unscheduled results currently ;
proc sort data = cmv.lbwi_urine_nat_result; by id dfseq; run;
data urine_nat; merge cmv.completedstudylist (in=a) cmv.lbwi_urine_nat_result; by id; run;
data urine_nat; set urine_nat; if urinetestresult = 2 | urinetestresult = 3; run;
data urine_nat; set urine_nat; by id; if first.id; run;

	/*data _null_; set blood_nat nobs=nobs;	call symput('cmv_inf2',trim(left(put(nobs,8.)))); run;*/
	%let cmv_inf2 = 0;


data cmv_infection1; 
	length row $ 120; row = "^S={font_weight = bold} Confirmed CMV infection";
	disp = compress(put(&cmv_inf1+&cmv_inf2, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put(((&cmv_inf1+&cmv_inf2)/&N) * 100, 12.1)) || ")";  
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
data nec; set cmv.nec; run;
proc sort data = nec; by id dfseq; run;
data nec; set nec;	by id;	if first.id; center = floor(id/1000000); run;
	data _null_; set nec nobs=nobs; call symput('N_nec',trim(left(put(nobs,8.)))); run;
data nec1; set nec; if center = 1; run;	
	data _null_; set nec1 nobs=nobs; call symput('N_nec1',trim(left(put(nobs,8.)))); run;
data nec2; set nec; if center = 2; run;	
	data _null_; set nec2 nobs=nobs; call symput('N_nec2',trim(left(put(nobs,8.)))); run;
data nec3; set nec; if center = 3; run;	
	/*data _null_; set nec3 nobs=nobs; call symput('N_nec3',trim(left(put(nobs,8.)))); run;*/
	/*-*-*-*-*-*-*-*-**-*-*-*-*-*/
	/*-*/ %let N_nec3 = 0; /*-*/
	/*-*-*-*-*-*-*-*-*-*-*-*-*-*/

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
data nec; set cmv.nec; center = floor(id/1000000); if laparotomydone = 1 | abdominaldrain = 1 | bowelresecdone = 1 | surgeryreqd = 1; run;
	data _null_; set nec nobs=nobs; call symput('N_nec_surg',trim(left(put(nobs,8.)))); run;
data nec1; set nec; if center = 1; run;	
	data _null_; set nec1 nobs=nobs; call symput('N_nec1_surg',trim(left(put(nobs,8.)))); run;
data nec2; set nec; if center = 2; run;	
	data _null_; set nec2 nobs=nobs; call symput('N_nec2_surg',trim(left(put(nobs,8.)))); run;
data nec3; set nec; if center = 3; run;	
	/*data _null_; set nec3 nobs=nobs; call symput('N_nec3_surg',trim(left(put(nobs,8.)))); run;*/
	/*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*/
	/*-*/ %let N_nec3_surg = 0; /*-*/
	/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/

data nec_number_surg; 
	length row $ 120; row = "	Surgical NEC";
	disp = compress(put(&N_nec_surg, 12.0)) || "/" || compress(put(&N_nec, 12.0)) || " (" || compress(put((&N_nec_surg/&N_nec) * 100, 12.1)) || ")";  
	disp1 = ""; *compress(put(&N_nec1_surg, 12.0)) || "/" || compress(put(&N1_nec1, 12.0)) || " (" || compress(put((&N_nec1_surg/&N1_nec1) * 100, 12.1)) || ")";
	disp2 = ""; *compress(put(&N_nec2_surg, 12.0)) || "/" || compress(put(&N2_nec1, 12.0)) || " (" || compress(put((&N_nec2_surg/&N2_nec2) * 100, 12.1)) || ")";
	disp3 = ""; *compress(put(&N_nec3_surg, 12.0)) || "/" || compress(put(&N3_nec3, 12.0)) || " (" || compress(put((&N_nec3_surg/&N3_nec3) * 100, 12.1)) || ")";
run; 


*** IVH ********************************************************************************************************;
data ivh; set cmv.ivh; center = floor(id/1000000); run;
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
**** grade3 ivh ;
****************;
proc sort data = cmv.ivh_image out=ivh_grade3; by id dfseq; run;

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
	disp = compress(put(&N_ivh_grade3, 12.0)) || "/" || compress(put(&N_ivh, 12.0)) || " (" || compress(put((&N_ivh_grade3/&N_ivh) * 100, 12.1)) || ")";  
	disp1 = ""; *compress(put(&N_ivh1_grade3, 12.0)) || "/" || compress(put(&N_ivh1, 12.0)) || " (" || compress(put((&N_ivh1_grade3/&N_ivh1) * 100, 12.1)) || ")";
	disp2 = ""; *compress(put(&N_ivh2_grade3, 12.0)) || "/" || compress(put(&N_ivh2, 12.0)) || " (" || compress(put((&N_ivh2_grade3/&N_ivh2) * 100, 12.1)) || ")";
	disp3 = ""; *compress(put(&N_ivh3_grade3, 12.0)) || "/" || compress(put(&N_ivh3, 12.0)) || " (" || compress(put((&N_ivh3_grade3/&N_ivh3) * 100, 12.1)) || ")";
run; 


*** PDA ********************************************************************************************************;
data pda; set cmv.pda; center = floor(id/1000000); run;
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
data pda; set cmv.pda; center = floor(id/1000000); if pdasurgery = 1; run;
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
data bpd; set cmv.bpd; center = floor(id/1000000); run;
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


*** ROP ********************************************************************************************************;
data rop; set cmv.rop; center = floor(id/1000000); run;
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


*** Infection **************************************************************************************************;
data inf; set cmv.infection_all;	if culturepositive = 1; center = floor(id/1000000); run;
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
	length row $ 120; row = "^S={font_weight = bold} Nosocomial Infection";
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
					if _LABEL_ = "SiteBlood" then row = "	Blood Infection";
					if _LABEL_ = "SiteCNS" then row = "	CNS Infection";
					if _LABEL_ = "SiteUT" then row = "	UT Infection";
					if _LABEL_ = "SiteCardio" then row = "	Cardiovascular Infection";
					if _LABEL_ = "SiteLowerResp" then row = "	Lower Respiratory Infection";
					if _LABEL_ = "SiteGI" then row = "	GI Infection";
					if _LABEL_ = "SiteSurgical" then row = "	Surgical Site Infection";
					if _LABEL_ = "SiteOther" then row = "	Other Infection";	
				if row = "" then delete;
				disp = compress(put(COL1*COL4, 12.0)) || "/" || compress(put(COL1, 12.0)) || " (" || compress(put(COL4 * 100, 12.1)) || ")";
				keep disp row;				
			run;
	



*** Death ******************************************************************************************************;
data death; set cmv.plate_100 (keep = id deathdate) cmv.plate_101 (keep = id deathdate); if deathdate ~= .; center = floor(id/1000000); run;
	data _null_; set death nobs=nobs; call symput('N_death',trim(left(put(nobs,8.)))); run;
data death1; set death; if center = 1; run;	
	data _null_; set death1 nobs=nobs; call symput('N_death1',trim(left(put(nobs,8.)))); run;
data death2; set death; if center = 2; run;	
	data _null_; set death2 nobs=nobs; call symput('N_death2',trim(left(put(nobs,8.)))); run;
data death3; set death; if center = 3; run;	
	/*data _null_; set death3 nobs=nobs; call symput('N_death3',trim(left(put(nobs,8.)))); run;*/
	/*-*-*-*-*-*-*-*-**-*-*-*-*-*/
	/*-*/ %let N_death3 = 0; /*-*/
	/*-*-*-*-*-*-*-*-*-*-*-*-*-*/

data death_number; 
	length row $ 120; row = "^S={font_weight = bold} Death";
	disp = compress(put(&N_death, 12.0)) || "/" || compress(put(&N, 12.0)) || " (" || compress(put((&N_death/&N) * 100, 12.1)) || ")";  
	disp1 = compress(put(&N_death1, 12.0)) || "/" || compress(put(&N1, 12.0)) || " (" || compress(put((&N_death1/&N1) * 100, 12.1)) || ")";
	disp2 = compress(put(&N_death2, 12.0)) || "/" || compress(put(&N2, 12.0)) || " (" || compress(put((&N_death2/&N2) * 100, 12.1)) || ")";
	disp3 = compress(put(&N_death3, 12.0)) || "/" || compress(put(&N3, 12.0)) || " (" || compress(put((&N_death3/&N3) * 100, 12.1)) || ")";
run; 



*** MERGE ***********************************************;
data space; length row $ 120; row = ""; run;
data outcome_freq; set 	cmv_disease cmv_infection space pda_number pda_number_surg rop_number bpd_number 
										nec_number nec_number_surg ivh_number ivh_number_grade3 inf_number inf_details death_number; 
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
ods rtf file = "&output./april2011abstracts/outcome_freq_bysite.rtf"  style=journal startpage = no bodytitle;
	title1 "Incidence of Outcome"; 			
	proc print data = outcome_freq label noobs split = "*" style(header) = {just=center} contents = "";
		id  row /style(data) = [font_size=1.8 font_style=Roman];
		by  row notsorted;
		var disp space disp1 disp2 disp3 /style(data) = [just=center font_size=1.8];
	run;
ods rtf close;


