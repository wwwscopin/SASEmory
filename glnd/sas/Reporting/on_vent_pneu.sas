/* on_vent_pneu.sas
 *
 * look at pneumonia cases. for prevalent ones, determine if on ventilator at baseline. for incident ones, look at whether they were on ventilation at the time of 
 * suspected onset.
 *
 */
	
	proc sort data= glnd.status; by id; run;
	proc sort data= glnd.plate101; by id; run;
	proc sort data= glnd.plate103; by id; run;
	proc sort data= glnd.plate17; by id; run;
	proc sort data= glnd.plate10; by id; run;

	data pneu;
		merge	glnd.status (keep = id dt_random)
				glnd.plate10 (keep = id mech_vent)
				glnd.plate101 (keep = id dt_infect in = has_infection)
				glnd.plate103 (keep = id infect_confirm site_code type_code infect_confirm )
				glnd.plate17 (keep = 	id dt_mech_vent_start_1 dt_mech_vent_start_2 dt_mech_vent_start_3 dt_mech_vent_start_4 dt_mech_vent_start_5
									dt_mech_vent_stop_1 dt_mech_vent_stop_2 dt_mech_vent_stop_3 dt_mech_vent_stop_4 dt_mech_vent_stop_5)
		;
		by id;

		if ~has_infection then DELETE;
		
		* determine whether infection prevalent or incident;
		days_post_entry = dt_infect - dt_random;
		if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry > 2) then incident = 1;
		else if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry <= 2) then incident = 0;

		if 	(((dt_infect >= dt_mech_vent_start_1) & (dt_infect <= dt_mech_vent_stop_1)) | ((dt_infect >= dt_mech_vent_start_2) & (dt_infect <= dt_mech_vent_stop_2)) 
					| ((dt_mech_vent_start_1~=.) &(dt_infect >= dt_mech_vent_start_1) & (dt_mech_vent_stop_1 = . )) | ((dt_mech_vent_start_2~=.) & (dt_infect >= dt_mech_vent_start_2) & (dt_mech_vent_stop_2 = . ))) 
				 then vent_infect = 1;
		else if days_post_entry < 0 then vent_infect = 2; /* = "N/A". We have limited mech vent info prior to enrollment */
		else vent_infect = 0;

	
	
		format incident yn.;
		format vent_infect na.;

		label vent_infect = "On Mech Vent*at Time of*Pneumonia?"
				mech_vent = "Mech Vent Baseline";

		
	
	run;

	data glnd_rep.pneu;
		set pneu;
		where site_code = "PNEU";
	run;

ods pdf file = "/glnd/sas/reporting/on_vent_pneu.pdf" style= journal;
	title 'Mechanical Ventilation Summary for Patients with Pneumonia';
	proc print data = glnd_rep.pneu label split ='*';
		var id dt_random mech_vent dt_infect dt_mech_vent_start_1 dt_mech_vent_stop_1 dt_mech_vent_start_2  dt_mech_vent_stop_2 incident vent_infect;
	run;
ods pdf close;
