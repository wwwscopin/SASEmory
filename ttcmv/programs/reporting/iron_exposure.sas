%include "&include./descriptive_stat.sas";


*** GET ENTERAL EXPOSURE ;

* Clean-up of Con Meds form is required -- see code for acceptable med names. ; 

	proc sort data = cmv.con_meds_long out = con_meds_long; by id; run;
	
	data enteral_iron; merge con_meds_long (in=b) cmv.completedstudylist (in=a); by id; if a&b;

		if medname = "FER-IN-SOL" | medname = "FERINSOL" | medname = "FERROUS SULFATE"
		then type = 1;
	
		if medname = "MULTIVITAMIN WITH IRON" | medname = "POLY-VI-SOL WITH IRON" | medname = "POLY-VI-SOL WITH FE" 
		 | medname = "POLYVISOL WITH IRON" | medname = "POLYVISOL WITH FE"  
		then type = 2;
	
		if type = 1 | type = 2;
	
	run; 
	
	
	data enteral_iron; set enteral_iron; 
	
		if type = 1 then total_dose = dose * dosenumber;
		if type = 2 then total_dose = 10 * dose * dosenumber; 
	
	run;
	
	
	proc sort data = enteral_iron; by id; run;
	
	data enteral_iron; set enteral_iron; by id; retain total_enteral;
	
		if first.id then total_enteral = total_dose;
		else total_enteral = total_enteral + total_dose;
		
		if last.id;
	
	run;
	
	
*** GET PRBC EXPOSURE ;

	proc sort data = cmv.plate_031 out = plate_031; by id; run;

	data rbc_iron; merge plate_031 (in=b) cmv.completedstudylist (in=a); by id; if a&b; run;

	data rbc_iron; set rbc_iron; by id; retain total_rbc;

		if first.id then total_rbc = rbcvolumetransfused;
		else total_rbc = total_rbc + rbcvolumetransfused;

		if last.id;

	run;



*** TOTAL ;

	data iron_exposure; merge enteral_iron (in=b) 
														rbc_iron (in=c)
														cmv.completedstudylist (in=a); 
		by id;
		if a;

		if b then enteral_exposure = 1; else enteral_exposure = 0;
		if c then rbc_exposure = 1; else rbc_exposure = 0; 
		if b|c then total_exposed = 1; else total_exposed = 0;

		tie = sum(total_enteral, total_rbc);

		keep id enteral_exposure total_enteral rbc_exposure total_rbc total_exposed tie;

	run;



*** Get ever breast fed ;

	proc sort data = cmv.breastfeedlog out = ever_breastfed; by id; run;
	data ever_breastfed; set ever_breastfed; if startdate1 ~= .; run;

	data iron_exposure; merge iron_exposure (in=a) ever_breastfed (in=b keep = id); by id; 

		if a; 

		if a&b then ever_breastfed = 1; 
		if a&~b then ever_breastfed = 0; 

	run; 
	


*************************;
*** Outcome variables ***;
*************************;

*** ROP ;

proc sort data = cmv.ROP out = rop; by id ropexamdate; run;

data rop; set rop; 

	if leftretinopathy = 1 | rightretinopathy = 1; 

run; 

data rop; set rop; by id; retain firstdate; retain stage2; retain treatment; 

	if first.id then firstdate = ropexamdate; 

	if first.id & (leftretinopathystage >= 2 | rightretinopathystage >= 2) then stage2 = 1;
	if first.id & ~(leftretinopathystage >= 2 | rightretinopathystage >= 2) then stage2 = 0;
	if ~first.id & (leftretinopathystage >= 2 | rightretinopathystage >= 2) then stage2 = 1;

	if leftlaser = 1 | rightlaser = 1 | leftcryotherapy = 1 | rightcryotherapy = 1 | leftsclebuckle = 1
	 | rightsclebuckle = 1 | leftvitrectomy = 1 | rightvitrectomy = 1 then wastreated = 1; 
	else wastreated = 0;

	if first.id & wastreated = 1 then treatment = 1;
	if first.id & wastreated = 0 then treatment = 0;
	if ~first.id & wastreated then treatment = 1;

	if last.id; 

run; 

data first2date; set rop; by id; retain first2date; 

	if stage2 = 1; 
	if first.id then first2date = ropexamdate;
	if last.id; 

run; 

