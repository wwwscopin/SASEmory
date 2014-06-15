/* CREATED BY: gcotson Sep 14,2006 09:03AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate4.d01';
data plate4(label="Apache II Scoring, Pg 2/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE
        DFSEQ  ptint $  apache_art_ph  apache_art_ph_pts  apache_ser_na
        apache_ser_na_pts  apache_ser_k  apache_ser_k_pts
        apache_ser_creat  apache_ser_creat_pts  apache_hemat
        apache_hemat_pts  apache_wbc  apache_wbc_pts  aps_total_b
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format apache_art_ph apa6v.  ;
  format apache_ser_na apa7v.  ;
  format apache_ser_k apa8v.  ;
  format apache_ser_creat apa9v.  ;
  format apache_hemat apa10v.  ;
  format apache_wbc apa11v.  ;
  format DFSCREEN DFSCRNv. ;
  
  array junk(6)
    apache_art_ph   apache_ser_na    apache_ser_k  
       apache_ser_creat   apache_hemat    apache_wbc ;
 
  do i=1 to 6;
     if junk(i)=99 then junk(i)=.;
  end;
  drop i;
  
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        apache_art_ph="1.A.6 APACHE artery pH"
        apache_art_ph_pts="1.A.6 APACHE art ph pts"
        apache_ser_na="1.A.7 APACHE serum Na"
        apache_ser_na_pts="1.A.7 APACHE serum Na pts"
        apache_ser_k="1.A.8 APACHE serum K"
        apache_ser_k_pts="1.A.9 APACHE serum K pts"
        apache_ser_creat="1.A.9 APACHE serum creat"
        apache_ser_creat_pts="1.A.9 APACHE ser creat pt"
        apache_hemat="1.A.10 APACHE hematocrit"
        apache_hemat_pts="1.A.10 APACHE hemat pts"
        apache_wbc="1.A.11 APACHE WBC"
        apache_wbc_pts="1.A.11 APACHE WBC points"
        aps_total_b="1.A APS Total B"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
  aps_total_b_check=apache_art_ph_pts+ apache_ser_na_pts+  apache_ser_k_pts+
        apache_ser_creat_pts+apache_hemat_pts+apache_wbc_pts;
        label aps_total_b_check="1.A APS Total B Check";


        data glnd.plate4;
         set plate4;
         if dfseq=0;
         run;
         proc freq;
          tables id;
          run;
         data glnd.plate4b;
         set plate4;
         if dfseq ne 0;
         run;

endsas;
proc print;
 var aps_total_b_check apache_art_ph_pts  apache_ser_na_pts apache_ser_k_pts
        apache_ser_creat_pts apache_hemat_pts apache_wbc_pts aps_total_b;
