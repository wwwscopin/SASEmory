/* CREATED BY: esrose2 May 03,2007 13:15PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate17.d01';
data glnd.plate17 (label="Mechanical Ventilation Form, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dt_mech_vent_start_1 MMDDYY8. ;  format dt_mech_vent_start_1  MMDDYY8. ;
  informat dt_mech_vent_stop_1 MMDDYY8. ;  format dt_mech_vent_stop_1  MMDDYY8. ;
  informat dt_mech_vent_start_2 MMDDYY8. ;  format dt_mech_vent_start_2  MMDDYY8. ;
  informat dt_mech_vent_stop_2 MMDDYY8. ;  format dt_mech_vent_stop_2  MMDDYY8. ;
  informat dt_mech_vent_start_3 MMDDYY8. ;  format dt_mech_vent_start_3  MMDDYY8. ;
  informat dt_mech_vent_stop_3 MMDDYY8. ;  format dt_mech_vent_stop_3  MMDDYY8. ;
  informat dt_mech_vent_start_4 MMDDYY8. ;  format dt_mech_vent_start_4  MMDDYY8. ;
  informat dt_mech_vent_stop_4 MMDDYY8. ;  format dt_mech_vent_stop_4  MMDDYY8. ;
  informat dt_mech_vent_start_5 MMDDYY8. ;  format dt_mech_vent_start_5  MMDDYY8. ;
  informat dt_mech_vent_stop_5 MMDDYY8. ;  format dt_mech_vent_stop_5  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dt_mech_vent_start_1  dt_mech_vent_stop_1
        mech_vent_narr_1  dt_mech_vent_start_2  dt_mech_vent_stop_2
        mech_vent_narr_2  dt_mech_vent_start_3  dt_mech_vent_stop_3
        mech_vent_narr_3  dt_mech_vent_start_4  dt_mech_vent_stop_4
        mech_vent_narr_4  dt_mech_vent_start_5  dt_mech_vent_stop_5
        mech_vent_narr_5  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format mech_vent_narr_1 yn.  ;
  format mech_vent_narr_2 yn.  ;
  format mech_vent_narr_3 yn.  ;
  format mech_vent_narr_4 yn.  ;
  format mech_vent_narr_5 yn.  ;
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
        dt_mech_vent_start_1="1.1 Mech Vent Start"
        dt_mech_vent_stop_1="1.1 Mech Vent Stop"
        mech_vent_narr_1="1.1 Mechanical Vent Narr"
        dt_mech_vent_start_2="1.2 Mech Vent Start"
        dt_mech_vent_stop_2="1.2 Mech Vent Stop"
        mech_vent_narr_2="1.2 Mechanical Vent Narr"
        dt_mech_vent_start_3="1.3 Mech Vent Start"
        dt_mech_vent_stop_3="1.3 Mech Vent Stop"
        mech_vent_narr_3="1.3 Mechanical Vent Narr"
        dt_mech_vent_start_4="1.4 Mech Vent Start"
        dt_mech_vent_stop_4="1.4 Mech Vent Stop"
        mech_vent_narr_4="1.4 Mechanical Vent Narr"
        dt_mech_vent_start_5="1.5 Mech Vent Start"
        dt_mech_vent_stop_5="1.5 Mech Vent Stop"
        mech_vent_narr_5="1.5 Mechanical Vent Narr"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

if mech_vent_narr_1 = 99 then mech_vent_narr_1 = . ;
if mech_vent_narr_2 = 99 then mech_vent_narr_2 = . ;
if mech_vent_narr_3 = 99 then mech_vent_narr_3 = . ;
if mech_vent_narr_4 = 99 then mech_vent_narr_4 = . ;
if mech_vent_narr_5 = 99 then mech_vent_narr_5 = . ;

proc print;
