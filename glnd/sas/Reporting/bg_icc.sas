
 proc sort data= glnd.followup_all_long;
 	by id day;
 run;
 
  * merge treatment info into a dataset that can be subsetted by treatment and used for plotting;
  proc sort data= glnd.george; by id; run;

 data follow_up_treat;
	merge 	glnd.followup_all_long
			glnd.george (keep = id treatment)
			;
	by id; 
run;

data x;
  set follow_up_treat;

    time=1; gluc=gluc_mrn; output;
    time=2; gluc=gluc_aft; output;
    time=3; gluc=gluc_eve; output;

keep id day treatment time gluc;
run;
data glnd.bg_iccraw;
   set x;
run;

/*
proc sort; by treatment;
proc mixed;
  by treatment; where day<=3;
   class id day treatment;
   model gluc= day treatment day*treatment/solution;
   repeated day*treatment / type= un subject=id ;
run;
endsas; 
*/

*ods select none;
proc sort; by day treatment id time;

ods ps file='bg_icc.ps';

proc nested;
  class id;
  by day treatment;
 var gluc;
ods output anova=anova;
;
run;
ods select all;
proc print data=anova;
  var day treatment source df varcomp percent;
run;
libname t '';
data t.bg_icc;
   set anova;
   ICC=percent/100;
  
   if varcomp <0 then varcomp=0;
symbol1 v=dot c=blue i=j l=1;
symbol2 v=circle c=red i=j l=2;
proc gplot;
  where source='id';
axis1 label=(r=0 a=90 'Between Variance Comp') order=0 to 3000 by 500;
axis2 order=0 to 28 by 7 minor=(n=6);

 plot varcomp*day=treatment / vaxis=axis1 haxis=axis2;

run;

proc gplot;
  where source='Error';
axis1 label=(r=0 a=90 'Within Variance Comp')  order=0 to 3000 by 500;;
axis2 order=0 to 28 by 7 minor=(n=6);

 plot varcomp*day=treatment / vaxis=axis1 haxis=axis2;

run;

proc gplot;
  where source='Total';
axis1 label=(r=0 a=90 'Total Variance')  order=0 to 3000 by 500;;
axis2 order=0 to 28 by 7 minor=(n=6);

 plot varcomp*day=treatment / vaxis=axis1 haxis=axis2;

run;

proc gplot;
axis1 label=(r=0 a=90 'ICC');
axis2 order=0 to 28 by 7 minor=(n=6);
 where source='id';
 plot ICC*day=treatment / vaxis=axis1 haxis=axis2;

run;


proc gplot;
axis1 label=(r=0 a=90 'Percent Between') order=0 to 100 by 10;;
axis2 order=0 to 28 by 7 minor=(n=6);
 where source='id';
 plot Percent*day=treatment / vaxis=axis1 haxis=axis2;

run;

proc gplot;
axis1 label=(r=0 a=90 'Percent Within') order=0 to 100 by 10;;
axis2 order=0 to 28 by 7 minor=(n=6);
 where source='Error';
 plot Percent*day=treatment / vaxis=axis1 haxis=axis2;

run;

