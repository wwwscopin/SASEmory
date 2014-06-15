/* CREATED BY: aknezev Dec 10,2010 11:24AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_100.d01';
data cmv.plate_100(label="Death/AE");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DeathDate MMDDYY8. ;  format DeathDate  MMDDYY8. ;
  informat DeathCauseText $CHAR100. ;
  informat Comments $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormComplete  DeathDate
        DeathCause  DeathContCause  DeathCauseText $  Autopsy  Comments $
        IsNarrative  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        DeathDate="Date of Death"
        DeathCause="Cause of Death"
        DeathContCause="Contributing cause of death determined"
        DeathCauseText="Contributing cause of death"
        Autopsy="Autopsy performed"
        Comments="Comments"
        IsNarrative="IsNarrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
