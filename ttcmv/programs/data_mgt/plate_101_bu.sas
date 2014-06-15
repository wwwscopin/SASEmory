/* CREATED BY: aknezev Apr 06,2010 15:17PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_101_bu.d01';
data cmv.plate_101_bu(label="Patient Screen Log");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateScreened_1 MMDDYY8. ;  format DateScreened_1  MMDDYY8. ;
  informat Notes_1  $CHAR50. ;
  informat DateScreened_2 MMDDYY8. ;  format DateScreened_2  MMDDYY8. ;
  informat Notes_2  $CHAR50. ;
  informat DateScreened_3 MMDDYY8. ;  format DateScreened_3  MMDDYY8. ;
  informat Notes_3  $CHAR50. ;
  informat DateScreened_4 MMDDYY8. ;  format DateScreened_4  MMDDYY8. ;
  informat Notes_4  $CHAR50. ;
  informat DateScreened_5 MMDDYY8. ;  format DateScreened_5  MMDDYY8. ;
  informat Notes_5  $CHAR50. ;
  informat DateScreened_6 MMDDYY8. ;  format DateScreened_6  MMDDYY8. ;
  informat Notes_6  $CHAR50. ;
  informat DateScreened_7 MMDDYY8. ;  format DateScreened_7  MMDDYY8. ;
  informat Notes_7  $CHAR50. ;
  informat DateScreened_8 MMDDYY8. ;  format DateScreened_8  MMDDYY8. ;
  informat Notes_8  $CHAR50. ;
  informat DateScreened_9 MMDDYY8. ;  format DateScreened_9  MMDDYY8. ;
  informat Notes_9  $CHAR50. ;
  informat DateScreened_10 MMDDYY8. ;  format DateScreened_10  MMDDYY8. ;
  informat Notes_10 $CHAR50. ;
  informat DateScreened_11 MMDDYY8. ;  format DateScreened_11  MMDDYY8. ;
  informat Notes_11 $CHAR50. ;
  informat DateScreened_12 MMDDYY8. ;  format DateScreened_12  MMDDYY8. ;
  informat Notes_12 $CHAR50. ;
  informat DateScreened_13 MMDDYY8. ;  format DateScreened_13  MMDDYY8. ;
  informat Notes_13 $CHAR50. ;
  informat DateScreened_14 MMDDYY8. ;  format DateScreened_14  MMDDYY8. ;
  informat Notes_14 $CHAR50. ;
  informat DateScreened_15 MMDDYY8. ;  format DateScreened_15  MMDDYY8. ;
  informat Notes_15 $CHAR50. ;
  informat DateScreened_16 MMDDYY8. ;  format DateScreened_16  MMDDYY8. ;
  informat Notes_16 $CHAR50. ;
  informat DateScreened_17 MMDDYY8. ;  format DateScreened_17  MMDDYY8. ;
  informat Notes_17 $CHAR50. ;
  informat DateScreened_18 MMDDYY8. ;  format DateScreened_18  MMDDYY8. ;
  informat Notes_18 $CHAR50. ;
  informat DateScreened_19 MMDDYY8. ;  format DateScreened_19  MMDDYY8. ;
  informat Notes_19 $CHAR50. ;
  informat DateScreened_20 MMDDYY8. ;  format DateScreened_20  MMDDYY8. ;
  informat Notes_20 $CHAR50. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input DCCUnitId  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        DFSEQ  MOCId_1  DateScreened_1  Enrolled_1  LBWI_id_1  Notes_1 $
        MOCId_2  DateScreened_2  Enrolled_2  LBWI_id_2  Notes_2 $
        MOCId_3  DateScreened_3  Enrolled_3  LBWI_id_3  Notes_3 $
        MOCId_4  DateScreened_4  Enrolled_4  LBWI_id_4  Notes_4 $
        MOCId_5  DateScreened_5  Enrolled_5  LBWI_id_5  Notes_5 $
        MOCId_6  DateScreened_6  Enrolled_6  LBWI_id_6  Notes_6 $
        MOCId_7  DateScreened_7  Enrolled_7  LBWI_id_7  Notes_7 $
        MOCId_8  DateScreened_8  Enrolled_8  LBWI_id_8  Notes_8 $
        MOCId_9  DateScreened_9  Enrolled_9  LBWI_id_9  Notes_9 $
        MOCId_10  DateScreened_10  Enrolled_10  LBWI_id_10  Notes_10 $
        MOCId_11  DateScreened_11  Enrolled_11  LBWI_id_11  Notes_11 $
        MOCId_12  DateScreened_12  Enrolled_12  LBWI_id_12  Notes_12 $
        MOCId_13  DateScreened_13  Enrolled_13  LBWI_id_13  Notes_13 $
        MOCId_14  DateScreened_14  Enrolled_14  LBWI_id_14  Notes_14 $
        MOCId_15  DateScreened_15  Enrolled_15  LBWI_id_15  Notes_15 $
        MOCId_16  DateScreened_16  Enrolled_16  LBWI_id_16  Notes_16 $
        MOCId_17  DateScreened_17  Enrolled_17  LBWI_id_17  Notes_17 $
        MOCId_18  DateScreened_18  Enrolled_18  LBWI_id_18  Notes_18 $
        MOCId_19  DateScreened_19  Enrolled_19  LBWI_id_19  Notes_19 $
        MOCId_20  DateScreened_20  Enrolled_20  LBWI_id_20  Notes_20 $
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label DCCUnitId="Site Id"
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCId_1="MOC Id Row 1"
        DateScreened_1="Date Screened Row 1"
        Enrolled_1="If patient enrolled"
        LBWI_id_1="LBWI_id_1"
        Notes_1="Notes_1"
        MOCId_2="MOC Id Row 2"
        DateScreened_2="Date Screened Row 2"
        Enrolled_2="If patient enrolled"
        LBWI_id_2="LBWI_id_2"
        Notes_2="Notes_2"
        MOCId_3="MOC Id Row 3"
        DateScreened_3="Date Screened Row 3"
        Enrolled_3="If patient enrolled"
        LBWI_id_3="LBWI_id_3"
        Notes_3="Notes_3"
        MOCId_4="MOC Id Row 4"
        DateScreened_4="Date Screened Row 4"
        Enrolled_4="If patient enrolled"
        LBWI_id_4="LBWI_id_4"
        Notes_4="Notes_4"
        MOCId_5="MOC Id Row 5"
        DateScreened_5="Date Screened Row 5"
        Enrolled_5="If patient enrolled"
        LBWI_id_5="LBWI_id_5"
        Notes_5="Notes_5"
        MOCId_6="MOC Id Row 6"
        DateScreened_6="Date Screened Row 6"
        Enrolled_6="If patient enrolled"
        LBWI_id_6="LBWI_id_6"
        Notes_6="Notes_6"
        MOCId_7="MOC Id Row 7"
        DateScreened_7="Date Screened Row 7"
        Enrolled_7="If patient enrolled"
        LBWI_id_7="LBWI_id_7"
        Notes_7="Notes_7"
        MOCId_8="MOC Id Row 8"
        DateScreened_8="Date Screened Row 8"
        Enrolled_8="If patient enrolled"
        LBWI_id_8="LBWI_id_8"
        Notes_8="Notes_8"
        MOCId_9="MOC Id Row 9"
        DateScreened_9="Date Screened Row 9"
        Enrolled_9="If patient enrolled"
        LBWI_id_9="LBWI_id_9"
        Notes_9="Notes_9"
        MOCId_10="MOC Id Row 10"
        DateScreened_10="Date Screened Row 10"
        Enrolled_10="If patient enrolled"
        LBWI_id_10="LBWI_id_10"
        Notes_10="Notes_10"
        MOCId_11="MOC Id Row 11"
        DateScreened_11="Date Screened Row 11"
        Enrolled_11="If patient enrolled"
        LBWI_id_11="LBWI_id_11"
        Notes_11="Notes_11"
        MOCId_12="MOC Id Row 12"
        DateScreened_12="Date Screened Row 12"
        Enrolled_12="If patient enrolled"
        LBWI_id_12="LBWI_id_12"
        Notes_12="Notes_12"
        MOCId_13="MOC Id Row 13"
        DateScreened_13="Date Screened Row 13"
        Enrolled_13="If patient enrolled"
        LBWI_id_13="LBWI_id_13"
        Notes_13="Notes_13"
        MOCId_14="MOC Id Row 14"
        DateScreened_14="Date Screened Row 14"
        Enrolled_14="If patient enrolled"
        LBWI_id_14="LBWI_id_14"
        Notes_14="Notes_14"
        MOCId_15="MOC Id Row 15"
        DateScreened_15="Date Screened Row 15"
        Enrolled_15="If patient enrolled"
        LBWI_id_15="LBWI_id_15"
        Notes_15="Notes_15"
        MOCId_16="MOC Id Row 16"
        DateScreened_16="Date Screened Row 16"
        Enrolled_16="If patient enrolled"
        LBWI_id_16="LBWI_id_16"
        Notes_16="Notes_16"
        MOCId_17="MOC Id Row 17"
        DateScreened_17="Date Screened Row 17"
        Enrolled_17="If patient enrolled"
        LBWI_id_17="LBWI_id_17"
        Notes_17="Notes_17"
        MOCId_18="MOC Id Row 18"
        DateScreened_18="Date Screened Row 18"
        Enrolled_18="If patient enrolled"
        LBWI_id_18="LBWI_id_18"
        Notes_18="Notes_18"
        MOCId_19="MOC Id Row 19"
        DateScreened_19="Date Screened Row 19"
        Enrolled_19="If patient enrolled"
        LBWI_id_19="LBWI_id_19"
        Notes_19="Notes_19"
        MOCId_20="MOC Id Row 20"
        DateScreened_20="Date Screened Row 20"
        Enrolled_20="If patient enrolled"
        LBWI_id_20="LBWI_id_20"
        Notes_20="Notes_20"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
