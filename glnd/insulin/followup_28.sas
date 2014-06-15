/* followup_28.sas
 *
 * This program creates two datasets from the eight Day 28 follow-up forms:
 *  1. glnd.followup_28 = a cross-sectional summary of all five forms
 *  2. glnd.followup_28_long = a longitudinal view of follow-up days 22,23,24,25,26,27,28 where day is a variable and all other variables are the same
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
 data glnd.followup_28;
	* merge all plates - where seq id matches day 28 f/u - drop DataFax variables and patient initials ; 
 	merge 
 		/* The next three plates are the same except that the day changes! */
 		
 		
		glnd.plate32 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_22  oral_kcal= oral_kcal_22  pn_aa_g= pn_aa_g_22  iv_kcal= iv_kcal_22  pn_aa_kcal= pn_aa_kcal_22  prop_kcal= prop_kcal_22
    			tube_prot= tube_prot_22  tot_aa= tot_aa_22 tube_kcal= tube_kcal_22  tot_kcal= tot_kcal_22  oral_prot= oral_prot_22  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_22  time_gluc_eve= time_gluc_eve_22  gluc_mrn= gluc_mrn_22  time_gluc_mrn= time_gluc_mrn_22  gluc_aft= gluc_aft_22
        		time_gluc_aft= time_gluc_aft_22  sofa_resp= sofa_resp_22  sofa_coag= sofa_coag_22  sofa_liver= sofa_liver_22  sofa_cardio= sofa_cardio_22
       			sofa_cns= sofa_cns_22  sofa_renal= sofa_renal_22  sofa_tot= sofa_tot_22  nar_prov= nar_prov_22  pn_lipid = pn_lipid_22  pn_cho = pn_cho_22)
       			)

       	glnd.plate33(drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_23  oral_kcal= oral_kcal_23  pn_aa_g= pn_aa_g_23  iv_kcal= iv_kcal_23  pn_aa_kcal= pn_aa_kcal_23  prop_kcal= prop_kcal_23
    			tube_prot= tube_prot_23  tot_aa= tot_aa_23 tube_kcal= tube_kcal_23  tot_kcal= tot_kcal_23  oral_prot= oral_prot_23  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_23  time_gluc_eve= time_gluc_eve_23  gluc_mrn= gluc_mrn_23  time_gluc_mrn= time_gluc_mrn_23  gluc_aft= gluc_aft_23
        		time_gluc_aft= time_gluc_aft_23  sofa_resp= sofa_resp_23  sofa_coag= sofa_coag_23  sofa_liver= sofa_liver_23  sofa_cardio= sofa_cardio_23
       			sofa_cns= sofa_cns_23  sofa_renal= sofa_renal_23  sofa_tot= sofa_tot_23  nar_prov= nar_prov_23  pn_lipid = pn_lipid_23  pn_cho = pn_cho_23)
       			)

 		glnd.plate34 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_24  oral_kcal= oral_kcal_24  pn_aa_g= pn_aa_g_24  iv_kcal= iv_kcal_24  pn_aa_kcal= pn_aa_kcal_24  prop_kcal= prop_kcal_24
    			tube_prot= tube_prot_24  tot_aa= tot_aa_24 tube_kcal= tube_kcal_24  tot_kcal= tot_kcal_24  oral_prot= oral_prot_24  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_24  time_gluc_eve= time_gluc_eve_24  gluc_mrn= gluc_mrn_24  time_gluc_mrn= time_gluc_mrn_24  gluc_aft= gluc_aft_24
        		time_gluc_aft= time_gluc_aft_24  sofa_resp= sofa_resp_24  sofa_coag= sofa_coag_24  sofa_liver= sofa_liver_24  sofa_cardio= sofa_cardio_24
       			sofa_cns= sofa_cns_24  sofa_renal= sofa_renal_24  sofa_tot= sofa_tot_24  nar_prov= nar_prov_24  pn_lipid = pn_lipid_24  pn_cho = pn_cho_24)
       			)
       			
       	glnd.plate35 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_25  oral_kcal= oral_kcal_25  pn_aa_g= pn_aa_g_25  iv_kcal= iv_kcal_25  pn_aa_kcal= pn_aa_kcal_25  prop_kcal= prop_kcal_25
    			tube_prot= tube_prot_25  tot_aa= tot_aa_25 tube_kcal= tube_kcal_25  tot_kcal= tot_kcal_25  oral_prot= oral_prot_25  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_25  time_gluc_eve= time_gluc_eve_25  gluc_mrn= gluc_mrn_25  time_gluc_mrn= time_gluc_mrn_25  gluc_aft= gluc_aft_25
        		time_gluc_aft= time_gluc_aft_25  sofa_resp= sofa_resp_25  sofa_coag= sofa_coag_25  sofa_liver= sofa_liver_25  sofa_cardio= sofa_cardio_25
       			sofa_cns= sofa_cns_25  sofa_renal= sofa_renal_25  sofa_tot= sofa_tot_25  nar_prov= nar_prov_25  pn_lipid = pn_lipid_25  pn_cho = pn_cho_25)
       			)
 		
		glnd.plate36 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_26  oral_kcal= oral_kcal_26  pn_aa_g= pn_aa_g_26  iv_kcal= iv_kcal_26  pn_aa_kcal= pn_aa_kcal_26  prop_kcal= prop_kcal_26
    			tube_prot= tube_prot_26  tot_aa= tot_aa_26 tube_kcal= tube_kcal_26  tot_kcal= tot_kcal_26  oral_prot= oral_prot_26  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_26  time_gluc_eve= time_gluc_eve_26  gluc_mrn= gluc_mrn_26  time_gluc_mrn= time_gluc_mrn_26  gluc_aft= gluc_aft_26
        		time_gluc_aft= time_gluc_aft_26  sofa_resp= sofa_resp_26  sofa_coag= sofa_coag_26  sofa_liver= sofa_liver_26  sofa_cardio= sofa_cardio_26
       			sofa_cns= sofa_cns_26  sofa_renal= sofa_renal_26  sofa_tot= sofa_tot_26  nar_prov= nar_prov_26  pn_lipid = pn_lipid_26  pn_cho = pn_cho_26)
       			)
 		
		glnd.plate37 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_27  oral_kcal= oral_kcal_27  pn_aa_g= pn_aa_g_27  iv_kcal= iv_kcal_27  pn_aa_kcal= pn_aa_kcal_27  prop_kcal= prop_kcal_27
    			tube_prot= tube_prot_27  tot_aa= tot_aa_27 tube_kcal= tube_kcal_27  tot_kcal= tot_kcal_27  oral_prot= oral_prot_27  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_27  time_gluc_eve= time_gluc_eve_27  gluc_mrn= gluc_mrn_27  time_gluc_mrn= time_gluc_mrn_27  gluc_aft= gluc_aft_27
        		time_gluc_aft= time_gluc_aft_27  sofa_resp= sofa_resp_27  sofa_coag= sofa_coag_27  sofa_liver= sofa_liver_27  sofa_cardio= sofa_cardio_27
       			sofa_cns= sofa_cns_27  sofa_renal= sofa_renal_27  sofa_tot= sofa_tot_27  nar_prov= nar_prov_27  pn_lipid = pn_lipid_27  pn_cho = pn_cho_27)
       			)
 			
 		glnd.plate38 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_28  oral_kcal= oral_kcal_28  pn_aa_g= pn_aa_g_28  iv_kcal= iv_kcal_28  pn_aa_kcal= pn_aa_kcal_28  prop_kcal= prop_kcal_28
    			tube_prot= tube_prot_28  tot_aa= tot_aa_28 tube_kcal= tube_kcal_28  tot_kcal= tot_kcal_28  oral_prot= oral_prot_28  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_28  time_gluc_eve= time_gluc_eve_28  gluc_mrn= gluc_mrn_28  time_gluc_mrn= time_gluc_mrn_28  gluc_aft= gluc_aft_28
        		time_gluc_aft= time_gluc_aft_28  sofa_resp= sofa_resp_28  sofa_coag= sofa_coag_28  sofa_liver= sofa_liver_28  sofa_cardio= sofa_cardio_28
       			sofa_cns= sofa_cns_28  sofa_renal= sofa_renal_28  sofa_tot= sofa_tot_28  nar_prov= nar_prov_28  pn_lipid = pn_lipid_28  pn_cho = pn_cho_28)
       			)
 			
 		glnd.plate39 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER);
 			
		where dfseq = 6; * select day 28 f/u ;

 	by id;
 run;
