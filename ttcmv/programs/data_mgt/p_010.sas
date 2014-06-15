/* CREATED BY: nshenvi Sep 16,2010 16:23PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0019v   99 = "Blank"
                 0 = "<=65 (0)"
                 1 = "66 - 88 (1)"
                 3 = "81 - 100 (3)"
                 4 = "> 100 (5)"
                 999 = "Missing" ;
  value F0020v   99 = "Blank"
                 5 = "< 20 (5)"
                 3 = "20 -29 (3)"
                 1 = "30 - 35 (1)"
                 0 = ">35 (0)"
                 999 = "Missing" ;
  value F0021v   99 = "Blank"
                 0 = "< 180 (0)"
                 1 = "180-200 (1)"
                 3 = "201-250 (3)"
                 5 = ">250 (5)"
                 999 = "Missing" ;
  value F0022v   99 = "Blank"
                 5 = "< 40 (5)"
                 3 = "40 -79 (3)"
                 1 = "80 -90 (1)"
                 0 = ">90 (0)"
                 999 = "Missing" ;
  value F0023v   99 = "Blank"
                 0 = "< 60 (0)"
                 1 = "60 - 100 (1)"
                 3 = "> 100 (3)"
                 999 = "Missing" ;
  value F0024v   99 = "Blank"
                 5 = "< 33.3 (5)"
                 3 = "33.3 - 34.9 (3)"
                 1 = "35 - 35.5 (1)"
                 0 = ">35.5 (0)"
                 999 = "Missing" ;
  value F0025v   99 = "Blank"
                 0 = "None (0)"
                 1 = "Single (1)"
                 3 = "Multiple (3)"
                 999 = "Missing" ;
  value F0026v   99 = "Blank"
                 0 = "None (0)"
                 1 = "Responsive to stimulation (1)"
                 3 = "Unresponsive (3)"
                 5 = "Complete (5)"
                 999 = "Missing" ;
  value F0027v   99 = "Blank"
                 0 = "Negative (0)"
                 1 = "Positive (1)"
                 999 = "Missing" ;
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;
  value F0028v   99 = "Blank"
                 0 = "<50 (0)"
                 1 = "50 - 65 (1)"
                 3 = "66 - 90 (3)"
                 5 = "> 90 (5)"
                 999 = "Missing" ;
  value F0029v   99 = "Blank"
                 0 = "< 0.07 (0)"
                 1 = "0.-7 - 0.2 (1)"
                 3 = "0.21 - 0.4 (3)"
                 5 = ">0.4 (5)"
                 999 = "Missing" ;
  value F0030v   99 = "Blank"
                 0 = "< 66 (0)"
                 1 = "66 - 70 (1)"
                 3 = "> 70 (3)"
                 999 = "Missing" ;
  value F0031v   99 = "Blank"
                 5 = "<20 (5)"
                 3 = "20 - 29 (3)"
                 1 = "30 -35 (1)"
                 0 = "> 35 (0)"
                 999 = "Missing" ;
  value F0032v   99 = "Blank"
                 3 = "<2000 (3)"
                 1 = "2000 - 5000 (1)"
                 0 = "> 5000 (0)"
                 999 = "Missing" ;
  value F0033v   99 = "Blank"
                 5 = "<30 (5)"
                 3 = "30 - 50 (3)"
                 1 = "50 - 65 (1)"
                 0 = "> 65 (0)"
                 999 = "Missing" ;
  value F0034v   99 = "Blank"
                 5 = "<0.3(5)"
                 3 = "0.3 - 2.49 (3)"
                 1 = "2.5 - 3.5 (1)"
                 0 = "> 3.5(0)"
                 999 = "Missing" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_010.d01';
data cmv.plate_010(label="SNAP Enrollment Page 1 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DateSnapData MMDDYY8. ;  format DateSnapData  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  DateSnapData  MaxMeanBP  MinMeanBP  MaxHeartRate
        MinHeartRate  RespRate  Temp  Seizures  Apnea  StoolGuaic
        pO2Value  po2missing  PCO2  Fio2  fio2missing  OxyIndex  MaxHct
        MinHct  WBC  PO2  PO2FO2Ratio  SNAP1Score ;
  /*format DFSTATUS DFSTATv. ;
  format MaxMeanBP F0019v.  ;
  format MinMeanBP F0020v.  ;
  format MaxHeartRate F0021v.  ;
  format MinHeartRate F0022v.  ;
  format RespRate F0023v.  ;
  format Temp     F0024v.  ;
  format Seizures F0025v.  ;
  format Apnea    F0026v.  ;
  format StoolGuaic F0027v.  ;
  format po2missing F0001v.  ;
  format PCO2     F0028v.  ;
  format fio2missing F0001v.  ;
  format OxyIndex F0029v.  ;
  format MaxHct   F0030v.  ;
  format MinHct   F0031v.  ;
  format WBC      F0032v.  ;
  format PO2      F0033v.  ;
  format PO2FO2Ratio F0034v.  ;*/
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        DateSnapData="Date for SNAP Data Collected"
        MaxMeanBP="1. Maximum Mean BP"
        MinMeanBP="2. Minimum Mean BP"
        MaxHeartRate="3 Maximum Heart Rate"
        MinHeartRate="4 Minimum Heart Rate"
        RespRate="5 Respiratory Rate"
        Temp="6 Temperature"
        Seizures="7 Seizures"
        Apnea="8 Apnea"
        StoolGuaic="9 Stool Guaic"
        pO2Value="10. pO2 Value"
        po2missing="po2 missing"
        PCO2="11.PCO2"
        Fio2="12. Fio2"
        fio2missing="fio2 missing"
        /*OxyIndex="13 Oxygenation Index"*/
        MaxHct="14 Maximum Hct"
        MinHct="15 Minimum Hct"
        WBC="16 WBC"
        PO2="1.10. PO2"
        PO2FO2Ratio="1.12.PO2/ FiO2"
        SNAP1Score="SNAP1Score";
run;
