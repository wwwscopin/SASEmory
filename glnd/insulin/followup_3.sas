/* followup_3.sas
 *
 * This program creates two datasets from the five Day 3 follow-up forms:
 *  1. glnd.followup_3 = a cross-sectional summary of all five forms
 *  2. glnd.followup_3_long = a longitudinal view of follow-up days 1,2,3, where day is a variable and all other variables are the same
 */
 


* first sort the forms by study id;
 proc sort data= glnd.plate22; by id; run;
 proc sort data= glnd.plate23; by id; run;
 proc sort data= glnd.plate24; by id; run;
 proc sort data= glnd.plate25; by id; run;
 proc sort data= glnd.plate26; by id; run;
 
 
 /* a cross-sectional summary of all five forms*/
 data glnd.followup_3;
	* merge all plates - drop DataFax variables and patient initials ; 
 	merge 
 		glnd.plate22 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER)
 		
 		/* The next three plates are the same except that the day changes! */
 		 		  
 		glnd.plate23 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
 			
		        tot_pn= tot_pn_1  oral_kcal= oral_kcal_1  pn_aa_g= pn_aa_g_1  iv_kcal= iv_kcal_1  pn_aa_kcal= pn_aa_kcal_1  prop_kcal= prop_kcal_1
    			tube_prot= tube_prot_1  tot_aa= tot_aa_1 tube_kcal= tube_kcal_1  tot_kcal= tot_kcal_1  oral_prot= oral_prot_1  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_1  time_gluc_eve= time_gluc_eve_1  gluc_mrn= gluc_mrn_1  time_gluc_mrn= time_gluc_mrn_1  gluc_aft= gluc_aft_1
        		time_gluc_aft= time_gluc_aft_1  sofa_resp= sofa_resp_1  sofa_coag= sofa_coag_1  sofa_liver= sofa_liver_1  sofa_cardio= sofa_cardio_1
       			sofa_cns= sofa_cns_1  sofa_renal= sofa_renal_1  sofa_tot= sofa_tot_1  nar_prov= nar_prov_1 pn_lipid = pn_lipid_1  pn_cho = pn_cho_1 )
       			)
       			
 		glnd.plate24 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_2  oral_kcal= oral_kcal_2  pn_aa_g= pn_aa_g_2  iv_kcal= iv_kcal_2  pn_aa_kcal= pn_aa_kcal_2  prop_kcal= prop_kcal_2
    			tube_prot= tube_prot_2  tot_aa= tot_aa_2 tube_kcal= tube_kcal_2  tot_kcal= tot_kcal_2  oral_prot= oral_prot_2  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_2  time_gluc_eve= time_gluc_eve_2  gluc_mrn= gluc_mrn_2  time_gluc_mrn= time_gluc_mrn_2  gluc_aft= gluc_aft_2
        		time_gluc_aft= time_gluc_aft_2  sofa_resp= sofa_resp_2  sofa_coag= sofa_coag_2  sofa_liver= sofa_liver_2  sofa_cardio= sofa_cardio_2
       			sofa_cns= sofa_cns_2  sofa_renal= sofa_renal_2  sofa_tot= sofa_tot_2  nar_prov= nar_prov_2  pn_lipid = pn_lipid_2  pn_cho = pn_cho_2)
       			)
 	
 
 		glnd.plate25 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_3  oral_kcal= oral_kcal_3  pn_aa_g= pn_aa_g_3  iv_kcal= iv_kcal_3  pn_aa_kcal= pn_aa_kcal_3  prop_kcal= prop_kcal_3
    			tube_prot= tube_prot_3  tot_aa= tot_aa_3 tube_kcal= tube_kcal_3  tot_kcal= tot_kcal_3  oral_prot= oral_prot_3  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_3  time_gluc_eve= time_gluc_eve_3  gluc_mrn= gluc_mrn_3  time_gluc_mrn= time_gluc_mrn_3  gluc_aft= gluc_aft_3
        		time_gluc_aft= time_gluc_aft_3  sofa_resp= sofa_resp_3  sofa_coag= sofa_coag_3  sofa_liver= sofa_liver_3  sofa_cardio= sofa_cardio_3
       			sofa_cns= sofa_cns_3  sofa_renal= sofa_renal_3  sofa_tot= sofa_tot_3  nar_prov= nar_prov_3  pn_lipid = pn_lipid_3  pn_cho = pn_cho_3)
       			)
 	
 		glnd.plate26 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER);
 			
 	by id;
 run;


 /* a longitudinal view of follow-up days 1,2,3 */ 
 data glnd.followup_3_long;
 	set glnd.plate23 (in= from1) glnd.plate24(in= from2) glnd.plate25(in= from3) ;
 	
 	* create a day variable (we are dropping the plate variable below);
 	if from1 = 1 then day= 1;
 	else if from2 = 1 then day= 2;
 	else if from3 = 1 then day= 3;
 	
 	
 	drop dfc fcbint ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSEQ DFSTATUS DFVALID DFRASTER;
 run;

proc print;
	var id day tot_insulin;
run;
