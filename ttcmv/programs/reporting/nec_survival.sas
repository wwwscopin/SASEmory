* TIME TO NEC PLOT ;

data necdate; merge cmv.completedstudylist (in=a) cmv.nec; if a; keep id necdate; if dfseq = 161; run;
proc sort data = cmv.snap out = snap; by id; run;


* get HB values ;

proc sort data = cmv.med_review out = hb_med; by id dfseq; run;
data hb_med; set hb_med; if hbdate = . then hbdate = bloodcollectdate; run;

*** EXCLUDE ALL DATA AFTER NEC DIAGNOSIS FOR NEC PATIENTS ;
proc sort data = cmv.nec out = nec_list; by id; run;
	data nec_list; merge nec_list (in=a) cmv.completedstudylist (in=b); by id; if a & b; if dfseq = 161; keep id necdate; run;
proc sort data = hb_med; by id; run;
data hb_med; merge hb_med nec_list (in=a); by id;	if a & hbdate > necdate then delete; run;

proc transpose data = hb_med out = hb_med_hb prefix = hb; by id; id dfseq; var hb; run;
proc transpose data = hb_med out = hb_med_date prefix = hbdate; by id; id dfseq; var hbdate; run;
data hb_med; merge hb_med_hb hb_med_date; by id; drop _name_ _label_; run;


proc sort data = cmv.plate_031 out = hb_rbc; by id dfseq; run;
data hb_rbc; set hb_rbc; if dfseq = 0 then delete; run;

*** EXCLUDE ALL DATA AFTER NEC DIAGNOSIS FOR NEC PATIENTS ;
proc sort data = hb_rbc; by id; run;
data hb_rbc; merge hb_rbc nec_list (in=a); by id;	if a & hbdate > necdate then delete; run;

proc transpose data = hb_rbc out = hb_rbc_hb prefix = hb; by id; id dfseq; var hb; run;
proc transpose data = hb_rbc out = hb_rbc_date prefix = hbdate; by id; id dfseq; var datehbhct; run;
data hb_rbc; merge hb_rbc_hb hb_rbc_date; by id; drop _name_ _label_; run;


data hb; merge hb_med hb_rbc cmv.completedstudylist (in=a); by id; if a; run;
proc sort data = hb; by id; run; 

data hb; set hb; 
	if 	(hb1 <= 7 & hb1 ~= .) | (hb4 <= 7 & hb4 ~= .) | (hb7 <= 7 & hb7 ~= .) | (hb14 <= 7 & hb14 ~= .) | (hb21 <= 7 & hb21 ~= .) | 
			(hb28 <= 7 & hb28 ~= .) | (hb40 <= 7 & hb40 ~= .) | (hb60 <= 7 & hb60 ~= .) |
			(hb101 <= 7 & hb101 ~= .) | (hb102 <= 7 & hb102 ~= .) | (hb103 <= 7 & hb103 ~= .) | (hb104 <= 7 & hb104 ~= .) | (hb105 <= 7 & hb105 ~= .) | 
			(hb106 <= 7 & hb106 ~= .) | (hb107 <= 7 & hb107 ~= .) | (hb108 <= 7 & hb108 ~= .) | (hb107 <= 7 & hb109 ~= .) | (hb110 <= 7 & hb110 ~= .) | 
			(hb111 <= 7 & hb111 ~= .) | (hb112 <= 7 & hb112 ~= .) | (hb113 <= 7 & hb113 ~= .) | (hb114 <= 7 & hb114 ~= .) | (hb115 <= 7 & hb115 ~= .) | 
			(hb116 <= 7 & hb116 ~= .) | (hb117 <= 7 & hb117 ~= .) | (hb118 <= 7 & hb118 ~= .) | (hb117 <= 7 & hb119 ~= .) | (hb120 <= 7 & hb120 ~= .) 
	then ever_anemic7 = 1; else ever_anemic7 = 0;

	if 	(hb1 <= 8 & hb1 ~= .) | (hb4 <= 8 & hb4 ~= .) | (hb7 <= 8 & hb7 ~= .) | (hb14 <= 8 & hb14 ~= .) | (hb21 <= 8 & hb21 ~= .) | 
			(hb28 <= 8 & hb28 ~= .) | (hb40 <= 8 & hb40 ~= .) | (hb60 <= 8 & hb60 ~= .) |
			(hb101 <= 8 & hb101 ~= .) | (hb102 <= 8 & hb102 ~= .) | (hb103 <= 8 & hb103 ~= .) | (hb104 <= 8 & hb104 ~= .) | (hb105 <= 8 & hb105 ~= .) | 
			(hb106 <= 8 & hb106 ~= .) | (hb108 <= 8 & hb107 ~= .) | (hb108 <= 8 & hb108 ~= .) | (hb108 <= 8 & hb109 ~= .) | (hb110 <= 8 & hb110 ~= .) | 
			(hb111 <= 8 & hb111 ~= .) | (hb112 <= 8 & hb112 ~= .) | (hb113 <= 8 & hb113 ~= .) | (hb114 <= 8 & hb114 ~= .) | (hb115 <= 8 & hb115 ~= .) | 
			(hb116 <= 8 & hb116 ~= .) | (hb118 <= 8 & hb117 ~= .) | (hb118 <= 8 & hb118 ~= .) | (hb118 <= 8 & hb119 ~= .) | (hb120 <= 8 & hb120 ~= .) 
	then ever_anemic8 = 1; else ever_anemic8 = 0;

	if 	(hb1 <= 9 & hb1 ~= .) | (hb4 <= 9 & hb4 ~= .) | (hb7 <= 9 & hb7 ~= .) | (hb14 <= 9 & hb14 ~= .) | (hb21 <= 9 & hb21 ~= .) | 
			(hb28 <= 9 & hb28 ~= .) | (hb40 <= 9 & hb40 ~= .) | (hb60 <= 9 & hb60 ~= .) |
			(hb101 <= 9 & hb101 ~= .) | (hb102 <= 9 & hb102 ~= .) | (hb103 <= 9 & hb103 ~= .) | (hb104 <= 9 & hb104 ~= .) | (hb105 <= 9 & hb105 ~= .) | 
			(hb106 <= 9 & hb106 ~= .) | (hb107 <= 9 & hb107 ~= .) | (hb108 <= 9 & hb108 ~= .) | (hb109 <= 9 & hb109 ~= .) | (hb110 <= 9 & hb110 ~= .) | 
			(hb111 <= 9 & hb111 ~= .) | (hb112 <= 9 & hb112 ~= .) | (hb113 <= 9 & hb113 ~= .) | (hb114 <= 9 & hb114 ~= .) | (hb115 <= 9 & hb115 ~= .) | 
			(hb116 <= 9 & hb116 ~= .) | (hb117 <= 9 & hb117 ~= .) | (hb118 <= 9 & hb118 ~= .) | (hb119 <= 9 & hb119 ~= .) | (hb120 <= 9 & hb120 ~= .) 
	then ever_anemic9 = 1; else ever_anemic9 = 0;

