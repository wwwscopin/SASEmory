/* CREATED BY: nshenvi Feb 19,2010 09:47AM using DFsas */
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
 

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_204.d01';
data cmv.MOC_sero(label="MOC DOL 1 Serology Result");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat DateBloodCollected MMDDYY8. ;  format DateBloodCollected  MMDDYY8. ;
  informat ComboTestDate MMDDYY8. ;  format ComboTestDate  MMDDYY8. ;
  informat IgMTestDate MMDDYY8. ;  format IgMTestDate  MMDDYY8. ;
  informat comments $CHAR200. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  DateBloodReceived
        PERLStaff $  DateBloodCollected  ComboTestStaff $
        ComboTestDate  ComboTestResult  IgMTestDate  IgMStaff $
        IgMTestResult  comments $  InterpretationYes ;
  format DFSTATUS DFSTATv. ;
 * format ComboTestResult F0095v.  ;
  *format IgMTestResult F0096v.  ;
 * format InterpretationYes F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodReceived="Date blood sample at PERL"
        PERLStaff="PERL Staff"
        DateBloodCollected="Date blood collected"
        ComboTestStaff="ComboTestStaff"
        ComboTestDate="IgG/IgM Combo Test Date"
        ComboTestResult="IgG/IgM ComboTestResult"
        IgMTestDate="IgM Test Date"
        IgMStaff="IgM Staff"
        IgMTestResult="IgM Test Result"
        comments="comments"
        InterpretationYes="Interpretation Yes No Box";

if dfstatus = 0 then delete;
