/* concom_meds_open.sas */

* objective: provide the median number of days that people are on a given class of drugs. thus we need to figure out the total number of days
			within each person. to do this, i will count only days with a type of drug, regardless of how many different types of the drug were 
			given that day ;



* first, make an entry for each day that a person is on EACH medication. will make a very long dataset! ;	
	proc sort data= glnd.concom_meds; by id med_code; run;

	data concom;
		set glnd.concom_meds;
		
		* don't do this for people missing a start or stop date ; * 9/12/09: DON'T THINK THIS IS TRUE ANYMORE: or TEMPORARILY if the data are from patient 32051, who has erroneous dates ;
		if ~( (dt_meds_str = .) | (dt_meds_stp = . ) /*| (id = 32051) */ ) then do;
			do day_on_drug = dt_meds_str 	to	 dt_meds_stp;
				output;
			end;
		end;
		else output; * if a field is missing, just output once;
			
		format day_on_drug mmddyy.;
	run;
	
* next, remove overlapping days within each drug class;
	proc sort data= concom; by id med_code day_on_drug; run;

	data concom;	
		set concom;
		by id med_code day_on_drug;
		
		if (~first.day_on_drug) & (day_on_drug ~= .) then delete;

	run;

* now cycle through each drug class within an individual and count the unique days and save just that last record ;
	
	data concom_days ;	
		set concom;
		by id med_code;
		retain unique_days;
		
		where (day_on_drug ~= .) ; 
		
		if first.med_code then unique_days = 1;
		else unique_days = unique_days + 1;
	
		if ~last.med_code then delete;
	run;

	/*proc print data = concom_days;	run;*/
		
* then take the median number of days on each drug and SAVE ;
	proc means data = concom_days n median;
		class med_code ;
		var unique_days ;
	output out = concom_summary_days median(unique_days) = median_unique_days  n(unique_days) = n_unique_days;
	run;

	* remove junk from the means dataset ;
	data concom_summary_days;
		set concom_summary_days;
		
		where _type_ = 1;
		drop _type_ _freq_;
	run;


** now figure out the total number of people taking each drug type (includes those with incomplete dates) **;

* remove duplicate meds within a person;
data concom_people;
	set glnd.concom_meds;
	by id med_code;
	
	if ~first.med_code then delete;
run;


* then count the number of ids on a drug;
proc means data = concom_people n;
	class med_code ;
	var id ;
	output out = concom_summary n(id) = ever_used;
run;


* get total number of people on study ;
proc means data= glnd.status n;
	var id;
	output out= n_patients n(id)= n_patients;
run;

data n_patients;
	set n_patients;
	keep n_patients;
run;

* merge total N back in ;
data concom_summary;
	if _N_ = 1 then set n_patients;
	set concom_summary;

	if _TYPE_ = 0 then delete;
	drop _TYPE_ _FREQ_;
run;

* ADDED 9/12/09: for corticosteroids, add in median dose after 9/4/2008 DSMB meeting, where it was requested. ;
* cannot use reduced days datasets since some dose data could be lost if overlapping dates. go to original data ;
	proc means data = glnd.concom_meds n median;
		where (med_code in (2,3,4)) & (dt_meds_str > mdy(9,4,2008)); * steroids;
		
		class med_code;
		var meds_dose;
		output out = steroid_dose median(meds_dose) = median_dose_num;
	run;
	
	
	* add med_code ;
	data steroid_dose;
		set steroid_dose;
		where _TYPE_ = 1;
		
		drop _TYPE_ _FREQ_;
	run;


data cort;
	set glnd.concom_meds(keep=id 	med_code dt_meds_str);
	where dt_meds_str>=mdy(9,04,2008);
	drop 	dt_meds_str;
run;

proc print;run;

data cort4;
	set cort;
	where med_code=4;
run;


proc sort data=cort nodupkey; by id; run;
proc means data=cort; output out=num n=n;run;

data _null_;
	set num;
	call symput('n', n);
run;


proc sort data=cort4 nodupkey; by id; run;
proc means data=cort4; output out=num4 n=n;run;

data _null_;
	set num4;
	call symput('n4', n);
run;



* merge the median days back in and format for display (presumes that each med code is seen once in order to correctly merge );
data glnd_rep.concom_summary;

	length temp $6;
	merge 	concom_summary	
			concom_summary_days
			steroid_dose
		;

	by med_code;
	/*if med_code=4 then do; n_patients=&n; ever_used=&n4; end;*/

	if (median_dose_num ~= .) then median_dose = compress(put(median_dose_num, 4.1)) || " mg";
	percent = (ever_used/n_patients) * 100;
	
	temp=put(ever_used, 3.0);
	if med_code=4 then temp=cats(ever_used,"/",n_patients);
	
	per_char=put(percent,4.1);

	format percent 4.1;	
	label	n_patients = "n"
			med_code='Medication'
	     	ever_used='Ever Used'
	     	/*per_char='Percent'*/
	     	percent='Percent'
			/*temp='Ever Used'*/
			median_unique_days = 'Median days on drug'
			n_unique_days = "n - patients with complete start/stop dates"	
			median_dose = "Median dose (post 9/4/08)";
		;
run;

options nonumber nodate;

			ods ps file="concom.ps" style=journal;
		
			proc print data= glnd_rep.concom_summary noobs label split="*" style(data)= [just = center] ;
				title "Concomitant Medication";
				var med_code temp per_char median_unique_days median_dose;
				
				format med_code med_code. percent 4.1 median_unique_days 2.0;
			run;	

		ods ps close;
		ods pdf close;





proc sort data= concom_summary; by med_code; run;

proc print data= glnd_rep.concom_summary label noobs split = "*";
	var med_code ever_used n_patients percent median_unique_days n_unique_days median_dose; 
run;
