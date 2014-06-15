/* moc_demo.sas
 *
 * produce tables summarizing MOC Demographic Data 
 *
 */

%include "&include./descriptive_stat.sas";
%include "&include./annual_toc.sas";

data cmv.valid_ids; set cmv.valid_ids; if id = . then delete; run;

proc sort data = cmv.moc_demo; by id;
proc sort data = cmv.lbwi_demo; by id; run;

data moc_demo; merge cmv.moc_demo (in=a) cmv.lbwi_demo (keep = id lbwidob lbwitob); by id; if a; run;

data valid_ids; set cmv.valid_ids; by moc_id; if first.moc_id; run;
data moc_demo; set moc_demo; moc_id = input(substr(put(id,7.0),1,5),5.0); run;
data moc_demo; merge moc_demo valid_ids (in=a); by moc_id; if a; run; 

/*
data completedstudylist; set cmv.completedstudylist; moc_id = input(substr(put(id,7.0),1,5),5.0); keep moc_id; run;
data completedstudylist; set completedstudylist; by moc_id; if first.moc_id; run;
data moc_demo; set moc_demo; moc_id = input(substr(put(id,7.0),1,5),5.0); run;
data moc_demo; merge moc_demo completedstudylist (in=a); by moc_id; if a; run; 
*/

data moc_demo; set moc_demo;
	format IsHispanic ROM ROM18hr yn. MOC_race race. MaritalStatus MaritalStatus. Education Education. Insurance Insurance. DeliveryMode DeliveryMode.; 

	if usealcohol = 99 then usealcohol = .;
	if ishispanic = 99 then ishispanic = .;
	if multiplebirth = 1 then singletonbirth = 0; if multiplebirth = 0 then singletonbirth = 1; if multiplebirth = 99 then singletonbirth = .;
	* new HIV variable: positive = 1, negative = 0, unknown = . ;
	if MOC_hiv = 1 then MOC_hiv2 = 0; if MOC_hiv = 2 then MOC_hiv2 = 1; if MOC_hiv = 3 then MOC_hiv2 = .; if MOC_hiv = . then MOC_hiv2 = .;

	age = round(yrdif(MOC_DOB,DateFormCompl,'ACT/ACT'));

	format lbwidob ROMdate date9.;
	lbwitob2 = input(substr(lbwitob,1,5), time.); 
	ROMtime2 = input(substr(ROMtime,1,5), time.);
	format lbwitob2 ROMtime2 hhmm.;
	priorROMhrs = (lbwidob*24*60*60 + lbwitob2) - (ROMdate*24*60*60 + ROMtime2);
	format priorROMhrs hhmm.;
	priorROMhrs2 = priorROMhrs/3600; 

	label 	age = "Age (years) - mean (sd) [min-max], N"
				ishispanic = "Hispanic ethnicity - no (%)"
				MOC_race = "Race"
				MaritalStatus = "Marital status"
				Education = "Highest education level"
				Insurance = "Medical insurance"

				usecigarettes = "Cigarette use"
				usealcohol = "Alcohol use"
				usedrugs = "Illegal drug use"
				diapercare = "Care for child/elderly adult in diapers"
				MOC_hiv2 = "HIV positive"
				prenatalvisit = "At least one prenatal visit"
				insulinpreg = "Insulin given during pregnancy"
				hypertension = "Hypertension prior to pregnancy"
				antepartumhemor = "Antepartum hemorrhage"
				antepartumhemoryes = "	Transfusion given after antepartum hemorrhage"
				ROM = "Rupture of membranes prior to delivery"

				singletonbirth = "Singleton births"
				deliverymode = "Delivery Mode"
				gravida = "Gravida - median (Q1, Q3), N"
				parity = "Parity - median (Q1, Q3), N"
				antibiotic = "Antibiotics given within 72 hrs of delivery"
				steroids = "Steriods given to accelerate maturity"
				betamethasone = "	Betamethasone"
				dexamethasone = "	Dexamethasone"
				deliverysteroidother = "	Other"
			
	        IsChorloConfirm="Confirmed clinical chorioamionotis"
	        PacentalPathology="Placental pathology performed"
	        HistoChloro="	Histologic chorioamionotis confirmed"

				lbwidob = "Date of birth"
				lbwitob2 = "Time of birth"
				ROM = "Rupture of Membranes occurred prior to delivery"
				ROMdate = "Date of ROM"	
				ROMtime2 = "Time of ROM"
				priorROMhrs2 = "	ROM prior (hours) - med (Q1, Q3), N"
				ROM18hr = "	ROM estimated > 18 hrs if time unk"
	;
run;

data cmv.moc_demo; set moc_demo; run;

options nodate orientation = portrait;


data temp; set moc_demo; if ROM = 1; run;
ods rtf file = "/ttcmv/sas/output/ROM_data.rtf" style=journal;
proc print data = temp noobs label ;
	var id ROM lbwidob lbwitob2 ROMdate ROMtime2 ROM18hr priorROMhrs;
run;
ods rtf close;


	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= age, type= cont, non_param=0, first_var= 1);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= IsHispanic, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= MOC_race, type= cat);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= MaritalStatus, type= cat);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= Education, type= cat);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary1, var= Insurance, type= cat, last_var= 1);

	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= usecigarettes, type= bin, non_param=0, first_var= 1);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= usealcohol, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= usedrugs, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= diapercare, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= MOC_hiv2, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= prenatalvisit, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= insulinpreg, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= hypertension, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= antepartumhemor, type= bin);
	*%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= antepartumhemoryes, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= ROM, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= priorROMhrs2, type= cont);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= ROM18hr, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= IsChorloConfirm, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= PacentalPathology, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary2, var= HistoChloro, type= bin, last_var=1);

	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= singletonbirth, type= bin, non_param=0, first_var= 1);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= deliverymode, type= cat);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= gravida, type= cont, non_param=1);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= parity, type= cont, non_param=1);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= antibiotic, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= steroids, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= betamethasone, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= dexamethasone, type= bin);
	%descriptive_stat(data_in= moc_demo, data_out= moc_demo_summary3, var= deliverysteroidother, type= bin, last_var= 1);



* HEADERS ;
	data header1; length row $ 120; row = "^S={font_weight=bold font_size=2}" || "Demographic factors"; run;
	data header2; length row $ 120; row = "^S={font_weight=bold font_size=2}" || "Risk Factors during pregnancy"; run;
	data header3; length row $ 120; row = "^S={font_weight=bold font_size=2}" || "Birth Data"; run;
* Merge tables and headers;
	data moc_demo_summary; set header1 moc_demo_summary1 header2 moc_demo_summary2 header3 moc_demo_summary3; run;


	* print table ;
	%descriptive_stat(print_rtf = 1, data_out= moc_demo_summary, file= "&output./monthly_internal/moc_demo_summary.rtf", title = "MOC Demographic Summary");
