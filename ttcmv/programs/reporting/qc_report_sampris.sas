/*
***************************
*program:	qc_report.sas
*purpose: create table for qc status report for dsmc
* from glnd report progam by Eli
*  /glnd/sas/reporting/df_reporting/QC_report.sas 

 QC_report.sas
 *
 * finalized 7/7/08
 *
 * new version of the monthly QC report. now gives median and range days to resolution as well as a quotient of QCs / page submitted.
 * 
 * to do this, the program now directly rads the QC database from Datafax, rather than using the built-in datafax QC report (though this report
 * is still called in order to obtain the "pages submitted" numbers)
 *
 */

	*	Unlike the previous qc_status_data, we do not need to save and store each month in a separate file, since I will not be
		reporting the number of QCs originally resolved in the first month of issue. this report will display the current
		state of QCs issued in the last 6 months, with median (min, max) time to resolution  ;


*****
added 2/17/2010 - restricting to non-central plates (or study specific plates
using email from 
J. Cleveland dates 1/22/2010;


*options mprint mlogic;

**** export the QC notes from the dedicated datafax plate (511) for QCs to a text file ;
data _NULL_;
  command = "$DATAFAX_DIR/bin/DFexport.rpc -s all 16 511 /sammpris/sas/ds/current_qcnotes.dat";	
		
  call symput('command1', command);
run;
	
data _NULL_;
  x "&command1";
run;


**** read in QC data - adapted from a program by George ****;
data qcs;
  infile '/sammpris/sas/ds/current_qcnotes.dat' dlm='|' dsd lrecl=2000 missover;;
  length f3 $ 12;
  length f13 $ 150;
  length f14 $ 150;
  length f17 $ 500 f18 $ 500 f19 $ 50 f20 $ 50 f21 $ 50 f12 $ 500;
	
  inpu	    f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12
		    f13 f14 f15 f16 f17 f18 f19 f20 f21 f22;
	
* f1 = status
* f5 = plate #
* f6 = reader code + 4000
* f7 = id
* f8 = field #+3
* f13 = field name
* f15 = problem code
;
  status = f1;
  plate = f5;
  dfseq = f6;
  id = f7;
  field = f8+3;	
  name = f13;
  problem_code = f15;
	
  center = f9;
  report_num = f10;
	
  creation_string = f19;
  last_modify_string = f20;
  resolution_string = f21;
  usage_code = f22;

  drop f1-f22;
  
  if center >95 then delete;
  * fix problem with plate 20 and other strange data;

  if center=. then delete;
  if id=17001 and f5=33 and f6=101 and f18=14 and f9=17 then delete;
  if id=17001 and f5=20 and f6=1 and f18=23 and f9=17 then delete;
run;



**** post-process data ****;
	
data ds.qcs;
  set qcs (keep = 	status plate field plate dfseq center report_num problem_code creation_string last_modify_string
						resolution_string usage_code) ;
	
** parse creation, last modified, and resolved dates ;

  creation_string = substr(creation_string, find(creation_string, " ") + 1, 8);
  creation_date = mdy(substr(creation_string, 4, 2) , substr(creation_string, 7, 2) , substr(creation_string, 1 , 2)); 

  last_modify_string = substr(last_modify_string, find(last_modify_string, " ") + 1, 8);
  last_modify_date = mdy(substr(last_modify_string, 4, 2) , substr(last_modify_string, 7, 2) , substr(last_modify_string, 1 , 2)); 

  resolution_string = substr(resolution_string, find(resolution_string, " ") + 1, 8);
  resolution_date = mdy(substr(resolution_string, 4, 2) , substr(resolution_string, 7, 2) , substr(resolution_string, 1 , 2)); 


** make new variables ;
  days_to_resolution = resolution_date - creation_date; 

  month = month(creation_date);
  year = year(creation_date);


  format creation_date last_modify_date resolution_date date. center center. ;
		
  drop creation_string last_modify_string resolution_string;

*** restrict ro external QCs that are non-missing page but field specific QCss;
*** if (usage_code = 1) & (problem_code < 21 );

**** change to restrict to external QSs ;
   if (usage_code = 1);


***** restrict to site specific plates;

   if 2<=plate<=22 or
      24<=plate<=36 or
      40<=plate<=53 or
      plate=58 or
      61<=plate<=66 or
      69<=plate<=96 or
      101<=plate<=127 or
      plate=366 or plate=372 or plate=374;
run;
proc print;
where days_to_resolution > 190;
run;	

**** collect descriptive statistics on QCs, by center ****;
proc means data = ds.qcs n mean median min max fw = 5 maxdec = 0 noprint;
	class center;
	var days_to_resolution;
* n for days_to_resolution is a surrogate for the number of QCs resolved, since the dates are therefore non-missing ;
		output out = qc_stats n(days_to_resolution) = days_n median(days_to_resolution) = days_med min(days_to_resolution) = days_min max   
         (days_to_resolution) = days_max;
	
run;
** post-process means output ;
data qc_stats;
	set qc_stats (rename = (_freq_ = qcs_created));

	if center>90 then delete;
		
	resolved_display = compress(put(days_n, 4.0)) || " (" || compress(put((days_n/qcs_created)*100 ,4.0)) || "%)";
		
*	if (tot_qcs = 0) then resolved_display = "--"; 
			
if center=. then center=99;
drop _type_;
run;

proc sort; by center;


* DataFax QC query to obtain the number of pages  ***;

data _NULL_;
  filename = "qc_status_current.txt"; 		
  command = "/usr/local/apps/datafax/reports/DF_CTqcs 16  > /sammpris/sas/ds/qc_status_current.txt";	
  call symput('filename', filename);	
  call symput('command1', command);
  put filename;
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /sammpris/DataFax/work/*";
   x "chgrp -f studies *";
run;
		 
* read first half of the columns (the first table);
data qc1;
 infile "/sammpris/sas/ds/qc_status_current.txt"  missover firstobs=9  ; * when importing a file from the cumulative QC report: firstobs= 12 obs=18 ;
		input center tot_records tot_qcs rate_100_rec num_resolved pct_resolved correct na irrel days;
 if center=. then delete;
 if center>90 then delete;
run;	

proc sort; by center;
data df_qc_report;
  set qc1;
  by center;
  if first.center;
  keep center tot_records;
  format center site.;
run;
proc print;
proc means noprint;
 var tot_records;
 output out=qc2 sum=tot_records;
run;

data qctot;
  set df_qc_report qc2;
  keep center tot_records;
  if center=. then center=99;
run;
options ls=80 ps=53;


** Sort and merge descriptive stats and total records **;

proc sort data = qc_stats; by  center; run;
proc sort data = qctot; by  center; run;

data qc;
  merge
  qctot qc_stats;
  by center;

  qc_quotient = qcs_created / tot_records;
  format qc_quotient 5.3;
  if qc_quotient=. then qc_quotient=0;
  if qcs_created=. then qcs_created=0;
  qcq=put(qc_quotient, 5.3);
  qcc=put(qcs_created, 5.);
  if qcc="" then qcc='NA';
  if qcq="" then qcq='NA';
  resolved_stats = compress(put(days_med, 4.0)) || " [" || compress(put(days_min, 4.0)) || "-" || compress(put(days_max, 4.0)) || "]";

  label center = "Center"
        tot_records = "CRF Pages Submitted"
        qcs_created = "Queries Issued"
        qc_quotient = "Queries / Page "
         qcq = "Queries / Page "
         qcc = "Queries Issued"
	resolved_display = "Queries Resolved n (%)"
	resolved_stats = "Days to Resolution Med. [Range]"
	;
  if resolved_stats=". [.-.]" then resolved_stats="  -";
run;
	

ods ps file = "QC_report.ps" style = journal;
ods pdf file = "QC_report.pdf" style = journal;
options nodate nonumber;

title ;
 
proc print   label noobs split ="*";  
  var  center tot_records qcs_created qc_quotient ;
  var resolved_display /style(data) = [just=center];
  var resolved_stats /style(data) = [just=center];
run;

ods pdf close;
ods ps close;

data ds.qc;
   set qc;
   if center<40;
run;
data ds.qc1;
  set qc;
   if center >=40;
