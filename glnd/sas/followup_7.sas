/* followup_7.sas
 *
 * This program creates two datasets from the five Day 7 follow-up forms:
 *  1. glnd.followup_7 = a cross-sectional summary of all five forms
 *  2. glnd.followup_7_long = a longitudinal view of follow-up days 4,5,6,7, where day is a variable and all other variables are the same
 */
 


* first sort the forms by study id;
 proc sort data= glnd.plate27; by id; run;
 proc sort data= glnd.plate28; by id; run;
 proc sort data= glnd.plate29; by id; run;
 proc sort data= glnd.plate30; by id; run;
 proc sort data= glnd.plate31; by id; run;
 
 
 /* a cross-sectional summary of all five forms*/
 data glnd.followup_7;
	* merge all plates - drop DataFax variables and patient initials ; 
 	merge 
 		/* The next three plates are the same except that the day changes! */
 		
 		
 	 	glnd.plate27 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_4  oral_kcal= oral_kcal_4  pn_aa_g= pn_aa_g_4  iv_kcal= iv_kcal_4  pn_aa_kcal= pn_aa_kcal_4  prop_kcal= prop_kcal_4
    			tube_prot= tube_prot_4  tot_aa= tot_aa_4 tube_kcal= tube_kcal_4  tot_kcal= tot_kcal_4  oral_prot= oral_prot_4  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_4  time_gluc_eve= time_gluc_eve_4  gluc_mrn= gluc_mrn_4  time_gluc_mrn= time_gluc_mrn_4  gluc_aft= gluc_aft_4
        		time_gluc_aft= time_gluc_aft_4  sofa_resp= sofa_resp_4  sofa_coag= sofa_coag_4  sofa_liver= sofa_liver_4  sofa_cardio= sofa_cardio_4
       			sofa_cns= sofa_cns_4  sofa_renal= sofa_renal_4  sofa_tot= sofa_tot_4  nar_prov= nar_prov_4  pn_lipid = pn_lipid_4  pn_cho = pn_cho_4)
       			)
       	
       			
 		glnd.plate28 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_5  oral_kcal= oral_kcal_5  pn_aa_g= pn_aa_g_5  iv_kcal= iv_kcal_5  pn_aa_kcal= pn_aa_kcal_5  prop_kcal= prop_kcal_5
    			tube_prot= tube_prot_5  tot_aa= tot_aa_5 tube_kcal= tube_kcal_5  tot_kcal= tot_kcal_5  oral_prot= oral_prot_5  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_5  time_gluc_eve= time_gluc_eve_5  gluc_mrn= gluc_mrn_5  time_gluc_mrn= time_gluc_mrn_5  gluc_aft= gluc_aft_5
        		time_gluc_aft= time_gluc_aft_5  sofa_resp= sofa_resp_5  sofa_coag= sofa_coag_5  sofa_liver= sofa_liver_5  sofa_cardio= sofa_cardio_5
       			sofa_cns= sofa_cns_5  sofa_renal= sofa_renal_5  sofa_tot= sofa_tot_5  nar_prov= nar_prov_5  pn_lipid = pn_lipid_5  pn_cho = pn_cho_5)
       			)
 
 		glnd.plate29 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_6  oral_kcal= oral_kcal_6  pn_aa_g= pn_aa_g_6  iv_kcal= iv_kcal_6  pn_aa_kcal= pn_aa_kcal_6  prop_kcal= prop_kcal_6
    			tube_prot= tube_prot_6  tot_aa= tot_aa_6 tube_kcal= tube_kcal_6  tot_kcal= tot_kcal_6  oral_prot= oral_prot_6  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_6  time_gluc_eve= time_gluc_eve_6  gluc_mrn= gluc_mrn_6  time_gluc_mrn= time_gluc_mrn_6  gluc_aft= gluc_aft_6
        		time_gluc_aft= time_gluc_aft_6  sofa_resp= sofa_resp_6  sofa_coag= sofa_coag_6  sofa_liver= sofa_liver_6  sofa_cardio= sofa_cardio_6
       			sofa_cns= sofa_cns_6  sofa_renal= sofa_renal_6  sofa_tot= sofa_tot_6  nar_prov= nar_prov_6  pn_lipid = pn_lipid_6  pn_cho = pn_cho_6)
       			)
       			
 		glnd.plate30 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_7  oral_kcal= oral_kcal_7  pn_aa_g= pn_aa_g_7  iv_kcal= iv_kcal_7  pn_aa_kcal= pn_aa_kcal_7  prop_kcal= prop_kcal_7
    			tube_prot= tube_prot_7  tot_aa= tot_aa_7 tube_kcal= tube_kcal_7  tot_kcal= tot_kcal_7  oral_prot= oral_prot_7  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_7  time_gluc_eve= time_gluc_eve_7  gluc_mrn= gluc_mrn_7  time_gluc_mrn= time_gluc_mrn_7  gluc_aft= gluc_aft_7
        		time_gluc_aft= time_gluc_aft_7  sofa_resp= sofa_resp_7  sofa_coag= sofa_coag_7  sofa_liver= sofa_liver_7  sofa_cardio= sofa_cardio_7
       			sofa_cns= sofa_cns_7  sofa_renal= sofa_renal_7  sofa_tot= sofa_tot_7  nar_prov= nar_prov_7  pn_lipid = pn_lipid_7  pn_cho = pn_cho_7)
       			)
 			
 		
 		glnd.plate31 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER);
 			
 	by id;
 run;


 /* a longitudinal view of follow-up days 4,5,6,7 */ 
 data glnd.followup_7_long;
 	set glnd.plate27 (in= from4) glnd.plate28(in= from5) glnd.plate29(in= from6) glnd.plate30(in= from7);
 	
 	* create a day variable (we are dropping the plate variable below);
 	if from4 = 1 then day= 4;
 	else if from5= 1 then day= 5;
 	else if from6 = 1 then day= 6;
 	else if from7 = 1 then day= 7;
 	
 	
 	drop dfc fcbint ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER;
 run;
 
proc print;
