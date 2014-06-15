/* CREATED BY: nshenvi Nov 03,2010 14:32PM using DFsas */
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
                 1 = "Yes" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_023.d01';
data cmv.plate_023(label="MOC d/c blood collection");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat DateBlood MMDDYY8. ;  format DateBlood  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  IsNATBlood  DateBlood ;
  *format DFSTATUS DFSTATv. ;
  *format IsNATBlood F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        IsNATBlood="IsNATBlood"
        DateBlood="1. CMV NAT Blood collection date";
run;
