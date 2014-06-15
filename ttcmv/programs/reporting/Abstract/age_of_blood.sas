%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";

**********************************;
* age of blood, etc. for RBC TXNS ;
**********************************;
* merge RBC txn data with donor unit data ;
proc sort data = cmv.plate_031 out = plate_031; by DonorUnitId;
proc sort data = cmv.plate_001_bu out = plate_001_bu; by DonorUnitId; run;
* remove dups ;
data plate_001_bu; set plate_001_bu; by donorunitid; if first.donorunitid; run;

 


data cmv.age_of_blood;
	merge 
		plate_031 	(	in = tx_record 
									keep = id datetransfusion dateirradiated donorunitid rbcvolumetransfused rbc_txendtime rbc_txstarttime hb hct
									rename = (dateirradiated = dateirradiated_txn hb = hb_txn hct = hct_txn)
								)
		plate_001_bu	(	in = tracking 
										keep = donorunitid dateirradiated datedonated DCCUnitID
									)

	;
	by DonorUnitID;

	*** COMPLETE RECORDS ONLY ;
	*if tx_record & tracking;

	*** IDENTIFY HOSPITAL ;
	center = floor(DCCUnitID/10000000);
	format center center.;

	*** GET DATE IRRADIATED ;
	if (center = 3 | center = 4 | center = 5) & dateirradiated_txn ~= . then dateirradiated = dateirradiated_txn;

run;

* keep only valid ids from frozen data ;
proc sort data = cmv.age_of_blood; by id; run;
data cmv.age_of_blood; merge cmv.age_of_blood (in=b) cmv.completedstudylist (in=a); by id; if a & b; run; 

*******************************************************************************************;
*******************************************************************************************;
* 	BY TRANSFUSION 
*******************************************************************************************;

proc sort data = cmv.age_of_blood; by center id; run;

data cmv.age_of_blood; set cmv.age_of_blood;

	age_of_blood = datetransfusion - datedonated; 
	days_irradiated = datetransfusion - dateirradiated;
	
	if age_of_blood > 14 then old_blood = 1;
	if age_of_blood <= 14 then old_blood = 0;

	format txnstarttime txnendtime txnlength HHMM.;
	txnstarttime = hms(input(substr(rbc_txstarttime,1,2),2.0), input(substr(rbc_txstarttime,4,2),2.0), 0);
	txnendtime = hms(input(substr(rbc_txendtime,1,2),2.0), input(substr(rbc_txendtime,4,2),2.0), 0);
	txnlength = txnendtime - txnstarttime;
	if txnlength < 0 then txnlength = (hms(24,0,0) - txnstarttime) + txnendtime;

	if txnlength > hms(10,0,0) then txnlength = .;

	label	age_of_blood = "Age of blood at transfusion (days) ^S={font_style=italic}median (Q1, Q3) [Range], N"
				days_irradiated = "Number of days blood transfused after irradiation ^S={font_style=italic}median (Q1, Q3) [Range], N"
				old_blood = "Number transfusions of old blood (stored >14 days) ^S={font_style=italic}median (Q1, Q3) [Range], N"
	;

run;


***	QC Data Listing ;

data aob_qc; set cmv.age_of_blood; 
	if age_of_blood < 4 | age_of_blood > 27 | days_irradiated < 0; 
run;

proc sort data = aob_qc; by center datedonated; run;

options nodate orientation = portrait;
ods rtf file = "&output./april2011abstracts/age_of_blood/ageofblood_list.rtf" style=journal;

	title "Age of RBC at Transfusion";

	proc print data = aob_qc label noobs; 
		var center dccunitid donorunitid datedonated dateirradiated id datetransfusion age_of_blood days_irradiated;
		by center; 
		label 	datedonated = "Date donated"
					dateirradiated = "Date irradiated"
					age_of_blood = "Age of RBC at transfusion (days)"
					days_irradiated = "Days transfused after irradiation"
			;
	run;

ods rtf close;

********************************************************;

data age_of_old_blood; set cmv.age_of_blood; if old_blood;
	label age_of_blood = "Age of old blood at transfusion (days) ^S={font_style=italic}median (Q1, Q3) [Range], N";
run;


* Number of transfusions for metadata table ;
data _null_; set cmv.age_of_blood nobs=nobs;
  call symput('txns',trim(left(put(nobs,8.))));
