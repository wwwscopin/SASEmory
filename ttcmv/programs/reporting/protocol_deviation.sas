
data cmv.plate_115; set cmv.plate_115;
	label formcompletedby = "Deviation Reported By";
run;

proc sort data = cmv.plate_115; by deviationdate; run;

	options nodate nonumber orientation = portrait;
	ods rtf file = "&output./protocol_deviations.rtf" style=journal;
		title "Protocol Deviations Listing";
		proc print data = cmv.plate_115 label noobs; 
			var id mocinit formcompletedby deviationdate comments;
		run;

	ods rtf close;
