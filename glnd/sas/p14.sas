/* CREATED BY: gcotson Apr 06,2012 10:38AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */



filename data1 '/dfax/glnd/sas/plate14.d01';
data glnd.plate14(label="PN Amino Acid Composition - 1st Calculation, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY10. ;  format dfc      MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  tot_pn_aa_2  ag_dipep_1  pn_vol_goal_2
        ag_pn_ratio_1  ag_pn_ratio_2  ag_dipep_pn  ag_dipep_pn_fin
        tot_pn_aa_3  ag_dipep_2  clinisol_pc  pn_vol_goal_3
        clin_pc_pn_ratio_1  clin_pc_pn_ratio_2  clin_ag_pn
        clin_ag_pn_fin  tot_pn_aa_4  clinisol_g  pn_vol_goal_4
        clin_g_pn_ratio_1  clin_g_pn_ratio_2  clin_std_pn
        clin_std_pn_fin  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        tot_pn_aa_2="1.A Total PN amino acid"
        ag_dipep_1="1.B 20% AG dipeptide"
        pn_vol_goal_2="1.C PN volume goal"
        ag_pn_ratio_1="1.D AG PN ratio"
        ag_pn_ratio_2="1.E AG PN ratio"
        ag_dipep_pn="1.F AG dipeptide in PN"
        ag_dipep_pn_fin="1.G AG dipeptide"
        tot_pn_aa_3="2.A Total PN amino acid"
        ag_dipep_2="2.B 20% AG dipeptide"
        clinisol_pc="2.C 15% Clinisol"
        pn_vol_goal_3="2.D PN volume goal"
        clin_pc_pn_ratio_1="2.E Clinisol PN ratio"
        clin_pc_pn_ratio_2="2.F Clinisol PN ratio"
        clin_ag_pn="2.G Clinisol AG-PN"
        clin_ag_pn_fin="2.H Clinisol AG-PN"
        tot_pn_aa_4="3.A Total PN amino acid"
        clinisol_g="3.B Clinisol"
        pn_vol_goal_4="3.C PN volume goal"
        clin_g_pn_ratio_1="3.D Clinisol PN ratio"
        clin_g_pn_ratio_2="3.E Clinisol PN ratio"
        clin_std_pn="3.F Clinisol in STD-PN"
        clin_std_pn_fin="3.G Clinisol in STD-PN"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

proc means;
