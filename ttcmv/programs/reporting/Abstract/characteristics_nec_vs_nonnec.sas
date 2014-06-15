
*****************************************************;
*** Reproduction of TABLE II from jpeds NEC paper ***;
*****************************************************;

%include "&include./descriptive_stat.sas";

	data lbwi_demo; set cmv.lbwi_demo; 
		moc_id = input(substr(put(id,7.0),1,5),5.0); run;
	proc sort data = lbwi_demo; by moc_id; run;

	data lbwi_demo; set lbwi_demo; 
		by moc_id; retain multiple;
		if first.moc_id then multiple = 1; else multiple = multiple + 1; 
		if last.moc_id & multiple = 1 then singleton = 1; else singleton = 0;  
	run;

	proc sort data = cmv.completedstudylist; by id; run;
	proc sort data = lbwi_demo; by id; run;
	data characteristics; merge lbwi_demo cmv.completedstudylist (in=a); by id; if a; 
		if gender = 2 then gender = 0; *change so 0=female 1=male report var as binary male gender ;
		if apgar5min < 6 then apgarlessthan6 = 1; else apgarlessthan6 = 0;
		label	gender = "Male gender - no. (%)"
					ishispanic = "Hispanic ethnicity - no. (%)"
					race = "Race - no. (%)"
					Gestage = "Gestational age (weeks) - median (Q1,Q3) [min-max], N"
					BirthWeight = "Weight (g) - median (Q1,Q3) [min-max], N"
					apgarlessthan6 = "5-min APGAR <6 - no. (%)"
		;
		format race race.;

		keep id gender IsHispanic race GestAge BirthWeight apgarlessthan6 singleton;
	run;

	proc sort data = cmv.nec out = nec_list; by id; run;
	data nec_list; merge nec_list (in=a) cmv.completedstudylist (in=b); by id; if a & b; if dfseq = 161; keep id necdate; run;

	data characteristics; merge characteristics nec_list (in=a); by id; 
		if a then has_nec = 1; else has_nec = 0; run;

	data nonnec_list; merge nec_list (in=a) cmv.completedstudylist (in=b); by id; if ~a & b; keep id; run;

*** SNAP score ;

	proc sort data = cmv.snap out = snap; by id; run;
	data characteristics; merge characteristics (in=a) snap (keep = id SNAPTotalScore); by id; if a; 
		label SNAPTotalScore = "SNAP - median (Q1,Q3) [min-max], N"; run;

***************;

*** delivery mode ;

	data moc_demo; set cmv.moc_demo; moc_id = input(substr(put(id,7.0),1,5),5.0); run;
	proc sort data = moc_demo out = moc_demo; by moc_id; run;

	data characteristics; set characteristics; moc_id = input(substr(put(id,7.0),1,5),5.0); run;

	data characteristics; merge characteristics (in=a) moc_demo (keep = id moc_id deliverymode); by moc_id; if a; 
		label deliverymode = "Mode of delivery - no. (%)";	
		format DeliveryMode DeliveryMode.;
	run;

***************;

*** had PDA (prior to NEC for NEC cases) ;

	proc sort data = cmv.pda out = pda; by id; run;

	data everpda_nonnec; merge pda (in=b) nonnec_list (in=a); by id; if a;
		if b then everpda = 1; else everpda = 0; keep id everpda; 
	run; 

	data everpda_nec; merge pda (in=b) nec_list (in=a); by id; if a;
		if b & pdadiagdate <= necdate then everpda = 1; else everpda = 0; keep id everpda; 
	run;

	data everpda; set everpda_nonnec everpda_nec; 
		label everpda = "PDA - n (%)*";
	run;

	proc sort data = everpda; by id; run;
	data characteristics; merge characteristics everpda; by id; run;	
	
***************;

*** had IVH > grade II (prior to NEC for NEC cases) ;

	proc sort data = cmv.ivh_image out=ivh_grade2; by id dfseq; run;

	data ivh_grade2; set ivh_grade2;
		by id; retain grade2;
	
		if first.id then grade2 = 0; 

			if 	leftivhgrade = 2 | leftivhgrade = 3 | leftivhgrade = 4 | 
				 	rightivhgrade = 2 |rightivhgrade = 3 | rightivhgrade = 4 then grade2 = 1;
	
		if last.id;
		if grade2 = 1;

		keep id;
	run;


		data everivh_nonnec; merge ivh_grade2 (in=b) nonnec_list (in=a); by id; if a;
			if b then everivh = 1; else everivh = 0; keep id everivh; 
		run; 

		proc sort data = cmv.ivh out = ivhdate; by id; run;
		data everivh_nec; merge ivh_grade2 (in=b) nec_list (in=a) ivhdate (keep = id ivhdiagdate); by id; if a;
			if b & ivhdiagdate <= necdate then everivh = 1; else everivh = 0; keep id everivh; 
		run;

	data everivh; set everivh_nonnec everivh_nec; 
		label everivh = "IVH (Grade II or higher) - no. (%)*";
	run;

	proc sort data = everivh; by id; run;
	data characteristics; merge characteristics everivh; by id; run;

