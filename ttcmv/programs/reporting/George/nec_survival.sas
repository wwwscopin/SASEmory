* TIME TO NEC PLOT ;

data necdate; merge cmv.completedstudylist (in=a) cmv.nec; if a; keep id necdate; if dfseq = 161; run;
proc sort data = cmv.km_rbc_variables; by id; run;
proc sort data = cmv.snap out = snap; by id; run;
data hb; set cmv.med_review; if dfseq = 1; keep id hb; run;
proc sort data = hb; by id; run; 

data cmv.km; 	merge 	cmv.completedstudylist (in=a)
									cmv.lbwi_demo (keep = id lbwidob gender birthweight gestage) 
									cmv.endofstudy (keep = id studyleftdate)
									necdate (in=b)
									cmv.km_rbc_variables
									snap (keep = id SNAPTotalScore rename = (snaptotalscore = snap))
									hb;
						by id; if a; if b then has_nec = 1; else has_nec = 0;

	time = necdate - lbwidob; 

	if time = . then censor = 1;
		else censor = 0;

	if time = . then time = studyleftdate - lbwidob;

	if hb >= 14.4 then hb_cat = 1; if hb < 14.4 then hb_cat = 0;

run;

*** Look for Medians ;
	/* proc means data = cmv.km; var gestage; output out = cmv.gestage_median median(gestage) = median min(gestage) = min max(gestage) = max; run; */
	/* proc means data = cmv.km; var snap; output out = cmv.snap_median median(snap) = median min(snap) = min max(snap) = max; run; */
	/* proc means data = cmv.km; var hb; output out = cmv.hb_median median(hb) = median min(hb) = min max(hb) = max; run; */


	goptions /*reset=all*/ rotate=landscape;

	symbol1 line=1 color=blue;
	symbol2 line=1 color=red;
	symbol3 line=1 color=green;

	ods rtf file = "&output./april2011abstracts/nec_lifetest.rtf" style=journal;

		proc lifetest data = cmv.km plots=(s);
			time time*censor(1);
			*strata gender;
			*strata birthweight (0-1000 1000-1500);
			*strata gestage (0-28 28-33);
			*strata snap (0-11 11-30);
			strata hb_cat;
			*strata rbctxn;
			*strata age_of_blood (0-8 8-15 15-40);
			*strata days_irradiated (0-8 8-40);
			*strata center;
		run;

	ods rtf close;

