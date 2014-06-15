


***************************
*program:	qc_report.sas
*purpose: create table for qc status report for monthly report
* 
*  original programmer: Neeta Shenvi
*
* Creation Date: July 08,2010
* Validation Date:
* Validator: Neeta Shenvi.
* Modification history:
*   ;




%include "&include./monthly_toc.sas";



*options mprint mlogic;

**** export the QC notes from the dedicated datafax plate (511) for QCs to a text file ;
data _NULL_;
  command = "$DATAFAX_DIR/bin/DFexport.rpc -s all 20 511 /ttcmv/sas/data/current_qcnotes.dat";	
		
  call symput('command1', command);
run;
	
data _NULL_;
  x "&command1";
run;


**** read in QC data - adapted from a program by George ****;
data cmv.qcs;
  infile '/ttcmv/sas/data/current_qcnotes.dat' dlm='|' dsd lrecl=2000 missover;;
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
  
  
run;


**** post-process data ****;
	
data qcs;
  set cmv.qcs (keep = 	status plate field plate dfseq center report_num problem_code creation_string last_modify_string
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

if plate = 66 or plate =93 or plate=91 or plate = 95 or plate = 131 then delete;

   
run;


proc print;
where days_to_resolution > 190;
run;	

**** collect descriptive statistics on QCs, by center ****;
proc means data = qcs n mean median min max fw = 5 maxdec = 0 noprint;
	class center;
	var days_to_resolution;
   * n for days_to_resolution is a surrogate for the number of QCs resolved,;
*  since the dates are therefore non-missing ;
		output out = qc_stats n(days_to_resolution) = days_n median(days_to_resolution) = days_med 
min(days_to_resolution) = days_min 
max(days_to_resolution) = days_max;
	
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

proc sort; by center; run;


* DataFax QC query to obtain the number of pages  ***;

data _NULL_;
  filename = "qc_status_current.txt"; 		
  command = "/usr/local/apps/datafax/reports/DF_CTqcs 20  > /ttcmv/sas/data/qc_status_current.txt";	
  call symput('filename', filename);	
  call symput('command1', command);
  put filename;
  put command;
run;

data _NULL_;
   x "&command1";
   x "chmod -f g+rw /ttcmv/DataFax/work/*";
   x "chgrp -f studies *";
run;
		 
* read first half of the columns (the first table);
data qc1;
 infile "/ttcmv/sas/data/qc_status_current.txt"  missover firstobs=9  ; * when importing a file from the cumulative QC report: firstobs= 12 obs=18 ;
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
  *format center center.;
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

data qc_report;
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

options nodate nonumber orientation = portrait;
ods rtf file = "&output./monthly/&qc_report_file.qc_table.rtf"  style = journal toc_data startpage = yes bodytitle;
ods noproctitle proclabel "&qc_report_title Center QC Reports ";

title  justify = center "&qc_report_title Center QC Reports";
footnote1 "";
footnote2 "";
 
proc print  data=qc_report label noobs split ="*"; 
where center < 99; 
  var  center tot_records qcs_created qc_quotient ;
  var resolved_display /style(data) = [just=center];
  var resolved_stats /style(data) = [just=center];
run;

/*
proc report data = qc_report nofs   style(header) = [just=center]  split = "_"  missing headline headskip  contents = ""; 

	column center tot_records qcs_created qc_quotient  resolved_display  resolved_stats dummy ;

define center / center group   order=internal     style(column)=[cellwidth=1in just=center]  "Site";
define resolved_display / center      style(column)=[cellwidth=1in just=center]  "Queries resolved_n (%)";
define resolved_stats / center      style(column)=[cellwidth=1in just=center]  ;
define dummy/ noprint;
run;
*/
ods rtf close;

	



