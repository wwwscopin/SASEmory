/* CREATED BY: esrose2 Dec 04,2009 11:59AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_001.d01';
data cmv.plate_001(label="Eligibility Page 1 of 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat ScreeningDate MMDDYY8. ;  format ScreeningDate  MMDDYY8. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat LBWIConsentDate MMDDYY8. ;  format LBWIConsentDate  MMDDYY8. ;
  informat RefuseOtherText $CHAR50. ;
  informat EnrollmentDate MMDDYY8. ;  format EnrollmentDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  ScreeningDate  DateFormCompl
        ItemA  InWeight  InLife  ExLifeExpect  ExAbnor  ExTX
        ExMOCPrevEnrolled  Consent  LBWIConsentDate  MOCNotAvailable
        ParticipationFear  BloodDraws  TooManyTrials  DangerToChild
        ReasonUnk  RefuseOther  RefuseOtherText $  EnrollmentDate
        IsEligible  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format InWeight yn.  ;
  format InLife   yn.  ;
  format ExLifeExpect yn.  ;
  format ExAbnor  yn.  ;
  format ExTX     yn.  ;
  format ExMOCPrevEnrolled yn.  ;
  format Consent  yn.  ;
  format MOCNotAvailable yn.  ;
  format ParticipationFear yn.  ;
  format BloodDraws yn.  ;
  format TooManyTrials yn.  ;
  format DangerToChild yn.  ;
  format ReasonUnk yn.  ;
  format RefuseOther yn.  ;
  format IsEligible eligible.  ;
  format DFSCREEN DFSCRNv. ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        ScreeningDate="Date of Screening by Required"
        DateFormCompl="Date form Completed by is Required"
        ItemA="LBWI birth number within mother"
        InWeight="2.a. Inclusion: LBWI birth weight"
        InLife="2b.Inclusion: LBWI <=5 DOL"
        ExLifeExpect="2.a.Exclusion: Life Expectancy"
        ExAbnor="2.b.Exclusion : Congenital Abnormality"
        ExTX="2.c.Exclusion: Transfusion Facility"
        ExMOCPrevEnrolled="2d.Exclusion : MOC Previously Enrolled"
        Consent="3.1 Informed consent"
        LBWIConsentDate="LBWI Date of consent"
        MOCNotAvailable="Mother not available"
        ParticipationFear="Scared to participate in research"
        BloodDraws="Too many blood draws"
        TooManyTrials="Too many research trials"
        DangerToChild="Dangerous for my child"
        ReasonUnk="No reason given"
        RefuseOther="Other reason to refuse participation"
        RefuseOtherText="Other specify"
        EnrollmentDate="Enrollment Date"
        IsEligible="IsEligible"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
        
  * recode 99 as missing ;      
  if InWeight = 99 then InWeight = .  ;
  if InLife   = 99 then InLife = .  ;
  if ExLifeExpect = 99 then ExLifeExpect= .  ;
  if ExAbnor  = 99 then ExAbnor = .  ;
  if ExTX     = 99 then ExTX = .  ;
  if ExMOCPrevEnrolled = 99 then ExMOCPrevEnrolled = .  ;
  if Consent  = 99 then Consent = .  ;
  if MOCNotAvailable = 99 then MOCNotAvailable = .  ;
  if ParticipationFear = 99 then ParticipationFear = .  ;
  if BloodDraws = 99 then BloodDraws = .  ;
  if TooManyTrials = 99 then TooManyTrials = .  ;
  if DangerToChild = 99 then DangerToChild = .  ;
  if ReasonUnk = 99 then ReasonUnk = .  ;
  if RefuseOther = 99 then RefuseOther = .  ;
  if IsEligible = 99 then IsEligible = .  ;
run;


proc print;
run;
