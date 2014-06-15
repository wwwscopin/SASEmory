%include "&include./descriptive_stat.sas";
%include "&include./annual_toc.sas";

data cmv.nec; set cmv.nec;
	if laparotomydone = 99 then laparotomydone = . ;
	if abdominaldrain = 99 then abdominaldrain = . ;
	if bowelresecdone = 99 then bowelresecdone = . ;
	if surgeryreqd = 99 then surgeryreqd = . ;

	if necbowel = 99 then necbowel = . ;
	if gangrenousbowel = 99 then gangrenousbowel = . ;
	if bowelharden = 99 then bowelharden = . ;
	if largeintestineperfor = 99 then largeintestineperfor = . ;
	if smallintestineperfor = 99 then smallintestineperfor = . ;
	
	if portionresec = 99 then portionresec = . ;
	if lengthresecmin = 99 then lengthresecmin = . ;
	if lengthresecmax = 99 then lengthresecmax = . ;
	if woundculture = 99 then woundculture = . ;
	if isculturepositive = 99 then isculturepositive = . ;

	if lbwisbsyndrome = 99 then lbwisbsyndrome = . ;

run;


proc sort data = cmv.nec; by id dfseq; run;
data cmv.nec; merge cmv.nec (in=b) cmv.completedstudylist (in=a); by id; if a & b; run;
data nec; set cmv.nec; run;

*** Get overall N for patients, episodes ***************************;

data _NULL_; set nec nobs=nobs;
  call symput('num_episodes',trim(left(put(nobs,8.)))); run;

data temp; set nec; by id; if first.id; run;
data _NULL_; set temp nobs=nobs;
  call symput('num_pts',trim(left(put(nobs,8.)))); run;

********************************************************************;


* get SNAP score at time of diagnosis, SNAP score at birth ;
	data nec_snap; set cmv.snap2 (rename = (snap2score = nec_snap)); if dfseq = 161 | dfseq = 162 | dfseq = 163; keep id nec_snap; run; 
	proc sort data = nec_snap; by id; run;
	data birth_snap; set cmv.snap; keep id snaptotalscore; run; 
	proc sort data = birth_snap; by id; run;

* get birthday for age at time of diagnosis ;
	data birthday; set cmv.lbwi_demo (keep = id lbwidob); run;
	proc sort data = birthday; by id; run;

* get hematocrit at birth ;
	data birth_hct; set cmv.med_review; if dfseq = 1; run;
	data birth_hct; set birth_hct; keep id hct; run;
	proc sort data = birth_hct; by id; run;

* get txn'd prior to nec diagnosis ;
	proc sort data=cmv.plate_031 out=plate_031; by id datetransfusion; run; 
	data txnd; merge plate_031 (keep = id datetransfusion) nec (keep = id necdate in=a); by id; if a; 
		if necdate > datetransfusion; run;
	data txnd; set txnd; by id; if first.id; txnd_prior_nec = 1; run;

***********************;
* nec feeding log data ;
***********************;
	data nec_feeding_log; set cmv.nec_feeding_log; if nec_date ~= . ; * discard old data ; run;

*** get median ent_pct prior to nec diagnosis ;

	%macro pointless;
		* I guess this has to be done inside a macro? output dataset is called _long ;
		data nec_feeding_long; set nec_feeding_log;
			%do i=1 %to 7;
				ent_pct = entrealpct_dp&i;
				i=&i;
				output;
			%end;
			keep id i ent_pct;
		run;
		%mend pointless;

	%pointless; quit;
	
	proc means data = nec_feeding_long median; var ent_pct; class id; output out = feeding_prenec median(ent_pct) = prenec_median; run;
	data feeding_prenec; set feeding_prenec; if id ~= .; keep id prenec_median; run;


*** get median ent_pct post nec diagnosis ;

	%macro pointless;
		data nec_feeding_long; set nec_feeding_log;
			%do i=1 %to 22;
				ent_pct = entrealpct&i;
				i=&i;
				output;
			%end;
			keep id i ent_pct;
		run;
		%mend pointless;

	%pointless; quit;

	proc means data = nec_feeding_long median; var ent_pct; class id; output out = feeding_postnec median(ent_pct) = postnec_median; run;
	data feeding_postnec; set feeding_postnec; if id ~= .; keep id postnec_median; run;

	data feeding_atnec; set nec_feeding_log; keep id entrealpct_d0; run;


