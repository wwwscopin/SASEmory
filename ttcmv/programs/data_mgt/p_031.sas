/* CREATED BY: aknezev May 17,2010 15:08PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_031.d01';
data cmv.plate_031(label="RBC Tx");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateTransfusion MMDDYY8. ;  format DateTransfusion  MMDDYY8. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat DateIrradiated MMDDYY8. ;  format DateIrradiated  MMDDYY8. ;
  informat DateHbHct MMDDYY8. ;  format DateHbHct  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateTransfusion  DateFormCompl
        DonorUnitId $  AliquotNum  DateIrradiated  rbc_TxStartTime $
        rbc_TxEndTime $  rbcVolumeTransfused  BodyWeight  HbHctTest
        DateHbHct  TimeHbHct $  Hct  Hb  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        DateFormCompl="Date form Completed by is Required"
        DonorUnitId="Donor Unit Id"
        AliquotNum="AliquotNum"
        DateIrradiated="2. Date Irradiated"
        rbc_TxStartTime="2.1 RBC Tx Start Time"
        rbc_TxEndTime="2.1 RBC Tx End Time"
        rbcVolumeTransfused="2.3 RBC Volume Transfused"
        BodyWeight="BodyWeight"
        HbHctTest="HbHctTest"
        DateHbHct="2.5.a Date Hb/Hct"
        TimeHbHct="2.5.b. Time Hb/Hct"
        Hct="2.5.c Hct"
        Hb="2.5.c Hb"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
