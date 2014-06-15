/* CREATED BY: esrose2 Aug 28,2007 13:26PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate46.d01';
data glnd.plate46(label="Organ Function Values, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  bun  creatinine  bilirubin  sgot_ast
        sgpt_alt  alk_phos  glucose  crp  wbc  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
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
        fcbint="Form Comp. By Initials"
        dfc="Date Form Completed"
        bun="1.1 BUN"
        creatinine="1.2 Creatinine"
        bilirubin="1.3 T. bilirubin"
        sgot_ast="1.4 SGOT/AST"
        sgpt_alt="1.5 SGPT/ALT"
        alk_phos="1.6 Alk Phos"
        glucose="1.7 Glucose"
        crp="1.8 CRP"
        wbc="1.9 WBC count"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
proc print;
