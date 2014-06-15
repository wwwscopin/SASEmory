
proc format library = work;
	value lt_forty
		1 = "<= 40"
		2 = "> 40 & <= 50"
	;
run;

proc freq data = glnd.plate201;
	tables ae_type;
run;

data ae_temp;
	set glnd.plate201;
	
	where (ae_type = 15);

	if (ae_glycemia = 2) & (glucose = .) then lt_forty = .;
	else if (ae_glycemia = 2) & (glucose <= 40) then lt_forty = 1;
	else if (ae_glycemia = 2) & (glucose <= 50) then lt_forty = 2;
	format lt_forty lt_forty.;

	center = floor(id/10000);
	format center center.;
run;

* add an indicator for individuals ;
proc sort data =ae_temp; by id lt_forty; run; 

data ae_temp;
	set ae_temp;
	
	by id lt_forty;
	
	if first.lt_forty then indiv =1;
run;

ods pdf file = "/glnd/sas/reporting/hypo_hyper_open.pdf" style = fancyprinter;
	title "Summary of hyperglycemia and hypoglycemia adverse events";
	proc freq data = ae_temp;
		tables center * ae_glycemia /missing nopercent;
	run;
	
	title "All hyperglycemic events, by center and id";
	proc print data = ae_temp;
		where ae_glycemia = 1;
		id id;
		by id;
		var center;
	run;
	
	* hypo <40, <50;
	title "Blood glucose levels among hypoglycemic events - # of episodes";
	proc freq data = ae_temp;
		where (ae_glycemia = 2);
		tables center * lt_forty /missing nopercent;
	run;
	
	* hypo <40, <50;
	title "Blood glucose levels among hypoglycemic events - # of people";
	proc freq data = ae_temp;
		where (ae_glycemia = 2) & (indiv = 1);
		tables center * lt_forty /missing nopercent;
	run;
	
	proc print data = ae_temp;
		where ae_glycemia = 2;
		id id;
		by id;
		var center lt_forty;
	run;
	

	
	
run;


/**** George stuff

 if hyper=1 or hypo=1;
keep id hyper hypo;
run; 
proc means noprint;
by id;
output out=hh mean=hyper hypo;
data hh1;
 set hh;
center=int(id/10000);
format center center.;
proc freq;
tables center *(hyper hypo);
run; 
*/
