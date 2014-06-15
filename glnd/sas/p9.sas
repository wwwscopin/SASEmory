/* CREATED BY: esrose2 Jun 13,2007 16:15PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate9.d01';
data glnd.plate9(label="Demographics/History Form, Pg 1/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_birth MMDDYY8. ;  format dt_birth  MMDDYY8. ;
  informat race_spec $CHAR60. ;
  informat dt_admission MMDDYY8. ;  format dt_admission  MMDDYY8. ;
  informat primary_diag_oth $CHAR40. ;
  informat dt_primary_elig_op MMDDYY8. ;  format dt_primary_elig_op  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  gender  dt_birth  hispanic  race
        race_spec $  dt_admission  days_sicu_prior  pre_op_kg
        pre_op_cm  adm_ibw  bw_loss_2mo  bw_loss_6mo  primary_diag
        primary_diag_oth $  dt_primary_elig_op  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
if gender=99 then gender=.;
if race=99 then race=.;
  format gender   gender.  ;
  format hispanic yn.  ;
  format race     race.  ;
  format primary_diag demo_diag.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        dfc="Date Form Completed"
        gender="1.1 Gender"
        dt_birth="1.2 Date of birth"
        hispanic="1.3 Hispanic or Latino?"
        race="1.4 Race"
        race_spec="1.4 Race: other (spec)"
        dt_admission="2.1 Date of admission"
        days_sicu_prior="2.2 Days SICU prior entry"
        pre_op_kg="2.3 Pre-operative weight"
        pre_op_cm="2.4 Pre-operative height"
        adm_ibw="2.5 IBW at admission"
        bw_loss_2mo="2.6 BW loss past 2 months"
        bw_loss_6mo="2.6 BW loss past 6 months"
        primary_diag="3.1 Primary diagnosis"
        primary_diag_oth="3.1 Primary diag (other)"
        dt_primary_elig_op="3.2 Date prim. elig. op."
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
proc freq;
 tables race gender;
run;
