/* CREATED BY: bwu2 Apr 12,2011 13:29PM using DFsas */
/*   VERSIONS: DFsas 3.8.3, May and .DFsas.awk 3.8.3, May */
/*
proc format ;
  value DFSTATv  0 = "lost"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error"
                 4 = "CLEAN"
                 5 = "DIRTY"
                 6 = "ERROR" ;
  value F0004v   99 = "Blank"
                 1 = "Patient and/or family"
                 2 = "Primary care physician's office"
                 3 = "Other" ;
  value F0017v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0019v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0010v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0001v   99 = "Blank"
                 0 = "No"
                 1 = "Yes" ;
  value F0078v   99 = "Blank"
                 0 = "No"
                 1 = "Yes"
                 2 = "Unknown" ;
  value DFSCRNv  0 = "blank"
                 1 = "clean"
                 2 = "dirty"
                 3 = "error" ;
*/
filename data1 '/dfax/glnd/sas/plate43.d01';
data glnd.plate43(label="X Month Post-Enrollment Follow-Up Telephone Call, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_pt_enroll MMDDYY10. ;  format dt_pt_enroll MMDDYY10. ;
  informat dt_phn_call MMDDYY10. ;  format dt_phn_call MMDDYY10. ;
  informat info_src_spec $CHAR36. ;
  informat dt_re_hosp MMDDYY10. ;  format dt_re_hosp MMDDYY10. ;
  informat dt_sicu  MMDDYY10. ;  format dt_sicu  MMDDYY10. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dt_pt_enroll  dt_phn_call  info_src
        info_src_spec $  died  re_hosp  dt_re_hosp  sicu  dt_sicu
        nar_prov  nursing_home  DFSCREEN  DFCREATE $  DFMODIFY $ ;
/*
  format DFSTATUS DFSTATv. ;
  format info_src F0004v.  ;
  format died     F0017v.  ;
  format re_hosp  F0019v.  ;
  format sicu     F0010v.  ;
  format nar_prov F0001v.  ;
  format nursing_home F0078v.  ;
  format DFSCREEN DFSCRNv. ;
*/
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        fcbint="Form Comp. By Initials"
        dt_pt_enroll="Date Patient Enrolled"
        dt_phn_call="Date of Phone Call"
        info_src="1.1 Information source"
        info_src_spec="1.1 Info source: Other"
        died="2.1 Patient died?"
        re_hosp="2.2 Patient Re-Hosp.?"
        dt_re_hosp="2.2 Date Re-Hosp"
        sicu="2.3 Patient in SICU?"
        dt_sicu="2.3 Date admitted SICU"
        nar_prov="Narrative provided"
        nursing_home="2.4 Pt in nursing home?"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
run;

data mo6;
   set glnd.plate43;
if dfseq=44;
  keep id dt_phn_call;
run;
proc sort; by id;
data xs;
   set glnd.status (keep=id dt_random);
proc sort; by id;
data final;
  merge mo6(in=a) xs;
 by id;
if a;
days=dt_phn_call-dt_random;
proc sort; by days;
ods ps file='plate43.ps' ;

proc print;
 var id  days dt_phn_call dt_random;
run;
ods rtf close;
run;
