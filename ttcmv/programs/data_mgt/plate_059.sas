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
  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_059.d01';
data cmv.nec_p3(label="NEC Pg 3/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat NECResolveDate MMDDYY8. ;  format NECResolveDate  MMDDYY8. ;
  informat Comments $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  NECResolveDate  LBWISBSyndrome  Comments $
        IsNarrative  DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format LBWISBSyndrome F0002v.  ;
  format IsNarrative F0002v.  ;
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
        NECResolveDate="5.1 NEC Resolve Date"
        LBWISBSyndrome="5.2 LBWI SB Syndrome"
        Comments="Comments"
        IsNarrative="IsNarrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
