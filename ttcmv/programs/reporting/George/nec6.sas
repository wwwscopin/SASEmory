* TIME TO NEC PLOT ;

data necdate; merge cmv.completedstudylist (in=a) cmv.nec; if a; keep id necdate; if dfseq = 161; run;
/*proc sort data = cmvkm_rbc_variables; by id; run;*/
proc sort data = cmv.snap out = snap; by id; run;
data hb; set cmv.med_review; if dfseq = 1; keep id hb; run;
proc sort data = hb; by id; run; 

data dob;
   set cmv.plate_005;
   keep id lbwidob;
data cmvkm; 	merge 	cmv.completedstudylist (in=a)
								/*cmv.lbwi_demo (keep = id lbwidob gender birthweight gestage)*/ 
								cmv.endofstudy (keep = id studyleftdate)
								necdate (in=b)
								dob
								/*cmvkm_rbc_variables*/
								snap (keep = id SNAPTotalScore rename = (snaptotalscore = snap))
								hb;
					by id; if a; if b then has_nec = 1; else has_nec = 0;

	time = necdate - lbwidob; 

	if time = . then censor = 1;
		else censor = 0;

	if time = . then time = studyleftdate - lbwidob;

	if hb >= 14.4 then hb_cat = 1; if hb < 14.4 then hb_cat = 0;

run;

data age;
  set cmv.age_of_blood;
  keep id age_of_blood datetransfusion;
if age_of_blood <0 then delete;
run;
      
proc sort; by id datetransfusion;
run;

data all;
  
     merge cmvkm age;
      by id;
     timetr=datetransfusion-lbwidob;
     if timetr gt .;
     if age_of_blood ge 14;
      bage=1;
      if datetransfusion gt necdate and necdate ne . then delete;
      
        
 proc means noprint;
    var bage;
    by id ;
    output out=new sum=ntrans14;
 run;

    
 data final;
   merge   cmvkm new;
   by id;
     if ntrans14=. then ntrans14=0;
   
proc sort; by censor;

ods pdf file = 'nec6.pdf';
   proc print;
  var id ntrans14 censor;
run;
proc ttest;
 class censor;
 var ntrans14;
run;
   

title Number of transfustions 14+ days Overall;
proc phreg ;
   model time*censor(1) = ntrans14 / risklimits;
   
run;


	ods pdf close;
