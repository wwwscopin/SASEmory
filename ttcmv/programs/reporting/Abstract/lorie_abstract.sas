***********************************************************************;
***	Various medical characteristics overall and by ever transfused ***;
***********************************************************************;

%include "&include./descriptive_stat.sas";

proc sort data = cmv.plate_031 out = evertxn; by id; run;
data evertxn; set evertxn; by id; if first.id; run;

data evertxn; merge evertxn (in=b) cmv.completedstudylist (in=a); by id;
	if a;
	if b then evertxn = 1; else evertxn = 0;
	keep id evertxn;
run;

proc sort data = cmv.lbwi_demo out = lbwi_demo; by id; run;

data lbwi_demo; set lbwi_demo;
	if birthweight < 1000 then bw_cat = 1;
	if birthweight >= 1000 & birthweight <= 1500 then bw_cat = 2;
	if birthweight > 1500 then bw_cat = 3;
	format bw_cat bw_cat.;
run;


proc sort data = cmv.nec out = nec; by id dfseq; run;
data nec; set nec; by id; if first.id; run;
proc sort data = cmv.ivh out = ivh; by id; run;
proc sort data = cmv.rop out = rop; by id; run;
proc sort data = cmv.pda out = pda; by id; run;
proc sort data = cmv.bpd out = bpd; by id; run;
proc sort data = cmv.infection_all out = inf; by id dfseq; run;
data inf; set inf; by id; if first.id; run;
data outcome_list; merge nec ivh rop pda bpd inf; by id; keep id; run; 

proc sort data = cmv.med_review out = labs; by id dfseq; run;
data labs; set labs (rename = (hct = hct_birth hb = hb_birth)); if dfseq = 1; keep id hb_birth hct_birth; run; 


proc sort data = cmv.plate_031 out = rbc; by id dfseq; run;
data rbc; set rbc (rename = (hct = hct_txn hb = hb_txn)); keep id hct_txn hb_txn; run;
proc means data = rbc maxdec=2; var hct_txn; by id; output out = hct_txn mean= / autoname; run;
proc means data = rbc maxdec=2; var hb_txn; by id; output out = hb_txn mean= / autoname; run;
data labs_txn; merge hct_txn hb_txn; by id; keep id hb_txn_mean hct_txn_mean; run;



%macro conmed();
	data conmeds;
		set cmv.con_meds;
		%do i=1 %to 9;
			center=floor(id/1000000);
			Dose=Dose&i;
			DoseNumber=DoseNumber&i;
			EndDate=EndDate&i;
			StartDate=StartDate&i;
			day=EndDate-StartDate;
			Indication=Indication&i;
			MedCode=MedCode&i;
			MedName=MedName&i;
			Unit=Unit&i;
			prn=prn&i;
			i=&i;
			output;
		%end;
		keep id center dose dosenumber EndDate Startdate day Indication MedCode MedName Unit prn i ; 
		format StartDate EndDate mmddyy8. center center. MedCode MedCode. Indication Indication. unit unit.;
	run;
%mend;
%conmed();

proc sort data = conmeds; by id; run;
data conmeds; merge conmeds cmv.completedstudylist (in=a); 	by id;	if a;
	* get rid of blank entries ;
	if MedCode ~= .;
run;

proc sort data = conmeds; by id; run;
data iron; set conmeds; by id;
	retain iron;
	if first.id then iron = 0;

	if 	medname = "FER-IN-SOL" | medname = "FERINSOL" | medname = "FERROUS SULFATE" | 
			medname = "POLY-VI-SOL WITH IRON" | medname = "POLY-VI-SOL FE" |
			medname = "POLYVISOL WITH IRON" | medname = "POLYVISOL FE" | medname = "POLYRISOL FE" | 
			medname = "MULTIVITAMIN WITH IRON" 
	then iron = 1;

	if last.id;
	keep id iron;
run;

