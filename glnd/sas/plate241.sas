/* CREATED BY: gcotson Oct 21,2010 10:45AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */


filename data1 '/dfax/glnd/sas/plate241.d01';
data glnd.plate241(label="Mortality Review, Page 1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY10. ;  format dfc      MMDDYY10. ;
  informat dt_death MMDDYY10. ;  format dt_death MMDDYY10. ;
  informat oth_items_spec $CHAR100. ;
  informat immed_cause_desc $CHAR100. ;
  informat immed_cause_icd9 $CHAR40. ;
  informat under_cause_desc $CHAR100. ;
  informat under_cause_icd9 $CHAR40. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  maskedid  fcbint $  dfc  dt_death  autopsy_rept
        death_cert  progress_notes  discharge_summ  coroner_inv
        nurse_notes  medication_records  oth_path_rept  oth_items
        oth_items_spec $  immed_cause_code  immed_cause_desc $
        immed_cause_icd9 $  under_cause_code  under_cause_desc $
        under_cause_icd9 $  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format autopsy_rept death_cert  progress_notes discharge_summ 
   coroner_inv nurse_notes  medication_records
   oth_path_rept  oth_items yn.  ;
  format DFSCREEN DFSCRNv. ;
  
  array junk(9)
  autopsy_rept death_cert  progress_notes discharge_summ 
   coroner_inv nurse_notes  medication_records
   oth_path_rept  oth_items;
  
  do i=1 to 9;
      if junk(i)=99 then junk(i)=.;
  end;
  
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        maskedid="Masked ID No"
        fcbint="Form Comp. By Initials"
        dfc="Date Form Completed"
        dt_death="Date of death"
        autopsy_rept="Autopsy report"
        death_cert="Death certificate data"
        progress_notes="Progress notes"
        discharge_summ="Hospital discharge summ."
        coroner_inv="Coroner invest rept"
        nurse_notes="Nursing notes"
        medication_records="Medication records"
        oth_path_rept="Other pathology reports"
        oth_items="Other items"
        oth_items_spec="Other items specify"
        immed_cause_code="Immediate cause code"
        immed_cause_desc="Immediate cause descriptn"
        immed_cause_icd9="Immediate cause ICD9"
        under_cause_code="Underlying cause code"
        under_cause_desc="Underlying cause descrptn"
        under_cause_icd9="Underlying cause ICD9"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
proc print;
 var id dfseq;