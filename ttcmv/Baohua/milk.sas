/*
proc contents data=cmv.BM_nat;run;
proc print data=cmv.BM_nat;run;
*/

proc format;
	value test 
			1="Not detected"
			2="Low Positive (<300 copies/mL)"
			3="Positive"
			4="Indeterminate"
			99="N/A"
			;
	value wk 
			1="Week 1 Sample"
			3="Week 3 Sample"
			4="Week 4 Sample"
			5="Day 34-40 Sample"
			;
run;

%macro bm(dataset);
data tmp;
	set &dataset;
		center=floor(id/1000000);
		NATCopy=NATCopy_wk1;
		NATResult=NATResult_wk1;
		milk_date=milk_date_wk1;
		test_date=test_date_wk1;
		test_person=test_person_wk1;
		day=test_date-milk_date;
		wk=1;
		output;
	%do i=3 %to 4;
		center=floor(id/1000000);
		NATCopy=NATCopy_wk&i;
		NATResult=NATResult_wk&i;
		milk_date=milk_date_wk&i;
		test_date=test_date_wk&i;
		test_person=test_person_wk&i;
		wk=&i;
		day=test_date-milk_date;
		output;
	%end;

		center=floor(id/1000000);
		NATCopy=NATCopy_d34;
		NATResult=NATResult_d34;
		milk_date=milk_date_d34;
		test_date=test_date_d34;
		test_person=test_person_d34;
		wk=5;
		day=test_date-milk_date;
		output;


		keep id center NATCopy NATResult milk_date  test_date day test_person wk;
		format center center. milk_date  test_date mmddyy8. NATResult test. wk wk.;
run;
%mend;

%bm(cmv.BM_nat);
quit;

proc sort nodupkey; by wk;run;

proc print;run;

proc freq data=tmp;
	tables NATResult;
run;