run;

	* Midtown ***********************************************************************************************************;
	data euhm; set cmv.age_of_blood; if center = 1; run;
	data header1; length row $ 120; row = "^S={font_weight=bold font_style=italic font_size=2}" || "EUH Midtown"; run;
	%descriptive_stat(data_in= euhm, data_out= table1, var= age_of_blood, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= euhm, data_out= table1, var= days_irradiated, type=cont, non_param=1, dec_places=0, last_var=1);

	* Grady *************************************************************************************************************;
	data grady; set cmv.age_of_blood; if center = 2; run;
	data header2; length row $ 120; row = "^S={font_weight=bold font_style=italic font_size=2}" || "Grady"; run;
	%descriptive_stat(data_in= grady, data_out= table2, var= age_of_blood, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= grady, data_out= table2, var= days_irradiated, type=cont, non_param=1, dec_places=0, last_var=1);

	* Northside *********************************************************************************************************;
	data northside; set cmv.age_of_blood; if center = 3; run;
	data header3; length row $ 120; row = "^S={font_weight=bold font_style=italic font_size=2}" || "Northside"; run;
	%descriptive_stat(data_in= northside, data_out= table3, var= age_of_blood, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= northside, data_out= table3, var= days_irradiated, type=cont, non_param=1, dec_places=0, last_var=1);

	* Egleston **********************************************************************************************************;
	data egleston; set cmv.age_of_blood; if center = 4; run;
	data header4; length row $ 120; row = "^S={font_weight=bold font_style=italic font_size=2}" || "Egleston"; run;
	%descriptive_stat(data_in= egleston, data_out= table4, var= age_of_blood, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= egleston, data_out= table4, var= days_irradiated, type=cont, non_param=1, dec_places=0, last_var=1);

	* OVERALL ***********************************************************************************************************;
	data header5; length row $ 120; row = "^S={font_weight=bold font_style=italic font_size=2}" || "OVERALL"; run;
	%descriptive_stat(data_in= cmv.age_of_blood, data_out= table5, var= age_of_blood, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= cmv.age_of_blood, data_out= table5, var= days_irradiated, type=cont, non_param=1, dec_places=0);
	%descriptive_stat(data_in= cmv.age_of_blood, data_out= table5, var= old_blood, type=bin);
	%descriptive_stat(data_in= age_of_old_blood, data_out= table5, var= age_of_blood, type=cont, non_param=1, dec_places=0, last_var=1);

	* Merge tables and headers ;
	data age_of_blood; 
		set 	header1 table1 
				header2 table2
				header3 table3
				header4 table4
				header5 table5
		; 
	run;

	* print ;
	%descriptive_stat(	print_rtf = 1, 
									data_out= age_of_blood, 
									file= "&output./april2011abstracts/age_of_blood/age_of_blood.rtf", 
									title= "RBC Age of Blood Summary - By Transfusion"
							);
***********************************************************************************************************************;


*******************************************************************************************;
*******************************************************************************************;
* 	BY PATIENT - CALCULATE THE FOLLOWING: (for patients who completed study)
	* patients ever transfused, number of transfusions, # of donors by patient ;
	* ever transfused with blood older than 7, 14 days ;
	* average age of blood, average days irradiated before given, average volume BY PATIENT ;
	*** pre-transfusion hematocrit levels ;
* vars in dataset rbctxn_summary ;
*******************************************************************************************;

*** EXCLUDE ALL TXNS THAT HAPPENED AFTER NEC DIAGNOSIS FOR NEC PATIENTS ;
proc sort data = cmv.nec out = nec_list; by id; run;
	data nec_list; merge nec_list (in=a) cmv.completedstudylist (in=b); by id; if a & b; if dfseq = 161; keep id necdate; run;
proc sort data = cmv.age_of_blood; by id; run;

data cmv.age_of_blood; merge cmv.age_of_blood nec_list (in=a); by id;
	if a & datetransfusion > necdate then delete;
run;
************************************************************************;


*** Calculate ever transfused for all patients who have completed study ;
proc sort data = cmv.age_of_blood; by id; run;
data evertxn; set cmv.age_of_blood; by id; if first.id; keep id evertxn; run;
* MERGE ;
data cmv.rbctxn_summary; merge cmv.completedstudylist (in=a) evertxn (in=b); 
	by id; 	if a; if b then evertxn = 1; else evertxn = 0; run;


