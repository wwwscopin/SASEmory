/* CREATED BY: aknezev Dec 10,2010 11:26AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_101.d01';
data cmv.plate_101(label="SAE");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat SAEDate  MMDDYY8. ;  format SAEDate   MMDDYY8. ;
  informat section2date MMDDYY8. ;  format section2date  MMDDYY8. ;
  informat deathdate MMDDYY8. ;  format deathdate  MMDDYY8. ;
  informat DeathCause $CHAR50. ;
  informat Comments $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  SAEDate  cardio
        hemat  CNS  digestive  metabolic  renal  endocrine  musculo
        resp  urogenital  section2date  deathdate  deathcause
        DeathCause $  Autopsy  Comments $  IsNarrative  DFSCREEN
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
        DateFormCompl="Date form Completed"
        SAEDate="SAE Date"
        cardio="Body System: Cardiovascular"
        hemat="Body System: Hematologic"
        CNS="Body System: CNS"
        digestive="Body System: Digestive"
        metabolic="Body System: Metabolic"
        renal="Body System : Renal"
        endocrine="Body System: Endocrine"
        musculo="Body System: Musculoskeletal"
        resp="Body System: Respiratory"
        urogenital="Body System : Urogenital"
        section2date="section 2 date"
        deathdate="Date of Death"
        deathcause="Cause of death known"
        DeathCause="Cause of Death"
        Autopsy="Autopsy performed"
        Comments="Comments"
        IsNarrative="IsNarrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
