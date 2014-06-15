/* CREATED BY: aknezev Jul 01,2010 13:06PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_035.d01';
data cmv.plate_035(label="FFP Tx");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateTransfusion MMDDYY8. ;  format DateTransfusion  MMDDYY8. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat DatePtPTTTest MMDDYY8. ;  format DatePtPTTTest  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateTransfusion  DateFormComplete
        DonorUnitId $  AliquotNum  ffp_TxStartTime $  ffp_TxEndTime $
        ffp_VolumeTransfused  PTPTTest  DatePtPTTTest  TimePtPTTTest $
        PT  PTT  inr  fibrinogen  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        AliquotNum="1.1 Aliquot Num"
        ffp_TxStartTime="2.1 ffp_Tx Start Time"
        ffp_TxEndTime="2.2 ffp Tx End Time"
        ffp_VolumeTransfused="2.3 ffp Volume Transfused"
        PTPTTest="2.4 PTPTTest"
        DatePtPTTTest="2.4.a. Date Pt PTTT est"
        TimePtPTTTest="Time Pt PTT Test done"
        PT="PT"
        PTT="PTT"
        inr="inr"
        fibrinogen="fibrinogen"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
