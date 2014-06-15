proc sort data = cmv.endofstudy; by id; run;
proc sort data = cmv.df_id3; by id; run;

data cmv.df_id3; merge cmv.df_id3 (in=a) cmv.endofstudy (keep = id studyleftdate); 
	delay = 18597 - studyleftdate;

	center = floor(id/1000000);
	format center center.;

	label 
		delay = "#Days between End of Study date and 12/01/2010"
		studyleftdate = "End of Study Date"
	;
run;

options nodate orientation = portrait;
ods rtf file = "&output./failed_CRF_completion.rtf" style=journal;

	title1 f=swissb h=3 justify=center "Failed CRF Completion - DEC 2010";
	proc print data = cmv.df_id3 label noobs style(header) = {just=center};
		by center;
	run;

ods rtf close;
