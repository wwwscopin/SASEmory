/* CREATED BY: aknezev Jun 10,2010 16:22PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
options YEARCUTOFF=1920;

filename data1 '/dfax/ttcmv/sas/programs/data_mgt/plate_021.d01';
data cmv.plate_021(label="LBWI Week XX Summary Pg 2 of 3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat ROPExamDate MMDDYY8. ;  format ROPExamDate  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        MOCInit $  RBCTx  PlateletTx  FFPTx  CryoTx  GranulocyteTx
        AdvReactionStatus  CMVDisStatus  ROPExamStatus  ROPExamDate
        Retinopathy  PDA  IVH  NEC  BPD  Infection  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  label id="TTCMV LBWI ID "
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        MOCInit="MOC Initials"
        RBCTx="RBC Tx"
        PlateletTx="Platelet Tx"
        FFPTx="FFP Tx"
        CryoTx="Cryoprecipitate Tx"
        GranulocyteTx="Granulocyte Tx"
        AdvReactionStatus="Adverse Reaction Status"
        CMVDisStatus="CMV Disease Status"
        ROPExamStatus="ROP Exam done?"
        ROPExamDate="ROP Exam Date"
        Retinopathy="LBWI diagnosed with ROP?"
        PDA="PDA"
        IVH="IVH"
        NEC="NEC"
        BPD="BPD"
        Infection="Infection"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