***********;
***	MERGE ;
***********;
data rbcabstract; merge 
		evertxn (in=a)
		lbwi_demo (keep = id BirthWeight bw_cat olsen_weight_z Length Headcircum)
		outcome_list (in=b)
		labs
		labs_txn
		iron
	;

	by id;
	if a;

	if b then outcome = 1; else outcome = 0;

	format evertxn outcome iron yn.;
	label
				evertxn = "Ever received RBC transfusion - no. (%)"	
				BirthWeight = "Birth weight (g) - mean (sd) [min-max], N"
				bw_cat = "Birth weight category - no. (%)"
				olsen_weight_z = "Birth weight Z-score - mean (sd) [min-max], N"
				Length = "Birth length (cm) - mean (sd) [min-max], N"
				Headcircum = "Birth head circumference (cm) - mean (sd) [min-max], N"
				hb_birth = "Hemoglobin at birth (g/dL) - mean (sd) [min-max], N "
				hct_birth = "Hematocrit at birth (%) - mean (sd) [min-max], N"
				hb_txn_mean = "Hemoglobin prior to transfusion (patient average) - mean (sd) [min-max], N"
				hct_txn_mean = "Hematocrit prior to transfusion (patient average) - mean (sd) [min-max], N"
				outcome = "At least one co-morbidity - no. (%)"
				iron = "Received supplemental iron - no. (%)"	
	;

run;


******************;
***	BUILD TABLES ;
******************;

*** two tables: overall and by ever txn ;

	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= BirthWeight, type= cont, non_param=0, dec_places=0, first_var=1);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= bw_cat, type= cat);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= olsen_weight_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= Length, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= HeadCircum, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= hb_birth, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= hct_birth, type= cont, non_param=0);	
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= outcome, type= bin);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= iron, type= bin);
	%descriptive_stat(data_in= rbcabstract, data_out= summary, var= evertxn, type= bin, last_var=1);	


	data rbcabstract0; set rbcabstract; if evertxn = 0; run;
	data rbcabstract1; set rbcabstract; if evertxn = 1; run;

	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= BirthWeight, type= cont, non_param=0, dec_places=0, first_var=1);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= bw_cat, type= cat);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= olsen_weight_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= Length, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= HeadCircum, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= hb_birth, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= hct_birth, type= cont, non_param=0);	
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= outcome, type= bin);
	%descriptive_stat(data_in= rbcabstract0, data_out= summary0, var= iron, type= bin, last_var=1);	

	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= BirthWeight, type= cont, non_param=0, dec_places=0, first_var=1);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= bw_cat, type= cat);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= olsen_weight_z, type= cont, non_param=0, dec_places=1);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= Length, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= HeadCircum, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= hb_birth, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= hct_birth, type= cont, non_param=0);	
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= hb_txn_mean, type= cont, non_param=0);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= hct_txn_mean, type= cont, non_param=0);	
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= outcome, type= bin);
	%descriptive_stat(data_in= rbcabstract1, data_out= summary1, var= iron, type= bin, last_var=1);	


	data summary1; set summary1; order = _N_; run;
	proc sort data = summary0; by row; run;
	proc sort data = summary1; by row; run;
	data txn_summary; merge 
		summary0 (rename = (disp_overall = disp0)) 
		summary1 (rename = (disp_overall = disp1))
		;
		by row; 
	run;
	proc sort data = txn_summary; by order; run;

	proc sql; select count(*) into :n1 from rbcabstract0;
	proc sql; select count(*) into :n2 from rbcabstract1;

	data txn_summary; set txn_summary; 	
		keep row disp0 disp1 ; 
		label 	disp0 = "Never Transfused*(n = &n1)"
					disp1 = "Transfused*(n = &n2)"
				;
	run;




	options nodate orientation = portrait;

	ods rtf file = "&output./april2011abstracts/lorie_table.rtf"  style=journal toc_data startpage = no bodytitle;
		title1 "Infant Characteristics - Overall"; 
		proc print data = summary label noobs split = "*" style(header) = {just=center} contents = "";
			id  row /style(data) = [font_size=1.8 font_style=Roman];
			by  row notsorted;
				var disp_overall /style(data) = [just=center font_size=1.8];
			run;

		title1 "Infant Characteristics - By Ever Transfused";
		proc print data = txn_summary label noobs split = "*" style(header) = {just=center} contents = "";
			id  row /style(data) = [font_size=1.8 font_style=Roman];
			by  row notsorted;
				var disp0 disp1 /style(data) = [just=center font_size=1.8];
			run;
	ods rtf close;
	
