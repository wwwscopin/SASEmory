/*proc contents data=glnd.plate203;run;*/


data sae_last;
	set glnd.plate203;
	keep id dt_sae_onset sae_code sae_type sae_number;
	if id in(11485,11515,12473,12499,12505,12506,31367,31386,41169);
run;

proc print;run;


data sae5;
	set glnd.plate203;
	keep id dt_sae_onset sae_code sae_type sae_number;
	where sae_code=5;
run;


title "SAE Type 5 Listing";
ods pdf file="sae5.pdf" style=journal;
proc print data=sae5  label style(data)=[just=center];
var id dt_sae_onset sae_code sae_type sae_number;
run;
ods pdf close;


data sae6;
	set glnd.plate203;
	keep id dt_sae_onset sae_code sae_type sae_number;
	where sae_code=6;
run;

title "SAE Type 6 Listing";
ods pdf file="sae6.pdf" style=journal;
proc print data=sae6 label style(data)=[just=center];

var id dt_sae_onset sae_code sae_type sae_number;
run;
ods pdf close;


proc sort data=sae6 nodupey; by id; run;
proc print;run;








