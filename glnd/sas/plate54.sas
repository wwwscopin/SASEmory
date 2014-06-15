/* CREATED BY: esrose2 Aug 11,2009 15:56PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */


filename data1 '/dfax/glnd/sas/plate54.d01';
data glnd.plate54(label="Adjudicated New Infection, Pg 3/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat narrative $CHAR500. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  site_code $  type_code $  same_site  two_wk_interval
        reso_int_infect  combo_new_signs  complete_antib  bsi_bld_cult
        narrative $  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
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
        site_code="3.1 Site code"
        type_code="3.1 Type code"
        same_site="4.1 Infection same site?"
        two_wk_interval="4.2.A Two week interval?"
        reso_int_infect="4.2.B Resolution int. inf"
        combo_new_signs="4.2.C Combo new signs/sym"
        complete_antib="4.2.D Complete antibiotic"
        bsi_bld_cult="4.2.E BSI neg blood cult"
        narrative="Narrative"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
