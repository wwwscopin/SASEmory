/* CREATED BY: nshenvi May 24,2010 13:58PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;/*
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_205.d01';
data cmv.bmilkloc(label="Breast Milk Location");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  Box $  BoxRow $  BoxColumnFrom $  BoxColumnTo $ ;
  *format DFSTATUS DFSTATv. ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed"
        Box="Box"
        BoxRow="Box Row"
        BoxColumnFrom="BoxColumnFrom"
        BoxColumnTo="BoxColumnTo"; run;
