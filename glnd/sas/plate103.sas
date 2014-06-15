/* CREATED BY: esrose2 Feb 20,2007 12:58PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;



filename data1 '/dfax/glnd/sas/plate103.d01';
data glnd.plate103(label="Suspected Nosocomial Infection, Pg 3/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  infect_confirm  site_code $  type_code $  same_site
        two_wk_interval  reso_int_infect  combo_new_signs  complete_antib
        bsi_bld_cult  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format infect_confirm infect_confirm.  ;
  format same_site yn.  ;
  format two_wk_interval yn.  ;
  format reso_int_infect yn.  ;
  format combo_new_signs yn.  ;
  format complete_antib yn.  ;
  format bsi_bld_cult bsi_bld_cult.  ;
  format site_code $site_code.;
  format type_code $type_code.;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        infect_confirm="3.1 Infection confirmed?"
        site_code="3.1 Site code"
        type_code="3.1 Type code"
        same_site="4.1 Infection same site?"
        two_wk_interval="4.2.A Two week interval?"
        reso_int_infect="4.2.B Resolution int. inf"
        combo_new_signs="4.2.C Combo new signs/sym"
        complete_antib="4.2.D Complete antibiotic"
        bsi_bld_cult="4.2.E BSI blood cultures?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";


if infect_confirm = 99 then infect_confirm = .  ;
 if same_site = 99 then same_site = .  ;
 if two_wk_interval = 99 then two_wk_interval = .  ;
 if reso_int_infect = 99 then reso_int_infect = .  ;
 if combo_new_signs = 99 then combo_new_signs = .  ;
 if complete_antib = 99 then complete_antib = .  ;
 if bsi_bld_cult = 99 then bsi_bld_cult = .  ;

proc print;
