/* CREATED BY: nshenvi May 24,2010 09:48AM using DFsas */
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
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0067v   99 = "Blank"
                 1 = "Not detected"
                 2 = "Low positive"
                 4 = "Indeterminate"
                 3 = "Positive" ;
  value F0068v   99 = "Blank"
                 1 = "Not detected"
                 2 = "Low positive"
                 4 = "Indeterminate"
                 3 = "Positive" ;
  value F0069v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inconclusive" ;
  value F0070v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inconclusive" ;*/
run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_054.d01';
data cmv.sus_cmv_p4(label="Sus CMV Pg 4/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat AbHbDate MMDDYY8. ;  format AbHbDate  MMDDYY8. ;
  informat AbNeutroDate MMDDYY8. ;  format AbNeutroDate  MMDDYY8. ;
  informat AbLymphoDate MMDDYY8. ;  format AbLymphoDate  MMDDYY8. ;
  informat BloodNATTestDate MMDDYY8. ;  format BloodNATTestDate  MMDDYY8. ;
  informat UrineNATTestDate MMDDYY8. ;  format UrineNATTestDate  MMDDYY8. ;
  informat SerologyDate MMDDYY8. ;  format SerologyDate  MMDDYY8. ;
  informat UrineCultureDate MMDDYY8. ;  format UrineCultureDate  MMDDYY8. ;
  informat UrineResultsDate MMDDYY8. ;  format UrineResultsDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  AbHct  AbHbDate
        AbHbValue  AbNeutro  AbNeutroDate  AbNeutroValue  AbLympho
        AbLymphoDate  AbLymphoValue  BloodNATTest  BloodNATTestDate
        BloodNATResult  BloodNATCopyNumber  UrineNATTest
        UrineNATTestDate  UrineNATResult  UrineNATCopyNumber
        SerologyTest  SerologyDate  SerologyResult  UrineCulture
        UrineCultureDate  UrineResultsDate  UrineCultureResult ;
  /*format DFSTATUS DFSTATv. ;
  format AbHct    F0002v.  ;
  format AbNeutro F0002v.  ;
  format AbLympho F0002v.  ;
  format BloodNATTest F0002v.  ;
  format BloodNATResult F0067v.  ;
  format UrineNATTest F0002v.  ;
  format UrineNATResult F0068v.  ;
  format SerologyTest F0002v.  ;
  format SerologyResult F0069v.  ;
  format UrineCulture F0002v.  ;
  format UrineCultureResult F0070v.  ;*/
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        AbHct="4.10. Abnormal HCT"
        AbHbDate="4.10a. Abnormal Hb Date"
        AbHbValue="4.10b. Abnormal Hb Value"
        AbNeutro="4.11. Abnormal Neutro"
        AbNeutroDate="4.11a.Abnormal Neutro Date"
        AbNeutroValue="4.12b. Abnormal Neutro Value"
        AbLympho="4.13. Abnormal Lymphocytes"
        AbLymphoDate="4.13a.Abnormal Lympho Date"
        AbLymphoValue="4.13b. Abnormal Lympho Value"
        BloodNATTest="5. 1. Blood NAT Test"
        BloodNATTestDate="5.1 Blood NAT Test Date"
        BloodNATResult="5.1.b Blood NAT Result"
        BloodNATCopyNumber="Blood NAT Copy Number"
        UrineNATTest="5. 1.Urine NAT Test"
        UrineNATTestDate="5.2 Urine NAT Date"
        UrineNATResult="5.1.b Urine NAT Result"
        UrineNATCopyNumber="Urine NAT Copy Number"
        SerologyTest="5. 3.SerologyTest"
        SerologyDate="5.32 Serology Date"
        SerologyResult="2. Serology Test Result"
        UrineCulture="5. 4.Urine Culture"
        UrineCultureDate="5.4 Urine Culture Date"
        UrineResultsDate="5.4 Urine Culture Results Date"
        UrineCultureResult="4. Urine Culture Result";
