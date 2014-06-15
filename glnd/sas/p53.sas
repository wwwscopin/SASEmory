/* CREATED BY: esrose2 Aug 11,2009 15:58PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */


filename data1 '/dfax/glnd/sas/plate53.d01';
data glnd.plate53(label="Adjudicated New Infection, Pg 2/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat org_spec_2 $CHAR30. ;
  informat dt_cult_rec_2 MMDDYY10. ;  format dt_cult_rec_2 MMDDYY10. ;
  informat dt_cult_rep_fax_2 MMDDYY10. ;  format dt_cult_rep_fax_2 MMDDYY10. ;
  informat org_spec_3 $CHAR30. ;
  informat dt_cult_rec_3 MMDDYY10. ;  format dt_cult_rec_3 MMDDYY10. ;
  informat dt_cult_rep_fax_3 MMDDYY10. ;  format dt_cult_rep_fax_3 MMDDYY10. ;
  informat org_spec_4 $CHAR30. ;
  informat dt_cult_rec_4 MMDDYY10. ;  format dt_cult_rec_4 MMDDYY10. ;
  informat dt_cult_rep_fax_4 MMDDYY10. ;  format dt_cult_rep_fax_4 MMDDYY10. ;
  informat org_spec_5 $CHAR30. ;
  informat dt_cult_rec_5 MMDDYY10. ;  format dt_cult_rec_5 MMDDYY10. ;
  informat dt_cult_rep_fax_5 MMDDYY10. ;  format dt_cult_rep_fax_5 MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  cult_org_code_2  esbl_2  cult_site_code_2  sets_col_2
        sets_positive_2  org_spec_2 $  time_cult_rec_2 $  dt_cult_rec_2
        cult_rep_fax_2  dt_cult_rep_fax_2  cult_org_code_3  esbl_3
        cult_site_code_3  sets_col_3  sets_positive_3  org_spec_3 $
        time_cult_rec_3 $  dt_cult_rec_3  cult_rep_fax_3
        dt_cult_rep_fax_3  cult_org_code_4  esbl_4  cult_site_code_4
        sets_col_4  sets_positive_4  org_spec_4 $  time_cult_rec_4 $
        dt_cult_rec_4  cult_rep_fax_4  dt_cult_rep_fax_4
        cult_org_code_5  esbl_5  cult_site_code_5  sets_col_5
        sets_positive_5  org_spec_5 $  time_cult_rec_5 $  dt_cult_rec_5
        cult_rep_fax_5  dt_cult_rep_fax_5  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format esbl_2   yn.  ;
  format cult_rep_fax_2 mark_box.  ;
  format esbl_3   yn.  ;
  format cult_rep_fax_3 mark_box.  ;
  format esbl_4   yn.  ;
  format cult_rep_fax_4 mark_box.  ;
  format esbl_5   yn.  ;
  format cult_rep_fax_5 mark_box.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        cult_org_code_2="2.3.B Culture org. code"
        esbl_2="2.3.B ESBL producer?"
        cult_site_code_2="2.3.B Culture site code"
        sets_col_2="2.3.B Sets collected"
        sets_positive_2="2.3.B Sets positive"
        org_spec_2="2.3.B Specify organism"
        time_cult_rec_2="2.3.B Time cult. received"
        dt_cult_rec_2="2.3.B Date cult. received"
        cult_rep_fax_2="2.3.B Culture faxed"
        dt_cult_rep_fax_2="2.3.B Date culture faxed"
        cult_org_code_3="2.3.C Culture org. code"
        esbl_3="2.3.C ESBL producer?"
        cult_site_code_3="2.3.C Culture site code"
        sets_col_3="2.3.C Sets collected"
        sets_positive_3="2.3.C Sets positive"
        org_spec_3="2.3.C Specify organism"
        time_cult_rec_3="2.3.C Time cult. received"
        dt_cult_rec_3="2.3.C Date cult. received"
        cult_rep_fax_3="2.3.C Culture faxed"
        dt_cult_rep_fax_3="2.3.C Date culture faxed"
        cult_org_code_4="2.3.D Culture org. code"
        esbl_4="2.3.D ESBL producer?"
        cult_site_code_4="2.3.D Culture site code"
        sets_col_4="2.3.D Sets collected"
        sets_positive_4="2.3.D Sets positive"
        org_spec_4="2.3.D Specify organism"
        time_cult_rec_4="2.3.D Time cult. received"
        dt_cult_rec_4="2.3.D Date cult. received"
        cult_rep_fax_4="2.3.D Culture faxed"
        dt_cult_rep_fax_4="2.3.D Date culture faxed"
        cult_org_code_5="2.3.E Culture org. code"
        esbl_5="2.3.E ESBL producer?"
        cult_site_code_5="2.3.E Culture site code"
        sets_col_5="2.3.E Sets collected"
        sets_positive_5="2.3.E Sets positive"
        org_spec_5="2.3.E Specify organism"
        time_cult_rec_5="2.3.E Time cult. received"
        dt_cult_rec_5="2.3.E Date cult. received"
        cult_rep_fax_5="2.3.E Culture faxed"
        dt_cult_rep_fax_5="2.3.E Date culture faxed"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
run;

proc print;
run;