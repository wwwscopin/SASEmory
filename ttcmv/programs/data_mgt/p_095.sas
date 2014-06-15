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
  value F0122v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0123v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0124v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0125v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0126v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0127v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0128v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0129v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0130v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;
  value F0131v   99 = "Blank"
                 1 = "Conventional"
                 2 = "Oscillator"
                 3 = "CPAP" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_095.d01';
data cmv.mechvent(label="Mech Vent Pg X/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat StartDate1 MMDDYY8. ;  format StartDate1  MMDDYY8. ;
  informat EndDate1 MMDDYY8. ;  format EndDate1  MMDDYY8. ;
  informat comment1 $CHAR100. ;
  informat StartDate2 MMDDYY8. ;  format StartDate2  MMDDYY8. ;
  informat EndDate2 MMDDYY8. ;  format EndDate2  MMDDYY8. ;
  informat comment2 $CHAR100. ;
  informat StartDate3 MMDDYY8. ;  format StartDate3  MMDDYY8. ;
  informat EndDate3 MMDDYY8. ;  format EndDate3  MMDDYY8. ;
  informat comment3 $CHAR100. ;
  informat StartDate4 MMDDYY8. ;  format StartDate4  MMDDYY8. ;
  informat EndDate4 MMDDYY8. ;  format EndDate4  MMDDYY8. ;
  informat comment4 $CHAR100. ;
  informat StartDate5 MMDDYY8. ;  format StartDate5  MMDDYY8. ;
  informat EndDate5 MMDDYY8. ;  format EndDate5  MMDDYY8. ;
  informat comment5 $CHAR100. ;
  informat StartDate6 MMDDYY8. ;  format StartDate6  MMDDYY8. ;
  informat EndDate6 MMDDYY8. ;  format EndDate6  MMDDYY8. ;
  informat comment6 $CHAR100. ;
  informat StartDate7 MMDDYY8. ;  format StartDate7  MMDDYY8. ;
  informat EndDate7 MMDDYY8. ;  format EndDate7  MMDDYY8. ;
  informat comment7 $CHAR100. ;
  informat StartDate8 MMDDYY8. ;  format StartDate8  MMDDYY8. ;
  informat EndDate8 MMDDYY8. ;  format EndDate8  MMDDYY8. ;
  informat comment8 $CHAR100. ;
  informat StartDate9 MMDDYY8. ;  format StartDate9  MMDDYY8. ;
  informat EndDate9 MMDDYY8. ;  format EndDate9  MMDDYY8. ;
  informat comment9 $CHAR100. ;
  informat StartDate10 MMDDYY8. ;  format StartDate10  MMDDYY8. ;
  informat EndDate10 MMDDYY8. ;  format EndDate10  MMDDYY8. ;
  informat comment10 $CHAR100. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  StartDate1  EndDate1
        VentType1  InitialFio2_1  FinalFio2_1  comment1 $  StartDate2
        EndDate2  VentType2  InitialFio2_2  FinalFio2_2  comment2 $
        StartDate3  EndDate3  VentType3  InitialFio2_3  FinalFio2_3
        comment3 $  StartDate4  EndDate4  VentType4  InitialFio2_4
        FinalFio2_4  comment4 $  StartDate5  EndDate5  VentType5
        InitialFio2_5  FinalFio2_5  comment5 $  StartDate6  EndDate6
        VentType6  InitialFio2_6  FinalFio2_6  comment6 $  StartDate7
        EndDate7  VentType7  InitialFio2_7  FinalFio2_7  comment7 $
        StartDate8  EndDate8  VentType8  InitialFio2_8  FinalFio2_8
        comment8 $  StartDate9  EndDate9  VentType9  InitialFio2_9
        FinalFio2_9  comment9 $  StartDate10  EndDate10  VentType10
        InitialFio2_10  FinalFio2_10  comment10 $ ;
  /*format DFSTATUS DFSTATv. ;
  format VentType1 F0122v.  ;
  format VentType2 F0123v.  ;
  format VentType3 F0124v.  ;
  format VentType4 F0125v.  ;
  format VentType5 F0126v.  ;
  format VentType6 F0127v.  ;
  format VentType7 F0128v.  ;
  format VentType8 F0129v.  ;
  format VentType9 F0130v.  ;
  format VentType10 F0131v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        StartDate1="1. Start Date"
        EndDate1="1. End Date"
        VentType1="1. Vent Type"
        InitialFio2_1="1. Initial Fio2"
        FinalFio2_1="1. Final Fio2"
        comment1="Comment Row 1"
        StartDate2="2. Start Date"
        EndDate2="2. End Date"
        VentType2="2. Vent Type"
        InitialFio2_2="2. Initial Fio2"
        FinalFio2_2="2. Final Fio2"
        comment2="Comment Row 2"
        StartDate3="3. Start Date"
        EndDate3="3. End Date"
        VentType3="3. Vent Type"
        InitialFio2_3="3. Initial Fio2"
        FinalFio2_3="3. Final Fio2"
        comment3="Comment Row 3"
        StartDate4="4. Start Date"
        EndDate4="4. End Date"
        VentType4="4. Vent Type"
        InitialFio2_4="4. Initial Fio2"
        FinalFio2_4="4. Final Fio2"
        comment4="Comment Row 4"
        StartDate5="5. Start Date"
        EndDate5="5. End Date"
        VentType5="5. Vent Type"
        InitialFio2_5="5. Initial Fio2"
        FinalFio2_5="5. Final Fio2"
        comment5="Comment Row 5"
        StartDate6="6. Start Date"
        EndDate6="6. End Date"
        VentType6="6. Vent Type"
        InitialFio2_6="6. Initial Fio2"
        FinalFio2_6="6. Final Fio2"
        comment6="Comment Row 6"
        StartDate7="7. Start Date"
        EndDate7="7. End Date"
        VentType7="7. Vent Type"
        InitialFio2_7="7. Initial Fio2"
        FinalFio2_7="7. Final Fio2"
        comment7="Comment Row 7"
        StartDate8="8. Start Date"
        EndDate8="8. End Date"
        VentType8="8. Vent Type"
        InitialFio2_8="8. Initial Fio2"
        FinalFio2_8="8. Final Fio2"
        comment8="Comment Row 8"
        StartDate9="9. Start Date"
        EndDate9="9. End Date"
        VentType9="9. Vent Type"
        InitialFio2_9="9. Initial Fio2"
        FinalFio2_9="9. Final Fio2"
        comment9="Comment Row 9"
        StartDate10="10. Start Date"
        EndDate10="10. End Date"
        VentType10="10. Vent Type"
        InitialFio2_10="10. Initial Fio2"
        FinalFio2_10="10. Final Fio2"
        comment10="Comment Row 10"; run;