data rop; merge rop (in=b keep = id ropexamdate firstdate stage2 treatment) 
								first2date (keep = id first2date)
								cmv.completedstudylist (in=a); 
	by id; 
	if a; 
	format firstdate first2date mmddyy.;

	if b then rop = 1; else rop = 0;

	* make demoninator all patients ;
	if stage2 = . then stage2 = 0;
	if treatment = . then treatment = 0;

run;


proc sort data = cmv.lbwi_demo out = demo; by id; run;
data dob; set demo; keep id lbwidob; run;

data rop; merge rop (in=a) dob; by id; if a; 

	firstdol = firstdate - lbwidob;
	first2dol = first2date - lbwidob;

run;


*** BPD ;



*** Death ;

proc sort data = cmv.plate_100 out = death; by id; run;
proc sort data = cmv.plate_101 out = death2; by id; run;
data death2; set death2; if deathdate ~= .; run;
data death; merge death (keep = id deathdate in=b) death2 (keep = id deathdate in=c) cmv.completedstudylist (in=a); by id; if a & (b|c); 
	center = floor(id/1000000); run;

proc sort data = death; by id; run; 

data death; merge death (in=b) 
									dob
									cmv.completedstudylist (in=a);
	by id; 
	if a;

	if b then death = 1; else death = 0;
	deathdol = deathdate - lbwidob; 

run;


*** Late-Onset Sepsis ;

* look for positive blood or CNS culture after 72 hours (first three days) of life ;
proc sort data = cmv.infection_all out = infection; by id; run;

data infection; set infection; 

	if culturepositive = 1 & (sitecns = 1 | siteblood = 1); 
	keep id sitecns siteblood 
			 culture1date culture1org culture1site culture2date culture2org culture2site
			 culture3date culture3org culture3site culture4date culture4org culture4site
			 culture5date culture5org culture5site culture6date culture6org culture6site
	;
	format culture1org culture2org culture3org culture4org culture5org culture6org cultureorg. 
				 culture1site culture2site culture3site culture4site culture5site culture6site culturesite.
	;

run;

* TEMPORARILY fix one erroneous value - culture date is in the future ;
data infection; set infection; if id = 2002111 then culture1date = 18387; run;


* look for treatment with antibiotics for at least 5 days ;
data antibiotics; set cmv.con_meds_long (keep = id medcode startdate enddate); 
	if medcode = 1 | medcode = 2 | medcode = 7 | medcode = 11 | medcode = 19 | medcode = 22; 
	if startdate ~= . & enddate ~= .;
	if enddate < startdate then delete;
run;

proc sort data = antibiotics; by id; run;
data antibiotics; merge antibiotics (in=b) infection (in=a keep=id); by id; if a; run;

* TEMPORARILY remove one erroneous value - start date is in the future ;
data antibiotics; set antibiotics; if startdate = 18991 then delete; run;

***************;

proc sort data = antibiotics; by id startdate; run;
data dayson_antibiotic; 
	array start{100};
	array end{100};
	do i=1 to 100; set antibiotics; by id; 
		start(i) = startdate; 
		end(i) = enddate; 
		if last.id then return; 
	end;
run;

data dayson_antibiotic; set dayson_antibiotic;
	array start{100};
	array end{100};
	array days{100}; do k=1 to 100; days(k)=0; end;
	do j=1 to i; 
		startval = start(j) - start(1) + 1; 
		endval = end(j) - start(1) + 1; 
	do k=startval to endval;
		days(k) = 1;
	end;
	end;
	antibiotic = sum(of days1-days100);
run;

data infection; merge infection dayson_antibiotic (in=a keep=id antibiotic); 
	by id; 
	if ~a then antibiotic = 0;
run;

***************;

* Finally, keep only patients who: 
		(1) Had sepsis onset after first 3 days of life and 
		(2) Were on antibiotics for 5 or more days ;

data infection; merge infection (in=b) dob; 

	by id; if b;

	infectiondol = culture1date - lbwidob; 
	if infectiondol >= 3;

	if antibiotic > 4;

run;

data infection; merge infection (in=b) 
											cmv.completedstudylist (in=a); 

	by id; if a;

	if b then los = 1; else los = 0;

run;


*** NEC ; 

proc sort data = cmv.nec out = nec; by id necdate; run;

data nec; set nec; 

	if laparotomydone = 1 | abdominaldrain = 1 | bowelresecdone = 1 | surgeryreqd = 1 
		then surgical = 1;
	else surgical = 0; 

	keep id necdate surgical laparotomydone abdominaldrain bowelresecdone surgeryreqd;

run;

* break up into 2 data sets. count infants with medical AND surigical episodes twice ; 
proc sort data = nec; by id necdate; run; 

