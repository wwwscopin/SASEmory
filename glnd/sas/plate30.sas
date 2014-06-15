/* CREATED BY: esrose2 May 03,2007 11:24AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate30.d01';
data glnd.plate30(label="Day 7 Follow-Up Form, Pg 4/5");
   infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  tot_pn  oral_prot  pn_aa_g  oral_kcal  pn_aa_kcal
        iv_kcal  pn_lipid  prop_kcal  pn_cho  tot_aa  tube_prot
        tot_kcal  tube_kcal  tot_insulin  gluc_eve  eve_gluc_src
        time_gluc_eve $  gluc_mrn  mrn_gluc_src  time_gluc_mrn $
        gluc_aft  aft_gluc_src  time_gluc_aft $  sofa_resp  sofa_coag
        sofa_liver  sofa_cardio  sofa_cns  sofa_renal  sofa_tot
        nar_prov  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format eve_gluc_src gluc_src.  ;
  format mrn_gluc_src gluc_src.  ;
  format aft_gluc_src gluc_src.  ;
  format nar_prov yn.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        tot_pn="1.A.1 Total infused PN"
        oral_prot="1.A.8 Oral food protein"
        pn_aa_g="1.A.2 PN amino acid grams"
        oral_kcal="1.A.9 Oral food kcal"
        pn_aa_kcal="1.A.3 PN amino acid kcal"
        iv_kcal="1.A.10 IV fluids kcal"
        pn_lipid="1.A.4 PN lipid"
        prop_kcal="1.A.11 Propofol kcal"
        pn_cho="1.A.5 PN CHO"
        tot_aa="1.A.12 Total protein/AA"
        tube_prot="1.A.6 Tube feeding prot."
        tot_kcal="1.A.13 Total kcal"
        tube_kcal="1.A.7 Tube feeding kcal"
        tot_insulin="1.A.14 Total insulin"
        gluc_eve="1.B.1 Eve blood glucose"
        eve_gluc_src="1.B.1 Evening Gluc Src"
        time_gluc_eve="1.B.1 Eve bld. gluc. time"
        gluc_mrn="1.B.2 Mrn blood glucose"
        mrn_gluc_src="1.B.2 Morning Gluc Src"
        time_gluc_mrn="1.B.2 Mrn bld. gluc. time"
        gluc_aft="1.B.3 Aft blood glucose"
        aft_gluc_src="1.B.3 Afternoon Gluc Src"
        time_gluc_aft="1.B.3 Aft bld. gluc. time"
        sofa_resp="1.C.1 SOFA respiration"
        sofa_coag="1.C.2 SOFA coagulation"
        sofa_liver="1.C.3 SOFA liver"
        sofa_cardio="1.C.2 SOFA cardiovascular"
        sofa_cns="1.C.5 SOFA CNS"
        sofa_renal="1.C.6 SOFA renal"
        sofa_tot="1.C SOFA total"
        nar_prov="Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

 * recode 99 as missing ;
  if nar_prov = 99 then nar_prov = . ;
  if gluc_eve = 999 then gluc_eve= .;
  if gluc_mrn = 999 then gluc_mrn= .;
  if gluc_aft = 999 then gluc_aft= .;
  if eve_gluc_src = 99 then eve_gluc_src = .;
  if mrn_gluc_src = 99 then mrn_gluc_src = .;
  if aft_gluc_src = 99 then aft_gluc_src = .;

proc print;
