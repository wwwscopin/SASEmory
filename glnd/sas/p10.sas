/* CREATED BY: gcotson Aug 22,2007 08:59AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


;
filename data1 '/dfax/glnd/sas/plate10.d01';
data glnd.plate10(label="Demographics/History Form, Pg 2/3");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat other_proc_other_a $CHAR100. ;
  informat other_proc_other_b $CHAR100. ;
  informat other_proc_other_c $CHAR100. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  other_procedures  other_proc_type_a
        other_proc_other_a $  concom_subseq_a  other_proc_type_b
        other_proc_other_b $  concom_subseq_b  other_proc_type_c
        other_proc_other_c $  concom_subseq_c  wbc_count  ards
        mech_vent  mech_vent_updt  int_aortic_pump  nosc_infect
        nutr_status  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format other_procedures yn.  ;
  format other_proc_type_a opc.  ;
  format concom_subseq_a concom_subseq.  ;
  format other_proc_type_b opc.  ;
  format concom_subseq_b concom_subseq.  ;
  format other_proc_type_c opc.  ;
  format concom_subseq_c concom_subseq.  ;
  format ards     yn.  ;
  format mech_vent yn.  ;
  format mech_vent_updt yn.  ;
  format int_aortic_pump yn.  ;
  format nosc_infect yn.  ;
  format nutr_status nutr_sta.  ;
  format DFSCREEN DFSCRNv. ;
  array junk(13) 
  other_procedures    other_proc_type_a    concom_subseq_a   
   other_proc_type_b    concom_subseq_b    other_proc_type_c 
   concom_subseq_c    ards        mech_vent 
   mech_vent_updt    int_aortic_pump    nosc_infect 
   nutr_status  ;
   
  do i=1 to 13;
    if junk(i)=99 then junk(i)=.;
  end;
  
  
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        other_procedures="3.3 Other procedures?"
        other_proc_type_a="3.3.A Other procedure"
        other_proc_other_a="3.3.A Other procedure oth"
        concom_subseq_a="3.3.A Concom/Subseq?"
        other_proc_type_b="3.3.B Other procedure"
        other_proc_other_b="3.3.B Other procedure oth"
        concom_subseq_b="3.3.B Concom/Subseq?"
        other_proc_type_c="3.3.C Other procedure"
        other_proc_other_c="3.3.C Other procedure oth"
        concom_subseq_c="3.3.C Concom/Subseq?"
        wbc_count="3.4 WBC count"
        ards="3.5 ARDS present?"
        mech_vent="3.6 Mechanical Vent."
        mech_vent_updt="3.6 Mech Vent Update"
        int_aortic_pump="3.7 Intra-aortic pump?"
        nosc_infect="3.8 Nosocomial infection?"
        nutr_status="3.9 Nutritional status"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
        drop i;
proc means;
