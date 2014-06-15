

*** SNAP ;

proc sort data = cmv.snap; by id;
proc sort data = cmv.lbwi_demo; by id; run;

data cmv.snap; merge cmv.snap cmv.lbwi_demo (keep = id LBWIDOB); by id; run;



data cmv.snap; set cmv.snap;

	days_off_target = DateSNAPData - LBWIDOB;

run;



data cmv.snap; set cmv.snap;

	out_of_window = 0;
	if days_off_target > 5 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;
/* neeta set it to 0 to match with expected */
if days_off_target = . then out_of_window = 0;

run; 



*** SNAPII ;

proc sql;
	create table cmv.snap2 as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.snap2 b
	on a.id=b.id;
quit;



data cmv.snap2; set cmv.snap2;

	days_off_target = abs(DOLdate - (LBWIDOB + dfseq));
	if dfseq = 75 or dfseq = 161 or dfseq = 162 then days_off_target = .;

run;


data cmv.snap2; set cmv.snap2;

	out_of_window = 0;
	if days_off_target > 2 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

/* neeta set it to 0 to match with expected */
if days_off_target = . then out_of_window = 0;

run; 



*** Medical record review ;

proc sql;
	create table cmv.med_review as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.med_review b
	on a.id=b.id;
quit;



data cmv.med_review; set cmv.med_review;

	days_off_target1 = abs(anthromeasuredate - (LBWIDOB + dfseq));
	days_off_target2 = abs(bloodcollectdate - (LBWIDOB + dfseq));

	if days_off_target1 >= days_off_target2 then days_off_target = days_off_target1;
	if days_off_target2 > days_off_target1 then days_off_target = days_off_target2;

run;


data cmv.med_review; set cmv.med_review;

	out_of_window = 0;
	if days_off_target > 2 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

/* neeta set it to 0 to match with expected */
if days_off_target = . then out_of_window = 0;
	

	drop days_off_target1 days_off_target2;

run; 



*** Blood collection ;

proc sql;
	create table cmv.lbwi_blood_collection as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.lbwi_blood_collection b
	on a.id=b.id;
quit;

data cmv.lbwi_blood_collection; set cmv.lbwi_blood_collection;

	days_off_target = abs(natblooddate - (LBWIDOB + dfseq)); 

	* don't care about time windows at end of study / post-discharge ;
	if dfseq = 63 or dfseq = 65 then do; days_off_target = 0;end;

	out_of_window = 0;
	if days_off_target > 4  then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

/* neeta set it to 0 to match with expected */
if days_off_target = . then out_of_window = 0;
if  dfseq = 65 then do; days_off_target = .;out_of_window = .;end;
run;


*** Urine collection ;

proc sql;
	create table cmv.lbwi_urine_collection as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.lbwi_urine_collection b
	on a.id=b.id;
quit;

data cmv.lbwi_urine_collection; set cmv.lbwi_urine_collection;

	days_off_target = urinesampledate - LBWIDOB; 

	* don't care about time windows at end of study ;
	if dfseq = 63 then days_off_target = .;

	out_of_window = 0;
	if days_off_target > 4 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

run;


*** Breast milk collection ;

proc sql;
	create table cmv.bm_collection as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.bm_collection b
	on a.id=b.id;
quit;

data cmv.bm_collection; set cmv.bm_collection;

	if breastmilkobtained = 1 then target1 = LBWIDOB + dfseq - 7;
	if breastmilkobtained = 1 then target2 = LBWIDOB + dfseq; 

	if datetransferred >= target1 and datetransferred <= target2 then days_off_target = 0;
	if datetransferred < target1 then days_off_target = target1 - datetransferred;
	if datetransferred > target2 then days_off_target = datetransferred - target2;
	if breastmilkobtained ~= 1 then days_off_target = .;

	out_of_window = 0;
	if days_off_target > 1 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

run;


*** MOC enrollment blood collection ;

proc sql;
	create table cmv.moc_sero as
	select a.lbwidob, b.*
	from cmv.lbwi_demo a right join cmv.moc_sero b
	on a.id=b.id;
quit;

data cmv.moc_sero; set cmv.moc_sero;

	if dfseq = 1;

	days_off_target = DateBloodCollected - lbwidob;
	out_of_window = 0;
	if days_off_target > 5 then out_of_window = 1;
	if days_off_target = . then out_of_window = .;

/* neeta set it to 0 to match with expected */
if days_off_target = . then out_of_window = 0;

run;



