/* CREATED BY: nshenvi Mar 10,2011 17:39PM using DFsas */
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
  value F0156v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inclonclusive" ;
  value F0157v   99 = "Blank"
                 1 = "No CMV isolated"
                 2 = "Cytopathogenic effect consistent with CMV"
                 3 = "Inconclusive" ;
  value F0158v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inclonclusive" ;
  value F0159v   99 = "Blank"
                 1 = "No CMV isolated"
                 2 = "Cytopathogenic effect consistent with CMV"
                 3 = "Inconclusive" ;
  value F0160v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inclonclusive" ;
  value F0161v   99 = "Blank"
                 1 = "No CMV isolated"
                 2 = "Cytopathogenic effect consistent with CMV"
                 3 = "Inconclusive" ;
  value F0162v   99 = "Blank"
                 1 = "Negative"
                 2 = "Positive"
                 3 = "Inclonclusive" ;
  value F0163v   99 = "Blank"
                 1 = "No CMV isolated"
                 2 = "Cytopathogenic effect consistent with CMV"
                 3 = "Inconclusive" ;
*/ run;
filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_216.d01';
data cmv.plate_216(label="Breast Milk Culture Result P1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DateFormComplete MMDDYY8. ;  format DateFormComplete  MMDDYY8. ;
  informat milk_date_1 MMDDYY8. ;  format milk_date_1  MMDDYY8. ;
  informat test_date_1 MMDDYY8. ;  format test_date_1  MMDDYY8. ;
  informat milk_date_2 MMDDYY8. ;  format milk_date_2  MMDDYY8. ;
  informat test_date_2 MMDDYY8. ;  format test_date_2  MMDDYY8. ;
  informat milk_date_3 MMDDYY8. ;  format milk_date_3  MMDDYY8. ;
  informat test_date_3 MMDDYY8. ;  format test_date_3  MMDDYY8. ;
  informat milk_date_4 MMDDYY8. ;  format milk_date_4  MMDDYY8. ;
  informat test_date_4 MMDDYY8. ;  format test_date_4  MMDDYY8. ;
  input id  DFSTATUS  DFVALID  DFSEQ  MOCInit $  FormCompletedBy $
        DateFormComplete  milk_date_1  test_date_1  test_person_1 $
        rapid_test_1  conv_test_1  milk_date_2  test_date_2
        test_person_2 $  rapid_test_2  conv_test_2  milk_date_3
        test_date_3  test_person_3 $  rapid_test_3  conv_test_3
        milk_date_4  test_date_4  test_person_4 $  rapid_test_4
        conv_test_4 ;
  /*format DFSTATUS DFSTATv. ;
  format rapid_test_1 F0156v.  ;
  format conv_test_1 F0157v.  ;
  format rapid_test_2 F0158v.  ;
  format conv_test_2 F0159v.  ;
  format rapid_test_3 F0160v.  ;
  format conv_test_3 F0161v.  ;
  format rapid_test_4 F0162v.  ;
  format conv_test_4 F0163v.  ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormComplete="DateFormComplete"
        milk_date_1="milk_date_1"
        test_date_1="test_date_1"
        test_person_1="test_person_1"
        rapid_test_1="Sample 1 :Rapid result"
        conv_test_1="Sample 1 : Convent Result"
        milk_date_2="milk_date_2"
        test_date_2="test_date_2"
        test_person_2="test_person_2"
        rapid_test_2="Sample 2 :Rapid result"
        conv_test_2="Sample 2 : Convent Result"
        milk_date_3="milk_date_3"
        test_date_3="test_date_3"
        test_person_3="test_person_3"
        rapid_test_3="Sample 3 :Rapid result"
        conv_test_3="Sample 3 : Convent Result"
        milk_date_4="milk_date_4"
        test_date_4="test_date_4"
        test_person_4="test_person_4"
        rapid_test_4="Sample 4 :Rapid result"
        conv_test_4="Sample 4 : Convent Result";
*/
run;
