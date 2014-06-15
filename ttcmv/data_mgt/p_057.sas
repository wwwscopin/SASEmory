/* CREATED BY: nshenvi May 24,2010 13:23PM using DFsas */
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
                 1 = "Yes" ;*/ run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_057.d01';
data cmv.nec_p1(label="NEC Pg 1/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat NECDate  MMDDYY8. ;  format NECDate   MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  IsBloodStool  IsEmesis  IsAbnDistension
        NECDate  LBWIWeight  ImageNumber  AntibioticNEC ;
  /*format DFSTATUS DFSTATv. ;
  format IsBloodStool F0002v.  ;
  format IsEmesis F0002v.  ;
  format IsAbnDistension F0002v.  ;
  format AntibioticNEC F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        IsBloodStool="1.1b. Bloody Stools"
        IsEmesis="1.1c.Emesis"
        IsAbnDistension="1.1d.Abn Distension"
        NECDate="1.1a NEC Diagnosis Date"
        LBWIWeight="1.2.LBWI Weight at diagnosisi"
        ImageNumber="2.1 Total Image Number"
        AntibioticNEC="3.1 Antibiotic treatment for NEC";
run;
