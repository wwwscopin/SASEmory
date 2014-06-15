/* CREATED BY: esrose2 Apr 17,2008 12:31PM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate201.d01';
data glnd.plate201(label="Adverse Event Form, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_ae_onset MMDDYY8. ;  format dt_ae_onset  MMDDYY8. ;
  informat dt_report_irb MMDDYY8. ;  format dt_report_irb  MMDDYY8. ;
  informat dt_ae_resolve MMDDYY8. ;  format dt_ae_resolve  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  ae_number  ae_code  ae_type
        ae_glycemia  glucose  dt_ae_onset  report_irb  dt_report_irb
        related_treat  ae_resolve  ae_sub_resolve  dt_ae_resolve
        DFSCREEN  DFCREATE $  DFMODIFY $ ;

  format DFSTATUS DFSTATv. ;
  format ae_type  ae.  ;
  format ae_glycemia ae_glycemia.;
  format report_irb yn.  ;
  format related_treat related_treat.  ;
  format ae_resolve yn.  ;
  format ae_sub_resolve yn.  ;
  format DFSCREEN DFSCRNv. ;


  if ae_type=99 then ae_type=.;
  if ae_glycemia = 99 then ae_glycemia = .;
  if report_irb=99 then report_irb=.;
  if related_treat=99 then related_treat=.;
  if ae_resolve=99 then ae_resolve=.;
  if ae_sub_resolve=99 then ae_sub_resolve=.;


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
        ae_number="1.1 AE log number"
        ae_code="1.2 AE log code"
        ae_type="1.3 Type of AE"
        ae_glycemia="3.O Hyper or Hypoglycemia"
        glucose="3.O Glucose value"
        dt_ae_onset="2.1 Date of AE onset"
        report_irb="2.2 Required report IRB?"
        dt_report_irb="2.2 Date reported IRB"
        related_treat="2.3 AE rel to treatment?"
        ae_resolve="2.4 AE resolved?"
        ae_sub_resolve="2.4 AE subsequently res?"
        dt_ae_resolve="2.4 Date AE resolved"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
data x;
 set glnd.plate201;
if ae_type=15 ;
proc sort; by id;
data z;
 set x;
 by id;
 if first.id;
center=int(id/10000);
proc freq;
 tables center;