*** get ent_pct at nec diagnosis ;

	data feeding; merge feeding_atnec feeding_prenec feeding_postnec; by id; run;

*******************************************************************************************************************************************;		

*** Merge and create new variables ***************************;

	data nec; 
		merge nec (in=a) nec_snap birth_snap birthday birth_hct txnd feeding; by id; if a; 
		if txnd_prior_nec = . then txnd_prior_nec = 0; 
	run;

	data nec; set nec; 
		* duration of episode of NEC ;
			duration = necresolvedate - necdate;
		* age at diagnosis ;
			age = necdate - lbwidob;
		* any signs or symptoms observed ;
			if isbloodstool = 1 | isemesis = 1 | isabndistension = 1 then ssobs = 1; else ssobs = 0;
		* recode portion resected variables ;
			* do this once neeta fixes the database: 1=small, 2=large, 3=both ;
		* create surgical nec variable ;
			if laparotomydone = 1 | abdominaldrain = 1 | bowelresecdone = 1 then surgical = 1; else surgical = 0;
	run;


*** NEC Imaging **********************************************;

	proc sort data=cmv.nec_image out=nec_image; by id dfseq; run;
	data nec_image; set nec_image; format imagetype imagetype.; run;

* check if given findings have been observed (report a count, or just y/n?) ; 
	data nec_image_totals; set nec_image; by id;

		retain disttotal bltotal sbstotal pitotal pvgtotal pntotal;

		if first.id then do;
			disttotal = intestinaldistension;
			bltotal = bowelloop;
			sbstotal = smallbowelseparation;
			pitotal = pneumointestinalis;
			pvgtotal = portalveingas;
			pntotal = pneumoperitoneum;
		end;

		else do;
			disttotal = disttotal + intestinaldistension;
			bltotal = bltotal + bowelloop;
			sbstotal = sbstotal + smallbowelseparation;
			pitotal = pitotal + pneumointestinalis;
			pvgtotal = pvgtotal + portalveingas;
			pntotal = pntotal + pneumoperitoneum;
		end;

		if last.id;

		if disttotal > 0 then dist = 1; else dist = 0;
		if bltotal > 0 then bl = 1; else bl = 0;
		if sbstotal > 0 then sbs = 1; else sbs = 0;
		if pitotal > 0 then pi = 1; else pi = 0;
		if pvgtotal > 0 then pvg = 1; else pvg = 0;
		if pntotal > 0 then pn = 1; else pn = 0;

		keep id imagetype disttotal bltotal sbstotal pitotal pvgtotal pntotal dist bl sbs pi pvg pn;   

	run;

	data nec; merge nec nec_image_totals; by id; run;

**************************************************************;

