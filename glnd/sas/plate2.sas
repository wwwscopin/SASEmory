/* CREATED BY: gcotson Sep 25,2006 11:32AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate2.d01';
data glnd.plate2(label="Eligibility Criteria Confirmation, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_screen MMDDYY8. ;  format dt_screen  MMDDYY8. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dt_screen  dfc  age_18_80  bmi_40
        sicu_or_proc  cent_ven_pn  cent_access  phys_allow  pn_4_days
        pregnant  clin_sepsis  malig  seizure  unex_enceph  cirr_bilir
        renal_dysfunc  burn_trauma_inj  gast_whipple  organ_trans
        invest_drug  ent_parent_feed  hiv_aids  study_proc  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format age_18_80 yn.  ;
  format bmi_40   yn.  ;
  format sicu_or_proc yn.  ;
  format cent_ven_pn yn.  ;
  format cent_access yn.  ;
  format phys_allow yn.  ;
  format pn_4_days yn.  ;
  format pregnant yn.  ;
  format clin_sepsis yn.  ;
  format malig    yn.  ;
  format seizure  yn.  ;
  format unex_enceph yn.  ;
  format cirr_bilir yn.  ;
  format renal_dysfunc yn.  ;
  format burn_trauma_inj yn.  ;
  format gast_whipple yn.  ;
  format organ_trans yn.  ;
  format invest_drug yn.  ;
  format ent_parent_feed yn.  ;
  format hiv_aids yn.  ;
  format study_proc yn.  ;
  format DFSCREEN DFSCRNv. ;
  array junk(21) age_18_80--study_proc;
  do i=1 to 21;
     if junk(i)=9 then junk(i)=.;
  end;

  
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        dt_screen="Date of Screening"
        dfc="Date Form Completed"
        age_18_80="1.1 Age 18-80"
        bmi_40="1.2 BMI <40"
        sicu_or_proc="1.3 SICU care or proc."
        cent_ven_pn="1.4 Central venous PN"
        cent_access="1.5 Central access"
        phys_allow="1.6 Physician(s) allow"
        pn_4_days="2.1 Received PN 4+ days"
        pregnant="2.2 Patient pregnant"
        clin_sepsis="2.3 Clinical sepsis within 24 hrs study entry"
        malig="2.4 Malignancy "
        seizure="2.5 Seizure hist/disorder"
        unex_enceph="2.6 Unexplained enceph."
        cirr_bilir="2.7 Cirr or bilirubin >10"
        renal_dysfunc="2.8 Renal dysfunction"
        burn_trauma_inj="2.9 Burn trauma injury"
        gast_whipple="2.10 Gastric surg Whipple"
        organ_trans="2.11 Organ transplant"
        invest_drug="2.12 Investigational drug"
        ent_parent_feed="2.13 Ent/parent feedings"
        hiv_aids="2.14 History of HIV/AIDS"
        study_proc="2.15 Study procedures"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
   validinc=(sum (of age_18_80--phys_allow)=6);
   validexc=(sum (of pn_4_days--study_proc)=0);
    validplate2=validinc*validexc;
    proc print;
