%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


proc sort data = cmv.plate_031; by DonorUnitId; run;
proc sort data = cmv.plate_001_bu; by DonorUnitId; run;		* tracking;
proc sort data = cmv.plate_002_bu; by DonorUnitId; run;		* WBC;
proc sort data = cmv.plate_003_bu; by DonorUnitId; run;		* NAT;

* stack LBWI transfusion records for the 5 product types and stamp with the type indicated ;
	data tx_records;
		set 
			cmv.plate_031 (in = rbc rename =(rbc_TxStartTime = starttime_char))
			cmv.plate_033 (in = plt rename =(plt_TxStartTime = starttime_char))
			cmv.plate_035 (in = ffp rename =(ffp_TxStartTime = starttime_char))

		;
		
		if rbc then BloodUnitType = 1;
		if plt then BloodUnitType = 4;
		if ffp then BloodUnitType = 2; 

		starttime_num = input(starttime_char, time5.);

		format starttime_num time5.;
	run;

data cmv.tx_records; set tx_records; run;

	* sort by TIME and assign transfusion number and stamp with an order variable;
		proc sort data = tx_records; by DateTransfusion starttime_num; run;

		data tx_records;
			set tx_records;
			order = _N_;
		run;

	proc print data =tx_records; run;

proc sort data = tx_records; by DonorUnitId; run;


/* CALCULATE WBC/UNIT TO DETERMINE FAILURE IN LEUKOREDUCTION */
/*************************************************************/
data cmv.plate_002_bu;
	merge cmv.plate_002_bu (in = a) cmv.plate_001_bu (keep = unitvolume); 
	if a;
run;

data cmv.plate_002_bu; set cmv.plate_002_bu;
	wbc_count = ResidualWBC * unitvolume * 1000; 
	label wbc_count = "WBC count/unit";
run;

data cmv.plate_002_bu; set cmv.plate_002_bu;
	if wbc_count > 5000000 then leuko_failure = 1; else leuko_failure = 0; 
	format leuko_failure leuko_failure.;
run;
/**********************************************************/
* merge in the tracking, WBC, and NAT result forms ;

	proc sort data = cmv.plate_001_bu; by DonorUnitID; 
	proc sort data = cmv.plate_002_bu; by DonorUnitID;
	proc sort data = cmv.plate_003_bu; by DonorUnitID;
		run;

	data unit_status;
		merge 
			tx_records (in = tx_record keep = order id DFVALID DonorUnitID DateTransfusion BloodUnitType DateTransfusion starttime_num
						rename = (BloodUnitType = unit_type_tx DFVALID = DFVALID_tx) )
			cmv.plate_001_bu (in = tracking keep = DonorUnitID DCCUnitId BloodUnitType DFVALID rename = (BloodUnitType = unit_type_tracking DCCUnitId = DCCUnitId_tracking DFVALID = DFVALID_tracking))
			cmv.plate_002_bu (in = WBC keep = DonorUnitID DCCUnitId DFVALID wbc_count leuko_failure rename = (DCCUnitId = DCCUnitId_WBC DFVALID = DFVALID_WBC) )
			cmv.plate_003_bu (in = NAT keep = DonorUnitID DCCUnitId UnitResult DFVALID rename = (DCCUnitId = DCCUnitId_NAT DFVALID = DFVALID_NAT) )
		;
		by DonorUnitID;

		center = floor(DCCUnitID_tracking/10000000);
		format center center.;
		
		length remarks $ 100;

		* figure out the presence of the 4 forms of interest;
		if tx_record 	then has_tx_record = 1; else has_tx_record = 0;
		if tracking 	then has_tracking = 1; else has_tracking = 0;
		if WBC		then has_WBC = 1; else has_WBC = 0;
		if NAT 		then has_NAT = 1; else has_NAT = 0;

		has_problem = 0; * intialize ;
 		
		* STILL TO DO: remarks!;
		remarks = ""; 	* initialize ;

			* which of the 4 forms are missing ; 
			if (has_tx_record + has_tracking + has_WBC + has_NAT) ~= 4 then do;
				has_problem = 1;

				remarks = "missing:";
				if has_tx_record = 0 then remarks = trim(remarks) || " Tx record";
				if has_tracking = 0 then remarks = trim(remarks) || ", tracking record";
				if has_WBC = 0 then remarks = trim(remarks) || ", WBC results";
				if has_NAT = 0 then remarks = trim(remarks) || ", NAT results";
			end;

			* if unit types don't match ;
			if (unit_type_tx ~= unit_type_tracking) & (has_tx_record & has_tracking) then do;
				has_problem = 1;
				remarks = trim(remarks) || "; Unit types on tx and tracking records don't match!";
			end;

	run;

