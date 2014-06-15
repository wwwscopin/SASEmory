/* CREATED BY: nshenvi May 24,2010 09:48AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;/*
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_055.d01';
data cmv.sus_cmv_p5(label="Sus CMV Pg5/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat CMVConfirmedDate MMDDYY8. ;  format CMVConfirmedDate  MMDDYY8. ;
  informat CMVRuleOutDate MMDDYY8. ;  format CMVRuleOutDate  MMDDYY8. ;
  informat Comments $CHAR1000. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  colonoscopy
        ConfirmColitis  OpExam  ConfirmRetinitis  Broncho
        ConfirmPneumonitis  SkinBiopsy  ConfirmDermatitis  SpinalTap
        ConfirmEncephal  ConfirmReport  CMVDisConf  CMVConfirmedDate
        CMVDisNo  CMVRuleOutDate  Comments $  IsNarrative ;
 /* format DFSTATUS DFSTATv. ;
  format colonoscopy F0002v.  ;
  format ConfirmColitis F0002v.  ;
  format OpExam   F0002v.  ;
  format ConfirmRetinitis F0002v.  ;
  format Broncho  F0002v.  ;
  format ConfirmPneumonitis F0002v.  ;
  format SkinBiopsy F0002v.  ;
  format ConfirmDermatitis F0002v.  ;
  format SpinalTap F0002v.  ;
  format ConfirmEncephal F0002v.  ;
  format ConfirmReport F0001v.  ;
  format CMVDisConf F0002v.  ;
  format CMVDisNo F0002v.  ;
  format IsNarrative F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        colonoscopy="6.1. Colonoscopy"
        ConfirmColitis="6.1 Confirmed Colitis"
        OpExam="6.2. Opthalmologic Exam"
        ConfirmRetinitis="6.2 Confirmed Retinitis"
        Broncho="6.3. Bronhoscopy /Lung Biopsy"
        ConfirmPneumonitis="6.3 Confirmed Pneumonitis"
        SkinBiopsy="6.4. Skin Biopsy"
        ConfirmDermatitis="6.4 Confirmed Dermatitis"
        SpinalTap="6.5. Spinal Tap"
        ConfirmEncephal="6.5 Confirmed Encephalopathy"
        ConfirmReport="ConfirmReport"
        CMVDisConf="7.1. CMV Disease Confirmed?"
        CMVConfirmedDate="7.1 CMV Confirmed Date"
        CMVDisNo="7.2. CMV Disease ruled out?"
        CMVRuleOutDate="7.2 CMV Rule Out Date"
        Comments="Comments"
        IsNarrative="IsNarrative";run;
