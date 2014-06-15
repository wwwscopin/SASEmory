/* CREATED BY: nshenvi Feb 02,2011 15:31PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;



filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_215.d01';
data cmv.plate_215(label="MOC CMV IgG at Enrollment");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateBloodReceived MMDDYY8. ;  format DateBloodReceived  MMDDYY8. ;
  informat IgGTestDate MMDDYY8. ;  format IgGTestDate  MMDDYY8. ;
  informat Interpretation $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  DateBloodReceived  PERLStaff $  IgGTestDate
        IgGStaff $  IgGTestResult  Interpretation $  IsNarrative
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  run;
