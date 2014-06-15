%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


data screening;	set cmv.plate_001 (rename = (isEligible = enrolled));

	center = floor(id/1000000);
	format center center.;

	if (InWeight & InLife & ~ExLifeExpect & ~ExAbnor & ~ExTX & ~ExMOCPrevEnrolled) then	elig_criteria = 1;
	else elig_criteria = 0;

	format date monname.;
	date = mdy(month(screeningdate), 1, year(screeningdate));
		
	drop DFSTATUS  DFVALID  DFRASTER  DFSTUDY  DFPLATE  DFSEQ DFSCREEN  DFCREATE  DFMODIFY;

run;


data refused; set screening;
	*Keep eligible - did not consent; 
		if elig_criteria = 1 & enrollmentdate = .;
run;

data other; set refused; if refuseother = 1; run; 

options nodate orientation = portrait;
	ods rtf file = "&output./reasons_refused_other.rtf" style=journal toc_data startpage = yes bodytitle;
		proc print data = other label noobs split = "*" style(header) = [just=center] contents = "";

				var center ID refuseothertext  / style(data) = [just=center];				

				label center = "Hospital"
						 ID = "Patient ID*"
						 refuseothertext = "Reasons not enrolled*"
				;

				run;

		ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
	ods rtf close;

proc sort data = refused out = refused_bydate; by center screeningdate; run;

data refused_bydate; set refused_bydate;
	length reason_text $ 100; 
		if mocnotavailable = 1 then reason_text = "Mother not available";
		if participationfear = 1 then reason_text = "Scared to participate in research";
		if blooddraws = 1 then reason_text = "`Too many blood draws`";
		if toomanytrials = 1 then reason_text = "`Too many research trials`";
		if dangertochild = 1 then reason_text = "`Dangerous for my child`";
		if reasonunk = 1 then reason_text = "No reason given";
		if oth = 1 then reason_text = "Other";
run;

	ods rtf file = "&output./reasons_refused_listing.rtf" style=journal toc_data startpage = yes bodytitle;
		proc print data = refused_bydate label noobs split = "*" style(header) = [just=center] contents = "";

				var center screeningdate ID reason_text refuseothertext  / style(data) = [just=center];				

				label center = "Hospital"
						 screeningdate = "Screening date"
						 ID = "Patient ID*"
						 reason_text = "Reason refused consent"
						 refuseothertext = "Reason given under `other`*"
				;

				run;

		ods rtf text = "{\sectd \pard \par \sect}"; * insert section and page breaks ;
	ods rtf close;



***** RECODE ;;;;;



data refused; set refused;
 
	if 	id = 1001319 | id = 1001329 | id = 1001339 | id = 1001519 | id = 1001529 | id = 1002219 | id = 1005119 | 
			id = 1005619 | id = 2000619 | id = 2004519 | id = 2004529 | id = 3008319 | id = 3008619 | id = 3010219 |
			id = 3012919 | id = 3012929 | id = 3012939 | id = 3013019 | id = 3013519 | id = 3013529 
	then toomuchgoingon = 1; else toomuchgoingon = 0;
	label toomuchgoingon = "Mother too overwhelmed to consider participation";

	if 	id = 2002019 | id = 2004219 | id = 3001719 | id = 3003919 | id = 3007619 
	then noenglishorspanish = 1; else noenglishorspanish = 0;
	label noenglishorspanish = "No English nor Spanish";

	if 	id = 2003811 | id = 2004911
	then unabletomakedecisions = 1; else unabletomakedecisions = 0;
	label unabletomakedecisions = "Mother unable to make medical decisions";

	if 	id = 3000881 | id = 3007129 | id = 3007219 | id = 3008119 | id = 3008719 | id = 3008829 | id = 3010019 | 
			id = 3011619 | id = 3012219 | id = 3014919 | id = 3015619 
	then justnotinterested = 1; else justnotinterested = 0;
	label justnotinterested = "Mother `just not interested`";

	if id = 3009719 
	then couldntunderstand = 1; else couldntunderstand = 0;
	label couldntunderstand = "Mother could not understand study";

	if id = 1006819 
	then participationfear = 1;

	if id = 1002419 | id = 1002429 | id = 2000219 | id = 2006419
	then blooddraws = 1;

	* didn't write anything ;
	if id = 3009319 | id = 3010619 
	then reasonunk = 1; 

run;


data refused; set refused;

	if 	refuseother = 1 &
			mocnotavailable = 0 & participationfear = 0 & blooddraws = 0 & toomanytrials = 0 & dangertochild = 0 & reasonunk = 0 &
			toomuchgoingon = 0 & noenglishorspanish = 0 & unabletomakedecisions = 0 & justnotinterested = 0 &
			couldntunderstand = 0 & personalreasons = 0 
			| id = 3005719 | id = 3015519 
	then oth = 1; else oth = 0;

	if 	refuseother = 0 &
			mocnotavailable = 0 & participationfear = 0 & blooddraws = 0 & toomanytrials = 0 & dangertochild = 0 & reasonunk = 0 &
			toomuchgoingon = 0 & noenglishorspanish = 0 & unabletomakedecisions = 0 & justnotinterested = 0 &
			couldntunderstand = 0 & personalreasons = 0 
	then reasonunk = 1;

	if 	refuseother = 1 | mocnotavailable = 1 | participationfear = 1 | blooddraws = 1 | toomanytrials = 1 | dangertochild = 1 |
			toomuchgoingon = 1 | noenglishorspanish = 1 | unabletomakedecisions = 1 | justnotinterested = 1 |
			couldntunderstand = 1 | personalreasons = 1 
	then reasonunk = 0;


	label 
		mocnotavailable = "Mother not available"
		participationfear = "Scared to participate in research"
		blooddraws = "`Too many blood draws`"
		toomanytrials = "`Too many research trials`"
		dangertochild = "`Dangerous for my child`"
		reasonunk = "No reason given"
		oth = "Other"
	;

run;

data cmv.refused; set refused; run;

proc sort data = refused; by center date; run;


	%descriptive_stat(data_in= refused, data_out= refused_summary, var= mocnotavailable, type= bin, first_var=1);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= toomuchgoingon, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= justnotinterested, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= participationfear, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= noenglishorspanish, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= blooddraws, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= toomanytrials, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= unabletomakedecisions, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= couldntunderstand, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= dangertochild, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= reasonunk, type= bin);
	%descriptive_stat(data_in= refused, data_out= refused_summary, var= oth, type= bin, last_var=1);


	* print table ;
	%descriptive_stat(print_rtf = 1, 
			data_out= refused_summary, 
			file= "&output./monthly/&mon_file_reasons_no_consent.reasons_refused_consent.rtf", 
			title= "&mon_pre_reasons_no_consent Reasons patients eligible at screening were not enrolled"
		);








