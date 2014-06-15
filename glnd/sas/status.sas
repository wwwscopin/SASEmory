/* status.sas 
 *
 * stores important endpoint information for each patient enrolled in the GLN-D trial
 *
 * Variables currently included - NOT CURRENTLY UPDATED: 
 * 
 * 1. - indicator if ever on mechanical ventilation. 0 = never, 1 = started pre-randomization, 2 = started after  randomization
 * 2. - days on mechanical ventilation after randomization (we do not have data on CRFs on days on ventilation before randomization)
 * 3. - total number of days in SICU
 * 4. - total number of days in SICU after randomzation
 * 5  - total number of days in hospital
 * 6. - total number of days in hospital after randomization
 * 7. - total number of days on PN
 * 8. - total number of days on PN after randomization
 * 9. - APACHE score category
 * 10. still_in_hosp = 0/1 indicator if currently hospitalized
 * 11. still_in_icu = 0/1 indicator if currently in SICU
 */


/**** LAST MODIFIED 6/16/2009  ****/


*options ls=200;

* Sort datasets! ;
proc sort data= glnd.plate8; by id; run;
proc sort data= glnd.demo_his; by id; run;

proc sort data= glnd.plate26; by id; run; * day 3;
proc sort data= glnd.plate31; by id; run; * day 7;
proc sort data= glnd.plate39; by id; run; * days 14, 21, 28;
proc sort data= glnd.plate40; by id; run; * day 35, 42, etc. weekly summary; 
proc sort data= glnd.plate45; by id; run; * day 28 form - date field completed field used as surrogate for date completed;
proc sort data= glnd.plate42; by id; run; * day 30 post-drug discontinuation form;
proc sort data= glnd.plate43; by id; run; * mo. 2, 4, 6 f/u phone calls;
proc sort data= glnd.plate205; by id; run; * Death Form ;
proc sort data= glnd.plate51; by id; run; * Lost to follow-up Form ;




	/*
glnd.plate45 (keep = id dfc rename = (dfc = dt)) /* day 28	*/
			
*/



* temporary datasets to store the last page of the days 14, 21, 28 forms - and to store 2,4,6 month forms;
data day14;
	set		glnd.plate39 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_14 dt_hosp_rel= dt_hosp_rel_14 sicu= sicu_14 dt_sicu_rel= dt_sicu_rel_14 mech_vent= mech_vent_14 
									mech_vent_updt= mech_vent_updt_14 study_pn= study_pn_14 time_study_pn_stp= time_study_pn_stp_14
								dt_study_pn_stp= dt_study_pn_stp_14)) ;
	where DFSEQ = 4;
run;

data day21;
	set		glnd.plate39 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_21 dt_hosp_rel= dt_hosp_rel_21 sicu= sicu_21 dt_sicu_rel= dt_sicu_rel_21 mech_vent= mech_vent_21 
									mech_vent_updt= mech_vent_updt_21 study_pn= study_pn_21 time_study_pn_stp= time_study_pn_stp_21
									dt_study_pn_stp= dt_study_pn_stp_21)) ;
	where DFSEQ = 5;
run;


data day28;
	set		glnd.plate39 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_28 dt_hosp_rel= dt_hosp_rel_28 sicu= sicu_28 dt_sicu_rel= dt_sicu_rel_28 mech_vent= mech_vent_28 
									mech_vent_updt= mech_vent_updt_28 study_pn= study_pn_28 time_study_pn_stp= time_study_pn_stp_28
									dt_study_pn_stp= dt_study_pn_stp_28)) ;
	where DFSEQ = 6;
run;

*** There is no visit 7 ***; 

data day35;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_35 dt_hosp_rel= dt_hosp_rel_35 sicu= sicu_35 dt_sicu_rel= dt_sicu_rel_35 mech_vent= mech_vent_35 
									mech_vent_updt= mech_vent_updt_35 study_pn= study_pn_35 time_study_pn_stp= time_study_pn_stp_35
									dt_study_pn_stp= dt_study_pn_stp_35)) ;
	where DFSEQ = 8;
run;


data day42;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_42 dt_hosp_rel= dt_hosp_rel_42 sicu= sicu_42 dt_sicu_rel= dt_sicu_rel_42 mech_vent= mech_vent_42 
									mech_vent_updt= mech_vent_updt_42 study_pn= study_pn_42 time_study_pn_stp= time_study_pn_stp_42
									dt_study_pn_stp= dt_study_pn_stp_42)) ;
	where DFSEQ = 9;
