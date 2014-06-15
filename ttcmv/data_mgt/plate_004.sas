/* CREATED BY: aknezev Jul 07,2010 13:10PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_004.d01';
data cmv.plate_004(label="MOC Enrollment Blood Collection Form");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DateNATSample MMDDYY8. ;  format DateNATSample  MMDDYY8. ;
  informat DateSerologySample MMDDYY8. ;  format DateSerologySample  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  NATSample
        DateNATSample  SerologySample  DateSerologySample  DFSCREEN
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
        DateFormCompl="Date form Completed by is Required"
        NATSample="NAT Sample Y/N is required"
        DateNATSample="1. CMV NAT Blood sample date"
        SerologySample="Serology Sample Y/N is required"
        DateSerologySample="2. CMV Serology sample date"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
