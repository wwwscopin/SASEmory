
*** transform BM Feeding log ;

%macro bm();
data cmv.breastfeedlog_long;
	set cmv.breastfeedlog;
	%do i=1 %to 15;
		center=floor(id/1000000);
		EndDate=EndDate&i;
		StartDate=StartDate&i;
		fresh_milk=fresh_milk&i;
		frozen_milk=frozen_milk&i;
		moc_milk=moc_milk&i;
		donor_milk=donor_milk&i;
		comments=comments&i;
		output;
	%end;

	keep id EndDate StartDate fresh_milk frozen_milk moc_milk donor_milk comments; 
	format  StartDate EndDate mmddyy8. center center.;
run;
%mend;

%bm(); quit;
data cmv.breastfeedlog_long; set cmv.breastfeedlog_long; if StartDate ~= .; if EndDate ~=.; run;

***********************************************************************************;
*** keep only data up to DOL28 ;
proc sort data = cmv.breastfeedlog_long out = bm; by id; run;
proc sort data = cmv.lbwi_demo out = lbwi_demo; by id; run;
proc sort data = cmv.completedstudylist; by id; run;

data bm; merge bm (in=b) lbwi_demo (keep = id lbwidob) cmv.completedstudylist (in=a); 
	by id; if a&b; 

	day28 = lbwidob + 27;

	if startdate > day28 then delete;
	if enddate > day28 then enddate = day28;

run;

* these are mistakes. identify them for quality control and then delete them 
  so they don't mess up the calculations. ;
proc print data = bm; where startdate < lbwidob; run;
data bm; set bm;
	if startdate < lbwidob then delete;
run;

*** calculate days breast fed in first 28 days ;
proc sort data = bm; by id startdate; run;
data dayson; 
	array start{100};
	array end{100};
	do i=1 to 100; set bm; by id; 
		start(i) = startdate; 
		end(i) = enddate; 
		if last.id then return; 
	end;
run;

data dayson; set dayson;
	array start{100};
	array end{100};
	array days{100}; do k=1 to 100; days(k)=0; end;
	do j=1 to i; 
		startval = start(j) - start(1) + 1; 
		endval = end(j) - start(1) + 1; 
	do k=startval to endval;
		days(k) = 1;
	end;
	end;
	bm28 = sum(of days1-days100);
run;

data bmfeeding_first28days; merge dayson (in=a keep = id bm28) cmv.completedstudylist (in=b keep=id); 
	by id;
	if ~a&b then bm28 = 0; 
	label bm28 = "Number of days LBWI received any breast milk in first 28 days";
run;

data cmv.bmfeed28;    
    set bmfeeding_first28days;
run;
