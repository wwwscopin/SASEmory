data x;
   set glnd.icudays;
   day=1;
   treatment=tr;
   drop tr;
proc sort; by id;
data y;
   set glnd_ext.glutamine;
   if day=0;
   day=1;
   keep id treatment day GlutamicAcid  glutamine   total_glutamine ;      
run;
proc sort; by id;
data z;
   set glnd_ext.chemistries;
 if day=0;
   day=1;
keep id day crp;
run;
options nodate nonumber ls=90 ps=54;
proc sort; by id;
	data glnd.paper1_table1;
		merge 	glnd.followup_all_long 
				glnd.status (keep = id treatment)
                               x
                               y
                               z;
         
		by id;
  if day=1; 
  keep id sofa_tot gluc_eve gluc_mrn treatment gluc_aft treatment days_in_sicu_hosp_stay 
       GlutamicAcid  glutamine   total_glutamine crp icu_free_days days_in_sicu_raw;
  label days_in_sicu_hosp_stay='Total Days in SICU'
        icu_free_days='ICU Free Days'
        days_in_sicu_raw='Days in SICU From Study Entry'
         total_glutamine='Total Glutamine'
         crp='Serum CRP';
proc ttest;
 class treatment;
 var sofa_tot  gluc_mrn days_in_sicu_hosp_stay GlutamicAcid  glutamine   total_glutamine crp;
run;
title;


ods ps file='table2.ps';
proc freq data=glnd.basedemo;
   tables surg*center / nocum norow nopercent;
run;

ods ps close;

proc sort data =glnd_rep.time_on_pn;
   by id;
data glnd.pndays;
   merge glnd_rep.time_on_pn glnd.status(keep=id treatment);
   by id;
proc means n mean std median;
class treatment;
run;
proc univariate freq plot;
  histogram days_on_pn;
  var days_on_pn;
  class treatment;
run;
proc contents data=glnd.followup_all_long ;

   
proc ttest data=glnd.basedemo;
  class treatment;
  var pre_op_kg;

data glu;
   set glnd.plate14;
   glu=ag_dipep_1*.673;
keep id glu;
proc sort; by id;
data glu1;
   merge glu glnd.status (keep = id treatment) glnd.basedemo (keep=id pre_op_kg) ;
   by id;
   gluwt=glu/pre_op_kg;
 proc ttest;
 class treatment;
  var glu gluwt;
run;

data sofa;
   set   glnd.followup_all_long (keep=id sofa_tot day );
   if day=1;
data x;
   merge glnd.status (keep=id treatment  mortality_28d hospital_death followup_days deceased)
         glnd.basedemo(keep=id apachese apachesicu mech_vent)
         sofa (keep=id sofa_tot)
         y(keep=id glutamine);
   by id;
   if apachese<=11 then apachese4=1;
    else if apachese<=16 then apachese4=2;
         else if apachese<=20 then apachese4=3;
              else apachese4=4;
   if apachesicu<=18 then apachesicu4=1;
    else if apachesicu<=23 then apachesicu4=2;
         else if apachesicu<=27 then apachesicu4=3;
              else apachesicu4=4;
  
/*
   apachese         APACHE II at study entry      12.0000000      16.0000000      20.0000000
                     apachesicu       APACHE II first day SICU      18.0000000      23.0000000      27.0000000
*/

proc format;
  value a4se
  1='1-11'
  2='12-16'
  3='17-20'
  4='21+';
  value a4sicu
  1='1-18'
  2='19-23'
  3='24-27'
  4='28+';
proc univariate freq;
var apachese apachesicu;
proc means p25 p50 p75 n ;
  var apachese apachesicu;
proc freq;
  tables apachese4 apachesicu4;
run;
ods ps file='apache_quartile.ps';
proc freq page;
   tables apachese4*treatment*hospital_death;
   tables apachesicu4 *treatment*hospital_death;
   format apachese4 a4se. apachesicu4 a4sicu.;
title;
run;
ods ps close;
proc format;   
   value c

        1='emory'
        2='Miriam'
        3='Vanderbilt'
        4='Colorado'
        5='Wisconsin'
        99='Test';

  
data x0;
  set x;
if treatment=2 then treatment=0;
 center = floor(id/10000);
   format  center c.;


format treatment;
proc means;
  var sofa_tot mech_vent apachese glutamine;

ods ps file='paperbaselogistic.ps';

ods pdf file='paperbaselogistic.pdf';
proc logistic;
   model hospital_death (event='1')= treatment ;
   where sofa_tot ne .;
run;
proc logistic;
   model hospital_death(event='1') = treatment sofa_tot mech_vent apachese / lackfit;
run;
ods pdf close;
ods ps close;

ods ps file='paperbasecox.ps';

ods pdf file='paperbasecox.pdf';
proc phreg;
   model followup_days*deceased(0)= treatment  / risklimits;
   where sofa_tot ne .;
run;
proc phreg;
   model followup_days*deceased(0)= treatment sofa_tot mech_vent apachese / risklimits;
run;
ods pdf close;
ods ps close;

proc freq;
    tables center*hospital_death / exact;
run;

ods pdf file='logistic.pdf';
proc logistic ;
   class center ;
   model hospital_death(event='1') = treatment sofa_tot mech_vent apachese center/ lackfit;
run;
ods pdf close;


proc logistic ;
   class center ;
   model hospital_death(event='1') =  sofa_tot  apachese center/ lackfit;
run;



proc logistic ;
   class center treatment;
   model hospital_death(event='1') = treatment sofa_tot mech_vent apachese center treatment*apachese/ lackfit;
run;
