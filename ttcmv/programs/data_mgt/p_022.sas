/* CREATED BY: aknezev Jun 10,2010 16:25PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_022.d01';
data cmv.plate_022(label="LBWI Week XX Summary Pg 3 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat Comments $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  UnexpectAE  Comments $  IsNarrative  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        UnexpectAE="Experience unexpected SAE?"
        Comments="Comments"
        IsNarrative="Is Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
