/* followup_14.sas
 *
 * This program creates two datasets from the eight Day 14 follow-up forms:
 *  1. glnd.followup_14 = a cross-sectional summary of all five forms
 *  2. glnd.followup_14_long = a longitudinal view of follow-up days 8,9,10,11,12,13,14 where day is a variable and all other variables are the same
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
 data glnd.followup_14;
	* merge all plates - where seq id matches day 14 f/u - drop DataFax variables and patient initials ; 
 	merge 
 		/* The next three plates are the same except that the day changes! */
 		
 		
 	 	 glnd.plate32 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_8  oral_kcal= oral_kcal_8  pn_aa_g= pn_aa_g_8  iv_kcal= iv_kcal_8  pn_aa_kcal= pn_aa_kcal_8  prop_kcal= prop_kcal_8
    			tube_prot= tube_prot_8  tot_aa= tot_aa_8 tube_kcal= tube_kcal_8  tot_kcal= tot_kcal_8  oral_prot= oral_prot_8  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_8  time_gluc_eve= time_gluc_eve_8  gluc_mrn= gluc_mrn_8  time_gluc_mrn= time_gluc_mrn_8  gluc_aft= gluc_aft_8
        		time_gluc_aft= time_gluc_aft_8  sofa_resp= sofa_resp_8  sofa_coag= sofa_coag_8  sofa_liver= sofa_liver_8  sofa_cardio= sofa_cardio_8
       			sofa_cns= sofa_cns_8  sofa_renal= sofa_renal_8  sofa_tot= sofa_tot_8  nar_prov= nar_prov_8  pn_lipid = pn_lipid_8  pn_cho = pn_cho_8)
       			)
       	
       	glnd.plate33(drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_9  oral_kcal= oral_kcal_9  pn_aa_g= pn_aa_g_9  iv_kcal= iv_kcal_9  pn_aa_kcal= pn_aa_kcal_9  prop_kcal= prop_kcal_9
    			tube_prot= tube_prot_9  tot_aa= tot_aa_9 tube_kcal= tube_kcal_9  tot_kcal= tot_kcal_9  oral_prot= oral_prot_9  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_9  time_gluc_eve= time_gluc_eve_9  gluc_mrn= gluc_mrn_9  time_gluc_mrn= time_gluc_mrn_9  gluc_aft= gluc_aft_9
        		time_gluc_aft= time_gluc_aft_9  sofa_resp= sofa_resp_9  sofa_coag= sofa_coag_9  sofa_liver= sofa_liver_9  sofa_cardio= sofa_cardio_9
       			sofa_cns= sofa_cns_9  sofa_renal= sofa_renal_9  sofa_tot= sofa_tot_9  nar_prov= nar_prov_9  pn_lipid = pn_lipid_9  pn_cho = pn_cho_9)
       			)

 		glnd.plate34 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_10  oral_kcal= oral_kcal_10  pn_aa_g= pn_aa_g_10  iv_kcal= iv_kcal_10  pn_aa_kcal= pn_aa_kcal_10  prop_kcal= prop_kcal_10
    			tube_prot= tube_prot_10  tot_aa= tot_aa_10 tube_kcal= tube_kcal_10  tot_kcal= tot_kcal_10  oral_prot= oral_prot_10  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_10  time_gluc_eve= time_gluc_eve_10  gluc_mrn= gluc_mrn_10  time_gluc_mrn= time_gluc_mrn_10  gluc_aft= gluc_aft_10
        		time_gluc_aft= time_gluc_aft_10  sofa_resp= sofa_resp_10  sofa_coag= sofa_coag_10  sofa_liver= sofa_liver_10  sofa_cardio= sofa_cardio_10
       			sofa_cns= sofa_cns_10  sofa_renal= sofa_renal_10  sofa_tot= sofa_tot_10  nar_prov= nar_prov_10  pn_lipid = pn_lipid_10  pn_cho = pn_cho_10)
       			)
       			
       	glnd.plate35 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_11  oral_kcal= oral_kcal_11  pn_aa_g= pn_aa_g_11  iv_kcal= iv_kcal_11  pn_aa_kcal= pn_aa_kcal_11  prop_kcal= prop_kcal_11
    			tube_prot= tube_prot_11  tot_aa= tot_aa_11 tube_kcal= tube_kcal_11  tot_kcal= tot_kcal_11  oral_prot= oral_prot_11  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_11  time_gluc_eve= time_gluc_eve_11  gluc_mrn= gluc_mrn_11  time_gluc_mrn= time_gluc_mrn_11  gluc_aft= gluc_aft_11
        		time_gluc_aft= time_gluc_aft_11  sofa_resp= sofa_resp_11  sofa_coag= sofa_coag_11  sofa_liver= sofa_liver_11  sofa_cardio= sofa_cardio_11
       			sofa_cns= sofa_cns_11  sofa_renal= sofa_renal_11  sofa_tot= sofa_tot_11  nar_prov= nar_prov_11  pn_lipid = pn_lipid_11  pn_cho = pn_cho_11)
       			)
 		
		glnd.plate36 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_12  oral_kcal= oral_kcal_12  pn_aa_g= pn_aa_g_12  iv_kcal= iv_kcal_12  pn_aa_kcal= pn_aa_kcal_12  prop_kcal= prop_kcal_12
    			tube_prot= tube_prot_12  tot_aa= tot_aa_12 tube_kcal= tube_kcal_12  tot_kcal= tot_kcal_12  oral_prot= oral_prot_12  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_12  time_gluc_eve= time_gluc_eve_12  gluc_mrn= gluc_mrn_12  time_gluc_mrn= time_gluc_mrn_12  gluc_aft= gluc_aft_12
        		time_gluc_aft= time_gluc_aft_12  sofa_resp= sofa_resp_12  sofa_coag= sofa_coag_12  sofa_liver= sofa_liver_12  sofa_cardio= sofa_cardio_12
       			sofa_cns= sofa_cns_12  sofa_renal= sofa_renal_12  sofa_tot= sofa_tot_12  nar_prov= nar_prov_12  pn_lipid = pn_lipid_12  pn_cho = pn_cho_12)
       			)
 		
		glnd.plate37 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_13  oral_kcal= oral_kcal_13  pn_aa_g= pn_aa_g_13  iv_kcal= iv_kcal_13  pn_aa_kcal= pn_aa_kcal_13  prop_kcal= prop_kcal_13
    			tube_prot= tube_prot_13  tot_aa= tot_aa_13 tube_kcal= tube_kcal_13  tot_kcal= tot_kcal_13  oral_prot= oral_prot_13  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_13  time_gluc_eve= time_gluc_eve_13  gluc_mrn= gluc_mrn_13  time_gluc_mrn= time_gluc_mrn_13  gluc_aft= gluc_aft_13
        		time_gluc_aft= time_gluc_aft_13  sofa_resp= sofa_resp_13  sofa_coag= sofa_coag_13  sofa_liver= sofa_liver_13  sofa_cardio= sofa_cardio_13
       			sofa_cns= sofa_cns_13  sofa_renal= sofa_renal_13  sofa_tot= sofa_tot_13  nar_prov= nar_prov_13  pn_lipid = pn_lipid_13  pn_cho = pn_cho_13)
       			)
 			
 		glnd.plate38 (drop = ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER
 			rename = (
		        tot_pn= tot_pn_14  oral_kcal= oral_kcal_14  pn_aa_g= pn_aa_g_14  iv_kcal= iv_kcal_14  pn_aa_kcal= pn_aa_kcal_14  prop_kcal= prop_kcal_14
    			tube_prot= tube_prot_14  tot_aa= tot_aa_14 tube_kcal= tube_kcal_14  tot_kcal= tot_kcal_14  oral_prot= oral_prot_14  tot_insulin= tot_insulin
        		gluc_eve= gluc_eve_14  time_gluc_eve= time_gluc_eve_14  gluc_mrn= gluc_mrn_14  time_gluc_mrn= time_gluc_mrn_14  gluc_aft= gluc_aft_14
        		time_gluc_aft= time_gluc_aft_14  sofa_resp= sofa_resp_14  sofa_coag= sofa_coag_14  sofa_liver= sofa_liver_14  sofa_cardio= sofa_cardio_14
       			sofa_cns= sofa_cns_14  sofa_renal= sofa_renal_14  sofa_tot= sofa_tot_14  nar_prov= nar_prov_14  pn_lipid = pn_lipid_14  pn_cho = pn_cho_14)
       			)
 			
 		glnd.plate39 (drop =  ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY  DFSTATUS DFVALID DFRASTER);
 			
		where dfseq = 4; * select day 14 f/u;

 	by id;
 run;