run;

data cmv.hb; set hb; run;
data hb; set hb; keep id hb1 ever_anemic7 ever_anemic8 ever_anemic9; run;

****************;


*** Get Medians ;
/* proc means data = cmv.km; var gestage; output out = cmv.gestage_median median(gestage) = median min(gestage) = min max(gestage) = max; run; */
/* proc means data = cmv.km; var snap; output out = cmv.snap_median median(snap) = median min(snap) = min max(snap) = max; run; */
/* proc means data = cmv.km; var hb; output out = cmv.hb_median median(hb) = median min(hb) = min max(hb) = max; run; */
/* proc means data = cmv.km; var numrbctxns; output out = cmv.numrbctxns_median median(numrbctxns) = median min(numrbctxns) = min max(numrbctxns) = max; run; */ 
/* proc means data = cmv.km; var avevol; output out = cmv.avevol_median median(avevol) = median min(avevol) = min max(avevol) = max; run; */
/* proc means data = cmv.km; var avelength; output out = cmv.avelength_median median(avelength) = median min(avelength) = min max(avelength) = max; run; */
/* proc means data = cmv.km; var numrbcdonors; output out= cmv.numrbcdonors_median median(numrbcdonors) = median min(numrbcdonors) = min max(numrbcdonors) = max; run; */