* Number of patients who received rbc txns for metadata table ;
data _null_; set evertxn nobs=nobs;
  call symput('pts',trim(left(put(nobs,8.))));
run;


*** Calculate number of RBC transfusions per patient, if ever txns old blood;
data numtxns; set cmv.age_of_blood; 
	by id; 

	retain numrbctxns; 
	if first.id then numrbctxns = 1;
		else numrbctxns = numrbctxns+1;

	retain evertxn7; 
	if first.id & age_of_blood >= 7 then evertxn7 = 1;
	if first.id & age_of_blood < 7 then evertxn7 = 0;
	*if ~first.id & age_of_blood >= 7 then evertxn7 = evertxn7+1; *count number of old blood txns;
	if ~first.id & age_of_blood >= 7 then evertxn7 = 1;

	retain evertxn14; 
	if first.id & age_of_blood >= 14 then evertxn14 = 1;
	if first.id & age_of_blood < 14 then evertxn14 = 0;
	if ~first.id & age_of_blood >= 14 then evertxn14 = 1;

	retain numtxn14; 
	if first.id & age_of_blood >= 14 then numtxn14 = 1;
	if first.id & age_of_blood < 14 then numtxn14 = 0;
	if ~first.id & age_of_blood >= 14 then numtxn14 = numtxn14+1; *count number of old blood txns;

	if last.id;
	keep id numrbctxns evertxn7 evertxn14 numtxn14;
run;
* MERGE ;
data cmv.rbctxn_summary; merge cmv.rbctxn_summary (in=a) numtxns; 
	by id; 	if a; run;

*** Calculate number of RBC donors per patient ;
proc sort data = cmv.age_of_blood; by id DonorUnitID datetransfusion; run;
data numdonors; set cmv.age_of_blood;
	by id; if first.id then reset = 1; run;

data numdonors; set numdonors; 
	by DonorUnitID notsorted; retain numrbcdonors;
	if reset = 1 then numrbcdonors = 1;
	if reset ~= 1 & first.DonorUnitID then numrbcdonors = numrbcdonors + 1;
run;

data numdonors; set numdonors;
	by id; if last.id; keep id numrbcdonors; run;

* MERGE ;
data cmv.rbctxn_summary; merge cmv.rbctxn_summary (in=a) numdonors; 
	by id; 	if a; run;




*** Calculate average age of blood, average days irradiated, average volume transfused for each patient ;
data aveage; set cmv.age_of_blood;
	by id; retain numrbctxns; 
	if first.id then numrbctxns = 1;
		else numrbctxns = numrbctxns+1;

	retain sumage; 
	if first.id then sumage = age_of_blood;
		else sumage = sumage + age_of_blood;
	if last.id then aveage = sumage / numrbctxns;

	retain sumirr; 
	if first.id then sumirr = days_irradiated;
		else sumirr = sumirr + days_irradiated;
	if last.id then aveirr = sumirr / numrbctxns;

	retain sumvol; 
	format avevol 2.0;
	if first.id then sumvol = rbcvolumetransfused;
		else sumvol = sumvol + rbcvolumetransfused;
	if last.id then avevol = sumvol / numrbctxns;

	retain sumlength; 
	format avelength hhmm.;
	if first.id then sumlength = txnlength;
		else sumlength = sumlength + txnlength;
	if last.id then avelength = sumlength / numrbctxns;

	if last.id; keep id aveage aveirr avevol avelength;
run;

* MERGE ;
data cmv.rbctxn_summary; merge cmv.rbctxn_summary (in=a) aveage; 
	by id; 	if a; run;



*** Calculate oldest age of blood, oldest days irradiated ;

proc sort data = cmv.age_of_blood out = oldestage; by id age_of_blood; run;
data oldestage; set oldestage (rename = (age_of_blood = oldestage)); by id; if last.id; 
	label oldestage = "Age of pRBC transfused (oldest, by patient)*"; 
	keep id oldestage; 
run;

proc sort data = cmv.age_of_blood out = oldestirr; by id days_irradiated; run;
data oldestirr; set oldestirr (rename = (days_irradiated = oldestirr)); by id; if last.id; 
	label oldestirr = "Days pRBC transfused after irradiation (max, by patient)*"; 
	keep id oldestirr; 
