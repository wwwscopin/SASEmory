/* CREATED BY: aknezev Dec 02,2010 12:39PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_123.d01';
data cmv.nec_image_case3(label="NEC image x Case 3 p1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat ImageDate MMDDYY8. ;  format ImageDate  MMDDYY8. ;
  informat OtherFinding $CHAR150. ;
  informat Impression $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  ImageDate
        ImageTime $  ImageType  IntestinalDistension  BowelLoop
        SmallBowelSeparation  PneumoIntestinalis  PortalVeinGas
        Pneumoperitoneum  Other  OtherFinding $  Impression $
        Narrative  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        FormCompletedBy="Form Completed By"
        DateFormCompl="Date form Completed by is Required"
        ImageDate="Image Date"
        ImageTime="Image Time"
        ImageType="Image Type"
        IntestinalDistension="Intestinal Distension"
        BowelLoop="Bowel Loop"
        SmallBowelSeparation="Small Bowel Separation"
        PneumoIntestinalis="Pneumo Intestinalis"
        PortalVeinGas="Portal Vein Gas"
        Pneumoperitoneum="Pneumoperitoneum"
        Other="Other"
        OtherFinding="Other Finding"
        Impression="Image Impression"
        Narrative="Narrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