data cmv.km; 	merge 	cmv.completedstudylist (in=a)
									cmv.lbwi_demo (keep = id lbwidob gender birthweight gestage) 
									cmv.endofstudy (keep = id studyleftdate)
									necdate (in=b)
									snap (keep = id SNAPTotalScore rename = (snaptotalscore = snap))
									cmv.rbctxn_summary (keep = id evertxn numrbctxns numrbcdonors avevol avelength evertxn14 numtxn14 oldestage oldestirr)
									hb;
						by id; if a; if b then has_nec = 1; else has_nec = 0;

	time = necdate - lbwidob; 

	if time = . then censor = 1;
		else censor = 0;

	if time = . then time = studyleftdate - lbwidob;

	if evertxn = 0 then numrbctxns = 0;
	if evertxn = 0 then numrbcdonors = 0;
	if evertxn = 0 then evertxn14 = 0;


	if snap < 11 then snap_cat = 1; if snap >= 11 then snap_cat = 2; if snap = . then snap_cat = .;
	if birthweight < 1000 then bw_cat = 1; if birthweight >= 1000 then bw_cat = 2; if birthweight = . then bw_cat = .;
	if gestage < 28 then ga_cat = 1; if gestage >= 28 then ga_cat = 2; if gestage = . then ga_cat = .;

	if oldestage < 7 then oldestage_cat = 1; if oldestage >= 7 then oldestage_cat = 2; if oldestage >= 14 then oldestage_cat = 3; 
			if oldestage = . then oldestage_cat = .;
	oldestage_cat2 = oldestage_cat; if evertxn = 0 then oldestage_cat2 = 0;
	if oldestirr < 2 then oldestirr_cat = 1; if oldestirr >= 2 then oldestirr_cat = 2; 
			if oldestirr = . then oldestirr_cat = .;
	oldestirr_cat2 = oldestirr_cat; if evertxn = 0 then oldestirr_cat2 = 0;

	if hb1 <=7 then anemia_birth = 1; if hb1 > 7 then anemia_birth = 0; if hb1 = . then anemia_birth = .;
	if hb1 < 14.4 then hb_cat = 1; if hb1 >= 14.4 then hb_cat = 0; if hb1 = . then hb_cat = .;
	if numrbctxns = 0 then numrbctxns_cat = 1; if numrbctxns = 1 | numrbctxns = 2 then numrbctxns_cat = 2; if numrbctxns > 2 then numrbctxns_cat = 3;
		if numrbctxns = . then numrbctxns_cat = .;
	if numrbcdonors = 0 then donors_cat = 1; if numrbcdonors = 1 | numrbcdonors = 2 then donors_cat = 2; if numrbcdonors > 2 then donors_cat = 3;
		if numrbcdonors = . then donors_cat = .;
	if center = 1 | center = 2 then center_pooled = 1; if center = 3 then center_pooled = 2;
	if avevol < 15 then avevol_cat = 1; if avevol >= 15 then avevol_cat = 2; if avevol = . then avevol_cat = .;
	if avelength < hms(3,6,0) then avelength_cat = 1; if avelength >= hms(3,6,0) then avelength_cat = 2; if avelength = . then avelength_cat = .;

run;

proc sort data = cmv.km; by id; run;
data cmv.km; set cmv.km; by id; if first.id; run;


*** Some frequencies ;
	proc sort data = cmv.age_of_blood out = age_of_blood; by id; run;
	data per_week; merge age_of_blood cmv.plate_005 (keep = id lbwidob); by id;
		time_txn = datetransfusion - lbwidob;
		week = int(time_txn/7)+1;
		if age_of_blood >= 14; 
	run;

	proc sort data = per_week; by id week; run;
	
	data cmv.per_week; set per_week; by id week;
		retain txn14_per_week; 
		if first.id | first.week then txn14_per_week = 1;
			else txn14_per_week = txn14_per_week+1;
		if last.id | last.week;
		keep id datetransfusion lbwidob time_txn week txn14_per_week;
	run; 

	ods rtf file = "&output./april2011abstracts/numtxn14_freq.rtf" style=journal;
		proc freq data = cmv.km; tables numtxn14; run;
		proc freq data = cmv.per_week; tables week*txn14_per_week / nopct nocol norow nocum; run;
	ods rtf close;

	
*** Median for groups ;
/*
	proc sort data = cmv.km out = temp; by age_of_blood_cat; run;
	proc means data = temp; var age_of_blood; by age_of_blood_cat; 
		output out = cmv.temp median(age_of_blood) = median min(age_of_blood) = min max(age_of_blood) = max; run;

	proc sort data = cmv.km out = temp; by days_irradiated_cat; run;
	proc means data = temp; var days_irradiated; by days_irradiated_cat; 
		output out = cmv.temp median(days_irradiated) = median min(days_irradiated) = min max(days_irradiated) = max; run;
*/

	ods rtf file = "&output./april2011abstracts/nec_lifetest.rtf" style=journal;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata gender;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata bw_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata ga_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata snap_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata hb_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata ever_anemic7;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata ever_anemic8;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata ever_anemic9;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata evertxn;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata numrbctxns_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata donors_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata oldestage_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata oldestirr_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata center_pooled;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
				time time*censor(1);
					strata center_pooled oldestage_cat2;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
				time time*censor(1);
					strata center_pooled oldestirr_cat2;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata avevol_cat;
		run;

		proc lifetest data = cmv.km intervals=21 40 60;
			time time*censor(1);
				strata avelength_cat;
		run;

	ods rtf close;


************************;
* Univariate Cox Models ;
************************;

	ods rtf file = "&output./april2011abstracts/nec_phreg.rtf" style=journal;

	proc phreg data = cmv.km; 
		model time*censor(1) = numrbctxns / rl ;
	run;

	proc phreg data = cmv.km; 
		model time*censor(1) = numrbcdonors / rl ;
	run;

	proc phreg data = cmv.km; 
		model time*censor(1) = evertxn14 / rl ;
	run;

	* can't use Cox model - no failures in never anemic group ;
/*
	proc phreg data = cmv.km; 
		model time*censor(1) = ever_anemic / rl ;
	run;
*/

	ods rtf close;




