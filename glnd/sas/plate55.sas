/* CREATED BY: bwu2 Apr 18,2011 14:42PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0012v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;

filename data1 '/dfax/glnd/sas/plate55.d01';
data glnd.plate55(label="Pt Monitoring Review, Pg 1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY10. ;  format dfc      MMDDYY10. ;
  informat dt_inpt_records MMDDYY10. ;  format dt_inpt_records MMDDYY10. ;
  informat dt_outpt_records MMDDYY10. ;  format dt_outpt_records MMDDYY10. ;
  informat dt_elig_reviewed MMDDYY10. ;  format dt_elig_reviewed MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  inpt_records  dt_inpt_records
        outpt_records  dt_outpt_records  elig_reviewed
        dt_elig_reviewed  criteria_met  criteria_met_narr
        no_aesae_src_docs  no_aesae_src_docs_narr  aesae_not_reported
        aesae_not_reported_narr  no_inf_src_docs  no_inf_src_docs_narr
        inf_not_reported  inf_not_reported_narr  prot_dev_not_reported
        prot_dev_not_reported_narr  DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format inpt_records F0012v.  ;
  format outpt_records F0012v.  ;
  format elig_reviewed F0012v.  ;
  format criteria_met F0012v.  ;
  format criteria_met_narr F0012v.  ;
  format no_aesae_src_docs F0012v.  ;
  format no_aesae_src_docs_narr F0012v.  ;
  format aesae_not_reported F0012v.  ;
  format aesae_not_reported_narr F0012v.  ;
  format no_inf_src_docs F0012v.  ;
  format no_inf_src_docs_narr F0012v.  ;
  format inf_not_reported F0012v.  ;
  format inf_not_reported_narr F0012v.  ;
  format prot_dev_not_reported F0012v.  ;
  format prot_dev_not_reported_narr F0012v.  ;
  format DFSCREEN DFSCRNv. ;
*/
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
        inpt_records="1.1 In-patient records"
        dt_inpt_records="1.1 Date of review"
        outpt_records="1.2 Out-patient records"
        dt_outpt_records="1.1 Date of review"
        elig_reviewed="2.1 Elig criteria review?"
        dt_elig_reviewed="2.1 Date of review"
        criteria_met="2.2 Elig. criteria met?"
        criteria_met_narr="2.2 Elig. criteria met?"
        no_aesae_src_docs="3.1 No AE/SAE src docs?"
        no_aesae_src_docs_narr="3.1 No AE/SAE src docs?"
        aesae_not_reported="3.2 AE/SAE not reported?"
        aesae_not_reported_narr="3.2 AE/SAE not reported?"
        no_inf_src_docs="4.1 No Infect. Src. Docs?"
        no_inf_src_docs_narr="4.1 No Infect. Src. Docs?"
        inf_not_reported="4.2 Infect. not reported?"
        inf_not_reported_narr="4.2 Infect. not reported?"
        prot_dev_not_reported="5.1 Prot dev not report?"
        prot_dev_not_reported_narr="5.1 Prot dev not report?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