run;


data day49;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_49 dt_hosp_rel= dt_hosp_rel_49 sicu= sicu_49 dt_sicu_rel= dt_sicu_rel_49 mech_vent= mech_vent_49 
									mech_vent_updt= mech_vent_updt_49 study_pn= study_pn_49 time_study_pn_stp= time_study_pn_stp_49
									dt_study_pn_stp= dt_study_pn_stp_49)) ;
	where DFSEQ = 10;
run;

data day56;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_56 dt_hosp_rel= dt_hosp_rel_56 sicu= sicu_56 dt_sicu_rel= dt_sicu_rel_56 mech_vent= mech_vent_56 
									mech_vent_updt= mech_vent_updt_56 study_pn= study_pn_56 time_study_pn_stp= time_study_pn_stp_56
									dt_study_pn_stp= dt_study_pn_stp_56)) ;
	where DFSEQ = 11;
run;

data day63;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_63 dt_hosp_rel= dt_hosp_rel_63 sicu= sicu_63 dt_sicu_rel= dt_sicu_rel_63 mech_vent= mech_vent_63 
									mech_vent_updt= mech_vent_updt_63 study_pn= study_pn_63 time_study_pn_stp= time_study_pn_stp_63
									dt_study_pn_stp= dt_study_pn_stp_63)) ;
	where DFSEQ = 12;
run;

data day70;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_70 dt_hosp_rel= dt_hosp_rel_70 sicu= sicu_70 dt_sicu_rel= dt_sicu_rel_70 mech_vent= mech_vent_70 
									mech_vent_updt= mech_vent_updt_70 study_pn= study_pn_70 time_study_pn_stp= time_study_pn_stp_70
									dt_study_pn_stp= dt_study_pn_stp_70)) ;
	where DFSEQ = 13;
run;

data day77;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_77 dt_hosp_rel= dt_hosp_rel_77 sicu= sicu_77 dt_sicu_rel= dt_sicu_rel_77 mech_vent= mech_vent_77 
									mech_vent_updt= mech_vent_updt_77 study_pn= study_pn_77 time_study_pn_stp= time_study_pn_stp_77
									dt_study_pn_stp= dt_study_pn_stp_77)) ;
	where DFSEQ = 14;
run;

data day84;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_84 dt_hosp_rel= dt_hosp_rel_84 sicu= sicu_84 dt_sicu_rel= dt_sicu_rel_84 mech_vent= mech_vent_84 
									mech_vent_updt= mech_vent_updt_84 study_pn= study_pn_84 time_study_pn_stp= time_study_pn_stp_84
									dt_study_pn_stp= dt_study_pn_stp_84)) ;
	where DFSEQ = 15;
run;

data day91;
	set		glnd.plate40 (keep = dfseq id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_91 dt_hosp_rel= dt_hosp_rel_91 sicu= sicu_91 dt_sicu_rel= dt_sicu_rel_91 mech_vent= mech_vent_91 
									mech_vent_updt= mech_vent_updt_91 study_pn= study_pn_91 time_study_pn_stp= time_study_pn_stp_91
									dt_study_pn_stp= dt_study_pn_stp_91)) ;
	where DFSEQ = 16;
run;


data month2;
	set glnd.plate43 (keep = dfseq id dt_phn_call info_src rename=(dt_phn_call = dt_phn_call_2 ));
	where DFSEQ = 42;
	
	if (dt_phn_call_2 ~= .) & (info_src = .) then dt_phn_call_2 = .; * safeguard against coordinators faxing form in with a date though they were unablet to contact patient;
	keep id dt_phn_call_2;
run;

data month4;
	set glnd.plate43 (keep = dfseq id dt_phn_call info_src rename=(dt_phn_call = dt_phn_call_4 ));
	where DFSEQ = 43;
	
	if (dt_phn_call_4 ~= .) & (info_src = .) then dt_phn_call_4 = .; * safeguard against coordinators faxing form in with a date though they were unablet to contact patient;
	keep id dt_phn_call_4;
run;