proc print;

 /* a longitudinal view of follow-up days  22,23,24,25,26,27,28  */ 
 data glnd.followup_28_long;
 	set glnd.plate32 (in= from22) glnd.plate33(in= from23) glnd.plate34(in= from24) glnd.plate35(in= from25)
		glnd.plate36(in= from26) glnd.plate37(in= from27) glnd.plate38(in= from28);
 	
 	* create a day variable (we are dropping the plate variable below);
 	if from22 = 1 then day= 22;
 	else if from23= 1 then day= 23;
 	else if from24 = 1 then day= 24;
 	else if from25 = 1 then day= 25;
 	else if from26 = 1 then day= 26;
 	else if from27 = 1 then day= 27;
 	else if from28 = 1 then day= 28;
 	
	where dfseq = 6; * select day 28 f/u ;
 	
 	drop dfc fcbint ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS dfseq DFVALID DFRASTER;
 run;

proc sort data= glnd.followup_28_long;
	by id day;
run;

proc print data= glnd.followup_28_long noobs;
	by id;
	var id day  tot_pn pn_aa_g pn_aa_kcal pn_lipid pn_cho  tube_prot tube_kcal oral_kcal oral_prot iv_kcal  prop_kcal tot_aa  tot_kcal  tot_insulin
        		gluc_eve gluc_mrn gluc_aft;
