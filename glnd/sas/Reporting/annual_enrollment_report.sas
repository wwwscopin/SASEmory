* generates a report gender * (hispanic race) for the annual GLND grant enrollment report ;

proc freq data = glnd.demo_his;
	tables (hispanic race) * gender;
run;


proc freq data = glnd.demo_his;
	where hispanic;
	tables race * gender;
run;
