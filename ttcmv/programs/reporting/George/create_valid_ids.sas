data cmv.valid_ids; set cmv.plate_001;

	if enrollmentdate ~= .;
	moc_id = input(substr(put(id,7.0),1,5),5.0);
	keep id moc_id;

run;


*** keep only if has LBWI demographic ;

data lbwi_demo_ids; set cmv.lbwi_demo; keep id; run;

proc sort data = cmv.valid_ids; by id; run;
proc sort data = lbwi_demo_ids; by id; run;

data cmv.test1; merge cmv.valid_ids; merge cmv.valid_ids (in=b) lbwi_demo_ids (in=a); by id; if a; if ~b; run;

data cmv.valid_ids; merge cmv.valid_ids lbwi_demo_ids (in=a); by id; if a; run;



*** keep only if has MOC demographic ;

data moc_demo_ids; set cmv.moc_demo; 
	moc_id = input(substr(put(id,7.0),1,5),5.0);
	keep moc_id; 
run;

proc sort data = cmv.valid_ids; by moc_id; run;
proc sort data = moc_demo_ids; by moc_id; run;

data cmv.test2; merge cmv.valid_ids; merge cmv.valid_ids (in=b) moc_demo_ids (in=a); by moc_id; if a; if ~b; run;

data cmv.valid_ids; merge cmv.valid_ids moc_demo_ids (in=a); by moc_id; if a; run;



*** remove patients withdrawn from study ;

proc sort data = cmv.endofstudy out = reasonleft; by id; run;
proc sort data = cmv.valid_ids; by id; run;
data cmv.valid_ids; merge cmv.valid_ids reasonleft (keep = id reason); by id; run;
data cmv.valid_ids; set cmv.valid_ids; if reason = 4 | reason = 5 then delete; run;
data cmv.valid_ids; set cmv.valid_ids; if moc_id = 30015 then delete; run;




* print # of LBWI, MOC in sas log ;

proc sql; select count(distinct(id)),count(distinct(moc_id)) into :lbwi_n, :moc_n from cmv.valid_ids;
%put &lbwi_n; 
%put &moc_n;
 
 

* create completed study list SAS databset ;

data cmv.completedstudylist; set cmv.endofstudy; if reason = 4 | reason = 5 then delete; 
	center = floor(id/1000000); 
	moc_id = input(substr(put(id,7.0),1,5),5.0);
	keep id moc_id center; 
run;

proc sql; select count(distinct(id)),count(distinct(moc_id)) into :lbwi_n, :moc_n from cmv.completedstudylist;
%put &lbwi_n; 
%put &moc_n;





