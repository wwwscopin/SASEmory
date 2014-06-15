/* CREATED BY: esrose2 Jan 11,2007 11:12AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate11.d01';
data glnd.plate11(label="PN Calorie and Macronutrient Composition, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  bbe  tot_kcal_goal  tot_en  tot_pn_1
        bod_weight  tot_prot_1  tot_prot_2  tot_en_prot  tot_pn_aa_1
        pn_aa_1  tot_pn_2  pn_aa_2  non_aa_1  tot_iv_dex_all_1
        tot_iv_dex_all_2  tot_iv_dex  dex_iv  pn_dex_1  pn_dex_2
        pn_vol_goal_1  pn_ratio  pn_dex_conc_1  pn_dex_fin  DFSCREEN
        DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
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
        dfc="Date Form Completed"
        bbe="1.A BBE"
        tot_kcal_goal="1.B Total kcal goal"
        tot_en="1.C Total EN"
        tot_pn_1="1.D Total PN"
        bod_weight="1.E Body Weight"
        tot_prot_1="1.F Total protein"
        tot_prot_2="1.G Total protein"
        tot_en_prot="1.H Total EN protein"
        tot_pn_aa_1="1.I Total PN amino acid"
        pn_aa_1="1.J PN amino acid"
        tot_pn_2="2.A Total PN"
        pn_aa_2="2.B PN amino acid"
        non_aa_1="2.C Non-amino acid"
        tot_iv_dex_all_1="2.D Total IV dextrose all"
        tot_iv_dex_all_2="2.E Total IV dextrose all"
        tot_iv_dex="2.F Total IV dextrose"
        dex_iv="2.G Dextrose IV fluids"
        pn_dex_1="2.H PN dextrose"
        pn_dex_2="2.I PN dextrose"
        pn_vol_goal_1="2.J PN volume goal"
        pn_ratio="2.K PN ratio"
        pn_dex_conc_1="2.l PN dextrose conc."
        pn_dex_fin="2.M PN dextrose final"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

proc print data= glnd.plate11;
run;
quit;