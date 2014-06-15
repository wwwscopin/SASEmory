/* CREATED BY: gcotson Sep 25,2006 11:03AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;

filename data1 '/dfax/glnd/sas/plate3.d01';
data plate3(label="Apache II Scoring, Pg 1/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  apache_temp  apache_temp_pts
        apache_art_pres  apache_art_pres_pts  apache_heart
        apache_heart_pts  apache_resp  apache_resp_pts  apache_oxy_a
        apache_oxy_b  apache_oxy_c  apache_oxy_pts  aps_total_a
        DFSCREEN  DFCREATE $  DFMODIFY $ ;
    format DFSTATUS DFSTATv. ;
  format apache_temp apa1v.  ;
  format apache_art_pres apa2v.  ;
  format apache_heart apa3v.  ;
  format apache_resp apa4v.  ;
  format apache_oxy_a apa5a.  ;
  format apache_oxy_b apa5b.  ;
  format apache_oxy_c apa5c.  ;
  format DFSCREEN DFSCRNv. ;
  
  array junk(7)
   apache_temp   apache_art_pres    apache_heart 
   apache_resp    apache_oxy_a    apache_oxy_b
   apache_oxy_c ;
  do i=1 to 7;
     if junk(i)=99 then junk(i)=.;
  end;
  drop i;
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
        apache_temp="1.A.1 APACHE temp."
        apache_temp_pts="1.A.1 APACHE temp. points"
        apache_art_pres="1.A.2 APACHE artery press"
        apache_art_pres_pts="1.A.2 APACHE art pres pts"
        apache_heart="1.A.3 APACHE heart"
        apache_heart_pts="1.A.3 APACHE heart points"
        apache_resp="1.A.4 APACHE resp"
        apache_resp_pts="1.A.4 APACHE resp points"
        apache_oxy_a="1.A.5a APACHE oxy a"
        apache_oxy_b="1.A.5b APACHE oxy b"
        apache_oxy_c="1.A.5c APACHE oxy c"
        apache_oxy_pts="1.A.5 APACHE oxy points"
        aps_total_a="1.A APS Total A"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

   aps_total_a_check=apache_temp_pts+apache_art_pres_pts+apache_heart_pts+
        apache_resp_pts+apache_oxy_pts;
        label aps_total_a_check="1.A APS Total A CHECK";
        run;
        




        data glnd.plate3;
         set plate3;
         if dfseq=0;
         run;
         proc freq;
          tables id;
          run;
         data glnd.plate3b;
         set plate3;
         if dfseq ne 0;
         run;
 