proc print;

 /* a longitudinal view of follow-up days 8,9,10,11,12,13,14 */ 
 data glnd.followup_14_long;
 	set glnd.plate32 (in= from8) glnd.plate33(in= from9) glnd.plate34(in= from10) glnd.plate35(in= from11)
		glnd.plate36(in= from12) glnd.plate37(in= from13) glnd.plate38(in= from14);
 	
 	* create a day variable (we are dropping the plate variable below);
 	if from8 = 1 then day= 8;
 	else if from9= 1 then day= 9;
 	else if from10 = 1 then day= 10;
 	else if from11 = 1 then day= 11;
 	else if from12 = 1 then day= 12;
 	else if from13 = 1 then day= 13;
 	else if from14 = 1 then day= 14;
 	
	where dfseq = 4 ; * select day 14 f/u;
 	
 	drop dfc fcbint ptint dfstudy dfplate DFSCREEN DFCREATE DFMODIFY dfseq DFSTATUS DFVALID DFRASTER;
 run;

proc sort data= glnd.followup_14_long;
	by id day;
run;

proc print data= glnd.followup_14_long noobs;
	by id;
	var id day  tot_pn pn_aa_g pn_aa_kcal pn_lipid pn_cho  tube_prot tube_kcal oral_kcal oral_prot iv_kcal  prop_kcal tot_aa  tot_kcal  tot_insulin
        		gluc_eve gluc_mrn gluc_aft;
