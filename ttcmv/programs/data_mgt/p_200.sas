/* CREATED BY: nshenvi Feb 19,2010 09:51AM using DFsas */
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
  
  

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_200.d01';
data cmv.LBWI_Urine_NAT_Result(label="LBWI DOB Urine NAT Results");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat UrineCollectDate MMDDYY8. ;  format UrineCollectDate  MMDDYY8. ;
  informat UrineTestDate MMDDYY8. ;  format UrineTestDate  MMDDYY8. ;
  informat Interpretation $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  DateBloodReceived
        PERLStaff $  UrineCollectDate  UrineTestDate  TESTStaff $
        UrineTestResult  UrineCopyNumber  Interpretation $  IsNarrative ;
  format DFSTATUS DFSTATv. ;
  *format UrineTestResult F0091v.  ;
 * format IsNarrative F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodReceived="1.1 Date blood sample at PERL"
        PERLStaff="PERL Staff"
        UrineCollectDate="2.1 Date Urine Collected"
        UrineTestDate="2.2 Date Urine Performed"
        TESTStaff="TEST Staff"
        UrineTestResult="2.2 Urine Test Result"
        UrineCopyNumber="Urine Copy Number"
        Interpretation="Interpretation"
        IsNarrative="Is Narrative provided";
