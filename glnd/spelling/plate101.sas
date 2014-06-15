/* CREATED BY: esrose2 Feb 20,2007 12:58PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate101.d01';
data glnd.plate101(label="Suspected Nosocomial Infection, Pg 1/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_infect MMDDYY8. ;  format dt_infect  MMDDYY8. ;
  informat org_spec_1 $CHAR80. ;
  informat dt_cult_rec_1 MMDDYY8. ;  format dt_cult_rec_1  MMDDYY8. ;
  informat dt_cult_rep_fax_1 MMDDYY8. ;  format dt_cult_rep_fax_1  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  infect_number  dt_infect
        infect_body_temp  cult_obtain  cult_positive  cult_org_code_1
        esbl_1  cult_site_code_1  sets_col_1  sets_positive_1
        org_spec_1 $  time_cult_rec_1 $  dt_cult_rec_1  cult_rep_fax_1
        dt_cult_rep_fax_1  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format cult_obtain yn.  ;
  format cult_positive yn.  ;
  format esbl_1   yn.  ;
  format cult_rep_fax_1 mark_box.  ;
  format cult_org_code_1 cult_org_code.;
  format cult_site_code_1 cult_site_code.; 

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
        infect_number="Infection Number from Log"
        dt_infect="1.1 Date of infect. onset"
        infect_body_temp="1.1 Infect. body temp."
        cult_obtain="2.1 Culture obtained?"
        cult_positive="2.2 Culture positive?"
        cult_org_code_1="2.3.A Culture org. code"
        esbl_1="2.3.A ESBL producer?"
        cult_site_code_1="2.3.A Culture site code"
        sets_col_1="2.3.A Sets collected"
        sets_positive_1="2.3.A Sets positive"
        org_spec_1="2.3.A Specify organism"
        time_cult_rec_1="2.3.A Time cult. received"
        dt_cult_rec_1="2.3.A Date cult. received"
        cult_rep_fax_1="2.3.A Culture faxed"
        dt_cult_rep_fax_1="2.3.A Date culture faxed"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

	if cult_obtain = 99 then cult_obtain = .;
	if cult_positive = 99 then cult_positive = .;
	if esbl_1 = 99 then esbl_1 = .;

proc contents;run;
proc print;run;
