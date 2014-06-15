/* CREATED BY: aknezev Jul 01,2010 13:03PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_033.d01';
data cmv.plate_033(label="Platelet Tx");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateTransfusion MMDDYY8. ;  format DateTransfusion  MMDDYY8. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat DateIrradiated MMDDYY8. ;  format DateIrradiated  MMDDYY8. ;
  informat DatePlateletCount MMDDYY8. ;  format DatePlateletCount  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateTransfusion  DateFormComplete
        DonorUnitId $  AliquotNum  DateIrradiated  plt_TxStartTime $
        plt_TxEndTime $  plt_VolumeTransfused  PlateletCount
        DatePlateletCount  TimePlateletCount $  PlateletNum  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateTransfusion="Date Transfusion"
        DateFormComplete="DateFormComplete"
        DonorUnitId="Donor Unit Id"
        AliquotNum="Aliquot Num"
        DateIrradiated="Date Irradiated"
        plt_TxStartTime="Tx Start Time"
        plt_TxEndTime="Tx End Time"
        plt_VolumeTransfused="Volume Transfused"
        PlateletCount="Platelet Count"
        DatePlateletCount="Date Platelet Count"
        TimePlateletCount="Time Platelet Count"
        PlateletNum="Platelet Count Number"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
