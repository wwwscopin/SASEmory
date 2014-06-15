
proc sort data = cmv.nec out=necdates; by id necdate; run;
proc sort data = cmv.lbwi_demo out=dob; by id; run;

data necdates; 
	merge necdates (in=a) dob (keep = id lbwidob);
		by id; if a;
run;

data necdates; set necdates;
	episode = dfseq-160;
	keep id lbwidob episode necdate; 
run;


data necdates; retain id lbwidob episode; set necdates; 
	label id="ID" lbwidob="Date of Birth" episode="Episode number" necdate="Date of NEC diagnosis";
run;

proc export 
	data=necdates  
	outfile="/ttcmv/sas/output/nec_dates.csv"
	dbms=csv
	label
	replace;
run;



proc sort data = cmv.plate_031 out=rbc_txn; by donorunitid; run;
proc sort data = cmv.plate_001_bu out=donor_date nodup; by donorunitid; run;

data rbc_txn; 
	merge rbc_txn (in=a) donor_date (keep = donorunitid datedonated);
		by donorunitid; if a; 
run; 

proc sort data=rbc_txn; by id datetransfusion; run;

data rbc_txn; set rbc_txn;
	age_of_blood = datetransfusion - datedonated; 
	keep id datetransfusion donorunitid aliquotnum age_of_blood; 
run;


data rbc_txn; retain id; set rbc_txn; 
	label id="ID" datetransfusion="Date of RBC TXN" 
				donorunitid="Donor Unit ID" aliquotnum="Aliquot Number"
				age_of_blood="Age of Blood (days)";
run;

proc export 
	data=rbc_txn  
	outfile="/ttcmv/sas/output/rbc_txn_dates.csv"
	dbms=csv
	label
	replace;
run;


