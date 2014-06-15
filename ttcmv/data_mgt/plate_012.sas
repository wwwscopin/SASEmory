/* CREATED BY: nshenvi Feb 19,2010 10:55AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_012.d01';
data cmv.plate_012 (label="SNAP Enrollment Page 3 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  MaxGlucose  MinGlucose
        MaxBicarbonate  MinBicarbonate  SerumPH  SNAP3Score
        SNAPTotalScore ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        MaxGlucose="Maximum Glucose"
        MinGlucose="Minimum Glucose"
        MaxBicarbonate="Maximum Bicarbonate"
        MinBicarbonate="Minimum Bicarbonate"
        SerumPH="Serum PH"
        SNAP3Score="SNAP Page 3 Score"
        SNAPTotalScore="SNAP (Score for Neonatal Acute Physiology)";
