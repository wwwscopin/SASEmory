/* CREATED BY: esrose2 Dec 20,2007 12:27PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate40.d01';
data glnd.plate40(label="Day XX Follow-Up Form, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_study_pn_stp MMDDYY8. ;  format dt_study_pn_stp  MMDDYY8. ;
  informat dt_sicu_rel MMDDYY8. ;  format dt_sicu_rel  MMDDYY8. ;
  informat dt_new_ards MMDDYY8. ;  format dt_new_ards  MMDDYY8. ;
  informat dt_pt_kg MMDDYY8. ;  format dt_pt_kg  MMDDYY8. ;
  informat dt_hosp_rel MMDDYY8. ;  format dt_hosp_rel  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  study_pn  time_study_pn_stp $
        dt_study_pn_stp  sicu  dt_sicu_rel  ards  dt_new_ards
        mech_vent  mech_vent_updt  pt_kg  dt_pt_kg  hosp  dt_hosp_rel
        nosc_infect  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format study_pn yn.  ;
  format sicu     yn.  ;
  format ards     yn.  ;
  format mech_vent yn.  ;
  format mech_vent_updt mark_box.  ;
  format hosp     yn.  ;
  format nosc_infect yn.  ;
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
        study_pn="2.1 Receiving study PN?"
        time_study_pn_stp="2.1 Time study PN stop?"
        dt_study_pn_stp="2.1 Date Study PN stop?"
        sicu="2.2 Patient in SICU?"
        dt_sicu_rel="2.2 Date SICU release?"
        ards="1.3 ARDS present?"
        dt_new_ards="2.3 Date of new ARDS"
        mech_vent="1.4 Mechanical Vent"
        mech_vent_updt="1.4 Mech Vent Update"
        pt_kg="2.5 Patient's body weight"
        dt_pt_kg="2.5 Date patient weighed"
        hosp="2.6 Patient hospitalized?"
        dt_hosp_rel="2.6 Date hops. release?"
        nosc_infect="2.1 Nosocomial infection?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
