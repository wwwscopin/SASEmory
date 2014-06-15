/* CREATED BY: nshenvi May 24,2010 13:32PM using DFsas */
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
  value F0115v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;
  value F0116v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;
  value F0117v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;
  value F0118v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;
  value F0119v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;
  value F0120v   1 = "EUHM"
                 2 = "Grady"
                 3 = "Northside"
                 4 = "CHOA Egleston"
                 5 = "CHOA SR" ;*/

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_110.d01';
data cmv.pdeviation(label="Transfer");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat TransferDate1 MMDDYY8. ;  format TransferDate1  MMDDYY8. ;
  informat TransferDate2 MMDDYY8. ;  format TransferDate2  MMDDYY8. ;
  informat TransferDate3 MMDDYY8. ;  format TransferDate3  MMDDYY8. ;
  informat TransferDate4 MMDDYY8. ;  format TransferDate4  MMDDYY8. ;
  informat TransferDate5 MMDDYY8. ;  format TransferDate5  MMDDYY8. ;
  informat TransferDate6 MMDDYY8. ;  format TransferDate6  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormCompl  TransferDate1  TransferHosp1  TransferDOL1
        TransferDate2  TransferHosp2  TransferDOL2  TransferDate3
        TransferHosp3  TransferDOL3  TransferDate4  TransferHosp4
        TransferDOL4  TransferDate5  TransferHosp5  TransferDOL5
        TransferDate6  TransferHosp6  TransferDOL6  transfer1email $
        transfer2email $  transfer3email $  transfer4email $
        transfer5email $  transfer6email $ ;
  /*format DFSTATUS DFSTATv. ;
  format TransferHosp1 F0115v.  ;
  format TransferHosp2 F0116v.  ;
  format TransferHosp3 F0117v.  ;
  format TransferHosp4 F0118v.  ;
  format TransferHosp5 F0119v.  ;
  format TransferHosp6 F0120v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        TransferDate1="1. Transfer Date"
        TransferHosp1="1b. Transferred Hosp"
        TransferDOL1="1c. Transfer DOL"
        TransferDate2="2. Transfer Date"
        TransferHosp2="2b. Transferred Hosp"
        TransferDOL2="2c. Transfer DOL"
        TransferDate3="3. Transfer Date"
        TransferHosp3="3b. Transferred Hosp"
        TransferDOL3="3c. Transfer DOL"
        TransferDate4="4. Transfer Date"
        TransferHosp4="4b. Transferred Hosp"
        TransferDOL4="4c. Transfer DOL"
        TransferDate5="5. Transfer Date"
        TransferHosp5="5b. Transferred Hosp"
        TransferDOL5="5c. Transfer DOL"
        TransferDate6="6. Transfer Date"
        TransferHosp6="6b. Transferred Hosp"
        TransferDOL6="6c. Transfer DOL"
        transfer1email="transfer 1 email"
        transfer2email="transfer 2 email"
        transfer3email="transfer 3 email"
        transfer4email="transfer 4 email"
        transfer5email="transfer 5 email"
        transfer6email="transfer 6 email"; run;
