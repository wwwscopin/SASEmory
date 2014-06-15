/* CREATED BY: aknezev Jun 10,2010 16:20PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_020.d01';
data cmv.plate_020(label="LBWI Week XX Summary Pg 1 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat StartDate MMDDYY8. ;  format StartDate  MMDDYY8. ;
  informat EndDate  MMDDYY8. ;  format EndDate   MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  StartDate  EndDate
        DischargeStatus  TransferStatus  VentStatus  ConMedStatus
        FeedStatus  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        StartDate="Interval Start Date"
        EndDate="Interval End Date"
        DischargeStatus="Discharge Status"
        TransferStatus="LBWI Transfer Status"
        VentStatus="Vent Status"
        ConMedStatus="Con Med Status"
        FeedStatus="Feeding Status"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
