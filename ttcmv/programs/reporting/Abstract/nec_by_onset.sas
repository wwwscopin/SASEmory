
****************************************************;
*** Reproduction of TABLE V from jpeds NEC paper ***;
****************************************************;

%include "&include./descriptive_stat.sas";

	
*** Given pRBC < 48 hours prior to NEC ;

	proc sort data = cmv.plate_031 out = rbc; by id dfseq; run;
	* list of NEC patients tranfused prior to NEC ;
	data list; set cmv.km; if has_nec = 1 & evertxn = 1; keep id necdate; run;

	data txn_prior; merge rbc (keep = id datetransfusion) list (in=a); by id; if a; 
		txn_prior_days = necdate - datetransfusion; 
		if txn_prior_days >= 0;
	run;

	proc sort data = txn_prior; by id txn_prior_days; run;
	data txn_prior; set txn_prior; by id; if first.id; run;

	proc format;
		value txn_prior_cat 
			1 = "<24h"
			2 = "24-48h"
			3 = ">48h"
		;
	run;
	
	data txn_prior; set txn_prior; 
		if txn_prior_days <= 2 then txn_prior48 = 1; else txn_prior48 = 0;
		label txn_prior48 = "<48 h from last RBC transfusion to onset of NEC - no. (%)";

		if txn_prior_days = 0 then txn_prior_cat = 1;
		if txn_prior_days > 0 & txn_prior_days <= 2 then txn_prior_cat = 2;
		if txn_prior_days > 2 then txn_prior_cat = 3;
		label txn_prior_cat = "Time from last RBC transfusion to onset of NEC - no. (%)";
		format txn_prior_cat txn_prior_cat.;
	run;

****************;

data km; set cmv.km; if has_nec = 1 & evertxn = 1; keep id time numrbctxns numrbcdonors avevol; run;

proc sort data = km; by id; run;
proc sort data = txn_prior; by id; run;

data early_onset; merge km txn_prior; by id; if time <= 28; run;
data late_onset; merge km txn_prior; by id; if time > 28; run;



	%descriptive_stat(data_in= early_onset, data_out= table1, var= numrbctxns, type= cont, non_param=1, first_var=1);
	%descriptive_stat(data_in= early_onset, data_out= table1, var= numrbcdonors, type= cont, non_param=1);
	%descriptive_stat(data_in= early_onset, data_out= table1, var= avevol, type= cont, non_param=1);
	%descriptive_stat(data_in= early_onset, data_out= table1, var= txn_prior48, type= bin);
	%descriptive_stat(data_in= early_onset, data_out= table1, var= txn_prior_cat, type= cat, last_var=1);

	%descriptive_stat(data_in= late_onset, data_out= table2, var= numrbctxns, type= cont, non_param=1, first_var=1);
	%descriptive_stat(data_in= late_onset, data_out= table2, var= numrbcdonors, type= cont, non_param=1);
	%descriptive_stat(data_in= late_onset, data_out= table2, var= avevol, type= cont, non_param=1);
	%descriptive_stat(data_in= late_onset, data_out= table2, var= txn_prior48, type= bin);
	%descriptive_stat(data_in= late_onset, data_out= table2, var= txn_prior_cat, type= cat, last_var=1);


	data table1; set table1 (rename = (disp_overall = disp1)); run;
	data table2; set table2 (rename = (disp_overall = disp2)); order = _N_; run;
	proc sort data = table1; by row; run;
	proc sort data = table2; by row; run;
	data table; merge table1 table2; by row; run;
	proc sort data = table; by order; run;

	proc sql; select count(distinct(id)) into :n1 from early_onset;
	proc sql; select count(distinct(id)) into :n2 from late_onset;	

	data table; set table; 	
		keep row disp1 disp2; 
		label 	disp1 = "Early-onset NEC/RBC-trasfused*(n=&n1)"
					disp2 = "Late-onset NEC/RBC-trasfused*(n=&n2)";
	run;


	options nodate orientation = portrait;
	ods rtf file = "&output./april2011abstracts/nec_by_onset.rtf"  style=journal toc_data startpage = no bodytitle;
		title1 "Blood transfusion history of NEC/RBC-transfused patients"; 
		proc print data = table label noobs split = "*" style(header) = {just=center} contents = "";
			id  row /style(data) = [font_size=1.8 font_style=Roman];
			by  row notsorted;
				var disp1 disp2 /style(data) = [just=center font_size=1.8];
			run;
	ods rtf close;


