/* CREATED BY: esrose2 Jul 24,2008 12:26PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */

filename data1 '/dfax/glnd/sas/plate49.d01';
data glnd.plate49(label="SICU Interruption Form");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat SICU_inter_start_day_1 MMDDYY10. ;  format SICU_inter_start_day_1 MMDDYY10. ;
  informat SICU_readmit_day_2 MMDDYY10. ;  format SICU_readmit_day_2 MMDDYY10. ;
  informat SICU_inter_start_day_2 MMDDYY10. ;  format SICU_inter_start_day_2 MMDDYY10. ;
  informat SICU_readmit_day_3 MMDDYY10. ;  format SICU_readmit_day_3 MMDDYY10. ;
  informat SICU_inter_start_day_3 MMDDYY10. ;  format SICU_inter_start_day_3 MMDDYY10. ;
  informat SICU_readmit_day_4 MMDDYY10. ;  format SICU_readmit_day_4 MMDDYY10. ;
  informat SICU_inter_start_day_4 MMDDYY10. ;  format SICU_inter_start_day_4 MMDDYY10. ;
  informat SICU_readmit_day_5 MMDDYY10. ;  format SICU_readmit_day_5 MMDDYY10. ;
  informat SICU_inter_start_day_5 MMDDYY10. ;  format SICU_inter_start_day_5 MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  SICU_inter_start_day_1  SICU_readmit_day_2
        SICU_inter_start_day_2  SICU_readmit_day_3
        SICU_inter_start_day_3  SICU_readmit_day_4
        SICU_inter_start_day_4  SICU_readmit_day_5
        SICU_inter_start_day_5  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        SICU_inter_start_day_1="SICU Interrupt Start Day"
        SICU_readmit_day_2="SICU Readmit Day"
        SICU_inter_start_day_2="SICU Interrupt Start Day"
        SICU_readmit_day_3="SICU Readmit Day"
        SICU_inter_start_day_3="SICU Interrupt Start Day"
        SICU_readmit_day_4="SICU Readmit Day"
        SICU_inter_start_day_4="SICU Interrupt Start Day"
        SICU_readmit_day_5="SICU Readmit Day"
        SICU_inter_start_day_5="SICU Interrupt Start Day"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";


proc print data = glnd.plate49;
run;
