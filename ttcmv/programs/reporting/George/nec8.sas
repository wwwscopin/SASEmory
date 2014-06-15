* TIME TO NEC PLOT ;

data necdate; merge cmv.completedstudylist (in=a) cmv.nec; if a; keep id necdate; if dfseq = 161; run;
/*proc sort data = cmvkm_rbc_variables; by id; run;*/
proc sort data = cmv.snap out = snap; by id; run;
data hb; set cmv.med_review; if dfseq = 1; keep id hb hbdate; run;
proc sort data = hb; by id; run; 

data dob;
   set cmv.plate_005;
   keep id lbwidob;
data cmvkm; 	merge 	cmv.completedstudylist (in=a)
								/*cmv.lbwi_demo (keep = id lbwidob gender birthweight gestage)*/ 
								cmv.endofstudy (keep = id studyleftdate)
								necdate (in=b)
								dob
								
								;
					by id; if a; if b then has_nec = 1; else has_nec = 0;

	time = necdate - lbwidob; 

	if time = . then censor = 1;
		else censor = 0;

	if time = . then time = studyleftdate - lbwidob;

	if hb >= 14.4 then hb_cat = 1; if hb < 14.4 then hb_cat = 0;

run;

data hb0;
        set cmv.plate_015;
        if hb=. then delete;
        if Hbdate=. then Hbdate=BloodCollectDate;
        if hb>25 then hb=.;
        keep id HbDate Hb;
run;
proc sort; by id;
data hb0a;
   merge cmv.completedstudylist (in=a) hb0 (in=b);
   by id;
   if a and b;
data hbb;
  set hb(in=a) hb0a;
  x31=a;
 run;
 

 proc means;
    var hb;
     class x31;
     run;
     proc sort; by id;
data all;
  
     merge cmvkm  hbb;
      by id;
    
      if hbdate gt necdate and necdate ne . then delete;
      
      timetr=hbdate-lbwidob;
     if timetr gt .;
     if hb<=9 then anemia=1;
        else  anemia=0;
        week=int(timetr/7)+1;
 proc freq;
 tables timetr;
run;
       
data x;
    array bhb(65) hb0-hb64;
    do i=1 to 64;
       set all;
        by id;
       bhb(timetr+1)=hb;
        if last.id then return;
    end;
    keep id hb0-hb63;
 data final;
   merge   cmvkm(drop=hb) x;
   by id;
   array hb(90);
   if hb(1)=. then hb(1)=0;
   do i=2 to 90;
       if hb(i)=. then hb(i)=hb(i-1);
   end;


ods pdf file = 'nec8.pdf';
title Hb on a daily bases;
title2 If no Hb values on a given day use results from previous days;
proc phreg ;
   model time*censor(1) = hbb / risklimits;
   array hb(90);
   hbb=hb[time];
    
run;


        ods pdf close;
