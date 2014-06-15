/* CREATED BY: aknezev Jun 30,2010 16:44PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_001_bu.d01';
data cmv.plate_001_bu(label="Unit Tracking");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat DateDonated MMDDYY8. ;  format DateDonated  MMDDYY8. ;
  informat DateFirstIssued MMDDYY8. ;  format DateFirstIssued  MMDDYY8. ;
  informat DateIrradiated MMDDYY8. ;  format DateIrradiated  MMDDYY8. ;
  informat TransferDate MMDDYY8. ;  format TransferDate  MMDDYY8. ;
  informat UnitReceivedDate MMDDYY8. ;  format UnitReceivedDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input DCCUnitId  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        DFSEQ  DateFormComplete  FormCompletedBy $  DonorUnitId $
        BloodUnitType  DateDonated  UnitVolume  DateFirstIssued
        ABOGroup  RhGroup  DateIrradiated  Leukoreduced  Washed
        VolReduced  UnitSeroStatus  unitstorage  plt_type  TransferDate
        UnitReceivedDate  FormInitial $  DCCsignature  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  label DCCUnitId="DCC Unit Id"
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        DateFormComplete="DateFormComplete"
        FormCompletedBy="Form Completed By"
        DonorUnitId="Dono rUnit Id"
        BloodUnitType="Blood Unit Type"
        DateDonated="3.Date blood donated"
        UnitVolume="UnitVolume"
        DateFirstIssued="DateFirstIssued"
        ABOGroup="6. ABO Group"
        RhGroup="7.Rh Group"
        DateIrradiated="3.Date Irradiated"
        Leukoreduced="8. Leukoreduced"
        Washed="8. Washed"
        VolReduced="8. VolReduced"
        UnitSeroStatus="9.Unit Sero Status"
        unitstorage="10. unit storage solution"
        plt_type="11. plt_type"
        TransferDate="TransferDate"
        UnitReceivedDate="UnitReceivedDate"
        FormInitial="Section 3 Initials"
        DCCsignature="DCC signature"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
