options nodate;

data all_pat;
	set cmv.comp_pat(keep=id);
	center=floor(id/1000000);
	if center in(1,2,3);
	format center center.;
run;


proc means data=all_pat noprint;
	class center;
	output out=n_pat n(center)=num;
run;

data n_pat;
	set n_pat(drop=_TYPE_ _FREQ_);
 	if center=1  then call symput("n1", compress(put(num,3.0)));
 	if center=2  then call symput("n2", compress(put(num,3.0)));
 	if center=3  then call symput("n3", compress(put(num,3.0)));

 	if center=.  then do; 
		center=0;
		call symput("n_total", compress(put(num,3.0)));
	end;
run;


proc format;

value drug 

   1 = "Dopamine"
   2 = "Dobutamine"
   3 = "Epinephrine"
   4 = "Norepinephrine"
   5 = "Milinone"
   6 = "Isoprotenol"
   7 = "Prostaglandin"
   8 = "Hydrocortisone"
   9 = "Other vasopressor"
	10= "Morphine"
	11= "Fentanyl"
	12= "Norcuron"
	13= "Other analgesic"
	14= "Other paralytic"
	15= "Other barbiturate"
	96="--Any Vasopressor--"
	97="--Any Analgesic--"
	;

run;


%macro vasopressor(dataset);
data tmp;
	set &dataset;
	%do i=1 %to 20;
		center=floor(id/1000000);
		drug=drugcode&i;
		treatmentdate=TreatmentDate&i;
		dose=dose&i;
		concentration=concentration&i;
		volume=volume&i;
		lbwi_weight=lbwi_weight&i;
		time_hr=time_hr&i;
		time_min=time_min&i;
		t=time_hr*60+time_min;
		if dose=. then dose=concentration*volume/(lbwi_weight/1000)/t;
		if drug=. then delete;
		i=&i;

		output;
	%end;
		keep id center drug treatmentdate dose concentration volume lbwi_weight time_hr time_min t i; 
		format drug drug. treatmentdate mmddyy8. dose 5.2 center center.;
run;
%mend;

%vasopressor(cmv.vasopressor);quit;

proc sql; 

create table tmp as 
	select tmp.*
	from tmp, all_pat
	where tmp.id=all_pat.id
	;

proc sort data=tmp; by id drug; run;

/*
proc sort data=tmp out=tmp_id nodupkey; by id drug; run;

proc means data=tmp_id noprint;
	class center;
	output out=drip n(center)=num;
run;

data drip;
	set drip(drop=_TYPE_ _FREQ_);
 	if center=1  then call symput("n1", compress(put(num,3.0)));
 	if center=2  then call symput("n2", compress(put(num,3.0)));
 	if center=3  then call symput("n3", compress(put(num,3.0)));

 	if center=.  then do; 
		center=0;
		call symput("n_total", compress(put(num,3.0)));
	end;
run;
*/

data tmp;
	set tmp; by id drug;
	first=first.drug;
	if drug in (1,2,3,9) then do; drip=96;end;
		else if drug in (10,11,13) then do; drip=97;end;
run;

proc means data=tmp;
class drip;
var dose;
output out=drip_median n(dose)=n_dose median(dose)=median_dose;
run;

data  drip_median;
	set drip_median;
	center=0;
	format center center.;
run;

proc means data=tmp n;
 	where first=1;
	class drip;
	var id;
	output out = drip_id n(id) =n;
run;

data drip;
	merge  drip_id(keep=drip n) drip_median(keep=drip n_dose median_dose); by drip;
   pct=n/&n_total*100; used=compress(n||"/"||&n_total);

	dose=compress(put(median_dose,5.2))||"("||compress(put(n_dose,5.0))||")";
	if drip=. then delete;
	center=0;
	rename drip=drug;
	format pct 5.1 drug drug.;
run;

***************************************************************;
proc means data=tmp;
class center drug;
var dose;
output out=drug_median n(dose)=n_dose median(dose)=median_dose;
run;


data  drug_median;
	set drug_median;
	if drug=. then delete;
	if center=. then center=0;
	format center center.;
run;

proc sort; by center drug;run;

proc print;run;

proc means data=tmp n;
 	where first=1;
	class center drug;
	var id;
	output out = drug_id n(id) =n;
run;


data  drug_id;
	set drug_id;
	if drug=. then delete;
	if center=. then center=0;
	format center center.;
run;

proc sort; by center drug;run;

**************************************************************************;


data vasopressor;
	merge  drug_id(keep=center drug n) drug_median(keep=center drug n_dose median_dose); by center drug;
	if center=1 then do; pct=n/&n1*100; used=compress(n||"/"||&n1); end;
	if center=2 then do; pct=n/&n2*100; used=compress(n||"/"||&n2); end;
	if center=3 then do; pct=n/&n3*100; used=compress(n||"/"||&n3); end;
	if center=0 then do; pct=n/&n_total*100; used=compress(n||"/"||&n_total); end;

	dose=compress(put(median_dose,5.2))||"("||compress(put(n_dose,5.0))||")";
	if drug=. then delete;
	format pct 5.1;
run;

data vasopressor;
	set vasopressor drip; by center drug;
	if drug in (1,2,3,9,96) then group=1;
	if drug in (10,11,13,97) then group=2;
run;

proc sort; by center group drug;run;

data vasopressor;
	set vasopressor; by center;
	if not first.center then center=99;
	format center center.;
run;

title "Drip Log Medications (n=&n_total)";
ods rtf file="vasopressor.rtf" style=journal;
proc print data=vasopressor noobs label split='*' style(data)=[just=left];
	var center drug;
	var used/style(data)=[cellwidth=1in just=center];;
	var pct dose /style(data) = [just=center];

 label /*std='Standard Deviation'*/
			used='Ever Used'
			pct='Percent(%)'
			dose='Median Dose*(count)'
			/*dose='Median Dose(mcg or mg/kg/min)*(count)'*/
			drug='Drug'
	;
run;
ods rtf close;



