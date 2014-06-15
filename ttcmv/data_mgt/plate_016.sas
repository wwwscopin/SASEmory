/* CREATED BY: nshenvi Feb 16,2010 15:25PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_016.d01';
data cmv.plate_016(label="LBWI Day XX Medical Review and Lab Results Pg 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat BUNDate  MMDDYY8. ;  format BUNDate   MMDDYY8. ;
  informat CreatDate MMDDYY8. ;  format CreatDate  MMDDYY8. ;
  informat PotassiumDate MMDDYY8. ;  format PotassiumDate  MMDDYY8. ;
  informat SodiumDate MMDDYY8. ;  format SodiumDate  MMDDYY8. ;
  informat ChlorideDate MMDDYY8. ;  format ChlorideDate  MMDDYY8. ;
  informat BicarbDate MMDDYY8. ;  format BicarbDate  MMDDYY8. ;
  informat GlucoseDate MMDDYY8. ;  format GlucoseDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  BUN  BUNDate
        Creatinine  CreatDate  Potassium  PotassiumDate  Sodium
        SodiumDate  Chloride  ChlorideDate  Bicarbonate  BicarbDate
        Glucose  GlucoseDate ;
  *format DFSTATUS DFSTATv. ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        BUN="BUN"
        BUNDate="Date BUN Measured"
        Creatinine="Creatinine"
        CreatDate="Date Creat Measured"
        Potassium="Potassium"
        PotassiumDate="Date Potassium Measured"
        Sodium="Sodium"
        SodiumDate="Date Sodium Measured"
        Chloride="Chloride"
        ChlorideDate="Date Chloride Measured"
        Bicarbonate="Bicarbonate"
        BicarbDate="Date Bicarb Measured"
        Glucose="Glucose"
        GlucoseDate="Date Glucose Measured";
