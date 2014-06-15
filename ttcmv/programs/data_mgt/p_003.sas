/* CREATED BY: aknezev Jun 04,2010 11:55AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_003.d01';
data cmv.lbwi_urine_collection(label="LBWI Enrollment Urine NAT Collection Form");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateComplete MMDDYY8. ;  format DateComplete  MMDDYY8. ;
  informat UrineSampleDate MMDDYY8. ;  format UrineSampleDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateComplete  UrineSample
        UrineSampleDate  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateComplete="Date form Completed"
        UrineSample="Urine Sample Y/N required"
        UrineSampleDate="3.Date urine collected"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
