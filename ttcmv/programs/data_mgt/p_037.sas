/* CREATED BY: aknezev Jul 01,2010 13:07PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_037.d01';
data cmv.plate_037(label="Cryo Tx");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateTransfusion MMDDYY8. ;  format DateTransfusion  MMDDYY8. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat DateFibrinogen MMDDYY8. ;  format DateFibrinogen  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateTransfusion  DateFormComplete
        DonorUnitId $  cryo_TxStartTime $  cryo_TxEndTime $
        cryo_VolumeTransfused  Fibrinogen  DateFibrinogen
        TimeFibrinogen $  FibrinogenLevel  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateTransfusion="DateT ransfusion"
        DateFormComplete="DateFormComplete"
        DonorUnitId="1.1 Donor Unit Id"
        cryo_TxStartTime="2.1 cryo Tx Star tTime"
        cryo_TxEndTime="2.2 cryo Tx End Time"
        cryo_VolumeTransfused="2.3 cryo Volume Transfused"
        Fibrinogen="Fibrinogen"
        DateFibrinogen="2.4.a Date Fibrinogen"
        TimeFibrinogen="2.4.a Time Fibrinogen"
        FibrinogenLevel="2.4.c Fibrinogen Level"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
