/* CREATED BY: esrose2 Jul 11,2008 13:20PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate48.d01';
data glnd.plate48(label="Study PN Interruption");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat pn_inter_start_day_1 MMDDYY8. ;  format pn_inter_start_day_1  MMDDYY8. ;
  informat pn_restart_day_2 MMDDYY8. ;  format pn_restart_day_2  MMDDYY8. ;
  informat pn_inter_start_day_2 MMDDYY8. ;  format pn_inter_start_day_2  MMDDYY8. ;
  informat pn_restart_day_3 MMDDYY8. ;  format pn_restart_day_3  MMDDYY8. ;
  informat pn_inter_start_day_3 MMDDYY8. ;  format pn_inter_start_day_3  MMDDYY8. ;
  informat pn_restart_day_4 MMDDYY8. ;  format pn_restart_day_4  MMDDYY8. ;
  informat pn_inter_start_day_4 MMDDYY8. ;  format pn_inter_start_day_4  MMDDYY8. ;
  informat pn_restart_day_5 MMDDYY8. ;  format pn_restart_day_5  MMDDYY8. ;
  informat pn_inter_start_day_5 MMDDYY8. ;  format pn_inter_start_day_5  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  pn_inter_start_day_1  pn_inter_start_time_1 $
        pn_restart_day_2  pn_restart_time_2 $  pn_inter_start_day_2
        pn_inter_start_time_2 $  pn_restart_day_3  pn_restart_time_3 $
        pn_inter_start_day_3  pn_inter_start_time_3 $  pn_restart_day_4
        pn_restart_time_4 $  pn_inter_start_day_4
        pn_inter_start_time_4 $  pn_restart_day_5  pn_restart_time_5 $
        pn_inter_start_day_5  pn_inter_start_time_5 $  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
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
        pn_inter_start_day_1="PN Interruption Start Day"
        pn_inter_start_time_1="PN Inter Start Time"
        pn_restart_day_2="PN Re-start Day"
        pn_restart_time_2="PN Inter Start Time"
        pn_inter_start_day_2="PN Interruption Start Day"
        pn_inter_start_time_2="PN Inter Start Time"
        pn_restart_day_3="PN Re-start Day"
        pn_restart_time_3="PN Inter Start Time"
        pn_inter_start_day_3="PN Interruption Start Day"
        pn_inter_start_time_3="PN Inter Start Time"
        pn_restart_day_4="PN Re-start Day"
        pn_restart_time_4="PN Inter Start Time"
        pn_inter_start_day_4="PN Interruption Start Day"
        pn_inter_start_time_4="PN Inter Start Time"
        pn_restart_day_5="PN Re-start Day"
        pn_restart_time_5="PN Inter Start Time"
        pn_inter_start_day_5="PN Interruption Start Day"
        pn_inter_start_time_5="PN Inter Start Time"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
run;

proc print data = glnd.plate48;
run;
