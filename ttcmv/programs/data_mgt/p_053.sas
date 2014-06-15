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
                 1 = "Yes" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_053.d01';
data cmv.sus_cmv_p3(label="Sus CMV Pg 3/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat HighASTDate MMDDYY8. ;  format HighASTDate  MMDDYY8. ;
  informat HighALTDate MMDDYY8. ;  format HighALTDate  MMDDYY8. ;
  informat HighGGTDate MMDDYY8. ;  format HighGGTDate  MMDDYY8. ;
  informat HighTBiliDate MMDDYY8. ;  format HighTBiliDate  MMDDYY8. ;
  informat HighDBiliDate MMDDYY8. ;  format HighDBiliDate  MMDDYY8. ;
  informat AbLipaseDate MMDDYY8. ;  format AbLipaseDate  MMDDYY8. ;
  informat AbChDate MMDDYY8. ;  format AbChDate  MMDDYY8. ;
  informat AbWBCDate MMDDYY8. ;  format AbWBCDate  MMDDYY8. ;
  informat AbPlateletDate MMDDYY8. ;  format AbPlateletDate  MMDDYY8. ;
  informat AHctDate MMDDYY8. ;  format AHctDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  HighAST  HighASTDate
        ASTValue  HighALT  HighALTDate  ALTValue  HighGGT  HighGGTDate
        GGTValue  HighTBili  HighTBiliDate  TBiliValue  HighDBili
        HighDBiliDate  DBiliValue  AbLipase  AbLipaseDate
        AbLipaseValue  AbCh  AbChDate  AbChValue  AbWBC  AbWBCDate
        AbWBCcount  AbPlatelet  AbPlateletDate  AbPlateletCount  AbHct
        AHctDate  AbHctCount ;
 /* format DFSTATUS DFSTATv. ;
  format HighAST  F0002v.  ;
  format HighALT  F0002v.  ;
  format HighGGT  F0002v.  ;
  format HighTBili F0002v.  ;
  format HighDBili F0002v.  ;
  format AbLipase F0002v.  ;
  format AbCh     F0002v.  ;
  format AbWBC    F0002v.  ;
  format AbPlatelet F0002v.  ;
  format AbHct    F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        HighAST="4.1. Elevated AST"
        HighASTDate="4.1a. High AST Observed Date"
        ASTValue="4. 1b.AST Value"
        HighALT="4.2. Elevated ALT"
        HighALTDate="4.2a. Elevated ALT Observed Date"
        ALTValue="4.2b. ALT Value"
        HighGGT="4.3. Elevated GGT"
        HighGGTDate="4.3a.High GGT Observed Date"
        GGTValue="4.3b.GGT Value"
        HighTBili="4.4. Elevated Total Bilirubin"
        HighTBiliDate="4.4a. High Total Bilirubin Date"
        TBiliValue="4.4b. Total Billirubin Value"
        HighDBili="4.5. Elevated Direct Bilirubin"
        HighDBiliDate="4.5a. High Direct Bilirubin Date"
        DBiliValue="4.5b. Direct Bilirubin Value"
        AbLipase="4.6. Abnormal Lipase"
        AbLipaseDate="4.6a. Abnormal Lipase Date"
        AbLipaseValue="4.6b. Abnormal Lipase Value"
        AbCh="4.7. Abnormal Cholesterol"
        AbChDate="4.7a. Abnormal Cholesterol Date"
        AbChValue="4.7b. Abnormal Cholesterol Value"
        AbWBC="4.8. Abnormal WBC count"
        AbWBCDate="4.8a.Abnormal WBC Date"
        AbWBCcount="4.8b.Abnormal WBC count"
        AbPlatelet="4.9. Abnormal Platelet count"
        AbPlateletDate="4.9a. Abnormal Platelet Date"
        AbPlateletCount="4.9b.Abnormal PlateletCount"
        AbHct="4.10. Abnormal HCT count"
        AHctDate="4.10a. Abnormal HCT Date"
        AbHctCount="4.10b.Abnormal HCT Count";
run;
