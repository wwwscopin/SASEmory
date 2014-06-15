/* CREATED BY: nshenvi Feb 25,2010 12:36PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  /* value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
*/
run;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_068.d01';
data cmv.plate_068 (label="IVH Pg 1/ 2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat IVHDiagDate MMDDYY8. ;  format IVHDiagDate  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  Apnea  Bradycardia  Cyanosis  WeakSuck
        HighCry  Seizures  Anemia  Swelling  RadiographFind
        IVHDiagDate  ImageTotal  Indomethacin  AntiConvulsant ;
 /* format DFSTATUS DFSTATv. ;
  format Apnea    F0002v.  ;
  format Bradycardia F0002v.  ;
  format Cyanosis F0002v.  ;
  format WeakSuck F0002v.  ;
  format HighCry  F0002v.  ;
  format Seizures F0002v.  ;
  format Anemia   F0002v.  ;
  format Swelling F0002v.  ;
  format RadiographFind F0002v.  ;
  format Indomethacin F0002v.  ;
  format AntiConvulsant F0002v.  ; */
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        Apnea="1.1b. Apnea"
        Bradycardia="1.1c. Bradycardia"
        Cyanosis="1.1d.Cyanosis"
        WeakSuck="1.1e. Weak Suck"
        HighCry="1.1e.High-pitched Cry"
        Seizures="1.1f.Seizures"
        Anemia="1.1g.Anemia"
        Swelling="1.1i.Swelling"
        RadiographFind="1.1i.Radiograph Findings"
        IVHDiagDate="1.1a. IVH Diagnosis Date"
        ImageTotal="2.1 Image Total"
        Indomethacin="3.1 Indomethacin within 24 hours?"
        AntiConvulsant="3.2 Seisures treated with AntiConvulsant";
