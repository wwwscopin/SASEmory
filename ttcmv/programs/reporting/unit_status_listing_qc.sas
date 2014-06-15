%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


* stack LBWI transfusion records for the 5 product types and stamp with the type indicated ;
	data tx_records;
		set 
			cmv.plate_031 (in = rbc)
			cmv.plate_033 (in = plt)
			cmv.plate_035 (in = ffp)
			cmv.plate_037 (in = cryo)
		;
		
			if rbc then BloodUnitType = 1;
			if plt then BloodUnitType = 4;
			if ffp then BloodUnitType = 2; 
			if cryo then BloodUnitType = 3;
	run;

* merge in the tracking, WBC, and NAT result forms ;

	proc sort data = tx_records; by DonorUnitId; run;
	proc sort data = cmv.plate_001_bu; by DonorUnitID; 
	proc sort data = cmv.plate_002_bu; by DonorUnitID;
	proc sort data = cmv.plate_003_bu; by DonorUnitID;
		run;

	data unit_status;
		merge 
			tx_records (	in = tx_record 
									keep = DFVALID id formcompletedby DonorUnitID DateTransfusion BloodUnitType
									rename = (BloodUnitType = unit_type_tx DFVALID = DFVALID_tx formcompletedby = txn_initials) 
								)
			cmv.plate_001_bu	(	in = tracking 
											keep = DFVALID formcompletedby DonorUnitID DCCUnitId BloodUnitType DateFirstIssued TransferDate
											rename = (formcompletedby = tracking_initials BloodUnitType = unit_type_tracking DCCUnitId = DCCUnitId_tracking DFVALID = DFVALID_tracking)
										)
			cmv.plate_002_bu (	in = WBC 
											keep = DFVALID DonorUnitID DCCUnitId
											rename = (DCCUnitId = DCCUnitId_WBC DFVALID = DFVALID_WBC)
										)
			cmv.plate_003_bu (	in = NAT 
											keep = DFVALID DonorUnitID DCCUnitId
											rename = (DCCUnitId = DCCUnitId_NAT DFVALID = DFVALID_NAT)
										)
		;
		by DonorUnitID;

		center = floor(DCCUnitID_tracking/10000000);
		format center center.;

		* figure out the presence of the 4 forms of interest;
		if tx_record 	then has_tx_record = 1; else has_tx_record = 0;
		if tracking 	then has_tracking = 1; else has_tracking = 0;
		if WBC		then has_WBC = 1; else has_WBC = 0;
		if NAT 		then has_NAT = 1; else has_NAT = 0;

	run;

data unit_status; set unit_status;

		label
			DonorUnitID = "Donor Unit ID*"
			center = "Hospital"
			has_tx_record = "LBWI Tx*record?"
			has_tracking = "Tracking*record?"
			has_WBC = "WBC*results?"
			has_NAT = "NAT*results?"
			txn_initials = "Tx Record*Completed By"
			tracking_initials = "Tracking Form*Completed By"
			DateTransfusion = "Date Tx"
			DateFirstIssued = "Date unit*first issued"
			unit_type_tx = "Unit type" /* *(tx rec)" */
			unit_type_tracking = "Unit type*(tracking rec)"
			DCCUnitID_tracking = "Unit ID*(tracking)"
			DCCUnitID_WBC = "Unit ID*(WBC)"
			DCCUnitID_NAT = "Unit ID*(NAT)"		
		;

		format 	has_tx_record has_tracking has_WBC has_NAT yn.
					unit_type_tx unit_type_tracking unit_type.
		;
	run;

/*** PRINT incomplete records ***/


data missing_tracking; set unit_status;
	if has_tracking = 0 & has_tx_record = 1; run;
* show donor unit only once ;
proc sort data = missing_tracking; by donorunitid datetransfusion; run;
data missing_tracking; set missing_tracking; by donorunitid; if first.donorunitid; run;
proc sort data = missing_tracking; by txn_initials id datetransfusion; run;

** remove entries with known missing segs ;
data missing_tracking; set missing_tracking; 
	if 	donorunitid = "03KW36992" | donorunitid = "03GP18175" | donorunitid = "03LJ73209" | 
			donorunitid = "03KK77778" | donorunitid = "03FZ28800" | donorunitid = "03FQ99297" |
			donorunitid = "01FP78875" | donorunitid = "12F17255" | donorunitid = "03FM59677" |
			donorunitid = "03GS89763" | donorunitid = "03GR01531" | donorunitid = "03LL78796"

	then delete;
run;



data missing_tx_record; set unit_status;
	if has_tracking = 1 & has_tx_record = 0; run;
* may be multiple records with same unit ID, only need to list unit ID once ;
proc sort data = missing_tx_record; by DonorUnitID; run;
data missing_tx_record; set missing_tx_record; by donorunitid; if first.donorunitid; run;
proc sort data = missing_tx_record; by center datefirstissued; run;



