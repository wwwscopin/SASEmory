
libname rand '/dfax/glnd/sas/randomization';
libname glnd  '/dfax/glnd/sas/';
libname library '/dfax/glnd/sas';
libname glnd_df "/dfax/glnd/sas/reporting/df_reporting";
libname glnd_ext "/dfax/glnd/sas/external_data";
libname glnd_rep "/dfax/glnd/sas/reporting";

options yearcutoff=1920 nonumber nodate;

%let last_dsmb_date =04,04,2011; * date last report freeze;
%let dsmb_date = 5,11,2011; ** current freeze date. used in last_contact.sas, last_contact_closed.sas and wherever we need to censor time for the DSMB report;


