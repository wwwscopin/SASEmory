/* CREATED BY: nshenvi Sep 23,2010 09:59AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  value QCSTATv  0 = "pending"
                 1 = "new"
                 2 = "in_report"
                 3 = "resolved_na"
                 4 = "resolved_irrelevant"
                 5 = "resolved_corrected"
                 6 = "in_sent_report" ;
  value DFQCPROB   0 = "blank"
                 1 = "missing_value"
                 2 = "illegal_value"
                 3 = "inconsistent_value"
                 4 = "illegible_value"
                 5 = "fax_noise"
                 6 = "other"
                 21 = "missing_plate"
                 22 = "overdue_visit"
                 23 = "EC_missing_plate" ;
  value DFQCRFAX   0 = "blank"
                 1 = "no"
                 2 = "yes" ;
  value DFQCUSE   0 = "blank"
                 1 = "send_to_center"
                 2 = "internal" ;

filename data1 '/dfax/ttcmv/DataFax/work/plate_511.dat';
data cmv.plate_511(label="Quality Control Notes");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFQCREPLY $CHAR500. ;
  informat DFQCNAME $CHAR150. ;
  informat DFQCVAL  $CHAR150. ;
  informat DFQCQRY  $CHAR500. ;
  informat DFQCNOTE $CHAR500. ;
  informat DFQCCRT  $CHAR34. ;
  informat DFQCMDFY $CHAR34. ;
  informat DFQCRSLV $CHAR34. ;
  input id  DFSTATUS  DFVALID  DFSEQ  DFQCFLD  DFQCCTR  DFQCRPT
        DFQCPAGE  DFQCREPLY $  DFQCNAME $  DFQCVAL $  DFQCPROB
        DFQCRFAX  DFQCQRY $  DFQCNOTE $  DFQCCRT $  DFQCMDFY $
        DFQCRSLV $  DFQCUSE ;
  format DFSTATUS QCSTATv. ;
  format DFQCPROB DFQCPROB.  ;
  format DFQCRFAX DFQCRFAX.  ;
  format DFQCUSE  DFQCUSE.  ;
  label id="QC Patient Number"
        DFSTATUS="QC Status"
        DFVALID="QC Validation Level"
        DFSEQ="QC Sequence Number"
        DFQCFLD="QC Field Number"
        DFQCCTR="QC Center Number"
        DFQCRPT="QC Report Number"
        DFQCPAGE="QC Report Page Number"
        DFQCREPLY="QC Reply"
        DFQCNAME="QC Field Description"
        DFQCVAL="QC Field Value"
        DFQCPROB="QC Problem Code"
        DFQCRFAX="QC Refax Code"
        DFQCQRY="QC Query"
        DFQCNOTE="QC Note"
        DFQCCRT="QC Creator & Date Stamp"
        DFQCMDFY="QC Modifier & Date Stamp"
        DFQCRSLV="QC Resolver & Date Stamp"
        DFQCUSE="QC Usage";
run;

