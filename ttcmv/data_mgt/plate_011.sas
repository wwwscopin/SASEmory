/* CREATED BY: nshenvi Feb 19,2010 10:39AM using DFsas */
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
  value F0001v   0 = "Unchecked"
                 1 = "Checked" ;
  value F0035v   99 = "Blank"
                 0 = "0"
                 1 = "1" ;
  value F0036v   99 = "Blank"
                 3 = "< 500 (3)"
                 1 = "500 - 900 (1)"
                 0 = ">=1000 (0)"
                 999 = "Missing" ;
  value F0037v   99 = "Blank"
                 3 = "< 30 (3)"
                 1 = "30 - 100 (1)"
                 0 = ">100 (0)"
                 999 = "Missing" ;
  value F0038v   99 = "Blank"
                 0 = "< 40(3)"
                 1 = "40 - 80 (1)"
                 3 = ">80 (3)"
                 999 = "Missing" ;
  value F0039v   99 = "Blank"
                 0 = "< 1.2 (0)"
                 1 = "1.2 - 2.4 (1)"
                 3 = "2.5 - 4.0 (3)"
                 5 = "> 4.0 (5)"
                 999 = "Missing" ;
  value F0040v   99 = "Blank"
                 5 = "< 0.1 (5)"
                 3 = "0.1 - 0.49 (3)"
                 1 = "0.5 - 0.9 (1)"
                 0 = "> 0.9 (0)"
                 999 = "Missing" ;
  value F0041v   99 = "Blank"
                 0 = "< 5 (0)"
                 1 = "5-10 (1)"
                 3 = ">10 (3)"
                 999 = "Missing" ;
  value F0042v   99 = "Blank"
                 0 = "< 2 (0)"
                 1 = ">= 2 (1)"
                 999 = "Missing" ;
  value F0043v   99 = "Blank"
                 0 = "< 150 (0)"
                 1 = "150 -160 (1)"
                 3 = "161 - 181 (3)"
                 5 = "> 180 (5)"
                 999 = "Missing" ;
  value F0044v   99 = "Blank"
                 3 = "< 120(3)"
                 1 = "120 - 130(1)"
                 0 = ">130 (0)"
                 999 = "Missing" ;
  value F0045v   99 = "Blank"
                 0 = "< 6.6 (05)"
                 1 = "6.6 - 7.5 (1)"
                 3 = "7.6 - 9.0 (3)"
                 5 = "> 9.0 (5)"
                 999 = "Missing" ;
  value F0046v   99 = "Blank"
                 3 = "< 2.0 (3)"
                 1 = "2.0 - 2.9 (1)"
                 0 = ">2.9 (0)"
                 999 = "Missing" ;
  value F0047v   99 = "Blank"
                 0 = "< 1.4 (0)"
                 1 = ">= 1.4 (1)"
                 999 = "Missing" ;
  value F0048v   99 = "Blank"
                 0 = "< 12 (0)"
                 1 = ">= 12 (1)"
                 999 = "Missing" ;
  value F0049v   99 = "Blank"
                 3 = "< 0.8 (3)"
                 1 = "0.8 - 1.0 (1)"
                 0 = ">1.0 (0)"
                 999 = "Missing" ;
  value F0050v   99 = "Blank"
                 3 = "< 5.0 (3)"
                 1 = "5.0 - 6.9 (1)"
                 0 = ">6.9 (0)"
                 999 = "Missing" ;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_011.d01';
data cmv.plate_011(label="SNAP Enrollment Page 2 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  Promyelocyte
        ProMyoMissing  Myelocyte  MyelocyteMissing  Metamyelocyte
        ImmRatio  MetamyeMissing  Bands  ImmRatioScore  BandsMissing
        TotalNeutro  TotalNeutroMissing  AbsNeutro  Platelets  BUN
        Creatinine  UOP  IndirectBili  DirectBili  MaxSodium  MinSodium
        MaxPotassium  MinPotassium  MaxIonizedCa  MaxTotalCa
        MinIonizedCa  MinTotalCa  SNAP2Score ;
  format DFSTATUS DFSTATv. ;
  * format ProMyoMissing F0001v.  ;
   * format MyelocyteMissing F0001v.  ;
   * format MetamyeMissing F0001v.  ;
  *  format ImmRatioScore F0035v.  ;
  *  format BandsMissing F0001v.  ;
 *   format TotalNeutroMissing F0001v.  ;
 *   format AbsNeutro F0036v.  ;
 *   format Platelets F0037v.  ;
 *   format BUN      F0038v.  ;
 *   format Creatinine F0039v.  ;
  *  format UOP      F0040v.  ;
 *   format IndirectBili F0041v.  ;
 *   format DirectBili F0042v.  ;
   * format MaxSodium F0043v.  ;
   * format MinSodium F0044v.  ;
   * format MaxPotassium F0045v.  ;
   * format MinPotassium F0046v.  ;
  *  format MaxIonizedCa F0047v.  ;
  *  format MaxTotalCa F0048v.  ;
   * format MinIonizedCa F0049v.  ;
   * format MinTotalCa F0050v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        Promyelocyte="Promyelocyte"
        ProMyoMissing="Promyolocyte Missing"
        Myelocyte="Myelocyte"
        MyelocyteMissing="Myelocyet Missing"
        Metamyelocyte="Metamyelocyte"
        ImmRatio="ImmRatio"
        MetamyeMissing="Metamyelocyte Missing"
        Bands="Bands"
        ImmRatioScore="ImmRatioScore"
        BandsMissing="Bands Missing"
        TotalNeutro="Total neutrophil count"
        TotalNeutroMissing="Total Neutro Missing"
        AbsNeutro="Absolute Neutrophils"
        Platelets="Platelets"
        BUN="BUN"
        Creatinine="Creatinine"
        UOP="UOP"
        IndirectBili="Indirect Bilirubin"
        DirectBili="Direct Bilirubin"
        MaxSodium="MaxSodium"
        MinSodium="Minimum Sodium"
        MaxPotassium="Minimum Potassium"
        MaxIonizedCa="Maximum Ionized Ca"
        MaxTotalCa="Maximum Total Ca"
        MinIonizedCa="Minimum Ionized Ca"
        MinTotalCa="Minimum Total Ca"
        SNAP2Score="SNAP2Score";
