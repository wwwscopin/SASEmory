
/*
modification of forms_submission in the df_reporting folder
	1. 6 baseline pages
	2. Plate 8  
	3. demo form
	4. PN Calc
	5. Blood forms
	6. Daily Follow-Up
	
	tie them to day 1 - give days late?

use in to determine whether form exists and then "dfc" to determine lateness

*/

* We are looking at the first plate of forms only;

/* FIRST grab plates that are uniquely assigned to one visit */


proc sort data = glnd.status; by id; run;
proc sort data = glnd.plate8; by id; run; * pharmacy conf. ;
proc sort data = glnd.plate9; by id; run; * demo ;
proc sort data = glnd.plate11; by id; run; * pn calc ;
proc sort data = glnd.plate23; by id; run; * day 3 f/u;
proc sort data = glnd.plate27; by id; run; * day 7 f/u ;
proc sort data = glnd.plate42; by id; run; * 30-day post-study drug discontinuation ;
proc sort data = glnd.plate45; by id; run; * day 28 vital status phonecall ;

* plate 14 - AA calc? ;
* plate 18 - concom meds? ; 


data forms;
	merge 
		glnd.plate8 (rename=(dfc=dfc8) keep= id dfc in = from_8 )
		glnd.plate9 (rename=(dfc=dfc9) keep= id dfc in = from_9)
		glnd.plate11 (rename=(dfc=dfc11) keep= id dfc in = from_11)
		glnd.plate23 (rename=(dfc=dfc23) keep= id dfc in = from_23)
		glnd.plate27 (rename=(dfc=dfc27) keep= id dfc in = from_27)
		glnd.plate42 (rename=(dfc=dfc42) keep= id dfc in = from_42)
		glnd.plate45 (rename=(dfc=dfc45) keep= id dfc in = from_45)
		;

	by id;

	* label if have a record of this plate - 1=Yes, 0=No, 2=not expected;
	if from_8 then pharm_conf = 1;
	if from_9 then demo = 1;
	if from_11 then pn_calc = 1;
	if from_23 then day_3 = 1;
	if from_27 then day_7 = 1;
	if from_42 then post_drug_30 = 1;
	if from_45 then day_28_vital = 1;


run;

/* NEXT, get plates which are used for multiple visit */
	* blood forms, 14,21 visit - by id and visit ;
	
	proc sort data = glnd.plate15; by id dfseq ; run; * blood calc ;
	proc sort data = glnd.plate32; by id dfseq; run; * day 14/21/28 f/u ;

	* get data stacked;	
	data a;
		merge 
			glnd.plate15 (keep= id  dfseq dt_bld_str in = from_15)
			glnd.plate32 (rename=(dfc=dfc32) keep = id dfseq dfc  in = from_32)
			;
		by id dfseq;
	
		if from_15 then has_15 = 1;
		if from_32 then has_32 = 1;
	run;

	* now transpose such that each visit and plate is in a column;
		proc transpose data= a out=b_15 ;
			by id;
			id dfseq;
			var has_15 ;
		run;

		proc transpose data= a out=b_32 ;
			by id;
			id dfseq;
			var has_32 ;
		run;

		data b;
			merge
				b_32 (drop = _1 _2 _3 rename = (_4 = day_14 _5 = day_21 _6 = day_28))
				b_15 (rename = (_1 = blood_base _2 = blood_3 _3 = blood_7 _4 = blood_14 _5 = blood_21 _6 = blood_28))
				;
	
			by id;

			drop _NAME_;
		run;



               proc transpose data= a out=b_15d ;
			by id;
			id dfseq;
			var dt_bld_str;
		run;

		proc transpose data= a out=b_32d ;
			by id;
			id dfseq;
			var dfc32 ;
		run;

		data bd;
			merge
				b_32d (drop = _1 _2 _3 rename = (_4 = day_14d _5 = day_21d _6 = day_28d))
				b_15d (rename = (_1 = blood_based _2 = blood_3d _3 = blood_7d _4 = blood_14d _5 = blood_21d _6 = blood_28d))
				;
	
			by id;

			drop _NAME_;
		run;


	* get 2/4/6 month phone call through a similar process;
		proc sort data = glnd.plate43; by id dfseq; run;
		
		data phone;
			set glnd.plate43 (keep = id dfseq dt_phn_call in=from_43);
		
			if from_43 then has_43 = 1;
		run;
		
		proc transpose data= phone out= phone_out;
			by id;
			id dfseq;
			var has_43;
		run; 	
		
		proc transpose data= phone out= phone_outd;
			by id;
			id dfseq;
			var dt_phn_call;
		run; 	
		
		data phone_out;
			set phone_out  (drop = _NAME_ rename = (_42 = phone_2mo _43 = phone_4mo _44 = phone_6mo));
		
		run;
		data phone_outd;
			set phone_outd  (drop = _NAME_ rename = (_42 = phone_2mod _43 = phone_4mod _44 = phone_6mod));
		
		run;
	


/* MERGE all plate info, and all study termination variables */
data forms;
	merge 
		forms
		b bd
		phone_out
		phone_outd
	;

	by id;
run;
/* skip for now;	 
data forms1;
 set forms;
 
   *length form $ 32;
   array d8s (19) dfc8 dfc9 dfc11 dfc23 dfc27 dfc42 dfc45
                  day_14d day_21d day_28d blood_based blood_3d
                  blood_7d blood_14d blood_21d blood_28d 
                  phone_2mod phone_4mod phone_6mod;
   array forms(19) pharm_conf  demo pn_calc day_3 day_7 post_drug_30 day_28_vital
                  day_14 day_21 day_28 blood_base blood_3
                  blood_7 blood_14 blood_21 blood_28
                  phone_2mo phone_4mo phone_6mo;
   
   do form=1 to 19;
     if forms(form)=1 then do;
        d8=d8s(form);
        output;
     end;   
   end;
   keep id form d8;
   format d8 mmddyy8.;
   run;
   
  proc sort; by id form;
*/;
   
   

