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
  value F0063v   99 = "Blank"
                 1 = "MRI"
                 2 = "CT Scan"
                 3 = "Ultrasound"
                 4 = "X-ray" ;
  value F0064v   99 = "Blank"
                 1 = "MRI"
                 2 = "CT Scan"
                 3 = "Ultrasound"
                 4 = "X-ray" ;
  value F0065v   99 = "Blank"
                 1 = "MRI"
                 2 = "CT Scan"
                 3 = "Ultrasound"
                 4 = "X-ray" ;
  value F0066v   99 = "Blank"
                 1 = "MRI"
                 2 = "CT Scan"
                 3 = "Ultrasound"
                 4 = "X-ray" ;
*/ run;
filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_052.d01';
data cmv.sus_cmv_p2(label="Sus CMV Pg 2/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat AbBrainParenDate MMDDYY8. ;  format AbBrainParenDate  MMDDYY8. ;
  informat BrainCalcDate MMDDYY8. ;  format BrainCalcDate  MMDDYY8. ;
  informat HydrocephalusDate MMDDYY8. ;  format HydrocephalusDate  MMDDYY8. ;
  informat PneumonitisDate MMDDYY8. ;  format PneumonitisDate  MMDDYY8. ;
  informat Comments $CHAR100. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  AbBrainParenchyma
        AbBrainParenDate  AbBrainParenImage  BrainCalc  BrainCalcDate
        BrainCalcImage  Hydrocephalus  HydrocephalusDate
        HydrocephalusImage  Pneumonitis  PneumonitisDate
        PneumonitisImage  Comments $  IsNarrative ;
  /*format DFSTATUS DFSTATv. ;
  format AbBrainParenchyma F0002v.  ;
  format AbBrainParenImage F0063v.  ;
  format BrainCalc F0002v.  ;
  format BrainCalcImage F0064v.  ;
  format Hydrocephalus F0002v.  ;
  format HydrocephalusImage F0065v.  ;
  format Pneumonitis F0002v.  ;
  format PneumonitisImage F0066v.  ;
  format IsNarrative F0002v.  ;*/
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        AbBrainParenchyma="3.1. Abnormal Brain Parenchyma"
        AbBrainParenDate="3.1a Abnormal Brain Paren Date"
        AbBrainParenImage="3.1b. Brain parenchyme image"
        BrainCalc="3.2. Brain Calcification"
        BrainCalcDate="3.2.a Brain Calcification Date"
        BrainCalcImage="3.2 b. Brain calcification image"
        Hydrocephalus="3.3. Hydrocephalus"
        HydrocephalusDate="3.3a Hydrocephalus Date"
        HydrocephalusImage="3.3b. Hydrocephalus image"
        Pneumonitis="3.4. Pneumonitis"
        PneumonitisDate="3.4 a. Pneumonitis Date"
        PneumonitisImage="3.4 b. Pneumonitis image"
        Comments="Comments"
        IsNarrative="Is Narrative provided";
run;