data missing_lab; set unit_status; 
	if ((unit_type_tracking = 1 | unit_type_tracking = 4) & (has_tx_record = 1 & TransferDate ~= .) & (has_WBC = 0 | has_NAT = 0))
		| ((unit_type_tracking = 2 | unit_type_tracking = 3) & (has_tx_record = 1 & TransferDate ~= .) & (has_NAT = 0)); 
	if (unit_type_tracking = 2 | unit_type_tracking = 3) then has_WBC = .;
run;
* if only missing lab results, print donor unit ID just once ;
proc sort data = missing_lab; by DonorUnitID; run;
data missing_lab; set missing_lab; by DonorUnitID; if first.DonorUnitID; run;
proc sort data = missing_lab; by DateFirstIssued center; run;

** remove entries with known missing results ;
data missing_lab; set missing_lab;
	if donorunitid = "03GJ97519" | donorunitid = "03P82553" then delete;
run;


data orphans; set unit_status;
	if (has_tx_record = 0 & has_tracking = 0) & (has_WBC = 1 | has_NAT = 1); run;



	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc.rtf" style = journal bodytitle ;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;

		title2 "List of Transfusion Records received with no corresponding Unit Tracking Form";

		proc print data = missing_tracking label split = "*" noobs;
			by txn_initials;
			var DateTransfusion id DonorUnitID unit_type_tx   
				  		/	style(data) = [just=center];
		run;

		title2 "Missing lab results";

		proc print data = missing_lab label split = "*" noobs;
			var	has_WBC has_NAT DonorUnitID DateFirstIssued unit_type_tx id /*unit_type_tracking*/ 	
					DCCUnitID_tracking	
				  		/	style(data) = [just=center];
		run;

		title2 "Orphan lab results";

		proc print data = orphans label split = "*" noobs;
			var	has_tx_record has_tracking has_WBC has_NAT	DonorUnitID DCCUnitID_WBC DCCUnitID_NAT	
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** Grady/JMS ;

data missing_tx_record_grady; set missing_tx_record; if center = 2; run;
data missing_tracking_grady; set missing_tracking; if txn_initials = "JMS"; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_grady.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record_grady label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;

		title2 "List of Transfusion Records received with no corresponding Unit Tracking Form";

		proc print data = missing_tracking_grady label split = "*" noobs;
			by txn_initials;
			var DateTransfusion id DonorUnitID unit_type_tx   
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** Midtown/LAC ;

data missing_tx_record_midtown; set missing_tx_record; if center = 1; run;
data missing_tracking_midtown; set missing_tracking; if txn_initials = "LAC"; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_midtown.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record_midtown label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;

		title2 "List of Transfusion Records received with no corresponding Unit Tracking Form";

		proc print data = missing_tracking_midtown label split = "*" noobs;
			by txn_initials;
			var DateTransfusion id DonorUnitID unit_type_tx   
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** Northside/KHG/PAM/CSH ;

data missing_tx_record_ns; set missing_tx_record; if center = 3; run;
data missing_tracking_ns; set missing_tracking; if txn_initials = "PAM" | txn_initials = "KHG" | txn_initials = "CSH"; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_ns.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record_ns label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;

		title2 "List of Transfusion Records received with no corresponding Unit Tracking Form";

		proc print data = missing_tracking_ns label split = "*" noobs;
			by txn_initials;
			var DateTransfusion id DonorUnitID unit_type_tx   
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** Egleston ;

data missing_tx_record_egleston; set missing_tx_record; if center = 4; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_egleston.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record_egleston label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;

	ods rtf close;


*** SR ;

data missing_tx_record_sr; set missing_tx_record; if center = 5; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_sr.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Unit Tracking Forms received with no corresponding Transfusion Record";

		proc print data = missing_tx_record_sr label split = "*" noobs;
			by center;
			var 	DateFirstIssued tracking_initials DonorUnitID unit_type_tracking DCCUnitId_tracking
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** MIC ;

data missing_tracking_mic; set missing_tracking; if txn_initials = "MIC"; run;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_mic.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "List of Transfusion Records received with no corresponding Unit Tracking Form";

		proc print data = missing_tracking_mic label split = "*" noobs;
			by txn_initials;
			var DateTransfusion id DonorUnitID unit_type_tx   
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;


*** Lab ;

	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing_qc_lab.rtf" style = journal bodytitle starpage=off;

		title1 "Incomplete transfusion records";
		title2 "Missing lab results";

		proc print data = missing_lab label split = "*" noobs;
			var	has_WBC has_NAT DonorUnitID DateFirstIssued unit_type_tx id /*unit_type_tracking*/ 	
					DCCUnitID_tracking	
				  		/	style(data) = [just=center];
		run;

		title2 "Orphan lab results";

		proc print data = orphans label split = "*" noobs;
			var	has_tx_record has_tracking has_WBC has_NAT	DonorUnitID DCCUnitID_WBC DCCUnitID_NAT	
				  		/	style(data) = [just=center];
		run;
	
	ods rtf close;





