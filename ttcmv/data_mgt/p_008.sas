/* CREATED BY: nshenvi Feb 16,2010 14:58PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;

  


  

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_008.d01';
data cmv.plate_008(label="MOC Demographic P 2 / 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat ROMDate  MMDDYY8. ;  format ROMDate   MMDDYY8. ;
  informat SteroidOther $CHAR100. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  MOC_Hiv  Gravida
        Parity  MultipleBirth  TotalFetuses  PrenatalVisit  InsulinPreg
        Hypertension  AntepartumHemor  AntepartumHemorYes  ROM  ROMDate
        ROMTime $  ROM18Hr  Antibiotic  AntibioticCode1 $
        AntibioticCode2 $  AntibioticCode3 $  AntibioticCode4 $
        Steroids  DeliverySteroidBetamethasone
        DeliverySteroidDexamethasone  DeliverySteroidOther
        SteroidOther $  DeliveryMode ;
  *format DFSTATUS DFSTATv. ;
  *format MOC_Hiv  F0017v.  ;
  *format MultipleBirth F0002v.  ;
  * format PrenatalVisit F0002v.  ;
  * format InsulinPreg F0002v.  ;
  * format Hypertension F0002v.  ;
  * format AntepartumHemor F0002v.  ;
  * format AntepartumHemorYes F0002v.  ;
  * format ROM      F0002v.  ;
  * format ROM18Hr  F0002v.  ;
  * format Antibiotic F0002v.  ;
  * format Steroids F0002v.  ;
  * format DeliverySteroidBetamethasone F0001v.  ;
 *  format DeliverySteroidDexamethasone F0001v.  ;
 * *  format DeliverySteroidOther F0001v.  ;
 * format DeliveryMode F0018v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        MOC_Hiv="MOC HIV status"
        Gravida="Gravida"
        Parity="Parity"
        MultipleBirth="Multiple Birth"
        TotalFetuses="Total number of fetuses"
        PrenatalVisit="Atleast one prenatal visit in pregna"
        InsulinPreg="Insulin during pregnancy"
        Hypertension="Hypertension during pregnancy"
        AntepartumHemor="Antepartam Hemorhage"
        AntepartumHemorYes="Was Tx required?"
        ROM="Rutpture of membrane"
        ROMDate="ROM date"
        ROMTime=" ROM time"
        ROM18Hr="ROM estimated at > 18 Hr"
        Antibiotic="MOC Antibiotics"
        AntibioticCode1="Antibiotic Code 1"
        AntibioticCode2="Antibiotic Code2"
        AntibioticCode3="Antibiotic Code3"
        AntibioticCode4="Antibiotic Code4"
        Steroids="Steroids prior to delivery"
        DeliverySteroidBetamethasone="Delivery Steroid Betamethasone"
        DeliverySteroidDexamethasone="Delivery Steroid Dexamethasone"
        DeliverySteroidOther="Delivery Steroid Other"
        SteroidOther="Steroid Other"
        DeliveryMode="Final Delivery Mode";

if MOC_Hiv = 99 then MOC_Hiv=.;

if PrenatalVisit = 99 then PrenatalVisit=.;
if InsulinPreg = 99 then InsulinPreg=.;
if Hypertension = 99 then Hypertension=.;
if AntepartumHemor = 99 then AntepartumHemor=.;
if AntepartumHemorYes = 99 then AntepartumHemorYes=.;
if ROM = 99 then ROM=.;
if ROM18Hr = 99 then ROM18Hr=.;
if Antibiotic = 99 then Antibiotic=.;
if Steroids = 99 then Steroids=.;
if DeliveryMode  = 99 then DeliveryMode=.;
           
