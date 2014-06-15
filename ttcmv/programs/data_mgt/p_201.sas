/* CREATED BY: nshenvi Feb 19,2010 09:57AM using DFsas */
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
 
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_201.d01';
data cmv.LBWI_blood_NAT_result(label="LBWI DOL XX CMV NAT Results");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat DateBloodCollected MMDDYY8. ;  format DateBloodCollected  MMDDYY8. ;
  informat NATTestDate MMDDYY8. ;  format NATTestDate  MMDDYY8. ;
  informat Interpretation $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  DateBloodReceived
        PERLStaff $  DateBloodCollected  NATTestDate  TESTStaff $
        NATTestResult  NATCopyNumber  Interpretation $  IsNarrative ;
  format DFSTATUS DFSTATv. ;
  *format NATTestResult F0092v.  ;
  *format IsNarrative F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodReceived="Date blood sample at PERL"
        PERLStaff="PERL Staff"
        DateBloodCollected="Date blood collected"
        NATTestDate="Date NAT Test Performed"
        TESTStaff="TEST Staff"
        NATTestResult="NAT Test Result"
        NATCopyNumber="NAT Copy Number"
        Interpretation="Interpretation"
        IsNarrative="Is Narrative provided";
