
libname rand '/glnd/sas/randomization';

libname glnd  '/glnd/sas/dsmc/20110404';
libname library '/glnd/sas';
libname glnd_df "/glnd/sas/dsmc/20110404/reporting/df_reporting";
libname glnd_ext "/glnd/sas/dsmc/20110404/external_data";
libname glnd_rep "/glnd/sas/dsmc/20110404/reporting";

options yearcutoff=1920;


%let last_dsmb_date =10,11,2010; * date last report freeze;
%let dsmb_date = 5,11,2011; ** current freeze date. used in last_contact.sas, last_contact_closed.sas and wherever we need to censor time for the DSMB report;
