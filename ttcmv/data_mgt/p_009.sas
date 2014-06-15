/* CREATED BY: aknezev Jun 14,2010 16:06PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_009.d01';
data cmv.plate_009(label="MOC Placental Pathology");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat impression $CHAR200. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormComplete  IsChorloConfirm
        PacentalPathology  HistoChloro  impression $  IsNarrative
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        impression="impression"
        IsNarrative="Is Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
	if IsChorloConfirm = 99 then IsChorloConfirm = .;
	if PacentalPathology = 99 then PacentalPathology = .;
	if HistoChloro = 99 then HistoChloro = .;
