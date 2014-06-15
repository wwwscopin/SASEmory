/* CREATED BY: aknezev Mar 19,2010 15:46PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_003_bu.d01';
data cmv.plate_003_bu(label="Unit CMV NAT Results");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat TransferDate MMDDYY8. ;  format TransferDate  MMDDYY8. ;
  informat Interpretation $CHAR50. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input DCCUnitId  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        DFSEQ  FormCompletedBy $  DateFormCompl  DonorUnitId $
        TransferDate  UnitResult  NATCopyNumber  Interpretation $
        Narrative  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label DCCUnitId="DCC Unit Id"
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        DonorUnitId="Donor Unit Id"
        TransferDate="TransferDate"
        UnitResult="UnitResult"
        NATCopyNumber="NATCopyNumber"
        Interpretation="Interpretation"
        Narrative="Narrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
