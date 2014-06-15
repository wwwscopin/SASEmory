/* sofa_plot_censor_adjust_open.sas
 *
 * For all patients, plot total sofa scores longitudinally and draw boxplots. 
 * Annotate with sample sizes at each day (SOFA scores are recordable when a patient
 * is in the SICU)
 *
 * This version was created (2/5/2010) per the DSMB recommendations to keep people who leave the SICU or die by assigning them a min or max score (0 if leave SICU, 24 if die)
 *
 */

options pagesize= 60 linesize = 85 center nodate nonumber;

data all;
	set glnd.followup_all_long(keep=id);
run;

data dead;
	set glnd_rep.death_details_open(keep=id);
run;

proc sql;
	create table sur as
	select *
      from all
   except
   select *
      from dead;

proc sort data=all nodup;by id;run;
proc sort data=dead nodup;by id;run;
proc sort data=sur nodup;by id;run;
proc sort data = glnd.followup_all_long; by id day; run;
