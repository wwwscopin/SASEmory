/* CREATED BY: nshenvi Mar 11,2011 14:16PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;/*
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0145v   99 = "Blank"
                 0 = "Not detected"
                 1 = "Low positive"
                 3 = "positive"
                 4 = "Indeterminate" ;
  value F0146v   99 = "Blank"
                 0 = "Not detected"
                 1 = "Low positive"
                 3 = "positive"
                 4 = "Indeterminate" ;
  value F0147v   99 = "Blank"
                 0 = "Not detected"
                 1 = "Low positive"
                 3 = "positive"
                 4 = "Indeterminate" ;
  value F0148v   99 = "Blank"
                 0 = "Not detected"
                 1 = "Low positive"
                 3 = "positive"
                 4 = "Indeterminate" ;*/run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_211.d01';
data cmv.plate_211(label="Unsch LBWI URINE NAT REsult");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat UrineCollectDate_1 MMDDYY8. ;  format UrineCollectDate_1  MMDDYY8. ;
  informat UrineTestDate_1 MMDDYY8. ;  format UrineTestDate_1  MMDDYY8. ;
  informat UrineCollectDate_2 MMDDYY8. ;  format UrineCollectDate_2  MMDDYY8. ;
  informat UrineTestDate_2 MMDDYY8. ;  format UrineTestDate_2  MMDDYY8. ;
  informat UrineCollectDate_3 MMDDYY8. ;  format UrineCollectDate_3  MMDDYY8. ;
  informat UrineTestDate_3 MMDDYY8. ;  format UrineTestDate_3  MMDDYY8. ;
  informat UrineCollectDate_4 MMDDYY8. ;  format UrineCollectDate_4  MMDDYY8. ;
  informat UrineTestDate_4 MMDDYY8. ;  format UrineTestDate_4  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  UrineCollectDate_1
        UrineTestDate_1  TESTStaff_1 $  UrineTestResult_1
        UrineCopyNumber_1  UrineCollectDate_2  UrineTestDate_2
        TESTStaff_2 $  UrineTestResult_2  UrineCopyNumber_2
        UrineCollectDate_3  UrineTestDate_3  TESTStaff_3 $
        UrineTestResult_3  UrineCopyNumber_3  UrineCollectDate_4
        UrineTestDate_4  TESTStaff_4 $  UrineTestResult_4
        UrineCopyNumber_4 ;
 /* format DFSTATUS DFSTATv. ;
  format UrineTestResult_1 F0145v.  ;
  format UrineTestResult_2 F0146v.  ;
  format UrineTestResult_3 F0147v.  ;
  format UrineTestResult_4 F0148v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        UrineCollectDate_1="UrineCollectDate 1"
        UrineTestDate_1="Urine Test Date1"
        TESTStaff_1="TEST Staff 1"
        UrineTestResult_1="Urine Test Result 1"
        UrineCopyNumber_1="Urine Copy Number1"
        UrineCollectDate_2="UrineCollectDate 2"
        UrineTestDate_2="Urine Test Date 2"
        TESTStaff_2="TEST Staff 2"
        UrineTestResult_2="Urine Test Result 2"
        UrineCopyNumber_2="Urine Copy Number 2"
        UrineCollectDate_3="UrineCollectDate 3"
        UrineTestDate_3="Urine Test Date 3"
        TESTStaff_3="TEST Staff 3"
        UrineTestResult_3="Urine Test Result 3"
        UrineCopyNumber_3="Urine Copy Number 3"
        UrineCollectDate_4="UrineCollectDate 4"
        UrineTestDate_4="Urine Test Date 4"
        TESTStaff_4="TEST Staff 4"
        UrineTestResult_4="Urine Test Result 4"
        UrineCopyNumber_4="Urine Copy Number 4";*/run;
