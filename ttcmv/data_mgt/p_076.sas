/* CREATED BY: nshenvi Nov 22,2010 14:19PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  /*value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;*/

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_076.d01';
data cmv.bpd(label="BPD");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat PneuthoraxDate MMDDYY8. ;  format PneuthoraxDate  MMDDYY8. ;
  informat PulHemorrhageDate MMDDYY8. ;  format PulHemorrhageDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  IsOxygenDOL28  oxygen_at_36  PercentOxygen
        require_ppv  resp_distress  req_ppv  Surfactant  Pneumothorax
        PneuthoraxDate  PulHemorrhage  PulHemorrhageDate  MedsReceived ;
  /*format DFSTATUS DFSTATv. ;
  format IsOxygenDOL28 F0002v.  ;
  format oxygen_at_36 F0002v.  ;
  format require_ppv F0002v.  ;
  format resp_distress F0002v.  ;
  format req_ppv  F0002v.  ;
  format Surfactant F0002v.  ;
  format Pneumothorax F0002v.  ;
  format PulHemorrhage F0002v.  ;
  format MedsReceived F0002v.  ;*/
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        IsOxygenDOL28="1.2. LBWI require oxygen within 28 days"
        oxygen_at_36="2. Does the LBWI currently (at 36 week"
        PercentOxygen="1.2 Percent Oxygen"
        require_ppv="3. Require PPV or NCPAP"
        resp_distress="2.1. Respiratory distress in first 24"
        req_ppv="2.2. Require PPV"
        Surfactant="2.3 LBWI Receive Surfactant"
        Pneumothorax="4. LBWI have Pneumothorax?"
        PneuthoraxDate="2.4. Pneuthorax Date"
        PulHemorrhage="4.Pumonary lHemorrhage"
        PulHemorrhageDate="2.5 Pul Hemorrhage Date"
        MedsReceived="3.1 Meds Received to treat BPD";
run;
