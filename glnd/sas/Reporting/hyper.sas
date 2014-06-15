
data ae_temp;
	set glnd.ae_patients;
	
 
	keep id hyper hypo hypo1;
run;

proc sort data=ae_temp nodupkey; by id; run;


/*
* for each patient, go through each AE and determine whether they've had it and also sum up the number of AEs for later reporting of cases;
proc means;
	by id;
	var ae1-ae17 hyper hypo hypo1;
	output out=aes_by_patient max=ae1-ae17 
	sum = sum_ae1-sum_ae17 max(hyper hypo hypo1) = hyper hypo hypo1 sum(hyper hypo hypo1) = sum_hyper sum_hypo sum_hypo1;
*/



data hyper;
	set ae_temp;
where hyper=1;
run;

proc print;

title "hyper id listing";
ods pdf file="hyper.pdf" style=journal;
proc print data=hyper label style(data)=[just=center]; 
var id hyper;
run;

ods pdf close;






