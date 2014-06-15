/* CREATED BY: gcotson Sep 25,2006 10:13AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate1.d01';
data glnd.plate1(label="Initial Screening, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_screen MMDDYY8. ;  format dt_screen  MMDDYY8. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat reas_no_consent_spec $CHAR100. ;
  informat dt_writ_consent MMDDYY8. ;  format dt_writ_consent  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        prospect_id $  ptint $  fcbint $  dt_screen  dfc  in_sicu
        in_sicu_choice  require_pn  pt_elig  writ_consent
        reas_no_consent  reas_no_consent_spec $  dt_writ_consent
        apache_score  apache_id  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format in_sicu  yn.  ;
  format in_sicu_choice op.  ;
  format require_pn yn.  ;
  format pt_elig  yn.  ;
  format writ_consent yn.  ;
  format reas_no_consent nonic.  ;
  format apache_id apache.  ;
  format DFSCREEN DFSCRNv. ;
  
  array junk(7)
    in_sicu    in_sicu_choice    require_pn 
    pt_elig     writ_consent    reas_no_consent  apache_id; 
  do i=1 to 7;
     if junk(i)=99 then junk(i)=.;
  end;
  drop i;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        prospect_id="GLND Prospect No."
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        dt_screen="Date of Screening"
        dfc="Date Form Completed"
        in_sicu="1.1 In SICU due to"
        in_sicu_choice="1.1 In SICU due to choice"
        require_pn="1.2 Likely PN 7 days"
        pt_elig="1.3 Patient eligible"
        writ_consent="1.4 Written consent"
        reas_no_consent="1.4 Reason no consent"
        reas_no_consent_spec="1.4 Reason no consent spe"
        dt_writ_consent="1.4 Written consent date"
        apache_score="1.5 APACHE score"
        apache_id="1.5 APACHE ID number"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
 
 validscreen=0;
 if in_sicu=1 and require_pn=1 and pt_elig=1 and writ_consent=1 and apache_score ne . then
     validscreen=1;
 format validscreen yn.;
 label validscreen='Patients meets initial screening form criteria';
proc print;
