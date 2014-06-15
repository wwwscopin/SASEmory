/* CREATED BY: esrose2 Jun 14,2007 11:03AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

 
filename data1 '/dfax/glnd/sas/plate22.d01';
data glnd.plate22(label="Demographics/History Form, Pg 3/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat indication_pn_oth $CHAR100. ;
  informat dt_drug_str MMDDYY8. ;  format dt_drug_str  MMDDYY8. ;
  informat time_drug_str time5.; format time_drug_str hhmm. ; * added by eli - DFsas makes this a character variable ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  indication_pn_1  indication_pn_2  indication_pn_3
        indication_pn_4  indication_pn_5  indication_pn_6
        indication_pn_oth $  ent_nutr  ent_nutr_days  parent_nutr
        parent_nutr_days  dt_drug_str  time_drug_str   DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format indication_pn_1 
   indication_pn_2 
   indication_pn_3
  indication_pn_4 i
   indication_pn_5 
   indication_pn_6 yn. ;
  format ent_nutr yn.  ;
  format parent_nutr yn.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        indication_pn_1="4.1 Illeus"
        indication_pn_2="4.1 Ischemic bowel"
        indication_pn_3="4.1 Hemodynamic instab."
        indication_pn_4="4.1 Intolerence to ent."
        indication_pn_5="4.1 Bowel obstruction"
        indication_pn_6="4.1 Other"
        indication_pn_oth="4.1 Other (specify)"
        ent_nutr="4.2 Enteral nutrition?"
        ent_nutr_days="4.2 Days ent nutrition"
        parent_nutr="4.3 Parenteral nutrition?"
        parent_nutr_days="4.3 Days parent nutrition"
        dt_drug_str="4.4.A Date drug started"
        time_drug_str="4.4.B Time drug started"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  if indication_pn_1 = 99 then indication_pn_1 = 0  ;
  if indication_pn_2 = 99 then indication_pn_2 = 0  ;
  if indication_pn_3 = 99 then indication_pn_3 = 0   ;
  if indication_pn_4 = 99 then indication_pn_4 = 0   ;
  if indication_pn_5 = 99 then indication_pn_5 = 0   ;
  if indication_pn_6 = 99 then indication_pn_6 = 0   ;
  if ent_nutr = 99 then ent_nutr = .  ;
  if parent_nutr = 99 then parent_nutr = . ;

proc print;
