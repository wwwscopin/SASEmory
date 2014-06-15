/* CREATED BY: esrose2 Jun 18,2007 11:47AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate42.d01';
data glnd.plate42(label="30 Days Post-Study Drug Discontinuation Form, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_drug_disc MMDDYY8. ;  format dt_drug_disc  MMDDYY8. ;
  informat info_src_spec $CHAR60. ;
  informat dt_re_hosp MMDDYY8. ;  format dt_re_hosp  MMDDYY8. ;
  informat dt_sicu  MMDDYY8. ;  format dt_sicu   MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  dt_drug_disc  info_src  info_src_spec $
        died  re_hosp  dt_re_hosp  sicu  dt_sicu  ae  sae  nar_prov
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format info_src info_src.  ;
  format died     yn.  ;
  format re_hosp  yn.  ;
  format sicu     yn.  ;
  format ae       yn.  ;
  format sae      yn.  ;
  format nar_prov yn.  ;
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
        dt_drug_disc="Date Study Drug Discont."
        info_src="1.1 Information source"
        info_src_spec="1.1 Info source: Other"
        died="2.1 Patient died?"
        re_hosp="2.2 Patient Re-Hosp.?"
        dt_re_hosp="2.2 Date Re-Hosp"
        sicu="2.3 Patient in SICU?"
        dt_sicu="2.3 Date admitted SICU"
        ae="4.1 AE?"
        sae="4.2 SAE?"
        nar_prov="Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  if info_src = 99 then info_src = .  ;
  if died     = 99 then died =.  ;
  if re_hosp  = 99 then re_hosp =.  ;
  if ae = 99 then ae = .;
  if sae = 99 then sae = .;
  if sicu     = 99 then sicu =.  ;
  if nar_prov = 99 then nar_prov =.  ;

proc print;
