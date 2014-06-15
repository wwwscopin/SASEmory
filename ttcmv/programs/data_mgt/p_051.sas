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
                 1 = "Yes" ;*/run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_051.d01';
data cmv.sus_cmv_p1(label="Sus CMV Pg 1/5");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat CMVSuspDate MMDDYY8. ;  format CMVSuspDate  MMDDYY8. ;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat FeverDate MMDDYY8. ;  format FeverDate  MMDDYY8. ;
  informat RashDate MMDDYY8. ;  format RashDate  MMDDYY8. ;
  informat JaundiceDate MMDDYY8. ;  format JaundiceDate  MMDDYY8. ;
  informat PetechiaeDate MMDDYY8. ;  format PetechiaeDate  MMDDYY8. ;
  informat SeizureDate MMDDYY8. ;  format SeizureDate  MMDDYY8. ;
  informat HepatomegalyDate MMDDYY8. ;  format HepatomegalyDate  MMDDYY8. ;
  informat SplenomegalyDate MMDDYY8. ;  format SplenomegalyDate  MMDDYY8. ;
  informat MicrocephalyDate MMDDYY8. ;  format MicrocephalyDate  MMDDYY8. ;
  informat labtestDate MMDDYY8. ;  format labtestDate  MMDDYY8. ;
  informat Fio2Date MMDDYY8. ;  format Fio2Date  MMDDYY8. ;
  informat VentIncreaseDate MMDDYY8. ;  format VentIncreaseDate  MMDDYY8. ;
  informat SPO2DecreaseDate MMDDYY8. ;  format SPO2DecreaseDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        CMVSuspDate  DateFormComplete  Fever  FeverDate  Rash  RashDate
        jaundice  JaundiceDate  petechiae  PetechiaeDate  seizure
        SeizureDate  hepatomegaly  HepatomegalyDate  splenomegaly
        SplenomegalyDate  microcephaly  MicrocephalyDate  labtest
        labtestDate  Fio2  Fio2Date  Fio2SetBefore  Fio2SetAfter
        VentIncrease  VentIncreaseDate  DecreaseSPO2  SPO2DecreaseDate
        SPO2BeforeDecrease  SPO2AfterDecrease ;
  /*format DFSTATUS DFSTATv. ;
  format Fever    F0002v.  ;
  format Rash     F0002v.  ;
  format jaundice F0002v.  ;
  format petechiae F0002v.  ;
  format seizure  F0002v.  ;
  format hepatomegaly F0002v.  ;
  format splenomegaly F0002v.  ;
  format microcephaly F0002v.  ;
  format labtest  F0002v.  ;
  format Fio2     F0002v.  ;
  format VentIncrease F0002v.  ;
  format DecreaseSPO2 F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        CMVSuspDate="Date CMV first suspected"
        DateFormComplete="DateFormComplete"
        Fever="1.1 Fever"
        FeverDate="1.1 Fever Date"
        Rash="1.2 Rash"
        RashDate="1.2 Rash Date"
        jaundice="1.3 Jaundice"
        JaundiceDate="1.3 Jaundice Date"
        petechiae="1.4 Petechiae"
        PetechiaeDate="1.4 Petechiae Date"
        seizure="1.5 seizure"
        SeizureDate="1.5 Seizure Date"
        hepatomegaly="1.6 hepatomegaly"
        HepatomegalyDate="1.6 Hepatomegaly Date"
        splenomegaly="1.7 splenomegaly"
        SplenomegalyDate="1.7 Splenomegaly Date"
        microcephaly="1.8 microcephaly"
        MicrocephalyDate="1.8 Microcephaly Date"
        labtest="1.9 lab test"
        labtestDate="1.9 lab test Date"
        Fio2="2.1 Increase in Fio2"
        Fio2Date="2.1a Fio2 Date"
        Fio2SetBefore="2.1b Fio2 Setting Before"
        Fio2SetAfter="2.1c Fio2 Setting After"
        VentIncrease="2.2 VentIncrease"
        VentIncreaseDate="2.2a Vent Increase Date"
        DecreaseSPO2="2.3 Decrease SPO2"
        SPO2DecreaseDate="2.3a SPO2 Decrease Date"
        SPO2BeforeDecrease="2.3ba SPO2 Before Decrease"
        SPO2AfterDecrease="2.3c SPO2 After Decrease";
run;
