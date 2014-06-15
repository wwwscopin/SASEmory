/* nosocomial_adjudicated_open.sas
 *
 * partially inherits/supercedes the former "nosocomial_open.sas", last used for the 2/13/2008 DSMB report and now incorporates Dr. Blumberg's 
 * infection adjudication findings
 *
 * created July 2008
 */

libname glnd_cur "/glnd/sas";

options nodate nonumber;

title ;

/*
%macro revise(termA, termB );
%do i=1 %to 5;
if lowcase(scan(org_spec_1,1))=&termA then org_spec_1=&termB;
%end;
%mend revise;
*/    


* macro for making a table BY episode;
*%inc "/glnd/sas/reporting/include/nosocomial_episode_table_open.sas" ;
%inc "nosocomial_episode_table_open.sas" ;


** 1. COMPILED A SAVED DATASET (old one was not stored in GLND) of all reported suspected infections, PRIOR TO ADJUDICATION. 
	LEAVING ALL ORIGINAL DATA INTACT (no removing repeate organisms) **;


 	proc sort data= glnd.status; by id ; run;
	proc sort data= glnd.plate101; by id dfseq; run;
	proc sort data= glnd.plate102; by id dfseq; run;
	proc sort data= glnd.plate103; by id dfseq; run;

	* gather dates and infection data from forms;

	data glnd_rep.suspected_noso_before_adj ;
		merge	glnd.plate101 (in = frozen keep = id dfseq dt_infect cult_obtain cult_positive cult_org_code_1)
				glnd.plate102 (keep = id dfseq cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5 )
				glnd.plate103 (keep = id dfseq infect_confirm site_code type_code)
				glnd_cur.plate101 (keep = id dfseq org_spec_1)
				glnd_cur.plate102 (keep = id dfseq org_spec_2 org_spec_3 org_spec_4 org_spec_5)
				;
		by id dfseq;

******** fix the output by wbh 09282010 *******************************************;
***********************************************************************************;
		if lowcase(scan(org_spec_1,1))='yeast' then org_spec_1='Yeast not specified';
		if lowcase(scan(org_spec_2,1))='yeast' then org_spec_2='Yeast not specified';
		if lowcase(scan(org_spec_3,1))='yeast' then org_spec_3='Yeast not specified';
		if lowcase(scan(org_spec_4,1))='yeast' then org_spec_4='Yeast not specified';
		if lowcase(scan(org_spec_5,1))='yeast' then org_spec_5='Yeast not specified';

		if lowcase(strip(org_spec_1))='cadida not otherwise specified' then org_spec_1='candida not otherwise specified';
		if lowcase(strip(org_spec_2))='cadida not otherwise specified' then org_spec_2='candida not otherwise specified';
		if lowcase(strip(org_spec_3))='cadida not otherwise specified' then org_spec_3='candida not otherwise specified';
		if lowcase(strip(org_spec_4))='cadida not otherwise specified' then org_spec_4='candida not otherwise specified';
		if lowcase(strip(org_spec_5))='cadida not otherwise specified' then org_spec_5='candida not otherwise specified';

		if lowcase(strip(org_spec_1))='enterococcus species' then org_spec_1='Enterococcus species not specified';
		if lowcase(strip(org_spec_2))='enterococcus species' then org_spec_2='Enterococcus species not specified';
		if lowcase(strip(org_spec_3))='enterococcus species' then org_spec_3='Enterococcus species not specified';
		if lowcase(strip(org_spec_4))='enterococcus species' then org_spec_4='Enterococcus species not specified';
		if lowcase(strip(org_spec_5))='enterococcus species' then org_spec_5='Enterococcus species not specified';


		if lowcase(strip(org_spec_1))='klebsiella oxytoca' then org_spec_1='Klebsiella oxytoca';
		if lowcase(strip(org_spec_2))='klebsiella oxytoca' then org_spec_2='Klebsiella oxytoca';
		if lowcase(strip(org_spec_3))='klebsiella oxytoca' then org_spec_3='Klebsiella oxytoca';
		if lowcase(strip(org_spec_4))='klebsiella oxytoca' then org_spec_4='Klebsiella oxytoca';
		if lowcase(strip(org_spec_5))='klebsiella oxytoca' then org_spec_5='Klebsiella oxytoca';
		
		if lowcase(strip(org_spec_1))='enterococcus species, beta-lactama negative' then org_spec_1='Enterococcus species, beta-lactamase negative';
		if lowcase(strip(org_spec_2))='enterococcus species, beta-lactama negative' then org_spec_2='Enterococcus species, beta-lactamase negative';
		if lowcase(strip(org_spec_3))='enterococcus species, beta-lactama negative' then org_spec_3='Enterococcus species, beta-lactamase negative';
		if lowcase(strip(org_spec_4))='enterococcus species, beta-lactama negative' then org_spec_4='Enterococcus species, beta-lactamase negative';
		if lowcase(strip(org_spec_5))='enterococcus species, beta-lactama negative' then org_spec_5='Enterococcus species, beta-lactamase negative';


		if lowcase(strip(org_spec_1))='lactobacillus' then org_spec_1='Lactobacillus species';
		if lowcase(strip(org_spec_2))='lactobacillus' then org_spec_2='Lactobacillus species';
		if lowcase(strip(org_spec_3))='lactobacillus' then org_spec_3='Lactobacillus species';
		if lowcase(strip(org_spec_4))='lactobacillus' then org_spec_4='Lactobacillus species';
		if lowcase(strip(org_spec_5))='lactobacillus' then org_spec_5='Lactobacillus species';


