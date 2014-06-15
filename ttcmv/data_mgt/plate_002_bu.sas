/* CREATED BY: nshenvi Nov 11,2010 12:40PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

proc format ;
  /*value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0010v   99 = "Blank"
                 1 = "RBC"
                 2 = "FFP"
                 3 = "Granulocyte"
                 4 = "Platelet"
                 5 = "Cryoprecipitate" ;
  value F0011v   99 = "Blank"
                 1 = "Roback lab results"
                 2 = "ARC results" ;
  value F0012v   99 = "Blank"
                 1 = "Not detected (<0.2 WBC/microL"
                 2 = "Detected ( >=0.2 WBC/microL)" ;
  value F0002v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0013v   99 = "Blank"
                 1 = "Not detected (<0.2 WBC/microL"
                 2 = "Detected ( >=0.2 WBC/microL)" ;
*/

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_002_bu.d01';
data cmv.Plate_002_bu(label="Unit WBC Results");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat DonorUnitId $CHAR15. ;
  informat UnitTestDate MMDDYY8. ;  format UnitTestDate  MMDDYY8. ;
  informat comments $CHAR150. ;
  input DCCUnitId  DFSTATUS  DFVALID  DFSEQ  FormCompletedBy $
        DateFormComplete  DonorUnitId $  BloodUnitType  UnitTestDate
        ResidualWBCTest  wbc_result1  wbc_count1  RetestUnit
        wbc_result2  wbc_count2  comments $  Narrative ;
  /*format DFSTATUS DFSTATv. ;
  format BloodUnitType F0010v.  ;
  format ResidualWBCTest F0011v.  ;
  format wbc_result1 F0012v.  ;
  format RetestUnit F0002v.  ;
  format wbc_result2 F0013v.  ;
  format Narrative F0002v.  ;*/
  label DCCUnitId="DCC Unit Id"
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        FormCompletedBy="Form Completed By"
        DateFormComplete="Date Form Complete"
        DonorUnitId="Dono rUnit Id"
        BloodUnitType="BloodUnitType"
        UnitTestDate="Unit Test Date is Required"
        ResidualWBCTest="ResidualWBCTest"
        wbc_result1="2. Residual WBC count test result"
        wbc_count1="wbc_count1"
        RetestUnit="Retest done on unit"
        wbc_result2="3. Retest WBC count test result"
        wbc_count2="3. WBC count"
        comments="comments"
        Narrative="Narrative";
run;
