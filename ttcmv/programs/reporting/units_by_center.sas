%include "&include./descriptive_stat.sas";
%include "&include./monthly_toc.sas";


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




/****************************************************************************/
* MERGE JUST UNIT INFO -- UNIT LEVEL DATA ;
/****************************************************************************/
proc sort data = cmv.plate_001_bu; by DonorUnitID; 
proc sort data = cmv.plate_002_bu; by DonorUnitID;
proc sort data = cmv.plate_003_bu; by DonorUnitID;
	run;

data unit_results;
		merge 
			cmv.plate_001_bu 	(in = tracking 
												keep = DonorUnitID DCCUnitId BloodUnitType DateFirstIssued DFVALID 
												rename = (BloodUnitType = unit_type_tracking DCCUnitId = DCCUnitId_tracking DFVALID = DFVALID_tracking) )
			cmv.plate_002_bu 	(in = WBC 
												keep = DonorUnitID DCCUnitId DFVALID wbc_count leuko_failure 
												rename = (DCCUnitId = DCCUnitId_WBC DFVALID = DFVALID_WBC) )
			cmv.plate_003_bu 	(in = NAT 
												keep = DonorUnitID DCCUnitId UnitResult DFVALID 
												rename = (DCCUnitId = DCCUnitId_NAT DFVALID = DFVALID_NAT) )
		;
		by DonorUnitID;
		
		* figure out the presence of the 4 forms of interest;
		if tracking 	then has_tracking = 1; else has_tracking = 0;
		if WBC				then has_WBC = 1; else has_WBC = 0;
		if NAT 				then has_NAT = 1; else has_NAT = 0;

		has_problem = 0; * intialize ;
 		
		* any forms are missing ; 
		if (has_tracking + has_WBC + has_NAT) ~= 3 then
				has_problem = 1;
run;

data unit_results; set unit_results;

		label
			DonorUnitID = "Donor Unit ID"
			DateFirstIssued = "Date first issued to NICU"
			unit_type_tracking = "Unit type"
			has_tracking = "Tracking*record?"
			has_WBC = "WBC*results?"
			has_NAT = "NAT*results?"
			UnitResult = "CMV NAT*result"
			wbc_count = "WBC Count"
			leuko_failure = "WBC Count*result"
			DCCUnitID_tracking = "Unit ID*(tracking)"
			DCCUnitID_WBC = "Unit ID*(WBC)"
			DCCUnitID_NAT = "Unit ID*(NAT)"		
			;

		format has_tracking has_WBC has_NAT yn. 	
					UnitResult CMVNATResult.
					unit_type_tracking unit_type.;

		center = floor(DCCUnitID_tracking/10000000);
		format center center.;
		label center = "Hospital";
run;


proc sort data = unit_results; by center DateFirstIssued; run;
	data unit_results; set unit_results;
		by center;
		retain order;
		if first.center then order = 1;
		else order = order + 1;

		label order = "Donor Unit #"; 
	run;

options nodate orientation = portrait;
ods rtf file = "&output./units_by_center.rtf" style = journal bodytitle ;

		title1 "Blood Unit Listing by Hospital";

		proc print data = unit_results label noobs split = "*";
			by center;
			var order DonorUnitID DateFirstIssued unit_type_tracking has_tracking has_WBC has_NAT
					DCCUnitID_tracking DCCUnitID_WBC DCCUnitID_NAT /*UnitResult leuko_failure wbc_count*/
				  /style(data) = [just=center];
			run;

ods rtf close;

