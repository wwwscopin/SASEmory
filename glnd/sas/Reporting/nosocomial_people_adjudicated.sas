* nosocomial_people_not_adjudicated.sas ;

* produce a table of IDs of people with nosocomial infection, still needing adjudication;

proc sort data = glnd.plate101; by id dfseq; run;				* reported suspected nosocomial infections ;
proc sort data = glnd.plate56; by id infect_visitno; run;		* adjudicated infections;


data non_adjudicated;
	merge 
		glnd.plate101		(keep = id dfseq rename = (dfseq = infect_visitno))
		glnd.plate56		(in = had_adj keep = id infect_visitno)
	;
	by id infect_visitno;

	if had_adj then adjudicated = 1; else adjudicated = 0;

	format adjudicated yn.; 
run;

	proc print data = non_adjudicated;
	run;

	proc means data = non_adjudicated n noprint;
		class adjudicated id;
		var infect_visitno;
		output out= adj_table n(infect_visitno) = num_infections; 
	run;

	proc sort data = adj_table; by _TYPE_ descending adjudicated; run;

	* add numbers to the table;
	data adj_table;
		set adj_table;
		by descending adjudicated;
		where _TYPE_ = 3; 	* just print the sums of adjudicated at each ;
		retain number;

		if first.adjudicated then number = 1;
		else number = number + 1;
		
		output;

		/** insert blank line between sections;
		if (adjudicated = 1) & (last.adjudicated) then do;
			number = .;
			num_infections = .;
			id = .;
			output;
		end;*/
	run;

options nodate nonumber;

ods pdf file = "/glnd/sas/reporting/nosocomial_people_adjudicated.pdf" style = journal;
	title "Summary of adjudication for GLND participants with reported suspected nosocomial infections";

	proc print data = adj_table label noobs;
		id adjudicated;
		by  descending adjudicated;
		
		var number id num_infections;
	
		sumby adjudicated;
		sum num_infections; 
		label 
			adjudicated = "Adjudicated"
			id = "GLND ID"
			number = "Num."
			num_infections = "# of susp. infections"
		;
	run;
ods pdf close;
