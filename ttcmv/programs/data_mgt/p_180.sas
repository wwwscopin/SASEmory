/* CREATED BY: nshenvi Nov 30,2010 11:06AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_180.d01';
data cmv.ivh_image(label="IVH Image x/X Case 1 P1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DateFormCompl MMDDYY8. ;  format DateFormCompl  MMDDYY8. ;
  informat ImageDate MMDDYY8. ;  format ImageDate  MMDDYY8. ;
  informat Impression $CHAR1000. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  FormCompletedBy $  DateFormCompl  ImageDate
        ImageTime $  ImageType  LeftHemorrhage  LTGerminalHemo
        LTIntraVentHemo  LTVentDilation  LTSubduralHemo  LTSubaralHemo
        LTIntraparenHemo  LeftIVHGrade  LeftCerebellarHemo
        LeftPostFossaHemo  LeftPeriLeuko  RightHemorrhage
        RTGerminalHemo  RTIntraVentHemo  RTVentDilation  RTSubduralHemo
        RTSubaralHemo  RTIntraparenHemo  RightIVHGrade
        RightCerebellarHemo  RightPostFossaHemo  RightPeriLeuko
        Impression $  IsNarrative  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  
        
        run;
