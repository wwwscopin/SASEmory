/* CREATED BY: esrose2 Jan 11,2007 11:17AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate12.d01';
data glnd.plate12(label="PN Calorie and Macronutrient Composition, Pg 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  non_aa_2  tot_iv_lip  propofol  pos_neg  iv_lip_a
        iv_neg  iv_lip_b  dex_eq  pn_vol_goal_2  dx_ratio
        dex_eq_conc_1  pn_dex_conc_2  dex_eq_conc_2  fin_pn_dex_conc
        fin_pn_dex_gl  iv_lip_c  intralipid  inf_hrs  iv_lip_rate
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format pos_neg  pos_neg.  ;
  format iv_neg   yn.  ;
  format inf_hrs  inf_hrs  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        non_aa_2="3.A Non-amino acid"
        tot_iv_lip="3.B Total IV lipid"
        propofol="3.C Propofol"
        pos_neg="Positive or negative?"
        iv_lip_a="3.D IV lipid"
        iv_neg="3.E IV value negative?"
        iv_lip_b="4.A IV lipid"
        dex_eq="4.B Dextrose equivalent"
        pn_vol_goal_2="4.C PN volume goal"
        dx_ratio="4.D Dextrose ratio"
        dex_eq_conc_1="4.E Dextrose eq. conc."
        pn_dex_conc_2="4.F PN dextrose conc."
        dex_eq_conc_2="4.G Dextrose eq. conc."
        fin_pn_dex_conc="4.H Final PN dextrose"
        fin_pn_dex_gl="4.I Final PN dextrose"
        iv_lip_c="5.A IV lipid"
        intralipid="5.B 20% Intralipid"
        inf_hrs="Infusion hours?"
        iv_lip_rate="5.C IV lipid rate"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
        
  * recode 99 as missing;
  if pos_neg = 99 then pos_neg = . ;
  if iv_neg = 99 then iv_neg = .  ;
  if inf_hrs = 99 then inf_hrs = .  ;
  
        proc print data= glnd.plate12;
        run;
        quit;