data month6;
	set glnd.plate43 (keep = dfseq id dt_phn_call info_src rename=(dt_phn_call = dt_phn_call_6 ));
	where DFSEQ = 44;
	
	if (dt_phn_call_6 ~= .) & (info_src = .) then dt_phn_call_6 = .; * safeguard against coordinators faxing form in with a date though they were unablet to contact patient;
	keep id dt_phn_call_6;
run;



data status_temp;
	merge	glnd.plate8 (keep = id dt_random time_random apache_2 in = was_randomized)
			glnd.demo_his (keep = id dt_admission days_SICU_prior ent_nutr parent_nutr ent_nutr_days parent_nutr_days dt_drug_str time_drug_str mech_vent 	
						rename = (mech_vent= mech_vent_base))	
		
			/* stop information from last plate of day 3,7,14,21,28 follow-ups. currently we have no 21 or 28 f/u forms and therefore they are not implement below:*/

			glnd.plate26 (keep = id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_3 dt_hosp_rel= dt_hosp_rel_3 sicu= sicu_3 dt_sicu_rel= dt_sicu_rel_3 mech_vent= mech_vent_3 
									mech_vent_updt= mech_vent_updt_3 study_pn= study_pn_3 time_study_pn_stp= time_study_pn_stp_3
									dt_study_pn_stp= dt_study_pn_stp_3))
			glnd.plate31 (keep = id hosp dt_hosp_rel sicu dt_sicu_rel mech_vent mech_vent_updt study_pn time_study_pn_stp dt_study_pn_stp
							rename = (hosp= hosp_7 dt_hosp_rel= dt_hosp_rel_7 sicu= sicu_7 dt_sicu_rel= dt_sicu_rel_7 mech_vent= mech_vent_7 
									mech_vent_updt= mech_vent_updt_7 study_pn= study_pn_7 time_study_pn_stp= time_study_pn_stp_7
									dt_study_pn_stp= dt_study_pn_stp_7))
			day14
			day21
			day28
			day35
			day42
			day49
			day56
			day63
			day70
			day77
			day84
			day91
			glnd.plate45 (keep = id dfc rename = (dfc = dt_fu_28))
			glnd.plate42 (keep = id dfc rename = (dfc = dt_post_study_30))
			month2
			month4
			month6
			
			glnd.plate205 (keep = id dt_death in = in_death)
			glnd.plate51 (keep = id dt_last_cont dt_wdraw_cons dt_cont_re_est lost_fup wdraw_cons cont_re_est ) 
			;
	by id;


	if ~was_randomized then DELETE;
	
			* turn "." into 0;
			if ent_nutr = 0 then ent_nutr_days = 0 ; drop ent_nutr; 
			if parent_nutr = 0 then parent_nutr_days = 0; drop parent_nutr;

			format time_study_pn_stopped hhmm. ; * reformat times from seconds to HH:MM on a 24-hour clock;

	* compute lost to follow-up and keep only the important stuff ;
		if (lost_fup & ~cont_re_est) then do lost_to_followup = 1; dt_lost_last_contact = dt_last_cont; end;
		else if (wdraw_cons) then do lost_to_followup = 1; dt_lost_last_contact = dt_wdraw_cons; end;
		else do lost_to_followup = 0; dt_lost_last_contact =  . ; end;
		
		drop dt_last_cont dt_wdraw_cons dt_cont_re_est lost_fup wdraw_cons cont_re_est;
		
	

	* compute important durations here: 
			* day of discharge;
			if hosp_3 = 0 then do; dt_discharge= dt_hosp_rel_3; still_in_hosp = 0; end;
			else if hosp_7 = 0 then do; dt_discharge= dt_hosp_rel_7; still_in_hosp = 0; end;
			else if hosp_14 = 0 then do; dt_discharge= dt_hosp_rel_14; still_in_hosp = 0; end;
			else if hosp_21 = 0 then do; dt_discharge= dt_hosp_rel_21; still_in_hosp = 0; end;			
			else if hosp_28 = 0 then do; dt_discharge= dt_hosp_rel_28; still_in_hosp = 0; end;			
			else if hosp_35 = 0 then do; dt_discharge= dt_hosp_rel_35; still_in_hosp = 0; end;			
			else if hosp_42 = 0 then do; dt_discharge= dt_hosp_rel_42; still_in_hosp = 0; end;			
			else if hosp_49 = 0 then do; dt_discharge= dt_hosp_rel_49; still_in_hosp = 0; end;
			else if hosp_56 = 0 then do; dt_discharge= dt_hosp_rel_56; still_in_hosp = 0; end;
			else if hosp_63 = 0 then do; dt_discharge= dt_hosp_rel_63; still_in_hosp = 0; end;
			else if hosp_70 = 0 then do; dt_discharge= dt_hosp_rel_70; still_in_hosp = 0; end;
			else if hosp_77 = 0 then do; dt_discharge= dt_hosp_rel_77; still_in_hosp = 0; end;
			else if hosp_84 = 0 then do; dt_discharge= dt_hosp_rel_84; still_in_hosp = 0; end;
			else if hosp_91 = 0 then do; dt_discharge= dt_hosp_rel_91; still_in_hosp = 0; end;						
			else do; dt_discharge = .;	still_in_hosp = 1; end; * not yet discharged or missing;
			format dt_discharge mmddyy8.;	
			
			if id=41144 then do; dt_discharge= dt_phn_call_6; still_in_hosp = 0; end;
			
			* day of leaving SICU;
			if sicu_3 = 0 then do; dt_leave_sicu= dt_sicu_rel_3; still_in_icu = 0; end;
			else if sicu_7 = 0 then do; dt_leave_sicu= dt_sicu_rel_7; still_in_icu = 0; end;	
			else	if sicu_14 = 0 then do; dt_leave_sicu= dt_sicu_rel_14; still_in_icu = 0; end;
			else	if sicu_21 = 0 then do; dt_leave_sicu= dt_sicu_rel_21; still_in_icu = 0; end;				
			else	if sicu_28 = 0 then do; dt_leave_sicu= dt_sicu_rel_28; still_in_icu = 0; end;			
			else	if sicu_35 = 0 then do; dt_leave_sicu= dt_sicu_rel_35; still_in_icu = 0; end;			
			else	if sicu_42 = 0 then do; dt_leave_sicu= dt_sicu_rel_42; still_in_icu = 0; end;			
			else	if sicu_49 = 0 then do; dt_leave_sicu= dt_sicu_rel_49; still_in_icu = 0; end;			
			else	if sicu_56 = 0 then do; dt_leave_sicu= dt_sicu_rel_56; still_in_icu = 0; end;			
			else	if sicu_63 = 0 then do; dt_leave_sicu= dt_sicu_rcel_63; still_in_icu = 0; end;			
			else	if sicu_70 = 0 then do; dt_leave_sicu= dt_sicu_rel_70; still_in_icu = 0; end;			
			else	if sicu_77 = 0 then do; dt_leave_sicu= dt_sicu_rel_77; still_in_icu = 0; end;			
			else	if sicu_84 = 0 then do; dt_leave_sicu= dt_sicu_rel_84; still_in_icu = 0; end;	
			else	if sicu_91 = 0 then do; dt_leave_sicu= dt_sicu_rel_91; still_in_icu = 0; end;					
			else do; dt_leave_sicu= .; still_in_icu = 1; end; * still in ICU or missing;
			format dt_leave_sicu mmddyy8.;	
			
			if id=11141 then dt_leave_sicu=dt_sicu_rel_21;
			if id=21020 then dt_leave_sicu=dt_sicu_rel_35;

			* day of stopping study PN;
			if study_pn_3 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_3; time_study_pn_stopped= time_study_pn_stp_3; still_on_study_pn = 0 ;end;
			else if study_pn_7 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_7; time_study_pn_stopped= time_study_pn_stp_7; still_on_study_pn = 0 ;end;
			else if study_pn_14 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_14; time_study_pn_stopped= time_study_pn_stp_14; still_on_study_pn = 0 ;end;
			else if study_pn_21 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_21; time_study_pn_stopped= time_study_pn_stp_21; still_on_study_pn = 0 ;end;
			else if study_pn_28 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_28; time_study_pn_stopped= time_study_pn_stp_28; still_on_study_pn = 0 ;end;
			else if study_pn_35 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_35; time_study_pn_stopped= time_study_pn_stp_35; still_on_study_pn = 0 ;end;
			else if study_pn_42 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_42; time_study_pn_stopped= time_study_pn_stp_42; still_on_study_pn = 0 ;end;
			else if study_pn_49 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_49; time_study_pn_stopped= time_study_pn_stp_49; still_on_study_pn = 0 ;end;
			else if study_pn_56 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_56; time_study_pn_stopped= time_study_pn_stp_56; still_on_study_pn = 0 ;end;
			else if study_pn_63 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_63; time_study_pn_stopped= time_study_pn_stp_63; still_on_study_pn = 0 ;end;
			else if study_pn_70 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_70; time_study_pn_stopped= time_study_pn_stp_70; still_on_study_pn = 0 ;end;
			else if study_pn_77 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_77; time_study_pn_stopped= time_study_pn_stp_77; still_on_study_pn = 0 ;end;
			else if study_pn_84 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_84; time_study_pn_stopped= time_study_pn_stp_84; still_on_study_pn = 0 ;end;
			else if study_pn_91 = 0 then do; dt_study_pn_stopped= dt_study_pn_stp_91; time_study_pn_stopped= time_study_pn_stp_91; still_on_study_pn = 0 ;end;
			else do; dt_study_pn_stopped = .; time_study_pn_stopped = .; still_on_study_pn = 1; end; * still on study PN or missing;
			format dt_study_pn_stopped mmddyy8.;

			* day of stopping mechanical ventilation;
				* cannot yet implement time on ventilation since CRFs do not provide begin dates for it;

			
				
		* days on study PN - expressed as fraction days - IS LATER ADJUSTED BY TIME_ON_PN TO ACCOUNT FOR ON AND OFF PN TIME!. ;
			if still_on_study_pn = 0 then do;
				if time_drug_str > time_study_pn_stopped then
					 	days_on_study_pn= (dt_study_pn_stopped - dt_drug_str) - 1 + ((24*3600)- (time_drug_str - time_study_pn_stopped) )/(24*3600) ;						
	
				else if time_drug_str < time_study_pn_stopped then 
						days_on_study_pn= (dt_study_pn_stopped - dt_drug_str) + (time_study_pn_stopped - time_drug_str)/(24*3600) ;
				end;		
			else days_on_study_pn = . ;


		* mechanical ventilation; 
		* TODO: change code below when CRFs are fixed. ie: get rid of "IF ( | | |)' Statements;
		/*if (mech_vent_3 ~= .) | (mech_vent_7 ~= .) | (mech_vent_14 ~= .) then	ever_on_ventilation_study = (mech_vent_3 | mech_vent_7 | mech_vent_14); * were they ever on a respirator after enrollment;
		ever_on_ventilation = (mech_vent_base | ever_on_ventilation_study) ; * were they ever on a respirator during this hospitalization; 
		COMMENTED OUT B/C WE HAVE CHANGED MECH VENT HANDLING IN CRFs*/ 

		* death;
		if (in_death) then deceased = 1; else deceased = 0; * simple indicator for whether we have a record of death, regardless of when patient died ;
		days_until_death = dt_death - dt_random; 
		if (days_until_death < 29) & (days_until_death ~= .) then mortality_28d = 1; else mortality_28d = 0; * 28-Day mortality;
		if (days_until_death <= 182.5) & (days_until_death  ~= .) then mortality_6mo = 1; else mortality_6mo = 0; * 6-month mortality;
		
	

	** CALCULATE FOLLOW-UP TIME **;
	
		* TIME ON STUDY ;
		* incorporate hosp release, phone calls, death, lost to followup ;
		
			if (deceased) then dt_last_contact = dt_death;
			else if (lost_to_followup) then dt_last_contact = dt_lost_last_contact;
			else dt_last_contact = max(dt_discharge, dt_fu_28, dt_post_study_30, dt_phn_call_2, dt_phn_call_4, dt_phn_call_6);
					
			followup_days = dt_last_contact - dt_random ;
		
			format dt_last_contact mmddyy.;

		* days in hospital;
			if ~((lost_to_followup) & (still_in_hosp)) then do;
				days_hosp= dt_discharge - dt_admission;
				days_hosp_post_entry=  dt_discharge - dt_random; * days from randomization to discharge ;
			end;

			else do; 						* case: they dropped out while still in the hospital ;
				still_in_hosp = 0;
				days_hosp = dt_last_contact - dt_admission;
				days_hosp_post_entry=  dt_last_contact - dt_random;
			end;


		* days in SICU - This variable is not entirely accurate, since it does not incorporate the SICU log. The icu_free_days programs properly use this log. ;
			if ~((lost_to_followup) & (still_in_sicu)) then do;
				days_sicu_post_entry = dt_leave_sicu - dt_random;
				days_sicu= days_sicu_prior + days_sicu_post_entry;
			end;

			else do; 						* case: they dropped out while still in the hospital ;
				still_in_sicu = 0;
				days_sicu_post_entry = dt_last_contact -dt_random;
				days_sicu= days_sicu_prior + days_sicu_post_entry;
			end;       
 run;

