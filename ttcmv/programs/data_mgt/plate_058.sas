/* CREATED BY: bwu2 Feb 09,2011 11:43AM using DFsas */
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
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0071v   99 = "Blank"
                 1 = "Small intestine"
                 2 = "Large intestine" ;
  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_058.d01';
data cmv.nec_p2(label="NEC Pg 2/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat LaparotomyDate MMDDYY8. ;  format LaparotomyDate  MMDDYY8. ;
  informat AbdominalDrainDate MMDDYY8. ;  format AbdominalDrainDate  MMDDYY8. ;
  informat BowelResecDate MMDDYY8. ;  format BowelResecDate  MMDDYY8. ;
  informat WoundCultureDate MMDDYY8. ;  format WoundCultureDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  LaparotomyDone  LaparotomyDate  NecBowel
        GangrenousBowel  BowelHarden  LargeIntestinePerfor
        SmallIntestinePerfor  AbdominalDrain  AbdominalDrainDate
        BowelResecDone  BowelResecDate  PortionResec  LengthResecMin
        LengthResecMax  WoundCulture  WoundCultureDate
        IsCulturePositive  CultureCode1  CultureCode2  CultureCode3
        SurgeryReqd  DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format LaparotomyDone F0002v.  ;
  format NecBowel F0002v.  ;
  format GangrenousBowel F0002v.  ;
  format BowelHarden F0002v.  ;
  format LargeIntestinePerfor F0002v.  ;
  format SmallIntestinePerfor F0002v.  ;
  format AbdominalDrain F0002v.  ;
  format BowelResecDone F0002v.  ;
  format PortionResec F0071v.  ;
  format WoundCulture F0002v.  ;
  format IsCulturePositive F0002v.  ;
  format SurgeryReqd F0002v.  ;
  format DFSCREEN DFSCRNv. ;
*/
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        LaparotomyDone="4.2 Laparotomy Done"
        LaparotomyDate="4.2a. Laparotomy Date"
        NecBowel="4.2b. Necrotic Bowel"
        GangrenousBowel="4.2c. Gangrenous Bowel"
        BowelHarden="4.2c. Bowel wall hardening"
        LargeIntestinePerfor="4.2e. Large Intestine Perforation"
        SmallIntestinePerfor="4.2f. Small Intestine Perforation"
        AbdominalDrain="4.1 Abdominal drain placed?"
        AbdominalDrainDate="4.2a.Abdominal Drain Date"
        BowelResecDone="4.3 Bowel Resection Done"
        BowelResecDate="4.3a.Bowel Resection Date"
        PortionResec="4.3b. Portion Resected"
        LengthResecMin="4.3c. Length Resected Min?"
        LengthResecMax="4.3c. Length Resected Max?"
        WoundCulture="4.3.d. Wound culture obtained?"
        WoundCultureDate="4.3di Wound Culture Date"
        IsCulturePositive="4.3dii. Was Culture Positive"
        CultureCode1="4.3dii 1. Culture Code1"
        CultureCode2="4.3dii 1. Culture Code 2"
        CultureCode3="4.3dii 1. Culture Code 3"
        SurgeryReqd="4.4. Additional Surgery Reqd"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
