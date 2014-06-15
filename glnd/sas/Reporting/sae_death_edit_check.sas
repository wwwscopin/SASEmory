/* sae_death_edit_check.sas
 *
 * perform an edit-check function that checks whether an SAE is expected or not for a given death form and whether it has been received
 *
 */


proc sort data = glnd.sae_patients; by id; run;
proc sort data = glnd.status; by id; run;


data sae_death;
	merge 	glnd.sae_patients (keep = id sae1)
			glnd.status (keep = id dt_study_pn_stopped dt_death deceased)	
	;

	* keep only deceased folks ;
	if ~deceased then delete;

	if (dt_study_pn_stopped + 30 >= dt_death) then sae_expected = 1;
	else if (dt_study_pn_stopped + 30 < dt_death) then sae_expected = 0;

	
	* check if a death SAE is expected but not received ;
	if (sae_expected & ~sae1) then do; %let sae_missing = "1"; end;
	else do; %let sae_missing = "0"; end;


	format sae_expected deceased yn.;
run;

* print table of deceased individuals with all variables  ;
proc print data = sae_death;
run;



data folks_missing;
	set sae_death;
	where (sae_expected & ~sae1);
run;

options nodate nonumber;


ods pdf file = "/glnd/sas/reporting/sas_death_edit_check.pdf" style=journal;
	title "Patients deceased within 30 days of drug discontinuation, missing a death SAE form";
	proc print data = folks_missing noobs label width=full;
		var id deceased dt_death dt_study_pn_stopped sae_expected sae1;
		
		label 	sae1 = "Death SAE form received?"
				dt_death = "Date deceased"
				dt_study_pn_stopped = "Date Study PN Stopped"
				deceased = "Deceased"
				sae_expected = "SAE Expected?"
		;
	run;
ods pdf close;



* if it's the first day of the month and such outstanding SAEs exists, then send the above PDF to the  database administrator so that a QC may be added in Datafax;  ;	

data _NULL_;
	if ( day(today()) = 1) & (&sae_missing = "1") then do;

		call system('sendmessage -s "GLND - SAS Edit Check - SAE missing page QCs need to be added for the attached patients" -r sswanso@sph.emory.edu -a /glnd/sas/reporting/sas_death_edit_check.pdf');
	end;
run;
