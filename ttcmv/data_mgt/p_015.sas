/* CREATED BY: aknezev Feb 11,2010 13:32PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_015.d01';

data cmv.plate_015(label="LBWI Day XX Medical Review and Lab Results Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat AnthroMeasureDate MMDDYY8. ;  format AnthroMeasureDate  MMDDYY8. ;
  informat HeightDate MMDDYY8. ;  format HeightDate  MMDDYY8. ;
  informat WeightDate MMDDYY8. ;  format WeightDate  MMDDYY8. ;
  informat HeadDate MMDDYY8. ;  format HeadDate  MMDDYY8. ;
  informat BloodCollectDate MMDDYY8. ;  format BloodCollectDate  MMDDYY8. ;
  informat WBCDate  MMDDYY8. ;  format WBCDate   MMDDYY8. ;
  informat PltDate  MMDDYY8. ;  format PltDate   MMDDYY8. ;
  informat HctDate  MMDDYY8. ;  format HctDate   MMDDYY8. ;
  informat HbDate   MMDDYY8. ;  format HbDate    MMDDYY8. ;
  informat NeutroDate MMDDYY8. ;  format NeutroDate  MMDDYY8. ;
  informat LymphoDate MMDDYY8. ;  format LymphoDate  MMDDYY8. ;
  informat ALTDate  MMDDYY8. ;  format ALTDate   MMDDYY8. ;
  informat ASTDate  MMDDYY8. ;  format ASTDate   MMDDYY8. ;
  informat AlbuminDate MMDDYY8. ;  format AlbuminDate  MMDDYY8. ;
  informat TBiliDate MMDDYY8. ;  format TBiliDate  MMDDYY8. ;
  informat DBiliDate MMDDYY8. ;  format DBiliDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormComplete
        AnthroMeasureDate  HtLength  HeightDate  Weight  WeightDate
        HeadCircum  HeadDate  BloodCollectDate  WBC  WBCDate  Platelet
        PltDate  Hct  HctDate  Hb  HbDate  AbsNeutrophil  NeutroDate
        Lympho  LymphoDate  ALT  ALTDate  AST  ASTDate  Albumin
        AlbuminDate  TotalBilirubin  TBiliDate  DirectBilirubin
        DBiliDate  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format DFSCREEN DFSCRNv. ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="Date form completed"
        AnthroMeasureDate="1.1 Anthropometric Measure Date"
        HtLength="1.1 Height/Length"
        HeightDate="Date Height /Length Measured"
        Weight="1.2 Weight"
        WeightDate="Date Weight Measured"
        HeadCircum="1.3 Head Circumference"
        HeadDate="Date Head Circum Measured"
        BloodCollectDate="2.Blood Collection Date"
        WBC="2.4 WBC"
        WBCDate="Date WBC Measured"
        Platelet="2.5 Platelet count"
        PltDate="Date Plt Measured"
        Hct="2.6 Hematocrit"
        HctDate="Date Hct Measured"
        Hb="2.7 Hemoglobin"
        HbDate="Date Hb Measured"
        AbsNeutrophil="2.8 Absolute Neutrophil"
        NeutroDate="Date Neutro Measured"
        Lympho="2.9 Lymphocytes"
        LymphoDate="Date Lympho Measured"
        ALT="2.10 ALT"
        ALTDate="Date ALT Measured"
        AST="2.11. AST"
        ASTDate="Date AST Measured"
        Albumin="2.12. Albumin"
        AlbuminDate="Date Albumin Measured"
        TotalBilirubin="2.13. Total Bilirubin"
        TBiliDate="Date TBili Measured"
        DirectBilirubin="2.14. Direct Bilirubin"
        DBiliDate="Date DBili Measured"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
		
run;

proc print data = cmv.plate_015;
run;
