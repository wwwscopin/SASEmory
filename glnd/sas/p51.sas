/* CREATED BY: esrose2 Feb 26,2009 14:31PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */

filename data1 '/dfax/glnd/sas/plate51.d01';
data glnd.plate51(label="Lost to Follow-Up Form, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY10. ;  format dfc      MMDDYY10. ;
  informat dt_last_cont MMDDYY10. ;  format dt_last_cont MMDDYY10. ;
  informat dt_wdraw_cons MMDDYY10. ;  format dt_wdraw_cons MMDDYY10. ;
  informat dt_cont_re_est MMDDYY10. ;  format dt_cont_re_est MMDDYY10. ;
  informat invest_name $CHAR60. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  lost_fup  dt_last_cont  wdraw_cons
        dt_wdraw_cons  cont_re_est  dt_cont_re_est  nar_prov
        invest_name $  invest_sig  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format lost_fup yn.  ;
  format wdraw_cons yn.  ;
  format cont_re_est yn.  ;
  format nar_prov yn.  ;
  format invest_sig yn.  ;
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
        lost_fup="1.1 Patient lost to f-up?"
        dt_last_cont="1.2 Date of last contact"
        wdraw_cons="2.1 Pt withdraw consent?"
        dt_wdraw_cons="2.2 Date withdraw consent"
        cont_re_est="3.1 Contact re-est.?"
        dt_cont_re_est="3.2 Date contact re-est."
        nar_prov="Narrative provided"
        invest_name="Investigator Name"
        invest_sig="Investigator Signature"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
        
  if lost_fup = 99 then lost_fup = .  ;
  if wdraw_cons = 99  then wdraw_cons = .  ;
  if cont_re_est = 99  then cont_re_est = .  ;
  if nar_prov = 99  then nar_prov = .  ;
  if invest_sig = 99  then invest_sig = .  ;
run;

proc print data = glnd.plate51;

run;
