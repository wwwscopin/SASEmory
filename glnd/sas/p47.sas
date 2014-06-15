/* CREATED BY: esrose2 Mar 06,2009 09:38AM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */


filename data1 '/dfax/glnd/sas/plate47.d01';
data glnd.plate47(label="Immune Function Values, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY10. ;  format dfc      MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  ros_prod_cont  ros_prod_stim
        phago_cont  phago_stim  cd4_unstim_per  cd4_unstim_num
        cd4_stim_per  cd4_stim_num  cd8_unstim_per  cd8_unstim_num
        cd8_stim_per  cd8_stim_num  cd4ifn_unstim_per
        cd4ifn_unstim_num  cd4ifn_stim_per  cd4ifn_stim_num
        cd4tfn_unstim_per  cd4tfn_unstim_num  cd4tfn_stim_per
        cd4tfn_stim_num  cd8ifn_unstim_per  cd8ifn_unstim_num
        cd8ifn_stim_per  cd8ifn_stim_num  cd8tfn_unstim_per
        cd8tfn_unstim_num  cd8tfn_stim_per  cd8tfn_stim_num
        cd4lsel_unstim_per  cd4lsel_unstim_num  cd4lsel_stim_per
        cd4lsel_stim_num  cd8lsel_unstim_per  cd8lsel_unstim_num
        cd8lsel_stim_per  cd8lsel_stim_num  bcell_unstim_per
        bcell_unstim_num  bcell_stim_per  bcell_stim_num  cd3_per
        cd3_num  cd14_per  cd14_num  DFSCREEN  DFCREATE $  DFMODIFY $ ;
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
        ros_prod_cont="A1. ROS Production Cont"
        ros_prod_stim="A1. ROS Production Stim"
        phago_cont="A2. Phagocytosis Control"
        phago_stim="A2. Phagocytosis Stim."
        cd4_unstim_per="B1. CD4 Unstim %"
        cd4_unstim_num="B1. CD4 Unstim #"
        cd4_stim_per="B1. CD4 Stim %"
        cd4_stim_num="B1. CD4 Stim #"
        cd8_unstim_per="B2. CD8 Unstim %"
        cd8_unstim_num="B2. CD8 Unstim #"
        cd8_stim_per="B2. CD8 Stim %"
        cd8_stim_num="B2. CD8 Stim #"
        cd4ifn_unstim_per="B3. CD4 IFN Unstim %"
        cd4ifn_unstim_num="B3. CD4 IFN Unstim #"
        cd4ifn_stim_per="B3. CD4 IFN Stim %"
        cd4ifn_stim_num="B3. CD4 IFN Stim #"
        cd4tfn_unstim_per="B4. CD4 TNF Unstim %"
        cd4tfn_unstim_num="B4. CD4 TNF Unstim #"
        cd4tfn_stim_per="B4. CD4 TNF Stim %"
        cd4tfn_stim_num="B4. CD4 TNF Stim #"
        cd8ifn_unstim_per="B5. CD8 IFN Unstim %"
        cd8ifn_unstim_num="B5. CD8 IFN Unstim #"
        cd8ifn_stim_per="B5. CD8 IFN Stim %"
        cd8ifn_stim_num="B5. CD8 IFN Stim #"
        cd8tfn_unstim_per="B6. CD8 TNF Unstim %"
        cd8tfn_unstim_num="B6. CD8 TNF Unstim #"
        cd8tfn_stim_per="B6. CD8 TNF Stim %"
        cd8tfn_stim_num="B6. CD8 TNF Stim #"
        cd4lsel_unstim_per="B7. CD4 L Sel Unstim %"
        cd4lsel_unstim_num="B7. CD4 L Sel Unstim #"
        cd4lsel_stim_per="B7. CD4 L Sel Stim %"
        cd4lsel_stim_num="B7. CD4 L Sel Stim #"
        cd8lsel_unstim_per="B8. CD8 L Sel Unstim %"
        cd8lsel_unstim_num="B8. CD8 L Sel Unstim #"
        cd8lsel_stim_per="B8. CD8 L Sel Stim %"
        cd8lsel_stim_num="B8. CD8 L Sel Stim #"
        bcell_unstim_per="B9. B Cell Lymph Unstim %"
        bcell_unstim_num="B9. B Cell Lymph Unstim #"
        bcell_stim_per="B9. B Cell Lymph Stim %"
        bcell_stim_num="B9. B Cell Lymph Stim #"
        cd3_per="B10. CD3 %"
        cd3_num="B10. CD3 #"
        cd14_per="B11. CD14 %"
        cd14_num="B11. CD14 #"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
run;

proc contents data = glnd.plate47;
run;

proc print data = glnd.plate47;
run;

proc means data = glnd.plate47 n;
	class dfseq;
run;

