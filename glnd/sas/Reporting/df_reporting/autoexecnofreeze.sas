
libname rand '/glnd/sas/randomization';

libname glnd  '/glnd/sas';
libname library '/glnd/sas';
libname glnd_df "/glnd/sas/reporting/df_reporting";
libname glnd_ext "/glnd/sas/external_data";
libname glnd_rep "/glnd/sas/reporting";

options yearcutoff=1920;

%let last_dsmb_date = 8,31,2009; * date last report freeze;
%let dsmb_date = 3,3,2010; ** current freeze date. used in last_contact.sas, last_contact_closed.sas and wherever we need to censor time for the DSMB report;
