/* CREATED BY: esrose2 Jun 09,2008 16:17PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate57.d01';
data glnd.plate57(label="Susp. Nosocomical Infct Adjudication, Pg 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat cult_a_org $CHAR80. ;
  informat cult_b_org $CHAR80. ;
  informat cult_c_org $CHAR80. ;
  informat unreport_inf_spec $CHAR300. ;
  informat adj_comments $CHAR600. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        infect_visitno  ptint $  cult_changes  cult_a_no  cult_a_code
        cult_a_prod  cult_a_org $  cult_b_no  cult_b_code  cult_b_prod
        cult_b_org $  cult_c_no  cult_c_code  cult_c_prod  cult_c_org $
        unreport_inf  unreport_inf_spec $  adj_comments $  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format cult_changes yn.  ;
  format cult_a_prod yn.  ;
  format cult_b_prod yn.  ;
  format cult_c_prod yn.  ;
  format unreport_inf yn.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        infect_visitno="Infection Visit No."
        ptint="Participant Initials"
        cult_changes="1.6 Changes needed?"
        cult_a_no="1.6 1st Culture #"
        cult_a_code="1.6 1st Culture Code"
        cult_a_prod="1.6 1st Culture Producer?"
        cult_a_org="1.6 1st Culture Organism"
        cult_b_no="1.6 2nd Culture Number"
        cult_b_code="1.6 2nd Culture Code"
        cult_b_prod="1.6 2nd Culture Producer?"
        cult_b_org="1.6 2nd Culture Organism"
        cult_c_no="1.6 3rd Culture Number"
        cult_c_code="1.6 3rd Culture Code"
        cult_c_prod="1.6 3rd Culture Producer?"
        cult_c_org="1.6 3rd Culture Organism"
        unreport_inf="2.1 Inf not site reported"
        unreport_inf_spec="2.2 Not site report spec"
        adj_comments="3.1 Narrative comments"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

 if cult_changes = 99 then cult_changes = .  ;
 if cult_a_prod  = 99 then cult_a_prod = .   ;
 if cult_b_prod  = 99 then cult_b_prod = .    ;
 if cult_c_prod  = 99 then cult_c_prod= .    ;
 if unreport_inf = 99 then unreport_inf= .    ;

run;

proc print data = glnd.plate57;
run;