/* This only work for before the cult_org_code_1 correction was made */
/*********************************************************************/

if org_spec_1="Cytomegalovirus" then cult_org_code_1=23;
if org_spec_1="2+ mixed gastro-intestinal flora" then cult_org_code_1=23;
if org_spec_2="Lactose fermenter gram negative rod" then cult_org_code_2=22;
if org_spec_3="Non-lactose fermenter gram negative rod" then cult_org_code_3=22;

	
		if id=41090 and org_spec_2="Not specified" then org_spec_2=" ";
		if id=41156 and cult_org_code_1=9 then cult_org_code_1=22;
		if id=41144 then org_spec_4='Streptococcus, viridans group';

		if ~frozen then delete;
	run;


proc sort nodupkey; by _all_;run;
proc sort; by id;run;

	data glnd_rep.suspected_noso_before_adj ;
		merge 	glnd_rep.suspected_noso_before_adj  (in = has_infection)
				glnd.status	(keep = id dt_random center apache_2)
			;
	
		by id;
		



		* delete people brought in from status with NO infections ;
			if ~has_infection then DELETE;

		* determine if prevalent or incident. 
			* incident if yes to nosocomial (pg 3) and more than 2 calendar days after randomization (though technically 48 hours after time of study drug starting, we do not record time of infection onset, nor is this something that is possible to determine) ;
			* prevalent if yes to nosocomial (pg 3) and less than 2 calendar days after randomization (though technically 48 hours after time of study drug starting, we do not record time of infection onset, nor is this something that is possible to determine) ;
	
		* determine infection onset ;	 
			days_post_entry = dt_infect - dt_random;	

			if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry > 2) then incident = 1;
			else if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry <= 2) then incident = 0;

		* recode vars for non-infections;
			if (infect_confirm > 2) then incident = .;  
			if site_code ="0000" then site_code = " ";
			if type_code ="0000" then type_code = " ";
				
		format 
			incident yn.;
			
		
		label
			incident = "Incident"
			days_post_entry = "Days post study entry"
			cult_positive="Culture positive?"
			cult_obtain="Culture obtained?"
	        	site_code="Site code"
	        	type_code="Type code"
			infect_confirm="Infection confirmed?"
			center = "Center"
		;

	run;


