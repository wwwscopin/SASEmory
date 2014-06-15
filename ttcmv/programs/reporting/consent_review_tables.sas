

data moc_demo; set cmv.moc_demo; 

	age = round(yrdif(MOC_DOB,DateFormCompl,'ACT/ACT'));

	label
		moc_dob = "MOC DOB" 
		age = "Age, years"
	;

run;

data young; set moc_demo; if age ~= . & age < 18; run;


	ods rtf file = "&output./moc_dob_lessthan18.rtf" style=journal bodytitle;
		title1 "List of TT-CMV MOC <18 years old"; 		
		proc print data = young noobs label style(header) = {just=center}; 
			var id moc_dob age;		
		run;
	ods rtf close;




data consent_date; set cmv.plate_001 (keep = id enrollmentdate lbwiconsentdate);
	if enrollmentdate ~= .;
run;

data dob; set cmv.plate_005 (keep = id lbwidob); run;

data lbwi_blood_date; set cmv.lbwi_blood_collection (rename = (dateformcompl = lbwi_blood_date) keep = id dateformcompl dfseq);
	if dfseq = 1; run; 
data lbwi_urine_date; set cmv.lbwi_urine_collection (rename = (datecomplete = lbwi_urine_date) keep = id datecomplete dfseq);
	if dfseq = 1; run; 
data moc_blood_date; set cmv.plate_004 (rename = (dateformcompl = moc_blood_date) keep = id dateformcompl dfseq);
	if dfseq = 1; run;


proc sort data = consent_date; by id; run;
proc sort data = dob; by id; run;
proc sort data = lbwi_blood_date; by id; run;
proc sort data = lbwi_urine_date; by id; run;
proc sort data = moc_blood_date; by id; run;

data consent_date_check; 
	merge consent_date dob lbwi_blood_date lbwi_urine_date moc_blood_date;
		by id; 
run;

data consent_date_check; set consent_date_check; 
	retain keep_date;
	if substr(put(id,$7.),6,1) = 1 then keep_date = moc_blood_date;
	if substr(put(id,$7.),6,1) ~= 1 & moc_blood_date = . then moc_blood_date = keep_date;
run;

data consent_date_check; set consent_date_check; 

	if enrollmentdate = lbwiconsentdate then enrollmentconsent = 1; else enrollmentconsent = 0;
	if enrollmentdate = . | lbwiconsentdate = . then enrollmentconsent = .;
	label enrollmentconsent = "Date of consent = Date of enrollment?";
	format enrollmentconsent yn.;

	if enrollmentdate <= lbwidob + 5 then enrollmentdob = 1; else enrollmentdob = 0;
	if enrollmentdate = . | lbwidob = . then enrollmentdob = .;
	label enrollmentdob = "Date of enrollment within 5 days of DOB?";
	format enrollmentdob yn.;

	if 	(lbwi_blood_date ~= . & lbwi_blood_date < lbwiconsentdate) | 
			(lbwi_urine_date ~= . & lbwi_urine_date < lbwiconsentdate) | 
			(moc_blood_date ~= . & moc_blood_date < lbwiconsentdate)
		then consentcollection = 1; else consentcollection = 0;
	if lbwi_blood_date = . & lbwi_urine_date = . & moc_blood_date = . then consentcollection = .;
	label consentcollection = "Collection form(s) completed prior to date of consent?";
	format consentcollection yn.;

run;

	options nodate orientation = portrait;
	ods rtf file = "&output./consent_date_check.rtf" style=journal startpage = off bodytitle;
		title1 "Date of enrollment, consent and date enrollment samples collected for all enrolled patients"; 		
		proc print data = consent_date_check noobs label style(header) = {just=center};
 
			var 	id lbwidob enrollmentdate enrollmentdob lbwiconsentdate enrollmentconsent 
					lbwi_blood_date lbwi_urine_date moc_blood_date consentcollection
			;
		
			label 	lbwi_blood_date = "LBWI Enrollment Blood Collection Form Completed Date"
						lbwi_urine_date = "LBWI Enrollment Urine Collection Form Completed Date"
						moc_blood_date = "MOC Enrollment Blood Collection Form Completed Date"
			;
		run;



	ods rtf close;