***************;

*** had positive blood culture (prior to NEC for NEC cases) ;

	data posbloodcult; set cmv.infection_all; if siteblood = 1 & culturepositive = 1; run;
	proc sort data = posbloodcult; by id dfseq; run;
	data posbloodcult; set posbloodcult; by id; if first.id; run;

		data posblood_nonnec; merge posbloodcult (in=b) nonnec_list (in=a); by id; if a;
			if b then posblood = 1; else posblood = 0; keep id posblood; 
		run; 

		data posblood_nec; merge posbloodcult (in=b) nec_list (in=a); by id; if a;
			if b & culture1date <= necdate then posblood = 1; else posblood = 0; keep id posblood; 
		run;

	data posblood; set posblood_nonnec posblood_nec; 
		label posblood = "Positive Blood Culture - no. (%)*";
	run;

	proc sort data = posblood; by id; run;
	data characteristics; merge characteristics posblood; by id; run;
	
***************;

*** HB/HCT at birth ;
	
	proc sort data = cmv.med_review out = lab_birth; by id dfseq; run;
	data lab_birth; merge lab_birth cmv.completedstudylist (in=a); by id; if a; if dfseq = 1; keep id hct hb; 
		label hct = "Hematocrit at birth (%)";
		label hb = "Hemoglobin at birth (g/dL)";
	run; 

	data characteristics; merge characteristics lab_birth; by id; run;

***************;

*** HB/HCT at NEC ;
	
	proc sort data = cmv.nec out = nec; by id dfseq; run;
		* keep only first episode of NEC for now ;
		data nec; set nec; if dfseq = 161; run;
	proc sort data = cmv.med_review out = hct_nec; by id dfseq; run;

	data hct_nec; merge hct_nec (keep = id hct hctdate bloodcollectdate) nec (in=b keep = id necdate) cmv.completedstudylist (in=a); by id; if a; if b; 
		if hct = . then delete;
		if hctdate = . then hctdate = bloodcollectdate;
		closestdate = necdate - hctdate; 
		if closestdate > 0 | closestdate < -2 then delete;
	run;

	proc sort data = hct_nec; by id closestdate; run; 
	data hct_nec; set hct_nec; by id;
		if last.id; 
		label hct = "Hematocrit prior to NEC (%)**";
	run; 

	******************************;

	proc sort data = cmv.nec out = nec; by id dfseq; run;
		* keep only first episode of NEC for now ;
		data nec; set nec; if dfseq = 161; run;
	proc sort data = cmv.med_review out = hb_nec; by id dfseq; run;

	data hb_nec; merge hb_nec (keep = id hb hbdate bloodcollectdate) nec (in=b keep = id necdate) cmv.completedstudylist (in=a); by id; if a; if b; 
		if hb = . then delete;
		if hbdate = . then hbdate = bloodcollectdate;
		closestdate = necdate - hbdate; 
		if closestdate > 0 | closestdate < -2 then delete;
	run;

	proc sort data = hb_nec; by id closestdate; run; 
	data hb_nec; set hb_nec; by id;
		if last.id; 
		label hb = "Hemoglobin prior to NEC (%)**";
	run; 

	data cmv.hb_nec; set hb_nec; run;


***************;

*** Given pRBC < 48 hours prior to NEC ;

	proc sort data = cmv.plate_031 out = rbc; by id dfseq; run;
	proc sort data = cmv.nec out = nec; by id dfseq; run;
		* keep only first episode of NEC for now ;
		data nec; set nec; if dfseq = 161; run;

	data txn_prior; merge rbc (keep = id datetransfusion) nec (in=b keep = id necdate) cmv.completedstudylist (in=a); by id; if a; if b; 
		txn_prior_days = necdate - datetransfusion; 
		if txn_prior_days = 0 | txn_prior_days = -1 | txn_prior_days = -2 then txn_prior48 = 1; else txn_prior48 = 0;
		if txn_prior_days = 0 | txn_prior_days = -1 | txn_prior_days = -2 | txn_prior_days = -3 then txn_prior72 = 1; else txn_prior72 = 0;
	run;

	data txn_prior; set txn_prior; by id; if first.id; run;
	
	data txn_prior; merge txn_prior (in=b) nec (in=c) cmv.completedstudylist (in=a); by id; if a; if c;
		if b then txn_prior = 1; else txn_prior = 0;
		label txn_prior = "TXN 48hrs prior to NEC - no. (%)";
	run;

***************;

data header1; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Demographic"; run;
data header2; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Clinical characteristics at birth"; run;
data header3; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Risk factors and outcomes related to NEC"; run;


