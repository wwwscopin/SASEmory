/* CREATED BY: esrose2 Jun 18,2007 11:30AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;



filename data1 '/dfax/glnd/sas/plate45.d01';
data glnd.plate45(label="28 Day Post-Enrollment F/U, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_enrolled MMDDYY8. ;  format dt_enrolled  MMDDYY8. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat info_src_spec $CHAR36. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dt_enrolled  dfc  info_src  info_src_spec $
        died  nar_prov  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format info_src info_src.  ;
  format died     yn.  ;
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
        dt_enrolled="Date Pt Enrolled"
        dfc="Date Form Completed"
        info_src="1.1 Information source"
        info_src_spec="1.1 Info source: Other"
        died="2.1 Patient died?"
        nar_prov="Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  if info_src = 99 then info_src = .  ;
  if died     = 99 then died =.  ;
  if nar_prov = 99 then nar_prov =.  ;

proc print;
