/* CREATED BY: aknezev Feb 16,2010 09:36AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_005.d01';
data cmv.plate_005(label="LBWI Demographic P1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat LBWIDOB  MMDDYY8. ;  format LBWIDOB   MMDDYY8. ;
  informat NICUAdmitDate MMDDYY8. ;  format NICUAdmitDate  MMDDYY8. ;
  informat RaceOther $CHAR50. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormComplete  LBWIDOB
        LBWITOB $  IsOutborn  NICUAdmitDate  Gender  IsHispanic  race
        RaceOther $  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        DateFormComplete="Date Form Complete is required"
        LBWIDOB="LBWI DOB"
        LBWITOB="LBWI Time of Birth"
        IsOutborn="Is infant Outborn"
        NICUAdmitDate="NICU Admit Date"
        Gender="LBWI Gender"
        IsHispanic="Is LBWI Hispanic"
        race="LBWI Race"
        RaceOther="LBWI Race Other"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
