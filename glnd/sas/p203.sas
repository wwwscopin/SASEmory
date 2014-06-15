/* CREATED BY: esrose2 Jan 17,2007 14:18PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate203.d01';
data glnd.plate203(label="Serious Adverse Event Form, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_sae_onset MMDDYY8. ;  format dt_sae_onset  MMDDYY8. ;
  informat dt_report_irb MMDDYY8. ;  format dt_report_irb  MMDDYY8. ;
  informat dt_sae_resolve MMDDYY8. ;  format dt_sae_resolve  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  sae_number  sae_code  sae_type
        bronchospasm  face_edema  stridor_hypo  dt_sae_onset
        report_irb  dt_report_irb  related_treat  sae_resolve
        sae_sub_resolve  dt_sae_resolve  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format sae_type sae_type.  ;
  format bronchospasm mark_box.  ;
  format face_edema mark_box.  ;
  format stridor_hypo mark_box.  ;
  format report_irb yn.  ;
  format related_treat related_treat.  ;
  format sae_resolve yn.  ;
  format sae_sub_resolve mark_box.  ;
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
        sae_number="1.1 SAE log number"
        sae_code="1.2 SAE log code"
        sae_type="1.3 Type of SAE"
        bronchospasm="1.3.a New onset broncho."
        face_edema="1.3.b Facial edema"
        stridor_hypo="1.3.c Stridor or hypoten."
        dt_sae_onset="2.1 Date of SAE onset"
        report_irb="2.2 Required report IRB?"
        dt_report_irb="2.2 Date reported IRB"
        related_treat="2.3 SAE rel to treatment?"
        sae_resolve="2.4 SAE resolved?"
        sae_sub_resolve="2.4 SAE subsequently res?"
        dt_sae_resolve="2.4 Date SAE resolved"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  * convert 99s to missing;        
  if sae_type = 99 then sae_type = .  ;
  if report_irb = 99 then report_irb = .  ;
  if related_treat = 99 then related_treat = .  ;
  if sae_resolve = 99 then sae_resolve = .  ;

proc print data= glnd.plate203;


