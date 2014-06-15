/* CREATED BY: aknezev Feb 16,2010 09:50AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_006.d01';
data cmv.plate_006(label="LBWI Demographic P 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  GestAge  BirthWeight  Length  HeadCircum  Apgar1Min
        Apgar5Min  BirthResus  BirthResusOxygen  BirthResusCompression
        BirthResusCPAP  BirthResusEpi  BirthResusInutbation
        BirthResusMask  IsBloodGas  CordPh  BaseDeficit  BloodGasType
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format DFSCREEN DFSCRNv. ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        GestAge="Gestational Age (weeks)"
        BirthWeight="LBWI Birth Weight (g)"
        Length="LBWI birth length (cm)"
        HeadCircum="LBWI Head Circumference (cm)"
        Apgar1Min="LBWI Apgar 1-min score"
        Apgar5Min="LBWI Apgar 5-min score"
        BirthResus="LBWI Birth Resuscitation"
        BirthResusOxygen="Birth Resuscitation by Oxygen"
        BirthResusCompression="Birth Resuscitation by Chest Compression"
        BirthResusCPAP="Birth Resuscitation by CPAP"
        BirthResusEpi="Birth Resuscitation by Epinephrine"
        BirthResusInutbation="Birth Resuscitation by Inutbation"
        BirthResusMask="Birth Resuscitation by Bagging and Mask"
        IsBloodGas="Blood Gas done"
        CordPh="Cord pH"
        BaseDeficit="Base Deficit"
        BloodGasType="Blood Gas (venous/arterial)"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
