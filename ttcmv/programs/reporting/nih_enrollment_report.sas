
data demo; set cmv.lbwi_demo;
	keep id gender race ishispanic; 
	label gender = "Gender" race = "Race" ishispanic = "Hispanic";
	format gender gender. race race. ishispanic yn.;
run;

proc sql; select count(distinct(id)) into :n from demo;


options nodate orientation = portrait;

ods rtf file = "&output./nih_enrollment_report.rtf" style=journal startpage = no bodytitle;
	
		title1 "Inclusion Enrollment Report - Total Enrollment N=&n";
		title2 "Part A. Total Enrollment Report: Number of subjects enrolled to date (cumulative), ethnicity and race by gender";
		proc freq data = demo; tables ishispanic*gender / nopct nocum nocol norow; run;
		title1 " ";
		title2 " ";
		proc freq data = demo; tables race*gender / nopct nocum nocol norow; run;

		title1 " ";
		title2 "Part B. Hispanic Enrollment Report: Number of Hispanics or Latinos enrolled to date (cumulative), race by gender";
		proc freq data = demo; where ishispanic=1; tables race*gender / nopct nocum nocol norow; run;

		title1 " ";
		title2 "Percentages for projections";
		proc freq data = demo; tables ishispanic*gender / nofreq nocum nocol norow; run;
		title1 " ";
		title2 " ";
		proc freq data = demo; tables race*gender / nofreq nocum nocol norow; run;		
	
ods rtf close;
