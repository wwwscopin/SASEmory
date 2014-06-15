/* CREATED BY: gcotson Jul 04,2007 22:00PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate15.d01';
data glnd.plate15(label="Day XX Plasma & Serum Storage Form, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_bld_str MMDDYY8. ;  format dt_bld_str  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  missed_blood_drw  dt_bld_str
        time_bld_draw $  typ_bld_draw  bld_gsh  bld_cys  bld_chem
        bld_crp  bld_xtra_b  bld_gln  bld_glu  bld_xtra_c  bld_flag
        bld_lps  bld_xtra_d  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format missed_blood_drw mark_box.  ;
  format typ_bld_draw typ_bld_draw.  ;
  format bld_gsh  yn.  ;
  format bld_cys  yn.  ;
  format bld_chem yn.  ;
  format bld_crp  yn.  ;
  format bld_xtra_b yn.  ;
  format bld_gln  yn.  ;
  format bld_glu  yn.  ;
  format bld_xtra_c yn.  ;
  format bld_flag yn.  ;
  format bld_lps  yn.  ;
  format bld_xtra_d yn.  ;
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
        missed_blood_drw="Missed Blood Draw"
        dt_bld_str="1.1 Date blood stored"
        time_bld_draw="1.2 Time of blood draw"
        typ_bld_draw="1.3 Type of blood draw"
        bld_gsh="2.A.1 Blood GSH"
        bld_cys="2.A.2 Blood CyS"
        bld_chem="2.B.1 Blood Chem"
        bld_crp="2.B.2 Blood CRP"
        bld_xtra_b="2.B.3 Blood xtra B"
        bld_gln="2.C.1 Blood GLN"
        bld_glu="2.C.2 Blood GLU"
        bld_xtra_c="2.C.3 Blood xtra C"
        bld_flag="2.D.1 Blood FLAG"
        bld_lps="2.D.2 Blood LPS"
        bld_xtra_d="2.D.1 Blood xtra D"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  if typ_bld_draw  = 99 then typ_bld_draw = .   ;
  if bld_gsh = 99 then bld_csh = .  ;
  if bld_cys   = 99 then bld_cys= .  ;
  if bld_chem  = 99 then bld_chem= .  ;
  if bld_crp   = 99 then bld_crp= .  ;
  if bld_xtra_b  = 99 then bld_xtra_b= .  ;
  if bld_gln   = 99 then bld_gln= .  ;
  if bld_glu   = 99 then bld_glu= .  ;
  if bld_xtra_c  = 99 then bld_xtra_c= .  ;
  if bld_flag  = 99 then bld_flag= .  ;
  if bld_lps   = 99 then bld_lps= .  ;
  if bld_xtra_d  = 99 then bld_xtra_d= .  ;

proc print;
