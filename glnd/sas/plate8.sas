/* CREATED BY: esrose2 Jan 30,2007 12:03PM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


/* TREATMENT BLINDED VERSION OF PLATE 8 (PHRAMARCY CONFIRMATION). TREATMENT FIELD IS NOT INCLUDED */

filename data1 '/dfax/glnd/sas/plate8.d01';
data glnd.george(label="Pharmacy Confirmation Form, Pg 1/1");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat dfc      MMDDYY8. ;  format dfc       MMDDYY8. ;
  informat dt_random MMDDYY8. ;  format dt_random  MMDDYY8. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  fcbint $  dfc  dt_random  time_random $  apache_2
        treatment  DFSCREEN  DFCREATE $  DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format apache_2 apache.  ;
  format treatment treatment.  ;
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
        dt_random="1.1 Date Randomized"
        time_random="1.2 Time patient random."
        apache_2="1.3 APACHE II"
        treatment="3.1 Treatment"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";
        run;
        proc freq;
         tables treatment;
         format treatment;
run;
data glnd.plate8;
 set glnd.george;
 
drop treatment;run;


proc print data= glnd.plate8;
	var id dt_random;
run;
