

options nodate orientation = portrait;
ods rtf file = "&output./end_of_study_list.rtf" style = journal bodytitle ;

		title1 "Patients reached End of study";
		proc print data = cmv.endofstudy label noobs; var id studyleftdate; run;

ods rtf close;