** CAPTURE SOME SAMPLE SIZES, FOR REPEAT USE **;

		* capture sample size of number of suspected infections;
			proc means data= glnd_rep.suspected_noso_before_adj noprint;
				output out= noso_n n(id) = id_n;
			run;
			data _null_;
				set noso_n;
		
				call symput('n_susp_infec', put(id_n, 3.0));
			run;
	
		* capture sample size of total people on study; 
			proc means data= glnd.status noprint;
				output out= study_n n(id) = id_n;
			run;
			data _null_;
				set study_n;
		
				call symput('n_study_1', put(id_n, 3.0));
			run;



** compile a SAVED dataset of all reported suspected infections, AFTER ADJUDICATION **;
	
	* combine plates 56 and 57;
	proc sort data = glnd.plate56; by id infect_visitno; run;
	proc sort data = glnd.plate57; by id infect_visitno; run;
	proc sort data = glnd_rep.suspected_noso_before_adj; by id dfseq; run;


proc print data=glnd.plate57; 
title "xxx";
where id=41076;
run;


	data adjudication;
		merge
			glnd.plate56 (	in = had_adj
					drop = dfcreate dfmodify dfplate dfraster dfscreen dfstatus dfvalid ptint 
						rename = (site_code = site_code_adj type_code = type_code_adj cult_pos = cult_positive_adj infect_confirm = infect_confirm_adj
								inf_onset_dt = dt_infect_adj ) )
			glnd.plate57 (drop = dfcreate dfmodify dfplate dfraster dfscreen dfstatus dfvalid )
			glnd_rep.suspected_noso_before_adj (rename = (dfseq = infect_visitno))
		;
		by id infect_visitno;
		
		
		if (had_adj) then adjudicated = 1; else adjudicated = 0;

		** make these two changes in the data for this DSMB report only **;
		if (id = 11041) & (infect_visitno = 106) then agree_site = 1;
		if (id = 12063) & (infect_visitno = 102) then agree_site = 1;
		
		if (id = 12155) & (infect_visitno = 103) then agree_site = 0;
		
		if type_code_adj = "PNUI" then type_code_adj = "PNU1"; * 3 such errors for this report;
		
			
		format adjudicated yn.;
	run;
	