title "xxx";
proc print;
var id days_sicu_post_entry dt_leave_sicu dt_random dt_last_contact dt_admission still_in_icu 
sicu_3 dt_sicu_rel_3  sicu_7 dt_sicu_rel_7 sicu_14 dt_sicu_rel_14 sicu_21 dt_sicu_rel_21 sicu_28  dt_sicu_rel_28
sicu_35  dt_sicu_rel_35 sicu_42  dt_sicu_rel_42 sicu_49  dt_sicu_rel_49;
run;


** Drop all the individual numbered variables for each day, month, etc;
data status_temp;
	set status_temp;
	
		data status_temp;
		set status_temp;
		
	drop
	dt_hosp_rel_3                               
dt_hosp_rel_7 
dt_hosp_rel_14 
dt_hosp_rel_21                            
dt_hosp_rel_28                               
dt_hosp_rel_35                                                                    
dt_hosp_rel_42                                                                    
dt_hosp_rel_49                                                                    
dt_hosp_rel_56                                                                    
dt_hosp_rel_63                                                                    
dt_hosp_rel_70                                                                    
dt_hosp_rel_77                                                                    
dt_hosp_rel_84                                                                    
dt_hosp_rel_91                                                                    
dt_phn_call_2                                                                          
dt_phn_call_4                                                                          
dt_phn_call_6                                                                          
dt_post_study_30                                                                                            
dt_sicu_rel_3                                                                      
dt_sicu_rel_7                                                                      
dt_sicu_rel_14                                                                     
dt_sicu_rel_21                                                                     
dt_sicu_rel_28                                                                     
dt_sicu_rel_35                                                                     
dt_sicu_rel_42                                                                     
dt_sicu_rel_49                                                                     
dt_sicu_rel_56                                                                     
dt_sicu_rel_63                                                                     
dt_sicu_rel_70                                                                     
dt_sicu_rel_77                                                                     
dt_sicu_rel_84                                                                     
dt_sicu_rel_91                                                                     
dt_study_pn_stp_3                                                                 
dt_study_pn_stp_7                                                                 
dt_study_pn_stp_14                                                                
dt_study_pn_stp_21                                                                
dt_study_pn_stp_28                                                                
dt_study_pn_stp_35                                                                
dt_study_pn_stp_42                                                                
dt_study_pn_stp_49                                                                
dt_study_pn_stp_56                                                                
dt_study_pn_stp_63                                                                
dt_study_pn_stp_70                                                                
dt_study_pn_stp_77                                                                
dt_study_pn_stp_84                                                                
dt_study_pn_stp_91                                                                      
hosp_3                                                                                       
hosp_7                                                                                       
hosp_14                                                                                      
hosp_21                                                                                      
hosp_28                                                                                      
hosp_35                                                                                      
hosp_42                                                           
hosp_49                                                                                      
hosp_56                                                                                      
hosp_63                                                                                      
hosp_70                                                                                      
hosp_77                                                                                      
hosp_84                                                                                      
hosp_91                                                                                      
mech_vent_3                                                                                       
mech_vent_7                                                                                       
mech_vent_14                                                                                      
mech_vent_21                                                                                      
mech_vent_28                                                                                      
mech_vent_35                                                                                       
mech_vent_42                                                                                       
mech_vent_49                                                                                       
mech_vent_56                                                                                       
mech_vent_63                                                                                       
mech_vent_70                                                                                       
mech_vent_77                                                                                       
mech_vent_84                                                                                       
mech_vent_91                                                                                       
mech_vent_base                                                                                    
mech_vent_updt_3                                                                            
mech_vent_updt_7                                                                            
mech_vent_updt_14                                                                           
mech_vent_updt_21                                                                           
mech_vent_updt_28                                                                           
mech_vent_updt_35                                                                           
mech_vent_updt_42                                                                           
mech_vent_updt_49                                                                           
mech_vent_updt_56                                                                           
mech_vent_updt_63                                                                           
mech_vent_updt_70                                                                           
mech_vent_updt_77                                                                           
mech_vent_updt_84                                                                           
mech_vent_updt_91                                                                                                            
sicu_3                                                                                            
sicu_7                                                                                            
sicu_14                                                                                           
sicu_21                                                                                           
sicu_28                                                                                           
sicu_35                                                                                           
sicu_42                                                                                           
sicu_49                                                                                           
sicu_56                                                                                           
sicu_63                                                                                           
sicu_70                                                                                           
sicu_77                                                                                           
sicu_84                                                                                           
sicu_91                                                                                     
study_pn_3                                                                                     
study_pn_7                                                                                     
study_pn_14                                                                                    
study_pn_21                                                                                    
study_pn_28                                                                                    
study_pn_35                                                                                    
study_pn_42                                                                                    
study_pn_49                                                                                    
study_pn_56                                                                                    
study_pn_63                                                                                    
study_pn_70                                                                                    
study_pn_77                                                                                    
study_pn_84                                                                                    
study_pn_91                                                                               
time_study_pn_stp_3                                                                       
time_study_pn_stp_7                                                                       
time_study_pn_stp_14                                                                      
time_study_pn_stp_21                                                                      
time_study_pn_stp_28                                                                      
time_study_pn_stp_35                                                                           
time_study_pn_stp_42                                                                           
time_study_pn_stp_49                                                                           
time_study_pn_stp_56                                                                           
time_study_pn_stp_63                                                                           
time_study_pn_stp_70                                                                           
time_study_pn_stp_77                                                                           
time_study_pn_stp_84                                                                           
time_study_pn_stp_91                                       
;
run;

