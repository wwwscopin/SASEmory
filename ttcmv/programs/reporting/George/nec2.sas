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
  
     merge cmvkm(in=a) age;
      by id;
     timetr=datetransfusion-lbwidob;
     if timetr gt .;
     if age_of_blood < 14 then bage=0;
        else  bage=1;
        week=int(timetr/7)+1;
     if a;      
     
 proc means noprint;
    var age_of_blood;
    by id week;
    output out=new max=bloodage;
 run;

 
 data x;
    array bage(13);
    do i=1 to 13;
       set new;
        by id;
        bage(week)=bloodage;
        if last.id then return;
    end;
    keep id bage1-bage13;
 data final;
   merge   cmvkm(in=a) x;
   by id;
   if a;
   array bage(13);
   do i=1 to 13;
       if bage(i)=. then bage(i)=0;
   end;
   
   proc print;
 var bage1-bage13;
run;

ods pdf file = 'nec2.pdf';

proc phreg ;
   model time*censor(1) = bloodage / risklimits;
   array bage (13) bage1-bage13;
    wk=int(time/7)+1;
    bloodage=bage[wk];
*title Weekly Levels of Blood Transfusions Where at Least One Tranfustions Was At Least 14 Days Old;
*title2 Coded as 0 = Either No Transfusions This Week or All Less Than 14 Days Old;
*title3          1 = at Least One Tranfustions Was At Least 14 Days Old;
title Weekly Maximum Blood Age;
run;


 ;
	ods pdf close;
