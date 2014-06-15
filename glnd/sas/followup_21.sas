/* followup_21.sas
 *
 * This program creates two datasets from the eight Day 21 follow-up forms:
 *  1. glnd.followup_21 = a cross-sectional summary of all five forms
 *  2. glnd.followup_21_long = a longitudinal view of follow-up days 15,16,17,18,19,20,21 where day is a variable and all other variables are the same
 */
 


* first sort the forms by study id;
 proc sort data= glnd.plate32; by id; run;
 proc sort data= glnd.plate33; by id; run;
 proc sort data= glnd.plate34; by id; run;
 proc sort data= glnd.plate35; by id; run;
 proc sort data= glnd.plate36; by id; run;
 proc sort data= glnd.plate37; by id; run;
 proc sort data= glnd.plate38; by id; run;
 proc sort data= glnd.plate39; by id; run;
 
 /* a cross-sectional summary of all five forms*/
 data glnd.followup_21;
	* merge all plates - where seq id matches day 21 f/u - drop DataFax variables and patient initials ; 
 	merge 
 		/* The next three plates are the same except that the day changes! */
 		
 		
 	 	 glnd.plate32 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_15  oral_kcal= oral_kcal_15  pn_aa_g= pn_aa_g_15  iv_kcal= iv_kcal_15  pn_aa_kcal= pn_aa_kcal_15  prop_kcal= prop_kcal_15
    			tube_prot= tube_prot_15  tot_aa= tot_aa_15 tube_kcal= tube_kcal_15  tot_kcal= tot_kcal_15  oral_prot= oral_prot_15  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_15  time_gluc_eve= time_gluc_eve_15  gluc_mrn= gluc_mrn_15  time_gluc_mrn= time_gluc_mrn_15  gluc_aft= gluc_aft_15
        		time_gluc_aft= time_gluc_aft_15  sofa_resp= sofa_resp_15  sofa_coag= sofa_coag_15  sofa_liver= sofa_liver_15  sofa_cardio= sofa_cardio_15
       			sofa_cns= sofa_cns_15  sofa_renal= sofa_renal_15  sofa_tot= sofa_tot_15  nar_prov= nar_prov_15  pn_lipid = pn_lipid_15  pn_cho = pn_cho_15)
       			)
       	glnd.plate33(drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_16  oral_kcal= oral_kcal_16  pn_aa_g= pn_aa_g_16  iv_kcal= iv_kcal_16  pn_aa_kcal= pn_aa_kcal_16  prop_kcal= prop_kcal_16
    			tube_prot= tube_prot_16  tot_aa= tot_aa_16 tube_kcal= tube_kcal_16  tot_kcal= tot_kcal_16  oral_prot= oral_prot_16  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_16  time_gluc_eve= time_gluc_eve_16  gluc_mrn= gluc_mrn_16  time_gluc_mrn= time_gluc_mrn_16  gluc_aft= gluc_aft_16
        		time_gluc_aft= time_gluc_aft_16  sofa_resp= sofa_resp_16  sofa_coag= sofa_coag_16  sofa_liver= sofa_liver_16  sofa_cardio= sofa_cardio_16
       			sofa_cns= sofa_cns_16  sofa_renal= sofa_renal_16  sofa_tot= sofa_tot_16  nar_prov= nar_prov_16  pn_lipid = pn_lipid_16  pn_cho = pn_cho_16)
       			)

 		glnd.plate34 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_17  oral_kcal= oral_kcal_17  pn_aa_g= pn_aa_g_17  iv_kcal= iv_kcal_17  pn_aa_kcal= pn_aa_kcal_17  prop_kcal= prop_kcal_17
    			tube_prot= tube_prot_17  tot_aa= tot_aa_17 tube_kcal= tube_kcal_17  tot_kcal= tot_kcal_17  oral_prot= oral_prot_17  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_17  time_gluc_eve= time_gluc_eve_17  gluc_mrn= gluc_mrn_17  time_gluc_mrn= time_gluc_mrn_17  gluc_aft= gluc_aft_17
        		time_gluc_aft= time_gluc_aft_17  sofa_resp= sofa_resp_17  sofa_coag= sofa_coag_17  sofa_liver= sofa_liver_17  sofa_cardio= sofa_cardio_17
       			sofa_cns= sofa_cns_17  sofa_renal= sofa_renal_17  sofa_tot= sofa_tot_17  nar_prov= nar_prov_17  pn_lipid = pn_lipid_17  pn_cho = pn_cho_17)
       			)
       			
       	glnd.plate35 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_18  oral_kcal= oral_kcal_18  pn_aa_g= pn_aa_g_18  iv_kcal= iv_kcal_18  pn_aa_kcal= pn_aa_kcal_18  prop_kcal= prop_kcal_18
    			tube_prot= tube_prot_18  tot_aa= tot_aa_18 tube_kcal= tube_kcal_18  tot_kcal= tot_kcal_18  oral_prot= oral_prot_18  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_18  time_gluc_eve= time_gluc_eve_18  gluc_mrn= gluc_mrn_18  time_gluc_mrn= time_gluc_mrn_18  gluc_aft= gluc_aft_18
        		time_gluc_aft= time_gluc_aft_18  sofa_resp= sofa_resp_18  sofa_coag= sofa_coag_18  sofa_liver= sofa_liver_18  sofa_cardio= sofa_cardio_18
       			sofa_cns= sofa_cns_18  sofa_renal= sofa_renal_18  sofa_tot= sofa_tot_18  nar_prov= nar_prov_18  pn_lipid = pn_lipid_18  pn_cho = pn_cho_18)
       			)
 		
		glnd.plate36 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_19  oral_kcal= oral_kcal_19  pn_aa_g= pn_aa_g_19  iv_kcal= iv_kcal_19  pn_aa_kcal= pn_aa_kcal_19  prop_kcal= prop_kcal_19
    			tube_prot= tube_prot_19  tot_aa= tot_aa_19 tube_kcal= tube_kcal_19  tot_kcal= tot_kcal_19  oral_prot= oral_prot_19  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_19  time_gluc_eve= time_gluc_eve_19  gluc_mrn= gluc_mrn_19  time_gluc_mrn= time_gluc_mrn_19  gluc_aft= gluc_aft_19
        		time_gluc_aft= time_gluc_aft_19  sofa_resp= sofa_resp_19  sofa_coag= sofa_coag_19  sofa_liver= sofa_liver_19  sofa_cardio= sofa_cardio_19
       			sofa_cns= sofa_cns_19  sofa_renal= sofa_renal_19  sofa_tot= sofa_tot_19  nar_prov= nar_prov_19  pn_lipid = pn_lipid_19  pn_cho = pn_cho_19)
       			)
 		
		glnd.plate37 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_20  oral_kcal= oral_kcal_20  pn_aa_g= pn_aa_g_20  iv_kcal= iv_kcal_20  pn_aa_kcal= pn_aa_kcal_20  prop_kcal= prop_kcal_20
    			tube_prot= tube_prot_20  tot_aa= tot_aa_20 tube_kcal= tube_kcal_20  tot_kcal= tot_kcal_20  oral_prot= oral_prot_20  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_20  time_gluc_eve= time_gluc_eve_20  gluc_mrn= gluc_mrn_20  time_gluc_mrn= time_gluc_mrn_20  gluc_aft= gluc_aft_20
        		time_gluc_aft= time_gluc_aft_20  sofa_resp= sofa_resp_20  sofa_coag= sofa_coag_20  sofa_liver= sofa_liver_20  sofa_cardio= sofa_cardio_20
       			sofa_cns= sofa_cns_20  sofa_renal= sofa_renal_20  sofa_tot= sofa_tot_20  nar_prov= nar_prov_20  pn_lipid = pn_lipid_20  pn_cho = pn_cho_20)
       			)
 			
 		glnd.plate38 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_21  oral_kcal= oral_kcal_21  pn_aa_g= pn_aa_g_21  iv_kcal= iv_kcal_21  pn_aa_kcal= pn_aa_kcal_21  prop_kcal= prop_kcal_21
    			tube_prot= tube_prot_21  tot_aa= tot_aa_21 tube_kcal= tube_kcal_21  tot_kcal= tot_kcal_21  oral_prot= oral_prot_21  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_21  time_gluc_eve= time_gluc_eve_21  gluc_mrn= gluc_mrn_21  time_gluc_mrn= time_gluc_mrn_21  gluc_aft= gluc_aft_21
        		time_gluc_aft= time_gluc_aft_21  sofa_resp= sofa_resp_21  sofa_coag= sofa_coag_21  sofa_liver= sofa_liver_21  sofa_cardio= sofa_cardio_21
       			sofa_cns= sofa_cns_21  sofa_renal= sofa_renal_21  sofa_tot= sofa_tot_21  nar_prov= nar_prov_21  pn_lipid = pn_lipid_21  pn_cho = pn_cho_21)
       			)
 			
 		glnd.plate39 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER);
 			
		where dfseq = 5; * select day 21 f/u ;

 	by id;
 run;