run;

proc sort data = oldestage; by id; run;
proc sort data = oldestirr; by id; run;

* MERGE ;
data cmv.rbctxn_summary; merge cmv.rbctxn_summary (in=a) oldestage oldestirr; 
	by id; 	if a; run;



	***********************************************************************************************************************;
	data cmv.rbctxn_summary; set cmv.rbctxn_summary;
		label 	evertxn = "At least one RBC transfusion"
					numrbctxns = "Number of RBC transfusions"
					numrbcdonors = "Number of RBC donors"
					evertxn7 = "At least one RBC transfusion with blood older than 7 days"
					evertxn14 = "At least one RBC transfusion with blood older than 14 days"
					aveage = "Average age of blood by patient"
					aveirr = "Average days blood transfused after irradiation"
					avevol = "Average blood volume transfused"
		;
	run;
		
	%descriptive_stat(data_in= cmv.rbctxn_summary, data_out=rbctxn1, var= evertxn, type=bin, first_var=1, last_var=1);
	data header; length disp_overall $ 65; disp_overall = "^S={font_style=italic font_size=2}" || "median (Q1, Q3) [range], N"; run;
	%descriptive_stat(data_in= cmv.rbctxn_summary, data_out=rbctxn2, var= numrbctxns, type=cont, non_param=1, dec_places=0, first_var=1);
	%descriptive_stat(data_in= cmv.rbctxn_summary, data_out=rbctxn2, var= numrbcdonors, type=cont, non_param=1, dec_places=0, last_var=1);
	data header2; length disp_overall $ 65; disp_overall = "^S={font_style=italic font_size=2}" || "total (%)"; run; 
	%descriptive_stat(data_in= cmv.rbctxn_summary, data_out=rbctxn3, var= evertxn7, type=bin, first_var=1);
	%descriptive_stat(data_in= cmv.rbctxn_summary, data_out=rbctxn3, var= evertxn14, type=bin, last_var=1);

	* Merge tables and headers ;
	data rbctxn; set rbctxn1 header rbctxn2 header2 rbctxn3; run;

	* print ;
	%descriptive_stat(	print_rtf = 1, 
									data_out= rbctxn, 
									file= "&output./april2011abstracts/age_of_blood/rbctxn_summary.rtf", 
									title= "RBC Transfusion Summary - By Patient"
							);





*******************************************************************************************;
*******************************************************************************************;
* 	BY UNIT: (for patients who completed study)
	* # of patients by donor ;
*******************************************************************************************;

*** Calculate number of RBC donors per patient ;
proc sort data = cmv.age_of_blood; by DonorUnitID id datetransfusion; run;
data numpts; set cmv.age_of_blood;
	by DonorUnitID; if first.DonorUnitID then reset = 1; run;

data numpts; set numpts; 
	by id notsorted; retain numpts;
	if reset = 1 then numpts = 1;
	if reset ~= 1 & first.id then numpts = numpts + 1;
run;

data numpts; set numpts;
	by DonorUnitID; if last.DonorUnitID; keep DonorUnitID numpts; run;


* Number of patients for metadata table ;
data _null_; set numpts nobs=nobs;
  call symput('units',trim(left(put(nobs,8.))));
run;



	data header; length disp_overall $ 65; disp_overall = "^S={font_style=italic font_size=2}median (Q1, Q3) [range], N"; run;
	%descriptive_stat(	data_in= numpts, data_out= donors, var= numpts, 
									custom_label= "Number of patients per RBC unit", 
									type=cont, dec_places=0, first_var=1, last_var=1);

	data donors; set header donors; run;
	%descriptive_stat(	print_rtf = 1, 
									data_out= donors, 
									file= "&output./april2011abstracts/age_of_blood/rbctxn_summary2.rtf", 
									title= "RBC Transfusion Summary - By Donor"
							);





* Metadata table ;
data metadata1; length row $ 65; row = "Number of RBC transfusions"; disp_overall = &txns; run;
data metadata2; length row $ 65; row = "Number of patients with at least one RBC transfusion"; disp_overall = &pts; run;
data metadata3; length row $ 65; row = "Number of RBC donor units"; disp_overall = &units; run;
data metadata; set metadata1 metadata2 metadata3; 
	label row = '00'x disp_overall = '00'x; run;

	%descriptive_stat(	print_rtf = 1, 
									data_out= metadata, 
									file= "&output./april2011abstracts/age_of_blood/metadata.rtf", 
									title= "RBC Transfusion Summary - Number of complete records"
							);


