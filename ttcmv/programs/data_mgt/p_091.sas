/* CREATED BY: nshenvi May 24,2010 14:04PM using DFsas */
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
  value F0087v   1 = "CMV"
                 2 = "NEC"
                 3 = "IVH"
                 4 = "BPD"
                 5 = "PDA( for prophylaxis)"
                 6 = "PDA(for treatment)"
                 7 = "ROP" ;
  value F0088v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;
  value F0089v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0090v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0091v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0092v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0093v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0094v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0095v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;
  value F0096v   1 = "Aminoglycosides"
                 2 = "Ampicilline/Penicilline"
                 3 = "Analgesics/Anesthetic/Anamnestic"
                 4 = "Bicarbonates"
                 5 = "Caffeine/Theophylline"
                 6 = "Calcium"
                 7 = "Cephalosporin"
                 8 = "Digitalis"
                 9 = "Anti-convulsant"
                 10 = "Diuretics"
                 11 = "Dopamine/Epi etc"
                 12 = "Ganciclovir"
                 13 = "Ibuprofin"
                 14 = "Indomethicin/Indoin"
                 15 = "Insulin"
                 16 = "Immuoglobin (IVIG)"
                 17 = "Steorids"
                 18 = "Surfactant"
                 19 = "Vancomycin"
                 20 = "Valganciclovir" ;
  value F0097v   99 = "Blank"
                 1 = "mg"
                 2 = "ml"
                 3 = "U"
                 4 = "mcg"
                 5 = "meq" ;*/

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_091.d01';
data cmv.con_meds(label="Con Med Pg X of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat MedName1 $CHAR150. ;
  informat StartDate1 MMDDYY8. ;  format StartDate1  MMDDYY8. ;
  informat EndDate1 MMDDYY8. ;  format EndDate1  MMDDYY8. ;
  informat MedName2 $CHAR100. ;
  informat StartDate2 MMDDYY8. ;  format StartDate2  MMDDYY8. ;
  informat EndDate2 MMDDYY8. ;  format EndDate2  MMDDYY8. ;
  informat MedName3 $CHAR100. ;
  informat StartDate3 MMDDYY8. ;  format StartDate3  MMDDYY8. ;
  informat EndDate3 MMDDYY8. ;  format EndDate3  MMDDYY8. ;
  informat MedName4 $CHAR100. ;
  informat StartDate4 MMDDYY8. ;  format StartDate4  MMDDYY8. ;
  informat EndDate4 MMDDYY8. ;  format EndDate4  MMDDYY8. ;
  informat MedName5 $CHAR100. ;
  informat StartDate5 MMDDYY8. ;  format StartDate5  MMDDYY8. ;
  informat EndDate5 MMDDYY8. ;  format EndDate5  MMDDYY8. ;
  informat MedName6 $CHAR100. ;
  informat StartDate6 MMDDYY8. ;  format StartDate6  MMDDYY8. ;
  informat EndDate6 MMDDYY8. ;  format EndDate6  MMDDYY8. ;
  informat MedName7 $CHAR100. ;
  informat StartDate7 MMDDYY8. ;  format StartDate7  MMDDYY8. ;
  informat EndDate7 MMDDYY8. ;  format EndDate7  MMDDYY8. ;
  informat MedName8 $CHAR100. ;
  informat StartDate8 MMDDYY8. ;  format StartDate8  MMDDYY8. ;
  informat EndDate8 MMDDYY8. ;  format EndDate8  MMDDYY8. ;
  informat MedName9 $CHAR100. ;
  informat StartDate9 MMDDYY8. ;  format StartDate9  MMDDYY8. ;
  informat EndDate9 MMDDYY8. ;  format EndDate9  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  MedName1 $  MedCode1
        Indication1  Dose1  Unit1  DoseNumber1  prn1  StartDate1
        EndDate1  MedName2 $  MedCode2  Indication2  Dose2  Unit2
        DoseNumber2  prn2  StartDate2  EndDate2  MedName3 $  MedCode3
        Indication3  Dose3  Unit3  DoseNumber3  prn3  StartDate3
        EndDate3  MedName4 $  MedCode4  Indication4  Dose4  Unit4
        DoseNumber4  prn4  StartDate4  EndDate4  MedName5 $  MedCode5
        Indication5  Dose5  Unit5  DoseNumber5  prn5  StartDate5
        EndDate5  MedName6 $  MedCode6  Indication6  Dose6  Unit6
        DoseNumber6  prn6  StartDate6  EndDate6  MedName7 $  MedCode7
        Indication7  Dose7  Unit7  DoseNumber7  prn7  StartDate7
        EndDate7  MedName8 $  MedCode8  Indication8  Dose8  Unit8
        DoseNumber8  prn8  StartDate8  EndDate8  MedName9 $  MedCode9
        Indication9  Dose9  Unit9  DoseNumber9  prn9  StartDate9
        EndDate9 ;
  /*format DFSTATUS DFSTATv. ;
  format Indication1 F0087v.  ;
  format Unit1    F0088v.  ;
  format prn1     F0001v.  ;
  format Unit2    F0089v.  ;
  format prn2     F0001v.  ;
  format Unit3    F0090v.  ;
  format prn3     F0001v.  ;
  format Unit4    F0091v.  ;
  format prn4     F0001v.  ;
  format Unit5    F0092v.  ;
  format prn5     F0001v.  ;
  format Unit6    F0093v.  ;
  format prn6     F0001v.  ;
  format Unit7    F0094v.  ;
  format prn7     F0001v.  ;
  format Unit8    F0095v.  ;
  format prn8     F0001v.  ;
  format MedCode9 F0096v.  ;
  format Unit9    F0097v.  ;
  format prn9     F0001v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        MedName1="1. MedName1"
        MedCode1="1. Med Code1"
        Indication1="1. Indication1"
        Dose1="1. Dose1"
        Unit1="1. Unit1"
        DoseNumber1="1. DoseNumber1"
        prn1="prn1"
        StartDate1="1. Start Date1"
        EndDate1="1. End Date1"
        MedName2="MedName2"
        MedCode2="MedCode2"
        Indication2="Indication2"
        Dose2="Dose2"
        Unit2="Unit2"
        DoseNumber2="DoseNumber2"
        prn2="prn2"
        StartDate2="StartDate2"
        EndDate2="EndDate2"
        MedName3="MedName3"
        MedCode3="MedCode3"
        Indication3="Indication3"
        Dose3="Dose3"
        Unit3="Unit3"
        DoseNumber3="DoseNumber3"
        prn3="prn3"
        StartDate3="StartDate3"
        EndDate3="EndDate3"
        MedName4="MedName4"
        MedCode4="MedCode4"
        Indication4="Indication4"
        Dose4="Dose4"
        Unit4="Unit4"
        DoseNumber4="DoseNumber4"
        prn4="prn4"
        StartDate4="StartDate4"
        EndDate4="EndDate4"
        MedName5="MedName5"
        MedCode5="MedCode5"
        Indication5="Indication5"
        Dose5="Dose5"
        Unit5="Unit5"
        DoseNumber5="DoseNumber5"
        prn5="prn5"
        StartDate5="StartDate5"
        EndDate5="EndDate5"
        MedName6="MedName6"
        MedCode6="MedCode6"
        Indication6="Indication6"
        Dose6="Dose6"
        Unit6="Unit6"
        DoseNumber6="DoseNumber6"
        prn6="prn6"
        StartDate6="StartDate6"
        EndDate6="EndDate6"
        MedName7="MedName7"
        MedCode7="MedCode7"
        Indication7="Indication7"
        Dose7="Dose7"
        Unit7="Unit7"
        DoseNumber7="DoseNumber7"
        prn7="prn7"
        StartDate7="StartDate7"
        EndDate7="EndDate7"
        MedName8="MedName8"
        MedCode8="MedCode8"
        Indication8="Indication8"
        Dose8="Dose8"
        Unit8="Unit8"
        DoseNumber8="DoseNumber8"
        prn8="prn8"
        StartDate8="StartDate8"
        EndDate8="EndDate8"
        MedName9="MedName9"
        MedCode9="MedCode9"
        Indication9="Indication9"
        Dose9="Dose9"
        Unit9="Unit9"
        DoseNumber9="DoseNumber9"
        prn9="prn9"
        StartDate9="StartDate9"
        EndDate9="EndDate9"; run;
