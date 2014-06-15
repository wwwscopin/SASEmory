* TIME TO NEC PLOT ;

data necdate; merge cmv.completedstudylist (in=a) cmv.nec; if a; keep id necdate; if dfseq = 161; run;
/*proc sort data = cmv.km_rbc_variables; by id; run;*/
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
								/*cmv.km_rbc_variables*/
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
     if age_of_blood < 14 then bage=0;
        else  bage=1;
        week=int(timetr/7)+1;
        
 *proc freq;
 *tables timetr;
 data x;
    array bag(90) bage0-bage89;
    do i=1 to 90;
       set all;
        by id;
        bag(timetr+1)=bage;
        if last.id then return;
    end;
    keep id bage1-bage90;
*proc means n sum;
run;


 data final;
   merge   cmvkm x;
   by id;
   array bage(90) bage0-bage89;
   do i=1 to 90;
       if bage(i)=. then bage(i)=0;
   end;
   do i=2 to 90;
      if bage(i-1)=1 then bage(i)=1;
  end;
    drop i;
*proc print;
run;
   

ods pdf file = 'nec4.pdf';
title Daily Exposure to 14+ day old blood;
title2 Once Exposed to 14+ day old blood always exposed ;
proc phreg ;
   model time*censor(1) = bloodage / risklimits;
   array bage (90) bage0-bage89;
        bloodage=bage[time];
run;


	ods pdf close;
