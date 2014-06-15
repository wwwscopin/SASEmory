options ls=120 orientation=portrait fmtsearch=(library) nofmterr;
%let path=H:\SAS_Emory\RedCap;
libname library "&path";		
libname brent "&path.\data";

data rest;
	set brent.rest1;
	if compress(patient_id,,"d")="CAS" then idx=1; 
	if compress(patient_id,,"d")="CON" then idx=0; 
	id=compress(patient_id,"CASON")+0;
	if idx=1;
run;
proc sort; by idx id; run;

data tdf;
	set brent.tdf;
	id=compress(study_no, "CASON")+0;
	keep id tdf d4t;
run;
proc sort; by id; run;

data brent.mutation;
	merge tdf(in=A) rest; by id; 
	if A;
run;
