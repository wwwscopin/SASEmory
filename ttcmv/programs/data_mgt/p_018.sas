/* CREATED BY: nshenvi Feb 19,2010 11:40AM using DFsas */
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
  value F0056v   99 = "Blank"
                 19 = "<20 (19)"
                 9 = "20 -29 (9)"
                 0 = "> 30 (0)"
                 999 = "Missing" ;
  value F0057v   99 = "Blank"
                 15 = "<35"
                 8 = "35-35.5"
                 0 = ">35"
                 999 = "Missing" ;
  value F0058v   99 = "Blank"
                 0 = "No"
                 19 = "Yes"
                 999 = "Missing" ;
  value F0059v   99 = "Blank"
                 18 = "<0.1"
                 5 = "0.1 - 0.9"
                 0 = ">=1.0"
                 999 = "Missing" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;
  value F0060v   99 = "Blank"
                 16 = "< 7.1"
                 7 = "7.1 - 7.19"
                 0 = ">= 7.2"
                 999 = "Missing" ;
  value F0061v   99 = "Blank"
                 28 = "<0.3"
                 16 = "0.3-0.09"
                 5 = "1 - 2.49"
                 0 = ">=2.5"
                 999 = "Missing" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_018.d01';
data cmv.snap2(label="SNAP II LBWI Day XX");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DOLDate  MMDDYY8. ;  format DOLDate   MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  DOLDate  MeanBP  LowestTemp  Seizures  UOP
        BloodCollect  Fio2  Foi2Missing  pO2Value  pO2Missing  LowPh
        PO2FO2Ratio  SNAP2Score ;
  format DFSTATUS DFSTATv. ;
  * format MeanBP   F0056v.  ;
   * format LowestTemp F0057v.  ;
  *  format Seizures F0058v.  ;
  *  format UOP      F0059v.  ;
  *  format BloodCollect F0002v.  ;
  *  format Foi2Missing F0001v.  ;
  *  format pO2Missing F0001v.  ;
  *  format LowPh    F0060v.  ;
  *  format PO2FO2Ratio F0061v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        DOLDate="DOLDate"
        MeanBP="Mean BP"
        LowestTemp="Lowest Temp"
        Seizures="Multiple Seizures"
        UOP="UOP"
        BloodCollect="Was Blood Collected for lab testing?"
        Fio2="Fio2"
        Foi2Missing="Foi2 Missing"
        pO2Value="pO2 Value"
        pO2Missing="pO2 Missing"
        LowPh="Low serum pH"
        PO2FO2Ratio="PO2 FO2 Ratio"
        SNAP2Score="SNAP2Score";
