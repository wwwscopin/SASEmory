
data demo; set cmv.lbwi_demo; 
	keep id gender gestage ;
run;

proc sql;
create table med_review as
select a.id, a.dfseq ,a.HeadCircum, a.HtLength, a.weight ,b.gender,b.gestage
from cmv.med_review as a right join demo as b
on a.id = b.id;
 
quit;

data med_review;set med_review;
birthweight=weight; Length=HtLength;

run;
proc sort data = med_review; by gender gestage;
proc sort data = cmv.olsen; by gender gestage; run;

proc sql;
create table anthro_olsen as 
select a.* , b.* 
from med_review as a 
inner join cmv.olsen as b
on a.gender=b.gender and a.gestage=b.gestage;

quit;

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
/*
data anthro_olsen2; set anthro_olsen2; run;


data anthro_olsen2; set anthro_olsen2;
	keep id 	olsen_weight_z olsen_weight_tenth olsen_weight_fiftieth
					olsen_length_z olsen_length_tenth olsen_length_fiftieth
					olsen_hc_z olsen_hc_tenth olsen_hc_fiftieth
	; 
run;


proc sort data = cmv.lbwi_demo; by id;
proc sort data = anthro_olsen; by id; run;

data cmv.lbwi_demo; merge cmv.lbwi_demo anthro_olsen; by id; run;

*/