proc print;

 /* a longitudinal view of follow-up days 15,16,17,18,19,20,21  */ 
 data glnd.followup_21_long;
 	set glnd.plate32 (in= from15) glnd.plate33(in= from16) glnd.plate34(in= from17) glnd.plate35(in= from18)
		glnd.plate36(in= from19) glnd.plate37(in= from20) glnd.plate38(in= from21);
 	
 	* create a day variable (we are dropping the plate variable below);
 	if from15 = 1 then day= 15;
 	else if from16= 1 then day= 16;
 	else if from17 = 1 then day= 17;
 	else if from18 = 1 then day= 18;
 	else if from19 = 1 then day= 19;
 	else if from20 = 1 then day= 20;
 	else if from21 = 1 then day= 21;
 	
	where dfseq = 5; * select day 21 f/u ;
 	
 	drop dfc fcbint ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS dfseq DFVALID DFRASTER;
 run;

proc sort data= glnd.followup_21_long;
	by id day;
run;

proc print data= glnd.followup_21_long noobs;
	by id;
	var id day  tot_pn pn_aa_g pn_aa_kcal pn_lipid pn_cho  tube_prot tube_kcal oral_kcal oral_prot iv_kcal  prop_kcal tot_aa  tot_kcal  tot_insulin
        		gluc_eve gluc_mrn gluc_aft;
