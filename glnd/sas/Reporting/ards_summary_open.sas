/* ards_summary_open.sas
 *
 * report on ARDS in GLND, through measures such as:
 *
 * 1. Any ARDS during hopsital stay
 *
 */

proc sort data= glnd.demo_his; by id; run;
proc sort data= glnd.plate26; by id; run;
proc sort data= glnd.plate31; by id; run;
proc sort data= glnd.plate39; by id; run;
proc sort data= glnd.plate40; by id; run;


data ards;
	set 	glnd.demo_his (in= from_demo keep = id ards)
			glnd.plate26 (keep = id dfseq ards dt_new_ards)
			glnd.plate31 (keep = id dfseq ards dt_new_ards)
			glnd.plate39 (keep = id dfseq ards dt_new_ards)
			glnd.plate40 (keep = id dfseq ards dt_new_ards)
	;

	if from_demo then dfseq=0; * mark baseline for now;

run;

proc sort data = ards; by id dfseq; run;

* print a listing to scan for all ARDS;
proc print data = ards;

	by id;
	var dfseq ards dt_new_ards;	
run;


* figure out the number of prevalent and incident ARDS people ;

	data ards_summary;
		set ards;
		by id;
		retain prevalent incident_person incident_case;
	
		if first.id then do;
			prevalent = 0;
			incident_person = 0;
			incident_case = 0;
		end;
	
		* determine if this is a prevalent person ; 
		if (dfseq = 0) & ards then prevalent = 1; 
	
		* if it is not baseline but they are listed as "ARDS" and have a date of onset, then this is a new ARDS onset ;
		if (dfseq ~= 0) & ards & (dt_new_ards ~= .) then do;
			incident_person = 1;
			incident_case = incident_case + 1;
		end; 
	run;

	* only keep the last record for each person as this contains the appropriate totals ;
	data ards_summary;
		set ards_summary;
		by id;
		
		if ~last.id then delete;
	run;



title "ards listing";
ods pdf file="ards.pdf" style=journal;
proc print noobs label style(data)=[just=center];
 id id;
 var ards prevalent incident_case incident_person;
run;

ods pdf close;

	
	proc means data = ards_summary n sum;
		var prevalent incident_person incident_case;
		output out = glnd_rep.ards_summary sum(prevalent incident_person incident_case) = s_prevalent s_incident_person s_incident_case n(prevalent) = n_prevalent;
	run;

	data glnd_rep.ards_summary;
		set glnd_rep.ards_summary;

		row = "ARDS";

		* compute percents ;
		prevalent_per = (s_prevalent / n_prevalent) * 100;
		incident_person_per = (s_incident_person / n_prevalent) * 100;

		
		* format the cells;

		prevalent = compress(put(s_prevalent, 4.0) || "/" || put(n_prevalent, 4.0)) || " (" || compress(put(prevalent_per, 4.1) || "%)"); 
		incident = compress(put(s_incident_case, 4.0)) || " " || compress("(" || put(s_incident_person, 4.0) || "/" || put(n_prevalent, 4.0)) || ", " || compress(put(incident_person_per, 4.1) || "%)"); 
			
		label 	
				prevalent = "Prevalent ARDS: \\# patients (% prev.)"
				incident = "Incident ARDS: \\# episodes (\\# patients, % incid.)"
				
				;


		keep row prevalent incident;
	run;
			
options nodate nonumber;
title;
ods pdf file = "/glnd/sas/reporting/ards_summary_open.pdf" style = journal;
	proc print data = glnd_rep.ards_summary noobs label split = "*"; 			* width=minimum style(table)= [font_width = compressed just = left];
		var prevalent /style(data) = [just=center]; * separate var statement for separate atrributes ;
		var incident /style(data) = [just=center]; * separate var statement for separate atrributes ;
	
	run;
ods pdf close;
