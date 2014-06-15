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

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_057.d01';
data cmv.nec_p1(label="NEC Pg 1/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat NECDate  MMDDYY8. ;  format NECDate   MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormComplete  IsBloodStool
        IsEmesis  IsAbnDistension  NECDate  LBWIWeight  ImageNumber
        AntibioticNEC  DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format IsBloodStool F0002v.  ;
  format IsEmesis F0002v.  ;
  format IsAbnDistension F0002v.  ;
  format AntibioticNEC F0002v.  ;
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
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        IsBloodStool="1.1b. Bloody Stools"
        IsEmesis="1.1c.Emesis"
        IsAbnDistension="1.1d.Abn Distension"
        NECDate="1.1a NEC Diagnosis Date"
        LBWIWeight="1.2.LBWI Weight at diagnosisi"
        ImageNumber="2.1 Total Image Number"
        AntibioticNEC="3.1 Antibiotic treatment for NEC"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
