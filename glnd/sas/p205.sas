/* CREATED BY: esrose2 Mar 21,2007 10:04AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

proc format ;


filename data1 '/dfax/glnd/sas/plate205.d01';
data glnd.plate205(label="Death Form, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_death MMDDYY8. ;  format dt_death  MMDDYY8. ;
  informat dt_event MMDDYY8. ;  format dt_event  MMDDYY8. ;
  informat other_spec $CHAR42. ;
  informat dt_autop_fax MMDDYY8. ;  format dt_autop_fax  MMDDYY8. ;
  informat dt_death_cert MMDDYY8. ;  format dt_death_cert  MMDDYY8. ;
  informat dt_prog_notes MMDDYY8. ;  format dt_prog_notes  MMDDYY8. ;
  informat dt_discharge_sum MMDDYY8. ;  format dt_discharge_sum  MMDDYY8. ;
  informat dt_coroner_rep MMDDYY8. ;  format dt_coroner_rep  MMDDYY8. ;
  informat dt_oth_path_rep MMDDYY8. ;  format dt_oth_path_rep  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  dt_death  dt_event  cause_death  ards
        sepsis  stroke  mi  pe  acute_isch  rupt_bld_ves  wnd_dehis
        sys_hemorrhage  heart_fail  mult_organ_fail  uncont_seiz  other
        other_spec $  autop_performed  autop_fax  dt_autop_fax
        death_cert  dt_death_cert  prog_notes  dt_prog_notes
        discharge_sum  dt_discharge_sum  coroner_rep  dt_coroner_rep
        oth_path_rep  dt_oth_path_rep  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format cause_death yn.  ;
  format ards     yn.  ;
  format sepsis   yn.  ;
  format stroke   yn.  ;
  format mi       yn.  ;
  format pe       yn.  ;
  format acute_isch yn.  ;
  format rupt_bld_ves yn.  ;
  format wnd_dehis yn.  ;
  format sys_hemorrhage yn.  ;
  format heart_fail yn.  ;
  format mult_organ_fail yn.  ;
  format uncont_seiz yn.  ;
  format other    yn.  ;
  format autop_performed autop_performed.  ;
  format autop_fax yn.  ;
  format death_cert yn.  ;
  format prog_notes yn.  ;
  format discharge_sum yn.  ;
  format coroner_rep yn.  ;
  format oth_path_rep yn.  ;
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
        dt_death="1.1 Date of death"
        dt_event="1.2 Date of event casued"
        cause_death="1.3 Cause of death"
        ards="1.3.1 ARDS"
        sepsis="1.3.2 Sepsis"
        stroke="1.3.3 Ischemic/hem stroke"
        mi="1.3.4 MI"
        pe="1.3.5 Pulmonary embolus"
        acute_isch="1.3.6 Acute ischemia org."
        rupt_bld_ves="1.3.7 Ruptured bld vessel"
        wnd_dehis="1.3.8 Wound dehiscence"
        sys_hemorrhage="1.3.9 Systemic hemorrhage"
        heart_fail="1.3.10 Heart failure"
        mult_organ_fail="1.3.11 Mult organ failure"
        uncont_seiz="1.3.12 Uncontrolled seiz."
        other="1.3.13 Other"
        other_spec="1.3.13 Other (specify)"
        autop_performed="1.4 Autopsy performed?"
        autop_fax="1.4 Autopsy faxed"
        dt_autop_fax="1.4 Date autopsy faxed"
        death_cert="2.1.A Death cert. submit"
        dt_death_cert="2.1.A Date death cert sub"
        prog_notes="2.1.B Prog notes submit"
        dt_prog_notes="2.1.B Date prog nts sub."
        discharge_sum="2.1.C Discharge sum. sub."
        dt_discharge_sum="2.1.C Dt discharg sum sub"
        coroner_rep="2.1.D Coroner rep submit"
        dt_coroner_rep="2.1.D Dt coroner rep sub"
        oth_path_rep="2.1.E Other pathology rep"
        dt_oth_path_rep="2.1.E Dt oth path rep sub"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

if cause_death = 99 then cause_death = .;
if autop_performed = 99 then autop_performed = . ;

proc print;