*
*
*
*
*		PLOTS
*
*
*
*;

* Number of transfusions per patient ;

proc freq data=cmv.rbctxn_summary; 
	tables numrbctxns /nocum out = cmv.numrbctxns; run;

data cmv.numrbctxns; set cmv.numrbctxns;
	by numrbctxns; if last.numrbctxns then call symput("max", numrbctxns); run;


	goptions reset=all rotate=landscape gunit=pct device=png noborder cback=white colors=(black) ftitle=swissb ftext=swissb;
	
	symbol1 value = "dot" h=2 i=join line=1;

	axis1 	label= (f=swissb h=2.5 'RBC Units per Patient')
				value= (f=swissb h=2) 
				order= (1 to &max by 1)
				major= (h=3 w=2) 
				minor= none
	;

	axis2 	label= (a=90 f=swissb h=2.5 'Percentage of Patients') 
				value= (f=swissb h=2) 
				order= (0 to 100 by 10) 
				major= (h=1.5 w=2) 
				minor= (number=3)
	;


	goptions device=png target=png xmax=10 in  xpixels=2500  ymax=7 in ypixels=1750;
	options nodate orientation = landscape;
	ods rtf file = "&output./april2011abstracts/age_of_blood/txn_per_pt.rtf" style=journal;

		title1 f=swissb h=2.5 justify=center "Distribution of Number of RBC Transfusions Received";
		title2 f=swissb h=2 justify=center "N = &pts patients";

		proc gplot data=cmv.numrbctxns; 
			plot percent*numrbctxns / haxis=axis1 vaxis=axis2; 
		run;
	ods rtf close;




* TIME TO NEC PLOT ;

data necdates; set cmv.nec; keep id necdate dfseq; run;
proc transpose data=necdates out=necdates2;
	by id; id dfseq; var necdate; run; 
data necdates2; set necdates2 (rename = (_161 = necdate1 _162 = necdate2 _163 = necdate3)); 
	keep id necdate1 necdate2 necdate3; run;


data cmv.km; 	merge 	cmv.lbwi_demo (keep = id lbwidob) 
									cmv.endofstudy (keep = id studyleftdate in=a)
									cmv.rbctxn_summary (keep = id evertxn14 rename = (evertxn14 = strata))
									necdates2; 
						by id; if a;

	* time to event ;
	time = necdate1 - lbwidob; 
	* if event didn't occur, censor and make time to EOS ;
	if time = . then censor = 1;
		else censor = 0;
	if time = . then time = studyleftdate - lbwidob;
	* strata: never received RBC (2), received new blood only (0) and received old blood (1) ;
	if strata = . then strata = 2;

run;

proc format;
	value kmstrata 	
		0 = "Received new RBC only"
		1 = "Received old RBC"
		2 = "Never received RBC"
	;
run;

data cmv.km; set cmv.km; 
	format strata kmstrata.; 
	label time = "Day of Life";
run;

* frequencies for the title of plot ;
proc freq data = cmv.km; tables strata / out = temp; run;
data _NULL_; set temp; 
	if strata = 0 then call symput('new', compress(put(count, 2.0)));
	if strata = 1 then call symput('old', compress(put(count, 2.0)));
	if strata = 2 then call symput('none', compress(put(count, 2.0)));
run;


	goptions /*reset=all*/ rotate=landscape;

	symbol1 line=1 color=blue;
	symbol2 line=1 color=red;
	symbol3 line=1 color=green;

	ods rtf file = "&output./april2011abstracts/age_of_blood/km.rtf" style=journal;

		proc lifetest data = cmv.km plots=(s);
			time time*censor(1);
			*strata strata; 
			title1 "Time to NEC";
			*title2 "Never RBC transfused (N = &none), New RBC only (N = &new), Old RBC (N = &old)";
		run;

	ods rtf close;

/*

x "cd /ttcmv/sas/data/monthly_freeze_2011.04.01"	
x "chmod g+rw *"
x "chgrp studies *"

*/