data characteristics1; set characteristics; by id; if first.id; if has_nec; run;
	
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1a, var= Gender, type= bin, first_var=1);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1a, var= race, type= cat);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1a, var= IsHispanic, type= bin);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1a, var= singleton, type= bin, last_var=1);
	
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= BirthWeight, type= cont, non_param=1, dec_places=0, first_var=1);	
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= GestAge, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= deliverymode, type= cat);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= SNAPTotalScore, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= apgarlessthan6, type= bin);	
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= hb, type= cont, non_param=1, dec_places=1);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1b, var= hct, type= cont, non_param=1, last_var=1);

data txn1; set cmv.rbctxn_summary; if has_nec = 1; run;

	%descriptive_stat(data_in= txn1, data_out= characteristics_table1c, var= evertxn, type= bin, first_var=1);
	%descriptive_stat(data_in= txn1, data_out= characteristics_table1c, var= oldestage, type= cont, non_param=1);
	%descriptive_stat(data_in= txn1, data_out= characteristics_table1c, var= oldestirr, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1c, var= everpda, type= bin);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1c, var= everivh, type= bin);
	%descriptive_stat(data_in= characteristics1, data_out= characteristics_table1c, var= posblood, type= bin, last_var=1);
	

		data characteristics_table1; 
		set 	header1 characteristics_table1a (rename = (disp_overall = disp1))
				header2 characteristics_table1b (rename = (disp_overall = disp1))
				header3 characteristics_table1c (rename = (disp_overall = disp1))
		; 
		run;

data characteristics2; set characteristics; by id; if first.id; if has_nec=0; run;

	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2a, var= Gender, type= bin, first_var=1);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2a, var= race, type= cat);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2a, var= IsHispanic, type= bin);	
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2a, var= singleton, type= bin, last_var=1);
	
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= BirthWeight, type= cont, non_param=1, dec_places=0, first_var=1);	
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= GestAge, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2c, var= deliverymode, type= cat);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= SNAPTotalScore, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= apgarlessthan6, type= bin);	
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= hb, type= cont, non_param=1, dec_places=1);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2b, var= hct, type= cont, non_param=1, last_var=1);
	
data txn2; set cmv.rbctxn_summary; if has_nec = 0; run;

	%descriptive_stat(data_in= txn2, data_out= characteristics_table2c, var= evertxn, type= bin, first_var=1);
	%descriptive_stat(data_in= txn2, data_out= characteristics_table2c, var= oldestage, type= cont, non_param=1);
	%descriptive_stat(data_in= txn2, data_out= characteristics_table2c, var= oldestirr, type= cont, non_param=1);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2c, var= everpda, type= bin);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2c, var= everivh, type= bin);
	%descriptive_stat(data_in= characteristics2, data_out= characteristics_table2c, var= posblood, type= bin, last_var=1);
	

		data characteristics_table2; 
		set 	header1 characteristics_table2a (rename = (disp_overall = disp2))
				header2 characteristics_table2b (rename = (disp_overall = disp2))
				header3 characteristics_table2c (rename = (disp_overall = disp2))
		; 
		run;
	

	data characteristics_table2; set characteristics_table2; order = _N_; run;
	proc sort data = characteristics_table1; by row; run;
	proc sort data = characteristics_table2; by row; run;
	data characteristics_table; merge characteristics_table1 characteristics_table2; by row; run;
	proc sort data = characteristics_table; by order; run;

	proc sql; select count(distinct(id)) into :has_nec from characteristics where has_nec = 1;
	proc sql; select count(distinct(id)) into :nonnec from characteristics where has_nec = 0;	

	data characteristics_table; set characteristics_table; 	
		keep row disp1 disp2; 
		label 	disp1 = "NEC cases*(n=&has_nec)"
					disp2 = "Non-NEC cases*(n=&nonnec)";
	run;


	%descriptive_stat(data_in= hb_nec, data_out= characteristics_table3, var= hb, type= cont, non_param=0, first_var=1);
	%descriptive_stat(data_in= hct_nec, data_out= characteristics_table3, var= hct, type= cont, non_param=0);
	%descriptive_stat(data_in= txn_prior, data_out= characteristics_table3, var= txn_prior, type= bin, last_var=1);

	data characteristics_table3; set characteristics_table3 (rename = (disp_overall = disp1)); run;
	data characteristics_table; set characteristics_table characteristics_table3; run;




	options nodate orientation = portrait;

	ods rtf file = "&output./april2011abstracts/characteristics_nec_ns_nonnec.rtf"  style=journal toc_data startpage = no bodytitle;
		title1 "Demographic and clinical characteristics of NEC cases versus subjects that did not develop NEC"; 
		footnote1 "*Only included transfusion, outcome data prior to NEC for NEC patients";
		footnote2 "**Only included HB/HCT data within 48 hours prior to NEC diagnosis.";
		proc print data = characteristics_table label noobs split = "*" style(header) = {just=center} contents = "";
			id  row /style(data) = [font_size=1.8 font_style=Roman];
			by  row notsorted;
				var disp1 disp2 /style(data) = [just=center font_size=1.8];
			run;
	ods rtf close;


