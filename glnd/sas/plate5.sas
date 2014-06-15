/* CREATED BY: gcotson Sep 25,2006 11:07AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate5.d01';
data plate5(label="Apache II Scoring, Pg 3/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  eye_open  verb_resp  motor_resp  age_score  
      DFSCREEN  DFCREATE $  DFMODIFY $ ;  
   format DFSTATUS DFSTATv. ;
  format eye_open gcs1v.  ;
  format verb_resp gcs2v.  ;
  format motor_resp gcs3v.  ;
  format age_score gcs4v.  ;
   array junk(4) eye_open verb_resp motor_resp age_score;
   do i=1 to 4;
      if junk(i)=99 then junk(i)=.;
   end;
   drop i;
   
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        eye_open="1.B.1 GCS eye opening"
        verb_resp="1.B.2 GCS verbal response"
        motor_resp="1.B.3 GCS motor response"
        age_score="2. Age Score"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

        data glnd.plate5;
         set plate5;
         if dfseq=0;
         run;
         proc freq;
          tables id;
          run;
         data glnd.plate5b;
         set plate5;
         if dfseq ne 0;
         run;