/*
	proc contents data= glnd_rep.suspected_noso_before_adj ; run;
	proc contents data= adjudication ; run;
	proc contents data= glnd.plate56 ; run;
	proc contents data= glnd.plate57 ; run;
*/

	** Make a table that summarizes the number of cases adjudicated and the basic findings - infections confirmed and whether they are incident or not ** ;	
	
		*** total number of cases and patients ***;
			data ids_adjudicated;
				set adjudication;
				where adjudicated;
				by id;
			
				if ~first.id then delete;
			run;
		
			* total cases;
			proc means data = adjudication noprint;
				where (adjudicated) & (adjud_dt > mdy(&last_dsmb_date));
				output out = adjud_cases sum(adjudicated) = adjud_cases;
			run;

			* total people;
			proc means data = ids_adjudicated noprint;
				where (adjud_dt > mdy(&last_dsmb_date));
				output out = adjud_people sum(adjudicated) = adjud_people;
			run;
			
			* display portions for table;
			data adj_totals;
				merge 	adjud_cases
					adjud_people
				;
				* BY NOTHING - 1 obs;
												
				length row $70;
				length display_1 $25;
				length display_2 $25;
				
				row = " ";
				display_1 = "# infec. (# patients)";
				output;
								
				row = "Infections reviewed since last DSMB report:";
				display_1 = compress(put(adjud_cases, 4.0)) || " (" || compress(put(adjud_people, 4.0)) || ")";
				output;

				*** store total number of people's records adjudicated - when I report this in the summaries, we are assuming that if the adjudicator has reviewed any records
					for a patient, then he has reviewed them for ALL infection for that patient;
				call symput('n_adjudicated', put(adjud_people, 3.0));

			run;
			
				
				
		
		*** total agreement with original findings *** ;
		
	
		
			proc freq data = adjudication noprint;
				where adjudicated & (adjud_dt > mdy(&last_dsmb_date));
				tables agree_site / out = agree_summary outcum;
			run;		
			
	
			data adj_overview;
				set agree_summary;
				
				length row $70;
				length display_1 $25;
				length display_2 $25;

				
				if (_N_ = 1) then do;
					row = "Adjudicator agreed with clinical center findings?";
					display_1 = " ";
					output;
					order = -2;
				end;
			
				order = agree_site * -1 ; * remap 0 to 0 and 1 to -1 so that can properly sort;
				 
				row = "- " || compress(put(agree_site, yn.));
				display_1 = compress(put(count,4.0)) || "/" || compress(put(count/(percent/100),4.0)) || " (" || compress(put(percent, 4.1)) || "%)";
				output;
				
				if (agree_site = 0) then call symput("num_cases_not_agreed" , compress(put(count,4.0)));
			run;
			
			proc sort data = adj_overview; by order; run;
			
			
		*** show the changes in general findings ***; 
		
			proc freq data = adjudication noprint;
				where (adjudicated) & (agree_site = 0) & (adjud_dt > mdy(&last_dsmb_date));
				tables infect_confirm / out = orig_finding_summary missing ;
				tables infect_confirm_adj /out = adj_finding_summary missing;
			run;
			
			data compare_infect_confirm;	
				merge
					orig_finding_summary
					adj_finding_summary (rename = (infect_confirm_adj = infect_confirm  	count = count_adj 	percent = percent_adj))
				;
				by infect_confirm;
			
				if (_N_ = 1) then do;
					row = "Nosocomial infection confirmed?";
					display_1 = "== Locally ==";
					display_2 = "== Centrally ==";
					output;
				end;
			
				if count = . then count = 0; 	* some categories are missing ;
				if count_adj = . then count_adj = 0;
			
				row = "- " || put(infect_confirm, infect_confirm.);
				display_1 = compress(put(count,4.0)) || "/" || compress(&num_cases_not_agreed) || " (" || compress(put((count/&num_cases_not_agreed) * 100 , 4.1)) || "%)";
				display_2 = compress(put(count_adj,4.0)) || "/" || compress(&num_cases_not_agreed) || " (" || compress(put((count_adj/&num_cases_not_agreed) * 100, 4.1)) || "%)";
				output;
			run;
	
	
		*** total number of altogether new infections found - data from 	nosocomial_adjudicated_new_infections.sas ***;
			proc means data = glnd.adjudicated_new_infections;
				
				output out = new_infect sum(adjudicated_new_infect) = total_new_infect;
			run;
			
			data new_infect;
				set new_infect; 
			
				row = "Number of previously unreported infections found:";
				display_1 = "0"; 			***** DONE FOR March 2009 DSMB  compress(put(total_new_infect, 4.0)); 
				
			run;
	
			
	
		*** a blank row ***;
			data blank_row;
				row = " ";
				display_1 = " ";
				display_2 = " ";
			run;
			
			
		*** Stack the tables and print ***;
		*** STILL ADD: 	1. incident/prevalent summary *** ;
	
			data glnd_rep.nosocomial_adj_summary_open;
				set 	adj_totals
						blank_row
					adj_overview
						blank_row
					compare_infect_confirm
						blank_row
					new_infect
				;
			keep row display_1 display_2;	
				label 
					row = ' '
					display_1 = ' '
					display_2 = ' '
					;
			run;
			

	*ods pdf file = "/glnd/sas/reporting/nosocomial_adjudicated_summary_open.pdf" style = journal ;
	ods pdf file = "nosocomial_adjudicated_summary_open.pdf" style = journal ;
	ods ps file = "ns.ps" style = journal ;
			title "Summary of nosocomial infection adjudications since the last DSMB report";
			proc print data = glnd_rep.nosocomial_adj_summary_open noobs label style(header) = [just=center]; 
				var row ;

				label row='00'x
   			   display_1='00'x
   			   display_2='00'x;				var display_1 display_2 /style(data) = [just=center]; 
			run;
	ods ps close;
	ods pdf close;
	
			proc print data = adjudication;
				where (adjudicated) & (agree_site = 0);
				var id infect_visitno infect_confirm_adj;
			run;
		

	** Make a table of the pre-adjudication results, for those people who were adjudicated! **;
	
		data adjudicated_people_before;
			set adjudication;
			where adjudicated & (adjud_dt > mdy(&last_dsmb_date));
		run;
	
		%nosocomial_episode_table_open(datasource = adjudicated_people_before, filename = nosocomial_before_adj_open, n_study = &n_adjudicated, custom_title = "Details of reported nosocomial infections for &n_adjudicated patients, prior to review");



	** Now go through the changed infections and update those records **;
	


	* reduce dataset to only those infections which have changed ;
	data adj_changed;
		set adjudication;
	
    	if id=41076 and infect_visitno=104 then cult_a_org='Enterococcus species, beta-lactamase negative';
	
		incident_prev = incident; 

		if (agree_site = 0) then do;

			** SECTION 1 ** ;
			if (infect_confirm_adj ~= .) then do;
			
				infect_confirm = infect_confirm_adj;
				site_code = site_code_adj;
				type_code = type_code_adj;
			end;
			

			if (dt_infect_adj ~= .) then do;
			
				*** update date of infection;
				dt_infect = dt_infect_adj;
			
				days_post_entry = dt_infect - dt_random;	

			end;

			if (cult_positive_adj ~= .) then cult_positive = cult_positive_adj;

			*** recalculate incidence ;
				
				if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry > 2) then incident = 1;
				else if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry <= 2) then incident = 0;

				* recode vars for non-infections;
				if (infect_confirm > 2) then incident = .;  
			
			* I am skipping the "new infection at the same site question" for now because it does have any bearing on this report.
				This is more of an interal check to ensure that the infection is truly unique. However, Section 1, Q3 (infect_confirm)
				pretty much answers this! ;
			
			
			** CHANGE ORGANISMS **;
			
			if (cult_a_no ~= .) then do;
			
				** ADD/CHANGE **;
				* cannot use CALL SYMPUT or macro variables here since they are saved only once at end of data step, not for each record! thus the huge repetition of code;
				if ~(cult_a_code in (. , 99)) & (cult_a_no = 1) then do; cult_org_code_1 = cult_a_code; org_spec_1 = cult_a_org;  end; * beta-lactamase producer not needed;
				if ~(cult_a_code in (. , 99)) & (cult_a_no = 2) then do; cult_org_code_2 = cult_a_code; org_spec_2 = cult_a_org;  end; * beta-lactamase producer not needed;
				if ~(cult_a_code in (. , 99)) & (cult_a_no = 3) then do; cult_org_code_3 = cult_a_code; org_spec_3 = cult_a_org;  end; * beta-lactamase producer not needed;
				if ~(cult_a_code in (. , 99)) & (cult_a_no = 4) then do; cult_org_code_4 = cult_a_code; org_spec_4 = cult_a_org;  end; * beta-lactamase producer not needed;
				if ~(cult_a_code in (. , 99)) & (cult_a_no = 5) then do; cult_org_code_5 = cult_a_code; org_spec_5 = cult_a_org;  end; * beta-lactamase producer not needed;
							
				** DELETE **;
				if (cult_a_code = 99) & (cult_a_no = 1) then do; cult_org_code_1 = .; org_spec_1 = ""; end; * beta-lactamase producer not needed;
				if (cult_a_code = 99) & (cult_a_no = 2) then do; cult_org_code_2 = .; org_spec_2 = ""; end; * beta-lactamase producer not needed;
				if (cult_a_code = 99) & (cult_a_no = 3) then do; cult_org_code_3 = .; org_spec_3 = ""; end; * beta-lactamase producer not needed;
				if (cult_a_code = 99) & (cult_a_no = 4) then do; cult_org_code_4 = .; org_spec_4 = ""; end; * beta-lactamase producer not needed;
				if (cult_a_code = 99) & (cult_a_no = 5) then do; cult_org_code_5 = .; org_spec_5 = ""; end; * beta-lactamase producer not needed;
				
			end;
			
			if (cult_b_no ~= .) then do;
			
				** ADD/CHANGE **;
				if ~(cult_b_code in (. , 99)) & (cult_b_no = 1) then do; cult_org_code_1 = cult_b_code; org_spec_1 = cult_b_org;  end; * beta-lactamase producer not needed;
				if ~(cult_b_code in (. , 99)) & (cult_b_no = 2) then do; cult_org_code_2 = cult_b_code; org_spec_2 = cult_b_org;  end; * beta-lactamase producer not needed;
				if ~(cult_b_code in (. , 99)) & (cult_b_no = 3) then do; cult_org_code_3 = cult_b_code; org_spec_3 = cult_b_org;  end; * beta-lactamase producer not needed;
				if ~(cult_b_code in (. , 99)) & (cult_b_no = 4) then do; cult_org_code_4 = cult_b_code; org_spec_4 = cult_b_org;  end; * beta-lactamase producer not needed;
				if ~(cult_b_code in (. , 99)) & (cult_b_no = 5) then do; cult_org_code_5 = cult_b_code; org_spec_5 = cult_b_org;  end; * beta-lactamase producer not needed;
							
				** DELETE **;
				if (cult_b_code = 99) & (cult_b_no = 1) then do; cult_org_code_1 = .; org_spec_1 = ""; end; * beta-lactamase producer not needed;
				if (cult_b_code = 99) & (cult_b_no = 2) then do; cult_org_code_2 = .; org_spec_2 = ""; end; * beta-lactamase producer not needed;
				if (cult_b_code = 99) & (cult_b_no = 3) then do; cult_org_code_3 = .; org_spec_3 = ""; end; * beta-lactamase producer not needed;
				if (cult_b_code = 99) & (cult_b_no = 4) then do; cult_org_code_4 = .; org_spec_4 = ""; end; * beta-lactamase producer not needed;
				if (cult_b_code = 99) & (cult_b_no = 5) then do; cult_org_code_5 = .; org_spec_5 = ""; end; * beta-lactamase producer not needed;
				
			end;			
			
			if (cult_c_no ~= .) then do;
			
				** ADD/CHANGE **;
				if ~(cult_c_code in (. , 99)) & (cult_c_no = 1) then do; cult_org_code_1 = cult_c_code; org_spec_1 = cult_c_org;  end; * beta-lactamase producer not needed;
				if ~(cult_c_code in (. , 99)) & (cult_c_no = 2) then do; cult_org_code_2 = cult_c_code; org_spec_2 = cult_c_org;  end; * beta-lactamase producer not needed;
				if ~(cult_c_code in (. , 99)) & (cult_c_no = 3) then do; cult_org_code_3 = cult_c_code; org_spec_3 = cult_c_org;  end; * beta-lactamase producer not needed;
				if ~(cult_c_code in (. , 99)) & (cult_c_no = 4) then do; cult_org_code_4 = cult_c_code; org_spec_4 = cult_c_org;  end; * beta-lactamase producer not needed;
				if ~(cult_c_code in (. , 99)) & (cult_c_no = 5) then do; cult_org_code_5 = cult_c_code; org_spec_5 = cult_c_org;  end; * beta-lactamase producer not needed;
							
				** DELETE **;
				if (cult_c_code = 99) & (cult_c_no = 1) then do; cult_org_code_1 = .; org_spec_1 = ""; end; * beta-lactamase producer not needed;
				if (cult_c_code = 99) & (cult_c_no = 2) then do; cult_org_code_2 = .; org_spec_2 = ""; end; * beta-lactamase producer not needed;
				if (cult_c_code = 99) & (cult_c_no = 3) then do; cult_org_code_3 = .; org_spec_3 = ""; end; * beta-lactamase producer not needed;
				if (cult_c_code = 99) & (cult_c_no = 4) then do; cult_org_code_4 = .; org_spec_4 = ""; end; * beta-lactamase producer not needed;
				if (cult_c_code = 99) & (cult_c_no = 5) then do; cult_org_code_5 = .; org_spec_5 = ""; end; * beta-lactamase producer not needed;
				
			end;
					
			** don't worry about text display here. do that in recycled table-layout program! **;

		end;
		
		if id=41076 and infect_visitno=105 then org_spec_1='Klebsiella oxytoca';
		

		format site_code_adj $site_code. type_code_adj $type_code.;

	run;
	

	proc freq data = adj_changed;
		tables incident*incident_prev;
	run;


	* ADD IN ALTOGETHER NEWLY DISCOVERED INFECTIONS DURING ADJUDICATION! 
	;
	proc sort data= glnd.plate52; by id dfseq; run;
	proc sort data= glnd.plate53; by id dfseq; run;
	proc sort data= glnd.plate54; by id dfseq; run;

	* gather dates and infection data from forms;

	data new_noso ;
		merge		glnd.plate52 (in = frozen keep = id dfc dfseq dt_infect cult_obtain cult_positive cult_org_code_1 org_spec_1 rename =(dfc = adjud_dt))
				glnd.plate53 (keep = id dfseq cult_org_code_2 cult_org_code_3 cult_org_code_4 cult_org_code_5 org_spec_2 org_spec_3 org_spec_4 org_spec_5)
				glnd.plate54 (keep = id dfseq site_code type_code)

				;
		by id dfseq; 		* <--- Note that this dfseq is not in sequence with "infect_visitno". this should be fixed using max (infect_visitno) for each ID + 1;
		
		
		*** ADD THESE VARIABLES TO EACH NEW INFECTION OBSERVATION ***;
		infect_confirm = 1;
		adjudicated = 1;
		adjudicated_new_infect = 1;
		*** END ***;


		* determine if prevalent or incident. 
			* incident if yes to nosocomial (pg 3) and more than 2 calendar days after randomization (though technically 48 hours after time of study drug starting, we do not record time of infection onset, nor is this something that is possible to determine) ;
			* prevalent if yes to nosocomial (pg 3) and less than 2 calendar days after randomization (though technically 48 hours after time of study drug starting, we do not record time of infection onset, nor is this something that is possible to determine) ;
	
			* determine infection onset ;	 
			days_post_entry = dt_infect - dt_random;	

			if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry > 2) then incident = 1;
			else if ((infect_confirm = 1) | (infect_confirm = 2)) & (days_post_entry <= 2) then incident = 0;



		if lowcase(scan(strip(org_spec_1),1))='serratia' then org_spec_1='Serratia marcescens';
		if lowcase(scan(strip(org_spec_2),1))='serratia' then org_spec_2='Serratia marcescens';
		if lowcase(scan(strip(org_spec_3),1))='serratia' then org_spec_3='Serratia marcescens';
		if lowcase(scan(strip(org_spec_4),1))='serratia' then org_spec_4='Serratia marcescens';
		if lowcase(scan(strip(org_spec_5),1))='serratia' then org_spec_5='Serratia marcescens';	
	
	run;
	

	
