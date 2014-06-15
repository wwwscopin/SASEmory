
libname rand '/glnd/sas/randomization';

libname glnd  '/glnd/sas/dsmc/20101011';
libname library '/glnd/sas';
libname glnd_df "/glnd/sas/dsmc/20101011/reporting/df_reporting";
libname glnd_ext "/glnd/sas/dsmc/20101011/external_data";
libname glnd_rep "/glnd/sas/dsmc/20101011/reporting";

options yearcutoff=1920;

%let last_dsmb_date = 4,01,2010; * date last report freeze;
%let dsmb_date = 10,11,2010; ** current freeze date. used in last_contact.sas, last_contact_closed.sas and wherever we need to censor time for the DSMB report;