* label ;
	data nec; set nec;

		label 	duration = "Duration of episode of NEC (days)"
					age = "Age at diagnosis (days)"
					lbwiweight = "Weight at diagnosis (g)"
					nec_snap = "Severity of illness at diagnosis (SNAP II)"
					snaptotalscore = "Severity of illness at birth (SNAP)"
					hct = "Hematocrit at birth (%)"
					ssobs = "Clinical signs/symptoms observed"
					isbloodstool = "	- Bloody stool"
					isemesis = "	- Emesis"
					isabndistension = "	- Abdominal distension"
					txnd_prior_nec = "RBC transfusion prior to diagnosis NEC"
					prenec_median = "Median % enteral feeding in 7 days prior to NEC diagnosis"
					entrealpct_d0 = "% Enteral feeding on day of NEC diagnosis"
					postnec_median = "Median % enteral feeding during episode of NEC"

					imagenumber = "Number of images taken related to NEC"
					dist = "	- Intestinal distension with ileus"
					bl = "	- Rigid bowel loops"
					sbs = "	- Small bowel separation"
					pi = "	- Pneumatosis intestinalis"
					pvg = "	- Portal vein gas" 
					pn = "	- Pneumoperitoneum"
					imagetype = "Type of image"

					antibioticnec = "Antibiotic treatment"
					surgical = "Surgery"

					laparotomydone = "	Exploratory laparotomy"
					necbowel = "		- Necrotic bowel"
					gangrenousbowel = "		- Gangrenous bowel"
					bowelharden = "		- Bowel wall hardening"
					largeintestineperfor = "		- Perforation of large intestine"
					smallintestineperfor = "		- Perforation of small intestine"

					abdominaldrain = "	Abdominal drains"

					bowelresecdone = "	Bowel resection"
					portionresec = "		- Portion resected"
					lengthresecmin = "		- Minimum length resected"
					woundculture = "		- Wound culture obtained"
					isculturepositive = "		- Wound culture positive"

					surgeryreqd = "	Additional surgery"

					lbwisbsyndrome = "Developed short bowel syndrome"

		;
	run;
	
	proc sort data = nec; by id; run;
	data nec; merge nec cmv.completedstudylist (in=a); by id; if a; run;


	* patient level stuff ;
	proc sort data=nec out=nec_pt; by id dfseq; run;
	data nec_pt; set nec_pt; by id; if first.id;
		keep age snaptotalscore hct txnd_prior_nec;
		label 	age = "Age at initial diagnosis"
					txnd_prior_nec = "pRBC transfusion prior to initial NEC diagnosis";
	run;



	* SECTION 1 ***********************************************************************************************************;
	data header1; 	length row $ 80; 				row = "^S={font_weight=bold font_size=2}Clinical Diagnosis"; 
							length disp_overall $ 65; 	disp_overall = "^S={font_weight=bold font_style=italic}Med (Q1, Q2) [min-max], N"; run;
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= duration, type= cont, first_var=1);
	%descriptive_stat(data_in= nec_pt, data_out= nec_summary1a, var= age, type= cont);
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= lbwiweight, type= cont);	
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= nec_snap, type= cont);
	%descriptive_stat(data_in= nec_pt, data_out= nec_summary1a, var= snaptotalscore, type= cont);
	%descriptive_stat(data_in= nec_pt, data_out= nec_summary1a, var= hct, type= cont);
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= prenec_median, type= cont);	
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= entrealpct_d0, type= cont);
	%descriptive_stat(data_in= nec, data_out= nec_summary1a, var= postnec_median, type= cont, last_var=1);

	data header1b; length disp_overall $ 65; disp_overall = "^S={font_weight=bold font_style=italic}Total (%)"; run;
	%descriptive_stat(data_in= nec, data_out= nec_summary1b, var= ssobs, type= bin, first_var=1);	
	%descriptive_stat(data_in= nec, data_out= nec_summary1b, var= isbloodstool, type= bin);	
	%descriptive_stat(data_in= nec, data_out= nec_summary1b, var= isemesis, type= bin);	
	%descriptive_stat(data_in= nec, data_out= nec_summary1b, var= isabndistension, type= bin);
	%descriptive_stat(data_in= nec_pt, data_out= nec_summary1b, var= txnd_prior_nec, type= bin, last_var=1);	
	* SECTION 2 ***********************************************************************************************************;
	data header2; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Imaging findings"; run;
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= imagenumber, type= cont, first_var=1);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= dist, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= bl, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= sbs, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= pi, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= pvg, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary2, var= pn, type= bin);
	%descriptive_stat(data_in= nec_image, data_out= nec_summary2, var= imagetype, type= cat, last_var=1);
	* SECTION 3 ***********************************************************************************************************;
	data header3; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Treatment, Surgery and Follow-up"; run;
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= antibioticnec, type= bin, first_var=1);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= surgical, type= bin);

	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= laparotomydone, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= necbowel, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= gangrenousbowel, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= bowelharden, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= largeintestineperfor, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= smallintestineperfor, type= bin);

	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= abdominaldrain, type= bin);

	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= bowelresecdone, type= bin);
	*%descriptive_stat(data_in= nec, data_out= nec_summary3, var= portionresec, format=portionresected., type= cat);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= lengthresecmin, type= cont);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= woundculture, type= bin);
	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= isculturepositive, type= bin);

	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= surgeryreqd, type= bin);

	%descriptive_stat(data_in= nec, data_out= nec_summary3, var= lbwisbsyndrome, type= bin, last_var=1);


	* Merge tables and headers;
	data nec_summary; 
		set 	header1 nec_summary1a header1b nec_summary1b
				header2 nec_summary2
				header3 nec_summary3
		; 
	run;

	* print table ;
	%descriptive_stat(print_rtf = 1, 
			data_out= nec_summary, 
			file= "&output./april2011abstracts/nec_summary.rtf", 
			title= "Necrotizing Enterocolitis (&num_pts patients, &num_episodes episodes)"
		);


