/* CREATED BY: gcotson Jul 04,2007 22:00PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate16.d01';
data glnd.plate16(label="Day XX Plasma & Serum Storage Form, Pg 2/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  bld_cyto1  bld_cyto2  bld_xtra_e  bld_hsp70  bld_hsp27
        bld_xtra_f  bld_antiflag  bld_antilps  bld_xtra_g  nar_prov
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format bld_cyto1 yn.  ;
  format bld_cyto2 yn.  ;
  format bld_xtra_e yn.  ;
  format bld_hsp70 yn.  ;
  format bld_hsp27 yn.  ;
  format bld_xtra_f yn.  ;
  format bld_antiflag yn.  ;
  format bld_antilps yn.  ;
  format bld_xtra_g yn.  ;
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
        bld_cyto1="2.E.1 Blood CYTO1"
        bld_cyto2="2.E.2 Blood CYTO2"
        bld_xtra_e="2.E.3 Blood xtra E"
        bld_hsp70="2.F.1 Blood HSP70"
        bld_hsp27="2.F.2 Blood HSP27"
        bld_xtra_f="2.F.3 Blood xtra F"
        bld_antiflag="2.G.1 Blood Anti-FLAG"
        bld_antilps="2.G.2 Blood Anti-LPS"
        bld_xtra_g="2.G.3 Blood xtra G"
        nar_prov="Narrative provided"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  if bld_cyto1 = 99 then bld_cyto1 = .  ;
  if bld_cyto2 = 99 then bld_cyto2= .  ;
  if bld_xtra_e = 99 then bld_xtra_e= .  ;
  if bld_hsp70 = 99 then bld_hsp70= .  ;
  if bld_hsp27 = 99 then bld_hsp27= .  ;
  if bld_xtra_f = 99 then bld_xtra_f= .  ;
  if bld_antiflag = 99 then bld_antiflag= .  ;
  if bld_antilps = 99 then bld_antilps= .  ;
  if bld_xtra_g = 99 then bld_xtra_g= .  ;
  if nar_prov = 99 then nar_prov= .  ;

proc print;