title "new adjudicated infections";
proc contents data = adj_changed;
run;


* deal with altogether newly reported infections - CREATE GLND.NOSOCOMIAL_ADJUDICATED_NEW_INFECT.SAS7BDAT? ;



** NEXT. 1. produce permanent dataset of all infection data, post-adjudication (ADD IN NEW INFECTIONS) **
	2. feed both pre and post dataset to a table-reporting by-cases macro that reports on the infections that were adjudicated ;





** PRODUCE THE FULL PRE-ADJUDICATION NOSOCOMIAL INFECTION EPISODE TABLE, AS ORIGINALLY DONE IN NOSOCOMIAL_OPEN.SAS **;
** discountinued for March 2009 report - we now report this table on the hybrid dataset that is both adjudicated and not **;
*	%nosocomial_episode_table_open(datasource = glnd_rep.suspected_noso_before_adj, filename = nosocomial_episode_table_open, n_study = &n_study_1 , custom_title = "All reported infections for &n_study patients - not adjudicated");

	



title; 

** Make a table of the post-adjudication results, for those people who were adjudicated! **;
	
		data glnd_rep.suspected_noso_after_adj;
			set 
				adj_changed							/* ADJUDICATED CHANGES TO REPORTED INFECTIONS */  
				new_noso	;			/* NEW INFECTIONS DISCOVERED THROUGH ADJUDICATION PROCESS */	
				* glnd.adjudicated_new_infections;	/* OLD VERSION  */

			where adjudicated;
		run;
		




	
	
		data adj_new;
			set glnd_rep.suspected_noso_after_adj;
			where (adjud_dt > mdy(&last_dsmb_date));
		run;



		%nosocomial_episode_table_open(datasource = adj_new, filename = nosocomial_after_adj_open, n_study = &n_adjudicated, custom_title = "Details of confirmed nosocomial infections for &n_adjudicated patients, after review");



