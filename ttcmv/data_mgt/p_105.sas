/* CREATED BY: nshenvi May 07,2010 12:12PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;
/*
proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value eosreason   99 = "Blank"
                 1 = "Day 90 on study"
                 2 = "Discharged home"
                 3 = "Transferred to non-study hospital"
                 4 = "Family withdrawl of consent"
                 5 = "Physician's decision" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
run;
*/
filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_105.d01';
data cmv.endofstudy(label="End of Study");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateComplete MMDDYY8. ;  format DateComplete  MMDDYY8. ;
  informat StudyLeftDate MMDDYY8. ;  format StudyLeftDate  MMDDYY8. ;
  informat comments $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateComplete  StudyLeftDate  Reason  comments $  IsNarrative ;
  *format DFSTATUS DFSTATv. ;
  *format Reason   eosreason.  ;
  *format IsNarrative F0002v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateComplete="DateFormCompleted"
        StudyLeftDate="1.1 Study Left Date"
        Reason="2. Reason LBWI left study"
        comments="comments"
        IsNarrative="IsNarrative";
run;
