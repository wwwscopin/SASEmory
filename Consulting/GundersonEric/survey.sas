PROC IMPORT OUT= WORK.tmp 
            DATAFILE= "H:\SAS_Emory\Consulting\GundersonEric\AT Residency survey results.xls" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$A2:L30"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data survey0;
	set tmp;
	if Q___1="Y" then Q1=1; else Q1=0;
	if Q___2="Y" then Q2=1; else Q2=0;
	rename Survey__=survey Q____3=Q3 Q____4=Q4 Q____5=Q5 Q___6=Q6 Q____7=Q7 Q___8=Q8 Q____9=Q9 Q____10=Q10;
	keep survey Q1-Q2 Q___6 Q___8 Q____3-Q____10; 
run;

proc format;
	value yn 1="Yes" 0="No";
	value scale 0="Not at all" 1="Not at all"  2="Minimal" 3="Minimal" 4="Adequate"  5="Adequate" 6="Adequate" 
		7="Very Well" 8="Very Well" 9="Exceptional" 10="Exceptional";
	value item 
		1="Have you employed, or have experience with, athletic trainers working as a physician extender that have been 'residency trained'?"
		2="Have you employed athletic trainers to work as physician extenders that HAVE NOT been residency trained?"
		3="How prepared do you feel a residency trained athletic trainer is to be integrated into your clinic?"
		4="Compare the clinical skills of a residency trained athletic trainer versus those of a non residency trained athletic trainer?"
		5="Compare the MUSCULOSKELETAL skills of a residency trained atheltic trainer to those of an entry level Physician Assistant (PA-C)/Family Nurse Practitioner (FNP):"
		6="Compare the CLINICAL SKILLS of a residency trained atheltic trainer to those of a Medical Assistant (CMA):"
		7="Extent to which you feel your patient satisfaction has improved having a residency trained athletic trainer in your practice:"
		8="Extent to which your quality of life has improved (more physician specific time with patients, clinics running on time, more work completed during clinic
			time) having a residency trained athletic trainer in your practice:"
		9="Extent to which your clinic directly benefited (i.e. increased clinical efficiency,volume, patient flow) from having a residency trained athletic trainer in your
			clinic versus another type of physician extender:"
		10="Your Overall Satisfaction utilizing a residency trained athletic trainer as a physician extender?"
		;
run;

data survey; 
	set survey0;
	format Q1-Q2 yn. Q3-Q10 scale.;
run;

proc ttest data = survey h0 = 5;
  var Q3-Q10;
run;