** Sort pre and post-adjudication datasets, create a hybrid infection dataset that contains the adjudicated records for those adjudicated
	and the non-adjudicated records for those IDs not yet adjudicated ;

	proc sort data =  glnd_rep.suspected_noso_before_adj; by id site_code type_code dt_infect ; run;
	proc sort data =  glnd_rep.suspected_noso_after_adj; by id site_code type_code dt_infect ; run;
	


	data non_adj_folks;
		merge 	glnd_rep.suspected_noso_before_adj
				glnd_rep.suspected_noso_after_adj (in = adjudicated keep = id)
		;

		by id;	
		
		if adjudicated then delete;

	run;
	


	* this is the patient infections, with the adjudicated infection data for those people adjudicated ;
	data glnd_rep.all_infections_with_adj;
		set
			non_adj_folks
			glnd_rep.suspected_noso_after_adj
			;
	run;



goptions reset=all;
options papersize=("7.75" "10");


	%nosocomial_episode_table_open(datasource = glnd_rep.all_infections_with_adj, filename = nosocomial_episode_table_open, n_study = &n_study_1 , custom_title = "All reported infections for &n_study patients - with adjudications applied");

proc print data=glnd_rep.all_infections_with_adj; title "wbh"; where id=42092; run;


*** 10/30/08 - I need a listing of the BSI in the adjudicated dataset ;

ods rtf file = "/glnd/sas/reporting/BSI.rtf" style = journal;

	proc print data = glnd_rep.suspected_noso_after_adj;
		var id agree_site site_code site_code_adj;
	run;
	
ods rtf close;

** 8/13/09 - I need a text listing of all infections "Other" infections ;

options orientation = landscape;
	
ods rtf file = "/glnd/sas/reporting/nosocomial_other_infection_listing.rtf" style = journal;
	title "Listing of all organisms associated with 'other' infections - 9/9/09";
	proc print data = glnd_rep.all_infections_with_adj;
		where (cult_org_code_1 = 21) | (cult_org_code_2 = 21) | (cult_org_code_3 = 21) | (cult_org_code_4 = 21) | (cult_org_code_5 = 21) ;
		var id dfseq infect_confirm site_code org_spec_1  org_spec_2 org_spec_3 org_spec_4 org_spec_5;
	run;
ods rtf close;

/*
	proc print data = glnd_rep.suspected_noso_before_adj ;
		where id = 21039;
	run;


proc contents data=glnd_rep.all_infections_with_adj;run;

*/

