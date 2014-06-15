


data ids; set cmv.endofstudy; keep id studyleftdate; run;

data seq; 
	input dfseq; datalines;
1
21
40
60
63
;
run;

proc sql; create table list as select distinct(ids.id), ids.studyleftdate, seq.dfseq from ids, seq; run;

data list; merge list (in=a) cmv.lbwi_demo (keep = id lbwidob); by id; if a; run;
data list; set list; if dfseq ~= 63 & studyleftdate < lbwidob + dfseq then delete; run;

proc sort data = list; by id dfseq; run;
proc sort data = cmv.lbwi_blood_collection; by id dfseq; run;
proc sort data = cmv.lbwi_blood_nat_result; by id dfseq; run;

data cmv.lbwi_blood; 
	merge 	list (in=a)
				cmv.lbwi_blood_collection (keep = id dfseq natbloodcollect natblooddate)
				cmv.lbwi_blood_nat_result (keep = id dfseq nattestdate)
	; by id dfseq; if a;
run;
