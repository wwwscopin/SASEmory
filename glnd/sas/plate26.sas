/* CREATED BY: esrose2 Mar 21,2007 14:05PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate26.d01';
data glnd.plate26(label="Day 3 Follow-Up Form, Pg 5/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_study_pn_stp MMDDYY8. ;  format dt_study_pn_stp  MMDDYY8. ;
  informat dt_sicu_rel MMDDYY8. ;  format dt_sicu_rel  MMDDYY8. ;
  informat dt_new_ards MMDDYY8. ;  format dt_new_ards  MMDDYY8. ;
  informat dt_pt_kg MMDDYY8. ;  format dt_pt_kg  MMDDYY8. ;
  informat dt_hosp_rel MMDDYY8. ;  format dt_hosp_rel  MMDDYY8. ;
  informat time_study_pn_stp time5.; /* Eli Added - otherwise time is stored as char */
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  study_pn  time_study_pn_stp $  dt_study_pn_stp  sicu
        dt_sicu_rel  ards  dt_new_ards  mech_vent  mech_vent_updt
        pt_kg  dt_pt_kg  hosp  dt_hosp_rel  nosc_infect  ae  sae
        concom_meds  meds_updt  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format study_pn yn.  ;
  format sicu     yn.  ;
  format ards     yn.  ;
  format mech_vent yn.  ;
  format mech_vent_updt mark_box.  ;
  format hosp     yn.  ;
  format nosc_infect yn.  ;
  format ae       yn.  ;
  format sae      yn.  ;
  format concom_meds yn.  ;
  format meds_updt mark_box.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        study_pn="4.1 Receiving study PN?"
        time_study_pn_stp="4.1 Time study PN stop?"
        dt_study_pn_stp="4.1 Date Study PN stop?"
        sicu="4.2 Patient in SICU?"
        dt_sicu_rel="4.2 Date SICU release?"
        ards="4.3 ARDS present?"
        dt_new_ards="4.3 Date of new ARDS"
        mech_vent="4.4 Mechanical Vent."
        mech_vent_updt="4.4 Mech Vent Update"
        pt_kg="4.5 Patient's body weight"
        dt_pt_kg="4.5 Date patient weighed"
        hosp="4.6 Patient hospitalized?"
        dt_hosp_rel="4.6 Date hops. release?"
        nosc_infect="5.1 Nosocomial infection?"
        ae="6.1 AE?"
        sae="6.2 SAE?"
        concom_meds="7.1 Concomitant meds"
        meds_updt="7.2 Meds form updated?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  * recode 99 as missing;
  if hosp = 99 then  hosp =.  ;
  if sicu = 99 then  sicu  =.  ;
  if ards  = 99 then ards  =.  ;
  if mech_vent = 99 then mech_vent =.  ;
  if study_pn = 99 then study_pn =.  ;
  if nosc_infect = 99 then nosc_infect =.  ;
  if ae       = 99 then ae =.  ;
  if sae      = 99 then sae =.  ;
  if concom_meds = 99 then concom_meds =.  ;
  if pt_kg = 999.9 then pt_kg= . ;

proc print data= glnd.plate26;
run;
quit;
