/* CREATED BY: esrose2 Aug 31,2007 11:15AM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate19.d01';
data glnd.plate19(label="Concomitant Medications Form, Pg 2/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat meds_1   $CHAR40. ;
  informat dt_meds_str_1 MMDDYY8. ;  format dt_meds_str_1  MMDDYY8. ;
  informat dt_meds_stp_1 MMDDYY8. ;  format dt_meds_stp_1  MMDDYY8. ;
  informat meds_2   $CHAR40. ;
  informat dt_meds_str_2 MMDDYY8. ;  format dt_meds_str_2  MMDDYY8. ;
  informat dt_meds_stp_2 MMDDYY8. ;  format dt_meds_stp_2  MMDDYY8. ;
  informat meds_3   $CHAR40. ;
  informat dt_meds_str_3 MMDDYY8. ;  format dt_meds_str_3  MMDDYY8. ;
  informat dt_meds_stp_3 MMDDYY8. ;  format dt_meds_stp_3  MMDDYY8. ;
  informat meds_4   $CHAR40. ;
  informat dt_meds_str_4 MMDDYY8. ;  format dt_meds_str_4  MMDDYY8. ;
  informat dt_meds_stp_4 MMDDYY8. ;  format dt_meds_stp_4  MMDDYY8. ;
  informat meds_5   $CHAR40. ;
  informat dt_meds_str_5 MMDDYY8. ;  format dt_meds_str_5  MMDDYY8. ;
  informat dt_meds_stp_5 MMDDYY8. ;  format dt_meds_stp_5  MMDDYY8. ;
  informat meds_6   $CHAR40. ;
  informat dt_meds_str_6 MMDDYY8. ;  format dt_meds_str_6  MMDDYY8. ;
  informat dt_meds_stp_6 MMDDYY8. ;  format dt_meds_stp_6  MMDDYY8. ;
  informat meds_7   $CHAR40. ;
  informat dt_meds_str_7 MMDDYY8. ;  format dt_meds_str_7  MMDDYY8. ;
  informat dt_meds_stp_7 MMDDYY8. ;  format dt_meds_stp_7  MMDDYY8. ;
  informat meds_8   $CHAR40. ;
  informat dt_meds_str_8 MMDDYY8. ;  format dt_meds_str_8  MMDDYY8. ;
  informat dt_meds_stp_8 MMDDYY8. ;  format dt_meds_stp_8  MMDDYY8. ;
  informat meds_9   $CHAR40. ;
  informat dt_meds_str_9 MMDDYY8. ;  format dt_meds_str_9  MMDDYY8. ;
  informat dt_meds_stp_9 MMDDYY8. ;  format dt_meds_stp_9  MMDDYY8. ;
  informat meds_10  $CHAR40. ;
  informat dt_meds_str_10 MMDDYY8. ;  format dt_meds_str_10  MMDDYY8. ;
  informat dt_meds_stp_10 MMDDYY8. ;  format dt_meds_stp_10  MMDDYY8. ;
  informat meds_11  $CHAR40. ;
  informat dt_meds_str_11 MMDDYY8. ;  format dt_meds_str_11  MMDDYY8. ;
  informat dt_meds_stp_11 MMDDYY8. ;  format dt_meds_stp_11  MMDDYY8. ;
  informat meds_12  $CHAR40. ;
  informat dt_meds_str_12 MMDDYY8. ;  format dt_meds_str_12  MMDDYY8. ;
  informat dt_meds_stp_12 MMDDYY8. ;  format dt_meds_stp_12  MMDDYY8. ;
  informat meds_13  $CHAR40. ;
  informat dt_meds_str_13 MMDDYY8. ;  format dt_meds_str_13  MMDDYY8. ;
  informat dt_meds_stp_13 MMDDYY8. ;  format dt_meds_stp_13  MMDDYY8. ;
  informat meds_14  $CHAR40. ;
  informat dt_meds_str_14 MMDDYY8. ;  format dt_meds_str_14  MMDDYY8. ;
  informat dt_meds_stp_14 MMDDYY8. ;  format dt_meds_stp_14  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  meds_1 $  med_code_1  meds_dose_1
        dt_meds_str_1  dt_meds_stp_1  meds_2 $  med_code_2  meds_dose_2
        dt_meds_str_2  dt_meds_stp_2  meds_3 $  med_code_3  meds_dose_3
        dt_meds_str_3  dt_meds_stp_3  meds_4 $  med_code_4  meds_dose_4
        dt_meds_str_4  dt_meds_stp_4  meds_5 $  med_code_5  meds_dose_5
        dt_meds_str_5  dt_meds_stp_5  meds_6 $  med_code_6  meds_dose_6
        dt_meds_str_6  dt_meds_stp_6  meds_7 $  med_code_7  meds_dose_7
        dt_meds_str_7  dt_meds_stp_7  meds_8 $  med_code_8  meds_dose_8
        dt_meds_str_8  dt_meds_stp_8  meds_9 $  med_code_9  meds_dose_9
        dt_meds_str_9  dt_meds_stp_9  meds_10 $  med_code_10
        meds_dose_10  dt_meds_str_10  dt_meds_stp_10  meds_11 $
        med_code_11  meds_dose_11  dt_meds_str_11  dt_meds_stp_11
        meds_12 $  med_code_12  meds_dose_12  dt_meds_str_12
        dt_meds_stp_12  meds_13 $  med_code_13  meds_dose_13
        dt_meds_str_13  dt_meds_stp_13  meds_14 $  med_code_14
        meds_dose_14  dt_meds_str_14  dt_meds_stp_14  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format med_code_1 med_code.;
  format med_code_2 med_code.;
  format med_code_3 med_code.;
  format med_code_4 med_code.;
  format med_code_5 med_code.;
  format med_code_6 med_code.;
  format med_code_7 med_code.;
  format med_code_8 med_code.;
  format med_code_9 med_code.;
  format med_code_10 med_code.;
  format med_code_11 med_code.;
  format med_code_12 med_code.;
  format med_code_13 med_code.;
  format med_code_14 med_code.;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        meds_1="Medication 1"
        med_code_1="Medication Code 1"
        meds_dose_1="Medication Daily Dose 1"
        dt_meds_str_1="Medication Start Date 1"
        dt_meds_stp_1="Medication Stop Date 1"
        meds_2="Medication 2"
        med_code_2="Medication Code 2"
        meds_dose_2="Medication Daily Dose 2"
        dt_meds_str_2="Medication Start Date 2"
        dt_meds_stp_2="Medication Stop Date 2"
        meds_3="Medication 3"
        med_code_3="Medication Code 3"
        meds_dose_3="Medication Daily Dose 3"
        dt_meds_str_3="Medication Start Date 3"
        dt_meds_stp_3="Medication Stop Date 3"
        meds_4="Medication 4"
        med_code_4="Medication Code 4"
        meds_dose_4="Medication Daily Dose 4"
        dt_meds_str_4="Medication Start Date 4"
        dt_meds_stp_4="Medication Stop Date 4"
        meds_5="Medication 5"
        med_code_5="Medication Code 5"
        meds_dose_5="Medication Daily Dose 5"
        dt_meds_str_5="Medication Start Date 5"
        dt_meds_stp_5="Medication Stop Date 5"
        meds_6="Medication 6"
        med_code_6="Medication Code 6"
        meds_dose_6="Medication Daily Dose 6"
        dt_meds_str_6="Medication Start Date 6"
        dt_meds_stp_6="Medication Stop Date 6"
        meds_7="Medication 7"
        med_code_7="Medication Code 7"
        meds_dose_7="Medication Daily Dose 7"
        dt_meds_str_7="Medication Start Date 7"
        dt_meds_stp_7="Medication Stop Date 7"
        meds_8="Medication 8"
        med_code_8="Medication Code 8"
        meds_dose_8="Medication Daily Dose 8"
        dt_meds_str_8="Medication Start Date 8"
        dt_meds_stp_8="Medication Stop Date 8"
        meds_9="Medication 9"
        med_code_9="Medication Code 9"
        meds_dose_9="Medication Daily Dose 9"
        dt_meds_str_9="Medication Start Date 9"
        dt_meds_stp_9="Medication Stop Date 9"
        meds_10="Medication 10"
        med_code_10="Medication Code 10"
        meds_dose_10="Medication Daily Dose 10"
        dt_meds_str_10="Medication Start Date 10"
        dt_meds_stp_10="Medication Stop Date 10"
        meds_11="Medication 11"
        med_code_11="Medication Code 11"
        meds_dose_11="Medication Daily Dose 11"
        dt_meds_str_11="Medication Start Date 11"
        dt_meds_stp_11="Medication Stop Date 11"
        meds_12="Medication 12"
        med_code_12="Medication Code 12"
        meds_dose_12="Medication Daily Dose 12"
        dt_meds_str_12="Medication Start Date 12"
        dt_meds_stp_12="Medication Stop Date 12"
        meds_13="Medication 13"
        med_code_13="Medication Code 13"
        meds_dose_13="Medication Daily Dose 13"
        dt_meds_str_13="Medication Start Date 13"
        dt_meds_stp_13="Medication Stop Date 13"
        meds_14="Medication 14"
        med_code_14="Medication Code 14"
        meds_dose_14="Medication Daily Dose 14"
        dt_meds_str_14="Medication Start Date 14"
        dt_meds_stp_14="Medication Stop Date 14"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";


proc sort data= glnd.plate19; by id ; run;

proc print data= glnd.plate19;
	by id;
run;

