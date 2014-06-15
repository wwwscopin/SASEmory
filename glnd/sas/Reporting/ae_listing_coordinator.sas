/* ae_listing_coordinator.sas
 * 
 * Creates a listing of AEs, by patient for the Emory coordinator
 *
 * 10/23/2008
 *
 */
 
 * stack AEs and SAEs into one dataset;
 data ae_sae;
 	set 	glnd.plate201 (keep = id ae_number dt_ae_onset dt_ae_resolve ae_type ae_glycemia
 				rename = (ae_number = number dt_ae_onset = dt_onset dt_ae_resolve = dt_resolve ae_type = type) 
 				in = from_ae)
 		glnd.plate203 (keep = id sae_number dt_sae_onset dt_sae_resolve sae_type 
 				rename = (sae_number = number dt_sae_onset = dt_onset dt_sae_resolve = dt_resolve sae_type = type) 
 				in = from_sae)
 		;
 	length event $ 3;
 	
 	if from_ae then event = "AE";
 	if from_sae then event = "SAE";
 	
 	label 
 		event = "Event type"
 		number = "AE/SAE number"
 		dt_onset = "Onset date"
 		dt_resolve = "Resolution date"
 		type = "Specific event"
 		ae_glycemia = "Hyper- or hypo-glycemia"
 		;
 run;
 
 
 proc sort data = ae_sae;
 	by id event number;
 run;
 
 ods pdf file = "/glnd/sas/reporting/ae_listing_coordinator.pdf" style = journal;
 	title "GLND AEs and SAEs - All centers";
	proc print data = ae_sae label noobs style(header) = [just=center];
 		id id event;
 		by id ;	
 		*where (floor(id/10000) = 1); * center = 1 = Emory;
 	
 		var number dt_onset dt_resolve type ae_glycemia /style(data) = [just=center];
 	run;
 ods pdf close;
 	