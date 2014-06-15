/* followup_all.sas
 *
 * This program creates two datasets from all follow-up forms:
 *  1. glnd.followup_7 = a cross-sectional summary of all forms
 *  2. glnd.followup_7_long = a longitudinal view of all follow-up days, where day is a variable and all other variables are the same
 */
 
%include "macro.sas";

* 1. not yet implemented

* 2. makes a longitudinal dataset containing all follow-up form data ;

data glnd.followup_all_long;
	set glnd.followup_3_long
		glnd.followup_7_long
		glnd.followup_14_long
		glnd.followup_21_long
		glnd.followup_28_long;
		
	if gluc_aft = 979 then gluc_aft = .;  * fix an erroneous value for the 2/2008 DSMB report; 
run;


proc contents data=glnd.followup_all_long;run;

 
*** Prepare data. add dates of enrollment and dates of each glucose measurement! ***;
	proc sort data = glnd.status; by id; run;
	proc sort data = glnd.followup_alL_long; by id day; run;


	data glnd.followup_all_long;
		merge 	glnd.followup_all_long 
				glnd.status (keep = id dt_random);

		by id;

		this_date = dt_random + (day - 1); * calculate the date of measurement. used to later restrict by date in reporting (ie: with blood glucose reports) ; 

		center = floor(id/10000);

		format this_date mmddyy. center center.;	
	run;
	


proc sort data = glnd.followup_all_long;
	by id day;
run;




/*
proc means data=glnd.followup_all_long;
class day;
var tube_kcal oral_kcal;
run;
*/

data nut;
    set glnd.followup_all_long;
    if tube_kcal=0 or tube_kcal=. then tool=0; else tool=1;
    if oral_kcal=0 or oral_kcal=. then oral=0; else oral=1;
    if oral and tool then both=2; else if oral=0 and tool=0 then both=0; else both=1;
run;

ods trace on/label listing;
proc freq  data=nut;
table day*tool;
ods output Freq.Table1.CrossTabFreqs=temp1;
table day*oral;
ods output Freq.Table2.CrossTabFreqs=temp2;
run;
ods trace off;

proc sort data=temp1; by day; run;
data tool;
    merge temp1(where=(tool=1) keep=day tool frequency rowpercent)
          temp1(where=(tool=.) keep=day tool frequency rename=(frequency=n)); by day;
    if day^=.;
    drop tool;
    
    rename frequency=f1 rowpercent=rp1 n=n1;
run;

proc sort data=temp2; by day; run;
data oral;
    merge temp2(where=(oral=1) keep=day oral frequency rowpercent)
          temp2(where=(oral=.) keep=day oral frequency rename=(frequency=n)); by day;
    if day^=.;
    drop oral;
    rename frequency=f2 rowpercent=rp2 n=n2;
run;

data feed;
    merge tool oral; by day;
    frp1=f1||"/"||compress(n1)||"("||compress(put(rp1,4.1))||"%)";
    frp2=f2||"/"||compress(n2)||"("||compress(put(rp2,4.1))||"%)";
run;

ods rtf file="feed.rtf" style=journal;
proc print noobs label;
title "Feeding Info.";
var day frp1 frp2/style=[width=1.5in]; 
label day="Day"
        frp1="Tool"
        frp2="Oral"
        ;
run;
ods rtf close;
