/* CREATED BY: aknezev May 11,2011 14:34PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_210.d01';
data cmv.plate_210(label="Unsch LBWIBlood NAT Result");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateBloodCollected_1 MMDDYY8. ;  format DateBloodCollected_1  MMDDYY8. ;
  informat NATTestDate_1 MMDDYY8. ;  format NATTestDate_1  MMDDYY8. ;
  informat DateBloodCollected_2 MMDDYY8. ;  format DateBloodCollected_2  MMDDYY8. ;
  informat NATTestDate_2 MMDDYY8. ;  format NATTestDate_2  MMDDYY8. ;
  informat DateBloodCollected_3 MMDDYY8. ;  format DateBloodCollected_3  MMDDYY8. ;
  informat NATTestDate_3 MMDDYY8. ;  format NATTestDate_3  MMDDYY8. ;
  informat DateBloodCollected_4 MMDDYY8. ;  format DateBloodCollected_4  MMDDYY8. ;
  informat NATTestDate_4 MMDDYY8. ;  format NATTestDate_4  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  DateBloodCollected_1  NATTestDate_1  TESTStaff_1 $
        NATTestResult_1  NATCopyNumber_1  DateBloodCollected_2
        NATTestDate_2  TESTStaff_2 $  NATTestResult_2  NATCopyNumber_2
        DateBloodCollected_3  NATTestDate_3  TESTStaff_3 $
        NATTestResult_3  NATCopyNumber_3  DateBloodCollected_4
        NATTestDate_4  TESTStaff_4 $  NATTestResult_4  NATCopyNumber_4
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        DateBloodCollected_1="DateBloodCollected 1"
        NATTestDate_1="NAT Test Date 1"
        TESTStaff_1="TEST Staff 1"
        NATTestResult_1="NAT Test Result 1"
        NATCopyNumber_1="NAT Copy Number 1"
        DateBloodCollected_2="DateBloodCollected 2"
        NATTestDate_2="NAT Test Date 2"
        TESTStaff_2="TEST Staff 2"
        NATTestResult_2="NAT Test Result 2"
        NATCopyNumber_2="NAT Copy Number 2"
        DateBloodCollected_3="DateBloodCollected 3"
        NATTestDate_3="NAT Test Date 3"
        TESTStaff_3="TEST Staff 3"
        NATTestResult_3="NAT Test Result 3"
        NATCopyNumber_3="NAT Copy Number 3"
        DateBloodCollected_4="DateBloodCollected 4"
        NATTestDate_4="NAT Test Date 4"
        TESTStaff_4="TEST Staff 4"
        NATTestResult_4="NAT Test Result 4"
        NATCopyNumber_4="NAT Copy Number 4"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
