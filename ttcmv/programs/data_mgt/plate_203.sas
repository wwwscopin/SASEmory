/* CREATED BY: nshenvi Feb 19,2010 09:39AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  



filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_203.d01';
data cmv.MOC_NAT(label="MOC DOL 1 CMV NAT Result");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat DateBloodCollected MMDDYY8. ;  format DateBloodCollected  MMDDYY8. ;
  informat NATTestDate MMDDYY8. ;  format NATTestDate  MMDDYY8. ;
  informat Interpretation $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  DateBloodReceived
        PERLStaff $  DateBloodCollected  NATTestDate  TESTStaff $
        NATTestResult  NATCopyNumber  Interpretation $
        InterpretationYes ;


 * format DFSTATUS DFSTATv. ;
 * format NATTestResult F0094v.  ;
 * format InterpretationYes F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodReceived="1.1 Date blood sample at PERL"
        PERLStaff="PERL Staff"
        DateBloodCollected="2.1 Date blood collected"
        NATTestDate="1.1 Date NAT Test Performed"
        TESTStaff="TEST Staff"
        NATTestResult="2. NAT Test Result"
        NATCopyNumber="NAT Copy Number"
        Interpretation="Interpretation"
        InterpretationYes="Interpretation Yes No Box";
