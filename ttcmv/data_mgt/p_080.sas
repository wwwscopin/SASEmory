/* CREATED BY: nshenvi Feb 26,2010 13:00PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_080.d01';
data cmv.pda (label="PDA");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat PDADiagDate MMDDYY8. ;  format PDADiagDate  MMDDYY8. ;
  informat EchoDate MMDDYY8. ;  format EchoDate  MMDDYY8. ;
  informat XRayDate MMDDYY8. ;  format XRayDate  MMDDYY8. ;
  informat PDASurgeryDate MMDDYY8. ;  format PDASurgeryDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  ContMurmur  HyperPrecoidium  BoundPulses
        WidePulsePressure  PulVasulature  CHF  PosImgResult
        PDADiagDate  IsPDAConfirmEcho  EchoDate  IsPDAConfirmXray
        XRayDate  PDAMeds  PDASurgery  PDASurgeryDate  PDALigation ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        ContMurmur="Continuos Murmur"
        HyperPrecoidium="Hyperdynamic Precoidium"
        BoundPulses="Bounding Pulses"
        WidePulsePressure="Wide Pulse Pressure"
        PulVasulature="Increased Pulmonary Vasulature"
        CHF="Congestive Heart Failure"
        PosImgResult="Positive Image Result"
        PDADiagDate="PDA diagnosis date"
        IsPDAConfirmEcho="PDA confirmed by Echocardiogram"
        EchoDate="Echocardiogram Date"
        IsPDAConfirmXray="PDA confirmed by X-ray"
        XRayDate="X-Ray Date"
        PDAMeds="Medication given for treatment"
        PDASurgery="Surgery been performed"
        PDASurgeryDate="Date of surgery"
        PDALigation="PDA ligation successful";
