/* CREATED BY: aknezev Dec 01,2010 15:20PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_209.d01';
data cmv.plate_209(label="MOC-CMV Serology Result -Unsc");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat DateBloodCollected MMDDYY8. ;  format DateBloodCollected  MMDDYY8. ;
  informat ComboTestDate MMDDYY8. ;  format ComboTestDate  MMDDYY8. ;
  informat IgMTestDate MMDDYY8. ;  format IgMTestDate  MMDDYY8. ;
  informat IgGTestDate MMDDYY8. ;  format IgGTestDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  DateBloodReceived  PERLStaff $  DateBloodCollected
        ComboTestStaff $  ComboTestDate  ComboTestResult  IgMTestDate
        IgMStaff $  IgMTestResult  IgGTestDate  IgGStaff $
        IgGTestResult  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodReceived="1.1 Date blood sample at PERL"
        PERLStaff="PERL Staff"
        DateBloodCollected="Date blood collected"
        ComboTestStaff="ComboTestStaff"
        ComboTestDate="IgG/IgM Combo Test Date"
        ComboTestResult="IgG/IgM ComboTestResult"
        IgMTestDate="IgM Test Date"
        IgMStaff="IgM Staff"
        IgMTestResult="IgM Test Result"
        IgGTestDate="4.1 IgM Test Date"
        IgGStaff="IgG Staff"
        IgGTestResult="IgG Test Result"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