/*
proc print data = status_temp;
	var id dt_random lost_to_followup dt_last_contact followup_days deceased days_until_death;
run;
*/


** ADDED 5/8/09 - Sequentially randomized ID added ***;

proc sort data = status_temp; by dt_random time_random; run;

	data status_temp;
		set status_temp;
		
		order_randomized = _N_;
run;

proc sort data = status_temp; by id; run;


*****;

data x;
 set glnd.george;
keep treatment id ptint;
format treatment trt.;
proc freq;
 tables treatment;
data glnd.status;
 merge status_temp x;
  by id;
center=int(id/10000);
 if id<99000;
	label   center='Center No.' 

		id="GLND ID No."
		days_sicu = "Total days in the SICU"
		days_sicu_post_entry = "Days in the SICU after study entry"
		days_hosp =  "Total days in the hospital"
		days_hosp_post_entry = "Days in the hospital after study entry"
		days_on_study_pn = "Total days on study PN"
		ever_on_ventilation = "Patient ever on mechanical ventilation during hospitalization"
		ever_on_ventilation_study = "Patient ever on mechanical ventilation after study entry"
		treatment='Treatment'
		followup_days = "Follow-up Days"
		order_randomized = "Order randomized"
	
	;
if deceased & (dt_death <= dt_discharge) then hospital_death = 1 ; else hospital_death = 0;

daysop=dt_random-dt_primary_elig_op;
label daysop='Days from Primary OP to Enrollment';

	format ever_on_ventilation_study yn.;
	format ever_on_ventilation yn.;
run;

proc means data= glnd.status n median q1 q3 min max maxdec=1;
	var  days_sicu days_sicu_post_entry days_hosp days_hosp_post_entry days_on_study_pn ;
run;

proc freq data = glnd.status;
	tables ever_on_ventilation_study ever_on_ventilation /nocol nopercent;
run;

/*
proc print data= glnd.status ;
	var id dt_leave_sicu days_sicu still_in_hosp days_hosp days_hosp_post_entry deceased mortality_28d still_on_study_pn dt_study_pn_stopped time_study_pn_stopped;
run;
*/

proc contents data = glnd.status;
run;

ods pdf file='deceased.pdf';
proc print noobs;
  var id ;
  where hospital_death=1;
title Hospital Death Patients;
run;
ods pdf close;
run;
proc freq;
 tables deceased;
run;
g
