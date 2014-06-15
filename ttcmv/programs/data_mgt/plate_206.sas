/* CREATED BY: aknezev Dec 01,2010 15:16PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_206.d01';
data cmv.BM_nat(label="Breast Milk CMV NAT Result P1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat milk_date_wk1 MMDDYY8. ;  format milk_date_wk1  MMDDYY8. ;
  informat test_date_wk1 MMDDYY8. ;  format test_date_wk1  MMDDYY8. ;
  informat milk_date_wk3 MMDDYY8. ;  format milk_date_wk3  MMDDYY8. ;
  informat test_date_wk3 MMDDYY8. ;  format test_date_wk3  MMDDYY8. ;
  informat milk_date_wk4 MMDDYY8. ;  format milk_date_wk4  MMDDYY8. ;
  informat test_date_wk4 MMDDYY8. ;  format test_date_wk4  MMDDYY8. ;
  informat milk_date_d34 MMDDYY8. ;  format milk_date_d34  MMDDYY8. ;
  informat test_date_d34 MMDDYY8. ;  format test_date_d34  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  milk_date_wk1
        test_date_wk1  test_person_wk1 $  NATResult_wk1  NATCopy_wk1
        milk_date_wk3  test_date_wk3  test_person_wk3 $  NATResult_wk3
        NATCopy_wk3  milk_date_wk4  test_date_wk4  test_person_wk4 $
        NATResult_wk4  NATCopy_wk4  milk_date_d34  test_date_d34
        test_person_d34 $  NATResult_d34  NATCopy_d34  DFSCREEN
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
        DateFormCompl="Date form Completed by is Required"
        milk_date_wk1="milk_date_wk1"
        test_date_wk1="test_date_wk1"
        test_person_wk1="test_person_wk1"
        NATResult_wk1="1. Week 1 NAT Test result"
        NATCopy_wk1="1.week 1 NAT Test Result"
        milk_date_wk3="milk_date_wk3"
        test_date_wk3="test_date_wk3"
        test_person_wk3="test_person_wk3"
        NATResult_wk3="3. Week 3 NAT Test result"
        NATCopy_wk3="3. Week 3 NAT Test Result"
        milk_date_wk4="milk_date_wk4"
        test_date_wk4="test_date_wk4"
        test_person_wk4="test_person_wk4"
        NATResult_wk4="3. week 4 CMV NAT Test Result"
        NATCopy_wk4="3. Week 4 NAT Copy Number"
        milk_date_d34="milk_date_d34"
        test_date_d34="test_date_d34"
        test_person_d34="test_person_d34"
        NATResult_d34="5.Day 34-40 NAT Test Result"
        NATCopy_d34="4. Day 34-40 NAT Copy Number"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