* CALCULATE TXN ORDER BY PATIENT (CHRONOLOGICALLY) ;
	proc sort data = unit_status; by id DateTransfusion center; run;
	data unit_status; set unit_status;
		by id;
		retain txn_order;
		if first.id then txn_order = 1;
		else txn_order = txn_order + 1;
	run;

* CALCULATE TXN ORDER BY UNIT BY PATIENT (USE BY NOTSORTED);
	proc sort data = unit_status; by id DonorUnitID; run;
	data unit_status; set unit_status;
			by DonorUnitID notsorted;
			retain donor_order;
			if first.DonorUnitID then donor_order = 1;
			else donor_order = donor_order + 1;
	run;


data unit_status; set unit_status;

		label
			DonorUnitID = "Donor Unit ID*"
			txn_order = "Tx #*(chrono.)"
			donor_order = "Tx # (from this unit)"
			order = "Tx #*(chrono.)"
			center = "Hospital"
			has_tx_record = "LBWI Tx*record?"
			has_tracking = "Tracking*record?"
			has_WBC = "WBC*results?"
			has_NAT = "NAT*results?"
			DateTransfusion = "Date Tx"
			unit_type_tx = "Unit type" /* *(tx rec)" */
			unit_type_tracking = "Unit type*(tracking rec)"
			UnitResult = "CMV NAT*result"
			leuko_failure = "WBC Count*result"
			DCCUnitID_tracking = "Unit ID*(tracking)"
			DCCUnitID_WBC = "Unit ID*(WBC)"
			DCCUnitID_NAT = "Unit ID*(NAT)"		
			remarks = "Remarks"
			;

		format has_tx_record has_tracking has_WBC has_NAT yn. 	
					UnitResult CMVNATResult.
					unit_type_tx unit_type.;
	run;

	proc contents data = unit_status;

	run;


/*** PRINT complete and incomplete records separately. ***/


* complete records sorted by time, then donor ID number, the patient ID number;
data complete; set unit_status; if ~has_problem; run;
proc sort data = complete; by DonorUnitID DateTransfusion; run;
* only display unit results once ;
data complete; set complete; 
	by DonorUnitID;
	if ~first.DonorUnitID then 
		do; 
			unit_type_tx = .; UnitResult = .; leuko_failure = .; wbc_count=.;
		end;
run;
proc sort data = complete; by id txn_order; run;


data incomplete; set unit_status; if has_problem; run;
proc sort data = incomplete; by id; run;
data incomplete; set incomplete; order = _N_; run;


	options nodate orientation = portrait;
	ods rtf file = "&output./unit_status_listing.rtf" style = journal bodytitle ;

		title1 "Blood Unit Status";
		title2 "Complete and error-free transfusion records";

		proc print data = complete label split = "*" noobs;
			by id notsorted;

			var	txn_order DonorUnitID donor_order /*has_tx_record has_tracking has_WBC has_NAT*/	
				/*id*/ DateTransfusion center unit_type_tx /*unit_type_tracking*/ UnitResult leuko_failure wbc_count /*DCCUnitID_tracking DCCUnitID_WBC DCCUnitID_NAT*/	
				  /style(data) = [just=center];
		run;

		title2 "Incomplete transfusion records";

		proc print data = incomplete label split = "*" noobs;
			by id notsorted;

			var	order DonorUnitID DateTransfusion center unit_type_tx /*unit_type_tracking*/ has_tx_record has_tracking has_WBC has_NAT	
				/*id*/  /*UnitResult leuko_failure*/ /*DCCUnitID_tracking DCCUnitID_WBC DCCUnitID_NAT	*/
				  /style(data) = [just=center];
		run;
	
	ods rtf close;




