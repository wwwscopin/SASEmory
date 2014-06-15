/* CREATED BY: gcotson Oct 21,2010 11:04AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */



filename data1 '/dfax/glnd/sas/plate242.d01';
data glnd.plate242(label="Mortality Review, Page 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat cont_cause_1_desc $CHAR100. ;
  informat cont_cause_1_icd9 $CHAR40. ;
  informat cont_cause_2_desc $CHAR100. ;
  informat cont_cause_2_icd9 $CHAR40. ;
  informat cont_cause_3_desc $CHAR100. ;
  informat cont_cause_3_icd9 $CHAR40. ;
  informat cont_cause_4_desc $CHAR100. ;
  informat cont_cause_4_icd9 $CHAR40. ;
  informat cont_cause_5_desc $CHAR100. ;
  informat cont_cause_5_icd9 $CHAR40. ;
  informat cont_cause_6_desc $CHAR100. ;
  informat cont_cause_6_icd9 $CHAR40. ;
  informat cont_cause_7_desc $CHAR100. ;
  informat cont_cause_7_icd9 $CHAR40. ;
  informat cont_cause_8_desc $CHAR100. ;
  informat cont_cause_8_icd9 $CHAR40. ;
  informat cont_cause_9_desc $CHAR100. ;
  informat cont_cause_9_icd9 $CHAR40. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  maskedid  cont_cause_1_desc $  cont_cause_1_icd9 $
        cont_cause_1_rel  cont_cause_2_desc $  cont_cause_2_icd9 $
        cont_cause_2_rel  cont_cause_3_desc $  cont_cause_3_icd9 $
        cont_cause_3_rel  cont_cause_4_desc $  cont_cause_4_icd9 $
        cont_cause_4_rel  cont_cause_5_desc $  cont_cause_5_icd9 $
        cont_cause_5_rel  cont_cause_6_desc $  cont_cause_6_icd9 $
        cont_cause_6_rel  cont_cause_7_desc $  cont_cause_7_icd9 $
        cont_cause_7_rel  cont_cause_8_desc $  cont_cause_8_icd9 $
        cont_cause_8_rel  cont_cause_9_desc $  cont_cause_9_icd9 $
        cont_cause_9_rel  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
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
        cont_cause_1_desc="Contributg cause 1 desc"
        cont_cause_1_icd9="Contributg cause 1 ICD9"
        cont_cause_1_rel="Contributg cause 1 relvn"
        cont_cause_2_desc="Contributg cause 2 desc"
        cont_cause_2_icd9="Contributg cause 2 ICD9"
        cont_cause_2_rel="Contributg cause 2 relvn"
        cont_cause_3_desc="Contributg cause 3 desc"
        cont_cause_3_icd9="Contributg cause 3 ICD9"
        cont_cause_3_rel="Contributg cause 3 relvn"
        cont_cause_4_desc="Contributg cause 4 desc"
        cont_cause_4_icd9="Contributg cause 4 ICD9"
        cont_cause_4_rel="Contributg cause 4 relvn"
        cont_cause_5_desc="Contributg cause 5 desc"
        cont_cause_5_icd9="Contributg cause 5 ICD9"
        cont_cause_5_rel="Contributg cause 5 relvn"
        cont_cause_6_desc="Contributg cause 6 desc"
        cont_cause_6_icd9="Contributg cause 6 ICD9"
        cont_cause_6_rel="Contributg cause 6 relvn"
        cont_cause_7_desc="Contributg cause 7 desc"
        cont_cause_7_icd9="Contributg cause 7 ICD9"
        cont_cause_7_rel="Contributg cause 7 relvn"
        cont_cause_8_desc="Contributg cause 8 desc"
        cont_cause_8_icd9="Contributg cause 8 ICD9"
        cont_cause_8_rel="Contributg cause 8 relvn"
        cont_cause_9_desc="Contributg cause 9 desc"
        cont_cause_9_icd9="Contributg cause 9 ICD9"
        cont_cause_9_rel="Contributg cause 9 relvn"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

proc print;
 var id dfseq;