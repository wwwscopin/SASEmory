/* CREATED BY: esrose2 Jun 11,2008 09:51AM using DFsas */
/*   VERSIONS: DFsas 3.8.2, May and .DFsas.awk 3.8.2, May */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate56.d01';
data glnd.plate56(label="Susp. Nosocomical Infct Adjudication, Pg 1/2");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat adjud_dt MMDDYY8. ;  format adjud_dt  MMDDYY8. ;
  informat inf_onset_dt MMDDYY8. ;  format inf_onset_dt  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        infect_visitno  ptint $  fcbint $  infect_no  adjud_dt
        agree_site  inf_onset_dt  cult_pos  infect_confirm  site_code $
        type_code $  same_site  two_wk_interval  res_int_infect
        comb_new_signs  comp_antib  bsi_bld_cult  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format agree_site yn.  ;
  format cult_pos yn.  ;
  format infect_confirm infect_confirm.  ;
  format same_site yn.  ;
  format two_wk_interval yn.  ;
  format res_int_infect yn.  ;
  format comb_new_signs yn.  ;
  format comp_antib yn.  ;
  format bsi_bld_cult bsi_bld_cult.  ;
  format DFSCREEN DFSCRNv. ;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        infect_visitno="Infection Visit No."
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        infect_no="Infection number from CRF"
        adjud_dt="Date of Adjudication"
        agree_site="Agree with site findings?"
        inf_onset_dt="1.1 Date infection onset"
        cult_pos="1.2 Was culture positive?"
        infect_confirm="1.3 Infection confirmed?"
        site_code="1.3 Site Code"
        type_code="1.3 Type Code"
        same_site="1.4 Infection same site?"
        two_wk_interval="1.5.A Two week interval?"
        res_int_infect="1.5.B Resolution int inf?"
        comb_new_signs="1.5.C Comb new signs/symp"
        comp_antib="1.5.D Complete antibiotic"
        bsi_bld_cult="1.5.E BSI neg blood cult"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

	if agree_site = 99 then agree_site  = .  ;
	if cult_pos = 99 then cult_pos = .  ;
	if infect_confirm in (99, 199) then infect_confirm = .  ;
	if same_site = 99 then same_site = .  ;
	if two_wk_interval = 99 then two_wk_interval = .  ;
	if res_int_infect = 99 then res_int_infect = .  ;
	if comb_new_signs = 99 then comb_new_signs = .  ;
	if comp_antib = 99 then comp_antib = .  ;
	if bsi_bld_cult in (99, 199) then bsi_bld_cult = .  ;
	
run;



proc print data = glnd.plate56;
run;
