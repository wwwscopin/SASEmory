/* CREATED BY: gcotson Oct 21,2010 13:59PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */



filename data1 '/dfax/glnd/sas/plate243.d01';
data glnd.plate243(label="Mortality Review, Page 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat cont_cause_10_desc $CHAR100. ;
  informat cont_cause_10_icd9 $CHAR40. ;
  informat cont_cause_11_desc $CHAR100. ;
  informat cont_cause_11_icd9 $CHAR40. ;
  informat cont_cause_12_desc $CHAR100. ;
  informat cont_cause_12_icd9 $CHAR40. ;
  informat cont_cause_13_desc $CHAR100. ;
  informat cont_cause_13_icd9 $CHAR40. ;
  informat cont_cause_14_desc $CHAR100. ;
  informat cont_cause_14_icd9 $CHAR40. ;
  informat cont_cause_15_desc $CHAR100. ;
  informat cont_cause_15_icd9 $CHAR40. ;
  informat cont_cause_addtl $CHAR500. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  maskedid  cont_cause_10_desc $  cont_cause_10_icd9 $
        cont_cause_10_rel  cont_cause_11_desc $  cont_cause_11_icd9 $
        cont_cause_11_rel  cont_cause_12_desc $  cont_cause_12_icd9 $
        cont_cause_12_rel  cont_cause_13_desc $  cont_cause_13_icd9 $
        cont_cause_13_rel  cont_cause_14_desc $  cont_cause_14_icd9 $
        cont_cause_14_rel  cont_cause_15_desc $  cont_cause_15_icd9 $
        cont_cause_15_rel  cont_cause_addtl $  withdraw_care
        DNR_ordered  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format withdraw_care   DNR_ordered yn.  ;
  if withdraw_care=99 then withdraw_care=.;
  if DNR_ordered=99 then DNR_ordered=.;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        maskedid="Masked ID No"
        cont_cause_10_desc="Contributg cause 10 desc"
        cont_cause_10_icd9="Contributg cause 10 ICD9"
        cont_cause_10_rel="Contributg cause 10 relvn"
        cont_cause_11_desc="Contributg cause 11 desc"
        cont_cause_11_icd9="Contributg cause 11 ICD9"
        cont_cause_11_rel="Contributg cause 11 relvn"
        cont_cause_12_desc="Contributg cause 12 desc"
        cont_cause_12_icd9="Contributg cause 12 ICD9"
        cont_cause_12_rel="Contributg cause 12 relvn"
        cont_cause_13_desc="Contributg cause 13 desc"
        cont_cause_13_icd9="Contributg cause 13 ICD9"
        cont_cause_13_rel="Contributg cause 13 relvn"
        cont_cause_14_desc="Contributg cause 14 desc"
        cont_cause_14_icd9="Contributg cause 14 ICD9"
        cont_cause_14_rel="Contributg cause 14 relvn"
        cont_cause_15_desc="Contributg cause 15 desc"
        cont_cause_15_icd9="Contributg cause 15 ICD9"
        cont_cause_15_rel="Contributg cause 15 relvn"
        cont_cause_addtl="Addtl contribute caus cmt"
        withdraw_care="Death from withdraw care?"
        DNR_ordered="Pt have DNR ordered?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
proc print;
 var id dfseq;