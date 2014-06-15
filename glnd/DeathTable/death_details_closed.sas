/* death_details.sas
 *
 * provides essential details on patients that have died
 *
 */

 * create library for reporting files and graphs;
 libname glnd_rep "/glnd/sas/reporting";

proc sort data= glnd.demo_his; by id; run;
proc sort data= glnd.plate205; by id; run;
proc sort data= glnd.george; by id; run;
proc sort data= glnd.plate1; by id; run;
proc sort data= glnd.george; by id; run;

* take data from the death form and demographics form;
data glnd_rep.death_details_closed;
	merge 	glnd.demo_his
			glnd.plate205 (in = died)
			glnd.status (keep = id dt_random dt_discharge)
			glnd.plate1 (keep = id in_sicu_choice apache_score)
			glnd.george (keep = id treatment)
		;

	by id;

	if ~died then delete;
	
	center = floor(id/10000);
		
	* concatenate reasons for death into one string ;
	
	length reasons_death $200;
	length old_reasons_death $200;
	
	reasons_death= " ";
	old_reasons_death = " ";

	if ards  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "ARDS, "); end;
	if sepsis  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Sepsis, "); end;
	if stroke  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Ischemic/hem stroke, "); end;
	if mi  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "MI, "); end;
	if pe  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Pulmonary embolus, "); end;
	if acute_isch  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death, "Acute ischemia org., "); end;
	if rupt_bld_ves  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Ruptured bld vessel, "); end;
	if wnd_dehis  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Wound dehiscence, "); end;
	if sys_hemorrhage  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death, "Systemic hemorrhage, "); end;
	if heart_fail  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Heart failure, "); end;
	if mult_organ_fail  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Mult organ failure, "); end;
	if uncont_seiz  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , "Uncontrolled seiz., "); end;
	if other  then do old_reasons_death= reasons_death; reasons_death= cats(old_reasons_death , other_spec) ; end;

	* concatenate indications for PN into one string;
	length indic_pn $200;
	length old_indic_pn $200;
	
	indic_pn= " ";
	old_indic_pn = " ";
	if indication_pn_1 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Ileus,"); end;	
	if indication_pn_2 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Ischemic bowel,"); end;	
	if indication_pn_3 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Hemodynamic instability,"); end;	
	if indication_pn_4 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Intolerence to enteral feeding,"); end;	
	if indication_pn_5 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Bowel obstruction,"); end;	
	if indication_pn_6 then do old_indic_pn = indic_pn; indic_pn = cats(old_indic_pn, "Other"); end;
		
	if reasons_death = "" then reasons_death ="(not specified)";

	age = (dt_death - dt_birth)/365.25;
	days_study = (dt_death - dt_random);
/*        if deceased & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;*/
	if died & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;
	if hospital_death then days_hosp = (dt_death - dt_admission);
	
	if (id = 22028) then hospital_death = 1; ** correction on 6/26/08 because we do not yet have hospital release date **;


	format age 4.1;
	format hospital_death yn.;
	format center center.;
	format treatment trt.;


	label 
		treatment = "Treatment"
		age= "Age at death"
		gender = "Gender"
		race = "Race"
		dt_admission = "Hosp. admission date"
		primary_diag = "Primary diagnosis"
		in_sicu_choice = "Eligibility operation"
		indic_pn = "Indications for PN"
		apache_score = "Apache score"
		days_hosp = "Days in hosp. until death"
		days_study = "Days on study until death"
		reasons_death = "Causes of death"	
		hospital_death = "In-hosp. death?"
		center = "Center"
		;


* days post surgery ? ;

	drop old_reasons_death old_indic_pn;
	keep center id treatment reasons_death gender race age days_study days_hosp dt_death dt_admission primary_diag indic_pn in_sicu_choice apache_score hospital_death;
run;

		* capture number of total deaths;
			proc means data= glnd_rep.death_details_closed noprint;
				output out= death_n n(id) = id_n;
			run;
			data _null_;
				set death_n;
		
				call symput('n_deaths', put(id_n, 3.0));
			run;

title h=3 "GLND Patient Death Summary - &n_deaths total deaths";
options orientation = landscape leftmargin= .1 rightmargin = .1 nodate nonumber;

ods pdf file = "/glnd/sas/reporting/death_details_closed.pdf" style=journal;
ods ps file = "/glnd/sas/reporting/deathdetailsclosed.ps" style=journal;
	proc print data = glnd_rep.death_details_closed label noobs;
	where id <= 22028;
		var treatment center id age gender race dt_admission primary_diag in_sicu_choice indic_pn apache_score hospital_death days_hosp days_study reasons_death;
	run;
ods ps close;
ods pdf close;

title h=3 "GLND Patient Death Summary - &n_deaths total deaths";
options orientation = landscape leftmargin= .1 rightmargin = .1 nodate nonumber;

ods pdf file = "/glnd/sas/reporting/death_details_closed1.pdf" style=journal;
ods ps file = "/glnd/sas/reporting/deathdetailsclosed1.ps" style=journal;
	proc print data = glnd_rep.death_details_closed label noobs;
	where 22028 <id < 30000;
		var treatment center id age gender race dt_admission primary_diag in_sicu_choice indic_pn apache_score hospital_death days_hosp days_study reasons_death;
	run;
ods ps close;
ods pdf close;



ods pdf file = "/glnd/sas/reporting/death_details_closed2.pdf" style=journal;
ods ps file = "/glnd/sas/reporting/deathdetailsclosed2.ps" style=journal;
	proc print data = glnd_rep.death_details_closed label noobs;
	where id >30000;
		var treatment center id age gender race dt_admission primary_diag in_sicu_choice indic_pn apache_score hospital_death days_hosp days_study reasons_death;
	run;
ods ps close;
ods pdf close;
run;



