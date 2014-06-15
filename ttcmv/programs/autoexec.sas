/* autoexec.sas
 *
 * establishes libnames, global variables, etc. for all TT-CMV programs 
 *
 */


** Data locations **;
libname cmv "/ttcmv/sas/data";				** stores primary study data - from DataFax submitted data or compiled from that data;
libname cmv_rep "/ttcmv/sas/data/reporting"; 		** stores datasets used in statistical reporting (non-primary study data) ;
libname cmv_qc "/ttcmv/sas/data/qc";					** stores datasets pertaining to reporting on data quality (such as output from DataFax QC reporting functions);
libname library "/ttcmv/sas/data";						** stores formats in a directory common to all data ;

** Output file locations **;
%let output =  /ttcmv/sas/output;


** Macro include directory **;
%let include = /ttcmv/sas/programs/include;

** Global variables **;
%let last_dsmb_date = 8,31,2009; * date last report freeze;
%let dsmb_date = 8,31,2009; ** current freeze date. used in last_contact.sas, last_contact_closed.sas and wherever we need to censor time for the DSMB report;

** SAS Options **;
options yearcutoff=1920;

** keep the formatted date in a global string ;
data _NULL_;
	call symput ("today_date", compress(put(today(), mmddyy10.)));
run;