data surgical_nec; set nec; if surgical = 1; run;
data surgical_nec; set surgical_nec; by id; if first.id; run;
data medical_nec; set nec; if surgical = 0; run; 
data medical_nec; set medical_nec; by id; if first.id; run; 

data nec; merge surgical_nec (in=a) medical_nec (in=b); by id; 

	if a then surgical_nec = 1; else surgical_nec = 0;
	if b then medical_nec = 1; else medical_nec = 0;

run; 


data nec; merge nec (in=b) 
					dob
					cmv.completedstudylist (in=a); 

	by id;
	if a; 

	if b then nec = 1; else nec = 0; 
	necdol = necdate - lbwidob; 

run;


*** PVL ;

proc sort data = cmv.ivh_image out=pvl; by id dfseq; run;
data pvl; set pvl; if leftperileuko = 1 | rightperileuko = 1; run; 
data pvl; set pvl; by id; if first.id; run;

data pvl; merge pvl (in=b keep=id) 
					cmv.completedstudylist (in=a); 

	by id;
	if a; 

	if b then pvl = 1; else pvl = 0; 

run;


********** MERGE & WRITE LABELS FOR TABLE **********;

data iron_exposure; merge iron_exposure rop /*bpd*/ death infection nec pvl
										cmv.completedstudylist (in=a);

	by id; if a;

	label 
		enteral_exposure = "Ever given enteral iron"
		total_enteral = "Total iron from enteral feeds, for those exposed (mg)"
		rbc_exposure = "Ever pRBC transfused"
		total_rbc = "Total iron from pRBC transfusions, for those exposed (mg)"
		total_exposed = "Ever exposed to iron, from enteral feeds and/or pRBC"
		tie = "Total Iron Exposure (TIE), for those exposed (mg)"
		ever_breastfed = "Ever fed breast milk"

		rop = "ROP prior to hospital discharge or 90 postnatal days"
		firstdol = "	DOL at ROP diagnosis"
		stage2 = "	ROP stage 2 or greater"
		first2dol = "		DOL at stage 2 ROP diagnosis"
		treatment = "	Received treatment for ROP"

		death = "Death prior to hospital discharge or 90 postnatal days"
		deathdol = "	DOL at death"

		los = "Late-onset sepsis prior to hospital discharge or 90 postnatal days"
		infectiondol = "	DOL at first positive sepsis culture"

		nec = "NEC prior to hosptial discharge or 90 postnatal days"
		necdol = "	DOL at initial NEC diagnosis"
		medical_nec = "	Medical NEC cases"
		surgical_nec = "	Surgical NEC cases"
		laparotomydone = "		-Laparotomy"
		abdominaldrain = "		-Abdominal drain"
		bowelresecdone = "		-Bowel resection"
		surgeryreqd = "		-Additional surgery"

		pvl = "Periventricular leukomalacia prior to hosptial discharge or 90 postnatal days"

	;

run;



* SECTION 1 ***********************************************************************************************************;
	data header1; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Predictor variables"; run;
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= enteral_exposure, type= bin, first_var=1);
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= total_enteral, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= rbc_exposure, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= total_rbc, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= total_exposed, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= tie, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary1, var= ever_breastfed, type= bin, last_var=1);
	* SECTION 2 ***********************************************************************************************************;
	data header2; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Primary outcomes"; run;
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= rop, type= bin, first_var=1);
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= firstdol, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= stage2, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= first2dol, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= treatment, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= death, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary2, var= deathdol, type= cont, non_param=1, last_var=1);
	* SECTION 3 ***********************************************************************************************************;
	data header3; length row $ 80; row = "^S={font_weight=bold font_size=2}" || "Secondary outcomes"; run;
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= los, type= bin, first_var=1);
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= infectiondol, type= cont, non_param=1);
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= nec, type= bin);
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= necdol, type= cont, non_param=1);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= medical_nec, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= surgical_nec, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= laparotomydone, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= abdominaldrain, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= bowelresecdone, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= surgeryreqd, type= bin);	
	%descriptive_stat(data_in= iron_exposure, data_out= summary3, var= pvl, type= bin, last_var=1);


* Merge tables and headers;
	data summary; 
		set 	header1 summary1 
				header2 summary2
				header3 summary3
		; 
	run;


	* print table ;
	%descriptive_stat(print_rtf = 1, 
			data_out= summary, 
			file= "&output./iron_exposure_summary.rtf", 
			title= "Summary of variables pertinent to Iron Exposure data analysis"
		);

