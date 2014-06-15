/* CREATED BY: gcotson Sep 25,2006 11:34AM using DFsas */
/*   VERSIONS: DFsas 3.7-004, 05/06/14 and .DFsas.awk 3.7-004, 05/06/14 */
options YEARCUTOFF=1920;


filename data1 '/dfax/glnd/sas/plate6.d01';
data plate6(label="Apache II Scoring, Pg 4/4");
  infile data1 LRECL=4096 dlm='|' missover dsd;
  informat DFRASTER $CHAR12. ;
  informat DFCREATE $CHAR17. ;
  informat DFMODIFY $CHAR17. ;
  input id  DFSTATUS  DFVALID  DFRASTER $  DFSTUDY  DFPLATE  DFSEQ
        ptint $  chron_health  aps_a  aps_b  aps_tot  glas_eye
        glas_verb  glas_motor  glas_total  glas_adj_total  apache_sect1
        apache_sect2  apache_sect3  apache_total  DFSCREEN  DFCREATE $
        DFMODIFY $ ;
  format DFSTATUS DFSTATv. ;
  format chron_health gcs38v.  ;
  format DFSCREEN DFSCRNv. ;
  if chron_health=99 then chron_health=.;
  label id="GLND ID No."
        DFSTATUS="DataFax Record Status"
        DFVALID="DataFax Validation Level"
        DFRASTER="DataFax Raster Name"
        DFSTUDY="DataFax Study Number"
        DFPLATE="DataFax Plate Number"
        DFSEQ="DataFax Sequence Number"
        ptint="Participant Initials"
        chron_health="3. Chronic Health Score"
        aps_a="4.1.A APS Total A"
        aps_b="4.1.A APS Total B"
        aps_tot="4.1.A APS Total (A+B)"
        glas_eye="4.1.B GCS eye opening pts"
        glas_verb="4.1.B GCS verbal resp pts"
        glas_motor="4.1.B GCS motor resp pts"
        glas_total="4.1.B GCS total"
        glas_adj_total="4.1.B GCS adjusted total"
        apache_sect1="4.1 Section 1 total"
        apache_sect2="4.2.A Section 2 total"
        apache_sect3="4.3.A Section 3 total"
        apache_total="4.4 APACHE II Score"
        DFSCREEN="DataFax Screen Status"
        DFCREATE="DataFax Create Stamp"
        DFMODIFY="DataFax Modify Stamp";

  sect1=aps_a+aps_b+15-(glas_eye+glas_verb+glas_motor);
  total=sect1+apache_sect2+apache_sect3;
  apachecorrect=0;
  if total=apache_total then apachecorrect=1;
  
  label sect1='APS A+B check'
        total= "APACHE Check"
        apachecorrect='Apache Correct on plate 6';      
run;

proc print ;run;

** George's code is subsetting the data based on DFSEQ, presumably for randomization programs. I need to capture the SICU entry APACHE and thus make a dataset just for it ;
data glnd.apache_sicu;
	set plate6;
	where dfseq = 46;

	keep apache_total id;
	rename apache_total = apache_total_sicu;
	label apache_total = "APACHE II SICU entry";

run;

proc print data =glnd.apache_sicu label;
run;

proc means data =glnd.apache_sicu Q1 median Q3;
var apache_total_sicu;
run;



        data glnd.plate6;
         set plate6;
         if dfseq=0;
         run;
         proc freq;
          tables id;
          run;
         data glnd.plate6b; /* I redirect where visit ~= 0 based on my code above */
         set plate6;
         if dfseq ne 0;
         run;
