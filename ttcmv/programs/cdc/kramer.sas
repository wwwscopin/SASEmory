
data demo; set cmv.lbwi_demo; 
	keep id gender gestage birthweight length headcircum;
run;

proc sort data = demo; by gender gestage;
proc sort data = cmv.olsen; by gender gestage; run;

data anthro_olsen; merge demo (in = a) cmv.olsen; by gender gestage; if a; run;

data anthro_olsen; set anthro_olsen;
	**********************************************************;
	olsen_weight_z = (birthweight - weight_mean)/weight_sd;

	if birthweight < weight_tenth then olsen_weight_tenth = 1;
	if birthweight >= weight_tenth then olsen_weight_tenth = 0;
	if birthweight = . then olsen_weight_tenth = .;

	if birthweight < weight_fiftieth then olsen_weight_fiftieth = 1;
	if birthweight >= weight_fiftieth then olsen_weight_fiftieth = 0;
	if birthweight = . then olsen_weight_fiftieth = .;
	**********************************************************;
	olsen_length_z = (length - length_mean)/length_sd;

	if length < length_tenth then olsen_length_tenth = 1;
	if length >= length_tenth then olsen_length_tenth = 0;
	if length = . then olsen_length_tenth = .;

	if length < length_fiftieth then olsen_length_fiftieth = 1;
	if length >= length_fiftieth then olsen_length_fiftieth = 0;
	if length = . then olsen_length_fiftieth = .;
	**********************************************************;
	olsen_hc_z = (headcircum - hc_mean)/hc_sd;

	if headcircum < hc_tenth then olsen_hc_tenth = 1;
	if headcircum >= hc_tenth then olsen_hc_tenth = 0;
	if headcircum = . then olsen_hc_tenth = .;

	if headcircum < hc_fiftieth then olsen_hc_fiftieth = 1;
	if headcircum >= hc_fiftieth then olsen_hc_fiftieth = 0;
	if headcircum = . then olsen_hc_fiftieth = .;
	**********************************************************;
run;

data cmv.anthro_olsen; set anthro_olsen; run;

data anthro_olsen; set anthro_olsen;
	keep id 	olsen_weight_z olsen_weight_tenth olsen_weight_fiftieth
					olsen_length_z olsen_length_tenth olsen_length_fiftieth
					olsen_hc_z olsen_hc_tenth olsen_hc_fiftieth
	; 
run;


proc sort data = cmv.lbwi_demo; by id;
proc sort data = anthro_olsen; by id; run;

data cmv.lbwi_demo; merge cmv.lbwi_demo anthro_olsen; by id; run;



/*
proc sort data = demo; by gender gestage;
proc sort data = cmv.kramer; by gender gestage; run;

data anthro_kramer; merge demo (in = a) cmv.kramer; by gender gestage; if a; run;

data anthro_kramer; set anthro_kramer;

	kramer_z = (birthweight - mean)/sd;

	if birthweight < tenth then kramer_tenth = 1;
	if birthweight >= tenth then kramer_tenth = 0;

	if birthweight < fiftieth then kramer_fiftieth = 1;
	if birthweight >= fiftieth then kramer_fiftieth = 0;

run;

data cmv.anthro_kramer; set anthro_kramer; run;

data anthro_kramer; set anthro_kramer;
	keep id kramer_z kramer_tenth kramer_fiftieth; 
run;


proc sort data = cmv.lbwi_demo; by id;
proc sort data = anthro_kramer; by id; run;

data cmv.lbwi_demo; merge cmv.lbwi_demo anthro_kramer; by id; run;
*/
